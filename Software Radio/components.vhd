library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

package components is


component gain is
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        volume : in integer;
        din : in std_logic_vector (31 downto 0);
        in_empty : in std_logic;
        out_full : in std_logic;
        in_rd_en : out std_logic;
        dout : out std_logic_vector (31 downto 0);
        out_wr_en : out std_logic
    );
end component;

component fir_decimated is
    generic
    (
        TAPS : natural := 20;
        DECIMATION : natural := 8
    );
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        din : in std_logic_vector (31 downto 0);
        coeffs : in SLV_ARRAY(0 to TAPS - 1);
        in_empty : in std_logic;
        out_full : in std_logic;
        in_rd_en : out std_logic;
        dout : out std_logic_vector (31 downto 0);
        out_wr_en : out std_logic
    );
end component;
component fir is
generic
(	
		TAPS: natural:=20
--        DECIMATION:natural:=1
);
port
(
		clock:in std_logic;
		reset: in std_logic;
		din: in std_logic_vector(31 downto 0);--add coeffs
		coeffs : in SLV_ARRAY(0 to TAPS - 1);
		in_empty: in std_logic;
		out_full:in std_logic;
		in_rd_en: out std_logic; 
		out_wr_en: out std_logic;
		dout: out std_logic_vector(31 downto 0)
);
end component;

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

component demodulate is
generic
(
	GAIN: natural:= FM_DEMOD_GAIN
	);
port
(
	clock: in std_logic;
	reset: in std_logic;
	real_in : in std_logic_vector (31 downto 0);
    imag_in : in std_logic_vector (31 downto 0);
    real_empty : in std_logic;
    imag_empty : in std_logic;
    out_full : in std_logic;
    real_rd_en : out std_logic;
    imag_rd_en : out std_logic;
    dout : out std_logic_vector (31 downto 0);
    out_wr_en : out std_logic
    );
end component;

component multiply is
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        x_din : in std_logic_vector (31 downto 0);
        y_din : in std_logic_vector (31 downto 0);
        x_empty : in std_logic;
        y_empty : in std_logic;
        z_full : in std_logic;
        x_rd_en : out std_logic;
        y_rd_en : out std_logic;
        z_dout : out std_logic_vector (31 downto 0);
        z_wr_en : out std_logic
    );
end component;

component read_iq is
generic
(
    SAMPLES: natural:= 1
);
port
(
    clock: in std_logic;
    reset: in std_logic;
    din : in std_logic_vector(31 downto 0);
    din_empty: in std_logic;
    i_out_full:in std_logic;
    q_out_full:in std_logic;
    din_rd_en: out std_logic; 
    i_wr_en: out std_logic;
    q_wr_en: out std_logic;
    i_out: out std_logic_vector(31 downto 0);
    q_out: out std_logic_vector(31 downto 0)
    );
end component;

component fir_complex is
generic
(	
		TAPS: natural:=20;
        DECIMATION:natural:=1
);
port
(
		clock:in std_logic;
		reset: in std_logic;
		real_in: in std_logic_vector(31 downto 0);--add coeffs
        imag_in : in std_logic_vector(31 downto 0);
		real_in_empty: in std_logic;
        imag_in_empty: in std_logic;
		real_out_full:in std_logic;
        imag_out_full: in std_logic;
		real_in_rd_en: out std_logic;
        imag_in_rd_en: out std_logic; 
		real_out_wr_en: out std_logic;
        imag_out_wr_en: out std_logic;
		real_out: out std_logic_vector(31 downto 0);
        imag_out: out std_logic_vector(31 downto 0)
);
end component;
component iir is
generic
(	
		TAPS: natural:=20
);
port
(
		clock:in std_logic;
		reset: in std_logic;
		din: in std_logic_vector(31 downto 0);
	        coeffs_x : in SLV_ARRAY (0 to TAPS - 1);
        	coeffs_y : in SLV_ARRAY (0 to TAPS - 1);--add coeffs
		in_empty: in std_logic;
		out_full:in std_logic;
		in_rd_en: out std_logic;
		out_wr_en: out std_logic;
		dout: out std_logic_vector(31 downto 0)
);
end component;

component addsub is
    port 
    (
        clock : in std_logic;
        reset : in std_logic;
        left_din : in std_logic_vector (31 downto 0);
        right_din : in std_logic_vector (31 downto 0);
        left_in_empty : in std_logic;
        right_in_empty : in std_logic;
        left_out_full : in std_logic;
        right_out_full : in std_logic;
        left_in_rd_en : out std_logic;
        right_in_rd_en : out std_logic;
        left_dout : out std_logic_vector (31 downto 0);
        right_dout : out std_logic_vector (31 downto 0);
        left_out_wr_en : out std_logic;
        right_out_wr_en : out std_logic
    );
end component;


component radio is
port(
		clock: in std_logic;
		reset: in std_logic;
		din: in std_logic_vector(31 downto 0);
        input_wr_en : in std_logic;
        left_rd_en : in std_logic;
        right_rd_en : in std_logic;  
        input_full : out std_logic;
        left : out std_logic_vector(31 downto 0);
        right : out std_logic_vector(31 downto 0);
        left_empty : out std_logic;
        right_empty :out std_logic
    );
end component;

end package;