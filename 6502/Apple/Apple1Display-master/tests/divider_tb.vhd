library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divider_tb is
	
	port(output: out std_logic);

end divider_tb;

architecture behavior OF divider_tb IS
signal clk : std_logic := '0';
begin
	
	dut: entity work.divider
	generic map(div => 14)
	port map(
		input => clk,
		output => output
		);
  
	process
	begin
		clk <= '0';
		wait for 1ns;
		clk <= '1';
		wait for 1ns;		
	end process;
	
end architecture;
