
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

entity vt is
   port(
      vga_hsync	: out std_logic;						-- horizontal sync
      vga_vsync	: out std_logic;						-- vertical sync
      vga_fb		: out std_logic;						-- output - full
      vga_ht		: out std_logic;						-- output - half

-- serial port
      tx				: out std_logic;						-- transmit
      rx				: in std_logic;						-- receive
      rts			: out std_logic;						-- request to send
      cts			: in std_logic := '0';				-- clear to send
      bps			: in integer range 1200 to 230400 := 9600;	-- bps rate - don't set to more than 38400
      force7bit	: in integer range 0 to 1 := 0;	-- zero out high order bit on transmission and reception
      rtscts		: in integer range 0 to 1 := 0;	-- conditional compilation switch for rts and cts signals; also implies to include core that implements a silo buffer

-- ps2 keyboard
      ps2k_c : in std_logic;                                         -- clock
      ps2k_d : in std_logic;                                         -- data

-- debug & blinkenlights
      ifetch : out std_logic;                                        -- ifetch : the cpu is running an instruction fetch cycle
      iwait : out std_logic;                                         -- iwait : the cpu is in wait state
      teste : in std_logic := '0';                                   -- teste : display 24*80 capital E without changing the display buffer
      testf : in std_logic := '0';                                   -- testf : display 24*80 all pixels on
      vga_debug : out std_logic_vector(15 downto 0);                 -- debug output from microcode
      vga_bl : out std_logic_vector(9 downto 0);                     -- blinkenlight vector

-- vt type code : 100 or 105
      vttype : in integer range 100 to 105 := 100;                   -- vt100 or vt105
      vga_cursor_block : in std_logic := '1';                        -- cursor is block ('1') or underline ('0')
      vga_cursor_blink : in std_logic := '0';                        -- cursor blinks ('1') or not ('0')
      have_act_seconds : in integer range 0 to 7200 := 900;          -- auto screen off time, in seconds; 0 means disabled
      have_act : in integer range 1 to 2 := 2;                       -- auto screen off counter reset by keyboard and serial port activity (1) or keyboard only (2)

-- clock & reset
      cpuclk : in std_logic;                                         -- cpuclk : should be around 10MHz, give or take a few
      clk50mhz : in std_logic;                                       -- clk50mhz : used for vga signal timing
      reset : in std_logic                                           -- reset
   );
end vt;

architecture implementation of vt is

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

      -- lma (f11)
      mmu_lma_c1 : out std_logic;
      mmu_lma_c0 : out std_logic;
      mmu_lma_eub : out std_logic_vector(21 downto 0);

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

      cons_exadep : in std_logic := '0';
      cons_consphy : in std_logic_vector(21 downto 0) := (others => '0');
      cons_adss_mode : in std_logic_vector(1 downto 0) := (others => '0');
      cons_adss_id : in std_logic := '0';
      cons_adss_cons : in std_logic := '0';
      cons_map16 : out std_logic;
      cons_map18 : out std_logic;
      cons_map22 : out std_logic;
      cons_id : out std_logic;

      modelcode : in integer range 0 to 255;
      sr0out_debug : out std_logic_vector(15 downto 0);
      have_odd_abort : out integer range 0 to 255;

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

-- lma (f11)
      mmu_lma_c1 : in std_logic := '0';
      mmu_lma_c0 : in std_logic := '0';
      mmu_lma_eub : in std_logic_vector(21 downto 0) := (others => '0');

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

component vtbr is
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

component vga is
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
end component;

component vgacr is
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
      vga_marker0 : out std_logic;                                   -- vt105 marker0 enabled
      vga_marker1 : out std_logic;                                   -- vt105 marker1 enabled
      vga_graph0s : out std_logic;                                   -- vt105 graph0 shading enabled
      vga_graph1s : out std_logic;                                   -- vt105 graph1 shading enabled
      vga_strip0 : out std_logic;                                    -- vt105 strip chart enabled
      vga_strip1 : out std_logic;                                    -- vt105 dual strip chart enabled
      vga_square : out std_logic;                                    -- vt105 graphics square format

      vga_acth : out std_logic_vector(7 downto 0);                   -- act counter, high byte (serial port activity)
      vga_actl : out std_logic_vector(7 downto 0);                   -- act counter, low byte (keyboard activity)

      vga_debug : out std_logic_vector(15 downto 0);                 -- debug output from microcode

      vttype : in integer range 100 to 105;                          -- conditional compilation; valid values are 100 and 105

      reset : in std_logic;                                          -- reset
      clk : in std_logic                                             -- bus clock
   );
end component;

component ps2 is
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

      ps2k_c : in std_logic;
      ps2k_d : in std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end component;

constant modelcode : integer := 20;
constant init_r7 : std_logic_vector(15 downto 0) := x"0200";         -- cpu starts at 1000 octal, 0x0200 hex
constant init_psw : std_logic_vector(15 downto 0) := x"00e0";        -- initial psw: priority 7

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

signal bus_unibus_mapped : std_logic;

signal bus_addr : std_logic_vector(21 downto 0);
signal bus_dati : std_logic_vector(15 downto 0);
signal bus_dato : std_logic_vector(15 downto 0);
signal bus_control_dati : std_logic;
signal bus_control_dato : std_logic;
signal bus_control_datob : std_logic;

signal busmaster_nxmabort : std_logic;

signal bus_addr_match : std_logic;
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

signal kl0_addr_match : std_logic;
signal kl0_dati : std_logic_vector(15 downto 0);

signal ps2_addr_match : std_logic;
signal ps2_dati : std_logic_vector(15 downto 0);

signal ram_addr_match : std_logic;
signal ram_dati : std_logic_vector(15 downto 0);

signal vga_addr_match : std_logic;
signal vga_dati : std_logic_vector(15 downto 0);
signal vgacr_addr_match : std_logic;
signal vgacr_dati : std_logic_vector(15 downto 0);

signal vga_cursor : std_logic_vector(12 downto 0);
signal vga_shade0 : std_logic_vector(7 downto 0);
signal vga_shade1 : std_logic_vector(7 downto 0);
signal vga_xp : std_logic_vector(8 downto 0);
signal vga_acth : std_logic_vector(7 downto 0);
signal vga_actl : std_logic_vector(7 downto 0);

signal vga_graphics : std_logic;
signal vga_graph0 : std_logic;
signal vga_graph1 : std_logic;
signal vga_hist0 : std_logic;
signal vga_hist1 : std_logic;
signal vga_hlines : std_logic;
signal vga_vlines : std_logic;
signal vga_marker0 : std_logic;
signal vga_marker1 : std_logic;
signal vga_graph0s : std_logic;
signal vga_graph1s : std_logic;
signal vga_strip0 : std_logic;
signal vga_strip1 : std_logic;
signal vga_square : std_logic;

signal cer_nxmabort : std_logic;
signal cer_ioabort : std_logic;

signal cpu_stack_limit : std_logic_vector(15 downto 0);
signal cpu_kmillhalt : std_logic;

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
      br7 => '0',
      int_vector7 => o"000",
      br6 => '0',
      int_vector6 => o"000",
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
      init_r7 => init_r7,
      init_psw => init_psw,
      clk => cpuclk,
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

      reset => cpu_init,
      clk => nclk
   );

  kl0: kl11 port map(
      base_addr => o"777560",
      ivec => o"060",
      ovec => o"064",

      br => cpu_br4,
      bg => cpu_bg4,
      int_vector => cpu_int_vector4,

      bus_addr_match => kl0_addr_match,
      bus_addr => unibus_addr,
      bus_dati => kl0_dati,
      bus_dato => unibus_dato,
      bus_control_dati => unibus_control_dati,
      bus_control_dato => unibus_control_dato,
      bus_control_datob => unibus_control_datob,

      tx => tx,
      rx => rx,
      cts => '0',
      have_kl11 => 1,
      have_kl11_bps => bps,
      have_kl11_force7bit => force7bit,
      have_kl11_rtscts => rtscts,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   vtbr0: vtbr port map(
      base_addr => o"000000",

      bus_addr_match => ram_addr_match,
      bus_addr => bus_addr(17 downto 0),
      bus_dati => ram_dati,
      bus_dato => bus_dato,
      bus_control_dati => bus_control_dati,
      bus_control_dato => bus_control_dato,
      bus_control_datob => bus_control_datob,

      reset => reset,
      clk => nclk
   );

   vga0: vga port map(
      base_addr => o"100000",

      bus_addr_match => vga_addr_match,
      bus_addr => bus_addr(17 downto 0),
      bus_dati => vga_dati,
      bus_dato => bus_dato,
      bus_control_dati => bus_control_dati,
      bus_control_dato => bus_control_dato,
      bus_control_datob => bus_control_datob,

      vga_cursor => vga_cursor,
      vga_shade0 => vga_shade0,
      vga_shade1 => vga_shade1,
      vga_xp => vga_xp,
      vga_graphics => vga_graphics,
      vga_graph0 => vga_graph0,
      vga_graph1 => vga_graph1,
      vga_hist0 => vga_hist0,
      vga_hist1 => vga_hist1,
      vga_hlines => vga_hlines,
      vga_vlines => vga_vlines,
      vga_marker0 => vga_marker0,
      vga_marker1 => vga_marker1,
      vga_graph0s => vga_graph0s,
      vga_graph1s => vga_graph1s,
      vga_strip0 => vga_strip0,
      vga_strip1 => vga_strip1,
      vga_square => vga_square,

      vga_acth => vga_acth,
      vga_actl => vga_actl,

      vga_hsync => vga_hsync,
      vga_vsync => vga_vsync,
      vga_fb => vga_fb,
      vga_ht => vga_ht,

      teste => teste,
      testf => testf,

      vga_cursor_block => vga_cursor_block,
      vga_cursor_blink => vga_cursor_blink,

      vttype => vttype,
      have_act_seconds => have_act_seconds,
      have_act => have_act,

      reset => reset,
      clk50mhz => clk50mhz,
      clk => nclk
   );

   vgacr0: vgacr port map(
      base_addr => o"140000",

      bus_addr_match => vgacr_addr_match,
      bus_addr => bus_addr(17 downto 0),
      bus_dati => vgacr_dati,
      bus_dato => bus_dato,
      bus_control_dati => bus_control_dati,
      bus_control_dato => bus_control_dato,
      bus_control_datob => bus_control_datob,

      vga_cursor => vga_cursor,
      vga_shade0 => vga_shade0,
      vga_shade1 => vga_shade1,
      vga_xp => vga_xp,
      vga_debug => vga_debug,
      vga_graphics => vga_graphics,
      vga_graph0 => vga_graph0,
      vga_graph1 => vga_graph1,
      vga_hist0 => vga_hist0,
      vga_hist1 => vga_hist1,
      vga_hlines => vga_hlines,
      vga_vlines => vga_vlines,
      vga_marker0 => vga_marker0,
      vga_marker1 => vga_marker1,
      vga_graph0s => vga_graph0s,
      vga_graph1s => vga_graph1s,
      vga_strip0 => vga_strip0,
      vga_strip1 => vga_strip1,
      vga_square => vga_square,

      vga_acth => vga_acth,
      vga_actl => vga_actl,

      vttype => vttype,

      reset => reset,
      clk => nclk
   );

   vga_bl(0) <= vga_graphics;
   vga_bl(1) <= vga_square;
   vga_bl(2) <= vga_graph0;
   vga_bl(3) <= vga_graph1;
   vga_bl(4) <= vga_marker0;
   vga_bl(5) <= vga_marker1;
   vga_bl(6) <= vga_graph0s;
   vga_bl(7) <= vga_graph1s;
   vga_bl(8) <= vga_hist0;
   vga_bl(9) <= vga_hist1;

   ps20: ps2 port map(
      base_addr => o"150000",
      ivec => o"070",

      br => cpu_br5,
      bg => cpu_bg5,
      int_vector => cpu_int_vector5,

      bus_addr_match => ps2_addr_match,
      bus_addr => bus_addr(17 downto 0),
      bus_dati => ps2_dati,
      bus_dato => bus_dato,
      bus_control_dati => bus_control_dati,
      bus_control_dato => bus_control_dato,
      bus_control_datob => bus_control_datob,

      ps2k_c => ps2k_c,
      ps2k_d => ps2k_d,

      reset => reset,
      clk => nclk
   );

   nclk <= not cpuclk;
   ifetch <= ifetchcopy;

   bus_addr_match <=
      '1' when ram_addr_match = '1'
      or vga_addr_match = '1'
      or vgacr_addr_match = '1'
      or ps2_addr_match = '1'
      else '0';

   bus_dati <=
      ram_dati when ram_addr_match = '1'
      else vga_dati when vga_addr_match = '1'
      else vgacr_dati when vgacr_addr_match = '1'
      else ps2_dati when ps2_addr_match = '1'
      else "0000000000000000";

   unibus_dati <=
      cr_dati when cr_addr_match = '1'
      else kl0_dati when kl0_addr_match = '1'
      else "0000000000000000";

   unibus_addr_match <= '1'
      when cr_addr_match = '1'
      or kl0_addr_match = '1'
      else '0';

   cer_nxmabort <= '1'
      when ram_addr_match = '0'
      and vga_addr_match = '0'
      and vgacr_addr_match = '0'
      and ps2_addr_match = '0'
      and (bus_control_dati = '1' or bus_control_dato = '1')
      and bus_unibus_mapped = '0'
      and cpu_npg = '0'
      else '0';

   cer_ioabort <= '1'
      when unibus_addr_match = '0' and (unibus_control_dati = '1' or unibus_control_dato = '1') and unibus_addr(17 downto 13) = "11111" and cpu_npg = '0'
      else '1' when ram_addr_match = '0' and bus_unibus_mapped = '1' and (bus_control_dati = '1' or bus_control_dato = '1') and cpu_npg = '0'
      else '0';

   nxmabort <= '1' when cer_nxmabort = '1' or cer_ioabort = '1' else '0';

   oddabort <=
      '1' when bus_control_dato = '1' and bus_control_datob = '0' and bus_addr(0) = '1'
      else '1' when ifetchcopy = '1' and unibus_control_dati = '1' and unibus_addr(17 downto 13) = "11111" and ram_addr_match /= '1'  -- FIXME???
      else '1' when mmu_oddabort = '1'
      else '0';

   busmaster_nxmabort <= '0';
   unibus_busmaster_addr <= "000000000000000000";
   unibus_busmaster_dato <= "0000000000000000";
   unibus_busmaster_control_dati <= '0';
   unibus_busmaster_control_dato <= '0';
   unibus_busmaster_control_datob <= '0';
   unibus_busmaster_control_npg <= '0';

   cpu_npr <= '0';

end implementation;

