
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
use ieee.numeric_std.all;

entity sdspi is
   port(
      sdcard_cs : out std_logic;
      sdcard_mosi : out std_logic;
      sdcard_sclk : out std_logic;
      sdcard_miso : in std_logic := '0';
      sdcard_debug : out std_logic_vector(3 downto 0);

      sdcard_addr : in std_logic_vector(22 downto 0);

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
end sdspi;

architecture implementation of sdspi is

type buffer_type is array(0 to 255) of std_logic_vector(15 downto 0);
signal rsector : buffer_type;
signal wsector : buffer_type;

type sd_states is (
   sd_reset,
   sd_sendcmd0,
   sd_checkcmd0,
   sd_checkcmd8,
   sd_checkcmd55,
   sd_checkacmd41,
   sd_checkcmd58,
   sd_checkcmd16,
   sd_checkcmd1,
   sd_read_data,
   sd_read_data_waitstart,
   sd_read_crc,
   sd_write_data_startblock,
   sd_write,
   sd_write_checkresponse,
   sd_write_last,
   sd_write_crc,
   sd_read_dr,
   sd_waitwritedone,
   sd_send_cmd,
   sd_readr1wait,
   sd_readr1,
   sd_readr3,
   sd_readr7,
   sd_wait,
   sd_error,
   sd_idle
);

signal sd_state : sd_states := sd_reset;
signal sd_nextstate : sd_states := sd_reset;
signal sd_cmd : std_logic_vector(47 downto 0);
signal sd_r1 : std_logic_vector(6 downto 0);                    -- r1 response token from card
signal sd_r3 : std_logic_vector(31 downto 0);
signal sd_r7 : std_logic_vector(31 downto 0);
signal sd_dr : std_logic_vector(7 downto 0);

signal do_readr3 : std_logic;
signal do_readr7 : std_logic;


type cardtype_type is (
   cardtype_none,
   cardtype_mmc,
   cardtype_sdv1,
   cardtype_sdv2
);

signal cardtype : cardtype_type;
signal sdhc : std_logic;

signal counter : integer range 0 to 1023;
signal sectorindex : integer range 0 to 255;
signal sd_word : std_logic_vector(15 downto 0);

signal need_400khz : std_logic := '1';
signal need_50mhz : std_logic := '0';
signal clkcounter : std_logic_vector(6 downto 0) := (others => '0');
signal clk : std_logic;


constant filter_in_size : integer := 4;
subtype filter_in_t is std_logic_vector(filter_in_size-1 downto 0);

constant filter_out_size : integer := 4;
subtype filter_out_t is std_logic_vector(filter_out_size-1 downto 0);

signal idle_filter : filter_out_t;
signal read_start_filter : filter_in_t;
signal read_ack_filter : filter_in_t;
signal read_done_filter : filter_out_t;
signal write_start_filter : filter_in_t;
signal write_ack_filter : filter_in_t;
signal write_done_filter : filter_out_t;
signal card_error_filter : filter_out_t;

signal idle : std_logic;
signal read_start : std_logic;
signal read_ack : std_logic;
signal read_done : std_logic;
signal write_start : std_logic;
signal write_ack : std_logic;
signal write_done : std_logic;
signal card_error : std_logic;

signal notnow : std_logic := '0';

begin

   process(controller_clk)
   begin
      if controller_clk = '1' and controller_clk'event then
         if enable = 1 then
            sdcard_xfer_out <= rsector(sdcard_xfer_addr);
            if sdcard_xfer_write = '1' then
               wsector(sdcard_xfer_addr) <= sdcard_xfer_in;
            end if;

            idle_filter <= idle_filter(filter_out_t'high-1 downto 0) & idle;
            read_start_filter <= read_start_filter(filter_in_t'high-1 downto 0) & sdcard_read_start;
            read_ack_filter <= read_ack_filter(filter_in_t'high-1 downto 0) & sdcard_read_ack;
            read_done_filter <= read_done_filter(filter_out_t'high-1 downto 0) & read_done;
            write_start_filter <= write_start_filter(filter_in_t'high-1 downto 0) & sdcard_write_start;
            write_ack_filter <= write_ack_filter(filter_in_t'high-1 downto 0) & sdcard_write_ack;
            write_done_filter <= write_done_filter(filter_out_t'high-1 downto 0) & write_done;
            card_error_filter <= card_error_filter(filter_out_t'high-1 downto 0) & card_error;

            if reset = '1' then
               sdcard_idle <= '0';
               read_start <= '0';
               read_ack <= '0';
               sdcard_read_done <= '0';
               write_start <= '0';
               write_ack <= '0';
               sdcard_write_done <= '0';
               sdcard_error <= '0';
            else
               if idle_filter = filter_out_t'(others => '0') then
                  sdcard_idle <= '0';
               elsif idle_filter = filter_out_t'(others => '1') then
                  sdcard_idle <= '1';
               end if;

               if read_start_filter = filter_in_t'(others => '0') then
                  read_start <= '0';
               elsif read_start_filter = filter_in_t'(others => '1') then
                  read_start <= '1';
               end if;

               if read_ack_filter = filter_in_t'(others => '0') then
                  read_ack <= '0';
               elsif read_ack_filter = filter_in_t'(others => '1') then
                  read_ack <= '1';
               end if;

               if read_done_filter = filter_out_t'(others => '0') then
                  sdcard_read_done <= '0';
               elsif read_done_filter = filter_out_t'(others => '1') then
                  sdcard_read_done <= '1';
               end if;

               if write_start_filter = filter_in_t'(others => '0') then
                  write_start <= '0';
               elsif write_start_filter = filter_in_t'(others => '1') then
                  write_start <= '1';
               end if;

               if write_ack_filter = filter_in_t'(others => '0') then
                  write_ack <= '0';
               elsif write_ack_filter = filter_in_t'(others => '1') then
                  write_ack <= '1';
               end if;

               if write_done_filter = filter_out_t'(others => '0') then
                  sdcard_write_done <= '0';
               elsif write_done_filter = filter_out_t'(others => '1') then
                  sdcard_write_done <= '1';
               end if;

               if card_error_filter = filter_out_t'(others => '0') then
                  sdcard_error <= '0';
               elsif card_error_filter = filter_out_t'(others => '1') then
                  sdcard_error <= '1';
               end if;

            end if;

         end if;
      end if;

   end process;


   process(clk50mhz, reset)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         if enable = 1 then
            clkcounter <= clkcounter + 1;
            if need_400khz = '1' then
               clk <= clkcounter(6);
            else
               clk <= clkcounter(1);
            end if;
         end if;
      end if;
   end process;

   sdcard_sclk <= clk;

   process(clk, reset)
      variable word: std_logic_vector(15 downto 0);
   begin
      if clk = '1' and clk'event then
         if enable = 1 then
            if reset = '1' then
               if notnow = '0' then
                  counter <= 255;
                  sd_state <= sd_reset;
                  sd_nextstate <= sd_reset;
                  need_400khz <= '1';
                  sdcard_cs <= '1';
                  idle <= '0';
                  read_done <= '0';
                  sdcard_debug <= "0011";
                  card_error <= '0';
               end if;
            else

               case sd_state is

-- init card - drop clock to 400kHz, cs inactive, wait for 1ms, then start with cmd0

                  when sd_reset =>
                     counter <= 600;           -- try a bit longer than 1ms?
                     do_readr3 <= '0';
                     do_readr7 <= '0';
                     need_400khz <= '1';
                     sdcard_cs <= '1';
                     sdcard_mosi <= '1';
                     sd_state <= sd_sendcmd0;
                     cardtype <= cardtype_none;
                     sd_r1 <= (others => '0');
                     sd_r3 <= (others => '0');
                     sd_r7 <= (others => '0');
                     sdhc <= '0';
                     idle <= '0';
                     read_done <= '0';
                     sdcard_debug <= "0011";
                     card_error <= '0';
                     notnow <= '1';

-- send cmd0

                  when sd_sendcmd0 =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        counter <= 48;
                        sdcard_cs <= '0';
                        sd_nextstate <= sd_checkcmd0;
                        sd_cmd <= x"400000000095";
                        sd_state <= sd_send_cmd;
                     end if;

-- check cmd0 result, should be x'01'. If so, send cmd8; if not, go into error - and retry init from start

                  when sd_checkcmd0 =>
                     if sd_r1 = "0000001" then
                        counter <= 48;
                        sd_nextstate <= sd_checkcmd8;
                        sd_cmd <= x"48000001AA87";
                        do_readr7 <= '1';
                        sd_state <= sd_send_cmd;
                     else
                        sd_state <= sd_reset;
                     end if;

-- check cmd8 result; this shows whether this is an sdhc card - or sdxc. If the command gets an error, the card is either sdv1 or mmc

                  when sd_checkcmd8 =>
                     counter <= 48;
                     sd_cmd <= x"770000000065";
                     sd_state <= sd_send_cmd;
                     sd_nextstate <= sd_checkcmd55;

                     if sd_r1 = "0000001" then
                        if sd_r7(11 downto 8) /= "0001" or sd_r7(7 downto 0) /= x"AA" then
                           sd_state <= sd_reset;
                        else
                           cardtype <= cardtype_sdv2;
                        end if;
                     else
                        cardtype <= cardtype_sdv1;
                     end if;

-- check cmd55 result

                  when sd_checkcmd55 =>
                     counter <= 48;
                     if sd_r1 = "0000001" then
                        if cardtype = cardtype_sdv2 then
                           sd_cmd <= x"694000000077";
                        else
                           sd_cmd <= x"6900000000E5";
                        end if;
                        sd_nextstate <= sd_checkacmd41;
                        sd_state <= sd_send_cmd;
                     elsif sd_r1(2) = '1' then                       -- command err
                        cardtype <= cardtype_mmc;
                        sd_cmd <= x"4100000000F9";
                        sd_nextstate <= sd_checkcmd1;
                        sd_state <= sd_send_cmd;
                     else
                        sd_state <= sd_reset;
                     end if;

-- check cmd1 result

                  when sd_checkcmd1 =>
                     counter <= 48;
                     if sd_r1 = "0000001" then
                        sd_cmd <= x"4100000000F9";
                        sd_state <= sd_send_cmd;
                        sd_nextstate <= sd_checkcmd1;
                     elsif sd_r1 = "0000000" then
                        sd_cmd <= x"500000020001";                   -- set blocklength to 512 bytes. It's the default, but let's just be sure anyway.
                        sd_state <= sd_send_cmd;
                        sd_nextstate <= sd_checkcmd16;
                     else
                        sd_state <= sd_reset;
                     end if;


-- check acmd41 result

                  when sd_checkacmd41 =>
                     counter <= 48;
                     if sd_r1 = "0000001" then
                        sd_cmd <= x"770000000065";
                        sd_nextstate <= sd_checkcmd55;
                        sd_state <= sd_send_cmd;
                     elsif sd_r1 = "0000000" then
                        if cardtype = cardtype_sdv2 then
                           sd_cmd <= x"7A0000000000";
                           sd_state <= sd_send_cmd;
                           sd_nextstate <= sd_checkcmd58;
                           do_readr3 <= '1';
                        else
                           sd_cmd <= x"500000020001";                   -- set blocklength to 512 bytes. It's the default, but let's just be sure anyway.
                           sd_state <= sd_send_cmd;
                           sd_nextstate <= sd_checkcmd16;
                        end if;
                     else
                        sd_cmd <= x"4100000000F9";
                        sd_nextstate <= sd_checkcmd1;
                        sd_state <= sd_send_cmd;
                     end if;

-- check cmd58 results

                  when sd_checkcmd58 =>
                     if sd_r1 = "0000000" then
                        if sd_r3(30) = '1' then
                           sdhc <= '1';
                        else
                           sdhc <= '0';
                        end if;
                        counter <= 48;
                        sd_cmd <= x"500000020001";                   -- set blocklength to 512 bytes. It's the default, but let's just be sure anyway.
                        sd_state <= sd_send_cmd;
                        sd_nextstate <= sd_checkcmd16;
                     else
                        sd_state <= sd_reset;
                     end if;

-- check cmd16 results -- set block length

                  when sd_checkcmd16 =>
                     if sd_r1 = "0000000" then
                        sd_state <= sd_idle;                            -- init is complete
                        need_400khz <= '0';
                     else
                        sd_state <= sd_reset;
                     end if;

-- done with card init

                  when sd_idle =>
                     sdcard_debug(0) <= '0';
                     sdcard_debug(1) <= not sdhc;
                     sdcard_debug(3 downto 2) <= "00";

                     idle <= '1';
                     notnow <= '0';

                     if read_start = '1' and read_done = '0' and write_done = '0' and read_ack = '0' and write_ack = '0' then
                        card_error <= '0';
                        idle <= '0';
                        counter <= 48;
                        if sdhc = '1' then
                           sd_cmd <= x"51" & "000000000" & sdcard_addr & x"01";
                        else
                           sd_cmd <= x"51" & sdcard_addr & "000000000" & x"FF";
                        end if;
                        sd_state <= sd_send_cmd;
                        sd_nextstate <= sd_read_data_waitstart;
                        sdcard_debug(2) <= '1';
                     end if;

                     if write_start = '1' and read_done = '0' and write_done = '0' and read_ack = '0' and write_ack = '0' then
                        card_error <= '0';
                        idle <= '0';
                        counter <= 48;
                        if sdhc = '1' then
                           sd_cmd <= x"58" & "000000000" & sdcard_addr & x"01";
                        else
                           sd_cmd <= x"58" & sdcard_addr & "000000000" & x"FF";
                        end if;
                        sd_state <= sd_send_cmd;
                        sd_nextstate <= sd_write_checkresponse;
                        sdcard_debug(3) <= '1';
                     end if;

                     if read_ack = '1' then
                        read_done <= '0';
                        card_error <= '0';
                     end if;

                     if write_ack = '1' then
                        write_done <= '0';
                        card_error <= '0';
                     end if;


-- check r1 response after write command

                  when sd_write_checkresponse =>
                     if sd_r1 = "0000000" then
                        counter <= 7;
                        sd_state <= sd_write_data_startblock;
                     else
                        sd_state <= sd_error;
                     end if;

                  when sd_write_data_startblock =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        sectorindex <= 0;
                        sdcard_mosi <= '1';
                     else
                        sdcard_mosi <= '0';
                        word := wsector(sectorindex);
                        sd_word <= word(7 downto 0) & word(15 downto 8);
                        sectorindex <= sectorindex + 1;
                        sd_state <= sd_write;
                        counter <= 15;
                     end if;

                  when sd_write =>
                     sdcard_mosi <= sd_word(15);
                     sd_word <= sd_word(14 downto 0) & '0';
                     counter <= counter - 1;
                     if counter = 0 then
                        word := wsector(sectorindex);
                        sd_word <= word(7 downto 0) & word(15 downto 8);
                        if sectorindex = 255 then
                           sd_state <= sd_write_last;
                        end if;
                        sectorindex <= sectorindex + 1;
                        counter <= 15;
                     end if;

                  when sd_write_last =>
                     sdcard_mosi <= sd_word(15);
                     sd_word <= sd_word(14 downto 0) & '0';
                     counter <= counter - 1;
                     if counter = 0 then
                        sd_state <= sd_write_crc;
                        counter <= 15;
                     end if;

                  when sd_write_crc =>
                     sdcard_mosi <= '0';
                     counter <= counter - 1;
                     if counter = 0 then
                        sd_state <= sd_read_dr;
                        counter <= 8;
                     end if;

                  when sd_read_dr =>
                     sd_dr <= sd_dr(6 downto 0) & sdcard_miso;
                     sdcard_mosi <= '1';
                     counter <= counter - 1;
                     if counter = 0 then
                        sd_state <= sd_waitwritedone;
                     end if;

                  when sd_waitwritedone =>
                     if sd_dr(3 downto 0) /= "0101" then
                        sd_state <= sd_error;
                     elsif sdcard_miso = '1' then
                        counter <= 7;
                        sd_state <= sd_wait;
                        write_done <= '1';
                        sd_nextstate <= sd_idle;
                     end if;



-- wait for the data header to be sent in response to the read command; the header value is 0xfe, so actually there is just one start bit to read.

                  when sd_read_data_waitstart =>
   -- FIXME, this can take long, but there should still be a timeout
                     if sd_r1 = "0000000" then
                        if sdcard_miso = '0' then
                           sd_state <= sd_read_data;
                           counter <= 15;
                           sectorindex <= 0;
                        end if;
                     else
                        sd_state <= sd_error;
                     end if;

-- actual read

                  when sd_read_data =>
                     if counter = 0 then
                        counter <= 15;
                        rsector(sectorindex) <= sd_word(6 downto 0) & sdcard_miso & sd_word(14 downto 7);
                        if sectorindex = 255 then
                           sd_state <= sd_read_crc;
                        else
                           sectorindex <= sectorindex + 1;
                        end if;
                     else
                        sd_word <= sd_word(14 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     end if;

-- read crc after data block

                  when sd_read_crc =>
                     if counter = 0 then
                        counter <= 15;
   --                     crc <= sd_word(6 downto 0) & sdcard_miso & sd_word(14 downto 7);
                        sd_state <= sd_wait;
                        sd_nextstate <= sd_idle;
                        read_done <= '1';
                     else
                        sd_word <= sd_word(14 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     end if;

-- clock out what is in the sd_cmd, then setup to wait for a r1 response

                  when sd_send_cmd =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        sdcard_mosi <= sd_cmd(47);
                        sd_cmd <= sd_cmd(46 downto 0) & '1';
                     else
                        counter <= 1023;
                        sd_state <= sd_readr1wait;
                        sdcard_mosi <= '1';
                     end if;

-- wait to read an r1 response token from the card

                  when sd_readr1wait =>
                     if counter /= 0 then
                        counter <= counter - 1;
                        if sdcard_miso = '0' then
                           sd_state <= sd_readr1;
                           counter <= 7;
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
                        if do_readr7 = '1' then
                           do_readr7 <= '0';
                           counter <= 31;
                           sd_r7(0) <= sdcard_miso;
                           sd_state <= sd_readr7;
                        elsif do_readr3 = '1' then
                           do_readr3 <= '0';
                           counter <= 31;
                           sd_r3(0) <= sdcard_miso;
                           sd_state <= sd_readr3;
                        elsif sd_nextstate = sd_read_data_waitstart then
                           sd_state <= sd_read_data_waitstart;
                        else
                           counter <= 8;
                           sd_state <= sd_wait;
                        end if;
                     end if;

-- read r3

                  when sd_readr3 =>
                     if counter /= 0 then
                        sd_r3 <= sd_r3(30 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     else
                        counter <= 8;
                        sd_state <= sd_wait;
                     end if;

-- read r7

                  when sd_readr7 =>
                     if counter /= 0 then
                        sd_r7 <= sd_r7(30 downto 0) & sdcard_miso;
                        counter <= counter - 1;
                     else
                        counter <= 8;
                        sd_state <= sd_wait;
                     end if;

-- wait 8 cycles after a command sequence

                  when sd_wait =>
                     if counter /= 0 then
                        counter <= counter - 1;
                     else
                        sd_state <= sd_nextstate;
                     end if;


                  when sd_error =>
                     card_error <= '1';
                     if read_start = '1' or write_start = '1' then
                        if read_ack = '1' or write_ack = '1' then
                           sd_state <= sd_idle;
                        end if;
                     else
                        sd_state <= sd_reset;
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
