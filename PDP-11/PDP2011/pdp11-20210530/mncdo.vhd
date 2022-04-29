
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

entity mncdo is
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

      d : out std_logic_vector(15 downto 0);
      hb_strobe : out std_logic;
      lb_strobe : out std_logic;
      reply : in std_logic := '0';

      have_mncdo : in integer range 0 to 1 := 0;

      reset : in std_logic;

      clk50mhz : in std_logic;
      clk : in std_logic
   );
end mncdo;

architecture implementation of mncdo is


-- bus interface
signal base_addr_match : std_logic;

-- interrupt system
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;

-- logic
signal docsr : std_logic_vector(15 downto 0);
                                                           -- bit 8 - w/o maintenance bit, when written to '1' simulates a pulse on the reply signal - possibly only when byte addressed?
signal docsr_done : std_logic;                             -- bit 7
signal docsr_ie : std_logic;                               -- bit 6
signal docsr_bit4 : std_logic;                             -- bit 4
signal docsr_bit3 : std_logic;                             -- bit 3

signal dodata : std_logic_vector(15 downto 0);

signal counter : integer range 0 to 255;

begin

   base_addr_match <= '1' when base_addr(17 downto 2) = bus_addr(17 downto 2) and have_mncdo = 1 else '0';
   bus_addr_match <= base_addr_match;

   docsr <= "00000000" & docsr_done & docsr_ie & '0' & docsr_bit4 & docsr_bit3 & "000";
   d <= dodata;

   process(clk, base_addr_match, reset, have_mncdo)
   begin
      if clk = '1' and clk'event then

         if have_mncdo = 1 then
            if reset = '1' then
               interrupt_state <= i_idle;
               br <= '0';
            else

               case interrupt_state is

                  when i_idle =>
                     br <= '0';
                     if docsr_ie = '1' and docsr_done = '1' then
                        interrupt_state <= i_req;
                        br <= '1';
                     end if;

                  when i_req =>
                     if bg = '1' then
                        int_vector <= ivec;
                        br <= '0';
                        interrupt_state <= i_wait;
                     end if;
                     if docsr_ie = '0' then
                        interrupt_state <= i_idle;
                     end if;

                  when i_wait =>
                     if bg = '0' then
                        docsr_done <= '0';                     -- FIXME, this changes the csr too, obvs. Maybe just a flank trigger instead?
                        interrupt_state <= i_idle;
                     end if;

                  when others =>
                     interrupt_state <= i_idle;

               end case;

            end if;
         else
            br <= '0';
         end if;

         if have_mncdo = 1 then
            if reset = '1' then
               docsr_done <= '0';
               docsr_ie <= '0';
               docsr_bit4 <= '0';
               docsr_bit3 <= '0';
               dodata <= (others => '0');
               counter <= 0;
            else

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(1) is
                     when '0' =>
                        bus_dati <= docsr;
                     when '1' =>
                        bus_dati <= dodata;
                     when others =>
                        null;
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(1) is
                        when '0' =>
                           docsr_done <= bus_dato(7);
                           docsr_ie <= bus_dato(6);
                           docsr_bit4 <= bus_dato(4);
                           docsr_bit3 <= bus_dato(3);
                        when '1' =>
                           dodata(7 downto 0) <= bus_dato(7 downto 0);
                           lb_strobe <= '1';
                           docsr_done <= '0';
                           counter <= 10;                   -- FIXME, make this somewhat variable and configurable
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(1) is
                        when '0' =>
                           if bus_dato(8) = '1' then
                              docsr_done <= '1';
                           end if;
                        when '1' =>
                           dodata(15 downto 8) <= bus_dato(15 downto 8);
                           hb_strobe <= '1';
                           docsr_done <= '0';
                           counter <= 10;
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               if counter > 0 then
                  counter <= counter - 1;
                  if counter = 1 then
                     hb_strobe <= '0';
                     lb_strobe <= '0';
                  end if;
               end if;

               if reply = '1' then
                  docsr_done <= '1';
               end if;

            end if;
         end if;
      end if;
   end process;

end implementation;

