
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

entity pmodda4 is
   port(
      da_daca : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacb : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacc : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacd : in std_logic_vector(11 downto 0) := "000000000000";
      da_dace : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacf : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacg : in std_logic_vector(11 downto 0) := "000000000000";
      da_dach : in std_logic_vector(11 downto 0) := "000000000000";

      da_cs : out std_logic;
      da_mosi : out std_logic;
      da_sclk : out std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end pmodda4;

architecture implementation of pmodda4 is

signal sclk : std_logic := '0';
signal clkcount : integer range 0 to 63 := 0;
signal chcount : std_logic_vector(2 downto 0) := "000";
signal buf : std_logic_vector(11 downto 0);
signal buf32 : std_logic_vector(31 downto 0);
signal refinternal : integer range 0 to 1 := 0;

begin
   da_sclk <= sclk;
   buf <= da_daca when chcount = "000"
      else da_dacb when chcount = "001"
      else da_dacc when chcount = "010"
      else da_dacd when chcount = "011"
      else da_dace when chcount = "100"
      else da_dacf when chcount = "101"
      else da_dacg when chcount = "110"
      else da_dach when chcount = "111"
      else "111111111111";

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         sclk <= not sclk;
      end if;
   end process;

   process(sclk, reset)
   begin
      if sclk = '0' and sclk'event then
         if reset = '1' then
            clkcount <= 35;
            chcount <= "000";
            da_cs <= '1';
            da_mosi <= '1';
            refinternal <= 0;
         else
            clkcount <= clkcount + 1;
            if clkcount = 63 then
               clkcount <= 0;
               chcount <= chcount + "001";
               if refinternal = 0 then
                  buf32 <= "0000" & "1000" & "0000" & "000000000000" & "0000" & "0001";
                  refinternal <= 1;
               else
                  if chcount /= "111" then
                     buf32 <= "0000" & "0000" & '0' & chcount & buf & "0000" & "0000";
                  else
                     buf32 <= "0000" & "0010" & '0' & chcount & buf & "0000" & "0000";
                  end if;
               end if;
            end if;

            if clkcount < 32 then
               da_cs <= '0';
               da_mosi <= buf32(31);
               buf32 <= buf32(30 downto 0) & '0';
            else
               da_mosi <= '1';
               da_cs <= '1';
            end if;

         end if;

      end if;
   end process;


end implementation;

