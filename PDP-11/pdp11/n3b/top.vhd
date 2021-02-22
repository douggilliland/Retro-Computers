
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

-- $Revision: 1.13 $

-- nexys3 board

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity n3b is
   port(
      led : out std_logic_vector(7 downto 0);
      sw : in std_logic_vector(7 downto 0);

      seg : out std_logic_vector(6 downto 0);
      an : out std_logic_vector(3 downto 0);
      dp : out std_logic;

      jc : out std_logic_vector(7 downto 0);

      tx : out std_logic;
      rx : in std_logic;

      ps2k_c : in std_logic;
      ps2k_d : in std_logic;
      ps2m_c : in std_logic;
      ps2m_d : in std_logic;

      vgar : out std_logic_vector(2 downto 0);
      vgag : out std_logic_vector(2 downto 0);
      vgab : out std_logic_vector(2 downto 1);
      vgah : out std_logic;
      vgav : out std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

-- ethernet, enc424j600 controller interface
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;

      psdram_addr : out std_logic_vector(22 downto 0);
      psdram_data : inout std_logic_vector(15 downto 0);
      psdram_we : out std_logic;
      psdram_oe : out std_logic;
      psdram_ub : out std_logic;
      psdram_lb : out std_logic;
      psdram_cs : out std_logic;
      psdram_cre : out std_logic;
      psdram_adv : out std_logic;
      psdram_clk : out std_logic;
      psdram_wait : in std_logic;

      clkin : in std_logic;
      reset : in std_logic
   );
end n3b;

architecture implementation of n3b is

component unibus is
   port(
-- bus interface
      addr : out std_logic_vector(21 downto 0);                      -- physical address driven out to the bus by cpu or busmaster peripherals
      dati : in std_logic_vector(15 downto 0);                       -- data input to cpu or busmaster peripherals
      dato : out std_logic_vector(15 downto 0);                      -- data output from cpu or busmaster peripherals
      control_dati : out std_logic;                                  -- if '1', this is an input cycle
      control_dato : out std_logic;                                  -- if '1', this is an output cycle
      control_datob : out std_logic;                                 -- if '1', the current output cycle is for a byte
      addr_match : in std_logic;                                     -- '1' if the address is recognized

-- debug & blinkenlights
      ifetch : out std_logic;                                        -- '1' if this cycle is an ifetch cycle
      iwait : out std_logic;                                         -- '1' if the cpu is in wait state
      cpu_addr_v : out std_logic_vector(15 downto 0);                -- virtual address from cpu, for debug and general interest

-- rl controller
      have_rl : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      have_rl_debug : in integer range 0 to 1 := 1;                  -- enable debug core
      rl_sdcard_cs : out std_logic;
      rl_sdcard_mosi : out std_logic;
      rl_sdcard_sclk : out std_logic;
      rl_sdcard_miso : in std_logic := '0';
      rl_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- rk controller
      have_rk : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      have_rk_debug : in integer range 0 to 2 := 1;                  -- enable debug core; 0=none; 1=all; 2=debug blinkenlights only
      have_rk_num : in integer range 1 to 8 := 8;                    -- active number of drives on the controller; set to < 8 to save core
      have_rk_minimal : in integer range 0 to 1 := 0;                -- 1 for smaller core, but not very compatible controller. Useful to fit s3b200 only
      rk_sdcard_cs : out std_logic;
      rk_sdcard_mosi : out std_logic;
      rk_sdcard_sclk : out std_logic;
      rk_sdcard_miso : in std_logic := '0';
      rk_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- rh controller
      have_rh : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      have_rh_debug : in integer range 0 to 1 := 1;                  -- enable debug core
      rh_sdcard_cs : out std_logic;
      rh_sdcard_mosi : out std_logic;
      rh_sdcard_sclk : out std_logic;
      rh_sdcard_miso : in std_logic := '0';
      rh_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- xu enc424j600 controller interface
      have_xu : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      have_xu_debug : in integer range 0 to 1 := 1;                  -- enable debug core
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic := '0';
      xu_debug_tx : out std_logic;                                   -- rs232, 115200/8/n/1 debug output from microcode

-- kl11, console ports
      have_kl11 : in integer range 0 to 4 := 1;                      -- conditional compilation - number of kl11 controllers to include. Should normally be at least 1

      tx0 : out std_logic;
      rx0 : in std_logic := '1';
      rts0 : out std_logic;
      cts0 : in std_logic := '0';
      kl0_bps : in integer range 1200 to 230400 := 9600;             -- bps rate - don't set over 38400 for interrupt control applications
      kl0_force7bit : in integer range 0 to 1 := 0;                  -- zero out high order bit on transmission and reception
      kl0_rtscts : in integer range 0 to 1 := 0;                     -- conditional compilation switch for rts and cts signals; also implies to include core that implements a silo buffer

      tx1 : out std_logic;
      rx1 : in std_logic := '1';
      rts1 : out std_logic;
      cts1 : in std_logic := '0';
      kl1_bps : in integer range 1200 to 230400 := 9600;
      kl1_force7bit : in integer range 0 to 1 := 0;
      kl1_rtscts : in integer range 0 to 1 := 0;

      tx2 : out std_logic;
      rx2 : in std_logic := '1';
      rts2 : out std_logic;
      cts2 : in std_logic := '0';
      kl2_bps : in integer range 1200 to 230400 := 9600;
      kl2_force7bit : in integer range 0 to 1 := 0;
      kl2_rtscts : in integer range 0 to 1 := 0;

      tx3 : out std_logic;
      rx3 : in std_logic := '1';
      rts3 : out std_logic;
      cts3 : in std_logic := '0';
      kl3_bps : in integer range 1200 to 230400 := 9600;
      kl3_force7bit : in integer range 0 to 1 := 0;
      kl3_rtscts : in integer range 0 to 1 := 0;

-- cpu console, switches and display register
      have_csdr : in integer range 0 to 1 := 1;
      console_switches : in std_logic_vector(15 downto 0) := "0000000000000000";
      console_displays : out std_logic_vector(15 downto 0);

-- clock
      have_kw11l : in integer range 0 to 1 := 1;                     -- conditional compilation
      kw11l_hz : in integer range 50 to 800 := 60;                   -- valid values are 50, 60, 800

-- model code
      modelcode : in integer range 0 to 255;                         -- mostly used are 20,34,44,45,70,94; others are less well tested
      have_fp : in integer range 0 to 2 := 2;                        -- fp11 switch; 0=don't include; 1=include; 2=include if the cpu model can support fp11
      have_fpa : in integer range 0 to 1 := 1;                       -- floating point accelerator present with J11 cpu

-- cpu initial r7 and psw
      init_r7 : in std_logic_vector(15 downto 0) := x"ea10";         -- start address after reset f600 = o'173000' = m9312 hi rom; ea10 = 165020 = m9312 lo rom
      init_psw : in std_logic_vector(15 downto 0) := x"00e0";        -- initial psw for kernel mode, primary register set, priority 7

-- clock, run & reset
      run : in std_logic := '0';                                     -- set to '1' to restart cpu from halt state
      clk : in std_logic;                                            -- cpu clock
      clk50mhz : in std_logic;                                       -- 50Mhz clock for peripherals
      reset : in std_logic                                           -- active '1' synchronous reset
   );
end component;

component vt is
   port(
      vga_hsync : out std_logic;
      vga_vsync : out std_logic;
      vga_out : out std_logic;

-- serial port
      tx : out std_logic;
      rx : in std_logic;

-- ps2 keyboard
      ps2k_c : in std_logic;
      ps2k_d : in std_logic;

-- debug & blinkenlights
      ifetch : out std_logic;
      iwait : out std_logic;

-- clock & reset
      cpuclk : in std_logic;
      clk50mhz : in std_logic;
      reset : in std_logic
   );
end component;

component qsseg is
   port(
      d3 : in std_logic_vector(3 downto 0);
      d2 : in std_logic_vector(3 downto 0);
      d1 : in std_logic_vector(3 downto 0);
      d0 : in std_logic_vector(3 downto 0);
      dp3 : in std_logic;
      dp2 : in std_logic;
      dp1 : in std_logic;
      dp0 : in std_logic;
      seg : out std_logic_vector(6 downto 0);
      an : out std_logic_vector(3 downto 0);
      dp : out std_logic;
      clk : in std_logic;
      reset : in std_logic
   );
end component;

component clkdiv50k is
   port(
      clkin : in std_logic;
      clkout : out std_logic
   );
end component;

type clk_fsm_type is (
   clk_n,
   clk_ne,
   clk_e,
   clk_se,
   clk_s,
   clk_sw,
   clk_w,
   clk_nw
);
signal clk_fsm : clk_fsm_type := clk_n;

signal lcdclk : std_logic;
signal clk50mhz : std_logic;
signal c0 : std_logic;

signal cpuclk : std_logic;
signal ifetch: std_logic;
signal iwait : std_logic;

signal addrq : std_logic_vector(21 downto 0);

signal addr : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;

signal psdram_match : std_logic;

signal cs : std_logic;
signal mosi : std_logic;
signal miso : std_logic;
signal sclk : std_logic;
signal sddebug : std_logic_vector(3 downto 0);

signal cs2 : std_logic;
signal mosi2 : std_logic;
signal miso2 : std_logic;
signal sclk2 : std_logic;
signal sddebug2 : std_logic_vector(3 downto 0);

signal vga_hsync : std_logic;
signal vga_vsync : std_logic;
signal vga_out : std_logic;

signal txtx0 : std_logic;
signal rxrx0 : std_logic;
signal txtx1 : std_logic;
signal rxrx1 : std_logic;

begin

   pdp11: unibus port map(
      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => psdram_match,

      ifetch => ifetch,
      iwait => iwait,

      have_rh => 1,
      have_rh_debug => 1,
      rh_sdcard_cs => cs,
      rh_sdcard_mosi => mosi,
      rh_sdcard_sclk => sclk,
      rh_sdcard_miso => miso,
      rh_sdcard_debug => sddebug,

      have_xu => 1,
      xu_cs => xu_cs,
      xu_mosi => xu_mosi,
      xu_sclk => xu_sclk,
      xu_miso => xu_miso,
--      xu_debug_tx => tx,

      have_kl11 => 1,
      rx0 => rx,
      tx0 => tx,
      kl0_force7bit => 1,

      modelcode => 70, 
      have_fp => 0,

      clk => cpuclk,
      clk50mhz => clk50mhz,
      reset => reset
   );

   qsseg0: qsseg port map(
      d3 => addrq(15 downto 12),
      d2 => addrq(11 downto 8),
      d1 => addrq(7 downto 4),
      d0 => addrq(3 downto 0),
      dp3 => '0',
      dp2 => '0',
      dp1 => '0',
      dp0 => '0',
      seg => seg,
      an => an,
      dp => dp,
      clk => lcdclk,
      reset => reset
   );

   clkdiv2: clkdiv50k port map(
      clkin => clkin,
      clkout => lcdclk
   );

   sdcard_cs <= cs;
   sdcard_mosi <= mosi;
   sdcard_sclk <= sclk;
   miso <= sdcard_miso;

   led <= not ps2k_c & not ps2k_d & not ps2m_c & not ps2m_d & sddebug;

   jc <= (others => '0');

   vgag <= "111" when vga_out = '1' else "000";
   vgab <= "00";
   vgar <= "000";
   vgav <= vga_vsync;
   vgah <= vga_hsync;

   psdram_match <= '1' when addr(21 downto 18) /= "1111" else '0';
--   psdram_match <= '1' when addr(21) = '0' else '0';
   psdram_addr(22) <= '0';
   psdram_addr(21) <= '0';
   psdram_addr(20 downto 0) <= addr(21 downto 1);
   psdram_clk <= '0';
   psdram_adv <= '0';
   psdram_cre <= '0';

   c0 <= clk50mhz;
   process(clkin)
   begin
      if clkin='1' and clkin'event then
         clk50mhz <= not clk50mhz;
      end if;
   end process;

   process(c0)
   begin
      if c0='1' and c0'event then

         case clk_fsm is

            when clk_n =>
               clk_fsm <= clk_ne;
-- read
               if psdram_match = '1' and control_dati = '1' then
                  psdram_cs <= '0';
                  psdram_oe <= '0';
                  psdram_ub <= '0';
                  psdram_lb <= '0';
                  psdram_we <= '1';
                  psdram_data <= "ZZZZZZZZZZZZZZZZ";
               end if;

-- blinkenlights
               if control_dati = '1' or control_dato = '1' or control_datob = '1' then
                  addrq <= addr;
               end if;

-- write
               if psdram_match = '1' and control_dato = '1' then
                  psdram_cs <= '0';
                  psdram_oe <= '1';
                  psdram_we <= '0';
                  psdram_data <= dato;
                  if control_datob = '1' then
                     if addr(0) = '0' then
                        psdram_lb <= '0';
                     else
                        psdram_ub <= '0';
                     end if;
                  else
                     psdram_lb <= '0';
                     psdram_ub <= '0';
                  end if;
               end if;

            when clk_ne =>
               clk_fsm <= clk_e;

            when clk_e =>
               clk_fsm <= clk_se;
            cpuclk <= '0';

            when clk_se =>
               clk_fsm <= clk_s;

            when clk_s =>
               clk_fsm <= clk_sw;

               if psdram_match = '1' and control_dati = '1' then
                  dati <= psdram_data;
               end if;

            when clk_sw =>
               clk_fsm <= clk_w;

            when clk_w =>
               clk_fsm <= clk_nw;
               psdram_cs <= '1';
               psdram_oe <= '1';
               psdram_we <= '1';
               psdram_lb <= '1';
               psdram_ub <= '1';
               psdram_data <= "ZZZZZZZZZZZZZZZZ";
            cpuclk <= '1';

            when clk_nw =>
               clk_fsm <= clk_n;

            when others =>
               null;

         end case;

      end if;
   end process;

end implementation;

