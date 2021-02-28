-- synthesis library utils
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- the virt_clk drives logic level operations
entity virtual_clock is
    PORT (
        CLOCK_50 : IN STD_LOGIC;
        virt_clk : BUFFER STD_LOGIC := '0'
    );
END entity;
