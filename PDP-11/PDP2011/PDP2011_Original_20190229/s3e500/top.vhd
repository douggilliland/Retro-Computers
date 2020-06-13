
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

-- Portions included in this file are copyright (c) Xilinx, 2003

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
    Port (         sma_out : out std_logic;
                       led : out std_logic_vector(7 downto 0);
            strataflash_oe : out std_logic;
            strataflash_ce : out std_logic;
            strataflash_we : out std_logic;
                     lcd_d : inout std_logic_vector(7 downto 4);
                    lcd_rs : out std_logic;
                    lcd_rw : out std_logic;
                     lcd_e : out std_logic;
                  rotary_a : in std_logic;
                  rotary_b : in std_logic;
              rotary_press : in std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

      sdcard2_cs : out std_logic;
      sdcard2_mosi : out std_logic;
      sdcard2_sclk : out std_logic;
      sdcard2_miso : in std_logic;

                     j3 : out std_logic_vector(3 downto 0);
                    sw : in std_logic_vector(3 downto 0);
      tx : out std_logic;
      rx : in std_logic;

      reset : in std_logic;

                       clk : in std_logic);
end top;

architecture implementation of top is

component frequency_generator is
    Port (         sma_out : out std_logic;
                    simple : out std_logic_vector(12 downto 9);
                       led : out std_logic_vector(7 downto 0);
            strataflash_oe : out std_logic;
            strataflash_ce : out std_logic;
            strataflash_we : out std_logic;
                     lcd_d : inout std_logic_vector(7 downto 4);
                    lcd_rs : out std_logic;
                    lcd_rw : out std_logic;
                     lcd_e : out std_logic;
                  rotary_a : in std_logic;
                  rotary_b : in std_logic;
              rotary_press : in std_logic;
                       clk : in std_logic);
end component;

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


signal dummyclk : std_logic;
signal dummyled : std_logic_vector(7 downto 0);
signal dummysimple : std_logic_vector(12 downto 9);

signal lineclock: std_logic;
signal sluclock: std_logic;
signal cpu_ifetch : std_logic;
signal clk_sw : std_logic_vector(7 downto 0);

signal addr : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;
signal console_switches : std_logic_vector(15 downto 0);
signal console_displays : std_logic_vector(15 downto 0);

signal ifetch : std_logic;
signal addr_match : std_logic;

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

signal  top_reset : std_logic;
signal sma : std_logic;

subtype u is std_logic_vector(7 downto 0);
type mem_type is array(0 to 16383) of u;

signal meme : mem_type;
signal memo : mem_type;


begin

  frequency_control: frequency_generator
    port map(      sma_out => sma,
                    simple => dummysimple,
                       led => dummyled,
            strataflash_oe => strataflash_oe,
            strataflash_ce => strataflash_ce,
            strataflash_we => strataflash_we,
                     lcd_d => lcd_d,
                    lcd_rs => lcd_rs,
                    lcd_rw => lcd_rw,
                     lcd_e => lcd_e,
                  rotary_a => rotary_a,
                  rotary_b => rotary_b,
              rotary_press => rotary_press,
                       clk => clk);


   pdp11: unibus port map(
      console_switches => console_switches,
      console_displays => console_displays,

      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => addr_match,

--       have_rl => 0,
--       have_rl_debug => 0,
--       rl_sdcard_cs => cs,
--       rl_sdcard_mosi => mosi,
--       rl_sdcard_sclk => sclk,
--       rl_sdcard_miso => miso,
--       rl_sdcard_debug => sddebug,

      have_rl => 1,
      rl_sdcard_debug => sddebug2,
      rl_sdcard_cs => cs2,
      rl_sdcard_mosi => mosi2,
      rl_sdcard_sclk => sclk2,
      rl_sdcard_miso => miso2,
 
      rx0 => rx,
      tx0 => tx,
      kl0_force7bit => 1,
 
      modelcode => 45,
      have_fp => 0,

      ifetch => ifetch,

      clk => sma,
		clk50mhz => clk,
      reset => reset
   );


   led <= "0000" & sddebug2;

   j3 <= sma & sma & sma & sma;

	sma_out <= sma;

   sdcard_cs <= cs;
   sdcard_mosi <= mosi;
   sdcard_sclk <= sclk;
   miso <= sdcard_miso;

   sdcard2_cs <= cs2;
   sdcard2_mosi <= mosi2;
   sdcard2_sclk <= sclk2;
   miso2 <= sdcard2_miso;

   addr_match <= '1' when addr(21 downto 15) = "0000000" else '0';

   process(sma, addr_match)
   begin
      if sma = '0' and sma'event then
         dati(7 downto 0) <= meme(conv_integer(addr(14 downto 1)));
         dati(15 downto 8) <= memo(conv_integer(addr(14 downto 1)));

         if addr_match = '1' and control_dato = '1' then
            if control_datob = '0' or (control_datob = '1' and addr(0) = '0') then
               meme(conv_integer(addr(14 downto 1))) <= dato(7 downto 0);
            end if;
            if control_datob = '0' or (control_datob = '1' and addr(0) = '1') then
               memo(conv_integer(addr(14 downto 1))) <= dato(15 downto 8);
            end if;
         end if;
      end if;
   end process;

end implementation;

