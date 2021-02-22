
--======================================================================
-- pdp11.vhd ::  PDP-11 instruction-set compatible microprocessor
--======================================================================
--
--  The PDP-11 series was an extremely successful and influential
--  family of machines designed at Digital Equipment Corporation (DEC)
--  The first PDP-11 (/20) was designed in the early 1970's and the
--  PDP-11 family prospered for over two decades through the mid 1990s.
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.my_types.all;


entity IP_PDP11 is
    port (
          ADDR_OUT   : out std_logic_vector(15 downto 0);
          DATA_IN    : in  std_logic_vector(15 downto 0);
          DATA_OUT   : out std_logic_vector(15 downto 0);

          R_W        : out std_logic;   -- 1==read 0==write
          BYTE       : out std_logic;   -- Byte memory operation
          SYNC       : out std_logic;   -- Opcode fetch status

          IRQ0       : in  std_logic;   -- Interrupt (active-low)
          IRQ1       : in  std_logic;   -- Interrupt (active-low)
          IRQ2       : in  std_logic;   -- Interrupt (active-low)
          IRQ3       : in  std_logic;   -- Interrupt (active-low)

          RDY        : in  std_logic;   -- Ready input
          RESET      : in  std_logic;   -- Reset input (active-low)
          FEN        : in  std_logic;   -- clock enable
          CLK        : in  std_logic;   -- system clock

          DBUG7      : out std_logic;   -- for debug
          DBUG6      : out std_logic;   -- for debug
          DBUG5      : out std_logic;   -- for debug
          DBUG4      : out std_logic;   -- for debug
          DBUG3      : out std_logic;   -- for debug
          DBUG2      : out std_logic;   -- for debug
          DBUG1      : out std_logic    -- for debug
         );
end IP_PDP11;


architecture BEHAVIORAL of IP_PDP11 is


    --=================================================================
    -- Types, component, and signal definitions
    --=================================================================

    signal  STATE       : UCODE_STATE_TYPE;
    signal  NEXT_STATE  : UCODE_STATE_TYPE;

    signal  C_OPCODE    : CNT_OP_TYPE;     -- count register micro-op
    signal  T_OPCODE    : REG_OP_TYPE;     -- temp register  micro-op
    signal  S_OPCODE    : REG_OP_TYPE;     -- src operand micro-op
    signal  D_OPCODE    : REG_OP_TYPE;     -- dst operand micro-op
    signal  SA_OPCODE   : REG_OP_TYPE;     -- src address micro-op
    signal  DA_OPCODE   : REG_OP_TYPE;     -- dst address micro-op
    signal  ALU_OPCODE  : ALU_OP_TYPE;     -- ALU micro-op
    signal  SX_OPCODE   : SX_OP_TYPE;      -- Address micro-op

    signal  R0_OPCODE   : PC_OP_TYPE;      -- R0 micro-op
    signal  R1_OPCODE   : PC_OP_TYPE;      -- R1 micro-op
    signal  R2_OPCODE   : PC_OP_TYPE;      -- R2 micro-op
    signal  R3_OPCODE   : PC_OP_TYPE;      -- R3 micro-op
    signal  R4_OPCODE   : PC_OP_TYPE;      -- R4 micro-op
    signal  R5_OPCODE   : PC_OP_TYPE;      -- R5 micro-op
    signal  SP_OPCODE   : REG_OP_TYPE;     -- SP micro-op
    signal  PC_OPCODE   : PC_OP_TYPE;      -- PC micro-op

    -- Internal busses
    signal ABUS         : std_logic_vector(15 downto 0);  -- ALU  operand A bus
    signal BBUS         : std_logic_vector(15 downto 0);  -- ALU  operand B bus
    signal RBUS         : std_logic_vector(15 downto 0);  -- ALU  result bus
    signal SX           : std_logic_vector(15 downto 0);  -- Addr result bus
    signal ADDR_OX      : std_logic_vector(15 downto 0);  -- Internal addr bus
    signal DATA_OX      : std_logic_vector(15 downto 0);  -- Internal data bus
    signal BYTE_DATA    : std_logic_vector(15 downto 0);  -- Byte_op data

    signal ASEL         : ASEL_TYPE;
    signal BSEL         : BSEL_TYPE;

    -- Address Decoding
    signal MACRO_OP     : MACRO_OP_TYPE;     -- macro opcode
    signal BYTE_OP      : std_logic;
    signal BYTE_ALU     : std_logic;
    signal FORMAT_OP    : std_logic_vector( 2 downto 0);
    signal FORMAT       : std_logic_vector( 2 downto 0);
    signal SRC_MODE     : std_logic_vector( 2 downto 0);
    signal SRC_RSEL     : std_logic_vector( 2 downto 0);
    signal SRC_LOAD     : std_logic;
    signal DST_MODE     : std_logic_vector( 2 downto 0);
    signal DST_RSEL     : std_logic_vector( 2 downto 0);
    signal DST_LOAD     : std_logic;

    -- Architectural registers
    signal R0           : std_logic_vector(15 downto 0);  -- register 0
    signal R1           : std_logic_vector(15 downto 0);  -- register 1
    signal R2           : std_logic_vector(15 downto 0);  -- register 2
    signal R3           : std_logic_vector(15 downto 0);  -- register 3
    signal R4           : std_logic_vector(15 downto 0);  -- register 4
    signal R5           : std_logic_vector(15 downto 0);  -- register 5
    signal SP           : std_logic_vector(15 downto 0);  -- stack pointer
    signal PC           : std_logic_vector(15 downto 0);  -- program counter
    signal PSW          : std_logic_vector( 3 downto 0);  -- status word
    signal T            : std_logic_vector(15 downto 0);  -- temp register
    signal SA           : std_logic_vector(15 downto 0);  -- src address
    signal DA           : std_logic_vector(15 downto 0);  -- dst address
    signal S            : std_logic_vector(15 downto 0);  -- src operand
    signal D            : std_logic_vector(15 downto 0);  -- dst operand
    signal SMUX         : std_logic_vector(15 downto 0);  -- src operand
    signal DMUX         : std_logic_vector(15 downto 0);  -- dst operand
    signal OPREG        : std_logic_vector(15 downto 0);  -- opcode reg

    -- Status flag update
    signal UPDATE_N     : std_logic;  -- update sign flag
    signal UPDATE_Z     : std_logic;  -- update zero flag
    signal UPDATE_V     : std_logic;  -- update overflow flag
    signal UPDATE_C     : std_logic;  -- update carry flag
    signal UPDATE_XC    : std_logic;  -- update aux carry flag

    signal SET_N        : std_logic;  -- set   N flag
    signal SET_C        : std_logic;  -- set   C flag
    signal SET_V        : std_logic;  -- set   V flag
    signal SET_Z        : std_logic;  -- set   Z flag
    signal CLR_N        : std_logic;  -- clear N flag
    signal CLR_C        : std_logic;  -- clear C flag
    signal CLR_V        : std_logic;  -- clear V flag
    signal CLR_Z        : std_logic;  -- clear Z flag
    signal CCC_OP       : std_logic;  -- conditional clear
    signal SCC_OP       : std_logic;  -- conditional set

    -- Arithmetic Status
    signal CARRY        : std_logic;  -- ALU carry-out
    signal ZERO         : std_logic;  -- ALU Zero status
    signal OVERFLOW     : std_logic;  -- ALU overflow
    signal SIGNBIT      : std_logic;  -- ALU sign bit
    signal XC           : std_logic;  -- ALU carry-out

    -- Interrupt Status flip-flops
    signal IRQ_FF       : std_logic;  -- IRQ flip-flop
    signal CLR_IRQ      : std_logic;  -- clear IRQ flip-flop
    signal IRQ_MASK     : std_logic_vector( 3 downto 0);
    signal IRQ_VEC      : std_logic_vector( 3 downto 0);

    -- Misc
    signal MY_RESET     : std_logic;  -- active high reset
    signal FETCH_FF     : std_logic;  -- fetch cycle flag
    signal READING      : std_logic;  -- R/W status
    signal CONDITION    : std_logic;  -- branch condition
    signal INT_OK       : std_logic;  -- interrupt level OK
    signal INIT_MPY     : std_logic;  -- for multiply
    signal MPY_STEP     : std_logic;  -- for multiply
    signal INIT_DIV     : std_logic;  -- for divide
    signal DIV_STEP     : std_logic;  -- for divide
    signal DIV_LAST     : std_logic;  -- for divide
    signal DIV_OP       : std_logic;  -- for divide
    signal SA_SBIT      : std_logic;  -- for divide
    signal DIV_SBIT     : std_logic;  -- for divide
    signal D_SBIT       : std_logic;  -- for divide
    signal BYTE_FF      : std_logic;  -- byte flag
    signal SET_BYTE_FF  : std_logic;  -- set byte flag
    signal CLR_BYTE_FF  : std_logic;  -- clr byte flag
    signal DEST_FF      : std_logic;  -- dest flag
    signal SET_DEST_FF  : std_logic;  -- set dest flag
    signal CLR_DEST_FF  : std_logic;  -- clr dest flag
    signal C            : std_logic_vector( 3 downto 0);
    signal JSE          : std_logic_vector( 6 downto 0);
    signal BRANCH_OP    : std_logic_vector( 3 downto 0);


    --================================================================
    -- Constant definition section
    --================================================================

    --================================================================
    -- Component definition section
    --================================================================

    --==========================
    -- instruction decoder
    --==========================
    component DECODE
    port (
        MACRO_OP    : out MACRO_OP_TYPE;                  -- opcode
        BYTE_OP     : out std_logic;                      -- byte/word
        FORMAT      : out std_logic_vector( 2 downto 0);  -- format
        IR          : in  std_logic_vector(15 downto 0)   -- inst reg
       );
    end component;


    --==============================
    -- 16-bit ALU 
    --==============================
    component ALU
    port (
          COUT     : out std_logic;                      -- carry out
          ZERO     : out std_logic;                      -- zero
          OVFL     : out std_logic;                      -- overflow
          SIGN     : out std_logic;                      -- sign
          RBUS     : out std_logic_vector(15 downto 0);  -- result bus
          A        : in  std_logic_vector(15 downto 0);  -- operand A
          B        : in  std_logic_vector(15 downto 0);  -- operand B
          OP       : in  ALU_OP_TYPE;                    -- micro op
          BYTE_OP  : in  std_logic;                      -- byte op
          DIV_OP   : in  std_logic;                      -- divide op
          DIV_SBIT : in  std_logic;                      -- divide sign bit
          CIN      : in  std_logic                       -- carry in
         );
    end component;


    --==============================
    -- 16-bit Address Adder
    --==============================
    component ADDR
    port (
          SX      : out std_logic_vector(15 downto 0);  -- result bus
          BX      : in  std_logic_vector(15 downto 0);  -- operand bus
          DISP    : in  std_logic_vector( 7 downto 0);  -- displacement
          OP      : in  SX_OP_TYPE                      -- micro op
         );
    end component;


    --==============================
    -- 4-bit Comparator
    --==============================
    component CMPR
    port (
          A_LE_B  : out std_logic;                      -- A <= B
          A       : in  std_logic_vector(3 downto 0);   -- operand A
          B       : in  std_logic_vector(3 downto 0)    -- operand B
         );
    end component;


    --================================================================
    -- End of types, component, and signal definition section
    --================================================================

begin

    --================================================================
    -- Start of the behavioral description
    --================================================================

    MY_RESET <= not RESET;

    --================================================================
    -- Microcode state machine
    --================================================================
    MICROCODE_STATE_MACHINE:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
            if ((FEN = '1') and (RDY = '1')) then
                STATE <= NEXT_STATE;
                -- reset state
                if (MY_RESET = '1') then
                    STATE <= RST_1;
                end if;
            end if;
        end if;
    end process;


    --================================================================
    -- Signals for Debug
    --================================================================

    DBUG1 <= '1';
    DBUG2 <= '1';
    DBUG3 <= '1';
    DBUG4 <= '1';
    DBUG5 <= '1';
    DBUG6 <= '1';
    DBUG7 <= MY_RESET;


    --================================================================
    -- Register IRQ (active-low) inputs
    --================================================================
    INTERRUPT_STATUS_REGISTERS:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            -- Only set the IRQ flip-flop if the interrupt level
            -- is less than or equal to the interrupt mask
            if ((IRQ0 = '0') and (INT_OK = '1')) then
                IRQ_FF  <= '1';
            end if;
            if (CLR_IRQ = '1') then
                IRQ_FF <= '0';
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            IRQ_FF   <= '0';
            IRQ_VEC  <= (others => '0');
            IRQ_MASK <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Opcode Register
    --================================================================
    OPCODE_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            if (STATE = FETCH_OPCODE) then
                OPREG <= DATA_IN;
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            OPREG <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Fetch cycle flag
    --================================================================
    FETCH_CYCLE_FLAG:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            FETCH_FF <= '0';
            if (NEXT_STATE = FETCH_OPCODE) then
                FETCH_FF <= '1';
            end if;
        end if;
        end if;
    end process;


    --================================================================
    -- byte flag
    --================================================================
    BYTE_FLAG:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            if (SET_BYTE_FF = '1') then
                BYTE_FF <= '1';
            end if;
            if (CLR_BYTE_FF = '1') then
                BYTE_FF <= '0';
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            BYTE_FF <= '0';
        end if;
    end process;

    BYTE <= BYTE_FF;

    --================================================================
    -- dest flag
    --================================================================
    DEST_FLAG:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            if (SET_DEST_FF = '1') then
                DEST_FF <= '1';
            end if;
            if (CLR_DEST_FF = '1') then
                DEST_FF <= '0';
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            DEST_FF <= '0';
        end if;
    end process;


    --================================================================
    -- modify format to reuse code
    --================================================================
    MODIFY_FORMAT:
    process(FORMAT_OP, DEST_FF)
    begin
        FORMAT <= FORMAT_OP;
        -- force TWO_OPERAND to become ONE_OPERAND
        if (DEST_FF = '1') then
            FORMAT(0) <= '0';
        end if;
    end process;

    SYNC      <= FETCH_FF;
    ADDR_OUT  <= ADDR_OX;

    BRANCH_OP <= OPREG(15) & OPREG(10 downto 8);
    SRC_MODE  <= OPREG(11 downto 9);
    SRC_RSEL  <= OPREG( 8 downto 6);
    DST_MODE  <= OPREG( 5 downto 3);
    DST_RSEL  <= OPREG( 2 downto 0);

    --================================================================
    -- Micro-operation and next-state generation
    --================================================================
    MICRO_OP_AND_NEXT_STATE_GENERATION:
    process(MACRO_OP, FORMAT, STATE, PC, SP, SA, DA, T, XC, C, PSW,
            SRC_MODE, SRC_RSEL, DST_MODE, DST_RSEL, RBUS, DMUX, SMUX,
            SA_SBIT, D_SBIT, BYTE_OP, BYTE_FF, IRQ_FF, CONDITION,
            SRC_LOAD, DST_LOAD)
    begin

        -- default micro-ops
        R0_OPCODE  <= HOLD;
        R1_OPCODE  <= HOLD;
        R2_OPCODE  <= HOLD;
        R3_OPCODE  <= HOLD;
        R4_OPCODE  <= HOLD;
        R5_OPCODE  <= HOLD;
        SP_OPCODE  <= HOLD;
        PC_OPCODE  <= HOLD;
        SA_OPCODE  <= HOLD;
        DA_OPCODE  <= HOLD;
        S_OPCODE   <= HOLD;
        D_OPCODE   <= HOLD;
        C_OPCODE   <= HOLD;
        T_OPCODE   <= HOLD;
        ALU_OPCODE <= OP_INCA1;
        SX_OPCODE  <= OP_INC2;

        -- default flag control
        UPDATE_N   <= '0';  -- update sign flag
        UPDATE_Z   <= '0';  -- update zero flag
        UPDATE_V   <= '0';  -- update overflow flag
        UPDATE_C   <= '0';  -- update carry flag
        UPDATE_XC  <= '0';  -- update carry flag
        CLR_IRQ    <= '0';  -- clear IRQ_FF
        SET_N      <= '0';  -- set   N flag
        SET_C      <= '0';  -- set   C flag
        SET_V      <= '0';  -- set   V flag
        SET_Z      <= '0';  -- set   Z flag
        CLR_N      <= '0';  -- clear N flag
        CLR_C      <= '0';  -- clear C flag
        CLR_V      <= '0';  -- clear V flag
        CLR_Z      <= '0';  -- clear Z flag
        CCC_OP     <= '0';  -- conditional clear
        SCC_OP     <= '0';  -- conditional set
        BYTE_ALU   <= '0';  -- ALU byte operation

        NEXT_STATE   <= FETCH_OPCODE;
        DATA_OX      <= RBUS;
        ADDR_OX      <= PC;
        DST_LOAD     <= '0';
        SRC_LOAD     <= '0';
        READING      <= '1';
        ASEL         <= SEL_PC;
        BSEL         <= SEL_D;
        SET_BYTE_FF  <= '0';
        CLR_BYTE_FF  <= '0';
        SET_DEST_FF  <= '0';
        CLR_DEST_FF  <= '0';
        INIT_MPY     <= '0';
        INIT_DIV     <= '0';
        MPY_STEP     <= '0';
        DIV_STEP     <= '0';
        DIV_LAST     <= '0';
        DIV_SBIT     <= D_SBIT;

        case STATE is

            --============================================
            -- Reset startup sequence
            --============================================
            when RST_1 =>
                -- Stay here until reset is de-bounced
                NEXT_STATE <= FETCH_OPCODE;

            when IRQ_1 =>
                -- fix me !!!!
                -- lot's of stuff missing here
                ALU_OPCODE <= OP_TA;
                T_OPCODE   <= LOAD_FROM_ALU;
                CLR_IRQ    <= '1';
                NEXT_STATE <= FETCH_OPCODE;


            --============================================
            -- Fetch Opcode State
            --============================================
            when FETCH_OPCODE =>

                if (IRQ_FF = '1') then
                    -- handle the interrupt
                    NEXT_STATE <= IRQ_1;
                else
                    -- increment the PC
                    SX_OPCODE  <= OP_INC2;
                    PC_OPCODE  <= LOAD_FROM_SX;
                    NEXT_STATE <= GOT_OPCODE;
                end if;
                CLR_BYTE_FF <= '1';


            --============================================
            -- Opcode register contains an opcode
            --============================================
            when GOT_OPCODE =>

                if (BYTE_OP = '1') then
                    SET_BYTE_FF <= '1';
                else
                    CLR_BYTE_FF <= '1';
                end if;

                case FORMAT is

                    --=================================
                    -- One operand Instruction Format
                    --=================================
                    when ONE_OPERAND =>

                        -- destination address mode calculations
                        case DST_MODE(2 downto 1) is

                        -- register
                        when "00" =>
                            -- check deferred bit
                            if (DST_MODE(0) = '0') then
                                -- load from register
                                D_OPCODE   <= LOAD_FROM_REG;
                                NEXT_STATE <= EXEC_OPCODE;
                            else
                                -- deferred
                                DA_OPCODE  <= LOAD_FROM_REG;
                                NEXT_STATE <= DST_RI1;
                            end if;

                        -- post-increment
                        when "01" =>
                            ADDR_OX <= DMUX;
                            -- check deferred bit
                            if (DST_MODE(0) = '0') then
                                D_OPCODE   <= LOAD_FROM_MEM;
                                DA_OPCODE  <= LOAD_FROM_REG;
                                NEXT_STATE <= DST_PI1;
                            else
                                -- deferred
                                DA_OPCODE  <= LOAD_FROM_MEM;
                                NEXT_STATE <= DST_PI2;
                            end if;

                        -- pre-decrement
                        when "10" =>
                            ASEL <= SEL_DMUX;
                            ALU_OPCODE <= OP_DECA2;
                            if (BYTE_OP = '1') then
                                ALU_OPCODE <= OP_DECA1;
                            end if;
                            DST_LOAD <= '1';
                            DA_OPCODE <= LOAD_FROM_ALU;
                            NEXT_STATE <= DST_PD1;

                        -- indexed ("11")
                        when others =>
                            -- get the next word
                            ADDR_OX <= PC;
                            D_OPCODE <= LOAD_FROM_MEM;
                            -- increment the PC
                            SX_OPCODE  <= OP_INC2;
                            PC_OPCODE  <= LOAD_FROM_SX;
                            NEXT_STATE <= DST_X1;

                        end case;


                    --=======================================================
                    -- Two operands instruction Format
                    --=======================================================
                    when TWO_OPERAND =>

                        -- allow dest code reuse
                        SET_DEST_FF <= '1';

                        -- source address mode calculations
                        case SRC_MODE(2 downto 1) is

                        -- register
                        when "00" =>
                            if (SRC_MODE(0) = '0') then
                                -- load from register
                                S_OPCODE   <= LOAD_FROM_REG;
                                NEXT_STATE <= GOT_OPCODE;
                            else
                                -- deferred
                                SA_OPCODE  <= LOAD_FROM_REG;
                                NEXT_STATE <= SRC_RI1;
                            end if;

                        -- post-increment
                        when "01" =>
                            ADDR_OX <= SMUX;
                            -- check deferred bit
                            if (SRC_MODE(0) = '0') then
                                S_OPCODE   <= LOAD_FROM_MEM;
                                SA_OPCODE  <= LOAD_FROM_REG;
                                NEXT_STATE <= SRC_PI1;
                            else
                                -- deferred
                                SA_OPCODE  <= LOAD_FROM_MEM;
                                NEXT_STATE <= SRC_PI2;
                            end if;

                        -- pre-decrement
                        when "10" =>
                            ASEL <= SEL_SMUX;
                            ALU_OPCODE <= OP_DECA2;
                            if (BYTE_OP = '1') then
                                ALU_OPCODE <= OP_DECA1;
                            end if;
                            SRC_LOAD <= '1';
                            SA_OPCODE <= LOAD_FROM_ALU;
                            NEXT_STATE <= SRC_PD1;

                        -- indexed ("11")
                        when others =>
                            -- get the next word
                            ADDR_OX <= PC;
                            S_OPCODE <= LOAD_FROM_MEM;
                            -- increment the PC
                            SX_OPCODE  <= OP_INC2;
                            PC_OPCODE  <= LOAD_FROM_SX;
                            NEXT_STATE <= SRC_X1;

                        end case;


                    --=================================
                    -- Branch Instruction Format
                    --=================================
                    when BRA_FORMAT =>

                        SX_OPCODE  <= OP_REL;
                        if (CONDITION = '1') then
                            PC_OPCODE <= LOAD_FROM_SX;
                        end if;
                        NEXT_STATE <= FETCH_OPCODE;


                    --======================================
                    -- Floating Point Instruction Format
                    --======================================
                    when FLOAT =>
                        -- not implemented
                        PC_OPCODE  <= HOLD;
                        NEXT_STATE <= UII_1;


                    --======================================
                    -- Implied-Operand Instruction Format
                    --======================================
                    when others =>


                        case MACRO_OP is

                            when MOP_HALT =>
                                -- halt processor
                                NEXT_STATE <= HALT_1;

                            when MOP_WAIT =>
                                -- wait for interrupt
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_RESET =>
                                -- reset bus
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_RTS =>
                                -- return from subroutine
                                -- load the PC from the link reg
                                ASEL <= SEL_DMUX;
                                ALU_OPCODE <= OP_TA;
                                PC_OPCODE  <= LOAD_FROM_ALU;
                                NEXT_STATE <= RTS_1;
                                -- special case when PC is link reg
                                if (DST_RSEL = "111") then
                                    -- load the PC from the stack
                                    ADDR_OX <= SP;
                                    PC_OPCODE <= LOAD_FROM_MEM;
                                    -- post-increment the stack pointer
                                    ASEL <= SEL_SP;
                                    ALU_OPCODE <= OP_INCA2;
                                    SP_OPCODE  <= LOAD_FROM_ALU;
                                    NEXT_STATE <= FETCH_OPCODE;
                                end if;

                            when MOP_RTI =>
                                -- return from interrupt
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_RTT =>
                                -- return from interrupt
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MARK =>
                                -- mark stack
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_TRAP =>
                                -- SW trap
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_BPT =>
                                -- breakpoint trap
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_IOT =>
                                -- I/O trap
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_EMT =>
                                -- emulator trap
                                -- not implemented yet !!!
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_SEN =>
                                -- set N flag
                                SET_N <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_SEC =>
                                -- set C flag
                                SET_C <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_SEV =>
                                -- set V flag
                                SET_V <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_SEZ =>
                                -- set Z flag
                                SET_Z <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CLN =>
                                -- clear N flag
                                CLR_N <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CLC =>
                                -- clear C flag
                                CLR_C <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CLV =>
                                -- clear V flag
                                CLR_V <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CLZ =>
                                -- clear Z flag
                                CLR_Z <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CCC =>
                                -- clear condition codes
                                CCC_OP <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_SCC =>
                                -- set condition codes
                                SCC_OP <= '1';
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_CSM =>
                                -- call supervisor mode
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MFPT =>
                                -- move from processor type
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MFPI =>
                                -- move from prev I-space
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MTPI =>
                                -- move to prev I-space
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MFPD =>
                                -- move to prev D-space
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MTPD =>
                                -- move to prev D-space
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MTPS =>
                                -- move to processor status
                                NEXT_STATE <= FETCH_OPCODE;

                            when MOP_MFPS =>
                                -- move from processor status
                                NEXT_STATE <= FETCH_OPCODE;

                            when others =>
                                -- unimplemented instruction
                                NEXT_STATE <= FETCH_OPCODE;

                        end case;


                end case;  -- end of instruction format case


            --====================================================
            -- We have the operands, now execute the instruction
            --====================================================
            when EXEC_OPCODE =>

                CLR_DEST_FF <= '1';
                BYTE_ALU <= BYTE_OP;

                case MACRO_OP is

                    --=================================
                    -- Jump Instructions
                    --=================================

                    -- Jump
                    when MOP_JMP =>
                        PC_OPCODE  <= LOAD_FROM_DA;
                        NEXT_STATE <= FETCH_OPCODE;

                    -- Jump to Subroutine
                    when MOP_JSR =>
                        -- pre-decrement the stack pointer
                        ASEL <= SEL_SP;
                        ALU_OPCODE <= OP_DECA2;
                        SP_OPCODE  <= LOAD_FROM_ALU;
                        NEXT_STATE <= JSR_1;


                    --=================================
                    -- One-operand Instructions
                    --=================================

                    -- Test
                    when MOP_TST =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_TA;
                        D_OPCODE   <= HOLD;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        CLR_V      <= '1';  -- clear overflow flag
                        CLR_C      <= '1';  -- clear carry flag
                        NEXT_STATE <= FETCH_OPCODE;

                    -- Bit Test
                    when MOP_BIT =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_AND;
                        D_OPCODE   <= HOLD;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        CLR_V      <= '1';      -- clear overflow flag
                        NEXT_STATE <= FETCH_OPCODE;

                    -- Clear
                    when MOP_CLR =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ZERO;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        CLR_N <= '1';  -- clear sign flag
                        SET_Z <= '1';  -- set zero flag
                        CLR_V <= '1';  -- clear overflow flag
                        CLR_C <= '1';  -- clear carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Sign Extend
                    when MOP_SXT =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ZERO;
                        -- check the sign bit
                        if (PSW(3) = '1') then
                            ALU_OPCODE <= OP_ONES;
                        end if;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        CLR_N <= '1';  -- clear sign flag
                        SET_Z <= '1';  -- set zero flag
                        CLR_V <= '1';  -- clear overflow flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Ones Complement
                    when MOP_COM =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_INV;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        CLR_V      <= '1';  -- clear overflow flag
                        SET_C      <= '1';  -- set carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Decrement by 1
                    when MOP_DEC =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_DECA1;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Increment by 1
                    when MOP_INC =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_INCA1;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Negate
                    when MOP_NEG =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_NEG;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Swap Bytes
                    when MOP_SWAB =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_SWP;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        CLR_V      <= '1';  -- clear overflow flag
                        CLR_C      <= '1';  -- clear carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Rotate Right
                    when MOP_ROR =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ROR;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Rotate Left
                    when MOP_ROL =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ROL;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Shift Right
                    when MOP_ASR =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ASR;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Shift Left
                    when MOP_ASL =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ASL;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';  -- update sign flag
                        UPDATE_Z   <= '1';  -- update zero flag
                        UPDATE_V   <= '1';  -- update overflow flag
                        UPDATE_C   <= '1';  -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;


                    --=================================
                    -- Two-operand Instructions
                    --=================================

                    -- Add
                    when MOP_ADD =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_ADD;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        UPDATE_V   <= '1';      -- update overflow flag
                        UPDATE_C   <= '1';      -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Add Carry
                    when MOP_ADC =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_ADC;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        UPDATE_V   <= '1';      -- update overflow flag
                        UPDATE_C   <= '1';      -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Subtract
                    when MOP_SUB =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_SUBA;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        UPDATE_V   <= '1';      -- update overflow flag
                        UPDATE_C   <= '1';      -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Subtract Carry
                    when MOP_SBC =>
                        ASEL <= SEL_D;
                        ALU_OPCODE <= OP_SBC;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        UPDATE_V   <= '1';      -- update overflow flag
                        UPDATE_C   <= '1';      -- update carry flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Compare
                    when MOP_CMP =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_SUBA;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        UPDATE_V   <= '1';      -- update overflow flag
                        UPDATE_C   <= '1';      -- update carry flag
                        NEXT_STATE <= FETCH_OPCODE;

                    -- Move
                    when MOP_MOV =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_TA;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        CLR_V      <= '1';      -- clear overflow flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Exclusive OR
                    when MOP_XOR =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_XOR;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_Z   <= '1';      -- update zero flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Bit Clear
                    when MOP_BIC =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_BIC;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        CLR_V      <= '1';      -- clear overflow flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Bit Set
                    when MOP_BIS =>
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_OR;
                        D_OPCODE   <= LOAD_FROM_ALU;
                        UPDATE_N   <= '1';      -- update sign flag
                        UPDATE_Z   <= '1';      -- update zero flag
                        CLR_V      <= '1';      -- clear overflow flag
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Multiply
                    when MOP_MUL =>
                        -- multiplicand is in D
                        -- multiplier   is in S
                        -- accumulate product in T:SA
                        -- clear T and SA
                        -- load C with the MPY count
                        INIT_MPY   <= '1';
                        if (DST_MODE = "000") then
                            -- store to register
                            DST_LOAD <= '1';
                            NEXT_STATE <= FETCH_OPCODE;
                        else
                            -- store to destination address
                            NEXT_STATE <= STORE_D;
                        end if;

                    -- Divide
                    when MOP_DIV =>
                        -- the divisor  is in S
                        -- the dividend is in D:T
                        -- the quotient  will be in T
                        -- the remainder will be left in D
                        -- compare D and S
                        ASEL <= SEL_S;
                        BSEL <= SEL_D;
                        ALU_OPCODE <= OP_SUBA;
                        INIT_DIV   <= '1';
                        UPDATE_XC  <= '1';  -- update aux carry flag
                        SA_OPCODE  <= LOAD_FROM_ALU;
                        NEXT_STATE <= DIV_1;


                    when others =>
                        PC_OPCODE  <= HOLD;
                        NEXT_STATE <= UII_1;

                end case;  -- end of MACRO_OP case


            --============================================
            -- Complete destination register indirect
            --============================================
            when DST_RI1 =>
                ADDR_OX <= DA;
                D_OPCODE <= LOAD_FROM_MEM;
                NEXT_STATE <= EXEC_OPCODE;


            --============================================
            -- Complete source register indirect
            --============================================
            when SRC_RI1 =>
                ADDR_OX <= SA;
                S_OPCODE <= LOAD_FROM_MEM;
                NEXT_STATE <= GOT_OPCODE;


            --============================================
            -- Complete destination post increment
            --============================================
            when DST_PI1 =>
                if (DST_RSEL = "111") then
                    -- increment the PC
                    SX_OPCODE  <= OP_INC2;
                    PC_OPCODE  <= LOAD_FROM_SX;
                else
                    -- post-increment the register
                    ASEL <= SEL_DMUX;
                    ALU_OPCODE <= OP_INCA2;
                    if (BYTE_FF = '1') then
                        ALU_OPCODE <= OP_INCA1;
                    end if;
                    DST_LOAD <= '1';
                end if;
                NEXT_STATE <= EXEC_OPCODE;


            --============================================
            -- Complete destination post indirect
            --============================================
            when DST_PI2 =>
                ADDR_OX <= DA;
                D_OPCODE <= LOAD_FROM_MEM;
                NEXT_STATE <= DST_PI1;


            --============================================
            -- Complete source post increment
            --============================================
            when SRC_PI1 =>
                if (SRC_RSEL = "111") then
                    -- increment the PC
                    SX_OPCODE  <= OP_INC2;
                    PC_OPCODE  <= LOAD_FROM_SX;
                else
                    -- post-increment the register
                    ASEL <= SEL_SMUX;
                    ALU_OPCODE <= OP_INCA2;
                    if (BYTE_FF = '1') then
                        ALU_OPCODE <= OP_INCA1;
                    end if;
                    SRC_LOAD <= '1';
                end if;
                NEXT_STATE <= GOT_OPCODE;


            --============================================
            -- Complete source post indirect
            --============================================
            when SRC_PI2 =>
                ADDR_OX <= SA;
                S_OPCODE <= LOAD_FROM_MEM;
                NEXT_STATE <= SRC_PI1;


            --============================================
            -- Complete destination pre decrement
            --============================================
            when DST_PD1 =>
                ADDR_OX <= DA;
                -- check deferred bit
                if (DST_MODE(0) = '0') then
                    D_OPCODE   <= LOAD_FROM_MEM;
                    NEXT_STATE <= EXEC_OPCODE;
                else
                    -- deferred
                    DA_OPCODE  <= LOAD_FROM_MEM;
                    NEXT_STATE <= DST_RI1;
                end if;


            --============================================
            -- Complete source pre decrement
            --============================================
            when SRC_PD1 =>
                ADDR_OX <= SA;
                -- check deferred bit
                if (DST_MODE(0) = '0') then
                    S_OPCODE   <= LOAD_FROM_MEM;
                    NEXT_STATE <= GOT_OPCODE;
                else
                    -- deferred
                    SA_OPCODE  <= LOAD_FROM_MEM;
                    NEXT_STATE <= SRC_RI1;
                end if;


            --============================================
            -- Complete destination indexed address
            --============================================
            when DST_X1 =>
                -- add D + R
                ASEL <= SEL_D;      -- D
                BSEL <= SEL_DMUX;   -- R
                ALU_OPCODE <= OP_ADD;
                DA_OPCODE <= LOAD_FROM_ALU;
                NEXT_STATE <= DST_X2;


            --============================================
            -- Complete destination indexed address
            --============================================
            when DST_X2 =>
                ADDR_OX <= DA;
                -- check deferred bit
                if (DST_MODE(0) = '0') then
                    D_OPCODE   <= LOAD_FROM_MEM;
                    NEXT_STATE <= EXEC_OPCODE;
                else
                    -- deferred
                    DA_OPCODE  <= LOAD_FROM_MEM;
                    NEXT_STATE <= DST_RI1;
                end if;


            --============================================
            -- Complete source indexed address
            --============================================
            when SRC_X1 =>
                -- add S + R
                ASEL <= SEL_S;      -- S
                BSEL <= SEL_SMUX;   -- R
                ALU_OPCODE <= OP_ADD;
                SA_OPCODE <= LOAD_FROM_ALU;
                NEXT_STATE <= SRC_X2;


            --============================================
            -- Complete source indexed address
            --============================================
            when SRC_X2 =>
                ADDR_OX <= SA;
                -- check deferred bit
                if (SRC_MODE(0) = '0') then
                    S_OPCODE   <= LOAD_FROM_MEM;
                    NEXT_STATE <= EXEC_OPCODE;
                else
                    -- deferred
                    SA_OPCODE  <= LOAD_FROM_MEM;
                    NEXT_STATE <= SRC_RI1;
                end if;


            --============================================
            -- Store the result
            --============================================
            when STORE_D =>
                -- store to the destination address
                ADDR_OX <= DA;
                ASEL <= SEL_D;
                ALU_OPCODE <= OP_TA;
                READING <= '0';
                NEXT_STATE <= FETCH_OPCODE;


            --============================================
            -- Halt the processor
            -- requires reboot or operator console input
            --============================================
            when HALT_1 =>
                PC_OPCODE  <= HOLD;
                NEXT_STATE <= HALT_1;


            --============================================
            -- Complete the JSR instruction
            --============================================
            when JSR_1 =>
                -- store the source register
                -- onto the stack
                ADDR_OX <= SP;
                READING  <= '0';
                ASEL <= SEL_SMUX;
                ALU_OPCODE <= OP_TA;
                NEXT_STATE <= JSR_2;
                -- special case when PC is link reg
                if (SRC_RSEL = "111") then
                    -- load the PC with the dest address
                    PC_OPCODE  <= LOAD_FROM_DA;
                    NEXT_STATE <= FETCH_OPCODE;
                end if;

            when JSR_2 =>
                -- copy the PC to the source register
                ASEL <= SEL_PC;
                ALU_OPCODE <= OP_TA;
                SRC_LOAD <= '1';
                -- load the PC with the dest address
                PC_OPCODE  <= LOAD_FROM_DA;
                NEXT_STATE <= FETCH_OPCODE;


            --============================================
            -- Complete the RTS instruction
            --============================================
            when RTS_1 =>
                -- load the PC from the stack
                ADDR_OX  <= SP;
                PC_OPCODE <= LOAD_FROM_MEM;
                -- post-increment the stack pointer
                ASEL <= SEL_SP;
                ALU_OPCODE <= OP_INCA2;
                SP_OPCODE  <= LOAD_FROM_ALU;
                NEXT_STATE <= FETCH_OPCODE;


            --============================================
            -- Complete the multiply instruction
            --============================================
            when MPY_1 =>
                -- if the multiplier bit is a 1
                -- then add the multiplicand to the product
                -- and shift product and multiplier right
                ASEL <= SEL_D;
                BSEL <= SEL_T;
                ALU_OPCODE <= OP_ADD;
                MPY_STEP   <= '1';
                -- decrement the loop count
                C_OPCODE <= DEC;
                NEXT_STATE <= MPY_1;
                -- Check if we are done
                if (C = "0000") then
                    NEXT_STATE <= MPY_2;
                end if;

            when MPY_2 =>
                -- store the upper product
                ADDR_OX <= DA;
                DATA_OX <= T;
                READING  <= '0';
                -- increment DA
                ASEL <= SEL_DA;
                ALU_OPCODE <= OP_INCA2;
                DA_OPCODE  <= LOAD_FROM_ALU;
                NEXT_STATE <= MPY_3;

            when MPY_3 =>
                -- store the lower product
                ADDR_OX <= DA;
                ASEL <= SEL_SA;
                ALU_OPCODE <= OP_TA;
                READING    <= '0';
                NEXT_STATE <= FETCH_OPCODE;


            --============================================
            -- Complete the divide instruction
            --============================================
            when DIV_1 =>
                -- increment DA
                ASEL <= SEL_DA;
                ALU_OPCODE <= OP_INCA2;
                DA_OPCODE  <= LOAD_FROM_ALU;
                NEXT_STATE <= DIV_2;
                -- if D > S then abort
                if (XC = '1') then
                    NEXT_STATE <= FETCH_OPCODE;
                end if;

            when DIV_2 =>
                -- get the lower dividend
                ADDR_OX <= DA;
                T_OPCODE <= LOAD_FROM_MEM;
                -- decrement DA
                ASEL <= SEL_DA;
                ALU_OPCODE <= OP_DECA2;
                DA_OPCODE  <= LOAD_FROM_ALU;
                NEXT_STATE <= DIV_3;

            when DIV_3 =>
                -- compare D and S
                ASEL <= SEL_S;
                BSEL <= SEL_D;
                -- Check if we need to restore
                if (XC = '1') then
                    DIV_SBIT <= SA_SBIT;
                    BSEL <= SEL_SA;
                end if;
                ALU_OPCODE <= OP_SUBA;
                UPDATE_XC  <= '1';  -- update aux carry flag
                DIV_STEP   <= '1';
                C_OPCODE   <= DEC;
                NEXT_STATE <= DIV_3;
                -- Check if we are done
                if (C = "0000") then
                    NEXT_STATE <= DIV_4;
                end if;

            when DIV_4 =>
                -- compare D and S
                ASEL <= SEL_S;
                BSEL <= SEL_D;
                -- Check if we need to restore
                if (XC = '1') then
                    DIV_SBIT <= SA_SBIT;
                    BSEL <= SEL_SA;
                end if;
                ALU_OPCODE <= OP_SUBA;
                UPDATE_XC  <= '1';  -- update aux carry flag
                DIV_LAST   <= '1';
                C_OPCODE   <= DEC;
                NEXT_STATE <= DIV_5;

            when DIV_5 =>
                -- store the quotient
                ADDR_OX <= DA;
                DATA_OX <= T;
                READING  <= '0';
                -- increment DA
                ASEL <= SEL_DA;
                ALU_OPCODE <= OP_INCA2;
                DA_OPCODE  <= LOAD_FROM_ALU;
                NEXT_STATE <= DIV_6;

            when DIV_6 =>
                -- store the remainder
                ADDR_OX <= DA;
                ASEL <= SEL_D;
                -- Check if we need to restore
                if (XC = '1') then
                    ASEL <= SEL_SA;
                end if;
                ALU_OPCODE <= OP_TA;
                READING    <= '0';
                NEXT_STATE <= FETCH_OPCODE;


            --=========================================
            -- Unimplemented Opcodes
            --=========================================
            when others =>
                PC_OPCODE  <= HOLD;
                NEXT_STATE <= UII_1;

        end case;  -- end of STATE case


        --=============================================
        -- Load Source register
        --=============================================
        if (SRC_LOAD = '1') then
            -- select register to load
            case SRC_RSEL is
                when "000" =>
                    R0_OPCODE <= LOAD_FROM_ALU;
                when "001" =>
                    R1_OPCODE <= LOAD_FROM_ALU;
                when "010" =>
                    R2_OPCODE <= LOAD_FROM_ALU;
                when "011" =>
                    R3_OPCODE <= LOAD_FROM_ALU;
                when "100" =>
                    R4_OPCODE <= LOAD_FROM_ALU;
                when "101" =>
                    R5_OPCODE <= LOAD_FROM_ALU;
                when "110" =>
                    SP_OPCODE <= LOAD_FROM_ALU;
                when "111" =>
                    PC_OPCODE <= LOAD_FROM_ALU;
                when others =>
            end case;
        end if;


        --=============================================
        -- Load Destination register
        --=============================================
        if (DST_LOAD = '1') then
            -- select register to load
            case DST_RSEL is
                when "000" =>
                    R0_OPCODE <= LOAD_FROM_ALU;
                when "001" =>
                    R1_OPCODE <= LOAD_FROM_ALU;
                when "010" =>
                    R2_OPCODE <= LOAD_FROM_ALU;
                when "011" =>
                    R3_OPCODE <= LOAD_FROM_ALU;
                when "100" =>
                    R4_OPCODE <= LOAD_FROM_ALU;
                when "101" =>
                    R5_OPCODE <= LOAD_FROM_ALU;
                when "110" =>
                    SP_OPCODE <= LOAD_FROM_ALU;
                when "111" =>
                    PC_OPCODE <= LOAD_FROM_ALU;
                when others =>
            end case;
        end if;

    end process;


    --================================================
    -- Destination register select
    --================================================
    DEST_REG_SELECT:
    process(DST_RSEL, R0, R1, R2, R3, R4, R5, SP, PC)
    begin
        case DST_RSEL is
            when "000" =>
                DMUX <= R0;
            when "001" =>
                DMUX <= R1;
            when "010" =>
                DMUX <= R2;
            when "011" =>
                DMUX <= R3;
            when "100" =>
                DMUX <= R4;
            when "101" =>
                DMUX <= R5;
            when "110" =>
                DMUX <= SP;
            when others =>
                DMUX <= PC;
        end case;
    end process;


    --================================================
    -- Source register select
    --================================================
    SRC_RSEL_SELECT:
    process(SRC_RSEL, R0, R1, R2, R3, R4, R5, SP, PC)
    begin
        case SRC_RSEL is
            when "000" =>
                SMUX <= R0;
            when "001" =>
                SMUX <= R1;
            when "010" =>
                SMUX <= R2;
            when "011" =>
                SMUX <= R3;
            when "100" =>
                SMUX <= R4;
            when "101" =>
                SMUX <= R5;
            when "110" =>
                SMUX <= SP;
            when others =>
                SMUX <= PC;
        end case;
    end process;


    --============================================
    -- Branch Condition Select
    --============================================
    BRANCH_CONDITION_SELECT:
    process(BRANCH_OP, PSW)
    begin
        CONDITION <= '0';

        case BRANCH_OP is

            when "0001" =>
                -- BR :: Unconditional
                CONDITION <= '1';

            when "0010" =>
                -- BNE :: Not Equal
                -- Zero = 0
                CONDITION <= not PSW(2);

            when "0011" =>
                -- BEQ :: Equal
                -- Zero = 1
                CONDITION <= PSW(2);

            when "0100" =>
                -- BGE :: Greater Than of Equal
                -- (Sign xor Overflow) = 0
                CONDITION <= not (PSW(3) xor PSW(1));

            when "0101" =>
                -- BLT :: Less Than
                -- (Sign xor Overflow) = 1
                CONDITION <= PSW(3) xor PSW(1);

            when "0110" =>
                -- BGT :: Greater Than
                -- (zero and (Sign xor Overflow)) = 0
                CONDITION <= not(PSW(2) or (PSW(3) xor PSW(1)));

            when "0111" =>
                -- BLE :: Less Than or Equal
                -- (zero and (Sign xor Overflow)) = 1
                CONDITION <= PSW(2) or (PSW(3) xor PSW(1));

            when "1000" =>
                -- BPL :: Plus
                -- Sign = 0
                CONDITION <= not PSW(3);

            when "1001" =>
                -- BMI :: Minus
                -- Sign = 1
                CONDITION <= PSW(3);

            when "1010" =>
                -- BHI :: Higher
                -- (Carry or Zero) = 0
                CONDITION <= not(PSW(2) or PSW(0));

            when "1011" =>
                -- BLOS :: Lower or same
                -- (Carry or Zero) = 1
                CONDITION <= PSW(2) or PSW(0);

            when "1100" =>
                -- BVC :: Overflow Clear
                -- Overflow = 0
                CONDITION <= not PSW(1);

            when "1101" =>
                -- BVS :: Overflow Set
                -- Overflow = 1
                CONDITION <= PSW(1);

            when "1110" =>
                -- BCC :: Carry clear
                -- Carry = 0
                CONDITION <= not PSW(0);

            when "1111" =>
                -- BCS :: Carry set
                -- Carry = 1
                CONDITION <= PSW(0);

            when others =>
                -- Never
                CONDITION <= '0';

        end case;

    end process;


    --==================================================
    -- A Mux
    --==================================================
    AMUX:
    process(ASEL, SA, DA, S, D, DMUX, SMUX, PSW, SP, PC)
    begin

        case ASEL is
            when SEL_SA =>
                ABUS <= SA;
            when SEL_DA =>
                ABUS <= DA;
            when SEL_S =>
                ABUS <= S;
            when SEL_D =>
                ABUS <= D;
            when SEL_DMUX =>
                ABUS <= DMUX;
            when SEL_SMUX =>
                ABUS <= SMUX;
            when SEL_PSW =>
                ABUS <= "000000000000" & PSW;
            when SEL_SP =>
                ABUS <= SP;
            when others =>
                ABUS <= PC;
        end case;

    end process;

    JSE <= (others => OPREG(7));

    --=========================================================
    -- B Mux
    --=========================================================
    BMUX:
    process(BSEL, SA, DMUX, SMUX, T, D)
    begin

        case BSEL is
            when SEL_SA =>
                BBUS <= SA;
            when SEL_DMUX =>
                BBUS <= DMUX;
            when SEL_SMUX =>
                BBUS <= SMUX;
            when SEL_T =>
                BBUS <= T;
            when others =>
                BBUS <= D;
        end case;

    end process;


    --=============================================
    -- Byte input data (swap memory data byte)
    --=============================================
    MEM_BYTE_DATA_IN:
    process (ADDR_OX(0), DATA_IN)
    begin
        BYTE_DATA <= "00000000" & DATA_IN(7 downto 0);
        if (ADDR_OX(0) = '1') then
            BYTE_DATA <= "00000000" & DATA_IN(15 downto 8);
        end if;
    end process;


    --=============================================
    -- Byte output data (swap memory data byte)
    --=============================================
    MEM_BYTE_DATA_OUT:
    process (BYTE_OP, ADDR_OX(0), DATA_OX)
    begin
        DATA_OUT <= DATA_OX;
        if ((BYTE_OP = '1') and (ADDR_OX(0) = '1')) then
            DATA_OUT(15 downto 8) <= DATA_OX(7 downto 0);
        end if;
    end process;


    --=======================================================
    -- External RAM Write Enable
    --=======================================================
    R_W <= READING;


    --=================================================
    -- Processor Status Register 
    --=================================================
    PSW_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then

            --===== Sign ========

            if (UPDATE_N = '1') then
                PSW(3) <= RBUS(15);
            end if;

            if (SET_N = '1') then
                PSW(3) <= '1';
            end if;

            if (CLR_N = '1') then
                PSW(3) <= '0';
            end if;

            if (CCC_OP = '1') then
                PSW(3) <= PSW(3) and not OPREG(3);
            end if;

            if (SCC_OP = '1') then
                PSW(3) <= PSW(3) or OPREG(3);
            end if;

            --===== Zero ========

            if (UPDATE_Z = '1') then
                PSW(2) <= ZERO;
            end if;

            if (SET_Z = '1') then
                PSW(2) <= '1';
            end if;

            if (CLR_Z = '1') then
                PSW(2) <= '0';
            end if;

            if (CCC_OP = '1') then
                PSW(2) <= PSW(2) and not OPREG(2);
            end if;

            if (SCC_OP = '1') then
                PSW(2) <= PSW(2) or OPREG(2);
            end if;

            --===== Overflow ========

            if (UPDATE_V = '1') then
                PSW(1) <= OVERFLOW;
            end if;

            if (SET_V = '1') then
                PSW(1) <= '1';
            end if;

            if (CLR_V = '1') then
                PSW(1) <= '0';
            end if;

            if (CCC_OP = '1') then
                PSW(1) <= PSW(1) and not OPREG(1);
            end if;

            if (SCC_OP = '1') then
                PSW(1) <= PSW(1) or OPREG(1);
            end if;

            --===== Carry ========

            if (UPDATE_C = '1') then
                PSW(0) <= CARRY;
            end if;

            if (SET_C = '1') then
                PSW(0) <= '1';
            end if;

            if (CLR_C = '1') then
                PSW(0) <= '0';
            end if;

            if (CCC_OP = '1') then
                PSW(0) <= PSW(0) and not OPREG(0);
            end if;

            if (SCC_OP = '1') then
                PSW(0) <= PSW(0) or OPREG(0);
            end if;

            --===== Aux Carry ========

            if (UPDATE_XC = '1') then
                XC <= CARRY;
            end if;

        end if;
        end if;

        -- reset state
        if (MY_RESET = '1') then
            PSW <= (others => '0');
            XC <= '0';
        end if;

    end process;


    --=======================
    -- Register R0
    --=======================
    REGISTER_R0:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R0_OPCODE is
                when LOAD_FROM_ALU =>
                    R0 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R0 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Register R1
    --=======================
    REGISTER_R1:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R1_OPCODE is
                when LOAD_FROM_ALU =>
                    R1 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R1 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Register R2
    --=======================
    REGISTER_R2:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R2_OPCODE is
                when LOAD_FROM_ALU =>
                    R2 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R2 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Register R3
    --=======================
    REGISTER_R3:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R3_OPCODE is
                when LOAD_FROM_ALU =>
                    R3 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R3 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Register R4
    --=======================
    REGISTER_R4:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R4_OPCODE is
                when LOAD_FROM_ALU =>
                    R4 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R4 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Register R5
    --=======================
    REGISTER_R5:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case R5_OPCODE is
                when LOAD_FROM_ALU =>
                    R5 <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            R5 <= (others => '0');
        end if;
    end process;


    --=======================
    -- Stack Pointer
    --=======================
    STACK_POINTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case SP_OPCODE is
                when LOAD_FROM_ALU =>
                    SP <= RBUS;
                when others =>
                    -- hold
             end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            SP <= (others => '0');
        end if;
    end process;


    --=======================
    -- Program Counter
    --=======================
    PROGRAM_COUNTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case PC_OPCODE is
                when LOAD_FROM_SX =>
                    PC <= SX;
                when LOAD_FROM_ALU =>
                    PC <= RBUS;
                when LOAD_FROM_MEM =>
                    PC <= DATA_IN;
                when LOAD_FROM_DA =>
                    PC <= DA;
                when others =>
                    -- hold
             end case;
             PC(0) <= '0'; -- PC is always even !!
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            PC <= (others => '0');
        end if;
    end process;


    --===================================
    -- Source operand Register
    --===================================
    S_REGISTER:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case S_OPCODE is
                when LOAD_FROM_ALU =>
                    S <= RBUS;
                when LOAD_FROM_REG =>
                    S <= SMUX;
                when LOAD_FROM_MEM =>
                    S <= DATA_IN;
                    if (BYTE_OP = '1') then
                        S <= BYTE_DATA;
                    end if;
                when others =>
                    -- hold
            end case;
            -- MPY step (shift multipier)
            if (MPY_STEP = '1') then
                S <= '0' & S(15 downto 1);
            end if;
        end if;
        end if;
    end process;


    --===================================
    -- Destination operand Register
    --===================================
    D_REGISTER:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            D_SBIT <= '0';
            case D_OPCODE is
                when LOAD_FROM_ALU =>
                    D <= RBUS;
                when LOAD_FROM_REG =>
                    D <= DMUX;
                when LOAD_FROM_MEM =>
                    D <= DATA_IN;
                    if (BYTE_OP = '1') then
                        D <= BYTE_DATA;
                    end if;
                when others =>
                    -- hold
            end case;
            -- DIV step shift
            if (DIV_STEP = '1') then
                if (XC = '1') then
                    -- subtract and shift
                    D <= SA(14 downto 0) & T(15);
                    D_SBIT <= SA(15);
                else
                    -- shift
                    D <= D(14 downto 0) & T(15);
                    D_SBIT <= D(15);
                end if;
            end if;
            -- last DIV step
            if (DIV_LAST = '1') then
                if (XC = '1') then
                    -- subtract with no shift
                    D <= SA;
                end if;
            end if;
        end if;
        end if;
    end process;


    --===================================
    -- Source Address Register
    --===================================
    SA_REGISTER:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            SA_SBIT <= '0';
            case SA_OPCODE is
                when LOAD_FROM_ALU =>
                    SA <= RBUS;
                when LOAD_FROM_REG =>
                    SA <= SMUX;
                when LOAD_FROM_MEM =>
                    SA <= DATA_IN;
                when others =>
                    -- hold
            end case;
            -- initialize to zero for MPY
            if (INIT_MPY = '1') then
                SA <= (others => '0');
            end if;
            -- MPY step (add and shift)
            if (MPY_STEP = '1') then
                if (S(0) = '1') then
                    -- add and shift
                    SA <= RBUS(0) & SA(15 downto 1);
                else
                    -- shift
                    SA <= T(0) & SA(15 downto 1);
                end if;
            end if;
            -- DIV step (sub and shift)
            if (DIV_STEP = '1') then
                SA <= RBUS(14 downto 0) & T(15);
                SA_SBIT <= RBUS(15);
            end if;
            -- last DIV step (sub with no shift)
            if (DIV_LAST = '1') then
                SA <= RBUS(15 downto 0);
            end if;
        end if;
        end if;
    end process;


    --===================================
    -- Destination Address Register
    --===================================
    DA_REGISTER:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case DA_OPCODE is
                when LOAD_FROM_ALU =>
                    DA <= RBUS;
                when LOAD_FROM_REG =>
                    DA <= DMUX;
                when LOAD_FROM_MEM =>
                    DA <= DATA_IN;
                when others =>
                    -- hold
            end case;
        end if;
        end if;
    end process;


    --===================================
    -- Temporary Register
    --===================================
    T_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case T_OPCODE is
                when LOAD_FROM_ALU =>
                    T <= RBUS;
                when LOAD_FROM_MEM =>
                    T <= DATA_IN;
                when others =>
                    -- hold
            end case;
            -- init to zero for MPY
            if (INIT_MPY = '1') then
                T <= (others => '0');
            end if;
            -- MPY step shift
            if (MPY_STEP = '1') then
                if (S(0) = '1') then
                    -- add and shift
                    T <= CARRY & RBUS(15 downto 1);
                else
                    -- shift
                    T <= '0' & T(15 downto 1);
                end if;
            end if;
            -- DIV step shift
            if ((DIV_STEP = '1') or (DIV_LAST = '1')) then
                T <= T(14 downto 0) & CARRY;
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            T <= (others => '0');
        end if;
    end process;


    --===================================
    -- Count Register
    --===================================
    C_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case C_OPCODE is
               when LOAD_COUNT =>
                    -- load count from opcode
                    C <= OPREG(7 downto 4);
                when DEC =>
                    -- decrement
                    C <= C - 1;
                when others =>
                    -- hold
            end case;
            -- initialize with MPY count
            if (INIT_MPY = '1') then
                C <= (others => '1');
            end if;
            -- initialize with DIV count
            if (INIT_DIV = '1') then
                C <= (others => '1');
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            C <= (others => '0');
        end if;
    end process;

    DIV_OP <=  DIV_STEP or DIV_LAST;

    --===================================
    -- Instantiate the ALU
    --===================================
    ALU1:
    ALU port map (
          COUT     => CARRY,
          ZERO     => ZERO,
          OVFL     => OVERFLOW,
          SIGN     => SIGNBIT,
          RBUS     => RBUS,
          A        => ABUS,
          B        => BBUS,
          OP       => ALU_OPCODE,
          BYTE_OP  => BYTE_ALU,
          DIV_OP   => DIV_OP,
          DIV_SBIT => DIV_SBIT,
          CIN      => PSW(0)
      );


    --===================================
    -- Instantiate the Address adder
    --===================================
    ADDR1:
    ADDR port map (
          SX       => SX,
          BX       => PC,
          DISP     => OPREG(7 downto 0),
          OP       => SX_OPCODE
      );


    --=========================================
    -- Instantiate the instruction decoder
    --=========================================
    DECODER:
    DECODE port map (
        MACRO_OP    => MACRO_OP,
        BYTE_OP     => BYTE_OP,
        FORMAT      => FORMAT_OP,
        IR          => OPREG
      );


    --================================================
    -- Instantiate the interrupt priority comparator
    --================================================
    PRIORITY:
    CMPR port map (
        A_LE_B      => INT_OK,
        A           => "0000",
        B           => "1111"
      );


end BEHAVIORAL;
