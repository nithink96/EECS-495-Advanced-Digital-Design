library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
entity matmultop is
port
(
signal clock : in std_logic;
signal reset : in std_logic;
signal start : in std_logic;
signal done : out std_logic;
signal x_wr_addr : in std_logic_vector (5 downto 0);
signal x_wr_en : in std_logic_vector (3 downto 0);
signal x_din : in std_logic_vector (31 downto 0);
signal y_wr_addr : in std_logic_vector (5 downto 0);
signal y_wr_en : in std_logic_vector (3 downto 0);
signal y_din : in std_logic_vector (31 downto 0);
signal z_rd_addr : in std_logic_vector (5 downto 0);
signal z_dout : out std_logic_vector (31 downto 0)
);
end entity matmultop;

architecture behavior of matmultop is
component matmul
port
(
signal clock : in std_logic;
signal reset : in std_logic;
signal start : in std_logic;
signal done : out std_logic;
signal x_dout : in std_logic_vector (31 downto 0);
signal x_addr : out std_logic_vector (5 downto 0);
signal y_dout : in std_logic_vector (31 downto 0);
signal y_addr : out std_logic_vector (5 downto 0);
signal z_din : out std_logic_vector (31 downto 0);
signal z_addr : out std_logic_vector (5 downto 0);
signal z_wr_en : out std_logic_vector (3 downto 0)
);
end component;
component bram_block is
generic (
constant BRAM_BUFFER_SIZE : integer := 1024;
constant BRAM_DATA_WIDTH : integer := 32;
constant BRAM_ADDR_WIDTH : integer := 10 );
port (
signal clock : in std_logic;
signal rd_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
signal wr_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
signal wr_en : in std_logic_vector (((BRAM_DATA_WIDTH / 8) - 1) downto 0);
signal dout : out std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0);
signal din : in std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0)
 );
end component;
component bram is
generic
(
	constant BRAM_BUFFER_SIZE : integer := 1024;
	constant BRAM_ADDR_WIDTH : integer := 10;
	constant BRAM_DATA_WIDTH : integer := 32
);
port
(
	signal clock : in std_logic;
	signal rd_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
	signal wr_addr : in std_logic_vector ((BRAM_ADDR_WIDTH - 1) downto 0);
	signal wr_en : in std_logic;
	signal dout : out std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0);
	signal din : in std_logic_vector ((BRAM_DATA_WIDTH - 1) downto 0)
);
end component bram;
signal x_dout : std_logic_vector (31 downto 0);
signal x_rd_addr : std_logic_vector (5 downto 0);
signal y_dout: std_logic_vector (31 downto 0);
signal y_rd_addr : std_logic_vector (5 downto 0);
signal z_din : std_logic_vector (31 downto 0);
signal z_wr_addr : std_logic_vector (5 downto 0);
signal z_wr_en : std_logic_vector (3 downto 0);
begin
matmul_inst : component matmul
port map (
clock => clock,
reset => reset,
start => start,
done => done,
x_dout => x_dout,
x_addr => x_rd_addr,
y_dout => y_dout,
y_addr => y_rd_addr,
z_din => z_din,
z_addr => z_wr_addr,
z_wr_en => z_wr_en);
x_inst : component bram_block
generic map(
BRAM_BUFFER_SIZE => 64,
BRAM_DATA_WIDTH => 32,
BRAM_ADDR_WIDTH => 6)
port map (
clock => clock,
rd_addr => x_rd_addr,
wr_addr => x_wr_addr,
wr_en => x_wr_en,
dout => x_dout,
din => x_din );
y_inst : component bram_block
generic map (
BRAM_BUFFER_SIZE => 64,
BRAM_DATA_WIDTH => 32,
BRAM_ADDR_WIDTH => 6)
port map(
clock => clock,
rd_addr => y_rd_addr,
wr_addr => y_wr_addr,
wr_en => y_wr_en,
dout => y_dout,
din => y_din);
z_inst : component bram_block
generic map (
BRAM_BUFFER_SIZE => 64,
BRAM_DATA_WIDTH => 32,
BRAM_ADDR_WIDTH => 6)
port map(
clock => clock,
rd_addr => z_rd_addr,
wr_addr => z_wr_addr,
wr_en => z_wr_en,
dout => z_dout,
din => z_din);
end architecture behavior;