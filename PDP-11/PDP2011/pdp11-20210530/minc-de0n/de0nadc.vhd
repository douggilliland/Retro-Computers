
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

entity de0nadc is
   port(
      ad_start : in std_logic;
      ad_done : out std_logic := '0';
      ad_channel : in std_logic_vector(5 downto 0);
      ad_nxc : out std_logic := '0';
      ad_sample : out std_logic_vector(11 downto 0) := "000000000000";

      ad_ch8 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch9 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch10 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch11 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch12 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch13 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch14 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch15 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch16 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch17 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch18 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch19 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch20 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch21 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch22 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch23 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch24 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch25 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch26 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch27 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch28 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch29 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch30 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch31 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch32 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch33 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch34 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch35 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch36 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch37 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch38 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch39 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch40 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch41 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch42 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch43 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch44 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch45 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch46 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch47 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch48 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch49 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch50 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch51 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch52 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch53 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch54 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch55 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch56 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch57 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch58 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch59 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch60 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch61 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch62 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch63 : in std_logic_vector(11 downto 0) := "000000000000";

      adc_cs_n : out std_logic;
      adc_saddr : out std_logic;
      adc_sdat : in std_logic;
      adc_sclk : out std_logic;

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end de0nadc;


architecture implementation of de0nadc is

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
   ad_nxc <= '0';
   ad_done <= adc_done;
   ad_sample <= adc_sample when ad_channel < "001000" else
      ad_ch8 when ad_channel = "001000" else
      ad_ch9 when ad_channel = "001001" else
      ad_ch10 when ad_channel = "001010" else
      ad_ch11 when ad_channel = "001011" else
      ad_ch12 when ad_channel = "001100" else
      ad_ch13 when ad_channel = "001101" else
      ad_ch14 when ad_channel = "001110" else
      ad_ch15 when ad_channel = "001111" else
      ad_ch16 when ad_channel = "010000" else
      ad_ch17 when ad_channel = "010001" else
      ad_ch18 when ad_channel = "010010" else
      ad_ch19 when ad_channel = "010011" else
      ad_ch20 when ad_channel = "010100" else
      ad_ch21 when ad_channel = "010101" else
      ad_ch22 when ad_channel = "010110" else
      ad_ch23 when ad_channel = "010111" else
      ad_ch24 when ad_channel = "011000" else
      ad_ch25 when ad_channel = "011001" else
      ad_ch26 when ad_channel = "011010" else
      ad_ch27 when ad_channel = "011011" else
      ad_ch28 when ad_channel = "011100" else
      ad_ch29 when ad_channel = "011101" else
      ad_ch30 when ad_channel = "011110" else
      ad_ch31 when ad_channel = "011111" else
      ad_ch32 when ad_channel = "100000" else
      ad_ch33 when ad_channel = "100001" else
      ad_ch34 when ad_channel = "100010" else
      ad_ch35 when ad_channel = "100011" else
      ad_ch36 when ad_channel = "100100" else
      ad_ch37 when ad_channel = "100101" else
      ad_ch38 when ad_channel = "100110" else
      ad_ch39 when ad_channel = "100111" else
      ad_ch40 when ad_channel = "101000" else
      ad_ch41 when ad_channel = "101001" else
      ad_ch42 when ad_channel = "101010" else
      ad_ch43 when ad_channel = "101011" else
      ad_ch44 when ad_channel = "101100" else
      ad_ch45 when ad_channel = "101101" else
      ad_ch46 when ad_channel = "101110" else
      ad_ch47 when ad_channel = "101111" else
      ad_ch48 when ad_channel = "110000" else
      ad_ch49 when ad_channel = "110001" else
      ad_ch50 when ad_channel = "110010" else
      ad_ch51 when ad_channel = "110011" else
      ad_ch52 when ad_channel = "110100" else
      ad_ch53 when ad_channel = "110101" else
      ad_ch54 when ad_channel = "110110" else
      ad_ch55 when ad_channel = "110111" else
      ad_ch56 when ad_channel = "111000" else
      ad_ch57 when ad_channel = "111001" else
      ad_ch58 when ad_channel = "111010" else
      ad_ch59 when ad_channel = "111011" else
      ad_ch60 when ad_channel = "111100" else
      ad_ch61 when ad_channel = "111101" else
      ad_ch62 when ad_channel = "111110" else
      ad_ch63 when ad_channel = "111111" else
      "000000000000";

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
            adc_sample <= (others => '0');
            ad_state <= idle;
         else

            case ad_state is
               when idle =>
                  if ad_start = '1' then
                     if ad_channel(5) = '0' and ad_channel(4) = '0' and ad_channel(3) = '0' then   -- only start the ad chip for local channels
                        ad_state <= run;
                        bitctr <= 1;
                        adc_cs_n <= '0';
                        adc_saddr <= '0';
                     else
                        ad_state <= done;
                     end if;
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
                  bitctr <= 0;
                  ad_state <= done;

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

