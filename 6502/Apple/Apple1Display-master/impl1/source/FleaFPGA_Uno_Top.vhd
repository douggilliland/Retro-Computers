----------------------------------------------------------------------------------
-- ********* 'FleaFPGA Uno' Platform VHDL top-level module ***********
-- This is basically a wrapper allows connection of user projects to 
-- FleaFPGA Uno's on-board hardware
--
-- Creation Date: 30th October 2015
-- Author: Valentin Angelovski
--
-- ©2015 - Valentin Angelovski
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity FleaFPGA_Uno_E1 is

	port(
	-- System clock input from onboard 25MHz oscillator
	sys_clock		: in		std_logic;	-- main clock input from 25MHz clock source
	-- Master reset control line
	--Shield_reset	: inout		std_logic;  -- Buffered reset signal out to GPIO header
	
	-- Digital Video Output - control lines
	--LVDS_Red		: out		std_logic;	-- main clock input from external clock source
	--LVDS_Green		: out		std_logic;	-- main clock input from external RC reset circuit
	--LVDS_Blue		: out		std_logic;
	--LVDS_ck			: out		std_logic;
	
	-- User LEDs
	User_LED1		: out		std_logic;
	User_LED2		: out		std_logic;
	
	-- NTSC DAC
	NTSC_DAC			: out		std_logic_vector(3 downto 0);
	-- User GPIO accessible from the shield header
	--GPIO_wordport	: inout 	std_logic_vector(15 downto 0);
	luma : out 	std_logic;
	sync : out 	std_logic;
	--GPIO_pullup		: out 	std_logic_vector(15 downto 0);

	-- User push button
	User_PB1		: in		std_logic;
	
	-- Sigma Delta ADC channels (x6) - input comparator and error out lines
	--ADC0_Comp_in	: inout		std_logic;
	--ADC0_Error_out	: inout		std_logic;
	--ADC1_Comp_in	: inout		std_logic;
	--ADC1_Error_out	: inout		std_logic;
	--ADC2_Comp_in	: inout		std_logic;
	--ADC2_Error_out	: inout		std_logic;
	--ADC3_Comp_in	: inout		std_logic;
	--ADC3_Error_out	: inout		std_logic;	
	--ADC4_Comp_in	: inout		std_logic; 
	--ADC4_Error_out	: inout		std_logic;
	--ADC5_Comp_in	: inout		std_logic;
	--ADC5_Error_out	: inout		std_logic;

	-- SRAM interface (For use with 512Kx8bit Fast SRAM)
	--SRAM_Addr		: out		std_logic_vector(18 downto 0);	-- SRAM address bus
	--SRAM_Data		: inout		std_logic_vector(7 downto 0);	-- data bus to/from SRAM
	SRAM_n_cs		: out		std_logic;
	--SRAM_n_oe		: out		std_logic;
	--SRAM_n_we		: out		std_logic;
	
	-- Stereo (PWM) audio out interface			
	Audio_l			: out		std_logic;
	Audio_r			: out		std_logic; 

	-- SPI1 to Flash ROM
	--spi1_miso		: in 		std_logic;
	--spi1_mosi		: out 		std_logic;
	--spi1_clk		: out 		std_logic;
	spi1_cs			: out 		std_logic;
	
	-- PS2 interface
	--PS2_clk1		: inout		std_logic;
	--PS2_data1		: inout		std_logic;	

	-- UART interface
	slave_rx_i		: in		std_logic
	--slave_tx_o		: out		std_logic  
	
	);  
end FleaFPGA_Uno_E1;


architecture arch of FleaFPGA_Uno_E1 is

signal circuit_clk : std_logic;
signal sync_temp : std_logic;
signal luma_temp : std_logic;
signal rx_ready : std_logic;
signal rx_data: std_logic_vector(7 downto 0);
signal rd: std_logic_vector(6 downto 0);
signal da : std_logic;
signal rda_i : std_logic := '1';
signal reset : std_logic;

constant flash_max: integer := 25000000/2-1;
signal flash_count: integer range 0 to flash_max;
	

begin

	-- Housekeeping logic for unwanted peripherals on FleaFPGA Uno board goes here..
	-- (Note: comment out any of the following code lines if peripheral is required)

	reset <= not User_PB1;
	User_LED1 <= '1';
	User_LED2 <= '0'; 	-- (Must be set to '1' if using the WiFi option - becomes 'module enable') 
	--GPIO_pullup(0) <= '1'; (Must be set to '1' if using the WiFi option)

	spi1_cs <= '1'; 
	SRAM_n_cs <= '1';
	Audio_l <= '0';
	Audio_r <= '0';
	
	-- User HDL component entitites go here!
	
	clock_module : entity work.master_clk
		port map(
			clki => sys_clock,
			clkos => circuit_clk
		);
		
	--div_module : entity work.divider
		--generic map(div => 14)
		--port map(
			--input => master_clk,
			--output => circuit_clk
		--);
		
	apple_module : entity work.apple1display
		port map(
			reset => reset,
			clk => circuit_clk,
			sync => sync_temp,
			luma => luma_temp,
			rd => rd,
			da => da,
			rda_i => rda_i
		);
		
	NTSC_DAC(0) <= '0';
	NTSC_DAC(1) <= '0';
	NTSC_DAC(2) <= '0';
	NTSC_DAC(3) <= sync_temp;
	
	sync <= sync_temp;
	luma <= luma_temp;
		
	uart_module : entity work.UART_RX
	generic map(g_CLKS_PER_BIT => 25000000/115200)
	port map (
		i_Clk       => sys_clock,
		i_RX_Serial => slave_rx_i,
		o_RX_DV     => rx_ready,
		o_RX_Byte   => rx_data
    );	
	
	process (sys_clock, rx_ready, rda_i, flash_count, rx_data)
	begin
		if rising_edge(sys_clock) then
			if flash_count>=flash_max then
				if rda_i='0' then
					da <= '0';
				elsif rx_ready='1' then
					da <= '1';
					rd <= rx_data(6 downto 0);
				end if;
			elsif flash_count=flash_max then
				da <= '0';
				rd <= "0000000";
			else
				flash_count <= flash_count+1;
				da <= '1';
				rd <= "1111111";
			end if;
		end if;
	end process;
	
end architecture;
