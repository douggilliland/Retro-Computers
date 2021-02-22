
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

-- $Revision: 1.90 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity unibus is
   port(
-- bus interface
      addr : out std_logic_vector(21 downto 0);                      -- physical address driven out to the bus by cpu or busmaster peripherals
      dati : in std_logic_vector(15 downto 0);                       -- data input to cpu or busmaster peripherals
      dato : out std_logic_vector(15 downto 0);                      -- data output from cpu or busmaster peripherals
      control_dati : out std_logic;                                  -- if '1', this is an input cycle
      control_dato : out std_logic;                                  -- if '1', this is an output cycle
      control_datob : out std_logic;                                 -- if '1', the current output cycle is for a byte
      addr_match : in std_logic;                                     -- '1' if the address is recognized
		init : out std_logic;
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
      kl0_bps : in integer range 300 to 230400 := 9600;             -- bps rate - don't set over 38400 for interrupt control applications
      kl0_force7bit : in integer range 0 to 1 := 0;                  -- zero out high order bit on transmission and reception
      kl0_rtscts : in integer range 0 to 1 := 0;                     -- conditional compilation switch for rts and cts signals; also implies to include core that implements a silo buffer

      tx1 : out std_logic;
      rx1 : in std_logic := '1';
      rts1 : out std_logic;
      cts1 : in std_logic := '0';
      kl1_bps : in integer range 300 to 230400 := 9600;
      kl1_force7bit : in integer range 0 to 1 := 0;
      kl1_rtscts : in integer range 0 to 1 := 0;

      tx2 : out std_logic;
      rx2 : in std_logic := '1';
      rts2 : out std_logic;
      cts2 : in std_logic := '0';
      kl2_bps : in integer range 300 to 230400 := 9600;
      kl2_force7bit : in integer range 0 to 1 := 0;
      kl2_rtscts : in integer range 0 to 1 := 0;

      tx3 : out std_logic;
      rx3 : in std_logic := '1';
      rts3 : out std_logic;
      cts3 : in std_logic := '0';
      kl3_bps : in integer range 300 to 230400 := 9600;
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
end unibus;

architecture implementation of unibus is

component cpu is
   port(
      addr_v : out std_logic_vector(15 downto 0);                    -- the virtual address that the cpu drives out to the bus for the current read or write
      datain : in std_logic_vector(15 downto 0);                     -- when doing a read, the data input to the cpu
      dataout : out std_logic_vector(15 downto 0);                   -- when doing a write, the data output from the cpu
      wr : out std_logic;                                            -- if '1', the cpu is doing a write to the bus and drives addr_v and dataout
      rd : out std_logic;                                            -- if '1', the cpu is doing a read from the bus, drives addr_v and reads datain
      dw8 : out std_logic;                                           -- if '1', the read or write initiated by the cpu is 8 bits wide
      cp : out std_logic;                                            -- if '1', the read or write should use the previous cpu mode
      ifetch : out std_logic;                                        -- if '1', this read is for an instruction fetch
      id : out std_logic;                                            -- if '1', the read or write should use data space
      init : out std_logic;                                          -- if '1', the devices on the bus should reset

      iwait : out std_logic;                                         -- if '1', the cpu is waiting for an interrupt

      br7 : in std_logic;                                            -- interrupt request, 7
      bg7 : out std_logic;                                           -- interrupt grant, 7
      int_vector7 : in std_logic_vector(8 downto 0);                 -- interrupt vector, 7
      br6 : in std_logic;
      bg6 : out std_logic;
      int_vector6 : in std_logic_vector(8 downto 0);
      br5 : in std_logic;
      bg5 : out std_logic;
      int_vector5 : in std_logic_vector(8 downto 0);
      bg4 : out std_logic;                                           -- interrupt request, 4
      br4 : in std_logic;                                            -- interrupt grant, 4
      int_vector4 : in std_logic_vector(8 downto 0);                 -- interrupt vector, 4

      mmutrap : in std_logic;                                        -- if '1', the mmu requests a trap to be serviced after the current instruction completes
      ack_mmutrap : out std_logic;                                   -- if '1', the mmu trap request is being acknowledged
      mmuabort : in std_logic;                                       -- if '1', the mmu requests that the current instruction is aborted because of a mmu fault
      ack_mmuabort : out std_logic;                                  -- if '1', the mmu abort request is being acknowledged

      npr : in std_logic;                                            -- non-processor request
      npg : out std_logic;                                           -- non-processor grant

      nxmabort : in std_logic;                                       -- nxm abort - a memory access cycle by the cpu refers to an address that does not exist
      oddabort : in std_logic;                                       -- odd abort - a memory access cycle by the cpu is for a full word, but uses an odd address
      illhalt : out std_logic;                                       -- a halt instruction was not executed because it was illegal in the current mode; for use in the cer cpu error register
      ysv : out std_logic;                                           -- a yellow stack trap is in progress - for use in the cer cpu error register
      rsv : out std_logic;                                           -- a red stack trap is in progress - for use in the cer cpu error register

      cpu_stack_limit : in std_logic_vector(15 downto 0);            -- the cpu stack limit control register value
      cpu_kmillhalt : in std_logic;                                  -- the control register setting for kernel mode illegal halt

      sr0_ic : out std_logic;                                        -- sr0/mmr0 instruction complete flag
      sr1 : out std_logic_vector(15 downto 0);                       -- sr1/mmr1, address of the current instruction
      sr2 : out std_logic_vector(15 downto 0);                       -- sr2, register autoincrement/autodecrement information for instruction restart
      dstfreference : out std_logic;                                 -- if '1', the destination reference is the final reference for this addressing mode
      sr3csmenable : in std_logic;                                   -- if '1', the enable csm instruction flag in sr3/mmr3 is set

      psw_in : in std_logic_vector(15 downto 0);                     -- psw input from the control register address @ 177776
      psw_in_we_even : in std_logic;                                 -- psw input from the control register address @ 177776, write enable for the even address part
      psw_in_we_odd : in std_logic;                                  -- psw input from the control register address @ 177776, write enable for the odd address part
      psw_out : out std_logic_vector(15 downto 0);                   -- psw output, current psw that the cpu uses

      pir_in : in std_logic_vector(15 downto 0);                     -- pirq value input from the control register

      modelcode : in integer range 0 to 255;                         -- cpu model code
      have_fp : in integer range 0 to 2 := 2;                        -- floating point; 0=force disable; 1=force enable; 2=follow default for cpu model
      have_fpa : in integer range 0 to 1 := 0;                       -- floating point accelerator present with J11 cpu
      init_r7 : in std_logic_vector(15 downto 0) := x"f600";         -- start address after reset = o'173000' = m9312 hi rom
      init_psw : in std_logic_vector(15 downto 0) := x"00e0";        -- initial psw for kernel mode, primary register set, priority 7

      cons_load : in std_logic := '0';                               -- load, pulse '1'
      cons_exa : in std_logic := '0';                                -- examine, pulse '1'
      cons_dep : in std_logic := '0';                                -- deposit, pulse '1'
      cons_cont : in std_logic := '0';                               -- continue, pulse '1'
      cons_ena : in std_logic := '1';                                -- ena/halt, '1' is enable, '0' is halt
      cons_start : in std_logic := '0';                              -- start, pulse '1'
      cons_sw : in std_logic_vector(21 downto 0) := (others => '0'); -- front panel switches
      cons_consphy : out std_logic_vector(21 downto 0);              -- console address
      cons_exadep : out std_logic;                                   -- '1' when running an examine or deposit memory cycle from the console
      cons_adrserr : out std_logic;                                  -- '1' when last access from console caused an nxmabort
      cons_br : out std_logic_vector(15 downto 0);                   -- bus register for the console displays
      cons_shfr : out std_logic_vector(15 downto 0);                 -- shfr register for the console displays
      cons_maddr : out std_logic_vector(15 downto 0);                -- microcode address fpu/cpu

      cons_run : out std_logic;                                      -- '1' if executing instructions (incl wait)
      cons_pause : out std_logic;                                    -- '1' if bus has been relinquished to npr
      cons_master : out std_logic;                                   -- '1' if cpu is bus master and not running
      cons_kernel : out std_logic;                                   -- '1' if kernel mode
      cons_super : out std_logic;                                    -- '1' if super mode
      cons_user : out std_logic;                                     -- '1' if user mode

      clk : in std_logic;                                            -- input clock
      reset : in std_logic                                           -- reset cpu, also causes init signal to devices on the bus to be asserted
   );
end component;

component mmu is
   port(
      cpu_addr_v : in std_logic_vector(15 downto 0);
      cpu_datain : out std_logic_vector(15 downto 0);
      cpu_dataout : in std_logic_vector(15 downto 0);
      cpu_rd : in std_logic;
      cpu_wr : in std_logic;
      cpu_dw8 : in std_logic;
      cpu_cp : in std_logic;

      mmutrap : out std_logic;
      ack_mmutrap : in std_logic;
      mmuabort : out std_logic;
      ack_mmuabort : in std_logic;

      mmuoddabort : out std_logic;

      sr0_ic : in std_logic;
      sr1_in : in std_logic_vector(15 downto 0);
      sr2_in : in std_logic_vector(15 downto 0);
      dstfreference : in std_logic;
      sr3csmenable : out std_logic;
      ifetch : in std_logic;

      bus_unibus_mapped : out std_logic;

      bus_addr : out std_logic_vector(21 downto 0);
      bus_dati : in std_logic_vector(15 downto 0);
      bus_dato : out std_logic_vector(15 downto 0);
      bus_control_dati : out std_logic;
      bus_control_dato : out std_logic;
      bus_control_datob : out std_logic;

      unibus_addr : out std_logic_vector(17 downto 0);
      unibus_dati : in std_logic_vector(15 downto 0);
      unibus_dato : out std_logic_vector(15 downto 0);
      unibus_control_dati : out std_logic;
      unibus_control_dato : out std_logic;
      unibus_control_datob : out std_logic;

      unibus_busmaster_addr : in std_logic_vector(17 downto 0);
      unibus_busmaster_dati : out std_logic_vector(15 downto 0);
      unibus_busmaster_dato : in std_logic_vector(15 downto 0);
      unibus_busmaster_control_dati : in std_logic;
      unibus_busmaster_control_dato : in std_logic;
      unibus_busmaster_control_datob : in std_logic;
      unibus_busmaster_control_npg : in std_logic;

      cons_exadep : in std_logic;
      cons_consphy : in std_logic_vector(21 downto 0);
      cons_adss_mode : in std_logic_vector(1 downto 0);
      cons_adss_id : in std_logic;
      cons_adss_cons : in std_logic;
      cons_map16 : out std_logic;
      cons_map18 : out std_logic;
      cons_map22 : out std_logic;
      cons_id : out std_logic;

      modelcode : in integer range 0 to 255;
      sr0out_debug : out std_logic_vector(15 downto 0);

      psw : in std_logic_vector(15 downto 0);
      id : in std_logic;
      reset : in std_logic;
      clk : in std_logic
   );
end component;

component cr is
   port(
      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

-- psw
      psw_in : out std_logic_vector(15 downto 0);
      psw_in_we_even : out std_logic;
      psw_in_we_odd : out std_logic;
      psw_out : in std_logic_vector(15 downto 0);

-- stack limit
      cpu_stack_limit : out std_logic_vector(15 downto 0);

-- pirq
      pir_in : out std_logic_vector(15 downto 0);

-- cer
      cpu_illegal_halt : in std_logic;
      cpu_address_error : in std_logic;
      cpu_nxm : in std_logic;
      cpu_iobus_timeout : in std_logic;
      cpu_ysv : in std_logic;
      cpu_rsv : in std_logic;

-- maintenance register (j11)
      cpu_kmillhalt : out std_logic;

-- model code

      modelcode : in integer range 0 to 255;
      have_fpa : in integer range 0 to 1 := 0;                       -- floating point accelerator present with J11 cpu

--
      reset : in std_logic;
      clk : in std_logic
   );
end component;

component csdr is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      have_csdr : in integer range 0 to 1;

      cs_reg : in std_logic_vector(15 downto 0);
      cd_reg : out std_logic_vector(15 downto 0);

      reset : in std_logic;
      clk : in std_logic
   );
end component;

component monitor is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end component;

component m9312l is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;

      clk : in std_logic
   );
end component;

component m9312h is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;

      clk : in std_logic
   );
end component;

component kl11 is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);
      ovec : in std_logic_vector(8 downto 0);

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

      tx : out std_logic;
      rx : in std_logic;
      rts : out std_logic;
      cts : in std_logic;

      have_kl11 : in integer range 0 to 1;
      have_kl11_force7bit : in integer range 0 to 1;
      have_kl11_rtscts : in integer range 0 to 1;
      have_kl11_bps : in integer range 1200 to 230400;

      reset : in std_logic;

      clk50mhz : in std_logic;

      clk : in std_logic
   );
end component;

component kw11l is
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
end component;

component rl11 is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      npr : out std_logic;
      npg : in std_logic;

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0);
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;
      sdcard_debug : out std_logic_vector(3 downto 0);

      have_rl : in integer range 0 to 1;
      have_rl_debug : in integer range 0 to 1;
      reset : in std_logic;
      sdclock : in std_logic;
      clk : in std_logic
   );
end component;

component rk11 is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      npr : out std_logic;
      npg : in std_logic;

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0);
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic;

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;
      sdcard_debug : out std_logic_vector(3 downto 0);

      have_rk : in integer range 0 to 1;
      have_rk_debug : in integer range 0 to 2;
      have_rk_num : in integer range 1 to 8;
      have_rk_minimal : in integer range 0 to 1;
      reset : in std_logic;
      sdclock : in std_logic;
      clk : in std_logic
   );
end component;

component rh11 is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      npr : out std_logic;
      npg : in std_logic;

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0) := (others => '0');
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic := '0';

      rh70_bus_master_addr : out std_logic_vector(21 downto 0);
      rh70_bus_master_dati : in std_logic_vector(15 downto 0) := (others => '0');
      rh70_bus_master_dato : out std_logic_vector(15 downto 0);
      rh70_bus_master_control_dati : out std_logic;
      rh70_bus_master_control_dato : out std_logic;
      rh70_bus_master_nxm : in std_logic := '0';

      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic;
      sdcard_debug : out std_logic_vector(3 downto 0);

      have_rh : in integer range 0 to 1 := 0;
      have_rh70 : in integer range 0 to 1 := 0;
      have_rh_debug : in integer range 0 to 1 := 1;
      rmtype : in integer range 4 to 7 := 6;
      reset : in std_logic;
      sdclock : in std_logic;
      clk : in std_logic
   );
end component;

component xu is
   port(
-- standard bus master interface
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      npr : out std_logic;
      npg : in std_logic;

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0) := (others => '0');
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic := '0';

-- ethernet, enc424j600 controller interface
      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;

-- flags
      have_xu : in integer range 0 to 1 := 0;
      have_xu_debug : in integer range 0 to 1 := 1;

-- debug & blinkenlights
      tx : out std_logic;
      ifetch : out std_logic;
      iwait : out std_logic;

-- clock & reset
      cpuclk : in std_logic;
      nclk : in std_logic;
      clk50mhz : in std_logic;
      reset : in std_logic
   );
end component;

component dr11c is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec1 : in std_logic_vector(8 downto 0);
      ivec2 : in std_logic_vector(8 downto 0);

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

      have_dr11c : in integer range 0 to 1 := 0;
      have_dr11c_loopback : in integer range 0 to 1 := 0;
      have_dr11c_signal_stretch : in integer range 0 to 127 := 7;

      dr11c_in : in std_logic_vector(15 downto 0) := (others => '0');
      dr11c_out : out std_logic_vector(15 downto 0);
      dr11c_reqa : in std_logic := '0';
      dr11c_reqb : in std_logic := '0';
      dr11c_csr0 : out std_logic;
      dr11c_csr1 : out std_logic;
      dr11c_ndr : out std_logic;
      dr11c_ndrlo : out std_logic;
      dr11c_ndrhi : out std_logic;
      dr11c_dxm : out std_logic;
      dr11c_init : out std_logic;

      reset : in std_logic;

      clk50mhz : in std_logic;

      clk : in std_logic
   );
end component;


signal cpu_addr : std_logic_vector(15 downto 0);
signal cpu_datain : std_logic_vector(15 downto 0);
signal cpu_dataout : std_logic_vector(15 downto 0);
signal cpu_wr : std_logic;
signal cpu_rd : std_logic;
signal cpu_psw : std_logic_vector(15 downto 0);
signal cpu_psw_in : std_logic_vector(15 downto 0);
signal cpu_psw_we_even : std_logic;
signal cpu_psw_we_odd : std_logic;
signal cpu_pir_in : std_logic_vector(15 downto 0);
signal cpu_dw8 : std_logic;
signal cpu_cp : std_logic;
signal cpu_id : std_logic;
signal cpu_init : std_logic;
signal cpu_addr_match : std_logic;
signal cpu_sr0_ic : std_logic;
signal cpu_sr1 : std_logic_vector(15 downto 0);
signal cpu_sr2 : std_logic_vector(15 downto 0);
signal cpu_dstfreference : std_logic;
signal cpu_sr3csmenable : std_logic;

signal cpu_br7 : std_logic;
signal cpu_bg7 : std_logic;
signal cpu_int_vector7 : std_logic_vector(8 downto 0);
signal cpu_br6 : std_logic;
signal cpu_bg6 : std_logic;
signal cpu_int_vector6 : std_logic_vector(8 downto 0);
signal cpu_br5 : std_logic;
signal cpu_bg5 : std_logic;
signal cpu_int_vector5 : std_logic_vector(8 downto 0);
signal cpu_br4 : std_logic;
signal cpu_bg4 : std_logic;
signal cpu_int_vector4 : std_logic_vector(8 downto 0);

signal mmu_trap : std_logic;
signal mmu_abort : std_logic;
signal mmu_oddabort : std_logic;
signal cpu_ack_mmuabort : std_logic;
signal cpu_ack_mmutrap : std_logic;

signal cpu_npr : std_logic;
signal cpu_npg : std_logic;

signal nxmabort : std_logic;
signal oddabort : std_logic;
signal illhalt : std_logic;
signal ysv : std_logic;
signal rsv : std_logic;
signal ifetchcopy : std_logic;
signal cpu_cons_run : std_logic;
signal cpu_cons_consphy : std_logic_vector(21 downto 0);

signal bus_unibus_mapped : std_logic;

signal bus_addr : std_logic_vector(21 downto 0);
signal bus_dati : std_logic_vector(15 downto 0);
signal bus_dato : std_logic_vector(15 downto 0);
signal bus_control_dati : std_logic;
signal bus_control_dato : std_logic;
signal bus_control_datob : std_logic;

signal busmaster_nxmabort : std_logic;

signal unibus_addr_match : std_logic;

signal unibus_addr : std_logic_vector(17 downto 0);
signal unibus_dati : std_logic_vector(15 downto 0);
signal unibus_dato : std_logic_vector(15 downto 0);
signal unibus_control_dati : std_logic;
signal unibus_control_dato : std_logic;
signal unibus_control_datob : std_logic;

signal unibus_busmaster_addr : std_logic_vector(17 downto 0);
signal unibus_busmaster_dati : std_logic_vector(15 downto 0);
signal unibus_busmaster_dato : std_logic_vector(15 downto 0);
signal unibus_busmaster_control_dati : std_logic;
signal unibus_busmaster_control_dato : std_logic;
signal unibus_busmaster_control_datob : std_logic;
signal unibus_busmaster_control_npg : std_logic;

type npr_states is (
   npr_idle,
   npr_rl0,
   npr_rk0,
   npr_rh0,
   npr_xu0
);
signal npr_state : npr_states := npr_idle;

type br5_states is (
   br5_rh0,
   br5_xu0,
   br5_rl0,
   br5_rk0,
   br5_dr11c0,
   br5_idle
);
signal br5_state : br5_states := br5_idle;

type br4_states is (
   br4_kl0,
   br4_kl1,
   br4_kl2,
   br4_kl3,
   br4_idle
);
signal br4_state : br4_states := br4_idle;

signal mem_addr_match : std_logic;
signal mem_dati : std_logic_vector(15 downto 0);

signal rom0_addr_match : std_logic;
signal rom0_dati : std_logic_vector(15 downto 0);

signal rom1_addr_match : std_logic;
signal rom1_dati : std_logic_vector(15 downto 0);

signal rom2_addr_match : std_logic;
signal rom2_dati : std_logic_vector(15 downto 0);

signal csdr_addr_match : std_logic;
signal csdr_dati : std_logic_vector(15 downto 0);

signal have_kl0 : integer range 0 to 1;
signal kl0_addr_match : std_logic;
signal kl0_dati : std_logic_vector(15 downto 0);
signal kl0_bg : std_logic;
signal kl0_br : std_logic;
signal kl0_ivec : std_logic_vector(8 downto 0);

signal have_kl1 : integer range 0 to 1;
signal kl1_addr_match : std_logic;
signal kl1_dati : std_logic_vector(15 downto 0);
signal kl1_bg : std_logic;
signal kl1_br : std_logic;
signal kl1_ivec : std_logic_vector(8 downto 0);

signal have_kl2 : integer range 0 to 1;
signal kl2_addr_match : std_logic;
signal kl2_dati : std_logic_vector(15 downto 0);
signal kl2_bg : std_logic;
signal kl2_br : std_logic;
signal kl2_ivec : std_logic_vector(8 downto 0);

signal have_kl3 : integer range 0 to 1;
signal kl3_addr_match : std_logic;
signal kl3_dati : std_logic_vector(15 downto 0);
signal kl3_bg : std_logic;
signal kl3_br : std_logic;
signal kl3_ivec : std_logic_vector(8 downto 0);

signal kw0_addr_match : std_logic;
signal kw0_dati : std_logic_vector(15 downto 0);
signal kw0_bg : std_logic;
signal kw0_br : std_logic;
signal kw0_ivec : std_logic_vector(8 downto 0);

signal rl0_addr_match : std_logic;
signal rl0_dati : std_logic_vector(15 downto 0);
signal rl0_npr : std_logic;
signal rl0_npg : std_logic;

signal rl0_bg : std_logic;
signal rl0_br : std_logic;
signal rl0_ivec : std_logic_vector(8 downto 0);

signal rl0_addr : std_logic_vector(17 downto 0);
signal rl0_dato : std_logic_vector(15 downto 0);
signal rl0_control_dati : std_logic;
signal rl0_control_dato : std_logic;

signal rk0_bg : std_logic;
signal rk0_br : std_logic;
signal rk0_ivec : std_logic_vector(8 downto 0);

signal rk0_addr_match : std_logic;
signal rk0_dati : std_logic_vector(15 downto 0);
signal rk0_npr : std_logic;
signal rk0_npg : std_logic;

signal rk0_addr : std_logic_vector(17 downto 0);
signal rk0_dato : std_logic_vector(15 downto 0);
signal rk0_control_dati : std_logic;
signal rk0_control_dato : std_logic;

signal rh0_bg : std_logic;
signal rh0_br : std_logic;
signal rh0_ivec : std_logic_vector(8 downto 0);

signal rh0_addr_match : std_logic;
signal rh0_dati : std_logic_vector(15 downto 0);
signal rh0_npr : std_logic;
signal rh0_npg : std_logic;

signal rh0_addr : std_logic_vector(17 downto 0);
signal rh0_dato : std_logic_vector(15 downto 0);
signal rh0_control_dati : std_logic;
signal rh0_control_dato : std_logic;

signal rh70_bus_master_addr : std_logic_vector(21 downto 0);
signal rh70_bus_master_dati : std_logic_vector(15 downto 0);
signal rh70_bus_master_dato : std_logic_vector(15 downto 0);
signal rh70_bus_master_control_dati : std_logic;
signal rh70_bus_master_control_dato : std_logic;
signal rh70_bus_master_nxm : std_logic;

signal have_rh70 : integer range 0 to 1;

signal xu0_bg : std_logic;
signal xu0_br : std_logic;
signal xu0_ivec : std_logic_vector(8 downto 0);

signal xu0_addr_match : std_logic;
signal xu0_dati : std_logic_vector(15 downto 0);
signal xu0_npr : std_logic;
signal xu0_npg : std_logic;

signal xu0_addr : std_logic_vector(17 downto 0);
signal xu0_dato : std_logic_vector(15 downto 0);
signal xu0_control_dati : std_logic;
signal xu0_control_dato : std_logic;

signal dr11c0_addr_match : std_logic;
signal dr11c0_dati : std_logic_vector(15 downto 0);
signal dr11c0_bg : std_logic;
signal dr11c0_br : std_logic;
signal dr11c0_ivec : std_logic_vector(8 downto 0);
signal dr11c0_ivec1 : std_logic_vector(8 downto 0);
signal dr11c0_ivec2 : std_logic_vector(8 downto 0);

signal cer_nxmabort : std_logic;
signal cer_ioabort : std_logic;

signal cpu_stack_limit : std_logic_vector(15 downto 0);
signal cpu_kmillhalt : std_logic;
signal cons_exadep : std_logic;

signal cr_addr_match : std_logic;
signal cr_dati : std_logic_vector(15 downto 0);

signal nclk : std_logic;

begin

   cpu0: cpu port map(
      addr_v => cpu_addr,
      datain => cpu_datain,
      dataout => cpu_dataout,
      wr => cpu_wr,
      rd => cpu_rd,
      dw8 => cpu_dw8,
      cp => cpu_cp,
      ifetch => ifetchcopy,
      iwait => iwait,
      id => cpu_id,
      init => cpu_init,
      br7 => cpu_br7,
      bg7 => cpu_bg7,
      int_vector7 => cpu_int_vector7,
      br6 => cpu_br6,
      bg6 => cpu_bg6,
      int_vector6 => cpu_int_vector6,
      br5 => cpu_br5,
      bg5 => cpu_bg5,
      int_vector5 => cpu_int_vector5,
      br4 => cpu_br4,
      bg4 => cpu_bg4,
      int_vector4 => cpu_int_vector4,
      mmutrap => mmu_trap,
      ack_mmutrap => cpu_ack_mmutrap,
      mmuabort => mmu_abort,
      ack_mmuabort => cpu_ack_mmuabort,
      npr => cpu_npr,
      npg => cpu_npg,
      nxmabort => nxmabort,
      oddabort => oddabort,
      illhalt => illhalt,
      ysv => ysv,
      rsv => rsv,
      cpu_stack_limit => cpu_stack_limit,
      cpu_kmillhalt => cpu_kmillhalt,
      sr0_ic => cpu_sr0_ic,
      sr1 => cpu_sr1,
      sr2 => cpu_sr2,
      dstfreference => cpu_dstfreference,
      sr3csmenable => cpu_sr3csmenable,
      psw_in => cpu_psw_in,
      psw_out => cpu_psw,
      psw_in_we_even => cpu_psw_we_even,
      psw_in_we_odd => cpu_psw_we_odd,
      pir_in => cpu_pir_in,
      modelcode => modelcode,
      have_fp => have_fp,
      have_fpa => have_fpa,
      init_r7 => init_r7,
      init_psw => init_psw,
      cons_load => cons_load,
      cons_exa => cons_exa,
      cons_dep => cons_dep,
      cons_cont => cons_cont,
      cons_ena => cons_ena,
      cons_start => cons_start,
      cons_sw => cons_sw,
      cons_consphy => cpu_cons_consphy,
      cons_exadep => cons_exadep,
      cons_adrserr => cons_adrserr,
      cons_br => cons_br,
      cons_shfr => cons_shfr,
      cons_maddr => cons_maddr,
      cons_run => cpu_cons_run,
      cons_pause => cons_pause,
      cons_master => cons_master,
      cons_kernel => cons_kernel,
      cons_super => cons_super,
      cons_user => cons_user,
      clk => clk,
      reset => reset
   );

   mmu0: mmu port map(
      cpu_addr_v => cpu_addr,
      cpu_datain => cpu_datain,
      cpu_dataout => cpu_dataout,
      cpu_rd => cpu_rd,
      cpu_wr => cpu_wr,
      cpu_dw8 => cpu_dw8,
      cpu_cp => cpu_cp,
      sr0_ic => cpu_sr0_ic,
      sr1_in => cpu_sr1,
      sr2_in => cpu_sr2,
      dstfreference => cpu_dstfreference,
      sr3csmenable => cpu_sr3csmenable,
      ifetch => ifetchcopy,
      mmutrap => mmu_trap,
      ack_mmutrap => cpu_ack_mmutrap,
      mmuabort => mmu_abort,
      ack_mmuabort => cpu_ack_mmuabort,

      mmuoddabort => mmu_oddabort,

      bus_unibus_mapped => bus_unibus_mapped,

      bus_addr => bus_addr,
      bus_dati => bus_dati,
      bus_dato => bus_dato,
      bus_control_dati => bus_control_dati,
      bus_control_dato => bus_control_dato,
      bus_control_datob => bus_control_datob,

      unibus_addr => unibus_addr,
      unibus_dati => unibus_dati,
      unibus_dato => unibus_dato,
      unibus_control_dati => unibus_control_dati,
      unibus_control_dato => unibus_control_dato,
      unibus_control_datob => unibus_control_datob,

      unibus_busmaster_addr => unibus_busmaster_addr,
      unibus_busmaster_dati => unibus_busmaster_dati,
      unibus_busmaster_dato => unibus_busmaster_dato,
      unibus_busmaster_control_dati => unibus_busmaster_control_dati,
      unibus_busmaster_control_dato => unibus_busmaster_control_dato,
      unibus_busmaster_control_datob => unibus_busmaster_control_datob,
      unibus_busmaster_control_npg => unibus_busmaster_control_npg,

      cons_exadep => cons_exadep,
      cons_consphy => cpu_cons_consphy,
      cons_adss_mode => cons_adss_mode,
      cons_adss_id => cons_adss_id,
      cons_adss_cons => cons_adss_cons,
      cons_map16 => cons_map16,
      cons_map18 => cons_map18,
      cons_map22 => cons_map22,
      cons_id => cons_id,

      modelcode => modelcode,

      psw => cpu_psw,
      id => cpu_id,
      reset => cpu_init,
      clk => nclk
   );

   cr0: cr port map(
      bus_addr_match => cr_addr_match,
      bus_addr => unibus_addr,
      bus_dati => cr_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      psw_in => cpu_psw_in,
      psw_in_we_even => cpu_psw_we_even,
      psw_in_we_odd => cpu_psw_we_odd,
      psw_out => cpu_psw,

      cpu_stack_limit => cpu_stack_limit,

      pir_in => cpu_pir_in,

      cpu_illegal_halt => illhalt,
      cpu_address_error => oddabort,
      cpu_nxm => cer_nxmabort,
      cpu_iobus_timeout => cer_ioabort,
      cpu_ysv => ysv,
      cpu_rsv => rsv,

      cpu_kmillhalt => cpu_kmillhalt,

      modelcode => modelcode,
      have_fpa => have_fpa,

      reset => cpu_init,
      clk => nclk
   );

   bootrom0: m9312l port map(
      base_addr => o"765000",                   -- m9312 lo rom

      bus_addr_match => rom0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rom0_dati,
      bus_control_dati => unibus_control_dati,

      clk => nclk
   );

   bootrom1: m9312h port map(
      base_addr => o"773000",                   -- m9312 hi rom

      bus_addr_match => rom1_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rom1_dati,
      bus_control_dati => unibus_control_dati,

      clk => nclk
   );

   bootrom2: monitor port map(
      base_addr => o"760000",                   -- monitor preloaded ram

      bus_addr_match => rom2_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rom2_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      reset => cpu_init,
      clk => nclk
   );

--    blockram0: blockram port map(
--       base_addr => o"000000",
--
--       bus_addr_match => rom_addr_match,
--       bus_addr => bus_addr,
--       bus_dati => rom_dati,
--       bus_dato => bus_dato,
--       bus_control_dati => bus_control_dati,
--       bus_control_dato => bus_control_dato,
--       bus_control_datob => bus_control_datob,
--
--       reset => reset,
--       clk => nclk
--    );

  kw0: kw11l port map(
      base_addr => o"777546",
      ivec => o"100",

      br => kw0_br,
      bg => kw0_bg,
      int_vector => kw0_ivec,

      bus_addr_match => kw0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kw0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      have_kw11l => have_kw11l,
      kw11l_hz => kw11l_hz,
      reset => cpu_init,
      clk50mhz => clk50mhz,
      clk => nclk
   );

   have_kl0 <= 1 when have_kl11 >= 1 else 0;
   kl0: kl11 port map(
--      base_addr => o"776510",
--      ivec => o"310",
--      ovec => o"314",
      base_addr => o"777560", -- Console terminal,  normal
      ivec => o"060",
      ovec => o"064",
--      base_addr => o"777550", -- PTR for boot TT
--      ivec => o"070",
--      ovec => o"074",
--      base_addr => o"776500", -- DL11 -B, alternative
--      ivec => o"300",
--      ovec => o"304",

      br => kl0_br,
      bg => kl0_bg,
      int_vector => kl0_ivec,

      bus_addr_match => kl0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kl0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      tx => tx0,
      rx => rx0,
      rts => rts0,
      cts => cts0,
      have_kl11_bps => kl0_bps,
      have_kl11_force7bit => kl0_force7bit,
      have_kl11_rtscts => kl0_rtscts,

      have_kl11 => have_kl0,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   have_kl1 <= 1 when have_kl11 >= 2 else 0;
   kl1: kl11 port map(
      base_addr => o"776510", -- 
      ivec => o"310",
      ovec => o"314",

--      base_addr => o"776500", -- DL11 -B normal 
--      ivec => o"300",
--      ovec => o"304",

--      base_addr => o"777550", -- PTR for boot TT
--      ivec => o"070",
--      ovec => o"074",

--      base_addr => o"777560", -- Console terminal, alternative
--      ivec => o"060",
--      ovec => o"064",

      br => kl1_br,
      bg => kl1_bg,
      int_vector => kl1_ivec,

      bus_addr_match => kl1_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kl1_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      tx => tx1,
      rx => rx1,
      rts => rts1,
      cts => cts1,
      have_kl11_bps => kl1_bps,
      have_kl11_force7bit => kl1_force7bit,
      have_kl11_rtscts => kl1_rtscts,

      have_kl11 => have_kl1,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   have_kl2 <= 1 when have_kl11 >= 3 else 0;
   kl2: kl11 port map(
      base_addr => o"777550", -- PTR for boot TT
      ivec => o"070",
      ovec => o"074",

--      base_addr => o"777560", -- Console terminal,  normal
--      ivec => o"060",
--      ovec => o"064",

--      base_addr => o"776510",
--      ivec => o"310",
--      ovec => o"314",

      br => kl2_br,
      bg => kl2_bg,
      int_vector => kl2_ivec,

      bus_addr_match => kl2_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kl2_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      tx => tx2,
      rx => rx2,
      rts => rts2,
      cts => cts2,
      have_kl11_bps => kl2_bps,
      have_kl11_force7bit => kl2_force7bit,
      have_kl11_rtscts => kl2_rtscts,

      have_kl11 => have_kl2,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   have_kl3 <= 1 when have_kl11 >= 4 else 0;
   kl3: kl11 port map(
      base_addr => o"776520",
      ivec => o"320",
      ovec => o"324",

      br => kl3_br,
      bg => kl3_bg,
      int_vector => kl3_ivec,

      bus_addr_match => kl3_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kl3_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      tx => tx3,
      rx => rx3,
      rts => rts3,
      cts => cts3,
      have_kl11_bps => kl3_bps,
      have_kl11_force7bit => kl3_force7bit,
      have_kl11_rtscts => kl3_rtscts,

      have_kl11 => have_kl3,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   csdr0: csdr port map(
      base_addr => o"777570",

      bus_addr_match => csdr_addr_match,
      bus_addr => unibus_addr,
      bus_dati => csdr_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      have_csdr => have_csdr,

      cs_reg => cons_sw(15 downto 0),
      cd_reg => cons_dr,

      reset => reset,
      clk => nclk
   );

   rl0: rl11 port map(
      base_addr => o"774400",
      ivec => o"160",

      br => rl0_br,
      bg => rl0_bg,
      int_vector => rl0_ivec,

      npr => rl0_npr,
      npg => rl0_npg,

      bus_addr_match => rl0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rl0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      bus_master_addr => rl0_addr,
      bus_master_dati => unibus_busmaster_dati,
      bus_master_dato => rl0_dato,
      bus_master_control_dati => rl0_control_dati,
      bus_master_control_dato => rl0_control_dato,
      bus_master_nxm => busmaster_nxmabort,

      sdcard_cs => rl_sdcard_cs,
      sdcard_mosi => rl_sdcard_mosi,
      sdcard_sclk => rl_sdcard_sclk,
      sdcard_miso => rl_sdcard_miso,
      sdcard_debug => rl_sdcard_debug,

      sdclock => clk,

      have_rl => have_rl,
      have_rl_debug => have_rl_debug,
      reset => cpu_init,
      clk => nclk
   );

   rk0: rk11 port map(
      base_addr => o"777400",
      ivec => o"220",

      br => rk0_br,
      bg => rk0_bg,
      int_vector => rk0_ivec,

      npr => rk0_npr,
      npg => rk0_npg,

      bus_addr_match => rk0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rk0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      bus_master_addr => rk0_addr,
      bus_master_dati => unibus_busmaster_dati,
      bus_master_dato => rk0_dato,
      bus_master_control_dati => rk0_control_dati,
      bus_master_control_dato => rk0_control_dato,
      bus_master_nxm => busmaster_nxmabort,

      sdcard_cs => rk_sdcard_cs,
      sdcard_mosi => rk_sdcard_mosi,
      sdcard_sclk => rk_sdcard_sclk,
      sdcard_miso => rk_sdcard_miso,
      sdcard_debug => rk_sdcard_debug,

      sdclock => clk,

      have_rk => have_rk,
      have_rk_debug => have_rk_debug,
      have_rk_num => have_rk_num,
      have_rk_minimal => have_rk_minimal,
      reset => cpu_init,
      clk => nclk
   );

   rh70_bus_master_nxm <= '1' when addr_match = '0' and cpu_npg = '1' and rh0_npr = '1' and have_rh70 = 1 else '0';
   rh0: rh11 port map(
      base_addr => o"776700",
      ivec => o"254",

      br => rh0_br,
      bg => rh0_bg,
      int_vector => rh0_ivec,

      npr => rh0_npr,
      npg => rh0_npg,

      bus_addr_match => rh0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => rh0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      bus_master_addr => rh0_addr,
      bus_master_dati => unibus_busmaster_dati,
      bus_master_dato => rh0_dato,
      bus_master_control_dati => rh0_control_dati,
      bus_master_control_dato => rh0_control_dato,
      bus_master_nxm => busmaster_nxmabort,

      rh70_bus_master_addr => rh70_bus_master_addr,
      rh70_bus_master_dati => rh70_bus_master_dati,
      rh70_bus_master_dato => rh70_bus_master_dato,
      rh70_bus_master_control_dati => rh70_bus_master_control_dati,
      rh70_bus_master_control_dato => rh70_bus_master_control_dato,
      rh70_bus_master_nxm => rh70_bus_master_nxm,

      sdcard_cs => rh_sdcard_cs,
      sdcard_mosi => rh_sdcard_mosi,
      sdcard_sclk => rh_sdcard_sclk,
      sdcard_miso => rh_sdcard_miso,
      sdcard_debug => rh_sdcard_debug,

      sdclock => clk,

      have_rh => have_rh,
      have_rh70 => have_rh70,
      have_rh_debug => have_rh_debug,
      reset => cpu_init,
      clk => nclk
   );

   xu0: xu port map(
      base_addr => o"774510",
      ivec => o"120",

      br => xu0_br,
      bg => xu0_bg,
      int_vector => xu0_ivec,

      npr => xu0_npr,
      npg => xu0_npg,

      bus_addr_match => xu0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => xu0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      bus_master_addr => xu0_addr,
      bus_master_dati => unibus_busmaster_dati,
      bus_master_dato => xu0_dato,
      bus_master_control_dati => xu0_control_dati,
      bus_master_control_dato => xu0_control_dato,
      bus_master_nxm => busmaster_nxmabort,

-- ethernet, enc424j600 controller interface
      xu_cs => xu_cs,
      xu_mosi => xu_mosi,
      xu_sclk => xu_sclk,
      xu_miso => xu_miso,

-- flags
      have_xu => have_xu,
      have_xu_debug => have_xu_debug,

-- clock & reset
      tx => xu_debug_tx,
      cpuclk => clk,
      nclk => nclk,
      clk50mhz => clk50mhz,
      reset => reset
   );

   dr11c0_ivec1 <= o"300" when have_kl11 = 1
      else o"310" when have_kl11 = 2
      else o"320" when have_kl11 = 3
      else o"330" when have_kl11 = 4
      else o"370";                                                   -- least likely to be in the way
   dr11c0_ivec2 <= dr11c0_ivec1 + o"004";

   dr11c0: dr11c port map(
      base_addr => o"767770",
      ivec1 => dr11c0_ivec1,
      ivec2 => dr11c0_ivec2,

      br => dr11c0_br,
      bg => dr11c0_bg,
      int_vector => dr11c0_ivec,

      bus_addr_match => dr11c0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => dr11c0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      have_dr11c => have_dr11c,
      have_dr11c_loopback => have_dr11c_loopback,
      have_dr11c_signal_stretch => have_dr11c_signal_stretch,
      dr11c_in => dr11c_in,
      dr11c_out => dr11c_out,
      dr11c_reqa => dr11c_reqa,
      dr11c_reqb => dr11c_reqb,
      dr11c_csr0 => dr11c_csr0,
      dr11c_csr1 => dr11c_csr1,
      dr11c_ndr => dr11c_ndr,
      dr11c_ndrlo => dr11c_ndrlo,
      dr11c_ndrhi => dr11c_ndrhi,
      dr11c_dxm => dr11c_dxm,
      dr11c_init => dr11c_init,

      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   nclk <= not clk;
   ifetch <= ifetchcopy;

-- console logic

   cons_run <= cpu_cons_run;
   cons_consphy <= cpu_cons_consphy;
   process(nclk)
   begin
      if nclk = '1' and nclk'event then
         if unibus_control_dati = '1' or unibus_control_dato = '1' then
            cons_progphy <= "1111" & unibus_addr;
         else
--            if bus_control_dati = '1' or bus_control_dato = '1' then
               cons_progphy <= bus_addr;
--             end if;
--             if cpu_cons_run = '1' then                                            -- this bit is to set the addr display to the incremented r7 value during wait/reset
--                cons_progphy <= bus_addr;
--             end if;
--             if cons_exadep = '1' then        -- ehh, what needs to happen is that for the halt states, exadep is driven so the mmu drives the right translation. Then maybe, the
--                cons_progphy <= bus_addr;     -- actual mapping here can be on bus_addr always.
--             end if;
         end if;

         cons_parh <= dati(15) xor dati(14) xor dati(13) xor dati(12) xor dati(11) xor dati(10) xor dati(9) xor dati(8);
         cons_parl <= dati(7) xor dati(6) xor dati(5) xor dati(4) xor dati(3) xor dati(2) xor dati(1) xor dati(0);

      end if;
   end process;

   have_rh70 <= 1 when modelcode = 70 else 0;


   unibus_dati <=
      cr_dati when cr_addr_match = '1'
      else kl0_dati when kl0_addr_match = '1'
      else kl1_dati when kl1_addr_match = '1'
      else kl2_dati when kl2_addr_match = '1'
      else kl3_dati when kl3_addr_match = '1'
      else kw0_dati when kw0_addr_match = '1'
      else csdr_dati when csdr_addr_match = '1'
      else rom0_dati when rom0_addr_match = '1'
      else rom1_dati when rom1_addr_match = '1'
      else rom2_dati when rom2_addr_match = '1'
      else rl0_dati when rl0_addr_match = '1'
      else rk0_dati when rk0_addr_match = '1'
      else rh0_dati when rh0_addr_match = '1'
      else xu0_dati when xu0_addr_match = '1'
      else dr11c0_dati when dr11c0_addr_match = '1'
      else "0000000000000000";

   unibus_addr_match <= '1'
      when cr_addr_match = '1'
      or kl0_addr_match = '1'
      or kl1_addr_match = '1'
      or kl2_addr_match = '1'
      or kl3_addr_match = '1'
      or kw0_addr_match = '1'
      or csdr_addr_match = '1'
      or rom0_addr_match = '1'
      or rom1_addr_match = '1'
      or rom2_addr_match = '1'
      or rl0_addr_match = '1'
      or rk0_addr_match = '1'
      or rh0_addr_match = '1'
      or xu0_addr_match = '1'
      or dr11c0_addr_match = '1'
--      or addr_match = '1'
      else '0';

   cer_nxmabort <= '1'
      when addr_match = '0'
      and (bus_control_dati = '1' or bus_control_dato = '1')
      and bus_unibus_mapped = '0'
      and cpu_npg = '0'
      else '0';

   cer_ioabort <= '1'
      when unibus_addr_match = '0' and (unibus_control_dati = '1' or unibus_control_dato = '1') and unibus_addr(17 downto 13) = "11111" and cpu_npg = '0'
      else '1' when addr_match = '0' and bus_unibus_mapped = '1' and (bus_control_dati = '1' or bus_control_dato = '1') and cpu_npg = '0'
      else '0';

   nxmabort <= '1' when cer_nxmabort = '1' or cer_ioabort = '1' else '0';

   oddabort <=
      '1' when bus_control_dato = '1' and bus_control_datob = '0' and bus_addr(0) = '1'
      else '1' when ifetchcopy = '1' and unibus_control_dati = '1' and unibus_addr(17 downto 13) = "11111" and rom0_addr_match /= '1' and rom1_addr_match /= '1' and rom2_addr_match /= '1'
      else '1' when mmu_oddabort = '1'
      else '0';

   busmaster_nxmabort <=
      '1' when cpu_npg = '1' and unibus_addr_match = '0' and (unibus_control_dati = '1' or unibus_control_dato = '1') and unibus_addr(17 downto 13) = "11111"      -- FIXME, why is this needed again?
      else '1' when cpu_npg = '1' and addr_match = '0' and (bus_control_dati = '1' or bus_control_dato = '1') and have_rh70 = 0
      else '0';

   unibus_busmaster_addr <= rl0_addr when rl0_npg = '1'
      else rk0_addr when rk0_npg = '1'
      else rh0_addr when rh0_npg = '1' and have_rh70 = 0
      else xu0_addr when xu0_npg = '1'
      else "000000000000000000";
   unibus_busmaster_dato <= rl0_dato when rl0_npg = '1'
      else rk0_dato when rk0_npg = '1'
      else rh0_dato when rh0_npg = '1' and have_rh70 = 0
      else xu0_dato when xu0_npg = '1'
      else "0000000000000000";
   unibus_busmaster_control_dati <= rl0_control_dati when rl0_npg = '1'
      else rk0_control_dati when rk0_npg = '1'
      else rh0_control_dati when rh0_npg = '1' and have_rh70 = 0
      else xu0_control_dati when xu0_npg = '1'
      else '0';
   unibus_busmaster_control_dato <= rl0_control_dato when rl0_npg = '1'
      else rk0_control_dato when rk0_npg = '1'
      else rh0_control_dato when rh0_npg = '1' and have_rh70 = 0
      else xu0_control_dato when xu0_npg = '1'
      else '0';
   unibus_busmaster_control_datob <= '0' when rl0_npg = '1'
      else '0' when rk0_npg = '1'
      else '0' when rh0_npg = '1' and have_rh70 = 0
      else '0' when xu0_npg = '1'
      else '0';
   unibus_busmaster_control_npg <= '1' when rl0_npg = '1'
      else '1' when rk0_npg = '1'
      else '1' when rh0_npg = '1' and have_rh70 = 0
      else '1' when xu0_npg = '1'
      else '0';

-- regular memory interface and rh70 interface to it
   addr <= rh70_bus_master_addr when rh0_npg = '1' and have_rh70 = 1
      else bus_addr;
   dato <= rh70_bus_master_dato when rh0_npg = '1' and have_rh70 = 1
      else bus_dato;
   bus_dati <= dati;
   rh70_bus_master_dati <= dati;
   control_dati <= rh70_bus_master_control_dati when rh0_npg = '1' and have_rh70 = 1
      else bus_control_dati;
   control_dato <= rh70_bus_master_control_dato when rh0_npg = '1' and have_rh70 = 1
      else bus_control_dato;
   control_datob <= '0' when rh0_npg = '1' and have_rh70 = 1
      else bus_control_datob;

   cpu_addr_v <= cpu_addr;

   cpu_br7 <= '0';
   cpu_br6 <= kw0_br;
   kw0_bg <= cpu_bg6;
   cpu_int_vector6 <= kw0_ivec;

-- npr logic

   process(nclk, reset)
   begin
      if nclk = '1' and nclk'event then
         if reset = '1' then
            cpu_npr <= '0';
--            cpu_br7 <= '0';
--            cpu_br6 <= '0';
            cpu_br5 <= '0';
            cpu_br4 <= '0';
         else

            case npr_state is
               when npr_idle =>
                  cpu_npr <= '0';
                  rl0_npg <= '0';
                  rk0_npg <= '0';
                  rh0_npg <= '0';
                  xu0_npg <= '0';

                  if rl0_npr = '1' then
                     npr_state <=   npr_rl0;
                  elsif rk0_npr = '1' then
                     npr_state <= npr_rk0;
                  elsif rh0_npr = '1' then
                     npr_state <= npr_rh0;
                  elsif xu0_npr = '1' then
                     npr_state <= npr_xu0;
                  end if;

               when npr_rl0 =>
                  cpu_npr <= '1';
                  if rl0_npr = '0' then
                     npr_state <= npr_idle;
                     rl0_npg <= '0';
                  else
                     rl0_npg <= cpu_npg;
                  end if;

               when npr_rk0 =>
                  cpu_npr <= '1';
                  if rk0_npr = '0' then
                     npr_state <= npr_idle;
                     rk0_npg <= '0';
                  else
                     rk0_npg <= cpu_npg;
                  end if;

               when npr_rh0 =>
                  cpu_npr <= '1';
                  if rh0_npr = '0' then
                     npr_state <= npr_idle;
                     rh0_npg <= '0';
                  else
                     rh0_npg <= cpu_npg;
                  end if;

               when npr_xu0 =>
                  cpu_npr <= '1';
                  if xu0_npr = '0' then
                     npr_state <= npr_idle;
                     xu0_npg <= '0';
                  else
                     xu0_npg <= cpu_npg;
                  end if;

               when others =>
                  npr_state <= npr_idle;

            end case;

            case br5_state is

               when br5_idle =>
                  if rh0_br = '1' then
                     br5_state <= br5_rh0;
                     cpu_br5 <= rh0_br;
                  elsif xu0_br = '1' then
                     br5_state <= br5_xu0;
                     cpu_br5 <= xu0_br;
                  elsif rl0_br = '1' then
                     br5_state <= br5_rl0;
                     cpu_br5 <= rl0_br;
                  elsif rk0_br = '1' then
                     br5_state <= br5_rk0;
                     cpu_br5 <= rk0_br;
                  elsif dr11c0_br = '1' then
                     br5_state <= br5_dr11c0;
                     cpu_br5 <= dr11c0_br;
                  else
                     cpu_br5 <= '0';
                  end if;

               when br5_rh0 =>
                  cpu_br5 <= rh0_br;
                  rh0_bg <= cpu_bg5;
                  cpu_int_vector5 <= rh0_ivec;
                  if rh0_br = '0' and rh0_bg = '0' then
                     br5_state <= br5_idle;
                  end if;

               when br5_xu0 =>
                  cpu_br5 <= xu0_br;
                  xu0_bg <= cpu_bg5;
                  cpu_int_vector5 <= xu0_ivec;
                  if xu0_br = '0' and xu0_bg = '0' then
                     br5_state <= br5_idle;
                  end if;

               when br5_rl0 =>
                  cpu_br5 <= rl0_br;
                  rl0_bg <= cpu_bg5;
                  cpu_int_vector5 <= rl0_ivec;
                  if rl0_br = '0' and rl0_bg = '0' then
                     br5_state <= br5_idle;
                  end if;

               when br5_rk0 =>
                  cpu_br5 <= rk0_br;
                  rk0_bg <= cpu_bg5;
                  cpu_int_vector5 <= rk0_ivec;
                  if rk0_br = '0' and rk0_bg = '0' then
                     br5_state <= br5_idle;
                  end if;

               when br5_dr11c0 =>
                  cpu_br5 <= dr11c0_br;
                  dr11c0_bg <= cpu_bg5;
                  cpu_int_vector5 <= dr11c0_ivec;
                  if dr11c0_br = '0' and dr11c0_bg = '0' then
                     br5_state <= br5_idle;
                  end if;

               when others =>
                  br5_state <= br5_idle;

            end case;

            case br4_state is

               when br4_idle =>
                  if kl0_br = '1' then
                     br4_state <= br4_kl0;
                     cpu_br4 <= kl0_br;
                  elsif kl1_br = '1' then
                     br4_state <= br4_kl1;
                     cpu_br4 <= kl1_br;
                  elsif kl2_br = '1' then
                     br4_state <= br4_kl2;
                     cpu_br4 <= kl2_br;
                  elsif kl3_br = '1' then
                     br4_state <= br4_kl3;
                     cpu_br4 <= kl3_br;
                  else
                     cpu_br4 <= '0';
                  end if;

               when br4_kl0 =>
                  cpu_br4 <= kl0_br;
                  kl0_bg <= cpu_bg4;
                  cpu_int_vector4 <= kl0_ivec;
                  if kl0_br = '0' and kl0_bg = '0' then
                     br4_state <= br4_idle;
                  end if;

               when br4_kl1 =>
                  cpu_br4 <= kl1_br;
                  kl1_bg <= cpu_bg4;
                  cpu_int_vector4 <= kl1_ivec;
                  if kl1_br = '0' and kl1_bg = '0' then
                     br4_state <= br4_idle;
                  end if;

               when br4_kl2 =>
                  cpu_br4 <= kl2_br;
                  kl2_bg <= cpu_bg4;
                  cpu_int_vector4 <= kl2_ivec;
                  if kl2_br = '0' and kl2_bg = '0' then
                     br4_state <= br4_idle;
                  end if;

               when br4_kl3 =>
                  cpu_br4 <= kl3_br;
                  kl3_bg <= cpu_bg4;
                  cpu_int_vector4 <= kl3_ivec;
                  if kl3_br = '0' and kl3_bg = '0' then
                     br4_state <= br4_idle;
                  end if;

               when others =>
                  br4_state <= br4_idle;

            end case;


         end if;
      end if;
   end process;

end implementation;

