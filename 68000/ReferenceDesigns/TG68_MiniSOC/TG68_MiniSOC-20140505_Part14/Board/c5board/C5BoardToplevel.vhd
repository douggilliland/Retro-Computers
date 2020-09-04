library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.Toplevel_Config.ALL;


entity C5BoardToplevel is
port(
		clk_50 	: in 	std_logic;
		reset_n : in 	std_logic;
		led_out : out 	std_logic;
		btn1 : in std_logic;
		btn2 : in std_logic;

		-- SDRAM - chip 1
		sdram_clk : out std_logic; -- Different name format to escape wildcard in SDC file
		sdram_addr : out std_logic_vector(12 downto 0);
		sdram_data : inout std_logic_vector(15 downto 0);
		sdram_ba : out std_logic_vector(1 downto 0);
		sdram_cke : out std_logic;
		--sdram_dqa : out std_logic;
		sdram_cs : out std_logic;
		sdram_we : out std_logic;
		sdram_cas : out std_logic;
		sdram_ras : out std_logic;
		DRAM_LDQM		:	 out STD_LOGIC;
		DRAM_UDQM		:	 out STD_LOGIC;

		-- SDRAM - chip 2
		-- VGA
		vga_red 		: out unsigned(1 downto 0);
		vga_green 	: out unsigned(1 downto 0);
		vga_blue 	: out unsigned(1 downto 0);
		
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
		leds : out std_logic_vector(3 downto 0)
	);
end entity;

architecture RTL of C5BoardToplevel is
-- Assigns pin location to ports on an entity.
-- Declare the attribute or import its declaration from 
-- altera.altera_syn_attributes
attribute chip_pin : string;


-- Signals internal to the project

signal clk : std_logic;
signal clk_fast : std_logic;
signal reset : std_logic;  -- active low
signal pll1_locked : std_logic;
signal pll2_locked : std_logic;

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

signal W_vga_red : unsigned(5 downto 0);
signal W_vga_grn : unsigned(5 downto 0);
signal W_vga_blu : unsigned(5 downto 0);

signal audio_l : signed(15 downto 0);
signal audio_r : signed(15 downto 0);

-- Sigma Delta audio
COMPONENT hybrid_pwm_sd
	PORT
	(
		clk		:	 IN STD_LOGIC;
		n_reset		:	 IN STD_LOGIC;
		din		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dout		:	 OUT STD_LOGIC
	);
END COMPONENT;

begin

	vga_red <= W_vga_red(5)&W_vga_red(4);
	vga_green <= W_vga_grn(5)&W_vga_grn(4);
	vga_blue <= W_vga_blu(5)&W_vga_blu(4);
	
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
		
	mypll : entity work.Clock_50to100Split
		port map (
			inclk0 => clk_50,
			c0 => clk_fast,
			c1 => sdram_clk,
			c2 => clk,
			locked => pll1_locked
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
			reset_button => reset_n and pll1_locked and pll2_locked,
			reset_out => reset,
			power_button => power_button,
			power_hold => power_hold		
		);

	mydither : entity work.video_vga_dither
		generic map(
			outbits => 6
		)
		port map(
			clk=>clk_fast,
			hsync=>vga_hsync,
			vsync=>vga_vsync,
			vid_ena=>vga_window,
			iRed => vga_r,
			iGreen => vga_g,
			iBlue => vga_b,
			oRed => W_vga_red,
			oGreen => W_vga_grn,
			oBlue => W_vga_blu
		);
	
	mytg68test : entity work.VirtualToplevel
		generic map(
			sdram_rows => 13,
			sdram_cols => 10,
			sysclk_frequency => 250
		)
		port map(
			clk => clk,
			clk_fast => clk_fast,
			reset_in => reset,
			
			-- SDRAM
			sdr_addr => sdram_addr,
			sdr_data => sdram_data,
			sdr_ba => sdram_ba,
			sdr_cke => sdram_cke,
			sdr_dqm(1) => DRAM_UDQM,
			sdr_dqm(0) => DRAM_LDQM,
			sdr_cs => sdram_cs,
			sdr_we => sdram_we,
			sdr_cas => sdram_cas,
			sdr_ras => sdram_ras,
			
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
			spi_cs => sd_cs,
			spi_miso => sd_miso,
			spi_mosi => sd_mosi,
			spi_clk => sd_clk,
			
			-- Audio - FIXME abstract this out, too.
			audio_l => audio_l,
			audio_r => audio_r
			
			-- LEDs
		);

		-- Do we have audio?  If so, instantiate a two DAC channels.
audio2: if Toplevel_UseAudio = true generate
leftsd: component hybrid_pwm_sd
	port map
	(
		clk => clk,
		n_reset => reset,
		din(15) => not audio_l(15),
		din(14 downto 0) => std_logic_vector(audio_l(14 downto 0)),
		dout => aud_l
	);
	
rightsd: component hybrid_pwm_sd
	port map
	(
		clk => clk,
		n_reset => reset,
		din(15) => not audio_r(15),
		din(14 downto 0) => std_logic_vector(audio_r(14 downto 0)),
		dout => aud_r
	);
end generate;

-- No audio?  Make the audio pins high Z.

audio3: if Toplevel_UseAudio = false generate
	aud_l<='Z';
	aud_r<='Z';
end generate;

end RTL;

