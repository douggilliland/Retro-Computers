
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

-- m9312h16.t1

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity m9312h is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;

      clk : in std_logic
   );
end m9312h;

architecture implementation of m9312h is

signal base_addr_match : std_logic;

subtype u is std_logic_vector(7 downto 0);
type mem_type is array(0 to 255) of u;

-- code base at 173000

signal meme : mem_type := mem_type'(
u'(x"5f"),u'(x"0c"),u'(x"5f"),u'(x"74"),u'(x"5f"),u'(x"60"),u'(x"c6"),u'(x"00"),u'(x"1f"),u'(x"06"),u'(x"df"),u'(x"32"),u'(x"04"),u'(x"df"),u'(x"00"),u'(x"c2"),
u'(x"9c"),u'(x"c1"),u'(x"f1"),u'(x"1f"),u'(x"04"),u'(x"1f"),u'(x"06"),u'(x"00"),u'(x"5d"),u'(x"c6"),u'(x"00"),u'(x"1f"),u'(x"06"),u'(x"df"),u'(x"58"),u'(x"04"),
u'(x"df"),u'(x"00"),u'(x"c2"),u'(x"ae"),u'(x"c1"),u'(x"de"),u'(x"1f"),u'(x"04"),u'(x"1f"),u'(x"06"),u'(x"00"),u'(x"18"),u'(x"c6"),u'(x"00"),u'(x"1f"),u'(x"06"),
u'(x"df"),u'(x"7e"),u'(x"04"),u'(x"df"),u'(x"c0"),u'(x"c2"),u'(x"c0"),u'(x"c1"),u'(x"cb"),u'(x"1f"),u'(x"04"),u'(x"1f"),u'(x"06"),u'(x"00"),u'(x"52"),u'(x"c2"),
u'(x"d2"),u'(x"c1"),u'(x"c1"),u'(x"00"),u'(x"c1"),u'(x"00"),u'(x"03"),u'(x"c3"),u'(x"c9"),u'(x"f1"),u'(x"0b"),u'(x"04"),u'(x"c3"),u'(x"04"),u'(x"c9"),u'(x"c9"),
u'(x"fe"),u'(x"03"),u'(x"c3"),u'(x"08"),u'(x"c9"),u'(x"c9"),u'(x"fe"),u'(x"42"),u'(x"06"),u'(x"c2"),u'(x"3f"),u'(x"82"),u'(x"b1"),u'(x"04"),u'(x"03"),u'(x"c3"),
u'(x"06"),u'(x"c9"),u'(x"c9"),u'(x"fe"),u'(x"31"),u'(x"04"),u'(x"f1"),u'(x"00"),u'(x"06"),u'(x"03"),u'(x"c3"),u'(x"0c"),u'(x"c9"),u'(x"c9"),u'(x"fe"),u'(x"c9"),
u'(x"02"),u'(x"05"),u'(x"d1"),u'(x"c9"),u'(x"ff"),u'(x"07"),u'(x"c1"),u'(x"04"),u'(x"31"),u'(x"04"),u'(x"03"),u'(x"a1"),u'(x"03"),u'(x"03"),u'(x"03"),u'(x"03"),
u'(x"f1"),u'(x"06"),u'(x"f1"),u'(x"00"),u'(x"02"),u'(x"c3"),u'(x"05"),u'(x"c9"),u'(x"c9"),u'(x"fe"),u'(x"c9"),u'(x"02"),u'(x"05"),u'(x"e8"),u'(x"c9"),u'(x"ff"),
u'(x"07"),u'(x"c1"),u'(x"c0"),u'(x"31"),u'(x"08"),u'(x"c2"),u'(x"39"),u'(x"c9"),u'(x"11"),u'(x"f1"),u'(x"00"),u'(x"1a"),u'(x"71"),u'(x"0e"),u'(x"0e"),u'(x"f1"),
u'(x"00"),u'(x"02"),u'(x"43"),u'(x"c3"),u'(x"ff"),u'(x"83"),u'(x"c9"),u'(x"c9"),u'(x"fe"),u'(x"c9"),u'(x"02"),u'(x"05"),u'(x"e4"),u'(x"c9"),u'(x"ff"),u'(x"07"),
u'(x"df"),u'(x"74"),u'(x"fd"),u'(x"ca"),u'(x"03"),u'(x"9f"),u'(x"76"),u'(x"f8"),u'(x"71"),u'(x"02"),u'(x"c2"),u'(x"18"),u'(x"b1"),u'(x"40"),u'(x"42"),u'(x"c3"),
u'(x"df"),u'(x"74"),u'(x"fd"),u'(x"9f"),u'(x"76"),u'(x"c2"),u'(x"86"),u'(x"c0"),u'(x"03"),u'(x"42"),u'(x"fc"),u'(x"f1"),u'(x"71"),u'(x"02"),u'(x"0d"),u'(x"62"),
u'(x"6f"),u'(x"20"),u'(x"72"),u'(x"6d"),u'(x"72"),u'(x"3a"),u'(x"0a"),u'(x"0d"),u'(x"62"),u'(x"6f"),u'(x"20"),u'(x"72"),u'(x"6d"),u'(x"72"),u'(x"3a"),u'(x"0a"),
u'(x"0d"),u'(x"62"),u'(x"6f"),u'(x"20"),u'(x"72"),u'(x"6d"),u'(x"72"),u'(x"3a"),u'(x"0a"),u'(x"0d"),u'(x"62"),u'(x"6f"),u'(x"3a"),u'(x"6e"),u'(x"20"),u'(x"65"),
u'(x"0d"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00") 
);
signal memo : mem_type := mem_type'(
u'(x"00"),u'(x"f6"),u'(x"00"),u'(x"f7"),u'(x"00"),u'(x"f7"),u'(x"15"),u'(x"02"),u'(x"0a"),u'(x"00"),u'(x"15"),u'(x"f6"),u'(x"00"),u'(x"0b"),u'(x"ff"),u'(x"15"),
u'(x"f7"),u'(x"11"),u'(x"01"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"01"),u'(x"15"),u'(x"02"),u'(x"0a"),u'(x"00"),u'(x"15"),u'(x"f6"),u'(x"00"),
u'(x"0b"),u'(x"f9"),u'(x"15"),u'(x"f7"),u'(x"11"),u'(x"01"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"01"),u'(x"15"),u'(x"02"),u'(x"0a"),u'(x"00"),
u'(x"15"),u'(x"f6"),u'(x"00"),u'(x"0b"),u'(x"fd"),u'(x"15"),u'(x"f7"),u'(x"11"),u'(x"01"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"00"),u'(x"0a"),u'(x"01"),u'(x"15"),
u'(x"f7"),u'(x"11"),u'(x"01"),u'(x"00"),u'(x"15"),u'(x"f9"),u'(x"10"),u'(x"00"),u'(x"10"),u'(x"15"),u'(x"00"),u'(x"00"),u'(x"55"),u'(x"00"),u'(x"10"),u'(x"8b"),
u'(x"80"),u'(x"8a"),u'(x"55"),u'(x"00"),u'(x"10"),u'(x"8b"),u'(x"80"),u'(x"1c"),u'(x"00"),u'(x"45"),u'(x"00"),u'(x"0a"),u'(x"10"),u'(x"00"),u'(x"8a"),u'(x"55"),
u'(x"00"),u'(x"10"),u'(x"8b"),u'(x"80"),u'(x"0a"),u'(x"00"),u'(x"15"),u'(x"fe"),u'(x"00"),u'(x"8a"),u'(x"55"),u'(x"00"),u'(x"10"),u'(x"8b"),u'(x"80"),u'(x"0b"),
u'(x"80"),u'(x"00"),u'(x"01"),u'(x"45"),u'(x"00"),u'(x"0a"),u'(x"15"),u'(x"ff"),u'(x"0a"),u'(x"00"),u'(x"10"),u'(x"00"),u'(x"0c"),u'(x"0c"),u'(x"0c"),u'(x"0c"),
u'(x"10"),u'(x"00"),u'(x"15"),u'(x"fe"),u'(x"00"),u'(x"55"),u'(x"00"),u'(x"10"),u'(x"8b"),u'(x"80"),u'(x"0b"),u'(x"80"),u'(x"00"),u'(x"01"),u'(x"45"),u'(x"00"),
u'(x"0a"),u'(x"15"),u'(x"fd"),u'(x"10"),u'(x"00"),u'(x"15"),u'(x"00"),u'(x"15"),u'(x"00"),u'(x"15"),u'(x"18"),u'(x"00"),u'(x"1c"),u'(x"00"),u'(x"00"),u'(x"15"),
u'(x"fe"),u'(x"00"),u'(x"12"),u'(x"45"),u'(x"00"),u'(x"50"),u'(x"10"),u'(x"8b"),u'(x"80"),u'(x"0b"),u'(x"80"),u'(x"00"),u'(x"01"),u'(x"45"),u'(x"00"),u'(x"0a"),
u'(x"8b"),u'(x"ff"),u'(x"80"),u'(x"8b"),u'(x"03"),u'(x"94"),u'(x"ff"),u'(x"01"),u'(x"00"),u'(x"00"),u'(x"15"),u'(x"00"),u'(x"00"),u'(x"0c"),u'(x"8c"),u'(x"11"),
u'(x"8b"),u'(x"ff"),u'(x"80"),u'(x"90"),u'(x"ff"),u'(x"15"),u'(x"20"),u'(x"0c"),u'(x"03"),u'(x"8c"),u'(x"87"),u'(x"01"),u'(x"00"),u'(x"00"),u'(x"0a"),u'(x"6f"),
u'(x"74"),u'(x"66"),u'(x"6f"),u'(x"20"),u'(x"6b"),u'(x"0d"),u'(x"00"),u'(x"0a"),u'(x"6f"),u'(x"74"),u'(x"66"),u'(x"6f"),u'(x"20"),u'(x"6c"),u'(x"0d"),u'(x"00"),
u'(x"0a"),u'(x"6f"),u'(x"74"),u'(x"66"),u'(x"6f"),u'(x"20"),u'(x"70"),u'(x"0d"),u'(x"00"),u'(x"0a"),u'(x"6f"),u'(x"74"),u'(x"20"),u'(x"6f"),u'(x"64"),u'(x"76"),
u'(x"0a"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00") 
);

-- m9312h16.t2

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

