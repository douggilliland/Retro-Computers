library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dm74161 is

	port(
		clk: in std_logic; clr_l: in std_logic; load_l: in std_logic; cet: in std_logic; cep: in std_logic;
		d3, d2, d1, d0: in std_logic;
		q3, q2, q1, q0: out std_logic;
		carry: out std_logic
	);

end dm74161;
  
architecture behavior OF dm74161 is
constant ZERO : std_logic_vector(3 downto 0) := "0000";
constant MAX_COUNT: std_logic_vector(3 downto 0) := "1111";
signal count: std_logic_vector(3 downto 0) := "0000";
begin
	
	process(clk, clr_l, load_l, cep, cet)
	begin
		if (clr_l = '0') then
			count <= ZERO;	-- reset
		elsif rising_edge(clk) then	-- clk rising edge			
			if (load_l = '0') then
				count <= d3 & d2 & d1 & d0;	-- load
			elsif (cep = '1') and (cet='1') then
				if (count = MAX_COUNT) then
					count <= ZERO;	-- overflow
				else
					count <= count + 1;	-- inc
				end if;
			end if;
		end if;		
	end process;
	
	(q3, q2, q1, q0) <= std_logic_vector'(ZERO) when clr_l = '0'
		else count;
	carry <= cet when (count = MAX_COUNT) and (clr_l = '1')
		else '0';
		
end architecture;
