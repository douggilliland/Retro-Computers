
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

entity dr11c is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec1 : in std_logic_vector(8 downto 0);
      ivec2 : in std_logic_vector(8 downto 0);

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

      have_dr11c : in integer range 0 to 1 := 0;
      have_dr11c_loopback : in integer range 0 to 1 := 0;
      have_dr11c_signal_stretch : in integer range 0 to 127 := 7;

      dr11c_in : in std_logic_vector(15 downto 0) := (others => '0');
      dr11c_out : out std_logic_vector(15 downto 0);
      dr11c_reqa : in std_logic := '0';
      dr11c_reqb : in std_logic := '0';
      dr11c_csr0 : out std_logic;
      dr11c_csr1 : out std_logic;
      dr11c_ndr : out std_logic;
      dr11c_ndrlo : out std_logic;
      dr11c_ndrhi : out std_logic;
      dr11c_dxm : out std_logic;
      dr11c_init : out std_logic;

      reset : in std_logic;

      clk50mhz : in std_logic;

      clk : in std_logic
   );
end dr11c;

architecture implementation of dr11c is


-- bus interface
signal base_addr_match : std_logic;


-- interrupt system
signal reqa_trigger : std_logic := '0';
signal reqb_trigger : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;

-- logic

signal intenba : std_logic;
signal intenbb : std_logic;
signal reqa : std_logic;
signal reqb : std_logic;
signal csr1 : std_logic;
signal csr0 : std_logic;
signal odb : std_logic_vector(15 downto 0);
signal idb : std_logic_vector(15 downto 0);

signal ndr : std_logic;
signal ndrlo : std_logic;
signal ndrlo_count : integer range 0 to 127;
signal ndrhi : std_logic;
signal ndrhi_count : integer range 0 to 127;
signal dxm : std_logic;
signal dxm_count : integer range 0 to 127;
signal init : std_logic;
signal init_count : integer range 0 to 127;


begin

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_dr11c = 1 else '0';
   bus_addr_match <= base_addr_match;


   ndr <= ndrlo or ndrhi;
   ndrlo <= '1' when ndrlo_count /= 0 else '0';
   ndrhi <= '1' when ndrhi_count /= 0 else '0';
   dxm <= '1' when dxm_count /= 0 else '0';
   init <= '1' when init_count /= 0 else '0';

   dr11c_out <= odb when have_dr11c_loopback = 0 else (others => '0');
   dr11c_ndr <= ndr when have_dr11c_loopback = 0 else '0';
   dr11c_ndrlo <= ndrlo when have_dr11c_loopback = 0 else '0';
   dr11c_ndrhi <= ndrhi when have_dr11c_loopback = 0 else '0';
   dr11c_dxm <= dxm when have_dr11c_loopback = 0 else '0';
   dr11c_init <= init when have_dr11c_loopback = 0 else '0';
   dr11c_csr0 <= csr0 when have_dr11c_loopback = 0 else '0';
   dr11c_csr1 <= csr1 when have_dr11c_loopback = 0 else '0';

   process(clk, base_addr_match, reset, have_dr11c)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            if have_dr11c = 1 then
               reqa_trigger <= '0';
               reqb_trigger <= '0';
               interrupt_state <= i_idle;
            end if;
            br <= '0';
         else

            if have_dr11c = 1 then

               case interrupt_state is

                  when i_idle =>
                     br <= '0';

                     if intenbb = '1' and reqb = '1' then
                        if reqb_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           reqb_trigger <= '1';
                           reqa_trigger <= '0';
                        end if;
                     else
                        reqb_trigger <= '0';
                     end if;

                     if intenba = '1' and reqa = '1' then
                        if reqa_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           reqa_trigger <= '1';
                           reqb_trigger <= '0';
                        end if;
                     else
                        reqa_trigger <= '0';
                     end if;

                  when i_req =>
                     if bg = '1' and reqa_trigger = '1' then
                        int_vector <= ivec1;
                        br <= '0';
                        interrupt_state <= i_wait;
                     elsif bg = '1' and reqb_trigger = '1' then
                        int_vector <= ivec2;
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

         if have_dr11c = 1 then
            if reset = '1' then

               intenba <= '0';
               intenbb <= '0';

               reqa <= '0';
               reqb <= '0';

               csr1 <= '0';
               csr0 <= '0';

               idb <= (others => '0');
               odb <= (others => '0');

               ndrhi_count <= 0;
               ndrlo_count <= 0;
               dxm_count <= 0;
               init_count <= have_dr11c_signal_stretch;

            else

               if ndrhi_count /= 0 then
                  ndrhi_count <= ndrhi_count - 1;
               end if;
               if ndrlo_count /= 0 then
                  ndrlo_count <= ndrlo_count - 1;
               end if;
               if dxm_count /= 0 then
                  dxm_count <= dxm_count - 1;
               end if;
               if init_count /= 0 then
                  init_count <= init_count - 1;
               end if;

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        bus_dati <= reqb & "0000000" & reqa & intenba & intenbb & "000" & csr1 & csr0;
                     when "01" =>
                        bus_dati <= odb;
                     when "10" =>
                        bus_dati <= idb;
                        dxm_count <= have_dr11c_signal_stretch;
                     when others =>
                        bus_dati <= "0000000000000000";
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           intenba <= bus_dato(6);
                           intenbb <= bus_dato(5);
                           csr1 <= bus_dato(1);
                           csr0 <= bus_dato(0);
                        when "01" =>
                           odb(7 downto 0) <= bus_dato(7 downto 0);
                           ndrlo_count <= have_dr11c_signal_stretch;
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(2 downto 1) is
                        when "01" =>
                           odb(15 downto 8) <= bus_dato(15 downto 8);
                           ndrhi_count <= have_dr11c_signal_stretch;
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               if have_dr11c_loopback = 1 then
                  idb <= odb;
                  reqb <= csr1;
                  reqa <= csr0;
               end if;

            end if;
         end if;
      end if;
   end process;


end implementation;

