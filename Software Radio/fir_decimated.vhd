library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.functions.all;

entity fir_decimated is
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
end entity;

architecture behavioral of fir_decimated is
    type states is(init,exec,dec);
    signal state, next_state : states := init;
    signal data_buffer, data_buffer_c : SLV_ARRAY (0 to TAPS - 1);
    signal dec_count, dec_count_c : natural;
begin

    filter_process : process (state, data_buffer, dec_count, din, in_empty, out_full, coeffs)
        variable sum : signed (31 downto 0) := (others => '0');
        variable data_buffer_v : SLV_ARRAY (0 to TAPS - 1) := (others => (others => '0'));
    begin
        next_state <= state;
        data_buffer_c <= data_buffer;
        dec_count_c <= dec_count;

        in_rd_en <= '0';
        out_wr_en <= '0';
        dout <= (others => '0');

        sum := (others => '0');
        data_buffer_v := (others => (others => '0'));

        case (state) is
            when init =>
                if (in_empty = '0') then
                    dec_count_c <= 0;
                    next_state <= exec;
                end if;

            when exec =>
                if (in_empty = '0') then
                    in_rd_en <= '1';
                    for i in TAPS - 1 downto 1 loop
                        -- shift buffer
                        data_buffer_v(i) := data_buffer(i - 1);
                    end loop;
                    data_buffer_v(0) := din;
                    data_buffer_c <= data_buffer_v;

                    dec_count_c <= dec_count + 1;
                    if (dec_count = DECIMATION - 1) then
                        next_state <= dec;
                    end if;
                end if;

            when dec =>
                if (out_full = '0') then
                    for i in 0 to TAPS - 1 loop
                        sum := sum + signed(DEQUANTIZE(signed(coeffs(TAPS - 1 - i)) * signed(data_buffer(i))));

                    end loop;
                    dout <= std_logic_vector(sum);
                    out_wr_en <= '1';
                    dec_count_c <= 0;
                    next_state <= exec;
                end if;

            when others =>
                next_state <= state;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= init;
            data_buffer <= (others => (others => '0'));
            dec_count <= 0;
        elsif (rising_edge(clock)) then
            state <= next_state;
            data_buffer <= data_buffer_c;
            dec_count <= dec_count_c;
        end if;
    end process;

end architecture;