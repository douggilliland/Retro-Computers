
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

-- $Revision: 1.60 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rk11 is
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
end rk11;

architecture implementation of rk11 is


-- regular bus interface

signal base_addr_match : std_logic;
signal interrupt_trigger : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;

-- rk11 registers - rkds - 777400

signal rkds_dri : std_logic_vector(2 downto 0);            -- drive ident - set to interrupting drive
signal rkds_dpl : std_logic;                               -- drive power loss
signal rkds_rk05 : std_logic;                              -- identify the drive as rk05
signal rkds_dru : std_logic;                               -- drive unsafe
signal rkds_sin : std_logic;                               -- seek incomplete
signal rkds_sok : std_logic;                               -- sector counter ok
signal rkds_dry : std_logic;                               -- drive ready
signal rkds_rwsrdy : std_logic;                            -- read/write/seek ready
signal rkds_wps : std_logic;                               -- write protected if 1
signal rkds_scsa : std_logic;                              -- disk address = sector counter
signal rkds_sc : std_logic_vector(3 downto 0);             -- sector counter

-- rk11 registers - rker - 777402

signal rker_wce : std_logic;                               -- write check error
signal rker_cse : std_logic;                               -- checksum error
signal rker_nxs : std_logic;                               -- nx sector
signal rker_nxc : std_logic;                               -- nx cylinder
signal rker_nxd : std_logic;                               -- nx disk
signal rker_te : std_logic;                                -- timing error
signal rker_dlt : std_logic;                               -- data late
signal rker_nxm : std_logic;                               -- nxm
signal rker_pge : std_logic;                               -- programming error
signal rker_ske : std_logic;                               -- seek error
signal rker_wlo : std_logic;                               -- write lockout
signal rker_ovr : std_logic;                               -- overrun
signal rker_dre : std_logic;                               -- drive error

-- rk11 registers - rkcs - 777404

signal rkcs_err : std_logic;                               -- error
signal rkcs_he : std_logic;                                -- hard error
signal rkcs_scp : std_logic;                               -- search complete
signal rkcs_iba : std_logic;                               -- inhibit increment rkba
signal rkcs_fmt : std_logic;                               -- format
signal rkcs_exb : std_logic;                               -- extra bit, unused?
signal rkcs_sse : std_logic;                               -- stop on soft error
signal rkcs_rdy : std_logic;                               -- ready
signal rkcs_ide : std_logic;                               -- interrupt on done enable
signal rkcs_mex : std_logic_vector(1 downto 0);            -- bit 18, 17 of address
signal rkcs_fu : std_logic_vector(2 downto 0);             -- function code
signal rkcs_go : std_logic;                                -- go

-- rk11 registers - rkwc - 777406

signal rkwc : std_logic_vector(15 downto 0);

-- rk11 registers - rkba - 777410

signal rkba : std_logic_vector(15 downto 0);

-- rk11 registers - rkda - 777412

signal rkda_dr : std_logic_vector(2 downto 0);
signal rkda_cy : std_logic_vector(7 downto 0);
signal rkda_hd : std_logic;
signal rkda_sc : std_logic_vector(3 downto 0);

-- rk11 registers - rkdb - 777416

signal rkdb : std_logic_vector(15 downto 0);


-- others

signal start : std_logic;
signal start_read : std_logic;
signal start_write : std_logic;
signal update_rkwc : std_logic;
signal wcp : std_logic_vector(15 downto 0);            -- word count, positive
signal wrkdb : std_logic_vector(15 downto 0);          -- written by sdcard state machine, copied whenever a command finishes


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
   sd_readfmt,
   sd_readfmt2,
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

signal hs_offset : std_logic_vector(16 downto 0);
signal ca_offset : std_logic_vector(16 downto 0);
signal dn_offset : std_logic_vector(16 downto 0);
signal sd_addr : std_logic_vector(16 downto 0);

signal work_bar : std_logic_vector(17 downto 1);

signal rkclock : integer range 0 to 4095;
subtype rksi_st is integer range 0 to 3;
type rksi_t is array(7 downto 0) of rksi_st;
signal rksi : rksi_t;
signal scpset : std_logic;

begin


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 4) = bus_addr(17 downto 4) and have_rk = 1 else '0';
   bus_addr_match <= base_addr_match;


-- specific logic for the device

   rkcs_err <= '1' when
      rker_wce = '1'
      or rker_cse = '1'
      or rker_nxs = '1'
      or rker_nxc = '1'
      or rker_nxd = '1'
      or rker_te = '1'
      or rker_dlt = '1'
      or rker_nxm = '1'
      or rker_pge = '1'
      or rker_ske = '1'
      or rker_wlo = '1'
      or rker_ovr = '1'
      or rker_dre = '1'
      else '0';

   rkcs_he <= '1' when
      rker_nxs = '1'
      or rker_nxc = '1'
      or rker_nxd = '1'
      or rker_te = '1'
      or rker_dlt = '1'
      or rker_nxm = '1'
      or rker_pge = '1'
      or rker_ske = '1'
      or rker_wlo = '1'
      or rker_ovr = '1'
      or rker_dre = '1'
      else '0';

   rkds_rwsrdy <= '1' when conv_integer(rkda_dr) < have_rk_num and rksi(conv_integer(rkda_dr)) = 0 and sd_state = sd_idle
      else '0';
   rkds_dry <= '1' when conv_integer(rkda_dr) < have_rk_num else '0';

-- regular bus interface : handle register contents and dependent logic

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            br <= '0';
            interrupt_trigger <= '0';
            interrupt_state <= i_idle;
            scpset <= '0';

            rksi(7) <= 0;
            rksi(6) <= 0;
            rksi(5) <= 0;
            rksi(4) <= 0;
            rksi(3) <= 0;
            rksi(2) <= 0;
            rksi(1) <= 0;
            rksi(0) <= 0;

            rkds_dri <= "000";                             -- drive ident
            rkds_dpl <= '0';                               -- not drive power loss
            rkds_rk05 <= '1';                              -- identify the drive as rk05
            rkds_dru <= '0';                               -- not drive unsafe
            rkds_sin <= '0';                               -- not seek incomplete
            rkds_sok <= '1';                               -- sector counter ok
--            rkds_dry <= '1';                               -- drive ready
            rkds_wps <= '0';                               -- not write protected
            rkds_scsa <= '1';                              -- disk address = sector counter
            rkds_sc <= "0000";                             -- sector counter

            rker_wce <= '0';
            rker_cse <= '0';
            rker_nxs <= '0';
            rker_nxc <= '0';
            rker_nxd <= '0';
            rker_te <= '0';
            rker_dlt <= '0';
            rker_nxm <= '0';
            rker_pge <= '0';
            rker_ske <= '0';
            rker_wlo <= '0';
            rker_ovr <= '0';
            rker_dre <= '0';

            rkba <= (others => '0');

            rkcs_scp <= '0';
            rkcs_iba <= '0';
            rkcs_fmt <= '0';
            rkcs_exb <= '0';
            rkcs_sse <= '0';
            rkcs_rdy <= '1';
            rkcs_ide <= '0';
            rkcs_mex <= "00";
            rkcs_fu <= "000";
            rkcs_go <= '0';

            rkda_dr <= (others => '0');
            rkda_cy <= (others => '0');
            rkda_hd <= '0';
            rkda_sc <= (others => '0');

            rkdb <= (others => '0');

            start <= '0';
            start_read <= '0';
            start_write <= '0';

            npr <= '0';

            rkwc <= (others => '0');
            update_rkwc <= '1';

            rkclock <= 0;

         else

            if have_rk = 1 then
               case interrupt_state is

                  when i_idle =>

                     br <= '0';
                     if rkcs_ide = '1' and scpset = '1' then
                        interrupt_state <= i_req;
                        br <= '1';
                        scpset <= '0';
                     end if;

                     if rkcs_ide = '1' and rkcs_rdy = '1' then
                        if interrupt_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger <= '1';
                        end if;
                     else
                        interrupt_trigger <= '0';
                     end if;

                  when i_req =>
                     if rkcs_ide = '1' then
                        if bg = '1' then
                           int_vector <= ivec;
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
                     end if;

                  when others =>
                     interrupt_state <= i_idle;

               end case;
            else
               npr <= '0';
               br <= '0';
            end if;

            if have_rk = 1 then
               rkclock <= rkclock + 1;
               if rkclock = 0 then
                  if have_rk_minimal = 0 then
                     if rkds_sc(3 downto 0) = "1011" then
                        rkds_sc <= "0000";
                     else
                        rkds_sc <= rkds_sc + "0001";
                     end if;
                  end if;

                  if have_rk_num = 8 and rksi(7) > 1 then
                     rksi(7) <= rksi(7) - 1;
                  end if;
                  if have_rk_num >= 7 and rksi(6) > 1 then
                     rksi(6) <= rksi(6) - 1;
                  end if;
                  if have_rk_num >= 6 and rksi(5) > 1 then
                     rksi(5) <= rksi(5) - 1;
                  end if;
                  if have_rk_num >= 5 and rksi(4) > 1 then
                     rksi(4) <= rksi(4) - 1;
                  end if;
                  if have_rk_num >= 4 and rksi(3) > 1 then
                     rksi(3) <= rksi(3) - 1;
                  end if;
                  if have_rk_num >= 3 and rksi(2) > 1 then
                     rksi(2) <= rksi(2) - 1;
                  end if;
                  if have_rk_num >= 2 and rksi(1) > 1 then
                     rksi(1) <= rksi(1) - 1;
                  end if;
                  if rksi(0) > 1 then
                     rksi(0) <= rksi(0) - 1;
                  end if;
               end if;

               if have_rk_minimal = 0 then
                  if rkds_sc = rkda_sc then
                     rkds_scsa <= '1';
                  else
                     rkds_scsa <= '0';
                  end if;
               else
                  rkds_sc <= rkda_sc;
                  rkds_scsa <= '1';
               end if;

               if base_addr_match = '1' and bus_control_dati = '1' then

                  case bus_addr(3 downto 1) is
                     when "000" =>
                        bus_dati <= rkds_dri & rkds_dpl & rkds_rk05 & rkds_dru & rkds_sin & rkds_sok & rkds_dry & rkds_rwsrdy & rkds_wps & rkds_scsa & rkds_sc;

                     when "001" =>
                        bus_dati <= rker_dre & rker_ovr & rker_wlo & rker_ske & rker_pge & rker_nxm & rker_dlt & rker_te & rker_nxd & rker_nxc & rker_nxs & "000" & rker_cse & rker_wce;

                     when "010" =>
                        bus_dati <= rkcs_err & rkcs_he & rkcs_scp & '0' & rkcs_iba & rkcs_fmt & rkcs_exb & rkcs_sse & rkcs_rdy & rkcs_ide & rkcs_mex & rkcs_fu & rkcs_go;

                     when "011" =>
                        bus_dati <= (not wcp) + 1;

                     when "100" =>
                        bus_dati <= rkba;

                     when "101" =>
                        bus_dati <= rkda_dr & rkda_cy & rkda_hd & rkda_sc;

                     when "111" =>
                        if have_rk_minimal = 0 then
                           bus_dati <= rkdb;
                        else
                           bus_dati <= (others => '0');
                        end if;

                     when others =>
                        bus_dati <= (others => '0');

                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then

                     case bus_addr(3 downto 1) is
                        when "000" =>
                        when "001" =>
                        when "010" =>
                           rkcs_go <= bus_dato(0);
                           rkcs_fu <= bus_dato(3 downto 1);
                           rkcs_mex <= bus_dato(5 downto 4);
                           rkcs_ide <= bus_dato(6);
                           if bus_dato(6) = '1' and bus_dato(0) = '0' and bus_dato(7) = '1' then
                              interrupt_trigger <= '1';                    -- setting ide, not setting go, but rdy = 1 -> interrupt
                           end if;

                        when "011" =>
                           rkwc(7 downto 0) <= bus_dato(7 downto 0);
                           update_rkwc <= '1';

                        when "100" =>
                           rkba(7 downto 0) <= bus_dato(7 downto 0);

                        when "101" =>
                           rkda_cy(2 downto 0) <= bus_dato(7 downto 5);
                           rkda_hd <= bus_dato(4);
                           rkda_sc <= bus_dato(3 downto 0);

                        when others =>
                           null;

                     end case;
                  end if;

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then

                     case bus_addr(3 downto 1) is
                        when "000" =>
                        when "001" =>
                        when "010" =>
                           if have_rk_minimal = 0 then
                              rkcs_sse <= bus_dato(8);
                              rkcs_exb <= bus_dato(9);
                              rkcs_fmt <= bus_dato(10);
                              rkcs_iba <= bus_dato(11);
                           end if;

                        when "011" =>
                           rkwc(15 downto 8) <= bus_dato(15 downto 8);
                           update_rkwc <= '1';

                        when "100" =>
                           rkba(15 downto 8) <= bus_dato(15 downto 8);

                        when "101" =>
                           rkda_dr <= bus_dato(15 downto 13);
                           rkda_cy(7 downto 3) <= bus_dato(12 downto 8);

                        when others =>
                           null;

                     end case;
                  end if;

               end if;

               if update_rkwc = '1' then
                  wcp <= (not rkwc) + 1;
                  update_rkwc <= '0';
               end if;

               if rkcs_go = '1' and start = '0' then
                  rkcs_rdy <= '0';
                  rkcs_go <= '0';
               end if;

               if rkcs_rdy = '0' and start = '0' then
                  if conv_integer(rkda_dr) < have_rk_num then
                     start <= '1';
                     rkcs_scp <= '0';
                     rkds_dri <= "000";                                    -- drive ident of interrupting drive
                  else
                     rker_nxd <= '1';
                     rkcs_rdy <= '1';
                  end if;
               end if;

               if start = '1' then
                  case rkcs_fu is

                     when "000" =>                                      -- control reset
                        rkcs_rdy <= '1';
                        rkcs_ide <= '0';                                -- control reset clears ide

                        rkcs_iba <= '0';
                        rkcs_exb <= '0';
                        rkcs_fmt <= '0';
                        rkcs_sse <= '0';
                        rkcs_mex <= "00";

                        rkwc <= (others => '0');
                        update_rkwc <= '1';

                        rkba <= (others => '0');

                        rkda_dr <= (others => '0');
                        rkda_cy <= (others => '0');
                        rkda_hd <= '0';
                        rkda_sc <= (others => '0');

                        rkdb <= (others => '0');

                        start <= '0';

                        rker_wce <= '0';
                        rker_cse <= '0';
                        rker_nxs <= '0';
                        rker_nxc <= '0';
                        rker_nxd <= '0';
                        rker_te <= '0';
                        rker_dlt <= '0';
                        rker_nxm <= '0';
                        rker_pge <= '0';
                        rker_ske <= '0';
                        rker_wlo <= '0';
                        rker_ovr <= '0';
                        rker_dre <= '0';


                     when "001" =>                                  -- write
                        npr <= '1';
                        rksi(conv_integer(rkda_dr)) <= 0;
                        if npg = '1' then
                           if sd_state = sd_idle and start_write = '0' then
                              if unsigned(rkda_cy) > unsigned'("11001010") then      -- o"000" thru "o"312"
                                 rker_nxc <= '1';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                                 npr <= '0';
                                 start <= '0';
                              elsif rkda_sc(3 downto 2) = "11" then
                                 rker_nxs <= '1';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                                 npr <= '0';
                                 start <= '0';
                              else
                                 start_write <= '1';
                              end if;
                           elsif sd_state = sd_write_done and start_write = '1' then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              if unsigned(rkda_sc(3 downto 0)) < unsigned'("1011") then             -- don't increment beyond 047=39.
                                 rkda_sc(3 downto 0) <= rkda_sc(3 downto 0) + 1;
                              else
                                 rkda_sc(3 downto 0) <= "0000";
                                 if rkda_hd = '0' then
                                    rkda_hd <= '1';
                                 else
                                    if unsigned(rkda_cy) = unsigned'("11001010") and rkcs_fmt /= '1' and unsigned(wcp) > unsigned'("0000000100000000") then      -- o"000" thru "o"312"
                                       rker_ovr <= '1';
                                       rkcs_rdy <= '1';
                                       if have_rk_minimal = 0 then
                                          rkdb <= wrkdb;
                                       end if;
                                       npr <= '0';
                                       start <= '0';
                                    else
                                       rkda_cy <= rkda_cy + 1;
                                       rkda_hd <= '0';
                                    end if;
                                 end if;
                              end if;

                              if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                 wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                              else
                                 wcp <= (others => '0');
                                 npr <= '0';
                                 start <= '0';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                              end if;
                              start_write <= '0';

                           elsif sd_state = sd_error_nxm and have_rk_minimal = 0 then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              npr <= '0';
                              start <= '0';
                              rker_nxm <= '1';
                              rkcs_rdy <= '1';
                              if have_rk_minimal = 0 then
                                 rkdb <= wrkdb;
                              end if;
                              start_write <= '0';

                           elsif sd_state = sd_error then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              npr <= '0';
                              start <= '0';
                              rker_dre <= '1';
                              rkcs_rdy <= '1';
                              if have_rk_minimal = 0 then
                                 rkdb <= wrkdb;
                              end if;
                              start_write <= '0';

                           end if;
                        end if;


                     when "010" | "011" | "101" =>                                  -- read, write check, read check
                        npr <= '1';
                        rksi(conv_integer(rkda_dr)) <= 0;
                        if npg = '1' then
                           if sd_state = sd_idle and start_read = '0' then
                              if unsigned(rkda_cy) > unsigned'("11001010") then      -- o"000" thru "o"312"
                                 rker_nxc <= '1';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                                 npr <= '0';
                                 start <= '0';
                              elsif rkda_sc(3 downto 2) = "11" then
                                 rker_nxs <= '1';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                                 npr <= '0';
                                 start <= '0';
                              elsif have_rk_minimal = 0 and rkcs_fu /= "010" and (rkcs_fmt = '1' or rkcs_exb = '1') then
                                 rker_pge <= '1';
                                 rkcs_rdy <= '1';
                                 if have_rk_minimal = 0 then
                                    rkdb <= wrkdb;
                                 end if;
                                 npr <= '0';
                                 start <= '0';
                              else
                                 start_read <= '1';
                              end if;
                           elsif sd_state = sd_read_done and start_read = '1' then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              if unsigned(rkda_sc(3 downto 0)) < unsigned'("1011") then             -- don't increment beyond 11.
                                 rkda_sc(3 downto 0) <= rkda_sc(3 downto 0) + 1;
                              else
                                 rkda_sc(3 downto 0) <= "0000";
                                 if rkda_hd = '0' then
                                    rkda_hd <= '1';
                                 else
                                    if unsigned(rkda_cy) = unsigned'("11001010") and rkcs_fmt /= '1' and unsigned(wcp) > unsigned'("0000000100000000") then      -- o"000" thru "o"312"
                                       rker_ovr <= '1';
                                       rkcs_rdy <= '1';
                                       if have_rk_minimal = 0 then
                                          rkdb <= wrkdb;
                                       end if;
                                       npr <= '0';
                                       start <= '0';
                                    else
                                       rkda_cy <= rkda_cy + 1;
                                       rkda_hd <= '0';
                                    end if;
                                 end if;
                              end if;

                              if rkcs_fmt = '1' and have_rk_minimal = 0 then
                                 if unsigned(wcp) > unsigned'("0000000000000001") then               -- check if we need to do another header, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000000000001");
                                 else
                                    wcp <= (others => '0');
                                    npr <= '0';
                                    start <= '0';
                                    rkcs_rdy <= '1';
                                    if have_rk_minimal = 0 then
                                       rkdb <= wrkdb;
                                    end if;
                                 end if;
                              else
                                 if unsigned(wcp) > unsigned'("0000000100000000") then               -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - unsigned'("0000000100000000");
                                 else
                                    wcp <= (others => '0');
                                    npr <= '0';
                                    start <= '0';
                                    rkcs_rdy <= '1';
                                    if have_rk_minimal = 0 then
                                       rkdb <= wrkdb;
                                    end if;
                                 end if;
                              end if;
                              start_read <= '0';

                           elsif sd_state = sd_error_nxm and have_rk_minimal = 0 then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              npr <= '0';
                              start <= '0';
                              rker_nxm <= '1';
                              rkcs_rdy <= '1';
                              if have_rk_minimal = 0 then
                                 rkdb <= wrkdb;
                              end if;
                              start_read <= '0';

                           elsif sd_state = sd_error then
                              rkcs_mex <= work_bar(17 downto 16);
                              rkba <= work_bar(15 downto 1) & '0';
                              npr <= '0';
                              start <= '0';
                              rker_dre <= '1';
                              rkcs_rdy <= '1';
                              if have_rk_minimal = 0 then
                                 rkdb <= wrkdb;
                              end if;
                              start_read <= '0';

                           end if;
                        end if;

                     when "100" =>                                  -- seek
                        if rkcs_fmt = '1' or rkcs_exb = '1' then
                           rker_pge <= '1';
                           rkcs_rdy <= '1';
                           start <= '0';
                        elsif unsigned(rkda_cy) > unsigned'("11001010") then      -- o"000" thru "o"312"
                           rker_nxc <= '1';
                           rkcs_rdy <= '1';
                           start <= '0';
                        else
                           rksi(conv_integer(rkda_dr)) <= 3;
                           rkcs_rdy <= '1';
                           start <= '0';
                        end if;

                     when "110" =>                                  -- drive reset
                        if rkcs_fmt = '1' or rkcs_exb = '1' then
                           rker_pge <= '1';
                           rkcs_rdy <= '1';
                           start <= '0';
                        else
                           rksi(conv_integer(rkda_dr)) <= 3;
                           rkcs_rdy <= '1';
                           start <= '0';
                        end if;

                     when others =>                                 -- catchall
   --                      npr <= '0';
   --                      rker_dre <= '1';
                        rkcs_rdy <= '1';
                        start <= '0';

                  end case;

               else

                  if rkcs_rdy = '1' then
                     if have_rk_num = 8 and rksi(7) = 1 then
                        rksi(7) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "111";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 7 and rksi(6) = 1 then
                        rksi(6) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "110";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 6 and rksi(5) = 1 then
                        rksi(5) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "101";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 5 and rksi(4) = 1 then
                        rksi(4) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "100";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 4 and rksi(3) = 1 then
                        rksi(3) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "011";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 3 and rksi(2) = 1 then
                        rksi(2) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "010";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif have_rk_num >= 2 and rksi(1) = 1 then
                        rksi(1) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "001";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     elsif rksi(0) = 1 then
                        rksi(0) <= 0;
                        if rkcs_ide = '1' then
                           rkds_dri <= "000";
                           rkcs_scp <= '1';
                           scpset <= '1';
                        end if;
                     end if;
                  end if;
               end if;

            end if;

         end if;
      end if;
   end process;

-- compose read address

   hs_offset <= "00000000000001100" when rkda_hd = '1' else "00000000000000000";             -- head/surface * 12
   ca_offset <= ("00000" & unsigned(rkda_cy) & "0000") + ("000000" & unsigned(rkda_cy) & "000");            -- cyl * 16 + cyl * 8 == cyl * 24
   dn_offset <= ("00" & unsigned(rkda_dr) & "000000000000") + ("000" & unsigned(rkda_dr) & "00000000000");     -- (disk * 16 + disk * 8) << 8

   sd_addr <= unsigned(dn_offset) + unsigned(hs_offset) + unsigned(ca_offset) + unsigned(rkda_sc);

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
            if have_rk_debug /= 0 then
               sdcard_debug <= "0010";
            end if;
            sdcard_cs <= '0';

            blockcounter <= 0;
            sectorcounter <= "000000000";
         else

            if have_rk = 1 then
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
                        if have_rk_debug /= 0 then
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
                     if have_rk_debug /= 0 then
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
                     work_bar <= rkcs_mex & rkba(15 downto 1);
                     if have_rk_minimal = 0 and rkcs_fmt = '1' then
   -- rk05 crazyness... need to read the 'format', and push it into memory using the busmaster. That's why this silly core is in here - don't have the busmaster in the main line core
                        sd_state <= sd_readfmt;
                     else
                        sd_cmd <= x"51" & "000000" & sd_addr & "000000000" & x"01";
                        sd_nextstate <= sd_read_checkresponse;
                        counter <= 48;
                        sd_state <= sd_send_cmd;

                        if have_rk_debug = 1 then
                           bus_master_addr <= "00" & rkda_dr & rkda_cy & rkda_hd & rkda_sc;
                        end if;
                        if have_rk_debug /= 0 then
                           sdcard_debug <= "0100";
                        end if;
                     end if;

                  when sd_readfmt =>
                     if have_rk_minimal = 0 then
                        if rkcs_iba = '0' then
                           work_bar <= work_bar + 1;
                        end if;
                        bus_master_addr <= work_bar & '0';
                        bus_master_dato <= "000" & rkda_cy & "00000";
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '1';
                     end if;
                     sd_state <= sd_readfmt2;

                  when sd_readfmt2 =>
                     bus_master_control_dato <= '0';
                     sd_state <= sd_read_done;

   -- check the first response (r1 format) to the read command

                  when sd_read_checkresponse =>
                     if sd_r1 = "0000000" then
--                         counter <= 65535;                            -- some cards may take a long time to respond
                        sd_state <= sd_read_data_waitstart;
                     else
                        sd_state <= sd_error;
                     end if;

                     if have_rk_debug = 1 then
                        bus_master_addr <= "00" & wcp;
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

                     if have_rk_debug = 1 then
                        bus_master_addr <= "00" & rkcs_err & rkcs_he & rkcs_scp & '0' & rkcs_iba & rkcs_fmt & rkcs_exb & rkcs_sse & rkcs_rdy & rkcs_ide & rkcs_mex & rkcs_fu & rkcs_go;
                     end if;

   -- actual read itself, including moving the data to core. must be bus master at this point.

                  when sd_read_data =>
                     if counter = 0 then
                        counter <= 15;
                        bus_master_addr <= work_bar & '0';
                        if rkcs_iba = '0' and rkcs_fu /= "101" then
                           work_bar <= work_bar + 1;
                        end if;
                        bus_master_dato <= sd_temp(6 downto 0) & sdcard_miso & sd_temp(14 downto 7);
                        if have_rk_minimal = 0 then
                           wrkdb <= sd_temp(6 downto 0) & sdcard_miso & sd_temp(14 downto 7);
                        end if;
                        if rkcs_fu = "010" then
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '1';
                        end if;
                        if have_rk_minimal = 0 then
                           if rkcs_fu = "011" or rkcs_fu = "101" then                        -- write check, read check - cause dati to set, to make nxm occur when it should. Maybe at some point we could also actually check the data - it does not seem all that difficult
                              bus_master_control_dati <= '1';
                              bus_master_control_dato <= '0';
                           end if;
                        end if;
                        if sectorcounter = 0 then
                           sd_state <= sd_read_rest;
                        else
                           sectorcounter <= sectorcounter - 1;
                           blockcounter <= blockcounter - 1;
                        end if;
                     else
                        if bus_master_nxm = '1' then
                           sd_state <= sd_error_nxm;
                        end if;
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                        sd_temp <= sd_temp(14 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     end if;

                     if have_rk_debug /= 0 then
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
                     bus_master_control_dati <= '0';
                     bus_master_control_dato <= '0';

                     if have_rk_debug /= 0 then
                        sdcard_debug <= "0110";
                     end if;

   -- read done, wait for controller to wake up and allow us on to idle state

                  when sd_read_done =>
                     if start_read = '0' then
                        sd_state <= sd_idle;
                     end if;

                     if have_rk_debug /= 0 then
                        sdcard_debug <= "0111";
                     end if;

   -- send a write data command to the card

                  when sd_write =>
                     work_bar <= rkcs_mex & rkba(15 downto 1);
                     sd_cmd <= x"58" & "000000" & sd_addr & "000000000" & x"0f";
                     sd_nextstate <= sd_write_checkresponse;
                     counter <= 48;
                     sd_state <= sd_send_cmd;

                     if have_rk_debug = 1 then
                        bus_master_addr <= "00" & rkda_dr & rkda_cy & rkda_hd & rkda_sc;
                     end if;
                     if have_rk_debug /= 0 then
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

                     if have_rk_debug = 1 then
                        bus_master_addr <= "00" & wcp;
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
                        bus_master_control_dati <= '1';
                        bus_master_control_dato <= '0';
                        bus_master_addr <= work_bar & '0';
                        if rkcs_iba = '0' then
                           work_bar <= work_bar + 1;
                        end if;
                     end if;
                     if counter = 0 then
                        sd_temp(15 downto 9) <= bus_master_dati(6 downto 0);
                        sd_temp(8 downto 1) <= bus_master_dati(15 downto 8);
                        sd_temp(0) <= '0';
                        bus_master_control_dati <= '0';
                        if have_rk_debug = 1 then
                           bus_master_addr(15 downto 0) <= bus_master_dati;          -- echo data for debugging
                        end if;
                        sdcard_mosi <= bus_master_dati(7);
                        if have_rk_minimal = 0 then
                           wrkdb <= (others => '0');                                  -- acc. zrkk
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
                        if bus_master_nxm = '1' then
                           sd_state <= sd_error_nxm;
                        end if;
                     else
                        sdcard_mosi <= sd_temp(15);
                        counter <= counter - 1;
                        sd_temp <= sd_temp(14 downto 0) & '0';
                     end if;

                     if have_rk_debug /= 0 then
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

                     if have_rk_debug /= 0 then
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

                     if have_rk_debug /= 0 then
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

                     if have_rk_debug /= 0 then
                        sdcard_debug <= "1011";
                     end if;

   -- wait for card to signal ready

                  when sd_write_waitcardready =>
--                      if counter = 0 then
   --                     sd_state <= sd_error;                     -- FIXME, should not be commented out
--                      else
--                         counter <= counter - 1;
--                         if have_rk_debug = 1 then
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

                     if have_rk_debug /= 0 then
                        sdcard_debug <= "0000";
                     end if;

   -- here is where we end when the wrong thing happened; wait till the controller has noticed, setup to rest some cycles, then restart

                  when sd_error_nxm =>
                     bus_master_control_dati <= '0';
                     bus_master_control_dato <= '0';
                     if start = '0' then
                        counter <= 4;
                        sd_state <= sd_error_recover;
                     end if;

                     if have_rk_debug /= 0 then
                        sdcard_debug <= "1110";
                     end if;

                  when sd_error =>
                     if start = '0' then
                        counter <= 4;
                        sd_state <= sd_error_recover;
                     end if;

                     if have_rk_debug /= 0 then
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

