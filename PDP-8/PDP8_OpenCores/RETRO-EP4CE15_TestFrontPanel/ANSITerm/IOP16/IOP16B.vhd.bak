-- ---------------------------------------------------------------------------------------
-- IOP16B - I/O Processor with minimal instruction set
--	
--	Useful for offloading polled I/O or replacing CPUs in small applications
--	Runs at 50 MHz / 8 clocks = 6.25 MIPs
--		Could easily be sped up (not necessary in my applications)
--	Small size in FPGA
--		Uses < 350 logic cell
--		Minimum 1 of 1K SRAM blocks (depends on program size)
--		Trade-off - SRAM could be replaced with logic cells (in theory)
--	16-bit instruction size
--	12-bits of address / program memory
--		Allows for up to 4096 instructions in the program
--		Program is stored in FPGA ROM
--		Set size of program memory in INST_SRAM_SIZE_PASS generic
--	8 registers in Register File
--		8-bit registers (read/write)
--		Used for parameters/data (allocations below)
--		Reserved space in instruction for up to 16 of 8-bit registers
--	Peripheral bus
--		8-bit address (controls up to 256 peripherals)
--		8-bit data
--		Read strobe (a couple of clocks wide)
--		Write strobe (single clock wide)
--	Stack options
--		Passed in STACK_DEPTH_PASS
--		0 - No stack needed (no subroutines)
--		1 - Single (1 level of subroutines)
--		> 1 - Deeper stack, 2^N deep (if n = 4, result is 16 deep stack)
--
-- Opcodes (Capacity for 5 or 6 more instructions)
--	NOP - x0 - No Operation - Increments PC (could be replaces)
--	LRI - x2 - Load register with immediate value
--	IOR - x6 - I/O Read into register
--	IOW - x7 - I/O Write from register
--	ARI - x8 - AND register with Immediate value and store back into register
--	ORI - x9 - OR register with Immediate value and store back into register
--	JSR - xA - Jump to subroutine (stack depth can be 1 or 16, set in STACK_DEPTH generic)
--	RTS - xB = Return from subroutine
--	BEZ - xc - Branch by offset if equal to zero
--	BNZ - xd - Branch by offset if not equal to zero
--	JMP - xe - Jump to address (12-bits)
--
-- Fields
--		d15..d12 = opcode
--		d11..d0  = 12-bit offset (BEZ, BNZ)
--		d11..d0  = 12-bit address (JMP)
--		d7..d0   = 8-bit address (IOR, IOW)
--		d11..d8  = register number (LRI, IOR, IOW, ARI, ORI)
--		d7..d0   = Immediate value (LRI, ARI, ORI)
--
--	Stack sizes are:
--		1	- Single subroutine (not nested)
--		>1	- 2^N deep (supports 16 deep nesting but consumes 1 memory block)
--
-- Registers are
--		Reg0-Reg7 - Read/Write values
--		Reg8 - Hard coded to x00
--		Reg9 - Hard coded to x01
--		Reg8 - Hard coded to x00
--		Reg9-RegE - Not used (return x00)
--		RegF - Hard coded to xFF
-- ---------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IOP16 IS
	generic (
		constant INST_SRAM_SIZE_PASS	: integer;	-- Legal Values are 256, 512, 1024, 2048, 4096
		constant STACK_DEPTH_PASS		: integer	-- Legal Values are 1 (single), > 1
	);
	PORT (
		i_clk					: IN std_logic;
		i_resetN				: IN std_logic;
		-- Peripheral Bus
		i_periphDataIn		: IN std_logic_vector(7 DOWNTO 0);				-- Data from peripheral
		o_periphWr			: OUT std_logic := '0';								-- I/O write strobe
		o_periphRd			: OUT std_logic := '0';								-- I/O read strobe
		o_periphDataOut	: OUT std_logic_vector(7 DOWNTO 0) := x"00";	-- Data to peripheral
		o_periphAdr			: OUT std_logic_vector(7 DOWNTO 0) := x"00"	-- Address to peripheral|FrontPanel01_test|FrontPanel01:fp_test	

	);
END IOP16;

ARCHITECTURE IOP16_beh OF IOP16 IS

	-- Grey code state counter
	signal w_lowCount : std_logic_vector(2 DOWNTO 0);		-- Grey code step counter
	
	-- Program Counter
	signal w_PC_out	: std_logic_vector(11 DOWNTO 0);		-- Program Couner output
	signal w_PC_in		: std_logic_vector(11 DOWNTO 0);		-- Program Couner input
	signal pcPlus1		: std_logic_vector(11 DOWNTO 0);		-- Program Couner + 1
	signal w_incPC		: std_logic;		-- Increment PC
	signal w_ldPC		: std_logic;		-- Load PC
	signal w_rtnAddr	: std_logic_vector(11 DOWNTO 0);		-- Return address
	
	-- ROM
	signal w_RomData	: std_logic_vector(15 DOWNTO 0);		-- Program data
	
	-- ALU
	signal w_RegFileFileOut	: std_logic_vector(7 DOWNTO 0);
	signal w_AluOut	: std_logic_vector(7 DOWNTO 0);
	signal w_zBit		: std_logic;		-- ALU Zero bit (latched)
	signal w_aluZero	: std_logic;		-- ALU zero value
	
	-- Register file controls/data
	signal w_wrRegF	: std_logic;
	signal w_regFileIn: std_logic_vector(7 DOWNTO 0);
	
	-- Opcode decodes
	signal w_OP_NOP	: std_logic;
	signal w_OP_LRI	: std_logic;
	signal w_OP_IOR	: std_logic;
	signal w_OP_IOW	: std_logic;
	signal w_OP_ARI	: std_logic;
	signal w_OP_ORI	: std_logic;
	signal w_OP_BEZ	: std_logic;
	signal w_OP_BNZ	: std_logic;
	signal w_OP_JMP	: std_logic;
	signal w_OP_JSR	: std_logic;
	signal w_OP_RTS	: std_logic;
	
	-- Signal Tap Logic Analyzer signals
--	attribute syn_keep	: boolean;
--	attribute syn_keep of w_lowCount			: signal is true;
--	attribute syn_keep of w_PC_out			: signal is true;
--	attribute syn_keep of w_RomData			: signal is true;
--	attribute syn_keep of w_rtnAddr			: signal is true;
--	attribute syn_keep of w_incPC				: signal is true;
--	attribute syn_keep of w_ldPC				: signal is true;
	

BEGIN

	-- OPCODE Decoder
	w_OP_NOP <= '1' when w_RomData(15 downto 12) = x"0" else '0';
	w_OP_LRI <= '1' when w_RomData(15 downto 12) = x"2" else '0';
	w_OP_IOR <= '1' when w_RomData(15 downto 12) = x"6" else '0';
	w_OP_IOW <= '1' when w_RomData(15 downto 12) = x"7" else '0';
	w_OP_ARI <= '1' when w_RomData(15 downto 12) = x"8" else '0';
	w_OP_ORI <= '1' when w_RomData(15 downto 12) = x"9" else '0';
	w_OP_JSR <= '1' when w_RomData(15 downto 12) = x"A" else '0';
	w_OP_RTS <= '1' when w_RomData(15 downto 12) = x"B" else '0';
	w_OP_BEZ <= '1' when w_RomData(15 downto 12) = x"c" else '0';
	w_OP_BNZ <= '1' when w_RomData(15 downto 12) = x"d" else '0';
	w_OP_JMP <= '1' when w_RomData(15 downto 12) = x"e" else '0';

	-- Grey code statew machine used for glitch-free decoding
	-- 3-bits that control the low level interface (strobes) to the peripheral interface
	-- 000 > 001 > 011 > 010 > 110 > 111 > 101 > 100
	greyLow : ENTITY work.GrayCounter
	generic map
	(
		N => 3
	)
	PORT map
	(
		clk		=> i_clk,
		Rst		=> not i_resetN,
		En			=> '1',
		output	=> w_lowCount
	);
	
	-- LIFO - Return address stack (JSR writes, RTS reads)
	-- Single depth uses no memory
	-- Deeper depth uses memory
	GEN_STACK_SINGLE : if (STACK_DEPTH_PASS = 1) generate
	begin
	-- Store the return address for JSR opcodes
	-- Single level stack
		returnAddress : PROCESS (i_clk)
		BEGIN
			IF rising_edge(i_clk) THEN
				if ((w_OP_JSR = '1') and (w_lowCount="101")) then
					w_rtnAddr <= w_PC_out + 1;
				END IF;
			END IF;
		END PROCESS;
	end generate GEN_STACK_SINGLE;

	GEN_STACK_DEEPER : if (STACK_DEPTH_PASS /= 1) generate
	begin
		pcPlus1 <= (w_PC_out + 1);				-- Next address past PC is the return address
		lifo : entity work.lifo
			generic map (
				g_INDEX_WIDTH => STACK_DEPTH_PASS, -- internal index bit width affecting the LIFO capacity
				g_DATA_WIDTH  => 12 				-- bit width of stored data
			)
			port map (
				i_clk		=> i_clk, 					-- clock signal
				i_rst		=> not i_resetN,			-- reset signal
				--
				i_we   	=> (w_OP_JSR and w_lowCount(2) and (not w_lowCount(1)) and w_lowCount(0)), -- write enable (push)
				i_data 	=> pcPlus1,			-- written data
	--			o_full	=> ,
				i_re		=> (w_OP_RTS and w_lowCount(2) and (not w_lowCount(1)) and w_lowCount(0)), -- read enable (pop)
				o_data  	=> w_rtnAddr			-- read data
		--		o_empty :=>							-- empty LIFO indicator
			);	
	end generate GEN_STACK_DEEPER;
	
	-- IO Processor ROM
	GEN_256W_INST_ROM: if (INST_SRAM_SIZE_PASS=256) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(7 downto 0),
			clock			=> i_clk,
			q				=> w_RomData
		);
	end generate GEN_256W_INST_ROM;
	
	GEN_512W_INST_ROM: if (INST_SRAM_SIZE_PASS=512) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(8 downto 0),
			clock			=> i_clk,
			q				=> w_RomData
		);
	end generate GEN_512W_INST_ROM;
	
	GEN_1KW_INST_ROM: if (INST_SRAM_SIZE_PASS=1024) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(9 downto 0),
			clock			=> i_clk,
			q				=> w_RomData
		);
	end generate GEN_1KW_INST_ROM;
	
	GEN_2KW_INST_ROM: if (INST_SRAM_SIZE_PASS=2048) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out(10 downto 0),
			clock			=> i_clk,
			q				=> w_RomData
		);
	end generate GEN_2KW_INST_ROM;
	
	GEN_4KW_INST_ROM: if (INST_SRAM_SIZE_PASS=4096) generate
		begin
		IopRom : ENTITY work.IOP_ROM
		PORT map
		(
			address		=> w_PC_out,
			clock			=> i_clk,
			q				=> w_RomData
		);
	end generate GEN_4KW_INST_ROM;
	
	-- Program Counter (PC)
	ProgramCounter	: PROCESS (i_clk, i_resetN, w_incPC, w_ldPC)
	BEGIN
		IF rising_edge(i_clk) THEN
			IF i_resetN = '0' THEN				-- Program always starts at address x000
				w_PC_out <= x"000";
			ELSIF w_incPC = '1' THEN		-- Increment PC
				w_PC_out <= w_PC_out + 1;
			ELSIF w_ldPC = '1' THEN			-- Load for [Conditional] Branches, JMP, JSR, RTS
				w_PC_out <= w_PC_in;
			END IF;
		END IF;
	END PROCESS;
	
	-- Mux PC input - used for Branches, JMP, JSR, RTS
	w_PC_in <=  (w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BEZ = '1') and (w_zBit = '1')) else
					(w_PC_out + w_RomData(11 downto 0)) when ((w_OP_BNZ = '1') and (w_zBit = '0')) else
					(w_RomData(11 downto 0))				when w_OP_JMP = '1' else
					(w_RomData(11 downto 0))				when w_OP_JSR = '1' else
					w_rtnAddr 									when w_OP_RTS = '1' else
					w_PC_out;

	-- Incremennt the PC
	w_incPC	<= '1' when ((w_lowCount = "100") and (w_OP_BEZ = '0') and (w_OP_BNZ = '0') and (w_OP_JMP = '0') and (w_OP_RTS = '0') and (w_OP_JSR = '0')) else 
					'1' when  (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '0') else
					'1' when  (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '1') else
					'0';
					
	-- Load the PC
	w_ldPC	<= '1' when (w_lowCount = "100") and (w_OP_BEZ = '1') and (w_zBit = '1') else		-- Conditional branche
					'1' when (w_lowCount = "100") and (w_OP_BNZ = '1') and (w_zBit = '0') else		-- Conditional branche
					'1' when (w_lowCount = "100") and (w_OP_JMP = '1') else								-- JMP
					'1' when (w_lowCount = "100") and (w_OP_RTS = '1') else								-- RTS
					'1' when (w_lowCount = "100") and (w_OP_JSR = '1') else								-- JSR
					'0';
	
	-- Load register file input dats mux
	w_regFileIn <=	i_periphDataIn						when w_OP_IOR = '1' else
						w_AluOut 					when w_OP_ARI = '1' else
						w_AluOut 					when w_OP_ORI = '1' else
						w_RomData(7 downto 0)	when w_OP_LRI = '1' else
						x"00";
	
	-- ALU result
	w_AluOut <= (w_RegFileFileOut and w_RomData(7 downto 0)) when w_OP_ARI = '1' else
					(w_RegFileFileOut or  w_RomData(7 downto 0)) when w_OP_ORI = '1' else
					x"00";
					
	-- ALU zero (for convenience)
	w_aluZero <= not (w_AluOut(7) or w_AluOut(6) or w_AluOut(5) or w_AluOut(4) or w_AluOut(3) or w_AluOut(2) or w_AluOut(1) or w_AluOut(0));
	
	-- Zero bit
	w_zBit <=	'1' when (w_OP_ARI = '1') and (w_lowCount="101") and (w_aluZero = '1') else
					'1' when (w_OP_ORI = '1') and (w_lowCount="101") and (w_aluZero = '1') else
					'0' when (w_OP_ARI = '1') and (w_lowCount="101") and (w_aluZero = '0') else
					'0' when (w_OP_ORI = '1') and (w_lowCount="101") and (w_aluZero = '0');

	-- Peripheral Address
	o_periphAdr <= 	w_RomData(7 downto 0) when w_OP_IOW = '1' else		-- Write
						w_RomData(7 downto 0) when w_OP_IOR = '1' else		-- Read
						x"ff";
	
	-- Peripheral output data bus
	o_periphDataOut <= 	w_RegFileFileOut when (w_OP_IOW = '1') else			-- Peripheral data out
						x"AA";
	
	-- Peripheral read/write Controls
	o_periphWr <= '1' when (w_OP_IOW = '1') and (w_lowCount="111") else '0';
	o_periphRd <= '1' when (w_OP_IOR = '1') and (w_lowCount(2 DOWNTO 1)="11") else 
					'1' when (w_OP_IOR = '1') and (w_lowCount(2 DOWNTO 1)="11") else 
					'0';
	
	-- Register file (8x8 plus constants)
	RegFile : ENTITY work.RegFile8x8
	PORT map
	(
		i_clk			=> i_clk,
		i_resetN		=> i_resetN,
		i_wrReg		=> w_wrRegF,
		i_regNum		=> w_RomData(11 downto 8),
		i_DataIn		=> w_regFileIn,
		o_DataOut	=> w_RegFileFileOut
	);
	
	-- Write register file
	w_wrRegF <= '1' when (w_OP_ARI = '1') and (w_lowCount="110") else
					'1' when (w_OP_ORI = '1') and (w_lowCount="110") else
					'1' when (w_OP_LRI = '1') and (w_lowCount="110") else
					'1' when (w_OP_IOR = '1') and (w_lowCount="101") else
					'0';
					
END IOP16_beh;
