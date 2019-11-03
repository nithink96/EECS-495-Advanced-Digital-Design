library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

package functions is
    function QUANTIZE (n : signed) return signed;
    function QUANTIZE_F (n : real) return std_logic_vector;
    function DEQUANTIZE (n : signed) return signed;
    function GET_MSB (n : signed) return natural;

end package;

package body functions is

    function QUANTIZE (n : signed) return signed is
    begin
        return resize(shift_left(n, BITS), WORD);
    end function;

  function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, BITS), WORD);
    end function;

    function QUANTIZE_F (n : real) return std_logic_vector is
        variable scale : signed (WORD - 1 downto 0);
        variable temp : integer;
    begin
        scale := to_signed(1, WORD);
        scale := scale sll BITS;
        temp := integer(n * real(to_integer(scale)));
        return std_logic_vector(to_signed(temp, WORD)); 
    end function;

    function GET_MSB(n : signed) return natural is
    begin
        for i in n'length - 1 downto 0 loop
            if (n(i) = '1') then
                return i;
            end if;
        end loop;
        return 0;
    end function;

end package body;