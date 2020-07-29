library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ShiftReg40_tb is
end ShiftReg40_tb;

architecture behavior OF ShiftReg40_tb is
	
	constant freq: natural := 14_318_180;
	constant period: time := 1 sec / FREQ;
	
	signal clk: std_logic;
	signal q: std_logic_vector(5 downto 0);

begin
	
	dut: entity ShiftReg40
		port map (
			Din(5 downto 0)=> q,
			Clock=> clk,
			ClockEn=> '1',
			Reset=> '0',
			Q(5 downto 0)=> q
		);
		
		process	
		begin
			
			clk <= '0';
			wait for period/2;
			clk <= '1';
			wait for period/2;
			
		end process;
	
end architecture;
