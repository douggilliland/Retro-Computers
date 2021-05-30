--------------------------------------------------------------------
-- Switch Debouncer
-- Turns Active low switch input into single "fast clock" pulse out
-- Uses "slow clock" to debounce switch (200 mS ish)
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity debounceSW is
	port(
		i_CLOCK_50					: in std_logic;
		i_slowCLK					: in std_logic;
		i_PinIn						: in std_logic;
		o_PinOut						: out std_logic
	);

end debounceSW;

architecture struct of debounceSW is
	
	signal dly1		: std_logic;
	signal dly2		: std_logic;
	signal dly3		: std_logic;
	signal dly4		: std_logic;
	signal rst_out			: std_logic;
	
begin

	process(i_CLOCK_50, i_slowCLK)
	begin
		if(rising_edge(i_CLOCK_50)) then
			if i_slowCLK = '1' then
				dly1 <= not i_PinIn;
				dly2 <= dly1 and (not i_PinIn);
			end if;
			dly3 <= dly2;
			dly4 <= dly3;
			o_PinOut <= dly4 and (not dly3);
		end if;
	end process;
end;
