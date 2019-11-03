// This example will strip the data segments from each UDP packet and write it to file.
// Use Wireshark (http://www.wireshark.org) to open the pcap data file.

// compile
g++ udp_reader.cpp -o udp_reader

// run the udp test with the input pcap file
./udp_reader test_data.pcap > output.txt

// compare output
diff output.txt results.txt
