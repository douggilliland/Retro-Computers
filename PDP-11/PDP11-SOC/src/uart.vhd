
--======================================================================
-- uart.vhd :: Generic UART
--
--      no hardware handshake
--      16-deep FIFO
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity UART is
  port(
    CS       : in  std_logic;                      -- chip select
    WE       : in  std_logic;                      -- write enable
    BYTE_SEL : in  std_logic;                      -- byte select
    REG_SEL  : in  std_logic_vector( 1 downto 0);  -- register select
    WR_DATA  : in  std_logic_vector(15 downto 0);  -- write data
    RD_DATA  : out std_logic_vector( 7 downto 0);  -- read  data
    RX_IRQ   : out std_logic;                      -- RX interrupt request
    TX_IRQ   : out std_logic;                      -- TX interrupt request
    RXD      : in  std_logic;                      -- RX serial data
    TXD      : out std_logic;                      -- TX serial data
    RESET    : in  std_logic;                      -- system reset
    RDV      : in  std_logic;                      -- read data valid
    FCLK     : in  std_logic                       -- fast clock
  );
end UART;


architecture BEHAVIORAL of UART is

    --=================================================================
    -- Signal definitions
    --=================================================================

    signal PARITY_MODE   : std_logic_vector(1 downto 0);
    signal FRAMING_ERR   : std_logic;
    signal PARITY_ERR    : std_logic;
    signal OVERRUN_ERR   : std_logic;
    signal STATUS_CLR    : std_logic;         -- clear status register

    signal TX_STATE      : std_logic_vector(3 downto 0); -- TX state
    signal TX_NSTATE     : std_logic_vector(3 downto 0); -- TX next state
    signal TX_SHIFT_REG  : std_logic_vector(7 downto 0); -- TX shift reg
    signal TX_COUNT      : std_logic_vector(3 downto 0); -- TX shift counter
    signal TX_FIFO_DATA  : std_logic_vector(7 downto 0); -- TX FIFO out
    signal TX_FIFO_IN    : std_logic_vector(7 downto 0); -- TX FIFO in

    signal TX_FIFO_OVFL  : std_logic;         -- TX FIFO overflow flag
    signal TX_FIFO_FULL  : std_logic;         -- TX FIFO full flag
    signal TX_FIFO_EMPTY : std_logic;         -- TX FIFO empty flag
    signal TX_FIFO_OP    : std_logic;         -- TX FIFO 1==push 0== pop
    signal TX_FIFO_CKEN  : std_logic;         -- TX FIFO clock enable
    signal TX_SHIFT_LD   : std_logic;         -- TX shift reg load
    signal TX_EN         : std_logic;         -- TX enabled
    signal TX_CLK_EN     : std_logic;         -- TX clock enable
    signal TX_PARITY     : std_logic;         -- TX parity
    signal TX_SHIFT_EN   : std_logic;         -- TX shift reg enable
    signal TX_SHIFT_EN1  : std_logic;         -- TX shift reg enable delayed
    signal TX_BCLK       : std_logic;         -- TX baud clock
    signal TX_BCLK_DLY   : std_logic;         -- TX baud clock delayed

    signal RX_STATE      : std_logic_vector(3 downto 0); -- RX state
    signal RX_NSTATE     : std_logic_vector(3 downto 0); -- RX next state
    signal RX_COUNT      : std_logic_vector(2 downto 0); -- RX shift counter
    signal RX_SHIFT_REG  : std_logic_vector(7 downto 0); -- RX shift register
    signal RX_FIFO_DATA  : std_logic_vector(7 downto 0); -- RX FIFO data

    signal RX_FIFO_OVFL  : std_logic;         -- RX FIFO overflow flag
    signal RX_FIFO_STOP  : std_logic;         -- RX FIFO stop flag
    signal RX_FIFO_FULL  : std_logic;         -- RX FIFO full flag
    signal RX_FIFO_EMPTY : std_logic;         -- RX FIFO empty flag
    signal RX_FIFO_OP    : std_logic;         -- RX FIFO 1==push 0== pop
    signal RX_FIFO_CKEN  : std_logic;         -- RX FIFO clock enable
    signal RX_EN         : std_logic;         -- RX enable
    signal RX_ACCEPT     : std_logic;         -- receiver has accepted frame
    signal RXD_SYNC      : std_logic;         -- synchronize received data
    signal RXD_SYNC1     : std_logic;         -- synchronize received data
    signal RX_CLK_EN     : std_logic;         -- receiver clock enable
    signal RX_SHIFT_EN   : std_logic;         -- receiver shift enable
    signal RX_PARITY     : std_logic;         -- calculated receiver parity
    signal RX_START      : std_logic;         -- testing start bit
    signal RX_BCLK       : std_logic;         -- receiver baud clock
    signal RX_BCLK_DLY   : std_logic;         -- receiver baud clock delayed
    signal RXDI          : std_logic;         -- receive  data
    signal TXDI          : std_logic;         -- transmit data

    signal PRELOAD       : std_logic_vector(15 downto 0); -- baud rate preload
    signal RX_BAUD       : std_logic_vector(15 downto 0); -- RX baud counter
    signal TX_BAUD       : std_logic_vector(15 downto 0); -- TX baud counter

    -- Registers
    signal CNTL_REG      : std_logic_vector( 3 downto 0); -- control
    signal BRSR_REG      : std_logic_vector(15 downto 0); -- baud rate select
    signal STAT_REG      : std_logic_vector( 7 downto 0); -- status
    signal MASK_REG      : std_logic_vector( 1 downto 0); -- interrupt mask

    -- Register addresses
    constant CNTL_ADDR   : std_logic_vector(1 downto 0) := "00"; -- control
    constant STAT_ADDR   : std_logic_vector(1 downto 0) := "00"; -- status
    constant BRSR_ADDR   : std_logic_vector(1 downto 0) := "01"; -- baud rate
    constant MASK_ADDR   : std_logic_vector(1 downto 0) := "10"; -- irq mask
    constant HOLD_ADDR   : std_logic_vector(1 downto 0) := "11"; -- hold reg

    -- parity modes
    constant NONE        : std_logic_vector(1 downto 0) := "00"; 
    constant EVEN        : std_logic_vector(1 downto 0) := "01"; 
    constant ODD         : std_logic_vector(1 downto 0) := "10";

    -- State Constants
    constant IDLE        : std_logic_vector(3 downto 0) := "1000";
    constant LOAD        : std_logic_vector(3 downto 0) := "0010";
    constant D7          : std_logic_vector(3 downto 0) := "0010";
    constant SHIFT       : std_logic_vector(3 downto 0) := "0100";
    constant PRTY        : std_logic_vector(3 downto 0) := "0000";
    constant STOP        : std_logic_vector(3 downto 0) := "0001";

    -- Misc
    constant CKDIV_TC    : std_logic_vector(9 downto 0) := "0000000000";
    constant TX_INIT     : std_logic_vector(3 downto 0) := "0011";
    constant TX_TC       : std_logic_vector(3 downto 0) := "0000";
    constant RX_INIT     : std_logic_vector(2 downto 0) := "000";
    constant RX_TC       : std_logic_vector(2 downto 0) := "100";


    --================================================================
    -- component definitions
    --================================================================

    component FIFO
    port (
          FIFO_OUT  : out std_logic_vector(7 downto 0);
          FIFO_IN   : in  std_logic_vector(7 downto 0);
          OVFL      : out std_logic;     -- overflow
          LAST      : out std_logic;     -- nearly full
          EMPTY     : out std_logic;     -- empty
          FIFO_OP   : in  std_logic;     -- 1==push  0==pop
          CKEN      : in  std_logic;     -- clock enable
          CLK       : in  std_logic;     -- clock
          RESET     : in  std_logic      -- Reset
         );
    end component;

    --================================================================
    -- End of types, component, and signal definition section
    --================================================================


begin

    --=============================================
    -- Register Writes
    --=============================================
    REGISTER_WRITES:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            STATUS_CLR <= '0';
            if ((CS = '1') and (WE = '1')) then
                case REG_SEL is
                    when CNTL_ADDR =>
                        if (WR_DATA(4) = '1') then
                            STATUS_CLR <= '1';
                        else
                            CNTL_REG  <= WR_DATA(3 downto 0);
                        end if;
                    when BRSR_ADDR =>
                        BRSR_REG  <= WR_DATA;
                    when MASK_ADDR =>
                        MASK_REG  <= WR_DATA(1 downto 0);
                    when others =>
                end case;
            end if;

            -- reset state
            if (RESET  = '1') then
                CNTL_REG <= (others => '0');
                BRSR_REG <= (others => '0');
                MASK_REG <= (others => '0');
                STATUS_CLR <= '1';
            end if;

        end if;
    end process;


    --=============================================
    -- TX FIFO Control
    --=============================================
    TX_FIFO_CONTROL:
    process (CS, WE, REG_SEL, TX_EN, TX_SHIFT_LD)
    begin
        TX_FIFO_CKEN <= '0';
        TX_FIFO_OP <= '0';

        -- push tx FIFO
        if ((CS = '1') and (WE = '1') and (REG_SEL = HOLD_ADDR)) then
            if (TX_EN = '1') then
                TX_FIFO_OP <= '1';
                TX_FIFO_CKEN <= '1';
            end if;
        end if;
        -- pop TX FIFO
        if (TX_SHIFT_LD = '1') then
            TX_FIFO_CKEN <= '1';
        end if;

    end process;


    --=============================================
    -- Status Register
    --=============================================
    STATUS_REGISTER:
    process (FRAMING_ERR, PARITY_ERR, OVERRUN_ERR,
             TX_FIFO_FULL, TX_FIFO_EMPTY, RX_FIFO_FULL, RX_FIFO_EMPTY)
    begin
        STAT_REG(7) <= '0';
        STAT_REG(6) <= FRAMING_ERR;
        STAT_REG(5) <= PARITY_ERR;
        STAT_REG(4) <= OVERRUN_ERR;
        STAT_REG(3) <= TX_FIFO_EMPTY;           -- TX FIFO is empty
        STAT_REG(2) <= not TX_FIFO_FULL;        -- TX FIFO is not full
        STAT_REG(1) <= RX_FIFO_FULL;            -- RX FIFO is full
        STAT_REG(0) <= not RX_FIFO_EMPTY;       -- RX FIFO is not empty
    end process;


    --=============================================
    -- Control Register Outputs
    --=============================================
    PRELOAD     <= BRSR_REG;                    -- baud rate select constant
    PARITY_MODE <= CNTL_REG(3 downto 2);        -- parity mode (even/odd/none)
    RX_EN       <= CNTL_REG(1);                 -- receiver enable
    TX_EN       <= CNTL_REG(0);                 -- transmit enable


    --=============================================
    -- Register Reads
    --=============================================
    REGISTER_READS:
    process (CS, REG_SEL, RX_FIFO_DATA, STAT_REG)
    begin
        RD_DATA <= RX_FIFO_DATA;
        if (CS = '1') then
            case REG_SEL is
                when STAT_ADDR =>  -- status register
                    RD_DATA <= STAT_REG;
                when others =>
            end case;
        end if;
    end process;


    --=========================================================================
    -- RX Interrupt Generation Logic
    --
    --  Generated RX_IRQ if: Data is ready in the receiver reg
    --  and the RX IRQ is not masked.
    --=========================================================================
    RX_IRQ_GENERATION:
    process (RX_FIFO_FULL, MASK_REG)
    begin
        RX_IRQ <= '0';
        if ((RX_FIFO_FULL  = '1') and (MASK_REG(0)= '1')) then
            RX_IRQ <= '1';
        end if;
    end process;


    --=========================================================================
    -- TX Interrupt Generation Logic
    --
    --  Generated TX_IRQ if: The transmitter is empty and the TX IRQ
    --  is not masked and the transmitter is enabled
    --  Note: The transmit interrupt can only be cleared by writing new data
    --  to the transmit hold register or by disabling the transmitter.
    --=========================================================================
    TX_IRQ_GENERATION:
    process (TX_FIFO_EMPTY, MASK_REG, TX_EN)
    begin
        TX_IRQ <= '0';
        if ((TX_FIFO_EMPTY = '1') and (MASK_REG(1) = '1') and
            (TX_EN = '1')) then
            TX_IRQ <= '1';
        end if;
    end process;

    TXD  <= TXDI;    -- transmit data from tx shift reg
    RXDI <= RXD;     -- receive  data from pin

    --================================================
    -- Transmit state machine
    --================================================
    TRANSMIT_STATE_MACHINE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (TX_CLK_EN = '1') then
                TX_STATE <= TX_NSTATE;
            end if;
            -- reset state
            if (RESET = '1') then
                TX_STATE <= IDLE;
            end if;
        end if;
    end process;


    --================================================
    -- Transmit shift counter
    --
    --  0) 0011    3) 1011    6) 1100
    --  1) 0110    4) 0111    7) 1000
    --  2) 1101    5) 1110    8) 0000   <- TC
    --
    --================================================
    TRANSMIT_SHIFT_COUNTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if ((TX_STATE = SHIFT) and (TX_CLK_EN = '1')) then
                TX_COUNT <= TX_COUNT(2 downto 0) &
                    not(TX_COUNT(0) xor TX_COUNT(3));
            end if;
            if (TX_STATE = IDLE) then
                TX_COUNT <= TX_INIT;
            end if;
        end if;
    end process;


    --================================================
    -- Transmit state machine next state logic
    --================================================
    TRANSMIT_NEXT_STATE_LOGIC:
    process (TX_STATE, TX_SHIFT_EN, TX_CLK_EN,
             TX_COUNT, PARITY_MODE)
    begin

        case TX_STATE is
            when IDLE =>
                -- detect the leading edge of the transmit shift enable
                if (TX_SHIFT_EN = '1') then
                    TX_NSTATE <= LOAD;
                else
                    TX_NSTATE <= IDLE;
                end if;

            when LOAD =>
                -- detect the first transmit clock enable
                if (TX_CLK_EN = '1') then
                    TX_NSTATE <= SHIFT;
                else
                    TX_NSTATE <= LOAD;
                end if;

            when SHIFT =>
                if ((TX_CLK_EN = '1') and (TX_COUNT = TX_TC)) then
                    if (PARITY_MODE = NONE) then
                        TX_NSTATE <= STOP;
                    else
                        TX_NSTATE <= PRTY;
                    end if;
                else
                    TX_NSTATE <= SHIFT;
                end if;

            when PRTY =>
                if (TX_CLK_EN = '1') then
                    TX_NSTATE <= STOP;
                else
                    TX_NSTATE <= PRTY;
                end if;

            when STOP =>
                if (TX_CLK_EN = '1') then
                    TX_NSTATE <= IDLE;
                else
                    TX_NSTATE <= STOP;
                end if;

            when others =>
                TX_NSTATE <= IDLE;
        end case;
    end process;


    --================================================
    -- Transmit Shift Enable
    --================================================
    TRANSMIT_SHIFT_ENABLE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- TX_SHIFT_EN is active if:
            --   the previous shift has finished (TX_STATE=IDLE) and
            --   the FIFO has data (TX_FIFO_EMPTY=0) and
            --   the transmitter is enabled (TX_EN=1)
            if ((TX_STATE = IDLE) and (TX_FIFO_EMPTY = '0') and
                (TX_EN = '1')) then
                TX_SHIFT_EN <= '1';
            elsif ((TX_STATE = STOP) and (TX_CLK_EN = '1')) then
                TX_SHIFT_EN <= '0';
            end if;
            -- delay for edge detection
            TX_SHIFT_EN1 <= TX_SHIFT_EN;

            -- reset state
            if ((RESET = '1') or (TX_EN = '0')) then
                TX_SHIFT_EN  <= '0';
                TX_SHIFT_EN1 <= '0';
            end if;
        end if;
    end process;


    --=============================================
    -- Transmit baud-rate clock divider
    --=============================================
    TRANSMIT_BAUD_CLK_DIVIDER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- delayed baud clock for edge detection
            TX_BCLK_DLY <= TX_BCLK;
            if (TX_SHIFT_EN = '1') then
                -- count
                TX_BAUD <= TX_BAUD(14 downto 0) &
                    not(TX_BAUD(2) xor TX_BAUD(15));
                -- reload at terminal count
                if (TX_BAUD = CKDIV_TC) then
                    TX_BAUD <= PRELOAD;
                    TX_BCLK <= not TX_BCLK;
                end if;
            end if;
            -- load the initial count on reset or
            -- when we start to send a new frame
            if ((RESET = '1') or
               ((TX_SHIFT_EN = '1') and (TX_SHIFT_EN1 = '0'))) then
                TX_BAUD <= PRELOAD;
                TX_BCLK <= '0';
            end if;
        end if;
    end process;


    --==========================================
    -- Transmit Clock Enable
    --==========================================
    TRANSMIT_CLOCK_ENABLE:
    process (TX_BCLK, TX_BCLK_DLY)
    begin
        if ((TX_BCLK = '0') and (TX_BCLK_DLY = '1')) then
            -- center TX clock in the middle of the data
            -- at the falling edge of TX_BCLK
            TX_CLK_EN <= '1';
        else
            TX_CLK_EN <= '0';
        end if;
    end process;


    --==========================================
    -- Transmit Parity Generation
    --==========================================
    TRANSMITTER_PARITY_GENERATION:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (TX_STATE = IDLE) then
                -- for odd  parity init TX_PARITY to 1
                -- for even parity init TX_PARITY to 0
                TX_PARITY <= PARITY_MODE(0);
            end if;
            if ((TX_CLK_EN = '1') and (TX_STATE = SHIFT)) then
                -- calculate parity during shift
                TX_PARITY <= TX_PARITY xor TX_SHIFT_REG(0);
            end if;
        end if;
    end process;


    --==========================================
    -- Transmit Shift Register
    --==========================================
    TRANSMIT_SHIFT_REGISTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            TX_SHIFT_LD <= '0';

            -- load from the hold register
            if (TX_SHIFT_EN = '1' and TX_SHIFT_EN1 = '0') then
                TX_SHIFT_REG <= TX_FIFO_DATA;
                TX_SHIFT_LD <= '1';
            end if;
            -- shift
            if ((TX_CLK_EN = '1') and (TX_STATE = SHIFT)) then
                TX_SHIFT_REG <= '1' & TX_SHIFT_REG(7 downto 1);
            end if;
            -- reset state
            if (RESET = '1') then
                TX_SHIFT_REG <= (others => '0');
            end if;
        end if;
    end process;


    --==========================================
    -- Transmit Data
    --==========================================
    TRANSMIT_DATA:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (TX_CLK_EN = '1') then

                TXDI <= '1';                  -- mark bit

                if (TX_STATE = LOAD) then
                    TXDI <= '0';              -- start bit
                end if;

                if (TX_STATE = SHIFT) then
                    TXDI <= TX_SHIFT_REG(0);  -- data bit
                end if;

                if (TX_NSTATE = PRTY) then
                    TXDI <= TX_PARITY;        -- parity bit
                end if;

            end if;

            -- reset state
            if (RESET = '1') then
                TXDI <= '1';
            end if;
        end if;
    end process;


    --================================================
    -- Receiver shift enable
    --================================================
    RECEIVER_SHIFT_ENABLE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- RX_SHIFT_EN is active if the start bit is OK
            -- and the shift register is not full.
            -- It is only hi during data bits
            if ((RX_STATE = IDLE) and (RX_START = '1') and
                (RX_FIFO_STOP = '0')) then
                RX_SHIFT_EN <= '1';
            end if;
            -- clear the RX shift enable
            if ((RX_CLK_EN = '1') and (RX_STATE = D7)) then
                RX_SHIFT_EN <= '0';
            end if;

            -- reset state
            if ((RESET = '1') or (RX_EN = '0')) then
                RX_SHIFT_EN <= '0';
            end if;
        end if;
    end process;


    --=============================================
    -- Receiver baud-rate clock divider
    --=============================================
    RECEIVER_BAUD_CLK_DIVIDER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            -- delayed baud clock for edge detection
            RX_BCLK_DLY <= RX_BCLK;

            if ((RX_SHIFT_EN = '1') or (RX_STATE /= IDLE)) then
                -- count
                RX_BAUD <= RX_BAUD(14 downto 0) &
                    not(RX_BAUD(2) xor RX_BAUD(15));
                -- reload at terminal count
                if (RX_BAUD = CKDIV_TC) then
                    RX_BAUD <= PRELOAD;
                    RX_BCLK <= not RX_BCLK;
                end if;
            end if;
            -- load the initial count on Reset or
            -- when we start to receive a new frame
            if ((RESET = '1') or (RX_START = '1')) then
                RX_BAUD <= PRELOAD;
                RX_BCLK <= '0';
            end if;
        end if;
    end process;


    --==========================================
    -- Receiver Clock Enable
    --==========================================
    RECEIVER_CLOCK_ENABLE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if ((RX_BCLK_DLY = '0') and (RX_BCLK = '1')) then
                -- center RX clock in the middle of the data
                -- at the rising edge of RX_BCLK
                RX_CLK_EN <= '1';
            else
                RX_CLK_EN <= '0';
            end if;
        end if;
    end process;


    --==========================================
    -- Receive start of frame
    --==========================================
    RECEIVE_START_OF_FRAME:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- find the falling edge of the start bit
            if ((RX_STATE = IDLE) and 
                ((RXD_SYNC1 = '0') and (RXD_SYNC = '1'))) then
                RX_START <= '1';
            else
                RX_START <= '0';
            end if;

            -- reset state
            if (RESET= '1') then
                RX_START  <= '0';
            end if;
        end if;
    end process;


    --================================================
    -- Receiver shift counter
    --
    -- 0) 000     3) 101     6) 100   <- TC
    -- 1) 001     4) 011
    -- 2) 010     5) 110
    --
    --================================================
    RECEIVER_SHIFT_COUNTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if ((RX_STATE = SHIFT) and (RX_CLK_EN = '1')) then
                RX_COUNT <= RX_COUNT(1 downto 0) &
                    not(RX_COUNT(0) xor RX_COUNT(2));
            end if;
            if (RX_STATE = IDLE) then
                RX_COUNT <= RX_INIT;
            end if;
        end if;
    end process;


    --================================================
    -- Receiver state machine
    --================================================
    RECEIVER_STATE_MACHINE:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (RX_CLK_EN = '1') then
                RX_STATE <= RX_NSTATE;
            end if;
            -- reset state
            if (RESET = '1') then
                RX_STATE <= IDLE;
            end if;
        end if;
    end process;


    --=============================================================
    -- Receiver state machine next state logic
    --=============================================================
    RECEIVER_NEXT_STATE_LOGIC:
    process (RX_STATE, RX_ACCEPT, RX_COUNT, PARITY_MODE)
    begin

        case RX_STATE is

            when IDLE =>
                if (RX_ACCEPT = '1') then
                    RX_NSTATE <= SHIFT;  -- accept data
                else
                    RX_NSTATE <= IDLE;   -- wait
                end if;

            when SHIFT =>
                if (RX_COUNT = RX_TC) then
                    RX_NSTATE <= D7;
                else
                    RX_NSTATE <= SHIFT;
                end if;

            when D7 =>
                if (PARITY_MODE = NONE) then
                    RX_NSTATE <= STOP;   -- skip parity
                else
                    RX_NSTATE <= PRTY;   -- get  parity
                end if;

            when PRTY =>
                RX_NSTATE <= STOP;

            when STOP =>
                RX_NSTATE <= IDLE;

            when others =>
                RX_NSTATE <= IDLE;
        end case;

    end process;


    --================================================
    -- Receiver shift register accept data
    --================================================
    RECEIVER_SHIFT_ACCEPT_DATA:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- RX_ACCEPT goes hi if start bit is OK & there's room
            -- It stays hi until the data has been received
            if ((RX_STATE = IDLE) and (RX_START = '1') and
                (RX_FIFO_STOP = '0')) then
                RX_ACCEPT<= '1';
            end if;
            if (RX_STATE = D7) then
                RX_ACCEPT<= '0';
            end if;

            -- reset state
            if ((RESET = '1') or (RX_EN = '0')) then
                RX_ACCEPT   <= '0';
            end if;
        end if;
    end process;


    --================================================
    -- Receiver shift register
    --================================================
    RECEIVER_SHIFT_REGISTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- synchronize the received data
            RXD_SYNC1 <= RXDI;
            RXD_SYNC  <= RXD_SYNC1;
            -- shift in the data
            if ((RX_CLK_EN = '1') and (RX_SHIFT_EN = '1')) then
                RX_SHIFT_REG <= RXD_SYNC & RX_SHIFT_REG(7 downto 1);
            end if;
        end if;
    end process;


    --================================================
    -- RX FIFO control
    --================================================
    RX_FIFO_CONTROL:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then

            RX_FIFO_OP   <= '0';
            RX_FIFO_CKEN <= '0';

            -- push the RX FIFO when data received
            if ((RX_CLK_EN = '1') and (RX_STATE = STOP)) then
                RX_FIFO_OP   <= '1';
                RX_FIFO_CKEN <= '1';
            end if;
            -- RX FIFO on a uP read
            if (RDV = '1') then
                if ((CS = '1') and (REG_SEL = HOLD_ADDR)) then
                    RX_FIFO_OP   <= '0';
                    RX_FIFO_CKEN <= '1';
                end if;
            end if;
        end if;
    end process;


    --================================================
    -- Receiver parity generation
    --================================================
    RECEIVER_PARITY_GENERATION:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if ((RX_STATE = IDLE) and (RX_ACCEPT = '0')) then
                -- for odd  parity init RX_PARITY to 1
                -- for even parity init RX_PARITY to 0
                RX_PARITY <= PARITY_MODE(0);
            else
                if (RX_CLK_EN = '1') then
                    -- calculate parity during shift
                    RX_PARITY <= RX_PARITY xor RXD_SYNC;
                end if;
            end if;
        end if;
    end process;


    --================================================
    -- Receiver error flags
    --================================================
    RECEIVER_ERROR_FLAGS:
    process (FCLK)
    begin

        -- PARITY_ERR is set when the calculated parity doesn't match
        -- the received parity. It stays set until a character
        -- without a parity error is received.
        -- FRAMING_ERR is set if the stop bit=0. It stays set until
        -- a character without a frame error is received.
        -- OVERRUN_ERR set if a new start bit is seen but there's no room
        -- for more data. It stays set until explicitly cleared.

        if (FCLK = '0' and FCLK'event) then
            if (RX_CLK_EN = '1') then
                -- check for framing sync
                if (RX_STATE = STOP) then
                    FRAMING_ERR <= not RXD_SYNC;
                end if;
                -- check parity
                if ((RX_STATE = STOP) and (PARITY_MODE /= NONE)) then
                    PARITY_ERR <= RX_PARITY;
                end if;
            end if;

            -- check for FIFO overrun
            if ((RX_FIFO_STOP = '1') and (RX_STATE = IDLE) and
                (RX_START = '1')) then
                OVERRUN_ERR <= '1';
            end if;

            -- Clear framing error
            if ((RX_EN = '0') or (STATUS_CLR = '1')) then
                FRAMING_ERR <= '0';
            end if;
            -- Clear parity error
            if ((RX_EN = '0') or (PARITY_MODE = NONE) or
                (STATUS_CLR = '1')) then
                PARITY_ERR  <= '0';
            end if;
            -- Clear overrun error
            if ((RX_EN = '0') or (STATUS_CLR = '1')) then
                OVERRUN_ERR <= '0';
            end if;

        end if;
    end process;


    --================================================
    -- RX FIFO flags
    --================================================
    RX_FIFO_FLAGS:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- set overflow
            if (RX_FIFO_OVFL = '1') then
                RX_FIFO_STOP <= '1';
            end if;
            -- reset state
            if ((RESET = '1') or (STATUS_CLR = '1')) then
                RX_FIFO_STOP <= '0';
            end if;
        end if;
    end process;


    --================================================
    -- TX FIFO input byte select
    --================================================
    TX_BYTE_SELECT:
    process (BYTE_SEL, WR_DATA)
    begin
        if (BYTE_SEL = '0') then
            TX_FIFO_IN <= WR_DATA(7 downto 0);
        else
            TX_FIFO_IN <= WR_DATA(15 downto 8);
        end if;
    end process;


    --============================================
    -- Instantiate the RX FIFO
    --============================================
    RX_FIFO: FIFO port map (
          FIFO_OUT => RX_FIFO_DATA,
          FIFO_IN  => RX_SHIFT_REG,
          OVFL     => RX_FIFO_OVFL,
          LAST     => RX_FIFO_FULL,
          EMPTY    => RX_FIFO_EMPTY,
          FIFO_OP  => RX_FIFO_OP,
          CKEN     => RX_FIFO_CKEN,
          CLK      => FCLK,
          RESET    => RESET
      );


    --============================================
    -- Instantiate the TX FIFO
    --============================================
    TX_FIFO: FIFO port map (
          FIFO_OUT => TX_FIFO_DATA,
          FIFO_IN  => TX_FIFO_IN,
          OVFL     => TX_FIFO_OVFL,
          LAST     => TX_FIFO_FULL,
          EMPTY    => TX_FIFO_EMPTY,
          FIFO_OP  => TX_FIFO_OP,
          CKEN     => TX_FIFO_CKEN,
          CLK      => FCLK,
          RESET    => RESET
      );


end BEHAVIORAL;

