
--======================================================================
-- reset.vhd ::  Debounce and Synchonize Reset
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity XRESET is
  port (
    RST_OUT1   : out std_logic;  -- (active low)
    RST_OUT2   : out std_logic;  -- (active low)
    RST_IN     : in  std_logic;  -- (active low)
    CLK        : in  std_logic
  );
end XRESET;


architecture BEHAVIORAL of XRESET is

    --=================================================================
    -- Signal definitions
    --=================================================================

    signal DLY_CNTR    :  std_logic_vector(3 downto 0);
    signal RST_DLY1    :  std_logic;
    signal RST_DLY2    :  std_logic;
    signal RST_INT1    :  std_logic;
    signal RST_INT2    :  std_logic;

begin

    --================================================================
    -- Debounce and Synchonize the (active-low) Reset Input
    --================================================================
    -- Depending on the reset and power-supply circuits of the host
    -- system, we may need to wait for the power supply to stabilize
    -- before starting to fetch opcodes.  A simple LFSR counter is
    -- provided for this purpose.  Here are the states
    --
    --  0  0000      4  1010       8  0110      12  1110
    --  1  0001      5  0100       9  1101      13  1100
    --  2  0010      6  1001      10  1011      14  1000
    --  3  0101      7  0011      11  0111
    --
    --================================================================
    DEBOUNCE_AND_SYNCHRONIZE_RESET:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
            RST_DLY1 <= RST_IN;
            RST_DLY2 <= RST_DLY1;

            -- count
            if (RST_INT2 = '1') then
                -- linear-feedback counter
                DLY_CNTR(0) <= DLY_CNTR(3) xnor DLY_CNTR(0);
                DLY_CNTR(1) <= DLY_CNTR(0);
                DLY_CNTR(2) <= DLY_CNTR(1);
                DLY_CNTR(3) <= DLY_CNTR(2);
            end if;

            -- release early reset
            if (DLY_CNTR = "0110") then
                RST_INT1 <= '0';
            end if;

            -- release late reset
            if (DLY_CNTR = "1000") then
                RST_INT2 <= '0';
                DLY_CNTR <= "0000";
            end if;

            -- initiatialize the reset counter
            if (RST_DLY1 = '0' and RST_DLY2 = '0') then
                RST_INT1 <= '1';
                RST_INT2 <= '1';
                DLY_CNTR <= "0000";
            end if;

        end if;

    end process;

    RST_OUT1 <= not RST_INT1;
    RST_OUT2 <= not RST_INT2;

end architecture BEHAVIORAL;
