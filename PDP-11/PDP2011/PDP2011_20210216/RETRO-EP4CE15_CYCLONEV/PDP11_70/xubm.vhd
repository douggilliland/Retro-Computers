
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

entity xubm is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      npr : out std_logic;
      npg : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0);
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic;

      localbus_npr : out std_logic;
      localbus_npg : in std_logic;

      localbus_master_addr : out std_logic_vector(17 downto 0);
      localbus_master_dati : in std_logic_vector(15 downto 0);
      localbus_master_dato : out std_logic_vector(15 downto 0);
      localbus_master_control_dati : out std_logic;
      localbus_master_control_dato : out std_logic;
      localbus_master_nxm : in std_logic;

      reset : in std_logic;
      xubmclk : in std_logic;
      clk : in std_logic
   );
end xubm;

architecture implementation of xubm is


-- regular bus interface

signal base_addr_match : std_logic;

signal xubm_bm : std_logic_vector(17 downto 0) := (others => '0');
signal xubm_xu : std_logic_vector(15 downto 0) := (others => '0');
signal xubm_ln : std_logic_vector(7 downto 0) := (others => '0');
signal xubm_dr : std_logic := '0';

signal bm : std_logic_vector(17 downto 0);
signal xu : std_logic_vector(15 downto 0);
signal ln : std_logic_vector(6 downto 0);

signal run : std_logic;
signal cs : std_logic;

type cmd_state_type is (
   cmd_start,
   cmd_run,
   cmd_done,
   cmd_wait
);
signal cmd_state : cmd_state_type := cmd_done;

begin


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) else '0';
   bus_addr_match <= base_addr_match;

-- regular bus interface : handle register contents and dependent logic

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            npr <= '0';
            localbus_npr <= '0';

            xubm_bm <= (others => '0');
            xubm_xu <= (others => '0');
            xubm_ln <= (others => '0');
            xubm_dr <= '0';

            run <= '0';

         else

            if base_addr_match = '1' and bus_control_dati = '1' then

               case bus_addr(2 downto 1) is
                  when "00" =>
                     bus_dati <= xubm_bm(15 downto 0);

                  when "01" =>
                     bus_dati <= "00000000000000" & xubm_bm(17 downto 16);

                  when "10" =>
                     bus_dati <= xubm_xu;

                  when "11" =>
                     bus_dati <= "0000000" & xubm_dr & xubm_ln;

                  when others =>
                     bus_dati <= (others => '0');

               end case;
            end if;

            if base_addr_match = '1' and bus_control_dato = '1' then
               case bus_addr(2 downto 1) is
                  when "00" =>
                     xubm_bm(15 downto 0) <= bus_dato;

                  when "01" =>
                     xubm_bm(17 downto 16) <= bus_dato(1 downto 0);

                  when "10" =>
                     xubm_xu <= bus_dato;

                  when "11" =>
                     if bus_control_datob = '0' or bus_addr(0) = '1' then
                        xubm_dr <= bus_dato(8);
                     end if;
                     if bus_control_datob = '0' or bus_addr(0) = '0' then
                        xubm_ln <= bus_dato(7 downto 0);
                        run <= '1';
                     end if;

                  when others =>
                     null;

               end case;
            end if;

            if run = '1' then
               localbus_npr <= '1';
               if localbus_npg = '1' then
                  npr <= '1';
                  if npg = '1' then
                     if cmd_state = cmd_done then
                        run <= '0';
                        npr <= '0';
                        localbus_npr <= '0';
                     end if;
                  end if;
               end if;
            else
               npr <= '0';
               localbus_npr <= '0';
            end if;

         end if;
      end if;
   end process;


   process(xubmclk, reset)
   begin
      if xubmclk = '1' and xubmclk'event then
         if reset = '1' then
            bus_master_addr <= (others => '0');
            bus_master_dato <= (others => '0');
            bus_master_control_dati <= '0';
            bus_master_control_dato <= '0';
            localbus_master_addr <= (others => '0');
            localbus_master_dato <= (others => '0');
            localbus_master_control_dati <= '0';
            localbus_master_control_dato <= '0';

         else

            bus_master_control_dati <= '0';
            bus_master_control_dato <= '0';
            localbus_master_control_dati <= '0';
            localbus_master_control_dato <= '0';

            if run = '1' then
               if npg = '1' then               -- main bus npg implies localbus npg

                  case cmd_state is

                     when cmd_start =>

                        if xubm_dr = '0' then
                           bus_master_addr <= bm;
                           bus_master_control_dati <= '1';
                           bus_master_control_dato <= '0';
                           localbus_master_control_dati <= '0';
                           localbus_master_control_dato <= '0';
                           bm <= bm + 2;
                           ln <= ln - 1;
                        else
                           localbus_master_addr <= "00" & xu;
                           bus_master_control_dati <= '0';
                           bus_master_control_dato <= '0';
                           localbus_master_control_dati <= '1';
                           localbus_master_control_dato <= '0';
                           xu <= xu + 2;
                           ln <= ln - 1;
                        end if;
                        cmd_state <= cmd_run;

                     when cmd_run =>
                        bm <= bm + 2;
                        xu <= xu + 2;
                        ln <= ln - 1;

                        bus_master_addr <= bm;
                        localbus_master_addr <= "00" & xu;

                        if xubm_dr = '0' then
                           bus_master_control_dati <= '1';
                           localbus_master_control_dati <= '0';
                           bus_master_control_dato <= '0';
                           localbus_master_control_dato <= '1';
                           localbus_master_dato <= bus_master_dati;
                        else
                           bus_master_control_dati <= '0';
                           localbus_master_control_dati <= '1';
                           bus_master_control_dato <= '1';
                           localbus_master_control_dato <= '0';
                           bus_master_dato <= localbus_master_dati;
                        end if;
                        if ln = "0000000" then
                           cmd_state <= cmd_done;
                           bus_master_control_dati <= '0';
                           localbus_master_control_dati <= '0';
                        end if;

                     when cmd_done =>
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                        localbus_master_control_dati <= '0';
                        localbus_master_control_dato <= '0';

                     when cmd_wait =>
                        bm <= xubm_bm(17 downto 1) & '0';
                        xu <= xubm_xu(15 downto 1) & '0';
                        ln <= xubm_ln(7 downto 1);
                        bus_master_control_dati <= '0';
                        bus_master_control_dato <= '0';
                        localbus_master_control_dati <= '0';
                        localbus_master_control_dato <= '0';
                        if xubm_ln(7 downto 1) /= "0000000" then
                           cmd_state <= cmd_start;
                        end if;

                     when others =>
                        cmd_state <= cmd_done;

                  end case;

               end if;

            else
               cmd_state <= cmd_wait;
               bus_master_control_dati <= '0';
               bus_master_control_dato <= '0';
               localbus_master_control_dati <= '0';
               localbus_master_control_dato <= '0';
            end if;

         end if;
      end if;
   end process;
end implementation;
