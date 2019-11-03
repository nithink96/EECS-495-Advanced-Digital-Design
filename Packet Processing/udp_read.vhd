library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity udp_read is
port
(
	clock:in std_logic;
	reset: in std_logic;
	input_empty:in std_logic;
	output_full:in std_logic;
	len_full:in std_logic;
	input_dout: in std_logic_vector(7 downto 0);
	output_din: out std_logic_vector(7 downto 0);
	in_rd_en:out std_logic;
	out_wr_en:out std_logic;
	buffer_reset: out std_logic;
	length:out std_logic_vector(UDP_LENGTH_BYTES*8 - 1 downto 0);
	valid: out std_logic
	);
end entity;

architecture behavioral of udp_read is
	type states is (wait_for_sof, eth_dst_addr_state,eth_src_addr_state,eth_protocol_state, ip_v_header_state, ip_type_state,ip_length_state,ip_id_state,ip_flag_state,ip_time_state,ip_protocol_state,ip_checksum_state, ip_src_addr_state,ip_dst_addr_state,udp_dst_port_state,udp_src_port_state, udp_length_state, udp_checksum_state, read_udp_data_state, write_udp_data_state);
	signal state,next_state:states:=wait_for_sof;
	signal bytes_c,bytes:natural:=0;
	signal sum,sum_c:std_logic_vector(31 downto 0):=(others=>'0');
	signal checksum:std_logic_vector(15 downto 0):=(others=>'0');
	signal eth_dst_addr, eth_dst_addr_c : std_logic_vector (ETH_DST_ADDR_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal eth_src_addr, eth_src_addr_c : std_logic_vector (ETH_SRC_ADDR_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal eth_protocol, eth_protocol_c : std_logic_vector (ETH_PROTOCOL_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_version, ip_version_c : std_logic_vector (3 downto 0):=(others=>'0');
    signal ip_header, ip_header_c : std_logic_vector (3 downto 0):=(others=>'0');
    signal ip_type, ip_type_c : std_logic_vector (IP_TYPE_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_length, ip_length_c : std_logic_vector (IP_LENGTH_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_id, ip_id_c : std_logic_vector (IP_ID_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_flag, ip_flag_c : std_logic_vector (IP_FLAG_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_time, ip_time_c : std_logic_vector (IP_TIME_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_protocol, ip_protocol_c : std_logic_vector (IP_PROTOCOL_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_checksum, ip_checksum_c : std_logic_vector (IP_CHECKSUM_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_src_addr, ip_src_addr_c : std_logic_vector (IP_SRC_ADDR_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal ip_dst_addr, ip_dst_addr_c : std_logic_vector (IP_DST_ADDR_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal udp_dst_port, udp_dst_port_c : std_logic_vector (UDP_DST_PORT_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal udp_src_port, udp_src_port_c : std_logic_vector (UDP_SRC_PORT_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal udp_length, udp_length_c : std_logic_vector (UDP_LENGTH_BYTES * 8 - 1 downto 0):=(others=>'0');
    signal udp_checksum, udp_checksum_c : std_logic_vector (UDP_CHECKSUM_BYTES * 8 - 1 downto 0):=(others=>'0');
	 signal check_word, check_word_c : std_logic_vector (15 downto 0):=(others=>'0');

    begin
    	udp_process : process (state, bytes, sum, eth_dst_addr, eth_src_addr, eth_protocol, ip_version, ip_header, ip_type, ip_length, ip_id, ip_flag, ip_time, ip_protocol, ip_checksum, ip_src_addr, ip_dst_addr, udp_dst_port, udp_src_port, udp_length, udp_checksum, check_word, input_empty, output_full, input_dout)
		
    	variable sum_temp:std_logic_vector(31 downto 0):=(others=>'0');
    	variable checksum_temp : std_logic_vector(15 downto 0):=(others=>'0');
    	variable ip_version_temp : std_logic_vector(3 downto 0):=(others=>'0');
		begin

    	case(state) is
    	when wait_for_sof =>
    		      bytes_c <= 0;
                sum_c <= (others => '0');
                eth_dst_addr_c <= (others => '0');
                eth_src_addr_c <= (others => '0');
                eth_protocol_c <= (others => '0');
                ip_version_c <= (others => '0');
                ip_header_c <= (others => '0');
                ip_type_c <= (others => '0');
                ip_length_c <= (others => '0');
                ip_id_c <= (others => '0');
                ip_flag_c <= (others => '0');
                ip_time_c <= (others => '0');
                ip_protocol_c <= (others => '0');
                ip_checksum_c <= (others => '0');
                ip_src_addr_c <= (others => '0');
                ip_dst_addr_c <= (others => '0');
                udp_dst_port_c <= (others => '0');
                udp_src_port_c <= (others => '0');
                udp_length_c <= (others => '0');
                udp_checksum_c <= (others => '0');
                check_word_c <= (others => '0');
                if (input_empty = '0') then
                    in_rd_en <= '1';
                    end if;
				if ( (input_empty = '0') and (input_dout = SOF) ) then
					next_state <= eth_dst_addr_state;
				end if;

		when eth_dst_addr_state =>
			eth_dst_addr_c<=eth_dst_addr;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				eth_dst_addr_c <= std_logic_vector((unsigned(eth_dst_addr) sll 8) or resize(unsigned(input_dout),ETH_DST_ADDR_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod ETH_DST_ADDR_BYTES;
				if ( bytes_c = ETH_DST_ADDR_BYTES-1 ) then
				next_state <= eth_src_addr_state;
				end if;
			end if;

		when eth_src_addr_state =>
			eth_src_addr_c<=eth_src_addr;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				eth_src_addr_c <= std_logic_vector((unsigned(eth_src_addr) sll 8) or resize(unsigned(input_dout),ETH_SRC_ADDR_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod ETH_SRC_ADDR_BYTES;
				if ( bytes_c = ETH_DST_ADDR_BYTES-1 ) then
				next_state <= eth_protocol_state;
				end if;
			end if;

		when eth_protocol_state =>
			eth_protocol_c<=eth_protocol;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				eth_protocol_c <= std_logic_vector((unsigned(eth_protocol) sll 8) or resize(unsigned(input_dout),ETH_PROTOCOL_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod ETH_PROTOCOL_BYTES;
				if ( bytes_c = ETH_PROTOCOL_BYTES-1 ) then
				next_state <= ip_v_header_state;
				end if;
			end if;

		when ip_v_header_state =>
		ip_version_c<=ip_version;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_version_temp := input_dout(7 downto 4);
				ip_header_c<=input_dout(3 downto 0);
				ip_version_c<=ip_version_temp;
				bytes_c<=0;
				next_state <=ip_type_state;
				--eth_dst_addr_c := eth_dst_addr_t;
				if (unsigned(eth_protocol) /= unsigned(IP_PROTOCOL_DEF)) then
                        next_state <= wait_for_sof;
            end if;
          end if;

		when ip_type_state =>
		ip_type_c<=ip_type;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_type_c <= std_logic_vector((unsigned(ip_type) sll 8) or resize(unsigned(input_dout),IP_TYPE_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_TYPE_BYTES;
				if ( bytes_c = IP_TYPE_BYTES-1 ) then
					next_state <= ip_length_state;
					 if (unsigned(ip_version_c) /= unsigned(IP_VERSION_DEF)) then
                          next_state <= wait_for_sof;
                    end if;
				end if;
			end if;	

		when ip_length_state =>
		ip_length_c<=ip_length;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_length_c <= std_logic_vector((unsigned(ip_length) sll 8) or resize(unsigned(input_dout),IP_LENGTH_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_LENGTH_BYTES;
				if ( bytes_c = IP_LENGTH_BYTES-1 ) then
				next_state <= ip_id_state;
				end if;
			end if;


		when ip_id_state =>
		ip_id_c<=ip_id;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_id_c <= std_logic_vector((unsigned(ip_id) sll 8) or resize(unsigned(input_dout),IP_ID_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_ID_BYTES;
				if ( bytes_c = IP_ID_BYTES-1 ) then
				next_state <= ip_flag_state;
				sum_c <= std_logic_vector(unsigned(sum) + unsigned(ip_length) -20);
				end if;
			end if;


		when ip_flag_state =>
		ip_flag_c<=ip_flag;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_flag_c <= std_logic_vector((unsigned(ip_flag) sll 8) or resize(unsigned(input_dout),IP_FLAG_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_FLAG_BYTES;
				if ( bytes_c = IP_FLAG_BYTES-1 ) then
				next_state <= ip_time_state;
				end if;
			end if;


		when ip_time_state =>
		ip_time_c<=ip_time;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_time_c <= std_logic_vector((unsigned(ip_time) sll 8) or resize(unsigned(input_dout),IP_TIME_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_TIME_BYTES;
				if ( bytes_c = IP_TIME_BYTES-1 ) then
				next_state <= ip_protocol_state;
				end if;
			end if;


		when ip_protocol_state =>
		ip_protocol_c<=ip_protocol;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_protocol_c <= std_logic_vector((unsigned(ip_protocol) sll 8) or resize(unsigned(input_dout),IP_PROTOCOL_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_PROTOCOL_BYTES;
				if ( bytes_c = IP_PROTOCOL_BYTES-1 ) then
				next_state <= ip_checksum_state;
				end if;
			end if;


		when ip_checksum_state =>
			ip_checksum_c<=ip_checksum;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_checksum_c <= std_logic_vector((unsigned(ip_checksum) sll 8) or resize(unsigned(input_dout),IP_CHECKSUM_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_CHECKSUM_BYTES;
				if ( bytes_c = IP_VERSION_BYTES-1 ) then
				next_state <= ip_src_addr_state;
				 sum_c <= std_logic_vector(unsigned(sum) + unsigned(ip_protocol));
				 if (unsigned(ip_protocol) /= unsigned(UDP_PROTOCOL_DEF)) then
                            next_state <= wait_for_sof;
                        end if;
				end if;
			end if;


		when ip_src_addr_state =>	
		ip_src_addr_c<=ip_src_addr;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_src_addr_c <= std_logic_vector((unsigned(ip_src_addr) sll 8) or resize(unsigned(input_dout),IP_SRC_ADDR_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_SRC_ADDR_BYTES;
				if ( bytes_c = IP_SRC_ADDR_BYTES-1 ) then
				next_state <= ip_dst_addr_state;
				end if;
			end if;


		when ip_dst_addr_state =>
		ip_dst_addr_c<=ip_dst_addr;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				ip_dst_addr_c <= std_logic_vector((unsigned(ip_dst_addr) sll 8) or resize(unsigned(input_dout),IP_DST_ADDR_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod IP_DST_ADDR_BYTES;
				if ( bytes_c = IP_DST_ADDR_BYTES-1 ) then
				next_state <= udp_dst_port_state;
			    sum_c <= std_logic_vector(unsigned(sum) + unsigned(ip_src_addr(7 downto 4)) + unsigned(ip_src_addr(3 downto 0)));
				end if;
			end if;


		when udp_dst_port_state =>
			udp_dst_port_c<=udp_dst_port;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				udp_dst_port_c <= std_logic_vector((unsigned(udp_dst_port) sll 8) or resize(unsigned(input_dout),UDP_DST_PORT_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod UDP_DST_PORT_BYTES;
				if ( bytes_c = UDP_DST_PORT_BYTES-1 ) then
				next_state <= udp_src_port_state;
				sum_c <= std_logic_vector(unsigned(sum) + unsigned(ip_dst_addr(31 downto 16)) + unsigned(ip_dst_addr(15 downto 0)));
				end if;
			end if;
			
			
		when udp_src_port_state =>
			udp_src_port_c<=udp_src_port;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				udp_src_port_c <= std_logic_vector((unsigned(udp_src_port) sll 8) or resize(unsigned(input_dout),UDP_SRC_PORT_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod UDP_SRC_PORT_BYTES;
				if ( bytes_c = UDP_SRC_PORT_BYTES-1 ) then
				next_state <= udp_length_state;
			    sum_c <= std_logic_vector(unsigned(sum) + unsigned(udp_dst_port));

				end if;
			end if;
		when udp_length_state =>
			udp_length_c<=udp_length;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				udp_length_c <= std_logic_vector((unsigned(udp_length) sll 8) or resize(unsigned(input_dout),UDP_LENGTH_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod UDP_LENGTH_BYTES;
				if ( bytes_c = UDP_LENGTH_BYTES-1 ) then
				next_state <= udp_checksum_state;
				sum_c <= std_logic_vector(unsigned(sum) + unsigned(udp_src_port));

				end if;
			end if;
		when udp_checksum_state =>
			udp_checksum_c<=udp_checksum;
			if ( input_empty = '0' ) then
				in_rd_en <= '1';
				udp_checksum_c <= std_logic_vector((unsigned(udp_checksum) sll 8) or resize(unsigned(input_dout),UDP_CHECKSUM_BYTES*8));
				--eth_dst_addr_c := eth_dst_addr_t;
				bytes_c <= (bytes + 1) mod UDP_CHECKSUM_BYTES;
				if ( bytes_c = UDP_CHECKSUM_BYTES-1 ) then
				next_state <= read_udp_data_state;
			    sum_c <= std_logic_vector(unsigned(sum) + unsigned(udp_length));

				end if;
			end if;

		when read_udp_data_state =>
			out_wr_en<='0';
			output_din<=(others=>'0');
			sum_temp:=sum;
			if ( input_empty = '0' and output_full = '0' ) then
				in_rd_en <= '1';
				out_wr_en<='1';
				output_din<=input_dout;
				bytes_c<=(bytes+1) ;
			   check_word_c <= check_word(7 downto 0) & input_dout;
                if (bytes_c mod 2 = 0) then
                    sum_temp := std_logic_vector(unsigned(sum) + resize(unsigned(check_word), 32));
                end if;
                if (bytes_c = unsigned(udp_length) - UDP_SUBLENGTH - 1) then
                    bytes_c <= 0;
       	            next_state <= write_udp_data_state;
                    if (unsigned(udp_length) mod 2 = 0) then
                     
                    sum_temp := std_logic_vector(unsigned(sum_temp) + unsigned(check_word(7 downto 0) & input_dout));
                        else
                         
                            sum_temp := std_logic_vector(unsigned(sum_temp) + unsigned(input_dout));
                end if;
            	end if;
            	sum_c <= sum_temp;
  		 end if;

        when write_udp_data_state =>
        	 next_state <= wait_for_sof;
                sum_temp := std_logic_vector(resize(unsigned(sum(31 downto 16)) + unsigned(sum(15 downto 0)), 32));
                sum_c <= sum_temp;
                if (unsigned(sum_temp(31 downto 16)) = 0) then
                    checksum_temp := sum_temp(15 downto 0);
                    checksum_temp := not checksum_temp;
                    checksum <= checksum_temp;
                    if (unsigned(checksum_temp) = unsigned(udp_checksum)) then
                        valid <= '1';
                    else
                        buffer_reset <= '1';
                    end if;
                else
                    next_state <= write_udp_data_state;
                end if;

            when others =>
                next_state <= wait_for_sof;
        end case;
    end process;
	clock_procss:process(clock,reset)
	begin
		if(reset = '1') then
			 state <= wait_for_sof;
            bytes <= 0;
            sum <= (others => '0');
            eth_dst_addr <= (others => '0');
            eth_src_addr <= (others => '0');
            eth_protocol <= (others => '0');
            ip_version <= (others => '0');
            ip_header <= (others => '0');
            ip_type <= (others => '0');
            ip_length <= (others => '0');
            ip_id <= (others => '0');
            ip_flag <= (others => '0');
            ip_time <= (others => '0');
            ip_protocol <= (others => '0');
            ip_checksum <= (others => '0');
            ip_src_addr <= (others => '0');
            ip_dst_addr <= (others => '0');
            udp_dst_port <= (others => '0');
            udp_src_port <= (others => '0');
            udp_length <= (others => '0');
            udp_checksum <= (others => '0');
            check_word <= (others => '0');
        elsif(rising_edge(clock)) then
        	state <= next_state;
            bytes <= bytes_c;
            sum <= sum_c;
            eth_dst_addr <= eth_dst_addr_c;
            eth_src_addr <= eth_src_addr_c;
            eth_protocol <= eth_protocol_c;
            ip_version <= ip_version_c;
            ip_header <= ip_header_c;
            ip_type <= ip_type_c;
            ip_length <= ip_length_c;
            ip_id <= ip_id_c;
            ip_flag <= ip_flag_c;
            ip_time <= ip_time_c;
            ip_protocol <= ip_protocol_c;
            ip_checksum <= ip_checksum_c;
            ip_src_addr <= ip_src_addr_c;
            ip_dst_addr <= ip_dst_addr_c;
            udp_dst_port <= udp_dst_port_c;
            udp_src_port <= udp_src_port_c;
            udp_length <= udp_length_c;
            udp_checksum <= udp_checksum_c;
            check_word <= check_word_c;
        end if;
    end process;
	length <= std_logic_vector(unsigned(udp_length) - UDP_SUBLENGTH);		
end architecture behavioral;