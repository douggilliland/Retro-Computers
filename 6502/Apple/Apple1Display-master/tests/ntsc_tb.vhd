											  library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ntsc_tb is
end ntsc_tb;
  
architecture behavior OF ntsc_tb is
signal clk: std_logic;
signal ntsc: std_logic_vector(3 downto 0);
constant freq: natural := 14_318_180;
constant period: time := 1 sec / FREQ;

begin
	
	dut: entity work.ntsc
	port map(
		clk => clk,
		ntsc => ntsc
	);
  
	process	
	begin
		clk <= '0';
		wait for period;
		clk <= '1';
		wait for period;
	end process;
	
end architecture;


