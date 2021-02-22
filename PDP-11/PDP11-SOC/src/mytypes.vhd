
--================================================================
-- mytypes.vhd ::  PDP-11 global type definitions
--
-- (c) Scott L. Baker, Sierra Circuit Design
--================================================================

library IEEE;
use IEEE.std_logic_1164.ALL;

package MY_TYPES is


    --=======================================
    -- ALU operations
    --=======================================
    type ALU_OP_TYPE is (
             OP_ADD,      --  add
             OP_ADC,      --  add carry
             OP_SBC,      --  subtract carry
             OP_SUBA,     --  subtract B-A
             OP_SUBB,     --  subtract A-B
             OP_INCA1,    --  increment A
             OP_INCA2,    --  increment A by 2
             OP_DECA1,    --  decrement A
             OP_DECA2,    --  decrement A by 2
             OP_INV,      --  1's complement A
             OP_NEG,      --  2's complement A
             OP_AND,      --  A AND B
             OP_BIC,      --  not A AND B
             OP_CZC,      --  A AND not B
             OP_SZC,      --  not A AND B
             OP_OR,       --  A OR  B
             OP_XOR,      --  A XOR B
             OP_ZERO,     --  zero
             OP_ONES,     --  all ones
             OP_TA,       --  Transfer A
             OP_TB,       --  Transfer B
             OP_SWP,      --  Swap bytes of A
             OP_ASL,      --  arithmetic shift left A
             OP_ASR,      --  arithmetic shift right A
             OP_LSR,      --  logical shift right A
             OP_ROL,      --  rotate left A
             OP_ROR       --  rotate right A
          );


    --=======================================
    -- Opcode Formats
    --=======================================

    constant ONE_OPERAND : std_logic_vector(2 downto 0) := "000";
    constant TWO_OPERAND : std_logic_vector(2 downto 0) := "001";
    constant BRA_FORMAT  : std_logic_vector(2 downto 0) := "010";
    constant IMPLIED     : std_logic_vector(2 downto 0) := "011";
    constant FLOAT       : std_logic_vector(2 downto 0) := "100";


    --=======================================
    -- Macro Operations (Instructions)
    --=======================================
    type  MACRO_OP_TYPE is (
             MOP_ADC,     -- add with carry
             MOP_ADD,     -- add source to destination
             MOP_ASH,     -- shift arithmetically
             MOP_ASHC,    -- arithmetic shift combined
             MOP_ASL,     -- arithmetic shift left
             MOP_ASR,     -- arithmetic shift right
             MOP_BR,      -- branch unconditional
             MOP_BNE,     -- branch not equal
             MOP_BEQ,     -- branch equal
             MOP_BGE,     -- branch greater than of equal
             MOP_BLT,     -- branch less than
             MOP_BGT,     -- branch greater than
             MOP_BLE,     -- branch less than or equal
             MOP_BPL,     -- branch plus
             MOP_BMI,     -- branch minus
             MOP_BHI,     -- branch higher
             MOP_BLOS,    -- branch lower or same
             MOP_BVC,     -- branch overflow clear
             MOP_BVS,     -- branch overflow set
             MOP_BCC,     -- branch carry clear
             MOP_BCS,     -- branch carry set
             MOP_BIC,     -- bit clear
             MOP_BIS,     -- bit set
             MOP_BIT,     -- bit test
             MOP_BPT,     -- breakpoint trap
             MOP_CCC,     -- clear condition code
             MOP_CLN,     -- clear N bit
             MOP_CLC,     -- clear C bit
             MOP_CLV,     -- clear V bit
             MOP_CLZ,     -- clear Z bit
             MOP_CLR,     -- clear dst
             MOP_CMP,     -- compare source to destination
             MOP_COM,     -- 1's complement dst
             MOP_CSM,     -- call to supervisor mode
             MOP_DEC,     -- decrement dst
             MOP_DIV,     -- divide
             MOP_EMT,     -- emulator trap
             MOP_FADD,    -- floating-point add
             MOP_FDIV,    -- floating-point divide
             MOP_FMUL,    -- floating-point multiply
             MOP_FSUB,    -- floating-point subtract
             MOP_HALT,    -- halt
             MOP_INC,     -- increment dst
             MOP_IOT,     -- input/output trap
             MOP_JMP,     -- jump
             MOP_JSR,     -- jump to subroutine
             MOP_MARK,    -- facilitates stack clean-up procedures
             MOP_MFPD,    -- move from previous instruction space
             MOP_MFPI,    -- move from previous instruction space
             MOP_MFPS,    -- move byte from processor status word
             MOP_MFPT,    -- move from processor type
             MOP_MOV,     -- move source to destination
             MOP_MTPD,    -- move to previous data space
             MOP_MTPI,    -- move to previous instruction space
             MOP_MTPS,    -- move byte to processor status word
             MOP_MUL,     -- multiply
             MOP_NEG,     -- 2's complement negate dst
             MOP_NOP,     -- no operation
             MOP_RESET,   -- reset UNIBUS
             MOP_ROL,     -- rotate left
             MOP_ROR,     -- rotate right
             MOP_RTI,     -- return from interrupt
             MOP_RTS,     -- return from subroutine
             MOP_RTT,     -- return from interrupt
             MOP_SBC,     -- subtract with carry
             MOP_SCC,     -- set condition code
             MOP_SEN,     -- set N bit
             MOP_SEC,     -- set C bit
             MOP_SEV,     -- set V bit
             MOP_SEZ,     -- set Z bit
             MOP_SOB,     -- subtract one and branch (if not = 0)
             MOP_SPL,     -- set priority level
             MOP_SUB,     -- subtract source from destination
             MOP_SWAB,    -- swap bytes
             MOP_SXT,     -- sign extend
             MOP_TRAP,    -- trap
             MOP_TST,     -- test dst
             MOP_TSTSET,  -- test/set dst  (MICRO/J-11 only)
             MOP_UII,     -- unimplemened instruction
             MOP_WAIT,    -- wait for interrupt
             MOP_WRTLCK,  -- read/lock dst (MICRO/J-11 only)
             MOP_XOR      -- exclusive OR
          );


    --=================================================================
    -- Microcode States
    --=================================================================
    type  UCODE_STATE_TYPE is (
              FETCH_OPCODE,
              GOT_OPCODE,
              EXEC_OPCODE,
              DIV_1,
              DIV_2,
              DIV_3,
              DIV_4,
              DIV_5,
              DIV_6,
              HALT_1,
              IRQ_1,
              IRQ_2,
              JSR_1,
              JSR_2,
              JSR_3,
              MPY_1,
              MPY_2,
              MPY_3,
              DST_RI1,
              DST_PI1,
              DST_PI2,
              DST_PD1,
              DST_X1,
              DST_X2,
              SRC_RI1,
              SRC_PI1,
              SRC_PI2,
              SRC_PD1,
              SRC_X1,
              SRC_X2,
              RST_1,
              RTS_1,
              SBO_1,
              SBZ_1,
              SHIFT_1,
              SHIFT_1A,
              SHIFT_1B,
              SHIFT_2,
              SHIFT_3,
              STORE_D,
              UII_1
          );


    --=================================================================
    -- PC operations
    --=================================================================
    type  PC_OP_TYPE is (
              LOAD_FROM_SX,  -- load from address adder
              LOAD_FROM_ALU, -- load from ALU
              LOAD_FROM_MEM, -- load from memory
              LOAD_FROM_DA,  -- load from DA register
              HOLD           -- hold
          );


    --=================================================================
    -- Register operations
    --=================================================================
    type  REG_OP_TYPE is (
              LOAD_FROM_ALU, -- load from ALU
              LOAD_FROM_REG, -- load from register
              LOAD_FROM_MEM, -- load from memory
              HOLD           -- hold
          );


    --=================================================================
    -- Count Register operations
    --=================================================================
    type  CNT_OP_TYPE is (
              LOAD_COUNT,    -- load from opcode field
              DEC,           -- decrement
              HOLD           -- hold
          );


    --=======================================
    -- Address adder operations
    --=======================================
    type  SX_OP_TYPE is (
             OP_REL,     --  Relative
             OP_INC2,    --  Increment by 2
             OP_DEC2     --  Decrement by 2
          );


    --=================================================================
    -- AMUX operand selector
    --=================================================================
    type  ASEL_TYPE is (
              SEL_SA,   -- select SA
              SEL_DA,   -- select DA
              SEL_S,    -- select S
              SEL_D,    -- select D
              SEL_DMUX, -- select DMUX
              SEL_SMUX, -- select SMUX
              SEL_PSW,  -- select PSW
              SEL_SP,   -- select SP
              SEL_PC    -- select PC
          );


    --=================================================================
    -- BMUX operand selector
    --=================================================================
    type  BSEL_TYPE is (
              SEL_SA,   -- Select SA
              SEL_DMUX, -- Select DMUX
              SEL_SMUX, -- Select SMUX
              SEL_T,    -- Select T
              SEL_D     -- Select D
          );


    --=======================================
    -- Shifter control
    --=======================================
    type SHIFT_CTL_TYPE is (
             NOP,    -- no shift
             LEFT,   -- shift left
             RIGHT,  -- shift right
             SWAP    -- swap hi and lo bytes
          );


end MY_TYPES;

