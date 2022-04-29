
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

entity clkdiv50k is
	port(
		clkin : in std_logic;
		clkout : out std_logic
	);
end clkdiv50k;

architecture Behavioral of clkdiv50k is

signal counter : std_logic_vector(19 downto 0);
signal lcl : std_logic := '0';

begin
	process(clkin)
	begin
      if clkin='1' and clkin'event then
         if counter < 1000 then
            counter <= counter + 1;
         else
            counter <= "00000000000000000000";
            lcl <= not lcl;
            clkout <= lcl;
         end if;
      end if;
	end process;
end Behavioral;

