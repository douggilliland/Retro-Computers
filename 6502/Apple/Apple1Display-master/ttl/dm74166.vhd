library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dm74166 is

	port(
		clk1, clk2: in std_logic;
		input, ld, clr_l: in std_logic;
		a, b, c, d, e, f, g, h: in std_logic;
		output: out std_logic
	);

end dm74166;
  
architecture behavior OF dm74166 is
signal Qa: std_logic := '0';
signal Qb: std_logic := '0';
signal Qc: std_logic := '0';
signal Qd: std_logic := '0';
signal Qe: std_logic := '0';
signal Qf: std_logic := '0';
signal Qg: std_logic := '0';
signal Qh: std_logic := '0';
begin
	
	process(clk1, clk2, clr_l)
	begin
		if (clr_l = '0') then
			Qa<='0'; Qb<='0'; Qc<='0'; Qd<='0'; Qe<='0'; Qf<='0'; Qg<='0'; Qh<='0'; 
		elsif rising_edge(clk1) or rising_edge(clk2) then
			if ld='0' then
				Qa<=a; Qb<=b; Qc<=c; Qd<=d; Qe<=e; Qf<=f; Qg<=g; Qh<=h; 
			else
				Qa<=input; Qb<=Qa; Qc<=Qb; Qd<=Qc; Qe<=Qd; Qf<=Qe; Qg<=Qf; Qh<=Qg; 
			end if;
		end if;		
	end process;
	
	output <= Qh when clr_l = '1'
		else '0';
		
end architecture;
