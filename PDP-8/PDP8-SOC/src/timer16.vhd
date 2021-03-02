
--======================================================================
-- timer.vhd ::  Counter/Timer
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity TIMER is
  port(
    CS       : in  std_logic;  -- chip select
    WE       : in  std_logic;  -- write enable
    REG_SEL  : in  std_logic_vector(1 downto 0);  -- register address
    WR_DATA  : in  std_logic_vector(7 downto 0);  -- write data
    RD_DATA  : out std_logic_vector(7 downto 0);  -- read  data
    TM_DONE  : out std_logic;  -- timer done
    RESET    : in  std_logic;  -- system reset
    FCLK     : in  std_logic   -- fast clock
  );
end entity TIMER;


architecture BEHAVIORAL of TIMER is

    --=================================================================
    -- Signal definitions
    --=================================================================

    -- Registers
    signal ICH_REG  : std_logic_vector( 7 downto 0);  -- hi byte init count
    signal ICL_REG  : std_logic_vector( 7 downto 0);  -- lo byte init count

    -- Counters
    signal PRE      : std_logic_vector(14 downto 0);  -- prescaler
    signal CTR      : std_logic_vector(15 downto 0);  -- timer count

    -- Counter Control
    signal PEN      : std_logic;     -- Prescaler count enable
    signal CEN      : std_logic;     -- Timer count enable
    signal DBG      : std_logic;     -- Debug mode (no prescaler)
    signal TRQ      : std_logic;     -- Timer interrupt
    signal LOAD     : std_logic;     -- load counter

    -- Terminal Counts
    signal TC       : std_logic;     -- Timer 1   terminal count

    -- Terminal Count Constant
    constant PRE_TC : std_logic_vector(14 downto 0) := "100101011100000";
    constant DBG_TC : std_logic_vector(14 downto 0) := "000010101010101";

    -- Register address constants
    constant CNTL_ADDR  : std_logic_vector(1 downto 0) := "00";
    constant ICL_ADDR   : std_logic_vector(1 downto 0) := "01";
    constant ICH_ADDR   : std_logic_vector(1 downto 0) := "10";


begin

    --=============================================
    -- Register Writes
    --=============================================
    REGISTER_WRITES:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            LOAD <= '0';

            if (CS = '1' and WE = '1') then
                case REG_SEL is
                    when CNTL_ADDR =>         -- control/status
                        TRQ <= '0';
                        DBG <= WR_DATA(1);
                        CEN <= WR_DATA(0);
                    when ICL_ADDR =>          -- initial count (lo)
                        ICL_REG <= WR_DATA;
                        LOAD <= '1';
                    when ICH_ADDR =>          -- initial count (hi)
                        ICH_REG <= WR_DATA;
                        LOAD <= '1';
                    when others =>
                end case;
            end if;

            -- set timer interrupt
            if (TC = '1') then
                TRQ <= '1';
            end if;

            if (RESET = '1') then
                TRQ <= '0';
                DBG <= '0';
                CEN <= '0';
                ICH_REG  <= (others => '0');
                ICL_REG  <= (others => '0');
            end if;

        end if;
    end process;

    TM_DONE <= TRQ;

    --========================================================
    -- Register Reads
    --========================================================
    REGISTER_READS:
    process (CS, REG_SEL, ICL_REG, ICH_REG, TRQ, CEN)
    begin

        RD_DATA <= "00000" & TRQ & '0' & CEN;

        if (CS = '1') then
            case REG_SEL is
                when ICL_ADDR =>       -- initial count (lo)
                    RD_DATA <= ICL_REG;
                when ICH_ADDR =>       -- initial count (hi)
                    RD_DATA <= ICH_REG;
                when others =>         -- control/status
            end case;
        end if;
    end process;


    --==================================================
    -- Prescaler (divide by 16000)
    --==================================================
    PRESCALER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            PEN  <= '0';
            -- If the counter is enabled then count
            if (CEN = '1') then
                -- linear-feedback counter
                PRE(0) <= PRE(14) xnor PRE(0);
                PRE(14 downto 1) <= PRE(13 downto 0);
                -- use PRE_TC terminal count for 1-msec
                -- use DBG_TC terminal count for debug
                if (((DBG = '0') and (PRE = PRE_TC)) or
                    ((DBG = '1') and (PRE = DBG_TC))) then
                    PRE <= (others => '0');
                    PEN <= '1';
                end if;
            end if;

            -- reset state
            if (RESET = '1') then
                PRE <= (others => '0');
                PEN <= '0';
            end if;
        end if;
    end process;


    --==================================================
    -- Timer
    --==================================================
    TIMER_COUNTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            TC  <= '0';
            -- count at each prescaler terminal count
            if (PEN = '1') then
                CTR <= CTR - 1;
            end if;

            -- terminal count
            if ((PEN = '1') and (CTR = "0000000000000001")) then
                TC  <= '1';
                -- Reload the counter when the
                -- terminal count is reached
                CTR <= ICH_REG & ICL_REG;
            end if;

            -- load the counter on uP write
            if (LOAD = '1') then
                CTR <= ICH_REG & ICL_REG;
            end if;

            -- reset state
            if (RESET = '1') then
                CTR <= (others => '1');
                TC <= '0';
            end if;

        end if;
    end process;

end architecture BEHAVIORAL;

