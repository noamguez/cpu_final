
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;

ENTITY mcu_tester IS
  port(
clock, reset: OUT std_logic;
GPI_write_data : OUT std_logic_vector(data_bus_size -1 downto 0);
PB1,PB2,PB3    :OUT std_logic;
LEDR : IN std_logic_vector(data_bus_size -1 downto 0);
HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : IN std_logic_vector(6 downto 0);
OUT_SIGNAL:IN STD_LOGIC;
GIE_OUT,INTR_OUT,INTA_OUT :IN STD_LOGIC;
IF_INST_OUT,ID_INST_OUT,EXE_INST_OUT,DM_INST_OUT,WB_INST_OUT, K1_OUT:IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
TYPE_OUT: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
PC_EXE_OUT: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SET_BTIFG_OUT : IN STD_LOGIC;
RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT: IN std_logic;
INTR_TMR_OUT: IN INTEGER;
IF_TYPE_PC_EN: IN std_logic;
IF_TYPE_PC: IN STD_LOGIC_VECTOR(9 DOWNTO 0 );
pending_out : IN std_logic_vector(7 downto 0);
served_out: IN integer;
CS_ADRESS_ENABLE_OUT: IN STD_LOGIC_VECTOR(15 DOWNTO 0 );
DATA_BUS_MCU_OUT: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
CS1_OUT, CS2_OUT, CS3_OUT, CS4_OUT, CS5_OUT, CS6_OUT, CS0_OUT, CS7_OUT, CS8_OUT, CS9_OUT, CS10_OUT, CS11_OUT:IN STD_LOGIC;
ADRESS_0_OUT :IN STD_LOGIC;
ena_interupt_to_bus_OUT, TIMER_WRITE_ENA_OUT, GPI_write_enable_OUT :IN STD_LOGIC;
btctl_out :IN std_logic_vector (7 downto 0);
 btcl0_out:IN std_logic_vector(31 downto 0);
 btcl1_out:IN std_logic_vector(31 downto 0);
 btcnt_out_verif:IN std_logic_vector(31 downto 0);
 btccr0_out: IN std_logic_vector(31 downto 0);
 btccr1_out: IN std_logic_vector(31 downto 0);
 ADDRESS_BUS_OUT: IN std_logic_vector(adress_size_vector -1 downto 0)

);

END mcu_tester ;

--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


ARCHITECTURE struct OF mcu_tester IS


   SIGNAL mw_U_0clk : std_logic;
   SIGNAL mw_U_0disable_clk : boolean := FALSE;
   SIGNAL mw_U_0switches : std_logic_vector(data_bus_size-1 downto 0);

   -- ModuleWare signal declarations(v1.9) for instance 'U_1' of 'pulse'
   SIGNAL mw_U_1pulse : std_logic :='0';


BEGIN

	
	
	
	GPI_write_data<= "00001001";
   -- ModuleWare code(v1.9) for instance 'U_0' of 'clk'
   u_0clk_proc: PROCESS
   BEGIN
      WHILE NOT mw_U_0disable_clk LOOP
         mw_U_0clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
   END PROCESS u_0clk_proc;
   mw_U_0disable_clk <= TRUE AFTER 100000000 ns;
   clock <= mw_U_0clk;

   -- ModuleWare code(v1.9) for instance 'U_1' of 'pulse'
   reset <=not( mw_U_1pulse);
   u_1pulse_proc: PROCESS
   
   BEGIN
      mw_U_1pulse <= 
         '0',
         '1' AFTER 20000 ps,
         '0' AFTER 120000 ps;
		 --'1' after 2000000 ps,
		-- '0' after 2050000 ps;
      WAIT;
    END PROCESS u_1pulse_proc;

   -- Instance port mappings.
   PBS_GEN: process
   begin
   PB1 <=  '1',
         '0' AFTER 5000  ns;
		 
   PB2 <=  '1',
           '0' AFTER 10000  ns;
		 
	PB3 <=  '1',
            '0' AFTER 12000  ns;
	   
   WAIT;
   end process;

END struct;
