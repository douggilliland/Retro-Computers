-- ------------------------------------------------------------------
-- OpenCores PDP-8 Processor
--	https://opencores.org/projects/pdp8
--
--	PDP-8 implementation for the RETRO-EP4CE15 board
--		CPU Configured to emulate PDP8A (swCPU)
--		Video Display Unit (VDU) with PS/2 keyboard or Serial (i_serSelect jumper selectable)
--
-- Build for RETRO-EP4CE15, using EP4CE15 FPGA
--		http://land-boards.com/blwiki/index.php?title=RETRO-EP4CE15
-- Front Panel
--		http://land-boards.com/blwiki/index.php?title=PDP-8_Front_Panel
--	IOP16 code
--		https://github.com/douggilliland/Retro-Computers/blob/master/PDP-8/PDP8_OpenCores/RETRO-EP4CE15_CYCLONE_IV_VDU/ANSITerm/IOP16/IOP16_ASSEMBLER/PDP_Term/PDP_Term.csv
-- Uses bin2mif.py utility to convert the DEC bin file to Altera MIF file
-- Software at:
--		https://github.com/douggilliland/Linux-68k/tree/master/pdp8
-- VHDL at:
--		https://github.com/douggilliland/Retro-Computers/tree/master/PDP-8/PDP8_OpenCores/RETRO-EP4CE15_CYCLONE_IV
--
--      pdp8_top.vhd
--
-- Original author (OpenCORES)
--    Joe Manojlovich - joe.manojlovich (at) gmail (dot) com
--
--	Doug Gilliland - adapted to EP4CE15 card
--
-- ------------------------------------------------------------------
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
-- ------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std;
use work.uart_types.all;		-- UART Types
use work.dk8e_types.all;		-- DK8E Types
use work.kc8e_types.all;		-- KC8E Types
use work.kl8e_types.all;		-- KL8E Types
use work.rk8e_types.all;		-- RK8E Types
use work.rk05_types.all;		-- RK05 Types
use work.ls8e_types.all;		-- LS8E Types
use work.pr8e_types.all;		-- PR8E Types
use work.cpu_types.all;			-- CPU Types
use work.sd_types.all;			-- SD Types
use work.sdspi_types.all;		-- SPI Types

ENTITY pdp8_top is  
  PORT ( 
		-- Clock and reset
		i_CLOCK_50		: IN STD_LOGIC;      -- Input clock
		i_reset_n 		: in STD_LOGIC;		-- Reset
		
		-- Switches/pushbuttons (Land Boards PDP-8 Front Panel)
		i_SW12_SS		: in STD_LOGIC_VECTOR(11 downto 0);		-- 12 Slide switches
		i_DISP_PB		: in std_logic;		-- 12 LEDs display select button selects source
		i_STEP_PB		: in std_logic;		-- Single Step pushbutton 
		i_LDPC_PB		: in std_logic;		-- Load PC pushbutton
		i_DEP_PB			: in std_logic;		-- Deposit pushbutton
		i_LDA_PB			: in std_logic;		-- Load Accum pushbutton
		i_LINK_SS		: in std_logic;		-- Link Switch
		i_EXAM_PB		: in std_logic;		-- Examine pushbutton (LDA) (Marked as PB1)
		i_RUN_SS			: in std_logic;		-- Run/Halt slide switch
		
		-- LEDs on Front Panel
		o_OUT12_LEDs	: out  STD_LOGIC_VECTOR (11 downto 0);	-- 12 Display LEDs
		o_RUN_LED		: out  STD_LOGIC;		-- RUN LED
		o_PC_LED			: out  STD_LOGIC;		-- PC is currently displayed on the 12 LEDs
		o_MADR_LED		: out  STD_LOGIC;		-- Indicates that the memory address is currently displayed on the 12 LEDs
		o_MD_LED			: out  STD_LOGIC;		-- Indicates that the memory data is currently displayed on the 12 LEDs
		o_AC_LED			: out  STD_LOGIC;		-- Indicates that the Accumulator is currently displayed on the 12 LEDs
		o_LINK_LED		: out  STD_LOGIC := '0';	-- LINK LED
		
		-- UART Serial (USB-Srtial I/F)
		i_TTY1_RXD_Ser	: IN	STD_LOGIC;	-- UART receive line
		o_TTY1_TXD_Ser : OUT	STD_LOGIC;	-- UART send line
		i_TTY1_CTS_Ser : IN	STD_LOGIC;	-- UART CTS
		o_TTY1_RTS_Ser : OUT	STD_LOGIC;	-- UART RTS
		i_serSelect		: IN	STD_LOGIC;	-- Serial select (Jumper J3-1 - Installed=USB, Removed=VDU)
		-- 
--		LPR_TXD : OUT STD_LOGIC;			-- LPR send line
--		LPR_RXD : IN STD_LOGIC;				-- LPR receive line
--		LPR_CTS : IN STD_LOGIC;
--		LPR_RTS : OUT STD_LOGIC;
--		PTR_TXD : OUT STD_LOGIC;
--		PTR_RXD : IN STD_LOGIC;
--		PTR_CTS : IN STD_LOGIC;
--		PTR_RTS : OUT STD_LOGIC;
		
		-- SD card
		o_sdCS		: OUT	STD_LOGIC;	-- SD card chip select
		o_sdCLK		: OUT	STD_LOGIC;	-- SD card clock
		o_sdDI		: OUT	STD_LOGIC;	-- SD card master out slave in
		i_sdDO		: IN	STD_LOGIC;	-- SD card master in slave out
		i_sdCD		: IN	STD_LOGIC;	-- SD card detect
		
		-- VGA Video (2:2:2 - R:G:B)
		o_videoR0	: out std_logic;
		o_videoR1	: out std_logic;
		o_videoG0	: out std_logic;
		o_videoG1	: out std_logic;
		o_videoB0	: out std_logic;
		o_videoB1	: out std_logic;
		o_hSync		: out std_logic;
		o_vSync		: out std_logic;
		
		-- PS/2 Keyboard
		io_PS2_CLK	: inout std_logic;
		io_PS2_DAT	: inout std_logic;
		
		-- Not using the External SRAM on the QMTECH card but making sure that it's not active
		io_sramData		: inout	std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		o_sramAddress	: out		std_logic_vector(19 downto 0) := x"00000";
		o_sRamWE_n		: out		std_logic :='1';
		o_sRamCS_n		: out		std_logic :='1';
		o_sRamOE_n		: out		std_logic :='1';
		
		-- Not using the SD RAM on the RETRO-EP4CE15 card but making sure that it's not active
		n_sdRamCas	: out std_logic := '1';		-- CAS on schematic
		n_sdRamRas	: out std_logic := '1';		-- RAS
		n_sdRamWe	: out std_logic := '1';		-- SDWE
		n_sdRamCe	: out std_logic := '1';		-- SD_NCS0
		sdRamClk		: out std_logic := '1';		-- SDCLK0
		sdRamClkEn	: out std_logic := '1';		-- SDCKE0
		sdRamAddr	: out std_logic_vector(14 downto 0) := "000"&x"000";
		sdRamData	: in	std_logic_vector(15 downto 0)
    );
END pdp8_top;

 architecture rtl of pdp8_top is
	signal w_rk8eSTAT			: rk8eSTAT_t;
	signal w_swCNTL			: swCNTL_t := (others => '0');   -- Front Panel Control Switches
	signal w_swROT				: swROT_t := dispPC;             -- Front panel rotator switch emulted with DISP pushbutton
	signal w_swOPT				: swOPT_t;                       -- PDP-8 options
	signal w_swDATA			: swDATA_t;             			-- Front panel switches
	signal w_ledDATA			: data_t;
	signal w_dispstep 		: std_logic;
	signal w_disp_out			: std_logic;   -- Disp select line output to PDP-8
	signal w_linkLB			: std_logic;	-- Loopback link switch to Link LED
	
	-- Front Panel SWitch debouncing
	signal w_rstOut_Hi		: std_logic;   -- Reset line output to PDP-8
	signal w_debouncedSws	: std_logic_vector(5 downto 0);
	
	-- Loop serial from PDP-8 and VDU_PS/2 - i_serSelect determines which are used
	signal w_TTY1_TXD_Term	: std_logic;
	signal w_TTY1_RXD_Term	: std_logic;
	signal w_TTY1_RTS_Term	: std_logic;
	signal w_TTY1_CTS_Term	: std_logic;	
	signal w_TTY1_TXD_PDP8	: std_logic;
	signal w_TTY1_RXD_PDP8	: std_logic;
	signal w_TTY1_RTS_PDP8	: std_logic;
	signal w_TTY1_CTS_PDP8	: std_logic;
	
begin
	
	-- Options
	w_swOPT.KE8       <= '1';	-- KE8 - Extended Arithmetic Element Provided 
	w_swOPT.KM8E      <= '1';	-- KM8E - Extended Memory Provided
	w_swOPT.TSD       <= '1';	-- Time Share Disable
	w_swOPT.STARTUP   <= '1';	-- Setting the 'STARTUP' bit will cause the PDP8 to boot
										-- to the address in the switch register (panel mode)
									
	o_LINK_LED <= i_LINK_SS;	-- Loop LINK slideswitch out to LINK LED (Not used yet)
	
	-- Route the serial port to/from PDP-8 and VDU/KBD or UART
	w_TTY1_RXD_PDP8 	<= (i_TTY1_RXD_Ser	and (not i_serSelect)) or (w_TTY1_RXD_Term and i_serSelect);
	w_TTY1_CTS_PDP8	<= (i_TTY1_CTS_Ser 	and (not i_serSelect)) or (w_TTY1_CTS_Term and i_serSelect);
	o_TTY1_TXD_Ser		<= (w_TTY1_TXD_PDP8	and (not i_serSelect)) or i_serSelect;
	o_TTY1_RTS_Ser		<= (w_TTY1_RTS_PDP8	and (not i_serSelect));
	w_TTY1_TXD_Term	<= (w_TTY1_TXD_PDP8	and      i_serSelect)  or (not i_serSelect);
	w_TTY1_RTS_Term	<= w_TTY1_RTS_PDP8	and      i_serSelect;
	
	----------------------------------------------------------------------------
	-- Stand-alone ANSI terminal
	ANSITerm : entity work.ANSITerm1
		port map
		(
			-- Clock and reset
			I_clock_50			=> i_CLOCK_50,			-- Clock (50 MHz)
			i_n_reset			=> not w_rstOut_Hi,	-- Reset from Pushbutton on FPGA card (De-bounced)
			-- Sense USB (0) vs VDU (1)
			serSource			=> i_serSelect,
			-- Serial port (as referenced from USB side)
			i_rxd					=> w_TTY1_TXD_Term,			-- PDP-11 to ANSI Terminal serial data
			o_txd					=> w_TTY1_RXD_Term,			-- ANSI Terminal to PDP-11 serial data
			i_cts					=> w_TTY1_RTS_Term,
			o_rts					=> w_TTY1_CTS_Term,
			-- Video VGA
			o_videoR0			=> o_videoR0,
			o_videoR1			=> o_videoR1,
			o_videoG0			=> o_videoG0,
			o_videoG1			=> o_videoG1,
			o_videoB0			=> o_videoB0,
			o_videoB1			=> o_videoB1,
			o_hSync				=> o_hSync,
			o_vSync				=> o_vSync,
			-- PS/2 Keyboard
			io_PS2_CLK			=> io_PS2_CLK,
			io_PS2_DAT			=> io_PS2_DAT
		);
		
	----------------------------------------------------------------------------
	-- DISP pushbutton increments display selection
	-- Emulates rotator switch
--    constant dispPC     : swROT_t := "000";	-- Display PC
--    constant dispAC     : swROT_t := "001";	-- Display AC
--    constant dispIR     : swROT_t := "010";	-- Display IR
--    constant dispMA     : swROT_t := "011";	-- Display MA
--    constant dispMD     : swROT_t := "100";	-- Display MD
--    constant dispMQ     : swROT_t := "101";	-- Display MQ
--    constant dispST     : swROT_t := "110";	-- Display ST
--    constant dispSC     : swROT_t := "111";	-- Display SC
	----------------------------------------------------------------------------
	process (i_CLOCK_50, w_dispstep)
	begin
		if rising_edge(i_CLOCK_50) then
			if w_dispstep = '1' then
				if		w_swROT = dispPC then
					w_swROT <= dispMA;
				elsif w_swROT = dispMA then
					w_swROT <= dispMD;
				elsif w_swROT = dispMD then
					w_swROT <= dispAC;
				else 
					w_swROT <= "000";
				end if;
			end if;
		end if;
	end process;
	-- Display selection LEDS - Press DISP button to select
	o_PC_LED		<= '1' when w_swROT = dispPC else '0';										-- Display PC
	o_MADR_LED	<= '1' when w_swROT = dispMA else '0';										-- Display MA
	o_MD_LED		<= '1' when w_swROT = dispMD else '0';										-- Display MD
	o_AC_LED		<= '1' when ((w_swROT = dispAC) or (w_swROT = dispMQ)) else '0';	-- Display AC
	
	----------------------------------------------------------------------------
	-- Front Panel Data Switches
	--	w_swDATA	<= o"0023";		-- Run OS/8
	--	w_swDATA	<= o"7400";		-- ? code
	-- w_swDATA	<= o"7600";		-- Re-start OS/2 after booting
	----------------------------------------------------------------------------
	
	w_swDATA			<= i_SW12_SS;			-- Set start address from switches
	w_swCNTL.halt	<= not i_RUN_SS;		-- Run/Halt slide switch

	-- Debounce the Front Panel pushbutton switches before using them
	debounceCtrlSwitches : entity work.debouncePBSWitches
		port map
		(
			i_CLOCK_50	=> i_CLOCK_50,
			i_InPins		=> i_reset_n & i_EXAM_PB & i_DEP_PB & i_LDPC_PB & i_STEP_PB & i_DISP_PB,
			o_OutPins	=> w_debouncedSws
		);
	-- Connect debounced pushbuttons to usage in FPGA
	w_rstOut_Hi 		<= w_debouncedSws(5);
	w_swCNTL.exam		<= w_debouncedSws(4);
	w_swCNTL.dep		<= w_debouncedSws(3);
	w_swCNTL.loadADDR	<= w_debouncedSws(2);
	w_swCNTL.step		<= w_debouncedSws(1);
	w_dispstep			<= w_debouncedSws(0);
	
	-- The 12 Data LEDs
	o_OUT12_LEDs <= w_ledDATA;
	
	-- Loopback link switch for now
	w_linkLB		<= i_LINK_SS;
	o_LINK_LED	<= w_linkLB;
	
	----------------------------------------------------------------------------
	-- PDP8 Processor
	---------------------------------------------------------------------------    
	iPDP8 : entity work.ePDP8 (rtl) port map (
	 -- System
	 clk      => i_CLOCK_50,			-- 50 MHz Clock
	 rst      => w_rstOut_Hi,			-- Reset Button
	 -- CPU Configuration
	 swCPU    => swPDP8A,				-- CPU Configured to emulate PDP8A (swCPU)
	 swOPT    => w_swOPT,				-- Enable Options
	 -- Real Time Clock Configuration
	 swRTC    => clkDK8EC2,				-- RTC 50 Hz interrupt
	 -- TTY1 Interfaces
	 tty1BR   => uartBR9600,			-- TTY1 is 9600 Baud
	 tty1HS   => uartHShw,				-- TTY1 uses hardware handshake
	 tty1CTS  => w_TTY1_CTS_PDP8,		-- TTY1 CTS (in)
	 tty1RTS  => w_TTY1_RTS_PDP8,		-- TTY1 RTS (out)
	 tty1RXD  => w_TTY1_RXD_PDP8,		-- TTY1 RXD (to RS-232 interface)
	 tty1TXD  => w_TTY1_TXD_PDP8,		-- TTY1 TXD (to RS-232 interface)
	 -- TTY2 Interfaces
	 tty2BR   => uartBR9600,			-- TTY2 is 9600 Baud
	 tty2HS   => uartHSnone,			-- TTY2 has no flow control
	 tty2CTS  => '1', 					-- TTY2 doesn't need CTS
	 tty2RTS  => open,					-- TTY2 doesn't need RTS
	 tty2RXD  => '1',						-- TTY2 RXD (tied off)
	 tty2TXD  => open,					-- TTY2 TXD (tied off)
	 -- LPR Interface
	 lprBR    => uartBR9600,			-- LPR is 9600 Baud
	 lprHS    => uartHSnone,			-- LPR has no flow control
	 lprDTR   => '1',						-- LPR doesn't need DTR
	 lprDSR   => open,					-- LPR doesn't need DSR
	 lprRXD   => '1',						-- LPR RXD (tied off)
	 lprTXD   => open,					-- LPR TXD (tied off)
	 -- Paper Tape Reader Interface
	 ptrBR    => uartBR9600,			-- PTR is 9600 Baud
	 ptrHS    => uartHSnone,			-- PTR has no flow control
	 ptrCTS   => '1',						-- PTR doesn't need CTS
	 ptrRTS   => open,					-- PTR doesn't need RTS
	 ptrRXD   => '1',						-- PTR RXD (tied off)
	 ptrTXD   => open,					-- PTR TXD (tied off)
	 -- Secure Digital Disk Interface
	 sdCD     => not i_sdCD,			-- SD Card Detec
	 sdWP     => '0',						-- SD Write Protect
	 sdMISO   => i_sdDO,					-- SD Data In
	 sdMOSI   => o_sdDI,					-- SD Data Out
	 sdSCLK   => o_sdCLK,				-- SD Clock
	 sdCS     => o_sdCS,					-- SD Chip Select
	 -- Status
	 rk8eSTAT => w_rk8eSTAT,			-- Disk Status (Ignore)
	 -- Switches and LEDS
	 swROT	=> w_swROT,					-- Data LEDS display PC
	 swDATA	=> w_swDATA,				-- RK8E Boot Loader Address
	 swCNTL	=> w_swCNTL,				-- Switches
	 ledRUN	=> o_RUN_LED,				-- Run LED
	 ledDATA => w_ledDATA				-- Data output register
	 );
	 
end rtl;
