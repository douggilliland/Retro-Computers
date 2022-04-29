
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

entity pmodhygro is
   port(
      -- pmodhygro
      hg_scl : inout std_logic;
      hg_sda : inout std_logic;

      hg_rh : out std_logic_vector(13 downto 0);
      hg_temp : out std_logic_vector(13 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end pmodhygro;


architecture implementation of pmodhygro is


signal clkdiv_i2c : integer range 0 to 127;

signal i2c_byte : std_logic_vector(7 downto 0);
type state_type is (
   state_idle,
   state_conf_addr, state_conf_ptr, state_conf_data1, state_conf_data2,
   state_start_m1, state_start_m2,
   state_read1, state_read2, state_read3, state_read4, state_read5, state_read6,
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
signal did_start : integer range 0 to 1 := 0;
signal sendack : integer range 0 to 1 := 0;

signal waitcount : integer range 0 to 195312;

signal rh : std_logic_vector(13 downto 0);
signal temp : std_logic_vector(13 downto 0);

begin

   process(clk50mhz, reset)
   begin

      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            clkdiv_i2c <= 0;
            state <= state_idle;
            did_init <= 0;
            did_start <= 0;
            hg_scl <= 'Z';
            hg_sda <= 'Z';
         else
            clkdiv_i2c <= clkdiv_i2c + 1;

            case state is
               when state_idle =>
                  state <= state_wait;
                  waitcount <= 195312;

                  hg_rh <= rh;
                  hg_temp <= temp;

                  if did_init = 0 then
                     nextstate <= state_conf_addr;
                     did_init <= 1;
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
                  byte_out <= "10000000";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_conf_ptr;

               when state_conf_ptr =>
                  byte_out <= "00000010";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data1;

               when state_conf_data1 =>
                  byte_out <= "00010000";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data2;

               when state_conf_data2 =>
                  byte_out <= "00000000";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

-- write 0 to pointer; this starts the measurement

               when state_start_m1 =>
                  byte_out <= "10000000";
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_start_m2;

               when state_start_m2 =>
                  byte_out <= "00000000";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

-- read the registers

               when state_read1 =>
                  byte_out <= "10000001";
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
                  temp(13 downto 6) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read4;

               when state_read4 =>
                  temp(5 downto 0) <= byte_in(7 downto 2);
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read5;

               when state_read5 =>
                  rh(13 downto 6) <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_read6;

               when state_read6 =>
                  rh(5 downto 0) <= byte_in(7 downto 2);
                  state <= state_stop;

-- end transaction

               when state_stop =>
                  if clkdiv_i2c = 0 then
                     hg_sda <= '0';
                     state <= state_stop1;
                  end if;

               when state_stop1 =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= 'Z';
                     state <= state_stop2;
                  end if;

               when state_stop2 =>
                  if clkdiv_i2c = 0 then
                     hg_sda <= 'Z';
                     state <= state_idle;
                  end if;

-- setup for start

               when state_send =>
                  hg_sda <= 'Z';
                  hg_scl <= 'Z';
                  if clkdiv_i2c = 0 then
                     hg_sda <= '0';
                     state <= state_start;
                  end if;

-- start

               when state_start =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= '0';
                     state <= state_send1;
                  end if;

-- send - four phases

               when state_send1 =>
                  if clkdiv_i2c = 0 then
                     if byte_out(7) = '0' then
                        hg_sda <= '0';
                     else
                        hg_sda <= 'Z';
                     end if;
                     byte_out <= byte_out(6 downto 0) & byte_out(7);
                     state <= state_send2;
                  end if;

               when state_send2 =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= 'Z';
                     state <= state_send3;
                  end if;

               when state_send3 =>
                  if clkdiv_i2c = 0 then
                     state <= state_send4;
                  end if;

               when state_send4 =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= '0';
                     byte_in <= byte_in(6 downto 0) & hg_sda;
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
                        hg_sda <= '0';
                        sendack <= 0;
                     else
                        hg_sda <= 'Z';
                     end if;
                     state <= state_ack2;
                  end if;

               when state_ack2 =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= 'Z';
                     state <= state_ack3;
                  end if;

               when state_ack3 =>
                  if clkdiv_i2c = 0 then
   --                  hg_sda <= 'Z';
                     state <= state_ack4;
                  end if;

               when state_ack4 =>
                  if clkdiv_i2c = 0 then
                     hg_scl <= '0';
                     state <= nextstate;
                  end if;

               when others =>

            end case;

         end if;
      end if;

   end process;

end implementation;
