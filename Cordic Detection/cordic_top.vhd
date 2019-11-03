library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_top is
port
(
	clock: in std_logic;
	reset: in std_logic;
	input: in std_logic_vector(15 downto 0);
	in_rd_en: in std_logic;
	out_wr_en: in std_logic;
	fifo_full: out std_logic;
	fifo_empty: out std_logic;
	CORDIC_1K : in std_logic_vector(15 downto 0);
	PI: in std_logic_vector(15 downto 0);
	HALF_PI:in std_logic_vector(15 downto 0);
	sine: out std_logic_vector(15 downto 0);
	cosine: out std_logic_vector(15 downto 0)
	);
end entity;

architecture structural of cordic_top is

component cordic
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
	signal new_read:in std_logic;
	signal in_rd_en,out_wr_en: out std_logic;
	signal CORDIC_1K: in std_logic_vector(15 downto 0);
	signal sine : out std_logic_vector(15 downto 0);
	signal cosine : out std_logic_vector(15 downto 0)
);
end component;

component fifo is
generic
(
	constant FIFO_DATA_WIDTH : integer := 16;
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
	signal empty : out std_logic;
	signal new_read:out std_logic
);
end component fifo;

	signal new_read,new_read1,new_read2,wr_en1,wr_en2,wr_en3,empty1,full1,full2,full3,rd_en1,empty2,empty3: std_logic:='0';
	signal sin,cos,theta: std_logic_vector(15 downto 0):=(others=>'0');
begin

in_fifo: component fifo
		port map
		(
			rd_clk=>clock,
			wr_clk=>clock,
			reset=>reset,
			rd_en=>in_rd_en,
			wr_en=>wr_en1,
			din=> input,
			dout=>theta,
			full=>fifo_full,
			empty=>empty1,
			new_read=>new_read
			);

cordic_main: component cordic
			generic map
			(
				PI=>PI,
				HALF_PI=>HALF_PI
			)
			port map
			(
				clk=>clock,
				reset=>reset,
				theta=>theta,
				fifo_empty=>empty1,
				fifo_full=>full3,
				new_read=>new_read,
				in_rd_en=>rd_en1,
				out_wr_en=>wr_en1,
				CORDIC_1K=>CORDIC_1K,
				sine=>sin,
				cosine=>cos
				);

sin_fifo: component fifo
			port map
			(
				rd_clk=>clock,
				wr_clk=>clock,
				reset=>reset,
				rd_en=>rd_en1,
				wr_en=>wr_en1,
				din=>sin,
				dout=>sine,
				full=>full1,
				empty=>empty2,
				new_read=>new_read2
			);

cosine_fifo: component fifo
			port map
			(
				rd_clk=>clock,
				wr_clk=>clock,
				reset=>reset,
				rd_en=>rd_en1,
				wr_en=>wr_en1,
				din=>cos,
				dout=>cosine,
				full=>full2,
				empty=>empty3,
				new_read=>new_read2
			);

		full3<= full1 or full2;
		fifo_empty<=empty2 or empty3;
end architecture structural;



