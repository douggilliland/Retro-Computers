
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

-- $Revision: 1.135 $

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
      have_rl_debug : in integer range 0 to 1;
      reset : in std_logic;
      sdclock : in std_logic;
      clk : in std_logic
   );
end rl11;

architecture implementation of rl11 is


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
--signal sa : std_logic_vector(5 downto 0);

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
signal start_read : std_logic;
signal start_write : std_logic;
signal update_mpr : std_logic;


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

signal counter : integer range 0 to 524287;
signal blockcounter : integer range 0 to 256;                   -- counter within sd card block
signal sectorcounter : std_logic_vector(8 downto 0);            -- counter within rl11 sector

signal sd_cmd : std_logic_vector(47 downto 0);
signal sd_r1 : std_logic_vector(6 downto 0);                    -- r1 response token from card
signal sd_dr : std_logic_vector(3 downto 0);                    -- data response token from card

signal sd_temp : std_logic_vector(15 downto 0);

signal hs_offset : std_logic_vector(17 downto 0);
signal ca_offset : std_logic_vector(17 downto 0);
signal dn_offset : std_logic_vector(17 downto 0);
signal sd_addr : std_logic_vector(17 downto 0);

signal work_bar : std_logic_vector(17 downto 1);



begin


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_rl = 1 else '0';
   bus_addr_match <= base_addr_match;


-- specific logic for the device

   csr_drdy <= '1';                    -- the drive is always ready
   csr_de <= '0';                      -- the drive has no errors

   csr_err <= '0' when csr_e = "000" and csr_nxm = '0' and csr_de = '0' else '1';


-- regular bus interface : handle register contents and dependent logic

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
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
               start_read <= '0';
               start_write <= '0';

               gs_vc <= '1';
               npr <= '0';
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
               npr <= '0';
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
                              if sd_state = sd_idle then                           -- idle is the only state the cpu should ever be able to witness, unless the card interface is recovering from an error. All busy states are passed through while the cpu is stopped.
                                 bus_dati(4 downto 0) <= "11101";                  -- heads out, brush home, locked
                              else
                                 bus_dati(4 downto 0) <= "00000";                  -- load cartridge
                              end if;

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
                           npr <= '1';
                           if npg = '1' then
                              if sd_state = sd_idle and start_read = '0' then
                                 if unsigned(dar(5 downto 0)) >= unsigned'("101000") then
                                    csr_e <= "101";
                                    csr_crdy <= '1';
                                    npr <= '0';
                                    start <= '0';
                                 else
                                    start_read <= '1';
                                 end if;
                              elsif sd_state = sd_read_done and start_read = '1' then
                                 start_read <= '0';
--                                  npr <= '0';
--                                  start <= '0';
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
                                       npr <= '0';
                                       start <= '0';
                                       csr_e <= "101";                                -- overrun, hnf
                                       csr_crdy <= '1';
                                    end if;
                                 else
                                    csr_crdy <= '1';
                                    npr <= '0';
                                    start <= '0';
                                 end if;

                              elsif sd_state = sd_error_nxm then
                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 start_read <= '0';
                                 npr <= '0';
                                 start <= '0';
                                 csr_e <= "000";
                                 csr_nxm <= '1';
                                 csr_crdy <= '1';

                              elsif sd_state = sd_error then
                                 start_read <= '0';
                                 npr <= '0';
                                 start <= '0';
                                 csr_e <= "011";                                -- fsm timeout, reported as hcrc
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
                           npr <= '1';
                           if npg = '1' then
                              if sd_state = sd_idle and start_write = '0' then
                                 if unsigned(dar(5 downto 0)) >= unsigned'("101000") then
                                    csr_e <= "101";
                                    csr_crdy <= '1';
                                    npr <= '0';
                                    start <= '0';
                                 else
                                    start_write <= '1';
                                 end if;
                              elsif sd_state = sd_write_done and start_write = '1' then
                                 start_write <= '0';
--                                  npr <= '0';
--                                  start <= '0';
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
                                       npr <= '0';
                                       start <= '0';
                                       csr_e <= "101";                                -- overrun, hnf
                                       csr_crdy <= '1';
                                    end if;
                                 else
                                    csr_crdy <= '1';
                                    npr <= '0';
                                    start <= '0';
                                 end if;

                              elsif sd_state = sd_error_nxm then
                                 csr_ba <= work_bar(17 downto 16);
                                 bar <= work_bar(15 downto 1);
                                 start_read <= '0';
                                 npr <= '0';
                                 start <= '0';
                                 csr_e <= "000";
                                 csr_nxm <= '1';
                                 csr_crdy <= '1';

                              elsif sd_state = sd_error then
                                 start_write <= '0';
                                 npr <= '0';
                                 start <= '0';
                                 csr_e <= "011";                                -- fsm timeout, reported as hcrc
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
            if have_rl_debug = 1 then
               sdcard_debug <= "0010";
            end if;
            sdcard_cs <= '0';

            blockcounter <= 0;
            sectorcounter <= "000000000";
         else

            if have_rl = 1 then
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
                        if have_rl_debug = 1 then
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
                     if have_rl_debug = 1 then
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
                     work_bar <= csr_ba & bar;
                     sd_cmd <= x"51" & "00000" & sd_addr & "000000000" & x"01";
                     sd_nextstate <= sd_read_checkresponse;
                     counter <= 48;
                     sd_state <= sd_send_cmd;

                     if have_rl_debug = 1 then
--                      bus_master_addr <= "00" & dnca(conv_integer(csr_ds)) & dnhs(conv_integer(csr_ds)) & dar(5 downto 0);
                        sdcard_debug <= "0100";
                     end if;

   -- check the first response (r1 format) to the read command

                  when sd_read_checkresponse =>
                     if sd_r1 = "0000000" then
                        counter <= 524287;                            -- some cards may take a long time to respond
                        sd_state <= sd_read_data_waitstart;
                     else
                        sd_state <= sd_error;
                     end if;

                     if have_rl_debug = 1 then
                        bus_master_addr <= "00000" & wcp;
                     end if;

   -- wait for the data header to be sent in response to the read command; the header value is 0xfe, so actually there is just one start bit to read.

                  when sd_read_data_waitstart =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        if sdcard_miso = '0' then
                           sd_state <= sd_read_data;
                           counter <= 15;
                           blockcounter <= 255;                      -- 256 words = 512 bytes
                           if unsigned(wcp) >= unsigned'("0000010000000") then
                              sectorcounter <= "001111111";           -- 128
                           else
                              sectorcounter <= '0' & (unsigned(wcp(7 downto 0)) - unsigned'("00000001"));  -- amount - 1
                           end if;
                        end if;
                     else
                        sd_state <= sd_error;
                     end if;

                     if have_rl_debug = 1 then
                        bus_master_addr <= "00" & csr_err & csr_de & csr_nxm & "000" & csr_ds & csr_crdy & csr_ie & csr_ba & csr_fc & csr_drdy;
                     end if;

   -- actual read itself, including moving the data to core. must be bus master at this point.

                  when sd_read_data =>
                     if counter = 0 then
                        counter <= 15;
                        bus_master_addr <= work_bar & '0';
                        work_bar <= work_bar + 1;
                        bus_master_dato <= sd_temp(6 downto 0) & sdcard_miso & sd_temp(14 downto 7);
                        if csr_fc = "110" then                                           -- drive dato for read only
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '1';
                        end if;
                        if csr_fc = "001" then                                           -- drive dati for write check - to cause nxm, and maybe later actually check
                           bus_master_control_dati <= '1';
                           bus_master_control_dato <= '0';
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

                     if have_rl_debug = 1 then
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
                     if bus_master_nxm = '1' then
                        sd_state <= sd_error_nxm;
                     end if;
                     bus_master_control_dati <= '0';
                     bus_master_control_dato <= '0';

                     if have_rl_debug = 1 then
                        sdcard_debug <= "0110";
                     end if;

   -- read done, wait for controller to wake up and allow us on to idle state

                  when sd_read_done =>
                     if start_read = '0' then
                        sd_state <= sd_idle;
                     end if;

                     if have_rl_debug = 1 then
                        sdcard_debug <= "0111";
                     end if;

   -- send a write data command to the card

                  when sd_write =>
                     work_bar <= csr_ba & bar;
                     sd_cmd <= x"58" & "00000" & sd_addr & "000000000" & x"0f";
                     sd_nextstate <= sd_write_checkresponse;
                     counter <= 48;
                     sd_state <= sd_send_cmd;

                     if have_rl_debug = 1 then
                        bus_master_addr <= "00" & dnca(conv_integer(csr_ds)) & dnhs(conv_integer(csr_ds)) & dar(5 downto 0);
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

                     if have_rl_debug = 1 then
                        bus_master_addr <= "00000" & wcp;
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
                     if unsigned(wcp) >= unsigned'("0000010000000") then
                        sectorcounter <= "010000000";           -- 128
                     else
                        sectorcounter <= '0' & wcp(7 downto 0);
                     end if;

   -- actually send out the bitstream

                  when sd_write_data =>
                     if counter = 1 and sectorcounter /= 0 then
                        bus_master_control_dati <= '1';
                        bus_master_control_dato <= '0';
                        bus_master_addr <= work_bar & '0';
                        work_bar <= work_bar + 1;
                     end if;
                     if counter = 0 then
                        sd_temp(15 downto 9) <= bus_master_dati(6 downto 0);
                        sd_temp(8 downto 1) <= bus_master_dati(15 downto 8);
                        sd_temp(0) <= '0';
                        bus_master_control_dati <= '0';
                        if have_rl_debug = 1 then
                           bus_master_addr(15 downto 0) <= bus_master_dati;          -- echo data for debugging
                        end if;
                        sdcard_mosi <= bus_master_dati(7);
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

                     if have_rl_debug = 1 then
                        sdcard_debug <= "1001";
                     end if;

   -- send out rest of the bitstream, comprising of zeros to fill the block

                  when sd_write_rest =>
                     if counter = 0 then
                        counter <= 15;
                        sdcard_mosi <= '0';
                        if blockcounter = 0 then
                           counter <= 15;                            -- 16 crc bits to write
                           sdcard_mosi <= '0';
                           sd_state <= sd_write_crc;
                        else
                           blockcounter <= blockcounter - 1;
                        end if;
                     else
                        counter <= counter - 1;
                     end if;

                     if have_rl_debug = 1 then
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

                     if have_rl_debug = 1 then
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
                        counter <= 65535;
                        sd_state <= sd_write_waitcardready;
                     else
                        counter <= counter - 1;
                     end if;

                     if have_rl_debug = 1 then
                        sdcard_debug <= "1011";
                     end if;

   -- wait for card to signal ready

                  when sd_write_waitcardready =>
                     if counter = 0 then
   --                     sd_state <= sd_error;                     -- FIXME, should not be commented out
                     else
                        counter <= counter - 1;
                        if have_rl_debug = 1 then
                           bus_master_addr(3 downto 0) <= sd_dr;                -- FIXME, check the card response
                        end if;
                     end if;
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

                     if have_rl_debug = 1 then
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

                     if have_rl_debug = 1 then
                        sdcard_debug <= "1110";
                     end if;

                  when sd_error =>
                     if start = '0' then
                        counter <= 4;
                        sd_state <= sd_error_recover;
                     end if;

                     if have_rl_debug = 1 then
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

