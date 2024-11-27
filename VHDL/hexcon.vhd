library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity hexcon is
port( 
	  
	  input:in std_logic_vector(3 downto 0);
	  output:out std_logic_vector(6 downto 0)
);
end hexcon;
--------------------------------------------------------------
architecture hex_arc of hexcon is
begin                                   

with input(3 downto 0) select
output <= NOT("0111111") WHEN "0000",
		NOT("0000110") when "0001",
		NOT("1011011") when "0010",
		NOT("1001111") when "0011",
		NOT("1100110") when "0100",
		NOT("1101101") when "0101",
		NOT("1111101") when "0110",
		NOT("0000111") when "0111",
		NOT("1111111") when "1000",
		NOT("1100111") when "1001",
		NOT("1110111") when "1010",
		NOT("1111100") when "1011",
		NOT("0111001") when "1100",
		NOT("1011110") when "1101",
		NOT("1111001") when "1110",
		NOT("1110001") when "1111",
		unaffected when others;

end hex_arc;
