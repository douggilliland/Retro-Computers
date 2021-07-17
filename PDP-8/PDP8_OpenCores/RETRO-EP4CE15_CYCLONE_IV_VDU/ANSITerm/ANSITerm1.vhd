--	---------------------------------------------------------------------------------------------------------
--
-- ANSI Terminal
--		Reads keyboard and writes to UART (connected at the higher level to PDP-8)
--		Reads UART (connected at the higher level to PDP-8) and writes to the screen
--		Supports Grant Searle's ANSI escape sequences
--			http://searle.x10host.com/Multicomp/index.html#ANSICodes
--			https://wiki.bash-hackers.org/scripting/terminalcodes?fbclid=IwAR1FXn3ETOIEj1U4R5_PKNk687XHcIYyUb7_M2F5QwQ9NkbIlfq5W705iJA#:~:text=Cursor%20handling%20%20%20%20ANSI%20%20,saved%20cursor%20position%20%203%20more%20rows%20
--
--	Peripherals
--		VGA
--			80x24
-- 	PS/2 keyboard
--		6850 ACIA UART
--
-- IOP16 CPU
--		Custom 16 bit I/O Processor
--		Minimal Intruction set (enough for basic I/O)
--		8 Clocks per instruction at 50 MHz = 6.25 MIPS
--
-- IOP16 MEMORY MAP
--		0X00 - UART (c/S) (r/w)
-- 	0X01 - UART (Data) (r/w)
-- 	0X02 - DISPLAY (c/S) (w)
-- 	0X03 - DISPLAY (Data) (w)
-- 	0X04 - KBD (c/S) (r)
-- 	0X05 - KBD (Data) (r) 
--		0x07 - Sense VDU or USB (r)
 
--	---------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity ANSITerm1 is
	port
	(
		-- Clock and reset
		i_CLOCK_50		: in std_logic;		-- Clock (50 MHz)
		i_n_reset		: in std_logic;		-- Debounced reset button
		-- Serial port (as referenced from USB side)
		i_rxd				: in	std_logic;
		o_txd				: out std_logic;
		i_cts				: in	std_logic;
		o_rts				: out std_logic;
		-- Sense serial source - USB (0) vs VDU (1)
		serSource		: in std_logic;		-- Detect Serial source
														-- monitored by IOP16
														-- Routing is via a mux at the next higher level
		-- Video
		o_videoR0		: out std_logic;
		o_videoR1		: out std_logic;
		o_videoG0		: out std_logic;
		o_videoG1		: out std_logic;
		o_videoB0		: out std_logic;
		o_videoB1		: out std_logic;
		o_hSync			: out std_logic;
		o_vSync			: out std_logic;
		-- PS/2 Keyboard
		io_PS2_CLK		: inout std_logic;
		io_PS2_DAT		: inout std_logic
	);
	end ANSITerm1;

architecture struct of ANSITerm1 is
	-- 
	--  IOP16 Peripheral bus
	signal w_periphAdr			:	std_logic_vector(7 downto 0);
	signal w_IOPDataIn			:	std_logic_vector(7 downto 0);
	signal w_IOPDataOut			:	std_logic_vector(7 downto 0);
	signal w_periphWr				:	std_logic;
	signal w_periphRd				:	std_logic;
	
	-- Decodes/Strobes
	signal w_wrUart				:	std_logic;
	signal w_rdUart				:	std_logic;
	signal w_rdKBD					:	std_logic;
	signal w_wrTerm				:	std_logic;
	signal w_rdTerm				:	std_logic;
	
	-- Serial clock enable
   signal w_serialEn      		: std_logic;		-- 16x baud rate clock
	
	-- Peripheral data outs
	signal w_KbdDataOut			:	std_logic_vector(7 downto 0);
	signal w_UartDataOut			:	std_logic_vector(7 downto 0);
	signal w_VDUDataOut			:	std_logic_vector(7 downto 0);
	signal w_SenseSrc				:	std_logic_vector(7 downto 0);

	-- Signal Tap Logic Analyzer signals
--	attribute syn_keep							: boolean;
--	attribute syn_keep of w_rdKBD				: signal is true;
--	attribute syn_keep of w_IOPDataIn		: signal is true;
--	attribute syn_keep of w_IOPDataOut		: signal is true;
--	attribute syn_keep of w_periphWr			: signal is true;
--	attribute syn_keep of w_periphRd			: signal is true;
--	attribute syn_keep of w_wrUart			: signal is true;
--	attribute syn_keep of w_serialEn			: signal is true;
	
begin

--	---------------------------------------------------------------------------------------------------------
	-- I/O Processor
	-- Set ROM size in generic INST_ROM_SIZE_PASS (512W uses 1 of 1K Blocks in EP4CE15 FPGA)
	-- Set stack size in STACK_DEPTH generic
	IOP : ENTITY work.cpu_001
	-- Need to pass down instruction RAM and stack sizes
		generic map 	( 
			INST_ROM_SIZE_PASS	=> 512,	-- Small code size since program is "simple"
			STACK_DEPTH_PASS		=> 1		-- Single level subroutine (not nested)
		)
		PORT map
		(
			i_clock					=> i_CLOCK_50,
			i_resetN					=> i_n_reset,
			-- Peripheral bus signals
			i_peripDataToCPU		=> w_IOPDataIn,
			o_peripWr				=> w_periphWr,
			o_peripRd				=> w_periphRd,
			o_peripDataFromCPU	=> w_IOPDataOut,
			o_peripAddr				=> w_periphAdr
		);
	
	-- Peripheral bus read mux
	w_IOPDataIn <=	w_UartDataOut		when (w_periphAdr(7 downto 1)="000"&x"0")	else
						w_VDUDataOut		when (w_periphAdr(7 downto 1)="000"&x"1")	else
						w_KbdDataOut		when (w_periphAdr(7 downto 1)="000"&x"2")	else
						w_SenseSrc			when (w_periphAdr(7 downto 1)="000"&x"3")	else
						x"00";

	w_SenseSrc <= "0000000" & serSource;		-- 0x00 is UART, 0x01 is VDU

	-- Strobes/Selects
	w_wrUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphWr = '1')) else '0';		-- UART (0X00=STAT, 0X01=DATA)
	w_rdUart		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"0") and (w_periphRd = '1')) else '0';
	w_wrTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphWr = '1')) else '0';		-- TERMINAL (0X02-STAT, 0X03=DATA)
	w_rdTerm		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"1") and (w_periphRd = '1')) else '0';
	w_rdKBD		<= '1' when ((w_periphAdr(7 downto 1)="000"&x"2") and (w_periphRd = '1')) else '0';		-- KEYBOARD (0X04=STAT, 0X05=DATA)
	
--	---------------------------------------------------------------------------------------------------------
	-- ANSI Display
	-- Resource usage can be reduced by changing the generics below
	-- EXTENDED_CHARSET=0, COLOUR_ATTS_ENABLED=0 - Uses 3 M9K blocks
	-- EXTENDED_CHARSET=1, COLOUR_ATTS_ENABLED=0 - Uses 4 M9K blocks
	-- EXTENDED_CHARSET=0, COLOUR_ATTS_ENABLED=1 - Uses 5 M9K blocks
	-- EXTENDED_CHARSET=1, COLOUR_ATTS_ENABLED=1 - Uses 6 M9K blocks
	ANSIDisplay: entity work.ANSIDisplayVGA	
	generic map	(
		EXTENDED_CHARSET 		=>	0,		 		-- 1 = 256 chars
														-- 0 = 128 chars
		COLOUR_ATTS_ENABLED	=> 0,				-- 1 = Color for each character
														-- 0 = Color applied to whole display
		DEFAULT_ATT				=> "00001111", -- background iBGR | foreground iBGR (i=intensity)
		ANSI_DEFAULT_ATT		=> "00000111",	-- background iBGR | foreground iBGR (i=intensity)
		SANS_SERIF_FONT		=> 1				-- 0 => use conventional CGA font
														-- 1 => use san serif font
		)
		port map (
			clk			=> i_CLOCK_50,
			n_reset		=> i_n_reset,
			-- CPU interface
			n_rd			=> not w_rdTerm,
			n_wr			=> not w_wrTerm,
			regSel		=> w_periphAdr(0),
			dataIn		=> w_IOPDataOut,
			dataOut		=> w_VDUDataOut,
			-- RGB video signals
			videoR0		=> o_videoR0,
			videoR1		=> o_videoR1,
			videoG0		=> o_videoG0,
			videoG1		=> o_videoG1,
			videoB0		=> o_videoB0,
			videoB1		=> o_videoB1,
			hSync  		=> o_hSync,
			vSync  		=> o_vSync
		);

--	---------------------------------------------------------------------------------------------------------
	-- PS/2 keyboard/mapper to ASCII
	-- Emulated 6850 ACIA (minimal) status/data accesses 
	KEYBOARD : ENTITY  WORK.Wrap_Keyboard
		port MAP (
			-- Clock, reset
			i_CLOCK_50		=> i_CLOCK_50,
			i_n_reset		=> i_n_reset,
			-- CPU I/F
			i_kbCS			=> w_rdKBD,
			i_RegSel			=> w_periphAdr(0),
			i_rd_Kbd			=> w_rdKBD,
			i_ps2_clk		=> io_PS2_CLK,
			i_ps2_data		=> io_PS2_DAT,
			o_kbdDat			=> w_KbdDataOut
		);

--	---------------------------------------------------------------------------------------------------------
	-- 6850 style UART
	UART: entity work.bufferedUART
		port map (
			clk     			=> i_CLOCK_50,
			-- Strobes
			n_wr				=> not w_wrUart,
			n_rd    			=> not w_rdUart,
			-- CPU 
			regSel  			=> w_periphAdr(0),
			dataIn  			=> w_IOPDataOut,
			dataOut 			=> w_UartDataOut,
			-- Clock strobes
			rxClkEn 			=> w_serialEn,
			txClkEn 			=> w_serialEn,
			-- Serial I/F
			rxd     			=> i_rxd,
			txd     			=> o_txd,
			n_rts   			=> o_rts,
			n_cts   			=> i_cts
		);

	-- Baud Rate Generator Wrapper
	-- These clock enables are asserted for one period of input clk, at 16x the baud rate.
	-- Set baud rate in BAUD_RATE generic
	BAUDRATEGEN	:	ENTITY work.BaudRate6850
		GENERIC map (
			BAUD_RATE	=> 9600
		)
		PORT map (
			i_CLOCK_50	=> i_CLOCK_50,
			o_serialEn	=> w_serialEn
		);

	-- ____________________________________________________________________________________

end;
