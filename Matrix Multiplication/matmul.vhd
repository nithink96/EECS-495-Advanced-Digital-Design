library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity matmul is
generic (
constant N : integer := 8;
constant AWIDTH : integer := 6
);
port (
signal clock : in std_logic;
signal reset : in std_logic;
signal start : in std_logic;
signal done : out std_logic;
signal x_dout : in std_logic_vector (31 downto 0);
signal x_addr : out std_logic_vector (AWIDTH-1 downto 0);
signal y_dout : in std_logic_vector (31 downto 0);
signal y_addr : out std_logic_vector (AWIDTH-1 downto 0);
signal z_din : out std_logic_vector (31 downto 0);
signal z_addr : out std_logic_vector (AWIDTH-1 downto 0);
signal z_wr_en : out std_logic_vector (3 downto 0)
);
end entity matmul;

architecture behavior of matmul is
TYPE state_type is (s0,s1);
signal state, next_state : state_type;
signal x_state, x_state_c : state_type;
signal y_state, y_state_c : state_type;
signal i, i_c, j, j_c : std_logic_vector(AWIDTH-1 downto 0);
signal xk, xk_c, yk, yk_c : std_logic_vector(AWIDTH-1 downto 0);
signal done_o, done_c : std_logic;
signal start_x, start_x_c, done_x, done_x_c : std_logic;
signal start_y, start_y_c, done_y, done_y_c : std_logic;
type ARRAY_SLV32 is array ( natural range <> ) of std_logic_vector (31 downto 0);
signal x, x_c, y, y_c : ARRAY_SLV32 (0 to N-1);


function MATMUL_N(A: ARRAY_SLV32(0 to N-1); B: ARRAY_SLV32(0 to N-1)) return std_logic_vector is
variable c : std_logic_vector(31 downto 0):= (others => '0');
begin 
 for m in 0 to N-1 loop
c := std_logic_vector(signed(c) + resize(signed(A(m)) * signed(B(m)), 32));
end loop ;
return c ;
end function MATMUL_N ; 
begin

read_x_process: process(start_x, x_dout, i, xk, x_state,done_x, x)
variable xk_tmp : std_logic_vector(AWIDTH-1 downto 0);
begin
x_addr <= (others => '0');
xk_c <= xk;
done_x_c <= done_x;
x_state_c <= x_state;
x_c<=x;
case ( x_state ) is
when s0 =>
xk_c <= (others => '0');
x_addr <= std_logic_vector(resize(unsigned(i) *
to_unsigned(N,AWIDTH),AWIDTH));
if ( start_x = '1' ) then
done_x_c <= '0';
x_state_c <= s1;
else
x_state_c <= s0;
end if;
when s1 =>
x_c(to_integer(unsigned(xk))) <= x_dout;
xk_tmp := std_logic_vector((unsigned(xk) +
to_unsigned(1,AWIDTH)) mod N);
x_addr <= std_logic_vector(resize(unsigned(i) *
to_unsigned(N,AWIDTH),AWIDTH) +
unsigned(xk_tmp));
xk_c <= xk_tmp;
if ( unsigned(xk) = to_unsigned(N-1,AWIDTH) ) then
done_x_c <= '1';
x_state_c <= s0;
else
x_state_c <= s1;
end if;
when OTHERS =>
x_addr <= (others => 'X');
xk_c <= (others => 'X');
done_x_c <= 'X';
x_state_c <= s0;
x_c <= (others => (others => 'X'));
end case;
end process read_x_process;

read_y_process : process(start_y, y_dout, j, yk, y_state, done_y, y)
variable yk_tmp : std_logic_vector(AWIDTH-1 downto 0) ;
begin
y_addr <= (others => '0');
yk_c <= yk;
done_y_c <= done_y;
y_state_c <= y_state;
for m in 0 to N-1 loop
y_c(m) <= y(m);
end loop;
case ( y_state ) is
when s0 =>
yk_c <= (others => '0');
y_addr <= j;
if ( start_y = '1' ) then
done_y_c <= '0';
y_state_c <= s1;
else
y_state_c <= s0;
end if;
when s1 =>
y_c(to_integer(unsigned(yk))) <= y_dout;
yk_tmp := std_logic_vector((unsigned(yk) +
to_unsigned(1,AWIDTH)) mod N);
y_addr <= std_logic_vector(resize(unsigned(yk_tmp)
* to_unsigned(N,AWIDTH),AWIDTH) +
unsigned(j));
yk_c <= yk_tmp;
if ( unsigned(yk) = to_unsigned(N-1,AWIDTH) ) then
done_y_c <= '1';
y_state_c <= s0;
else
y_state_c <= s1;
end if;
when OTHERS =>
y_addr <= (others => 'X');
yk_c <= (others => 'X');
done_y_c <= 'X';
y_state_c <= s0;
y_c <= (others => (others => 'X'));
end case;
end process read_y_process;

matmul_fsm_process : process(state, x, y, i, j, done_o, start, start_x,
start_y, done_x, done_y )
variable i_tmp, j_tmp : std_logic_vector(AWIDTH-1 downto 0);
variable c : std_logic_vector(31 downto 0);
begin
z_din <= X"00000000";
z_wr_en <= (others => '0');
z_addr <= (others => '0');
i_c <= i; j_c <= j;
done_c <= done_o;
next_state <= state;
start_x_c <= '0'; start_y_c <= '0';
case ( state ) is
when s0 =>
i_c <= (others => '0');
j_c <= (others => '0');
if ( start = '1' ) then
start_x_c <= '1';
start_y_c <= '1';
done_c <= '0';
next_state <= s1;
end if;
when s1 =>
if ( start_x = '0' and done_x = '1' and start_y = '0' and done_y =
'1' ) then
next_state <= s1;
j_c <= std_logic_vector((unsigned(j) +
to_unsigned(1,AWIDTH)) mod N);
z_din <= MATMUL_N(x,y);
z_addr <= std_logic_vector(resize(unsigned(i) *
to_unsigned(N,AWIDTH),AWIDTH) + unsigned(j));
z_wr_en <= "1111";
start_y_c <= '1';
if ( unsigned(j) = to_unsigned(N-1,AWIDTH) ) then
i_c <= std_logic_vector((unsigned(i) +
to_unsigned(1,AWIDTH)) mod N);
start_x_c <= '1';
if ( unsigned(i) = to_unsigned(N-1,AWIDTH) ) then
done_c <= '1';
next_state <= s0;
end if;
end if;
end if;
when OTHERS =>
z_din <= (others => 'X');
z_wr_en <= (others => 'X');
z_addr <= (others => 'X');
i_c <= (others => 'X');
j_c <= (others => 'X');
done_c <= 'X';
next_state <= s0;
end case;
end process matmul_fsm_process;

matmul_reg_process : process(reset, clock)
begin
if ( reset = '1' ) then
state <= s0;
i <= (others => '0');
j <= (others => '0');
done_o <= '0';
start_x <= '0';
start_y <= '0';
x_state <= s0;
xk <= (others => '0');
done_x <= '0';
x <= (others => (others => '0'));
y_state <= s0;
yk <= (others => '0');
done_y <= '0';
y <= (others => (others => '0'));
elsif ( rising_edge(clock) ) then
state <= next_state;
i <= i_c;
j <= j_c;
done_o <= done_c;
start_x <= start_x_c;
start_y <= start_y_c;
x_state <= x_state_c;
xk <= xk_c;
done_x <= done_x_c;
for m in 0 to 7 loop
x(m) <= x_c(m);
end loop;
y_state <= y_state_c;
yk <= yk_c;
done_y <= done_y_c;
for m in 0 to 7 loop
y(m) <= y_c(m);
end loop;
end if;
end process matmul_reg_process;
done <= done_o;
end architecture behavior;
