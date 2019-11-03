library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity cordic_stage is
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
	reset:in std_logic;
	x_i: in std_logic_vector(15 downto 0);
	y_i: in std_logic_vector(15 downto 0);
	z_i: in std_logic_vector(15 downto 0);
	valid_i : in std_logic;
	x_o: out std_logic_vector(15 downto 0);
	y_o: out std_logic_vector(15 downto 0);
	z_o: out std_logic_vector(15 downto 0);
	valid_o : out std_logic
);
end entity;

architecture behavioral of cordic_stage is
begin

	clocked_process: process(clock,reset) is
	variable d: std_logic_vector(15 downto 0):=(others=>'0');
	begin
	if(reset = '1') then
		x_o<=(others=>'0');
		y_o<=(others=>'0');
		z_o<=(others=>'0');
		valid_o<='0';
	elsif(rising_edge(clock)) then	
		if(signed(z_i)>=0) then
			d:=(others=>'0');
		else
			d:=(others=>'1');
		end if;
		valid_o <= '0';
		if ( valid_i = '1' ) then
			x_o <= std_logic_vector(signed(x_i) - (signed(std_logic_vector(shift_right(signed(y_i),k)) xor d) - signed(d)));
			y_o<= std_logic_vector(signed(y_i) - (signed(std_logic_vector(shift_right(signed(x_i),k)) xor d) - signed(d)));
			z_o <= std_logic_vector(signed(z_i) - (signed(cordic_val xor d)- signed(d)));
			valid_o<='1';
		end if;
	end if;
		
	end process clocked_process;
end architecture;
