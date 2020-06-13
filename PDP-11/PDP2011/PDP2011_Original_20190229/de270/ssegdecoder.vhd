
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

-- $Revision: 1.8 $


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ssegdecoder is
	port(
		i : in std_logic_vector(3 downto 0);
		idle : in std_logic;
		u : out std_logic_vector(6 downto 0)
	);
end;

architecture behavioral of ssegdecoder is

begin

   with idle & i select
      u <=
         "1000000" when "00000",
         "1111001" when "00001",
         "0100100" when "00010",
         "0110000" when "00011",
         "0011001" when "00100",
         "0010010" when "00101",
         "0000010" when "00110",
         "1111000" when "00111",
         "0000000" when "01000",
         "0010000" when "01001",
         "0001000" when "01010",
         "0000011" when "01011",
         "1000110" when "01100",
         "0100001" when "01101",
         "0000110" when "01110",
         "0001110" when "01111",
         "1111111" when others;

end behavioral;
