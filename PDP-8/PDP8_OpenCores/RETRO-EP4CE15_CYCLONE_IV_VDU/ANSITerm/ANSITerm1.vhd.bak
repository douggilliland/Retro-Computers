--	---------------------------------------------------------------------------------------------------------
-- ANSI Terminal
--		Reads keyboard and writes to UART
--		Reads UART and writes to the screen
--		Supports Grant Searle's ANSI escape sequences
--			http://searle.x10host.com/Multicomp/index.html#ANSICodes
--
--	VGA
--		80x24
-- PS/2 keyboard
--	6850 UART
--
-- IOP16 CPU
--		Custom 16 bit I/O Processor
--		Minimal Intruction set (enough for basic I/O)
--		8 Clocks per instruction at 50 MHz = 6.25 MIPS
--
-- IOP16 mEMORY mAP
--		0X00 - UART (c/S) (r/w)
-- 	0X01 - UART (Data) (r/w)
-- 	0X02 - DISPLAY (c/S) (w)
-- 	0X03 - DISPLAY (Data) (w)
-- 	0X04 - KBD (c/S) (r)
-- 	0X05 - KBD (Data) (r) 
 
--	---------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity ANSITerm1 is
	port
	(
		-- Clock and reset
		w_clk					: in std_logic := '1';		-- Clock (50 MHz)
		i_n_reset					: in std_logic := '1';		-- Reset from Pushbutton on FPGA card
		-- Serial port (as referenced from USB side)
		urxd1							: in	std_logic := '1';
		utxd1							: out std_logic;
		ucts1							: in	std_logic := '1';
		urts1							: out std_logic;
		serSelect					: in	std_logic := '1';
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
		-- The key and LED on the FPGA card - helpful for debugging
		i_key1						: in std_logic := '1';		-- KEY1 on the FPGA card
		o_UsrLed						: out std_logic := '1'		-- USR LED on the FPGA card
	);
	end ANSITerm1;

architecture struct of ANSITerm1 is
	-- 
	signal w_resetClean_n		:	std_logic;								-- De-bounced reset button
	
	--  IOP16 Peripheral bus
	signal w_periphAdr			:	std_logic_vector(7 downto 0);
	signal w_periphIn				:	std_logic_vector(7 downto 0);
	signal w_periphOut			:	std_logic_vector(7 downto 0);
	signal w_periphWr				:	std_logic;
	signal w_periphRd				:	std_logic;
	
	-- Decodes/Strobes
	signal w_wrUart				:	std_logic;
	signal w_rdUart				:	std_logic;
	signal W_kbcs					:	std_logic;
	signal w_wrTerm				:	std_logic;
	signal w_rdTerm				:	std_logic;
	
	-- Serial clock enable
   signal serialEn      		: std_logic;		-- 16x baud rate clock
	

	-- Keyboard
	signal w_latKBDData			:	std_logic_vector(7 downto 0);
	signal w_KbdData				:	std_logic_vector(7 downto 0);
	signal w_UartDataOut			:	std_logic_vector(7 downto 0);
	signal w_TermDataOut			:	std_logic_vector(7 downto 0);

	-- Signal Tap Logic Analyzer signals
--	attribute syn_keep	: boolean;
--	attribute syn_keep of W_kbcs			: signal is true;
--	attribute syn_keep of w_periphIn			: signal is true;
--	attribute syn_keep of w_periphWr			: signal is true;
--	attribute syn_keep of w_periphRd			: signal is true;
	
begin

	-- Peripheral bus read mux
	w_periphIn <=	w_UartDataOut		when (w_periphAdr(7 downto 1)="000"&x"0")	else
						w_TermDataOut		when (w_periphAdr(7 downto 1)="000"&x"1")	else
						w_KbdData			when (w_periphAdr(7 downto 1)="000"&x"2")	else
						x"00";

	-- Strobes/Selects
	w_wrUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphWr = '1')) else '0';
	w_rdUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphRd = '1')) else '0';
	w_wrTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphWr = '1')) else '0';
	w_rdTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphRd = '1')) else '0';
	W_kbcs		<= '1' when  (w_periphAdr(7 downto 1)="000"&x"2") else '0';
	
	-- Debounce/sync reset to 50 MHz FPGA clock
	debounceReset : entity work.Debouncer
		port map
		(
			i_clk				=> w_clk,
			i_PinIn			=> i_n_reset,
			o_PinOut			=> w_resetClean_n
		);

	-- I/O Processor
	-- Set ROM size in generic INST_SRAM_SIZE_PASS (512W uses 1 of 1K Blocks in EP4CE15 FPGA)
	-- Set stack size in STACK_DEPTH generic
	IOP16: ENTITY work.IOP16
	-- Need to pass down instruction RAM and stack sizes
		generic map 	( 
			INST_SRAM_SIZE_PASS	=> 512,	-- Small code size since program is "simple"
			STACK_DEPTH_PASS		=> 4		-- Single level subroutine (not nested)
		)
		PORT map
		(
			i_clk					=> w_clk,
			i_resetN				=> w_resetClean_n,
			-- Peripheral bus signals
			i_periphDataIn		=> w_periphIn,
			o_periphWr			=> w_periphWr,
			o_periphRd			=> w_periphRd,
			o_periphDataOut	=> w_periphOut,
			o_periphAdr			=> w_periphAdr
		);
	
	-- ANSI Display
	-- Resource usage can be reduced by changing the generics below
	ANSIDisplay: entity work.ANSIDisplayVGA	
	generic map	(
		EXTENDED_CHARSET 		=>	0,		 		-- 1 = 256 chars
														-- 0 = 128 chars
		COLOUR_ATTS_ENABLED	=> 1,				-- 1 = Color for each character
														-- 0 = Color applied to whole display
		DEFAULT_ATT				=> "00001111", -- background iBGR | foreground iBGR (i=intensity)
		ANSI_DEFAULT_ATT		=> "00000111",	-- background iBGR | foreground iBGR (i=intensity)
		SANS_SERIF_FONT		=> 1				-- 0 => use conventional CGA font
														-- 1 => use san serif font
		)
		port map (
			n_reset		=> w_resetClean_n,
			clk			=> w_clk,
			n_wr			=> w_wrTerm,
			-- CPU interface
			n_rd			=> w_rdTerm,
			regSel		=> w_periphAdr(0),
			dataIn		=> w_periphOut,
			dataOut		=> w_TermDataOut,
			-- RGB video signals
			videoR0		=> o_videoR0,
			videoR1		=> o_videoR1,
			videoG0		=> o_videoG0,
			videoG1		=> o_videoG1,
			videoB0		=> o_videoB0,
			videoB1		=> o_videoB1,
--			o_hActive	=> ,					- Use to force background color by replacing videoXx with o_hActive
			hSync  		=> o_hSync,
			vSync  		=> o_vSync
	 );

	-- PS/2 keyboard/mapper to ANSI
	KEYBOARD : ENTITY  WORK.Wrap_Keyboard
		port MAP (
			i_CLOCK_50		=> w_clk,
			i_n_reset		=> w_resetClean_n,
			i_kbCS			=> W_kbcs,
			i_RegSel			=> w_periphAdr(0),
			i_rd_Kbd			=> W_kbcs and w_periphRd,
			i_ps2_clk		=> io_PS2_CLK,
			i_ps2_data		=> io_PS2_DAT,
			o_kbdDat			=> w_KbdData
		);

	-- Baud Rate Generator
	-- These clock enables are asserted for one period of input clk, at 16x the baud rate.
	-- Set baud rate in BAUD_RATE generic
	BAUDRATEGEN	:	ENTITY work.BaudRate6850
		GENERIC map (
			BAUD_RATE	=> 115200
		)
		PORT map (
			i_CLOCK_50	=> w_clk,
			o_serialEn	=> serialEn
	);

	-- 6850 style UART
	UART: entity work.bufferedUART
		port map (
			clk     			=> w_clk,
			-- Strobes
			n_wr				=> not w_wrUart,
			n_rd    			=> not w_rdUart,
			-- CPU 
			regSel  			=> w_periphAdr(0),
			dataIn  			=> w_periphOut,
			dataOut 			=> w_UartDataOut,
			-- Clock strobes
			rxClkEn 			=> serialEn,
			txClkEn 			=> serialEn,
			-- Serial I/F
			rxd     			=> urxd1,
			txd     			=> utxd1,
			n_rts   			=> urts1,
			n_cts   			=> ucts1
   );

	-- ____________________________________________________________________________________

end;
