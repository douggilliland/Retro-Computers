library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library utils;
use utils.machine_state_type.all;

-- Top-Level entity
entity LEDMatrix is
    PORT (
        RESET,
        CLOCK_50 : IN STD_LOGIC;
        LED_DIGITS  : IN STD_LOGIC_VECTOR(39 downto 0);
        LED_DIN,
        LED_CS,
        LED_CLK  : OUT STD_LOGIC
    );
END entity;

 