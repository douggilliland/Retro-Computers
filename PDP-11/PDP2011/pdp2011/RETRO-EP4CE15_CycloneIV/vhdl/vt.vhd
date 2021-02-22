
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

-- $Revision: 1.16 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vt is
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
end vt;

architecture implementation of vt is

component cpu is
   port(
      addr_v : out std_logic_vector(15 downto 0);
      datain : in std_logic_vector(15 downto 0);
      dataout : out std_logic_vector(15 downto 0);
      wr : out std_logic;
      rd : out std_logic;
      dw8 : out std_logic;
      cp : out std_logic;
      ifetch : out std_logic;
      iwait : out std_logic;
      id : out std_logic;
      init : out std_logic;

      br7 : in std_logic;
      bg7 : out std_logic;
      int_vector7 : in std_logic_vector(8 downto 0);
      br6 : in std_logic;
      bg6 : out std_logic;
      int_vector6 : in std_logic_vector(8 downto 0);
      br5 : in std_logic;
      bg5 : out std_logic;
      int_vector5 : in std_logic_vector(8 downto 0);
      bg4 : out std_logic;
      br4 : in std_logic;
      int_vector4 : in std_logic_vector(8 downto 0);

      mmutrap : in std_logic;
      ack_mmutrap : out std_logic;
      mmuabort : in std_logic;
      ack_mmuabort : out std_logic;

      npr : in std_logic;
      npg : out std_logic;

      nxmabort : in std_logic;
      oddabort : in std_logic;
      illhalt : out std_logic;
      ysv : out std_logic;
      rsv : out std_logic;

      cpu_stack_limit : in std_logic_vector(15 downto 0);
      cpu_kmillhalt : in std_logic;

      sr0_ic : out std_logic;
      sr1 : out std_logic_vector(15 downto 0);
      sr2 : out std_logic_vector(15 downto 0);
      dstfreference : out std_logic;
      sr3csmenable : in std_logic;

      psw_in : in std_logic_vector(15 downto 0);
      psw_in_we_even : in std_logic;
      psw_in_we_odd : in std_logic;
      psw_out : out std_logic_vector(15 downto 0);

      pir_in : in std_logic_vector(15 downto 0);

      modelcode : in integer range 0 to 255;
      init_r7 : in std_logic_vector(15 downto 0) := x"f600";         -- start address after reset = o'173000' = m9312 hi rom
      init_psw : in std_logic_vector(15 downto 0) := x"00e0";        -- initial psw for kernel mode, primary register set, priority 7

      clk : in std_logic;
      reset : in std_logic
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

component blockram is
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
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      vga_cursor : in std_logic_vector(12 downto 0);

      vga_hsync : out std_logic;
      vga_vsync : out std_logic;
      vga_out : out std_logic;

      reset : in std_logic;
      clk : in std_logic;
      clk50mhz : in std_logic
   );
end component;

component vgacr is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      vga_cursor : out std_logic_vector(12 downto 0);

      reset : in std_logic;
      clk : in std_logic
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
constant init_r7 : std_logic_vector(15 downto 0) := x"0200";         -- start address after reset = o'173000' = m9312 hi rom
constant init_psw : std_logic_vector(15 downto 0) := x"00e0";        -- initial psw for kernel mode, primary register set, priority 7

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
signal vga_cursor : std_logic_vector(12 downto 0);
signal vgacr_addr_match : std_logic;
signal vgacr_dati : std_logic_vector(15 downto 0);

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
      have_kl11_bps => 9600,
      have_kl11_force7bit => 1,
      have_kl11_rtscts => 0,
      clk50mhz => clk50mhz,
      reset => cpu_init,
      clk => nclk
   );

   blockram0: blockram port map(
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

      vga_hsync => vga_hsync,
      vga_vsync => vga_vsync,
      vga_out => vga_out,

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

      reset => reset,
      clk => nclk
   );

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

