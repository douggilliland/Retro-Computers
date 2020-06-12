library ieee;
use ieee.std_logic_1164.all;
library utils;
use utils.machine_state_type.all;

entity max7219 is
    PORT (
		  RESET,
        CLOCK_50        : IN STD_LOGIC;
        input           : IN STD_LOGIC_VECTOR(15 downto 0);
        run             : IN STD_LOGIC := '0';
        state           : BUFFER machine_state_type := initialize;
        virt_clk        : IN STD_LOGIC := '0';
        CLK, DIN, CS    : OUT STD_LOGIC
    );
END entity;
