library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7408 Quad 2-Input AND Gates

entity dm7408 is

	port(
		A1, B1, A2, B2, A3, B3, A4, B4: in std_logic := '0';
		Y1, Y2, Y3, Y4: out std_logic
	);

end dm7408;
  
architecture behavior OF dm7408 IS
begin

	Y1 <= A1 and B1;
	Y2 <= A2 and B2;
	Y3 <= A3 and B3;
	Y4 <= A4 and B4;
  
end architecture;
