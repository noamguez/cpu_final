LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;
-------------------------------



entity interupt_ctr is 
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
  END interupt_ctr;
  
  architecture interupt_ctr_ARCH of interupt_ctr is
  signal IE, IFG_SIGNAL,  PENDING: std_logic_vector(7 downto 0);
  signal TYPE_REG : std_logic_vector(7 downto 0);
  signal almost_type: std_logic_vector (7 downto 0);
  signal type_change, ifg_change: std_logic;
  signal served_int : integer;
  signal SRC_2, SRC_3, SRC_4, SRC_5: std_logic;
  begin
  -----outputs------------
  pending_out <= pending;
  served_out<= served_int;
  
  ------------------
  SRC_2 <= IFG_in(2);
  SRC_3 <= IFG_in(3);
  SRC_4 <= IFG_in(4);
  SRC_5 <= IFG_in(5);


  DATA_BUS_SIG_OUT <=  TYPE_REG when sent_type = '1' else				--- for interupt service
					IFG_SIGNAL when read_selector = "01" else               --- 01 for IFG 
			        IE when read_selector = "10" else			   --- 10 for IE
				    TYPE_REG;										--- 00 or 11 for type_reg
					
	PEN: for i in 0 to 7 generate
			PENDING(i) <= IFG_SIGNAL(i) and IE(i);    
		end generate;
  
  intr <=  (PENDING(2) OR PENDING(3) OR PENDING(4) OR PENDING(5)) AND GIE_IN;
  
  
  
    type_reg_def: process(clk, reset)
	begin
		if (reset  = '1') then
			TYPE_REG <= ( others => '0');
		elsif (clk'event and clk='1') then
				if(type_change = '1') then
					TYPE_REG <= almost_type;

				end if;
		end if;
	end process;
  
	type_change <= ena_write_type or (PENDING(2) OR PENDING(3)OR PENDING(4) OR PENDING(5)); 
	almost_type <= DATA_BUS_SIG_IN when ena_write_type = '1' else
							 x"10" when PENDING(2) = '1' else
							 x"14" when PENDING(3) = '1' else
							 x"18" when PENDING(4) = '1' else
							 x"1C" when PENDING(5) = '1' else
							 ( others => '0') ;


---------IFG LATCH ------
int_src_0: process (ena_write_ifg,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(0) <= '0';
		ELSIF( INTA='0' AND served_int =0) then
			IFG_SIGNAL(0) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(0) <= DATA_BUS_SIG_IN(0);
			END IF;
		elsif (IFG_in(0) = '1' ) then
			IFG_SIGNAL(0) <= '1';
		
		
		END IF;
	end process;	
int_src_1: process (ena_write_ifg,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(1) <= '0';
		ELSIF( INTA='0' AND served_int =1) then
			IFG_SIGNAL(1) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(1) <= DATA_BUS_SIG_IN(1);
			END IF;
		elsif (IFG_in(1) = '1' ) then
			IFG_SIGNAL(1) <= '1';
		END IF;
	end process;	
int_src_2: process (ena_write_ifg, SRC_2,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(2) <= '0';
		ELSIF( INTA='0' AND served_int =2) then
			IFG_SIGNAL(2) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0')  THEN
				IFG_SIGNAL(2) <= DATA_BUS_SIG_IN(2);
			END IF;
		elsif (SRC_2 = '1') then
			IFG_SIGNAL(2) <= '1';
		END IF;
	end process;

int_src_3: process (ena_write_ifg, SRC_3,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(3) <= '0';
		ELSIF( INTA='0' AND served_int =3) then
			IFG_SIGNAL(3) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(3) <= DATA_BUS_SIG_IN(3);
			END IF;
		elsif (SRC_3 = '1') then
			IFG_SIGNAL(3) <= '1';
		END IF;
	end process;

int_src_4: process (ena_write_ifg, SRC_4,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(4) <= '0';
		ELSIF( INTA='0' AND served_int =4) then
			IFG_SIGNAL(4) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(4) <= DATA_BUS_SIG_IN(4);
			END IF;
		elsif (SRC_4 = '1' ) then
			IFG_SIGNAL(4) <= '1';
		END IF;
	end process;

int_src_5: process (ena_write_ifg, SRC_5,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(5) <= '0';
		ELSIF( INTA='0' AND served_int =5) then
			IFG_SIGNAL(5) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(5) <= DATA_BUS_SIG_IN(5);
			END IF;
		elsif (SRC_5 = '1') then
			IFG_SIGNAL(5) <= '1';
		END IF;
	end process;

int_src_6: process (ena_write_ifg,RESET,INTA, clk)
begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(6) <= '0';
		ELSIF( INTA='0' AND served_int =6) then
			IFG_SIGNAL(6) <= '0';
	ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(6) <= DATA_BUS_SIG_IN(6);
			END IF;
		elsif (IFG_in(6) = '1') then
			IFG_SIGNAL(6) <= '1';
		END IF;
	end process;	

int_src_7: process (ena_write_ifg,RESET,INTA, clk)
	begin
		IF(RESET = '1') THEN
			IFG_SIGNAL(7) <= '0';
		ELSIF( INTA='0' AND served_int =7) then
			IFG_SIGNAL(7) <= '0';
		ELSIF (ena_write_ifg = '1' ) then   
			IF(clk'event and clk='0') THEN
				IFG_SIGNAL(7) <= DATA_BUS_SIG_IN(7);
			END IF;
		elsif (IFG_in(7) = '1') then
			IFG_SIGNAL(7) <= '1';
		END IF;
	end process;	
-----------------------------------------

served_int <= 	 0 WHEN RESET ='1' ELSE
				 2 when PENDING(2) = '1' AND GIE_IN ='1' else
				 3 when PENDING(3) = '1' AND GIE_IN ='1' else
				 4 when PENDING(4) = '1' AND GIE_IN ='1' else
				 5 when PENDING(5) = '1' AND GIE_IN ='1' else
					unaffected;


	
IE_reg: process(clk, reset)
	begin
		if (reset  = '1') then
			IE <= ( others => '0');   
		elsif (clk'event and clk='1') then
				if(ena_write_ie = '1') then
					IE <= DATA_BUS_SIG_IN;
				end if;
		end if;
	end process;
  
  
  
  end interupt_ctr_ARCH;