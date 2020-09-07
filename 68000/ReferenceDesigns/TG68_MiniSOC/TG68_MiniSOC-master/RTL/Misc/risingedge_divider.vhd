library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

-- Divide a clock, and emit a single-pulse "tick" signal
-- in the original clock domain.

entity risingedge_divider is
generic (
		divisor : integer := 1;
		bits : integer :=16
	);
port(
	clk : in std_logic;
	reset_n : in std_logic; -- Active low
	tick : out std_logic
	);
end entity;


architecture behavioural of risingedge_divider is
constant divisor_adj : integer := divisor-1;
signal counter : unsigned(bits-1 downto 0);
begin
	process(clk)
	begin
		if reset_n='0' then
			counter<=(others=>'0');
		elsif rising_edge(clk) then
			tick<='0';
			counter<=counter-1;
			if counter=0 then
				tick<='1';
				counter<=to_unsigned(divisor_adj,bits);
			end if;
		end if;
	end process;
end architecture;
