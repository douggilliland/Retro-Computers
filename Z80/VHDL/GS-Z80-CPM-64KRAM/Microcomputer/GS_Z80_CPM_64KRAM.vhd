-- Design is based on Grant Searle's 9-chip Z80 design
--		http://searle.hostei.com/grant/cpm/index.html
-- Built to run on RETRO-EP4 card
--		Card has EP4CE6 FPGA with external 512KB SRAM
--		Only using 64KB of the SRAM
--		EPROM overlays bottom of the SRAM until it is switched out
-- Z80 clocked at 7.3728 MHz
-- Serial clock is 7.3728 MHz
-- Doug Gilliland 2019

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity GS_Z80_CPM_64KRAM is
	port(
		n_reset		: in std_logic :='1';
		i_clk			: in std_logic;
		-- Serial Port
		rxd1			: in std_logic;
		txd1			: out std_logic :='1';
		rts1			: out std_logic;
		-- External SRAM
		sramData		: inout std_logic_vector(7 downto 0);
		sramAddress	: out std_logic_vector(18 downto 0);
		n_sRamWE		: out std_logic :='1';
		n_sRamCS		: out std_logic :='1';
		n_sRamOE		: out std_logic :='1';
		-- SD Card
		sdCS			: out std_logic :='1';
		sdMOSI		: out std_logic :='1';
		sdMISO		: in std_logic;
		sdSCLK		: out std_logic :='1';
		
		driveLED		: out std_logic :='1'
	);
end GS_Z80_CPM_64KRAM;

architecture struct of GS_Z80_CPM_64KRAM is

	signal n_WR							: std_logic :='1';
	signal n_RD							: std_logic :='1';
	signal cpuAddress					: std_logic_vector(15 downto 0);
	signal cpuDataOut					: std_logic_vector(7 downto 0);
	signal cpuDataIn					: std_logic_vector(7 downto 0);

	signal basRomData					: std_logic_vector(7 downto 0);
	signal internalRam1DataOut		: std_logic_vector(7 downto 0);
	signal internalRam2DataOut		: std_logic_vector(7 downto 0);
	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal sdCardDataOut				: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_memRD 					: std_logic :='1';

	signal n_ioWR						: std_logic :='1';
	signal n_ioRD 						: std_logic :='1';
	
	signal n_MREQ						: std_logic :='1';
	signal n_IORQ						: std_logic :='1';	

	signal n_int1						: std_logic :='1';	
	
	signal n_externalRamCS			: std_logic :='1';
	signal n_basRomCS					: std_logic :='1';
	signal n_interface1CS			: std_logic :='1';
	signal n_sdCardCS					: std_logic :='1';

	signal serialClkCount			: std_logic_vector(15 downto 0);
	signal cpuClkCount				: std_logic_vector(5 downto 0); 
	signal sdClkCount					: std_logic_vector(5 downto 0); 	
	signal cpuClock					: std_logic;
	signal serialClock				: std_logic;
	signal sdClock						: std_logic;	
--CP/M
	signal n_RomActive 				: std_logic := '0';

begin

--CP/M
-- Disable ROM if out 38. Re-enable when (asynchronous) reset pressed
process (n_ioWR, n_reset) 
	begin
		if (n_reset = '0') then
			n_RomActive <= '0';
		elsif (rising_edge(n_ioWR)) then
		if cpuAddress(7 downto 0) = "00111000" then -- $38
			n_RomActive <= '1';
		end if;
	end if;
end process;

-- ____________________________________________________________________________________
-- Z80 CPU
cpu1 : entity work.t80s
generic map(mode => 1, t2write => 1, iowait => 0)
port map(
	reset_n => n_reset,
	clk_n => cpuClock,
	wait_n => '1',
	int_n => '1',
	nmi_n => '1',
	busrq_n => '1',
	mreq_n => n_MREQ,
	iorq_n => n_IORQ,
	rd_n => n_RD,
	wr_n => n_WR,
	a => cpuAddress,
	di => cpuDataIn,
	do => cpuDataOut
);

-- ____________________________________________________________________________________
-- External RAM
sramAddress(18 downto 16) <= "000";
sramAddress(15 downto 0) <= cpuAddress(15 downto 0);
sramData <= cpuDataOut when n_memWR='0' else (others => 'Z');
n_sRamWE <= n_memWR or n_externalRamCS;
n_sRamOE <= n_memRD or n_externalRamCS;
n_sRamCS <= n_externalRamCS;

-- ____________________________________________________________________________________
-- BASIC and CP/M ROM

rom1 : entity work.ROM
port map(
	address => cpuAddress(13 downto 0),
	clock => cpuclock,
	q => basRomData
);

-- ____________________________________________________________________________________
-- INPUT/OUTPUT DEVICES

io1 : entity work.bufferedUART	-- Serial port
port map(
	
	n_wr => n_interface1CS or n_ioWR,
	n_rd => n_interface1CS or n_ioRD,
	regSel => cpuAddress(0),
	dataIn => cpuDataOut,
	dataOut => interface1DataOut,
	n_int => n_int1,
	rxClock => cpuclock,
	txClock => cpuclock,
	rxd => rxd1,
	txd => txd1,
	n_rts => rts1,
	n_cts => '0',
	n_dcd => '0'
);


sd1 : entity work.sd_controller
port map(
	sdCS => sdCS,
	sdMOSI => sdMOSI,
	sdMISO => sdMISO,
	sdSCLK => sdSCLK,
	n_wr => n_sdCardCS or n_ioWR,
	n_rd => n_sdCardCS or n_ioRD,
	n_reset => n_reset,
	dataIn => cpuDataOut,
	dataOut => sdCardDataOut,
	regAddr => cpuAddress(2 downto 0),
	driveLED => driveLED,
	clk => sdClock -- twice the spi clk
);

-- ____________________________________________________________________________________
-- MEMORY READ/WRITE LOGIC
n_ioWR <= n_WR or n_IORQ;
n_memWR <= n_WR or n_MREQ;
n_ioRD <= n_RD or n_IORQ;
n_memRD <= n_RD or n_MREQ;

-- ____________________________________________________________________________________
-- CHIP SELECTS
n_basRomCS <= '0' when cpuAddress(15 downto 13)   = "000" and n_RomActive = '0' else '1'; --8K at bottom of memory
n_interface1CS <= '0' when cpuAddress(7 downto 1) = "1000000" and (n_ioWR='0' or n_ioRD = '0') else '1'; -- 2 Bytes $80-$81
n_sdCardCS <= '0' when cpuAddress(7 downto 3)     = "10001"   and (n_ioWR='0' or n_ioRD = '0') else '1'; -- 8 Bytes $88-$8F
n_externalRamCS<= not n_basRomCS;

-- ____________________________________________________________________________________
-- BUS ISOLATION
cpuDataIn <=
interface1DataOut when n_interface1CS = '0' else	-- UART 1
sdCardDataOut when n_sdCardCS = '0' else				-- SD Card
basRomData when n_basRomCS = '0' else
sramData when n_externalRamCS = '0' else
x"FF";

-- ____________________________________________________________________________________
-- SYSTEM CLOCKS implemented as PLL

clocks : ENTITY work.PLL
	PORT MAP (
		inclk0		=> i_clk,
		c0				=> cpuclock,
		c1				=> sdClock
	);

end;
