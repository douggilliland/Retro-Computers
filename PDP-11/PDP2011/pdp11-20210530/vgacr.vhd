
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

entity vgacr is
   port(
      base_addr : in std_logic_vector(17 downto 0);                  -- base address of this bus entity
      bus_addr_match : out std_logic;                                -- current access recognised by this bus entity
      bus_addr : in std_logic_vector(17 downto 0);                   -- current bus address
      bus_dati : out std_logic_vector(15 downto 0);                  -- input to bus
      bus_dato : in std_logic_vector(15 downto 0);                   -- output from bus
      bus_control_dati : in std_logic;                               -- bus is doing a read transaction
      bus_control_dato : in std_logic;                               -- bus is doing a write transaction
      bus_control_datob : in std_logic;                              -- bus is doing a byte write transaction

      vga_cursor : out std_logic_vector(12 downto 0);                -- cursor address
      vga_shade0 : out std_logic_vector(7 downto 0);                 -- vt105 shade0 value
      vga_shade1 : out std_logic_vector(7 downto 0);                 -- vt105 shade1 value
      vga_xp : out std_logic_vector(8 downto 0);                     -- vt105 x coordinate for strip charts
      vga_graphics : out std_logic;                                  -- vt105 master graph enable
      vga_graph0 : out std_logic;                                    -- vt105 graph0 enabled
      vga_graph1 : out std_logic;                                    -- vt105 graph1 enabled
      vga_hist0 : out std_logic;                                     -- vt105 graph0 histogram mode
      vga_hist1 : out std_logic;                                     -- vt105 graph1 histogram mode
      vga_hlines : out std_logic;                                    -- vt105 horizontal lines enabled
      vga_vlines : out std_logic;                                    -- vt105 vertical lines enabled
      vga_vcur : out std_logic;                                      -- vt220 visible cursor
      vga_marker0 : out std_logic;                                   -- vt105 marker0 enabled
      vga_marker1 : out std_logic;                                   -- vt105 marker1 enabled
      vga_graph0s : out std_logic;                                   -- vt105 graph0 shading enabled
      vga_graph1s : out std_logic;                                   -- vt105 graph1 shading enabled
      vga_strip0 : out std_logic;                                    -- vt105 strip chart enabled
      vga_strip1 : out std_logic;                                    -- vt105 dual strip chart enabled
      vga_square : out std_logic;                                    -- vt105 graphics square format

      vga_doublewidth : out std_logic_vector(23 downto 0);           -- marker for double width lines
      vga_doubleheight : out std_logic_vector(23 downto 0);          -- marker for double heigth lines
      vga_doubleheight_low : out std_logic_vector(23 downto 0);      -- marks high (0) or low(1) part of double height

      vga_acth : out std_logic_vector(7 downto 0);                   -- act counter, high byte (serial port activity)
      vga_actl : out std_logic_vector(7 downto 0);                   -- act counter, low byte (keyboard activity)

      vga_debug : out std_logic_vector(15 downto 0);                 -- debug output from microcode

      vttype : in integer range 100 to 105;                          -- conditional compilation; valid values are 100 and 105

      reset : in std_logic;                                          -- reset
      clk : in std_logic                                             -- bus clock
   );
end vgacr;

architecture implementation of vgacr is

signal base_addr_match : std_logic;
signal we : std_logic;
signal wo : std_logic;

signal cursor : std_logic_vector(12 downto 0);
signal shade0 : std_logic_vector(7 downto 0);
signal shade1 : std_logic_vector(7 downto 0);
signal xp : std_logic_vector(8 downto 0);
signal acth : std_logic_vector(7 downto 0);
signal actl : std_logic_vector(7 downto 0);

signal graphics : std_logic;                                    -- 000001
signal graph0 : std_logic;                                      -- 000002
signal graph1 : std_logic;                                      -- 000004
signal hist0 : std_logic;                                       -- 000010
signal hist1 : std_logic;                                       -- 000020
signal hlines : std_logic;                                      -- 000040
signal vlines : std_logic;                                      -- 000100
signal vcur : std_logic;                                        -- 000200
signal marker0 : std_logic;                                     -- 000400
signal marker1 : std_logic;                                     -- 001000
signal graph0s : std_logic;                                     -- 002000
signal graph1s : std_logic;                                     -- 004000
signal strip0 : std_logic;                                      -- 010000
signal strip1 : std_logic;                                      -- 020000
signal square : std_logic;                                      -- 100000

signal vga_d : std_logic_vector(15 downto 0);

signal doublewidth : std_logic_vector(23 downto 0);
signal doubleheight : std_logic_vector(23 downto 0);
signal doubleheight_low  : std_logic_vector(23 downto 0);

begin

   base_addr_match <= '1' when base_addr(17 downto 6) = bus_addr(17 downto 6) else '0';
   bus_addr_match <= '1' when base_addr_match = '1' else '0';

   we <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '0') else '0';
   wo <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '1') else '0';

   vga_cursor <= cursor;
   vga_shade0 <= shade0;
   vga_shade1 <= shade1;
   vga_xp <= xp;

   vga_graphics <= graphics;
   vga_graph0 <= graph0;
   vga_graph1 <= graph1;
   vga_hist0 <= hist0;
   vga_hist1 <= hist1;
   vga_hlines <= hlines;
   vga_vlines <= vlines;
   vga_vcur <= vcur;
   vga_marker0 <= marker0;
   vga_marker1 <= marker1;
   vga_graph0s <= graph0s;
   vga_graph1s <= graph1s;
   vga_strip0 <= strip0;
   vga_strip1 <= strip1;
   vga_square <= square;

   vga_acth <= acth;
   vga_actl <= actl;

   vga_debug <= vga_d;

   vga_doublewidth <= doublewidth;
   vga_doubleheight <= doubleheight;
   vga_doubleheight_low <= doubleheight_low;

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            cursor <= (others => '0');
            graphics <= '0';
            graph0 <= '0';
            graph1 <= '0';
            hist0 <= '0';
            hist1 <= '0';
            hlines <= '0';
            vlines <= '0';
            vcur <= '0';
            marker0 <= '0';
            marker1 <= '0';
            graph0s <= '0';
            graph1s <= '0';
            strip0 <= '0';
            strip1 <= '0';
            square <= '0';

            doublewidth <= (others => '0');
            doubleheight <= (others => '0');
            doubleheight_low <= (others => '0');

         else

            if base_addr_match = '1' and bus_addr(5 downto 4) = "00" and (bus_control_dati = '1' or bus_control_dato = '1') then
               case bus_addr(3 downto 1) is
                  when "000" =>
                     if bus_control_dati = '1' then
                        bus_dati <= "000" & cursor;
                     end if;
                     if wo = '1' then
                        cursor(12 downto 8) <= bus_dato(12 downto 8);
                     end if;
                     if we = '1' then
                        cursor(7 downto 0) <= bus_dato(7 downto 0);
                     end if;

                  when "001" =>
                     if bus_control_dati = '1' then
                        bus_dati <= square & "0" & strip1 & strip0 & graph1s & graph0s & marker1 & marker0 & vcur & vlines & hlines & hist1 & hist0 & graph1 & graph0 & graphics;
                     end if;
                     if wo = '1' then
                        marker0 <= bus_dato(8);
                        marker1 <= bus_dato(9);
                        graph0s <= bus_dato(10);
                        graph1s <= bus_dato(11);
                        strip0 <= bus_dato(12);
                        strip1 <= bus_dato(13);
                        square <= bus_dato(15);
                     end if;
                     if we = '1' then
                        graphics <= bus_dato(0);
                        graph0 <= bus_dato(1);
                        graph1 <= bus_dato(2);
                        hist0 <= bus_dato(3);
                        hist1 <= bus_dato(4);
                        hlines <= bus_dato(5);
                        vlines <= bus_dato(6);
                        vcur <= bus_dato(7);
                     end if;

                  when "010" =>
                     if bus_control_dati = '1' then
                        bus_dati <= "00000000" & shade0;
                     end if;
                     if we = '1' then
                        shade0 <= bus_dato(7 downto 0);
                     end if;

                  when "011" =>
                     if bus_control_dati = '1' then
                        bus_dati <= "00000000" & shade1;
                     end if;
                     if we = '1' then
                        shade1 <= bus_dato(7 downto 0);
                     end if;

                  when "100" =>
                     if bus_control_dati = '1' then
                        bus_dati <= "0000000" & xp;
                     end if;
                     if we = '1' then
                        xp(7 downto 0) <= bus_dato(7 downto 0);
                     end if;
                     if wo = '1' then
                        xp(8) <= bus_dato(8);
                     end if;

                  when "101" =>
                     if bus_control_dati = '1' then
                        bus_dati <= conv_std_logic_vector(vttype,bus_dati'length);
                     end if;

                  when "110" =>
                     if bus_control_dati = '1' then
                        bus_dati <= acth & actl;
                     end if;
                     if wo = '1' then
                        acth <= bus_dato(15 downto 8);
                     end if;
                     if we = '1' then
                        actl <= bus_dato(7 downto 0);
                     end if;

                  when "111" =>
                     if bus_control_dati = '1' then
                        bus_dati <= vga_d;
                     end if;
                     if wo = '1' then
                        vga_d(15 downto 8) <= bus_dato(15 downto 8);
                     end if;
                     if we = '1' then
                        vga_d(7 downto 0) <= bus_dato(7 downto 0);
                     end if;

                  when others =>
                     null;

               end case;

            end if;

            if base_addr_match = '1' and bus_addr(5) = '1' and (bus_control_dati = '1' or bus_control_dato = '1') then
               if bus_control_dati = '1' and bus_addr(4 downto 0) < "11000" then
                  bus_dati <= "00000"
                     & doublewidth(conv_integer(bus_addr(4 downto 1) & '1')) & doubleheight_low(conv_integer(bus_addr(4 downto 1) & '1')) & doubleheight(conv_integer(bus_addr(4 downto 1) & '1'))
                     & "00000"
                     & doublewidth(conv_integer(bus_addr(4 downto 1) & '0')) & doubleheight_low(conv_integer(bus_addr(4 downto 1) & '0')) & doubleheight(conv_integer(bus_addr(4 downto 1) & '0'))
                     ;
               else
                  bus_dati <= "0000000000000000";
               end if;
               if we = '1' and bus_addr(4 downto 0) < "11000" then
                  doublewidth(conv_integer(bus_addr(4 downto 1) & '0')) <= bus_dato(2);
                  doubleheight_low(conv_integer(bus_addr(4 downto 1) & '0')) <= bus_dato(1);
                  doubleheight(conv_integer(bus_addr(4 downto 1) & '0')) <= bus_dato(0);
               end if;
               if wo = '1' and bus_addr(4 downto 0) < "11000" then
                  doublewidth(conv_integer(bus_addr(4 downto 1) & '1')) <= bus_dato(10);
                  doubleheight_low(conv_integer(bus_addr(4 downto 1) & '1')) <= bus_dato(9);
                  doubleheight(conv_integer(bus_addr(4 downto 1) & '1')) <= bus_dato(8);
               end if;
            end if;

         end if;
      end if;
   end process;

end implementation;

