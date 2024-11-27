				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;
ENTITY MIPS IS
	generic (address_size : integer := 0);
	PORT( reset, clock					: IN 	STD_LOGIC; 
		--interupts handling signals---
		intr : in std_logic;
		inta: out std_logic;
		GIE: out std_logic;
		K1_OUT: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 ); 
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
		DM_MEM_WRITE  						: OUT 	STD_LOGIC;
		DM_IO_READ  						: OUT 	STD_LOGIC;
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
END 	MIPS;

ARCHITECTURE structure OF MIPS IS


					-- declare signals used to connect VHDL components
	----------------------PIPLIE LEVEL 0 SIGNALS-------------------
	SIGNAL PC_plus_4_before_reg_0 ,  PC_plus_4_after_reg_0		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL instruction_after_reg_0, Instruction_before_reg_0, instruction : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	----------------------PIPLIE LEVEL 1 SIGNALS-------------------
	SIGNAL read_data_1_before_reg_1,read_data_1_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2_before_reg_1,read_data_2_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend_before_reg_1, Sign_Extend_after_reg_1  		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL  PC_plus_4_after_reg_1: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL rt, rd : STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
	signal  mux_address_before_reg_2  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL instruction_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	------- control vec-----------
	SIGNAL  EX_control_before_reg_1,EX_control_after_reg_1 :STD_LOGIC_VECTOR( 2+ ALU_OP_SIZE-1 DOWNTO 0 ); 
	SIGNAL  Mem_control_before_reg_1,Mem_control_after_reg_1 :STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
	SIGNAL  WB_control_before_reg_1,WB_control_after_reg_1 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	
	------- control sig-----------
	SIGNAL ALUSrc_before_reg_1, ALUSrc_after_reg_1		: STD_LOGIC;
	SIGNAL Branch_before_reg_1, Branch_after_reg_2		: STD_LOGIC;
	SIGNAL Branch_NE_before_reg_1, Branch_NE_after_reg_2 : STD_LOGIC;
	signal jump, jr, jal 								: STD_LOGIC;										
	SIGNAL RegDst_before_reg_1, RegDst_after_reg_1		: STD_LOGIC;
	SIGNAL Regwrite_before_reg_1, Regwrite_after_reg_3	: STD_LOGIC;
	SIGNAL MemWrite_before_reg_1, MemWrite_after_reg_2 	: STD_LOGIC;
	SIGNAL MemtoReg_before_reg_1, MemtoReg_after_reg_3		: STD_LOGIC;
	SIGNAL MemRead_before_reg_1 , MemRead_after_reg_2		: STD_LOGIC;
	SIGNAL ALUop_before_reg_1, ALUop_after_reg_1			: STD_LOGIC_VECTOR( ALU_OP_SIZE -1  DOWNTO 0 );
	
	----------------------PIPLIE LEVEL 2 SIGNALS-------------------
	SIGNAL  Mem_control_after_reg_2 :STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
	SIGNAL  WB_control_after_reg_2 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL Add_result	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PC_plus_4_after_reg_2: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL ALU_result_before_reg_2, ALU_result_after_reg_2		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Zero_before_reg_2 , Zero_after_reg_2	: STD_LOGIC;
	signal write_data_after_reg_2 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal  mux_address_after_reg_2  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL instruction_after_reg_2 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal zero_vector_before_reg_2, zero_vector_after_reg_2: STD_LOGIC_VECTOR( 0 DOWNTO 0 );
	signal PCsrc : STD_LOGIC;
	----------------------PIPLIE LEVEL 3 SIGNALS-------------------
	SIGNAL  WB_control_after_reg_3 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL  ALU_result_after_reg_3		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal  mux_address_after_reg_3  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL  PC_plus_4_after_reg_3: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_before_reg_3, read_data_after_reg_3,instruction_after_reg_3 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal jal_after_reg_3 : std_logic;
	-------flush & stall signals & forwarding ---
	signal stall_pc, stall_reg,stall_reg_hazard, flush_hazard, flush ,control_mux  : STD_LOGIC;
	SIGNAL EXECUTE_REG_WRITE, MEM_REG_WRITE, EX_MEMREAD : STD_LOGIC;
	signal MUX_A_INPUT,MUX_B_INPUT,MUX_SW_INPUT :  STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	signal EX_MEMwrite : std_logic;
	signal data_wb : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal actual_write_data,actual_read_data : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	------Final project extensions signal-----------------------------------------
	signal enable_MEM_write : std_logic;
	signal enable_MEM_read : std_logic;
	---interupt signals---
	signal interupt_flush: std_logic;
	signal count_rst,flush_ifid : std_logic; 
	signal jump_occurred_ID,jump_occurred_EX,jump_occurred_DM: std_logic_vector(0 downto 0); ----- jump occured also for branch
	signal stall_pc_inerupt,inta_tmp: std_logic;
	signal stall_reg_interupt: std_logic;
	signal stall_pc_hazard,k1en: std_logic;
	signal pc_exe: std_logic_vector(31 downto 0);
	signal intr_timer : integer;
	signal type_tmp: std_logic_vector(adress_size_actual-1 downto 0);
	signal type_read,type_en,RETI_OUT, RETI_IN_PIPE: std_logic;
	SIGNAL RETI_ID, RETI_EX, RETI_DM, RETI_WB: STD_LOGIC_VECTOR (0 DOWNTO 0);
	SIGNAL pc_exe_was_sampled,PC_NOT0: std_logic;
	----------------------


	
BEGIN   

	--------------------interupt processes
	count_rst <= '1' when (reset='1') or (intr_timer =4) or (inta_tmp = '0') else '0';
	process( intr, clock, reset, inta_tmp)
	begin
		if(count_rst = '1') then
			intr_timer <=0;
		elsif (clock'event and clock='1') then
			if (intr='1') then
				intr_timer <= intr_timer + 1;
			end if;
		end if;
	end process;
	
	process( intr_timer, clock, reset)
	begin
		if(reset='1') then
			inta_tmp <='1';
		elsif (clock'event and clock='0') then
			if (intr_timer = 2) then
				inta_tmp <='0';
				flush_ifid <= '1';
			else
				inta_tmp <= '1';
				flush_ifid <= '0';
			end if;
		end if;
	end process;
	
		
	process( clock)
	begin	
	if (clock'event and clock='0') then
		if (intr_timer = 1) then
			type_tmp <= DM_IO_READ_DATA (adress_size_actual+1 downto 2);
			type_read <= '1';
		elsif(intr_timer = 2) then 
			type_en <='1';
			k1en <= '1';
		else
			type_tmp <= CONV_STD_LOGIC_VECTOR( 0,adress_size_actual);
			type_read <= '0';
			type_en<= '0';
			k1en <= '0';
		end if;
	END IF;
	end process;
	
	RETI_IN_PIPE<= RETI_ID(0) OR RETI_EX(0) OR RETI_DM(0) OR RETI_WB(0);
	pc_exe<= --X"00000020";
			 X"00000000" when reset='1' else
			 B"0000000000000000000000" & CONV_STD_LOGIC_VECTOR( CONV_INTEGER(unsigned(PC_plus_4_after_reg_1))- 4 , 10 ) when
			 (intr ='1') and (RETI_IN_PIPE = '0') AND (intr_timer = 0) and (jump_occurred_DM(0) = '0' ) and (PC_plus_4_after_reg_1 /= "0000000000") else
			 B"0000000000000000000000" & CONV_STD_LOGIC_VECTOR( CONV_INTEGER(unsigned(PC_plus_4_after_reg_2))- 4 , 10 ) when
			 (intr ='1') and (RETI_IN_PIPE = '0') AND (intr_timer = 0) and (jump_occurred_DM(0) = '1' ) and (PC_plus_4_after_reg_2 /= "0000000000") else
			 unaffected;
	pc_exe_was_sampled<= '0' when reset='1' else
			 '1' when (intr ='1') and (RETI_IN_PIPE = '0') AND (intr_timer = 0) else
			 '0' when intr='0';
	
		-----------------------------------------------------------------------
	
	----------------------- OUTPUT DECLARATIONS--------------------------------
	--interupts
	inta<= inta_tmp;
	PC_EXE_OUT <= pc_exe;
	RETI_EX_OUT <= RETI_EX(0);
	RETI_ID_OUT <=RETI_ID(0);
	jump_occurred_DM_OUT <= jump_occurred_DM(0);
	k1en_OUT <= k1en;
	INTR_TMR_OUT <= intr_timer;
	IF_TYPE_PC_EN <= type_en;
	IF_TYPE_PC <= read_data_before_reg_3( 9 DOWNTO 0);
	--lvl0
	IF_INSTUCTION_out <= Instruction_before_reg_0;
	-- pc declared in ifetch;
	IF_PC_SRC_OUT <=PCsrc;
	--lvl1
	ID_INSTUCTION_out <= instruction_after_reg_0;
	ID_read_data_1_out<= read_data_1_before_reg_1;
    ID_read_data_2_out <= read_data_2_before_reg_1;
    ID_write_data_out <= data_wb;
	ID_Regwrite_out <= RegWrite_after_reg_3;
	ID_SIGN_EXT_OUT <= Sign_Extend_before_reg_1;
	
	---lvl2
	EXE_INSTUCTION_out <= instruction_after_reg_1;
	EXE_ALU_result_out <= ALU_result_before_reg_2;
	EXE_MUX_AINPUT_OUT <= MUX_A_INPUT;
	EXE_MUX_BINPUT_OUT <= MUX_B_INPUT;
	EXE_Zero_out<= Zero_before_reg_2;
	EXE_MUX_ADRESS_OUT <= mux_address_before_reg_2;
	
	---lvl3
	DM_INSTUCTION_out <= instruction_after_reg_2;
	DM_MEM_WRITE  <= MemWrite_after_reg_2;
	DM_WRITE_DATA <= write_data_after_reg_2;
	DM_READ_DATA  <= read_data_before_reg_3;
	DM_MEM_ADDRESS	<= ALU_result_after_reg_2 (adress_size_vector - 1 DOWNTO 0) ;
	
	--lvl 4
	WB_INSTUCTION_out <= instruction_after_reg_3;
	WB_REGWRITE	<= RegWrite_after_reg_3;
	WB_JAL_OUT	<= jal_after_reg_3;
	WB_write_data_out <= data_wb;
	
	--hazards
	stall_out <= stall_reg or stall_pc;   --- actually they are the same 
	flash_out <= flush;
	
	---------------------------------------------------------------------------------

   data_wb  	<= read_data_after_reg_3 WHEN MemtoReg_after_reg_3 = '1' ELSE 
				B"0000000000000000000000" &PC_plus_4_after_reg_3 when jal_after_reg_3 ='1' else 
				ALU_result_after_reg_3;
	

---------------------interupt section---------------------------------
stall_pc_inerupt<= '1' WHEN intr = '1' ELSE '0'; -- or (intr_timer = 2)
interupt_flush <= intr;
flush <= flush_hazard or interupt_flush or flush_ifid;
stall_pc <= stall_pc_hazard or stall_pc_inerupt;
stall_reg_interupt <= intr;
stall_reg <= stall_reg_interupt or stall_pc_hazard;
jump_occurred_ID <= "1" when (jump or jr or jal or PCsrc) = '1' else "0";
 RETI_ID(0) <= RETI_OUT; 
 
--------------------- lvl0 -------------------------------------	  
  IFE : Ifetch generic map (address_size )
	PORT MAP (	Instruction 	=> Instruction_before_reg_0,
    	    	PC_plus_4_out 	=> PC_plus_4_before_reg_0,
				Add_result 		=> Add_result,
				jump 			=> jump,
				jr				=> jr,
				jal 			=> jal,
				PCsrc           => PCsrc,
				PC_out 			=> IF_PC_out,  
				IDecode_Sign_extend 	=> Sign_Extend_before_reg_1,	
				read_data_1 	=> read_data_1_before_reg_1,
				stall_pc        => stall_pc,
				type_pc			=> read_data_before_reg_3( 9 DOWNTO 0),
				type_en			=> type_en,
				clock 			=> clock,  
				reset 			=> reset );


--------------------- lvl0 registers------
reg0_IR      :if_reg generic map (32) port map(clock, reset,flush , stall_reg ,Instruction_before_reg_0,instruction_after_reg_0  );	
reg0_PC_PLUS4: if_reg generic map (10) port map(clock, reset,flush , stall_reg ,PC_plus_4_before_reg_0,PC_plus_4_after_reg_0  );	


   ID : Idecode 
   	PORT MAP (	read_data_1 	=> read_data_1_before_reg_1,
        		read_data_2 	=> read_data_2_before_reg_1,
        		Instruction 	=> instruction_after_reg_0,
        		data_wb			=> data_wb,
				RegWrite 		=> RegWrite_after_reg_3,
				shift			=> ALUop_before_reg_1(2),
				MemtoReg 		=> MemtoReg_after_reg_3,
				Sign_extend 	=> Sign_Extend_before_reg_1,
				PC_plus_4		=> PC_plus_4_after_reg_0,
				jr 				=> jr,
				jal_wb 			=> jal_after_reg_3,
				mux_address		=> mux_address_after_reg_3,
				Branch 			=> Branch_before_reg_1,
				Branch_NE 		=> Branch_NE_before_reg_1,
				PCsrc           => PCsrc,
				Add_Result 		=> ADD_result,
				k1en			=>k1en,
				k1val			=>pc_exe,
				GIE				=>GIE,
				RETI_OUT		=> RETI_OUT,
				RETI_EX_IN		=> RETI_EX(0),
				K1_OUT			=> K1_OUT,
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 			=> instruction_after_reg_0( 31 DOWNTO 26 ),
				Function_opcode	=> instruction_after_reg_0( 5 DOWNTO 0 ),
				RegDst 			=> RegDst_before_reg_1,
				ALUSrc 			=> ALUSrc_before_reg_1,
				MemtoReg 		=> MemtoReg_before_reg_1,
				RegWrite 		=> RegWrite_before_reg_1,
				MemRead 		=> MemRead_before_reg_1,
				MemWrite 		=> MemWrite_before_reg_1,
				Branch 			=> Branch_before_reg_1,
				Branch_NE 		=> Branch_NE_before_reg_1,
				ALUop 			=> ALUop_before_reg_1,
				jump 			=> jump,
				jr 				=> jr,
				jal 			=> jal,
                clock 			=> clock,
				reset 			=> reset );

--------------------- lvl1 -------------------------------------				
------------------ control vectors--------
EXE_VEC:  EX_control_before_reg_1 <= RegDst_before_reg_1 & ALUSrc_before_reg_1 & ALUOp_before_reg_1 when control_mux = '0' else "00000000000";
Mem_vec:  Mem_control_before_reg_1<= MemRead_before_reg_1 & MemWrite_before_reg_1 & Branch_before_reg_1 & Branch_NE_before_reg_1 when control_mux = '0' else "0000"; 
WB_vec:   WB_control_before_reg_1 <= jal & MemtoReg_before_reg_1 & RegWrite_before_reg_1 when control_mux = '0' else "000";




--------------------- lvl1 registers------	
--interapt--
jump_ocr_1:REG generic map (1) port map(clock, reset ,jump_occurred_ID, jump_occurred_EX  );
jump_ocr_2:REG generic map (1) port map(clock, reset ,jump_occurred_EX, jump_occurred_DM  );
RETI_IDEX: 	   REG generic map (1) port map(clock, reset ,RETI_ID, RETI_EX  );
RETI_EXDM: 	   REG generic map (1) port map(clock, reset ,RETI_EX, RETI_DM  );
RETI_DMWB: 	   REG generic map (1) port map(clock, reset ,RETI_DM, RETI_WB  );
----		
reg1_rt: if_reg generic map(5) port map (clock, reset,interupt_flush, '0' ,instruction_after_reg_0(20 downto 16), rt); 
reg1_rd: if_reg generic map(5) port map (clock, reset,interupt_flush, '0' , instruction_after_reg_0(15 downto 11), rd); 
reg1_signExtended: if_reg generic map(32) port map (clock, reset,interupt_flush, '0' , Sign_Extend_before_reg_1, Sign_Extend_after_reg_1); 
reg1_readData1: if_reg generic map (32) port map (clock, reset,interupt_flush, '0' , read_data_1_before_reg_1, read_data_1_after_reg_1);
reg1_readData2: if_reg generic map (32) port map (clock, reset,interupt_flush, '0' , read_data_2_before_reg_1, read_data_2_after_reg_1);
reg1_PC_plus_4: if_reg generic map (10) port map (clock, reset,interupt_flush, '0' , PC_plus_4_after_reg_0, PC_plus_4_after_reg_1);
reg1_EX_control: if_reg generic map (11) port map (clock, reset,interupt_flush, '0' , EX_control_before_reg_1, EX_control_after_reg_1);
reg1_MEM_control: if_reg generic map (4) port map (clock, reset,interupt_flush, '0' ,Mem_control_before_reg_1,Mem_control_after_reg_1);
reg1_WB_control: if_reg generic map (3) port map (clock, reset,interupt_flush, '0' ,WB_control_before_reg_1,WB_control_after_reg_1);
reg1_IR      :if_reg generic map (32) port map(clock, reset,interupt_flush, '0'  ,instruction_after_reg_0,instruction_after_reg_1  );	

--------------- control sig after reg-----
RegDst_after_reg_1<= EX_control_after_reg_1(10);
ALUSrc_after_reg_1<= EX_control_after_reg_1(9);
ALUop_after_reg_1<= EX_control_after_reg_1(8 downto 0);

EXECUTE_REG_WRITE <= WB_control_after_reg_1(0);
EX_MEMREAD <= Mem_control_after_reg_1(3);
EX_MEMwrite <= Mem_control_after_reg_1(2);

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1_after_reg_1,
             	Read_data_2 	=> read_data_2_after_reg_1,
				Sign_extend 	=> Sign_Extend_after_reg_1,
                Function_opcode	=> Sign_Extend_after_reg_1( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop_after_reg_1,
				ALUSrc 			=> ALUSrc_after_reg_1,
				RegDst 			=> RegDst_after_reg_1,
				Zero 			=> Zero_before_reg_2,
                ALU_Result		=> ALU_result_before_reg_2,
				rd              => rd,
				rt				=> rt,
				mux_address		=> mux_address_before_reg_2,
				A_input_mux =>	MUX_A_INPUT,
				B_input_mux => MUX_B_INPUT,
				OPERAND_FROM_MEM=> ALU_result_after_reg_2,
				OPERAND_FROM_WB=> data_wb,
				Ainput_out      =>EXE_AINPUT_OUT,
				Binput_out      =>EXE_BINPUT_OUT,
                Clock			=> clock,
				Reset			=> reset );
				
--------------------- lvl2 -------------------------------------
reg2_WB: if_reg generic map (3) port map (clock, reset,interupt_flush, '0' ,WB_control_after_reg_1,WB_control_after_reg_2); 						
reg2_MEM: if_reg generic map (4) port map (clock, reset,interupt_flush, '0' ,Mem_control_after_reg_1,Mem_control_after_reg_2); 	
reg2_ALU_RES: REG generic map (32) port map (clock, reset,ALU_result_before_reg_2, ALU_result_after_reg_2); 
reg2_ZERO: REG generic map (1) port map (clock, reset,zero_vector_before_reg_2 , zero_vector_after_reg_2); 
reg2_WRITE_DATA: REG generic map (32) port map (clock, reset,actual_write_data, write_data_after_reg_2); 
reg2_WRITE_REG: REG generic map (5) port map (clock, reset,mux_address_before_reg_2, mux_address_after_reg_2); 
reg2_IR :REG generic map (32) port map(clock, reset ,instruction_after_reg_1,instruction_after_reg_2  );
reg2_PC_plus_4: REG generic map (10) port map (clock, reset, PC_plus_4_after_reg_1, PC_plus_4_after_reg_2);

--------------------- lvl2 control-------------------------------------
MemRead_after_reg_2<= Mem_control_after_reg_2(3);
MemWrite_after_reg_2<= Mem_control_after_reg_2(2);
Branch_after_reg_2<=   Mem_control_after_reg_2(1);
Branch_NE_after_reg_2<= Mem_control_after_reg_2(0);
zero_vector_before_reg_2(0) <= Zero_before_reg_2;
Zero_after_reg_2 <= zero_vector_after_reg_2(0);

MEM_REG_WRITE <= WB_control_after_reg_2(0);
DM_IO_READ <= MemRead_after_reg_2;

enable_MEM_write <= (MemWrite_after_reg_2) and (not (ALU_result_after_reg_2 (adress_size_vector-1)));
enable_MEM_read  <= (MemRead_after_reg_2) and (not (ALU_result_after_reg_2 (adress_size_vector-1)));
actual_read_data<= DM_IO_READ_DATA when (ALU_result_after_reg_2 (adress_size_vector-1) and MemRead_after_reg_2)  = '1' else 
				   read_data_before_reg_3; --- nadav asked to notice that it needs to be modify in the case of other inputs (like camera for example).

---- sw forwarding mux in EX level:---
actual_write_data <= ALU_result_after_reg_2 WHEN MUX_SW_INPUT = "01" else
					 data_wb WHEN MUX_SW_INPUT = "10" else
					 read_data_2_after_reg_1 ;
---------------------------

   MEM:  dmemory generic  map (address_size )
	PORT MAP (	read_data 		=> read_data_before_reg_3,
				address 		=> ALU_result_after_reg_2 (adress_size_vector - 2 DOWNTO 2),--jump memory address by 4
				write_data 		=> write_data_after_reg_2,
				MemRead 		=> enable_MEM_read, 
				Memwrite 		=> enable_MEM_write, 
				type_input      => type_tmp,
				type_read		=> type_read,
                clock 			=> clock,  
				reset 			=> reset );
				
				

--------------------- lvl3 ---------------------------------------------				
reg3_WB: REG generic map (3) port map (clock, reset,WB_control_after_reg_2,WB_control_after_reg_3); 
reg3_ALU_RES: REG generic map (32) port map (clock, reset,ALU_result_after_reg_2, ALU_result_after_reg_3); 
reg3_WRITE_REG: REG generic map (5) port map (clock, reset,mux_address_after_reg_2, mux_address_after_reg_3); 
reg3_IR :REG generic map (32) port map(clock, reset ,instruction_after_reg_2,instruction_after_reg_3  );
reg3_READ_DATA :REG generic map (32) port map(clock, reset ,actual_read_data, read_data_after_reg_3  );
reg3_PC_plus_4: REG generic map (10) port map (clock, reset, PC_plus_4_after_reg_2, PC_plus_4_after_reg_3);
--------------------- lvl3 control-------------------------------------
jal_after_reg_3 <= WB_control_after_reg_3(2);
MemtoReg_after_reg_3<= WB_control_after_reg_3(1);
RegWrite_after_reg_3<= WB_control_after_reg_3(0);


-------stalls and forwarding------------------------------------------------------------------------
HAZARD_DEC: hazard_unit PORT MAP(
	instruction_after_reg_0,
	EXECUTE_REG_WRITE,
	MEM_REG_WRITE,
	RegWrite_after_reg_3,
	mux_address_before_reg_2,
	mux_address_after_reg_2,
	mux_address_after_reg_3, 
	EX_MEMREAD, MemRead_before_reg_1 , MemWrite_before_reg_1,
	PCsrc,
	ALUOp_before_reg_1,
	jump,jr,jal,
	stall_pc_hazard, stall_reg_hazard, flush_hazard ,control_mux,
	clock,reset
 );

Forwarding_dec: forwarding_unit
port map( instruction_after_reg_1,
	  MEM_REG_WRITE,
	  RegWrite_after_reg_3,
	  mux_address_after_reg_2,
	  mux_address_after_reg_3, 
	  ALUOp_after_reg_1,
	  MUX_A_INPUT,
	  MUX_B_INPUT,
	  MUX_SW_INPUT,
	  EX_MEMREAD,
	  EX_MEMwrite,
	  clock, reset);

END structure;

