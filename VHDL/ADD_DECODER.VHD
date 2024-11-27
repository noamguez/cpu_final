LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.AUX_package.all;
--------------------------------------
entity ADD_DECODER is
PORT ( 
 address_bus_sig :in std_logic_vector(adress_size_vector -1 downto 0);
CS0,CS1, CS2, CS3, CS4, CS5, CS6, CS7, CS8, CS9, CS10, CS11, CS12, CS13, CS14: OUT STD_LOGIC
);
END ADD_DECODER;

architecture ADD_DECODER_BEHAV OF ADD_DECODER is

begin
-------I/O------
CS7 <= '1' WHEN address_bus_sig = X"810" ELSE '0';        -- CHIP SELECT FOR SWITCHES
CS1 <= '1' WHEN address_bus_sig = X"800" ELSE '0';      -- CHIP SELECT FOR LEDS
CS2 <= '1' WHEN address_bus_sig = X"804" ELSE '0';   		   -- CHIP SELECT FOR HEX 0
CS3 <= '1' WHEN address_bus_sig = X"808" ELSE '0';   		   -- CHIP SELECT FOR HEX 2
CS4 <= '1' WHEN address_bus_sig = X"80C" ELSE '0';   			   -- CHIP SELECT FOR HEX 4
CS12 <= '1' WHEN address_bus_sig = X"805" ELSE '0';  			 -- CHIP SELECT FOR HEX 1
CS13 <= '1' WHEN address_bus_sig = X"809" ELSE '0';  			 -- CHIP SELECT FOR HEX 3
CS14 <= '1' WHEN address_bus_sig = X"80D" ELSE '0';  			 -- CHIP SELECT FOR HEX 5
-----BASIC TIMER--
CS8 <= '1' WHEN address_bus_sig = X"81C" ELSE '0';   					-- CHIP SELECT FOR BTCTL
CS9 <= '1' WHEN address_bus_sig = X"820" ELSE '0';      -- CHIP SELECT FOR BTCNT
CS10 <='1' WHEN address_bus_sig = X"824" ELSE '0';   		   -- CHIP SELECT FOR CCR0
CS11 <= '1' WHEN address_bus_sig = X"828" ELSE '0';   	   -- CHIP SELECT FOR CCR1

---INTERUPT CONTROLLER--
cs0 <= '1' WHEN address_bus_sig = X"82E" ELSE '0';      ---type register
cs5 <= '1' WHEN address_bus_sig = X"82C" ELSE '0';     -- IE register
cs6 <= '1' WHEN address_bus_sig = X"82D" ELSE '0';     -- ifg register


END ADD_DECODER_BEHAV;