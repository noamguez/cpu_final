LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


package aux_package is

constant ALU_OP_SIZE: integer := 9;
constant adress_size_actual: integer := 9;
constant adress_size_vector: integer := 12;  --+2 for 2 lsb +1 for 1 msb(0x800)
constant data_bus_size: integer := 8;


COMPONENT MIPS IS
	generic (address_size : integer := 0);
	PORT( reset, clock					: IN 	STD_LOGIC; 
		--interupts handling signals---
		intr : in std_logic;
		inta: out std_logic;
		GIE: out std_logic;
		K1_OUT			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		PC_EXE_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
		RETI_EX_OUT,RETI_ID_OUT,jump_occurred_DM_OUT,k1en_OUT: out std_logic;
		INTR_TMR_OUT: out INTEGER;
		IF_TYPE_PC_EN: out std_logic;
		IF_TYPE_PC: out STD_LOGIC_VECTOR(9 DOWNTO 0 ); 
		-- Output important signals 
		--------- pipeline lvl0   IF---------
		IF_PC_out								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IF_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		IF_PC_SRC_OUT							: OUT 	STD_LOGIC;
		--------- pipeline lvl1   ID---------
		ID_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_read_data_1_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_read_data_2_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_write_data_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_SIGN_EXT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_Regwrite_out						: OUT 	STD_LOGIC;
		--------- pipeline lvl2   EXE---------
		EXE_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_ALU_result_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_AINPUT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_BINPUT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_MUX_AINPUT_OUT					: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		EXE_MUX_BINPUT_OUT					: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		EXE_Zero_out						: OUT 	STD_LOGIC;
		EXE_MUX_ADRESS_OUT					: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		--------- pipeline lvl3   DMEM---------
		DM_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_MEM_WRITE,DM_IO_READ				: OUT 	STD_LOGIC;
		DM_WRITE_DATA                       : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_READ_DATA                        : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_IO_READ_DATA                     : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_MEM_ADDRESS						: OUT 	STD_LOGIC_VECTOR( adress_size_vector - 1 DOWNTO 0 );
		
		--------- pipeline lvl4   WB---------
		WB_INSTUCTION_out,WB_write_data_out	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		WB_REGWRITE							: OUT 	STD_LOGIC;
		WB_JAL_OUT							: OUT 	STD_LOGIC;
		
		---------hazards outputs-------------
		stall_out, flash_out                : OUT 	STD_LOGIC 
		
		-------------------------------------------------
		 );
END 	COMPONENT;
COMPONENT Ifetch
   	    generic ( address_size : integer := 0);
		PORT(	  
		    SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			signal jump, jr,jal	 			: in	STD_LOGIC;
        	signal PCsrc			: IN    STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			signal IDecode_Sign_extend       : in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );  -- for jump, jr or jal (from idcode)
			signal read_data_1	: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );    -- for jump, jr or jal   (from idcode)
			signal stall_pc : IN 	STD_LOGIC; 
			signal type_pc			: in	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			signal type_en			: IN 	STD_LOGIC;			
			SIGNAL clock, reset 	: IN 	STD_LOGIC);
	END COMPONENT; 

	COMPONENT Idecode
 	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			data_wb	    : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			shift 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus_4 	: in	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			jr	    : in 	STD_LOGIC;
			jal_wb	    : in 	STD_LOGIC;
			mux_address 	: in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Branch          : in    STD_LOGIC;
			Branch_NE       : in    STD_LOGIC;
			PCsrc			: OUT    STD_LOGIC;
			Add_result		: out    STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			k1en			: in    STD_LOGIC;
			k1val			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			GIE: out std_logic;
			RETI_OUT		:OUT    STD_LOGIC;
			RETI_EX_IN		:IN    STD_LOGIC;
			K1_OUT			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode,Function_opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC;
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC;
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch 				: OUT 	STD_LOGIC;
				Branch_NE 			: OUT	STD_LOGIC;
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 );
				jump	 			: OUT	STD_LOGIC;
				jr	 			: OUT	STD_LOGIC;
				jal	    : out 	STD_LOGIC;
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	    PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			RegDst 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			rd, rt 	: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			mux_address 	: out	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			A_input_mux, B_input_mux: in STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			OPERAND_FROM_MEM, OPERAND_FROM_WB: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Ainput_out, Binput_out	: out STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT dmemory
		generic ( address_size : integer := 0);
	   PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( adress_size_actual-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			type_input			: in std_logic_vector(adress_size_actual-1 downto 0);
			type_read			: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;


component reg is
generic(size: integer:= 32);
port( 
	  clk,reset : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

component if_reg is
generic(size: integer:= 16);
port( 
	  clk,reset : in std_logic;
	  flush     : in std_logic;
	  stall      : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

component hazard_unit is
port( 
signal ID_instruction  : in std_logic_vector(31 downto 0);
signal EX_regw, DM_regw, WB_regw : in std_logic;
signal EX_muxAdress, DM_muxAdress, WB_muxAdress : in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal EX_memread,ID_memread,ID_memwrite : in std_logic;
signal pcSRC : in std_logic;
signal ALUop 		: in 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
signal jump	    : in 	STD_LOGIC;  --WB
signal jr	    : in 	STD_LOGIC; --WB
signal jal	    : in 	STD_LOGIC; --WB
signal stall_pc, stall_reg, flush ,control_mux : out std_logic;
signal clock, reset	: IN 	STD_LOGIC );
end component;

component forwarding_unit is
port( 
signal EX_instruction  : in std_logic_vector(31 downto 0);
signal  DM_regw, WB_regw : in std_logic;
signal  DM_muxAdress, WB_muxAdress : in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal ALUop 		: in 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
signal MUX_A_INPUT,MUX_B_INPUT : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal SW_MUX  : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal EX_MEMread , EX_MEMwrite : in std_logic;
signal clock, reset	: IN 	STD_LOGIC );
end component;

component BidirPin is
	generic( width: integer:=16 );
	port(   Dout: 	in 		std_logic_vector(width-1 downto 0);
			en:		in 		std_logic;
			Din:	out		std_logic_vector(width-1 downto 0);
			IOpin: 	inout 	std_logic_vector(width-1 downto 0)
	);
end component;


component ADD_DECODER is
PORT ( 
 address_bus_sig :in std_logic_vector(adress_size_vector -1 downto 0);
CS0,CS1, CS2, CS3, CS4, CS5, CS6, CS7, CS8, CS9, CS10, CS11, CS12, CS13, CS14: OUT STD_LOGIC
);
END component;

component hexcon is
port( 
	  
	  input:in std_logic_vector(3 downto 0);
	  output:out std_logic_vector(6 downto 0)
);
end component;



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
set_BTIFG: OUT std_logic;
------for verification----
 btctl_out :out std_logic_vector (7 downto 0);
 btcl0_out:out std_logic_vector(31 downto 0);
 btcl1_out:out std_logic_vector(31 downto 0);
 btcnt_out_verif:out std_logic_vector(31 downto 0);
 btccr0_out: out std_logic_vector(31 downto 0);
 btccr1_out: out std_logic_vector(31 downto 0)
);
END COMPONENT;


COMPONENT interupt_ctr is 
 port (
 --for testing
pending_out : out std_logic_vector(7 downto 0);
served_out: out integer;
----------------------------------------------------------
  clk,reset : in std_logic;
  read_selector: in  std_logic_vector(1 downto 0);
  IFG_in: in std_logic_vector(7 downto 0);
  ena_write_ifg, ena_write_ie,ena_write_type : in std_logic;
  DATA_BUS_SIG_IN: in std_logic_vector(7 downto 0);
  GIE_IN: IN STD_LOGIC;
  inta: in STD_LOGIC;
  intr: out STD_LOGIC;
  sent_type:  in STD_LOGIC;
  DATA_BUS_SIG_OUT: OUT std_logic_vector(7 downto 0)
  );
  END COMPONENT;



end aux_package;