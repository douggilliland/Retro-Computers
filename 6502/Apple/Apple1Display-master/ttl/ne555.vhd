library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;

entity ne555 is

	port(
		clk_in: in std_logic;
		clk_out: out std_logic
	);

end ne555;
  
architecture behavior of ne555 is

signal flash_counter : std_logic_vector(5 downto 0) := "000000";
constant start_val: std_logic_vector(5 downto 0) := "101101";	-- -19
constant end_val: std_logic_vector(5 downto 0) := "001011";	-- +11
begin
	
	process (clk_in)
	begin
		if rising_edge(clk_in) then
			if flash_counter = end_val then
				flash_counter <= start_val;
			else
				flash_counter <= flash_counter + 1;
			end if;
		end if;
	end process;
	
	clk_out <= flash_counter(5);
		
end architecture;
