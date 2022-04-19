
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

entity mnckw is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);

      br : out std_logic;
      bg : in std_logic;
      int_vector : out std_logic_vector(8 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      st1in : in std_logic := '0';
      st2in : in std_logic := '0';
      st1out : out std_logic;
      st2out : out std_logic;
      clkov : out std_logic;

      have_mnckw : in integer range 0 to 1 := 0;

      reset : in std_logic;

      clk50mhz : in std_logic;
      clk : in std_logic
   );
end mnckw;

architecture implementation of mnckw is


-- bus interface
signal base_addr_match : std_logic;


-- interrupt system
signal interrupt_trigger1 : std_logic := '0';
signal interrupt_trigger2 : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;

-- logic

-- kwcsr_rate values:
-- 000 : off
-- 001 : 1MHz
-- 010 : 100kHz
-- 011 : 10kHz
-- 100 : 1kHz
-- 101 : 100Hz
-- 110 : ST1
-- 111 : line (60Hz)

signal kwcsr_st2flag : std_logic;                          -- bit 15  100000 - set on ST2 pulse
signal kwcsr_stintenable : std_logic;                      -- bit 14  040000 - when set, a pulse on either ST triggers the 2nd interrupt vector
signal kwcsr_st2goenable : std_logic;                      -- bit 13  020000 - when set, a pulse on ST2 sets the kwcsr_go bit
signal kwcsr_for : std_logic;                              -- bit 12  010000 - flag overflow for st1flag, st2flag and ovfflag - set when that flag is already set and another pulse comes
signal kwcsr_disintosc : std_logic;                        -- bit 11  004000 - maintenance bit, disables the oscillator and counts ST2 pulses instead
signal kwcsr_st1flag : std_logic;                          -- bit 10  002000 - set on ST1 pulse
--                                                         -- bit 9   001000 - write-only bit, triggers an ST2 pulse
--                                                         -- bit 8   000400 - write-only bit, triggers an ST1 pulse
signal kwcsr_ovfflag : std_logic;                          -- bit 7   000200
signal kwcsr_ovfintenable : std_logic;                     -- bit 6   000100
signal kwcsr_rate : std_logic_vector(2 downto 0);          -- bit 5:3 000070
signal kwcsr_mode : std_logic_vector(1 downto 0);          -- bit 2:1 000006
signal kwcsr_go : std_logic;                               -- bit 0   000001

signal kwcsr : std_logic_vector(15 downto 0);
signal kwbuf : std_logic_vector(15 downto 0);
signal kwbuf_preset : std_logic_vector(15 downto 0);

signal ovfflag_set_trigger : std_logic;

signal count10 : integer range 0 to 10;
signal count50 : integer range 0 to 50;
signal count1mhz : integer range 0 to 19999;
signal counter : std_logic_vector(15 downto 0);
signal counter_overflow : std_logic;
signal counter_enable : std_logic;

constant filter_in_size : integer := 2;
subtype filter_in_t is std_logic_vector(filter_in_size-1 downto 0);
constant filter_out_size : integer := 2;
subtype filter_out_t is std_logic_vector(filter_out_size-1 downto 0);


signal enable_counter_filter : filter_in_t;
signal counter_overflow_filter : filter_out_t;
signal ovf_ack_filter : filter_in_t;

signal st1in_last : std_logic;
signal st2in_last : std_logic;
signal st1_trigger : std_logic;
signal st2_trigger : std_logic;

signal ovf_ack : std_logic;

signal st1_pulse : std_logic;
signal st1_pulse_filter : filter_in_t;
signal counter_st1_pulse : std_logic;
signal counter_st1_pulse_ack : std_logic;
signal st1_pulse_ack_filter : filter_out_t;
signal st1_pulse_ack : std_logic;

signal st2_pulse : std_logic;
signal st2_pulse_filter : filter_in_t;
signal counter_st2_pulse : std_logic;
signal counter_st2_pulse_ack : std_logic;
signal st2_pulse_ack_filter : filter_out_t;
signal st2_pulse_ack : std_logic;

begin

   base_addr_match <= '1' when base_addr(17 downto 2) = bus_addr(17 downto 2) and have_mnckw = 1 else '0';
   bus_addr_match <= base_addr_match;

   kwcsr <= kwcsr_st2flag & kwcsr_stintenable & kwcsr_st2goenable & kwcsr_for & kwcsr_disintosc & kwcsr_st1flag &"00" & kwcsr_ovfflag & kwcsr_ovfintenable & kwcsr_rate & kwcsr_mode & kwcsr_go;

   process(clk, base_addr_match, reset, have_mnckw)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            if have_mnckw = 1 then
               interrupt_trigger1 <= '0';
               interrupt_trigger2 <= '0';
               interrupt_state <= i_idle;
            end if;
            br <= '0';
         else

            if have_mnckw = 1 then

               case interrupt_state is

                  when i_idle =>
                     br <= '0';
                     if kwcsr_ovfintenable = '1' and kwcsr_ovfflag = '1' then
                        if interrupt_trigger1 = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger1 <= '1';
                           interrupt_trigger2 <= '0';
                        end if;
                     elsif kwcsr_stintenable = '1' and (kwcsr_st1flag = '1' or kwcsr_st2flag = '1') then
                        if interrupt_trigger2 = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger2 <= '1';
                           interrupt_trigger1 <= '0';
                        end if;
                     else
                        interrupt_trigger1 <= '0';
                        interrupt_trigger2 <= '0';
                     end if;

                  when i_req =>
                     if bg = '1' and interrupt_trigger1 = '1' then
                        int_vector <= ivec;
                        br <= '0';
                        interrupt_state <= i_wait;
                     end if;
                     if bg = '1' and interrupt_trigger2 = '1' then
                        int_vector <= ivec+4;
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

         end if;

         if have_mnckw = 0 then
            st1out <= '0';
            clkov <= '0';
         else
            if reset = '1' then
               kwcsr_st2flag <= '0';
               kwcsr_stintenable <= '0';
               kwcsr_st2goenable <= '0';
               kwcsr_for <= '0';
               kwcsr_disintosc <= '0';
               kwcsr_st1flag <= '0';
               kwcsr_ovfflag <= '0';
               kwcsr_ovfintenable <= '0';
               kwcsr_rate <= "000";
               kwcsr_mode <= "00";
               kwcsr_go <= '0';
               kwbuf_preset <= (others => '0');
               ovfflag_set_trigger <= '0';

               st1out <= '0';
               st2out <= '0';
               st1in_last <= '0';
               st2in_last <= '0';
               st1_trigger <= '0';
               st2_trigger <= '0';
               clkov <= '0';
               ovf_ack <= '0';
            else

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(1) is
                     when '0' =>
                        bus_dati <= kwcsr;
                     when '1' =>
                        bus_dati <= kwbuf;
                        kwbuf_preset <= kwbuf;
                     when others =>
                        null;
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(1) is
                        when '0' =>
                           kwcsr_ovfflag <= bus_dato(7);
                           kwcsr_ovfintenable <= bus_dato(6);
                           kwcsr_rate <= bus_dato(5 downto 3);
                           kwcsr_mode <= bus_dato(2 downto 1);
                           kwcsr_go <= bus_dato(0);
                           if kwcsr_go = '0' and bus_dato(0) = '1' then
                              kwcsr_for <= '0';
                           end if;
                        when '1' =>
                           kwbuf_preset(7 downto 0) <= bus_dato(7 downto 0);
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(1) is
                        when '0' =>
                           kwcsr_st2flag <= bus_dato(15);
                           kwcsr_stintenable <= bus_dato(14);
                           kwcsr_st2goenable <= bus_dato(13);
                           if bus_dato(12) = '0' then
                              kwcsr_for <= '0';
                           end if;
                           kwcsr_disintosc <= bus_dato(11);
                           kwcsr_st1flag <= bus_dato(10);
                           if bus_dato(9) = '1' then
                              st2_trigger <= '1';
                           end if;
                           if bus_dato(8) = '1' then
                              st1_trigger <= '1';
                           end if;
                        when '1' =>
                           kwbuf_preset(15 downto 8) <= bus_dato(15 downto 8);
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               st1out <= kwcsr_st1flag;
               st2out <= kwcsr_st2flag;
               clkov <= kwcsr_ovfflag;

               if st1_trigger = '1' or (st1in /= st1in_last and st1in = '1') then
                  st1_pulse <= '1';
                  if kwcsr_st1flag = '1' then
                     kwcsr_for <= '1';
                  end if;
                  st1_trigger <= '0';
               end if;
               st1in_last <= st1in;

               if st2_trigger = '1' or (st2in /= st2in_last and st2in = '1')  then
                  st2_pulse <= '1';
                  if kwcsr_st2goenable = '1' then
                     kwcsr_go <= '1';
                     kwcsr_st2goenable <= '0';
                  end if;
                  if kwcsr_st2flag = '1' then
                     kwcsr_for <= '1';
                  end if;
                  st2_trigger <= '0';
               end if;
               st2in_last <= st2in;

               counter_overflow_filter <= counter_overflow_filter(filter_out_t'high-1 downto 0) & counter_overflow;
               if counter_overflow_filter = filter_out_t'(others => '0') then
                  ovfflag_set_trigger <= '0';
                  ovf_ack <= '0';
               elsif counter_overflow_filter = filter_out_t'(others => '1') then
                  if ovfflag_set_trigger = '0' then
                     ovf_ack <= '1';
                     kwcsr_ovfflag <= '1';
                     if kwcsr_mode = "00" then
                        kwcsr_go <= '0';
                     end if;
                     if kwcsr_ovfflag = '1' then
                        kwcsr_for <= '1';
                     end if;
                     ovfflag_set_trigger <= '1';
                  end if;
               end if;

               st1_pulse_ack_filter <= st1_pulse_ack_filter(filter_out_t'high-1 downto 0) & counter_st1_pulse_ack;
               if st1_pulse_ack_filter = filter_out_t'(others => '0') then
               elsif st1_pulse_ack_filter = filter_out_t'(others => '1') then
                  st1_pulse <= '0';
               end if;
               st2_pulse_ack_filter <= st2_pulse_ack_filter(filter_out_t'high-1 downto 0) & counter_st2_pulse_ack;
               if st2_pulse_ack_filter = filter_out_t'(others => '0') then
               elsif st2_pulse_ack_filter = filter_out_t'(others => '1') then
                  st2_pulse <= '0';
               end if;

               if st1_pulse = '1' then
                  kwcsr_st1flag <= '1';
               end if;
               if st2_pulse = '1' then
                  kwcsr_st2flag <= '1';
--                   if kwcsr_mode(1) = '1' then
--                      kwcsr_ovfflag <= '1';
--                   end if;
               end if;

            end if;
         end if;
      end if;
   end process;

   process(clk50mhz, reset)
      variable pulse1mhz, pulse, count_pulse: std_logic;
   begin
      if clk50mhz = '1' and clk50mhz'event then
         pulse := '0';
         count_pulse := '0';

         if reset = '1' then
            if have_mnckw = 1 then
               count50 <= 0;
               count10 <= 0;
               count1mhz <= 0;
            end if;
         else

            pulse1mhz := '0';
            if kwcsr_disintosc = '0' then
               count50 <= count50 + 1;
               if count50 >= 49 then
                  count50 <= 0;
                  pulse1mhz := '1';
               end if;
            end if;

            if counter_st1_pulse = '1' then
               counter_st1_pulse_ack <= '1';
               if kwcsr_rate = "110" and counter_st1_pulse_ack = '0' then
                  count_pulse := '1';
               elsif kwcsr_rate = "000" and counter_st1_pulse_ack = '0' then
                  counter <= (others => '0');
               elsif kwcsr_disintosc = '1' and counter_st1_pulse_ack = '0' then
                  count10 <= count10 + 1;
                  if count10 >= 9 then
                     count10 <= 0;
                     pulse1mhz := '1';
                  end if;
               end if;
            end if;

            if pulse1mhz = '1' then
               case kwcsr_rate is
                  when "001" =>
                     pulse := '1';
                  when "010" =>
                     if count1mhz >= 9 then
                        count1mhz <= 0;
                        pulse := '1';
                     else
                        count1mhz <= count1mhz + 1;
                     end if;
                  when "011" =>
                     if count1mhz >= 99 then
                        count1mhz <= 0;
                        pulse := '1';
                     else
                        count1mhz <= count1mhz + 1;
                     end if;
                  when "100" =>
                     if count1mhz >= 999 then
                        count1mhz <= 0;
                        pulse := '1';
                     else
                        count1mhz <= count1mhz + 1;
                     end if;
                  when "101" =>
                     if count1mhz >= 9999 then
                        count1mhz <= 0;
                        pulse := '1';
                     else
                        count1mhz <= count1mhz + 1;
                     end if;
                  when "111" =>
                     if count1mhz >= 16666 then
                        count1mhz <= 0;
                        pulse := '1';
                     else
                        count1mhz <= count1mhz + 1;
                     end if;
                  when others =>
                     count1mhz <= 0;
               end case;
            end if;

            if pulse = '1' and counter_enable = '1' then
               count_pulse := '1';
            end if;

            if count_pulse = '1' then
               if counter = "1111111111111111" then
                  counter <= (others => '0');
                  counter_overflow <= '1';
               elsif counter = "0000000000000000" and kwcsr_mode = "01" then
                  counter <= kwbuf_preset;
               else
                  counter <= counter + 1;
               end if;
            end if;

            if counter_st2_pulse = '1' then
               counter_st2_pulse_ack <= '1';
               if counter_st2_pulse_ack = '0' then
                  if kwcsr_mode(1) = '1' then
                     kwbuf <= counter;
                     if kwcsr_mode(0) = '1' then
                        counter <= (others => '0');
                     end if;
                  end if;
               end if;
            end if;

            ovf_ack_filter  <= ovf_ack_filter(filter_in_t'high-1 downto 0) & ovf_ack;
            if ovf_ack_filter = filter_in_t'(others => '0') then
            elsif ovf_ack_filter = filter_in_t'(others => '1') then
               counter_overflow <= '0';
            end if;

            if counter_enable = '0' and kwcsr_rate /= "110" then -- FIXME, really not sure about the rate /= 6 exclusion here. But it is the one last thing to make the VMNC test pass flawlessly.
               counter <= kwbuf_preset;
               kwbuf <= kwbuf_preset;
            end if;

            enable_counter_filter <= enable_counter_filter(filter_in_t'high-1 downto 0) & kwcsr_go;
            if enable_counter_filter = filter_in_t'(others => '0') then
               counter_enable <= '0';
            elsif enable_counter_filter = filter_in_t'(others => '1') then
               if counter_enable = '0' and kwcsr_mode(1) = '0' then
                  counter <= kwbuf_preset;
               elsif counter_enable = '0' and kwcsr_mode(1) = '1' then
                  counter <= (others => '0');
               end if;
               counter_enable <= '1';
            end if;

            st1_pulse_filter <= st1_pulse_filter(filter_in_t'high-1 downto 0) & st1_pulse;
            if st1_pulse_filter = filter_in_t'(others => '0') then
               counter_st1_pulse_ack <= '0';
               counter_st1_pulse <= '0';
            elsif st1_pulse_filter = filter_in_t'(others => '1') then
               counter_st1_pulse <= '1';
            end if;
            st2_pulse_filter <= st2_pulse_filter(filter_in_t'high-1 downto 0) & st2_pulse;
            if st2_pulse_filter = filter_in_t'(others => '0') then
               counter_st2_pulse_ack <= '0';
               counter_st2_pulse <= '0';
            elsif st2_pulse_filter = filter_in_t'(others => '1') then
               counter_st2_pulse <= '1';
            end if;

         end if;
      end if;
   end process;

end implementation;

