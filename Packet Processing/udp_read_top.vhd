library IEEE;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity udp_read_top is
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        input_wr_en : in std_logic;
        output_rd_en : in std_logic;
        len_rd_en : in std_logic;
        din : in std_logic_vector (7 downto 0);
        dout : out std_logic_vector (7 downto 0);
        length : out std_logic_vector (UDP_LENGTH_BYTES * 8 - 1 downto 0);
        input_full : out std_logic;
        output_empty : out std_logic;
        len_empty : out std_logic
    );
end entity;

architecture structural of udp_read_top is
    constant LENGTH_DATA_WIDTH : natural := UDP_LENGTH_BYTES * 8;
    signal input_dout : std_logic_vector (7 downto 0) := (others => '0');
    signal output_din : std_logic_vector (7 downto 0) := (others => '0');
    signal len_din : std_logic_vector (LENGTH_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal input_rd_en : std_logic := '0';
    signal output_wr_en : std_logic := '0';
    signal input_empty : std_logic := '0';
    signal output_full : std_logic := '0';
    signal output_reset : std_logic := '0';
    signal buffer_reset : std_logic := '0';
    signal len_full : std_logic := '0';
    signal valid : std_logic := '0';


component udp_read is
port
(
	clock:in std_logic;
	reset: in std_logic;
	input_empty:in std_logic;
	output_full:in std_logic;
	len_full:in std_logic;
	input_dout: in std_logic_vector(7 downto 0);
	output_din: out std_logic_vector(7 downto 0);
	in_rd_en:out std_logic;
	out_wr_en:out std_logic;
	buffer_reset: out std_logic;
	length:out std_logic_vector(UDP_LENGTH_BYTES*8 - 1 downto 0);
	valid: out std_logic
	);
end component;

component fifo is
generic

(
	constant FIFO_DATA_WIDTH : integer := 32;
	constant FIFO_BUFFER_SIZE : integer := 32
);
port
(
	signal rd_clk : in std_logic;
	signal wr_clk : in std_logic;
	signal reset : in std_logic;
	signal rd_en : in std_logic;
	signal wr_en : in std_logic;
	signal din : in std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
	signal dout : out std_logic_vector ((FIFO_DATA_WIDTH - 1) downto 0);
	signal full : out std_logic;
	signal empty : out std_logic
);
end component fifo;


begin

    input_fifo : fifo
    generic map
    (
        FIFO_DATA_WIDTH => 8,
        FIFO_BUFFER_SIZE => 1024
    )
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => reset,
        rd_en => input_rd_en,
        wr_en => input_wr_en,
        din => din,
        dout => input_dout,
        full => input_full,
        empty => input_empty
    );

    output_fifo : fifo
    generic map
    (
        FIFO_DATA_WIDTH => 8,
        FIFO_BUFFER_SIZE => 1024
    )
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => output_reset,
        rd_en => output_rd_en,
        wr_en => output_wr_en,
        din => output_din,
        dout => dout,
        full => output_full,
        empty => output_empty
    );

    length_fifo : fifo
    generic map
    (
        FIFO_DATA_WIDTH => LENGTH_DATA_WIDTH,
        FIFO_BUFFER_SIZE => 16
    )
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => reset,
        rd_en => len_rd_en,
        wr_en => valid,
        din => len_din,
        dout => length,
        full => len_full,
        empty => len_empty
    );

    reader : udp_read
    port map
    (
        clock =>clk,
        reset => reset,
        input_empty => input_empty,
        output_full => output_full,
        len_full => len_full,
        input_dout => input_dout,
        output_din => output_din,
        length => len_din,
        in_rd_en => input_rd_en,
        out_wr_en => output_wr_en,
        buffer_reset => buffer_reset,
        valid => valid
    );

    output_reset <= reset or buffer_reset;

end architecture;