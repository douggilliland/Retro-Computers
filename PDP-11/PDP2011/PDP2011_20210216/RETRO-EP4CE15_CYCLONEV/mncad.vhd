
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

entity mncad is
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

      st1 : in std_logic;
      clkov : in std_logic;

      ad_start : out std_logic;
      ad_done : in std_logic := '0';
      ad_channel : out std_logic_vector(5 downto 0);
      ad_nxc : in std_logic := '0';
      ad_sample : in std_logic_vector(11 downto 0) := "000000000000";

      have_mncad : in integer range 0 to 1 := 0;

      reset : in std_logic;

      clk50mhz : in std_logic;
      clk : in std_logic
   );
end mncad;

architecture implementation of mncad is


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

signal adcsr_err : std_logic := '0';                       -- bit 15   100000  error
signal adcsr_errie : std_logic;                            -- bit 14   040000  error interrupt enable
signal adcsr_muxch : std_logic_vector(5 downto 0);         -- bit 13:8         multiplexor channel
signal adcsr_done : std_logic;                             -- bit 7       200  done
signal adcsr_ie : std_logic;                               -- bit 6       100  interrupt enable
signal adcsr_clkovf : std_logic;                           -- bit 5        40  start conversion on mnckw clock overflow
signal adcsr_ext : std_logic;                              -- bit 4        20  start conversion on external trigger
signal adcsr_enable_id : std_logic;                        -- bit 3        10  ?
signal adcsr_maint : std_logic;                            -- bit 2         4  maintenance - if set, even channels read all zeroes, odd channels read all ones
signal adcsr_nxc : std_logic;                              -- bit 1         2  no such channel
signal adcsr_go : std_logic := '0';                        -- bit 0         1  start conversion

signal adcsr : std_logic_vector(15 downto 0);

signal adbuf_read : std_logic := '1';
signal adbuf : std_logic_vector(15 downto 0);
signal ad_done_trigger : std_logic;
signal ad_running : std_logic;

signal st1trigger : std_logic;
signal clkovtrigger : std_logic;


begin

   base_addr_match <= '1' when base_addr(17 downto 2) = bus_addr(17 downto 2) and have_mncad = 1 else '0';
   bus_addr_match <= base_addr_match;

   adcsr <= adcsr_err & adcsr_errie & adcsr_muxch & adcsr_done & adcsr_ie & adcsr_clkovf & adcsr_ext & adcsr_enable_id & adcsr_maint & adcsr_nxc & adcsr_go;
   adcsr_nxc <= ad_nxc;
   ad_channel <= adcsr_muxch;

   process(clk, base_addr_match, reset, have_mncad)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            if have_mncad = 1 then
               interrupt_trigger1 <= '0';
               interrupt_trigger2 <= '0';
               interrupt_state <= i_idle;
            end if;
            br <= '0';

         else

            if have_mncad = 1 then

               case interrupt_state is

                  when i_idle =>
                     br <= '0';
                     if adcsr_ie = '1' and adcsr_done = '1' then
                        if interrupt_trigger1 = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger1 <= '1';
                           interrupt_trigger2 <= '0';
                        end if;
                     elsif adcsr_err = '1' and adcsr_errie = '1' then
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

         if have_mncad = 1 then
            if reset = '1' then
               adcsr_err <= '0';
               adcsr_errie <= '0';
               adcsr_muxch <= (others => '0');
               adcsr_done <= '0';
               adcsr_ie <= '0';
               adcsr_clkovf <= '0';
               adcsr_ext <= '0';
               adcsr_enable_id <= '0';
               adcsr_maint <= '0';
               adcsr_go <= '0';

               adbuf_read <= '1';
               ad_done_trigger <= '0';

               st1trigger <= '0';
               clkovtrigger <= '0';

               ad_start <= '0';
               ad_running <= '0';
            else

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(1) is
                     when '0' =>
                        bus_dati <= adcsr;
                     when '1' =>
                        adcsr_done <= '0';
                        adbuf_read <= '1';
                        if adcsr_maint = '1' and adcsr_muxch(0) = '0' then
                           bus_dati <= "0000" & "000000000000";
                        elsif adcsr_maint = '1' and adcsr_muxch(0) = '1' then
                           bus_dati <= "0000" & "111111111111";
                        else
                           bus_dati <= adbuf;
                        end if;
                     when others =>
                        null;
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(1) is
                        when '0' =>
                           adcsr_done <= bus_dato(7);
                           adcsr_ie <= bus_dato(6);
                           adcsr_clkovf <= bus_dato(5);
                           adcsr_ext <= bus_dato(4);
                           adcsr_enable_id <= bus_dato(3);
                           adcsr_maint <= bus_dato(2);
--                           adcsr_nxc <= bus_dato(1);
                           adcsr_go <= bus_dato(0);
                           if bus_dato(0) = '1' then
                              if ad_running = '1' then
                                 adcsr_err <= '1';
                              end if;
                              adcsr_done <= '0';
                           end if;
                        when '1' =>
                           null;
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(1) is
                        when '0' =>
                           adcsr_err <= bus_dato(15);
                           adcsr_errie <= bus_dato(14);
                           adcsr_muxch <= bus_dato(13 downto 8);
                        when '1' =>
                           null;
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               if adcsr_go = '1' then
                  ad_start <= '1';
                  ad_running <= '1';
                  adcsr_go <= '0';
               end if;

               if ad_done = '1' then
                  ad_done_trigger <= '1';
                  if ad_done_trigger = '0' then
                     ad_running <= '0';
                     ad_start <= '0';
                     adbuf <= "0000" & ad_sample;
                     adbuf_read <= '0';
                     if adbuf_read = '0' then
                        adcsr_err <= '1';
                     end if;
                     adcsr_done <= '1';
                  end if;
               else
                  ad_done_trigger <= '0';
               end if;

               if st1 = '1' and adcsr_ext = '1' then
                  st1trigger <= '1';
                  if st1trigger = '0' then
                     adcsr_go <= '1';
                  end if;
               else
                  st1trigger <= '0';
               end if;

               if clkov = '1' and adcsr_clkovf = '1' then
                  clkovtrigger <= '1';
                  if clkovtrigger = '0' then
                     adcsr_go <= '1';
                  end if;
               else
                  clkovtrigger <= '0';
               end if;

            end if;
         end if;
      end if;
   end process;


end implementation;

