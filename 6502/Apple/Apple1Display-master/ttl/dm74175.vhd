library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- dm74175 Quad D-type flip-flop

entity dm74175 is

	generic(
		s3, s2, s1, s0: std_logic
	);
	port(
		cp: in std_logic;
		mr: in std_logic;
		d3, d2, d1, d0: in std_logic;
		q3, q2, q1, q0: out std_logic;
		q3_i, q2_i, q1_i, q0_i: out std_logic
	);

end dm74175;  
  
architecture behavior OF dm74175 is
signal states : std_logic_vector(3 downto 0) := s3 & s2 & s1 & s0;
begin
	
	process(cp, mr)
	begin
		if (mr = '0') then
			states <= "0000";
		elsif rising_edge(cp) then
			states <= d3 & d2 & d1 & d0;
		end if;		
	end process;
	
	(q3, q2, q1, q0) <= states;
	(q3_i, q2_i, q1_i, q0_i) <= not states;
  
end architecture;
