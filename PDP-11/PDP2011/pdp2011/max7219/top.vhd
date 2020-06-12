library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
   port(
      redled : out std_logic_vector(3 downto 0);
      beep : out std_logic;
      sseg0 : out std_logic_vector(0 to 6);
      ssegP : out std_logic;
      Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals

      clkin : in std_logic;
      switch : in std_logic_vector(3 downto 0);
      resetbtn : in std_logic;

      max7219_load  : out std_logic;
      max7219_data : out std_logic;
      max7219_clock : out std_logic
   );
end top;

architecture implementation of top is

component LEDMatrix is
    PORT (
        RESET,
        CLOCK_50 : IN STD_LOGIC;
		  LED_DIGITS  : IN STD_LOGIC_VECTOR(39 downto 0);
        LED_DIN,
        LED_CS,
        LED_CLK  : OUT STD_LOGIC
    );
END component;

-------------------------------cc------------------------",---8,---7,---6,---5,---4,---3,---2,---1"
--signal  my_digits : std_logic_vector ( 39 downto 0) := "1111111111001100010100100000110001000001";
signal    my_digits : std_logic_vector ( 39 downto 0) := "0100000111001100010100100000110001000001";
---------------------------------cc--------------------------35---30---25---20---15---10----5----0
--signal  my_digits : std_logic_vector ( 39 downto 0);


begin

	t_LEDMatrix: LEDMatrix PORT map(
        RESET => resetbtn,
        CLOCK_50 => clkin,
		  LED_DIGITS => my_digits,
        LED_DIN => max7219_data,
        LED_CS => max7219_load,
        LED_CLK => max7219_clock
    );

	beep <= '1';
	redled <= "1111";
	Anode_Activate <= "1110";
	sseg0 <= "1111111";
	ssegP <= '0';

	 
end;