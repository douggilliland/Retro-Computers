
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

entity de0adc is
   port(
      ad_start : in std_logic;
      ad_done : out std_logic := '0';
      ad_channel : in std_logic_vector(5 downto 0);
      ad_nxc : out std_logic := '0';
      ad_sample : out std_logic_vector(11 downto 0) := "000000000000";

      adc_cs_n : out std_logic;
      adc_saddr : out std_logic;
      adc_sdat : in std_logic;
      adc_sclk : out std_logic;

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end de0adc;


architecture implementation of de0adc is

signal clkcount : integer range 0 to 50 := 0;
signal clk : std_logic := '0';
signal adc_done : std_logic := '0';
signal adc_channel : std_logic_vector(2 downto 0) := "000";
signal lastchannel : std_logic_vector(2 downto 0);
signal bitctr : integer range 0 to 63;
signal adc_sample : std_logic_vector(11 downto 0);
type ad_state_type is (
   idle,
   run,
   syncwait,
   done
);
signal ad_state : ad_state_type := idle;

begin
   adc_sclk <= clk when bitctr /= 0 else '0';
   adc_channel <= ad_channel(2 downto 0);
   ad_nxc <= '1' when ad_channel(3) = '1' or ad_channel(4) = '1' or ad_channel(5) = '1' else '0';
   ad_done <= adc_done;

   process(clk50mhz, reset)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         clkcount <= clkcount + 1;
         if clkcount >= 24 then
            clkcount <= 0;
            clk <= not clk;
         end if;
      end if;
   end process;

   process(clk, reset, ad_start, adc_channel)
   begin
      if clk = '0' and clk'event then
         if reset = '1' then
            adc_cs_n <= '1';
            bitctr <= 0;
            adc_done <= '0';
            ad_sample <= (others => '0');
            ad_state <= idle;
         else

            case ad_state is
               when idle =>
                  if ad_start = '1' then
                     ad_state <= run;
                     bitctr <= 1;
                     adc_cs_n <= '0';
                     adc_saddr <= '0';
                  end if;

               when run =>
                  adc_sample <= adc_sample(10 downto 0) & adc_sdat;
                  bitctr <= bitctr + 1;
                  case bitctr is
                     when 16 =>
                        if lastchannel = adc_channel then
                           adc_cs_n <= '1';
                           bitctr <= 32;
                           ad_state <= syncwait;
                        end if;
                     when 32 =>
                        lastchannel <= adc_channel;
                        adc_cs_n <= '1';
                        ad_state <= syncwait;
                     when 2 | 18 =>
                        adc_saddr <= adc_channel(2);
                     when 3 | 19 =>
                        adc_saddr <= adc_channel(1);
                     when 4 | 20 =>
                        adc_saddr <= adc_channel(0);
                     when others =>
                        adc_saddr <= '0';
                  end case;

               when syncwait =>
                  bitctr <= bitctr + 1;
                  ad_sample <= adc_sample;
--                  if bitctr >= 40 then
                  bitctr <= 0;
                  ad_state <= done;
--                  end if;

               when done =>
                  adc_done <= '1';
                  if ad_start = '0' then
                     adc_done <= '0';
                     ad_state <= idle;
                  end if;

               when others =>
                  ad_state <= idle;

            end case;

         end if;
      end if;
   end process;

end implementation;

