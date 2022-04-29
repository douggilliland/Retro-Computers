
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

      -- ssram
      sram_addr : out std_logic_vector(18 downto 0);
      sram_dq : inout std_logic_vector(31 downto 0);
      sram_adsc_n : out std_logic;
      sram_adsp_n : out std_logic;
      sram_adv_n : out std_logic;
      sram_be_n0 : out std_logic;
      sram_be_n1 : out std_logic;
      sram_be_n2 : out std_logic;
      sram_be_n3 : out std_logic;
      sram_ce1_n : out std_logic;
      sram_ce2 : out std_logic;
      sram_ce3_n : out std_logic;
      sram_clk : out std_logic;
      sram_dpa0 : out std_logic;
      sram_dpa1 : out std_logic;
      sram_dpa2 : out std_logic;
      sram_dpa3 : out std_logic;
      sram_gw_n : out std_logic;
      sram_oe_n : out std_logic;
      sram_we_n : out std_logic;

      -- board peripherals
      greenled : out std_logic_vector(8 downto 0);
      redled : out std_logic_vector(17 downto 0);

      sseg7 : out std_logic_vector(6 downto 0);
      sseg7dp : out std_logic;
      sseg6 : out std_logic_vector(6 downto 0);
      sseg6dp : out std_logic;
      sseg5 : out std_logic_vector(6 downto 0);
      sseg5dp : out std_logic;
      sseg4 : out std_logic_vector(6 downto 0);
      sseg4dp : out std_logic;
      sseg3 : out std_logic_vector(6 downto 0);
      sseg3dp : out std_logic;
      sseg2 : out std_logic_vector(6 downto 0);
      sseg2dp : out std_logic;
      sseg1 : out std_logic_vector(6 downto 0);
      sseg1dp : out std_logic;
      sseg0 : out std_logic_vector(6 downto 0);
      sseg0dp : out std_logic;

      sw : in std_logic_vector(17 downto 0);

      key3 : in std_logic;
      key2 : in std_logic;
      key1 : in std_logic;
      key0 : in std_logic;
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

      sample_cycles : in std_logic_vector(15 downto 0) := x"0400";
      minon_cycles : in std_logic_vector(15 downto 0) := x"0400";

      clkin : in std_logic;
      reset : in std_logic
   );
end component;

component ssegdecoder is
	port(
		i : in std_logic_vector(3 downto 0);
		idle : in std_logic;
		u : out std_logic_vector(6 downto 0)
	);
end component;

component pll is
   port(
      inclk0 : in std_logic  := '0';
      c0 : out std_logic
   );
end component;


-- signal clk : std_logic;

type clk_fsm_type is (
   clk_idle,
   clk_n,
   clk_ne,
   clk_e,
   clk_se,
   clk_s,
   clk_sw,
   clk_w,
   clk_nw
);
signal clk_fsm : clk_fsm_type := clk_idle;


signal power_on_reset : std_logic := '1';

signal c0 : std_logic;

signal reset : std_logic;
signal cpuclk : std_logic := '0';
signal cpureset : std_logic := '1';
signal cpuresetlength : integer range 0 to 4095 := 4095;
signal slowreset : std_logic;
signal slowresetdelay : integer range 0 to 4095 := 4095;

signal ifetch: std_logic;
signal iwait: std_logic;
signal txtx : std_logic;
signal rxrx : std_logic;
signal txtx1 : std_logic;
signal rxrx1 : std_logic;

signal have_rl : integer range 0 to 1;
signal rl_cs : std_logic;
signal rl_mosi : std_logic;
signal rl_miso : std_logic;
signal rl_sclk : std_logic;
signal rl_sddebug : std_logic_vector(3 downto 0);

signal have_rk : integer range 0 to 1;
signal rk_cs : std_logic;
signal rk_mosi : std_logic;
signal rk_miso : std_logic;
signal rk_sclk : std_logic;
signal rk_sddebug : std_logic_vector(3 downto 0);

signal have_rh : integer range 0 to 1;
signal rh_cs : std_logic;
signal rh_mosi : std_logic;
signal rh_miso : std_logic;
signal rh_sclk : std_logic;
signal rh_sddebug : std_logic_vector(3 downto 0);

signal sddebug : std_logic_vector(3 downto 0);

signal addr : std_logic_vector(21 downto 0);
signal addrq : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;

signal sram_match : std_logic;
signal sram_ce_n : std_logic;
signal data_valid : std_logic;

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

signal sample_cycles : std_logic_vector(15 downto 0) := x"0400";
signal minon_cycles : std_logic_vector(15 downto 0) := x"0400";


begin

   pll0: pll port map(
      inclk0 => clkin,
      c0 => c0
   );

--   c0 <= clkin;

   have_rh <= 1; have_rl <= 0; have_rk <= 0;

   pdp11: unibus port map(
      modelcode => 70,

      have_kl11 => 1,
      tx0 => txtx,
      rx0 => rxrx,
      cts0 => cts,
      rts0 => rts,
      kl0_bps => 9600,
      kl0_force7bit => 1,
      kl0_rtscts => 0,

      tx1 => txtx1,
      rx1 => rxrx1,
      kl1_bps => 9600,
      kl1_force7bit => 1,

      have_rl => have_rl,
      rl_sdcard_cs => rl_cs,
      rl_sdcard_mosi => rl_mosi,
      rl_sdcard_sclk => rl_sclk,
      rl_sdcard_miso => rl_miso,
      rl_sdcard_debug => rl_sddebug,

      have_rk => have_rk,
      rk_sdcard_cs => rk_cs,
      rk_sdcard_mosi => rk_mosi,
      rk_sdcard_sclk => rk_sclk,
      rk_sdcard_miso => rk_miso,
      rk_sdcard_debug => rk_sddebug,

      have_rh => have_rh,
      rh_sdcard_cs => rh_cs,
      rh_sdcard_mosi => rh_mosi,
      rh_sdcard_sclk => rh_sclk,
      rh_sdcard_miso => rh_miso,
      rh_sdcard_debug => rh_sddebug,

      have_xu => 0,
      xu_cs => xu_cs,
      xu_mosi => xu_mosi,
      xu_sclk => xu_sclk,
      xu_miso => xu_miso,
      xu_debug_tx => xu_debug_tx,

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
      addr_match => sram_match,

      ifetch => ifetch,
      iwait => iwait,

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

      sample_cycles => sample_cycles,
      minon_cycles => minon_cycles,

      clkin => cpuclk,
      reset => cpureset
   );

   ssegd7: ssegdecoder port map(
      i => '0' & '0' & '0' & addrq(21),
      idle => iwait,
      u => sseg7
   );
   ssegd6: ssegdecoder port map(
      i => '0' & addrq(20 downto 18),
      idle => iwait,
      u => sseg6
   );
   ssegd5: ssegdecoder port map(
      i => '0' & addrq(17 downto 15),
      idle => iwait,
      u => sseg5
   );
   ssegd4: ssegdecoder port map(
      i => '0' & addrq(14 downto 12),
      idle => iwait,
      u => sseg4
   );
   ssegd3: ssegdecoder port map(
		i => '0' & addrq(11 downto 9),
      idle => iwait,
		u => sseg3
	);
   ssegd2: ssegdecoder port map(
		i => '0' & addrq(8 downto 6),
      idle => iwait,
		u => sseg2
	);
   ssegd1: ssegdecoder port map(
		i => '0' & addrq(5 downto 3),
      idle => iwait,
		u => sseg1
	);
   ssegd0: ssegdecoder port map(
		i => '0' & addrq(2 downto 0),
      idle => iwait,
		u => sseg0
	);


   sseg7dp <= '1';
   sseg6dp <= '1';
   sseg5dp <= '1';
   sseg4dp <= '1';
   sseg3dp <= '1';
   sseg2dp <= '1';
   sseg1dp <= '1';
   sseg0dp <= '1';

   redled <= "00" & cons_dr;
   addrq <= cons_consphy;
--   console_switches <= sw(15 downto 0);

   greenled(8) <= ifetch;
	greenled(0) <= '0';

   tx <= txtx;
   rxrx <= rx;
   tx1 <= txtx1;
   rxrx1 <= rx1;

   sddebug <= rh_sddebug when have_rh = 1 else rl_sddebug when have_rl = 1 else rk_sddebug;
   sdcard_cs <= rh_cs when have_rh = 1 else rl_cs when have_rl = 1 else rk_cs;
   sdcard_mosi <= rh_mosi when have_rh = 1 else rl_mosi when have_rl = 1 else rk_mosi;
   sdcard_sclk <= rh_sclk when have_rh = 1 else rl_sclk when have_rl = 1 else rk_sclk;
   rh_miso <= sdcard_miso;
   rl_miso <= sdcard_miso;
   rk_miso <= sdcard_miso;

   sram_match <= '1' when addr(21) = '0' else '0';
   sram_addr <= addr(20 downto 2);

   sram_ce1_n <= sram_ce_n;
   sram_ce2 <= not sram_ce_n;
   sram_ce3_n <= sram_ce_n;

   sram_adv_n <= '1';
   sram_gw_n <= '1';

   sram_dpa3 <= '0';
   sram_dpa2 <= '0';
   sram_dpa1 <= '0';
   sram_dpa0 <= '0';

	reset <= not key0;

   process(c0)
   begin
      if c0='1' and c0'event then
         if reset = '1' or power_on_reset = '1' then
            power_on_reset <= '0';
            cpureset <= '1';
            cpuresetlength <= 4095;
         end if;

         case clk_fsm is

            when clk_n =>
               clk_fsm <= clk_ne;
               sram_clk <= '0';

-- read -- set ce etc
               if sram_match = '1' and control_dati = '1' then
                  sram_ce_n <= '0';
                  sram_adsp_n <= '0';
                  sram_adsc_n <= '0';
               end if;

            when clk_ne =>
               clk_fsm <= clk_e;
               sram_clk <= '1';

            when clk_e =>
               clk_fsm <= clk_se;
               sram_clk <= '0';

-- read -- reset ce etc
               if sram_match = '1' and control_dati = '1' then
                  sram_ce_n <= '1';
                  sram_adsp_n <= '1';
                  sram_adsc_n <= '1';
               end if;

-- write -- set ce etc
               if sram_match = '1' and control_dato = '1' then
                  sram_ce_n <= '0';
                  sram_adsp_n <= '0';
                  sram_adsc_n <= '0';
               end if;

            when clk_se =>
               clk_fsm <= clk_s;
               sram_clk <= '1';

               cpuclk <= '0';
               if cpuresetlength = 0 then
                  cpureset <= '0';
               else
                  cpuresetlength <= cpuresetlength - 1;
               end if;

            when clk_s =>
               clk_fsm <= clk_sw;
               sram_clk <= '0';

               if sram_match = '1' and control_dati = '1' then
                  sram_ce_n <= '0';
                  sram_adsp_n <= '0';
                  sram_adsc_n <= '0';
                  sram_oe_n <= '0';
               end if;

               if sram_match = '1' and control_dato = '1' then
                  sram_ce_n <= '1';
                  sram_adsp_n <= '1';
                  sram_adsc_n <= '1';
                  sram_we_n <= '0';
                  sram_dq(15 downto 0) <= dato;
                  sram_dq(31 downto 16) <= dato;
                  if control_datob = '1' then
                     if addr(1) = '0' then
                        if addr(0) = '0' then
                           sram_be_n3 <= '1';
                           sram_be_n2 <= '1';
                           sram_be_n1 <= '1';
                           sram_be_n0 <= '0';
                        else
                           sram_be_n3 <= '1';
                           sram_be_n2 <= '1';
                           sram_be_n1 <= '0';
                           sram_be_n0 <= '1';
                        end if;
                     else
                        if addr(0) = '0' then
                           sram_be_n3 <= '1';
                           sram_be_n2 <= '0';
                           sram_be_n1 <= '1';
                           sram_be_n0 <= '1';
                        else
                           sram_be_n3 <= '0';
                           sram_be_n2 <= '1';
                           sram_be_n1 <= '1';
                           sram_be_n0 <= '1';
                        end if;
                     end if;
                  else
                     if addr(1) = '0' then
                        sram_be_n3 <= '1';
                        sram_be_n2 <= '1';
                        sram_be_n1 <= '0';
                        sram_be_n0 <= '0';
                     else
                        sram_be_n3 <= '0';
                        sram_be_n2 <= '0';
                        sram_be_n1 <= '1';
                        sram_be_n0 <= '1';
                     end if;
                  end if;
               end if;

            when clk_sw =>
               clk_fsm <= clk_w;
               sram_clk <= '1';

            when clk_w =>
               clk_fsm <= clk_nw;
               sram_clk <= '0';
               if sram_match = '1' and control_dato = '1' then
                  sram_we_n <= '1';
                  sram_be_n3 <= '1';
                  sram_be_n2 <= '1';
                  sram_be_n1 <= '1';
                  sram_be_n0 <= '1';
                  sram_dq(31 downto 16) <= "ZZZZZZZZZZZZZZZZ";
                  sram_dq(15 downto 0) <= "ZZZZZZZZZZZZZZZZ";
               end if;

               if sram_match = '1' and control_dati = '1' then
                  if (addr(1) = '0') then
                     dati <= sram_dq(15 downto 0);
                  else
                     dati <= sram_dq(31 downto 16);
                  end if;
                  sram_oe_n <= '1';
               end if;

            when clk_nw =>
               clk_fsm <= clk_n;
               sram_clk <= '1';

               cpuclk <= '1';

            when clk_idle =>
               clk_fsm <= clk_n;

            when others =>
               null;

         end case;

      end if;
   end process;

end implementation;

