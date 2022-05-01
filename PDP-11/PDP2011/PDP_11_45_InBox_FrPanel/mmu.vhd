
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

entity mmu is
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
end mmu;

architecture implementation of mmu is

signal sr0 : std_logic_vector(15 downto 0) := x"0000";
signal sr0out : std_logic_vector(15 downto 0);
signal sr1 :  std_logic_vector(15 downto 0) := x"0000";
signal sr1out : std_logic_vector(15 downto 0);
signal sr2 :  std_logic_vector(15 downto 0) := x"0000";
signal sr3 : std_logic_vector(5 downto 0) := "000000";
signal sr3id : std_logic;
signal sr3out : std_logic_vector(5 downto 0);

signal psw_mmumode : std_logic_vector(1 downto 0);
signal psw_mmumodelegal : std_logic;

signal par : std_logic_vector(15 downto 0);
signal pdr : std_logic_vector(15 downto 0);
signal pdra : std_logic;
signal pdrw : std_logic;
signal parout : std_logic_vector(15 downto 0);
signal pdrout : std_logic_vector(15 downto 0);

signal addr_p : std_logic_vector(21 downto 0);

signal addr_p18 : std_logic_vector(17 downto 6);
signal addr_p22 : std_logic_vector(21 downto 6);
signal addr_p24z1 : std_logic_vector(23 downto 0);
signal addr_p24z5 : std_logic_vector(23 downto 0);
signal mmu_datain : std_logic_vector(15 downto 0);

signal ppraddr : std_logic_vector(5 downto 0);

signal par0o : std_logic_vector(7 downto 0);
signal par1o : std_logic_vector(7 downto 0);
signal pdr0o : std_logic_vector(3 downto 0);
signal pdr1o : std_logic_vector(7 downto 0);

signal paro2 : std_logic_vector(15 downto 0);
signal pdro2 : std_logic_vector(15 downto 0);
signal paro2valid : std_logic;
signal pdro2valid : std_logic;

type wbit_array is array(15 downto 0) of std_logic;
signal kpdr_w : wbit_array;
signal spdr_w : wbit_array;
signal updr_w : wbit_array;
type abit_array is array(15 downto 0) of std_logic;
signal kpdr_a : abit_array;
signal spdr_a : abit_array;
signal updr_a : abit_array;

signal abort_nonresident : std_logic;
signal abort_pagelength : std_logic;
signal abort_readonly : std_logic;
signal mmu_mmuabort : std_logic;
signal trap_mm : std_logic;

signal oddabort : std_logic;
signal oddaddress : std_logic;

signal mmu_addr_match : std_logic;

signal abort_acknowledged : std_logic;

signal mmu_dato : std_logic_vector(15 downto 0);

-- unibus map
signal ubmraddr : std_logic_vector(4 downto 0);
signal ubmo : std_logic_vector(21 downto 0);
signal ubmo2 : std_logic_vector(21 downto 0);
signal ubmo2valid : std_logic;
signal ubmmaddr : std_logic_vector(21 downto 0);

subtype ubmb0_unit is std_logic_vector(7 downto 1);
type ubmb0_type is array(31 downto 0) of ubmb0_unit;
signal ubmb0 : ubmb0_type := ubmb0_type'(
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000"),
   ubmb0_unit'("0000000")
);

subtype ubmb1_unit is std_logic_vector(7 downto 0);
type ubmb1_type is array(31 downto 0) of ubmb1_unit;
signal ubmb1 : ubmb1_type := ubmb1_type'(
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000"),
   ubmb1_unit'("00000000")
);

subtype ubmb2_unit is std_logic_vector(5 downto 0);
type ubmb2_type is array(31 downto 0) of ubmb2_unit;
signal ubmb2 : ubmb2_type := ubmb2_type'(
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000"),
   ubmb2_unit'("000000")
);

-- par
subtype par1_unit is std_logic_vector(7 downto 0);
type par1_type is array(15 downto 0) of par1_unit;
signal par1_00 : par1_type := par1_type'(
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000")
);
signal par1_01 : par1_type := par1_type'(
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000")
);
signal par1_11 : par1_type := par1_type'(
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000"),
   par1_unit'("00000000")
);

subtype par0_unit is std_logic_vector(7 downto 0);
type par0_type is array(15 downto 0) of par0_unit;
signal par0_00 : par0_type := par0_type'(
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),             -- kipar 7
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000")
);
signal par0_01 : par0_type := par0_type'(
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000")
);
signal par0_11 : par0_type := par0_type'(
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000"),
   par0_unit'("00000000")
);

-- pdr
subtype pdr1_unit is std_logic_vector(7 downto 0);
type pdr1_type is array(15 downto 0) of pdr1_unit;
signal pdr1_00 : pdr1_type := pdr1_type'(
   pdr1_unit'("00000000"),             -- kdpdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),             -- kdpdr0
   pdr1_unit'("00000000"),             -- kipdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000")              -- kipdr0
);
signal pdr1_01 : pdr1_type := pdr1_type'(
   pdr1_unit'("00000000"),             -- sdpdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),             -- sdpdr0
   pdr1_unit'("00000000"),             -- sipdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000")              -- sipdr0
);
signal pdr1_11 : pdr1_type := pdr1_type'(
   pdr1_unit'("00000000"),             -- udpdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),             -- udpdr0
   pdr1_unit'("00000000"),             -- uipdr7
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000"),
   pdr1_unit'("00000000")              -- uipdr0
);

subtype pdr0_unit is std_logic_vector(3 downto 0);
type pdr0_type is array(15 downto 0) of pdr0_unit;
signal pdr0_00 : pdr0_type := pdr0_type'(
   pdr0_unit'("0000"),                 -- kdpdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),                 -- kdpdr0
   pdr0_unit'("0000"),                 -- kipdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000")                  -- kipdr0
);
signal pdr0_01 : pdr0_type := pdr0_type'(
   pdr0_unit'("0000"),                 -- sdpdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),                 -- sdpdr0
   pdr0_unit'("0000"),                 -- sipdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000")                  -- sipdr0
);
signal pdr0_11 : pdr0_type := pdr0_type'(
   pdr0_unit'("0000"),                 -- udpdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),                 -- udpdr0
   pdr0_unit'("0000"),                 -- uipdr7
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000"),
   pdr0_unit'("0000")                  -- uipdr0
);


-- configuration stuff
signal have_mmu22 : integer range 0 to 1;
signal have_1920 : integer range 0 to 1;
signal have_mmumm : integer range 0 to 1;
signal have_mmutr : integer range 0 to 1;
signal have_mmu : integer range 0 to 1;
signal have_ubm : integer range 0 to 1;
signal have_pdr15 : integer range 0 to 1;
signal have_pdra : integer range 0 to 1;
signal have_pdrw : integer range 0 to 1;
signal have_acf3 : integer range 0 to 1;
signal have_acf2 : integer range 0 to 1;
signal have_sr0ic : integer range 0 to 1;
signal have_sr1zero : integer range 0 to 1;
signal have_id : integer range 0 to 1;
signal have_sup : integer range 0 to 1;
signal have_sr3 : integer range 0 to 1;

signal have_csm : integer range 0 to 1;
signal have_oddabort : integer range 0 to 1;


begin

-- cpu model configuration

   with modelcode select have_mmu22 <= -- does the mmu have 22 bit mode
      1 when 23 | 24,                        -- kdf11
      1 when 44,
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_1920 <=  -- for 22-bit, does memory end at 1920KWords
      1 when 24,                             -- kdf11 but not 11/23, I'd speculate
      1 when 44,
      1 when 70,
      0 when others;

   with modelcode select have_mmumm <= -- does the mmu have the maintenance mode bit in sr0
      1 when 34 | 35 | 40,                   -- kt11d!
      1 when 44,
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 60,
      1 when 70,
      0 when others;

   with modelcode select have_mmutr <= -- does the mmu implement trap on access
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      0 when others;

   with modelcode select have_mmu <=   -- master switch - is there an mmu at all
      1 when 23 | 24,                        -- kdf11
      1 when 34 | 35 | 40,                   -- kt11d!
      1 when 44,
      1 when 45 | 50 | 55,
      1 when 60,
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_ubm <=   -- does the system have the unibus map
      1 when 24,
      1 when 44,
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11 FIXME, this incorrectly causes the non-unibus systems to include the map - probably incorrect. What is required is probably only to mechanize the mmr3 bit, because at least zkdj tests it.
--      1 when 84 | 94,
      0 when others;

   with modelcode select have_pdr15 <= -- is there a bit 15, bypass cache, in the pdr
      1 when 44,
      0 when 70,                             -- acc. handbook
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_pdra <=  -- is there an a bit in the pdr
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      0 when others;

   with modelcode select have_pdrw <=  -- is there a w bit in the pdr
      1 when 23 | 24,                        -- kdf11
      1 when 34 | 35 | 40,                   -- kt11d!
      1 when 44,
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 60,
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_acf2 <=  -- is the acf of the 2-bit model
      1 when 23 | 24,                        -- kdf11
      1 when 34 | 35 | 40,                   -- kt11d!
      1 when 44,
      1 when 60,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_acf3 <=  -- is the acf of the 3-bit model
      1 when 45 | 50 | 55,
      1 when 70,
      0 when others;

   with modelcode select have_sr0ic <= -- is the sr0 instruction complete bit working
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      0 when others;

   with modelcode select have_sr1zero <=  -- is the sr1 always zero
      1 when 23 | 24,                        -- kdf11
      1 when 34 | 35 | 40,                   -- kt11d!
      1 when 60,
      0 when others;

   with modelcode select have_id <=    -- does the mmu do separate i and d
      1 when 44,
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_sup <=   -- does the mmu do supervisor state
      1 when 44,
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_sr3 <=   -- is the sr3 register present
      1 when 23 | 24,                        -- kdf11
      1 when 44,
      1 when 45 | 50 | 55,                   -- kt11c
      1 when 70,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_csm <=   -- is the csm instruction present and does the mmu have the bit for it in sr3
      1 when 44,
      1 when 73 | 83 | 84 | 93 | 94,         -- kdj11
      0 when others;

   with modelcode select have_oddabort <= -- does the system detect odd address errors
      0 when 23 | 24,                        -- kdf11
      1 when others;
   have_odd_abort <= have_oddabort;                                  -- the unibus component needs this too


-- console lights - mapping mode
   cons_map16 <= '1' when sr0(0) = '0' or have_mmu = 0
      else '0';
   cons_map18 <= '1' when sr0(0) = '1' and have_mmu = 1 and (have_mmu22 = 0 or sr3(4) = '0')
      else '0';
   cons_map22 <= '1' when sr0(0) = '1' and have_mmu = 1 and have_mmu22 = 1 and sr3(4) = '1'
      else '0';
   cons_id <= '1' when sr3id = '1'
      else '0';

-- determine mode

   psw_mmumode <= psw(15 downto 14) when cpu_cp = '0' else psw(13 downto 12);
   psw_mmumodelegal <=
      '0' when psw_mmumode = "10"
      else '0' when psw_mmumode = "01" and have_sup = 0
      else '1';

-- process sr3 settings on id
   sr3id <=
      id when psw_mmumode = "00" and sr3(2) = '1' and have_id = 1
      else id when psw_mmumode = "01" and sr3(1) = '1' and have_id = 1
      else id when psw_mmumode = "11" and sr3(0) = '1' and have_id = 1
      else '0';

-- find current par & pdr
   ppraddr <=
      cons_adss_mode & cons_adss_id & cpu_addr_v(15 downto 13) when cons_exadep = '1'
      else psw_mmumode & sr3id & cpu_addr_v(15 downto 13);
   par <= par1o & par0o;
   pdr <= "0000000000000000" when psw_mmumodelegal = '0' else pdr1o & "0000" & pdr0o;

-- calculate physical address from what the cpu is driving to us
-- considering whether sr0 says mmu should be enabled
   addr_p(5 downto 0) <= cpu_addr_v(5 downto 0);
   addr_p18 <= unsigned(par(11 downto 0)) + (unsigned'("00000") & unsigned(cpu_addr_v(12 downto 6)));
   addr_p22 <= unsigned(par) + (unsigned'("000000000") & unsigned(cpu_addr_v(12 downto 6)));
   addr_p24z1 <= "00" & addr_p(21 downto 1) & '0';
   addr_p24z5 <= "00" & addr_p(21 downto 5) & "00000";
   addr_p(21 downto 6) <=
      cons_consphy(21 downto 6) when cons_exadep = '1' and cons_adss_cons = '1'
      else "0000" & addr_p18 when have_mmu = 1 and sr0(0) = '1' and (sr3(4) = '0' or have_mmu22 = 0) and addr_p18(17 downto 13) /= "11111"
      else "1111" & addr_p18 when have_mmu = 1 and sr0(0) = '1' and (sr3(4) = '0' or have_mmu22 = 0) and addr_p18(17 downto 13) = "11111"
      else addr_p22 when have_mmu = 1 and sr0(0) = '1' and sr3(4) = '1' and have_mmu22 = 1
      else "0000" & addr_p18 when sr0(8) = '1' and dstfreference = '1' and (sr3(4) = '0' or have_mmu22 = 0)  and have_mmumm = 1 and addr_p18(17 downto 13) /= "11111"
      else "1111" & addr_p18 when sr0(8) = '1' and dstfreference = '1' and (sr3(4) = '0' or have_mmu22 = 0)  and have_mmumm = 1 and addr_p18(17 downto 13) = "11111"
      else addr_p22 when sr0(8) = '1' and dstfreference = '1' and sr3(4) = '1' and have_mmu22 = 1 and have_mmumm = 1
      else "000000" & cpu_addr_v(15 downto 6) when cpu_addr_v(15 downto 13) /= "111"
      else "111111" & cpu_addr_v(15 downto 6);

-- generate abort nonresident
   abort_nonresident <= '1' when have_acf3 = 1 and sr0(0) = '1' and (cpu_rd = '1' or cpu_wr = '1')
      and (pdr(2 downto 0) = "000" or pdr(2 downto 0) = "011" or pdr(2 downto 0) = "111")
      else '1' when have_acf2 = 1 and sr0(0) = '1' and (cpu_rd = '1' or cpu_wr = '1')
      and (pdr(2 downto 1) = "00" or pdr(2 downto 1) = "10")
      else '0';

-- generate abort page length
   abort_pagelength <=
      '1' when (cpu_rd = '1' or cpu_wr = '1')
         and have_mmu = 1 and sr0(0) = '1'
         and (
            (pdr(3) = '0' and unsigned(cpu_addr_v(12 downto 6)) > unsigned(pdr(14 downto 8)))
         or
            (pdr(3) = '1' and unsigned(cpu_addr_v(12 downto 6)) < unsigned(pdr(14 downto 8)))
         )
         and psw_mmumodelegal = '1'                                            -- fkth tests for this. jkdk too. Still, PDP11_Handbook1979.pdf pg. 163 specifically states that bit 14 will be set on access in an illegal mode.
         else '0';

-- generate abort readonly
   abort_readonly <=
      '1' when have_acf3 = 1 and cpu_wr = '1' and sr0(0) = '1' and (pdr(2 downto 0) = "000" or pdr(2 downto 0) = "010")
      else '1' when have_acf2 = 1 and cpu_wr = '1' and sr0(0) = '1' and (pdr(2 downto 1) = "00" or pdr(2 downto 1) = "01")
      else '0';

-- generate mmu_mmuabort, from the three types above
-- mmu_mmuabort is used to block driving the unibus when
-- one of the aborts is active
-- copy into mmuabort for communication to the cpu
-- also, block generating a mmu abort if at the same time
-- also an odd abort is detected, see test 44 fkth
--
   mmu_mmuabort <=
      '1' when (abort_nonresident = '1' or abort_pagelength = '1' or abort_readonly = '1') and abort_acknowledged = '0'
      else '0';
   mmuabort <= mmu_mmuabort when oddabort = '0'
      else '0';

-- generate mmu trap
   trap_mm <=
      '1' when sr0(9) = '1' and sr0(0)= '1'
         and have_mmutr = 1
         and ((cpu_rd = '1' and (pdr(2 downto 0) = "001" or pdr(2 downto 0) = "100")) or (cpu_wr = '1' and (pdr(2 downto 0) = "100" or pdr(2 downto 0) = "101")))
      else '0';


-- select mapping register from unibus map
   ubmraddr <= addr_p(17 downto 13) when unibus_busmaster_control_npg = '0'
      else unibus_busmaster_addr(17 downto 13);
   ubmmaddr <= unsigned(ubmo) + unsigned(addr_p(12 downto 0)) when unibus_busmaster_control_npg = '0'
      else unsigned(ubmo) + unsigned(unibus_busmaster_addr(12 downto 0));

-- memory interface
   bus_unibus_mapped <= '1' when addr_p(21 downto 18) = "1111"
--      else '1' when unibus_busmaster_control_npg = '1'
      else '0';

   bus_addr <= ubmmaddr when sr3(5) = '1' and unibus_busmaster_control_npg = '1' and have_ubm = 1
   else "0000" & unibus_busmaster_addr when unibus_busmaster_control_npg = '1'
   else ubmmaddr when sr3(5) = '1' and sr3(4) = '1' and sr0(0) = '1' and unibus_busmaster_control_npg = '0' and addr_p(21 downto 18) = "1111" and have_ubm = 1
   else "0000" & addr_p(17 downto 0) when addr_p(21 downto 18) = "1111" and have_mmu22 = 1 and have_1920 = 1
   else addr_p;

   bus_dato <= mmu_dato when unibus_busmaster_control_npg = '0'
      else unibus_busmaster_dato;

   bus_control_dati <= '1' when unibus_busmaster_control_npg = '0'
      and cpu_rd = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0' and oddaddress = '0'
      and addr_p(21 downto 13) /= "111111111"
      else unibus_busmaster_control_dati when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) /= "11111"
      else '0';

   bus_control_dato <= '1' when unibus_busmaster_control_npg = '0'
      and cpu_rd = '0' and cpu_wr = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0'
      and addr_p(21 downto 13) /= "111111111"
      else unibus_busmaster_control_dato when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) /= "11111"
      else '0';

   bus_control_datob <= '1' when unibus_busmaster_control_npg = '0'
      and cpu_rd = '0' and cpu_wr = '1' and cpu_dw8 = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0'
      and addr_p(21 downto 13) /= "111111111"
      else unibus_busmaster_control_datob when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) /= "11111"
      else '0';

   unibus_busmaster_dati <= bus_dati;



-- unibus interface - to the registers in the devices on the unibus
-- or what behaves like that, ie. the top 8K of the unibus address space only;
-- all the rest lives on the unibus map, via unibus_busmaster, or the memory bus
-- hence, the addresses that are valid on this bus are addr_p(21 downto 13) = all ones.

   unibus_addr <= unibus_busmaster_addr when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) = "11111"
      else addr_p(17 downto 0);
   unibus_control_dati <= '1' when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) = "11111" and unibus_busmaster_control_dati = '1'
      else '1' when addr_p(21 downto 13) = "111111111" and cpu_rd = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0' and oddaddress = '0'
      else '0';
   unibus_control_dato <= '1' when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) = "11111" and unibus_busmaster_control_dato = '1'
      else '1' when addr_p(21 downto 13) = "111111111" and cpu_rd = '0' and cpu_wr = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0'
      else '0';
   unibus_control_datob <= '1' when unibus_busmaster_control_npg = '1' and unibus_busmaster_addr(17 downto 13) = "11111" and unibus_busmaster_control_datob = '1'
      else '1' when addr_p(21 downto 13) = "111111111" and cpu_rd = '0' and cpu_wr = '1' and cpu_dw8 = '1' and mmu_addr_match = '0' and mmu_mmuabort = '0'
      else '0';

-- drive out word or byte writes onto the bus, taking care of flipping output bytes onto the odd byte of the bus if needed
   mmu_dato <=
      cpu_dataout when cpu_wr = '1' and cpu_dw8 = '0'
      else cpu_dataout when cpu_wr = '1' and cpu_dw8 = '1' and cpu_addr_v(0) = '0'
      else cpu_dataout(7 downto 0) & "00000000" when cpu_wr = '1' and cpu_dw8 = '1' and cpu_addr_v(0) = '1'
      else "0000000000000000";
   unibus_dato <= mmu_dato;

-- read in data from bus, flip input bytes when required
   cpu_datain <=
      mmu_datain when cpu_dw8 = '1' and cpu_addr_v(0) = '0'
      else "00000000" & mmu_datain(15 downto 8) when cpu_dw8 = '1' and cpu_addr_v(0) = '1'
      else mmu_datain;

   oddaddress <=
      '1' when cpu_dw8 = '0' and cpu_addr_v(0) = '1' and have_oddabort = 1
      else '0';
   oddabort <=                                           -- FIXME, this aborts on read with dw8=0, but would a real pdp11 detect this error? Yes- at least, kkab fails if it's disabled.
      '1' when (cpu_rd = '1' or cpu_wr = '1') and oddaddress = '1'
--      '1' when (cpu_wr = '1') and oddaddress = '1'
      else '0';
   mmuoddabort <= oddabort;


   parout(15 downto 12) <= paro2(15 downto 12) when have_mmu22 = 1 else "0000";
   parout(11 downto 0) <= paro2(11 downto 0);

   pdrout(15) <= pdro2(15) when have_pdr15 = 1 else '0';
   pdrout(14 downto 8) <= pdro2(14 downto 8);
   pdrout(7) <= pdra when have_pdra = 1 else '0';
   pdrout(6) <= pdrw when have_pdrw = 1 else '0';
   pdrout(5) <= '0';
   pdrout(4) <= '0';
   pdrout(3) <= pdro2(3);
   pdrout(2 downto 1) <= pdro2(2 downto 1);
   pdrout(0) <= pdro2(0) when have_acf3 = 1 else '0';

   sr0out(15 downto 13) <= sr0(15 downto 13);
   sr0out(12) <= sr0(12) when have_mmutr = 1 else '0';
   sr0out(11 downto 10) <= "00";
   sr0out(9) <= sr0(9) when have_mmutr = 1 else '0';
   sr0out(8) <= sr0(8) when have_mmumm = 1 else '0';
   sr0out(7) <= sr0(7) when have_sr0ic = 1 else '0';
   sr0out(6 downto 5) <= sr0(6 downto 5);
   sr0out(4) <= sr0(4) when have_id = 1 else '0';
   sr0out(3 downto 1) <= sr0(3 downto 1);
   sr0out(0) <= sr0(0);

   sr1out <= "0000000000000000" when have_sr1zero = 1
      else sr1;

   sr3out(5) <= sr3(5) when have_ubm = 1 else '0';
   sr3out(4) <= sr3(4) when have_mmu22 = 1 else '0';
   sr3out(3) <= sr3(3) when have_csm = 1 else '0';
   sr3out(2) <= sr3(2) when have_id = 1 else '0';
   sr3out(1) <= sr3(1) when have_id = 1 and have_sup = 1 else '0';
   sr3out(0) <= sr3(0) when have_id = 1 else '0';

   sr3csmenable <= sr3(3) when have_csm = 1 else '0';

-- handle the output from the mmu itself
   mmu_datain <=
      parout when paro2valid = '1' and have_mmu = 1
      else pdrout when pdro2valid = '1' and have_mmu = 1
      else sr0out when addr_p24z1 = o"17777572" and have_mmu = 1
      else sr1out when addr_p24z1 = o"17777574" and have_mmu = 1
      else sr2 when addr_p24z1 = o"17777576" and have_mmu = 1
      else "0000000000" & sr3out when addr_p24z1 = o"17772516" and have_mmu = 1
      else ubmo2(15 downto 0) when ubmo2valid = '1' and addr_p(1) = '0' and have_ubm = 1
      else "0000000000" & ubmo2(21 downto 16) when ubmo2valid = '1' and addr_p(1) = '1' and have_ubm = 1
      else unibus_dati when addr_p(21 downto 13) = "111111111"
      else bus_dati;

-- generate mmu_addr_match, extremely unelegant but I don't see how else to do this
   mmu_addr_match <=
      '1' when (
            (addr_p24z5 = o"17772300" and (have_id = 1 or (have_id = 0 and addr_p(4) = '0')))
            or (addr_p24z5 = o"17772340" and (have_id = 1 or (have_id = 0 and addr_p(4) = '0')))
            or (addr_p24z5 = o"17772200" and have_sup = 1)
            or (addr_p24z5 = o"17772240" and have_sup = 1)
            or (addr_p24z5 = o"17777600" and (have_id = 1 or (have_id = 0 and addr_p(4) = '0')))
            or (addr_p24z5 = o"17777640" and (have_id = 1 or (have_id = 0 and addr_p(4) = '0')))
            or addr_p24z1 = o"17777572"                                   -- sr0
            or addr_p24z1 = o"17777574"                                   -- sr1
            or addr_p24z1 = o"17777576"                                   -- sr2
            or (addr_p24z1 = o"17772516" and have_sr3 = 1)                -- sr3
            or (addr_p(21 downto 7) = "111111111100001" and have_ubm = 1)
         )
         and have_mmu = 1
      else '0';

sr0out_debug <= sr0;


-- handle updates to pdr for w and a bits
   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            abort_acknowledged <= '0';
            mmutrap <= '0';
            sr0(15 downto 0) <= "0000000000000000";
            sr1 <= sr1_in;
            sr2 <= sr2_in;
            sr3 <= "000000";
            if modelcode = 23 or modelcode = 24 then
               mmu_lma_eub <= (others => '0');
               mmu_lma_c0 <= '0';
               mmu_lma_c1 <= '0';
            end if;
         else

            -- process updates to sr0, sr1, sr2, handle abort acknowledgement
            if ifetch = '1' then
               abort_acknowledged <= '0';
            end if;
            if ack_mmuabort = '1' then
               sr1 <= sr1_in;                                        -- ugly hack, really. But, the sr1 is not completely updated until now
               abort_acknowledged <= '1';
            end if;
            if trap_mm = '1' then
               mmutrap <= '1';
            end if;
            if ack_mmutrap = '1' then
               mmutrap <= '0';
            end if;
            if sr0(15 downto 13) = "000" then
               abort_acknowledged <= '0';
               sr2 <= sr2_in;
               if sr0(0) = '1' then
                  sr0(15) <= abort_nonresident;
                  sr0(14) <= abort_pagelength;
                  sr0(13) <= abort_readonly;
                  sr0(12) <= trap_mm;
                  sr0(7) <= sr0_ic;
                  if (cpu_rd = '1' or cpu_wr = '1') then
                     sr0(6 downto 5) <= psw_mmumode;
                     sr0(4) <= sr3id;
                     sr0(3 downto 1) <= cpu_addr_v(15 downto 13);
                  end if;
               end if;
            else
               -- don't update; mmr is freezed
            end if;

         -- handle w bit in pdr
            if have_pdrw = 1 and sr0(0) = '1' and cpu_wr = '1' and mmu_addr_match = '0'
            and abort_nonresident = '0' and abort_pagelength = '0' and abort_readonly = '0' then
               case psw(15 downto 14) is
                  when "00" =>
                     kpdr_w(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when "01" =>
                     spdr_w(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when "11" =>
                     updr_w(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when others =>
                     null;
               end case;
            end if;

            -- handle a bit in pdr
            if have_pdra = 1 and sr0(0) = '1' and mmu_addr_match = '0'
            and abort_nonresident = '0' and abort_pagelength = '0' and abort_readonly = '0'
            and
            ((pdr(2 downto 0) = "001" and cpu_rd = '1')
            or (pdr(2 downto 0) = "100" and (cpu_rd = '1' or cpu_wr = '1' ))
            or (pdr(2 downto 0) = "101" and cpu_wr = '1' ))
            then
               case psw(15 downto 14) is
                  when "00" =>
                     kpdr_a(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when "01" =>
                     spdr_a(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when "11" =>
                     updr_a(conv_integer(sr3id & cpu_addr_v(15 downto 13))) <= '1';
                  when others =>
                     null;
               end case;
            end if;

-- f11

            if modelcode = 23 or modelcode = 24 then
               if sr3(4) = '1' and sr0(0) = '1' and addr_p(21 downto 18) = "1111" and have_ubm = 1 and (cpu_rd = '1' or cpu_wr = '1') then
                  mmu_lma_eub <= ubmmaddr;
                  if cpu_dw8 = '1' then
                     mmu_lma_c0 <= '1';
                  else
                     mmu_lma_c0 <= '0';
                  end if;
                  if cpu_wr = '1' then
                     mmu_lma_c1 <= '1';
                  else
                     mmu_lma_c1 <= '0';
                  end if;
               end if;
            end if;

-- read and write into local registers for mmu

            paro2valid <= '0';
            pdro2valid <= '0';
            ubmo2valid <= '0';

            if cpu_rd = '1' then
               case addr_p24z5 is
                  when o"17772340" =>              -- k[id]par
                     paro2valid <= '1';
                     paro2 <= par1_00(conv_integer(addr_p(4 downto 1))) & par0_00(conv_integer(addr_p(4 downto 1)));
                  when o"17772240" =>              -- s[id]par
                     paro2valid <= '1';
                     paro2 <= par1_01(conv_integer(addr_p(4 downto 1))) & par0_01(conv_integer(addr_p(4 downto 1)));
                  when o"17777640" =>              -- u[id]par
                     paro2valid <= '1';
                     paro2 <= par1_11(conv_integer(addr_p(4 downto 1))) & par0_11(conv_integer(addr_p(4 downto 1)));
                  when o"17772300" =>              -- k[id]pdr
                     pdro2valid <= '1';
                     pdro2 <= pdr1_00(conv_integer(addr_p(4 downto 1))) & "0000" & pdr0_00(conv_integer(addr_p(4 downto 1)));
                     pdra <= kpdr_a(conv_integer(addr_p(4 downto 1)));
                     pdrw <= kpdr_w(conv_integer(addr_p(4 downto 1)));
                 when o"17772200" =>              -- s[id]pdr
                     pdro2valid <= '1';
                     pdro2 <= pdr1_01(conv_integer(addr_p(4 downto 1))) & "0000" & pdr0_01(conv_integer(addr_p(4 downto 1)));
                     pdra <= spdr_a(conv_integer(addr_p(4 downto 1)));
                     pdrw <= spdr_w(conv_integer(addr_p(4 downto 1)));
                  when o"17777600" =>              -- u[id]pdr
                     pdro2valid <= '1';
                     pdro2 <= pdr1_11(conv_integer(addr_p(4 downto 1))) & "0000" & pdr0_11(conv_integer(addr_p(4 downto 1)));
                     pdra <= updr_a(conv_integer(addr_p(4 downto 1)));
                     pdrw <= updr_w(conv_integer(addr_p(4 downto 1)));
                  when others =>
                     null;
               end case;

               if addr_p(21 downto 7) = "111111111100001" and have_ubm = 1 then
                  ubmo2(0) <= '0';
                  ubmo2(7 downto 1) <= ubmb0(conv_integer(addr_p(6 downto 2)));
                  ubmo2(15 downto 8) <= ubmb1(conv_integer(addr_p(6 downto 2)));
                  ubmo2(21 downto 16) <= ubmb2(conv_integer(addr_p(6 downto 2)));
                  ubmo2valid <= '1';
               end if;

            elsif cpu_wr = '1' then

               if addr_p(21 downto 7) = "111111111100001" and addr_p(1) = '0' and have_ubm = 1 then
                  if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then       -- word write or even address
                     ubmb0(conv_integer(cpu_addr_v(6 downto 2))) <= mmu_dato(7 downto 1);
                  end if;
                  if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then       -- word write or odd address
                     ubmb1(conv_integer(cpu_addr_v(6 downto 2))) <= mmu_dato(15 downto 8);
                  end if;
               end if;
               if addr_p(21 downto 7) = "111111111100001" and addr_p(1) = '1' and have_ubm = 1 then
                  if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then       -- word write or even address
                     ubmb2(conv_integer(cpu_addr_v(6 downto 2))) <= mmu_dato(5 downto 0);
                  end if;
               end if;

               case addr_p24z1 is
                  when o"17777572" =>                                 -- sr0
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        sr0(0) <= mmu_dato(0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        sr0(15 downto 13) <= mmu_dato(15 downto 13);
                        sr0(9) <= mmu_dato(9);          -- traps, 45 and 70
                        sr0(8) <= mmu_dato(8);
                     end if;

                  when o"17772516" =>                                 -- sr3
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        sr3 <= mmu_dato(5 downto 0);
                     end if;
                  when others =>
                     null;
               end case;

               case addr_p24z5 is
                  when o"17772340" =>
                     kpdr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     kpdr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        par0_00(conv_integer(addr_p(4 downto 1))) <= mmu_dato(7 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        par1_00(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when o"17772240" =>
                     spdr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     spdr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        par0_01(conv_integer(addr_p(4 downto 1))) <= mmu_dato(7 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        par1_01(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when o"17777640" =>
                     updr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     updr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        par0_11(conv_integer(addr_p(4 downto 1))) <= mmu_dato(7 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        par1_11(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when o"17772300" =>
                     kpdr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     kpdr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        pdr0_00(conv_integer(addr_p(4 downto 1))) <= mmu_dato(3 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        pdr1_00(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when o"17772200" =>
                     spdr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     spdr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        pdr0_01(conv_integer(addr_p(4 downto 1))) <= mmu_dato(3 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        pdr1_01(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when o"17777600" =>
                     updr_a(conv_integer(addr_p(4 downto 1))) <= '0';
                     updr_w(conv_integer(addr_p(4 downto 1))) <= '0';
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '0' then   -- word write or even address
                        pdr0_11(conv_integer(addr_p(4 downto 1))) <= mmu_dato(3 downto 0);
                     end if;
                     if cpu_dw8 = '0' or cpu_addr_v(0) = '1' then   -- word write or odd address
                        pdr1_11(conv_integer(addr_p(4 downto 1))) <= mmu_dato(15 downto 8);
                     end if;

                  when others =>
                     null;
               end case;
            end if;
         end if;
      end if;
   end process;

   process(ubmraddr, ubmb0, ubmb1, ubmb2)
   begin
      ubmo(0) <= '0';
      ubmo(7 downto 1) <= ubmb0(conv_integer(ubmraddr));
      ubmo(15 downto 8) <= ubmb1(conv_integer(ubmraddr));
      ubmo(21 downto 16) <= ubmb2(conv_integer(ubmraddr));
   end process;

   process(ppraddr, par1_00, par1_01, par1_11)
   begin
      case ppraddr(5 downto 4) is
         when "00" =>
            par1o <= par1_00(conv_integer(ppraddr(3 downto 0)));
         when "01" =>
            par1o <= par1_01(conv_integer(ppraddr(3 downto 0)));
         when "11" =>
            par1o <= par1_11(conv_integer(ppraddr(3 downto 0)));
         when others =>
            par1o <= "00000000";
      end case;
   end process;

   process(ppraddr, par0_00, par0_01, par0_11)
   begin
      case ppraddr(5 downto 4) is
         when "00" =>
            par0o <= par0_00(conv_integer(ppraddr(3 downto 0)));
         when "01" =>
            par0o <= par0_01(conv_integer(ppraddr(3 downto 0)));
         when "11" =>
            par0o <= par0_11(conv_integer(ppraddr(3 downto 0)));
         when others =>
            par0o <= "00000000";
      end case;
   end process;

   process(ppraddr, pdr1_00, pdr1_01, pdr1_11)
   begin
      case ppraddr(5 downto 4) is
         when "00" =>
            pdr1o <= pdr1_00(conv_integer(ppraddr(3 downto 0)));
         when "01" =>
            pdr1o <= pdr1_01(conv_integer(ppraddr(3 downto 0)));
         when "11" =>
            pdr1o <= pdr1_11(conv_integer(ppraddr(3 downto 0)));
         when others =>
            pdr1o <= "00000000";
      end case;
   end process;

   process(ppraddr, pdr0_00, pdr0_01, pdr0_11)
   begin
      case ppraddr(5 downto 4) is
         when "00" =>
            pdr0o <= pdr0_00(conv_integer(ppraddr(3 downto 0)));
         when "01" =>
            pdr0o <= pdr0_01(conv_integer(ppraddr(3 downto 0)));
         when "11" =>
            pdr0o <= pdr0_11(conv_integer(ppraddr(3 downto 0)));
         when others =>
            pdr0o <= "0000";
      end case;
   end process;

end implementation;

