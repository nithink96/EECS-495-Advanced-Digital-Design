library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.functions.all;

entity gain is
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
end entity;

architecture behavioral of gain is
    type states is (init,exec);
    signal state, next_state : states := init;
begin

    gain_process : process (state, din, in_empty, out_full, volume)
    begin
        next_state <= state;

        in_rd_en <= '0';
        out_wr_en <= '0';
        dout <= (others => '0');

        case (state) is
            when init =>
                if (in_empty = '0') then
                    next_state <= exec;
                end if;

            when exec =>
                if (in_empty = '0' and out_full = '0') then
                    in_rd_en <= '1';
                    dout <= std_logic_vector(shift_left(DEQUANTIZE(signed(din) * volume), 14 - BITS));
                    out_wr_en <= '1';
                end if;

            when others =>
                next_state <= state;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= init;
        elsif (rising_edge(clock)) then
            state <= next_state;
        end if;
    end process;

end architecture;