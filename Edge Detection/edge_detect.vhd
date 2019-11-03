library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity edge_detect is
generic
(
	wid: natural:= 720;
	height: natural:=540
);
port
(
	signal clk: in std_logic;
	signal reset: in std_logic;
	signal fifo_full,fifo_empty: in std_logic;
	signal din: in std_logic_vector(23 downto 0);
	signal in_rd_en:out std_logic;
	signal out_wr_en: out std_logic;
	signal gray_scale: out std_logic_vector(7 downto 0)
	--signal done: out std_logic
);
end entity;


architecture behavioral of edge_detect is


begin
	
	l1:process(clk)
	variable gs: std_logic_vector(15 downto 0);
	begin
	if(rising_edge(clk)) then
		if((fifo_full = '0') and (fifo_empty = '0')) then
		in_rd_en<='1';
		out_wr_en<='1';
		 gs := std_logic_vector((resize(unsigned(din(23 downto 16)),16) + resize(unsigned(din(15 downto 8)),16) + resize(unsigned(din(7 downto 0)),16)) / to_unsigned(3, 16));
		gray_scale<=gs(7 downto 0);		
		end if;
	end if;
	end process l1;
	--done<='1';
end architecture ;