LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
---------------------------------
ENTITY BTCNT is
PORT( 
mcu_clk:	in std_logic;
clk, reset: in std_logic;
BTHOLD: in std_logic;
WRITE_ENA: in std_logic;   --- TO WRITE FRIM DATA BUS
BTIP : in std_logic_vector(2 downto 0);
BTCNT_WRITE_DATA: in std_logic_vector(31 downto 0);
BTCNT_READ_DATA: OUT std_logic_vector(31 downto 0);
set_BTIFG: OUT std_logic;
btctl_changed: in std_logic
);
END BTCNT;

architecture BTCNT_ARCH OF BTCNT is
signal btcnt_data : std_logic_vector(31 downto 0);
signal ena: std_logic;
signal trigger_bit,rizing_edge: std_logic; ---- get out to signaltap
begin

ena <= not (BTHOLD);

process(clk, reset )
	variable btcnt_data_var : std_logic_vector(31 downto 0);
	begin
		if(reset = '1') then
			btcnt_data_var := x"00000000";
		elsif (clk'event and clk='1') then
				if(WRITE_ENA = '1') then 
					btcnt_data_var := BTCNT_WRITE_DATA;
				elsif(ena = '1') then 
					btcnt_data_var := btcnt_data_var + x"00000001";
					end if;
		end if;
		btcnt_data<=btcnt_data_var;
	end process;


BTCNT_READ_DATA <= btcnt_data;


trigger_bit <= btcnt_data(0) WHEN "000"= BTIP and btctl_changed = '0' else
		btcnt_data(3) WHEN "001"= BTIP and btctl_changed = '0' else
		btcnt_data(7) WHEN "010"= BTIP and btctl_changed = '0' else
		btcnt_data(11) WHEN "011"= BTIP and btctl_changed = '0' else
		btcnt_data(15) WHEN "100"= BTIP and btctl_changed = '0' else
		btcnt_data(19) WHEN "101"= BTIP and btctl_changed = '0' else
		btcnt_data(23) WHEN "110"= BTIP and btctl_changed = '0' else
		btcnt_data(25) WHEN "111"= BTIP and btctl_changed = '0' else
		'0';



process(trigger_bit,mcu_clk,reset)
begin
	if(reset = '1') then
		set_BTIFG <= '0';
		rizing_edge <= '0';
	elsif(trigger_bit ='1' and rizing_edge = '0') then
		set_BTIFG <= '1';
		rizing_edge <= '1';
	elsif(trigger_bit ='0') then
		rizing_edge <= '0';
	elsif (mcu_clk'event and mcu_clk='1') then
				if(rizing_edge = '1') then 
					set_BTIFG <= '0';
				end if;
	end if;
end process;

END BTCNT_ARCH;