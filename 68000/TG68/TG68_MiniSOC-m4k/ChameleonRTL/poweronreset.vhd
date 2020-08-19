library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity poweronreset is
	port(
		clk : in std_logic;
		reset_button : in std_logic;
		reset_out : out std_logic
	);
end entity;

architecture rtl of poweronreset is
signal counter : unsigned(15 downto 0):=(others => '1');
signal resetbutton_debounced : std_logic;

begin
	mydb : entity work.debounce
		port map(
			clk=>clk,
			signal_in=>reset_button,
			signal_out=>resetbutton_debounced
		);
	process(clk)
	begin
		if rising_edge(clk) then
			reset_out<='0';
			if resetbutton_debounced='0' then
				counter<=X"FFFF";
			elsif counter=X"0000" then
				reset_out<='1';
			else
				counter<=counter-1;
			end if;
		end if;
	end process;

end architecture;
