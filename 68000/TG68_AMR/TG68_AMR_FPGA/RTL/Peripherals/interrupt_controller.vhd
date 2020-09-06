library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Simple 68K interrupt controller
-- Accepts 7 individual interrupt lines.  A high pulse of at least one clock on any of these will
-- cause an interrupt condition to be stored.
-- The int_out lines are suitable for plumbing straight into TG68 or similar.
-- Interrupts are prioritised, highest number first, and asserted until acknowledged with the
-- ack signal.  However, a low-numbered interrupt won't be usurped by a higher-numbered interrupt;
-- the higher-numbered interrupt won't be asserted until the current int has been acknowledged.


entity interrupt_controller is
	port (
		clk : in std_logic;
		reset : in std_logic;
		int1 : in std_logic;
		int2 : in std_logic;
		int3 : in std_logic;
		int4 : in std_logic;
		int5 : in std_logic;
		int6 : in std_logic;
		int7 : in std_logic;
		int_out : buffer std_logic_vector(2 downto 0);
		ack : in std_logic
	);
end entity;

architecture rtl of interrupt_controller is
signal pending : std_logic_vector(6 downto 0) := "0000000";
begin

process(clk,reset)
begin

	if reset='0' then
		pending<="0000000";
		int_out<="111";
	elsif rising_edge(clk) then

		if ack='1' then
			int_out<="111";
		elsif int_out="111" then
			if pending(6)='1' then
				int_out<="000";
				pending(6)<='0';
			elsif pending(5)='1' then
				int_out<="001";
				pending(5)<='0';
			elsif pending(4)='1' then
				int_out<="010";
				pending(4)<='0';
			elsif pending(3)='1' then
				int_out<="011";
				pending(3)<='0';
			elsif pending(2)='1' then
				int_out<="100";
				pending(2)<='0';
			elsif pending(1)='1' then
				int_out<="101";
				pending(1)<='0';
			elsif pending(0)='1' then
				int_out<="110";
				pending(0)<='0';
			end if;
		end if;

		if int7='1' then
			pending(6)<='1';
		end if;
		if int6='1' then
			pending(5)<='1';
		end if;
		if int5='1' then
			pending(4)<='1';
		end if;
		if int4='1' then
			pending(3)<='1';
		end if;
		if int3='1' then
			pending(2)<='1';
		end if;
		if int2='1' then
			pending(1)<='1';
		end if;
		if int1='1' then
			pending(0)<='1';
		end if;

	end if;
end process;

end architecture;
