
--========================================================================
-- decode.vhd ::  PDP-11 Instruction Decoder
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;

use work.my_types.all;


entity DECODE is
    port (
        MACRO_OP    : out MACRO_OP_TYPE;                  -- opcode
        BYTE_OP     : out std_logic;                      -- byte/word
        FORMAT      : out std_logic_vector( 2 downto 0);  -- format
        IR          : in  std_logic_vector(15 downto 0)   -- inst reg
       );
end DECODE;


architecture BEHAVIORAL of DECODE is

begin

    --=========================================================
    -- Decode the opcode and addressing mode
    --=========================================================
    DECODE_OPCODE_AND_ADDRESS_MODE:
    process(IR)
    begin

        -- Set the default states for the addressing modes
        MACRO_OP <= MOP_NOP;
        FORMAT   <= IMPLIED;
        BYTE_OP  <= '0';

        case IR(15 downto 12) is

        -- Group 0: branches, jumps and Implied operand instructions

        when "0000" =>

            case IR(11 downto 6) is

            when "000000" =>

                case IR(2 downto 0) is
                when "000" =>                   -- HALT :: halt
                    MACRO_OP <= MOP_HALT;
                    FORMAT   <= IMPLIED;

                when "001" =>                   -- WAIT :: wait
                    MACRO_OP <= MOP_WAIT;
                    FORMAT   <= IMPLIED;

                when "010" =>                   -- RTI :: return from interrupt
                    MACRO_OP <= MOP_RTI;
                    FORMAT   <= IMPLIED;

                when "011" =>                   -- BPT :: breakpoint trap
                    MACRO_OP <= MOP_BPT;
                    FORMAT   <= IMPLIED;

                when "100" =>                   -- IOT :: I/O trap
                    MACRO_OP <= MOP_IOT;
                    FORMAT   <= IMPLIED;

                when "101" =>                   -- RESET :: reset bus
                    MACRO_OP <= MOP_RESET;
                    FORMAT   <= IMPLIED;

                when "110" =>                   -- RTT :: return from interrupt
                    MACRO_OP <= MOP_RTT;
                    FORMAT   <= IMPLIED;

                when others =>                  -- MFPT :: move from P-type
                    MACRO_OP <= MOP_MFPT;
                    FORMAT   <= IMPLIED;

                end case;
                if (IR(5 downto 3) /= "000") then   -- UII :: unimplemented
                    MACRO_OP <= MOP_UII;
                    FORMAT   <= IMPLIED;
                end if;

            when "000001" =>                    -- JMP :: jump
                MACRO_OP <= MOP_JMP;
                FORMAT   <= ONE_OPERAND;

            when "000010" =>

                case IR(5 downto 3) is
                when "000" =>                   -- RTS return from subroutine
                    MACRO_OP <= MOP_RTS;
                    FORMAT   <= IMPLIED;

                when "011" =>                   -- SPL :: set priority level

                    MACRO_OP <= MOP_SPL;
                    FORMAT   <= IMPLIED;

                when "100" =>              
                    case IR(2 downto 0) is

                        when "000" =>           -- NOP :: no operation
                        MACRO_OP <= MOP_NOP;
                        FORMAT   <= IMPLIED;

                        when "001" =>           -- CLC :: clear C bit
                        MACRO_OP <= MOP_CLC;
                        FORMAT   <= IMPLIED;

                        when "010" =>           -- CLV :: clear V bit
                        MACRO_OP <= MOP_CLV;
                        FORMAT   <= IMPLIED;

                        when "100" =>           -- CLZ :: clear Z bit
                        MACRO_OP <= MOP_CLZ;
                        FORMAT   <= IMPLIED;

                        when others =>
                    end case;

                when "101" =>
                    case IR(2 downto 0) is

                        when "000" =>           -- CLN :: clear N bit
                        MACRO_OP <= MOP_CLN;
                        FORMAT   <= IMPLIED;

                        when "111" =>           -- CCC :: set cond codes
                        MACRO_OP <= MOP_CCC;
                        FORMAT   <= IMPLIED;

                        when others =>
                    end case;

                when "110" =>
                    case IR(2 downto 0) is

                        when "001" =>           -- SEC :: set C bit
                        MACRO_OP <= MOP_SEC;
                        FORMAT   <= IMPLIED;

                        when "010" =>           -- SEV :: set V bit
                        MACRO_OP <= MOP_SEV;
                        FORMAT   <= IMPLIED;

                        when "100" =>           -- SEZ :: set Z bit
                        MACRO_OP <= MOP_SEZ;
                        FORMAT   <= IMPLIED;

                        when others =>
                    end case;

                when "111" =>

                    case IR(2 downto 0) is

                        when "000" =>           -- SEN :: set N bit
                        MACRO_OP <= MOP_SEN;
                        FORMAT   <= IMPLIED;

                        when "111" =>           -- SCC :: set cond codes
                        MACRO_OP <= MOP_SCC;
                        FORMAT   <= IMPLIED;

                        when others =>

                    end case;

                when others =>                  -- UII :: unimplemented

                    MACRO_OP <= MOP_UII;
                    FORMAT   <= IMPLIED;

                end case;

            when "000011" =>                    -- SWAB :: swap bytes
                MACRO_OP <= MOP_SWAB;
                FORMAT   <= ONE_OPERAND;

            when "000100" =>                    -- BR :: branch always
                MACRO_OP <= MOP_BR;
                FORMAT   <= BRA_FORMAT;

            when "000101" =>                    -- BR :: branch always
                MACRO_OP <= MOP_BR;
                FORMAT   <= BRA_FORMAT;

            when "000110" =>                    -- BR :: branch always
                MACRO_OP <= MOP_BR;
                FORMAT   <= BRA_FORMAT;

            when "000111" =>                    -- BR :: branch always
                MACRO_OP <= MOP_BR;
                FORMAT   <= BRA_FORMAT;

            when "001000" =>                    -- BNE :: branch if negative
                MACRO_OP <= MOP_BNE;
                FORMAT   <= BRA_FORMAT;

            when "001001" =>                    -- BNE :: branch if negative
                MACRO_OP <= MOP_BNE;
                FORMAT   <= BRA_FORMAT;

            when "001010" =>                    -- BNE :: branch if negative
                MACRO_OP <= MOP_BNE;
                FORMAT   <= BRA_FORMAT;

            when "001011" =>                    -- BNE :: branch if negative
                MACRO_OP <= MOP_BNE;
                FORMAT   <= BRA_FORMAT;

            when "001100" =>                    -- BEQ :: branch if equal
                MACRO_OP <= MOP_BEQ;
                FORMAT   <= BRA_FORMAT;

            when "001101" =>                    -- BEQ :: branch if equal
                MACRO_OP <= MOP_BEQ;
                FORMAT   <= BRA_FORMAT;

            when "001110" =>                    -- BEQ :: branch if equal
                MACRO_OP <= MOP_BEQ;
                FORMAT   <= BRA_FORMAT;

            when "001111" =>                    -- BEQ :: branch if equal
                MACRO_OP <= MOP_BEQ;
                FORMAT   <= BRA_FORMAT;

            when "010000" =>                    -- BGE :: branch if greater or equal
                MACRO_OP <= MOP_BGE;
                FORMAT   <= BRA_FORMAT;

            when "010001" =>                    -- BGE :: branch if greater or equal
                MACRO_OP <= MOP_BGE;
                FORMAT   <= BRA_FORMAT;

            when "010010" =>                    -- BGE :: branch if greater or equal
                MACRO_OP <= MOP_BGE;
                FORMAT   <= BRA_FORMAT;

            when "010011" =>                    -- BGE :: branch if greater or equal
                MACRO_OP <= MOP_BGE;
                FORMAT   <= BRA_FORMAT;

            when "010100" =>                    -- BLT :: branch if less than
                MACRO_OP <= MOP_BLT;
                FORMAT   <= BRA_FORMAT;

            when "010101" =>                    -- BLT :: branch if less than
                MACRO_OP <= MOP_BLT;
                FORMAT   <= BRA_FORMAT;

            when "010110" =>                    -- BLT :: branch if less than
                MACRO_OP <= MOP_BLT;
                FORMAT   <= BRA_FORMAT;

            when "010111" =>                    -- BLT :: branch if less than
                MACRO_OP <= MOP_BLT;
                FORMAT   <= BRA_FORMAT;

            when "011000" =>                    -- BGT :: branch if greater than
                MACRO_OP <= MOP_BGT;
                FORMAT   <= BRA_FORMAT;

            when "011001" =>                    -- BGT :: branch if greater than
                MACRO_OP <= MOP_BGT;
                FORMAT   <= BRA_FORMAT;

            when "011010" =>                    -- BGT :: branch if greater than
                MACRO_OP <= MOP_BGT;
                FORMAT   <= BRA_FORMAT;

            when "011011" =>                    -- BGT :: branch if greater than
                MACRO_OP <= MOP_BGT;
                FORMAT   <= BRA_FORMAT;

            when "011100" =>                    -- BLE :: branch if less or equal
                MACRO_OP <= MOP_BLE;
                FORMAT   <= BRA_FORMAT;

            when "011101" =>                    -- BLE :: branch if less or equal
                MACRO_OP <= MOP_BLE;
                FORMAT   <= BRA_FORMAT;

            when "011110" =>                    -- BLE :: branch if less or equal
                MACRO_OP <= MOP_BLE;
                FORMAT   <= BRA_FORMAT;

            when "011111" =>                    -- BLE :: branch if less or equal
                MACRO_OP <= MOP_BLE;
                FORMAT   <= BRA_FORMAT;

            when "100000" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100001" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100010" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100011" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100100" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100101" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100110" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "100111" =>                    -- JSR :: jump to subroutine
                MACRO_OP <= MOP_JSR;
                FORMAT   <= ONE_OPERAND;

            when "101000" =>                    -- CLR :: clear
                MACRO_OP <= MOP_CLR;
                FORMAT   <= ONE_OPERAND;

            when "101001" =>                    -- COM :: ones complement
                MACRO_OP <= MOP_COM;
                FORMAT   <= ONE_OPERAND;

            when "101010" =>                    -- INC :: increment
                MACRO_OP <= MOP_INC;
                FORMAT   <= ONE_OPERAND;

            when "101011" =>                    -- DEC :: decrement
                MACRO_OP <= MOP_DEC;
                FORMAT   <= ONE_OPERAND;

            when "101100" =>                    -- NEG :: twos complement
                MACRO_OP <= MOP_NEG;
                FORMAT   <= ONE_OPERAND;

            when "101101" =>                    -- ADC :: add carry
                MACRO_OP <= MOP_ADC;
                FORMAT   <= ONE_OPERAND;

            when "101110" =>                    -- SBC :: subtract carry
                MACRO_OP <= MOP_SBC;
                FORMAT   <= ONE_OPERAND;

            when "101111" =>                    -- TST :: test
                MACRO_OP <= MOP_TST;
                FORMAT   <= ONE_OPERAND;

            when "110000" =>                    -- ROR :: rotate right
                MACRO_OP <= MOP_ROR;
                FORMAT   <= ONE_OPERAND;

            when "110001" =>                    -- ROL :: rotate left
                MACRO_OP <= MOP_ROL;
                FORMAT   <= ONE_OPERAND;

            when "110010" =>                    -- ASR :: shift right
                MACRO_OP <= MOP_ASR;
                FORMAT   <= ONE_OPERAND;

            when "110011" =>                    -- ASL :: shift left
                MACRO_OP <= MOP_ASL;
                FORMAT   <= ONE_OPERAND;

            when "110100" =>                    -- MARK :: mark stack
                MACRO_OP <= MOP_MARK;
                FORMAT   <= IMPLIED;

            when "110101" =>                    -- MFPI :: move from prev I-space
                MACRO_OP <= MOP_MFPI;
                FORMAT   <= IMPLIED;

            when "110110" =>                    -- MTPI :: move to prev I-space
                MACRO_OP <= MOP_MTPI;
                FORMAT   <= IMPLIED;

            when "110111" =>                    -- SXT :: sign extend
                MACRO_OP <= MOP_SXT;
                FORMAT   <= ONE_OPERAND;

            when "111000" =>                    -- CSM :: call supervisor mode
                MACRO_OP <= MOP_CSM;
                FORMAT   <= IMPLIED;

            when "111010" =>                    -- TSTSET :: test and set
                MACRO_OP <= MOP_TSTSET;
                FORMAT   <= ONE_OPERAND;

            when "111011" =>                    -- WRTLCK :: write lock
                MACRO_OP <= MOP_WRTLCK;
                FORMAT   <= ONE_OPERAND;

            when others =>
                MACRO_OP <= MOP_UII;
                FORMAT   <= IMPLIED;

            end case;

        -- Groups 1 through 6: Double operand word instructions

        when "0001" =>                          -- MOV :: move
            MACRO_OP <= MOP_MOV;
            FORMAT   <= TWO_OPERAND;

        when "0010" =>                          -- CMP :: compare
            MACRO_OP <= MOP_CMP;
            FORMAT   <= TWO_OPERAND;

        when "0011" =>                          -- BIT :: bit test
            MACRO_OP <= MOP_BIT;
            FORMAT   <= TWO_OPERAND;

        when "0100" =>                          -- BCI :: bit clear
            MACRO_OP <= MOP_BIC;
            FORMAT   <= TWO_OPERAND;

        when "0101" =>                          -- BIS :: bit set
            MACRO_OP <= MOP_BIS;
            FORMAT   <= TWO_OPERAND;

        when "0110" =>                          -- ADD :: add
            MACRO_OP <= MOP_ADD;
            FORMAT   <= TWO_OPERAND;


        -- Group 7: Double operand word instructions

        when "0111" =>

            case IR(11 downto 9) is

            when "000" =>                       -- MUL :: multiply
                MACRO_OP <= MOP_MUL;
                FORMAT   <= TWO_OPERAND;

            when "001" =>                       -- DIV :: divide
                MACRO_OP <= MOP_DIV;
                FORMAT   <= TWO_OPERAND;

            when "010" =>                       -- ASH :: shift
                MACRO_OP <= MOP_ASH;
                FORMAT   <= TWO_OPERAND;

            when "011" =>                       -- ASHC :: shift with carry
                MACRO_OP <= MOP_ASHC;
                FORMAT   <= TWO_OPERAND;

            when "100" =>                       -- XOR :: exclusive OR
                MACRO_OP <= MOP_XOR;
                FORMAT   <= TWO_OPERAND;

            when "101" =>

                if (IR(8 downto 6) = "000") then

                    case IR(5 downto 3) is

                        when "000" =>           -- FADD :: floating add
                            MACRO_OP <= MOP_FADD;
                            FORMAT   <= FLOAT;

                        when "001" =>           -- FSUB :: floating subtract
                            MACRO_OP <= MOP_FSUB;
                            FORMAT   <= FLOAT;

                        when "010" =>           -- FMUL :: floating multiply
                            MACRO_OP <= MOP_FMUL;
                            FORMAT   <= FLOAT;

                        when "011" =>           -- FDIV :: floating divide
                            MACRO_OP <= MOP_FDIV;
                            FORMAT   <= FLOAT;

                        when others =>          -- UII :: unimplemented
                            MACRO_OP <= MOP_UII;
                            FORMAT   <= IMPLIED;

                    end case;

                else                            -- UII :: unimplemented
                    MACRO_OP <= MOP_UII;
                    FORMAT   <= IMPLIED;

                end if;


            when "110" =>                       -- UII :: unimplemented
                MACRO_OP <= MOP_UII;
                FORMAT   <= IMPLIED;

            when others =>                      -- SOB :: decrement and branch
                MACRO_OP <= MOP_SOB;
                FORMAT   <= BRA_FORMAT;

            end case;


        -- Group 8: branches, traps and Single operand instructions

        when "1000" =>

           case IR(11 downto 6) is

            when "000000" =>                -- BPL :: branch if plus
                MACRO_OP <= MOP_BPL;
                FORMAT   <= BRA_FORMAT;

            when "000001" =>                -- BPL :: branch if plus
                MACRO_OP <= MOP_BPL;
                FORMAT   <= BRA_FORMAT;

            when "000010" =>                -- BPL :: branch if plus
                MACRO_OP <= MOP_BPL;
                FORMAT   <= BRA_FORMAT;

            when "000011" =>                -- BPL :: branch if plus
                MACRO_OP <= MOP_BPL;
                FORMAT   <= BRA_FORMAT;

            when "000100" =>                -- BMI :: branch if minus
                MACRO_OP <= MOP_BMI;
                FORMAT   <= BRA_FORMAT;

            when "000101" =>                -- BMI :: branch if minus
                MACRO_OP <= MOP_BMI;
                FORMAT   <= BRA_FORMAT;

            when "000110" =>                -- BMI :: branch if minus
                MACRO_OP <= MOP_BMI;
                FORMAT   <= BRA_FORMAT;

            when "000111" =>                -- BMI :: branch if minus
                MACRO_OP <= MOP_BMI;
                FORMAT   <= BRA_FORMAT;

            when "001000" =>                -- BHI :: branch if higher
                MACRO_OP <= MOP_BHI;
                FORMAT   <= BRA_FORMAT;

            when "001001" =>                -- BHI :: branch if higher
                MACRO_OP <= MOP_BHI;
                FORMAT   <= BRA_FORMAT;

            when "001010" =>                -- BHI :: branch if higher
                MACRO_OP <= MOP_BHI;
                FORMAT   <= BRA_FORMAT;

            when "001011" =>                -- BHI :: branch if higher
                MACRO_OP <= MOP_BHI;
                FORMAT   <= BRA_FORMAT;

            when "001100" =>                -- BLOS :: branch if lower or same
                MACRO_OP <= MOP_BLOS;
                FORMAT   <= BRA_FORMAT;

            when "001101" =>                -- BLOS :: branch if lower or same
                MACRO_OP <= MOP_BLOS;
                FORMAT   <= BRA_FORMAT;

            when "001110" =>                -- BLOS :: branch if lower or same
                MACRO_OP <= MOP_BLOS;
                FORMAT   <= BRA_FORMAT;

            when "001111" =>                -- BLOS :: branch if lower or same
                MACRO_OP <= MOP_BLOS;
                FORMAT   <= BRA_FORMAT;

            when "010000" =>                -- BVC :: branch if overflow clear
                MACRO_OP <= MOP_BVC;
                FORMAT   <= BRA_FORMAT;

            when "010001" =>                -- BVC :: branch if overflow clear
                MACRO_OP <= MOP_BVC;
                FORMAT   <= BRA_FORMAT;

            when "010010" =>                -- BVC :: branch if overflow clear
                MACRO_OP <= MOP_BVC;
                FORMAT   <= BRA_FORMAT;

            when "010011" =>                -- BVC :: branch if overflow clear
                MACRO_OP <= MOP_BVC;
                FORMAT   <= BRA_FORMAT;

            when "010100" =>                -- BVS :: branch if overflow set
                MACRO_OP <= MOP_BVS;
                FORMAT   <= BRA_FORMAT;

            when "010101" =>                -- BVS :: branch if overflow set
                MACRO_OP <= MOP_BVS;
                FORMAT   <= BRA_FORMAT;

            when "010110" =>                -- BVS :: branch if overflow set
                MACRO_OP <= MOP_BVS;
                FORMAT   <= BRA_FORMAT;

            when "010111" =>                -- BVS :: branch if overflow set
                MACRO_OP <= MOP_BVS;
                FORMAT   <= BRA_FORMAT;

            when "011000" =>                -- BCC :: branch if carry clear
                MACRO_OP <= MOP_BCC;
                FORMAT   <= BRA_FORMAT;

            when "011001" =>                -- BCC :: branch if carry clear
                MACRO_OP <= MOP_BCC;
                FORMAT   <= BRA_FORMAT;

            when "011010" =>                -- BCC :: branch if carry clear
                MACRO_OP <= MOP_BCC;
                FORMAT   <= BRA_FORMAT;

            when "011011" =>                -- BCC :: branch if carry clear
                MACRO_OP <= MOP_BCC;
                FORMAT   <= BRA_FORMAT;

            when "011100" =>                -- BCS :: branch if carry set
                MACRO_OP <= MOP_BCS;
                FORMAT   <= BRA_FORMAT;

            when "011101" =>                -- BCS :: branch if carry set
                MACRO_OP <= MOP_BCS;
                FORMAT   <= BRA_FORMAT;

            when "011110" =>                -- BCS :: branch if carry set
                MACRO_OP <= MOP_BCS;
                FORMAT   <= BRA_FORMAT;

            when "011111" =>                -- BCS :: branch if carry set
                MACRO_OP <= MOP_BCS;
                FORMAT   <= BRA_FORMAT;

            when "100000" =>                -- EMT :: emulator trap
                MACRO_OP <= MOP_EMT;
                FORMAT   <= IMPLIED;

            when "100001" =>                -- EMT :: emulator trap
                MACRO_OP <= MOP_EMT;
                FORMAT   <= IMPLIED;

            when "100010" =>                -- EMT :: emulator trap
                MACRO_OP <= MOP_EMT;
                FORMAT   <= IMPLIED;

            when "100011" =>                -- EMT :: emulator trap
                MACRO_OP <= MOP_EMT;
                FORMAT   <= IMPLIED;

            when "100100" =>                -- TRAP :: SW trap
                MACRO_OP <= MOP_TRAP;
                FORMAT   <= IMPLIED;

            when "100101" =>                -- TRAP :: SW trap
                MACRO_OP <= MOP_TRAP;
                FORMAT   <= IMPLIED;

            when "100110" =>                -- TRAP :: SW trap
                MACRO_OP <= MOP_TRAP;
                FORMAT   <= IMPLIED;

            when "100111" =>                -- TRAP :: SW trap
                MACRO_OP <= MOP_TRAP;
                FORMAT   <= IMPLIED;

            when "101000" =>                -- CLRB :: clear
                MACRO_OP <= MOP_CLR;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101001" =>                -- COMB :: ones complement
                MACRO_OP <= MOP_COM;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101010" =>                -- INCB :: increment
                MACRO_OP <= MOP_INC;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101011" =>                -- DECB :: decrement
                MACRO_OP <= MOP_DEC;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101100" =>                -- NEGB :: twos complement
                MACRO_OP <= MOP_NEG;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101101" =>                -- ADCB :: add carry
                MACRO_OP <= MOP_ADC;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101110" =>                -- SBCB :: subtract carry
                MACRO_OP <= MOP_SBC;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "101111" =>                -- TSTB :: test
                MACRO_OP <= MOP_TST;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "110000" =>                -- RORB :: rotate right
                MACRO_OP <= MOP_ROR;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "110001" =>                -- ROLB :: rotate left
                MACRO_OP <= MOP_ROL;
                BYTE_OP  <= '1';

            when "110010" =>                -- ASRB :: shift right
                MACRO_OP <= MOP_ASR;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "110011" =>                -- ASLB :: shift left
                MACRO_OP <= MOP_ASL;
                FORMAT   <= ONE_OPERAND;
                BYTE_OP  <= '1';

            when "110100" =>                -- MTPS :: move to status
                MACRO_OP <= MOP_MTPS;
                FORMAT   <= IMPLIED;

            when "110101" =>                -- MFPD :: move from prev D-space
                MACRO_OP <= MOP_MFPD;
                FORMAT   <= IMPLIED;

            when "110110" =>                -- MTPD :: move to prev D-space
                MACRO_OP <= MOP_MTPD;
                FORMAT   <= IMPLIED;

            when "110111" =>                -- MFPS :: move from status
                MACRO_OP <= MOP_MFPS;
                FORMAT   <= IMPLIED;

            when others =>
                MACRO_OP <= MOP_UII;
                FORMAT   <= IMPLIED;

            end case;


    -- Groups 9 through 14:  Double operand byte instructions

        when "1001" =>                      -- MOVB :: move
            MACRO_OP <= MOP_MOV;
            FORMAT   <= TWO_OPERAND;
            BYTE_OP  <= '1';

        when "1010" =>                      -- CMPB :: compare
            MACRO_OP <= MOP_CMP;
            FORMAT   <= TWO_OPERAND;
            BYTE_OP  <= '1';

        when "1011" =>                      -- BITB :: bit test
            MACRO_OP <= MOP_BIT;
            FORMAT   <= TWO_OPERAND;
            BYTE_OP  <= '1';

        when "1100" =>                      -- BICB :: bit clear
            MACRO_OP <= MOP_BIC;
            FORMAT   <= TWO_OPERAND;
            BYTE_OP  <= '1';

        when "1101" =>                      -- BISB :: bit set
            MACRO_OP <= MOP_BIS;
            FORMAT   <= TWO_OPERAND;
            BYTE_OP  <= '1';

        when "1110" =>                      -- SUB :: subtract
            MACRO_OP <= MOP_SUB;
            FORMAT   <= TWO_OPERAND;

    -- Group 15: floating point (currently not implemented)

        when others =>                      -- call fpp
            MACRO_OP <= MOP_UII;
            FORMAT   <= FLOAT;

        end case;

    end process;

end BEHAVIORAL;

