library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7432 Quad 2-Input OR Gates

entity dm74157 is

	port(
		enable: in std_logic;
		sel: in std_logic;
		A: in std_logic_vector(3 downto 0);
		B: in std_logic_vector(3 downto 0);
		Y: out std_logic_vector(3 downto 0)
	);

end dm74157;
  
architecture behavior OF dm74157 IS

begin

	Y(0) <= ((A(0) and not(sel)) or (B(0) and sel)) and not(enable);
	Y(1) <= ((A(1) and not(sel)) or (B(1) and sel)) and not(enable);
	Y(2) <= ((A(2) and not(sel)) or (B(2) and sel)) and not(enable);
	Y(3) <= ((A(3) and not(sel)) or (B(3) and sel)) and not(enable);
  
end architecture;
