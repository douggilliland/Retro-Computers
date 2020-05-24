library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7400 Quad 2-Input NAND Gate

entity dm7400 is

	port(
		A1, B1, A2, B2, A3, B3, A4, B4: in std_logic := '0';
		Y1, Y2, Y3, Y4: out std_logic
	);

end dm7400;  
  
architecture behavior of dm7400 is
begin

	Y1 <= A1 nand B1;
	Y2 <= A2 nand B2;
	Y3 <= A3 nand B3;
	Y4 <= A4 nand B4;
  
end architecture;
