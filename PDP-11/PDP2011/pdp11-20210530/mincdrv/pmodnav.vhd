
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

entity pmodnav is
   port(
      nv_csag : out std_logic;                   -- cs acc/gyro
      nv_mosi : out std_logic;
      nv_miso : in std_logic;
      nv_sclk : out std_logic;
      nv_csm : out std_logic;                    -- cs magnetometer
      nv_csa : out std_logic;                    -- cs altimeter

      nv_temp : out std_logic_vector(11 downto 0);         -- divide by 30, add to 42.5 (signed arithmetic!) to get temp
      nv_pressure : out std_logic_vector(11 downto 0);     -- pressure in mbar/hPa
      nv_pressure_f : out std_logic_vector(11 downto 0);   -- pressure fraction

      nv_xlt : out std_logic_vector(11 downto 0);
      nv_xlx : out std_logic_vector(11 downto 0);
      nv_xly : out std_logic_vector(11 downto 0);
      nv_xlz : out std_logic_vector(11 downto 0);
      nv_gx : out std_logic_vector(11 downto 0);
      nv_gy : out std_logic_vector(11 downto 0);
      nv_gz : out std_logic_vector(11 downto 0);
      nv_mx : out std_logic_vector(11 downto 0);
      nv_my : out std_logic_vector(11 downto 0);
      nv_mz : out std_logic_vector(11 downto 0);

      reset : in std_logic;
      clk : in std_logic
   );
end pmodnav;

architecture implementation of pmodnav is

signal clkcount : integer range 0 to 63 := 0;
signal step : integer range 0 to 2047 := 0;
signal sclk : std_logic;
signal mosi : std_logic;
signal do : std_logic_vector(7 downto 0);
signal di : std_logic_vector(7 downto 0);
signal dih : std_logic_vector(7 downto 0);
signal dixh : std_logic_vector(7 downto 0);
signal addr : std_logic_vector(6 downto 0);
signal wr : std_logic;
signal l : integer range 0 to 24 := 8;
signal done_init : integer range 0 to 1 := 0;

signal cs : std_logic;
signal csa : std_logic;
signal csag : std_logic;
signal csm : std_logic;

signal temp : std_logic_vector(11 downto 0);
signal press : std_logic_vector(11 downto 0);
signal pressf : std_logic_vector(11 downto 0);
signal xlt : std_logic_vector(11 downto 0);
signal xlx : std_logic_vector(11 downto 0);
signal xly : std_logic_vector(11 downto 0);
signal xlz : std_logic_vector(11 downto 0);
signal gx : std_logic_vector(11 downto 0);
signal gy : std_logic_vector(11 downto 0);
signal gz : std_logic_vector(11 downto 0);
signal mx : std_logic_vector(11 downto 0);
signal my : std_logic_vector(11 downto 0);
signal mz : std_logic_vector(11 downto 0);


begin
   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         sclk <= not sclk;
      end if;
   end process;

   nv_sclk <= sclk when csa = '1' or csag = '1' or csm = '1' else '1';
   nv_mosi <= mosi when csa = '1' or csag = '1' or csm = '1' else '1';
   nv_csa <= cs when csa = '1' else '1';
   nv_csag <= cs when csag = '1' else '1';
   nv_csm <= cs when csm = '1' else '1';

   process(sclk, reset)
   begin
      if sclk = '0' and sclk'event then
         if reset = '1' then
            clkcount <= 63;
            step <= 200;                         -- this should give the sensors some more time to power up
            wr <= '0';
            addr <= "0000000";

            csa <= '0';
            csag <= '0';
            csm <= '0';
            l <= 8;
            done_init <= 0;
         else
            clkcount <= clkcount + 1;

            case clkcount is
               when 1 =>
                  cs <= '0';
                  mosi <= not wr;
               when 2 =>
                  mosi <= addr(6);
               when 3 =>
                  mosi <= addr(5);
               when 4 =>
                  mosi <= addr(4);
               when 5 =>
                  mosi <= addr(3);
               when 6 =>
                  mosi <= addr(2);
               when 7 =>
                  mosi <= addr(1);
               when 8 =>
                  mosi <= addr(0);
               when 9 =>
                  if wr = '1' then
                     mosi <= do(7);
                  else
                     mosi <= '1';
                  end if;
               when 10 =>
                  if wr = '1' then
                     mosi <= do(6);
                  else
                     mosi <= '1';
                  end if;
                  di(7) <= nv_miso;
               when 11 =>
                  if wr = '1' then
                     mosi <= do(5);
                  else
                     mosi <= '1';
                  end if;
                  di(6) <= nv_miso;
               when 12 =>
                  if wr = '1' then
                     mosi <= do(4);
                  else
                     mosi <= '1';
                  end if;
                  di(5) <= nv_miso;
               when 13 =>
                  if wr = '1' then
                     mosi <= do(3);
                  else
                     mosi <= '1';
                  end if;
                  di(4) <= nv_miso;
               when 14 =>
                  if wr = '1' then
                     mosi <= do(2);
                  else
                     mosi <= '1';
                  end if;
                  di(3) <= nv_miso;
               when 15 =>
                  if wr = '1' then
                     mosi <= do(1);
                  else
                     mosi <= '1';
                  end if;
                  di(2) <= nv_miso;
               when 16 =>
                  if wr = '1' then
                     mosi <= do(0);
                  else
                     mosi <= '1';
                  end if;
                  di(1) <= nv_miso;
               when 17 =>
                  if l = 8 then
                     cs <= '1';
                  end if;
                  mosi <= '1';
                  di(0) <= nv_miso;
               when 18 =>
                  dih(7) <= nv_miso;
               when 19 =>
                  dih(6) <= nv_miso;
               when 20 =>
                  dih(5) <= nv_miso;
               when 21 =>
                  dih(4) <= nv_miso;
               when 22 =>
                  dih(3) <= nv_miso;
               when 23 =>
                  dih(2) <= nv_miso;
               when 24 =>
                  dih(1) <= nv_miso;
               when 25 =>
                  dih(0) <= nv_miso;
                  if l = 16 then
                     cs <= '1';
                  end if;
               when 26 =>
                  dixh(7) <= nv_miso;
               when 27 =>
                  dixh(6) <= nv_miso;
               when 28 =>
                  dixh(5) <= nv_miso;
               when 29 =>
                  dixh(4) <= nv_miso;
               when 30 =>
                  dixh(3) <= nv_miso;
               when 31 =>
                  dixh(2) <= nv_miso;
               when 32 =>
                  dixh(1) <= nv_miso;
               when 33 =>
                  dixh(0) <= nv_miso;
                  cs <= '1';
               when others =>
            end case;

            if clkcount = 63 then
               step <= step + 1;
            end if;

            if clkcount = 0 then
               wr <= '0';
               l <= 8;
               csa <= '0';
               csag <= '0';
               csm <= '0';

               case step is

-- setup

                  when 1 =>
                     done_init <= 1;

                  when 2 =>
                     csa <= '1';
                     addr <= "0100000";          -- 0x20 - ctrl_reg1
                     wr <= '1';                  -- write
                     do <= "11000100";           -- pd=1 (power on); odr=100 (25Hz); bdu=1 (block update)

                  when 3 =>
                     csa <= '1';
                     addr <= "0100001";          -- 0x20 - ctrl_reg1
                     wr <= '1';                  -- write
                     do <= "00001000";           -- i2c_dis=1 (disable i2c)

                  when 4 =>
                     csag <= '1';
                     addr <= "0100000";          -- 0x20 - ctrl_reg6_xl
                     wr <= '1';                  -- write
                     do <= "00100000";          -- odr_xl=001,fs_g=00,bw_g=00

                  when 5 =>
                     csag <= '1';
                     addr <= "0010000";          -- 0x10 - ctrl_reg1_g
                     wr <= '1';                  -- write
                     do <= "00100000";           -- odr_g=001,fs_g=00,bw_g=00

                  when 6 =>
                     csm <= '1';
                     addr <= "0100000";          -- 0x20 - ctrl_reg1_m
                     wr <= '1';
                     do <= "00000100";           -- data rate 1.25Hz

                  when 7 =>
                     csm <= '1';
                     addr <= "0100010";          -- 0x22 - ctrl_reg3_m
                     wr <= '1';
                     do <= "10000000";           -- i2c_disable=1, sim=0, md=00

-- read

                  when 10 =>

                  when 11 =>
                     l <= 24;
                     csa <= '1';
                     addr <= "1101000";          -- 0x28 - press_out_xl

                  when 12 =>
                     pressf(11 downto 8) <= dih(3 downto 0);
                     pressf(7 downto 0) <= di;
                     press(3 downto 0) <= dih(7 downto 4);
                     press(11 downto 4) <= dixh;

                  when 13 =>
                     csa <= '1';
                     l <= 16;
                     addr <= "1101011";          -- 0x2b - temp_out_l

                  when 14 =>
                     temp(3 downto 0) <= di(7 downto 4);
                     temp(11 downto 4) <= dih;

                  when 15 =>
                     csag <= '1';
                     l <= 16;
                     addr <= "0010101";          -- 0x15 - out_temp_l, out_temp_h

                  when 16 =>
                     xlt(11 downto 8) <= dih(3 downto 0);
                     xlt(7 downto 0) <= di;

                     csag <= '1';
                     l <= 16;
                     addr <= "0101000";          -- 0x28 - out_x_xl

                  when 17 =>
                     xlx(11 downto 4) <= dih;
                     xlx(3 downto 0) <= di(7 downto 4);

                     csag <= '1';
                     l <= 16;
                     addr <= "0101010";          -- 0x2a - out_y_xl

                  when 18 =>
                     xly(11 downto 4) <= dih;
                     xly(3 downto 0) <= di(7 downto 4);

                     csag <= '1';
                     l <= 16;
                     addr <= "0101100";          -- 0x2c - out_z_xl

                  when 19 =>
                     xlz(11 downto 4) <= dih;
                     xlz(3 downto 0) <= di(7 downto 4);

                     csag <= '1';
                     l <= 16;
                     addr <= "0011000";          -- 0x18 - out_x_g

                  when 20 =>
                     gx(11 downto 4) <= dih;
                     gx(3 downto 0) <= di(7 downto 4);

                     csag <= '1';
                     l <= 16;
                     addr <= "0011010";          -- 0x1a - out_y_g

                  when 21 =>
                     gy(11 downto 4) <= dih;
                     gy(3 downto 0) <= di(7 downto 4);

                     csag <= '1';
                     l <= 16;
                     addr <= "0011100";          -- 0x1c - out_z_g

                  when 22 =>
                     gz(11 downto 4) <= dih;
                     gz(3 downto 0) <= di(7 downto 4);

                     csm <= '1';
                     l <= 16;
                     addr <= "1101000";          -- 0x28 - out_x_m

                  when 23 =>
                     mx(11 downto 4) <= dih;
                     mx(3 downto 0) <= di(7 downto 4);

                     csm <= '1';
                     l <= 16;
                     addr <= "1101010";          -- 0x2a - out_y_m

                  when 24 =>
                     my(11 downto 4) <= dih;
                     my(3 downto 0) <= di(7 downto 4);

                     csm <= '1';
                     l <= 16;
                     addr <= "1101100";          -- 0x2c - out_z_m

                  when 25 =>
                     mz(11 downto 4) <= dih;
                     mz(3 downto 0) <= di(7 downto 4);


-- done, setup for next

                  when 2047 =>
                     if done_init = 1 then
                        step <= 10;
                     else
                        step <= 1;
                     end if;

                     nv_temp <= temp;
                     nv_temp(11) <= not temp(11);
                     nv_pressure <= press;
                     nv_pressure(11) <= not press(11);
                     nv_pressure_f <= pressf;

                     nv_xlt <= xlt;
                     nv_xlx <= xlx;
                     nv_xly <= xly;
                     nv_xlz <= xlz;
                     nv_gx <= gx;
                     nv_gy <= gy;
                     nv_gz <= gz;
                     nv_mx <= mx;
                     nv_my <= my;
                     nv_mz <= mz;

                  when others =>
                     csa <= '0';
                     null;

               end case;
            end if;

         end if;
      end if;
   end process;

end implementation;

