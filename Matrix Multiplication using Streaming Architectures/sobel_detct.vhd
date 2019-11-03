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
	signal din: in std_logic_vector(7 downto 0);
	signal x,y: in natural;
	signal fifo_full: in std_logic;
	signal sobel: out std_logic_vector(7 downto 0);	
	signal done: out std_logic
);
end entity;

architecture behavioral of sobel_detect is

function sobel_func(buffer: 2Dstring;horizontal_operator: 2Dint; vertical_operator: 2Dint) return character is
variable horizontal_grad,vertical_grad: integer:=0;
variable v: integer:=0;
variable out_data: character;
begin


	for j in 0 to 2 loop
		for i in 0 to 2 loop
			horizontal_grad := horizontal_grad + integer'value(buffer(j)(i))*horizontal_operator(i)(j);
			horizontal_grad := vertical_grad + integer'value(buffer(j)(i))*vertical_operator(i)(j);
		end loop;
	end loop;
	v:= abs((horizontal_grad)+abs(vertical_grad))/2;
	if(v>255) then
		v:=255;
	else
		v:=v;
	end if;
	out_data:= character'val(v);
	return out_data;
end function sobel_func;

				


type String is array (0 to 2) of character;
type 2Dstring is array(0 to 2)of String;
type intarray is array (0 to 2) of integer;
type 2Dint is array(0 to 2) of intarray;
signal buffer: 2Dstring;
signal data:character;
signal in_data: integer;
signal out_data:String;
signal horizontal_operator: 2Dint:=(-1,0,1,-2,0,2,-1,0,1);
signal vertical_operator: 2Dint:=(-1,-2,-1,0,0,0,1,2,1);
begin 
	l2:process(clk)
	begin
		if(rising_edge(clk))then
		in_data<=to_integer(din);
				data<='0';
				if(x /= 0 and y /= 0 and x /= height-1 and y /=wid-1 and fifo_full = '0') then
					for j in -1 to 1 loop
						for  i in -1 to 1 loop
							buffer(j+1)(i+1) = in_data((y+j)*wid + (x+i));
						end loop;
					end loop;

					data = sobel_func(buffer,horizontal_operator,vertical_operator);
				end if;
				out_data(y*wid+x)<=data;
		end if;
 	end process l2;
 	l3:process(clk)
 		begin
 			if(rising_edge(clk)) then
 			for i in 0 to --some value loop
 				dout<= CONV_STD_LOGIC_VECTOR(character'pos(out_data),8);
 			end loop;
 			end if;
 		end process l3;
end architecture behavioral;

