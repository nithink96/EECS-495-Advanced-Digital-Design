library IEEE;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.MATH_real.all;
--use work.constants.all;
package constants is
type SLV_ARRAY is array(natural range <>) of std_logic_vector(15 downto 0);
type signed_array is array (0 to 15) of signed(15 downto 0);
type intarray is array (0 to 15) of integer;
constant BITS: integer:=14;
constant quant_value: std_logic_vector(15 downto 0):= std_logic_vector(to_unsigned(1,16) sll BITS);
constant K:real:= 1.646760258121066;
constant MATH_PI180: real:=0.017453292519943;
end package;