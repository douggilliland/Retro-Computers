
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
      greenled : out std_logic_vector(7 downto 0);
      redled : out std_logic_vector(9 downto 0);

      sseg3 : out std_logic_vector(6 downto 0);
      sseg2 : out std_logic_vector(6 downto 0);
      sseg1 : out std_logic_vector(6 downto 0);
      sseg0 : out std_logic_vector(6 downto 0);

      clkin : in std_logic;

      sw : in std_logic_vector(9 downto 0);

      tx : out std_logic;
      rx : in std_logic;

      sram_addr : out std_logic_vector(17 downto 0);
      sram_dq : inout std_logic_vector(15 downto 0);
      sram_we_n : out std_logic;
      sram_oe_n : out std_logic;
      sram_ub_n : out std_logic;
      sram_lb_n : out std_logic;
      sram_ce_n : out std_logic;

      lpddr2_ca : out std_logic_vector(9 downto 0);
      lpddr2_dq : inout std_logic_vector(31 downto 0);
      lpddr2_dqsp : inout std_logic_vector(3 downto 0);
      lpddr2_dqsn : inout std_logic_vector(3 downto 0);
      lpddr2_dm : out std_logic_vector(3 downto 0);
      lpddr2_ckp : out std_logic;
      lpddr2_ckn : out std_logic;
      lpddr2_cke0 : out std_logic;
      lpddr2_cke1 : out std_logic;
      lpddr2_cs0 : out std_logic;
      lpddr2_cs1 : out std_logic;
      lpddr2_rqz : in std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;

-- ethernet, enc424j600 controller interface
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;

      clkout : out std_logic;
      clkout2 : out std_logic;
      pod : out std_logic_vector(7 downto 0);

      runbtn : in std_logic;
      resetbtn : in std_logic
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
      rh_type : in integer range 4 to 7 := 6;

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

component ssegdecoder is
	port(
		i : in std_logic_vector(3 downto 0);
		idle : in std_logic;
		u : out std_logic_vector(6 downto 0)
	);
end component;

component pll is
   port(
      refclk : in std_logic  := '0';
      rst : in std_logic := '0';
      outclk_0 : out std_logic;
      locked : out std_logic
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


signal cpuclk : std_logic;
signal power_on_reset : std_logic := '1';

signal ifetch: std_logic;
signal iwait: std_logic;
signal reset: std_logic;
signal run: std_logic;
signal txtx : std_logic;
signal rxrx : std_logic;

signal addr : std_logic_vector(21 downto 0);
signal addrq : std_logic_vector(21 downto 0);
signal dati : std_logic_vector(15 downto 0);
signal dato : std_logic_vector(15 downto 0);
signal control_dati : std_logic;
signal control_dato : std_logic;
signal control_datob : std_logic;
signal console_switches : std_logic_vector(15 downto 0);
signal console_displays : std_logic_vector(15 downto 0);
signal sram_match : std_logic;
signal clk : std_logic;

signal cs : std_logic;
signal mosi : std_logic;
signal miso : std_logic;
signal sclk : std_logic;
signal sddebug : std_logic_vector(3 downto 0);

signal c0 : std_logic;

begin

   pll0: pll port map(
      refclk => clkin,
      outclk_0 => c0
   );

--   c0 <= clkin;
   clk <= c0;

   pdp11: unibus port map(
      addr => addr,
      dati => dati,
      dato => dato,
      control_dati => control_dati,
      control_dato => control_dato,
      control_datob => control_datob,
      addr_match => sram_match,

      ifetch => ifetch,
      iwait => iwait,

      have_rl => 1,
      rl_sdcard_cs => cs,
      rl_sdcard_mosi => mosi,
      rl_sdcard_sclk => sclk,
      rl_sdcard_miso => miso,
      rl_sdcard_debug => sddebug,

      have_kl11 => 1,
      rx0 => rx,
      tx0 => txtx,
      kl0_force7bit => 1,

      console_switches => console_switches,
      console_displays => console_displays,

      modelcode => 45,
      init_r7 => x"ea10",

--      init_psw => x"0000",
--      init_r7 => x"0000",

      clk => cpuclk,
      clk50mhz => clkin,
      run => run,
      reset => reset
   );

   ssegd3: ssegdecoder port map(
		i => addrq(15 downto 12),
      idle => iwait,
		u => sseg3
	);
   ssegd2: ssegdecoder port map(
		i => addrq(11 downto 8),
      idle => iwait,
		u => sseg2
	);
   ssegd1: ssegdecoder port map(
		i => addrq(7 downto 4),
      idle => iwait,
		u => sseg1
	);
   ssegd0: ssegdecoder port map(
		i => addrq(3 downto 0),
      idle => iwait,
		u => sseg0
	);

   reset <= (not resetbtn) or power_on_reset;
   run <= (not runbtn);

   sdcard_cs <= cs;
   sdcard_mosi <= mosi;
   sdcard_sclk <= sclk;
   miso <= sdcard_miso;

   addrq <= addr;
   redled <= console_displays(9 downto 0);
   console_switches <= "000000" & sw;

   greenled <= ifetch & "000" & sddebug;
   tx <= txtx;
   rxrx <= rx;

   sram_match <= '1' when addr(21 downto 19) = "000" else '0';
   sram_addr <= addr(18 downto 1);

   clkout <= cpuclk;
   clkout2 <= ifetch;
   pod(2) <= cpuclk;
   pod(3) <= ifetch;

   lpddr2_ckp <= '0';
   lpddr2_ckn <= '1';
   lpddr2_dqsp <= "0000";
   lpddr2_dqsn <= "1111";
   lpddr2_cs0 <= '1';
   lpddr2_cke0 <= '0';

   process(cpuclk)
   begin
      if cpuclk='1' and cpuclk'event then
         if power_on_reset = '1' then
            power_on_reset <= '0';
         end if;
      end if;
   end process;

   process(clk)
   begin
      if clk='1' and clk'event then

         case clk_fsm is

            when clk_n =>
               clk_fsm <= clk_ne;
               pod(0) <= '0';
               pod(1) <= '0';

-- read
               if sram_match = '1' and control_dati = '1' then
                  pod(0) <= '1';
                  sram_ce_n <= '0';
                  sram_oe_n <= '0';
                  sram_ub_n <= '0';
                  sram_lb_n <= '0';
                  sram_we_n <= '1';
                  sram_dq <= "ZZZZZZZZZZZZZZZZ";
               end if;

-- write
               if sram_match = '1' and control_dato = '1' then
                  pod(1) <= '1';
                  sram_ce_n <= '0';
                  sram_oe_n <= '1';
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
               sram_ce_n <= '1';
               sram_oe_n <= '1';
               sram_we_n <= '1';
               sram_lb_n <= '1';
               sram_ub_n <= '1';
               sram_dq <= "ZZZZZZZZZZZZZZZZ";
            cpuclk <= '1';

            when clk_nw =>
               clk_fsm <= clk_n;

            when clk_idle =>
               clk_fsm <= clk_n;
               sram_ce_n <= '1';
               sram_oe_n <= '1';
               sram_we_n <= '1';
               sram_lb_n <= '1';
               sram_ub_n <= '1';
               sram_dq <= "ZZZZZZZZZZZZZZZZ";

            when others =>
               null;

         end case;

      end if;
   end process;

end implementation;

