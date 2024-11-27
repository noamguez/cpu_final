LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


package aux_package_timer is

component BTCNT is
PORT( 
mcu_clk	:in std_logic;
clk, reset: in std_logic;
BTHOLD: in std_logic;
WRITE_ENA: in std_logic;   --- TO WRITE FRIM DATA BUS
BTIP : in std_logic_vector(2 downto 0);
BTCNT_WRITE_DATA: in std_logic_vector(31 downto 0);
BTCNT_READ_DATA: OUT std_logic_vector(31 downto 0);
set_BTIFG: OUT std_logic;
btctl_changed: in std_logic
);
END component;

component Basic_timer is
port (
clk, reset :in std_logic;
BTCTL_WRITE_ENA : in std_logic;
BTCNT_WRITE_ENA: in std_logic;
CCR0_WRITE_ENA: IN std_logic;
CCR1_WRITE_ENA: IN std_logic;
read_selctor: IN STD_LOGIC_VECTOR (1 downto 0);  
DATA_BUS_SIG_IN: IN STD_LOGIC_VECTOR (31 downto 0);
DATA_BUS_SIG_OUT: OUT STD_LOGIC_VECTOR (31 downto 0);
OUT_SIGNAL : OUT STD_LOGIC;
set_BTIFG: OUT std_logic
);
end component;

end aux_package_timer;