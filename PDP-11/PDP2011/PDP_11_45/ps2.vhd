
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

entity ps2 is
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

      ps2k_c : in std_logic;
      ps2k_d : in std_logic;

      reset : in std_logic;
      clk : in std_logic
   );
end ps2;

architecture implementation of ps2 is


-- regular bus interface

signal base_addr_match : std_logic;
signal interrupt_trigger : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;


-- local data

type ps2_scanstate_type is (
   ps2_scanstate_idle,
   ps2_scanstate_counting,
   ps2_scanstate_parity,
   ps2_scanstate_stop
);
signal ps2_scanstate : ps2_scanstate_type := ps2_scanstate_idle;

signal ps2_counter : integer range 7 downto 0;

signal ps2_scancode : std_logic_vector(7 downto 0);
signal ps2_rxdone : std_logic;
signal ps2_rxie : std_logic;

constant ps2_cfilter_size : integer := 8;
subtype ps2_cfilter_t is std_logic_vector(ps2_cfilter_size-1 downto 0);
signal ps2_cfilter : std_logic_vector(7 downto 0);
signal ps2_transition : std_logic := '0';
signal ps2_clk : std_logic;

begin

   base_addr_match <= '1' when base_addr(17 downto 2) = bus_addr(17 downto 2) else '0';
   bus_addr_match <= base_addr_match;

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then

            ps2_rxdone <= '0';
            ps2_rxie <= '0';

            ps2_clk <= '0';
            ps2_cfilter <= (others => '1');

            ps2_scancode <= (others => '0');
            ps2_scanstate <= ps2_scanstate_idle;
            ps2_transition <= '0';

            br <= '0';
            interrupt_trigger <= '0';
            interrupt_state <= i_idle;

         else

            case interrupt_state is

               when i_idle =>

                  br <= '0';
                  if ps2_rxie = '1' and ps2_rxdone = '1' then
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

            if base_addr_match = '1' and bus_control_dati = '1' then
               case bus_addr(2 downto 1) is
                  when "00" =>
                     bus_dati <= "00000000" & ps2_rxdone & ps2_rxie & "000000";
                  when "01" =>
                     ps2_rxdone <= '0';
                     bus_dati <= "00000000" & ps2_scancode;
                  when others =>
                     bus_dati <= "0000000000000000";
               end case;

            end if;

            if base_addr_match = '1' and bus_control_dato = '1' then
               if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        ps2_rxie <= bus_dato(6);
                     when others =>
                        null;
                  end case;
               end if;
            end if;

--
-- filter the ps2k_c clock
--

            ps2_cfilter <= ps2_cfilter(ps2_cfilter'high-1 downto 0) & ps2k_c;
            if ps2_cfilter = ps2_cfilter_t'(others => '1') then
               ps2_clk <= '1';
               ps2_transition <= '0';
            elsif ps2_cfilter = ps2_cfilter_t'(others => '0') then
               ps2_clk <= '0';
               if ps2_clk = '1' then
                  ps2_transition <= '1';
               else
                  ps2_transition <= '0';
               end if;
            end if;

--
-- the idea behind the implementation with the transition trigger, instead of moving this into a process gated by ps2_clk,
-- is that this makes it possible to add a timeout counter if that becomes desirable
--

            if ps2_transition = '1' then
               case ps2_scanstate is
                  when ps2_scanstate_idle =>
                     ps2_scanstate <= ps2_scanstate_counting;
                     ps2_counter <= 0;

                  when ps2_scanstate_counting =>
                     ps2_scancode(ps2_counter) <= ps2k_d;
                     if ps2_counter /= 7 then
                        ps2_counter <= ps2_counter + 1;
                     else
                        ps2_scanstate <= ps2_scanstate_parity;
                     end if;

                  when ps2_scanstate_parity =>
                     ps2_scanstate <= ps2_scanstate_stop;

                  when ps2_scanstate_stop =>
                     ps2_rxdone <= '1';
                     ps2_scanstate <= ps2_scanstate_idle;

               end case;
            end if;

         end if;
      end if;

   end process;


end implementation;

