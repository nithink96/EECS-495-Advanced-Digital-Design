library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity cordic is
generic
(
	PI: std_logic_vector(15 downto 0):=(others=>'0');
	HALF_PI:std_logic_vector(15 downto 0):=(others=>'0')
	--radian: std_logic_vector(15 downto 0):=(others=>'0')
);
port
(
	signal clk : in std_logic;
	signal reset : in std_logic;
	signal theta : in std_logic_vector(15 downto 0);
	signal fifo_empty : in std_logic;
	signal fifo_full : in std_logic;
	signal new_read: in std_logic;
	signal in_rd_en,out_wr_en: out std_logic;
	signal CORDIC_1K: in std_logic_vector(15 downto 0);
	signal sine : out std_logic_vector(15 downto 0);
	signal cosine : out std_logic_vector(15 downto 0)
);
end entity;


architecture behavioral of cordic is

signal sine_c,cosine_c : std_logic_vector(15 downto 0);
signal x,y,z,xc,yc,zc:std_logic_vector(15 downto 0);
signal sin_array,cos_array:SLV_ARRAY(0 to 16):=(others=>(others=>'0'));
signal theta_array: SLV_ARRAY(0 to 16):=(others=>(others=>'0'));
signal cordic_table : SLV_ARRAY(0 to 15):=(x"3243", x"1DAC", x"0FAD", x"07F5", x"03FE", x"01FF", x"00FF", x"007F", x"003F", x"001F", x"000F", x"0007", x"0003", x"0001", x"0000", x"0000");
--type states is (init,cordic_state,done_state);
--signal state,next_state : states:=init;
--signal cordic_val: std_logic_vector_array :=(std_logic_vector(cordic_table(0)),std_logic_vector(cordic_table(1)),std_logic_vector(cordic_table(2)),std_logic_vector(cordic_table(3)),std_logic_vector(cordic_table(4)),std_logic_vector(cordic_table(5)),std_logic_vector(cordic_table(6)),std_logic_vector(cordic_table(7)),std_logic_vector(cordic_table(8)),std_logic_vector(cordic_table(9)),std_logic_vector(cordic_table(10)),std_logic_vector(cordic_table(11)),std_logic_vector(cordic_table(12)),std_logic_vector(cordic_table(13)),std_logic_vector(cordic_table(14)),std_logic_vector(cordic_table(15)));
signal valid_i:std_logic:='1';
signal valid_o:std_logic_vector(16 downto 0):=(others=>'0');
--signal done:std_logic_vector(14 downto 0):=(others=>'0');
--signal k: integer:=0;


component cordic_stage is
generic
(
	constant k: integer:=0;
	constant cordic_val: std_logic_vector(15 downto 0):=(others=>'0')
);
port
(
	--k: in integer;
--	c: in std_logic_vector(15 downto 0);
	clock: in std_logic;
	reset: in std_logic;
	x_i: in std_logic_vector(15 downto 0);
	y_i: in std_logic_vector(15 downto 0);
	z_i: in std_logic_vector(15 downto 0);
	valid_i : in std_logic;
	x_o: out std_logic_vector(15 downto 0);
	y_o: out std_logic_vector(15 downto 0);
	z_o: out std_logic_vector(15 downto 0);
	valid_o : out std_logic
);
end component;
begin
			
		l0:component cordic_stage
		generic map
		(
			k=>0,
			cordic_val=>cordic_table(0))
		port map
		(	
			clock=>clk,
			reset=>reset,
			x_i=>xc,
			y_i=>yc,
			z_i=>zc,
			valid_i=>valid_o(0),
			x_o=>cos_array(1),
			y_o=>sin_array(1),
			z_o=>theta_array(1),
			valid_o=>valid_o(1)
			);
		gen:for i in 1 to 15 generate 
		l1:component cordic_stage
		generic map
		(
			k=>i,
			cordic_val=>cordic_table(i))
		port map
		(	
			clock=>clk,
			reset=>reset,
			x_i=>cos_array(i),
			y_i=>sin_array(i),
			z_i=>theta_array(i),
			valid_i=>valid_o(i),
			x_o=>cos_array(i+1),
			y_o=>sin_array(i+1),
			z_o=>theta_array(i+1),
			valid_o=>valid_o(i+1)
			);
		end generate;

		--cos_array(0) <= yc;
	--	sin_array(0) <= xc;
	--	theta_array(0) <= zc;
		
			
	process(xc,yc,zc,fifo_empty,fifo_full,sin_array,cos_array) is
	--variable k: natural:=0;
	--variable rad:std_logic_vector(15 downto 0):=std_logic_vector(theta);
		begin

		if(new_read = '1') then
		valid_o(0) <= '1';
		xc<=(std_logic_vector(CORDIC_1K));	
		yc<=(others=>'0');
		zc<=(std_logic_vector(theta));	
		else 
		valid_o(0)<='0';
		end if;
		--next_state<=state;

		--done<=(others=>'0');
		--sine_c<= sin;
		--cosine_c<=cos;
	--	in_rd_en<='0';
	--	out_wr_en<='0';
--		case(state) is
--			when init => 
	--	if(fifo_empty ='0') then
	
				--	done<=(others=>'0');
			--		cosine_c<=0;
			--		sine_c<=0;
	--				next_state<= cordic_state;
	--			end if;
--			when cordic_state =>
				if(fifo_empty = '0' and fifo_full ='0') then
					in_rd_en <='1'; out_wr_en<='1';
					--for j in 0 to 15 loop
--					k:=k+1;
					if(signed(zc) > signed(HALF_PI)) then
						zc<=std_logic_vector(signed(zc) - signed(PI));
						xc<= std_logic_vector(0-signed(xc));
						yc<= std_logic_vector(0-signed(yc));
					elsif(signed(zc) < signed(HALF_PI)) then
						zc <=std_logic_vector(signed(zc) + signed(PI));
						xc<=std_logic_vector(0-signed(xc));
						yc<= std_logic_vector(0-signed(yc));
						
					end if;
				--for i in 0 to 15 loop
				if(valid_o(16) = '1') then
				sine<=sin_array(16);
				cosine<=cos_array(16);
			--	if(valid_o(15) = '1') then
			--	next_state<=done_state;
			--	else 
			--	next_state<=cordic_state;
				end if;
				end if;
--			when done_state => 
		--		next_state<=init;
				--done<=(others=>'0');
--			when others =>
	--			xc<=(others=>'0');
	--			yc<=(others=>'0');
	---			zc<=(others=>'0');
				--sine_c<=0;
	--			--cosine_c<=0;
	--			next_state<=init;
	--			in_rd_en<='0';
	--			out_wr_en<='0';
--			end case;

		end process;
		
--	process(clk,reset,sine_c,cosine_c) is 
--	begin
--		if(reset = '1') then
--			state<=init;
--			x<=(others=>'0');
--			y<=(others=>'0');
--			z<=(others=>'0');
--			sine<=(others=>'0');
--			cosine<=(others=>'0');
		--	sin<=0;
		--	cos<=0;
--		elsif(rising_edge(clk)) then
--			state<=next_state;
--			x<=xc;
--			y<=yc;
--			z<=zc;
--		--	for i in 0 to 15 loop
--			sine<=std_logic_vector(sine_c);
--			cosine<=std_logic_vector(cosine_c);
			--end loop;
		--	sin<=sine_c;
		--	cos<=cosine_c;
--		end if;
--	end process;
end architecture behavioral;