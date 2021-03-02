
--======================================================================
-- rand8.vhd ::  Random Number Generator
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity RAND8 is
  port(
    CS       : in  std_logic;  -- chip select
    WE       : in  std_logic;  -- write enable
    REG_SEL  : in  std_logic;  -- register select
    WR_DATA  : in  std_logic_vector(7 downto 0);  -- write data
    RD_DATA  : out std_logic_vector(7 downto 0);  -- read  data
    RESET    : in  std_logic;  -- system reset
    FEN      : in  std_logic;  -- clock enable
    FCLK     : in  std_logic   -- fast clock
  );
end entity RAND8;


architecture BEHAVIORAL of RAND8 is

    --=================================================================
    -- Signal definitions
    --=================================================================

    signal MASK : std_logic_vector(7 downto 0);  -- mask
    signal CX   : std_logic_vector(8 downto 0);  -- counter
    signal CEN  : std_logic;                     -- count enable


begin

    --=============================================
    -- Register Write
    --=============================================
    REGISTER_WRITE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (CS = '1' and WE = '1') then
                if (REG_SEL = '1') then
                    MASK <= WR_DATA;
                else
                    CEN <= WR_DATA(0);
                end if;
            end if;
            if (RESET = '1') then
                MASK <= (others => '1');
                CEN  <= '0';
            end if;
        end if;
    end process;


    --==================================================
    -- Counter
    --==================================================
    COUNTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (CEN = '1') then
                -- linear-feedback counter
                CX(0) <= CX(8) xnor CX(3);
                CX(8 downto 1) <= CX(7 downto 0);
            end if;
            -- reset state
            if (RESET = '1') then
                CX <= (others => '0');
            end if;
        end if;
    end process;


    --==================================================
    -- Output Register
    --==================================================
    OUTPUT_REG:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (CS = '1' and FEN = '1') then
                RD_DATA(7) <= CX(7) and MASK(7);
                RD_DATA(6) <= CX(3) and MASK(6);
                RD_DATA(5) <= CX(5) and MASK(5);
                RD_DATA(4) <= CX(1) and MASK(4);
                RD_DATA(3) <= CX(0) and MASK(3);
                RD_DATA(2) <= CX(4) and MASK(2);
                RD_DATA(1) <= CX(2) and MASK(1);
                RD_DATA(0) <= CX(6) and MASK(0);
            end if;
            -- reset state
            if (RESET = '1') then
                RD_DATA <= (others => '0');
            end if;
        end if;
    end process;


end architecture BEHAVIORAL;

