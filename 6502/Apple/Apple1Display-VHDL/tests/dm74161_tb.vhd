library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dm74161_tb is
end dm74161_tb;
  
architecture behavior OF dm74161_tb is

type test_state is (init, counting, load, cet_inhibit, cep_inhibit, finished);

signal clk, clr_l, load_l, cet, cep: std_logic;
signal d:std_logic_vector(3 downto 0);
signal q:std_logic_vector(3 downto 0);
signal carry: std_logic;
signal state: test_state;

begin
	
	dut: entity work.dm74161
	port map(
		clk => clk, clr_l => clr_l, load_l => load_l, cet => cet, cep => cep,
		d3=>d(3), d2=>d(2), d1=>d(1), d0=>d(0),
		q3=>q(3), q2=>q(2), q1=>q(1), q0=>q(0),
		carry => carry
	);
  
	process	
	begin
		-- init
		state <= init;
		clk <= '0';
		clr_l <= '1';
		load_l <= '1';
		cet <= '1';
		cep <= '1';
		d <= "0000";
		wait for 1ns;
		
		-- count to 16
		state <= counting;
		for ii in 1 to 3 loop
			clk <= '1';
			wait for 1ns;
			clk <= '0';
			wait for 1ns;
		end loop;
		
		-- load
		state <= load;
		d <= "1110";
		load_l <= '0';
		clk <= '1';
		wait for 1ns;
		load_l <= '1';
		clk <= '0';
		wait for 1ns;
		
		-- cet inhibit
		state <= cet_inhibit;
		cet <= '0';
		for ii in 1 to 3 loop
			clk <= '1';
			wait for 1ns;
			clk <= '1';
			wait for 1ns;
		end loop;
		cet <= '1';
		
		-- cep inhibit
		state <= cep_inhibit;
		cep <= '0';
		for ii in 1 to 3 loop
			clk <= '1';
			wait for 1ns;
			clk <= '0';
			wait for 1ns;
		end loop;
		cep <= '1';
		
		-- all done
		state <= finished;
		wait;
		
	end process;
   
end architecture;
