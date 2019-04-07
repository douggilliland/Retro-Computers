library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SwitchBuzzer is
	Port (
	Switch1 : in STD_LOGIC;		-- aka uKEY3 = pin 88
	Switch2 : in STD_LOGIC;		-- aka uKEY2 = pin 91
	Switch3 : in STD_LOGIC;		-- aka uKEY1 = pin 90
	Switch4 : in STD_LOGIC;		-- aka RSTn = pin 89
	LED2 : out STD_LOGIC;		-- aka DS_DP = pin 3
	LED3 : out STD_LOGIC;		-- aka DS_G = pin 2
	LED4 : out STD_LOGIC;		-- aka DS_C = pin 1
	LED5 : out STD_LOGIC;		-- aka DS_D = pin 141
	Buzzer : out STD_LOGIC);		-- aka BP1 = pin 85
end SwitchBuzzer;

architecture Behavioral of SwitchBuzzer is

begin

--	LED2 <= Switch1;
--	LED3 <= Switch2;
--	LED4 <= Switch3;
--	LED5 <= Switch4;
	Buzzer <= Switch1;
	
end behavioral;
