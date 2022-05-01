
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

entity panelos is
   port(
      sw : in std_logic;
      psw : out std_logic;

      clkin : in std_logic;
      reset : in std_logic
   );
end panelos;

architecture implementation of panelos is

signal old : std_logic;

begin

   process(clkin, reset)
   begin
      if clkin = '1' and clkin'event then
         if reset = '1' then
            psw <= '0';
            old <= '0';
         else
            old <= sw;
            psw <= '0';
            if sw = '1' then
               if old = '0' then
                  psw <= '1';
               end if;
            end if;
         end if;
      end if;
   end process;

end implementation;
