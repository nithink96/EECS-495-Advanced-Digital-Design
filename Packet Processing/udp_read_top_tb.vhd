library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.constants.all;


entity udp_read_top_tb is
    generic
    (
    constant FILE_IN_NAME : string (14 downto 1) := "test_data.pcap";--change path
    constant FILE_OUT_NAME : string (10 downto 1) := "output.txt";
    constant FILE_CMP_NAME : string (11 downto 1) := "compare.txt";
    constant CLOCK_PERIOD : time := 2 ns
);
end entity;


architecture behavioral of udp_read_top_tb is

	function slv2hstr(slv: std_logic_vector) return string is
	variable hexlen: integer;
	variable longslv : std_logic_vector(127 downto 0) := (others => '0');
	variable hex : string(1 to 16);
	variable fourbit : std_logic_vector(3 downto 0);
	begin
	hexlen := (slv'left+1)/4;
	if (slv'left+1) mod 4 /= 0 then
	hexlen := hexlen + 1;
	end if;
	longslv(slv'left downto 0) := slv;
	for i in (hexlen -1) downto 0 loop
	fourbit := longslv(((i*4)+3) downto (i*4));
	case fourbit is
		when "0000" => hex(hexlen-i) := '0';
		when "0001" => hex(hexlen-i) := '1';
		when "0010" => hex(hexlen-i) := '2';
		when "0011" => hex(hexlen-i) := '3';
		when "0100" => hex(hexlen-i) := '4';
		when "0101" => hex(hexlen-i) := '5';
		when "0110" => hex(hexlen-i) := '6';
		when "0111" => hex(hexlen-i) := '7';
		when "1000" => hex(hexlen-i) := '8';
		when "1001" => hex(hexlen-i) := '9';
		when "1010" => hex(hexlen-i) := 'A';
		when "1011" => hex(hexlen-i) := 'B';
		when "1100" => hex(hexlen-i) := 'C';
		when "1101" => hex(hexlen-i) := 'D';
		when "1110" => hex(hexlen-i) := 'E';
		when "1111" => hex(hexlen-i) := 'F';
		when "ZZZZ" => hex(hexlen-i) := 'z';
		when "UUUU" => hex(hexlen-i) := 'u';
		when "XXXX" => hex(hexlen-i) := 'x';
		when others => hex(hexlen-i) := '?';
	end case;
	end loop;
	return hex(1 to hexlen);
end slv2hstr;


 function to_char (std: std_logic_vector)
    return character is
    begin
        return character'val(to_integer(unsigned(std)));
    end function;

    function to_slv (char: character)
    return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(character'pos(char), 8));
    end function;
        type raw_file is file of character;

 	signal clk : std_logic := '1';
	signal read_done,write_done:std_logic;
    --signal wr_clk : std_logic := '0';
        signal reset : std_logic := '0';    
	signal start : std_logic := '0';
	signal done : std_logic := '0';
	signal hold_clock: std_logic:='0';
	signal din: std_logic_vector(7 downto 0):=(others=>'0');
	signal dout: std_logic_vector(7 downto 0):=(others=>'0');
    signal leng: std_logic_vector(UDP_LENGTH_BYTES* 8 -1 downto 0);
	signal wr_en,rd_en,full,empty,len_rd_en,len_empty,buffer_reset,valid: std_logic:='0';	signal read_errors : natural := 0;	
component udp_read_top
port
(
	clk: in std_logic;
	reset: in std_logic;
	input_wr_en: in std_logic;
	output_rd_en: in std_logic;
	len_rd_en: in std_logic;
	din: in std_logic_vector(7 downto 0);
	dout: out std_logic_vector(7 downto 0);
	length: out std_logic_vector(UDP_LENGTH_BYTES*8 - 1 downto 0);
	input_full:out std_logic;
	output_empty: out std_logic;
	len_empty: out std_logic
	);
end component;
begin
	top: component udp_read_top
	port map
	(
		clk=>clk,
		reset=>reset,
		input_wr_en=>wr_en,
		output_rd_en=>rd_en,
		din=>din,
		dout=>dout,
		input_full=>full,
		output_empty=>empty,
		len_rd_en=>len_rd_en,
		length=>leng,
		len_empty=>len_empty
		
);

	 clock_process : process 
    begin 
        clk <= '1';
        clk <= '0'; 
        wait for CLOCK_PERIOD / 2; 
        clk <= '0'; 
        clk <= '1';
        wait for CLOCK_PERIOD / 2; 
        if (hold_clock = '1') then
            wait; 
        end if; 
    end process;

    reset_process: process 
    begin reset <= '0'; 
        wait until clk = '0'; 
        wait until clk = '1'; 
        reset <= '1'; 
        wait until clk = '0'; 
        wait until clk = '1'; 
        reset <= '0'; 
        wait; 
    end process;
     
file_read_process : process
file in_file : raw_file;
variable char : character;
variable ln1 : line;
variable i : integer := 0;
variable n_bytes : std_logic_vector(31 downto 0) := (others => '0');
begin
wait until  (reset = '1');
wait until  (reset = '0');
write( ln1, string'("@ ") );
write( ln1, NOW );
write( ln1, string'(": Loading file ") );write( ln1, FILE_IN_NAME );write( ln1, string'("...") );writeline( output, ln1 );
file_open( in_file, FILE_IN_NAME, read_mode );
wr_en <= '0';
--in_sof <= '0';in_eof <= '0';
din <= (others => '0');-- read global header
while ( not ENDFILE( in_file) and i < 24 ) loop
read( in_file, char );
i := i + 1;
end loop;
while ( not ENDFILE( in_file) ) loop
i := 0;
while ( not ENDFILE( in_file) and i < 16 ) loop
read( in_file, char );
if ( i >= 8 AND i < 12 ) then
n_bytes := to_slv(char) & n_bytes(31 downto 8);
end if;
i := i + 1;
end loop;
report "Number Bytes: " & slv2hstr(n_bytes);i := 0;
while ( not ENDFILE( in_file) and i < to_integer(unsigned(n_bytes)) ) loop
wait until (clk = '1');
wait until (clk = '0');
if ( full = '0' ) then
read( in_file, char );
--report
-- "Byte " & slv2hstr(std_logic_vector(to_unsigned(i,16))) & ": " & slv2hstr(to_slv(char));
din <= to_slv( char );
--in_sof <= if_cond(i = 0, '1', '0');
--in_eof <= if_cond(i = to_integer(unsigned(n_bytes))-1, '1', '0');
wr_en <= '1';
i := i + 1;
else
wr_en <= '0';
end if;
end loop;
end loop;
wait until (clk = '1');
wait until (clk = '0');
wr_en <= '0';
--in_sof <= '0';
--in_eof <= '0';
din <= (others => '0');
file_close( in_file );
write_done <= '1';
wait;
end process file_read_process;
	  read_output_process : process
        file output_file,cmp_file : text;
        variable char : std_logic_vector (7 downto 0);
        variable count : natural := 0;
        variable len : natural := 0;
        variable ln,l7 : line;
    begin
        wait until (start = '1');
        wait until (clk = '1');
        wait until (clk = '0');
        file_open (output_file, FILE_OUT_NAME, write_mode);
	file_open (cmp_file,FILE_CMP_NAME , read_mode);
        while (not ENDFILE(cmp_file)) loop
            len_rd_en <= '0';
            wait until (len_empty = '0');
            wait until (clk = '0');
            len_rd_en <= '1';
            wait until (clk = '1');
            len := to_integer(unsigned(leng));
            wait until (clk = '0');
            len_rd_en <= '0';
            for i in 0 to len loop
                wait until (clk = '0');
                rd_en <= '0';
                if (empty = '0') then
                    rd_en <= '1';
                    wait until (clk = '1');
		    write(l7, to_char(dout));
			writeline(output_file,l7);
                    readline (cmp_file, ln);
                    hread (ln, char);
                    count := count + 1;
                    if (unsigned(char) /= unsigned(dout)) then
                        read_errors <= read_errors + 1;
                        write (ln, string'("Error at line "));
                        write (ln, count);
                        write (ln, string'(": "));
                        hwrite (ln, char);
                        write (ln, string'(" != "));
                        hwrite (ln, dout);
                        writeline (output, ln);
                    end if;
                else
                    wait until (clk = '1');
                end if;
            end loop;
        end loop;
        file_close (output_file);
        done <= '1';
        wait;
    end process; 

    --file_write_process : process
	---file cmp_file : raw_file;
--	file out_file : raw_file;
--	variable char : character;
--	variable ln1, ln2, ln3 : line;
--	variable i : integer := 0;
--	variable out_data_read : std_logic_vector (7 downto 0);
--	variable out_data_cmp : std_logic_vector (7 downto 0);
--	begin
--		wait until  (reset = '1');
--		wait until  (reset = '0');
--		wait until  (clk = '1');
--		wait until  (clk = '0');
--		write( ln1, string'("@ ") );
--		write( ln1, NOW );
--		write( ln1, string'(": Comparing file ") );
--		write( ln1, FILE_OUT_NAME );
--		write( ln1, string'("...") );
--		writeline( output, ln1 );
--		file_open( out_file, FILE_OUT_NAME, write_mode);
--		file_open( cmp_file, FILE_CMP_NAME, read_mode );
--		rd_en <= '0';
--		i := 0;
--		while ( not ENDFILE(cmp_file) ) loop
--        len_rd_en<='0';
--		wait until ( clk = '1');
--		wait until ( clk = '0');
--
--		if ( empty = '0' ) then
--		rd_en <= '1';
 --       len_rd_en<='1';
--		read( cmp_file, char );
--		out_data_cmp := to_slv(char);
--		write(out_file, to_char(dout));-- 
--		write( ln3, string'("@ ") );
--		--write( ln3, NOW );
		-- write( ln3, string'(": ") );
		-- write( ln3, i );-- write( ln3, string'(": ") );
		-- hwrite( ln3, out_dout );-- writeline( output, ln3 );
--		if ( to_01(unsigned(dout)) /= to_01(unsigned(out_data_cmp)) ) then
--		read_errors <= read_errors + 1;
--		write( ln2, string'("@ ") );write( ln2, NOW );
--		write( ln2, string'(": ") );
--		write( ln2, FILE_OUT_NAME );
--		write( ln2, string'("(") );
--		write( ln2, i + 1 );
--		write( ln2, string'("): ERROR: ") );
--		hwrite( ln2, dout );
--		write( ln2, string'(" != ") );
---		hwrite( ln2, out_data_cmp );
--		write( ln2, string'(" at address 0x") );
--		hwrite( ln2, std_logic_vector(to_unsigned(i,32)) );
---		write( ln2, string'(".") );writeline( output, ln2 );-- uncomment to exit on errorexit;
--		end if;
--		i := i + 1;
--		else
--		rd_en <= '0';
--		end if;
--		end loop;
--		wait until (clk = '1');
--		wait until (clk = '0');
--		rd_en <= '0';
--	file_close( cmp_file );
--	file_close( out_file );
--	read_done <= '1';
--	wait;
--end process file_write_process;
 tb_process : process 
        variable errors : integer := 0; 
        variable warnings : integer := 0; 
        variable start_time : time; 
        variable end_time : time; 
        variable ln1, ln2, ln3, ln4 : line; 
    begin 
        wait until (reset = '1'); 
        wait until (reset = '0'); 
        --        wait until ((a_write_done = '1') and (b_write_done = '1'));
        wait until (clk = '0'); 
        wait until (clk = '1');
        start_time := NOW; 
        write( ln1, string'("@ ") ); 
        write( ln1, start_time ); 
        write( ln1, string'(": Beginning simulation...") ); 
        writeline( output, ln1 );
        start <= '1'; 
        wait until (clk = '0');
        wait until (clk = '1'); 
        start <= '0'; 
        wait until  (done = '1');
        end_time := NOW; 
        write( ln2, string'("@ ") ); 
        write( ln2, end_time ); 
        write( ln2, string'(": Simulation completed.") ); 
        writeline( output, ln2 );
	hold_clock<='1';
        wait; 
    end process tb_process;

end architecture;