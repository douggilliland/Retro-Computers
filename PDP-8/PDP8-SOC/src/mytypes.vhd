
--========================================================================
-- mytypes.vhd ::  PDP-8 global type definitions
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.ALL;


package my_types is

    --=======================================
    -- Macro Opcodes
    --=======================================
    type  OPCODE_TYPE is (
             MOP_AND,     -- logical AND
             MOP_TAD,     -- 2's complement add
             MOP_ISZ,     -- increment and skip if zero
             MOP_DCA,     -- deposit and clear AC
             MOP_JMS,     -- jump to subroutine
             MOP_JMP,     -- jump
             MOP_IOT,     -- in-out transfer
             MOP_IOP1,    -- IOP group 1
             MOP_IOP2,    -- IOP group 2
             MOP_EAE,     -- EAE group
             MOP_OPR,     -- operate
             MOP_NOP,     -- no operation
             MOP_BSW,     -- byte swap
             MOP_CLA,     -- clear AC
             MOP_CLL,     -- clear link
             MOP_CMA,     -- complement AC
             MOP_CML,     -- complement link
             MOP_RAR,     -- rotate AC and link right one
             MOP_RAL,     -- rotate AC and link left one
             MOP_RTR,     -- rotate AC and link right two
             MOP_RTL,     -- rotate AC and link left two
             MOP_IAC,     -- increment AC
             MOP_SMA,     -- skip on minus AC
             MOP_SZA,     -- skip on zero AC
             MOP_SPA,     -- skip on plus AC
             MOP_SNA,     -- skip on non zero AC
             MOP_SNL,     -- skip on non-zero link
             MOP_SZL,     -- skip on zero link
             MOP_SKP,     -- skip unconditionally
             MOP_OSR,     -- OR and switch register with AC
             MOP_HLT,     -- halts the program
             MOP_CLA2,    -- clear AC
             MOP_CIA,     -- complement and increment AC
             MOP_LAS,     -- load AC with switch register
             MOP_STL,     -- set link (to 1
             MOP_DVI,     -- divide
             MOP_NMI,     -- normalize
             MOP_SHL,     -- shift left
             MOP_ASR,     -- arithmetic shift right
             MOP_LSR,     -- logical shift right
             MOP_MQL,     -- load AC into MQ, clear AC
             MOP_MUY,     -- multiply
             MOP_MQA,     -- load AC with MQ or AC
             MOP_CAM,     -- clear AC and MQ
             MOP_SWP,     -- swap  AC and MQ
             MOP_SCA,     -- read SC into AC
             MOP_AQL,     -- read MQ into AC
             MOP_ION,     -- turn interrupt on
             MOP_IOF,     -- turn interrupt off
             MOP_ADC,     -- convert A to D
             MOP_KSF,     -- skip if keyboard/reader flag set
             MOP_KCC,     -- clear AC and keyboard/reader
             MOP_KRS,     -- read keyboard/reader buffer
             MOP_KRB,     -- clear AC, read keyboard buffer
             MOP_TSF,     -- skip if teleprinter/punch flag set
             MOP_TCF,     -- clear teleprinter/punch flag
             MOP_TPC,     -- load teleprinter/punch
             MOP_TLS,     -- load teleprinter/punch buffer
             MOP_RSF,     -- skip if reader flag set
             MOP_RRB,     -- read reader buffer
             MOP_RFC,     -- fetch character
             MOP_PSF,     -- skip if punch flag set
             MOP_PCF,     -- clear flag and buffer
             MOP_PPC,     -- load buffer and punch
             MOP_PLS,     -- clear flag and buffer
             MOP_DXL,     -- clear and load x buffer
             MOP_DYL,     -- clear and load y buffer
             MOP_DXS,     -- combined dxl and dix
             MOP_DYS,     -- combined dyl and diy
             MOP_DIY,     -- intensify point
             MOP_DIX,     -- intensify point
             MOP_DCY,     -- clear y buffer
             MOP_DCX,     -- clear x buffer
             MOP_DTRA,    -- read status register A
             MOP_DTCA,    -- clear status register A
             MOP_DTXA,    -- load status register A
             MOP_DTSF,    -- skip on flags
             MOP_DTRB,    -- read status register B
             MOP_DTLB,    -- load status register B
             MOP_CDF,     -- change to data field n
             MOP_CIF,     -- change to instruction field n
             MOP_RDF,     -- read data field into AC
             MOP_RIF,     -- read instruction field into AC
             MOP_RMF,     -- restore memory field
             MOP_RIB,     -- read interrupt buffer
             MOP_UII      -- unimplemented instruction
          );


    --=======================================
    -- 12-bit ALU operations
    --=======================================
    type  ALU_OP_TYPE is (
             OP_ADD,      --  add
             OP_ADC,      --  add with carry
             OP_SUB,      --  subtract
             OP_SBC,      --  subtract with carry
             OP_INCA,     --  increment A
             OP_INCB,     --  increment B
             OP_DECA,     --  decrement A
             OP_DECB,     --  decrement B
             OP_COM,      --  1's complement A
             OP_NEG,      --  2's complement A
             OP_AND,      --  logical AND
             OP_OR,       --  logical OR
             OP_XOR,      --  exclusive OR
             OP_TA,       --  Transfer A
             OP_TB,       --  Transfer B
             OP_ASL,      --  arithmetic shift left A
             OP_ASR,      --  arithmetic shift right A
             OP_LSR,      --  logical shift right A
             OP_ROL,      --  rotate left A
             OP_ROR,      --  rotate right A
             OP_SWAP,     --  swap A
             OP_ONE,      --  output one
             OP_ONES,     --  output all ones
             OP_ZERO      --  output zero
          );

end my_types;

