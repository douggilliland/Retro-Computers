-- This file is copyright by Grant Searle 2014
-- You are free to use this file in your own projects but must never charge for it nor use it without
-- acknowledgement.
-- Please ask permission from Grant Searle before republishing elsewhere.
-- If you use this file or any part of it, please add an acknowledgement to myself and
-- a link back to my main web site http://searle.hostei.com/grant/    
-- and to the "multicomp" page at http://searle.hostei.com/grant/Multicomp/index.html
--
-- Please check on the above web pages to see if there are any updates before using this file.
-- If for some reason the page is no longer available, please search for "Grant Searle"
-- on the internet to see if I have moved to another web hosting service.
--
-- Grant Searle
-- eMail address available on my main web page link above.

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;

entity Microcomputer is
	port(
		n_reset		: in std_logic;
		clk			: in std_logic;
		cpuClock	: in std_logic;
		vgaClock    : in std_logic;

		videoR0		: out std_logic;
		videoG0		: out std_logic;
		videoB0		: out std_logic;
		videoR1		: out std_logic;
		videoG1		: out std_logic;
		videoB1		: out std_logic;
		hSync			: buffer std_logic;
		vSync			: buffer std_logic;

		ps2Clk		: inout std_logic;
		ps2Data		: inout std_logic;
		

--		sdCS			: out std_logic;
--		sdMOSI		: out std_logic;
--		sdMISO		: in std_logic;
--		sdSCLK		: out std_logic;
--		driveLED		: out std_logic :='1';
		
		rxd1			: in std_logic;
		txd1			: out std_logic;
		rts1			: out std_logic
	);
end Microcomputer;

architecture struct of Microcomputer is

   --signal reset : std_logic := '0';

	signal n_WR							: std_logic;
	signal n_RD							: std_logic;

	signal basRomData					: std_logic_vector(15 downto 0);
	signal internalRam1DataOut		: std_logic_vector(15 downto 0);
	signal internalRam2DataOut		: std_logic_vector(7 downto 0);
	signal interface1DataOut		: std_logic_vector(7 downto 0);
	signal interface2DataOut		: std_logic_vector(7 downto 0);
	signal sdCardDataOut				: std_logic_vector(7 downto 0);

	signal n_memWR						: std_logic :='1';
	signal n_memRD 					: std_logic :='1';

	signal n_ioWR						: std_logic :='1';
	signal n_ioRD 						: std_logic :='1';
	
	signal n_MREQ						: std_logic :='1';
	signal n_IORQ						: std_logic :='1';	

	signal n_int1						: std_logic :='1';	
	signal n_int2						: std_logic :='1';	
	
	signal n_externalRamCS			: std_logic :='1';
	signal n_internalRam1CS			: std_logic :='1';
	signal n_internalRam2CS			: std_logic :='1';
	signal n_basRom1CS					: std_logic :='1';
    signal n_basRom2CS					: std_logic :='1';

	signal n_interface1CS			: std_logic :='1';
	signal n_interface2CS			: std_logic :='1';
	signal n_sdCardCS					: std_logic :='1';

	signal serialClkCount			: std_logic_vector(15 downto 0);
	signal cpuClkCount				: std_logic_vector(5 downto 0); 
	signal sdClkCount					: std_logic_vector(5 downto 0); 	
	signal serialClock				: std_logic;
	signal sdClock						: std_logic;	
	signal topAddress               : std_logic_vector(7 downto 0);
	--CPM
    signal n_RomActive : std_logic := '0';
    
    signal		cpuAddress	    :  std_logic_vector(31 downto 0);
	signal	cpuDataOut		:  std_logic_vector(15 downto 0);
	signal    cpuDataIn		:  std_logic_vector(15 downto 0);
	signal    memAddress		:  std_logic_vector(15 downto 0);
	signal    cpu_as :  std_logic; -- Address strobe
    signal    cpu_uds :  std_logic; -- upper data strobe
    signal    cpu_lds :  std_logic; -- lower data strobe
    signal    cpu_r_w :   std_logic; -- read(high)/write(low)
    signal    cpu_dtack :  std_logic; -- data transfer acknowledge
    
    signal  regsel: std_logic := '1';
    
    type t_Vector is array (0 to 10) of std_logic_vector(15 downto 0);
    signal r_vec : t_Vector;
    
    signal vecAddress: integer := 0;
	
begin

-- ____________________________________________________________________________________
-- CPU CHOICE GOES HERE
    
cpu1 : entity work.TG68
   port map
	(
		clk => clk,
        reset => n_reset,
        clkena_in => '1',
        data_in => cpuDataIn,   
		IPL => "111",	-- For this simple demo we'll ignore interrupts
		dtack => cpu_dtack,
		addr => cpuAddress,
		as => cpu_as,
		data_out => cpuDataOut,
		rw => cpu_r_w,
		uds => cpu_uds,
		lds => cpu_lds
  );
	
	-- rom address
    memAddress <= std_logic_vector(to_unsigned(conv_integer(cpuAddress(15 downto 0)) / 2, memAddress'length)) ;
   
    -- vector address storage
    vecAddress <= conv_integer(cpuAddress(3 downto 0)) / 2 ;
    r_Vec(vecAddress) <= cpuDataOut when cpuAddress(31 downto 16) = X"FFFF" and cpu_r_w = '0' ;
-- ____________________________________________________________________________________
-- ROM GOES HERE
    
	rom1 : entity work.rom -- 8 
	generic map (
	   G_ADDR_BITS => 16,
	   G_INIT_FILE => "D:/code/zed-68k/roms/monitor/monitor_0.hex"
	)
    port map(
        addr_i => memAddress,
        clk_i => clk,
        data_o => basRomData(15 downto 8)
    );
    
    rom2 : entity work.rom -- 8 
	generic map (
	   G_ADDR_BITS => 16,
	   G_INIT_FILE => "D:/code/zed-68k/roms/monitor/monitor_1.hex"
	)
    port map(
        addr_i => memAddress,
        clk_i => clk,
        data_o => basRomData(7 downto 0)
    );
-- ____________________________________________________________________________________
-- RAM GOES HERE

    ram1 : entity work.ram16 --64k
    generic map (
      -- Number of bits in the address bus. The size of the memory will
      -- be 2**G_ADDR_BITS bytes.
      G_ADDR_BITS => 16
    )
   port map (
      clk_i => clk,

      -- Current address selected.
      addr_i => cpuAddress(15 downto 0),

      -- Data contents at the selected address.
      -- Valid in same clock cycle.
      data_o  => internalRam1DataOut,

      -- New data to (optionally) be written to the selected address.
      data_i => cpuDataOut,

      -- '1' indicates we wish to perform a write at the selected address.
      wren_i => not(cpu_r_w or n_internalRam1CS)
   );

-- ____________________________________________________________________________________
-- INPUT/OUTPUT DEVICES GO HERE	
io1 : entity work.SBCTextDisplayRGB
port map (
n_reset => n_reset,
clk => clk,

-- RGB video signals
hSync => hSync,
vSync => vSync,
videoR0 => videoR0,
videoR1 => videoR1,
videoG0 => videoG0,
videoG1 => videoG1,
videoB0 => videoB0,
videoB1 => videoB1,

-- Monochrome video signals (when using TV timings only)
sync => open,
video => open,

n_wr => n_interface1CS or cpu_r_w,
n_rd => n_interface1CS or (not cpu_r_w),
n_int => n_int1,
regSel => regsel,
dataIn => cpuDataOut(7 downto 0),
dataOut => interface1DataOut,
ps2Clk => ps2Clk,
ps2Data => ps2Data
);

	
-- ____________________________________________________________________________________
-- CHIP SELECTS GO HERE


n_basRom1CS <= '0' when cpu_uds = '0' and cpuAddress(23 downto 20) = "1010" else '1'; --A00000-A0FFFF
n_basRom2CS <= '0' when cpu_lds = '0' and cpuAddress(23 downto 20) = "1010" else '1'; 
n_interface1CS <= '0' when cpuAddress = X"f0000b" or cpuAddress = X"f00009" else '1'; -- f00000b
regsel <= '0' when cpuAddress = X"f00009" else '1';
n_interface2CS <= '1'; -- '1' when cpuAddress = X"f200000" else '1'; -- f200000
n_sdCardCS <= '1'; -- '0' when cpuAddress(15 downto 3) = "1111111111011" else '1'; -- 8 bytes FFD8-FFDF
n_internalRam1CS <= '0'  when  cpuAddress <= X"FFFF" else '1' ;

-- ____________________________________________________________________________________
-- BUS ISOLATION GOES HERE
 
cpuDataIn(15 downto 8) 
<= 
r_Vec(vecAddress)(15 downto 8)
when cpuAddress(31 downto 16) = X"FFFF" and cpu_r_w = '1' else
X"00"
when n_interface1CS = '0' or n_interface2CS = '0' or (cpuAddress(31 downto 16) = X"FFFF" and cpu_r_w = '0' ) else
basRomData(15 downto 8)
when n_basRom1CS = '0' else
internalRam1DataOut(15 downto 8)
when n_internalRam1CS= '0' else
X"00" when cpu_uds = '1';

cpuDataIn(7 downto 0)
<= 
interface1DataOut 
when n_interface1CS = '0' else
interface2DataOut
when n_interface2CS = '0' else 
basRomData(7 downto 0)
when n_basRom2CS = '0' else 
internalRam1DataOut(7 downto 0)
when n_internalRam1CS = '0' else
"00000" & cpuAddress(3 downto 1)
when cpuAddress(31 downto 16) = X"FFFF" and cpu_r_w = '0' else 
r_Vec(vecAddress)(7 downto 0)
when cpuAddress(31 downto 16) = X"FFFF" and cpu_r_w = '1' 
else
X"00" when cpu_lds = '1';



cpu_dtack <= '1' when cpu_lds = '1' and cpu_uds='1' else '0';
-- Serial clock DDS
-- 50MHz master input clock:
-- Baud Increment
-- 115200 2416
-- 38400 805
-- 19200 403
-- 9600 201
-- 4800 101
-- 2400 50
-- SUB-CIRCUIT CLOCK SIGNALS
--serialClock <= serialClkCount(15);

--clock: process (clk)
--begin

--    if rising_edge(clk) then
--        serialClkCount <= serialClkCount + 201;
--    end if;

--end process;
    
end;