						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.AUX_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	generic (address_size : integer := 0);
	
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( adress_size_actual - 1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			type_input			: in std_logic_vector(adress_size_actual-1 downto 0);
			type_read			: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock : STD_LOGIC;
signal adress_tmp : std_logic_vector (adress_size_actual-1 + address_size downto 0 );
BEGIN
		
	

	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => (adress_size_actual  + address_size),
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\nadav\Desktop\project_cpu\CODE\RTtest_modif_data.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => memwrite,
		clock0 => write_clock,
		address_a => adress_tmp ,
		data_a => write_data ,
		q_a => read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
		
		adress_tmp <= type_input & CONV_STD_LOGIC_VECTOR( 0, address_size ) when type_read='1' else
					  address & CONV_STD_LOGIC_VECTOR( 0, address_size );
		
END behavior;

