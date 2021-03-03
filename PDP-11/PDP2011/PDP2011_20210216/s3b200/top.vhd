
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

-- s3b200 board

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
   port(
      led : out std_logic_vector(7 downto 0);
      seg : out std_logic_vector(6 downto 0);
      an : out std_logic_vector(3 downto 0);
      dp : out std_logic;
      clkin : in std_logic;
      sw : in std_logic_vector(7 downto 0);
      tx : out std_logic;
      rx : in std_logic;

      clkout : out std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

      sdcard2_cs : out std_logic;
      sdcard2_mosi : out std_logic;
      sdcard2_sclk : out std_logic;
      sdcard2_miso : in std_logic;

      sram_addr : out std_logic_vector(17 downto 0);
      sram_dq : inout std_logic_vector(15 downto 0);
      sram_we_n : out std_logic;
      sram_oe_n : out std_logic;
      sram_ub_n : out std_logic;
      sram_lb_n : out std_logic;
      sram_ce_n1 : out std_logic;
      sram_ce_n2 : out std_logic;

      reset : in std_logic
   );
end top;

architecture implementation of top is

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

signal cpuclk : std_logic;
signal iwait : std_logic;
signal ifetch : std_logic;

signal addr : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;

signal rxrx0 : std_logic;
signal txtx0 : std_logic;

signal sram_match : std_logic;

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

begin

   pdp11: unibus port map(
      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => sram_match,

      ifetch => ifetch,

      have_rk => 1,
      have_rk_debug => 0,
      have_rk_minimal => 1,
      have_rk_num => 2,
      rk_sdcard_cs => cs2,
      rk_sdcard_mosi => mosi2,
      rk_sdcard_sclk => sclk2,
      rk_sdcard_miso => miso2,
      rk_sdcard_debug => sddebug,

      have_kl11 => 1,
      kl0_force7bit => 1,
      kl0_bps => 9600,
      rx0 => rxrx0,
      tx0 => txtx0,

      have_csdr => 0,
      have_kw11l => 1,
      modelcode => 10,

      clk => cpuclk,
      clk50mhz => clkin,
      reset => reset
   );

--    qsseg0: qsseg port map(
--       d3 => addr(15 downto 12),
--       d2 => addr(11 downto 8),
--       d1 => addr(7 downto 4),
--       d0 => addr(3 downto 0),
--       dp3 => '0',
--       dp2 => '0',
--       dp1 => '0',
--       dp0 => '0',
--       seg => seg,
--       an => an,
--       dp => dp,
--       clk => lcdclk,
--       reset => reset
--    );

   seg <= "1111111";
   an <= "0000";
   dp <= '1';

--    clkdiv2: clkdiv50k port map(
--      clkin => clkin,
--      clkout => lcdclk
--    );


   clkout <= '0';

   sdcard_cs <= cs;
   sdcard_mosi <= mosi;
   sdcard_sclk <= sclk;
   miso <= sdcard_miso;

   sdcard2_cs <= cs2;
   sdcard2_mosi <= mosi2;
   sdcard2_sclk <= sclk2;
   miso2 <= sdcard2_miso;

   rxrx0 <= rx;
   tx <= txtx0;

--    led(7 downto 4) <= sddebug;
--    led(3 downto 0) <= sddebug2;
   led <= not rxrx0 & not txtx0 & "00" & sddebug;

--   sdcard_debug <= sddebug;

   sram_match <= '1' when addr(21 downto 19) = "000" else '0';
   sram_addr <= addr(18 downto 1);

   sram_ce_n1 <= '1';

   process(clkin)
   begin
      if clkin='1' and clkin'event then

         case clk_fsm is

            when clk_n =>
               clk_fsm <= clk_ne;
-- read
               if sram_match = '1' and control_dati = '1' then
                  sram_ce_n2 <= '0';
                  sram_oe_n <= '0';
                  sram_ub_n <= '0';
                  sram_lb_n <= '0';
                  sram_we_n <= '1';
                  sram_dq <= "ZZZZZZZZZZZZZZZZ";
               end if;


-- blinkenlights
               if control_dati = '1' or control_dato = '1' or control_datob = '1' then
               end if;

               if control_dato = '1' then
               else
               end if;

-- write
               if sram_match = '1' and control_dato = '1' then
                  sram_ce_n2 <= '0';
                  sram_oe_n <= '1';
               end if;
               if sram_match = '1' and control_dato = '1' then
                  sram_we_n <= '0';
                  sram_dq <= dato;
                  if control_datob = '1' then
                     if addr(0) = '0' then
                        sram_lb_n <= '0';
                     else
                        sram_ub_n <= '0';
                     end if;
                  else
                     sram_lb_n <= '0';
                     sram_ub_n <= '0';
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

               if sram_match = '1' and control_dati = '1' then
                  dati <= sram_dq(15 downto 0);
               end if;

            when clk_sw =>
               clk_fsm <= clk_w;

            when clk_w =>
               clk_fsm <= clk_nw;
               sram_ce_n2 <= '1';
               sram_oe_n <= '1';
               sram_we_n <= '1';
               sram_lb_n <= '1';
               sram_ub_n <= '1';
               sram_dq <= "ZZZZZZZZZZZZZZZZ";
            cpuclk <= '1';

            when clk_nw =>
               clk_fsm <= clk_n;

            when others =>
               null;

         end case;

      end if;
   end process;

end implementation;

