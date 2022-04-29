
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

entity kw11l is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      have_kw11l : in integer range 0 to 1;
      kw11l_hz : in integer range 50 to 800;

      reset : in std_logic;
      clk50mhz : in std_logic;
      clk : in std_logic
   );
end kw11l;

architecture implementation of kw11l is

signal lc_monitor : std_logic;
signal lc_ie : std_logic;
signal lineclk : std_logic;

signal lc_clk_old : std_logic;

-- regular bus interface

signal base_addr_match : std_logic;
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait,
   i_oth
);
signal interrupt_state : interrupt_state_type := i_idle;

signal counter : integer range 0 to 500000;
signal limit : integer range 31249 to 500000;


begin

   base_addr_match <= '1' when base_addr(17 downto 1) = bus_addr(17 downto 1) and have_kw11l = 1 else '0';
   bus_addr_match <= base_addr_match;

   with kw11l_hz select limit <=
      31249  when 800,
      416666 when 60,
      499999 when 50,
      416666 when others;

   process(clk, reset, lineclk)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            br <= '0';
            if have_kw11l = 1 then
               interrupt_state <= i_idle;

               lc_clk_old <= lineclk;
               lc_monitor <= '1';                -- EK-KDJ1B-UG_KDJ11-B_Nov86.pdf, table 1-23, pg. 1-45
               lc_ie <= '0';
            end if;

         else

            if have_kw11l = 1 then
               case interrupt_state is

                  when i_idle =>

                     br <= '0';
                     if lc_ie = '1' and lc_monitor = '1' then
                        interrupt_state <= i_req;
                        br <= '1';
                     end if;

                  when i_req =>
                     lc_monitor <= '0';
                     br <= '1';
                     if lc_ie = '1' then
                        if bg = '1' then
                           int_vector <= ivec;
                           br <= '0';
                           interrupt_state <= i_wait;
                        end if;
                     else
                        interrupt_state <= i_idle;
                     end if;

                  when i_wait =>
                     if bg = '0' then
                        interrupt_state <= i_idle;
                     end if;

                  when others =>
                     interrupt_state <= i_idle;

               end case;
            else
               br <= '0';
            end if;

            if have_kw11l = 1 then
               if base_addr_match = '1' and bus_control_dati = '1' then
                  bus_dati <= "00000000" & lc_monitor & lc_ie & "000000";
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     lc_monitor <= bus_dato(7);
                     lc_ie <= bus_dato(6);
                  end if;
               end if;

               lc_clk_old <= lineclk;
               if lineclk /= lc_clk_old and lineclk = '1' then
                  lc_monitor <= '1';
               end if;
            end if;

         end if;
      end if;

   end process;

   process(clk50mhz, reset)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            counter <= 0;
            lineclk <= '0';
         else
            counter <= counter + 1;
            if counter >= limit then
               lineclk <= not lineclk;
               counter <= 0;
            end if;
         end if;
      end if;
   end process;

end implementation;

