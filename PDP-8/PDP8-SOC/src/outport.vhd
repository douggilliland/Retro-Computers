
--======================================================================
-- outport.vhd ::  Digital Output Port
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity OUTPORT is
  port(
    CS       : in  std_logic;  -- chip select
    WE       : in  std_logic;  -- write enable
    WR_DATA  : in  std_logic_vector(7 downto 0);  -- data in
    RD_DATA  : out std_logic_vector(7 downto 0);  -- data out
    RESET    : in  std_logic;  -- system reset
    FCLK     : in  std_logic   -- fast clock
  );
end entity OUTPORT;


architecture BEHAVIORAL of OUTPORT is

    --=================================================================
    -- Signal definitions
    --=================================================================

    signal OREG : std_logic_vector( 7 downto 0);  -- output reg

begin

    --=============================================
    -- Output Register
    --=============================================
    OUTPUT_REG:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (CS = '1' and WE = '1') then
                OREG <= WR_DATA;
            end if;
            if (RESET = '1') then
                OREG  <= (others => '0');
            end if;
        end if;
    end process;

    RD_DATA <= OREG;

end architecture BEHAVIORAL;

