
--======================================================================
-- sim.vhd ::  SOC simulation testbench
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity TEST_TOP is

end TEST_TOP;


architecture BEHAVIORAL of TEST_TOP is

    --================================================================
    -- Signal and component definition section
    --================================================================

    -- Output Port A
    signal PORTA      : std_logic_vector(7 downto 0);

    -- UART
    signal UART_RXD   : std_logic;   -- receive data
    signal UART_TXD   : std_logic;   -- transmit data

    -- reset and clock
    signal RESET      : std_logic;   -- system reset
    signal FCLK       : std_logic;   -- fast   clock


    component SOC
    port (
          -- Output Port A
          PORTA      : out std_logic_vector(7 downto 0);

          -- UART
          UART_RXD   : in  std_logic;  -- receive data
          UART_TXD   : out std_logic;  -- transmit data

          -- reset and clock
          SYSRESET   : in  std_logic;  -- system reset
          FCLK       : in  std_logic   -- fast clock

         );
    end component;

    --================================================================
    -- End of types, component, and signal definition section
    --================================================================

begin

    MAKE_FCLK:
    process(FCLK)
    begin
        if (FCLK = '1') then
            FCLK <= '0' after 1 ns;
        else
            FCLK <= '1' after 1 ns;
        end if;
    end process;


    MAKE_RESET:
    process
    begin
        -- System Reset (active low)
        RESET <= '0' after 0 ns, '1' after 10 ns;
        wait;
    end process;


    UART_RXD <= '0';

    --============================================
    -- Instantiate the SOC
    --============================================
    MYSOC:
    SOC port map (

          PORTA      => PORTA,
          UART_RXD   => UART_RXD,
          UART_TXD   => UART_TXD,
          SYSRESET   => RESET,
          FCLK       => FCLK
      );


end BEHAVIORAL;

