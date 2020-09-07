--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:20:35 05/20/2014
-- Design Name:   
-- Module Name:   C:/Users/CHEMSTI/HOME/TG68_MiniSOC/branches/burst8/SOC/fpga/ems11-bb21/abb_tb.vhd
-- Project Name:  SOC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: EMS11_BB21Toplevel
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY abb_tb IS
END abb_tb;
 
ARCHITECTURE behavior OF abb_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT EMS11_BB21Toplevel
    PORT(
         CLK50 : IN  std_logic;
         UART1_TXD : OUT  std_logic;
         UART1_RXD : IN  std_logic;
         UART1_RTS_N : OUT  std_logic;
         UART1_CTS_N : IN  std_logic;
         DR_CAS_N : OUT  std_logic;
         DR_CS_N : OUT  std_logic;
         DR_RAS_N : OUT  std_logic;
         DR_WE_N : OUT  std_logic;
         DR_CLK_I : IN  std_logic;
         DR_CLK_O : OUT  std_logic;
         DR_CKE : OUT  std_logic;
         DR_A : OUT  std_logic_vector(12 downto 0);
         DR_D : INOUT  std_logic_vector(15 downto 0);
         DR_DQMH : OUT  std_logic;
         DR_DQML : OUT  std_logic;
         DR_BA : OUT  std_logic_vector(1 downto 0);
         FPGA_SD_CDET_N : IN  std_logic;
         FPGA_SD_WPROT_N : IN  std_logic;
         FPGA_SD_CMD : OUT  std_logic;
         FPGA_SD_D0 : IN  std_logic;
         FPGA_SD_D1 : IN  std_logic;
         FPGA_SD_D2 : IN  std_logic;
         FPGA_SD_D3 : OUT  std_logic;
         FPGA_SD_SCLK : OUT  std_logic;
         UART2_RTS_N : OUT  std_logic;
         M1_S : INOUT  std_logic_vector(39 downto 0);
         LED1 : OUT  std_logic;
         LED2 : OUT  std_logic;
         GPIO : INOUT  std_logic_vector(15 downto 0);
         DIAG_N : IN  std_logic;
         RESET_N : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK50 : std_logic := '0';
   signal UART1_RXD : std_logic := '0';
   signal UART1_CTS_N : std_logic := '0';
   signal DR_CLK_I : std_logic := '0';
   signal FPGA_SD_CDET_N : std_logic := '0';
   signal FPGA_SD_WPROT_N : std_logic := '0';
   signal FPGA_SD_D0 : std_logic := '0';
   signal FPGA_SD_D1 : std_logic := '0';
   signal FPGA_SD_D2 : std_logic := '0';
   signal DIAG_N : std_logic := '0';
   signal RESET_N : std_logic := '0';

	--BiDirs
   signal DR_D : std_logic_vector(15 downto 0);
   signal M1_S : std_logic_vector(39 downto 0);
   signal GPIO : std_logic_vector(15 downto 0);

 	--Outputs
   signal UART1_TXD : std_logic;
   signal UART1_RTS_N : std_logic;
   signal DR_CAS_N : std_logic;
   signal DR_CS_N : std_logic;
   signal DR_RAS_N : std_logic;
   signal DR_WE_N : std_logic;
   signal DR_CLK_O : std_logic;
   signal DR_CKE : std_logic;
   signal DR_A : std_logic_vector(12 downto 0);
   signal DR_DQMH : std_logic;
   signal DR_DQML : std_logic;
   signal DR_BA : std_logic_vector(1 downto 0);
   signal FPGA_SD_CMD : std_logic;
   signal FPGA_SD_D3 : std_logic;
   signal FPGA_SD_SCLK : std_logic;
   signal UART2_RTS_N : std_logic;
   signal LED1 : std_logic;
   signal LED2 : std_logic;

   -- Clock period definitions
   constant CLK50_period : time := 10 ns;
   constant FPGA_SD_SCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: EMS11_BB21Toplevel PORT MAP (
          CLK50 => CLK50,
          UART1_TXD => UART1_TXD,
          UART1_RXD => UART1_RXD,
          UART1_RTS_N => UART1_RTS_N,
          UART1_CTS_N => UART1_CTS_N,
          DR_CAS_N => DR_CAS_N,
          DR_CS_N => DR_CS_N,
          DR_RAS_N => DR_RAS_N,
          DR_WE_N => DR_WE_N,
          DR_CLK_I => DR_CLK_I,
          DR_CLK_O => DR_CLK_O,
          DR_CKE => DR_CKE,
          DR_A => DR_A,
          DR_D => DR_D,
          DR_DQMH => DR_DQMH,
          DR_DQML => DR_DQML,
          DR_BA => DR_BA,
          FPGA_SD_CDET_N => FPGA_SD_CDET_N,
          FPGA_SD_WPROT_N => FPGA_SD_WPROT_N,
          FPGA_SD_CMD => FPGA_SD_CMD,
          FPGA_SD_D0 => FPGA_SD_D0,
          FPGA_SD_D1 => FPGA_SD_D1,
          FPGA_SD_D2 => FPGA_SD_D2,
          FPGA_SD_D3 => FPGA_SD_D3,
          FPGA_SD_SCLK => FPGA_SD_SCLK,
          UART2_RTS_N => UART2_RTS_N,
          M1_S => M1_S,
          LED1 => LED1,
          LED2 => LED2,
          GPIO => GPIO,
          DIAG_N => DIAG_N,
          RESET_N => RESET_N
        );

   -- Clock process definitions
   CLK50_process :process
   begin
		CLK50 <= '0';
		wait for CLK50_period/2;
		CLK50 <= '1';
		wait for CLK50_period/2;
   end process;
 
   FPGA_SD_SCLK_process :process
   begin
		FPGA_SD_SCLK <= '0';
		wait for FPGA_SD_SCLK_period/2;
		FPGA_SD_SCLK <= '1';
		wait for FPGA_SD_SCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		RESET_N <= '0';
      wait for CLK50_period*10;
		RESET_N <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
