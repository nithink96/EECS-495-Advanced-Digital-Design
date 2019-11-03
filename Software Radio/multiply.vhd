library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.functions.all;

entity multiply is
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
end entity;

architecture behavioral of multiply is
    type states is(init,exec);

    signal state, next_state : states := init;
begin

    multiply_process : process (state, x_din, y_din, x_empty, y_empty, z_full)
    begin
        next_state <= state;

        x_rd_en <= '0';
        y_rd_en <= '0';
        z_wr_en <= '0';
        z_dout <= (others => '0');

        case (state) is
            when init =>
                if (x_empty = '0' and y_empty = '0') then
                    next_state <= exec;
                end if;

            when exec =>
                if (x_empty = '0' and y_empty = '0' and z_full = '0') then
                    x_rd_en <= '1';
                    y_rd_en <= '1';
                    z_dout <= std_logic_vector(DEQUANTIZE(signed(x_din) * signed(y_din)));
                    z_wr_en <= '1';
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