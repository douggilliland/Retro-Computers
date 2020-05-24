library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ttl2519 40-bit static shift register

entity ttl2519 is

	port(
		cl: in std_logic;
		rc: in std_logic;
		i: in std_logic_vector(5 downto 0);
		q: out std_logic_vector(5 downto 0)
	);

end ttl2519;
  
architecture behavior OF ttl2519 is
signal cur : std_logic_vector(5 downto 0);
signal input : std_logic_vector(5 downto 0);
begin
	
	LineBuffer : entity ShiftReg40
	port map(
		Din => input,
        Clock => cl,
        ClockEn => '1',
        Reset => '0',
        Q => cur
	);
	
	q <= cur;
	input <= cur when rc = '1'
		else i;

end architecture;
