-- Toplevel file for EMS11-BB21 board

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity EMS11_BB21Toplevel is
port
(
		-- Housekeeping
	CLK50 : in std_logic;

		-- UART
	UART1_TXD : out std_logic;
	UART1_RXD : in std_logic;
	UART1_RTS_N : out std_logic;
	UART1_CTS_N : in std_logic;
	
		-- SDRAM
	DR_CAS_N : out std_logic;
	DR_CS_N : out std_logic;
	DR_RAS_N : out std_logic;
	DR_WE_N	: out std_logic;
	DR_CLK_I : in std_logic;
	DR_CLK_O : out std_logic;
	DR_CKE : out std_logic;
	DR_A : out std_logic_vector(12 downto 0);
	DR_D : inout std_logic_vector(15 downto 0);
	DR_DQMH : out std_logic;
	DR_DQML : out std_logic;
	DR_BA : out std_logic_vector(1 downto 0);
	
		-- SD Card

	FPGA_SD_CDET_N : in std_logic;
	FPGA_SD_WPROT_N : in std_logic;
	FPGA_SD_CMD : out std_logic;
	FPGA_SD_D0 : in std_logic;
	FPGA_SD_D1 : in std_logic; -- High Z since we're using SPI-mode
	FPGA_SD_D2 : in std_logic; -- High Z since we're using SPI-mode
	FPGA_SD_D3 : out std_logic;
	FPGA_SD_SCLK : out std_logic;
	
		-- VGA Connector
	UART2_RTS_N : out std_logic; -- Actually used for VGA
	M1_S : inout std_logic_vector(39 downto 0);

		-- LEDs
	LED1 : out std_logic;
	LED2 : out std_logic;
	
		-- Emus GPIO
	GPIO : inout std_logic_vector(15 downto 0);

		-- Buttons
	DIAG_N : in std_logic;
	RESET_N : in std_logic
);
end entity;


architecture rtl of EMS11_BB21Toplevel is

signal sdram_clk : std_logic;
signal sdram_clk_inv : std_logic;
signal sysclk : std_logic;
signal sysclk_inv : std_logic;
signal clklocked : std_logic;
signal sysclk_slow : std_logic;

signal vga_red : unsigned(9 downto 0);
signal vga_green : unsigned(9 downto 0);
signal vga_blue : unsigned(9 downto 0);
signal vga_hsync : std_logic;
signal vga_vsync : std_logic;
signal vga_window : std_logic;
signal vga_clock : std_logic;
signal vga_blank : std_logic;
signal vga_sync : std_logic;
signal vga_psave : std_logic;

-- PS/2 ports
-- alias PS2_MCLK : std_logic is M1_S(35);
-- alias PS2_MDAT : std_logic is M1_S(33);
-- alias PS2_CLK : std_logic is M1_S(37);
-- alias PS2_DAT : std_logic is M1_S(39);

alias PS2_MCLK : std_logic is M1_S(33);
alias PS2_MDAT : std_logic is M1_S(35);
alias PS2_CLK : std_logic is M1_S(39);
alias PS2_DAT : std_logic is M1_S(37);

signal ps2m_clk_in : std_logic;
signal ps2m_clk_out : std_logic;
signal ps2m_dat_in : std_logic;
signal ps2m_dat_out : std_logic;

signal ps2k_clk_in : std_logic;
signal ps2k_clk_out : std_logic;
signal ps2k_dat_in : std_logic;
signal ps2k_dat_out : std_logic;

begin
UART1_RTS_N<='1';  -- safe default since we're not using handshaking.

-- DR_CLK_O<='1';
LED1 <= RESET_N;
LED2 <= DIAG_N;

ps2m_dat_in<=PS2_MDAT;
PS2_MDAT <= '0' when ps2m_dat_out='0' else 'Z';
ps2m_clk_in<=PS2_MCLK;
PS2_MCLK <= '0' when ps2m_clk_out='0' else 'Z';

ps2k_dat_in<=PS2_DAT;
PS2_DAT <= '0' when ps2k_dat_out='0' else 'Z';
ps2k_clk_in<=PS2_CLK;
PS2_CLK <= '0' when ps2k_clk_out='0' else 'Z';

-- Clock generation.  We need a system clock and an SDRAM clock.
-- Limitations of the Spartan 6 mean we need to "forward" the SDRAM clock
-- to the io pin.

myclock : entity work.Clock_50to100Split
port map(
	CLK_IN1 => CLK50,
	RESET => '0',
	CLK_OUT1 => sysclk,
	CLK_OUT2 => sdram_clk,
	CLK_OUT3 => sysclk_slow,
	LOCKED => clklocked
);

sysclk_inv <= not sysclk;
sdram_clk_inv <= not sdram_clk;

ODDR2_inst : ODDR2
generic map(
	DDR_ALIGNMENT => "NONE",
	INIT => '0',
	SRTYPE => "SYNC")
port map (
	Q => DR_CLK_O,
	C0 => sdram_clk,
	C1 => sdram_clk_inv,
	CE => '1',
	D0 => '0',
	D1 => '1',
	R => '0',    -- 1-bit reset input
	S => '0'     -- 1-bit set input
);

-- Forward the VGA clock too.

ODDR2_inst2 : ODDR2
generic map(
	DDR_ALIGNMENT => "NONE",
	INIT => '0',
	SRTYPE => "SYNC")
port map (
	Q => vga_clock,
	C0 => sysclk,
	C1 => sysclk_inv,
	CE => '1',
	D0 => '0',
	D1 => '1',
	R => '0',    -- 1-bit reset input
	S => '0'     -- 1-bit set input
);


-- vga_clock <= sysclk;
vga_sync <= '0';
vga_blank <= vga_window;
vga_psave <= '1';

UART2_RTS_N<=vga_green(9);
M1_S(0)<=vga_green(8);
M1_S(2)<=vga_green(7);
M1_S(4)<=vga_green(6);
M1_S(6)<=vga_green(5);
M1_S(8)<=vga_green(4);
M1_S(10)<=vga_green(3);
M1_S(12)<=vga_green(2);
M1_S(14)<=vga_green(1);
M1_S(16)<=vga_green(0);

M1_S(18)<=vga_blue(4);
M1_S(20)<=vga_blue(5);
M1_S(22)<=vga_blue(6);
M1_S(24)<=vga_blue(7);
M1_S(26)<=vga_blue(8);
M1_S(28)<=vga_blue(9);

M1_S(30)<=vga_clock;
M1_S(32)<=vga_psave;
M1_S(34)<=vga_hsync;
M1_S(36)<=vga_vsync;

M1_S(1)<=vga_blue(3);
M1_S(3)<=vga_blue(2);
M1_S(5)<=vga_blue(1);
M1_S(7)<=vga_blue(0);

M1_S(9)<=vga_blank;
M1_S(11)<=vga_sync;
M1_S(13)<=vga_red(9);
M1_S(15)<=vga_red(8);
M1_S(17)<=vga_red(7);
M1_S(19)<=vga_red(6);
M1_S(21)<=vga_red(5);
M1_S(23)<=vga_red(4);
M1_S(25)<=vga_red(3);
M1_S(27)<=vga_red(2);
M1_S(29)<=vga_red(1);
M1_S(31)<=vga_red(0);
M1_S(38)<='1';

-- DR_A(12)<='0'; -- Temporary measure

project: entity work.VirtualToplevel
	generic map (
		sdram_rows => 13,
		sdram_cols => 10,
		sysclk_frequency => 250, -- Sysclk frequency * 10
		fastclk_frequency => 1000 -- Sysclk frequency * 10
	)
	port map (
		clk => sysclk_slow,
		clk_fast => sysclk,
		reset_in => RESET_N,
	
		-- VGA
		vga_red => vga_red(9 downto 2),
		vga_green => vga_green(9 downto 2),
		vga_blue => vga_blue(9 downto 2),
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_window => vga_window,

		-- SDRAM
		sdr_data => DR_D,
		sdr_addr => DR_A(12 downto 0),
		sdr_dqm(1) => DR_DQMH,
		sdr_dqm(0) => DR_DQML,
		sdr_we => DR_WE_N,
		sdr_cas => DR_CAS_N,
		sdr_ras => DR_RAS_N,
		sdr_cs => DR_CS_N,
		sdr_ba => DR_BA,
		sdr_cke => DR_CKE,

		-- SD Card
		spi_cs => FPGA_SD_D3,
		spi_miso => FPGA_SD_D0,
		spi_mosi => FPGA_SD_CMD,
		spi_clk => FPGA_SD_SCLK,

		-- PS/2
		ps2k_clk_in => ps2k_clk_in,
		ps2k_dat_in => ps2k_dat_in,
		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_out => ps2k_dat_out,
		ps2m_clk_in => ps2m_clk_in,
		ps2m_dat_in => ps2m_dat_in,
		ps2m_clk_out => ps2m_clk_out,
		ps2m_dat_out => ps2m_dat_out,
		
		-- Emus GPIO
		gpio_data => GPIO,

		-- UART
		rxd => UART1_RXD,
		txd => UART1_TXD
);

end architecture;
