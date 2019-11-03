library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Canny_Edge_Detection is

port(
        signal clk : in std_logic;
        signal reset : in std_logic;
        signal in_full : out std_logic;
        signal in_wr_en : in std_logic;
        signal in_din : in std_logic_vector (23  downto 0);
        signal out_rd_en : in std_logic;
        signal out_empty : out std_logic;
        signal out_dout : out std_logic_vector (7 downto 0)
);
end entity;

architecture structural of Canny_Edge_Detection is
signal gs_full,gs_empty,full_1,empty_1,full_2,empty_2:std_logic:='0';
signal gs_din: std_logic_vector(23 downto 0);
signal gray_out,sobel_in,sobel_out: std_logic_vector(7 downto 0);
signal in_rd_en1,out_wr_en1,in_rd_en2,out_wr_en2:std_logic:='0';
component fifo is
generic

(
	constant FIFO_DATA_WIDTH : integer := 24;
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
component edge_detect is
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
end component;
component sobel_detect is
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
end component;

begin

a_fifo : component fifo
generic map
(
	FIFO_DATA_WIDTH=>24,
	FIFO_BUFFER_SIZE=>48
)
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => reset,
        rd_en => in_rd_en1,
        wr_en => in_wr_en,
        din => in_din,
        dout => gs_din,
        full => full_1,
        empty => empty_1 
);
gray_scale: component edge_detect
port map
(
	 clk=>clk,
	 reset=>reset,
	fifo_full=>gs_full,
	fifo_empty=>empty_1,
	 din=>gs_din,
	in_rd_en=>in_rd_en1,
	out_wr_en=>out_wr_en1,
	 gray_scale=>gray_out
);

b_fifo : component fifo
generic map
(
    FIFO_DATA_WIDTH=>8,
    FIFO_BUFFER_SIZE=>16
)
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => reset,
        rd_en => in_rd_en2,
        wr_en => out_wr_en1,
        din => gray_out,
        dout => sobel_in,
        full => gs_full,
        empty => gs_empty 
);

sobel_detection: component sobel_detect
port map
(	clk=>clk,
	reset=>reset,
	din=>sobel_in,
	in_rd_en=>in_rd_en2,
    fifo_full=>full_2,
    fifo_empty=>gs_empty,
	out_wr_en=>out_wr_en2,
	sobel=>sobel_out
);
c_fifo : component fifo
generic map

(
 FIFO_DATA_WIDTH => 8,
 FIFO_BUFFER_SIZE => 16
)
    port map
    (
        rd_clk => clk,
        wr_clk => clk,
        reset => reset,
        rd_en => out_rd_en,
        wr_en => out_wr_en2,
        din => sobel_out,
        dout => out_dout,
        full => full_2,
        empty => empty_2
    );
    in_full<=full_2;
    out_empty<=empty_1;
end architecture structural;