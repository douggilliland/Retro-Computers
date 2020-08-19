library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

entity main_tb is
end main_tb;

architecture structural of main_tb is

   -- Clock
   signal main_clk  : std_logic;
   signal reset : std_logic := '0' ;
   signal txd: std_logic := '0';
   signal rxd: std_logic := '0';
      signal rts: std_logic := '0';
      
    
begin
   
   --------------------------------------------------
   -- Generate clock
   --------------------------------------------------

   -- Generate clock
   main_clk_proc : process
   begin
      main_clk <= '1', '0' after 5 ns; -- 100 MHz
      wait for 10 ns;
   end process main_clk_proc;

   --------------------------------------------------
   -- Instantiate MAIN
   --------------------------------------------------

   main_inst : entity work.multicomp_wrapper

   port map (
        sys_clock => main_clk,
        reset => reset,
		videoR0	=> open,
		videoG0	=> open,
		videoB0	=> open,
		videoR1	=> open,
		videoG1 => open,
		videoB1 => open,
		hSync	=> open,
		vSync	=> open,

		ps2Clk	=> open,
		ps2Data	=> open,
		rxd1 => rxd,
		txd1 => txd,
		rts1 => rts
   ); -- main_inst
   
end architecture structural;

