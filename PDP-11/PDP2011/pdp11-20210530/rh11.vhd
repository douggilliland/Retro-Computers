
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

entity rh11 is
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
      rh_type : in integer range 1 to 7 := 6;              -- 1:RM06; 2:RP2G; 3:-;4:RP04/RP05; 5:RM05; 6:RP06; 7:RP07
      rh_noofcyl : in integer range 128 to 8192 := 1024;   -- for RM06 and RP2G: how many cylinders are available

      reset : in std_logic;
      clk50mhz : in std_logic;
      nclk : in std_logic;
      clk : in std_logic
   );
end rh11;

architecture implementation of rh11 is


component sdspi is
   port(
      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic := '0';
      sdcard_debug : out std_logic_vector(3 downto 0);

      sdcard_addr : in std_logic_vector(23 downto 0);

      sdcard_idle : out std_logic;
      sdcard_read_start : in std_logic;
      sdcard_read_ack : in std_logic;
      sdcard_read_done : out std_logic;
      sdcard_write_start : in std_logic;
      sdcard_write_ack : in std_logic;
      sdcard_write_done : out std_logic;
      sdcard_error : out std_logic;

      sdcard_xfer_addr : in integer range 0 to 255;
      sdcard_xfer_read : in std_logic;
      sdcard_xfer_out : out std_logic_vector(15 downto 0);
      sdcard_xfer_write : in std_logic;
      sdcard_xfer_in : in std_logic_vector(15 downto 0);

      enable : in integer range 0 to 1 := 0;
      controller_clk : in std_logic;
      reset : in std_logic;
      clk50mhz : in std_logic
   );
end component;


-- regular bus interface

signal base_addr_match : std_logic;
signal interrupt_trigger : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;

-- rm controller registers

-- rmcs1 17 776 700                                             -- control/status 1
signal rmcs1_sc : std_logic;                                         -- special condition
signal rmcs1_tre : std_logic;                                        -- transfer error
signal rmcs1_mcpe : std_logic;                                       -- mass control parity error
signal rmcs1_dva : std_logic;                                        -- device available
signal rmcs1_psel : std_logic;                                       -- port select
signal rmcs1_bae : std_logic_vector(1 downto 0);                     -- bus address extension
signal rmcs1_rdy : std_logic;                                        -- controller ready
signal rmcs1_ie : std_logic;                                         -- interrupt enable
signal rmcs1_fnc : std_logic_vector(4 downto 0);                     -- function code
signal rmcs1_go : std_logic;                                         -- go

-- rmwc  17 776 702                                             -- word count
signal rmwc : std_logic_vector(15 downto 0);

-- rmba  17 776 704                                             -- bus address
signal rmba : std_logic_vector(15 downto 0);

-- rmda  17 776 706                                             -- desired sector/track
signal rmda_ta : std_logic_vector(7 downto 0);                       -- track
signal rmda_sa : std_logic_vector(7 downto 0);                       -- sector

-- rmcs2  17 776 710                                            -- control/status 2
signal rmcs2_dlt : std_logic;                                        -- data late
signal rmcs2_wce : std_logic;                                        -- write check error
signal rmcs2_pe : std_logic;                                        -- unibus parity error
signal rmcs2_ned : std_logic;                                        -- nonexistent drive
signal rmcs2_nem : std_logic;                                        -- nxm
signal rmcs2_pge : std_logic;                                        -- program error
signal rmcs2_mxf : std_logic;                                        -- missed transfer
signal rmcs2_mdpe : std_logic;                                       -- massbus data parity error
signal rmcs2_or : std_logic;                                         -- output ready
signal rmcs2_ir : std_logic;                                         -- input ready
signal rmcs2_clr : std_logic;                                        -- clear
signal rmcs2_pat : std_logic;                                        -- parity test
signal rmcs2_bai : std_logic;                                        -- bus address increment inhibit
signal rmcs2_u : std_logic_vector(2 downto 0);                       -- drive select

-- rmds   17 776 712                                            -- drive status
signal rmds_ata : std_logic;                                         -- attention active
signal rmds_err : std_logic;                                         -- composite error
signal rmds_pip : std_logic;                                         -- positioning operation in progress
signal rmds_mol : std_logic;                                         -- medium online
signal rmds_wrl : std_logic;                                         -- write lock
signal rmds_lst : std_logic;                                         -- last sector txfrd
signal rmds_pgm : std_logic;                                         -- programmable
signal rmds_dpr : std_logic;                                         -- drive preset
signal rmds_dry : std_logic;                                         -- drive ready
signal rmds_vv : std_logic;                                          -- volume valid
signal rmds_om : std_logic;                                          --

-- rmer1  17 776 714                                            -- error status 1
signal rmer1_dck : std_logic;                                        -- data check error
signal rmer1_uns : std_logic;                                        -- drive unsafe
signal rmer1_opi : std_logic;                                        -- operation incomplete
signal rmer1_dte : std_logic;                                        -- drive timing error
signal rmer1_wle : std_logic;                                        -- write lock error
signal rmer1_iae : std_logic;                                        -- invalid access error
signal rmer1_aoe : std_logic;                                        -- address overflow error
signal rmer1_hcrc : std_logic;                                       -- header crc error
signal rmer1_hce : std_logic;                                        -- header compare error
signal rmer1_ech : std_logic;                                        -- ecc hard error
signal rmer1_wcf : std_logic;                                        -- write clock fail
signal rmer1_fer : std_logic;                                        -- format error
signal rmer1_par : std_logic;                                        -- parity error
signal rmer1_rmr : std_logic;                                        -- register modification refused
signal rmer1_ilr : std_logic;                                        -- illegal register
signal rmer1_ilf : std_logic;                                        -- illegal function

-- rmas  17 776 716                                             -- attention summary

-- rmla  17 776 720                                             -- look ahead
signal rmla_sc : std_logic_vector(4 downto 0);                       -- sector count

-- rmmr1  17 776 724                                             -- maintenance register
signal rmmr1 : std_logic_vector(15 downto 0);

-- rmdt  17 776 726                                             -- drive type

-- rmsn  17 776 730                                             -- serial number

-- rmof  17 776 732                                             -- offset
signal rmof_fmt : std_logic;
signal rmof_eci : std_logic;
signal rmof_hci : std_logic;
signal rmof_ofd : std_logic;

-- rmdc  17 776 734                                             -- cylinder
signal rmdc : std_logic_vector(15 downto 0);                         -- desired cylinder number

-- rmhr  17 776 736                                                  -- holding register (rm05) current cylinder (rp0x)
--signal rmhr : std_logic_vector(15 downto 0);                         -- holding register

-- rmmr2 17 776 740
signal rmmr2 : std_logic_vector(15 downto 0);

-- rmer2 17 776 742
signal rmer2_dpe : std_logic;                                        -- data parity error
signal rmer2_dvc : std_logic;                                        -- device check
signal rmer2_lbc : std_logic;                                        -- loss of bit check
signal rmer2_lsc : std_logic;                                        -- loss of system clock
signal rmer2_ivc : std_logic;                                        -- invalid command
signal rmer2_ope : std_logic;                                        -- operator plug error
signal rmer2_ski : std_logic;                                        -- seek incomplete
signal rmer2_bse : std_logic;                                        -- bad sector error

-- rmec1 17 776 744

-- rmec2 17 776 746

-- rmbae 17 776 750
signal rmbae : std_logic_vector(5 downto 0);

-- rmcs3 17 776 752
signal rmcs3_ape : std_logic;
signal rmcs3_dpe : std_logic_vector(1 downto 0);
signal rmcs3_wce : std_logic_vector(1 downto 0);
signal rmcs3_dbl : std_logic;
signal rmcs3_ie : std_logic;
signal rmcs3_ipck : std_logic_vector(3 downto 0);


-- controller internals

signal update_rmwc : std_logic;
signal wcp : std_logic_vector(15 downto 0);            -- word count, positive
signal wrkdb : std_logic_vector(15 downto 0);

signal error_reset : std_logic := '1';
signal rmclock : integer range 0 to 4095 := 0;
signal rmclock_piptimer : integer range 0 to 3 := 0;

signal rmcs1_rdyset : std_logic := '0';
signal rmds_ataset : std_logic := '0';

signal work_bar : std_logic_vector(21 downto 1);

signal noofsec : std_logic_vector(7 downto 0);
signal nooftrk : std_logic_vector(7 downto 0);
signal noofcyl : std_logic_vector(15 downto 0);

signal write_start : std_logic;


-- sdspi interface signals

signal sdcard_xfer_clk : std_logic;
signal sdcard_xfer_addr : integer range 0 to 255;
signal sdcard_xfer_read : std_logic;
signal sdcard_xfer_out : std_logic_vector(15 downto 0);
signal sdcard_xfer_write : std_logic;
signal sdcard_xfer_in : std_logic_vector(15 downto 0);

signal sdcard_idle : std_logic;
signal sdcard_read_start : std_logic;
signal sdcard_read_ack : std_logic;
signal sdcard_read_done : std_logic;
signal sdcard_write_start : std_logic;
signal sdcard_write_ack : std_logic;
signal sdcard_write_done : std_logic;
signal sdcard_error : std_logic;

-- busmaster controller

signal nxm : std_logic;
signal sectorcounter : std_logic_vector(8 downto 0);            -- counter within sector
signal hs_offset : std_logic_vector(23 downto 0);
signal ca_offset : std_logic_vector(23 downto 0);
signal dn_offset : std_logic_vector(23 downto 0);
signal sd_addr : std_logic_vector(23 downto 0);

type busmaster_state_t is (
   busmaster_idle,
   busmaster_read,
   busmaster_readh,
   busmaster_readh2,
   busmaster_read1,
   busmaster_read_done,
   busmaster_write1,
   busmaster_write,
   busmaster_writen,
   busmaster_write_wait,
   busmaster_write_done,
   busmaster_wait
);
signal busmaster_state : busmaster_state_t := busmaster_idle;

begin

   with rh_type select noofsec <=
      "01000000" when 1,                         -- 64                         RM06
      "01000000" when 2,                         -- 64                         RP2G
      "00010110" when 4,                         -- 22                         RP04/RP05
      "00100000" when 5,                         -- 32                         RM05
      "00010110" when 6,                         -- 22                         RP06
      "00110010" when 7,                         -- 50                         RP07
      "00000000" when others;

   with rh_type select nooftrk <=
      "00100000" when 1,                         -- 32                         RM06
      "01000000" when 2,                         -- 64                         RP2G
      "00010011" when 4,                         -- 19                         RP04/RP05
      "00010011" when 5,                         -- 19                         RM05
      "00010011" when 6,                         -- 19                         RP06
      "00100000" when 7,                         -- 32                         RP07
      "00000000" when others;

   with rh_type select noofcyl <=
      conv_std_logic_vector(rh_noofcyl,noofcyl'length) when 1,       --        RM06
      conv_std_logic_vector(rh_noofcyl,noofcyl'length) when 2,       --        RP2G
      "0000000110011011" when 4,                 -- 411 = 171798               RP04/RP05
      "0000001100110111" when 5,                 -- 823 = 500384               RM05
      "0000001100101111" when 6,                 -- 815 = 340670               RP06
      "0000001001110110" when 7,                 -- 630 = 1008000              RP07
      "0000000000000000" when others;


   sd1: sdspi port map(
      sdcard_cs => sdcard_cs,
      sdcard_mosi => sdcard_mosi,
      sdcard_sclk => sdcard_sclk,
      sdcard_miso => sdcard_miso,
      sdcard_debug => sdcard_debug,

      sdcard_addr => sd_addr,

      sdcard_idle => sdcard_idle,
      sdcard_read_start => sdcard_read_start,
      sdcard_read_ack => sdcard_read_ack,
      sdcard_read_done => sdcard_read_done,
      sdcard_write_start => sdcard_write_start,
      sdcard_write_ack => sdcard_write_ack,
      sdcard_write_done => sdcard_write_done,
      sdcard_error => sdcard_error,

      sdcard_xfer_addr => sdcard_xfer_addr,
      sdcard_xfer_read => sdcard_xfer_read,
      sdcard_xfer_out => sdcard_xfer_out,
      sdcard_xfer_in => sdcard_xfer_in,
      sdcard_xfer_write => sdcard_xfer_write,

      enable => have_rh,
      controller_clk => clk,
      reset => reset,
      clk50mhz => clk50mhz
   );


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 6) = bus_addr(17 downto 6) and have_rh = 1 and have_rh70 = 0 and bus_addr(5 downto 1) < "10100"
      else '1' when base_addr(17 downto 6) = bus_addr(17 downto 6) and have_rh = 1 and have_rh70 = 1
      else '0';
   bus_addr_match <= base_addr_match;

   int_vector <= ivec;

-- specific logic for the device

   rmcs1_sc <= '1' when rmcs1_tre = '1' or rmcs1_mcpe = '1'-- FIXME, others?
      else '0';
   rmcs1_tre <= '1' when rmcs2_dlt = '1' or rmcs2_wce = '1' or rmcs2_pe = '1' or rmcs2_ned = '1'
      or rmcs2_nem = '1' or rmcs2_mxf = '1' or rmcs2_pge = '1' or rmcs2_mdpe = '1'
      or rmer1_iae = '1' or rmer2_ivc = '1'
      else '0';

   rmcs1_bae <= rmbae(1 downto 0);

   rmcs2_ned <= '0' when rmcs2_u = "000" else '1';          -- sorry, one drive only

   rmcs3_ie <= rmcs1_ie;

   rmds_err <= '1' when  rmer1_dck = '1' or rmer1_uns = '1' or rmer1_opi = '1' or rmer1_dte = '1' or rmer1_wle = '1'
      or rmer1_iae = '1' or rmer1_aoe = '1' or rmer1_hcrc = '1' or rmer1_hce = '1' or rmer1_ech = '1' or rmer1_wcf = '1'
      or rmer1_fer = '1' or rmer1_par = '1' or rmer1_rmr = '1' or rmer1_ilr = '1' or rmer1_ilf = '1'
      or rmer2_dpe = '1' or rmer2_dvc = '1' or rmer2_lbc = '1' or rmer2_lsc = '1' or rmer2_ivc = '1'
      or rmer2_ope = '1' or rmer2_ski = '1' or rmer2_bse = '1'
   else '0';

-- regular bus interface : handle register contents and dependent logic

   process(nclk, reset)
      variable v_rsec : std_logic;
      variable v_rtrk : std_logic;
      variable v_rcyl : std_logic;
      variable v_iae : std_logic;
   begin
      if nclk = '1' and nclk'event then
         if reset = '1' then

            br <= '0';
            interrupt_trigger <= '0';
            interrupt_state <= i_idle;

            rmcs2_clr <= '1';
            error_reset <= '1';
            rmcs1_rdyset <= '0';
            rmds_ataset <= '0';

            sdcard_read_start <= '0';
            write_start <= '0';
            rmcs1_rdy <= '1';
            rmcs1_rdyset <= '0';

         else

            if have_rh = 1 then
               case interrupt_state is

                  when i_idle =>

                     br <= '0';
                     if rmcs1_ie = '1' and (rmcs1_rdyset = '1' or rmds_ataset = '1') then
                        if interrupt_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger <= '1';
                        end if;
                     else
                        interrupt_trigger <= '0';
                     end if;

                  when i_req =>
                     if rmcs1_ie = '1' then
                        if bg = '1' then
                           br <= '0';
                           interrupt_state <= i_wait;
                        end if;
                     else
                        interrupt_trigger <= '0';
                        interrupt_state <= i_idle;
                     end if;

                  when i_wait =>
                     if bg = '0' then
                        interrupt_state <= i_idle;
                        rmcs1_ie <= '0';                                      -- automatically reset ie when interrupt recognized
                     end if;

                  when others =>
                     interrupt_state <= i_idle;

               end case;
            else
               br <= '0';
            end if;

            if have_rh = 1 then

               if base_addr_match = '1' and bus_control_dati = '1' then

                  case bus_addr(5 downto 1) is

-- rmcs1 17 776 700 - control/status 1
                     when "00000" =>
                        bus_dati <= rmcs1_sc & rmcs1_tre & rmcs1_mcpe &  "0" & rmcs1_dva & rmcs1_psel & rmcs1_bae & rmcs1_rdy & rmcs1_ie & rmcs1_fnc & rmcs1_go;

-- rmwc  17 776 702                                             -- word count
                     when "00001" =>
                        bus_dati <= (not wcp) + 1;

-- rmba  17 776 704                                             -- bus address
                     when "00010" =>
                        bus_dati <= rmba;

-- rmda  17 776 706                                             -- desired sector/track
                     when "00011" =>
                        bus_dati <= "000" & rmda_ta(4 downto 0) & "000" & rmda_sa(4 downto 0);

-- rmcs2 17 776 710                                             -- control/status 2
                     when "00100" =>
                        bus_dati <= rmcs2_dlt & rmcs2_wce & rmcs2_pe & rmcs2_ned & rmcs2_nem & rmcs2_pge & rmcs2_mxf & rmcs2_mdpe & rmcs2_or & rmcs2_ir & rmcs2_clr & rmcs2_pat & rmcs2_bai & rmcs2_u;

-- rmds  17 776 712                                             -- drive status
                     when "00101" =>
                        bus_dati <= rmds_ata & rmds_err & rmds_pip & rmds_mol & rmds_wrl & rmds_lst & rmds_pgm & rmds_dpr & rmds_dry & rmds_vv & "00000" & rmds_om;

-- rmer1 17 776 714                                             -- error status 1
                     when "00110" =>
                        bus_dati <= rmer1_dck & rmer1_uns & rmer1_opi & rmer1_dte & rmer1_wle & rmer1_iae  & rmer1_aoe & rmer1_hcrc & rmer1_hce & rmer1_ech & rmer1_wcf & rmer1_fer & rmer1_par & rmer1_rmr & rmer1_ilr & rmer1_ilf;

-- rmas  17 776 716                                             -- attention summary
                     when "00111" =>
                        bus_dati <= "000000000000000" & rmds_ata;

-- rmla  17 776 720                                             -- look ahead???
                     when "01000" =>
                        bus_dati <=  "00000" & rmla_sc & "000000";

-- rmmr1  17 776 724                                             -- maintenance register
                     when "01010" =>
                        bus_dati <= rmmr1;

-- rmdt  17 776 726                                             -- drive type
                     when "01011" =>
                        case rh_type is
                           when 1 =>
                              bus_dati <= "0" & o"00047";       -- the mythical rm06
                           when 2 =>
                              bus_dati <= "0" & o"20222";       -- the mythical rp2g
                           when 4 =>
                              bus_dati <= "0" & o"20020";
                           when 5 =>
                              bus_dati <= "0" & o"20027";
                           when 6 =>
                              bus_dati <= "0" & o"20022";
                           when 7 =>
                              bus_dati <= "0" & o"20042";
                           when others =>
                              bus_dati <= "0" & o"20777";       -- illegal value, I hope
                        end case;

-- rmsn  17 776 730                                             -- serial number
                     when "01100" =>
                        bus_dati <= "0" & o"20040";

-- rmof  17 776 732                                             -- offset
                     when "01101" =>
                        bus_dati <=  "000" & rmof_fmt & rmof_eci & rmof_hci & "00" & rmof_ofd & "0000000";

-- rmdc  17 776 734                                             -- cylinder
                     when "01110" =>
                        bus_dati <= rmdc;

-- rmhr  17 776 736                                             -- holding register (rm05) current cylinder (rp0x)
                     when "01111" =>
--                        bus_dati <= rmhr;
                        if rh_type = 1 then                     -- for RM06
                           bus_dati <= noofcyl - 1;
                        else
                           bus_dati <= rmdc;
                        end if;

-- rmmr2 17 776 740
                     when "10000" =>
                        bus_dati <= rmmr2;

-- rmer2 17 776 742
                     when "10001" =>
                        bus_dati <= rmer2_bse & rmer2_ski & rmer2_ope & rmer2_ivc & rmer2_lsc & rmer2_lbc & "00" & rmer2_dvc & "000" & rmer2_dpe & "000";

-- rmec1 17 776 744
                     when "10010" =>
                        bus_dati <= (others => '0');

-- rmec2 17 776 746
                     when "10011" =>
                        bus_dati <= (others => '0');

-- rmbae 17 776 750
                     when "10100" | "11110" =>
                        if have_rh70 = 1 then
                           bus_dati <= "0000000000" & rmbae;
                        else
                           bus_dati <= (others => '1');
                        end if;

-- rmcs3 17 776 752
                     when "10101" =>
                        if have_rh70 = 1 then
                           bus_dati <= rmcs3_ape & rmcs3_dpe & rmcs3_wce & rmcs3_dbl & "000" & rmcs3_ie & "00" & rmcs3_ipck;
                        else
                           bus_dati <= (others => '1');
                        end if;

                     when others =>
                        bus_dati <= (others => '0');

                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if rmcs1_go = '1' and bus_addr(5 downto 1) /= "00111" and bus_addr(5 downto 1) /= "01010" then
                     rmer1_rmr <= '1';
                  else

                     if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then

                        case bus_addr(5 downto 1) is
-- rmcs1 17 776 700 - control/status 1
                           when "00000" =>
                              rmcs1_rdyset <= bus_dato(7);
                              rmcs1_ie <= bus_dato(6);
                              rmcs1_fnc <= bus_dato(5 downto 1);
                              if rmcs1_sc = '0' then
                                 rmcs1_go <= bus_dato(0);
                                 if rmds_err = '0' then
                                    rmds_ata <= '0';
                                 end if;
                              end if;

-- rmwc  17 776 702                                             -- word count
                           when "00001" =>
                              rmwc(7 downto 0) <= bus_dato(7 downto 0);
                              update_rmwc <= '1';

-- rmba  17 776 704                                             -- bus address
                           when "00010" =>
                              rmba(7 downto 0) <= bus_dato(7 downto 0);

-- rmda  17 776 706                                             -- desired sector/track
                           when "00011" =>
                              rmda_sa <= bus_dato(7 downto 0);

-- rmcs2 17 776 710                                             -- control/status 2
                           when "00100" =>
                              if bus_dato(5) = '1' then
                                 rmcs2_clr <= '1';
                              end if;
                              rmcs2_pat <= bus_dato(4);
                              rmcs2_bai <= bus_dato(3);
                              rmcs2_u <= bus_dato(2 downto 0);

-- rmer1 17 776 714                                             -- error status 1
                           when "00110" =>
                              rmer1_hce <= bus_dato(7);
                              rmer1_ech <= bus_dato(6);
                              rmer1_wcf <= bus_dato(5);
                              rmer1_fer <= bus_dato(4);
                              rmer1_par <= bus_dato(3);
                              rmer1_rmr <= bus_dato(2);
                              rmer1_ilr <= bus_dato(1);
                              rmer1_ilf <= bus_dato(0);

-- rmas  17 776 716                                             -- attention summary
                           when "00111" =>
                              rmds_ata <= '0';                   -- FIXME, not correct@!

-- rmmr1  17 776 724                                            -- maintenance register
                           when "01010" =>
                              if bus_dato(3) = '1' then         -- set rmds writelock
                                 rmds_wrl <= '1';
                              end if;
                              if bus_dato(0) = '1' then
                                 rmds_vv <= '0';
                              end if;
                              rmmr1(0) <= bus_dato(0);          -- dmd bit
                              if bus_dato(0) = '0' then
                                 rmmr1 <= (others => '0');
                              end if;

-- rmof  17 776 732                                             -- offset
                           when "01101" =>
                              rmof_ofd <= bus_dato(7);

-- rmdc  17 776 734                                             -- cylinder
                           when "01110" =>
                              rmdc(7 downto 0) <= bus_dato(7 downto 0);
                              rmds_om <= '0';

-- rmer2 17 776 742
                           when "10001" =>
                              rmer2_dvc <= bus_dato(7);
                              rmer2_dpe <= bus_dato(3);

-- rmbae 17 776 750
                           when "10100" | "11110" =>
                              if have_rh70 = 1 then
                                 rmbae <= bus_dato(5 downto 0);
                              end if;

                           when others =>
                              null;

                        end case;
                     end if;

                     if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then

                        case bus_addr(5 downto 1) is
-- rmcs1 17 776 700 - control/status 1
                           when "00000" =>
                              rmbae(1 downto 0) <= bus_dato(9 downto 8);

-- rmwc   17 776 702                                            -- word count
                           when "00001" =>
                              rmwc(15 downto 8) <= bus_dato(15 downto 8);
                              update_rmwc <= '1';

-- rmba   17 776 704                                            -- bus address
                           when "00010" =>
                              rmba(15 downto 8) <= bus_dato(15 downto 8);

-- rmda   17 776 706                                            -- desired sector/track
                           when "00011" =>
                              rmda_ta <= bus_dato(15 downto 8);

-- rmcs2 17 776 710                                             -- control/status 2
                           when "00100" =>
                              rmcs2_pe <= bus_dato(13);
                              rmcs2_mxf <= bus_dato(9);

-- rmer1 17 776 714                                             -- error status 1
                           when "00110" =>
                              rmer1_dck <= bus_dato(15);
                              rmer1_uns <= bus_dato(14);
                              rmer1_opi <= bus_dato(13);
                              rmer1_dte <= bus_dato(12);
                              rmer1_wle <= bus_dato(11);
                              rmer1_iae <= bus_dato(10);
                              rmer1_aoe <= bus_dato(9);
                              rmer1_hcrc <= bus_dato(8);

-- rmas  17 776 716                                             -- attention summary
                           when "00111" =>
                              rmds_ata <= '0';

-- rmof  17 776 732                                             -- offset
                           when "01101" =>
                              rmof_fmt <= bus_dato(12);
                              rmof_eci <= bus_dato(11);
                              rmof_hci <= bus_dato(10);

-- rmdc  17 776 734                                             -- cylinder
                           when "01110" =>
                              rmdc(15 downto 8) <= bus_dato(15 downto 8);
                              rmds_om <= '0';

-- rmer2 17 776 742
                           when "10001" =>
                              rmer2_bse <= bus_dato(15);
                              rmer2_ski <= bus_dato(14);
                              rmer2_ope <= bus_dato(13);
                              rmer2_ivc <= bus_dato(12);
                              rmer2_lsc <= bus_dato(11);
                              rmer2_lbc <= bus_dato(10);

                           when others =>
                              null;

                        end case;
                     end if;
                  end if;

               end if;

               if base_addr_match = '1' and (bus_control_dati = '1' or bus_control_dato = '1') then

                  case bus_addr(5 downto 1) is

                     when "10100" | "10101" | "11110" =>
                        if have_rh70 = 0 then
                           rmer1_ilr <= '1';
                        end if;

                     when "10110" | "10111"
                        | "11000" | "11001"
                        | "11010" | "11011"
                        | "11100" | "11101"
                                  | "11111" =>
                        rmer1_ilr <= '1';

                     when others =>
                        null;

                  end case;

               end if;

               rmclock <= rmclock + 1;
               if rmclock = 0 then
                  if rmla_sc = "11111" then
                     rmla_sc <= "00000";
                  else
                     rmla_sc <= rmla_sc + "00001";
                  end if;
               end if;

               if rmds_ataset = '1' then
                  rmds_ata <= '1';
                  rmds_ataset <= '0';
               end if;

               if rmcs1_rdyset = '1' then
                  rmcs1_rdy <= '1';
                  rmcs1_rdyset <= '0';
               end if;

               if update_rmwc = '1' then
                  update_rmwc <= '0';
                  wcp <= (not rmwc) + 1;
               end if;

               if rmcs2_pat = '1' and (bus_dato(15) xor bus_dato(14) xor bus_dato(13) xor bus_dato(12) xor bus_dato(11)
               xor bus_dato(10) xor bus_dato(9) xor bus_dato(8) xor bus_dato(7) xor bus_dato(6)
               xor bus_dato(5) xor bus_dato(4) xor bus_dato(3) xor bus_dato(2) xor bus_dato(1)
               xor bus_dato(0)) = '1' then
                  rmer1_par <= '1';
               end if;

               if rmcs1_go = '1' then

                  rmcs1_mcpe <= '0';
                  rmcs1_psel <= '0';

                  rmcs2_dlt <= '0';
                  rmcs2_wce <= '0';
                  rmcs2_pe <= '0';
                  --rmcs2_ned <= '0';
                  rmcs2_nem <= '0';
                  rmcs2_mxf <= '0';
                  rmcs2_pge <= '0';
                  rmcs2_mdpe <= '0';

                  if (rmds_vv = '0' or rmds_dry = '0')
                  and rmcs1_fnc /= "01000" and rmcs1_fnc /= "01001" then
                     rmer2_ivc <= '1';
                     rmcs1_go <= '0';
                     rmds_ataset <= '1';
                  elsif rmcs2_u /= "000" then
                   -- nothing - there is one drive only
                  else

                     if unsigned(rmdc) < unsigned(noofcyl) then
                        v_rcyl := '0';
                     else
                        v_rcyl := '1';
                     end if;

                     if unsigned(rmda_ta) < unsigned(nooftrk) then
                        v_rtrk := '0';
                     else
                        v_rtrk := '1';
                     end if;

                     if unsigned(rmda_sa) < unsigned(noofsec) then
                        v_rsec := '0';
                     else
                        v_rsec := '1';
                     end if;

                     if v_rcyl = '0' and v_rtrk = '0' and v_rsec = '0'
                     then
                        v_iae := '0';
                     else
                        v_iae := '1';
                     end if;

                     case rmcs1_fnc is
                        when "00000" =>             -- nop
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "00010" =>             -- seek
                           if v_iae = '1' then
                              rmer1_iae <= '1';
                           end if;
                           rmds_ataset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';
                           rmcs1_rdyset <= '1';

                        when "00011" =>             -- recalibrate
                           rmda_ta <= (others => '0');
                           rmda_sa <= (others => '0');
                           rmdc <= (others => '0');           -- clear desired cylinder
                           rmds_vv <= '1';                    -- set volume valid
                           rmds_om <= '0';
                           rmof_ofd <= '0';
                           rmof_hci <= '0';
                           rmof_eci <= '0';
                           rmof_fmt <= '0';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';
                           rmds_ataset <= '1';

                        when "00100" =>             -- drive clear (EK-RP056-MM-01_maint_Dec75.pdf)
                           error_reset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "00101" =>             -- port clear aka release
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "00110" =>             -- offset
                           rmds_om <= '1';
                           rmds_ataset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "00111" =>             -- centerline aka reset
                           rmds_om <= '0';
                           rmds_ataset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "01000" =>             -- read in preset (EK-RP056-MM-01_maint_Dec75.pdf)
                           rmda_ta <= (others => '0');
                           rmda_sa <= (others => '0');
                           rmdc <= (others => '0');           -- clear desired cylinder
                           rmds_vv <= '1';                    -- set volume valid
                           rmds_om <= '0';
                           rmof_ofd <= '0';
                           rmof_hci <= '0';
                           rmof_eci <= '0';
                           rmof_fmt <= '0';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "01001" =>             -- pack acknowledge
                           rmds_vv <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                        when "01100" =>             -- search
                           if v_iae = '1' then
                              rmer1_iae <= '1';
                           end if;
                           rmds_ataset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';
--                           rmcs1_rdyset <= '1';

                        when "10011" =>             -- ident for RM06
                           if rh_type = 1 then
                              rmcs1_go <= '0';
                              rmds_dry <= '1';
                           else
                              rmer1_ilf <= '1';
                              rmer2_ivc <= '1';
                              rmds_ataset <= '1';
                              rmcs1_go <= '0';
                              rmds_dry <= '1';
                           end if;

                        when "11000" | "11001" =>             -- write data, write header/data
                           rmcs1_rdy <= '0';
                           rmds_om <= '0';
                           if sdcard_idle = '1' and write_start = '0' then
                              if v_iae = '1' then
                                 rmer1_iae <= '1';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 rmcs1_rdyset <= '1';
                                 rmds_ataset <= '1';
                              elsif rmds_wrl = '1' then                  -- if write lock is on
                                 rmer1_wle <= '1';
                                 rmds_ataset <= '1';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 rmcs1_rdyset <= '1';
                              else
                                 write_start <= '1';
                                 if rmcs1_fnc(0) = '1' and unsigned(wcp) >= unsigned'("0000000000000010") then
                                    wcp <= wcp - 2;
                                 end if;
                              end if;

                           elsif sdcard_write_ack = '1' and sdcard_write_done = '0' and write_start = '1' then
                              write_start <= '0';

                              if nxm = '0' and sdcard_error = '0' then
                                 if rmda_sa = noofsec - 1 then
                                    rmda_sa <= (others => '0');
                                    if rmda_ta = nooftrk - 1 then
                                       rmda_ta <= (others => '0');
                                       if rmdc = noofcyl then
                                          rmer1_aoe <= '1';
                                       else
                                          rmdc <= rmdc + 1;
                                          if rmdc = noofcyl - 1 then
                                             rmds_lst <= '1';
                                          end if;
                                       end if;
                                    else
                                       rmda_ta <= rmda_ta + 1;
                                    end if;
                                 else
                                    rmda_sa <= rmda_sa + 1;
                                 end if;

                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                                 else
                                    wcp <= (others => '0');
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
--                                    rmcs1_rdy <= '1';
                                    rmcs1_rdyset <= '1';
                                 end if;
                              else
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 if nxm = '1' then
                                    rmcs2_nem <= '1';
                                 end if;
                                 if sdcard_error = '1' then
                                    rmer1_dck <= '1';
                                 end if;
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                              end if;

                           end if;

                        when "11100" | "11101" | "10100" | "10101" =>             -- read data, read header/data, write check, write check header/data
                           rmcs1_rdy <= '0';
                           if sdcard_idle = '1' and sdcard_read_start = '0' and sdcard_read_done = '0' then
                              if v_iae = '1' then
                                 rmer1_iae <= '1';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 rmcs1_rdyset <= '1';
                                 rmds_ataset <= '1';
                              else
                                 sdcard_read_start <= '1';
                                 if rmcs1_fnc(0) = '1' and unsigned(wcp) >= unsigned'("0000000000000010") then
                                    wcp <= wcp - 2;
                                 end if;
                              end if;

                           elsif sdcard_read_ack = '1' and sdcard_read_done = '0' and sdcard_read_start = '1' then
                              sdcard_read_start <= '0';

                              if nxm = '0' and sdcard_error = '0' then
                                 if rmda_sa = noofsec - 1 then
                                    rmda_sa <= (others => '0');
                                    if rmda_ta = nooftrk - 1 then
                                       rmda_ta <= (others => '0');
                                       if rmdc = noofcyl then
                                          rmer1_aoe <= '1';
                                       else
                                          rmdc <= rmdc + 1;
                                          if rmdc = noofcyl - 1 then
                                             rmds_lst <= '1';
                                          end if;
                                       end if;
                                    else
                                       rmda_ta <= rmda_ta + 1;
                                    end if;
                                 else
                                    rmda_sa <= rmda_sa + 1;
                                 end if;

                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                                 else
                                    wcp <= (others => '0');
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
--                                    rmcs1_rdy <= '1';
                                    rmcs1_rdyset <= '1';
                                 end if;
                              else
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 if nxm = '1' then
                                    rmcs2_nem <= '1';
                                 end if;
                                 if sdcard_error = '1' then
                                    rmer1_dck <= '1';
                                 end if;
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                              end if;

                           end if;

                        when others =>
                           rmer1_ilf <= '1';
                           rmer2_ivc <= '1';
                           rmds_ataset <= '1';
                           rmcs1_go <= '0';
                           rmds_dry <= '1';

                     end case;
                  end if;
               end if;


-- reset controller and disks
               if rmcs2_clr = '1' then

-- rmcs1 17 776 700 - control/status 1
                  rmcs1_rdy <= '1';
                  rmcs1_ie <= '0';
                  rmcs1_fnc <= "00000";
                  rmcs1_go <= '0';

                  rmcs1_dva <= '1';
                  rmcs1_mcpe <= '0';
                  rmcs1_psel <= '0';

-- rmwc  17 776 702                                             -- word count
                  rmwc <= (others => '0');
                  update_rmwc <= '1';

-- rmba   17 776 704                                            -- bus address
                  rmba <= (others => '0');

-- rmda   17 776 706                                            -- desired sector/track
                  rmda_ta <= (others => '0');
                  rmda_sa <= (others => '0');

-- rmcs2 17 776 710                                             -- control/status 2
                  rmcs2_clr <= '0';                                  -- reset master flag
                  rmcs2_dlt <= '0';
                  rmcs2_wce <= '0';
                  rmcs2_pe <= '0';
                  --rmcs2_ned <= '0';
                  rmcs2_nem <= '0';
                  rmcs2_pge <= '0';
                  rmcs2_mxf <= '0';
                  rmcs2_mdpe <= '0';
                  rmcs2_or <= '0';                                   -- not ready for output just after reset
                  rmcs2_ir <= '1';                                   -- ready for input
                  rmcs2_pat <= '0';
                  rmcs2_bai <= '0';
                  rmcs2_u <= "000";                                  -- unit number

-- rmds  17 776 712                                             -- drive status
                  rmds_ata <= '0';
--                  rmds_err <= '0';
                  rmds_pip <= '0';
                  rmds_mol <= '1';                                   -- medium is online
                  rmds_wrl <= '0';
                  rmds_lst <= '0';
                  rmds_pgm <= '0';
                  rmds_dpr <= '1';                                   -- drive is available to this controller, there is no other controller
                  rmds_dry <= '1';                                   -- FIXME, set according to sdcard state?
                  rmds_vv <= '1';                                    -- FIXME, set according to sdcard state?
                  rmds_om <= '0';

-- rmmr1  17 776 724                                             -- maintenance register
                  rmmr1 <= (others => '0');

-- rmdc  17 776 734                                             -- cylinder
                  rmdc <= (others => '0');           -- clear desired cylinder

-- rmbae 17 776 750
                  rmbae <= (others => '0');

-- rmcs3 17 776 752
                  rmcs3_ape <='0';
                  rmcs3_dpe <= (others => '0');
                  rmcs3_wce <= (others => '0');
                  rmcs3_dbl <='0';
--                  rmcs3_ie <='0';
                  rmcs3_ipck <= (others => '0');


                  error_reset <= '1';
               end if;

               if error_reset = '1' then
                  error_reset <= '0';

                  rmer1_dck <='0';
                  rmer1_uns <='0';
                  rmer1_opi <='0';
                  rmer1_dte <='0';
                  rmer1_wle <='0';
                  rmer1_iae <='0';
                  rmer1_aoe <='0';
                  rmer1_hcrc <='0';
                  rmer1_hce <='0';
                  rmer1_ech <='0';
                  rmer1_wcf <='0';
                  rmer1_fer <='0';
                  rmer1_par <='0';
                  rmer1_rmr <='0';
                  rmer1_ilr <='0';
                  rmer1_ilf <='0';

                  rmer2_dpe <='0';
                  rmer2_dvc <='0';
                  rmer2_lbc <='0';
                  rmer2_lsc <='0';
                  rmer2_ivc <='0';
                  rmer2_ope <='0';
                  rmer2_ski <='0';
                  rmer2_bse <='0';

                  rmmr1 <= "0000000000001000";
                  rmmr2 <= "0" & o"11777";

               end if;
            end if;

         end if;
      end if;
   end process;

-- compose sector address

-- 24 bits adders :-)
   ca_offset <=
      ("000000" & rmdc(9 downto 0) & "00000000")
      + ("0000000" & rmdc(9 downto 0) & "0000000")
      + ("000000000" & rmdc(9 downto 0) & "00000")
      + ("0000000000000" & rmdc(9 downto 0) & "0")
   when rh_type = 4                                                  -- rmdc * 418, rp04/rp05
   else
      ("00000" & rmdc(9 downto 0) & "000000000")
      + ("00000000" & rmdc(9 downto 0) & "000000")
      + ("000000000" & rmdc(9 downto 0) & "00000")
   when rh_type = 5                                                  -- rmdc * 608, rm05
   else
      ("000000" & rmdc(9 downto 0) & "00000000")
      + ("0000000" & rmdc(9 downto 0) & "0000000")
      + ("000000000" & rmdc(9 downto 0) & "00000")
      + ("0000000000000" & rmdc(9 downto 0) & "0")
   when rh_type = 6                                                  -- rmdc * 418, rp06
   else
      + ("0000" & rmdc(9 downto 0) & "0000000000")
      + ("00000" & rmdc(9 downto 0) & "000000000")
      + ("00000000" & rmdc(9 downto 0) & "000000")
   when rh_type = 7                                                  -- rmdc * 1600, rp07
   else "000000000000000000000000";

   sd_addr <=
      rmdc(12 downto 0) & rmda_ta(4 downto 0) & rmda_sa(5 downto 0)
   when rh_type = 1                                                  -- 2048*dc + 64*ta + sa : rm06
   else
      rmdc(11 downto 0) & rmda_ta(5 downto 0) & rmda_sa(5 downto 0)
   when rh_type = 2                                                  -- 4096*dc + 64*ta + sa : rp2g
   else
      unsigned(ca_offset)
      + unsigned("000000000000000" & rmda_ta(4 downto 0) & "0000")
      + unsigned("00000000000000000" & rmda_ta(4 downto 0) & "00")
      + unsigned("000000000000000000" & rmda_ta(4 downto 0) & "0")
      + unsigned("0000000000000000000" & rmda_sa(4 downto 0))
   when rh_type = 4                                                  -- 418*dc + 22*ta + sa : rp04/rp05
   else
      unsigned(ca_offset)
      + unsigned("00000000000000" & rmda_ta(4 downto 0) & "00000")
      + unsigned("0000000000000000000" & rmda_sa(4 downto 0))
   when rh_type = 5                                                  -- 608*dc + 32*ta + sa : rm05
   else
      unsigned(ca_offset)
      + unsigned("000000000000000" & rmda_ta(4 downto 0) & "0000")
      + unsigned("00000000000000000" & rmda_ta(4 downto 0) & "00")
      + unsigned("000000000000000000" & rmda_ta(4 downto 0) & "0")
      + unsigned("0000000000000000000" & rmda_sa(4 downto 0))
   when rh_type = 6                                                  -- 418*dc + 22*ta + sa : rp06
   else
      unsigned(ca_offset)
      + unsigned("00000000000000" & rmda_ta(4 downto 0) & "00000")
      + unsigned("000000000000000" & rmda_ta(4 downto 0) & "0000")
      + unsigned("000000000000000000" & rmda_ta(4 downto 0) & "0")
      + unsigned("000000000000000000" & rmda_sa(5 downto 0))
   when rh_type = 7                                                  -- 1600*dc + 50*ta + sa : rp07
   else "000000000000000000000000";

-- busmaster

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            busmaster_state <= busmaster_idle;
            npr <= '0';
            sdcard_read_ack <= '0';
            sdcard_write_start <= '0';
            nxm <= '0';
         else

            if have_rh = 1 then

               case busmaster_state is

                  when busmaster_idle =>
                     nxm <= '0';
                     if write_start = '1' then
                        npr <= '1';
                        if npg = '1' then
                           busmaster_state <= busmaster_write1;
                           if rmcs1_fnc = "11001" then                        -- write header/data
                              work_bar <= (rmbae & rmba(15 downto 1)) + 2;
                           else
                              work_bar <= rmbae & rmba(15 downto 1);
                           end if;
                           if unsigned(wcp) >= unsigned'("0000000100000000") then
                              sectorcounter <= "100000000";
                           elsif wcp = "0000000000000000" then
                              sectorcounter <= "000000000";
                           else
                              sectorcounter <= '0' & wcp(7 downto 0);
                           end if;

                           sdcard_xfer_addr <= 0;
                        end if;
                     elsif sdcard_read_done = '1' then
                        npr <= '1';
                        if npg = '1' then
                           work_bar <= rmbae & rmba(15 downto 1);
                           if rmcs1_fnc(0) = '1' then                        -- read header/data, write check header/data
                              busmaster_state <= busmaster_readh;
                           else
                              busmaster_state <= busmaster_read1;
                           end if;
                           if unsigned(wcp) >= unsigned'("0000000100000000") then
                              sectorcounter <= "100000000";
                           else
                              sectorcounter <= '0' & wcp(7 downto 0);
                           end if;

                           sdcard_xfer_addr <= 0;
                           sdcard_xfer_read <= '1';
                        end if;
                     end if;


                  when busmaster_readh =>
                     if have_rh70 = 1 then
                        rh70_bus_master_addr <= work_bar & '0';
                        rh70_bus_master_dato <= "110" & rmof_fmt & rmdc(11 downto 0);  -- this is for testing only, so don't need it for rm06/rp2g. But it won't do any harm.
                        rh70_bus_master_control_dato <= '1';
                     else
                        bus_master_addr <= work_bar(17 downto 1) & '0';
                        bus_master_dato <= rmdc;
                        bus_master_control_dato <= '1';
                     end if;
                     work_bar <= work_bar + 1;
                     busmaster_state <= busmaster_readh2;


                  when busmaster_readh2 =>
                     if have_rh70 = 1 then
                        rh70_bus_master_addr <= work_bar & '0';
                        rh70_bus_master_dato <= rmda_ta & rmda_sa;
                        rh70_bus_master_control_dato <= '1';
                     else
                        bus_master_addr <= work_bar(17 downto 1) & '0';
                        bus_master_dato <= rmda_ta & rmda_sa;
                        bus_master_control_dato <= '1';
                     end if;
                     work_bar <= work_bar + 1;
                     busmaster_state <= busmaster_read1;


                  when busmaster_read1 =>
                     busmaster_state <= busmaster_read;
                     if have_rh70 = 1 then
                        rh70_bus_master_addr <= work_bar & '0';
                        rh70_bus_master_dato <= sdcard_xfer_out;
                        rh70_bus_master_control_dato <= '0';
                     else
                        bus_master_addr <= work_bar(17 downto 1) & '0';
                        bus_master_dato <= sdcard_xfer_out;
                        bus_master_control_dato <= '0';
                     end if;
                     sdcard_xfer_addr <= sdcard_xfer_addr + 1;


                  when busmaster_read =>
                     if sectorcounter /= "000000000" then
                        work_bar <= work_bar + 1;
                        sdcard_xfer_addr <= sdcard_xfer_addr + 1;
                        sectorcounter <= sectorcounter - 1;

                        if have_rh70 = 1 then
                           rh70_bus_master_control_dati <= '0';
                           rh70_bus_master_control_dato <= '1';
                           rh70_bus_master_addr <= work_bar & '0';
                           rh70_bus_master_dato <= sdcard_xfer_out;
                        else
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '1';
                           bus_master_addr <= work_bar(17 downto 1) & '0';
                           bus_master_dato <= sdcard_xfer_out;
                        end if;
                     else
                        busmaster_state <= busmaster_read_done;
                        if have_rh70 = 1 then
                           rh70_bus_master_control_dati <= '0';
                           rh70_bus_master_control_dato <= '0';
                        else
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '0';
                        end if;
                     end if;

                     if bus_master_nxm = '1' and have_rh70 = 0 then
                        nxm <= '1';
                        busmaster_state <= busmaster_read_done;
                     end if;
                     if rh70_bus_master_nxm = '1' and have_rh70 = 1 then
                        nxm <= '1';
                        busmaster_state <= busmaster_read_done;
                     end if;


                  when busmaster_read_done =>
                     npr <= '0';
                     sdcard_xfer_read <= '0';
                     sdcard_read_ack <= '1';
                     if have_rh70 = 1 then
                        rh70_bus_master_control_dati <= '0';
                        rh70_bus_master_control_dato <= '0';
                     else
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                     end if;
                     if sdcard_read_ack = '1' and sdcard_read_done = '0' then
                        busmaster_state <= busmaster_idle;
                        sdcard_read_ack <= '0';
                     end if;


                  when busmaster_write1 =>
                     sdcard_xfer_write <= '0';
                     sdcard_xfer_addr <= 255;
                     if sectorcounter /= "000000000" then
                        if have_rh70 = 1 then
                           rh70_bus_master_addr <= work_bar & '0';
                           rh70_bus_master_control_dati <= '1';
                        else
                           bus_master_addr <= work_bar(17 downto 1) & '0';
                           bus_master_control_dati <= '1';
                        end if;
                        work_bar <= work_bar + 1;
                        busmaster_state <= busmaster_write;
                     else
                        busmaster_state <= busmaster_writen;
                     end if;


                  when busmaster_write =>
                     sectorcounter <= sectorcounter - 1;
                     if sectorcounter /= "000000000" then
                        if have_rh70 = 1 then
                           sdcard_xfer_in <= rh70_bus_master_dati;
                        else
                           sdcard_xfer_in <= bus_master_dati;
                        end if;
                        sdcard_xfer_write <= '1';
                        sdcard_xfer_addr <= sdcard_xfer_addr + 1;

                        if sectorcounter /= "000000001" then
                           work_bar <= work_bar + 1;
                           if have_rh70 = 1 then
                              rh70_bus_master_addr <= work_bar & '0';
                              rh70_bus_master_control_dati <= '1';
                           else
                              bus_master_addr <= work_bar(17 downto 1) & '0';
                              bus_master_control_dati <= '1';
                           end if;
                        end if;
                     else
                        if sdcard_xfer_addr = 255 then
                           busmaster_state <= busmaster_write_wait;
                        else
                           busmaster_state <= busmaster_writen;
                        end if;
                        npr <= '0';
                        if have_rh70 = 1 then
                           rh70_bus_master_control_dati <= '0';
                        else
                           bus_master_control_dati <= '0';
                        end if;
                     end if;


                  when busmaster_writen =>
                     npr <= '0';
                     if sdcard_xfer_addr = 255 then
                        busmaster_state <= busmaster_write_wait;
                     else
                        sdcard_xfer_in <= (others => '0');
                        sdcard_xfer_addr <= sdcard_xfer_addr + 1;
                        sdcard_xfer_write <= '1';
                     end if;


                  when busmaster_write_wait =>
                     sdcard_write_start <= '1';
                     sdcard_xfer_write <= '0';
                     if sdcard_write_done = '1' then
                        busmaster_state <= busmaster_write_done;
                        sdcard_write_start <= '0';
                     end if;


                  when busmaster_write_done =>
                     sdcard_write_ack <= '1';
                     if sdcard_write_ack = '1' and sdcard_write_done = '0' then
                        busmaster_state <= busmaster_idle;
                        sdcard_write_ack <= '0';
                     end if;

                  when others =>

               end case;

            end if;

         end if;
      end if;
   end process;

end implementation;

