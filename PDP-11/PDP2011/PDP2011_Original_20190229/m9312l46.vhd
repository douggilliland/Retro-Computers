
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

-- m9312l16.t1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity m9312l is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;

      clk : in std_logic
   );
end m9312l;

architecture implementation of m9312l is

signal base_addr_match : std_logic;

subtype u is std_logic_vector(7 downto 0);
type mem_type is array(0 to 255) of u;

-- code base at 165000

signal meme : mem_type := mem_type'(
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"ff"),u'(x"06"),u'(x"06"),u'(x"40"),u'(x"41"),u'(x"03"),u'(x"83"),u'(x"43"),u'(x"83"),u'(x"c3"),u'(x"03"),u'(x"c3"),u'(x"03"),
u'(x"c3"),u'(x"83"),u'(x"43"),u'(x"43"),u'(x"c3"),u'(x"ff"),u'(x"c2"),u'(x"00"),u'(x"83"),u'(x"83"),u'(x"ff"),u'(x"83"),u'(x"83"),u'(x"83"),u'(x"83"),u'(x"0a"),
u'(x"83"),u'(x"0a"),u'(x"ff"),u'(x"c3"),u'(x"53"),u'(x"c3"),u'(x"52"),u'(x"5b"),u'(x"4b"),u'(x"50"),u'(x"df"),u'(x"04"),u'(x"ff"),u'(x"92"),u'(x"d2"),u'(x"ff"),
u'(x"ca"),u'(x"ff"),u'(x"c1"),u'(x"6c"),u'(x"c1"),u'(x"56"),u'(x"00"),u'(x"54"),u'(x"80"),u'(x"c1"),u'(x"51"),u'(x"40"),u'(x"4f"),u'(x"85"),u'(x"c1"),u'(x"60"),
u'(x"c2"),u'(x"40"),u'(x"c3"),u'(x"6c"),u'(x"c6"),u'(x"2e"),u'(x"c2"),u'(x"2c"),u'(x"97"),u'(x"20"),u'(x"21"),u'(x"02"),u'(x"01"),u'(x"d5"),u'(x"84"),u'(x"97"),
u'(x"20"),u'(x"1f"),u'(x"97"),u'(x"20"),u'(x"13"),u'(x"97"),u'(x"0d"),u'(x"02"),u'(x"05"),u'(x"4d"),u'(x"c4"),u'(x"00"),u'(x"02"),u'(x"05"),u'(x"04"),u'(x"17"),
u'(x"00"),u'(x"dc"),u'(x"f9"),u'(x"c1"),u'(x"16"),u'(x"a1"),u'(x"74"),u'(x"08"),u'(x"c1"),u'(x"11"),u'(x"0d"),u'(x"d2"),u'(x"c1"),u'(x"0d"),u'(x"05"),u'(x"04"),
u'(x"cd"),u'(x"46"),u'(x"45"),u'(x"c4"),u'(x"df"),u'(x"70"),u'(x"fd"),u'(x"02"),u'(x"c2"),u'(x"72"),u'(x"2f"),u'(x"00"),u'(x"02"),u'(x"c3"),u'(x"f5"),u'(x"97"),
u'(x"0d"),u'(x"1b"),u'(x"c2"),u'(x"38"),u'(x"c2"),u'(x"08"),u'(x"e8"),u'(x"c0"),u'(x"c0"),u'(x"c0"),u'(x"80"),u'(x"f0"),u'(x"c2"),u'(x"18"),u'(x"b1"),u'(x"40"),
u'(x"42"),u'(x"c3"),u'(x"1d"),u'(x"c2"),u'(x"86"),u'(x"c0"),u'(x"03"),u'(x"42"),u'(x"fc"),u'(x"f5"),u'(x"c2"),u'(x"c3"),u'(x"13"),u'(x"51"),u'(x"71"),u'(x"fe"),
u'(x"c2"),u'(x"0a"),u'(x"c3"),u'(x"0c"),u'(x"c2"),u'(x"f7"),u'(x"02"),u'(x"c2"),u'(x"0d"),u'(x"f8"),u'(x"a0"),u'(x"c2"),u'(x"40"),u'(x"02"),u'(x"c2"),u'(x"20"),
u'(x"df"),u'(x"74"),u'(x"fd"),u'(x"9f"),u'(x"76"),u'(x"c2"),u'(x"80"),u'(x"d3"),u'(x"73"),u'(x"fe"),u'(x"c5"),u'(x"06"),u'(x"c2"),u'(x"40"),u'(x"43"),u'(x"0a"),
u'(x"4a"),u'(x"82"),u'(x"4a"),u'(x"c2"),u'(x"4a"),u'(x"0d"),u'(x"82"),u'(x"52"),u'(x"62"),u'(x"52"),u'(x"08"),u'(x"42"),u'(x"45"),u'(x"fa"),u'(x"5a"),u'(x"7a"),
u'(x"00"),u'(x"ea"),u'(x"07"),u'(x"00"),u'(x"d3"),u'(x"09"),u'(x"85"),u'(x"07"),u'(x"83"),u'(x"00"),u'(x"86"),u'(x"c2"),u'(x"a8"),u'(x"d6"),u'(x"ca"),u'(x"00"),
u'(x"f2"),u'(x"04"),u'(x"c5"),u'(x"00"),u'(x"1f"),u'(x"06"),u'(x"df"),u'(x"d2"),u'(x"04"),u'(x"c6"),u'(x"42"),u'(x"e5"),u'(x"03"),u'(x"cb"),u'(x"d3"),u'(x"c5"),
u'(x"fc"),u'(x"03"),u'(x"0b"),u'(x"cb"),u'(x"d3"),u'(x"04"),u'(x"c5"),u'(x"fa"),u'(x"74"),u'(x"02"),u'(x"c4"),u'(x"c0"),u'(x"06"),u'(x"00"),u'(x"30"),u'(x"72") 
);
signal memo : mem_type := mem_type'(
u'(x"ea"),u'(x"ea"),u'(x"80"),u'(x"ff"),u'(x"ea"),u'(x"ea"),u'(x"01"),u'(x"01"),u'(x"0a"),u'(x"0a"),u'(x"0a"),u'(x"0c"),u'(x"0c"),u'(x"0c"),u'(x"0b"),u'(x"0b"),
u'(x"0a"),u'(x"0b"),u'(x"0c"),u'(x"0b"),u'(x"00"),u'(x"02"),u'(x"15"),u'(x"ea"),u'(x"12"),u'(x"24"),u'(x"02"),u'(x"66"),u'(x"ea"),u'(x"48"),u'(x"5c"),u'(x"00"),
u'(x"3e"),u'(x"00"),u'(x"03"),u'(x"11"),u'(x"00"),u'(x"15"),u'(x"ea"),u'(x"00"),u'(x"00"),u'(x"ea"),u'(x"8b"),u'(x"ea"),u'(x"02"),u'(x"24"),u'(x"8b"),u'(x"02"),
u'(x"8b"),u'(x"80"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"11"),u'(x"01"),
u'(x"95"),u'(x"00"),u'(x"11"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"00"),u'(x"01"),u'(x"20"),u'(x"4c"),u'(x"03"),u'(x"21"),u'(x"02"),u'(x"0b"),u'(x"10"),u'(x"20"),
u'(x"45"),u'(x"03"),u'(x"20"),u'(x"44"),u'(x"03"),u'(x"20"),u'(x"53"),u'(x"02"),u'(x"00"),u'(x"00"),u'(x"15"),u'(x"f6"),u'(x"25"),u'(x"03"),u'(x"63"),u'(x"21"),
u'(x"f8"),u'(x"03"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"11"),u'(x"01"),u'(x"10"),u'(x"01"),u'(x"11"),u'(x"01"),u'(x"10"),u'(x"0a"),
u'(x"01"),u'(x"11"),u'(x"13"),u'(x"01"),u'(x"8b"),u'(x"ff"),u'(x"80"),u'(x"8a"),u'(x"d7"),u'(x"ff"),u'(x"01"),u'(x"0a"),u'(x"0a"),u'(x"11"),u'(x"01"),u'(x"a0"),
u'(x"00"),u'(x"03"),u'(x"e5"),u'(x"00"),u'(x"65"),u'(x"00"),u'(x"86"),u'(x"0c"),u'(x"0c"),u'(x"0c"),u'(x"50"),u'(x"01"),u'(x"15"),u'(x"00"),u'(x"00"),u'(x"0c"),
u'(x"8c"),u'(x"11"),u'(x"01"),u'(x"15"),u'(x"20"),u'(x"0c"),u'(x"03"),u'(x"8c"),u'(x"87"),u'(x"01"),u'(x"00"),u'(x"11"),u'(x"01"),u'(x"24"),u'(x"00"),u'(x"ff"),
u'(x"15"),u'(x"18"),u'(x"11"),u'(x"01"),u'(x"63"),u'(x"07"),u'(x"8a"),u'(x"d5"),u'(x"00"),u'(x"01"),u'(x"00"),u'(x"b5"),u'(x"00"),u'(x"03"),u'(x"c5"),u'(x"00"),
u'(x"8b"),u'(x"ff"),u'(x"80"),u'(x"90"),u'(x"ff"),u'(x"c5"),u'(x"80"),u'(x"24"),u'(x"00"),u'(x"ff"),u'(x"15"),u'(x"ea"),u'(x"15"),u'(x"01"),u'(x"13"),u'(x"0a"),
u'(x"95"),u'(x"0a"),u'(x"95"),u'(x"0a"),u'(x"27"),u'(x"02"),u'(x"0a"),u'(x"c7"),u'(x"29"),u'(x"c7"),u'(x"02"),u'(x"11"),u'(x"1d"),u'(x"ff"),u'(x"91"),u'(x"d1"),
u'(x"00"),u'(x"20"),u'(x"03"),u'(x"00"),u'(x"0b"),u'(x"02"),u'(x"23"),u'(x"02"),u'(x"00"),u'(x"00"),u'(x"12"),u'(x"15"),u'(x"eb"),u'(x"0b"),u'(x"08"),u'(x"00"),
u'(x"08"),u'(x"00"),u'(x"15"),u'(x"e0"),u'(x"0a"),u'(x"00"),u'(x"15"),u'(x"eb"),u'(x"00"),u'(x"15"),u'(x"01"),u'(x"0b"),u'(x"0a"),u'(x"10"),u'(x"0b"),u'(x"20"),
u'(x"83"),u'(x"0a"),u'(x"0b"),u'(x"60"),u'(x"0b"),u'(x"02"),u'(x"20"),u'(x"83"),u'(x"00"),u'(x"00"),u'(x"18"),u'(x"10"),u'(x"0a"),u'(x"00"),u'(x"41"),u'(x"a6") 
);

-- m9312l16.t2

begin
   base_addr_match <= '1' when base_addr(17 downto 9) = bus_addr(17 downto 9) else '0';
   bus_addr_match <= base_addr_match;

   process(clk, base_addr_match)
   begin
      if clk = '1' and clk'event then
         bus_dati(7 downto 0) <= meme(conv_integer(bus_addr(8 downto 1)));
         bus_dati(15 downto 8) <= memo(conv_integer(bus_addr(8 downto 1)));
      end if;
   end process;

end implementation;

