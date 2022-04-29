
--
-- Copyright (c) 2008-2021 Sytse van Slooten
--
-- Permission is hereby granted to any person obtaining a copy of these VHDL source files and
-- other language source files and associated documentation files ("the materials") to use
-- these materials solely for personal, non-commercial purposes.
-- You are also granted permission to make changes to the materials, on the condition that this
-- copyright notice is retained unchanged.
--
-- The materials are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--

-- $Revision$

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity de10ladc is
   port(
      ad_start : in std_logic;
      ad_done : out std_logic := '0';
      ad_channel : in std_logic_vector(5 downto 0);
      ad_nxc : out std_logic := '0';
      ad_sample : out std_logic_vector(11 downto 0) := "000000000000";

      clk : in std_logic;
      clk50mhz : in std_logic;
      reset : in std_logic
   );
end de10ladc;

architecture implementation of de10ladc is

component m10adc is
   port (
         clock_clk              : in  std_logic                     := 'X';             -- clk
         reset_sink_reset_n     : in  std_logic                     := 'X';             -- reset_n
         adc_pll_clock_clk      : in  std_logic                     := 'X';             -- clk
         adc_pll_locked_export  : in  std_logic                     := 'X';             -- export
         command_valid          : in  std_logic                     := 'X';             -- valid
         command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
         command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
         command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
         command_ready          : out std_logic;                                        -- ready
         response_valid         : out std_logic;                                        -- valid
         response_channel       : out std_logic_vector(4 downto 0);                     -- channel
         response_data          : out std_logic_vector(11 downto 0);                    -- data
         response_startofpacket : out std_logic;                                        -- startofpacket
         response_endofpacket   : out std_logic                                         -- endofpacket
   );
end component;

component pll10mhz is
   port (
      inclk0 : in std_logic := '0';
      c0 : out std_logic;
      locked : out std_logic
   );
end component;


signal clk10mhz : std_logic;
signal clk10mhzlocked : std_logic;

signal adc_start : std_logic;
signal adc_channel : std_logic_vector(4 downto 0) := "00000";
signal adc_done : std_logic := '0';
signal adc_respchannel : std_logic_vector(4 downto 0);
signal adc_responsevalid : std_logic;
signal adc_sample : std_logic_vector(11 downto 0);
signal adc_lastsample : std_logic_vector(11 downto 0);
signal adc_nxc : std_logic;

type ad_state_type is (
   idle,
   start,
   run,
   done
);
signal ad_state : ad_state_type := idle;

begin
   adc_nxc <= '1' when ad_channel(5) = '1' else '0';
   ad_nxc <= adc_nxc;

   adcpll: pll10mhz port map(
      inclk0 => clk50mhz,
      c0 => clk10mhz,
      locked => clk10mhzlocked
   );

   adc0: m10adc port map(
      command_valid => adc_start,
      command_channel => adc_channel,
      command_startofpacket => '1',
      command_endofpacket => '1',
      command_ready => adc_done,
      response_channel => adc_respchannel,
      response_data => adc_sample,
      response_valid => adc_responsevalid,

      clock_clk => clk50mhz,
      reset_sink_reset_n => not reset,
      adc_pll_clock_clk => clk10mhz,
      adc_pll_locked_export => clk10mhzlocked
   );

   process(clk, reset, ad_start, ad_channel)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            ad_state <= idle;
         else
            case ad_state is
               when idle =>
                  if ad_start = '1' then
                     ad_state <= start;
                  end if;
                  ad_done <= '0';
               when start =>
                  if adc_nxc = '1' then
                     ad_state <= done;
                  else
                     adc_start <= '1';
--
-- map the channel that the mncad wants to a channel that the max10 can do.
-- if we give the max10 a channel it doesn't know about, it will not set the
-- responsevalid signals, so the controller will hang.
-- also, channel 17 - 10001 - is the built-in NTC that will report the max10 core
-- temp - see the manual for a conversion table. It would be tempting to set that
-- on any of the mappings that don't directly reference a 'real' channel, but then,
-- converting the build-in NTC drops the conversion frequency. But I still want to
-- enable reading it, not block the core for missing channels, and not slow down
-- because someone unwittingly does a sweep of the first 8 channels.
-- Hence this weird logic.
--
                     if ad_channel = "000000" then
                        adc_channel <= "00001";
                     elsif ad_channel = "010001" then
                        adc_channel <= "10001";
                     elsif ad_channel > "000110" then
                        adc_channel <= "00001";
                     else
                        adc_channel <= ad_channel(4 downto 0);
                     end if;
                     ad_state <= run;
                  end if;
               when run =>
                  if adc_done = '1' then
                     if adc_responsevalid = '1' and adc_respchannel = adc_channel then
                        ad_state <= done;
                        ad_sample <= adc_sample;
                        adc_lastsample <= adc_sample;
                     else
                        ad_state <= start;
                     end if;
                  end if;
               when done =>
                  adc_start <= '0';
                  ad_done <= '1';
                  if ad_start = '0' then
                     ad_state <= idle;
                  end if;
               when others =>
                  null;
            end case;

         end if;
      end if;
   end process;

end implementation;

