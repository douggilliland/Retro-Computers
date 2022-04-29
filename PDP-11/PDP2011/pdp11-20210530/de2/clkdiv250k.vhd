
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

entity clkdiv250k is
	port(
		clkin : in std_logic;
      sw : in std_logic_vector;
		clkout : out std_logic
	);
end clkdiv250k;

architecture Behavioral of clkdiv250k is

signal counter : std_logic_vector(24 downto 0);
signal lcl : std_logic := '0';

begin
	process(clkin)
	begin
      if clkin='1' and clkin'event then
         if counter < 25000000 and sw(0) = '0' then
            counter <= counter + 1;
         elsif counter < 1000000 and sw(1) = '0' then
            counter <= counter + 1;
         elsif counter < 500000 and sw(2) = '0' then
            counter <= counter + 1;
         elsif counter < 100000 and sw(3) = '0' then
            counter <= counter + 1;
         elsif counter < 20000 and sw(4) = '0' then
            counter <= counter + 1;
         elsif counter < 5000 and sw(5) = '0' then
            counter <= counter + 1;
         elsif counter < 2000 and sw(6) = '0' then
            counter <= counter + 1;
         elsif counter < 1000 and sw(7) = '0' then
            counter <= counter + 1;
         elsif counter < 100 and sw(8) = '0' then
            counter <= counter + 1;
         elsif counter < 10 and sw(9) = '0' then
            counter <= counter + 1;
         else
            counter <= "0000000000000000000000000";
            lcl <= not lcl;
         end if;
      end if;
	end process;

	clkout <= lcl;

end Behavioral;

