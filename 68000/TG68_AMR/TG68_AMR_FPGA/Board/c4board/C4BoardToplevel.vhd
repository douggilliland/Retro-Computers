--
--	TG68_AMR Design 
--		https://hackaday.io/project/174679-68k-cpu-with-frame-buffer-on-fpga
--	
-- Top level TG68 files
--
-- Features
--		68000 Core
--		32MB SDRAM
--			support for Main Memory and Frame buffer
--		VGA Framebuffer supports various screen resolutions
--		PS/2 Keyboard and Mouse support
--		USB-Serial port
--			115.200 baud
--		Stereo Audio (External via J1)
--		SD Card support (External via J1)
--		SRAM (not used but pulled to inactive)
-- Runs on FPGA card is 5CEFA2F23I7 Cyclone V FPGA
--		http://land-boards.com/blwiki/index.php?title=QM_Tech_Cyclone_V_FPGA_Board
--	Multicomp in a Box
--		http://land-boards.com/blwiki/index.php?title=Multicomp_in_a_Box
--
-- Memory Map
--		0x00000000-0x0000ffff = ROM 
--		0x80000000 = VGA controller
--		0x81000000 = Peripherals
--		0x82000000 = Audio controller
--		Everywhere else = SDRAM - 8 MB?
--
-- Doug Gilliland 2020
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL; 

library altera;
use altera.altera_syn_attributes.all;

library work;
use work.Toplevel_Config.ALL;

entity C4BoardToplevel is
	port (
		clk_50			: in 	std_logic;
		reset_n			: in 	std_logic;

		-- SDRAM
		o_sdram_clk		: buffer std_logic; -- Different name format to escape wildcard in SDC file
		o_sdram_addr	: out std_logic_vector(12 downto 0);
		io_sdram_data	: inout std_logic_vector(15 downto 0);
		o_sdram_ba		: out std_logic_vector(1 downto 0);
		o_sdram_cke		: out std_logic;
		o_sdram_cs		: buffer std_logic;
		o_sdram_we		: out std_logic;
		o_sdram_cas		: out std_logic;
		o_sdram_ras		: out std_logic;
		o_sdram_ldqm	: out std_logic;
		o_sdram_udqm	: out std_logic;

		-- VGA 2:2:2 R:G:B
		o_vga_red 		: out unsigned(1 downto 0);
		o_vga_green 	: out unsigned(1 downto 0);
		o_vga_blue 		: out unsigned(1 downto 0);
		o_vga_hsync 	: buffer std_logic;
		o_vga_vsync 	: buffer std_logic;

		-- PS/2 Keyboard/Mouse
		ps2k_clk 		: inout std_logic;
		ps2k_dat 		: inout std_logic;
		ps2m_clk 		: inout std_logic;
		ps2m_dat 		: inout std_logic;
		
		-- Audio
		aud_l 			: out std_logic;
		aud_r 			: out std_logic;
		
		-- Serial (USB-to-Serial)
		rs232_rxd		: in std_logic;
		rs232_txd		: out std_logic;
		n_cts				: in std_logic := '0';
		n_rts				: out std_logic := '0';

		-- SD card interface
		sd_cs				: out std_logic;
		sd_miso			: in std_logic;
		sd_mosi			: out std_logic;
		sd_clk			: out std_logic;
		
		-- SRAM not used
		io_sramData 	: inout	std_logic_vector(7 downto 0);
		o_sramAddress	: out		std_logic_vector(19 downto 0) := x"00000";
		o_n_sRamWE		: out		std_logic := '1';
		o_n_sRamCS		: out		std_logic := '1';
		o_n_sRamOE 		: out		std_logic := '1';
		
		-- Power and LEDs (wired to J1 pins 3-...)
		power_button 	: in std_logic;
		power_hold 		: out std_logic := '1';
		leds 				: out std_logic_vector(3 downto 0)
	);
end entity;

architecture RTL of C4BoardToplevel is

signal clk					: std_logic;
signal w_clk_fast			: std_logic;
signal w_reset				: std_logic;  -- active low
signal w_pll_locked		: std_logic;

signal w_debugvalue		: std_logic_vector(15 downto 0);

signal w_ps2m_clk_in 	: std_logic;
signal w_ps2m_clk_out	: std_logic;
signal w_ps2m_dat_in 	: std_logic;
signal w_ps2m_dat_out	: std_logic;

signal w_ps2k_clk_in		: std_logic;
signal w_ps2k_clk_out	: std_logic;
signal w_ps2k_dat_in		: std_logic;
signal w_ps2k_dat_out	: std_logic;

signal w_power_led		: unsigned(5 downto 0);
signal w_disk_led			: unsigned(5 downto 0);
signal w_net_led			: unsigned(5 downto 0);
signal w_odd_led			: unsigned(5 downto 0);

signal w_vga_r 			: unsigned(7 downto 0);
signal w_vga_g				: unsigned(7 downto 0);
signal w_vga_b				: unsigned(7 downto 0);
signal w_vga_window 		: std_logic;

signal w_audio_l 			: signed(15 downto 0);
signal w_audio_r 			: signed(15 downto 0);

-- Sigma Delta audio output
COMPONENT hybrid_pwm_sd
	PORT
	(
		clk		:	 IN STD_LOGIC;
		n_reset	:	 IN STD_LOGIC;
		din		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		dout		:	 OUT STD_LOGIC
	);
END COMPONENT;

begin

	w_power_led(5 downto 2)	<= unsigned(w_debugvalue(15 downto 12));
	w_disk_led(5 downto 2)	<= unsigned(w_debugvalue(11 downto 8));
	w_net_led(5 downto 2)	<= unsigned(w_debugvalue(7 downto 4));
	w_odd_led(5 downto 2)	<= unsigned(w_debugvalue(3 downto 0));

	w_ps2m_dat_in	<= ps2m_dat;
	ps2m_dat			<= '0' when w_ps2m_dat_out='0' else 'Z';
	w_ps2m_clk_in	<= ps2m_clk;
	ps2m_clk			<= '0' when w_ps2m_clk_out='0' else 'Z';

	w_ps2k_dat_in	<= ps2k_dat;
	ps2k_dat			<= '0' when w_ps2k_dat_out='0' else 'Z';
	w_ps2k_clk_in	<= ps2k_clk;
	ps2k_clk			<= '0' when w_ps2k_clk_out='0' else 'Z';
		
	mypll : entity work.Clock_50to100
		port map (
			inclk0	=> clk_50,
			c0	=> w_clk_fast,			-- 100 MHz
			c1	=> o_sdram_clk,		-- 100 MHz
			c2	=> clk,					-- 25 MHz
			locked	=> w_pll_locked
		);

	myleds : entity work.statusleds_pwm
		port map(
			clk			=> clk,
			power_led	=> w_power_led,
			disk_led		=> w_disk_led,
			net_led		=> w_net_led,
			odd_led		=> w_odd_led,
			leds_out		=> leds
		);
	
	myw_reset : entity work.poweronreset
		port map(
			clk				=> clk,
			reset_button	=> reset_n and w_pll_locked,
			reset_out		=> w_reset,
			power_button	=> power_button,
			power_hold		=> power_hold		
		);

	mydither : entity work.video_vga_dither
		generic map(
			outbits => 2
		)
		port map (
			clk		=> w_clk_fast,
			hsync		=> o_vga_hsync,
			vsync		=> o_vga_vsync,
			vid_ena	=> w_vga_window,
			iRed		=> w_vga_r,
			iGreen	=> w_vga_g,
			iBlue		=> w_vga_b,
			oRed		=> o_vga_red,
			oGreen	=> o_vga_green,
			oBlue		=> o_vga_blue
		);

--	o_vga_hsync <= w_vga_hsync;
--	o_vga_vsync <= w_vga_vsync;
	
	tg68tst : entity work.VirtualToplevel
		generic map (
			-- W9825C6KH-6 Winbond 4M X 4 Banks x 16 bits SDRAM
			-- 13 rows, 9 columns
			sdram_rows			=> 13,
			sdram_cols			=> 9,
			sysclk_frequency	=> 250
		)
		port map (
			clk			=> clk,
			clk_fast 	=> w_clk_fast,
			reset_in 	=> w_reset,
			
			-- SDRAM
			sdr_addr		=> o_sdram_addr,
			sdr_data		=> io_sdram_data,
			sdr_ba		=> o_sdram_ba,
			sdr_cke		=> o_sdram_cke,
			sdr_dqm(1)	=> o_sdram_udqm,
			sdr_dqm(0)	=> o_sdram_ldqm,
			sdr_cs		=> o_sdram_cs,
			sdr_we		=> o_sdram_we,
			sdr_cas		=> o_sdram_cas,
			sdr_ras		=> o_sdram_ras,
			
			-- VGA
			vga_red		=> w_vga_r,
			vga_green	=> w_vga_g,
			vga_blue		=> w_vga_b,
			vga_hsync => o_vga_hsync,
			vga_vsync => o_vga_vsync,
			
			vga_window => w_vga_window,

			-- UART
			rxd => rs232_rxd,
			txd => rs232_txd,
				
			-- PS/2
			ps2k_clk_in		=> w_ps2k_clk_in,
			ps2k_dat_in		=> w_ps2k_dat_in,
			ps2k_clk_out	=> w_ps2k_clk_out,
			ps2k_dat_out	=> w_ps2k_dat_out,
			ps2m_clk_in		=> w_ps2m_clk_in,
			ps2m_dat_in		=> w_ps2m_dat_in,
			ps2m_clk_out	=> w_ps2m_clk_out,
			ps2m_dat_out	=> w_ps2m_dat_out,
			
			-- SD Card interface
			spi_cs	=> sd_cs,
			spi_miso	=> sd_miso,
			spi_mosi => sd_mosi,
			spi_clk	=> sd_clk,
			
			-- Audio - FIXME abstract this out, too.
			audio_l => w_audio_l,
			audio_r => w_audio_r
		);

	-- Do we have audio?  If so, instantiate a two DAC channels.
	audio2: if Toplevel_UseAudio = true generate
		leftsd: component hybrid_pwm_sd
			port map
			(
				clk					=> clk,
				n_reset				=> reset_n,
				din(15)				=> not w_audio_l(15),
				din(14 downto 0)	=> std_logic_vector(w_audio_l(14 downto 0)),
				dout					=> aud_l
			);
			
		rightsd: component hybrid_pwm_sd
			port map
			(
				clk => clk,
				n_reset => reset_n,
				din(15) => not w_audio_r(15),
				din(14 downto 0) => std_logic_vector(w_audio_r(14 downto 0)),
				dout => aud_r
			);
		end generate;

	-- No audio?  Make the audio pins high Z.
	audio3: if Toplevel_UseAudio = false generate
		aud_l<='Z';
		aud_r<='Z';
	end generate;

end RTL;

