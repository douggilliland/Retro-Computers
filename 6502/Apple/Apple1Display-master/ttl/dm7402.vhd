library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7402 Quad 2-Input NOR Gates

entity dm7402 is

	port(
		A1, B1, A2, B2, A3, B3, A4, B4: in std_logic := '0';
		Y1, Y2, Y3, Y4: out std_logic
	);

end dm7402;  
  
architecture behavior OF dm7402 IS
begin
			
	Y1 <= A1 nor B1;
	Y2 <= A2 nor B2;
	Y3 <= A3 nor B3;
	Y4 <= A4 nor B4;
   
end architecture;
