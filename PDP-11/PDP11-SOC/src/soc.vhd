
--========================================================================
-- soc.vhd ::  pdp-11 SOC for Latice experiments
--
--  contains:
--
--  (1) pdp-11 core
--  (1) UART
--  (1) timer
--  (1) random number generator
--  (1) Digital I/O
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity SOC is
    port (

          -- Output Port A
          PORTA      : out std_logic_vector(7 downto 0);

          -- UART
          UART_RXD   : in  std_logic;  -- receive data
          UART_TXD   : out std_logic;  -- transmit data

          -- Reset and Clock
          SYSRESET   : in  std_logic;  -- system reset
          FCLK       : in  std_logic   -- fast clock

         );

end SOC;


architecture BEHAVIORAL of SOC is

    --=================================================================
    -- Types, component, and signal definitions
    --=================================================================

    signal ADDR_OUT   : std_logic_vector(15 downto 0);
    signal DATA_IX    : std_logic_vector(15 downto 0);
    signal DATA_OX    : std_logic_vector(15 downto 0);
    signal IMSK_REG   : std_logic_vector( 7 downto 0);
    signal ISRC       : std_logic_vector( 7 downto 0);
    signal PHASE      : std_logic_vector( 3 downto 0);

    signal IO_RESET   : std_logic;   -- I/O reset   (active high)
    signal RESET1     : std_logic;   -- short reset (active low)
    signal RESET      : std_logic;   -- long  reset (active low)

    signal RW         : std_logic;   -- Read/Write  (0=write)
    signal RDY        : std_logic;   -- Ready/Wait
    signal BYTEOP     : std_logic;   -- byte operation
    signal SYNC       : std_logic;   -- Opcode fetch status
    signal FEN        : std_logic;   -- clock enable

    signal BOOT_RE    : std_logic;   -- Boot RAM read  enable
    signal BOOT_WE    : std_logic;   -- Boot RAM write enable
    signal IO_WE      : std_logic;   -- IO write enable
    signal TIMR_IRQ   : std_logic;   -- Timer interrupt
    signal UART_RRQ   : std_logic;   -- UART receive interrupt
    signal UART_TRQ   : std_logic;   -- UART transmit interrupt
    signal UART_RD    : std_logic;   -- UART read data valid

    signal TIMR_DATA  : std_logic_vector(15 downto 0);
    signal BOOT_DATA  : std_logic_vector(15 downto 0);
    signal UART_DATA  : std_logic_vector( 7 downto 0);
    signal PRTA_DATA  : std_logic_vector( 7 downto 0);
    signal RAND_DATA  : std_logic_vector( 7 downto 0);

    signal UART_CS    : std_logic;
    signal TIMR_CS    : std_logic;
    signal PRTA_CS    : std_logic;
    signal IMSK_CS    : std_logic;
    signal RAND_CS    : std_logic;

    signal IRQ0       : std_logic;   -- Interrupt (active-low)
    signal IRQ1       : std_logic;   -- Interrupt (active-low)
    signal IRQ2       : std_logic;   -- Interrupt (active-low)
    signal IRQ3       : std_logic;   -- Interrupt (active-low)

    signal DBUG1      : std_logic;   -- for debug
    signal DBUG2      : std_logic;   -- for debug
    signal DBUG3      : std_logic;   -- for debug
    signal DBUG4      : std_logic;   -- for debug
    signal DBUG5      : std_logic;   -- for debug
    signal DBUG6      : std_logic;   -- for debug
    signal DBUG7      : std_logic;   -- for debug


    --================================================================
    -- Constant definition section
    --================================================================

    -- $0000 -> $1FFF  Boot RAM (8k)
    constant BOOT_SEL : std_logic_vector(15 downto 14) := "00";

    -- $F000 -> $F006  UART registers
    constant UART_SEL : std_logic_vector(15 downto 3)  := "1111000000000";

    -- $F008 -> $F00A  Timer registers
    constant TIMR_SEL : std_logic_vector(15 downto 2)  := "11110000000010";

    -- $F00C           Output Register
    constant PRTA_SEL : std_logic_vector(15 downto 0)  := "1111000000001100";

    -- $F00E           Interrupt mask register
    constant IMSK_SEL : std_logic_vector(15 downto 0)  := "1111000000001110";

    -- $F010 -> $F012  Random number generator
    constant RAND_SEL : std_logic_vector(15 downto 2)  := "11110000000100";

    -- $F014           Interrupt source register
    constant ISRC_SEL : std_logic_vector(15 downto 0)  := "1111000000010100";


    --================================================================
    -- Component definition section
    --================================================================

    --==================================
    -- pdp-11
    --==================================
    component IP_PDP11
    port (
          ADDR_OUT   : out std_logic_vector(15 downto 0);
          DATA_IN    : in  std_logic_vector(15 downto 0);
          DATA_OUT   : out std_logic_vector(15 downto 0);

          R_W        : out std_logic;   -- 1==read 0==write
          BYTE       : out std_logic;   -- byte memory operation
          SYNC       : out std_logic;   -- Opcode fetch status

          IRQ0       : in  std_logic;   -- Interrupt (active-low)
          IRQ1       : in  std_logic;   -- Interrupt (active-low)
          IRQ2       : in  std_logic;   -- Interrupt (active-low)
          IRQ3       : in  std_logic;   -- Interrupt (active-low)

          RDY        : in  std_logic;   -- Ready input
          RESET      : in  std_logic;   -- Reset input (active-low)
          FEN        : in  std_logic;   -- clock enable
          CLK        : in  std_logic;   -- System Clock

          DBUG7      : out std_logic;   -- for debug
          DBUG6      : out std_logic;   -- for debug
          DBUG5      : out std_logic;   -- for debug
          DBUG4      : out std_logic;   -- for debug
          DBUG3      : out std_logic;   -- for debug
          DBUG2      : out std_logic;   -- for debug
          DBUG1      : out std_logic    -- for debug
         );
    end component;


    --===============================
    -- UART (no handshake lines)
    --===============================
    component UART
    port (
          CS         : in  std_logic;  -- chip select
          WE         : in  std_logic;  -- write enable
          BYTE_SEL   : in  std_logic;  -- byte select
          REG_SEL    : in  std_logic_vector( 1 downto 0);  -- register select
          WR_DATA    : in  std_logic_vector(15 downto 0);  -- write data
          RD_DATA    : out std_logic_vector( 7 downto 0);  -- read  data
          RX_IRQ     : out std_logic;  -- RX interrupt req
          TX_IRQ     : out std_logic;  -- TX interrupt req
          RXD        : in  std_logic;  -- received data
          TXD        : out std_logic;  -- transmit data
          RESET      : in  std_logic;  -- system reset
          RDV        : in  std_logic;  -- read data valid
          FCLK       : in  std_logic   -- fast clock
         );
    end component;


    --==============================
    -- Timer
    --==============================
    component TIMER
    port (
          CS         : in  std_logic;  -- chip select
          WE         : in  std_logic;  -- write enable
          WR_DATA    : in  std_logic_vector(15 downto 0);  -- write data
          RD_DATA    : out std_logic_vector(15 downto 0);  -- read  data
          IRQ        : out std_logic;  -- DMA Interrupt
          SEL_IC     : in  std_logic;  -- select initial count
          RESET      : in  std_logic;  -- system reset
          FCLK       : in  std_logic   -- fast clock
         );
    end component;


    --==============================
    -- Random Number Generator
    --==============================
    component RAND8
    port (
          CS         : in  std_logic;  -- chip select
          WE         : in  std_logic;  -- write enable
          REG_SEL    : in  std_logic;  -- register select
          WR_DATA    : in  std_logic_vector(7 downto 0);  -- write data
          RD_DATA    : out std_logic_vector(7 downto 0);  -- read  data
          RESET      : in  std_logic;  -- system reset
          FEN        : in  std_logic;  -- clock enable
          FCLK       : in  std_logic   -- fast clock
         );
    end component;


    --==============================
    -- Output Port
    --==============================
    component OUTPORT
    port (
          CS         : in  std_logic;  -- chip select
          WE         : in  std_logic;  -- write enable
          WR_DATA    : in  std_logic_vector(7 downto 0);  -- data in
          RD_DATA    : out std_logic_vector(7 downto 0);  -- data out
          RESET      : in  std_logic;  -- system reset
          FCLK       : in  std_logic   -- fast clock
         );
    end component;


    --=========================================
    -- Boot RAM (8kx16)
    --=========================================
    component RAM
    port (
          RADDR     : in    std_logic_vector(12 downto 0);
          WADDR     : in    std_logic_vector(12 downto 0);
          DATA_IN   : in    std_logic_vector(15 downto 0);
          DATA_OUT  : out   std_logic_vector(15 downto 0);
          BYTEOP    : in    std_logic; -- byte operation
          REN       : in    std_logic; -- read  enable
          WEN       : in    std_logic; -- write enable
          WCLK      : in    std_logic;
          RCLK      : in    std_logic
         );
    end component;


    --=========================================
    -- Debounce and Sync Reset
    --=========================================
    component XRESET
    port (
          RST_OUT1  : out   std_logic;
          RST_OUT2  : out   std_logic;
          RST_IN    : in    std_logic;
          CLK       : in    std_logic
         );
    end component;


begin

    --=============================================
    -- Clock Phase Divider (divide by 4)
    -- S0=000   S1=001   S2=010   S3=100
    --=============================================
    CLOCK_PHASE_DIVIDER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            -- count
            PHASE <= PHASE(2 downto 0) & PHASE(3);
            -- reset state
            if (RESET1 = '0') then
                PHASE <= "0001";
            end if;
        end if;
    end process;


    --==========================================================
    -- System Clock Enable
    --==========================================================
    SYSTEM_CLOCK_ENABLE:
    process(FCLK)
    begin
        if (FCLK = '1' and FCLK'event) then
            FEN <= PHASE(3);
        end if;
    end process;


    --==========================================================
    -- Address Decoder
    --==========================================================
    ADDRESS_DECODER:
    process(ADDR_OUT, UART_DATA, TIMR_DATA, PRTA_DATA,
            IMSK_REG, ISRC, RAND_DATA, BOOT_DATA, PHASE, RW)
    begin

        UART_CS <= '0';
        TIMR_CS <= '0';
        PRTA_CS <= '0';
        IMSK_CS <= '0';
        RAND_CS <= '0';
        BOOT_RE <= '0';
        BOOT_WE <= '0';
        IO_WE   <= '0';
        UART_RD <= '0';
        DATA_IX <= BOOT_DATA;

        -- Boot RAM
        if (ADDR_OUT(15 downto 14) = BOOT_SEL) then
            BOOT_RE <= PHASE(0) and RW;
            BOOT_WE <= PHASE(3) and not RW;
        end if;

        -- UART registers
        if (ADDR_OUT(15 downto 3) = UART_SEL) then
            UART_CS <= '1';
            DATA_IX <= "00000000" & UART_DATA;
            UART_RD <= PHASE(3) and RW;
            IO_WE   <= PHASE(3) and not RW;
        end if;

        -- Timer registers
        if (ADDR_OUT(15 downto 2) = TIMR_SEL) then
            TIMR_CS <= '1';
            DATA_IX <= TIMR_DATA;
            IO_WE   <= PHASE(3) and not RW;
        end if;

        -- output Port
        if (ADDR_OUT(15 downto 0) = PRTA_SEL) then
            PRTA_CS <= '1';
            DATA_IX <= "00000000" & PRTA_DATA;
            IO_WE   <= PHASE(3) and not RW;
        end if;

        -- Interrupt Mask register
        if (ADDR_OUT(15 downto 0) = IMSK_SEL) then
            IMSK_CS <= '1';
            DATA_IX <= "00000000" & IMSK_REG;
            IO_WE   <= PHASE(3) and not RW;
        end if;

        -- Interrupt Source register
        if (ADDR_OUT(15 downto 0) = ISRC_SEL) then
            DATA_IX <= "00000000" & ISRC;
            IO_WE   <= PHASE(3) and not RW;
        end if;

        -- Random Number registers
        if (ADDR_OUT(15 downto 2) = RAND_SEL) then
            RAND_CS <= '1';
            DATA_IX <= "00000000" & RAND_DATA;
            IO_WE   <= PHASE(3) and not RW;
        end if;

    end process;

    RDY  <= '1';    -- Ready
    IO_RESET <= not RESET;
    PORTA    <= PRTA_DATA;


    --================================================
    -- Interrupt mask register
    --================================================
    INTERRUPT_MASK_REGISTER:
    process (FCLK)
    begin
        if (FCLK = '0' and FCLK'event) then
            if ((IMSK_CS = '1') and (IO_WE = '1')) then
                IMSK_REG <= DATA_OX(7 downto 0);
            end if;
            -- reset state
            if (RESET = '0') then
                IMSK_REG <= (others => '0');
            end if;
        end if;
    end process;


    --================================================
    -- Interrupt Source
    --================================================

    ISRC <= "00000" & UART_TRQ & UART_RRQ & TIMR_IRQ;

    IRQ0 <= not ((IMSK_REG(7) and ISRC(7)) or
                 (IMSK_REG(6) and ISRC(6)) or
                 (IMSK_REG(5) and ISRC(5)) or
                 (IMSK_REG(4) and ISRC(4)) or
                 (IMSK_REG(3) and ISRC(3)) or
                 (IMSK_REG(2) and ISRC(2)) or
                 (IMSK_REG(1) and ISRC(1)) or
                 (IMSK_REG(0) and ISRC(0)));

    IRQ1 <= '1';    -- Interrupt 1
    IRQ2 <= '1';    -- Interrupt 2
    IRQ3 <= '1';    -- Interrupt 3


    --=========================================
    -- Instantiate the pdp-11
    --=========================================
    UPROC:
    IP_PDP11 port map (
          ADDR_OUT   => ADDR_OUT,
          DATA_IN    => DATA_IX,
          DATA_OUT   => DATA_OX,
          R_W        => RW,
          BYTE       => BYTEOP,
          SYNC       => SYNC,
          IRQ0       => IRQ0,
          IRQ1       => IRQ1,
          IRQ2       => IRQ2,
          IRQ3       => IRQ3,
          RDY        => RDY,
          RESET      => RESET,
          FEN        => FEN,
          CLK        => FCLK,
          DBUG7      => DBUG7,
          DBUG6      => DBUG6,
          DBUG5      => DBUG5,
          DBUG4      => DBUG4,
          DBUG3      => DBUG3,
          DBUG2      => DBUG2,
          DBUG1      => DBUG1
      );


    --===========================================
    -- Instantiate the UART
    --===========================================
    UART1:
    UART port map (
          CS         => UART_CS,
          WE         => IO_WE,
          BYTE_SEL   => ADDR_OUT(0),
          REG_SEL    => ADDR_OUT(2 downto 1),
          WR_DATA    => DATA_OX,
          RD_DATA    => UART_DATA,
          RX_IRQ     => UART_RRQ,
          TX_IRQ     => UART_TRQ,
          RXD        => UART_RXD,
          TXD        => UART_TXD,
          RESET      => IO_RESET,
          RDV        => UART_RD,
          FCLK       => FCLK
      );


    --===========================================
    -- Instantiate the TIMER
    --===========================================
    TIMER1:
    TIMER port map (
          CS         => TIMR_CS,
          WE         => IO_WE,
          WR_DATA    => DATA_OX,
          RD_DATA    => TIMR_DATA,
          IRQ        => TIMR_IRQ,
          SEL_IC     => ADDR_OUT(1),
          RESET      => IO_RESET,
          FCLK       => FCLK
      );


    --===========================================
    -- Instantiate the OUTPORT
    --===========================================
    PORT1:
    OUTPORT port map (
          CS         => PRTA_CS,
          WE         => IO_WE,
          WR_DATA    => DATA_OX(7 downto 0),
          RD_DATA    => PRTA_DATA,
          RESET      => IO_RESET,
          FCLK       => FCLK
      );


    --===========================================
    -- Instantiate the RAND generator
    --===========================================
    RAND8X:
    RAND8 port map (
          CS         => RAND_CS,
          WE         => IO_WE,
          REG_SEL    => ADDR_OUT(1),
          WR_DATA    => DATA_OX(7 downto 0),
          RD_DATA    => RAND_DATA,
          RESET      => IO_RESET,
          FEN        => FEN,
          FCLK       => FCLK
      );


    --===========================================
    -- Instantiate the BOOT RAM
    --===========================================
    BOOTRAM:
    RAM port map (
          RADDR      => ADDR_OUT(12 downto 0),
          WADDR      => ADDR_OUT(12 downto 0),
          DATA_IN    => DATA_OX,
          DATA_OUT   => BOOT_DATA,
          BYTEOP     => BYTEOP,
          REN        => BOOT_RE,
          WEN        => BOOT_WE,
          WCLK       => FCLK,
          RCLK       => FCLK
      );


    --=========================================
    -- Instantiate the Reset Sync
    --=========================================
    SDRESET:
    XRESET port map (
          RST_OUT1  => RESET1,  -- short reset
          RST_OUT2  => RESET,   -- long  reset
          RST_IN    => SYSRESET,
          CLK       => FCLK
      );


end BEHAVIORAL;

