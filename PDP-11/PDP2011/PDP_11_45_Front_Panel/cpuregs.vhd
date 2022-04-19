
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

entity cpuregs is
   port(
      raddr : in std_logic_vector(5 downto 0);
      waddr : in std_logic_vector(5 downto 0);
      d : in std_logic_vector(15 downto 0);
      o : out std_logic_vector(15 downto 0);
      we : in std_logic;
      r0s : in std_logic;
      r0 : out std_logic_vector(15 downto 0);
      clk : in std_logic
   );
end cpuregs;

architecture implementation of cpuregs is

subtype mem_unit is std_logic_vector(15 downto 0);
type mem_type is array(15 downto 0) of mem_unit;
signal regs : mem_type := mem_type'(
   mem_unit'("0000000000000000"),                          --  0/r0
   mem_unit'("0000000000000000"),                          --  1/r1
   mem_unit'("0000000000000000"),                          --  2/r2
   mem_unit'("0000000000000000"),                          --  3/r3
   mem_unit'("0000000000000000"),                          --  4/r4
   mem_unit'("0000000000000000"),                          --  5/r5
   mem_unit'("0000000000000000"),                          --  6/ksp
   mem_unit'("0000000000000000"),                          --  7/pc - not used
   mem_unit'("0000000000000000"),                          --  8/10/r0
   mem_unit'("0000000000000000"),                          --  9/11/r1
   mem_unit'("0000000000000000"),                          -- 10/12/r2
   mem_unit'("0000000000000000"),                          -- 11/13/r3
   mem_unit'("0000000000000000"),                          -- 12/14/r4
   mem_unit'("0000000000000000"),                          -- 13/15/r5
   mem_unit'("0000000000000000"),                          -- 14/16/ssp
   mem_unit'("0000000000000000")                           -- 15/17/usp
);

signal r_loc : std_logic_vector(3 downto 0);
signal w_loc : std_logic_vector(3 downto 0);

begin

   r0 <= regs(conv_integer(0)) when r0s = '0' else
       regs(conv_integer(8));

   r_loc <=
      raddr(3 downto 0) when raddr(2 downto 1) /= "11" else                           -- kernel 0-5 loc 0-5, u 0-5 loc 8-13
      "0110" when raddr(2 downto 0) = "110" and raddr(5 downto 4) = "00" else         -- kernel sp loc 6
      "1110" when raddr(2 downto 0) = "110" and raddr(5 downto 4) = "01" else         -- super sp loc 14
      "1111" when raddr(2 downto 0) = "110" and raddr(5 downto 4) = "11" else         -- user sp loc 15
      "0111";                                                                         -- invalid

   w_loc <=
      waddr(3 downto 0) when waddr(2 downto 1) /= "11" else                           -- kernel 0-5 loc 0-5, u 0-5 loc 8-13
      "0110" when waddr(2 downto 0) = "110" and waddr(5 downto 4) = "00" else         -- kernel sp loc 6
      "1110" when waddr(2 downto 0) = "110" and waddr(5 downto 4) = "01" else         -- super sp loc 14
      "1111" when waddr(2 downto 0) = "110" and waddr(5 downto 4) = "11" else         -- user sp loc 15
      "0111";                                                                         -- invalid

   process(clk, we, w_loc, d)
   begin
      if clk = '1' and clk'event then
         if we = '1' and w_loc /= "0111" then
            regs(conv_integer(w_loc)) <= d;
         end if;
      end if;
   end process;

   process(r_loc, regs, raddr)
   begin
      if r_loc /= "0111" then
         o <= regs(conv_integer(r_loc));
      else
         o <= (others => '0');
      end if;
   end process;

end implementation;
