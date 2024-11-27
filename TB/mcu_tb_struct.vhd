
--
USE work.AUX_package.all;

ENTITY MIPS_tb IS


END MIPS_tb ;

--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

LIBRARY work;


ARCHITECTURE struct OF MIPS_tb IS

   COMPONENT MCU IS
port(
clock, reset: in std_logic;
GPI_write_data : IN std_logic_vector(data_bus_size -1 downto 0);
PB1,PB2,PB3    : IN std_logic;
LEDR : OUT std_logic_vector(data_bus_size -1 downto 0);
HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : OUT std_logic_vector(6 downto 0);
OUT_SIGNAL: OUT STD_LOGIC;
GIE_OUT,INTR_OUT,INTA_OUT : OUT STD_LOGIC;
IF_INST_OUT,ID_INST_OUT,EXE_INST_OUT,DM_INST_OUT,WB_INST_OUT, K1_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
TYPE_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
PC_EXE_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SET_BTIFG_OUT : OUT STD_LOGIC;
RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT: out std_logic;
INTR_TMR_OUT: out INTEGER;
IF_TYPE_PC_EN: out std_logic;
IF_TYPE_PC: out STD_LOGIC_VECTOR(9 DOWNTO 0 );
pending_out : out std_logic_vector(7 downto 0);
served_out: out integer;
CS_ADRESS_ENABLE_OUT: out STD_LOGIC_VECTOR(15 DOWNTO 0 );
DATA_BUS_MCU_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
CS1_OUT, CS2_OUT, CS3_OUT, CS4_OUT, CS5_OUT, CS6_OUT, CS0_OUT, CS7_OUT, CS8_OUT, CS9_OUT, CS10_OUT, CS11_OUT:out STD_LOGIC;
ADRESS_0_OUT :out STD_LOGIC;
ena_interupt_to_bus_OUT, TIMER_WRITE_ENA_OUT, GPI_write_enable_OUT :out STD_LOGIC;
btctl_out :out std_logic_vector (7 downto 0);
 btcl0_out:out std_logic_vector(31 downto 0);
 btcl1_out:out std_logic_vector(31 downto 0);
 btcnt_out_verif:out std_logic_vector(31 downto 0);
 btccr0_out: out std_logic_vector(31 downto 0);
 btccr1_out: out std_logic_vector(31 downto 0);
 ADDRESS_BUS_OUT: OUT std_logic_vector(adress_size_vector -1 downto 0)

);

END COMPONENT;
   COMPONENT mcu_tester IS
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

   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   
 
	signal	reset,clock, OUT_SIGNAL :  std_logic;

	signal	GPI_write_data :  std_logic_vector(data_bus_size -1 downto 0);
	signal LEDR :  std_logic_vector(data_bus_size -1 downto 0);
	signal HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 :  std_logic_vector(6 downto 0);
    signal PB1,PB2,PB3    : std_logic;	
	SIGNAL GIE_OUT,INTR_OUT,INTA_OUT : STD_LOGIC;
	SIGNAL IF_INST_OUT,ID_INST_OUT,EXE_INST_OUT,DM_INST_OUT,WB_INST_OUT,K1_OUT,TYPE_OUT,PC_EXE_OUT:  	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL SET_BTIFG_OUT :  STD_LOGIC;
	SIGNAL RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT:  std_logic;
	SIGNAL INTR_TMR_OUT:  INTEGER;
	SIGNAL IF_TYPE_PC_EN:  std_logic;
	SIGNAL IF_TYPE_PC:  STD_LOGIC_VECTOR(9 DOWNTO 0 );
	SIGNAL pending_out : std_logic_vector(7 downto 0);
	SIGNAL served_out:  integer;
	SIGNAL CS_ADRESS_ENABLE_OUT:  STD_LOGIC_VECTOR(15 DOWNTO 0 );
	SIGNAL DATA_BUS_MCU_OUT:	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL CS1_OUT, CS2_OUT, CS3_OUT, CS4_OUT, CS5_OUT, CS6_OUT, CS0_OUT, CS7_OUT, CS8_OUT, CS9_OUT, CS10_OUT, CS11_OUT: STD_LOGIC;
	SIGNAL ADRESS_0_OUT : STD_LOGIC;
	SIGNAL ena_interupt_to_bus_OUT, TIMER_WRITE_ENA_OUT, GPI_write_enable_OUT : STD_LOGIC;
	SIGNAL btctl_out : std_logic_vector (7 downto 0);
	SIGNAL btcl0_out: std_logic_vector(31 downto 0);
	SIGNAL btcl1_out: std_logic_vector(31 downto 0);
	SIGNAL btcnt_out_verif: std_logic_vector(31 downto 0);
	SIGNAL btccr0_out:  std_logic_vector(31 downto 0);
	SIGNAL btccr1_out:  std_logic_vector(31 downto 0);
	SIGNAL ADDRESS_BUS_OUT:  std_logic_vector(adress_size_vector -1 downto 0);





BEGIN

   -- Instance port mappings.
   U_0 : MCU PORT MAP (
clock, reset,
GPI_write_data,
PB1,PB2,PB3,
LEDR,
HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,OUT_SIGNAL,
GIE_OUT,INTR_OUT,INTA_OUT,
IF_INST_OUT,ID_INST_OUT,EXE_INST_OUT,DM_INST_OUT,WB_INST_OUT,K1_OUT,
TYPE_OUT,
PC_EXE_OUT,
SET_BTIFG_OUT,
RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT,
INTR_TMR_OUT,
IF_TYPE_PC_EN,
IF_TYPE_PC,
pending_out,
served_out,
CS_ADRESS_ENABLE_OUT,
DATA_BUS_MCU_OUT,
CS1_OUT, CS2_OUT, CS3_OUT, CS4_OUT, CS5_OUT, CS6_OUT, CS0_OUT, CS7_OUT, CS8_OUT, CS9_OUT, CS10_OUT, CS11_OUT,
ADRESS_0_OUT,
ena_interupt_to_bus_OUT, TIMER_WRITE_ENA_OUT, GPI_write_enable_OUT,
btctl_out ,
 btcl0_out,
 btcl1_out,
 btcnt_out_verif,
 btccr0_out,
 btccr1_out,
 ADDRESS_BUS_OUT
);
   
   U_1 : mcu_tester PORT MAP (
clock, reset,
GPI_write_data,
PB1,PB2,PB3,
LEDR,
HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, OUT_SIGNAL,
GIE_OUT,INTR_OUT,INTA_OUT,
IF_INST_OUT,ID_INST_OUT,EXE_INST_OUT,DM_INST_OUT,WB_INST_OUT,K1_OUT,
TYPE_OUT,
PC_EXE_OUT, 
SET_BTIFG_OUT,
RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT,
INTR_TMR_OUT,
IF_TYPE_PC_EN,
IF_TYPE_PC,
pending_out,
served_out,
CS_ADRESS_ENABLE_OUT,
DATA_BUS_MCU_OUT,
CS1_OUT, CS2_OUT, CS3_OUT, CS4_OUT, CS5_OUT, CS6_OUT, CS0_OUT, CS7_OUT, CS8_OUT, CS9_OUT, CS10_OUT, CS11_OUT,
ADRESS_0_OUT,
ena_interupt_to_bus_OUT, TIMER_WRITE_ENA_OUT, GPI_write_enable_OUT,
btctl_out ,
 btcl0_out,
 btcl1_out,
 btcnt_out_verif,
 btccr0_out,
 btccr1_out,
 ADDRESS_BUS_OUT
);
   

END struct;
