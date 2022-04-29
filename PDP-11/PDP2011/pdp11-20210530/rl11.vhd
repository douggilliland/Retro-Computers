
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

entity rl11 is
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
      reset : in std_logic;
      clk50mhz : in std_logic;
      nclk : in std_logic;
      clk : in std_logic
   );
end rl11;

architecture implementation of rl11 is

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

-- rl11 registers

signal csr_err : std_logic;
signal csr_de : std_logic;
signal csr_nxm : std_logic;
signal csr_e : std_logic_vector(2 downto 0);
signal csr_ds : std_logic_vector(1 downto 0);
signal csr_crdy : std_logic;
signal csr_ie : std_logic;
signal csr_ba : std_logic_vector(17 downto 16);
signal csr_fc : std_logic_vector(2 downto 0);
signal csr_drdy : std_logic;

signal bar : std_logic_vector(15 downto 1);

-- dar subfields : read/write

subtype dnhs_subtype is std_logic;
type dnhs_type is array(3 downto 0) of dnhs_subtype;
signal dnhs : dnhs_type;
subtype dnca_subtype is std_logic_vector(8 downto 0);
type dnca_type is array(3 downto 0) of dnca_subtype;
signal dnca : dnca_type;

signal dar : std_logic_vector(15 downto 0);

-- mpr subfields : get status
signal gs_vc : std_logic;          -- volume changed

signal mpr : std_logic_vector(15 downto 0);

-- mpr subfield; wc is only writeable field, but it is not readable
signal wcp : std_logic_vector(12 downto 0);               -- positive value of wc

-- others

signal start : std_logic;
signal write_start : std_logic;
signal update_mpr : std_logic;


signal hs_offset : std_logic_vector(17 downto 0);
signal ca_offset : std_logic_vector(17 downto 0);
signal dn_offset : std_logic_vector(17 downto 0);
signal sd_addr : std_logic_vector(17 downto 0);

signal work_bar : std_logic_vector(17 downto 1);

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

   sd1: sdspi port map(
      sdcard_cs => sdcard_cs,
      sdcard_mosi => sdcard_mosi,
      sdcard_sclk => sdcard_sclk,
      sdcard_miso => sdcard_miso,
      sdcard_debug => sdcard_debug,

      sdcard_addr => "000000" & sd_addr,

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

      enable => have_rl,
      controller_clk => clk,
      reset => reset,
      clk50mhz => clk50mhz
   );


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_rl = 1 else '0';
   bus_addr_match <= base_addr_match;


-- specific logic for the device

   csr_drdy <= '1';                    -- the drive is always ready
   csr_de <= '0';                      -- the drive has no errors

   csr_err <= '0' when csr_e = "000" and csr_nxm = '0' and csr_de = '0' else '1';


-- regular bus interface : handle register contents and dependent logic

   process(nclk, reset)
   begin
      if nclk = '1' and nclk'event then
         if reset = '1' then

            if have_rl = 1 then
               csr_fc <= "000";
               csr_ba <= "00";
               csr_ie <= '0';
               csr_crdy <= '1';
               csr_ds <= "00";
               csr_e <= "000";
               csr_nxm <= '0';

               bar <= "000000000000000";
               dar <= "0000000000000000";
               mpr <= "0000000000000000";
               wcp <= "0000000000000";

               dnhs(conv_integer(3)) <= '0';
               dnhs(conv_integer(2)) <= '0';
               dnhs(conv_integer(1)) <= '0';
               dnhs(conv_integer(0)) <= '0';
               dnca(conv_integer(3)) <= (others => '0');
               dnca(conv_integer(2)) <= (others => '0');
               dnca(conv_integer(1)) <= (others => '0');
               dnca(conv_integer(0)) <= (others => '0');

               start <= '0';

               gs_vc <= '1';
               update_mpr <= '0';

               br <= '0';
               interrupt_trigger <= '0';
               interrupt_state <= i_idle;

            end if;
         else

            if have_rl = 1 then

               case interrupt_state is

                  when i_idle =>

                     br <= '0';
                     if csr_ie = '1' and csr_crdy = '1' then
                        if interrupt_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger <= '1';
                        end if;
                     else
                        interrupt_trigger <= '0';
                     end if;

                  when i_req =>
                     if bg = '1' then
                        int_vector <= ivec;
                        br <= '0';
                        interrupt_state <= i_wait;
                     end if;

                  when i_wait =>
                     if bg = '0' then
                        interrupt_state <= i_idle;
                     end if;

                  when others =>
                     interrupt_state <= i_idle;

               end case;

            else
               br <= '0';
            end if;


            if have_rl = 1 then

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        bus_dati <= csr_err & csr_de & csr_nxm & csr_e & csr_ds & csr_crdy & csr_ie & csr_ba & csr_fc & csr_drdy;
                     when "01" =>
                        bus_dati <= bar & '0';
                     when "10" =>
                        bus_dati <= dar;
                     when "11" =>

                        case csr_fc is
                           when "010" =>                                  -- get status
                              bus_dati(15 downto 14) <= "00";                      -- write data error, current in head error; not applicable
                              bus_dati(13) <= '0';                                 -- means write protect is off
                              bus_dati(12 downto 10) <= "000";                     -- seek time out, spin error, write gate error; not applicable
                              bus_dati(9) <= '0';                                  -- gs_vc; disabled because it prevents (at least) V7 from booting
                              bus_dati(8) <= '0';                                  -- drive select error, not applicable
                              bus_dati(7) <= '1';                                  -- 0 means rl01, 1 means rl02
                              bus_dati(6) <= dnhs(conv_integer(csr_ds));           -- current head
                              bus_dati(5) <= '0';                                  -- cover open
--                              if sd_state = sd_idle then                           -- idle is the only state the cpu should ever be able to witness, unless the card interface is recovering from an error. All busy states are passed through while the cpu is stopped.
                              bus_dati(4 downto 0) <= "11101";                     -- heads out, brush home, locked
--                              else
--                                 bus_dati(4 downto 0) <= "00000";                  -- load cartridge
--                              end if;

                           when "100" =>                                  -- read header
                              bus_dati <= dnca(conv_integer(csr_ds)) & dnhs(conv_integer(csr_ds)) & dar(5 downto 0);                   -- 2nd and 3rd read should give zeros and crc, respectively. Is anyone interested? Unix doesn't seem to be.

                           when others =>
                              bus_dati <= (others => '0');
                        end case;
                     when others =>
                        bus_dati <= (others => '0');
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           csr_fc <= bus_dato(3 downto 1);
                           csr_ba <= bus_dato(5 downto 4);
                           csr_ie <= bus_dato(6);
                           csr_crdy <= bus_dato(7);
                        when "01" =>
                           bar(7 downto 1) <= bus_dato(7 downto 1);
                        when "10" =>
                           dar(7 downto 0) <= bus_dato(7 downto 0);
                        when "11" =>
                           mpr(7 downto 0) <= bus_dato(7 downto 0);
                           update_mpr <= '1';
                        when others =>
                           null;
                     end case;
                  end if;

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           csr_e <= "000";
                           csr_nxm <= '0';
                           csr_ds <= bus_dato(9 downto 8);
                        when "01" =>
                           bar(15 downto 8) <= bus_dato(15 downto 8);
                        when "10" =>
                           dar(15 downto 8) <= bus_dato(15 downto 8);
                        when "11" =>
                           mpr(15 downto 8) <= bus_dato(15 downto 8);
                           update_mpr <= '1';
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               if update_mpr = '1' then
                  wcp <= (not mpr(12 downto 0)) + 1;
                  update_mpr <= '0';
               end if;

               if csr_crdy = '0' and start = '0' then
                  start <= '1';
               end if;

               if start = '1' then
                  case csr_fc is

                     when "000" =>                                  -- no-op
                        csr_crdy <= '1';
                        start <= '0';

--                      when "001" =>                                        -- write check... we're not doing any of that, really.
--                         csr_e <= "000";                                            -- make sure error bits are clear
--                         csr_nxm <= '0';
--                         csr_crdy <= '1';
--                         start <= '0';

                     when "010" =>                                        -- get status
                        if dar(1) = '0' then                                       -- check if go bit is set
                           csr_e <= "001";                                         -- if not, signal error. zrlg checks this, thats why
                        end if;
                        if dar(3) = '1' then                                       -- reset error
                           gs_vc <= '0';                                           -- reset volume changed
                        end if;
                        csr_crdy <= '1';
                        start <= '0';

                     when "011" =>                                        -- seek
                        if dar(2) = '1' then
                           dnca(conv_integer(csr_ds)) <= dnca(conv_integer(csr_ds)) + dar(15 downto 7);
                        else
                           dnca(conv_integer(csr_ds)) <= dnca(conv_integer(csr_ds)) - dar(15 downto 7);
                        end if;
                        dnhs(conv_integer(csr_ds)) <= dar(4);
                        csr_crdy <= '1';
                        start <= '0';

                     when "100" =>                                        -- read header
                        if unsigned(dar(5 downto 0)) < unsigned'("100111") then             -- don't increment beyond 047=39.
                           dar(5 downto 0) <= dar(5 downto 0) + 1;
                        else
                           dar(5 downto 0) <= "000000";                   -- set to 0 on track overrun, does that make sense?
                        end if;
                        csr_crdy <= '1';
                        start <= '0';

                     when "110" | "001" =>                                     -- read or write check
                        if dnca(conv_integer(csr_ds)) = dar(15 downto 7)
                        and dnhs(conv_integer(csr_ds)) = dar(6) then
                           if sdcard_idle = '1' and sdcard_read_start = '0' and sdcard_read_done = '0' then
                              if unsigned(dar(5 downto 0)) >= unsigned'("101000") then
                                 csr_e <= "101";
                                 csr_crdy <= '1';
                                 start <= '0';
                              else
                                 sdcard_read_start <= '1';
                              end if;
                           elsif sdcard_read_ack = '1' and sdcard_read_done = '0' and sdcard_read_start = '1' then
                              sdcard_read_start <= '0';

                              if nxm = '0' and sdcard_error = '0' then
                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 if unsigned(dar(5 downto 0)) < unsigned'("100111") then             -- don't increment beyond 047=39.
                                    dar(5 downto 0) <= dar(5 downto 0) + 1;
                                 else
                                    dar(5 downto 0) <= "101000";                -- acc. manual, should be set to 050/40. on track overrun
                                 end if;

                                 if unsigned(wcp) > unsigned'("0000010000000") then                  -- check if we need to do another sector, and setup for the next round if so
                                    wcp <= unsigned(wcp) - 128;
                                    if dar(5 downto 0) = "101000" then
                                       start <= '0';
                                       csr_e <= "101";                                -- overrun, hnf
                                       csr_crdy <= '1';
                                    end if;
                                 else
                                    csr_crdy <= '1';
                                    start <= '0';
                                 end if;

                              else

                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 start <= '0';
                                 if nxm = '1' then
                                    csr_e <= "000";
                                    csr_nxm <= '1';
                                 end if;
                                 if sdcard_error = '1' then
                                    csr_e <= "011";
                                 end if;
                                 csr_crdy <= '1';
                              end if;
                           end if;
                        else
                           csr_e <= "101";
                           csr_crdy <= '1';
                           start <= '0';
                        end if;


                     when "101" =>                                        -- write
                        if dnca(conv_integer(csr_ds)) = dar(15 downto 7)
                        and dnhs(conv_integer(csr_ds)) = dar(6) then
                           if sdcard_idle = '1' and write_start = '0' then
                              if unsigned(dar(5 downto 0)) >= unsigned'("101000") then
                                 csr_e <= "101";
                                 csr_crdy <= '1';
                                 start <= '0';
                              else
                                 write_start <= '1';
                              end if;
                           elsif sdcard_write_ack = '1' and sdcard_write_done = '0' and write_start = '1' then
                              write_start <= '0';

                              if nxm = '0' and sdcard_error = '0' then
                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 if unsigned(dar(5 downto 0)) < unsigned'("100111") then             -- don't increment beyond 047=39.
                                    dar(5 downto 0) <= dar(5 downto 0) + 1;
                                 else
                                    dar(5 downto 0) <= "101000";                -- acc. manual, should be set to 050/40. on track overrun
                                 end if;

                                 if unsigned(wcp) > unsigned'("0000010000000") then                  -- check if we need to do more
                                    wcp <= unsigned(wcp) - 128;
                                    if dar(5 downto 0) = "101000" then
                                       start <= '0';
                                       csr_e <= "101";                                -- overrun, hnf
                                       csr_crdy <= '1';
                                    end if;
                                 else
                                    csr_crdy <= '1';
                                    start <= '0';
                                 end if;

                              else

                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 start <= '0';
                                 if nxm = '1' then
                                    csr_e <= "000";
                                    csr_nxm <= '1';
                                 end if;
                                 if sdcard_error = '1' then
                                    csr_e <= "011";
                                 end if;
                                 csr_crdy <= '1';
                              end if;

                           end if;
                        else
                           csr_e <= "101";
                           csr_crdy <= '1';
                           start <= '0';
                        end if;

                     when others =>                                        -- catchall
                        csr_crdy <= '1';
                        start <= '0';

                  end case;
               end if;

            end if;
         end if;
      end if;
   end process;

-- compose read address

   hs_offset <= "000000000000101000" when dnhs(conv_integer(csr_ds)) = '1' else "000000000000000000";                  -- track# * 40
   ca_offset <= ("00000" & dnca(conv_integer(csr_ds)) & "0000") + ("000" & dnca(conv_integer(csr_ds)) & "000000");     -- cyl#  * 2 * 40
   dn_offset <= (('0' & csr_ds & "0000000000000") + ('0' & csr_ds & "000000000000000"));                               -- disk * 512 * 2 * 40

   sd_addr <= (dn_offset + hs_offset) + (ca_offset + ("000000000000" & dar(5 downto 0)));

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

            if have_rl = 1 then

               case busmaster_state is

                  when busmaster_idle =>
                     nxm <= '0';
                     if write_start = '1' then
                        npr <= '1';
                        if npg = '1' then
                           busmaster_state <= busmaster_write1;
                           work_bar <= csr_ba & bar(15 downto 1);
                           if unsigned(wcp) >= unsigned'("0000000010000000") then
                              sectorcounter <= "010000000";
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
                           work_bar <= csr_ba & bar(15 downto 1);
                           busmaster_state <= busmaster_read1;
                           if unsigned(wcp) >= unsigned'("0000000010000000") then
                              sectorcounter <= "010000000";
                           else
                              sectorcounter <= '0' & wcp(7 downto 0);
                           end if;

                           sdcard_xfer_addr <= 0;
                           sdcard_xfer_read <= '1';
                        end if;
                     end if;

                  when busmaster_read1 =>
                     busmaster_state <= busmaster_read;
                     bus_master_addr <= work_bar(17 downto 1) & '0';
                     bus_master_dato <= sdcard_xfer_out;
                     bus_master_control_dato <= '0';
                     sdcard_xfer_addr <= sdcard_xfer_addr + 1;


                  when busmaster_read =>
                     if sectorcounter /= "000000000" then
                        work_bar <= work_bar + 1;
                        sdcard_xfer_addr <= sdcard_xfer_addr + 1;
                        sectorcounter <= sectorcounter - 1;

                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '1';
                        bus_master_addr <= work_bar(17 downto 1) & '0';
                        bus_master_dato <= sdcard_xfer_out;
                     else
                        busmaster_state <= busmaster_read_done;
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                     end if;

                     if bus_master_nxm = '1' then
                        nxm <= '1';
                        busmaster_state <= busmaster_read_done;
                     end if;


                  when busmaster_read_done =>
                     npr <= '0';
                     sdcard_xfer_read <= '0';
                     sdcard_read_ack <= '1';
                     bus_master_control_dati <= '0';
                     bus_master_control_dato <= '0';
                     if sdcard_read_ack = '1' and sdcard_read_done = '0' then
                        busmaster_state <= busmaster_idle;
                        sdcard_read_ack <= '0';
                     end if;


                  when busmaster_write1 =>
                     sdcard_xfer_write <= '0';
                     sdcard_xfer_addr <= 255;
                     if sectorcounter /= "000000000" then
                        bus_master_addr <= work_bar(17 downto 1) & '0';
                        bus_master_control_dati <= '1';
                        work_bar <= work_bar + 1;
                        busmaster_state <= busmaster_write;
                     else
                        busmaster_state <= busmaster_writen;
                     end if;


                  when busmaster_write =>
                     sectorcounter <= sectorcounter - 1;
                     if sectorcounter /= "000000000" then
                        sdcard_xfer_in <= bus_master_dati;
                        sdcard_xfer_write <= '1';
                        sdcard_xfer_addr <= sdcard_xfer_addr + 1;

                        if sectorcounter /= "000000001" then
                           work_bar <= work_bar + 1;
                           bus_master_addr <= work_bar(17 downto 1) & '0';
                           bus_master_control_dati <= '1';
                        end if;
                     else
                        if sdcard_xfer_addr = 255 then
                           busmaster_state <= busmaster_write_wait;
                        else
                           busmaster_state <= busmaster_writen;
                        end if;
                        npr <= '0';
                        bus_master_control_dati <= '0';
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


