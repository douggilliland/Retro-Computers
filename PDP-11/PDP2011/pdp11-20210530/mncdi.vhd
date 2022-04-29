
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

entity mncdi is
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

      d : in std_logic_vector(15 downto 0) := "0000000000000000";
      strobe : in std_logic := '0';
      reply : out std_logic;
      pgmout : out std_logic;
      event : out std_logic;

      have_mncdi : in integer range 0 to 1 := 0;

      reset : in std_logic;

      clk50mhz : in std_logic;
      clk : in std_logic
   );
end mncdi;

architecture implementation of mncdi is


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
signal icsr : std_logic_vector(15 downto 0);
signal icsr_overrun : std_logic;                           -- bit 15 100000 : 'overrun'
signal icsr_errie : std_logic;                             -- bit 14 040000 : 'int err en'
                                                           -- bit 13 020000 : n/c, read as zero
signal icsr_disinp : std_logic;                            -- bit 12 010000 : 'dis inputs'
                                                           -- bit 11 004000 : maint strobe?, read as zero
                                                           -- bit 10 002000 : n/c, read as zero
signal icsr_pgmout : std_logic;                            -- bit 9  001000 : 'pgm out'
signal icsr_tren : std_logic;                              -- bit 8  000400 : 'transition en'
signal icsr_done : std_logic;                              -- bit 7  000200 : 'sbr data ready'
signal icsr_ie : std_logic;                                -- bit 6  000100 : 'int rdy en'
signal icsr_invdata : std_logic;                           -- bit 5  000040 : 'inv data'
signal icsr_pnlsw : std_logic;                             -- bit 4  000020 : 'def pnl sw' - whether the panel switches invert data/strobe, or the csr bits do
signal icsr_invstr : std_logic;                            -- bit 3  000010 : 'inv strb'
signal icsr_stim : std_logic;                              -- bit 2  000004 : 'stim mode'
signal icsr_extstrb : std_logic;                           -- bit 1  000002 : 'ext strb en'
signal icsr_go : std_logic;                                -- bit 0  000001 : n/c, read as zero

signal dir : std_logic_vector(15 downto 0);
signal ddir : std_logic_vector(15 downto 0);
signal sbr : std_logic_vector(15 downto 0);

signal last_strobe : std_logic;
signal td : std_logic_vector(15 downto 12);

begin

   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_mncdi = 1 else '0';
   bus_addr_match <= base_addr_match;

   icsr <= icsr_overrun & icsr_errie & '0' & icsr_disinp & "00" & icsr_pgmout & icsr_tren & icsr_done & icsr_ie & icsr_invdata & icsr_pnlsw & icsr_invstr & icsr_stim & icsr_extstrb & icsr_go;

   dir <= ddir when icsr_invdata = '0' else not ddir;
   reply <= icsr_done;
   pgmout <= icsr_pgmout;
   event <= icsr_done;                                               -- not quite clear from the manuals, but the schematics seem to indicate it is probably 'j2 fp output low' and that is derived from the done bit

   process(clk, base_addr_match, reset, have_mncdi)
      variable v_strobe : std_logic;
   begin
      if clk = '1' and clk'event then

         if reset = '1' then
            if have_mncdi = 1 then
               interrupt_trigger1 <= '0';
               interrupt_trigger2 <= '0';
               interrupt_state <= i_idle;
            end if;
            br <= '0';
         else
            if have_mncdi = 1 then

               case interrupt_state is
                  when i_idle =>
                     br <= '0';
                     if icsr_ie = '1' and icsr_done = '1' then
                        if interrupt_trigger1 = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           interrupt_trigger1 <= '1';
                           interrupt_trigger2 <= '0';
                        end if;
                     elsif icsr_errie = '1' and icsr_overrun = '1' then
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

         if have_mncdi = 1 then
            if reset = '1' then
               icsr_errie <= '0';
               icsr_disinp <= '0';
               icsr_pgmout <= '0';
               icsr_tren <= '0';
               icsr_done <= '0';
               icsr_ie <= '0';
               icsr_invdata <= '0';
               icsr_pnlsw <= '0';
               icsr_invstr <= '0';
               icsr_stim <= '0';
               icsr_extstrb <= '0';
               icsr_go <= '0';
               ddir <= (others => '0');
               sbr <= (others => '0');

               last_strobe <= strobe;
            else

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        bus_dati <= icsr;
                     when "01" =>
                        bus_dati <= dir;
                     when "10" =>
                        bus_dati <= sbr;
                     when others =>
                        null;
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then

                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           icsr_done <= bus_dato(7);
                           icsr_ie <= bus_dato(6);
                           icsr_invdata <= bus_dato(5);
                           icsr_pnlsw <= bus_dato(4);
                           icsr_invstr <= bus_dato(3);
                           icsr_stim <= bus_dato(2);
                           icsr_extstrb <= bus_dato(1);
                           icsr_go <= bus_dato(0);
                        when "01" =>
                           if icsr_invdata = '1' then
                              ddir(7 downto 0) <= not bus_dato(7 downto 0);
                           else
                              ddir(7 downto 0) <= ddir(7 downto 0) and (not bus_dato(7 downto 0));
                           end if;
                        when "10" =>
                           sbr(7 downto 0) <= bus_dato(7 downto 0);
                        when others =>
                           null;
                     end case;
                  end if;
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '1') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           icsr_overrun <= bus_dato(15);
                           icsr_errie <= bus_dato(14);
                           icsr_disinp <= bus_dato(12);
                           if bus_dato(11) = '1' and icsr_stim = '0' then      -- maintenance strobe
                              icsr_done <= '1';
                              if icsr_done = '0' then
                                 if icsr_disinp = '0' then
                                    ddir <= d;
                                 else
                                    if icsr_invdata = '0' then
                                       ddir <= (others => '0');
                                    else
                                       ddir <= (others => '1');
                                    end if;
                                 end if;
                              end if;
                           end if;
                           icsr_pgmout <= bus_dato(9);
                           icsr_tren <= bus_dato(8);
                        when "01" =>
                           if icsr_invdata = '1' then
                              ddir(15 downto 8) <= not bus_dato(15 downto 8);
                           else
                              ddir(15 downto 8) <= ddir(15 downto 8) and (not bus_dato(15 downto 8));
                           end if;
                        when "10" =>
                           sbr(15 downto 8) <= bus_dato(15 downto 8);
                        when others =>
                           null;
                     end case;
                  end if;

               end if;

               if (strobe = '1' and icsr_invstr = '0' and last_strobe = '0') or (strobe = '0' and icsr_invstr = '1' and last_strobe = '1') then
                  v_strobe := '1';
               else
                  v_strobe := '0';
               end if;
               if v_strobe = '1' then
                  if icsr_stim = '0' then
                     if icsr_done = '1' then
                        icsr_overrun <= '1';
                     end if;
                     icsr_done <= '1';
                  end if;
               end if;
               if icsr_stim = '1' and (((d xor ddir) and sbr) /= "0000000000000000") then
                  icsr_done <= '1';
                  icsr_overrun <= '1';
               end if;
               if icsr_disinp = '0' then
                  if (icsr_extstrb = '0') or v_strobe = '1' then
                     ddir <= d;
                     if icsr_tren = '1' and d(15 downto 12) /= ddir(15 downto 12) then
                        icsr_done <= '1';
                        icsr_overrun <= '1';
                     end if;
                  end if;
               end if;
               last_strobe <= strobe;

            end if;
         end if;
      end if;
   end process;

end implementation;

