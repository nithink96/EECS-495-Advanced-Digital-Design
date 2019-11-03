library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.functions.all;

entity read_iq is
generic
(
    SAMPLES: natural := 1
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
end entity;

architecture behavioral of read_iq is 

type states is (init,exec);
signal next_state,state: states :=init;
signal i_out_c,q_out_c: std_logic_vector(31 downto 0):=(others=>'0');
begin
read_iq_process: process(state,din,din_empty,i_out_full,q_out_full) is
        variable i : std_logic_vector (31 downto 0);
        variable q : std_logic_vector (31 downto 0);
        begin
        next_state <= state;
        din_rd_en <= '0';
        i_wr_en <= '0';
        q_wr_en <= '0';
       -- i_out_c <= (others =>'0');
        --q_out_c <= (others =>'0');
        i := (others => '0');
        q := (others => '0');
        case(state) is
        when init =>
                   if (din_empty = '0') then
                    next_state <= exec;
                    end if;
        when exec =>
                  if (din_empty = '0' and i_out_full = '0' and q_out_full = '0') then
                    din_rd_en <= '1';
                    i(15 downto 0) := din(31 downto 16);
                    i(31 downto 16) := (others => i(15)); 
                    i_out_c <= std_logic_vector(QUANTIZE(signed(i)));
                    i_wr_en <= '1';

                    
                    q(15 downto 0) := din(15 downto 0);
                    q(31 downto 16) := (others => q(15)); 
                    q_out_c <= std_logic_vector(QUANTIZE(signed(q)));
                    q_wr_en <= '1';
		    --next_state<=init;
                    end if;
        when others =>
                next_state<=init;
        end case;
    end process read_iq_process;

clock_process : process(clock,reset)
        begin
            if (reset = '1') then
            state <= init;
	    i_out<=(others=>'0');
	    q_out<=(others=>'0');
        elsif (rising_edge(clock)) then
            state <= next_state;
	    i_out<=i_out_c;
	    q_out<=q_out_c;
            end if;
    end process;
end architecture;
