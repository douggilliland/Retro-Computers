
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


entity vga is
   port(
      base_addr : in std_logic_vector(17 downto 0);                  -- base address of this bus entity
      bus_addr_match : out std_logic;                                -- current access recognised by this bus entity
      bus_addr : in std_logic_vector(17 downto 0);                   -- current bus address
      bus_dati : out std_logic_vector(15 downto 0);                  -- input to bus
      bus_dato : in std_logic_vector(15 downto 0);                   -- output from bus
      bus_control_dati : in std_logic;                               -- bus is doing a read transaction
      bus_control_dato : in std_logic;                               -- bus is doing a write transaction
      bus_control_datob : in std_logic;                              -- bus is doing a byte write transaction

      vga_cursor : in std_logic_vector(12 downto 0);                 -- cursor address
      vga_shade0 : in std_logic_vector(7 downto 0);                  -- vt105 shade0 value
      vga_shade1 : in std_logic_vector(7 downto 0);                  -- vt105 shade1 value
      vga_xp : in std_logic_vector(8 downto 0);                      -- vt105 x coordinate for strip charts
      vga_graphics : in std_logic;                                   -- vt105 master graph enable
      vga_graph0 : in std_logic;                                     -- vt105 graph0 enabled
      vga_graph1 : in std_logic;                                     -- vt105 graph1 enabled
      vga_hist0 : in std_logic;                                      -- vt105 graph0 histogram mode
      vga_hist1 : in std_logic;                                      -- vt105 graph1 histogram mode
      vga_hlines : in std_logic;                                     -- vt105 horizontal lines enabled
      vga_vlines : in std_logic;                                     -- vt105 vertical lines enabled
      vga_marker0 : in std_logic;                                    -- vt105 marker0 enabled
      vga_marker1 : in std_logic;                                    -- vt105 marker1 enabled
      vga_graph0s : in std_logic;                                    -- vt105 graph0 shading enabled
      vga_graph1s : in std_logic;                                    -- vt105 graph1 shading enabled
      vga_strip0 : in std_logic;                                     -- vt105 strip chart enabled
      vga_strip1 : in std_logic;                                     -- vt105 dual strip chart enabled
      vga_square : in std_logic;                                     -- vt105 graphics square format

      vga_acth : in std_logic_vector(7 downto 0);                    -- act counter, high byte (serial port activity)
      vga_actl : in std_logic_vector(7 downto 0);                    -- act counter, low byte (keyboard activity)

      vga_hsync : out std_logic;                                     -- horizontal sync
      vga_vsync : out std_logic;                                     -- vertical sync
      vga_fb : out std_logic;                                        -- monochrome output full on
      vga_ht : out std_logic;                                        -- monochrome output half strength for shading

      vga_cursor_block : in std_logic := '1';                        -- block or underline cursor
      vga_cursor_blink : in std_logic := '0';                        -- blinking or steady cursor

      teste : in std_logic := '0';                                   -- show 24*80 capital-E test pattern
      testf : in std_logic := '0';                                   -- show 24*80 all bits on test pattern

      vttype : in integer range 100 to 105;                          -- conditional compilation; valid values are 100 and 105

      have_act_seconds : in integer range 0 to 7200 := 900;          -- auto screen off time, in seconds; 0 means disabled
      have_act : in integer range 1 to 2 := 2;                       -- auto screen off counter reset by keyboard and serial port activity (1) or keyboard only (2)

      reset : in std_logic;                                          -- reset
      clk : in std_logic;                                            -- bus clock
      clk50mhz : in std_logic                                        -- 50MHz input for vga signals
   );
end vga;

architecture implementation of vga is

component vgafont is
   port(
      ix : in std_logic_vector(15 downto 0);
      pix : out std_logic;
      vgaclk : in std_logic
   );
end component;


signal base_addr_match : std_logic;

subtype vgachar_subtype is std_logic_vector(7 downto 0);
type charbuf_type is array(0 to 2047) of vgachar_subtype;
subtype attr_subtype is std_logic_vector(3 downto 0);
type attrbuf_type is array(0 to 2047) of attr_subtype;
subtype graph_subtype is std_logic_vector(7 downto 0);
type graph_type is array(0 to 511) of graph_subtype;
subtype graphdata_subtype is std_logic_vector(3 downto 0);
type graphdata_type is array(0 to 511) of graphdata_subtype;

signal charbuf : charbuf_type;
signal attrbuf : attrbuf_type;
signal graph0 : graph_type;
signal graph1 : graph_type;
signal graphdata : graphdata_type;

signal charbuf_addr_match : std_logic;
signal graphbuf0_addr_match : std_logic;
signal g0addr : std_logic_vector(8 downto 0);
signal graphbuf1_addr_match : std_logic;
signal g1addr : std_logic_vector(8 downto 0);

signal vgaclk : std_logic := '0';
signal vga_col : integer range 0 to 1039 := 0;
signal vga_row : integer range 0 to 665 := 0;
signal vga_row_evenodd : std_logic;
signal vga_fontcolumnindex : std_logic_vector(2 downto 0) := "000";
signal vga_fontrowindex : std_logic_vector(4 downto 0) := "00000";
signal vga_charindex : std_logic_vector(12 downto 0) := "0000000000000";
signal vga_rowstartindex : std_logic_vector(12 downto 0) := "0000000000000";

signal graph_col : std_logic_vector(8 downto 0);
signal graph_row : std_logic_vector(7 downto 0);
signal g0val : std_logic_vector(7 downto 0);
signal g1val : std_logic_vector(7 downto 0);
signal gcoldata : std_logic_vector(3 downto 0);
signal growdata : std_logic_vector(3 downto 0);

signal cursor_match : std_logic_vector(2 downto 0) := "000";
signal ix : std_logic_vector(15 downto 0);
signal pix : std_logic;
signal fb : std_logic;
signal ht : std_logic;
signal boldpix : std_logic;

signal char : std_logic_vector(7 downto 0);
signal attr2 : std_logic_vector(3 downto 0);
signal attr : std_logic_vector(3 downto 0);
signal attr_bd : std_logic;
signal attr_ul : std_logic;
signal attr_bl : std_logic;
signal attr_rv : std_logic;
signal chaddr : std_logic_vector(11 downto 1);

signal blink_on : std_logic;
signal blinkcount : integer range 0 to 31 := 0;
constant max_seconds : integer := 7201;
signal seconds : integer range 0 to max_seconds := 0;

signal actxh : std_logic_vector(7 downto 0);
signal actxl : std_logic_vector(7 downto 0);
signal act2h : std_logic_vector(7 downto 0);
signal act2l : std_logic_vector(7 downto 0);
signal act1h : std_logic_vector(7 downto 0);
signal act1l : std_logic_vector(7 downto 0);

begin
   font: vgafont port map(
      ix => ix,
      pix => pix,
      vgaclk => vgaclk
   );

   base_addr_match <= '1' when base_addr(17 downto 13) = bus_addr(17 downto 13) else '0';
   bus_addr_match <= base_addr_match;

   process(clk50mhz)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            vgaclk <= '0';
         else
            vgaclk <= not vgaclk;
         end if;
      end if;
   end process;

   charbuf_addr_match <= '1' when base_addr_match = '1' and bus_addr(12) = '0' else '0';
   process(clk)
   begin
      if clk = '1' and clk'event then
         if charbuf_addr_match = '1' then
            chaddr <= bus_addr(11 downto 1);
            if bus_control_dato = '1' then
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                  charbuf(conv_integer(bus_addr(11 downto 1))) <= bus_dato(7 downto 0);
               end if;
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                  attrbuf(conv_integer(bus_addr(11 downto 1))) <= bus_dato(11 downto 8);
               end if;
            end if;
         end if;
      end if;
   end process;

   graphbuf0_addr_match <= '1' when vttype = 105 and base_addr_match = '1' and bus_addr(12 downto 10) = "100" else '0';
   process(clk, graphbuf0_addr_match)
   begin
      if clk = '1' and clk'event then
         if graphbuf0_addr_match = '1' then
            g0addr <= bus_addr(9 downto 1);
            if bus_control_dato = '1' then
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                  graph0(conv_integer(bus_addr(9 downto 1))) <= bus_dato(7 downto 0);
               end if;
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                  graphdata(conv_integer(bus_addr(9 downto 1))) <= bus_dato(11 downto 8);
               end if;
            end if;
         end if;
      end if;
   end process;

   graphbuf1_addr_match <= '1' when vttype = 105 and base_addr_match = '1' and bus_addr(12 downto 10) = "101" else '0';
   process(clk, graphbuf1_addr_match)
   begin
      if clk = '1' and clk'event then
         if graphbuf1_addr_match = '1' then
            g1addr <= bus_addr(9 downto 1);
            if bus_control_dato = '1' then
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                  graph1(conv_integer(bus_addr(9 downto 1))) <= bus_dato(7 downto 0);
               end if;
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
               end if;
            end if;
         end if;
      end if;
   end process;

   bus_dati <= "0000" & attrbuf(conv_integer(chaddr)) & charbuf(conv_integer(chaddr)) when charbuf_addr_match = '1'
   else "0000" & graphdata(conv_integer(g0addr)) & graph0(conv_integer(g0addr)) when graphbuf0_addr_match = '1'
   else "00000000" & graph1(conv_integer(g1addr)) when graphbuf1_addr_match = '1'
   else "0000000000000000";

   process(vgaclk)
   begin
      if vgaclk='1' and vgaclk'event then
         if reset = '1' then
            vga_col <= 0;
            vga_row <= 0;
            vga_rowstartindex <= "0000000000000";
            vga_fontrowindex <= "00000";
            vga_hsync <= '1';
            vga_vsync <= '1';
            vga_fb <= '0';
            vga_ht <= '0';
            blinkcount <= 0;
            blink_on <= '0';
            seconds <= 0;
            actxh <= (others => '0');
            actxl <= (others => '0');
            act2h <= (others => '0');
            act2l <= (others => '0');
            act1h <= (others => '0');
            act1l <= (others => '0');
         else
            if vga_col < 799 then
               vga_col <= vga_col + 1;
            else
               vga_col <= 0;
               if unsigned(vga_fontrowindex) < unsigned'("10011") then
                  vga_fontrowindex <= vga_fontrowindex + 1;
               else
                  vga_fontrowindex <= "00000";
                  vga_rowstartindex <= vga_rowstartindex + 80;
               end if;
               if vga_row < 523 then
                  vga_row <= vga_row + 1;
                  vga_row_evenodd <= not vga_row_evenodd;
                  if vga_row_evenodd = '0' then
                     graph_row <= graph_row - 1;
                  end if;
                  if vga_row >= 479 then
                     vga_rowstartindex <= "0000000000000";
                     vga_fontrowindex <= "00000";
                  end if;
               else
                  if blinkcount < 29 then
                     blinkcount <= blinkcount + 1;
                  else
                     blinkcount <= 0;
                     blink_on <= not blink_on;
                     if blink_on = '1' then
                        if seconds < max_seconds then
                           seconds <= seconds + 1;
                        end if;
                     end if;
                  end if;
                  vga_row <= 0;
                  vga_row_evenodd <= '0';
                  vga_rowstartindex <= "0000000000000";
                  vga_fontrowindex <= "00000";
                  graph_row <= "11101111";          -- 239
               end if;
            end if;

            vga_hsync <= '1';
            vga_fb <= '0';
            vga_ht <= '0';
            fb <= '0';
            ht <= '0';

            if (vga_charindex = '0' & vga_cursor(12 downto 1)) then
               cursor_match <= cursor_match(1 downto 0) & '1';
            else
               cursor_match <= cursor_match(1 downto 0) & '0';
            end if;

--
-- read the character to display from the buffer. And attributes, including pipeline
--

            char <= charbuf(conv_integer(vga_charindex));
            attr2 <= attrbuf(conv_integer(vga_charindex));
            attr <= attr2;
            attr_bd <= attr(0);
            attr_ul <= attr(1);
            attr_bl <= attr(2);
            attr_rv <= attr(3);

--
-- teste - substitute whatever is in the buffer with E, no attributes. Useful for screen alignment
--

            if teste = '1' then
               char <= "01000101";                     -- capital E
               attr2 <= "0000";
            end if;

--
-- form the index into the font rom
--

            ix <= ("0" & vga_fontrowindex & "0000000000") + (vga_fontcolumnindex & "0000000") + char;

--
-- pick up the pixel from the font rom
--

            fb <= pix;
            boldpix <= pix;

--
-- deal with the cursor
--

            if cursor_match(2) = '1' then
               if (vga_cursor_blink = '1' and blink_on = '0') or (vga_cursor_blink = '0') then
                  if vga_cursor_block = '1' then
                     if unsigned(vga_fontrowindex) < unsigned'("10000") then         -- don't let the cursor match the full 8*20, that doesn't look right
                        fb <= not pix;                                               -- the block cursor is really reverse video
                     end if;
                  else
                     if unsigned(vga_fontrowindex) >= unsigned'("10000") and unsigned(vga_fontrowindex) <= unsigned'("10010") then
                        fb <= '1';
                     end if;
                  end if;
               end if;
            end if;

--
-- deal with attributes
--

            if attr_bd = '1' and boldpix = '1' then
               fb <= '1';
            end if;
            if attr_ul = '1' and vga_fontrowindex = "10000" then
               fb <= '1';
            end if;
            if attr_rv = '1' then
               fb <= not pix;
               if attr_bd = '1' and boldpix = '1' then
                  fb <= '0';
               end if;
               if attr_ul = '1' and vga_fontrowindex = "10000" then
                  fb <= '0';
               end if;
            end if;
            if attr_bl = '1' then
               if blink_on = '1' then
                  if attr_rv = '1' then
                     fb <= '1';
                  else
                     fb <= '0';
                  end if;
                  if attr_bd = '1' and boldpix = '1' then
                     if attr_rv = '1' then
                        fb <= '1';
                     else
                        fb <= '0';
                     end if;
                  end if;
               end if;
            end if;

--
-- testf - this is useful for aligning timing for the full screen
--

            if testf = '1' then
               fb <= '1';
            end if;

--
-- graph stuff
--

            if vttype = 105 and vga_graphics = '1' then
               g0val <= graph0(conv_integer(graph_col));
               g1val <= graph1(conv_integer(graph_col));
               gcoldata <= graphdata(conv_integer(graph_col));
               if vga_col = 209 then
                  graph_col <= '0' & graph_row;
               elsif vga_col = 211 then
                  growdata <= gcoldata;
                  if vga_strip0 = '1' or vga_strip1 = '1' then
                     graph_col <= vga_xp;
                  else
                     graph_col <= (others => '0');
                  end if;
               elsif vga_col > 212 and vga_col <= 724 then
                  graph_col <= graph_col + 1;
                  if vga_graph0 = '1' and g0val = graph_row then
                     fb <= '1';
                  end if;
                  if vga_graph1 = '1' and g1val = graph_row then
                     fb <= '1';
                  end if;
                  if vga_marker0 = '1' and g0val(7 downto 2) = (graph_row(7 downto 2) - 1) and gcoldata(0) = '1' then
                     fb <= '1';
                  end if;
                  if vga_marker1 = '1' and g1val(7 downto 2) = (graph_row(7 downto 2) - 1) and gcoldata(1) = '1' then
                     fb <= '1';
                  end if;
                  if vga_hlines = '1' and growdata(3) = '1' then
                     fb <= '1';
                  end if;
                  if vga_vlines = '1' and gcoldata(2) = '1' then
                     fb <= '1';
                  end if;
                  if vga_graph0s = '1' and
                     ((unsigned(g0val) > unsigned(graph_row) and unsigned(graph_row) > unsigned(vga_shade0))
                        or
                      (unsigned(g0val) < unsigned(graph_row) and unsigned(graph_row) < unsigned(vga_shade0)))
                   then
                     ht <= '1';
                  end if;
                  if vga_graph1s = '1' and
                     ((unsigned(g1val) > unsigned(graph_row) and unsigned(graph_row) > unsigned(vga_shade1))
                        or
                      (unsigned(g1val) < unsigned(graph_row) and unsigned(graph_row) < unsigned(vga_shade1)))
                   then
                     ht <= '1';
                  end if;
               end if;
            end if;

--
-- timing
--

            if vga_col < 96 then
               vga_hsync <= '0';
            elsif vga_col < 141 then
               vga_fontcolumnindex <= "111";
               vga_charindex <= vga_rowstartindex;
            elsif vga_col < 784 then

               if unsigned(vga_fontcolumnindex) = unsigned'("110") then
                  vga_charindex <= vga_charindex + 1;
               end if;

               if unsigned(vga_fontcolumnindex) < unsigned'("111") then
                  vga_fontcolumnindex <= vga_fontcolumnindex + 1;
               else
                  vga_fontcolumnindex <= "000";
               end if;

               if vga_col < 144 then
                  vga_fb <= '0';
                  vga_ht <= '0';
               else
                  vga_fb <= fb;
                  vga_ht <= ht;
               end if;

            end if;

            vga_vsync <= '1';
            if vga_row < 480 then                                              -- 480 normal display rows
            elsif vga_row < 489 then                                           -- 10 rows - front porch
               vga_fb <= '0';
               vga_ht <= '0';
            elsif vga_row < 491 then                                           -- 2 rows - sync pulse
               vga_vsync <= '0';
               vga_fb <= '0';
               vga_ht <= '0';
            else                                                               -- 33 rows - back porch
               vga_fb <= '0';
               vga_ht <= '0';
            end if;

            if seconds > have_act_seconds and have_act_seconds > 0 then
               vga_hsync <= '1';
               vga_vsync <= '1';
               vga_fb <= '0';
               vga_ht <= '0';
            end if;

            if have_act_seconds > 0 then
               act1h <= vga_acth;
               act1l <= vga_actl;
               act2h <= act1h;
               act2l <= act1l;
               if actxl /= act2l then
                  actxl <= act2l;
                  seconds <= 0;
               end if;
               if actxh /= act2h and have_act = 1 then
                  actxh <= act2h;
                  seconds <= 0;
               end if;
            end if;

         end if;

      end if;
   end process;

end implementation;

