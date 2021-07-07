-- LED-SWITCHES-2

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LEDSWITCHES2 is
   port(
		-- Clock, reset
		i_clk				: in std_logic;
		i_resetN			: in std_logic;
		-- Switches and PEDs
		i_SS				: in std_logic_vector(8 downto 1);
		i_PB				: in std_logic_vector(8 downto 1);
		o_LED				: OUT std_logic_vector(8 downto 1)
  );
end LEDSWITCHES2;

architecture implementation of LEDSWITCHES2 is

	signal w_outVal	: std_logic_vector(7 downto 0);

begin

	latchSwitches : process ( i_clk )
	begin
		if rising_edge(i_clk) then
			w_outVal <= i_SS xor i_PB;
			o_LED <= w_outVal;
		end if;
	end process;
 
end implementation;
