
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

entity xubl is
   port(
      base_addr : in std_logic_vector(17 downto 0);

      npr : out std_logic;
      npg : in std_logic;

      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

      bus_master_addr : out std_logic_vector(17 downto 0);
      bus_master_dati : in std_logic_vector(15 downto 0);
      bus_master_dato : out std_logic_vector(15 downto 0);
      bus_master_control_dati : out std_logic;
      bus_master_control_dato : out std_logic;
      bus_master_nxm : in std_logic;

      xu_cs : out std_logic;
      xu_mosi : out std_logic;
      xu_sclk : out std_logic;
      xu_miso : in std_logic;

      reset : in std_logic;
      xublclk : in std_logic;
      clk : in std_logic
   );
end xubl;

architecture implementation of xubl is


-- regular bus interface

signal base_addr_match : std_logic;

-- registers for the bus interface - remember addresses for the xu cpu are at most 16 bits long, as there is no mmu

signal xubl_xf : std_logic_vector(15 downto 0);            -- xmit from this address
signal xubl_xl : std_logic_vector(7 downto 3);             -- xmit length
signal xubl_rt : std_logic_vector(15 downto 0);            -- receive to this address
signal xubl_rl : std_logic_vector(7 downto 3);             -- receive length

-- internal buffered versions of the registers

signal xf : std_logic_vector(15 downto 0);                 -- xmit from
signal xl : std_logic_vector(7 downto 0);                  -- xmit length
signal rt : std_logic_vector(15 downto 0);                 -- receive to
signal rl : std_logic_vector(7 downto 0);                  -- receive length

signal work: std_logic_vector(15 downto 0);

signal run : std_logic;
signal cs : std_logic;

signal bitcount : integer range 0 to 15;

type cmd_state_type is (
   cmd_start,
   cmd_xmit,
   cmd_recv,
   cmd_done,
   cmd_wait
);
signal cmd_state : cmd_state_type := cmd_done;

begin


-- regular bus interface

   base_addr_match <= '1' when base_addr(17 downto 4) = bus_addr(17 downto 4) else '0';
   bus_addr_match <= base_addr_match;

   xu_cs <= cs;
   xu_sclk <= clk when cs = '0' else '0';

-- regular bus interface : handle register contents and dependent logic

   process(clk, reset)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            npr <= '0';

            xubl_xf <= (others => '0');
            xubl_xl <= (others => '0');
            xubl_rt <= (others => '0');
            xubl_rl <= (others => '0');

            run <= '0';

         else

-- there appears to never be a need to read back these values

--             if base_addr_match = '1' and bus_control_dati = '1' then
--
--                case bus_addr(3 downto 1) is
--                   when "000" =>
--                      bus_dati <= xubl_xf;
--
--                   when "001" =>
--                      bus_dati <= xubl_xl;
--
--                   when "010" =>
--                      bus_dati <= xubl_rt;
--
--                   when "011" =>
--                      bus_dati <= xubl_rl;
--
--                   when others =>
--                      bus_dati <= (others => '0');
--
--                end case;
--             end if;
--
            if base_addr_match = '1' and bus_control_dato = '1' then
               case bus_addr(3 downto 1) is
                  when "000" =>
                     xubl_xf <= bus_dato;

                  when "001" =>
                     xubl_xl <= bus_dato(7 downto 3);
                     run <= '1';

                  when "010" =>
                     xubl_rt <= bus_dato;

                  when "011" =>
                     xubl_rl <= bus_dato(7 downto 3);

                  when others =>
                     null;

               end case;
            end if;

            if run = '1' then
               npr <= '1';
               if npg = '1' then
                  if cmd_state = cmd_done then
                     run <= '0';
                     npr <= '0';
                  end if;
               end if;
            end if;

         end if;
      end if;
   end process;


-- state machine for spi communication to the encx24j600
-- the communication always follows the pattern of transmitting
-- (x) bits to the chip, then reading (r) bits. The number of
-- bits must in all cases be a multiple of 8, but the access to
-- main memory will be multiples of 16, ie words.
-- The receive length (r) may be zero.
-- The maximum length is 32 bytes in one run - 256 bits; both
-- 256 xmit, and 256 receive are allowed in one run.
-- The current core enforces the length fields to be multiples
-- of 8 - the low bits are masked.

   process(xublclk, reset)
   begin
      if xublclk = '1' and xublclk'event then
         if reset = '1' then
            bus_master_addr <= (others => '0');
            bus_master_dato <= (others => '0');
            bus_master_control_dati <= '0';
            bus_master_control_dato <= '0';

            cs <= '1';

         else
            if run = '1' then
               if npg = '1' then

                  case cmd_state is

                     when cmd_start =>
                        rt <= xubl_rt;
                        xf <= xubl_xf + 2;
                        xl <= xubl_xl(7 downto 3) & "000";
                        rl <= xubl_rl(7 downto 3) & "000";

                        bitcount <= 15;
                        bus_master_addr <= "00" & xubl_xf;
                        bus_master_control_dati <= '1';
                        cmd_state <= cmd_xmit;

                     when cmd_xmit =>
                        bitcount <= bitcount - 1;
                        if bitcount = 15 then
                           bus_master_control_dati <= '0';
                           work <= bus_master_dati(14 downto 0) & bus_master_dati(15);
                           xu_mosi <= bus_master_dati(7);
                           cs <= '0';
                        else
                           xu_mosi <= work(7);
                           work <= work(14 downto 0) & work(15);
                           if bitcount = 0 then
                              bitcount <= 15;
                              bus_master_addr <= "00" & xf;
                              xf <= xf + 2;
                              bus_master_control_dati <= '1';
                           end if;
                        end if;
                        if xl = "00000000" then
                           cmd_state <= cmd_recv;
                           bitcount <= 15;
                           if rl = "00000000" then
                              cmd_state <= cmd_done;
                           end if;
                        else
                           xl <= xl - 1;
                        end if;

                     when cmd_recv =>
                        work <= work(14 downto 8) & xu_miso & work(6 downto 0) & work(15);
                        if rl = "00000000" then
                           cmd_state <= cmd_done;
                        else
                           rl <= rl - 1;
                        end if;
                        bitcount <= bitcount - 1;
                        if bitcount = 0 then
                           bitcount <= 15;
                           bus_master_addr <= "00" & rt;
                           bus_master_dato <= work(14 downto 8) & xu_miso & work(6 downto 0) & work(15);
                           bus_master_control_dato <= '1';
                           rt <= rt + 2;
                        else
                           bitcount <= bitcount - 1;
                           bus_master_control_dato <= '0';
                        end if;

                     when cmd_done =>
                        cs <= '1';

                     when cmd_wait =>
                        cmd_state <= cmd_start;

                     when others =>
                        null;
                  end case;

               end if;

            else
               cmd_state <= cmd_wait;
               cs <= '1';
            end if;

         end if;
      end if;
   end process;
end implementation;
