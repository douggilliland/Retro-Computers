
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

entity kl11 is
   port(
      base_addr : in std_logic_vector(17 downto 0);
      ivec : in std_logic_vector(8 downto 0);
      ovec : in std_logic_vector(8 downto 0);

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

      tx : out std_logic;
      rx : in std_logic;
      rts : out std_logic;
      cts : in std_logic;

      have_kl11 : in integer range 0 to 1;
      have_kl11_force7bit : in integer range 0 to 1;
      have_kl11_rtscts : in integer range 0 to 1;
      have_kl11_bps : in integer range 1200 to 230400;

      reset : in std_logic;

      clk50mhz : in std_logic;

      clk : in std_logic
   );
end kl11;

architecture implementation of kl11 is

-- configuration

signal have_kl11_silo : integer range 0 to 1;

-- rcsr
signal rx_act : std_logic;                                 -- rcsr bit 11
signal rx_done : std_logic;                                -- rcsr bit 7
signal rx_ie : std_logic;                                  -- rcsr bit 6

-- rbuf
signal rx_buf : std_logic_vector(7 downto 0);

-- xcsr
signal tx_rdy : std_logic;                                 -- xcsr bit 7
signal tx_ie : std_logic;                                  -- xcsr bit 6

-- xbuf
signal tx_buf : std_logic_vector(7 downto 0);

-- bus interface
signal base_addr_match : std_logic;


-- interrupt system
signal rx_trigger : std_logic := '0';
signal tx_trigger : std_logic := '0';
type interrupt_state_type is (
   i_idle,
   i_req,
   i_wait
);
signal interrupt_state : interrupt_state_type := i_idle;


-- clock divisors, speed
constant max_clkdiv : integer := 2976;
signal clkdiv : integer range 0 to max_clkdiv;
signal cdc : integer range 0 to max_clkdiv := 0;
signal cdctrigger : integer range 0 to 1 := 1;
constant max_samplerate : integer := 16;
signal samplerate : integer range 1 to max_samplerate;
signal minsample : integer range 1 to max_samplerate;


-- receiver signals, rx_<...> is owner by the bus clock domain
constant rxfilter_size : integer := 8;
subtype rxfilter_t is std_logic_vector(rxfilter_size-1 downto 0);
signal rxfilter : rxfilter_t;

signal rxf : std_logic;
signal rx_copied : std_logic := '0';

constant rx_copied_filter_size : integer := 2;
subtype rx_copied_filter_t is std_logic_vector(rx_copied_filter_size-1 downto 0);
signal rx_copied_filter : rx_copied_filter_t;


-- receiver signals, recv_<...> is owned by the receiver clock domain
type recv_state_type is (
   recv_idle,
   recv_startbit,
   recv_data,
   recv_stopbit
);
signal recv_state : recv_state_type := recv_idle;
signal recv_sample : integer range 0 to max_samplerate := 0;
signal recv_count : integer range 0 to max_samplerate := 0;
signal recv_buf : std_logic_vector(7 downto 0);
signal recv_work : std_logic_vector(7 downto 0);
signal recv_bit : integer range 0 to 7 := 0;

subtype silo_byte is std_logic_vector(7 downto 0);
type recv_silo_t is array(0 to 15) of silo_byte;
signal recv_silo : recv_silo_t;
signal recv_c : std_logic_vector(3 downto 0);
signal recv_p : std_logic_vector(3 downto 0);

signal recv_copy : std_logic := '0';
constant recv_copy_filter_size : integer := 2;
subtype recv_copy_filter_t is std_logic_vector(recv_copy_filter_size-1 downto 0);
signal recv_copy_filter : recv_copy_filter_t;

signal rtsstretch : integer range 0 to 800 := 0;


-- transmitter signals, tx_<...> is owned by the bus clock domain
signal tx_start : integer range 0 to 1 := 0;


-- transmitter signals, xmit_<...> is owned by the transmitter clock domain
type xmit_state_type is (
   xmit_idle,
   xmit_startbit,
   xmit_data,
   xmit_stopbit
);
signal xmit_state : xmit_state_type := xmit_idle;
signal xmit_sample : integer range 0 to max_samplerate;
signal xmit_buf : std_logic_vector(7 downto 0);
signal xmit_buf_loaded : integer range 0 to 1 := 0;
signal xmit_bit : integer range 0 to 7 := 0;


begin

-- clkdiv: this many cycles to count off for each sample
   with have_kl11_bps select clkdiv <=
      2976 when 1200,
      1488 when 2400,
      744  when 4800,
      372  when 9600,
      186  when 19200,
      93   when 38400,
      62   when 57600,
      31   when 115200,
      18   when 230400,
      372  when others;                -- fallback to 9600 when we don't know the translation

-- samplerate: this many samples for each bit
   with have_kl11_bps select samplerate <=
      14 when 1200,
      14 when 2400,
      14 when 4800,
      14 when 9600,
      14 when 19200,
      14 when 38400,
      14 when 57600,
      14 when 115200,
      12 when 230400,
      14 when others;                  -- fallback to 9600 when we don't know the translation

-- samplerate: this many samples for each bit
   with have_kl11_bps select minsample <=
      8  when 1200,
      8  when 2400,
      8  when 4800,
      8  when 9600,
      8  when 19200,
      8  when 38400,
      8  when 57600,
      8  when 115200,
      6  when 230400,
      10 when others;                  -- fallback to 9600 when we don't know the translation


   base_addr_match <= '1' when base_addr(17 downto 3) = bus_addr(17 downto 3) and have_kl11 = 1 else '0';
   bus_addr_match <= base_addr_match;

   have_kl11_silo <= 1 when have_kl11_rtscts = 1 else 0;

   process(clk, base_addr_match, reset, have_kl11, recv_copy)
   begin
      if clk = '1' and clk'event then
         if reset = '1' then
            if have_kl11 = 1 then
               rx_trigger <= '0';
               tx_trigger <= '0';
               interrupt_state <= i_idle;
            end if;
            br <= '0';
         else
            if have_kl11 = 1 then

               case interrupt_state is

                  when i_idle =>
                     br <= '0';
                     if tx_ie = '1' and tx_rdy = '1' then
                        if tx_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           tx_trigger <= '1';
                           rx_trigger <= '0';
                        end if;
                     else
                        tx_trigger <= '0';
                     end if;
                     if rx_ie = '1' and rx_done = '1' then
                        if rx_trigger = '0' then
                           interrupt_state <= i_req;
                           br <= '1';
                           rx_trigger <= '1';
                           tx_trigger <= '0';
                        end if;
                     else
                        rx_trigger <= '0';
                     end if;

                  when i_req =>
                     if tx_trigger = '1' then
                        if bg = '1' then
                           int_vector <= ovec;
                           br <= '0';
                           interrupt_state <= i_wait;
                        end if;
                     end if;
                     if rx_trigger = '1' then
                        if bg = '1' then
                           int_vector <= ivec;
                           br <= '0';
                           interrupt_state <= i_wait;
                        end if;
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

         if have_kl11 = 1 then
            if reset = '1' then
               rx_done <= '0';
               rx_ie <= '0';
               tx_buf <= "00000000";
               rx_buf <= "00000000";
               tx_ie <= '0';
               rx_act <= '0';
               tx_rdy <= '1';

               tx_start <= 0;
            else

               recv_copy_filter <= recv_copy_filter(recv_copy_filter_t'high-1 downto 0) & recv_copy;
               if recv_copy_filter = recv_copy_filter_t'(others => '1') and rx_copied = '0' then
                  if rx_done = '0' then
                     rx_buf <= recv_buf;
                     rx_done <= '1';
                     rx_copied <= '1';
                  end if;
               end if;
               if rx_copied = '1' then
                  if recv_copy_filter = recv_copy_filter_t'(others => '0') then
                     rx_copied <= '0';
                  end if;
               end if;

               if tx_start = 1 then
                  if xmit_buf_loaded = 1 then
                     tx_start <= 0;
                  end if;
               end if;
               if tx_start = 0 and xmit_state = xmit_idle then
--                  if cts = '0' then
                     tx_rdy <= '1';
--                  end if;
               end if;

               if recv_state /= recv_idle then
                  rx_act <= '1';
               else
                  rx_act <= '0';
               end if;

               if base_addr_match = '1' and bus_control_dati = '1' then
                  case bus_addr(2 downto 1) is
                     when "00" =>
                        bus_dati <= "0000" & rx_act & "000" & rx_done & rx_ie & "000000";
                     when "01" =>
                        rx_done <= '0';
                        if have_kl11_force7bit = 1 then
                           bus_dati <= "00000000" & "0" & rx_buf(6 downto 0);
                        else
                           bus_dati <= "00000000" & rx_buf;
                        end if;
                     when "10" =>
                        bus_dati <= "00000000" & tx_rdy & tx_ie & "000000";
                     when "11" =>
                        bus_dati <= "00000000" & tx_buf;
                     when others =>
                        bus_dati <= "0000000000000000";
                  end case;
               end if;

               if base_addr_match = '1' and bus_control_dato = '1' then
                  if bus_control_datob = '0' or (bus_control_datob = '1' and bus_addr(0) = '0') then
                     case bus_addr(2 downto 1) is
                        when "00" =>
                           rx_ie <= bus_dato(6);
                           if bus_dato(0) = '1' then
                              rx_done <= '0';
                           end if;
                        when "01" =>
                           rx_done <= '0';
                        when "10" =>
                           tx_ie <= bus_dato(6);
                        when "11" =>
                           if have_kl11_force7bit = 1 then
                              tx_buf <= '0' & bus_dato(6 downto 0);
                           else
                               tx_buf <= bus_dato(7 downto 0);
                           end if;
                           tx_start <= 1;
                           tx_rdy <= '0';
                        when others =>
                           null;
                     end case;
                  end if;
               end if;

            end if;
         end if;
      end if;
   end process;

   process(clk50mhz, reset, rx, rx_done, rx_copied)
   begin
      if clk50mhz = '1' and clk50mhz'event then
         if reset = '1' then
            if have_kl11 = 1 then
               cdc <= 0;
               cdctrigger <= 1;
               recv_state <= recv_idle;
               xmit_state <= xmit_idle;
               xmit_buf_loaded <= 0;
               recv_copy <= '0';
               rtsstretch <= 0;
               rts <= '0';
               rxf <= '1';

               recv_c <= "0000";
               recv_p <= "0000";
            end if;
         else

            if have_kl11 = 1 then

--
-- filter rx
--

               rxfilter <= rxfilter(rxfilter_t'high-1 downto 0) & rx;
               if rxfilter = rxfilter_t'(others => '0') then
                  rxf <= '0';
               elsif rxfilter = rxfilter_t'(others => '1') then
                  rxf <= '1';
               else
-- undefined keeps the last value. handle that in some other way? FIXME
--                  rxf <= '1';
               end if;

               if cdc <= clkdiv-1 then
                  cdc <= cdc + 1;
                  cdctrigger <= 0;
               else
                  cdc <= 0;
                  cdctrigger <= 1;
               end if;

               if cdctrigger = 1 then


-- receiver

                  rx_copied_filter <= rx_copied_filter(rx_copied_filter_t'high-1 downto 0) & rx_copied;
                  if recv_copy = '1' then
                     if rx_copied_filter = rx_copied_filter_t'(others => '1') then
                        recv_copy <= '0';
                     end if;
                  end if;

-- what to do to rts is depending on all the configuration complexity. It should allow the silo to be used, if it is
-- there. And if not, it should allow some movement as well. And if rts is not wanted, just set it to allow sending
-- just in case the other side is monitoring the level anyway.

                  if have_kl11_silo = 1 then

                     if recv_c /= recv_p then                                  -- if the silo is not empty
                        if recv_copy = '0' then                                -- and if we're not already in an interchange with the controller
                           recv_copy <= '1';                                   -- then issue a byte to the controller to dispose of
                           recv_buf <= recv_silo(conv_integer(recv_c));        -- and this byte is what it is
                           recv_c <= recv_c + 1;                               -- and be done with it
                        end if;
                     end if;

                     if (recv_p - recv_c) > "1011" then                        -- allow the silo to reach some size, but leave some headroom as well
                        rts <= '1';                                            -- before blocking the transmitter on the other side
                        rtsstretch <= samplerate*15;                           -- and block for a meaningful minimum of time, while we're at it
                     elsif recv_p = recv_c then
                        if rtsstretch = 0 then
                           rts <= '0';
                        else
                           rtsstretch <= rtsstretch - 1;
                        end if;
                     end if;

                  elsif have_kl11_rtscts = 1 then

                     if recv_state /= recv_idle and recv_copy = '1' then         -- if we're already receiving, and in the process of getting rid of the last byte, then we're busy.
                        rts <= '1';
                        rtsstretch <= samplerate*15;
                     else
                        if rtsstretch = 0 then
                           rts <= '0';
                        else
                           rtsstretch <= rtsstretch - 1;
                        end if;
                     end if;

                  else
                     rts <= '0';                                               -- we're not going to block the transmitter of the other side, even if we're not doing rtscts
                  end if;

                  case recv_state is

                     when recv_idle =>
                        if rxf = '0' then
                           recv_state <= recv_startbit;
                           recv_count <= 0;
                        end if;

                     when recv_startbit =>
                        if rxf = '0' then
                           recv_count <= recv_count + 1;
                        end if;
                        if recv_sample >= samplerate-1 then
                           recv_state <= recv_data;
                           recv_bit <= 0;
                           recv_count <= 0;
                        end if;

                     when recv_data =>
                        if rxf = '0' then
                           recv_count <= recv_count + 1;
                        end if;
                        if recv_sample >= samplerate-1 then
                           if have_kl11_silo = 1 then
                              if recv_count >= minsample then
                                 recv_work(recv_bit) <= '0';
                              else
                                 recv_work(recv_bit) <= '1';
                              end if;
                           else
                              if recv_count >= minsample then
                                 recv_buf(recv_bit) <= '0';
                              else
                                 recv_buf(recv_bit) <= '1';
                              end if;
                           end if;
                           recv_count <= 0;
                           recv_bit <= recv_bit + 1;
                           if recv_bit = 7 then
                              recv_state <= recv_stopbit;
                           end if;
                        end if;

                     when recv_stopbit =>
                        if rxf = '0' then
                           recv_count <= recv_count + 1;
                        end if;
                        if have_kl11_silo = 1 then                             -- if the silo is configured
                           if recv_sample = 0 then                             -- and we're in the first sample of receiving the stopbit
                              recv_p <= recv_p + 1;                            -- then add the byte to the silo
                              recv_silo(conv_integer(recv_p)) <= recv_work;
                           end if;
                        else                                                   -- if no silo, then the byte will have been collected in recv_buf, which can be accessed by the controller
                           if recv_sample = 0 then
                              recv_copy <= '1';                                -- so set recv_copy to kick it off and issue the byte to the controller to dispose of
                           end if;
                        end if;
                        if recv_sample > minsample-4 and rxf = '1' then        -- allow to stop early, some transmitters don't honour stop bit timing
                           recv_state <= recv_idle;
                        end if;

                     when others =>
                        null;

                  end case;

                  if recv_state = recv_idle then
                     recv_sample <= 0;
                  else
                     recv_sample <= recv_sample + 1;
                     if recv_sample >= samplerate-1 then
                        recv_sample <= 0;
                     end if;
                  end if;

-- transmitter

                  if xmit_buf_loaded = 1 and tx_start = 0 then
                     xmit_buf_loaded <= 0;
                  end if;

                  case xmit_state is

                     when xmit_idle =>
                        tx <= '1';
                        if tx_start = 1 and xmit_buf_loaded = 0 then
                           xmit_state <= xmit_startbit;
                           xmit_buf <= tx_buf;
                           xmit_buf_loaded <= 1;
                        end if;

                     when xmit_startbit =>
                        tx <= '0';
                        if xmit_sample >= samplerate-1 then
                           xmit_state <= xmit_data;
                           xmit_bit <= 0;
                        end if;

                     when xmit_data =>
                        tx <= xmit_buf(xmit_bit);
                        if xmit_sample >= samplerate-1 then
                           xmit_bit <= xmit_bit + 1;
                           if xmit_bit = 7 then
                              xmit_state <= xmit_stopbit;
                           end if;
                        end if;

                     when xmit_stopbit =>
                        tx <= '1';
                        if xmit_sample >= samplerate-1 then
                           xmit_state <= xmit_idle;
                        end if;

                     when others =>
                        null;

                  end case;

                  if xmit_state = xmit_idle then
                     xmit_sample <= 0;
                  else
                     xmit_sample <= xmit_sample + 1;
                     if xmit_sample >= samplerate-1 then
                        xmit_sample <= 0;
                     end if;
                  end if;

               end if;

            else

               tx <= '1';

            end if;

         end if;
      end if;
   end process;

end implementation;

