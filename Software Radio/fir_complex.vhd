library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.functions.all;

entity fir_complex is
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
end entity;

architecture behavioral of fir_complex is
type SLV_ARRAY is array(natural range<>) of std_logic_vector(31 downto 0);
type states is (init,exec);
signal state, next_state : states := init;
signal real_buffer, real_buffer_c : SLV_ARRAY (0 to TAPS - 1) := (others => (others => '0'));
signal imag_buffer, imag_buffer_c : SLV_ARRAY (0 to TAPS - 1) := (others => (others => '0'));
signal dec_count, dec_count_c : natural:=0;
begin

	fir_complex_process: process(state,real_in,imag_in,real_buffer,imag_buffer,real_in_empty,imag_in_empty,real_out_full,imag_out_full) is
    variable sum_real,sum_imag : signed (31 downto 0) := (others => '0');
    variable real_buffer_v,imag_buffer_v : SLV_ARRAY (0 to TAPS - 1);

    begin
           next_state <= state;
        real_buffer_c <= real_buffer;
        imag_buffer_c <= imag_buffer;

        real_in_rd_en <= '0';
        imag_in_rd_en <= '0';
        real_out_wr_en <= '0';
        imag_out_wr_en <= '0';
        real_out <= (others => '0');
        imag_out <= (others => '0');

        sum_real := (others => '0');
        sum_imag := (others => '0');
        real_buffer_v := (others => (others => '0'));
        imag_buffer_v := (others => (others => '0')); 
        case(state) is
        when init =>
                   if (real_in_empty = '0' and imag_in_empty = '0') then
                    next_state <= exec;
                    end if;
        when exec =>
                if(real_in_empty = '0' and real_out_full = '0' and imag_in_empty = '0' and imag_out_full = '0')then
                    real_in_rd_en<='1';
                    imag_in_rd_en<='1';
                    for j in TAPS - 1 downto 1 loop
                        real_buffer_v(j):=real_buffer(j-1);
                    end loop;
                real_buffer_v(0) := real_in;
                real_buffer_c <= real_buffer_v;

                for j in TAPS - 1 downto 1 loop
                    imag_buffer_v(j):= imag_buffer(j-1);
                end loop;
                imag_buffer_v(0) := imag_in;
                imag_buffer_c <= imag_buffer_v;
                dec_count_c <= dec_count_c + 1;
                if(dec_count = DECIMATION - 1) then
                for i in 0 to TAPS - 1 loop
                        sum_real := sum_real + signed(DEQUANTIZE(signed(CHANNEL_COEFFS_REAL(i)) * signed(real_buffer_v(i)) - signed(CHANNEL_COEFFS_IMAG(i)) * signed(imag_buffer_v(i))));
                        sum_imag := sum_imag + signed(DEQUANTIZE(signed(CHANNEL_COEFFS_REAL(i)) * signed(imag_buffer_v(i)) - signed(CHANNEL_COEFFS_IMAG(i)) * signed(real_buffer_v(i))));
                    end loop;
		end if;
                real_out<= std_logic_vector(sum_real);
                imag_out <= std_logic_vector(sum_imag);
                real_out_wr_en <= '1';
                imag_out_wr_en <='1';
                dec_count_c <= 0;
                next_state <= exec;
                end if;

         when others =>
                next_state <= init;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= init;
            real_buffer <= (others => (others => '0'));
            imag_buffer <= (others => (others => '0'));
            dec_count <= 0;
        elsif (rising_edge(clock)) then
            state <= next_state;
            real_buffer <= real_buffer_c;
            imag_buffer <= imag_buffer_c;
            dec_count <= dec_count_c;
        end if;
    end process;

end architecture;