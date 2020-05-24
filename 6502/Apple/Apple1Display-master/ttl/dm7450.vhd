library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7450 Dual 2-wide 2-input and-or-invert gates

entity dm7450 is

	port(
		A1, B1, C1, D1,
		A2, B2, C2, D2: in std_logic := '0';
		X1: in std_logic := '1';
		X1_l: in std_logic := '0';
		Y1, Y2: out std_logic
	);

end dm7450;
  
architecture behavior OF dm7450 IS
begin

	Y1 <=	'Z' when (X1 = '0') or (X1_l = '1') else
			(A1 and B1) nor (C1 and D1);
	
	Y2 <= (A2 and B2) nor (C2 and D2);
  
end architecture;
