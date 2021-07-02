--------------------------------------------------------------------
-- OpenCores PDP-8 Processor
--	https://opencores.org/projects/pdp8
--
--	PDP-8 implementation for the RETRO-EP4CE15 board
--		CPU Configured to emulate PDP8A (swCPU)
--		Video Display Unit (VDU) with PS/2 kryboard
--
-- Additional Comments: Build for RETRO-EP4CE15, using EP4CE15 FPGA
--		http://land-boards.com/blwiki/index.php?title=RETRO-EP4CE15
-- Front Panel
--		http://land-boards.com/blwiki/index.php?title=PDP-8_Front_Panel
-- Uses bin2mif.py utility to convert the DEC bin file to Altera MIF file
-- Software at:
--		https://github.com/douggilliland/Linux-68k/tree/master/pdp8
-- VHDL at:
--		https://github.com/douggilliland/Retro-Computers/tree/master/PDP-8/PDP8_OpenCores/RETRO-EP4CE15_CYCLONE_IV
--
-- \file
--      pdp8FPTest.vhd
--
-- \author
--    Joe Manojlovich - joe.manojlovich (at) gmail (dot) com
--
--	Doug Gilliland - adapted to EP4CE15 card
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

ENTITY pdp8FPTest is  
  PORT ( 
		CLOCK_50		: IN STD_LOGIC;      -- Input clock
		reset_n 		: in STD_LOGIC;		-- Reset
		
		-- Switches/pushbuttons
		dispPB		: in std_logic;		-- 12 LEDs display select button selects source
		stepPB		: in std_logic;		-- Single Step pushbutton 
		ldPCPB		: in std_logic;		-- Load PC pushbutton
		ldACPB		: in std_logic;		-- Load Accum pushbutton
		runSwitch	: in std_logic;		-- Run/Halt slide switch
		depPB			: in std_logic;		-- Deposit pushbutton
		examinePB	: in std_logic;		-- Examine pushbutton (LDA)
		linkSW		: in std_logic;		-- Link Switch
		sw			 	: in STD_LOGIC_VECTOR(11 downto 0);		-- Slide switches

		-- LEDs
		runLED		: out  STD_LOGIC;		-- RUN LED
		dispPCLED	: out  STD_LOGIC;		-- PC is currently displayed on the 12 LEDs
		dispMALED	: out  STD_LOGIC;		-- Indicates that the memory address is currently displayed on the 12 LEDs
		dispMDLED	: out  STD_LOGIC;		-- Indicates that the memory data is currently displayed on the 12 LEDs
		dispACLED	: out  STD_LOGIC;		-- Indicates that the Accumulator is currently displayed on the 12 LEDs
		linkLED		: out  STD_LOGIC := '0';		-- 
		dispLEDs		: out STD_LOGIC_VECTOR(11 downto 0);		-- Slide switches

		-- SD card
		sdCS		: OUT STD_LOGIC := '1';		-- SD card chip select
		sdCLK		: OUT STD_LOGIC := '0';		-- SD card clock
		sdDI		: OUT STD_LOGIC;				-- SD card master out slave in
		sdDO		: IN STD_LOGIC := '0';		-- SD card master in slave out
		sdCD		: IN STD_LOGIC;				-- SD card detect
	 
		-- ANSI Terminal
		-- Serial port (not used with VDU)
		rxd1							: in	std_logic := '1';
		txd1							: out std_logic := '1';
		cts1							: in	std_logic := '1';
		rts1							: out std_logic := '1';
		serSelect					: in	std_logic := '1'; --
		-- Video
		o_videoR0					: out std_logic;
		o_videoR1					: out std_logic;
		o_videoG0					: out std_logic;
		o_videoG1					: out std_logic;
		o_videoB0					: out std_logic;
		o_videoB1					: out std_logic;
		o_hSync						: out std_logic;
		o_vSync						: out std_logic;
		-- PS/2 Keyboard
		io_PS2_CLK					: inout std_logic;
		io_PS2_DAT					: inout std_logic;
		
		-- Test Points
		testPt						: out std_logic_vector(6 downto 1);
		
		-- Not using the External SRAM on the QMTECH card but making sure that it's not active
		sramData		: inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		sramAddress	: out std_logic_vector(19 downto 0) := x"00000";
		n_sRamWE		: out std_logic :='1';
		n_sRamCS		: out std_logic :='1';
		n_sRamOE		: out std_logic :='1';

		-- Not using the SD RAM on the RETRO-EP4CE15 card but making sure that it's not active
		n_sdRamCas	: out std_logic := '1';		-- CAS on schematic
		n_sdRamRas	: out std_logic := '1';		-- RAS
		n_sdRamWe	: out std_logic := '1';		-- SDWE
		n_sdRamCe	: out std_logic := '1';		-- SD_NCS0
		sdRamClk		: out std_logic := '1';		-- SDCLK0
		sdRamClkEn	: out std_logic := '1';		-- SDCKE0
		sdRamAddr	: out std_logic_vector(14 downto 0) := "000"&x"000";
		sdRamData	: in std_logic_vector(15 downto 0)
    );
END pdp8FPTest;

 architecture rtl of pdp8FPTest is

 -- Front Panel Loopback
	signal swLEDLoopback	: std_logic_vector (19 downto 0);
	
	
begin

	swLEDLoopback(11 downto 0) <= sw;
	swLEDLoopback(12) <= dispPB;
	swLEDLoopback(13) <= stepPB;
	swLEDLoopback(14) <= ldPCPB;
	swLEDLoopback(15) <= runSwitch;
	swLEDLoopback(16) <= depPB;
	swLEDLoopback(17) <= examinePB;
	swLEDLoopback(18) <= linkSW;
	swLEDLoopback(19) <= ldACPB;
	
	
	dispLEDs <= swLEDLoopback(11 downto 0);
	dispMALED <= ((not swLEDLoopback(13)) or (not swLEDLoopback(12)));
	dispPCLED <= ((not swLEDLoopback(14)) or (not swLEDLoopback(12)));
	runLED <= swLEDLoopback(15);
	dispMDLED <= ((not swLEDLoopback(16)) or (not swLEDLoopback(17)));
	linkLED <= swLEDLoopback(18);
	dispACLED <= ((not swLEDLoopback(19)) or (not swLEDLoopback(17)));
	 
end rtl;
