library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

library altera;
use altera.altera_syn_attributes.all;


entity C3BoardToplevel is
port(
		clk_50 	: in 	std_logic;
		reset_n : in 	std_logic;
		led_out : out 	std_logic;
		btn1 : in std_logic;
		btn2 : in std_logic;

		-- SDRAM - chip 1
		sdram1_clk : out std_logic; -- Different name format to escape wildcard in SDC file
		sd1_addr : out std_logic_vector(11 downto 0);
		sd1_data : inout std_logic_vector(7 downto 0);
		sd1_ba : out std_logic_vector(1 downto 0);
		sd1_cke : out std_logic;
		sd1_dqm : out std_logic;
		sd1_cs : out std_logic;
		sd1_we : out std_logic;
		sd1_cas : out std_logic;
		sd1_ras : out std_logic;

		-- SDRAM - chip 2
		sdram2_clk : out std_logic; -- Different name format to escape wildcard in SDC file
		sd2_addr : out std_logic_vector(11 downto 0);
		sd2_data : inout std_logic_vector(7 downto 0);
		sd2_ba : out std_logic_vector(1 downto 0);
		sd2_cke : out std_logic;
		sd2_dqm : out std_logic;
		sd2_cs : out std_logic;
		sd2_we : out std_logic;
		sd2_cas : out std_logic;
		sd2_ras : out std_logic;
		
		-- VGA
		vga_red 		: out unsigned(5 downto 0);
		vga_green 	: out unsigned(5 downto 0);
		vga_blue 	: out unsigned(5 downto 0);
		
		vga_hsync 	: buffer std_logic;
		vga_vsync 	: buffer std_logic;

		-- PS/2
		ps2k_clk : inout std_logic;
		ps2k_dat : inout std_logic;
		ps2m_clk : inout std_logic;
		ps2m_dat : inout std_logic;
		
		-- Audio
		aud_l : out std_logic;
		aud_r : out std_logic;
		
		-- RS232
		rs232_rxd : in std_logic;
		rs232_txd : out std_logic;

		-- SD card interface
		sd_cs : out std_logic;
		sd_miso : in std_logic;
		sd_mosi : out std_logic;
		sd_clk : out std_logic;
		
		-- Power and LEDs
		power_button : in std_logic;
		power_hold : out std_logic := '1';
		leds : out std_logic_vector(3 downto 0);
		
		-- Any remaining IOs yet to be assigned
		misc_ios_1 : in std_logic_vector(5 downto 0);
		misc_ios_21 : in std_logic_vector(13 downto 0);
		misc_ios_22 : in std_logic_vector(8 downto 0);
		misc_ios_3 : in std_logic_vector(1 downto 0)
	);
end entity;

architecture RTL of C3BoardToplevel is
-- Assigns pin location to ports on an entity.
-- Declare the attribute or import its declaration from 
-- altera.altera_syn_attributes
attribute chip_pin : string;

-- Board features

attribute chip_pin of clk_50 : signal is "152";
attribute chip_pin of reset_n : signal is "181";
attribute chip_pin of led_out : signal is "233";

-- SDRAM (2 distinct 8-bit wide chips)

attribute chip_pin of sd1_addr : signal is "83,69,82,81,80,78,99,110,63,64,65,68";
attribute chip_pin of sd1_data : signal is "109,103,111,93,100,106,107,108";
attribute chip_pin of sd1_ba : signal is "70,71";
attribute chip_pin of sdram1_clk : signal is "117";
attribute chip_pin of sd1_cke : signal is "84";
attribute chip_pin of sd1_dqm : signal is "87";
attribute chip_pin of sd1_cs : signal is "72";
attribute chip_pin of sd1_we : signal is "88";
attribute chip_pin of sd1_cas : signal is "76";
attribute chip_pin of sd1_ras : signal is "73";

attribute chip_pin of sd2_addr : signal is "142,114,144,139,137,134,148,161,120,119,118,113";
attribute chip_pin of sd2_data : signal is "166,164,162,160,146,147,159,168";
attribute chip_pin of sd2_ba : signal is "126,127";
attribute chip_pin of sdram2_clk : signal is "186";
attribute chip_pin of sd2_cke : signal is "143";
attribute chip_pin of sd2_dqm : signal is "145";
attribute chip_pin of sd2_cs : signal is "128";
attribute chip_pin of sd2_we : signal is "133";
attribute chip_pin of sd2_cas : signal is "132";
attribute chip_pin of sd2_ras : signal is "131";

-- Video output via custom board

attribute chip_pin of vga_red : signal is "13, 9, 5, 240, 238, 236";
attribute chip_pin of vga_green : signal is "49, 45, 43, 39, 37, 18";
attribute chip_pin of vga_blue : signal is "52, 50, 46, 44, 41, 38";

attribute chip_pin of vga_hsync : signal is "51";
attribute chip_pin of vga_vsync : signal is "55";

-- Audio output via custom board

attribute chip_pin of aud_l : signal is "6";
attribute chip_pin of aud_r : signal is "22";

-- PS/2 sockets on custom board

attribute chip_pin of ps2k_clk : signal is "235";
attribute chip_pin of ps2k_dat : signal is "237";
attribute chip_pin of ps2m_clk : signal is "239";
attribute chip_pin of ps2m_dat : signal is "4";

-- RS232
attribute chip_pin of rs232_rxd : signal is "98";
attribute chip_pin of rs232_txd : signal is "112";

-- SD card interface
attribute chip_pin of sd_cs : signal is "185";
attribute chip_pin of sd_miso : signal is "196";
attribute chip_pin of sd_mosi : signal is "188";
attribute chip_pin of sd_clk : signal is "194";


-- Power and LEDs
attribute chip_pin of power_hold : signal is "171";
attribute chip_pin of power_button : signal is "94";

attribute chip_pin of leds : signal is "173, 169, 167, 135";

attribute chip_pin of btn1 : signal is "226";
attribute chip_pin of btn2 : signal is "231";

-- Free pins, not yet assigned

attribute chip_pin of misc_ios_1 : signal is "12,14,56,234,21,57";

attribute chip_pin of misc_ios_21 : signal is "184,187,189,195,197,201,203,214,217,219,221,223,232";
attribute chip_pin of misc_ios_22 : signal is "176,183,200,202,207,216,218,224,230";
attribute chip_pin of misc_ios_3 : signal is "95,177";

-- Signals internal to the project

signal clk : std_logic;
signal reset : std_logic;  -- active low
signal counter : unsigned(34 downto 0);

signal debugvalue : std_logic_vector(15 downto 0);

signal btn1_d : std_logic;
signal btn2_d : std_logic;

signal currentX : unsigned(11 downto 0);
signal currentY : unsigned(11 downto 0);
signal end_of_pixel : std_logic;
signal end_of_line : std_logic;
signal end_of_frame : std_logic;

-- SDRAM - merged signals to make the two chips appear as a single 16-bit wide entity.
signal sdr_addr : std_logic_vector(11 downto 0);
signal sdr_dqm : std_logic_vector(1 downto 0);
signal sdr_we : std_logic;
signal sdr_cas : std_logic;
signal sdr_ras : std_logic;
signal sdr_cs : std_logic;
signal sdr_ba : std_logic_vector(1 downto 0);
-- signal sdr_clk : std_logic;
signal sdr_cke : std_logic;

signal ps2m_clk_in : std_logic;
signal ps2m_clk_out : std_logic;
signal ps2m_dat_in : std_logic;
signal ps2m_dat_out : std_logic;

signal ps2k_clk_in : std_logic;
signal ps2k_clk_out : std_logic;
signal ps2k_dat_in : std_logic;
signal ps2k_dat_out : std_logic;

signal power_led : unsigned(5 downto 0);
signal disk_led : unsigned(5 downto 0);
signal net_led : unsigned(5 downto 0);
signal odd_led : unsigned(5 downto 0);

signal vga_r : unsigned(7 downto 0);
signal vga_g : unsigned(7 downto 0);
signal vga_b : unsigned(7 downto 0);
signal vga_window : std_logic;

signal pll_phasedir : std_logic;
signal pll_phasestep : std_logic_vector(1 downto 0); -- We have two chips and hence two PLLs to configure
signal pll_phasedone : std_logic;
signal pll_phasedone2 : std_logic;

begin

	mybtn1: entity work.Debounce
		port map(
		clk => clk,
		signal_in => btn1,
		signal_out => btn1_d
	);

	mybtn2: entity work.Debounce
		port map(
		clk => clk,
		signal_in => btn2,
		signal_out => btn2_d
	);

	power_led(5 downto 2)<=unsigned(debugvalue(15 downto 12));
	disk_led(5 downto 2)<=unsigned(debugvalue(11 downto 8));
	net_led(5 downto 2)<=unsigned(debugvalue(7 downto 4));
	odd_led(5 downto 2)<=unsigned(debugvalue(3 downto 0));

	ps2m_dat_in<=ps2m_dat;
	ps2m_dat <= '0' when ps2m_dat_out='0' else 'Z';
	ps2m_clk_in<=ps2m_clk;
	ps2m_clk <= '0' when ps2m_clk_out='0' else 'Z';

	ps2k_dat_in<=ps2k_dat;
	ps2k_dat <= '0' when ps2k_dat_out='0' else 'Z';
	ps2k_clk_in<=ps2k_clk;
	ps2k_clk <= '0' when ps2k_clk_out='0' else 'Z';

	sd1_addr <= sdr_addr;
	sd1_dqm <= sdr_dqm(0);
--	sd1_clk <= sdr_clk;
	sd1_we <= sdr_we;
	sd1_cas <= sdr_cas;
	sd1_ras <= sdr_ras;
	sd1_cs <= sdr_cs;
	sd1_ba <= sdr_ba;
	sd1_cke <= sdr_cke;

	sd2_addr <= sdr_addr;
	sd2_dqm <= sdr_dqm(1);
--	sd2_clk <= sdr_clk;
	sd2_we <= sdr_we;
	sd2_cas <= sdr_cas;
	sd2_ras <= sdr_ras;
	sd2_cs <= sdr_cs;
	sd2_ba <= sdr_ba;
	sd2_cke <= sdr_cke;
		
	mypll : entity work.PLL
		port map (
			inclk0 => clk_50,
			c0 => clk,
			c1 => sdram1_clk
		);
		
	mypll2 : entity work.PLL2
		port map (
			inclk0 => clk_50,
			c1 => sdram2_clk
		);

	myleds : entity work.statusleds_pwm
	port map(
		clk => clk,
		power_led => power_led,
		disk_led => disk_led,
		net_led => net_led,
		odd_led => odd_led,
		leds_out => leds
	);
	
	myreset : entity work.poweronreset
		port map(
			clk => clk,
			reset_button => reset_n,
			reset_out => reset,
			power_button => power_button,
			power_hold => power_hold		
		);

	mydither : entity work.video_vga_dither
		generic map(
			outbits => 6
		)
		port map(
			clk=>clk,
			hsync=>vga_hsync,
			vsync=>vga_vsync,
			vid_ena=>vga_window,
			iRed => vga_r,
			iGreen => vga_g,
			iBlue => vga_b,
			oRed => vga_red,
			oGreen => vga_green,
			oBlue => vga_blue
		);
	
	mytg68test : entity work.TG68Test
		generic map(
			sdram_rows => 12,
			sdram_cols => 10,
			sysclk_frequency => 1330,
			spi_maxspeed => 4
		)
		port map(
			clk => clk,
			reset_in => reset,
			
			switches => (others =>'0'),

--			-- Timing configuration
--			pll_phasedir => pll_phasedir,
--			pll_phasestep => pll_phasestep,
--			pll_phasedone => pll_phasedone and pll_phasedone2,
			
			-- SDRAM - presenting a single interface to both chips.
			sdr_addr => sdr_addr,
			sdr_data(15 downto 8) => sd2_data,
			sdr_data(7 downto 0) => sd1_data,
			sdr_ba => sdr_ba,
			sdr_cke => sdr_cke,
			sdr_dqm => sdr_dqm,
			sdr_cs => sdr_cs,
			sdr_we => sdr_we,
			sdr_cas => sdr_cas,
			sdr_ras => sdr_ras,
			
			-- VGA
			vga_red => vga_r,
			vga_green => vga_g,
			vga_blue => vga_b,
			
			vga_hsync => vga_hsync,
			vga_vsync => vga_vsync,
			
			vga_window => vga_window,

			-- UART
			rxd => rs232_rxd,
			txd => rs232_txd,
			
			-- Misc
			pausecpu => '1',
			pausevga => '1',
			buttons => "111",
			
			-- PS/2
			ps2k_clk_in => ps2k_clk_in,
			ps2k_dat_in => ps2k_dat_in,
			ps2k_clk_out => ps2k_clk_out,
			ps2k_dat_out => ps2k_dat_out,
			ps2m_clk_in => ps2m_clk_in,
			ps2m_dat_in => ps2m_dat_in,
			ps2m_clk_out => ps2m_clk_out,
			ps2m_dat_out => ps2m_dat_out,
			
			-- SD Card interface
			sd_cs => sd_cs,
			sd_miso => sd_miso,
			sd_mosi => sd_mosi,
			sd_clk => sd_clk,
			
			-- Audio - FIXME abstract this out, too.
--			aud_l => aud_l,
--			aud_r => aud_r,
			
			-- LEDs
			counter => debugvalue
--			led_out => led_out,
--			power_led => power_led,
--			disk_led => disk_led,
--			net_led => net_led,
--			odd_led => odd_led
		);
		
end RTL;

	