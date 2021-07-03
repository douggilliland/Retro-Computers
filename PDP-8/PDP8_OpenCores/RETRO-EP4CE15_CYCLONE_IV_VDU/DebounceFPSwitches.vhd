--

library ieee;
use ieee.std_logic_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity debouncePBSWitches is
	port(
		i_CLOCK_50			: in std_logic;								-- FPGA Clock (50 MHz)
		i_InPins				: in std_logic_vector(5 downto 0);		-- Ins
		o_OutPins			: out std_logic_vector(5 downto 0)		-- Outs - Active High Pulse
	);
end debouncePBSWitches;

architecture struct of debouncePBSWitches is
	
	-- Front Panel SWitch debouncing
	signal deb_counter	: std_logic_vector (19 downto 0) := (others => '0');
	signal pulse20ms		: std_logic;

begin

	-- 20 mS counter
	-- 2^20 = 1M 000, 50M/1M = 50 Hz  = 20 mS ticks
	-- Used for prescaling pushbuttons
	-- pulse20ms = single 20 nS clock pulse every 20 mSecs
	----------------------------------------------------------------------------
	process (i_CLOCK_50) begin
		if rising_edge(i_CLOCK_50) then
			deb_counter <= deb_counter+1;
			if deb_counter = 0 then
				pulse20ms <= '1';
			else
				pulse20ms <= '0';
			end if;
		end if;
	end process;
	
	debounceSw5 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(5),
		o_PinOut		=> o_OutPins(5)
	);
	

	debounceSw4 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(4),
		o_PinOut		=> o_OutPins(4)
	);
	

	debounceSw3 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(3),
		o_PinOut		=> o_OutPins(3)
	);
	

	debounceSw2 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(2),
		o_PinOut		=> o_OutPins(2)
	);
	

	debounceSw1 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(1),
		o_PinOut		=> o_OutPins(1)
	);
	

	debounceSw0 : entity work.debounceSW
	port map (
		i_CLOCK_50	=> i_CLOCK_50,
		i_slowCLK	=> pulse20ms,
		i_PinIn		=> i_InPins(0),
		o_PinOut		=> o_OutPins(0)
	);

end;
