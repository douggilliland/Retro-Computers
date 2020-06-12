
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
u'(x"52"),u'(x"16"),u'(x"b1"),u'(x"c0"),u'(x"00"),u'(x"c1"),u'(x"68"),u'(x"c4"),u'(x"34"),u'(x"0a"),u'(x"00"),u'(x"e0"),u'(x"54"),u'(x"66"),u'(x"b1"),u'(x"c0"),
u'(x"00"),u'(x"c1"),u'(x"70"),u'(x"f3"),u'(x"c5"),u'(x"00"),u'(x"c3"),u'(x"04"),u'(x"d3"),u'(x"0b"),u'(x"c6"),u'(x"42"),u'(x"65"),u'(x"c5"),u'(x"1a"),u'(x"d5"),
u'(x"c1"),u'(x"d5"),u'(x"16"),u'(x"d5"),u'(x"c2"),u'(x"d5"),u'(x"ea"),u'(x"d5"),u'(x"89"),u'(x"d5"),u'(x"c9"),u'(x"d5"),u'(x"fe"),u'(x"d5"),u'(x"72"),u'(x"d5"),
u'(x"02"),u'(x"4d"),u'(x"15"),u'(x"85"),u'(x"d5"),u'(x"b7"),u'(x"d5"),u'(x"ee"),u'(x"d5"),u'(x"f5"),u'(x"4d"),u'(x"75"),u'(x"e6"),u'(x"5f"),u'(x"74"),u'(x"e7"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00") 
);
signal memo : mem_type := mem_type'(
u'(x"50"),u'(x"00"),u'(x"00"),u'(x"15"),u'(x"00"),u'(x"15"),u'(x"ff"),u'(x"11"),u'(x"86"),u'(x"01"),u'(x"f6"),u'(x"00"),u'(x"54"),u'(x"00"),u'(x"00"),u'(x"15"),
u'(x"00"),u'(x"15"),u'(x"ff"),u'(x"01"),u'(x"15"),u'(x"e0"),u'(x"15"),u'(x"00"),u'(x"11"),u'(x"0a"),u'(x"15"),u'(x"01"),u'(x"10"),u'(x"45"),u'(x"00"),u'(x"15"),
u'(x"1d"),u'(x"15"),u'(x"00"),u'(x"15"),u'(x"15"),u'(x"15"),u'(x"00"),u'(x"15"),u'(x"0a"),u'(x"15"),u'(x"8b"),u'(x"15"),u'(x"80"),u'(x"15"),u'(x"9c"),u'(x"15"),
u'(x"00"),u'(x"11"),u'(x"8a"),u'(x"0a"),u'(x"15"),u'(x"0a"),u'(x"15"),u'(x"ff"),u'(x"15"),u'(x"01"),u'(x"10"),u'(x"00"),u'(x"ff"),u'(x"00"),u'(x"eb"),u'(x"d9"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),
u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00"),u'(x"00") 
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

