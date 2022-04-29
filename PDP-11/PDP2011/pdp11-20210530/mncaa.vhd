
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

entity mncaa is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      da_dac0 : out std_logic_vector(11 downto 0);
      da_dac1 : out std_logic_vector(11 downto 0);
      da_dac2 : out std_logic_vector(11 downto 0);
      da_dac3 : out std_logic_vector(11 downto 0);

      have_mncaa : in integer range 0 to 1 := 0;

      reset : in std_logic;

      clk50mhz : in std_logic;
      clk : in std_logic
   );
end mncaa;

architecture implementation of mncaa is


-- bus interface
signal base_addr_match : std_logic;


-- logic

signal aadac0 : std_logic_vector(11 downto 0);
signal aadac1 : std_logic_vector(11 downto 0);
signal aadac2 : std_logic_vector(11 downto 0);
signal aadac3 : std_logic_vector(11 downto 0);


begin

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_mncaa = 1 else '0';
   bus_addr_match <= base_addr_match;

   da_dac0 <= aadac0;
   da_dac1 <= aadac1;
   da_dac2 <= aadac2;
   da_dac3 <= aadac3;

   process(clk, base_addr_match, reset, have_mncaa)
   begin
      if clk = '1' and clk'event then

         if have_mncaa = 1 then
            if reset = '1' then
               aadac0 <= (others => '0');
               aadac1 <= (others => '0');
               aadac2 <= (others => '0');
               aadac3 <= (others => '0');
            else

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        bus_dati <= "0000" & aadac0;
                     when "01" =>
                        bus_dati <= "0000" & aadac1;
                     when "10" =>
                        bus_dati <= "0000" & aadac2;
                     when "11" =>
                        bus_dati <= "0000" & aadac3;
                     when others =>
                        null;
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           aadac0(7 downto 0) <= bus_dato(7 downto 0);
                        when "01" =>
                           aadac1(7 downto 0) <= bus_dato(7 downto 0);
                        when "10" =>
                           aadac2(7 downto 0) <= bus_dato(7 downto 0);
                        when "11" =>
                           aadac3(7 downto 0) <= bus_dato(7 downto 0);
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           aadac0(11 downto 8) <= bus_dato(11 downto 8);
                        when "01" =>
                           aadac1(11 downto 8) <= bus_dato(11 downto 8);
                        when "10" =>
                           aadac2(11 downto 8) <= bus_dato(11 downto 8);
                        when "11" =>
                           aadac3(11 downto 8) <= bus_dato(11 downto 8);
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

            end if;
         end if;
      end if;
   end process;

end implementation;

