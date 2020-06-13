
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

-- $Revision: 1.14 $

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
      have_rh_debug : in integer range 0 to 1 := 1;
      rmtype : in integer range 4 to 7 := 6;
      reset : in std_logic;
      sdclock : in std_logic;
      clk : in std_logic
   );
end rh11;

architecture implementation of rh11 is


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

-- rmhr  17 776 736                                                  -- holding register
signal rmhr : std_logic_vector(15 downto 0);                         -- holding register

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


-- others

signal start_read : std_logic;
signal start_write : std_logic;
signal update_rmwc : std_logic;
signal wcp : std_logic_vector(15 downto 0);            -- word count, positive
signal wrkdb : std_logic_vector(15 downto 0);          -- written by sdcard state machine, copied whenever a command finishes

signal error_reset : std_logic := '1';
signal rmclock : integer range 0 to 4095 := 0;
signal rmclock_piptimer : integer range 0 to 3 := 0;

signal rmcs1_rdyset : std_logic := '0';
signal rmds_ataset : std_logic := '0';


-- sd card interface

signal sdclock_enable : std_logic;

type sd_states is (
   sd_reset,
   sd_clk1,
   sd_clk2,
   sd_cmd0,
   sd_cmd1,
   sd_cmd1_checkresponse,
   sd_error_nxm,
   sd_error,
   sd_error_recover,
   sd_send_cmd,
   sd_send_cmd_noresponse,
   sd_set_block_length,
   sd_set_block_length_checkresponse,
   sd_read,
   sd_read_checkresponse,
   sd_read_data_waitstart,
   sd_read_data,
   sd_read_rest,
   sd_read_done,
   sd_readr1,
   sd_readr1wait,
   sd_write,
   sd_write_checkresponse,
   sd_write_data_waitstart,
   sd_write_data_startblock,
   sd_write_data,
   sd_write_rest,
   sd_write_crc,
   sd_write_readcardresponse,
   sd_write_waitcardready,
   sd_write_done,
   sd_wait,
   sd_idle
);

signal sd_state : sd_states := sd_reset;
signal sd_nextstate : sd_states := sd_reset;

signal counter : integer range 0 to 255;
signal blockcounter : integer range 0 to 256;                   -- counter within sd card block
signal sectorcounter : std_logic_vector(8 downto 0);            -- counter within rk11 sector

signal sd_cmd : std_logic_vector(47 downto 0);
signal sd_r1 : std_logic_vector(6 downto 0);                    -- r1 response token from card
signal sd_dr : std_logic_vector(3 downto 0);                    -- data response token from card

signal sd_temp : std_logic_vector(15 downto 0);

signal hs_offset : std_logic_vector(22 downto 0);
signal ca_offset : std_logic_vector(22 downto 0);
signal dn_offset : std_logic_vector(22 downto 0);
signal sd_addr : std_logic_vector(22 downto 0);

signal work_bar : std_logic_vector(21 downto 1);

signal noofsec : std_logic_vector(7 downto 0);
signal nooftrk : std_logic_vector(7 downto 0);
signal noofcyl : std_logic_vector(15 downto 0);

begin

   with rmtype select noofsec <=
      "00010110" when 4,
      "00100000" when 5,
      "00010110" when 6,
      "00110010" when 7,
      "00000000" when others;

   with rmtype select nooftrk <=
      "00010011" when 4,
      "00010011" when 5,
      "00010011" when 6,
      "00100000" when 7,
      "00000000" when others;

   with rmtype select noofcyl <=
      "0000000110011011" when 4,
      "0000001100110111" when 5,
      "0000001100101111" when 6,
      "0000001001110110" when 7,
      "0000000000000000" when others;

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

   process(clk, reset)
      variable v_rsec : std_logic;
      variable v_rtrk : std_logic;
      variable v_rcyl : std_logic;
      variable v_iae : std_logic;
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            br <= '0';
            interrupt_trigger <= '0';
            interrupt_state <= i_idle;

            start_read <= '0';
            start_write <= '0';

            npr <= '0';

            rmcs2_clr <= '1';
            error_reset <= '1';
            rmcs1_rdyset <= '0';
            rmds_ataset <= '0';

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
               npr <= '0';
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
                        case rmtype is
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
                        bus_dati <= "000000" & rmdc(9 downto 0);

-- rmhr  17 776 736                                             -- holding register (rm05) current cylinder (rp0x)
                     when "01111" =>
--                        bus_dati <= rmhr;
                        bus_dati <= "000000" & rmdc(9 downto 0);

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
-- FIXME, left off for now - only causes more messages from zrmm                              rmmr1(0) <= bus_dato(0);          -- dmd bit

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

--                   if rmds_pip = '1' then
--                      if rmclock_piptimer /= 0 then
--                         rmclock_piptimer <= rmclock_piptimer - 1;
--                      else
--                         rmds_pip <= '0';
-- --                        rmds_ata <= '1';
--                      end if;
--                   end if;

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
                           rmcs1_rdyset <= '1';

                        when "11000" | "11001" =>             -- write data, write header/data
                           npr <= '1';
                           if npg = '1' then
                              if sd_state = sd_idle and start_write = '0' then
                                 if v_iae = '1' then
                                    rmer1_iae <= '1';
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
                                    npr <= '0';
                                    rmcs1_rdyset <= '1';
                                 elsif rmds_wrl = '1' then                  -- if write lock is on
                                    rmer1_wle <= '1';
                                    rmds_ataset <= '1';
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
                                    npr <= '0';
                                    rmcs1_rdyset <= '1';
                                 else
                                    start_write <= '1';
                                    if rmcs1_fnc = "11001" and unsigned(wcp) >= unsigned'("0000000000000010") then
                                       wcp <= wcp - 2;
                                    end if;
                                 end if;

                              elsif sd_state = sd_write_done and start_write = '1' then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 if rmda_sa = noofsec - 1 then
                                    rmda_sa <= (others => '0');
                                    if rmda_ta = nooftrk - 1 then
                                       rmda_ta <= (others => '0');
                                       if rmdc = noofcyl - 1 then
                                          rmer1_aoe <= '1';
                                       else
                                          rmdc <= rmdc + 1;
                                       end if;
                                    else
                                       rmda_ta <= rmda_ta + 1;
                                    end if;
                                 else
                                    rmda_sa <= rmda_sa + 1;
                                 end if;

                                 if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                                 else
                                    wcp <= (others => '0');
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
                                    npr <= '0';
                                    rmcs1_rdyset <= '1';
                                 end if;
                                 start_write <= '0';

                              elsif sd_state = sd_error_nxm then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 npr <= '0';
                                 rmcs2_nem <= '1';
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                                 start_write <= '0';

                              elsif sd_state = sd_error then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 npr <= '0';
                                 rmer1_dck <= '1';           -- ?? some error bit should be set, but this one?
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                                 start_write <= '0';

                              end if;
                           end if;

                        when "11100" | "11101" | "10100" | "10101" =>             -- read data, read header/data, write check, write check header/data
                           npr <= '1';
                           if npg = '1' then
                              if sd_state = sd_idle and start_read = '0' then
                                 if v_iae = '1' then
                                    rmer1_iae <= '1';
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
                                    npr <= '0';
                                    rmcs1_rdyset <= '1';
                                 else
                                    start_read <= '1';
                                    if rmcs1_fnc(0) = '1' and unsigned(wcp) >= unsigned'("0000000000000010") then
                                       wcp <= wcp - 2;
                                    end if;
                                 end if;

                              elsif sd_state = sd_read_done and start_read = '1' then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 if rmda_sa = noofsec - 1 then
                                    rmda_sa <= (others => '0');
                                    if rmda_ta = nooftrk - 1 then
                                       rmda_ta <= (others => '0');
                                       if rmdc = noofcyl - 1 then
                                          rmer1_aoe <= '1';
                                       else
                                          rmdc <= rmdc + 1;
                                       end if;
                                    else
                                       rmda_ta <= rmda_ta + 1;
                                    end if;
                                 else
                                    rmda_sa <= rmda_sa + 1;
                                 end if;

                                 if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                                 else
                                    wcp <= (others => '0');
                                    rmcs1_go <= '0';
                                    rmds_dry <= '1';
                                    npr <= '0';
                                    rmcs1_rdyset <= '1';
                                 end if;
                                 start_read <= '0';

                              elsif sd_state = sd_error_nxm then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 npr <= '0';
                                 rmcs2_nem <= '1';
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                                 start_read <= '0';

                              elsif sd_state = sd_error then
                                 rmbae <= work_bar(21 downto 16);
                                 rmba <= work_bar(15 downto 1) & '0';
                                 rmcs1_go <= '0';
                                 rmds_dry <= '1';
                                 npr <= '0';
                                 rmer1_dck <= '1';           -- ?? some error bit should be set, but this one?
                                 rmds_ataset <= '1';
                                 rmcs1_rdyset <= '1';
                                 start_read <= '0';

                              end if;
                           end if;

                        when others =>
                           rmer1_ilf <= '1';
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
                  rmcs2_u <= "000";

-- rmds  17 776 712                                             -- drive status
                  rmds_ata <='0';
--                  rmds_err <='0';
                  rmds_pip <='0';
                  rmds_mol <='1';                                    -- medium is online
                  rmds_wrl <='0';
                  rmds_lst <='0';
                  rmds_pgm <='0';
                  rmds_dpr <='1';                                    -- drive is available to this controller, there is no other controller
                  rmds_dry <='1';                                    -- FIXME, set according to sdcard state?
                  rmds_vv <='1';                                     -- FIXME, set according to sdcard state?
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

-- compose read address

-- 23 bits adders :-)
   ca_offset <=
      ("0000" & rmdc(9 downto 0) & "000000000")
      + ("0000000" & rmdc(9 downto 0) & "000000")
      + ("00000000" & rmdc(9 downto 0) & "00000")
   when rmtype = 5  -- rmdc * 608
   else
      ("00000" & rmdc(9 downto 0) & "00000000")
      + ("000000" & rmdc(9 downto 0) & "0000000")
      + ("00000000" & rmdc(9 downto 0) & "00000")
      + ("000000000000" & rmdc(9 downto 0) & "0")
   when rmtype = 4
   else
      ("00000" & rmdc(9 downto 0) & "00000000")
      + ("000000" & rmdc(9 downto 0) & "0000000")
      + ("00000000" & rmdc(9 downto 0) & "00000")
      + ("000000000000" & rmdc(9 downto 0) & "0")
   when rmtype = 6
   else "00000000000000000000000";

   sd_addr <=
      unsigned(ca_offset)
      + unsigned("0000000000000" & rmda_ta(4 downto 0) & "00000")
      + unsigned("000000000000000000" & rmda_sa(4 downto 0))
   when rmtype = 5
   else
      unsigned(ca_offset)
      + unsigned("00000000000000" & rmda_ta(4 downto 0) & "0000")
      + unsigned("0000000000000000" & rmda_ta(4 downto 0) & "00")
      + unsigned("00000000000000000" & rmda_ta(4 downto 0) & "0")
      + unsigned("000000000000000000" & rmda_sa(4 downto 0))
   when rmtype = 4
   else
      unsigned(ca_offset)
      + unsigned("00000000000000" & rmda_ta(4 downto 0) & "0000")
      + unsigned("0000000000000000" & rmda_ta(4 downto 0) & "00")
      + unsigned("00000000000000000" & rmda_ta(4 downto 0) & "0")
      + unsigned("000000000000000000" & rmda_sa(4 downto 0))
   when rmtype = 6
   else "00000000000000000000000";

-- handle sd card interface

   sdcard_sclk <= sdclock when sdclock_enable = '1' else '0';

   process(sdclock, reset)
   begin
      if sdclock = '1' and sdclock'event then
         if reset = '1' then
            sdclock_enable <= '0';
            counter <= 255;
            sd_state <= sd_reset;
            sd_nextstate <= sd_reset;
            if have_rh_debug = 1 then
               sdcard_debug <= "0010";
            end if;
            sdcard_cs <= '0';

            blockcounter <= 0;
            sectorcounter <= "000000000";
         else

            if have_rh = 1 then
               case sd_state is

   -- reset : start here to set the sd card in spi mode; first step is starting the clock

                  when sd_reset =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        counter <= 170;
                        sdclock_enable <= '1';
                        sdcard_cs <= '1';
                        sdcard_mosi <= '1';
                        sd_state <= sd_clk1;
                        if have_rh_debug = 1 then
                           sdcard_debug <= "0010";
                        end if;
                     end if;

   -- set the cs signal active

                  when sd_clk1 =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        counter <= 31;
                        sdcard_cs <= '0';
                        sd_state <= sd_clk2;
                     end if;

   -- allow some time to pass with the cs signal active

                  when sd_clk2 =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        sd_state <= sd_cmd0;
                     end if;

   -- send a cmd0 command, with a valid crc. after completion of this command, the card is in spi mode

                  when sd_cmd0 =>
                     counter <= 48;
                     sd_nextstate <= sd_cmd1;
                     sd_cmd <= x"400000000095";
                     sd_state <= sd_send_cmd_noresponse;

   -- send a cmd1 command, this initializes processes within the card

                  when sd_cmd1 =>
                     counter <= 48;
                     sd_nextstate <= sd_cmd1_checkresponse;
                     sd_cmd <= x"410000000001";
                     sd_state <= sd_send_cmd;

   -- check for completion of the cmd1 command. This may take a long time, so several retries are normal.

                  when sd_cmd1_checkresponse =>
                     if sd_r1 = "0000001" then
                        sd_state <= sd_cmd1;
                     elsif sd_r1 = "0000000" then
                        sd_state <= sd_set_block_length;
                     else
                        sd_state <= sd_error;
                     end if;

   -- set the default blocklength for read commands. Since 512 is required for all write commands anyway, this is what we'll use.

                  when sd_set_block_length =>
                     counter <= 48;
                     sd_nextstate <= sd_set_block_length_checkresponse;
                     sd_cmd <= x"500000020001";                   -- set blocklength to 512 bytes. It's the default, but let's just be sure anyway.
                     sd_state <= sd_send_cmd;
                     if have_rh_debug = 1 then
                        sdcard_debug <= "0001";
                     end if;

                  when sd_set_block_length_checkresponse =>
                     if sd_r1 = "0000000" then
                        sd_state <= sd_idle;                   -- init is complete
                     else
                        sd_state <= sd_error;
                     end if;

   -- send a read data command to the card

                  when sd_read =>
                     if rmcs1_fnc(0) = '1' then
                        work_bar <= (rmbae & rmba(15 downto 1)) + 2;
                     else
                        work_bar <= rmbae & rmba(15 downto 1);
                     end if;
                     sd_cmd <= x"51" & sd_addr & "000000000" & x"01";
                     sd_nextstate <= sd_read_checkresponse;
                     counter <= 48;
                     sd_state <= sd_send_cmd;

                     if have_rh_debug = 1 then
--                         bus_master_addr <= "00" & rkda_dr & rkda_cy & rkda_hd & rkda_sc;
                        sdcard_debug <= "0100";
                     end if;

   -- check the first response (r1 format) to the read command

                  when sd_read_checkresponse =>
                     if sd_r1 = "0000000" then
--                         counter <= 65535;                            -- some cards may take a long time to respond
                        sd_state <= sd_read_data_waitstart;
                     else
                        sd_state <= sd_error;
                     end if;

                     if have_rh_debug = 1 then
--                         bus_master_addr <= "00" & wcp;
                     end if;

   -- wait for the data header to be sent in response to the read command; the header value is 0xfe, so actually there is just one start bit to read.

                  when sd_read_data_waitstart =>
--                      if counter /= 0 then
--                         counter <= counter - 1;
                        if sdcard_miso = '0' then
                           sd_state <= sd_read_data;
                           counter <= 15;
                           blockcounter <= 255;                      -- 256 words = 512 bytes
                           if unsigned(wcp) >= unsigned'("0000000100000000") then
                              sectorcounter <= "011111111";           -- 255
                           else
                              sectorcounter <= '0' & (unsigned(wcp(7 downto 0)) - unsigned'("00000001"));  -- amount - 1
                           end if;
                        end if;
--                      else
--                         sd_state <= sd_error;
--                      end if;

                     if have_rh_debug = 1 then
--                         bus_master_addr <= "00" & rkcs_err & rkcs_he & rkcs_scp & '0' & rkcs_iba & rkcs_fmt & rkcs_exb & rkcs_sse & rkcs_rdy & rkcs_ide & rkcs_mex & rkcs_fu & rkcs_go;
                     end if;

   -- actual read itself, including moving the data to core. must be bus master at this point.

                  when sd_read_data =>
                     if counter = 0 then
                        counter <= 15;
                        work_bar <= work_bar + 1;
                        if have_rh70 = 1 then
                           rh70_bus_master_addr <= work_bar & '0';
                           rh70_bus_master_dato <= sd_temp(6 downto 0) & sdcard_miso & sd_temp(14 downto 7);
                        else
                           bus_master_addr <= work_bar(17 downto 1) & '0';
                           bus_master_dato <= sd_temp(6 downto 0) & sdcard_miso & sd_temp(14 downto 7);
                        end if;
                        if rmcs1_fnc = "11100" or rmcs1_fnc = "11101" then
                           if have_rh70 = 1 then
                              rh70_bus_master_control_dati <= '0';
                              rh70_bus_master_control_dato <= '1';
                           else
                              bus_master_control_dati <= '0';
                              bus_master_control_dato <= '1';
                           end if;
                        end if;
                        if sectorcounter = 0 then
                           sd_state <= sd_read_rest;
                        else
                           sectorcounter <= sectorcounter - 1;
                           blockcounter <= blockcounter - 1;
                        end if;
                     else
                        if bus_master_nxm = '1' and have_rh70 = 0 then
                           sd_state <= sd_error_nxm;
                        end if;
                        if rh70_bus_master_nxm = '1' and have_rh70 = 1 then
                           sd_state <= sd_error_nxm;
                        end if;
                        if have_rh70 = 1 then
                           rh70_bus_master_control_dati <= '0';
                           rh70_bus_master_control_dato <= '0';
                        else
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '0';
                        end if;
                        sd_temp <= sd_temp(14 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "0101";
                     end if;

   -- skip the rest of the sdcard sector

                  when sd_read_rest =>
                     if counter = 0 then
                        counter <= 15;
                        if blockcounter = 0 then
                           counter <= 31;
                           sd_state <= sd_wait;
                           sd_nextstate <= sd_read_done;
                        else
                           blockcounter <= blockcounter - 1;
                        end if;
                     else
                        counter <= counter - 1;
                     end if;
--                      if bus_master_nxm = '1' then
--                         sd_state <= sd_error_nxm;
--                      end if;
                     if have_rh70 = 1 then
                        rh70_bus_master_control_dati <= '0';
                        rh70_bus_master_control_dato <= '0';
                     else
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "0110";
                     end if;

   -- read done, wait for controller to wake up and allow us on to idle state

                  when sd_read_done =>
                     if start_read = '0' then
                        sd_state <= sd_idle;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "0111";
                     end if;

   -- send a write data command to the card

                  when sd_write =>
                     if rmcs1_fnc = "11001" then
                        work_bar <= (rmbae & rmba(15 downto 1)) + 2;
                     else
                        work_bar <= rmbae & rmba(15 downto 1);
                     end if;
                     sd_cmd <= x"58" & sd_addr & "000000000" & x"0f";
                     sd_nextstate <= sd_write_checkresponse;
                     counter <= 48;
                     sd_state <= sd_send_cmd;

                     if have_rh_debug = 1 then
--                        bus_master_addr <= "00" & rkda_dr & rkda_cy & rkda_hd & rkda_sc;
                        sdcard_debug <= "1000";
                     end if;

   -- check the first response (r1 format) to the write command

                  when sd_write_checkresponse =>
                     sdcard_mosi <= '1';
                     if sd_r1 = "0000000" then
                        counter <= 17;                              -- wait for this many cycles, should correspond to Nwr
                        sd_state <= sd_write_data_waitstart;
                     else
                        sd_state <= sd_error;
                     end if;

                     if have_rh_debug = 1 then
                        if have_rh70 = 1 then
                           rh70_bus_master_addr <= "000000" & wcp;
                        else
                           bus_master_addr <= "00" & wcp;
                        end if;
                     end if;

   -- wait for a while before starting the actual data block

                  when sd_write_data_waitstart =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        sd_state <= sd_write_data_startblock;
                     end if;

   -- send a start block token, note that the token is actually 1111 1110, but the first 6 bits should already have been sent by waitstart. This state sends another 1, and leaves sending the final 0 over to the next state.

                  when sd_write_data_startblock =>
                     sd_temp <= "0000000000000000";
                     counter <= 1;
                     sd_state <= sd_write_data;
                     blockcounter <= 256;                      -- 256 words = 512 bytes
                     if unsigned(wcp) >= unsigned'("0000000100000000") then
                        sectorcounter <= "100000000";           -- 256
                     else
                        sectorcounter <= '0' & wcp(7 downto 0);
                     end if;

   -- actually send out the bitstream

                  when sd_write_data =>
                     if counter = 1 and sectorcounter /= 0 then
                        if have_rh70 = 1 then
                           rh70_bus_master_control_dati <= '1';
                           rh70_bus_master_control_dato <= '0';
                           rh70_bus_master_addr <= work_bar & '0';
                        else
                           bus_master_control_dati <= '1';
                           bus_master_control_dato <= '0';
                           bus_master_addr <= work_bar(17 downto 1) & '0';
                        end if;
                        work_bar <= work_bar + 1;
                     end if;
                     if counter = 0 then
                        if have_rh70 = 1 then
                           sd_temp(15 downto 9) <= rh70_bus_master_dati(6 downto 0);
                           sd_temp(8 downto 1) <= rh70_bus_master_dati(15 downto 8);
                           sd_temp(0) <= '0';
                           rh70_bus_master_control_dati <= '0';
                           sdcard_mosi <= rh70_bus_master_dati(7);
                           if have_rh_debug = 1 then
                              rh70_bus_master_addr(15 downto 0) <= rh70_bus_master_dati;          -- echo data for debugging
                           end if;
                        else
                           sd_temp(15 downto 9) <= bus_master_dati(6 downto 0);
                           sd_temp(8 downto 1) <= bus_master_dati(15 downto 8);
                           sd_temp(0) <= '0';
                           bus_master_control_dati <= '0';
                           sdcard_mosi <= bus_master_dati(7);
                           if have_rh_debug = 1 then
                              bus_master_addr(15 downto 0) <= bus_master_dati;          -- echo data for debugging
                           end if;
                        end if;
                        counter <= 15;
                        if sectorcounter = 0 then
                           if blockcounter = 0 then
                              sd_state <= sd_write_crc;
                           else
                              sd_state <= sd_write_rest;
                           end if;
                        else
                           sectorcounter <= sectorcounter - 1;
                           blockcounter <= blockcounter - 1;
                        end if;
                        if bus_master_nxm = '1' and have_rh70 = 0 then
                           sd_state <= sd_error_nxm;
                        end if;
                        if rh70_bus_master_nxm = '1' and have_rh70 = 1 then
                           sd_state <= sd_error_nxm;
                        end if;
                     else
                        sdcard_mosi <= sd_temp(15);
                        counter <= counter - 1;
                        sd_temp <= sd_temp(14 downto 0) & '0';
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1001";
                     end if;

   -- send out rest of the bitstream, comprising of zeros to fill the block

                  when sd_write_rest =>
                     if counter = 0 then
                        counter <= 15;
                        sdcard_mosi <= '0';
                        if blockcounter = 0 then
                           counter <= 15;                            -- 16 crc bits to write
                           sdcard_mosi <= '1';
                           sd_state <= sd_write_crc;
                        else
                           blockcounter <= blockcounter - 1;
                        end if;
                     else
                        counter <= counter - 1;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1010";
                     end if;

   -- write crc bits, these will be ignored

                  when sd_write_crc =>
                     if counter = 0 then
                        counter <= 7;
                        sd_state <= sd_write_readcardresponse;
                        sdcard_mosi <= '0';
                     else
                        counter <= counter - 1;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1010";
                     end if;

   -- read card response token

                  when sd_write_readcardresponse =>
                     sd_dr(0) <= sdcard_miso;
                     sdcard_mosi <= '1';                               -- from this point on, mosi should probably be high
                     if counter < 3 then
                        sd_dr(3 downto 1) <= sd_dr(2 downto 0);
                     end if;
                     if counter = 0 then
--                         counter <= 65535;
                        sd_state <= sd_write_waitcardready;
                     else
                        counter <= counter - 1;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1011";
                     end if;

   -- wait for card to signal ready

                  when sd_write_waitcardready =>
--                      if counter = 0 then
   --                     sd_state <= sd_error;                     -- FIXME, should not be commented out
--                      else
--                         counter <= counter - 1;
--                         if have_rh_debug = 1 then
--                            bus_master_addr(3 downto 0) <= sd_dr;                -- FIXME, check the card response
--                         end if;
--                      end if;
                     if sdcard_miso = '1' then
                        counter <= 31;
                        sd_state <= sd_wait;
                        sd_nextstate <= sd_write_done;
                     end if;

   -- write done, wait for controller to wake up and allow us on to idle state

                  when sd_write_done =>
                     if start_write = '0' then
                        sd_state <= sd_idle;
                     end if;

   -- idle, wait for the controller to signal us to do some work

                  when sd_idle =>
                     if start_write = '1' then
                        sd_state <= sd_write;
                     end if;
                     if start_read = '1' then
                        sd_state <= sd_read;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "0000";
                     end if;

   -- here is where we end when the wrong thing happened; wait till the controller has noticed, setup to rest some cycles, then restart

                  when sd_error_nxm =>
                     if have_rh70 = 1 then
                        rh70_bus_master_control_dati <= '0';
                        rh70_bus_master_control_dato <= '0';
                     else
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                     end if;
                     if start_read = '0' and start_write = '0' then
                        counter <= 4;
                        sd_state <= sd_error_recover;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1110";
                     end if;

                  when sd_error =>
                     if start_read = '0' and start_write = '0' then
                        counter <= 4;
                        sd_state <= sd_error_recover;
                     end if;

                     if have_rh_debug = 1 then
                        sdcard_debug <= "1111";
                     end if;

   -- countdown some time and then try to reset the card

                  when sd_error_recover =>
                     sdcard_cs <= '0';
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        sd_state <= sd_reset;
                     end if;

   -- clock out what is in the sd_cmd, then setup to wait for a r1 response

                  when sd_send_cmd =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        sdcard_mosi <= sd_cmd(47);
                        sd_cmd <= sd_cmd(46 downto 0) & '1';
                     else
                        counter <= 255;
                        sd_state <= sd_readr1wait;
                     end if;

   -- clock out what in in the sd_cmd

                  when sd_send_cmd_noresponse =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        sdcard_mosi <= sd_cmd(47);
                        sd_cmd <= sd_cmd(46 downto 0) & '1';
                     else
                        counter <= 16;
                        sd_state <= sd_wait;
                     end if;

   -- wait to read an r1 response token from the card

                  when sd_readr1wait =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        if sdcard_miso = '0' then
                           sd_state <= sd_readr1;
                           counter <= 7;
                           sd_r1 <= (others => '1');
                        end if;
                     else
                        sd_state <= sd_error;
                     end if;

   -- read the r1 token

                  when sd_readr1 =>
                     if counter /= 0 then
                        sd_r1 <= sd_r1(5 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     else
                        counter <= 8;
                        sd_state <= sd_wait;
                     end if;

   -- wait some cycles after a command sequence, this seems to improve stability across card types

                  when sd_wait =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        sd_state <= sd_nextstate;
                     end if;

   -- catchall

                  when others =>
                     sd_state <= sd_reset;

               end case;

            end if;

         end if;
      end if;
   end process;

end implementation;

