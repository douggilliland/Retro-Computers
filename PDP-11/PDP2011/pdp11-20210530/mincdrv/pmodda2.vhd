
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

entity pmodda2 is
   port(
      da_daca : in std_logic_vector(11 downto 0);
      da_dacb : in std_logic_vector(11 downto 0);

      da_sync : out std_logic;
      da_dina : out std_logic;
      da_dinb : out std_logic;
      da_sclk : out std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end pmodda2;

architecture implementation of pmodda2 is

signal clkcount : integer range 0 to 63 := 0;
signal bufa : std_logic_vector(11 downto 0);
signal bufb : std_logic_vector(11 downto 0);

begin
   da_sclk <= clk;

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            clkcount <= 0;
            da_sync <= '0';
            da_dina <= '0';
            da_dinb <= '0';
         else
            clkcount <= clkcount + 1;

            if clkcount = 10 then
               da_sync <= '1';
            end if;
            if clkcount = 11 then
               da_sync <= '0';
               bufa <= da_daca;
               bufb <= da_dacb;
            end if;
            if clkcount > 14 then
               da_dina <= bufa(11);
               da_dinb <= bufb(11);
               bufa <= bufa(10 downto 0) & '0';
               bufb <= bufb(10 downto 0) & '0';
            end if;
            if clkcount = 63 then
               clkcount <= 0;
            end if;
         end if;

      end if;
   end process;


end implementation;

