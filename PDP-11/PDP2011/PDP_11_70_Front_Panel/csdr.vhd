
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

entity csdr is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

-- config

      have_csdr : in integer range 0 to 1;

-- console switches

      cs_reg : in std_logic_vector(15 downto 0);

-- console display
      cd_reg : out std_logic_vector(15 downto 0);

      reset : in std_logic;
      clk : in std_logic
   );
end csdr;

architecture implementation of csdr is

signal base_addr_match : std_logic;

begin

   base_addr_match <= '1' when base_addr(17 downto 1) = bus_addr(17 downto 1) and have_csdr = 1 else '0';
   bus_addr_match <= base_addr_match;

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if have_csdr = 1 then
            if reset = '1' then
               cd_reg <= "0000000000000000";
            else

               bus_dati <= cs_reg;

               if base_addr_match = '1' and bus_control_dato = '1' then
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     cd_reg(7 downto 0) <= bus_dato(7 downto 0);
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     cd_reg(15 downto 8) <= bus_dato(15 downto 8);
                  end if;
               end if;

            end if;
         else
            cd_reg <= "XXXXXXXXXXXXXXXX";
         end if;
      end if;
   end process;

end implementation;

