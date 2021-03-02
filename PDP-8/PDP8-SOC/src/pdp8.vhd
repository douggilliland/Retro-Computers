
--======================================================================
-- pdp8.vhd ::  PDP-8 source-code-compatible microprocessor
--======================================================================
--
-- The PDP-8 was a 12-bit computer introduced by Digital Equipment
-- Corporation (DEC) on March 22, 1965. The chief designer of the PDP-8
-- was Edson de Castro, who later founded Data General. The PDP-8 was
-- a highly successful product line for DEC due to its relatively
-- low price and good support for a wide range of peripherals.
-- The PDP-8 was an improvement on the earlier DEC PDP-5 and the PDP-5
-- in turn was influenced by the MIT LINC and the CDC 160 minicomputers.
-- Architecturally it was very simple with only a single 12-bit
-- accumulator (on the base model) and very simple addressing modes.
-- The base PDP-8 could only address 4096 12-bit words although later
-- models added a user-managed memory-paging system to expand memory
-- to 32K 12-bit words.
--
-- (c) Scott L. Baker, Sierra Circuit Design
--======================================================================

library IEEE;
use IEEE.std_logic_1164.all;

use work.my_types.all;


entity IP_PDP8 is
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
end IP_PDP8;


architecture BEHAVIORAL of IP_PDP8 is

    --=================================================================
    -- Signal definition section
    --=================================================================

    -- fixme
    -- move type definitions to mytypes.vhd

    --=================================================================
    -- Program-Counter operations
    --=================================================================
    type  PC_OP_TYPE is (
              HOLD,    -- hold
              LDA,     -- load from EA register
              LDR,     -- load from RBUS
              LZP,     -- load zero page
              LCP,     -- load current page
              RST      -- reset
          );


    --=================================================================
    -- Effective address register operations
    --=================================================================
    type  EA_OP_TYPE is (
              HOLD,    -- hold
              LDR,     -- load from RBUS
              LZP,     -- load zero page
              LCP      -- load current page
          );


    --=================================================================
    -- Memory Bank Register operations
    --=================================================================
    type  AC_OP_TYPE is (
              HOLD,    -- hold
              LDR,     -- load from opcode
              LDMX,    -- load from bank select mux
              RESTORE  -- restore from SF
          );


    --=================================================================
    -- Memory Bank Register operations
    --=================================================================
    type  MBX_OP_TYPE is (
              HOLD,    -- hold
              LOAD,    -- load from opcode
              RESTORE  -- restore from SF
          );


    --=================================================================
    -- Register operations
    --=================================================================
    type  REG_OP_TYPE is (
              HOLD,    -- hold
              LDR      -- load from RBUS
          );


    --=================================================================
    -- Link operations
    --=================================================================
    type  LINK_OP_TYPE is (
              HOLD,    -- hold
              COUT,    -- update from ALU cout
              TAD,     -- complement if ALU cout
              COM,     -- complement
              SET,     -- set
              CLR      -- clear
          );

    --=================================================================
    -- Microcode States
    --=================================================================
    type  UCODE_STATE_TYPE is (
              FETCH_OPCODE,
              GOT_OPCODE,
              GOT_ADDRESS,
              AUTOINC_1,
              HALT_1,
              CLA_1,
              IAC_1,
              INDIR_1,
              IRQ_1,
              ISZ_1,
              JMS_1,
              SWP_1,
              SWP_2,
              SHIFT_1,
              SHIFT_2,
              RST_1,
              UII_1
          );

    signal STATE         : UCODE_STATE_TYPE;
    signal NEXT_STATE    : UCODE_STATE_TYPE;

    signal AC_OPCODE     : AC_OP_TYPE;      -- Accumulator micro op
    signal MQ_OPCODE     : REG_OP_TYPE;     -- Multiplier/Quotient micro op
    signal PC_OPCODE     : PC_OP_TYPE;      -- Program-counter micro op
    signal EA_OPCODE     : EA_OP_TYPE;      -- Address register micro op
    signal T1_OPCODE     : REG_OP_TYPE;     -- Register T1 micro op
    signal ALU_OPCODE    : ALU_OP_TYPE;     -- BCD ALU micro op
    signal LN_OPCODE     : LINK_OP_TYPE;    -- Link micro op

    signal IF_OPCODE     : REG_OP_TYPE;     -- instr field micro op
    signal DF_OPCODE     : MBX_OP_TYPE;     -- data  field micro op
    signal IB_OPCODE     : MBX_OP_TYPE;     -- instr buffer micro op
    signal SF_OPCODE     : REG_OP_TYPE;     -- save  field micro op

    -- Internal busses
    signal ABUS        :  std_logic_vector(11 downto 0);  -- ALU operand A bus
    signal BBUS        :  std_logic_vector(11 downto 0);  -- ALU operand B bus
    signal RBUS        :  std_logic_vector(11 downto 0);  -- result bus

    signal MACRO_OP    :  OPCODE_TYPE;                    -- macro opcode
    signal OP_GROUP    :  std_logic_vector(2 downto 0);   -- opcode group
    signal IAMP        :  std_logic_vector(1 downto 0);   -- indirect/page
    signal IOT_OP      :  std_logic_vector(2 downto 0);   -- IOT opcode

    -- Architectural registers
    signal AC          :  std_logic_vector(11 downto 0);  -- accumulator
    signal MQ          :  std_logic_vector(11 downto 0);  -- MQ register
    signal CCR         :  std_logic_vector( 3 downto 0);  -- status reg
    signal OP_REG      :  std_logic_vector(11 downto 0);  -- opcode reg
    signal PC          :  std_logic_vector(11 downto 0);  -- program counter
    signal EA          :  std_logic_vector(11 downto 0);  -- EA register
    signal T1          :  std_logic_vector(11 downto 0);  -- temp register

    -- Memory Bank control
    signal IF_REG      :  std_logic_vector(2 downto 0);   -- instr field
    signal DF_REG      :  std_logic_vector(2 downto 0);   -- data field
    signal IB_REG      :  std_logic_vector(2 downto 0);   -- instr buffer
    signal SF_REG      :  std_logic_vector(5 downto 0);   -- save fields
    signal MX          :  std_logic_vector(2 downto 0);   -- field mux

    signal IDF_FF      :  std_logic;  -- indirect data flag
    signal SET_IDF     :  std_logic;  -- set indirect data flag
    signal CLR_IDF     :  std_logic;  -- clr indirect data flag

    -- Status flag update
    signal UPDATE_Z    :  std_logic;  -- update  zero flag
    signal SET_IEN     :  std_logic;  -- enable  interrupts
    signal CLR_IEN     :  std_logic;  -- disable interrupts
    signal SET_DONE    :  std_logic;  -- set done bit
    signal CLR_DONE    :  std_logic;  -- clr done bit

    -- Misc
    signal MY_RESET    :  std_logic;  -- active high reset
    signal READING     :  std_logic;  -- R/W status
    signal LOAD_OPREG  :  std_logic;  -- load opcode register
    signal ZERO        :  std_logic;  -- RBUS equals zero
    signal ALU_CIN     :  std_logic;  -- ALU carry-in
    signal CARRY_OUT   :  std_logic;  -- ALU carry-out status bit
    signal IRQ_FF      :  std_logic;  -- IRQ flip-flop
    signal DONE_FF     :  std_logic;  -- done flip-flop

    -- group 1 combined opcodes
    signal CLA         :  std_logic;  -- clear AC
    signal CLL         :  std_logic;  -- clear link
    signal CMA         :  std_logic;  -- complement AC
    signal CML         :  std_logic;  -- complement link
    signal CRR         :  std_logic;  -- rotate AC/L right
    signal CRL         :  std_logic;  -- rotate AC/L left
    signal CR2         :  std_logic;  -- rotate by 1 or 2
    signal IAC         :  std_logic;  -- increment AC

    -- group 2 combined opcodes
    signal SMA         :  std_logic;  -- skip on AC minus
    signal SZA         :  std_logic;  -- skip on AC zero
    signal SNL         :  std_logic;  -- skip on non-zero link
    signal REV         :  std_logic;  -- reverse SMA/SZA/SNL
    signal OSR         :  std_logic;  -- rotate AC/L left
    signal HLT         :  std_logic;  -- rotate by 1 or 2

    -- EAE group combined opcodes
    signal MQA         :  std_logic;  -- load AC with MQ or AC
    signal SCA         :  std_logic;  -- load AC with step counter
    signal MQL         :  std_logic;  -- load AC into MQ


    --================================================================
    -- Component definition section
    --================================================================

    --==========================
    -- instruction decoder
    --==========================
    component DECODE
    port (
        MACRO_OP    : out OPCODE_TYPE;
        OP_GROUP    : out std_logic_vector( 2 downto 0);
        DECODE_IN   : in  std_logic_vector(11 downto 0)
       );
    end component;


    --==========================
    -- 12-bit ALU 
    --==========================
    component ALU
    port (
          RBUS  : out std_logic_vector(11 downto 0);  -- result bus
          COUT  : out std_logic;                      -- carry out
          ZERO  : out std_logic;                      -- zero
          A     : in  std_logic_vector(11 downto 0);  -- operand A
          B     : in  std_logic_vector(11 downto 0);  -- operand B
          OP    : in  ALU_OP_TYPE;                    -- ALU micro op
          CIN   : in  std_logic                       -- carry bit
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
    IAMP <= OP_REG(8 downto 7);
    -- group 1 combined opcodes
    CLA  <= OP_REG(7);
    CLL  <= OP_REG(6);
    CMA  <= OP_REG(5);
    CML  <= OP_REG(4);
    CRR  <= OP_REG(3);
    CRL  <= OP_REG(2);
    CR2  <= OP_REG(1);
    IAC  <= OP_REG(0);
    -- group 2 combined opcodes
    SMA  <= OP_REG(6);
    SZA  <= OP_REG(5);
    SNL  <= OP_REG(4);
    REV  <= OP_REG(3);
    OSR  <= OP_REG(2);
    HLT  <= OP_REG(1);
    -- EAE group combined opcodes
    MQA  <= OP_REG(6);
    SCA  <= OP_REG(5);
    MQL  <= OP_REG(4);

    --================================================================
    -- Microcode state machine
    --================================================================
    MICROCODE_STATE_MACHINE:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            STATE <= NEXT_STATE;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            STATE <= RST_1;
        end if;
    end process;


    --================================================================
    -- Logic analyzer triggers
    --================================================================
    TRIG1 <= '1';
    TRIG2 <= '1';


    --================================================================
    -- Register IRQ (active-low) inputs
    --================================================================
    INTERRUPT_STATUS_REGISTERS:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            -- only set the IRQ flip-flop if enabled
            IRQ_FF <= not (IRQ or not CCR(3));
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            IRQ_FF <= '0';
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
            if (LOAD_OPREG = '1') then
                OP_REG <= DATA_IN;
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            OP_REG <= (others => '0');
        end if;
    end process;

    R_W <= READING;
    DEV_SEL <= OP_REG(8 downto 3);
    IOT_OP  <= OP_REG(2 downto 0);

    --================================================================
    -- Micro-operation and next-state generation
    --================================================================
    MICRO_OP_AND_NEXT_STATE_GENERATION:
    process(OP_GROUP, MACRO_OP, DATA_IN, STATE, AC, T1, EA, PC, IAMP,
            IOT_OP, CCR, IORDY, DONE_FF, IRQ_FF, HLT, OSR, REV, SNL,
            SZA, SMA, IAC, CR2, CRL, CRR, CML, CMA, CLL, CLA, MQ,
            MQL, MQA)
    begin

        -- default micro-ops
        ALU_OPCODE <= OP_TA;
        PC_OPCODE  <= HOLD;
        EA_OPCODE  <= HOLD;
        T1_OPCODE  <= HOLD;
        AC_OPCODE  <= HOLD;
        MQ_OPCODE  <= HOLD;
        LN_OPCODE  <= HOLD;

        ABUS       <= AC;
        BBUS       <= DATA_IN;
        DATA_OUT   <= AC;
        ADDR_OUT   <= PC;
        BANK_SEL   <= IF_REG;    -- 8K memory-bank select
        MX         <= DF_REG;
        READING    <= '1';       -- reading memory
        IOM        <= '0';       -- (0 = Memory) (1 = I/O)
        LOAD_OPREG <= '0';       -- load the opcode register
        UPDATE_Z   <= '0';       -- update  zero flag
        SET_IEN    <= '0';       -- enable  interrupts
        CLR_IEN    <= '0';       -- disable interrupts
        SET_DONE   <= '0';       -- set done bit
        CLR_DONE   <= '0';       -- clr done bit
        SET_IDF    <= '0';       -- set indirect data flag
        CLR_IDF    <= '0';       -- clr indirect data flag
        ALU_CIN    <= '0';
        NEXT_STATE <= UII_1;

        case STATE is

        --============================================
        -- Reset startup sequence
        --============================================
        when RST_1 =>
            -- Stay here until reset is de-bounced
            NEXT_STATE <= FETCH_OPCODE;


        --============================================
        -- Fetch Opcode State
        --============================================
        when FETCH_OPCODE =>

            -- clear the indirect data flag
            CLR_IDF <= '1';

            if (IRQ_FF = '1') then
                -- save the current PC @ address 0
                READING  <= '0';
                DATA_OUT <= PC;
                ADDR_OUT <= (others => '0');
                -- get the indirect vector @ address 1
                ABUS <= EA;
                ALU_OPCODE <= OP_ONE;
                EA_OPCODE  <= LDR;
                NEXT_STATE <= IRQ_1;
            else
                -- load the opcode and increment the PC
                ABUS <= PC;
                ALU_OPCODE <= OP_INCA;
                PC_OPCODE  <= LDR;
                LOAD_OPREG <= '1';
                NEXT_STATE <= GOT_OPCODE;
            end if;


        --============================================
        -- Opcode register contains an opcode
        --============================================
        when GOT_OPCODE =>

            case OP_GROUP is

                --=================================
                -- Group 0 Basic Instructions
                --=================================
                when "000" =>
                    case IAMP is
                        -- direct zero page
                        when "00" =>
                            -- special case for jumps
                            case MACRO_OP is
                                when MOP_JMS =>
                                    EA_OPCODE  <= LZP;
                                    NEXT_STATE <= JMS_1;
                                when MOP_JMP =>
                                    PC_OPCODE  <= LZP;
                                    NEXT_STATE <= FETCH_OPCODE;
                                when others =>
                                    EA_OPCODE  <= LZP;
                                    NEXT_STATE <= GOT_ADDRESS;
                            end case;
                        -- direct current page
                        when "01" =>
                            -- special case for jumps
                            case MACRO_OP is
                                when MOP_JMS =>
                                    EA_OPCODE  <= LCP;
                                    NEXT_STATE <= JMS_1;
                                when MOP_JMP =>
                                    PC_OPCODE  <= LCP;
                                    NEXT_STATE <= FETCH_OPCODE;
                                when others =>
                                    EA_OPCODE <= LCP;
                                    NEXT_STATE <= GOT_ADDRESS;
                            end case;
                        -- indirect zero page
                        when "10" =>
                            EA_OPCODE <= LZP;
                            NEXT_STATE <= INDIR_1;
                        -- indirect current page
                        when "11" =>
                            EA_OPCODE <= LCP;
                            NEXT_STATE <= INDIR_1;
                        when others =>
                            NEXT_STATE <= UII_1;
                    end case;

                --=================================
                -- IOP Group 1 Instructions
                --=================================
                when "001" =>
                    case MACRO_OP is

                        -- do nothing
                        when MOP_NOP =>
                            NEXT_STATE <= FETCH_OPCODE;

                        -- byte swap
                        when MOP_BSW =>
                            ALU_OPCODE <= OP_SWAP;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear A
                        when MOP_CLA =>
                            ALU_OPCODE <= OP_ZERO;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- set link
                        when MOP_STL =>
                            LN_OPCODE  <= SET;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear link
                        when MOP_CLL =>
                            LN_OPCODE  <= CLR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- complement AC
                        when MOP_CMA =>
                            ALU_OPCODE <= OP_COM;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- complement and increment AC
                        when MOP_CIA =>
                            ABUS <= AC;
                            ALU_OPCODE <= OP_NEG;
                            LN_OPCODE  <= COUT;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- complement link
                        when MOP_CML =>
                            LN_OPCODE  <= COM;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- rotate AC and link right one
                        when MOP_RAR =>
                            ALU_OPCODE <= OP_ROR;
                            LN_OPCODE  <= COUT;
                            AC_OPCODE  <= LDR;
                            ALU_CIN    <= CCR(1);
                            NEXT_STATE <= FETCH_OPCODE;

                        -- rotate AC and link left one
                        when MOP_RAL =>
                            ALU_OPCODE <= OP_ROL;
                            LN_OPCODE  <= COUT;
                            AC_OPCODE  <= LDR;
                            ALU_CIN    <= CCR(1);
                            NEXT_STATE <= FETCH_OPCODE;

                        -- rotate AC and link right two
                        when MOP_RTR =>
                            ALU_OPCODE <= OP_ROR;
                            LN_OPCODE  <= COUT;
                            AC_OPCODE  <= LDR;
                            ALU_CIN    <= CCR(1);
                            NEXT_STATE <= SHIFT_2;

                        -- rotate AC and link left two
                        when MOP_RTL =>
                            ALU_OPCODE <= OP_ROL;
                            LN_OPCODE  <= COUT;
                            AC_OPCODE  <= LDR;
                            ALU_CIN    <= CCR(1);
                            NEXT_STATE <= SHIFT_2;

                        -- increment AC
                        when MOP_IAC =>
                            ALU_OPCODE <= OP_INCA;
                            LN_OPCODE  <= TAD;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- group 1 combined opcodes
                        --
                        -- CLA -- clear AC
                        -- CLL -- clear link
                        -- CMA -- complement AC
                        -- CML -- complement link
                        -- CRR -- rotate AC/L right
                        -- CRL -- rotate AC/L left
                        -- CR2 -- rotate by 1 or 2
                        -- IAC -- increment AC
                        when others =>
                            if (CLA = '1') then
                                -- load AC with zero
                                ALU_OPCODE <= OP_ZERO;
                                AC_OPCODE  <= LDR;
                                if (CMA = '1') then
                                    -- load AC with -1
                                    ALU_OPCODE <= OP_ONES;
                                    AC_OPCODE  <= LDR;
                                end if;
                            else
                                if (CMA = '1') then
                                    -- complement AC
                                    ALU_OPCODE <= OP_COM;
                                    AC_OPCODE  <= LDR;
                                end if;
                            end if;
                            if (CLL = '1') then
                                LN_OPCODE <= CLR;
                                if (CML = '1') then
                                    LN_OPCODE <= SET;
                                end if;
                            else
                                if (CML = '1') then
                                    LN_OPCODE <= COM;
                                end if;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;
                            if (IAC = '1') then
                                NEXT_STATE <= IAC_1;
                            elsif ((CRR = '1') or (CRL = '1')) then
                                NEXT_STATE <= SHIFT_1;
                            end if;

                    end case;

                --=================================
                -- IOP Group 2 Instructions
                --=================================
                when "010" =>
                    case MACRO_OP is

                        -- skip on plus AC
                        when MOP_SPA =>
                            if (AC(11) = '0') then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip on minus AC
                        when MOP_SMA =>
                            if (AC(11) = '1') then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip on zero AC
                        when MOP_SZA =>
                            if (AC = x"000") then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip on non zero AC
                        when MOP_SNA =>
                            if (AC /= x"000") then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip on non-zero link
                        when MOP_SNL =>
                            if (CCR(1) = '1') then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip on zero link
                        when MOP_SZL =>
                            if (CCR(1) = '0') then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip unconditionally
                        when MOP_SKP =>
                            ABUS <= PC;
                            ALU_OPCODE <= OP_INCA;
                            PC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- inclusive OR, switch register with AC
                        when MOP_OSR =>
                            -- we have no switch register
                            -- just set AC = -1
                            ALU_OPCODE <= OP_ONES;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- halt the program
                        when MOP_HLT =>
                            NEXT_STATE <= HALT_1;

                        -- do nothing
                        when MOP_NOP =>
                            NEXT_STATE <= FETCH_OPCODE;

                        -- load AC with switch register
                        when MOP_LAS =>
                            -- we have no switch register
                            -- just set AC = -1
                            ALU_OPCODE <= OP_ONES;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear AC
                        when MOP_CLA2 =>
                            ALU_OPCODE <= OP_ZERO;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- group 2 combined opcodes
                        --
                        -- CLA -- clear AC
                        -- SMA -- skip on AC minus
                        -- SZA -- skip on AC zero
                        -- SNL -- skip on non-zero link
                        -- REV -- reverse SMA/SZA/SNL
                        -- OSR -- rotate AC/L left
                        -- HLT -- rotate by 1 or 2
                        when others =>
                            if (REV = '0') then
                                if (((SMA = '1') and (AC(11) = '1')) or
                                    ((SZA = '1') and (AC = x"000")) or
                                    ((SNL = '1') and (CCR(1) = '1'))) then
                                    ABUS <= PC;
                                    ALU_OPCODE <= OP_INCA;
                                    PC_OPCODE  <= LDR;
                                end if;
                            else
                                if (not(((SMA = '1') and (AC(11) = '1')) or
                                    ((SZA = '1') and (AC = x"000")) or
                                    ((SNL = '1') and (CCR(1) = '1')))) then
                                    ABUS <= PC;
                                    ALU_OPCODE <= OP_INCA;
                                    PC_OPCODE  <= LDR;
                                end if;
                            end if;
                            if (OSR = '1') then
                                -- we have no switch register
                                -- just set AC = -1
                                ALU_OPCODE <= OP_ONES;
                                AC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;
                            if (CLA = '1') then
                                NEXT_STATE <= CLA_1;
                            end if;
                            if (HLT = '1') then
                                NEXT_STATE <= HALT_1;
                            end if;
                    end case;

                --=================================
                -- EAE Instructions
                --=================================
                when "100" =>
                    case MACRO_OP is

                        -- divide
                        when MOP_DVI =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- normalize
                        when MOP_NMI =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- shift left
                        when MOP_SHL =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- arithmetic shift right
                        when MOP_ASR =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- logical shift right
                        when MOP_LSR =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- load AC into MQ
                        when MOP_MQL =>
                            ABUS <= AC;
                            MQ_OPCODE  <= LDR;
                            -- clear AC
                            NEXT_STATE <= CLA_1;

                        -- multiply
                        when MOP_MUY =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- load AC with MQ or AC
                        when MOP_MQA =>
                            ABUS <= AC;
                            BBUS <= MQ;
                            ALU_OPCODE <= OP_OR;
                            AC_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear AC and MQ
                        when MOP_CAM =>
                            ALU_OPCODE <= OP_ZERO;
                            AC_OPCODE  <= LDR;
                            MQ_OPCODE  <= LDR;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- read SC into AC
                        when MOP_SCA =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- read MQ into AC
                        when MOP_AQL =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                        -- swap MQ and AC
                        when MOP_SWP =>
                            -- save AC to T1
                            ABUS <= AC;
                            T1_OPCODE  <= LDR;
                            NEXT_STATE <= SWP_1;

                        -- EAE group combined opcodes
                        when others =>
                            -- fixme
                            NEXT_STATE <= UII_1;

                    end case;

                --=================================
                -- IOP Group 6 Instructions
                --=================================
                when "110" =>
                    case MACRO_OP is

                        -- enable interrupts
                        when MOP_ION =>
                            SET_IEN <= '1';
                            NEXT_STATE <= FETCH_OPCODE;

                        -- disable interrupts
                        when MOP_IOF =>
                            CLR_IEN <= '1';
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear AC and keyboard flag
                        when MOP_KCC =>
                            -- clear AC
                            ALU_OPCODE <= OP_ZERO;
                            AC_OPCODE  <= LDR;
                            -- I/O register write
                            IOM <= '1';
                            READING <= '0';
                            NEXT_STATE <= FETCH_OPCODE;

                        -- clear teleprinter flag
                        when MOP_TCF =>
                            -- I/O register write
                            IOM <= '1';
                            READING <= '0';
                            NEXT_STATE <= FETCH_OPCODE;

                        -- load teleprinter buffer
                        when MOP_TLS =>
                            IOM <= '1';
                            READING <= '0';
                            NEXT_STATE <= FETCH_OPCODE;

                        -- skip if teleprinter flag set
                        when MOP_TSF =>
                            IOM <= '1';
                            if (IORDY = '1') then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- change data field
                        when MOP_CDF =>
                            DF_OPCODE  <= LOAD;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- change instruction field
                        when MOP_CIF =>
                            IB_OPCODE  <= LOAD;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- read data field
                        when MOP_RDF =>
                            MX <= DF_REG;
                            AC_OPCODE  <= LDMX;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- read instruction field
                        when MOP_RIF =>
                            MX <= IF_REG;
                            AC_OPCODE  <= LDMX;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- read instruction buffer
                        when MOP_RIB =>
                            MX <= IB_REG;
                            AC_OPCODE  <= LDMX;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- restore memory fields
                        when MOP_RMF =>
                            IB_OPCODE  <= RESTORE;
                            DF_OPCODE  <= RESTORE;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- generic IOT instruction
                        when MOP_IOT =>
                            IOM <= '1';
                            -- I/O register write
                            if (IOT_OP(1) = '1') then
                                READING <= '0';
                            end if;
                            -- I/O skip on flag
                            if ((IOT_OP(0) = '1') and (IORDY = '1')) then
                                ABUS <= PC;
                                ALU_OPCODE <= OP_INCA;
                                PC_OPCODE  <= LDR;
                            end if;
                            NEXT_STATE <= FETCH_OPCODE;

                        -- undefined
                        when others =>
                            NEXT_STATE <= UII_1;
                    end case;

                when others =>
                    NEXT_STATE <= UII_1;

            end case;  -- end of OP_GROUP case


        --============================================
        -- EA register contains the operand address
        --============================================
        when GOT_ADDRESS =>

            -- use DF to fetch indirect data
            if (IDF_FF = '1') then
                BANK_SEL <= DF_REG;
            end if;

            case MACRO_OP is

                --  logical AND
                when MOP_AND =>
                    ADDR_OUT <= EA;
                    ABUS <= AC;
                    ALU_OPCODE <= OP_AND;
                    AC_OPCODE  <= LDR;
                    NEXT_STATE <= FETCH_OPCODE;

                --  2's complement add
                when MOP_TAD =>
                    ADDR_OUT <= EA;
                    ABUS <= AC;
                    ALU_OPCODE <= OP_ADD;
                    AC_OPCODE  <= LDR;
                    LN_OPCODE  <= TAD;
                    NEXT_STATE <= FETCH_OPCODE;

                --  increment and skip if zero
                when MOP_ISZ =>
                    ADDR_OUT <= EA;
                    ALU_OPCODE <= OP_INCB;
                    T1_OPCODE  <= LDR;
                    UPDATE_Z <= '1';
                    NEXT_STATE <= ISZ_1;

                --  deposit and clear AC
                when MOP_DCA =>
                    ADDR_OUT <= EA;
                    DATA_OUT <= AC;
                    READING  <= '0';
                    ALU_OPCODE <= OP_ZERO;
                    AC_OPCODE  <= LDR;
                    NEXT_STATE <= FETCH_OPCODE;

                when others =>
                    NEXT_STATE <= UII_1;

            end case;


        --============================================
        -- EA register contains the indirect address
        --============================================
        when INDIR_1 =>

            -- set the indirect data flag
            SET_IDF <= '1';

            -- check for zero-page auto-inc case
            if ((DONE_FF = '0') and (IAMP(0) = '0') and
               (EA(11 downto 3) = "000000001")) then
                SET_DONE <= '1';
                ADDR_OUT <= EA;
                ALU_OPCODE <= OP_INCB;
                T1_OPCODE <= LDR;
                NEXT_STATE <= AUTOINC_1;
            else
                CLR_DONE <= '1';
                ADDR_OUT <= EA;
                ALU_OPCODE <= OP_TB;
                case MACRO_OP is
                    when MOP_JMS =>
                        EA_OPCODE  <= LDR;
                        NEXT_STATE <= JMS_1;
                    when MOP_JMP =>
                        PC_OPCODE  <= LDR;
                        NEXT_STATE <= FETCH_OPCODE;
                    when others =>
                        EA_OPCODE  <= LDR;
                        NEXT_STATE <= GOT_ADDRESS;
                end case;
            end if;


        --============================================
        -- Complete the auto-increment
        --============================================
        when AUTOINC_1 =>
            -- store the incremented indirect address
            READING  <= '0';
            DATA_OUT <= T1;
            ADDR_OUT <= EA;
            NEXT_STATE <= INDIR_1;


        --=========================================
        -- Complete the IOP group 1 opcode
        --=========================================
        when IAC_1 =>
            -- increment AC
            ALU_OPCODE <= OP_INCA;
            LN_OPCODE  <= TAD;
            AC_OPCODE  <= LDR;
            NEXT_STATE <= FETCH_OPCODE;
            -- check if a shift is needed
            if ((CRR = '1') or (CRL = '1')) then
                NEXT_STATE <= SHIFT_1;
            end if;


        --=========================================
        -- Complete the IOP group 2 opcode
        --=========================================
        when CLA_1 =>
            ALU_OPCODE <= OP_ZERO;
            AC_OPCODE  <= LDR;
            NEXT_STATE <= FETCH_OPCODE;


        --=========================================
        -- Complete the swap of MQ and AC
        --=========================================
        when SWP_1 =>
            -- load AC from MQ
            ABUS <= MQ;
            AC_OPCODE  <= LDR;
            NEXT_STATE <= SWP_2;


        --=========================================
        -- Complete the swap of MQ and AC
        --=========================================
        when SWP_2 =>
            -- load MQ from T1 (T1=AC)
            ABUS <= T1;
            MQ_OPCODE  <= LDR;
            NEXT_STATE <= FETCH_OPCODE;


        --=========================================
        -- Complete the interrupt jump
        --=========================================
        when IRQ_1 =>
            -- get the interrupt handler address
            ADDR_OUT <= EA;
            ALU_OPCODE <= OP_TB;
            PC_OPCODE  <= LDR;
            -- save memory bank-select register
            SF_OPCODE  <= LDR;
            NEXT_STATE <= FETCH_OPCODE;


        --=========================================
        -- Complete the increment and skip
        --=========================================
        when ISZ_1 =>
            -- store the incremented value
            READING  <= '0';
            DATA_OUT <= T1;
            ADDR_OUT <= EA;
            -- skip if zero
            if (CCR(0) = '1') then
                ABUS <= PC;
                ALU_OPCODE <= OP_INCA;
                PC_OPCODE  <= LDR;
            end if;
            NEXT_STATE <= FETCH_OPCODE;


        --=========================================
        -- Complete the jump to subroutine
        --=========================================
        when JMS_1 =>
            -- store the return address
            READING  <= '0';
            DATA_OUT <= PC;
            ADDR_OUT <= EA;
            -- get the start address
            ABUS <= EA;
            ALU_OPCODE <= OP_INCA;
            PC_OPCODE  <= LDR;
            NEXT_STATE <= FETCH_OPCODE;

        when SHIFT_1 =>
            if ((CRR = '1') and (CRL = '0')) then
                -- rotate AC and link right by 1
                ALU_OPCODE <= OP_ROR;
                LN_OPCODE  <= COUT;
                AC_OPCODE  <= LDR;
                ALU_CIN    <= CCR(1);
                NEXT_STATE <= FETCH_OPCODE;
                if (CR2 = '1') then
                    NEXT_STATE <= SHIFT_2;
                end if;
            elsif ((CRR = '0') and (CRL = '1')) then
                -- rotate AC and link left by 1
                ALU_OPCODE <= OP_ROL;
                LN_OPCODE  <= COUT;
                AC_OPCODE  <= LDR;
                ALU_CIN    <= CCR(1);
                NEXT_STATE <= FETCH_OPCODE;
                if (CR2 = '1') then
                    NEXT_STATE <= SHIFT_2;
                end if;
            end if;

        when SHIFT_2 =>
            if ((CRR = '1') and (CRL = '0')) then
                -- rotate AC and link right by 2
                ALU_OPCODE <= OP_ROR;
                LN_OPCODE  <= COUT;
                AC_OPCODE  <= LDR;
                ALU_CIN    <= CCR(1);
                NEXT_STATE <= FETCH_OPCODE;
            elsif ((CRR = '0') and (CRL = '1')) then
                -- rotate AC and link left by 2
                ALU_OPCODE <= OP_ROL;
                LN_OPCODE  <= COUT;
                AC_OPCODE  <= LDR;
                ALU_CIN    <= CCR(1);
                NEXT_STATE <= FETCH_OPCODE;
            end if;


        --=========================================
        -- Halt (wait for interrupt)
        --=========================================
        when HALT_1 =>
            NEXT_STATE <= HALT_1;
            if (IRQ_FF = '1') then
                PC_OPCODE  <= RST;
                NEXT_STATE <= FETCH_OPCODE;
            end if;

 
        --=========================================
        -- Unimplemented Opcodes
        --=========================================
        when UII_1 =>
            PC_OPCODE  <= HOLD;
            NEXT_STATE <= UII_1;

        when others =>
            PC_OPCODE  <= HOLD;
            NEXT_STATE <= UII_1;

        end case;  -- end of STATE case

    end process;


    --=================================================
    -- Status Flag Register 
    --=================================================
    STATUS_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            -- update zero flag
            if (UPDATE_Z = '1') then
                CCR(0) <= ZERO;
            end if;
            -- update link bit
            case LN_OPCODE is
                when COUT =>
                    CCR(1) <= CARRY_OUT;
                when TAD =>
                    CCR(1) <= CCR(1) xor CARRY_OUT;
                when COM =>
                    CCR(1) <= not CCR(1);
                when SET =>
                    CCR(1) <= '1';
                when CLR =>
                    CCR(1) <= '0';
                when others =>
                    -- hold link
            end case;
            -- update interrupt enable bit
            if (SET_IEN = '1') then
                CCR(3) <= '1';   -- enable  interrupts
            end if;
            if (CLR_IEN = '1') then
                CCR(3) <= '0';   -- disable interrupts
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            CCR  <= "0000";
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
                when LDA =>
                    PC <= EA;
                when LDR =>
                    PC <= RBUS;
                when LZP =>
                    PC <= "00000" & OP_REG(6 downto 0);
                when LCP =>
                    PC(6 downto 0) <= OP_REG(6 downto 0);
                when RST =>
                    PC <= "000010000000";  -- octal 200
                when others =>
                    -- hold PC
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            PC <= "000010000000";  -- octal 100
        end if;
    end process;


    --================================================================
    -- EA register
    --================================================================
    EA_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case EA_OPCODE is
                when LDR =>
                    EA <= RBUS;
                when LZP =>
                    EA <= "00000" & OP_REG(6 downto 0);
                when LCP =>
                    EA <= PC(11 downto 7) & OP_REG(6 downto 0);
                when others =>
                    -- hold EA
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            EA <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Accumulator
    --================================================================
    ACCUMULATOR:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case AC_OPCODE is
                when LDR =>
                    AC <= RBUS;
                when LDMX =>
                    AC(5 downto 3) <= MX;
                when others =>
                    -- hold AC
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            AC <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Multiplier/Quotient Register
    --================================================================
    MQ_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case MQ_OPCODE is
                when LDR =>
                    MQ <= RBUS;
                when others =>
                    -- hold MQ
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            MQ <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Instruction Field Register
    --================================================================
    IF_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case IF_OPCODE is
                when LDR =>
                    IF_REG <= OP_REG(5 downto 3);
                when others =>
                    -- hold IF
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            IF_REG <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Data Field Register
    --================================================================
    DF_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case DF_OPCODE is
                when LOAD =>
                    DF_REG <= OP_REG(5 downto 3);
                when RESTORE =>
                    DF_REG <= SF_REG(2 downto 0);
                when others =>
                    -- hold DF
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            DF_REG <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Instruction Buffer Register
    --================================================================
    IB_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case IB_OPCODE is
                when LOAD =>
                    IB_REG <= OP_REG(5 downto 3);
                when RESTORE =>
                    IB_REG <= SF_REG(5 downto 3);
                when others =>
                    -- hold IB
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            IB_REG <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Save Field Register
    --================================================================
    SF_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case SF_OPCODE is
                when LDR =>
                    SF_REG(5 downto 3) <= IB_REG;
                    SF_REG(2 downto 0) <= DF_REG;
                when others =>
                    -- hold SF
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            SF_REG <= (others => '0');
        end if;
    end process;


    --================================================================
    -- T1 Temp Register
    --================================================================
    T1_REGISTER:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            case T1_OPCODE is
                when LDR =>
                    T1 <= RBUS;
                when others =>
                    -- hold T1
            end case;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            T1 <= (others => '0');
        end if;
    end process;


    --================================================================
    -- Indirect Data Flag Register
    --================================================================
    IDF_FLAG:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            if (SET_IDF = '1') then
                IDF_FF <= '1';
            end if;
            if (CLR_IDF = '1') then
                IDF_FF <= '0';
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            IDF_FF <= '0';
        end if;
    end process;


    --================================================================
    -- Done Flag Register
    --================================================================
    DONE_FLAG:
    process(CLK, MY_RESET)
    begin
        if (CLK = '0' and CLK'event) then
        if (FEN = '1') then
            if (SET_DONE = '1') then
                DONE_FF <= '1';
            end if;
            if (CLR_DONE = '1') then
                DONE_FF <= '0';
            end if;
        end if;
        end if;
        -- reset state
        if (MY_RESET = '1') then
            DONE_FF <= '0';
        end if;
    end process;


    --================================================================
    -- Instantiate the ALU
    --================================================================
    ALU1:
    ALU port map (
          RBUS  => RBUS,
          COUT  => CARRY_OUT,
          ZERO  => ZERO,
          A     => ABUS,
          B     => BBUS,
          OP    => ALU_OPCODE,
          CIN   => ALU_CIN
      );


    --================================================================
    -- Instantiate the instruction decoder
    --================================================================
    DECODER:
    DECODE port map (
        MACRO_OP   => MACRO_OP,
        OP_GROUP   => OP_GROUP,
        DECODE_IN  => OP_REG
      );

end BEHAVIORAL;

