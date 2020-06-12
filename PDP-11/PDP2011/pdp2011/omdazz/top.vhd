
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

-- $Revision: 1.58 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
   port(
      redled : out std_logic_vector(3 downto 0);
      beep : out std_logic;
      sseg0 : out std_logic_vector(0 to 6);
      ssegP : out std_logic;
      Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals

      clkin : in std_logic;

      switch : in std_logic_vector(3 downto 0);

      rx1 : in std_logic;
      tx1 : out std_logic;
      cts1 : in std_logic;
      rts1 : out std_logic;

      rx2: in std_logic;
      tx2: out std_logic;
      cts2 : in std_logic;
      rts2 : out std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

--      panel_xled : out std_logic_vector(5 downto 0);
--      panel_col : inout std_logic_vector(11 downto 0);
--      panel_row : out std_logic_vector(2 downto 0);

-- ethernet, enc424j600 controller interface
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;
      xu_debug_tx : out std_logic;                                   -- rs232, 115200/8/n/1 debug output from microcode

      dram_addr : out std_logic_vector(11 downto 0);
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

      resetbtn : in std_logic;
		enablebtn : in std_logic;

      max7219_load  : out std_logic;
      max7219_data : out std_logic;
      max7219_clock : out std_logic
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
      have_rl : in integer range 0 to 1 := 1;                        -- enable conditional compilation
      have_rl_debug : in integer range 0 to 1 := 1;                  -- enable debug core
      rl_sdcard_cs : out std_logic;
      rl_sdcard_mosi : out std_logic;
      rl_sdcard_sclk : out std_logic;
      rl_sdcard_miso : in std_logic := '0';
      rl_sdcard_debug : out std_logic_vector(3 downto 0);            -- debug/blinkenlights

-- rk controller
      have_rk : in integer range 0 to 1 := 1;                        -- enable conditional compilation
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
      have_kl11 : in integer range 0 to 4 := 2;                      -- conditional compilation - number of kl11 controllers to include. Should normally be at least 1

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
      kl1_bps : in integer range 300 to 230400 := 2400;              -- note: 300 bps now possible
      kl1_force7bit : in integer range 0 to 1 := 0;
      kl1_rtscts : in integer range 0 to 1 := 1;

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

		cons_addr : out std_logic_vector(21 downto 0);
		cons_data : out std_logic_vector(15 downto 0);

      clkin : in std_logic;
      reset : in std_logic
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

component LEDMatrix is
    PORT (
        RESET,
        CLOCK_50 : IN STD_LOGIC;
        LED_DIGITS  : IN STD_LOGIC_VECTOR(39 downto 0);
        LED_DIN,
        LED_CS,
        LED_CLK  : OUT STD_LOGIC
    );
END component;

component debounce IS
  GENERIC(
    counter_size  :  INTEGER := 19); --counter size (19 bits gives 10.5ms with 50MHz clock)
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
END component;

component OneShot is
   generic (
      shotLength  :  integer
      );
    port (
    clk: in std_logic;
    trig: in std_logic;
    output: out std_logic
    );
end component;


------------------------------------------------------------------------------------------------
signal      panel_xled :  std_logic_vector(5 downto 0);
signal      panel_col :  std_logic_vector(11 downto 0);
signal      panel_row :  std_logic_vector(2 downto 0);

signal c0 : std_logic;

signal cpuclk : std_logic := '0';
signal cpureset : std_logic := '1';
signal cpuresetlength : integer range 0 to 63 := 63;
signal slowreset : std_logic;
signal slowresetdelay : integer range 0 to 4095 := 4095;

signal ifetch: std_logic;
--signal iwait: std_logic;
signal reset: std_logic;

  signal t_cons_start: std_logic;
  signal t_cons_cont: std_logic;
  signal db_switch3: std_logic;
  signal t_cons_ena: std_logic;
  signal t_cons_run: std_logic;
  
  signal t_reset: std_logic;
  signal t_cont: std_logic;
  signal t_ena: std_logic;

signal txtx1 : std_logic;
signal txtx2 : std_logic;


signal addr : std_logic_vector(21 downto 0);
--signal addrq : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;

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

signal dram_match : std_logic;
signal dram_counter : integer range 0 to 32767;
signal dram_wait : integer range 0 to 15;

signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
signal one_second_enable: std_logic;
signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
--signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (21 downto 0);
signal LED_activating_counter: std_logic_vector(1 downto 0);


-------------------------------------------------------",---8,---7,---6,---5,---4,---3,---2,---1"
--signal  my_digits : std_logic_vector ( 39 downto 0) := "1111111111001100010100100000110001000001";
--signal  my_digits : std_logic_vector ( 39 downto 0) := "0100000111001100010100100000110001000001";
-----------------------------------------------------------35---30---25---20---15---10----5----0
signal  my_address : std_logic_vector ( 21 downto 0);
signal  my_data : std_logic_vector ( 15 downto 0);

signal sample_cycles : std_logic_vector(15 downto 0) := x"0400";
signal minon_cycles : std_logic_vector(15 downto 0) := x"0400";


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
   dram_c15,
   dram_c16,
   dram_idle
);
signal dram_fsm : dram_fsm_type := dram_init;

---------------------------------------------------------------------------------------------
begin

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
		
		cons_addr => my_address,
		cons_data => my_data,

      clkin => cpuclk,
      reset => reset
   );

--   issp0: issp port map(
--      source => sample_cycles
--   );
--   issp1: issplim port map(
--      source => minon_cycles
--   );

	t_LEDMatrix: LEDMatrix PORT map(
        RESET => resetbtn,
--        RESET => t_reset,
        CLOCK_50 => clkin,
		  LED_DIGITS(21 downto 0) => my_address,
        LED_DIN => max7219_data,
        LED_CS => max7219_load,
        LED_CLK => max7219_clock
    );

	t_debounce1: debounce 
	generic map(
		counter_size => 21
	)
	port map(
		clk => clkin,
		button => switch(2),
		result => t_cons_ena
	);

	t_debounce2: debounce 
	generic map(
		counter_size => 21
	)
	port map(
		clk => clkin,
		button => switch(3),
		result => db_switch3
	);

	t_oneshot: OneSHot
	generic map(
		shotLength => 11
	)
	port map(
		clk => clkin,
		trig => not db_switch3,
		output => t_cons_cont
	);

	
   pll0: pll port map(
      inclk0 => clkin,
      c0 => c0
   );

   pdp11: unibus port map(
      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => dram_match,

      ifetch => ifetch,
--      iwait => iwait,

      have_rl => have_rl,
      have_rl_debug => 0,
      rl_sdcard_cs => rl_cs,
      rl_sdcard_mosi => rl_mosi,
      rl_sdcard_sclk => rl_sclk,
      rl_sdcard_miso => rl_miso,
      rl_sdcard_debug => rl_sddebug,

      have_rk => have_rk,
      have_rk_debug => 1,
      rk_sdcard_cs => rk_cs,
      rk_sdcard_mosi => rk_mosi,
      rk_sdcard_sclk => rk_sclk,
      rk_sdcard_miso => rk_miso,
      rk_sdcard_debug => rk_sddebug,

      have_rh => have_rh,
      have_rh_debug => 0,
      rh_sdcard_cs => rh_cs,
      rh_sdcard_mosi => rh_mosi,
      rh_sdcard_sclk => rh_sclk,
      rh_sdcard_miso => rh_miso,
      rh_sdcard_debug => rh_sddebug,

      have_kl11 => 2,
      tx0 => txtx1,
      rx0 => rx1,
      kl0_bps => 9600,
      kl0_force7bit => 1,

      tx1 => txtx2,
      rx1 => rx2,
      rts1 => rts2,
      cts1 => cts2,
      kl1_bps => 300, --2400, --9600, --38400,
      kl1_rtscts => 1,

      cons_run => t_cons_run,
--      cons_cont => not t_cons_cont,
      cons_cont => t_cons_cont,
      cons_ena =>  t_cons_ena,
--      cons_start => t_cons_start,
      have_xu => 0,
      xu_cs => xu_cs,
      xu_mosi => xu_mosi,
      xu_sclk => xu_sclk,
      xu_miso => xu_miso,
      xu_debug_tx => xu_debug_tx,

      cons_load => cons_load,
      cons_exa => cons_exa,
      cons_dep => cons_dep,
--      cons_cont => cons_cont,
--      cons_ena => cons_ena,
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
--      cons_run => cons_run,
      cons_pause => cons_pause,
      cons_master => cons_master,
      cons_kernel => cons_kernel,
      cons_super => cons_super,
      cons_user => cons_user,
      cons_id => cons_id,
      cons_map16 => cons_map16,
      cons_map18 => cons_map18,
      cons_map22 => cons_map22,


      modelcode => 20, --45,--70,--45,--20,--70,				-- mostly used are 20,34,44,45,70,94; others are less well tested
      have_fp => 0,

      reset => cpureset,
      clk50mhz => clkin,
      clk => cpuclk
   );

	ssegP <= '1'; -- blank DP

   reset <= (not resetbtn) ; -- or power_on_reset;
--	cons_cont <= (not switch(3));
--	cons_ena <= ( switch(2));

--   greenled <= not ps2k_c & not ps2k_d & ifetch & not rxrx0 & not txtx1 & not rxrx1 & sddebug;
--   redled <= not ps2k_c & not ps2k_d & ifetch & not rxrx0;
--   redled <= ps2k_c & ps2k_d & ifetch & rxrx0;
--   redled <= txtx1 & rxrx1 & txtx0 & rxrx0;
--   redled <= (not sddebug);

--redled(0) <= ( txtx1);
--redled(1) <= ( rx1);
--redled(2) <= ( txtx2);
--redled(2) <= ( rx2);
--  redled(0) <= cons_run;

--	t_cons_start <= not switch(1);
   t_reset <= switch(1);

--   t_cons_ena <= switch(2); // debounced
--   t_cons_ena <= enablebtn;
--   t_cons_cont <= not switch(3);

  redled(0) <= t_cons_run;
  redled(1) <= t_reset;
  redled(2) <= t_cons_ena;
--  redled(3) <= not t_cons_cont; //invisible
  redled(3) <= db_switch3;
--  redled(3) <= switch(3);
--redled(2) <= cons_run;
--redled(3) <= (not cons_run);

   tx1 <= txtx1;
   tx2 <= txtx2;

   sddebug <= rh_sddebug when have_rh = 1 else rl_sddebug when have_rl = 1 else rk_sddebug;
   sdcard_cs <= rh_cs when have_rh = 1 else rl_cs when have_rl = 1 else rk_cs;
   sdcard_mosi <= rh_mosi when have_rh = 1 else rl_mosi when have_rl = 1 else rk_mosi;
   sdcard_sclk <= rh_sclk when have_rh = 1 else rl_sclk when have_rl = 1 else rk_sclk;
   rh_miso <= sdcard_miso;
   rl_miso <= sdcard_miso;
   rk_miso <= sdcard_miso;



   dram_match <= '1' when addr(21 downto 18) /= "1111" else '0';
--   dram_match <= '1' when addr(21) /= '1' else '0';
   dram_cke <= '1';
   dram_clk <= c0;

--   have_rh <= 1; have_rl <= 0; have_rk <= 0;
--   have_rh <= 0;

---------------------------------------------------------------------------------------------

process(LED_BCD)
begin
    case LED_BCD is
    when "0000" => sseg0 <= "0000001"; -- "0"     
    when "0001" => sseg0 <= "1001111"; -- "1" 
    when "0010" => sseg0 <= "0010010"; -- "2" 
    when "0011" => sseg0 <= "0000110"; -- "3" 
    when "0100" => sseg0 <= "1001100"; -- "4" 
    when "0101" => sseg0 <= "0100100"; -- "5" 
    when "0110" => sseg0 <= "0100000"; -- "6" 
    when "0111" => sseg0 <= "0001111"; -- "7" 
    when "1000" => sseg0 <= "0000000"; -- "8"     
    when "1001" => sseg0 <= "0000100"; -- "9" 
    when "1010" => sseg0 <= "0000010"; -- a
    when "1011" => sseg0 <= "1100000"; -- b
    when "1100" => sseg0 <= "0110001"; -- C
    when "1101" => sseg0 <= "1000010"; -- d
    when "1110" => sseg0 <= "0110000"; -- E
    when "1111" => sseg0 <= "0111000"; -- F
    end case;
end process;

process(c0, reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(c0)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;

--LED_activating_counter <= refresh_counter(18 downto 17);
LED_activating_counter <= refresh_counter(20 downto 19);

process(LED_activating_counter, reset)
begin
	if(reset='1') then
		Anode_Activate <= "1111"; 
	else
		case LED_activating_counter is
		when "00" =>
		  Anode_Activate <= "0111"; 
		  -- activate LED1 and Deactivate LED2, LED3, LED4
		  LED_BCD <= my_data(15 downto 12);
		  -- the first hex digit of the 16-bit number
		when "01" =>
		  Anode_Activate <= "1011"; 
		  -- activate LED2 and Deactivate LED1, LED3, LED4
		  LED_BCD <= my_data(11 downto 8);
		  -- the second hex digit of the 16-bit number
		when "10" =>
		  Anode_Activate <= "1101"; 
		  -- activate LED3 and Deactivate LED2, LED1, LED4
		  LED_BCD <= my_data(7 downto 4);
		  -- the third hex digit of the 16-bit number
		when "11" =>
		  Anode_Activate <= "1110"; 
		  -- activate LED4 and Deactivate LED2, LED3, LED1
		  LED_BCD <= my_data(3 downto 0);
		  -- the fourth hex digit of the 16-bit number    
		end case;
	end if;
end process;



   process(c0)
   begin
      if c0='1' and c0'event then
         if slowreset = '1' then
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

            if switch(1) = '0' then                  -- beep when button 1 pressed
              beep <= '0';
            else
              beep <= '1';
            end if;

            if switch(0) = '0' then                  -- swap boot drives when button 0 pressed
               have_rl <= 1;
               have_rk <= 0;
            else
               have_rl <= 0;
               have_rk <= 1;
            end if;
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
                  cpuresetlength <= 8;
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
--                  dram_addr(12) <= '0';
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

                  dram_addr(11 downto 7) <= (others => '0');
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
--                  dram_addr(12) <= '0';
                  dram_addr(11) <= '0';
                  dram_addr(9 downto 0) <= (others => '0');

                  dram_fsm <= dram_c1;

               when dram_c1 =>

               cpuclk <= '1';

                  if cpuresetlength = 0 then
                     cpureset <= '0';
                  else
                     cpuresetlength <= cpuresetlength - 1;
                  end if;
                  dram_fsm <= dram_c2;

               when dram_c2 =>
                  dram_dq <= (others => 'Z');
                  dram_fsm <= dram_c3;

               when dram_c3 =>
                  dram_fsm <= dram_c4;

               when dram_c4 =>
                  dram_fsm <= dram_c5;

               when dram_c5 =>
                  dram_fsm <= dram_c6;

               when dram_c6 =>
                  -- read, t1-t2
--                  if ifetch = '1' then
--                     addrq <= addr;
--                  end if;
                  if dram_match = '1' and control_dati = '1' then
                     -- activate command
                     dram_cs_n <= '0';
                     dram_ras_n <= '0';
                     dram_cas_n <= '1';
                     dram_we_n <= '1';
--                     dram_addr(12) <= '0';
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
--                     dram_addr(12) <= '0';
                     dram_addr(11 downto 0) <= addr(20 downto 9);

                     dram_udqm <= '0';
                     dram_ldqm <= '0';
                     dram_ba_1 <= '0';
                     dram_ba_0 <= addr(21);
                  end if;

                  if dram_match = '0' or (control_dato = '0' and control_dati = '0') then
                     -- auto refresh command
                     dram_cs_n <= '0';
                     dram_ras_n <= '0';
                     dram_cas_n <= '0';
                     dram_we_n <= '1';
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
--                     dram_addr(12) <= '0';
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
--                     dram_addr(12) <= '0';
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

   process (c0)
   begin
      if c0='1' and c0'event then
         if reset = '1' then
            slowreset <= '1';
            slowresetdelay <= 4095;
         else
            if slowresetdelay = 0 then
               slowreset <= '0';
            else
               slowreset <= '1';
               slowresetdelay <= slowresetdelay - 1;
            end if;
         end if;
      end if;
   end process;

end implementation;

