LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;
-------------------------------

ENTITY MCU IS
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
END MCU;

architecture MCU_ARCH OF MCU IS

signal fpga_reset: std_logic;
---------I/O SIGNALS---------
signal data_bus_sig : std_logic_vector(31 downto 0);
signal address_bus_sig : std_logic_vector(adress_size_vector -1 downto 0);
signal cpu_write_enable,cpu_mem_write : std_logic;
signal cpu_write_data ,GPI_WRITE_DATA_32 : std_logic_vector(31 downto 0);
signal GPI_write_enable,MEM_READ : std_logic;
signal CS1, CS2, CS3, CS4, CS5, CS6, CS0, CS7, CS8, CS9, CS10, CS11,CS12,CS13,CS14: STD_LOGIC;
signal seven_sig_out :  std_logic_vector(6 downto 0);

---------BASIC TIMER SIGNALS-------
SIGNAL	BTCTL_WRITE_ENA : std_logic;
SIGNAL	BTCNT_WRITE_ENA: std_logic;
SIGNAL	CCR0_WRITE_ENA: std_logic;
SIGNAL	CCR1_WRITE_ENA: std_logic;
signal  TIMER_WRITE_ENA: std_logic;
SIGNAL	read_selctor  :  std_logic_vector(1 downto 0);
SIGNAL	DATA_BUS_SIG_IN : std_logic_vector(31 downto 0);
SIGNAL	DATA_BUS_SIG_OUT: std_logic_vector(31 downto 0);
SIGNAL	set_BTIFG: std_logic;

-----INERUPT CONTROLLER SIGNALS------
SIGNAL  IFG_in:  std_logic_vector(7 downto 0);
SIGNAL  ena_write_ifg:  std_logic;
SIGNAL  ena_write_ie:  std_logic;
SIGNAL  ena_write_type:  std_logic;
SIGNAL  GIE:  std_logic;
SIGNAL  inta:  std_logic;
SIGNAL  intr:  std_logic;
SIGNAL  ena_interupt_to_bus:  std_logic;
SIGNAL DATA_BUS_SIG_OUT_interupt:  std_logic_vector(7 downto 0);
SIGNAL DATA_BUS_SIG_OUT_interupt_32:  std_logic_vector(31 downto 0);
SIGNAL  read_selctor_intr:  std_logic_vector(1 downto 0);
signal sent_type: std_logic;
SIGNAL PB1_IFG, PB2_IFG, PB3_IFG,pb1_fallingedge,pb2_fallingedge,pb3_fallingedge : std_logic;
signal HEX0_ENA ,HEX1_ENA ,HEX2_ENA ,HEX3_ENA ,HEX4_ENA ,HEX5_ENA ,LEDR_ENA : std_logic;





	
begin
--------------OUTPUTS------------------------------
GIE_OUT <= GIE;
INTR_OUT <= INTR;
INTA_OUT <=INTA;
TYPE_OUT <=DATA_BUS_SIG_OUT_interupt_32;
SET_BTIFG_OUT <= set_BTIFG;
DATA_BUS_MCU_OUT <= data_bus_sig;
CS1_OUT <= CS1;
CS2_OUT<= CS2;
CS3_OUT<= CS3;
CS4_OUT<= CS4;
CS5_OUT<= CS5;
CS6_OUT<= CS6;
CS0_OUT<= CS0;
CS7_OUT<= CS7;
CS8_OUT<= CS8;
CS9_OUT<= CS9;
CS10_OUT<= CS10;
CS11_OUT<= CS11;
ADRESS_0_OUT<= address_bus_sig(0);
ena_interupt_to_bus_OUT<= ena_interupt_to_bus;
TIMER_WRITE_ENA_OUT<= TIMER_WRITE_ENA;
GPI_write_enable_OUT<= GPI_write_enable;
ADDRESS_BUS_OUT <= address_bus_sig;


fpga_reset <= not(reset);


ADDRESS_TRANSLATOR: ADD_DECODER port map (
address_bus_sig, 
CS0 => CS0,
CS1 => CS1,
CS2 => CS2,
CS3 => CS3,
CS4 => CS4,
CS5 => CS5, 
CS6 => CS6,
CS7 => CS7,
CS8 => CS8,
CS9 => CS9,
CS10 => CS10,
CS11 => CS11,
CS12 => CS12,
CS13 => CS13,
CS14 => CS14
);

----------------------------------------------------
--------------------------------------------------------------------------
			--!!!!!!!!!!!!!!!!!!!!!!!!!!!--
					--REMINDER--
			-- GENERIC MAP 0 FOR MODELSIM
			-- GENERIC MAP 2 FOR QUARTUS

--------------------------------------------------------------------------
CPU: MIPS generic map(2) --------- REMEMBER  
port map(
		reset=> fpga_reset,
		clock=> clock,
		--interupts handling signals---
		intr => intr,
		inta => inta,
		GIE  => GIE,
		K1_OUT=> K1_OUT,
		PC_EXE_OUT=>PC_EXE_OUT,
		RETI_EX_OUT=>RETI_EX_OUT,
		RETI_ID_OUT=>RETI_ID_OUT,
		jump_occurred_DM_OUT=>jump_occurred_DM_OUT,
		k1en_OUT=>k1en_OUT,
		INTR_TMR_OUT => INTR_TMR_OUT,
		IF_TYPE_PC_EN=>IF_TYPE_PC_EN,
		IF_TYPE_PC=>IF_TYPE_PC,
		--------- pipeline lvl0   IF---------
		IF_PC_out=> open,
		IF_INSTUCTION_out=> IF_INST_OUT,
		IF_PC_SRC_OUT=> open,
		--------- pipeline lvl1   ID---------
		ID_INSTUCTION_out=> ID_INST_OUT,
		ID_read_data_1_out=> open,
		ID_read_data_2_out=> open,
		ID_write_data_out=> open,
		ID_SIGN_EXT_OUT=> open,
		ID_Regwrite_out=> open,
		--------- pipeline lvl2   EXE---------
		EXE_INSTUCTION_out=> EXE_INST_OUT,
		EXE_ALU_result_out=> open,
		EXE_AINPUT_OUT=> open,
		EXE_BINPUT_OUT=> open,
		EXE_MUX_AINPUT_OUT=> open,
		EXE_MUX_BINPUT_OUT=> open,
		EXE_Zero_out=> open,
		EXE_MUX_ADRESS_OUT=> open,
		--------- pipeline lvl3   DMEM---------
		DM_INSTUCTION_out=> DM_INST_OUT,
		DM_MEM_WRITE=> cpu_mem_write,
		DM_IO_READ => MEM_READ,
		DM_WRITE_DATA=> cpu_write_data,
		DM_READ_DATA=> open,
		DM_IO_READ_DATA=> data_bus_sig,
		DM_MEM_ADDRESS=> address_bus_sig,
		
		--------- pipeline lvl4   WB---------
		WB_INSTUCTION_out=> WB_INST_OUT,
		WB_write_data_out=> open,
		WB_REGWRITE=> open,
		WB_JAL_OUT=> open
		-------------------------------------------------
);

--------------------IO----------------------------------------------------------------------

--------------TRANSITION------------------------------


--------------ENABLES---------------------------------
cpu_write_enable <= cpu_mem_write AND address_bus_sig(11);
GPI_write_enable <= MEM_READ AND CS7;

-------------BI_DIR_PIN--------------------------------
		
CPU_DATA_WRITE: BidirPin generic map (32) port map (cpu_write_data ,cpu_write_enable,open,data_bus_sig);
GPI_DATA_WRITE:  BidirPin generic map (32) port map (GPI_WRITE_DATA_32,GPI_write_enable,open,data_bus_sig);

GPI_WRITE_DATA_32 <= X"000000" & GPI_WRITE_DATA;
---Seven Segment---
seven_seg: hexcon port map(data_bus_sig(3 downto 0),seven_sig_out);

------------------------------------------------------------------------------------------
-------Basic Timer------------------------------------------------------------------------
timer_module: Basic_timer port map (
	clk => clock,
	reset => fpga_reset,
	BTCTL_WRITE_ENA => BTCTL_WRITE_ENA,
	BTCNT_WRITE_ENA => BTCNT_WRITE_ENA,
	CCR0_WRITE_ENA => CCR0_WRITE_ENA,
	CCR1_WRITE_ENA => CCR1_WRITE_ENA,
	read_selctor   => read_selctor,
	DATA_BUS_SIG_IN => DATA_BUS_SIG_IN,
	DATA_BUS_SIG_OUT => DATA_BUS_SIG_OUT,
	OUT_SIGNAL  =>	OUT_SIGNAL, 
	set_BTIFG	=> set_BTIFG,
	btctl_out => btctl_out,
	btcl0_out=> btcl0_out,
	btcl1_out => btcl1_out,
	btcnt_out_verif => btcnt_out_verif,
	btccr0_out => btccr0_out,
	btccr1_out => btccr1_out
	);
-------------BI_DIR_PIN--------------------------------
timer_write_dataBus: BidirPin generic map (32) port map (DATA_BUS_SIG_OUT ,TIMER_WRITE_ENA,open,data_bus_sig);
DATA_BUS_SIG_IN <= data_bus_sig;
-------------------------------------------------------
BTCTL_WRITE_ENA <= CS8 AND cpu_mem_write;
BTCNT_WRITE_ENA <= CS9 AND cpu_mem_write;
CCR0_WRITE_ENA <= CS10 AND cpu_mem_write;
CCR1_WRITE_ENA <= CS11 AND cpu_mem_write;
TIMER_WRITE_ENA <= (CS8 OR CS9 OR CS10 OR CS11) AND (NOT cpu_mem_write);
read_selctor <= "11" WHEN CS8 = '1' ELSE "10" WHEN  CS11 = '1' ELSE "01" WHEN CS10 = '1' ELSE "00";  -- WHICH REGOSTER TO PUT ON DATA BUS  
------------------------------------------------------------------------------------------
------------OUTPUTS------------------------------------


--LEDR <= X"00" WHEN fpga_reset ='1' ELSE data_bus_sig(7 DOWNTO 0) when (cpu_mem_write and CS1) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX0 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS2 ) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX1 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS12) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX2 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS3) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX3 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS13) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX4 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS4) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;
--HEX5 <= B"1111111" WHEN fpga_reset ='1' ELSE seven_sig_out when (cpu_mem_write and CS14) = '1' AND (ena_interupt_to_bus or TIMER_WRITE_ENA or GPI_write_enable) = '0' else unaffected;

LEDR_ENA <= cpu_mem_write and CS1 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX0_ENA <= cpu_mem_write and CS2 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX1_ENA <= cpu_mem_write and CS12 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX2_ENA <= cpu_mem_write and CS3 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX3_ENA <= cpu_mem_write and CS13 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX4_ENA <= cpu_mem_write and CS4 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;
HEX5_ENA <= cpu_mem_write and CS14 AND  NOT ena_interupt_to_bus AND NOT TIMER_WRITE_ENA and NOT GPI_write_enable;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		LEDR <= X"00";
	elsif (clock'event and clock='0') then
		IF(LEDR_ENA = '1')THEN
			LEDR <= data_bus_sig(7 DOWNTO 0);
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX0 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX0_ENA = '1')THEN
			HEX0 <= seven_sig_out;
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX1 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX1_ENA = '1')THEN
			HEX1 <= seven_sig_out;
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX2 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX2_ENA = '1')THEN
			HEX2 <= seven_sig_out;
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX3 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX3_ENA = '1')THEN
			HEX3 <= seven_sig_out;
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX4 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX4_ENA = '1')THEN
			HEX4 <= seven_sig_out;
			END IF;
	END IF;
END process;

process (fpga_reset, CLOCK)
begin
	IF(fpga_reset = '1') then
		HEX5 <= B"1111111";
	elsif (clock'event and clock='0') then
		IF(HEX5_ENA = '1')THEN
			HEX5 <= seven_sig_out;
			END IF;
	END IF;
END process;
-------------------------------------------------------
--------INTERUPT CTR------------------------------------------------------------------
interupt_controller: interupt_ctr 
 port map(
 pending_out=> pending_out,
served_out=> served_out,
  clk => clock,
  reset => fpga_reset,
  read_selector => read_selctor_intr,
  IFG_in => IFG_in,
  ena_write_ifg => ena_write_ifg,
  ena_write_ie => ena_write_ie,
  ena_write_type => ena_write_type,
  DATA_BUS_SIG_IN => data_bus_sig(7 downto 0),
  GIE_IN => GIE,
  inta => inta,
  intr => intr,
  sent_type => sent_type,
  DATA_BUS_SIG_OUT => DATA_BUS_SIG_OUT_interupt
  );


ena_write_ifg <= cs6 and cpu_mem_write;
ena_write_ie  <= cs5 and cpu_mem_write;
ena_write_type<= cs0 and cpu_mem_write;

IFG_in <= "00"& PB3_IFG & PB2_IFG & PB1_IFG & set_BTIFG & "00";
read_selctor_intr <= "10" when cs5 = '1' else "01" when cs6 = '1' else "00";
ena_interupt_to_bus <= not(inta) or ((cs5 or cs6 or cs0) and MEM_READ) or sent_type;
DATA_BUS_SIG_OUT_interupt_32 <= X"000000" & DATA_BUS_SIG_OUT_interupt;
interupt_write_dataBus: BidirPin generic map (32) port map (DATA_BUS_SIG_OUT_interupt_32 ,ena_interupt_to_bus,open,data_bus_sig);
------------------------------
----interupt handler

process(PB1,clock,fpga_reset)
begin
	if(fpga_reset = '1') then
		PB1_IFG <= '0';
		pb1_fallingedge <= '0';
	elsif(PB1 ='0' and pb1_fallingedge = '0') then
		PB1_IFG <= '1';
		pb1_fallingedge <= '1';
	elsif(PB1 ='1') then
		pb1_fallingedge <= '0';
	elsif (clock'event and clock='1') then
				if(pb1_fallingedge = '1') then 
					PB1_IFG <= '0';
				end if;
	end if;
end process;
	

process(PB2,clock,fpga_reset)
begin
	if(fpga_reset = '1') then
		PB2_IFG <= '0';
		pb2_fallingedge <= '0';
	elsif(PB2 ='0' and pb2_fallingedge = '0') then
		PB2_IFG <= '1';
		pb2_fallingedge <= '1';
	elsif(PB2 ='1') then
		pb2_fallingedge <= '0';
	elsif (clock'event and clock='1') then
				if(pb2_fallingedge = '1') then 
					PB2_IFG <= '0';
				end if;
	end if;
end process;
	
process(PB3,clock,fpga_reset)
begin
	if(fpga_reset = '1') then
		PB3_IFG <= '0';
		pb3_fallingedge <= '0';
	elsif(PB3 ='0' and pb3_fallingedge = '0') then
		PB3_IFG <= '1';
		pb3_fallingedge <= '1';
	elsif(PB3 ='1') then
		pb3_fallingedge <= '0';
	elsif (clock'event and clock='1') then
				if(pb3_fallingedge = '1') then 
					PB3_IFG <= '0';
				end if;
	end if;
end process;


		process( clock, fpga_reset)
	begin
		if(fpga_reset='1') then
			sent_type <= '0';
		elsif (clock'event and clock='1') then
			if (intr='1') then--- AND ena_interupt_to_bus ='0'
				sent_type <='1';
			else --- ELSIF intr='1' AND ena_interupt_to_bus ='1'
				sent_type <= '0';
			end if;
		end if;
	end process;
	
	
---------- if timer=1 type=>bus 


END MCU_ARCH;