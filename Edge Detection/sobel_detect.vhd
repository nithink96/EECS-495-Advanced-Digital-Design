library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity sobel_detect is
generic
(
	wid: natural:= 720;
	height: natural:=540
);
port
(
	signal clk: in std_logic;
	signal reset: in std_logic;
	signal in_rd_en:out std_logic;
	signal fifo_full,fifo_empty:in std_logic;
	signal out_wr_en: out std_logic;
	signal din: in std_logic_vector(7 downto 0);
	signal sobel: out std_logic_vector(7 downto 0)	
	--signal done: out std_logic
);
end entity;

architecture behavioral of sobel_detect is

--type String is array (0 to 2) of character;
--type twoDstring is array(0 to 2)of String;
type state_type is (s0,s1,s2,s3);
signal state,next_state:state_type:=s0;
constant reg_size:integer:=(wid*2)+3;
type array_slv is array(natural range<>) of std_logic_vector(7 downto 0);
signal shift_reg_c,shift_reg:array_slv(0 to reg_size-1);
signal in_rd_en_c,out_wr_en_c,ready,ready_c:std_logic;
type intarray is array (integer range<>) of integer;
signal buffer_val: array_slv(0 to 8);
signal data:std_logic_vector(7 downto 0);
signal x,x_c,y,y_c:integer:=0;
signal in_data: integer;
signal dout_o: std_logic_vector(7 downto 0);

function sobel_func(buffer_val: array_slv) return std_logic_vector is
variable horizontal_grad,vertical_grad: integer:=0; 
  
variable v: integer:=0;
variable out_data:std_logic_vector(7 downto 0);
constant horizontal_operator: intarray(0 to 8):=(-1,0,1,-2,0,2,-1,0,1);
constant vertical_operator: intarray(0 to 8):=(-1,-2,-1,0,0,0,1,2,1);
--variable out_data: integer;
begin

	for j in 0 to 2 loop
	for i in 0 to 2 loop
			horizontal_grad := horizontal_grad + (to_integer(unsigned(buffer_val(i+(j*3))))*horizontal_operator(j+(i*3)));
			vertical_grad := vertical_grad + (to_integer(unsigned(buffer_val(i+(j*3))))*vertical_operator(j+(i*3)));
		end loop;
	end loop;
	v:= abs((horizontal_grad)+abs(vertical_grad))/2;
	if(v<255) then
		v:=v;
	else 
		v:=255;
	end if;
	out_data:= std_logic_vector(to_unsigned(v,8));
	return out_data;
end function sobel_func;

begin 

	process(fifo_empty,state,fifo_full,din,shift_reg,x,y) is
	  variable grad   : std_logic_vector(7 downto 0);
	begin
	next_state <= state;
	shift_reg_c<=shift_reg;
        x_c <= x;
	y_c<=y;
        in_rd_en <= '0';
	out_wr_en<='0';
	for i in 0 to 2 loop
	for j in 0 to 2 loop
	buffer_val(i+3*j)<=shift_reg(i*wid+j);
	end loop;
	end loop;
	 grad := (others => '0');
        if ( (x /= 0) AND (x /= wid-1) AND (y /= 0) AND (y /= height-1) ) then
            grad := sobel_func(buffer_val);
        end if;
	case(state) is
	when s0=>
	--in_rd_en <= '0';
                if (fifo_empty = '0') then
                    shift_reg_c <= (others => (others => '0'));
                    next_state <= s1;
                    ready_c <= '0';
                end if;
	when s1=>
	if(fifo_empty = '0') then
	in_rd_en <= '1';
	shift_reg_c(0 to reg_size-2)<=shift_reg(1 to reg_size-1);
	shift_reg_c(reg_size-1)<=din;
	x_c<=x_c+1;
	if(x = wid-1)then
	x_c<=0;
	y_c<=y_c+1;
	end if;
	 if ( (y * wid + x) = (wid + 1) ) then
      x_c <= x - 1;
     y_c <= y - 1;
    next_state<=s2;
	end if;
	end if;
	when s2=>
	 if ( fifo_empty = '0' AND fifo_full = '0' ) then
     shift_reg_c(0 to reg_size-2) <= shift_reg(1 to reg_size-1);
                    shift_reg_c(reg_size-1) <= din;
                    x_c <= x + 1;
                    if ( x = wid - 1 ) then
                        x_c <= 0;
                        y_c <= y + 1;
                    end if;

                    sobel <= grad;
                    in_rd_en <= '1';
                    out_wr_en <= '1';
                    if ( y = height-2 AND x = wid-3 ) then
                        next_state <= s3;
                    else
                        next_state <= s2;
                    end if;
                end if;
	when s3=>
                if ( fifo_full = '0' ) then
                    x_c <= x + 1;
                    if ( x = wid - 1 ) then
                        x_c <= 0;
                        y_c <= y + 1;
                    end if;
                    sobel <= grad;
                    out_wr_en <= '1';
                    if ( (x = wid-1) AND (y = height-1) ) then
                        next_state <= s0;
                    end if;
                end if;
                
            when others =>
                x_c <= 0;
                y_c <= 0;
                shift_reg_c <= (others => (others => 'X'));
                next_state <= s0;
	end case;
	end process;
	process(clk)
	begin

		if(rising_edge(clk)) then
		state<=next_state;
		x<=x_c;
		y<=y_c;
		shift_reg<=shift_reg_c;
		end if;
	end process;
end architecture behavioral;

