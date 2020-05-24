library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7404 Hex Inverting Gates

entity dm7404 is

	port(
		A1, A2, A3, A4, A5, A6: in std_logic := '0';
		Y1, Y2, Y3, Y4, Y5, Y6: out std_logic
	);

end dm7404;
  
architecture behavior OF dm7404 IS
begin

	Y1 <= not A1;
	Y2 <= not A2;
	Y3 <= not A3;
	Y4 <= not A4;
	Y5 <= not A5;
	Y6 <= not A6;
  
end architecture;

