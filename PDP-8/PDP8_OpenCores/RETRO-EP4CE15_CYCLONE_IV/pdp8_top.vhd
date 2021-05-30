--------------------------------------------------------------------
--! OpenCores PDP-8 Processor
--!	https://opencores.org/projects/pdp8
--!
--! \brief
--!      PDP-8 implementation for the RETRO-EP4CE15 board
--! 		CPU Configured to emulate PDP8A (swCPU)
--!
--! \details
--! Additional Comments: Build for RETRO-EP4CE15, using EP4CE15 FPGA
--!		http://land-boards.com/blwiki/index.php?title=RETRO-EP4CE15
--! Front Panel
--!		http://land-boards.com/blwiki/index.php?title=PDP-8_Front_Panel
--! Uses bin2mif.py utility to convert the DEC bin file to Altera MIF file
--! Software at:
--!		https://github.com/douggilliland/Linux-68k/tree/master/pdp8
--! VHDL at:
--!		https://github.com/douggilliland/Retro-Computers/tree/master/PDP-8/PDP8_OpenCores/RETRO-EP4CE15_CYCLONE_IV
--!
--! \file
--!      pdp8_top.vhd
--!
--! \author
--!    Joe Manojlovich - joe.manojlovich (at) gmail (dot) com
--!
--!	Doug Gilliland - adapted to EP4CE15 card
--
--------------------------------------------------------------------
--
--  Copyright (C) 2012 Joe Manojlovich
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std;
use work.uart_types.all;                        --! UART Types
use work.dk8e_types.all;                        --! DK8E Types
use work.kc8e_types.all;                        --! KC8E Types
use work.kl8e_types.all;                        --! KL8E Types
use work.rk8e_types.all;                        --! RK8E Types
use work.rk05_types.all;                        --! RK05 Types
use work.ls8e_types.all;                        --! LS8E Types
use work.pr8e_types.all;                        --! PR8E Types
use work.cpu_types.all;                         --! CPU Types
use work.sd_types.all;                          --! SD Types
use work.sdspi_types.all;                       --! SPI Types
use work.oct_7seg;

ENTITY pdp8_top is  
  PORT ( 
		CLOCK_50		: IN STD_LOGIC;      -- Input clock
		reset_n 		: in STD_LOGIC;		-- Reset
		-- 
		dispPB		: in std_logic;		-- 12 LEDs display select button selects source
		stepPB		: in std_logic;		-- Single Step pushbutton 
		ldPCPB		: in std_logic;		-- Load PC pushbutton
		runSwitch	: in std_logic;		-- Run/Halt slide switch
		depPB			: in std_logic;		-- Deposit pushbutton
		examinePB	: in std_logic;		-- Examine pushbutton (LDA)
		linkSW		: in std_logic;		-- Link Switch
		sw			 	: in STD_LOGIC_VECTOR(11 downto 0);		-- Slide switches

		runLED		: out  STD_LOGIC;		-- RUN LED
		dispPCLED	: out  STD_LOGIC;		-- PC is currently displayed on the 12 LEDs
		dispMALED	: out  STD_LOGIC;		-- Indicates that the memory address is currently displayed on the 12 LEDs
		dispMDLED	: out  STD_LOGIC;		-- Indicates that the memory data is currently displayed on the 12 LEDs
		dispACLED	: out  STD_LOGIC;		-- Indicates that the Accumulator is currently displayed on the 12 LEDs
		linkLED		: out  STD_LOGIC := '0';		-- 
		dispLEDs		: out  STD_LOGIC_VECTOR (11 downto 0);

		TTY1_TXD : OUT STD_LOGIC;                                    --! UART send line
		TTY1_RXD : IN STD_LOGIC;                                     --! UART receive line
--		TTY2_TXD : OUT STD_LOGIC;                                    --! UART send line
--		TTY2_RXD : IN STD_LOGIC;                                     --! UART receive line	 
--		LPR_TXD : OUT STD_LOGIC;                                     --! LPR send line
--		LPR_RXD : IN STD_LOGIC;                                      --! LPR receive line
--		LPR_CTS : IN STD_LOGIC;
--		LPR_RTS : OUT STD_LOGIC;
--		PTR_TXD : OUT STD_LOGIC;
--		PTR_RXD : IN STD_LOGIC;
--		PTR_CTS : IN STD_LOGIC;
--		PTR_RTS : OUT STD_LOGIC;
--		fpMISO : IN STD_LOGIC;

		-- SD card
		sdCS		: OUT STD_LOGIC; --! SD card chip select
		sdCLK		: OUT STD_LOGIC; --! SD card clock
		sdDI		: OUT STD_LOGIC; --! SD card master out slave in
		sdDO		: IN STD_LOGIC; --! SD card master in slave out
		sdCD		: IN STD_LOGIC;
	 
		-- Not using the External SRAM but making sure that it's not active
		sramData		: inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		sramAddress	: out std_logic_vector(19 downto 0) := x"00000";
		n_sRamWE		: out std_logic :='1';
		n_sRamCS		: out std_logic :='1';
		n_sRamOE		: out std_logic :='1';

		-- Not using the SD RAM but making sure that it's not active
		n_sdRamCas	: out std_logic := '1';		-- CAS on schematic
		n_sdRamRas	: out std_logic := '1';		-- RAS
		n_sdRamWe	: out std_logic := '1';		-- SDWE
		n_sdRamCe	: out std_logic := '1';		-- SD_NCS0
		sdRamClk		: out std_logic := '1';		-- SDCLK0
		sdRamClkEn	: out std_logic := '1';		-- SDCKE0
		sdRamAddr	: out std_logic_vector(14 downto 0) := "000"&x"000";
		sdRamData	: in std_logic_vector(15 downto 0)
    );
END pdp8_top;

 architecture rtl of pdp8_top is
	signal rk8eSTAT		: rk8eSTAT_t;
	signal swCNTL			: swCNTL_t := (others => '0');   --! Front Panel Control Switches
	signal swROT			: swROT_t := dispPC;             --! Front panel rotator switch emulted with DISP pushbutton
	signal swOPT			: swOPT_t;                       --! PDP-8 options
	signal swDATA			: swDATA_t;             			--! Front panel switches
	signal ledDATA			: data_t;
	
	-- Front Panel SWitch debouncing
	signal dig_counter	: std_logic_vector (19 downto 0) := (others => '0');
	signal dispstep 		: std_logic;
	signal pulse200ms		: std_logic;
	signal rst_out			: std_logic;   --! Reset line output to PDP-8
	signal disp_out		: std_logic;   --! Disp select line output to PDP-8

	signal linkLB			: std_logic;	--! Loopback link switch to Link LED
	
begin

	-- Options
	swOPT.KE8       <= '1';	-- KE8 - Extended Arithmetic Element Provided 
	swOPT.KM8E      <= '1';	-- KM8E - Extended Memory Provided
	swOPT.TSD       <= '1';	-- Time Share Disable
	swOPT.STARTUP   <= '1'; -- Setting the 'STARTUP' bit will cause the PDP8 to boot
									-- to the address in the switch register (panel mode)

	----------------------------------------------------------------------------
	-- 200 mS counter
	-- 2^18 = 256,000, 50M/250K = 200 mS ticks
	-- Used for prescaling pushbuttons
	-- pulse200ms = single 20 nS clock pulse every 200 mSecs
	----------------------------------------------------------------------------
	process (CLOCK_50) begin
		if rising_edge(CLOCK_50) then
			dig_counter <= dig_counter+1;
			if dig_counter(17 downto 0) = 0 then
				pulse200ms <= '1';
			else
				pulse200ms <= '0';
			end if;
		end if;
	end process;

	----------------------------------------------------------------------------
	--  Debounce for RESET pushbutton
	----------------------------------------------------------------------------
	debounceReset : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> reset_n,
		o_PinOut		=> rst_out
	);

	----------------------------------------------------------------------------
	--  Debounce for Examine pushbutton
	----------------------------------------------------------------------------
	debounceExamine : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> examinePB,
		o_PinOut		=> swCNTL.exam
	);

	----------------------------------------------------------------------------
	--  Debounce for Deposit pushbutton (PB1)
	----------------------------------------------------------------------------
	debounceDeposit : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> depPB,
		o_PinOut		=> swCNTL.dep
	);

	----------------------------------------------------------------------------
	--  Debounce for LoaD PC pushbutton
	----------------------------------------------------------------------------
	debounceLoadAC : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> ldPCPB,
		o_PinOut		=> swCNTL.loadADDR
	);
	
	----------------------------------------------------------------------------
	--  Debounce for STEP pushbutton
	----------------------------------------------------------------------------
	debounceStep : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> stepPB,
		o_PinOut		=> swCNTL.step
	);

	----------------------------------------------------------------------------
	-- Debounce for DISPlay select pushbutton
	----------------------------------------------------------------------------
	debounceDispSel : entity work.debounceSW
	port map (
		i_CLOCK_50	=> CLOCK_50,
		i_slowCLK	=> pulse200ms,
		i_PinIn		=> dispPB,
		o_PinOut		=> dispstep
	);
	
	----------------------------------------------------------------------------
	-- Increment display selection
	-- Emulates rotator switch
--    constant dispPC     : swROT_t := "000";                     --! Display PC
--    constant dispAC     : swROT_t := "001";                     --! Display AC
--    constant dispIR     : swROT_t := "010";                     --! Display IR
--    constant dispMA     : swROT_t := "011";                     --! Display MA
--    constant dispMD     : swROT_t := "100";                     --! Display MD
--    constant dispMQ     : swROT_t := "101";                     --! Display MQ
--    constant dispST     : swROT_t := "110";                     --! Display ST
--    constant dispSC     : swROT_t := "111";                     --! Display SC
	----------------------------------------------------------------------------
	process (CLOCK_50, dispstep)
	begin
		if rising_edge(CLOCK_50) then
			if dispstep = '1' then
				if		swROT = dispPC then swROT <= dispMA;
				elsif swROT = dispMA then swROT <= dispMD;
				elsif swROT = dispMD then swROT <= dispAC;
				else  swROT <= "000";
				end if;
			end if;
		end if;
	end process;
	-- Display selection LEDS
	dispPCLED <= '1' when swROT = dispPC else '0';		--! Display PC
	dispMALED <= '1' when swROT = dispMA else '0';		--! Display MA
	dispMDLED <= '1' when swROT = dispMD else '0';		--! Display MD
	dispACLED <= '1' when ((swROT = dispAC) or (swROT = dispMQ)) else '0';		--! Display AC
	
	----------------------------------------------------------------------------
	-- Front Panel Data Switches
	--	swDATA          <= o"0023";		-- Tight loop code? 
	--	swDATA          <= o"7400";		-- ? code
	----------------------------------------------------------------------------
	swDATA		<= sw;				-- Set start address from switches
	swCNTL.halt	<= not runSwitch;	-- Run/Halt slide switch

	dispLEDs <= ledDATA;
	
	-- Loopback link switch for now
	linkLB	<= linkSW;
	linkLED	<= linkLB;

	----------------------------------------------------------------------------
	-- PDP8 Processor
	---------------------------------------------------------------------------    
	iPDP8 : entity work.ePDP8 (rtl) port map (
	 -- System
	 clk      => CLOCK_50,                   --! 50 MHz Clock
	 rst      => rst_out,                    --! Reset Button
	 -- CPU Configuration
	 swCPU    => swPDP8A,                    --! CPU Configured to emulate PDP8A (swCPU)
	 swOPT    => swOPT,                      --! Enable Options
	 -- Real Time Clock Configuration
	 swRTC    => clkDK8EC2,                  --! RTC 50 Hz interrupt
	 -- TTY1 Interfaces
	 tty1BR   => uartBR9600,                 --! TTY1 is 9600 Baud
	 tty1HS   => uartHSnone,                 --! TTY1 has no flow control
	 tty1CTS  => '1',                        --! TTY1 doesn't need CTS
	 tty1RTS  => open,                       --! TTY1 doesn't need RTS
	 tty1RXD  => TTY1_RXD,                   --! TTY1 RXD (to RS-232 interface)
	 tty1TXD  => TTY1_TXD,                   --! TTY1 TXD (to RS-232 interface)
	 -- TTY2 Interfaces
	 tty2BR   => uartBR9600,                 --! TTY2 is 9600 Baud
	 tty2HS   => uartHSnone,                 --! TTY2 has no flow control
	 tty2CTS  => '1',                        --! TTY2 doesn't need CTS
	 tty2RTS  => open,                       --! TTY2 doesn't need RTS
	 tty2RXD  => '1',                        --! TTY2 RXD (tied off)
	 tty2TXD  => open,                       --! TTY2 TXD (tied off)
	 -- LPR Interface
	 lprBR    => uartBR9600,                 --! LPR is 9600 Baud
	 lprHS    => uartHSnone,                 --! LPR has no flow control
	 lprDTR   => '1',                        --! LPR doesn't need DTR
	 lprDSR   => open,                       --! LPR doesn't need DSR
	 lprRXD   => '1',                        --! LPR RXD (tied off)
	 lprTXD   => open,                       --! LPR TXD (tied off)
	 -- Paper Tape Reader Interface
	 ptrBR    => uartBR9600,                 --! PTR is 9600 Baud
	 ptrHS    => uartHSnone,                 --! PTR has no flow control
	 ptrCTS   => '1',                        --! PTR doesn't need CTS
	 ptrRTS   => open,                       --! PTR doesn't need RTS
	 ptrRXD   => '1',                        --! PTR RXD (tied off)
	 ptrTXD   => open,                       --! PTR TXD (tied off)
	 -- Secure Digital Disk Interface
	 sdCD     => sdCD,                        --! SD Card Detect
	 sdWP     => '0',                        --! SD Write Protect
	 sdMISO   => sdDO,                       --! SD Data In
	 sdMOSI   => sdDI,                       --! SD Data Out
	 sdSCLK   => sdCLK,                      --! SD Clock
	 sdCS     => sdCS,                       --! SD Chip Select
	 -- Status
	 rk8eSTAT => rk8eSTAT,                   --! Disk Status (Ignore)
	 -- Switches and LEDS
	 swROT    => swROT,                      --! Data LEDS display PC
	 swDATA   => swDATA,                     --! RK8E Boot Loader Address
	 swCNTL   => swCNTL,                     --! Switches
	 ledRUN 	=> runLED,                      --! Run LED
	 ledDATA => ledDATA                      --! Data output register
	 );
	 
end rtl;
