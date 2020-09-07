library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;


entity cascade_timer is
	port (
		clk : in std_logic;
		reset : in std_logic;
		setdiv : in std_logic;
		divisor : in std_logic_vector(2 downto 0);
		divin : in unsigned(15 downto 0);
		trigger : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of cascade_timer is

signal divisor0 : unsigned(15 downto 0);
signal divisor1 : unsigned(15 downto 0);
signal divisor2 : unsigned(15 downto 0);
signal divisor3 : unsigned(15 downto 0);
signal divisor7 : unsigned(15 downto 0);	-- Clock 7 is based on sysclk, not clock 0

signal counter0 : unsigned(15 downto 0);
signal counter1 : unsigned(15 downto 0);
signal counter2 : unsigned(15 downto 0);
signal counter3 : unsigned(15 downto 0);
signal counter4 : unsigned(15 downto 0);	-- Clocks 4 and 5 are one-shot delays.
signal counter5 : unsigned(15 downto 0);
signal counter6 : unsigned(15 downto 0);
signal counter7 : unsigned(15 downto 0);

begin

	process(clk)
	begin
		if reset='0' then
			divisor0<=X"2710"; -- 10KHz @ 100 MHz sysclock
			divisor1<=X"0064"; -- 100Hz
			divisor2<=X"0064"; -- 100Hz
			divisor3<=X"0064"; -- 100Hz
									 -- 4 to 6 are one-shot so don't need to store the divisor.
			divisor7<=X"0100"; -- ~400KHz @ 100MHz sysclk
			counter0<=X"0000";
			counter1<=X"0000";
			counter2<=X"0000";
			counter3<=X"0000";
			counter4<=X"0000"; -- One-shot, inactive
			counter5<=X"0000";
			counter6<=X"0000";
			counter7<=X"0000";
		elsif rising_edge(clk) then
			if setdiv='1' then
				case divisor is
					when "000" =>
						divisor0<=divin;
						counter0<=divin;
					when "001" =>
						divisor1<=divin;
						counter1<=divin;
					when "010" =>
						divisor2<=divin;
						counter2<=divin;
					when "011" =>
						divisor3<=divin;
						counter3<=divin;
					when "100" =>	-- One-shot
						counter4<=divin;
					when "101" =>	-- One-shot
						counter5<=divin;
					when "110" =>	-- One-shot
						counter6<=divin;
					when "111" =>	-- SD / SPI
						divisor7<=divin;
						counter7<=divin;
					when others =>
						null;
				end case;
			end if;
			
			trigger<="00000000";

			counter0<=counter0-1;
			
			if counter0 = 0 then
				counter0 <= divisor0;
				
				counter1<=counter1-1;
				counter2<=counter2-1;
				counter3<=counter3-1;
				
				if counter1 = 0 then
					counter1 <= divisor1;
					trigger(1)<='1';
				end if;

				if counter2 = 0 then
					counter2 <= divisor2;
					trigger(2)<='1';
				end if;

				if counter3 = 0 then
					counter3 <= divisor3;
					trigger(3)<='1';
				end if;

				if counter4=1 then
					trigger(4)<='1';
				end if;
				if counter4/=0 then
					counter4<=counter4-1;
				end if;

				if counter5=1 then
					trigger(5)<='1';
				end if;
				if counter5/=0 then
					counter5<=counter5-1;
				end if;

				if counter6=1 then
					trigger(6)<='1';
				end if;
				if counter6/=0 then
					counter6<=counter6-1;
				end if;

			end if;
						
			counter7 <= counter7-1;
			if counter7 = 0 then
				counter7 <= divisor7;
				trigger(7)<='1';
			end if;
			
		end if;
	end process;
end architecture;