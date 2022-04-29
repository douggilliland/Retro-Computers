
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

entity de0nadxl345 is
   port(
      -- de0n adxl345
      adxl345_scl : inout std_logic;
      adxl345_sda : inout std_logic;
      adxl345_cs : out std_logic;

      adxl345_x0 : out std_logic_vector(7 downto 0);
      adxl345_x1 : out std_logic_vector(7 downto 0);
      adxl345_y0 : out std_logic_vector(7 downto 0);
      adxl345_y1 : out std_logic_vector(7 downto 0);
      adxl345_z0 : out std_logic_vector(7 downto 0);
      adxl345_z1 : out std_logic_vector(7 downto 0);

      reset : in std_logic;
      clk50mhz : in std_logic
   );
end de0nadxl345;


architecture implementation of de0nadxl345 is


signal clkdiv_i2c : integer range 0 to 127;

signal i2c_byte : std_logic_vector(7 downto 0);
type state_type is (
   state_idle,
   state_conf_addr, state_conf_ptr, state_conf_data1,
   state_conf2_addr, state_conf2_ptr, state_conf2_data1,
   state_start_m1, state_start_m2,
   state_read1, state_read2, state_read3, state_read4, state_read5, state_read6, state_read7, state_read8,
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
signal did_init2 : integer range 0 to 1 := 0;
signal did_init3 : integer range 0 to 1 := 0;
signal did_start : integer range 0 to 1 := 0;
signal sendack : integer range 0 to 1 := 0;

signal waitcount : integer range 0 to 195312;

signal datax0 : std_logic_vector(7 downto 0);
signal datax1 : std_logic_vector(7 downto 0);
signal datay0 : std_logic_vector(7 downto 0);
signal datay1 : std_logic_vector(7 downto 0);
signal dataz0 : std_logic_vector(7 downto 0);
signal dataz1 : std_logic_vector(7 downto 0);

begin
   adxl345_cs <= '1';

   adxl345_x0 <= datax0;
   adxl345_x1 <= datax1;
   adxl345_y0 <= datay0;
   adxl345_y1 <= datay1;
   adxl345_z0 <= dataz0;
   adxl345_z1 <= dataz1;

   process(clk50mhz, reset)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            clkdiv_i2c <= 0;
            state <= state_idle;
            did_init <= 0;
            did_init2 <= 0;
            did_start <= 0;
            adxl345_scl <= 'Z';
            adxl345_sda <= 'Z';
         else
            clkdiv_i2c <= clkdiv_i2c + 1;

            case state is
               when state_idle =>
                  adxl345_scl <= 'Z';
                  adxl345_sda <= 'Z';

                  state <= state_wait;
                  waitcount <= 195312;

                  if did_init = 0 then
                     state <= state_conf_addr;
                     did_init <= 1;
                  elsif did_init2 = 0 then
                     state <= state_conf2_addr;
                     did_init2 <= 1;
                  elsif did_start = 0 then
                     nextstate <= state_start_m1;
                     did_start <= 1;
                  else
                     did_start <= 0;
                     state <= state_read1;
                  end if;

               when state_wait =>
                  adxl345_scl <= 'Z';
                  adxl345_sda <= 'Z';
                  if clkdiv_i2c = 0 then
                     if waitcount /= 0 then
                        waitcount <= waitcount - 1;
                     else
                        state <= nextstate;
                     end if;
                  end if;

   -- send configuration

               when state_conf_addr =>
                  byte_out <= "00111010";           -- 0x3a - address+write
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_conf_ptr;

               when state_conf_ptr =>
                  byte_out <= "00101101";           -- 0x2d - power_ctl
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf_data1;

               when state_conf_data1 =>
                  byte_out <= "00001000";           -- d3 measure=1
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

               when state_conf2_addr =>
                  byte_out <= "00111010";           -- 0x3a - address+write
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_conf2_ptr;

               when state_conf2_ptr =>
                  byte_out <= "00110001";           -- 0x31 - data_format
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_conf2_data1;

               when state_conf2_data1 =>
                  byte_out <= "00001011";           -- full_res=1,justify=0,range=11(16g)
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

   -- write read pointer

               when state_start_m1 =>
                  byte_out <= "00111010";           -- 0x3a - address+write
                  bitcount <= 7;
                  state <= state_send;
                  nextstate <= state_start_m2;

               when state_start_m2 =>
                  byte_out <= "00110010";           -- 0x32 - datax0
                  bitcount <= 7;
                  state <= state_send1;
                  nextstate <= state_stop;

   -- read the registers

               when state_read1 =>
                  byte_out <= "00111011";           -- 0x3b - address+read
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
                  datax0 <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read4;

               when state_read4 =>
                  datax1 <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read5;

               when state_read5 =>
                  datay0 <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read6;

               when state_read6 =>
                  datay1 <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read7;

               when state_read7 =>
                  dataz0 <= byte_in;
                  byte_out <= "11111111";
                  bitcount <= 7;
--                  sendack <= 1;
                  state <= state_send1;
                  nextstate <= state_read8;

               when state_read8 =>
                  dataz1 <= byte_in;
                  state <= state_stop;

   -- end transaction

               when state_stop =>
                  if clkdiv_i2c = 0 then
                     adxl345_sda <= '0';
                     state <= state_stop1;
                  end if;

               when state_stop1 =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= 'Z';
                     state <= state_stop2;
                  end if;

               when state_stop2 =>
                  if clkdiv_i2c = 0 then
                     adxl345_sda <= 'Z';
                     state <= state_idle;
                  end if;

   -- setup for start

               when state_send =>
                  adxl345_sda <= 'Z';
                  adxl345_scl <= 'Z';
                  if clkdiv_i2c = 0 then
                     adxl345_sda <= '0';
                     state <= state_start;
                  end if;

   -- start

               when state_start =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= '0';
                     state <= state_send1;
                  end if;

   -- send - four phases

               when state_send1 =>
                  if clkdiv_i2c = 0 then
                     if byte_out(7) = '0' then
                        adxl345_sda <= '0';
                     else
                        adxl345_sda <= 'Z';
                     end if;
                     byte_out <= byte_out(6 downto 0) & byte_out(7);
                     state <= state_send2;
                  end if;

               when state_send2 =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= 'Z';
                     state <= state_send3;
                  end if;

               when state_send3 =>
                  if clkdiv_i2c = 0 then
                     state <= state_send4;
                  end if;

               when state_send4 =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= '0';
                     byte_in <= byte_in(6 downto 0) & adxl345_sda;
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
                        adxl345_sda <= '0';
                        sendack <= 0;
                     else
                        adxl345_sda <= 'Z';
                     end if;
                     state <= state_ack2;
                  end if;

               when state_ack2 =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= 'Z';
                     state <= state_ack3;
                  end if;

               when state_ack3 =>
                  if clkdiv_i2c = 0 then
                     state <= state_ack4;
                  end if;

               when state_ack4 =>
                  if clkdiv_i2c = 0 then
                     adxl345_scl <= '0';
                     state <= nextstate;
                  end if;

               when others =>

            end case;

         end if;

      end if;

   end process;

end implementation;
