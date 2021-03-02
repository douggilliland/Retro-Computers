
--======================================================================
-- uart.vhd :: simplified UART for PDP-8
--
--      no parity modes
--      no hardware handshake
--      no interrupts
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
    WR_DATA  : in  std_logic_vector(7 downto 0);   -- write data
    RD_DATA  : out std_logic_vector(7 downto 0);   -- read  data
    RX_RDY   : out std_logic;                      -- RX ready
    TX_RDY   : out std_logic;                      -- TX ready
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

    signal TX_STATE      : std_logic_vector(1 downto 0); -- TX state
    signal TX_NSTATE     : std_logic_vector(1 downto 0); -- TX next state
    signal TX_SHIFT_REG  : std_logic_vector(7 downto 0); -- TX shift reg
    signal TX_COUNT      : std_logic_vector(3 downto 0); -- TX shift counter
    signal TX_FIFO_DATA  : std_logic_vector(7 downto 0); -- TX FIFO data

    signal TX_FIFO_OVFL  : std_logic;         -- TX FIFO overflow flag
    signal TX_FIFO_FULL  : std_logic;         -- TX FIFO full flag
    signal TX_FIFO_EMPTY : std_logic;         -- TX FIFO empty flag
    signal TX_FIFO_PUSH  : std_logic;         -- TX FIFO push
    signal TX_FIFO_POP   : std_logic;         -- TX FIFO pop
    signal TX_FIFO_CKEN  : std_logic;         -- TX FIFO clock enable
    signal TX_SHIFT_LD   : std_logic;         -- TX shift reg load
    signal TX_CLK_EN     : std_logic;         -- TX clock enable
    signal TX_SHIFT_EN   : std_logic;         -- TX shift reg enable
    signal TX_SHIFT_EN1  : std_logic;         -- TX shift reg enable delayed
    signal TX_BCLK       : std_logic;         -- TX baud clock
    signal TX_BCLK_DLY   : std_logic;         -- TX baud clock delayed

    signal RX_STATE      : std_logic_vector(1 downto 0); -- RX state
    signal RX_NSTATE     : std_logic_vector(1 downto 0); -- RX next state
    signal RX_COUNT      : std_logic_vector(2 downto 0); -- RX shift counter
    signal RX_SHIFT_REG  : std_logic_vector(7 downto 0); -- RX shift register
    signal RX_FIFO_DATA  : std_logic_vector(7 downto 0); -- RX FIFO data

    signal RX_FIFO_OVFL  : std_logic;         -- RX FIFO overflow flag
    signal RX_FIFO_STOP  : std_logic;         -- RX FIFO stop flag
    signal RX_FIFO_FULL  : std_logic;         -- RX FIFO full flag
    signal RX_FIFO_EMPTY : std_logic;         -- RX FIFO empty flag
    signal RX_FIFO_PUSH  : std_logic;         -- RX FIFO push
    signal RX_FIFO_POP   : std_logic;         -- RX FIFO pop
    signal RX_FIFO_CKEN  : std_logic;         -- RX FIFO clock enable
    signal RX_ACCEPT     : std_logic;         -- receiver has accepted frame
    signal RXD_SYNC      : std_logic;         -- synchronize received data
    signal RXD_SYNC1     : std_logic;         -- synchronize received data
    signal RX_CLK_EN     : std_logic;         -- receiver clock enable
    signal RX_SHIFT_EN   : std_logic;         -- receiver shift enable
    signal RX_START      : std_logic;         -- testing start bit
    signal RX_BCLK       : std_logic;         -- receiver baud clock
    signal RX_BCLK_DLY   : std_logic;         -- receiver baud clock delayed
    signal RXDI          : std_logic;         -- receive  data
    signal TXDI          : std_logic;         -- transmit data

    signal PRELOAD       : std_logic_vector(15 downto 0); -- baud rate preload
    signal RX_BAUD       : std_logic_vector(15 downto 0); -- RX baud counter
    signal TX_BAUD       : std_logic_vector(15 downto 0); -- TX baud counter

    -- Register addresses
    constant HOLD_ADDR   : std_logic_vector(2 downto 0) := "101";   -- hold reg

    -- parity modes
    constant NONE        : std_logic_vector(1 downto 0) := "00"; 
    constant EVEN        : std_logic_vector(1 downto 0) := "01"; 
    constant ODD         : std_logic_vector(1 downto 0) := "10";

    -- State Constants
    constant IDLE        : std_logic_vector(1 downto 0) := "00";
    constant LOAD        : std_logic_vector(1 downto 0) := "10";
    constant D7          : std_logic_vector(1 downto 0) := "10";
    constant SHIFT       : std_logic_vector(1 downto 0) := "01";
    constant STOP        : std_logic_vector(1 downto 0) := "11";

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
          FPUSH     : in  std_logic;     -- fifo push
          FPOP      : in  std_logic;     -- fifo pop
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
    -- TX FIFO Control
    --=============================================
    TX_FIFO_CONTROL:
    process (CS, WE, TX_SHIFT_LD)
    begin
        TX_FIFO_PUSH <= '0';
        TX_FIFO_POP  <= '0';
        TX_FIFO_CKEN <= '0';

        -- push TX FIFO
        if ((CS = '1') and (WE = '1')) then
            TX_FIFO_PUSH <= '1';
            TX_FIFO_CKEN <= '1';
        end if;
        -- pop TX FIFO
        if (TX_SHIFT_LD = '1') then
            TX_FIFO_POP  <= '1';
            TX_FIFO_CKEN <= '1';
        end if;

    end process;


    --=============================================
    -- Control Register Outputs
    --=============================================
    PARITY_MODE <= NONE;                -- parity mode
    RX_RDY      <= not RX_FIFO_EMPTY;   -- RX FIFO is not empty
    TX_RDY      <= not TX_FIFO_FULL;    -- TX FIFO is not full


    --=============================================
    -- Ready Status
    --=============================================
    RX_RDY  <= not RX_FIFO_EMPTY;  -- RX FIFO is not empty
    TX_RDY  <= not TX_FIFO_FULL;   -- TX FIFO is not full
    RD_DATA <= RX_FIFO_DATA;


    --=============================================
    -- Misc Control
    --=============================================
    PRELOAD <= x"78e3";     -- baud rate 115200
    TXD     <= TXDI;        -- transmit data from tx shift reg
    RXDI    <= RXD;         -- receive  data from pin

    --================================================
    -- Transmit state machine
    --================================================
    TRANSMIT_STATE_MACHINE:
    process (FCLK, RESET)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (TX_CLK_EN = '1') then
                TX_STATE <= TX_NSTATE;
            end if;
        end if;
        -- reset state
        if (RESET = '1') then
            TX_STATE <= IDLE;
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
    process (TX_STATE, TX_SHIFT_EN, TX_CLK_EN, TX_COUNT)
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
                    TX_NSTATE <= STOP;
                else
                    TX_NSTATE <= SHIFT;
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
    process (FCLK, RESET)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- TX_SHIFT_EN is active if:
            --   the previous shift has finished (TX_STATE=IDLE) and
            --   the FIFO has data (TX_FIFO_EMPTY=0)
            if ((TX_STATE = IDLE) and (TX_FIFO_EMPTY = '0')) then
                TX_SHIFT_EN <= '1';
            elsif ((TX_STATE = STOP) and (TX_CLK_EN = '1')) then
                TX_SHIFT_EN <= '0';
            end if;
            -- delay for edge detection
            TX_SHIFT_EN1 <= TX_SHIFT_EN;
        end if;
        -- reset state
        if (RESET = '1') then
            TX_SHIFT_EN  <= '0';
            TX_SHIFT_EN1 <= '0';
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
    -- Transmit Shift Register
    --==========================================
    TRANSMIT_SHIFT_REGISTER:
    process (FCLK, RESET)
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
        end if;
        -- reset state
        if (RESET = '1') then
            TX_SHIFT_REG <= (others => '0');
        end if;
    end process;


    --==========================================
    -- Transmit Data
    --==========================================
    TRANSMIT_DATA:
    process (FCLK, RESET)
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
            end if;
        end if;
        -- reset state
        if (RESET = '1') then
            TXDI <= '1';
        end if;
    end process;


    --================================================
    -- Receiver shift enable
    --================================================
    RECEIVER_SHIFT_ENABLE:
    process (FCLK, RESET)
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
        end if;
        -- reset state
        if (RESET = '1') then
            RX_SHIFT_EN <= '0';
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
    process (FCLK, RESET)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- find the falling edge of the start bit
            if ((RX_STATE = IDLE) and 
                ((RXD_SYNC1 = '0') and (RXD_SYNC = '1'))) then
                RX_START <= '1';
            else
                RX_START <= '0';
            end if;
        end if;
        -- reset state
        if (RESET= '1') then
            RX_START  <= '0';
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
    process (FCLK, RESET)
    begin
        if (FCLK = '0' and FCLK'event) then
            if (RX_CLK_EN = '1') then
                RX_STATE <= RX_NSTATE;
            end if;
        end if;
        -- reset state
        if (RESET = '1') then
            RX_STATE <= IDLE;
        end if;
    end process;


    --=============================================================
    -- Receiver state machine next state logic
    --=============================================================
    RECEIVER_NEXT_STATE_LOGIC:
    process (RX_STATE, RX_ACCEPT, RX_COUNT)
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
                RX_NSTATE <= STOP;   -- skip parity

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
    process (FCLK, RESET)
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
        end if;
        -- reset state
        if (RESET = '1') then
            RX_ACCEPT   <= '0';
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

            RX_FIFO_PUSH <= '0';
            RX_FIFO_POP  <= '0';
            RX_FIFO_CKEN <= '0';

            -- push the RX FIFO when data received
            if ((RX_CLK_EN = '1') and (RX_STATE = STOP)) then
                RX_FIFO_PUSH <= '1';
                RX_FIFO_CKEN <= '1';
            end if;
            -- RX FIFO on a uP read
            if (RDV = '1') then
                RX_FIFO_POP  <= '1';
                RX_FIFO_CKEN <= '1';
            end if;
        end if;
    end process;


    --================================================
    -- RX FIFO flags
    --================================================
    RX_FIFO_FLAGS:
    process (FCLK, RESET)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- set overflow
            if (RX_FIFO_OVFL = '1') then
                RX_FIFO_STOP <= '1';
            end if;
        end if;
        -- reset state
        if (RESET = '1') then
            RX_FIFO_STOP <= '0';
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
          FPUSH    => RX_FIFO_PUSH,
          FPOP     => RX_FIFO_POP,
          CKEN     => RX_FIFO_CKEN,
          CLK      => FCLK,
          RESET    => RESET
      );


    --============================================
    -- Instantiate the TX FIFO
    --============================================
    TX_FIFO: FIFO port map (
          FIFO_OUT => TX_FIFO_DATA,
          FIFO_IN  => WR_DATA,
          OVFL     => TX_FIFO_OVFL,
          LAST     => TX_FIFO_FULL,
          EMPTY    => TX_FIFO_EMPTY,
          FPUSH    => TX_FIFO_PUSH,
          FPOP     => TX_FIFO_POP,
          CKEN     => TX_FIFO_CKEN,
          CLK      => FCLK,
          RESET    => RESET
      );


end BEHAVIORAL;

