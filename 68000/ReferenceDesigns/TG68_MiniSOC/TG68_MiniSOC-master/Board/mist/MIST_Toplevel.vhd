library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
 
entity MIST_Toplevel is
	port
	(
		CLOCK_27		:	 in std_logic_vector(1 downto 0);
		
		LED			: 	out std_logic;

		UART_TX		:	 out STD_LOGIC;
		UART_RX		:	 in STD_LOGIC;

		SDRAM_DQ		:	 inout std_logic_vector(15 downto 0);
		SDRAM_A	:	 out std_logic_vector(12 downto 0);
		SDRAM_DQMH	:	 out STD_LOGIC;
		SDRAM_DQML	:	 out STD_LOGIC;
		SDRAM_nWE	:	 out STD_LOGIC;
		SDRAM_nCAS	:	 out STD_LOGIC;
		SDRAM_nRAS	:	 out STD_LOGIC;
		SDRAM_nCS	:	 out STD_LOGIC;
		SDRAM_BA		:	 out std_logic_vector(1 downto 0);
		SDRAM_CLK	:	 out STD_LOGIC;
		SDRAM_CKE	:	 out STD_LOGIC;

		SPI_DO	: inout std_logic;
		SPI_DI	: in std_logic;
		SPI_SCK		:	 in STD_LOGIC;
		SPI_SS2		:	 in STD_LOGIC; -- FPGA
		SPI_SS3		:	 in STD_LOGIC; -- OSD
		SPI_SS4		:	 in STD_LOGIC; -- "sniff" mode
		CONF_DATA0  : in std_logic; -- SPI_SS for user_io

		VGA_HS		:	buffer STD_LOGIC;
		VGA_VS		:	buffer STD_LOGIC;
		VGA_R		:	 out unsigned(5 downto 0);
		VGA_G		:	 out unsigned(5 downto 0);
		VGA_B		:	 out unsigned(5 downto 0);

		AUDIO_L : out std_logic;
		AUDIO_R : out std_logic
	);
END entity;

architecture rtl of MIST_Toplevel is

signal reset : std_logic;
signal pll_locked : std_logic;
signal clk_fast : std_logic;
signal clk      : std_logic;

signal audiol : std_logic_vector(15 downto 0);
signal audior : std_logic_vector(15 downto 0);

signal vga_tred : unsigned(7 downto 0);
signal vga_tgreen : unsigned(7 downto 0);
signal vga_tblue : unsigned(7 downto 0);
signal vga_window : std_logic;

-- core video to be fed into osd
signal core_r : std_logic_vector(5 downto 0);
signal core_g : std_logic_vector(5 downto 0);
signal core_b : std_logic_vector(5 downto 0);
signal core_vs: std_logic;
signal core_hs: std_logic;
signal osdclk:  std_logic;

-- user_io
signal buttons: std_logic_vector(1 downto 0);
signal status:  std_logic_vector(7 downto 0);
signal joy_0: std_logic_vector(5 downto 0);
signal joy_1: std_logic_vector(5 downto 0);
signal joyn_0: std_logic_vector(5 downto 0);
signal joyn_1: std_logic_vector(5 downto 0);
signal joy_ana_0: std_logic_vector(15 downto 0);
signal joy_ana_1: std_logic_vector(15 downto 0);
signal txd:     std_logic;
signal par_out_data: std_logic_vector(7 downto 0);
signal par_out_strobe: std_logic;

-- signals to connect sd card emulation with io controller
signal sd_lba:  std_logic_vector(31 downto 0);
signal sd_rd:   std_logic;
signal sd_wr:   std_logic;
signal sd_ack:  std_logic;
signal sd_conf: std_logic;
signal sd_sdhc: std_logic;
signal sd_allow_sdhc: std_logic;
signal sd_allow_sdhcD: std_logic;
signal sd_allow_sdhcD2: std_logic;
signal sd_allow_sdhc_changed: std_logic;
-- data from io controller to sd card emulation
signal sd_data_in: std_logic_vector(7 downto 0);
signal sd_data_in_strobe:  std_logic;
signal sd_data_out: std_logic_vector(7 downto 0);
signal sd_data_out_strobe:  std_logic;

-- sd card emulation
signal sd_cs:	std_logic;
signal sd_sck:	std_logic;
signal sd_sdi:	std_logic;
signal sd_sdo:	std_logic;

-- PS/2
signal ps2_clk : std_logic;
signal ps2counter : unsigned(10 downto 0);

-- PS/2 Keyboard
signal ps2_keyboard_clk_in : std_logic;
signal ps2_keyboard_dat_in : std_logic;
signal ps2_keyboard_clk_mix : std_logic;
signal ps2_keyboard_clk_out : std_logic;
signal ps2_keyboard_dat_out : std_logic;

-- PS/2 Mouse
signal ps2_mouse_clk_in : std_logic;
signal ps2_mouse_dat_in : std_logic;
signal ps2_mouse_clk_mix : std_logic;
signal ps2_mouse_clk_out : std_logic;
signal ps2_mouse_dat_out : std_logic;

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

COMPONENT video_vga_dither
	GENERIC ( outbits : INTEGER := 4 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		hsync		:	 IN STD_LOGIC;
		vsync		:	 IN STD_LOGIC;
		vid_ena		:	 IN STD_LOGIC;
		iRed		:	 IN UNSIGNED(7 DOWNTO 0);
		iGreen		:	 IN UNSIGNED(7 DOWNTO 0);
		iBlue		:	 IN UNSIGNED(7 DOWNTO 0);
		oRed		:	 OUT UNSIGNED(outbits-1 DOWNTO 0);
		oGreen		:	 OUT UNSIGNED(outbits-1 DOWNTO 0);
		oBlue		:	 OUT UNSIGNED(outbits-1 DOWNTO 0)
	);
END COMPONENT;

component osd
generic ( OSD_COLOR : integer );
port ( pclk, sck, ss, sdi, hs_in, vs_in : in std_logic;
       red_in, blue_in, green_in : in std_logic_vector(5 downto 0);
       red_out, blue_out, green_out : out std_logic_vector(5 downto 0);
       hs_out, vs_out : out std_logic
     );
end component osd;

-- the config string is read by the io controller and allows simple core specific
-- controls
constant CONF_STR : string := "TG68MiniSOC;;T1,Reset";

function to_slv(s: string) return std_logic_vector is
    constant ss: string(1 to s'length) := s;
    variable rval: std_logic_vector(1 to 8 * s'length);
    variable p: integer;
    variable c: integer;
  
  begin  
    for i in ss'range loop
      p := 8 * i;
      c := character'pos(ss(i));
      rval(p - 7 to p) := std_logic_vector(to_unsigned(c,8));
    end loop;
    return rval;

end function;
  

component user_io 
	generic ( STRLEN : integer := 0 );
   port (
			  SPI_CLK, SPI_SS_IO, SPI_MOSI :in std_logic;
           SPI_MISO : out std_logic;
           conf_str : in std_logic_vector(8*STRLEN-1 downto 0);
           joystick_0 : out std_logic_vector(5 downto 0);
           joystick_1 : out std_logic_vector(5 downto 0);
           joystick_analog_0 : out std_logic_vector(15 downto 0);
           joystick_analog_1 : out std_logic_vector(15 downto 0);
           status: out std_logic_vector(7 downto 0);
           switches : out std_logic_vector(1 downto 0);
           buttons : out std_logic_vector(1 downto 0);
			  sd_lba : in std_logic_vector(31 downto 0);
			  sd_rd : in std_logic;
			  sd_wr : in std_logic;
			  sd_ack : out std_logic;
			  sd_conf : in std_logic;
			  sd_sdhc : in std_logic;
			  sd_dout : out std_logic_vector(7 downto 0);
			  sd_dout_strobe : out std_logic;
			  sd_din : in std_logic_vector(7 downto 0);
			  sd_din_strobe : out std_logic;
           ps2_clk : in std_logic;
           ps2_kbd_clk : out std_logic;
           ps2_kbd_data : out std_logic;
           ps2_mouse_clk : out std_logic;
           ps2_mouse_data : out std_logic;
			  serial_data : in std_logic_vector(7 downto 0);
           serial_strobe : in std_logic
      );
  end component user_io;
  
component mist_console
	generic ( CLKFREQ : integer := 100 );
   port (  clk 	:	in std_logic;
           n_reset:	in std_logic;
           ser_in :	in std_logic;
           par_out_data :	out std_logic_vector(7 downto 0);
           par_out_strobe :	out std_logic
  );
  end component mist_console;

component sd_card
   port (  io_lba 	: out std_logic_vector(31 downto 0);
			  io_rd  	: out std_logic;
			  io_wr  	: out std_logic;
			  io_ack 	: in std_logic;
			  io_sdhc 	: out std_logic;
			  io_conf 	: out std_logic;
			  io_din 	: in std_logic_vector(7 downto 0);
			  io_din_strobe : in std_logic;
			  io_dout 	: out std_logic_vector(7 downto 0);
			  io_dout_strobe : in std_logic;

			  allow_sdhc : in std_logic;
			  
           sd_cs 		:	in std_logic;
           sd_sck 	:	in std_logic;
           sd_sdi 	:	in std_logic;
           sd_sdo 	:	out std_logic
  );
  end component sd_card;

begin


	mypll : entity work.Clock_27to100Split
		port map (
			inclk0 => CLOCK_27(0),
			c0 => clk_fast,
			c1 => SDRAM_CLK,
			c2 => clk,
			locked => pll_locked
		);
		

-- reset from IO controller
-- status bit 0 is always triggered by the i ocontroller on its own reset
-- status bit 1 is driven by the "T2,Reset" entry in the config string
-- button 1 is the core specfic button in the mists front
reset <= '0' when status(0)='1' or status(1)='1' or buttons(1)='1' else '1';

process(clk)
begin
--	ps2_keyboard_clk_mix <= ps2_keyboard_clk_in and (ps2_clk or ps2_keyboard_dat_out);
	ps2_keyboard_clk_mix <= ps2_keyboard_clk_in; -- and (ps2_clk or ps2_keyboard_dat_out);
	ps2_mouse_clk_mix <= ps2_mouse_clk_in; -- and (ps2_clk or ps2_mouse_dat_out);
	if rising_edge(clk) then
		ps2counter<=ps2counter+1;
		if ps2counter=1200 then
			ps2_clk<=not ps2_clk;
			ps2counter<=(others => '0');
		end if;
	end if;
end process;


mist_console_d: component mist_console
	generic map
	( CLKFREQ => 100)
	port map
	(
		clk => clk_fast,
		n_reset => reset,
		ser_in => txd,
		par_out_data => par_out_data,
		par_out_strobe => par_out_strobe
	);


sd_card_d: component sd_card
	port map
	(
 		-- connection to io controller
 		io_lba => sd_lba,
 		io_rd  => sd_rd,
		io_wr  => sd_wr,
 		io_ack => sd_ack,
		io_conf => sd_conf,
		io_sdhc => sd_sdhc,
 		io_din => sd_data_in,
 		io_din_strobe => sd_data_in_strobe,
		io_dout => sd_data_out,
		io_dout_strobe => sd_data_out_strobe,
 
		allow_sdhc  => '1',
		
 		-- connection to host
 		sd_cs  => sd_cs,
 		sd_sck => sd_sck,
		sd_sdi => sd_sdi,
		sd_sdo => sd_sdo		
	);

-- prevent joystick signals from being optimzed away
LED <= '0' when ((joy_ana_0 /= joy_ana_1) AND (joy_0 /= joy_1)) else '1';
	
user_io_d : user_io
    generic map (STRLEN => CONF_STR'length)
    port map (
      SPI_CLK => SPI_SCK,
      SPI_SS_IO => CONF_DATA0,
      SPI_MISO => SPI_DO,
      SPI_MOSI => SPI_DI,
      conf_str => to_slv(CONF_STR),
      status => status,
		
 		-- connection to io controller
		sd_lba  => sd_lba,
		sd_rd   => sd_rd,
		sd_wr   => sd_wr,
		sd_ack  => sd_ack,
		sd_sdhc => sd_sdhc,
		sd_conf => sd_conf,
 		sd_dout => sd_data_in,
 		sd_dout_strobe => sd_data_in_strobe,
		sd_din => sd_data_out,
		sd_din_strobe => sd_data_out_strobe,

      joystick_0 => joy_0,
      joystick_1 => joy_1,
      joystick_analog_0 => joy_ana_0,
      joystick_analog_1 => joy_ana_1,
--      switches => switches,
       BUTTONS => buttons,
		ps2_clk => ps2_clk,
      ps2_kbd_clk => ps2_keyboard_clk_in,
      ps2_kbd_data => ps2_keyboard_dat_in,
      ps2_mouse_clk => ps2_mouse_clk_in,
      ps2_mouse_data => ps2_mouse_dat_in,
 		serial_data => par_out_data,
 		serial_strobe => par_out_strobe
 );
 
 joyn_0 <= not joy_0;
 joyn_1 <= not joy_1;

 
mydither : component video_vga_dither
	generic map (
		outbits => 6
	)
	port map (
		clk => clk_fast,
		hsync => core_hs,
		vsync => core_vs,
		vid_ena => vga_window,
		iRed => vga_tred,
		iGreen => vga_tgreen,
		iBlue => vga_tblue,
		std_logic_vector(oRed) => core_r,
		std_logic_vector(oGreen) => core_g,
		std_logic_vector(oBlue) => core_b
	);

	
-- OSD pixel clock from system clock
process(clk_fast)
variable clk_div : unsigned(7 downto 0);
begin
	if rising_edge(clk_fast) then
		clk_div := clk_div + 1;
   end if;

   osdclk <= clk_div(1);
end process;

osd_inst : component osd
  generic map (OSD_COLOR => 6)
  port map (
      pclk => osdclk,
      sdi => SPI_DI,
      sck => SPI_SCK,
      ss => SPI_SS3,
      red_in => core_r,
      green_in => core_g,
      blue_in => core_b,
      hs_in => core_hs,
      vs_in => core_vs,
      unsigned(red_out) => VGA_R,
      unsigned(green_out) => VGA_G,
      unsigned(blue_out) => VGA_B,
      hs_out => VGA_HS,
      vs_out => VGA_VS
    );
 

-- Do we have audio?  If so, instantiate a two DAC channels.
leftsd: component hybrid_pwm_sd
	port map
	(
		clk => clk_fast,
		n_reset => reset,
		din(15) => not audiol(15),
		din(14 downto 0) => std_logic_vector(audiol(14 downto 0)),
		dout => AUDIO_L
	);
	
rightsd: component hybrid_pwm_sd
	port map
	(
		clk => clk_fast,
		n_reset => reset,
		din(15) => not audior(15),
		din(14 downto 0) => std_logic_vector(audior(14 downto 0)),
		dout => AUDIO_R
	);

	
mytg68test : entity work.VirtualToplevel
		generic map(
			sdram_rows => 13,
			sdram_cols => 9,
			sysclk_frequency => 250,
			fastclk_frequency => 1000
		)
		port map(
			clk => clk,
			clk_fast => clk_fast,
			reset_in => reset,
			
			-- SDRAM
			sdr_addr => SDRAM_A,
			sdr_data => SDRAM_DQ,
			sdr_ba => SDRAM_BA,
			sdr_cke => SDRAM_CKE,
			sdr_dqm(1) => SDRAM_DQMH,
			sdr_dqm(0) => SDRAM_DQML,
			sdr_cs => SDRAM_nCS,
			sdr_we => SDRAM_nWE,
			sdr_cas => SDRAM_nCAS,
			sdr_ras => SDRAM_nRAS,
			
			-- VGA
			unsigned(vga_red) => vga_tred,
			unsigned(vga_green) => vga_tgreen,
			unsigned(vga_blue) => vga_tblue,
			
			vga_hsync => core_hs,
			vga_vsync => core_vs,
			
			vga_window => vga_window,

			-- UART
			rxd => UART_RX,
			txd => txd,
				
			-- PS/2
			ps2k_clk_in => ps2_keyboard_clk_in,
			ps2k_dat_in => ps2_keyboard_dat_in,
			ps2k_clk_out => ps2_keyboard_clk_out,
			ps2k_dat_out => ps2_keyboard_dat_out,
			ps2m_clk_in => ps2_mouse_clk_in,
			ps2m_dat_in => ps2_mouse_dat_in,
			ps2m_clk_out => ps2_mouse_clk_out,
			ps2m_dat_out => ps2_mouse_dat_out,
			
			-- SD Card interface
			spi_cs => sd_cs,
			spi_miso => sd_sdo,
			spi_mosi => sd_sdi,
			spi_clk => sd_sck,
			
			-- Audio - FIXME abstract this out, too.
			std_logic_vector(audio_l) => audiol,
			std_logic_vector(audio_r) => audior
			
			-- LEDs
		);

	
end architecture;
