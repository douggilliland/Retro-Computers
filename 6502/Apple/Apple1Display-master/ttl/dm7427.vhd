library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7427 Triple 3-Input NOR Gate

entity dm7427 is

	port(
		A1, A2, A3,
		B1, B2, B3,
		C1, C2, C3: in std_logic := '0';
		Y1, Y2, Y3: out std_logic
	);

end dm7427;  

architecture behavior OF dm7427 IS
begin

	Y1 <= not (A1 or B1 or C1);
	Y2 <= not (A2 or B2 or C2);
	Y3 <= not (A3 or B3 or C3);
  
end architecture;
