library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is
constant EOF: std_logic_vector(7 downto 0):=x"03";
constant SOF: std_logic_vector(7 downto 0):=x"02";
constant PCAP_GLOBAL_HEADER_BYTES : natural := 24;
constant PCAP_DATA_HEADER_BYTES : natural := 16;
constant PCAP_DATA_LENGTH_BYTES : natural := 4;
constant ETH_DST_ADDR_BYTES:natural:=6;
constant ETH_SRC_ADDR_BYTES:natural:=6;
constant ETH_PROTOCOL_BYTES:natural:=2;
constant IP_VERSION_BYTES:natural:=1;
constant IP_HEADER_BYTES:natural:=1;
constant IP_TYPE_BYTES:natural:=1;
constant IP_LENGTH_BYTES:natural:=2;
constant IP_ID_BYTES:natural:=2;
constant IP_FLAG_BYTES:natural:=2;
constant IP_TIME_BYTES:natural:=1;
constant IP_PROTOCOL_BYTES:natural:=1;
constant IP_CHECKSUM_BYTES:natural:=2;
constant IP_SRC_ADDR_BYTES:natural:=4;
constant IP_DST_ADDR_BYTES:natural:=4;
constant UDP_DST_PORT_BYTES:natural:=2;
constant UDP_SRC_PORT_BYTES:natural:=2;
constant UDP_LENGTH_BYTES:natural:=2;
constant UDP_CHECKSUM_BYTES:natural:=2;
constant IP_PROTOCOL_DEF:std_logic_vector(15 downto 0):=x"0800";--#define IP_PROTOCOL_DEF 0x0800
constant IP_VERSION_DEF:std_logic_vector(3 downto 0):=x"4";--#define IP_VERSION_DEF 0x4
constant IP_HEADER_LENGTH_DEF:std_logic_vector(3 downto 0):=x"5";--#define IP_HEADER_LENGTH_DEF 0x5
constant IP_TYPE_DEF:std_logic_vector(3 downto 0):=x"0";
constant IP_FLAGS_DEF:std_logic_vector(3 downto 0):=x"4";--#define IP_FLAGS_DEF 0x4
constant TTL:std_logic_vector(3 downto 0):=x"e";
constant UDP_PROTOCOL_DEF:std_logic_vector(15 downto 0):=x"0800";
constant UDP_SUBLENGTH : natural := UDP_CHECKSUM_BYTES + UDP_LENGTH_BYTES + UDP_DST_PORT_BYTES + UDP_SRC_PORT_BYTES;
end package;