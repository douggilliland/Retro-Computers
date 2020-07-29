library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- dm74174 Hex D-type flip-flop

entity dm74174 is

	generic(
		s5: std_logic:='0';
		s4: std_logic:='0';
		s3: std_logic:='0';
		s2: std_logic:='0';
		s1: std_logic:='0';
		s0: std_logic:='0'
	);
	port(
		cp: in std_logic;
		mr: in std_logic;
		d5, d4, d3, d2, d1, d0: in std_logic;
		q5, q4, q3, q2, q1, q0: out std_logic;
		q5_i, q4_i, q3_i, q2_i, q1_i, q0_i: out std_logic
	);

end dm74174;
  
architecture behavior OF dm74174 is
signal states : std_logic_vector(5 downto 0) := s5 & s4 & s3 & s2 & s1 & s0;
begin
	
	process(cp, mr)
	begin
		if (mr = '0') then
			states <= "000000";
		elsif rising_edge(cp) then
			states <= d5 & d4 & d3 & d2 & d1 & d0;
		end if;		
	end process;
	
	(q5, q4, q3, q2, q1, q0) <= states;
	(q5_i, q4_i, q3_i, q2_i, q1_i, q0_i) <= not states;
  
end architecture;
