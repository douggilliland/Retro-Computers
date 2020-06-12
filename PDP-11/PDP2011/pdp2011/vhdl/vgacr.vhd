
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

entity vgacr is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      vga_cursor : out std_logic_vector(12 downto 0);

      reset : in std_logic;
      clk : in std_logic
   );
end vgacr;

architecture implementation of vgacr is

signal base_addr_match : std_logic;
signal we : std_logic;
signal wo : std_logic;

signal cursor: std_logic_vector(12 downto 0);

begin

   base_addr_match <= '1' when base_addr(17 downto 2) = bus_addr(17 downto 2) else '0';
   bus_addr_match <= '1' when base_addr_match = '1' else '0';

   we <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '0') else '0';
   wo <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '1') else '0';

   vga_cursor <= cursor;

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            cursor <= (others => '0');

         else

            if base_addr_match = '1' and (bus_control_dati = '1' or bus_control_dato = '1') then
               case bus_addr(2 downto 1) is
                  when "00" =>
                     if bus_control_dati = '1' then
                        bus_dati <= "000" & cursor;
                     end if;
                     if wo = '1' then
                        cursor(12 downto 8) <= bus_dato(12 downto 8);
                     end if;
                     if we = '1' then
                        cursor(7 downto 0) <= bus_dato(7 downto 0);
                     end if;

                  when others =>
                     null;

               end case;

            end if;

         end if;
      end if;
   end process;

end implementation;

