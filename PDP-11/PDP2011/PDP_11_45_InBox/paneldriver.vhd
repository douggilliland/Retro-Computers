
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


entity paneldriver is
   port(
      panel_xled : out std_logic_vector(5 downto 0);
      panel_col : inout std_logic_vector(11 downto 0);
      panel_row : out std_logic_vector(2 downto 0);

      cons_load : out std_logic;
      cons_exa : out std_logic;
      cons_dep : out std_logic;
      cons_cont : out std_logic;
      cons_ena : out std_logic;
      cons_inst : out std_logic;
      cons_start : out std_logic;
      cons_sw : out std_logic_vector(21 downto 0);
      cons_adss_mode : out std_logic_vector(1 downto 0);
      cons_adss_id : out std_logic;
      cons_adss_cons : out std_logic;

      cons_consphy : in std_logic_vector(21 downto 0);
      cons_progphy : in std_logic_vector(21 downto 0);
      cons_shfr : in std_logic_vector(15 downto 0);
      cons_maddr : in std_logic_vector(15 downto 0);                 -- microcode address fpu/cpu
      cons_br : in std_logic_vector(15 downto 0);
      cons_dr : in std_logic_vector(15 downto 0);
      cons_parh : in std_logic;
      cons_parl : in std_logic;

      cons_adrserr : in std_logic;
      cons_run : in std_logic;
      cons_pause : in std_logic;
      cons_master : in std_logic;
      cons_kernel : in std_logic;
      cons_super : in std_logic;
      cons_user : in std_logic;
      cons_id : in std_logic;
      cons_map16 : in std_logic;
      cons_map18 : in std_logic;
      cons_map22 : in std_logic;

      sample_cycles : in std_logic_vector(15 downto 0) := x"0400";   -- a sample is this many runs of the panel state machine (which has 16 cycles, so multiply by that)
      minon_cycles : in std_logic_vector(15 downto 0) := x"0400";    -- if a signal has been on for this many cycles in a sample, then the corresponding output will be on - note 16, above.

      paneltype : in integer range 0 to 3 := 0;                      -- 0 - no console; 1 - PiDP11, regular; 2 - PiDP11, widdershins; 3 - PDP2011 nanocons

      cons_reset : out std_logic;                                    -- a request for a reset from the console

      clkin : in std_logic;
      reset : in std_logic
   );
end paneldriver;

architecture implementation of paneldriver is

component paneldb is
   port(
      sw : in std_logic_vector(11 downto 0);
      dsw : out std_logic_vector(11 downto 0);

      clkin : in std_logic;
      reset : in std_logic
   );
end component;

component panelos is
   port(
      sw : in std_logic;
      psw : out std_logic;

      clkin : in std_logic;
      reset : in std_logic
   );
end component;


signal counter : std_logic_vector(15 downto 0);

signal seq : integer range 0 to 15;

type adss_type is (
   adss_pp,
   adss_cp,
   adss_ki,
   adss_kd,
   adss_si,
   adss_sd,
   adss_ui,
   adss_ud
);
signal adss : adss_type;

type ddss_type is (
   ddss_dp,
   ddss_br,
   ddss_dr,
   ddss_mu
);
signal ddss : ddss_type;

signal panel_sw : std_logic_vector(21 downto 0);
signal panel_sw_test : std_logic;
signal panel_sw_load : std_logic;
signal panel_sw_exa : std_logic;
signal panel_sw_dep : std_logic;
signal panel_sw_cont : std_logic;
signal panel_sw_ena : std_logic;
signal panel_sw_inst : std_logic;
signal panel_sw_start : std_logic;


signal panel_sw_raw1 : std_logic_vector(11 downto 0);
signal panel_sw_raw2 : std_logic_vector(11 downto 0);
signal panel_sw_raw3 : std_logic_vector(11 downto 0);

signal panel_sw_deb1 : std_logic_vector(11 downto 0);
signal panel_sw_deb2 : std_logic_vector(11 downto 0);
signal panel_sw_deb3 : std_logic_vector(11 downto 0);

type rotary_type is (
   rotary_idle,
   rotary_l,
   rotary_l2,
   rotary_r,
   rotary_r2,
   rotary_reset
) ;

signal rotary1 : rotary_type := rotary_idle;
signal rotary2 : rotary_type := rotary_idle;

signal rotary1_bin : integer range 0 to 7 := 0;
signal rotary2_bin : integer range 0 to 3 := 0;

signal temp_addr : std_logic_vector(21 downto 0);
signal temp_data : std_logic_vector(15 downto 0);
signal temp_adrserr : std_logic;
signal temp_run : std_logic;
signal temp_pause : std_logic;
signal temp_master : std_logic;
signal temp_kernel : std_logic;
signal temp_super : std_logic;
signal temp_user : std_logic;
signal temp_id : std_logic;
signal temp_map16 : std_logic;
signal temp_map18 : std_logic;
signal temp_map22 : std_logic;
signal temp_parh : std_logic;
signal temp_parl : std_logic;

constant counter_size : integer := 15;
subtype counter_t is std_logic_vector(counter_size downto 0);
type addresscounter_a is array (21 downto 0) of counter_t;
signal cons_addr_counter : addresscounter_a;
type datacounter_a is array(15 downto 0) of counter_t;
signal cons_data_counter : datacounter_a;

signal cons_adrserr_counter : counter_t;
signal cons_run_counter : counter_t;
signal cons_pause_counter : counter_t;
signal cons_master_counter : counter_t;
signal cons_kernel_counter : counter_t;
signal cons_super_counter : counter_t;
signal cons_user_counter : counter_t;
signal cons_id_counter : counter_t;
signal cons_map16_counter : counter_t;
signal cons_map18_counter : counter_t;
signal cons_map22_counter : counter_t;
signal cons_parh_counter : counter_t;
signal cons_parl_counter : counter_t;


begin

   db1: paneldb port map(
      sw => panel_sw_raw1,
      dsw => panel_sw_deb1,
      clkin => clkin,
      reset => reset
   );
   db2: paneldb port map(
      sw => panel_sw_raw2,
      dsw => panel_sw_deb2,
      clkin => clkin,
      reset => reset
   );
   db3: paneldb port map(
      sw => panel_sw_raw3,
      dsw => panel_sw_deb3,
      clkin => clkin,
      reset => reset
   );

   cons_sw(11 downto 0) <= panel_sw_deb1;
   cons_sw(21 downto 12) <= panel_sw_deb2(9 downto 0);

   panel_sw_test <= not panel_sw_deb3(0) when (paneltype = 1 or paneltype = 2)
      else panel_sw_deb3(0) when paneltype = 3
      else '0';
   panel_sw_load <= '0' when paneltype = 0
      else panel_sw_deb3(1);
   panel_sw_exa <= '0' when paneltype = 0
      else panel_sw_deb3(2);
   panel_sw_dep <= '0' when paneltype = 0
      else panel_sw_deb3(3);
   panel_sw_cont <= '0' when paneltype = 0
      else panel_sw_deb3(4);
   panel_sw_ena <= '1' when paneltype = 0
      else not panel_sw_deb3(5);
   panel_sw_inst <= '0' when paneltype = 0
      else panel_sw_deb3(6);
   panel_sw_start <= '0' when paneltype = 0
      else panel_sw_deb3(7);

   cons_reset <= '1' when (panel_sw_deb3(9) = '1' and panel_sw_deb3(8) = '1' and paneltype = 3)
      else '1' when ((paneltype = 1 or paneltype = 2) and (panel_sw_deb2(10) = '1' and panel_sw_deb2(11) = '1'))
      else '0';

   cons_ena <= panel_sw_ena;
   cons_inst <= panel_sw_inst;

   pl_load: panelos port map(
      sw => panel_sw_load,
      psw => cons_load,
      clkin => clkin,
      reset => reset
   );
   pl_exa: panelos port map(
      sw => panel_sw_exa,
      psw => cons_exa,
      clkin => clkin,
      reset => reset
   );
   pl_dep: panelos port map(
      sw => panel_sw_dep,
      psw => cons_dep,
      clkin => clkin,
      reset => reset
   );
   pl_cont: panelos port map(
      sw => panel_sw_cont,
      psw => cons_cont,
      clkin => clkin,
      reset => reset
   );
   pl_start: panelos port map(
      sw => panel_sw_start,
      psw => cons_start,
      clkin => clkin,
      reset => reset
   );

   process(clkin, reset)
   begin
      if clkin = '1' and clkin'event then
         if reset = '1' then
            counter <= (others => '1');                              -- causes the counter overflow to happen soon, so that'll take care of resetting all the counters
            seq <= 0;
         else

            if paneltype /= 0 then
               counter <= counter + 1;

               p1: for i in 0 to 21 loop
                  if adss = adss_pp then
                     if cons_progphy(i) = '1' then
                        cons_addr_counter(i) <= cons_addr_counter(i) + 1;
                     end if;
                  else
                     if cons_consphy(i) = '1' then
                        cons_addr_counter(i) <= cons_addr_counter(i) + 1;
                     end if;
                  end if;
               end loop p1;
               p2: for i in 0 to 15 loop
                  if (cons_shfr(i) = '1' and ddss = ddss_dp)
                  or (cons_br(i) = '1' and ddss = ddss_br)
                  or (cons_dr(i) = '1' and ddss = ddss_dr)
                  or (cons_maddr(i) = '1' and ddss = ddss_mu)
                  then
                     cons_data_counter(i) <= cons_data_counter(i) + 1;
                  end if;
               end loop p2;

               if cons_adrserr = '1' then
                  cons_adrserr_counter <= cons_adrserr_counter + 1;
               end if;
               if cons_run = '1' then
                  cons_run_counter <= cons_run_counter + 1;
               end if;
               if cons_pause = '1' then
                  cons_pause_counter <= cons_pause_counter + 1;
               end if;
               if cons_master = '1' then
                  cons_master_counter <= cons_master_counter + 1;
               end if;
               if cons_kernel = '1' then
                  cons_kernel_counter <= cons_kernel_counter + 1;
               end if;
               if cons_super = '1' then
                  cons_super_counter <= cons_super_counter + 1;
               end if;
               if cons_user = '1' then
                  cons_user_counter <= cons_user_counter + 1;
               end if;
               if cons_id = '1' then
                  cons_id_counter <= cons_id_counter + 1;
               end if;
               if cons_map16 = '1' then
                  cons_map16_counter <= cons_map16_counter + 1;
               end if;
               if cons_map18 = '1' then
                  cons_map18_counter <= cons_map18_counter + 1;
               end if;
               if cons_map22 = '1' then
                  cons_map22_counter <= cons_map22_counter + 1;
               end if;
               if cons_parh = '1' then
                  cons_parh_counter <= cons_parh_counter + 1;
               end if;
               if cons_parl = '1' then
                  cons_parl_counter <= cons_parl_counter + 1;
               end if;

               if not (counter < sample_cycles) then
                  counter <= (others => '0');

                  if seq = 0 then
                     c1: for i in 0 to 21 loop
                        if unsigned(cons_addr_counter(i)) > unsigned(minon_cycles(counter_size downto 0)) then
                           temp_addr(i) <= '1';
                        else
                           temp_addr(i) <= '0';
                        end if;
                     end loop c1;
                     c2: for i in 0 to 15 loop
                        if unsigned(cons_data_counter(i)) > unsigned(minon_cycles(counter_size downto 0)) then
                           temp_data(i) <= '1';
                        else
                           temp_data(i) <= '0';
                        end if;
                     end loop c2;

                     if unsigned(cons_adrserr_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_adrserr <= '1';
                     else
                        temp_adrserr <= '0';
                     end if;
                     if unsigned(cons_run_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_run <= '1';
                     else
                        temp_run<= '0';
                     end if;
                     if unsigned(cons_pause_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_pause <= '1';
                     else
                        temp_pause <= '0';
                     end if;
                     if unsigned(cons_master_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_master <= '1';
                     else
                        temp_master <= '0';
                     end if;
                     if unsigned(cons_kernel_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_kernel <= '1';
                     else
                        temp_kernel <= '0';
                     end if;
                     if unsigned(cons_super_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_super <= '1';
                     else
                        temp_super <= '0';
                     end if;
                     if unsigned(cons_user_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_user <= '1';
                     else
                        temp_user <= '0';
                     end if;
                     if unsigned(cons_id_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_id <= '1';
                     else
                        temp_id <= '0';
                     end if;
                     if unsigned(cons_map16_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_map16 <= '1';
                     else
                        temp_map16 <= '0';
                     end if;
                     if unsigned(cons_map18_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_map18 <= '1';
                     else
                        temp_map18 <= '0';
                     end if;
                     if unsigned(cons_map22_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_map22 <= '1';
                     else
                        temp_map22 <= '0';
                     end if;
                     if unsigned(cons_parh_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_parh <= '1';
                     else
                        temp_parh <= '0';
                     end if;
                     if unsigned(cons_parl_counter) > unsigned(minon_cycles(counter_size downto 0)) then
                        temp_parl <= '1';
                     else
                        temp_parl <= '0';
                     end if;

                     r1: for i in 0 to 21 loop
                        cons_addr_counter(i) <= (others => '0');
                     end loop r1;
                     r2 : for i in 0 to 15 loop
                        cons_data_counter(i) <= (others => '0');
                     end loop r2;
                     cons_adrserr_counter <= (others => '0');
                     cons_run_counter <= (others => '0');
                     cons_pause_counter <= (others => '0');
                     cons_master_counter <= (others => '0');
                     cons_kernel_counter <= (others => '0');
                     cons_super_counter <= (others => '0');
                     cons_user_counter <= (others => '0');
                     cons_id_counter <= (others => '0');
                     cons_map16_counter <= (others => '0');
                     cons_map18_counter <= (others => '0');
                     cons_map22_counter <= (others => '0');
                     cons_parh_counter <= (others => '0');
                     cons_parl_counter <= (others => '0');

                  end if;

                  seq <= seq + 1;
                  if seq = 15 then
                     seq <= 0;
                  end if;

                  case seq is
                     when 0 =>
                        panel_xled <= "000001";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col <= not temp_addr(11 downto 0);
                        end if;

                     when 1 =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";

                     when 2 =>
                        panel_xled <= "000010";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col(11 downto 10) <= "11";
                           panel_col(9 downto 0) <= not temp_addr(21 downto 12);
                        end if;

                     when 3 =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";

                     when 4 =>
                        panel_xled <= "000100";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col <= "1" & not temp_adrserr & not temp_run & not temp_pause & not temp_master & not temp_user & not temp_super & not temp_kernel & not temp_id & not temp_map16 & not temp_map18 & not temp_map22;
                        end if;

                     when 5 =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";

                     when 6 =>
                        panel_xled <= "001000";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col <= not temp_data(11 downto 0);
                        end if;

                     when 7 =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";

                     when 8 =>
                        panel_xled <= "010000";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col(3 downto 0) <= not temp_data(15 downto 12);

                           panel_col(11 downto 6) <= "111111";
                           if ddss = ddss_br then
                              panel_col(11) <= '0';
                           end if;
                           if ddss = ddss_dp then
                              panel_col(10) <= '0';
                           end if;
                           if adss = adss_cp then
                              panel_col(9) <= '0';
                           end if;
                           if adss = adss_kd then
                              panel_col(8) <= '0';
                           end if;
                           if adss = adss_sd then
                              panel_col(7) <= '0';
                           end if;
                           if adss = adss_ud then
                              panel_col(6) <= '0';
                           end if;

                           panel_col(5) <= cons_parh;
                           panel_col(4) <= cons_parl;
                        end if;

                     when 9 =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";

                     when 10 =>
                        panel_xled <= "100000";
                        if panel_sw_test = '1' then
                           panel_col <= "000000000000";
                        else
                           panel_col <= "111111111111";
                           if ddss = ddss_dr then
                              panel_col(11) <= '0';
                           end if;
                           if ddss = ddss_mu then
                              panel_col(10) <= '0';
                           end if;
                           if adss = adss_pp then
                              panel_col(9) <= '0';
                           end if;
                           if adss = adss_ki then
                              panel_col(8) <= '0';
                           end if;
                           if adss = adss_si then
                              panel_col(7) <= '0';
                           end if;
                           if adss = adss_ui then
                              panel_col(6) <= '0';
                           end if;
                        end if;


                     when 11 =>
                        panel_xled <= "000000";
                        panel_col <= "ZZZZZZZZZZZZ";
                        panel_row <= "111";

                     when 12 =>
                        panel_row <= "110";

                     when 13 =>
                        panel_row <= "101";
                        panel_sw_raw1 <= not panel_col;

                     when 14 =>
                        panel_row <= "011";
                        panel_sw_raw2 <= not panel_col;

                     when 15 =>
                        panel_row <= "111";
                        panel_sw_raw3 <= not panel_col;


                     when others =>
                        panel_xled <= "000000";
                        panel_col <= "111111111111";
                        seq <= 0;

                  end case;

               end if;

               if paneltype = 1 or paneltype = 2 then
                  case rotary1 is
                     when rotary_idle =>
                        if panel_sw_deb3(9) = '1' then
                           rotary1 <= rotary_l;
                        end if;
                        if panel_sw_deb3(8) = '1' then
                           rotary1 <= rotary_r;
                        end if;
                     when rotary_l =>
                        if panel_sw_deb3(9) = '1' then
                           rotary1 <= rotary_l2;
                        end if;
                     when rotary_l2 =>
                        if panel_sw_deb3(8) = '0' and panel_sw_deb3(9) = '0' then
                           rotary1 <= rotary_idle;
                           if paneltype = 1 then
                              rotary1_bin <= rotary1_bin - 1;
                           end if;
                           if paneltype = 2 then
                              rotary1_bin <= rotary1_bin + 1;
                           end if;
                        end if;
                     when rotary_r =>
                        if panel_sw_deb3(9) = '1' then
                           rotary1 <= rotary_r2;
                        end if;
                     when rotary_r2 =>
                        if panel_sw_deb3(8) = '0' and panel_sw_deb3(9) = '0' then
                           rotary1 <= rotary_idle;
                           if paneltype = 1 then
                              rotary1_bin <= rotary1_bin + 1;
                           end if;
                           if paneltype = 2 then
                              rotary1_bin <= rotary1_bin - 1;
                           end if;
                        end if;
                     when others =>
                        null;
                  end case;
               elsif paneltype = 3 then
                  case rotary1 is
                     when rotary_idle =>
                        if panel_sw_deb3(9) = '1' then
                           rotary1 <= rotary_r2;
                        end if;
                     when rotary_r2 =>
                        if panel_sw_deb3(8) = '1' then
                           rotary1 <= rotary_reset;
                        end if;
                        if panel_sw_deb3(9) = '0' then
                           rotary1_bin <= rotary1_bin + 1;
                           rotary1 <= rotary_idle;
                        end if;
                     when rotary_reset =>
                        if panel_sw_deb3(8) = '0' and panel_sw_deb3(9) = '0' then
                           rotary1 <= rotary_idle;
                        end if;
                     when others =>
                        rotary1 <= rotary_idle;
                  end case;
               end if;

               case rotary1_bin is
                  when 0 =>
                     adss <= adss_pp;
                     cons_adss_cons <= '0'; cons_adss_mode <= "00"; cons_adss_id <= '0';
                  when 1 =>
                     adss <= adss_cp;
                     cons_adss_cons <= '1'; cons_adss_mode <= "00"; cons_adss_id <= '0';
                  when 2 =>
                     adss <= adss_kd;
                     cons_adss_cons <= '0'; cons_adss_mode <= "00"; cons_adss_id <= '1';
                  when 3 =>
                     adss <= adss_sd;
                     cons_adss_cons <= '0'; cons_adss_mode <= "01"; cons_adss_id <= '1';
                  when 4 =>
                     adss <= adss_ud;
                     cons_adss_cons <= '0'; cons_adss_mode <= "11"; cons_adss_id <= '1';
                  when 5 =>
                     adss <= adss_ui;
                     cons_adss_cons <= '0'; cons_adss_mode <= "11"; cons_adss_id <= '0';
                  when 6 =>
                     adss <= adss_si;
                     cons_adss_cons <= '0'; cons_adss_mode <= "01"; cons_adss_id <= '0';
                  when 7 =>
                     adss <= adss_ki;
                     cons_adss_cons <= '0'; cons_adss_mode <= "00"; cons_adss_id <= '0';
               end case;

               if paneltype = 1 or paneltype = 2 then
                  case rotary2 is
                     when rotary_idle =>
                        if panel_sw_deb3(11) = '1' then
                           rotary2 <= rotary_l;
                        end if;
                        if panel_sw_deb3(10) = '1' then
                           rotary2 <= rotary_r;
                        end if;
                     when rotary_l =>
                        if panel_sw_deb3(10) = '1' then
                           rotary2 <= rotary_l2;
                        end if;
                     when rotary_l2 =>
                        if panel_sw_deb3(10) = '0' and panel_sw_deb3(11) = '0' then
                           rotary2 <= rotary_idle;
                           if paneltype = 1 then
                              rotary2_bin <= rotary2_bin - 1;
                           end if;
                           if paneltype = 2 then
                              rotary2_bin <= rotary2_bin + 1;
                           end if;
                        end if;
                     when rotary_r =>
                        if panel_sw_deb3(11) = '1' then
                           rotary2 <= rotary_r2;
                        end if;
                     when rotary_r2 =>
                        if panel_sw_deb3(10) = '0' and panel_sw_deb3(11) = '0' then
                           rotary2 <= rotary_idle;
                           if paneltype = 1 then
                              rotary2_bin <= rotary2_bin + 1;
                           end if;
                           if paneltype = 2 then
                              rotary2_bin <= rotary2_bin - 1;
                           end if;
                        end if;
                     when others =>
                        null;
                  end case;
               elsif paneltype = 3 then
                  case rotary2 is
                     when rotary_idle =>
                        if panel_sw_deb3(8) = '1' then
                           rotary2 <= rotary_r2;
                        end if;
                     when rotary_r2 =>
                        if panel_sw_deb3(9) = '1' then
                           rotary2 <= rotary_reset;
                        end if;
                        if panel_sw_deb3(8) = '0' then
                           rotary2_bin <= rotary2_bin + 1;
                           rotary2 <= rotary_idle;
                        end if;
                     when rotary_reset =>
                        if panel_sw_deb3(8) = '0' and panel_sw_deb3(9) = '0' then
                           rotary2 <= rotary_idle;
                        end if;
                     when others =>
                        rotary2 <= rotary_idle;
                  end case;
               end if;

               case rotary2_bin is
                  when 0 => ddss <= ddss_dp;
                  when 1 => ddss <= ddss_mu;
                  when 2 => ddss <= ddss_dr;
                  when 3 => ddss <= ddss_br;
               end case;

            else
               panel_col <= (others => '0');
               panel_xled <= (others => '0');
               panel_row <= (others => '0');
            end if;
         end if;
      end if;
   end process;

end implementation;
