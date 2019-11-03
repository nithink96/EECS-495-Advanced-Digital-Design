library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_real.all;
use work.constants.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity cordic_top_tb is
generic(
	    constant FILE_OUT_SIN : string (8 downto 1) := "sine.txt";
	    constant FILE_OUT_COS : string (10 downto 1) := "cosine.txt";
	constant Quant_val: integer:= to_integer(unsigned(quant_value));
	constant K: real:=1.646760258121066;
       	constant CLOCK_PERIOD : time := 10 ns
	);
	end entity;

architecture behavioral of cordic_top_tb is

function Quantize_F(f:real;size: integer) return std_logic_vector is
 variable scale : signed (size - 1 downto 0);
        variable temp : integer;
    begin
        scale := to_signed(1, size);
        scale := scale sll 10;
        temp := integer(f * real(to_integer(scale)));
        return std_logic_vector(to_signed(temp, size)); 
	--return std_logic_vector( to_signed(integer(trunc(f * (2.0 ** Quant_val))),size)  );
end function;

function Quantize_I(i:std_logic_vector) return std_logic_vector is
variable it: std_logic_vector(15 downto 0);
begin
	return std_logic_vector( signed(i) * (2 ** Quant_val));
end function;

function Dequantize_F(f:std_logic_vector(15 downto 0)) return std_logic_vector is
variable ft : std_logic_vector(15 downto 0);
begin
	ft:= std_logic_vector(to_signed(to_integer(signed(f))/Quant_val,16));
	return ft;
end function;

function Dequantize_I(i:std_logic_vector) return std_logic_vector is
begin
	return std_logic_vector( signed(i) / (2 ** Quant_val));
end function;


signal clock,reset,fifo_full,fifo_empty: std_logic:='0';
signal sine,cosine,input: std_logic_vector(15 downto 0);
signal out_errors: integer:=0;
signal in_rd_en,out_wr_en,in_rd_done,out_wr_done,hold_clock: std_logic:='0';
signal temp1K:real:=1.0/K; 
signal tempMPI2: real:=MATH_PI/2.0;
signal rad_temp: real:= MATH_PI/180.0;
signal radian : std_logic_vector(31 downto 0):=Quantize_F(rad_temp,32);
signal CORDIC_1K: std_logic_vector(15 downto 0):=Quantize_F(temp1K,16);  
signal PI:std_logic_vector(15 downto 0):= Quantize_F(MATH_PI,16) ;
signal HALF_PI:std_logic_vector(15 downto 0):=Quantize_F(tempMPI2,16);



component cordic_top is
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
end component;

begin
tb_inst: component cordic_top
		port map
		(
			clock=>clock,
			reset=>reset,
			input=>input,
			in_rd_en=>in_rd_en,
			out_wr_en=>out_wr_en,
			fifo_full=>fifo_full,
			fifo_empty=>fifo_empty,
			CORDIC_1K=>CORDIC_1K,
			PI=>PI,
			HALF_PI=>HALF_PI,
			sine=>sine,
			cosine=>cosine
		);


    clock_process : process
    begin
        clock <= '1';
        wait for  (CLOCK_PERIOD / 2);
        clock <= '0';
        wait for  (CLOCK_PERIOD / 2);
        if ( hold_clock = '1' ) then
            wait;
        end if;
    end process clock_process;


    reset_process : process
    begin
        reset <= '0';
        wait until  (clock = '0');
        wait until  (clock = '1');
        reset <= '0';
        wait until  (clock = '0');
        wait until  (clock = '1');
        reset <= '0';
        wait;
    end process reset_process;

    tb_process : process
        variable errors : integer := 0;
        variable warnings : integer := 0;
        variable start_time : time;
        variable end_time : time;
        variable ln1, ln2, ln3, ln4 : line;
    begin
--        wait until  (reset = '1');
        --wait until  (reset = '0');

        wait until  (clock = '0');
        wait until  (clock = '1');

        start_time := NOW;
        write( ln1, string'("@ ") );
        write( ln1, start_time );
        write( ln1, string'(": Beginning simulation...") );
        writeline( output, ln1 );

        wait until  (clock = '0');
        wait until  (clock = '1');
        wait until  (in_rd_done = '1');

        end_time := NOW;
        write( ln2, string'("@ ") );
        write( ln2, end_time );
        write( ln2, string'(": Simulation completed.") );
        writeline( output, ln2 );

        errors := out_errors;

        write( ln3, string'("Total simulation cycle count: ") );
        write( ln3, (end_time - start_time) / CLOCK_PERIOD );
        writeline( output, ln3 );
        write( ln4, string'("Total error count: ") );
        write( ln4, errors );
        writeline( output, ln4 );

        hold_clock <= '1';
        wait;
    end process tb_process;

read_data: process 
variable i:integer :=-360;
variable p:real;
begin
	--wait until(reset = '1');
	--wait until(reset = '0');
	while(i<=360) loop
	wait until(clock = '1');
	wait until(clock = '0');
	p:= MATH_PI/180.0;
	in_rd_en<='1';
	input<=std_logic_vector(resize(signed(radian)*i,16));
	i:=i+1;
	end loop;		
	wait until(clock = '1');
	wait until(clock ='0');
	in_rd_done<='1';
	input<=(others=>'0');
	in_rd_en<='0';
	wait;
end process;

write_process: process
	file s_file: text;
   file c_file : text; 
    variable ln1, ln2 : line; 
    variable i: integer:=-360;
    variable out_data_cmp_sin,out_data_cmp_cos : real := 0.0; 
    variable out_data_sin,out_data_cos:std_logic_vector(15 downto 0):=(others=>'0');
    begin
--    wait until (reset = '1'); 
   -- wait until (reset = '0'); 
    wait until (clock = '1'); 
    wait until (clock = '0');
         file_open( s_file,FILE_OUT_SIN, write_mode );
         file_open(c_file,FILE_OUT_COS,write_mode); 
         while(i<360) loop
         	i:=i+1;
         	wait until (clock = '0'); 
            out_wr_en <= '1';
            wait until (clock = '1'); 
            --wait until (clock = '0'); 
            out_data_sin := Dequantize_I(sine);
            out_data_cos := Dequantize_I(cosine);
            hwrite(ln1,out_data_sin);
	    writeline(s_file,ln1);
            hwrite(ln2,out_data_cos);
	    writeline(c_file,ln2);
        end loop;--Have to make changes.
      file_close(s_file);
	 file_close(c_file);
      out_wr_done<='1';
      wait;
      end process;
end architecture behavioral;
     
