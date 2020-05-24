library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7432 Quad 2-Input OR Gates

entity dm7432 is

	port(
		A1, B1, A2, B2, A3, B3, A4, B4: in std_logic := '0';
		Y1, Y2, Y3, Y4: out std_logic
	);

end dm7432;
  
architecture behavior OF dm7432 IS
begin

	Y1 <= A1 or B1;
	Y2 <= A2 or B2;
	Y3 <= A3 or B3;
	Y4 <= A4 or B4;
  
end architecture;
