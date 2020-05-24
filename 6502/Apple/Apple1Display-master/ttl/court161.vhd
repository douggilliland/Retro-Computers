library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dm74161b is

	port(
		clk: in std_logic; clr_l: in std_logic; load_l: in std_logic; cet: in std_logic; cep: in std_logic;
		d3, d2, d1, d0: in std_logic;
		q3, q2, q1, q0: out std_logic;
		carry: out std_logic
	);

end dm74161b;  
  
architecture behavior OF dm74161b is
constant MAX_COUNT: std_logic_vector(3 downto 0) := "0011";
signal count: std_logic_vector(3 downto 0) := "0000";
begin
	
	process(clk, clr_l)
	begin
		if (clr_l = '0') then
			count <= "0000";	-- reset
		elsif rising_edge(clk) then	-- clk rising edge			
			if (count = MAX_COUNT) then
				count <= "0000";	-- overflow
			else
				count <= count + 1;	-- inc
			end if;
		end if;
	end process;
	
	(q3, q2, q1, q0) <= count;
	carry <= cet when (count = MAX_COUNT)
		else '0';
	     
end architecture;

