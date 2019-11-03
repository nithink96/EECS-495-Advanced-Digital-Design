
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bram_block is
generic
(
	constant BRAM_BUFFER_SIZE : integer := 1024;
	constant BRAM_DATA_WIDTH : integer := 32;
	constant BRAM_ADDR_WIDTH : integer := 10
);
port
(
	signal clock : in std_logic;
	signal rd_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
	signal wr_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
	signal wr_en : in std_logic_vector (((BRAM_DATA_WIDTH / 8) - 1) downto 0);
	signal dout : out std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0);
	signal din : in std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0)
);
end entity bram_block;


architecture structure of bram_block is 

	constant NUM_BYTES : integer := BRAM_DATA_WIDTH / 8;

	component bram
	generic
	(
		constant BRAM_BUFFER_SIZE : integer := 1024;
		constant BRAM_ADDR_WIDTH : integer := 10;
		constant BRAM_DATA_WIDTH : integer := 32
	);
	port
	(
		signal clock : in std_logic;
		signal din : in std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0);
		signal rd_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
		signal wr_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
		signal wr_en : in std_logic;
		signal dout : out std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0)
	);
	end component;

begin

	bram_blocks : for i in 0 to (NUM_BYTES - 1) generate

		bram_instance : component bram
		generic map
		(
			BRAM_BUFFER_SIZE => BRAM_BUFFER_SIZE,
			BRAM_ADDR_WIDTH => BRAM_ADDR_WIDTH,
			BRAM_DATA_WIDTH => 8
		)
		port map
		(
			clock => clock,
			din => din(((8 * (i + 1)) - 1) downto (8 * i)),
			rd_addr => rd_addr((BRAM_ADDR_WIDTH - 1) downto 0),
			wr_addr => wr_addr((BRAM_ADDR_WIDTH - 1) downto 0),
			wr_en => wr_en(i),
			dout => dout(((8 * (i + 1)) - 1) downto (8 * i))
		);

	end generate bram_blocks;


end architecture structure;
