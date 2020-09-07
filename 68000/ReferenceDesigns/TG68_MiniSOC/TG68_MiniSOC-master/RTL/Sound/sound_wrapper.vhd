library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;


entity sound_wrapper is
	generic (
		clk_frequency : integer := 1000 -- System clock frequency
	);
	port (
		clk : in std_logic;
		reset : in std_logic;

		reg_addr_in : in std_logic_vector(7 downto 0); -- from host CPU
		reg_data_in: in std_logic_vector(15 downto 0);
		reg_data_out: out std_logic_vector(15 downto 0);
		reg_rw : in std_logic;
		reg_req : in std_logic;

		dma_data : in std_logic_vector(15 downto 0);
		channel0_fromhost : out DMAChannel_FromHost;
		channel0_tohost : in DMAChannel_ToHost;
		channel1_fromhost : out DMAChannel_FromHost;
		channel1_tohost : in DMAChannel_ToHost;
		channel2_fromhost : out DMAChannel_FromHost;
		channel2_tohost : in DMAChannel_ToHost;
		channel3_fromhost : out DMAChannel_FromHost;
		channel3_tohost : in DMAChannel_ToHost;
		
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0);
		audio_ints : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of sound_wrapper is

	constant clk_hz : integer := clk_frequency*100000;
	constant clkdivide : integer := clk_hz/3546895;
	signal audiotick : std_logic;
	
	-- Select signals for the four channels
	signal sel0 : std_logic;
	signal sel1 : std_logic;
	signal sel2 : std_logic;
	signal sel3 : std_logic;

	-- The output of each channel.  Aud0 and 3 will be summed to make the left channel
	-- while aud1 and 2 will be summed to make the right channel.
	signal aud0 : signed(13 downto 0);
	signal aud1 : signed(13 downto 0);
	signal aud2 : signed(13 downto 0);
	signal aud3 : signed(13 downto 0);

begin

-- Create ~3.5Mhz tick signal
-- FIXME - will need to make this more accurate in time.

myclkdiv: entity work.risingedge_divider
	generic map (
		divisor => clkdivide,
		bits => 6
	)
port map (
		clk => clk,
		reset_n => reset, -- Active low
		tick => audiotick
	);

	
	sel0<='1' when reg_addr_in(5 downto 4)="00" else '0';
	sel1<='1' when reg_addr_in(5 downto 4)="01" else '0';
	sel2<='1' when reg_addr_in(5 downto 4)="10" else '0';
	sel3<='1' when reg_addr_in(5 downto 4)="11" else '0';
	audio_l(0)<='0';
	audio_r(0)<='0';
	audio_l(15 downto 1)<=(aud0(13)&aud0)+(aud3(13)&aud3);
	audio_r(15 downto 1)<=(aud1(13)&aud1)+(aud2(13)&aud2);

channel0 : entity work.sound_controller
	port map (
		clk => clk,
		reset => reset,
		audiotick => audiotick,

		reg_addr_in => "0000"&reg_addr_in(3 downto 0),
		reg_data_in => reg_data_in,
		reg_data_out => open,
		reg_rw => '0',
		reg_req => reg_req and sel0,

		dma_data => dma_data,
		channel_fromhost => channel0_fromhost,
		channel_tohost => channel0_tohost,
		
		audio_out => aud0,
		audio_int => audio_ints(0)
	);

channel1 : entity work.sound_controller
	port map (
		clk => clk,
		reset => reset,
		audiotick => audiotick,

		reg_addr_in => "0000"&reg_addr_in(3 downto 0),
		reg_data_in => reg_data_in,
		reg_data_out => open,
		reg_rw => '0',
		reg_req => reg_req and sel1,

		dma_data => dma_data,
		channel_fromhost => channel1_fromhost,
		channel_tohost => channel1_tohost,
		
		audio_out => aud1,
		audio_int => audio_ints(1)
	);

channel2 : entity work.sound_controller
	port map (
		clk => clk,
		reset => reset,
		audiotick => audiotick,

		reg_addr_in => "0000"&reg_addr_in(3 downto 0),
		reg_data_in => reg_data_in,
		reg_data_out => open,
		reg_rw => '0',
		reg_req => reg_req and sel2,

		dma_data => dma_data,
		channel_fromhost => channel2_fromhost,
		channel_tohost => channel2_tohost,
		
		audio_out => aud2,
		audio_int => audio_ints(2)
	);

channel3 : entity work.sound_controller
	port map (
		clk => clk,
		reset => reset,
		audiotick => audiotick,

		reg_addr_in => "0000"&reg_addr_in(3 downto 0),
		reg_data_in => reg_data_in,
		reg_data_out => open,
		reg_rw => '0',
		reg_req => reg_req and sel3,

		dma_data => dma_data,
		channel_fromhost => channel3_fromhost,
		channel_tohost => channel3_tohost,
		
		audio_out => aud3,
		audio_int => audio_ints(3)
	);
	
end architecture;
