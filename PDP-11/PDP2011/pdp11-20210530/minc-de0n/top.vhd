
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

entity top is
   port(
      -- console serial port
      rx : in std_logic;
      tx : out std_logic;
      cts : in std_logic;
      rts : out std_logic;
      -- second serial port
      rx1: in std_logic;
      tx1: out std_logic;

      -- sd card
      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

      -- enc424j600 backend for xu
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;
		xu_debug_tx : out std_logic;

      -- pidp11 console
      panel_xled : out std_logic_vector(5 downto 0);
      panel_col : inout std_logic_vector(11 downto 0);
      panel_row : out std_logic_vector(2 downto 0);

      -- dram
      dram_addr : out std_logic_vector(12 downto 0);
      dram_dq : inout std_logic_vector(15 downto 0);
      dram_ba_1 : out std_logic;
      dram_ba_0 : out std_logic;
      dram_udqm : out std_logic;
      dram_ldqm : out std_logic;
      dram_ras_n : out std_logic;
      dram_cas_n : out std_logic;
      dram_cke : out std_logic;
      dram_clk : out std_logic;
      dram_we_n : out std_logic;
      dram_cs_n : out std_logic;

      -- pmodda2
      da2_dina0 : out std_logic;
      da2_dinb0 : out std_logic;
      da2_sclk0 : out std_logic;
      da2_sync0 : out std_logic;

      -- pmodda2
      da4_cs : out std_logic;
      da4_mosi : out std_logic;
      da4_sclk : out std_logic;

      -- pmodhygro
      hg_scl : inout std_logic;
      hg_sda : inout std_logic;

      -- pmodcolor
      co_scl : inout std_logic;
      co_sda : inout std_logic;

      -- pmodnav
      nv_csag : out std_logic;                   -- cs acc/gyro
      nv_mosi : out std_logic;
      nv_miso : in std_logic;
      nv_sclk : out std_logic;
      nv_csm : out std_logic;                    -- cs magnetometer
      nv_csa : out std_logic;                    -- cs altimeter

      -- board peripherals
      adc_cs_n : out std_logic;
      adc_saddr : out std_logic;
      adc_sdat : in std_logic;
      adc_sclk : out std_logic;

      adxl345_scl : inout std_logic;
      adxl345_sda : inout std_logic;
      adxl345_cs : out std_logic;

      sw : in std_logic_vector(3 downto 0);
      greenled : out std_logic_vector(7 downto 0);
      key0 : in std_logic;
      key1 : in std_logic;
      clkin : in std_logic
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
      rl_sdcard_cs : out std_logic;
      rl_sdcard_mosi : out std_logic;
      rl_sdcard_sclk : out std_logic;
      rl_sdcard_miso : in std_logic := '0';
      rl_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- rk controller
      have_rk : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      have_rk_num : in integer range 1 to 8 := 8;                    -- active number of drives on the controller; set to < 8 to save core
      rk_sdcard_cs : out std_logic;
      rk_sdcard_mosi : out std_logic;
      rk_sdcard_sclk : out std_logic;
      rk_sdcard_miso : in std_logic := '0';
      rk_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- rh controller
      have_rh : in integer range 0 to 1 := 0;                        -- enable conditional compilation
      rh_sdcard_cs : out std_logic;
      rh_sdcard_mosi : out std_logic;
      rh_sdcard_sclk : out std_logic;
      rh_sdcard_miso : in std_logic := '0';
      rh_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights
      rh_type : in integer range 1 to 7 := 6;

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

-- dr11c, universal interface

      have_dr11c : in integer range 0 to 1 := 0;                     -- conditional compilation
      have_dr11c_loopback : in integer range 0 to 1 := 0;            -- for testing only - zdrc
      have_dr11c_signal_stretch : in integer range 0 to 127 := 7;    -- the signals ndr*, dxm, init will be stretched to this many cpu cycles

      dr11c_in : in std_logic_vector(15 downto 0) := (others => '0');
      dr11c_out : out std_logic_vector(15 downto 0);
      dr11c_reqa : in std_logic := '0';
      dr11c_reqb : in std_logic := '0';
      dr11c_csr0 : out std_logic;
      dr11c_csr1 : out std_logic;
      dr11c_ndr : out std_logic;                                     -- new data ready : dr11c_out has new data
      dr11c_ndrlo : out std_logic;                                   -- new data ready : dr11c_out(7 downto 0) has new data
      dr11c_ndrhi : out std_logic;                                   -- new data ready : dr11c_out(15 downto 8) has new data
      dr11c_dxm : out std_logic;                                     -- data transmitted : dr11c_in data has been read by the cpu
      dr11c_init : out std_logic;                                    -- unibus reset propagated out to the user device

-- minc-11

      have_mncad : in integer range 0 to 1 := 0;                     -- mncad: a/d, max one card in a system
      have_mnckw : in integer range 0 to 2 := 0;                     -- mnckw: clock, either one or two
      have_mncaa : in integer range 0 to 4 := 0;                     -- mncaa: d/a
      have_mncdi : in integer range 0 to 4 := 0;                     -- mncdi: digital in
      have_mncdo : in integer range 0 to 4 := 0;                     -- mncdo: digital out
      ad_start : out std_logic;                                      -- interface from mncad to a/d hardware : '1' signals to start converting
      ad_done : in std_logic := '1';                                 -- interface from mncad to a/d hardware : '1' signals to the mncad that the a/d has completed a conversion
      ad_channel : out std_logic_vector(5 downto 0);                 -- interface from mncad to a/d hardware : the channel number for the current command
      ad_nxc : in std_logic := '1';                                  -- interface from mncad to a/d hardware : '1' signals to the mncad that the required channel does not exist
      ad_sample : in std_logic_vector(11 downto 0) := "000000000000";-- interface from mncad to a/d hardware : the value of the last sample
      kw_st1in : in std_logic := '0';                                -- mnckw0 st1 signal input, active on rising edge
      kw_st2in : in std_logic := '0';                                -- mnckw0 st2 signal input, active on rising edge
      kw_st1out : out std_logic;                                     -- mnckw0 st1 output pulse - actually : copy of the st1flag in the csr
      kw_st2out : out std_logic;                                     -- mnckw0 st2 output pulse
      kw_clkov : out std_logic;                                      -- mnckw0 clkovf output pulse
      da_dac0 : out std_logic_vector(11 downto 0);                   -- da channel 0 - 1st mncaa unit
      da_dac1 : out std_logic_vector(11 downto 0);                   -- da channel 1
      da_dac2 : out std_logic_vector(11 downto 0);                   -- da channel 2
      da_dac3 : out std_logic_vector(11 downto 0);                   -- da channel 3
      da_dac4 : out std_logic_vector(11 downto 0);                   -- da channel 4 - 2nd mncaa unit
      da_dac5 : out std_logic_vector(11 downto 0);                   -- da channel 5
      da_dac6 : out std_logic_vector(11 downto 0);                   -- da channel 6
      da_dac7 : out std_logic_vector(11 downto 0);                   -- da channel 7
      da_dac8 : out std_logic_vector(11 downto 0);                   -- da channel 8 - 3rd mncaa unit
      da_dac9 : out std_logic_vector(11 downto 0);                   -- da channel 9
      da_dac10 : out std_logic_vector(11 downto 0);                  -- da channel 10
      da_dac11 : out std_logic_vector(11 downto 0);                  -- da channel 11
      da_dac12 : out std_logic_vector(11 downto 0);                  -- da channel 12 - 4th mncaa unit
      da_dac13 : out std_logic_vector(11 downto 0);                  -- da channel 13
      da_dac14 : out std_logic_vector(11 downto 0);                  -- da channel 14
      da_dac15 : out std_logic_vector(11 downto 0);                  -- da channel 15
      have_diloopback : in integer range 0 to 1 := 0;                -- set to 1 to loop back mncdo0 to mncdi0 internally for testing
      di_dir0 : in std_logic_vector(15 downto 0) := "0000000000000000";    -- mncdi0 data input register
      di_strobe0 : in std_logic := '0';                              -- strobe
      di_reply0 : out std_logic;                                     -- reply
      di_pgmout0 : out std_logic;                                    -- pgmout
      di_event0 : out std_logic;                                     -- event
      di_dir1 : in std_logic_vector(15 downto 0) := "0000000000000000";    -- mncdi1 data input register
      di_strobe1 : in std_logic := '0';                              -- strobe
      di_reply1 : out std_logic;                                     -- reply
      di_pgmout1 : out std_logic;                                    -- pgmout
      di_event1 : out std_logic;                                     -- event
      di_dir2 : in std_logic_vector(15 downto 0) := "0000000000000000";    -- mncdi2 data input register
      di_strobe2 : in std_logic := '0';                              -- strobe
      di_reply2 : out std_logic;                                     -- reply
      di_pgmout2 : out std_logic;                                    -- pgmout
      di_event2 : out std_logic;                                     -- event
      di_dir3 : in std_logic_vector(15 downto 0) := "0000000000000000";    -- mncdi3 data input register
      di_strobe3 : in std_logic := '0';                              -- strobe
      di_reply3 : out std_logic;                                     -- reply
      di_pgmout3 : out std_logic;                                    -- pgmout
      di_event3 : out std_logic;                                     -- event
      do_dor0 : out std_logic_vector(15 downto 0);                   -- mncdo unit 0 data output
      do_hb_strobe0 : out std_logic;                                 -- mncdo unit 0 high byte strobe
      do_lb_strobe0 : out std_logic;                                 -- mncdo unit 0 low byte strobe
      do_reply0 : in std_logic := '0';                               -- mncdo unit 0 reply input
      do_dor1 : out std_logic_vector(15 downto 0);                   -- mncdo unit 1 data output
      do_hb_strobe1 : out std_logic;                                 -- mncdo unit 1 high byte strobe
      do_lb_strobe1 : out std_logic;                                 -- mncdo unit 1 low byte strobe
      do_reply1 : in std_logic := '0';                               -- mncdo unit 1 reply input
      do_dor2 : out std_logic_vector(15 downto 0);                   -- mncdo unit 2 data output
      do_hb_strobe2 : out std_logic;                                 -- mncdo unit 2 high byte strobe
      do_lb_strobe2 : out std_logic;                                 -- mncdo unit 2 low byte strobe
      do_reply2 : in std_logic := '0';                               -- mncdo unit 2 reply input
      do_dor3 : out std_logic_vector(15 downto 0);                   -- mncdo unit 3 data output
      do_hb_strobe3 : out std_logic;                                 -- mncdo unit 3 high byte strobe
      do_lb_strobe3 : out std_logic;                                 -- mncdo unit 3 low byte strobe
      do_reply3 : in std_logic := '0';                               -- mncdo unit 3 reply input

-- cpu console, switches and display register
      have_csdr : in integer range 0 to 1 := 1;

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

-- console
      cons_load : in std_logic := '0';
      cons_exa : in std_logic := '0';
      cons_dep : in std_logic := '0';
      cons_cont : in std_logic := '0';                               -- continue, pulse '1'
      cons_ena : in std_logic := '1';                                -- ena/halt, '1' is enable
      cons_start : in std_logic := '0';
      cons_sw : in std_logic_vector(21 downto 0) := (others => '0');
      cons_adss_mode : in std_logic_vector(1 downto 0) := (others => '0');
      cons_adss_id : in std_logic := '0';
      cons_adss_cons : in std_logic := '0';
      cons_consphy : out std_logic_vector(21 downto 0);
      cons_progphy : out std_logic_vector(21 downto 0);
      cons_br : out std_logic_vector(15 downto 0);
      cons_shfr : out std_logic_vector(15 downto 0);
      cons_maddr : out std_logic_vector(15 downto 0);                -- microcode address fpu/cpu
      cons_dr : out std_logic_vector(15 downto 0);
      cons_parh : out std_logic;
      cons_parl : out std_logic;

      cons_adrserr : out std_logic;
      cons_run : out std_logic;                                      -- '1' if executing instructions (incl wait)
      cons_pause : out std_logic;                                    -- '1' if bus has been relinquished to npr
      cons_master : out std_logic;                                   -- '1' if cpu is bus master and not running
      cons_kernel : out std_logic;                                   -- '1' if kernel mode
      cons_super : out std_logic;                                    -- '1' if super mode
      cons_user : out std_logic;                                     -- '1' if user mode
      cons_id : out std_logic;                                       -- '0' if instruction, '1' if data AND data mapping is enabled in the mmu
      cons_map16 : out std_logic;                                    -- '1' if 16-bit mapping
      cons_map18 : out std_logic;                                    -- '1' if 18-bit mapping
      cons_map22 : out std_logic;                                    -- '1' if 22-bit mapping

-- clocks and reset
      clk : in std_logic;                                            -- cpu clock
      clk50mhz : in std_logic;                                       -- 50Mhz clock for peripherals
      reset : in std_logic                                           -- active '1' synchronous reset
   );
end component;

component paneldriver is
   port(
      panel_xled : out std_logic_vector(5 downto 0);
      panel_col : inout std_logic_vector(11 downto 0);
      panel_row : out std_logic_vector(2 downto 0);

      cons_load : out std_logic;
      cons_exa : out std_logic;
      cons_dep : out std_logic;
      cons_cont : out std_logic;
      cons_ena : out std_logic;
      cons_inst : out std_logic;
      cons_start : out std_logic;
      cons_sw : out std_logic_vector(21 downto 0);
      cons_adss_mode : out std_logic_vector(1 downto 0);
      cons_adss_id : out std_logic;
      cons_adss_cons : out std_logic;

      cons_consphy : in std_logic_vector(21 downto 0);
      cons_progphy : in std_logic_vector(21 downto 0);
      cons_shfr : in std_logic_vector(15 downto 0);
      cons_maddr : in std_logic_vector(15 downto 0);                 -- microcode address fpu/cpu
      cons_br : in std_logic_vector(15 downto 0);
      cons_dr : in std_logic_vector(15 downto 0);
      cons_parh : in std_logic;
      cons_parl : in std_logic;

      cons_adrserr : in std_logic;
      cons_run : in std_logic;
      cons_pause : in std_logic;
      cons_master : in std_logic;
      cons_kernel : in std_logic;
      cons_super : in std_logic;
      cons_user : in std_logic;
      cons_id : in std_logic;
      cons_map16 : in std_logic;
      cons_map18 : in std_logic;
      cons_map22 : in std_logic;

      sample_cycles : in std_logic_vector(15 downto 0) := x"0400";   -- a sample is this many runs of the panel state machine (which has 16 cycles, so multiply by that)
      minon_cycles : in std_logic_vector(15 downto 0) := x"0400";    -- if a signal has been on for this many cycles in a sample, then the corresponding output will be on - note 16, above.

      paneltype : in integer range 0 to 3 := 0;                      -- 0 - no console; 1 - PiDP11, regular; 2 - PiDP11, widdershins; 3 - PDP2011 nanocons

      cons_reset : out std_logic;                                    -- a request for a reset from the console

      clkin : in std_logic;
      reset : in std_logic
   );
end component;

component de0nadc is
   port(
      ad_start : in std_logic;
      ad_done : out std_logic := '0';
      ad_channel : in std_logic_vector(5 downto 0);
      ad_nxc : out std_logic := '0';
      ad_sample : out std_logic_vector(11 downto 0) := "000000000000";

      ad_ch8 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch9 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch10 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch11 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch12 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch13 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch14 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch15 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch16 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch17 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch18 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch19 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch20 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch21 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch22 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch23 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch24 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch25 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch26 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch27 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch28 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch29 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch30 : in std_logic_vector(11 downto 0) := "000000000000";
      ad_ch31 : in std_logic_vector(11 downto 0) := "000000000000";

      adc_cs_n : out std_logic;
      adc_saddr : out std_logic;
      adc_sdat : in std_logic;
      adc_sclk : out std_logic;

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end component;

component de0nadxl345 is
   port(
      -- de0n adxl345
      adxl345_scl : inout std_logic;
      adxl345_sda : inout std_logic;
      adxl345_cs : out std_logic;

      adxl345_x0 : out std_logic_vector(7 downto 0);
      adxl345_x1 : out std_logic_vector(7 downto 0);
      adxl345_y0 : out std_logic_vector(7 downto 0);
      adxl345_y1 : out std_logic_vector(7 downto 0);
      adxl345_z0 : out std_logic_vector(7 downto 0);
      adxl345_z1 : out std_logic_vector(7 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end component;

component pmodda2 is
   port(
      da_daca : in std_logic_vector(11 downto 0);
      da_dacb : in std_logic_vector(11 downto 0);

      da_sync : out std_logic;
      da_dina : out std_logic;
      da_dinb : out std_logic;
      da_sclk : out std_logic;

      reset : in std_logic;
      clk : in std_logic
    );
end component;

component pmodda4 is
   port(
      da_daca : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacb : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacc : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacd : in std_logic_vector(11 downto 0) := "000000000000";
      da_dace : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacf : in std_logic_vector(11 downto 0) := "000000000000";
      da_dacg : in std_logic_vector(11 downto 0) := "000000000000";
      da_dach : in std_logic_vector(11 downto 0) := "000000000000";

      da_cs : out std_logic;
      da_mosi : out std_logic;
      da_sclk : out std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end component;

component pmodhygro is
   port(
      -- pmodhygro
      hg_scl : inout std_logic;
      hg_sda : inout std_logic;

      hg_rh : out std_logic_vector(13 downto 0);
      hg_temp : out std_logic_vector(13 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end component;

component pmodcolor is
   port(
      -- pmodcolor
      co_scl : inout std_logic;
      co_sda : inout std_logic;

      co_clear : out std_logic_vector(15 downto 0);
      co_red : out std_logic_vector(15 downto 0);
      co_green : out std_logic_vector(15 downto 0);
      co_blue : out std_logic_vector(15 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end component;

component pmodnav is
   port(
      nv_csag : out std_logic;                   -- cs acc/gyro
      nv_mosi : out std_logic;
      nv_miso : in std_logic;
      nv_sclk : out std_logic;
      nv_csm : out std_logic;                    -- cs magnetometer
      nv_csa : out std_logic;                    -- cs altimeter

      nv_temp : out std_logic_vector(11 downto 0);         -- divide by 30, add to 42.5 (signed arithmetic!) to get temp
      nv_pressure : out std_logic_vector(11 downto 0);     -- pressure in mbar/hPa
      nv_pressure_f : out std_logic_vector(11 downto 0);   -- pressure fraction

      nv_xlt : out std_logic_vector(11 downto 0);
      nv_xlx : out std_logic_vector(11 downto 0);
      nv_xly : out std_logic_vector(11 downto 0);
      nv_xlz : out std_logic_vector(11 downto 0);
      nv_gx : out std_logic_vector(11 downto 0);
      nv_gy : out std_logic_vector(11 downto 0);
      nv_gz : out std_logic_vector(11 downto 0);
      nv_mx : out std_logic_vector(11 downto 0);
      nv_my : out std_logic_vector(11 downto 0);
      nv_mz : out std_logic_vector(11 downto 0);

      reset : in std_logic;
      clk : in std_logic
   );
end component;

component pll is
   port(
      inclk0 : in std_logic := '0';
      c0 : out std_logic
   );
end component;

component issp
   port(
      source : out std_logic_vector(15 downto 0)
   );
end component;

component issplim
   port(
      source : out std_logic_vector(15 downto 0)
   );
end component;


signal c0 : std_logic;

signal reset: std_logic;
signal cpuclk : std_logic := '0';
signal cpureset : std_logic := '1';
signal cpuresetlength : integer range 0 to 63 := 63;

signal ifetch: std_logic;
signal cpu_addr_v : std_logic_vector(15 downto 0);
signal txtx : std_logic;
signal rxrx : std_logic;
signal txtx1 : std_logic;
signal rxrx1 : std_logic;

signal ad_start : std_logic;
signal ad_done : std_logic;
signal ad_channel : std_logic_vector(5 downto 0);
signal ad_nxc : std_logic;
signal ad_sample : std_logic_vector(11 downto 0);

signal hg_rh : std_logic_vector(13 downto 0);
signal hg_temp : std_logic_vector(13 downto 0);
signal co_clear : std_logic_vector(15 downto 0);
signal co_red : std_logic_vector(15 downto 0);
signal co_green : std_logic_vector(15 downto 0);
signal co_blue : std_logic_vector(15 downto 0);

signal nv_temp : std_logic_vector(11 downto 0);
signal nv_pressure : std_logic_vector(11 downto 0);
signal nv_pressure_f : std_logic_vector(11 downto 0);

signal da_dac0 : std_logic_vector(11 downto 0);
signal da_dac1 : std_logic_vector(11 downto 0);
signal da_dac2 : std_logic_vector(11 downto 0);
signal da_dac3 : std_logic_vector(11 downto 0);
signal da_dac4 : std_logic_vector(11 downto 0);
signal da_dac5 : std_logic_vector(11 downto 0);
signal da_dac6 : std_logic_vector(11 downto 0);
signal da_dac7 : std_logic_vector(11 downto 0);

signal sddebug : std_logic_vector(3 downto 0);

signal addr : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;

signal cons_load : std_logic;
signal cons_exa : std_logic;
signal cons_dep : std_logic;
signal cons_cont : std_logic;
signal cons_ena : std_logic;
signal cons_start : std_logic;
signal cons_sw : std_logic_vector(21 downto 0);
signal cons_adss_mode : std_logic_vector(1 downto 0);
signal cons_adss_id : std_logic;
signal cons_adss_cons : std_logic;

signal cons_consphy : std_logic_vector(21 downto 0);
signal cons_progphy : std_logic_vector(21 downto 0);
signal cons_br : std_logic_vector(15 downto 0);
signal cons_shfr : std_logic_vector(15 downto 0);
signal cons_maddr : std_logic_vector(15 downto 0);
signal cons_dr : std_logic_vector(15 downto 0);
signal cons_parh : std_logic;
signal cons_parl : std_logic;

signal cons_adrserr : std_logic;
signal cons_run : std_logic;
signal cons_pause : std_logic;
signal cons_master : std_logic;
signal cons_kernel : std_logic;
signal cons_super : std_logic;
signal cons_user : std_logic;
signal cons_id : std_logic;
signal cons_map16 : std_logic;
signal cons_map18 : std_logic;
signal cons_map22 : std_logic;

signal cons_reset : std_logic;

signal sample_cycles : std_logic_vector(15 downto 0) := x"0400";
signal minon_cycles : std_logic_vector(15 downto 0) := x"0400";


signal dram_match : std_logic;
signal dram_counter : integer range 0 to 32767;
signal dram_wait : integer range 0 to 15;

signal dram_refresh_count : integer range 0 to 255;


type dram_fsm_type is (
   dram_init,
   dram_poweron,
   dram_pwron_pre, dram_pwron_prew,
   dram_pwron_ref, dram_pwron_refw,
   dram_pwron_mrs, dram_pwron_mrsw,
   dram_c1,
   dram_c2,
   dram_c3,
   dram_c4,
   dram_c5,
   dram_c6,
   dram_c7,
   dram_c8,
   dram_c9,
   dram_c10,
   dram_c11,
   dram_c12,
   dram_c13,
   dram_c14,
   dram_idle
);
signal dram_fsm : dram_fsm_type := dram_init;

begin

--  issp0: issp port map(
--     source => sample_cycles
--  );
--  issp1: issplim port map(
--     source => minon_cycles
--  );

   pll0: pll port map(
      inclk0 => clkin,
      c0 => c0
   );

   adc0: de0nadc port map(
      ad_start => ad_start,
      ad_done => ad_done,
      ad_channel => ad_channel,
      ad_nxc => ad_nxc,
      ad_sample => ad_sample,

      ad_ch8 => hg_rh(13 downto 2),
      ad_ch9 => hg_temp(13 downto 2),
      ad_ch10 => co_clear(15 downto 4),
      ad_ch11 => co_red(15 downto 4),
      ad_ch12 => co_green(15 downto 4),
      ad_ch13 => co_blue(15 downto 4),
      ad_ch14 => nv_pressure_f,
      ad_ch15 => nv_pressure,

      adc_cs_n => adc_cs_n,
      adc_saddr => adc_saddr,
      adc_sdat => adc_sdat,
      adc_sclk => adc_sclk,

      reset => cpureset,
      clk50mhz => clkin
   );

   adxl0: de0nadxl345 port map(
      -- de0n adxl345
      adxl345_scl => adxl345_scl,
      adxl345_sda => adxl345_sda,
      adxl345_cs => adxl345_cs,

      reset => cpureset,
      clk50mhz => clkin
   );

   dac0: pmodda4 port map(
      da_daca => da_dac0,
      da_dacb => da_dac1,
      da_dacc => da_dac2,
      da_dacd => da_dac3,
      da_dace => da_dac4,
      da_dacf => da_dac5,
      da_dacg => da_dac6,
      da_dach => da_dac7,

      da_cs => da4_cs,
      da_mosi => da4_mosi,
      da_sclk => da4_sclk,

      reset => reset,
      clk => cpuclk
   );

   hg0: pmodhygro port map(
      hg_scl => hg_scl,
      hg_sda => hg_sda,
      hg_rh => hg_rh,
      hg_temp => hg_temp,
      reset => cpureset,
      clk50mhz => clkin
   );

   co0: pmodcolor port map(
      co_scl => co_scl,
      co_sda => co_sda,
      co_clear => co_clear,
      co_red => co_red,
      co_green => co_green,
      co_blue => co_blue,
      reset => cpureset,
      clk50mhz => clkin
   );

   nv0: pmodnav port map(
      nv_csag => nv_csag,
      nv_mosi => nv_mosi,
      nv_miso => nv_miso,
      nv_sclk => nv_sclk,
      nv_csm => nv_csm,
      nv_csa => nv_csa,

      nv_temp => nv_temp,
      nv_pressure => nv_pressure,
      nv_pressure_f => nv_pressure_f,

      reset => reset,
      clk => cpuclk
   );

--   c0 <= clkin;

   pdp11: unibus port map(
      modelcode => 23,

      have_mncad => 1,
      have_mnckw => 2,
      have_mncaa => 4,
      have_mncdi => 4,
      have_mncdo => 4,
      have_diloopback => 0,

      ad_start => ad_start,
      ad_done => ad_done,
      ad_channel => ad_channel,
      ad_nxc => ad_nxc,
      ad_sample => ad_sample,
      da_dac0 => da_dac0,
      da_dac1 => da_dac1,
      da_dac2 => da_dac2,
      da_dac3 => da_dac3,
      da_dac4 => da_dac4,
      da_dac5 => da_dac5,
      da_dac6 => da_dac6,
      da_dac7 => da_dac7,

      have_kl11 => 1,
      tx0 => txtx,
      rx0 => rxrx,
      cts0 => cts,
      rts0 => rts,
      kl0_bps => 9600,
      kl0_force7bit => 1,
      kl0_rtscts => 1,

      tx1 => txtx1,
      rx1 => rxrx1,
      kl1_bps => 9600,
      kl1_force7bit => 1,

      have_rl => 1,
      rl_sdcard_cs => sdcard_cs,
      rl_sdcard_mosi => sdcard_mosi,
      rl_sdcard_sclk => sdcard_sclk,
      rl_sdcard_miso => sdcard_miso,
      rl_sdcard_debug => sddebug,

      cons_load => cons_load,
      cons_exa => cons_exa,
      cons_dep => cons_dep,
      cons_cont => cons_cont,
      cons_ena => cons_ena,
      cons_start => cons_start,
      cons_sw => cons_sw,
      cons_adss_mode => cons_adss_mode,
      cons_adss_id => cons_adss_id,
      cons_adss_cons => cons_adss_cons,

      cons_consphy => cons_consphy,
		cons_progphy => cons_progphy,
      cons_shfr => cons_shfr,
      cons_maddr => cons_maddr,
      cons_br => cons_br,
      cons_dr => cons_dr,
      cons_parh => cons_parh,
      cons_parl => cons_parl,

      cons_adrserr => cons_adrserr,
      cons_run => cons_run,
      cons_pause => cons_pause,
      cons_master => cons_master,
      cons_kernel => cons_kernel,
      cons_super => cons_super,
      cons_user => cons_user,
      cons_id => cons_id,
      cons_map16 => cons_map16,
      cons_map18 => cons_map18,
      cons_map22 => cons_map22,

      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => dram_match,

      ifetch => ifetch,
		cpu_addr_v => cpu_addr_v,
      reset => cpureset,
      clk50mhz => clkin,
      clk => cpuclk
   );

   panel: paneldriver port map(
      panel_xled => panel_xled,
      panel_col => panel_col,
      panel_row => panel_row,

      cons_load => cons_load,
      cons_exa => cons_exa,
      cons_dep => cons_dep,
      cons_cont => cons_cont,
      cons_ena => cons_ena,
      cons_start => cons_start,
      cons_sw => cons_sw,
      cons_adss_mode => cons_adss_mode,
      cons_adss_id => cons_adss_id,
      cons_adss_cons => cons_adss_cons,

      cons_consphy => cons_consphy,
      cons_progphy => cons_progphy,
      cons_shfr => cons_shfr,
      cons_maddr => cons_maddr,
      cons_br => cons_br,
      cons_dr => cons_dr,
      cons_parh => cons_parh,
      cons_parl => cons_parl,

      cons_adrserr => cons_adrserr,
      cons_run => cons_run,
      cons_pause => cons_pause,
      cons_master => cons_master,
      cons_kernel => cons_kernel,
      cons_super => cons_super,
      cons_user => cons_user,
      cons_id => cons_id,
      cons_map16 => cons_map16,
      cons_map18 => cons_map18,
      cons_map22 => cons_map22,

      cons_reset => cons_reset,

      sample_cycles => sample_cycles,
      minon_cycles => minon_cycles,

		paneltype => 0,

      clkin => cpuclk,
      reset => reset
   );

   reset <= (not key0);

   tx <= txtx;
	rxrx <= rx;
   tx1 <= txtx1;
   rxrx1 <= rx1;

   greenled <= ifetch & not rxrx & not rxrx1 & not txtx1 & sddebug;

--   dram_match <= '1' when addr(21 downto 13) /= "111111111" else '0';
   dram_match <= '1' when addr(21 downto 18) /= "1111" else '0';
   dram_cke <= '1';
   dram_clk <= c0;

   process(c0, reset)
   begin
      if c0='1' and c0'event then

         if reset = '1' then
            dram_fsm <= dram_init;
            dram_cs_n <= '0';
            dram_ras_n <= '1';
            dram_cas_n <= '1';
            dram_we_n <= '1';
            dram_addr <= (others => '0');

            dram_udqm <= '1';
            dram_ldqm <= '1';
            dram_ba_1 <= '0';
            dram_ba_0 <= '0';

            cpuclk <= '0';
            cpureset <= '1';
            cpuresetlength <= 63;
            dram_refresh_count <= 1;
         else

            case dram_fsm is

               when dram_init =>
                  dram_cs_n <= '0';
                  dram_ras_n <= '1';
                  dram_cas_n <= '1';
                  dram_we_n <= '1';
                  dram_addr <= (others => '0');

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';

                  cpureset <= '1';
                  cpuresetlength <= 63;
                  dram_counter <= 32767;
                  dram_fsm <= dram_poweron;

               when dram_poweron =>
                  dram_cs_n <= '0';
                  dram_ras_n <= '1';
                  dram_cas_n <= '1';
                  dram_we_n <= '1';
                  dram_addr <= (others => '0');

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';

                  if dram_counter = 0 then
                     dram_fsm <= dram_pwron_pre;
                  else
                     dram_counter <= dram_counter - 1;
                  end if;

               when dram_pwron_pre =>
                  dram_cs_n <= '0';
                  dram_ras_n <= '0';
                  dram_cas_n <= '1';
                  dram_we_n <= '0';
                  dram_addr(10) <= '1';

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';
                  dram_addr(12) <= '0';
                  dram_addr(11) <= '0';
                  dram_addr(9 downto 0) <= (others => '0');

                  dram_wait <= 4;
                  dram_fsm <= dram_pwron_prew;

               when dram_pwron_prew =>
                  dram_cs_n <= '1';
                  if dram_wait = 0 then
                     dram_fsm <= dram_pwron_ref;
                     dram_counter <= 20;
                  else
                     dram_wait <= dram_wait - 1;
                  end if;

               when dram_pwron_ref =>
                  dram_cs_n <= '0';
                  dram_ras_n <= '0';
                  dram_cas_n <= '0';
                  dram_we_n <= '1';
                  dram_addr <= (others => '0');

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';

                  dram_wait <= 15;
                  dram_fsm <= dram_pwron_refw;

               when dram_pwron_refw =>
                  dram_cs_n <= '1';
                  if dram_wait = 0 then
                     if dram_counter = 0 then
                        dram_fsm <= dram_pwron_mrs;
                     else
                        dram_counter <= dram_counter - 1;
                        dram_fsm <= dram_pwron_ref;
                     end if;
                  else
                     dram_wait <= dram_wait - 1;
                  end if;

               when dram_pwron_mrs =>
                  dram_cs_n <= '0';
                  dram_ras_n <= '0';
                  dram_cas_n <= '0';
                  dram_we_n <= '0';

                  dram_addr(12 downto 7) <= (others => '0');
                  dram_addr(6 downto 4) <= "011";          -- cas length 3
                  dram_addr(3) <= '0';                     -- sequential
                  dram_addr(2 downto 0) <= "000";          -- length 0

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';

                  dram_wait <= 4;
                  dram_fsm <= dram_pwron_mrsw;

               when dram_pwron_mrsw =>
                  dram_cs_n <= '1';
                  if dram_wait = 0 then
                     dram_fsm <= dram_idle;
                  else
                     dram_wait <= dram_wait - 1;
                  end if;

               when dram_idle =>
                  dram_cs_n <= '1';
                  dram_ras_n <= '1';
                  dram_cas_n <= '1';
                  dram_we_n <= '1';
                  dram_addr(10) <= '0';

                  dram_udqm <= '1';
                  dram_ldqm <= '1';
                  dram_ba_1 <= '0';
                  dram_ba_0 <= '0';
                  dram_addr(12) <= '0';
                  dram_addr(11) <= '0';
                  dram_addr(9 downto 0) <= (others => '0');

                  dram_fsm <= dram_c1;

               when dram_c1 =>

                  if cpuresetlength = 0 then
                     cpureset <= '0';
                  else
                     cpuresetlength <= cpuresetlength - 1;
                  end if;
                  if cons_reset = '1' then
                     cpuresetlength <= 63;
                     cpureset <= '1';
                  end if;

               cpuclk <= '1';

                  dram_fsm <= dram_c2;

               when dram_c2 =>
                  dram_dq <= (others => 'Z');
                  dram_fsm <= dram_c3;

               when dram_c3 =>
                  dram_fsm <= dram_c4;         -- 5, for more agressive timing

               when dram_c4 =>
                  dram_fsm <= dram_c5;

               when dram_c5 =>
                  dram_fsm <= dram_c6;

               when dram_c6 =>
                  -- read, t1-t2

                  if dram_match = '1' and control_dati = '1' then
                     -- activate command
                     dram_cs_n <= '0';
                     dram_ras_n <= '0';
                     dram_cas_n <= '1';
                     dram_we_n <= '1';
                     dram_addr(12) <= '0';
                     dram_addr(11 downto 0) <= addr(20 downto 9);

                     dram_udqm <= '0';
                     dram_ldqm <= '0';
                     dram_ba_1 <= '0';
                     dram_ba_0 <= addr(21);
                  end if;

                  -- write, t1-t2
                  if dram_match = '1' and control_dato = '1' then
                     -- activate command
                     dram_cs_n <= '0';
                     dram_ras_n <= '0';
                     dram_cas_n <= '1';
                     dram_we_n <= '1';
                     dram_addr(12) <= '0';
                     dram_addr(11 downto 0) <= addr(20 downto 9);

                     dram_udqm <= '0';
                     dram_ldqm <= '0';
                     dram_ba_1 <= '0';
                     dram_ba_0 <= addr(21);
                  end if;

                  if dram_match = '0' or (control_dato = '0' and control_dati = '0') then
                     -- auto refresh command
                     if dram_refresh_count = 0 then
                        dram_cs_n <= '0';
                        dram_ras_n <= '0';
                        dram_cas_n <= '0';
                        dram_we_n <= '1';
                        dram_refresh_count <= 255;
                     else
                        dram_refresh_count <= dram_refresh_count - 1;
                     end if;
                  end if;

                  dram_fsm <= dram_c7;

               when dram_c7 =>
                  -- t2-t3 - set nop command
                  dram_cs_n <= '1';
                  dram_ras_n <= '1';
                  dram_cas_n <= '1';
                  dram_we_n <= '1';

                  dram_fsm <= dram_c8;

               when dram_c8 =>

                  -- read, t3-t4
                  if dram_match = '1' and control_dati = '1' then
                     -- reada command
                     dram_cs_n <= '0';
                     dram_ras_n <= '1';
                     dram_cas_n <= '0';
                     dram_we_n <= '1';
                     dram_addr(12) <= '0';
                     dram_addr(11) <= '0';
                     dram_addr(10) <= '1';
                     dram_addr(9) <= '1';
                     dram_addr(8) <= '0';
                     dram_addr(7 downto 0) <= addr(8 downto 1);

                     dram_udqm <= '0';
                     dram_ldqm <= '0';
                     dram_ba_1 <= '0';
                     dram_ba_0 <= addr(21);
                  end if;

                  -- write, t3-t4
                  if dram_match = '1' and control_dato = '1' then
                     -- writea command
                     dram_cs_n <= '0';
                     dram_ras_n <= '1';
                     dram_cas_n <= '0';
                     dram_we_n <= '0';
                     dram_addr(12) <= '0';
                     dram_addr(11) <= '0';
                     dram_addr(10) <= '1';
                     dram_addr(9) <= '1';
                     dram_addr(8) <= '0';
                     dram_addr(7 downto 0) <= addr(8 downto 1);
                     dram_udqm <= '0';
                     dram_ldqm <= '0';
                     if control_datob = '1' then
                        if addr(0) = '0' then
                           dram_udqm <= '1';
                        else
                           dram_ldqm <= '1';
                        end if;
                     end if;
                     dram_ba_1 <= '0';
                     dram_ba_0 <= addr(21);
                     dram_dq <= dato;
                  end if;

                  dram_fsm <= dram_c9;

               cpuclk <= '0';

               when dram_c9 =>

                  -- read/write, t4-t5 - set nop command and deselect
                  dram_cs_n <= '1';
                  dram_ras_n <= '1';
                  dram_cas_n <= '1';
                  dram_we_n <= '1';

                  dram_fsm <= dram_c10;

               when dram_c10 =>
                  dram_fsm <= dram_c11;

               when dram_c11 =>
                  dram_fsm <= dram_c12;

               when dram_c12 =>
                  dram_fsm <= dram_c13;

               when dram_c13 =>
                  -- read, t5-t6
                  if dram_match = '1' and control_dati = '1' then
                     dati <= dram_dq;
                  end if;
                  dram_fsm <= dram_c14;

               when dram_c14 =>
                  dram_fsm <= dram_c1;

               when others =>
                  null;

            end case;

         end if;
      end if;
   end process;

end implementation;

