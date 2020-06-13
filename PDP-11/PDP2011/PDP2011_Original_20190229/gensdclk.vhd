
--
-- Copyright (c) 2008-2019 Sytse van Slooten
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

-- $Revision: 1.9 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gensdclock is
   port(
      clk50mhz : in std_logic;
      highspeed : in std_logic;
      sdclock : out std_logic
   );
end gensdclock;

architecture implementation of gensdclock is

signal counter : std_logic_vector(6 downto 0) := (others => '0');
signal localclk : std_logic := '0';


begin
   sdclock <= localclk;

   process(clk50mhz)
   begin
      if clk50mhz='1' and clk50mhz'event then
         if highspeed = '1' then
            localclk <= not localclk;
         else
            if counter < 124 then
               counter <= counter + 1;
            else
               counter <= (others => '0');
               localclk <= not localclk;
            end if;
         end if;
      end if;
   end process;
end implementation;

