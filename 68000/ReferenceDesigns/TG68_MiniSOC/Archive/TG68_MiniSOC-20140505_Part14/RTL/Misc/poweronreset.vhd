library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity poweronreset is
	port(
		clk : in std_logic;
		reset_button : in std_logic;
		reset_out : out std_logic;
		power_button : in std_logic := '1';
		power_hold : out std_logic := '1'
	);
end entity;

architecture rtl of poweronreset is
signal counter : unsigned(15 downto 0):=(others => '1');
signal resetbutton_debounced : std_logic;
signal powerbutton_debounced : std_logic;
signal power_cut : std_logic;

begin
	mydb : entity work.debounce
		port map(
			clk=>clk,
			signal_in=>reset_button,
			signal_out=>resetbutton_debounced
		);
	mydb2 : entity work.debounce
		generic map(
			default => '0',	-- Will probably power up with the button held.
			bits => 22
		)
		port map(
			clk=>clk,
			signal_in=>power_button,
			signal_out=>powerbutton_debounced
		);
	process(clk)
	begin
		if(rising_edge(clk)) then
			reset_out<='0';
			power_cut<='0';
			if resetbutton_debounced='0' then
				counter<=X"FFFF";
			elsif counter=X"0000" then
				reset_out<='1';

				if powerbutton_debounced='0' then -- If we're not in reset, cut power if the power button is pressed
					power_cut<='1';
				elsif power_cut='1' then -- ... but don't actually cut the power until the button's released again.
					power_hold<='0';
				end if;

			elsif powerbutton_debounced='1' then -- Don't let the reset counter run while the power button's pushed
				counter <= counter-1;
			end if;
		end if;
	end process;

end architecture;