library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_entity is

	port(
		clk: in std_logic;
		clr: in std_logic;
		q: out std_logic_vector(3 downto 0)
	);

end test_entity;
  
	architecture behavior OF test_entity is
	signal count: std_logic_vector(3 downto 0) := "0000";
	begin
		
		process(clk, clr)
		begin
			if (clr='1') then
				count <= "0000";
			elsif rising_edge(clk) then
				count <= count + 1;
			end if;		
		end process;
		
		q <= count;
			
	end architecture;
