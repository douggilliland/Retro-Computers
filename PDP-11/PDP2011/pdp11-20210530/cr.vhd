
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

entity cr is
   port(
      bus_addr_match : out std_logic;
      bus_addr : in std_logic_vector(17 downto 0);
      bus_dati : out std_logic_vector(15 downto 0);
      bus_dato : in std_logic_vector(15 downto 0);
      bus_control_dati : in std_logic;
      bus_control_dato : in std_logic;
      bus_control_datob : in std_logic;

-- psw
      psw_in : out std_logic_vector(15 downto 0);
      psw_in_we_even : out std_logic;
      psw_in_we_odd : out std_logic;
      psw_out : in std_logic_vector(15 downto 0);

-- stack limit
      cpu_stack_limit : out std_logic_vector(15 downto 0);

-- pirq
      pir_in : out std_logic_vector(15 downto 0);

-- cer
      cpu_illegal_halt : in std_logic;
      cpu_address_error : in std_logic;
      cpu_nxm : in std_logic;
      cpu_iobus_timeout : in std_logic;
      cpu_ysv : in std_logic;
      cpu_rsv : in std_logic;

-- lma (f11)
      mmu_lma_c1 : in std_logic := '0';
      mmu_lma_c0 : in std_logic := '0';
      mmu_lma_eub : in std_logic_vector(21 downto 0) := (others => '0');

-- maintenance register (j11)
      cpu_kmillhalt : out std_logic;

-- model code

      modelcode : in integer range 0 to 255;
      have_fpa : in integer range 0 to 1 := 0;                       -- floating point accelerator present with J11 cpu

--
      reset : in std_logic;
      clk : in std_logic
   );
end cr;

architecture implementation of cr is

signal base_addr_match : std_logic;
signal nxm : std_logic;
signal we : std_logic;
signal wo : std_logic;

signal stacklimit : std_logic_vector(15 downto 0);

signal pir : std_logic_vector(15 downto 0);
signal pia : std_logic_vector(2 downto 0);

signal cer_illhlt : std_logic;
signal cer_addrerr : std_logic;
signal cer_nxm : std_logic;
signal cer_iobto : std_logic;
signal cer_ysv : std_logic;
signal cer_rsv : std_logic;

signal ccr : std_logic_vector(5 downto 0);

signal kmillhalt : std_logic;

signal lma_fj : std_logic;

signal f11 : integer range 0 to 1;
signal j11 : integer range 0 to 1;

begin

   with modelcode select f11 <=
      1 when 23 | 24,
      0 when others;

   with modelcode select j11 <=
      1 when 73 | 83 | 84 | 93 | 94,   -- kdj11
      0 when others;

   base_addr_match <= '1' when
      bus_addr(17 downto 5) = "1111111111111"
   or
      (f11 = 1 and bus_addr(17 downto 3) = o"77773" and bus_addr(2) = '1')
   or
      (j11 = 1 and bus_addr(17 downto 3) = o"77773")
   or
      (j11 = 1 and bus_addr(17 downto 3) = o"77752")
   else '0';

   bus_addr_match <= '1' when base_addr_match = '1' and nxm = '0' else '0';

   we <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '0') else '0';
   wo <= '1' when (bus_control_dato = '1' and bus_control_datob = '0') or (bus_control_datob = '1' and bus_addr(0) = '1') else '0';

   cpu_stack_limit <= stacklimit;

   cpu_kmillhalt <= kmillhalt;

   pia <=
      "111" when pir(15) = '1'
      else "110" when pir(14) = '1'
      else "101" when pir(13) = '1'
      else "100" when pir(12) = '1'
      else "011" when pir(11) = '1'
      else "010" when pir(10) = '1'
      else "001" when pir(9) = '1'
      else "000";

   pir(8) <= '0';
   pir(7 downto 5) <= pia;
   pir(4) <= '0';
   pir(3 downto 1) <= pia;
   pir(0) <= '0';

   pir_in <= pir;


   process(clk, reset)
   begin

      if clk = '1' and clk'event then
         if reset = '1' then

            nxm <= '0';

-- psw
            psw_in <= "0000000000000000";

-- stack limit
            stacklimit <= x"0000";

-- pirq
            pir(15 downto 9) <= "0000000";

-- cer
            cer_illhlt <= '0';
            cer_addrerr <= '0';
            cer_nxm <= '0';
            cer_iobto <= '0';
            cer_ysv <= '0';
            cer_rsv <= '0';

-- ccr
            ccr <= (others => '0');

-- mr
            kmillhalt <= '0';

            if f11 = 1 then
               lma_fj <= '0';
            end if;

         else

            if cpu_illegal_halt = '1' then
               cer_illhlt <= '1';
            end if;

            if cpu_address_error = '1' then
               cer_addrerr <= '1';
            end if;

            if cpu_nxm = '1' then
               cer_nxm <= '1';
            end if;

            if cpu_iobus_timeout = '1' then
               cer_iobto <= '1';
            end if;

            if cpu_ysv = '1' then
               cer_ysv <= '1';
            end if;

            if cpu_rsv = '1' then
               cer_rsv <= '1';
            end if;

            psw_in_we_even <= '0';
            psw_in_we_odd <= '0';

            nxm <= '0';

            if bus_addr(17 downto 5) = "1111111111111" and (bus_control_dati = '1' or bus_control_dato = '1') then
               case bus_addr(4 downto 1) is

-- 17 777 776
                  when "1111" =>                           -- psw
                     if modelcode = 23 or modelcode = 24             -- kdf11
                     or modelcode = 4
                     or modelcode = 5  or modelcode = 10
                     or modelcode = 15 or modelcode = 20
                     or modelcode = 34
                     or modelcode = 35 or modelcode = 40
                     or modelcode = 44
                     or modelcode = 45 or modelcode = 50 or modelcode = 55
                     or modelcode = 60
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 83 or modelcode = 84 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= psw_out;
                        end if;
                        if wo = '1' then
                           psw_in(15 downto 8) <= bus_dato(15 downto 8);
                           psw_in_we_odd <= '1';
                        end if;
                        if we = '1' then
                           psw_in(7 downto 0) <= bus_dato(7 downto 0);
                           psw_in_we_even <= '1';
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 774
                  when "1110" =>                           -- stack limit
                     if modelcode = 45 or modelcode = 50 or modelcode = 55
                     or modelcode = 60
                     or modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= stacklimit;
                        end if;
                        if wo = '1' then
                           stacklimit(15 downto 8) <= bus_dato(15 downto 8);
                        end if;
                        stacklimit(7 downto 0) <= "00000000";
                     else
                        nxm <= '1';
                     end if;

-- 17 777 772
                  when "1101" =>                           -- pirq
                     if modelcode = 44
                     or modelcode = 45 or modelcode = 50 or modelcode = 55
                     or modelcode = 60
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 83 or modelcode = 84 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= pir;
                        end if;
                        if wo = '1' then
                           pir(15 downto 9) <= bus_dato(15 downto 9);
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 770
                  when "1100" =>                           -- microbreak register, EK-KB11C-TM-001_1170procMan.pdf
                     if modelcode = 45 or modelcode = 50 or modelcode = 55
                     or modelcode = 60                        -- ??
                     or modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 766
                  when "1011" =>                           -- cer
                     if modelcode = 23 or modelcode = 24
                     or modelcode = 44
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 83 or modelcode = 84 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           if modelcode = 44 then
                              bus_dati <= "00000000"
                              & cer_illhlt                           -- 07 - 0080 - Illegal Halt
                              & cer_addrerr                          -- 06 - 0040 - Odd Address Error
                              & cer_nxm                              -- 05 - 0020 - Memory Time-Out
                              & cer_iobto                            -- 04 - 0010 - Unibus Time-Out
                              & '0'                                  -- 03 - 0008 - this bit monitors the processor initialize signal
                              & cer_ysv                              -- 02 - 0004 - Stack Overflow - This bit is set to 1 when the kernel hardware stack is less than octal 400
                              & '0'                                  -- 01 - 0002 - This bit is set when the PAX Interrupt line is asserted
                              & '0';                                 -- 00 - 0001 - CIM Power Failure - This bit, when set to 1, indicates that dc power to the machine has exceeded voltage tolerance limits
                           else                            -- default model is compliant with 11/70 acc. PDP11_Handbook1979.pdf
                              bus_dati <= "00000000"
                              & cer_illhlt                           -- 07 - 0080 - Illegal Halt
                              & cer_addrerr                          -- 06 - 0040 - Odd Address Error
                              & cer_nxm                              -- 05 - 0020 - Memory Time-Out
                              & cer_iobto                            -- 04 - 0010 - Unibus Time-Out
                              & cer_ysv                              -- 03 - 0008 - Yellow stack trap
                              & cer_rsv                              -- 02 - 0004 - Red stack trap
                              & "00";
                           end if;
                        end if;
                        if we = '1' then
                           cer_illhlt <= '0';
                           cer_addrerr <= '0';
                           cer_nxm <= '0';
                           cer_iobto <= '0';
                           cer_ysv <= '0';
                           cer_rsv <= '0';
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 764
                  when "1010" =>                           -- system id
                     if modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= '0' & o"03733";     -- this is apparently only used by the rsts ha/li display, and that displays it in decimal. Hence this value.
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 762
                  when "1001" =>                           -- system size, upper system size
                     if modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 760
                  when "1000" =>                           -- system size, lower system size
                     if modelcode = 70
                     then
                        if bus_control_dati = '1' then
--                           bus_dati <= "0111111111111111";           -- 077777 means 1024Kwords
                           bus_dati <= "1110111111111111";           -- 167777 means 1920Kwords
   --                                   1098765432109876
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 756
                  when "0111" =>                           -- ?
                     nxm <= '1';

-- 17 777 754
                  when "0110" =>                           -- ?
                     nxm <= '1';

-- 17 777 752
                  when "0101" =>                           -- hit/miss register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-21
                     if modelcode = 44
                     or modelcode = 60
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     elsif modelcode = 83 or modelcode = 84 then
                        if bus_control_dati = '1' then
                           bus_dati <= "0000000000001000";           -- acc. simh pdp11_cpumod.c, 11/8x hit/miss reg should be nonzero
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 750
                  when "0100" =>                           -- maintenance register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-21
                     if modelcode = 44
                     or modelcode = 70
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     elsif modelcode = 73 or modelcode = 83 or modelcode = 93 then       -- qbus j11 models
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                           bus_dati(9) <= '0';                                           -- not unibus system
                           if have_fpa = 1 then
                              bus_dati(8) <= '1';                                        -- this bit is about the floating point accelerator only - j-11 has a regular fpu already in its microcode
                           else
                              bus_dati(8) <= '0';                                        -- this bit is about the floating point accelerator only - j-11 has a regular fpu already in its microcode
                           end if;
                           bus_dati(7 downto 4) <= "0010";                               -- module type -- FIXME
                           bus_dati(3) <= kmillhalt;                                     -- trap to odt on halt
                           bus_dati(2 downto 1) <= "10";                                 -- powerup mode
                           bus_dati(0) <= '1';                                           -- power ok
                        end if;
                        if we = '1' then
                           kmillhalt <= bus_dato(3);
                        end if;
                     elsif modelcode = 84 or modelcode = 94 then                         -- unibus j11 models
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                           bus_dati(9) <= '1';                                           -- unibus system
                           if have_fpa = 1 then
                              bus_dati(8) <= '1';                                        -- this bit is about the floating point accelerator only - j-11 has a regular fpu already in its microcode
                           else
                              bus_dati(8) <= '0';                                        -- this bit is about the floating point accelerator only - j-11 has a regular fpu already in its microcode
                           end if;
                           if modelcode = 94 then
                              bus_dati(7 downto 4) <= "0101";                            -- module type 94=5=KDJ11E
                           elsif modelcode = 84 then
                              bus_dati(7 downto 4) <= "0010";                            -- module type 84=2=KDJ11B
                           else
                              bus_dati(7 downto 4) <= "0010";
                           end if;
                           bus_dati(3) <= kmillhalt;                                     -- trap to odt on halt
                           bus_dati(2 downto 1) <= "10";                                 -- powerup mode
                           bus_dati(0) <= '1';                                           -- power ok
                        end if;
                        if we = '1' then
                           kmillhalt <= bus_dato(3);
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 746
                  when "0011" =>                           -- cache control register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-19
                     if modelcode = 44
                     or modelcode = 60
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 83 or modelcode = 84 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                           bus_dati(5 downto 0) <= ccr;
                        end if;
                        if we = '1' then
                           ccr <= bus_dato(5 downto 0);
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 744
                  when "0010" =>                           -- memory system error register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-19
                     if modelcode = 44
                     or modelcode = 60
                     or modelcode = 70
                     or modelcode = 73 or modelcode = 83 or modelcode = 84 or modelcode = 93 or modelcode = 94
                     or modelcode = 53
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 742
                  when "0001" =>                           -- high error address register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-18
                     if modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     else
                        nxm <= '1';
                     end if;

-- 17 777 740
                  when "0000" =>                           -- low error address register, EK-KB11C-TM-001_1170procMan.pdf pg. VI-4-18
                     if modelcode = 70
                     then
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;
                     else
                        nxm <= '1';
                     end if;

                  when others =>
                     nxm <= '1';

               end case;

            end if;

-- f11 specific control registers

            if f11 = 1 then

               if bus_addr(17 downto 3) = o"77773" and bus_addr(2) = '1' and (bus_control_dati = '1' or bus_control_dato = '1') then
                  case bus_addr(1) is
                     when '0' =>
                        if bus_control_dati = '1' then
                           bus_dati <= mmu_lma_eub(15 downto 0);
                        end if;
                     when '1' =>
                        if bus_control_dati = '1' then
                           bus_dati <= mmu_lma_c1 & mmu_lma_c0 & "0000000" & lma_fj & mmu_lma_eub(21 downto 16);
                        end if;
                        if bus_control_dato = '1' then
                           lma_fj <= bus_dato(6);
                        end if;
                     when others =>
                  end case;
               end if;

            end if;

-- j11 specific control registers
            if j11 = 1 then

               if bus_addr(17 downto 3) = o"77773" and (bus_control_dati = '1' or bus_control_dato = '1') then

                  case bus_addr(2 downto 1) is

-- 17 777 730; diagnostic controller status register; EK-PDP94-MG-001_Sep90.pdf pg. 5-49
                     when "00" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

-- 17 777 732; diagnostic data register; EK-PDP94-MG-001_Sep90.pdf pg. 5-51
                     when "01" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

-- 17 777 734; memory configuration register; EK-PDP94-MG-001_Sep90.pdf pg. 5-48
                     when "10" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

                     when others =>

                  end case;

               end if;

               if bus_addr(17 downto 3) = o"77752" and (bus_control_dati = '1' or bus_control_dato = '1') then

                  case bus_addr(2 downto 1) is

-- 17 777 520; control/status register; EK-PDP94-MG-001_Sep90.pdf pg. 5-27
                     when "00" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

-- 17 777 522; page control register; EK-PDP94-MG-001_Sep90.pdf pg. 5-29
                     when "01" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

-- 17 777 524; configuration and display register; EK-PDP94-MG-001_Sep90.pdf pg. 5-30
                     when "10" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

-- 17 777 526; additional status register; EK-PDP94-MG-001_Sep90.pdf pg. 5-31
                     when "11" =>
                        if bus_control_dati = '1' then
                           bus_dati <= (others => '0');
                        end if;

                     when others =>

                  end case;

               end if;
            end if;



         end if;
      end if;
   end process;

end implementation;

