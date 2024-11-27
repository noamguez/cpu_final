LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package_timer.all;
-------------------------------------

entity Basic_timer is
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
end Basic_timer;


architecture Basic_timer_arch of Basic_timer is
 signal q_int: std_logic_vector(31 downto 0);
 signal actual_reset: std_logic;
 signal btouten: std_logic;
 signal bthold,set_BTIFG_temp: std_logic;
 signal btssel:  std_logic_vector(1 downto 0);
 signal btip:  std_logic_vector(2 downto 0);
 signal btccr0: std_logic_vector(31 downto 0);
 signal btccr1: std_logic_vector(31 downto 0);
 signal btcl0: std_logic_vector(31 downto 0);
 signal btcl1: std_logic_vector(31 downto 0);
 signal btcnt_out: std_logic_vector(31 downto 0);
 signal btctl : std_logic_vector (7 downto 0);
 signal actual_clock: std_logic;
 signal end_period,btctl_changed: std_logic;
 signal real_out_signal : std_logic;
 constant mclk_2 : integer := 0;
 constant mclk_4 : integer := 1;
 constant mclk_8 : integer := 2;
 
 begin 
 ------outputs for signal tap---
 btctl_out <= btctl;
 btcl0_out<= btcl0;
 btcl1_out<= btcl1;
 btcnt_out_verif <= btcnt_out;
 btccr0_out <= btccr0;
 btccr1_out<= btccr1;
 ------


DATA_BUS_SIG_OUT <= btccr0 when read_selctor = "01" else               --- 01 for btccr0 
			        btccr1 when read_selctor = "10" else			   --- 10 for btccr1
			        x"000000" & btctl when read_selctor = "11" else    --- 11 for btctl
				    btcnt_out;										   --- 00 for btcnt
			  
actual_reset <= reset or end_period;  -- end period for PWM

with btssel select
actual_clock <= clk WHEN "00",
		q_int(mclk_2) WHEN "01",
		q_int(mclk_4) WHEN "10",
		q_int(mclk_8) WHEN "11",
		'X' when others;

btcnt_con: BTCNT port map (
	mcu_clk => clk,
    clk => actual_clock,
	reset => actual_reset,
	BTHOLD => bthold,
	WRITE_ENA => BTCNT_WRITE_ENA,
	BTIP  => btip,
	BTCNT_WRITE_DATA => DATA_BUS_SIG_IN,
	BTCNT_READ_DATA => btcnt_out,
	set_BTIFG => set_BTIFG,
	btctl_changed => btctl_changed
	);
	
---- control signals----
	btouten <= btctl(6);
	bthold  <= btctl(5);
	btssel  <= btctl(4 downto 3);
	btip    <= btctl (2 downto 0);
-----


btcl0_latch:process (RESET, clk)
				begin
				if (reset  = '1') then
					btcl0 <= (others => '0');
				elsif (clk'event and clk='1') then
					btcl0 <= btccr0;
				END IF;
			end process;

btcl1_latch: process (RESET, clk)
				begin
				if (reset  = '1') then
					btcl1 <= (others => '0');
				elsif (clk'event and clk='1') then
					btcl1 <= btccr1;
				END IF;
			end process;

btctl_reg: process(clk, reset)
	begin
		if (reset  = '1') then
			btctl <= ( 5 => '1' , others => '0'); -- when reset bthold = 1 and all the rest 0  
		elsif (clk'event and clk='1') then
				if(BTCTL_WRITE_ENA = '1') then
					btctl <= DATA_BUS_SIG_IN(7 downto 0);
					btctl_changed<= '1';
				else
					btctl_changed<= '0';
				end if;
		end if;
	end process;

btccr0_reg: process(clk, reset)
	begin
		if (reset  = '1') then
			btccr0 <= ( others => '0'); 
		elsif (clk'event and clk='1') then
				if(CCR0_WRITE_ENA = '1') then
					btccr0 <= DATA_BUS_SIG_IN;
				end if;
		end if;
	end process;
	
btccr1_reg: process(clk, reset)
	begin
		if (reset  = '1') then
			btccr1<= ( others => '0');   
		elsif (clk'event and clk='1') then
				if(CCR1_WRITE_ENA = '1') then
					btccr1 <= DATA_BUS_SIG_IN;
				end if;
		end if;
	end process;	

compare_unit: process(btcnt_out, reset,  actual_clock)
	begin
		if (reset  = '1') then
			real_out_signal<= '1';   
			end_period <= '0';
		elsif (btcnt_out = btcl1 and btouten='1') then
			real_out_signal <= '0';
			end_period <= '0';
		elsif (btcnt_out = btcl0 and btouten='1') then
		    real_out_signal <= '1';
			end_period <= '1';
		elsif (actual_clock'event and actual_clock='0') then
			 end_period <= '0';
		end if;
	end process;	

OUT_SIGNAL <= real_out_signal WHEN btouten = '1' ELSE '0';


------------------------------------
freq_divider: process(clk, reset)
		begin
		if(reset = '1') then
			q_int <= (others => '0');
		elsif(rising_edge(clk)) then
			q_int <= q_int + 1;
		end if;
 end process;
 ------------------------------------
 end Basic_timer_arch;