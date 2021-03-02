
--========================================================================
-- soc.vhd ::  PDP-8 SOC for Latice experiments
--
--  contains:
--
--  (1) PDP-8 core
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

    signal ADDR_OUT   : std_logic_vector(11 downto 0);
    signal BOOT_ADDR  : std_logic_vector(12 downto 0);
    signal DATA_IX    : std_logic_vector(11 downto 0);
    signal DATA_OX    : std_logic_vector(11 downto 0);
    signal DEV_SEL    : std_logic_vector( 5 downto 0);
    signal BANK_SEL   : std_logic_vector( 2 downto 0);
    signal PHASE      : std_logic_vector( 3 downto 0);

    signal IO_RESET   : std_logic;   -- I/O reset   (active high)
    signal RESET1     : std_logic;   -- short reset (active low)
    signal RESET      : std_logic;   -- long  reset (active low)

    signal IOM        : std_logic;   -- (0 = Memory) (1 = I/O)
    signal RW         : std_logic;   -- Read/Write  (0=write)
    signal IORDY      : std_logic;   -- I/O ready status
    signal IRQ        : std_logic;   -- Interrupt Request  (active-low)
    signal FEN        : std_logic;   -- clock enable       (active-hi)

    signal BOOT_RE    : std_logic;   -- Boot RAM read  enable
    signal BOOT_WE    : std_logic;   -- Boot RAM write enable
    signal IO_WE      : std_logic;   -- IO write enable
    signal TM_DONE    : std_logic;   -- timer done
    signal RX_RDY     : std_logic;   -- UART RX ready
    signal TX_RDY     : std_logic;   -- UART TX ready
    signal UART_RD    : std_logic;   -- UART read data valid

    signal UART_DATA  : std_logic_vector( 7 downto 0);
    signal TIMR_DATA  : std_logic_vector( 7 downto 0);
    signal BOOT_DATA  : std_logic_vector(11 downto 0);
    signal PRTA_DATA  : std_logic_vector( 7 downto 0);
    signal RAND_DATA  : std_logic_vector( 7 downto 0);

    signal UART_CS    : std_logic;
    signal TIMR_CS    : std_logic;
    signal PRTA_CS    : std_logic;
    signal RAND_CS    : std_logic;

    signal TRIG1      : std_logic; -- for debug
    signal TRIG2      : std_logic; -- for debug


    --================================================================
    -- Constant definition section (octal)
    --================================================================

    -- 03              UART read (keyboard)
    constant KBD_SEL  : std_logic_vector(5 downto 0)  := "000011";

    -- 04              UART write (teleprint)
    constant TTY_SEL  : std_logic_vector(5 downto 0)  := "000100";

    -- 30->32          Timer registers
    constant TIM0_SEL : std_logic_vector(5 downto 0)  := "011000";
    constant TIM1_SEL : std_logic_vector(5 downto 0)  := "011001";
    constant TIM2_SEL : std_logic_vector(5 downto 0)  := "011010";

    -- 33              Output Register
    constant PRTA_SEL : std_logic_vector(5 downto 0)  := "011011";

    -- 34->35          Random number generator
    constant RAN0_SEL : std_logic_vector(5 downto 0)  := "011100";
    constant RAN1_SEL : std_logic_vector(5 downto 0)  := "011101";


    --================================================================
    -- Component definition section
    --================================================================

    --==================================
    -- PDP-8
    --==================================
    component IP_PDP8
    port (
          ADDR_OUT   : out std_logic_vector(11 downto 0);
          DATA_IN    : in  std_logic_vector(11 downto 0);
          DATA_OUT   : out std_logic_vector(11 downto 0);
          BANK_SEL   : out std_logic_vector( 2 downto 0);
          DEV_SEL    : out std_logic_vector( 5 downto 0);
          IOM        : out std_logic;   -- (0 = Memory) (1 = I/O)
          R_W        : out std_logic;   -- Read/Write (1=read 0=write)
          TRIG2      : out std_logic;   -- trigger (for debug)
          TRIG1      : out std_logic;   -- trigger (for debug)
          IORDY      : in  std_logic;   -- I/O ready status
          IRQ        : in  std_logic;   -- Interrupt Request (active-low)
          RESET      : in  std_logic;   -- Reset input       (active-low)
          FEN        : in  std_logic;   -- clock enable
          CLK        : in  std_logic    -- system clock
         );
    end component;


    --===============================
    -- UART (no handshake lines)
    --===============================
    component UART
    port (
          CS         : in  std_logic;  -- chip select
          WE         : in  std_logic;  -- write enable
          WR_DATA    : in  std_logic_vector(7 downto 0);  -- write data
          RD_DATA    : out std_logic_vector(7 downto 0);  -- read  data
          RX_RDY     : out std_logic;  -- RX ready
          TX_RDY     : out std_logic;  -- TX ready
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
          REG_SEL    : in  std_logic_vector(1 downto 0);  -- register address
          WR_DATA    : in  std_logic_vector(7 downto 0);  -- write data
          RD_DATA    : out std_logic_vector(7 downto 0);  -- read  data
          TM_DONE    : out std_logic;  -- timer done
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
    -- Boot RAM (4kx8)
    --=========================================
    component RAM
    port (
          RADDR     : in    std_logic_vector(12 downto 0);
          WADDR     : in    std_logic_vector(12 downto 0);
          DATA_IN   : in    std_logic_vector(11 downto 0);
          DATA_OUT  : out   std_logic_vector(11 downto 0);
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
    process(UART_DATA, TIMR_DATA, PRTA_DATA, RAND_DATA, TM_DONE,
            BOOT_DATA, PHASE, RX_RDY, TX_RDY, DEV_SEL, IOM, RW)
    begin

        UART_CS <= '0';
        TIMR_CS <= '0';
        PRTA_CS <= '0';
        RAND_CS <= '0';
        BOOT_RE <= '0';
        BOOT_WE <= '0';
        IO_WE   <= '0';
        UART_RD <= '0';
        IORDY   <= '0';
        DATA_IX <= BOOT_DATA;

        if (IOM = '0') then
            -- Boot RAM
            BOOT_RE <= PHASE(0) and RW;
            BOOT_WE <= PHASE(3) and not RW;
        else
            -- I/O devices
            case DEV_SEL is

                -- UART (read) registers
                when KBD_SEL =>
                    UART_CS <= '1';
                    IORDY   <= RX_RDY;
                    DATA_IX <= "0000" & UART_DATA;
                    UART_RD <= PHASE(3) and RW;

                -- UART (write) registers
                when TTY_SEL =>
                    UART_CS <= '1';
                    IORDY   <= TX_RDY;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Timer control register
                when TIM0_SEL =>
                    TIMR_CS <= '1';
                    IORDY   <= TM_DONE;
                    DATA_IX <= "0000" & TIMR_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Timer ICL register
                when TIM1_SEL =>
                    TIMR_CS <= '1';
                    DATA_IX <= "0000" & TIMR_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Timer ICH register
                when TIM2_SEL =>
                    TIMR_CS <= '1';
                    DATA_IX <= "0000" & TIMR_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Output Port
                when PRTA_SEL =>
                    PRTA_CS <= '1';
                    DATA_IX <= "0000" & PRTA_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Random Number control register
                when RAN0_SEL =>
                    RAND_CS <= '1';
                    DATA_IX <= "0000" & RAND_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                -- Random Number mask register
                when RAN1_SEL =>
                    RAND_CS <= '1';
                    DATA_IX <= "0000" & RAND_DATA;
                    IO_WE   <= PHASE(3) and IOM and not RW;

                when others =>

            end case;
        end if;
    end process;

    BOOT_ADDR <= BANK_SEL(0) & ADDR_OUT;
    IO_RESET  <= not RESET;
    PORTA <= PRTA_DATA;
    IRQ   <= '1';

    --=========================================
    -- Instantiate the PDP-8
    --=========================================
    UPROC:
    IP_PDP8 port map (
          ADDR_OUT   => ADDR_OUT,
          DATA_IN    => DATA_IX,
          DATA_OUT   => DATA_OX,
          BANK_SEL   => BANK_SEL,
          DEV_SEL    => DEV_SEL,
          IOM        => IOM,
          R_W        => RW,
          TRIG2      => TRIG2,
          TRIG1      => TRIG1,
          IORDY      => IORDY,
          IRQ        => IRQ,
          RESET      => RESET,
          FEN        => FEN,
          CLK        => FCLK
      );


    --===========================================
    -- Instantiate the UART
    --===========================================
    UART1:
    UART port map (
          CS         => UART_CS,
          WE         => IO_WE,
          WR_DATA    => DATA_OX(7 downto 0),
          RD_DATA    => UART_DATA,
          RX_RDY     => RX_RDY,
          TX_RDY     => TX_RDY,
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
          REG_SEL    => DEV_SEL(1 downto 0),
          WR_DATA    => DATA_OX(7 downto 0),
          RD_DATA    => TIMR_DATA,
          TM_DONE    => TM_DONE,
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
          REG_SEL    => DEV_SEL(0),
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
          RADDR      => BOOT_ADDR,
          WADDR      => BOOT_ADDR,
          DATA_IN    => DATA_OX,
          DATA_OUT   => BOOT_DATA,
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

