-- LED-SWITCHES-2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LEDSWITCHES2 is
   port(
		i_SS				: in std_logic_vector(7 downto 0);
		i_PB				: in std_logic_vector(7 downto 0);
		o_LED				: OUT std_logic_vector(7 downto 0)
  );
end LEDSWITCHES2;

architecture implementation of LEDSWITCHES2 is

	signal w_outVal	: std_logic_vector(7 downto 0);


begin

	w_outVal <= i_SS xor i_PB;
	o_LED <= w_outVal;
 
end implementation;
