library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7410 Triple 3-Input NAND Gates

entity dm7410 is

	port(
		A1, A2, A3,
		B1, B2, B3,
		C1, C2, C3: in std_logic := '0';
		Y1, Y2, Y3: out std_logic
	);

end dm7410;
  
architecture behavior OF dm7410 IS
begin

	Y1 <= not (A1 and B1 and C1);
	Y2 <= not (A2 and B2 and C2);
	Y3 <= not (A3 and B3 and C3);
  
end architecture;
