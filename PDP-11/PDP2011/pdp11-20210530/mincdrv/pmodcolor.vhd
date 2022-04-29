
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

entity pmodcolor is
   port(
      -- pmodcolor
      co_scl : inout std_logic;
      co_sda : inout std_logic;

      co_clear : out std_logic_vector(15 downto 0);
      co_red : out std_logic_vector(15 downto 0);
      co_green : out std_logic_vector(15 downto 0);
      co_blue : out std_logic_vector(15 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end pmodcolor;


architecture implementation of pmodcolor is


signal clkdiv_i2c : integer range 0 to 127;

signal i2c_byte : std_logic_vector(7 downto 0);
type state_type is (
   state_idle,
   state_conf_addr, state_conf_ptr, state_conf_data0, state_conf_data1, state_conf_data2, state_conf_data3,
   state_gain1, state_gain2, state_gain3,
   state_start_m1, state_start_m2,
   state_read1, state_read2, state_read3, state_read4, state_read5, state_read6, state_read7, state_read8, state_read9, state_read10,
   state_send, state_send1, state_send2, state_send3, state_send4,
   state_start,
   state_ack1, state_ack2, state_ack3, state_ack4,
   state_stop, state_stop1, state_stop2,
   state_wait
);
signal state : state_type;
signal nextstate : state_type;
signal byte_out : std_logic_vector(7 downto 0);
signal byte_in : std_logic_vector(7 downto 0);
signal bitcount : integer range 0 to 10;

signal did_init : integer range 0 to 1 := 0;
signal did_gain : integer range 0 to 1 := 0;
signal did_start : integer range 0 to 1 := 0;
signal sendack : integer range 0 to 1 := 0;

signal waitcount : integer range 0 to 195312;

signal clear : std_logic_vector(15 downto 0);
signal red : std_logic_vector(15 downto 0);
signal green : std_logic_vector(15 downto 0);
signal blue : std_logic_vector(15 downto 0);

begin

   process(clk50mhz, reset)
   begin

      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            clkdiv_i2c <= 0;
            state <= state_idle;
            did_init <= 0;
            did_gain <= 0;
            did_start <= 0;
            co_scl <= 'Z';
            co_sda <= 'Z';
         else
            clkdiv_i2c <= clkdiv_i2c + 1;

            case state is
               when state_idle =>
                  state <= state_wait;
                  waitcount <= 60157;

                  co_clear <= clear;
                  co_red <= red;
                  co_green <= green;
                  co_blue <= blue;

                  if did_init = 0 then
                     nextstate <= state_conf_addr;
                     did_init <= 1;
                  elsif did_gain = 0 then
                     nextstate <= state_gain1;
                     did_gain <= 1;
                  elsif did_start = 0 then
                     nextstate <= state_start_m1;
                     did_start <= 1;
                  else
                     did_start <= 0;
                     nextstate <= state_read1;
                  end if;

               when state_wait =>
                  if clkdiv_i2c = 0 then
                     if waitcount /= 0 then
                        waitcount <= waitcount - 1;
                     else
                        state <= nextstate;
                     end if;
                  end if;

-- send configuration

               when state_conf_addr =>
                  byte_out <= "01010010";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_conf_ptr;

               when state_conf_ptr =>
                  byte_out <= "10100000";           -- autoincrement
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data0;

               when state_conf_data0 =>
                  byte_out <= "00001011";           -- wen, aen, pon
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data1;

               when state_conf_data1 =>
                  byte_out <= "11000000";           -- c0 - 64 cycles, 154 ms, max count 65535
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data2;

               when state_conf_data2 =>
                  byte_out <= "00000000";           -- dummy, this register does not exist?
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data3;

               when state_conf_data3 =>
                  byte_out <= "10101011";           -- ab - wait time 85, 204ms
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

-- write gain register

               when state_gain1 =>
                  byte_out <= "01010010";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_gain2;

               when state_gain2 =>
                  byte_out <= "10101111";           -- autoincrement, from 0x0f
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_gain3;

               when state_gain3 =>
                  byte_out <= "00000010";           -- gain 16x
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

-- write 0 to pointer; this starts the measurement

               when state_start_m1 =>
                  byte_out <= "01010010";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_start_m2;

               when state_start_m2 =>
                  byte_out <= "10110100";           -- autoincrement from 0x14
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

-- read the registers

               when state_read1 =>
                  byte_out <= "01010011";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_read2;

               when state_read2 =>
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read3;

               when state_read3 =>
                  clear(7 downto 0) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read4;

               when state_read4 =>
                  clear(15 downto 8) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read5;

               when state_read5 =>
                  red(7 downto 0) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read6;

               when state_read6 =>
                  red(15 downto 8) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read7;

               when state_read7 =>
                  green(7 downto 0) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read8;

               when state_read8 =>
                  green(15 downto 8) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read9;

               when state_read9 =>
                  blue(7 downto 0) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_read10;

               when state_read10 =>
                  blue(15 downto 8) <= byte_in;
                  state <= state_stop;

-- end transaction

               when state_stop =>
                  if clkdiv_i2c = 0 then
                     co_sda <= '0';
                     state <= state_stop1;
                  end if;

               when state_stop1 =>
                  if clkdiv_i2c = 0 then
                     co_scl <= 'Z';
                     state <= state_stop2;
                  end if;

               when state_stop2 =>
                  if clkdiv_i2c = 0 then
                     co_sda <= 'Z';
                     state <= state_idle;
                  end if;

-- setup for start

               when state_send =>
                  co_sda <= 'Z';
                  co_scl <= 'Z';
                  if clkdiv_i2c = 0 then
                     co_sda <= '0';
                     state <= state_start;
                  end if;

-- start

               when state_start =>
                  if clkdiv_i2c = 0 then
                     co_scl <= '0';
                     state <= state_send1;
                  end if;

-- send - four phases

               when state_send1 =>
                  if clkdiv_i2c = 0 then
                     if byte_out(7) = '0' then
                        co_sda <= '0';
                     else
                        co_sda <= 'Z';
                     end if;
                     byte_out <= byte_out(6 downto 0) & byte_out(7);
                     state <= state_send2;
                  end if;

               when state_send2 =>
                  if clkdiv_i2c = 0 then
                     co_scl <= 'Z';
                     state <= state_send3;
                  end if;

               when state_send3 =>
                  if clkdiv_i2c = 0 then
                     state <= state_send4;
                  end if;

               when state_send4 =>
                  if clkdiv_i2c = 0 then
                     co_scl <= '0';
                     byte_in <= byte_in(6 downto 0) & co_sda;
                     bitcount <= bitcount - 1;
                     if bitcount = 0 then
                        state <= state_ack1;
                     else
                        state <= state_send1;
                     end if;
                  end if;

-- ack - four phases

               when state_ack1 =>
                  if clkdiv_i2c = 0 then
                     if sendack = 1 then
                        co_sda <= '0';
                        sendack <= 0;
                     else
                        co_sda <= 'Z';
                     end if;
                     state <= state_ack2;
                  end if;

               when state_ack2 =>
                  if clkdiv_i2c = 0 then
                     co_scl <= 'Z';
                     state <= state_ack3;
                  end if;

               when state_ack3 =>
                  if clkdiv_i2c = 0 then
   --                  co_sda <= 'Z';
                     state <= state_ack4;
                  end if;

               when state_ack4 =>
                  if clkdiv_i2c = 0 then
                     co_scl <= '0';
                     state <= nextstate;
                  end if;

               when others =>

            end case;

         end if;

      end if;

   end process;

end implementation;
