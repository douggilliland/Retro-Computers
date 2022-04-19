
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

entity paneldb is
   port(
      sw : in std_logic_vector(11 downto 0);
      dsw : out std_logic_vector(11 downto 0);

      clkin : in std_logic;
      reset : in std_logic
   );
end paneldb;

architecture implementation of paneldb is

constant counter_size : integer := 10;

subtype counter_t is std_logic_vector(counter_size downto 0);
type counter_a is array (11 downto 0) of counter_t;
signal counter : counter_a;

signal currentsample : std_logic_vector(11 downto 0);
signal prevsample : std_logic_vector(11 downto 0);

begin

   process(clkin, reset)
   begin
      if clkin = '1' and clkin'event then
         if reset = '1' then
            r1: for i in 0 to 11 loop
               counter(i) <= (others => '0');
               currentsample(i) <= '0';
               prevsample(i) <= '0';
               dsw(i) <= '0';
            end loop r1;
         else
            p1: for i in 0 to 11 loop
               prevsample(i) <= currentsample(i);
               currentsample(i) <= sw(i);
               if prevsample(i) /= currentsample(i) then
                  counter(i) <= (others => '0');
               else
                  if counter(i)(counter_size) /= '1' then
                     counter(i) <= counter(i) + 1;
                  else
                     dsw(i) <= prevsample(i);
                  end if;
               end if;
            end loop p1;
         end if;
      end if;
   end process;

end implementation;
