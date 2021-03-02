
--========================================================================
-- decode.vhd ::  PDP-8 instruction decoder
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;

use work.my_types.all;


entity DECODE is
    port (
        MACRO_OP    : out OPCODE_TYPE;
        OP_GROUP    : out std_logic_vector( 2 downto 0);
        DECODE_IN   : in  std_logic_vector(11 downto 0)
       );
end DECODE;

architecture BEHAVIORAL of DECODE is

    --=================================================================
    -- signal definitions
    --=================================================================


begin

    --=========================================================
    -- Decode the opcode and addressing mode
    --=========================================================
    DECODE_OPCODE_AND_ADDRESS_MODE:
    process(DECODE_IN)
    begin

        -- default values
        MACRO_OP <= MOP_UII;
        OP_GROUP <= "000";

        case DECODE_IN(11 downto 9) is

            -- 0000  logical AND
            when "000" =>
                MACRO_OP <= MOP_AND;

            -- 1000  2's complement add
            when "001" =>
                MACRO_OP <= MOP_TAD;

            -- 2000  increment and skip if zero
            when "010" =>
                MACRO_OP <= MOP_ISZ;

            -- 3000  deposit and clear AC
            when "011" =>
                MACRO_OP <= MOP_DCA;

            -- 4000  jump to subroutine
            when "100" =>
                MACRO_OP <= MOP_JMS;

            -- 5000  jump
            when "101" =>
                MACRO_OP <= MOP_JMP;

            -- 6xxx  IOT instructions
            when "110" =>

                case DECODE_IN(8 downto 0) is

                    -- IOT GROUP 6

                    -- 6001  turn interrupt on
                    when "000000001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_ION;

                    -- 6002  turn interrupt off
                    when "000000010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_IOF;

                    -- 6004  convert A to D
                    when "000000100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_IOF;

                    -- Teletype keyboard/reader

                    -- 6031  skip if keyboard flag set
                    when "000011001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_KSF;

                    -- 6032  clear AC and keyboard flag
                    when "000011010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_KCC;

                    -- 6034  read keyboard buffer
                    when "000011100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_KRS;

                    -- 6036  read keyboard buffer
                    when "000011110" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_KRB;

                    -- Teletype teleprinter/punch

                    -- 6041  skip if teleprinter flag set
                    when "000100001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_TSF;

                    -- 6042  clear teleprinter flag
                    when "000100010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_TCF;

                    -- 6044  load teleprinter and print
                    when "000100100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_TPC;

                    -- 6046  load teleprinter buffer
                    when "000100110" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_TLS;

                    -- Paper tape reader type PC02

                    -- 6011  skip if reader flag set
                    when "000001001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RSF;

                    -- 6012  read reader buffer
                    when "000001010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RRB;

                    -- 6014  fetch character
                    when "000001100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RFC;

                    -- Paper tape punch type PC03

                    -- 6021  skip if punch flag set
                    when "000010001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_PSF;

                    -- 6022  clear flag and buffer
                    when "000010010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_PCF;

                    -- 6024  load and punch
                    when "000010100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_PPC;

                    -- 6026  load and punch
                    when "000010110" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_PLS;

                    -- Display type 34B

                    -- 6053  clear and load x buffer
                    when "000101011" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DXL;

                    -- 6063  clear and load y buffer
                    when "000110011" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DYL;

                    -- 6057  combined dxl and dix
                    when "000101111" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DXS;

                    -- 6067  combined dyl and diy
                    when "000110111" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DYS;

                    -- 6064  intensify point
                    when "000110100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DIY;

                    -- 6054  intensify point
                    when "000101100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DIX;

                    -- 6061  clear y buffer
                    when "000110001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DCY;

                    -- 6051  clear x buffer
                    when "000101001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DCX;

                    -- Dectape Control Type TU55/TC01

                    -- 6761  read status register A
                    when "111110001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTRA;

                    -- 6762  clear status register A
                    when "111110010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTCA;

                    -- 6764  load status register A
                    when "111110100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTXA;

                    -- 6771  skip on flags
                    when "111111001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTSF;

                    -- 6772  read status register B
                    when "111111010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTRB;

                    -- 6774  load status register B
                    when "111111100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_DTLB;

                    -- Extended Memory Type 183

                    -- 62n1  change to data field 0
                    when "010000001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 1
                    when "010001001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 2
                    when "010010001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 3
                    when "010011001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 4
                    when "010100001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 5
                    when "010101001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 6
                    when "010110001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n1  change to data field 7
                    when "010111001" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CDF;

                    -- 62n2  change to instruction field 0
                    when "010000010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 1
                    when "010001010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 2
                    when "010010010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 3
                    when "010011010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 4
                    when "010100010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 5
                    when "010101010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 6
                    when "010110010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 62n2  change to instruction field 7
                    when "010111010" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_CIF;

                    -- 6214  read data field into AC 6-8
                    when "010001100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RDF;

                    -- 6224  read instruction field into AC 6-8
                    when "010010100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RIF;

                    -- 6244  restore memory field
                    when "010100100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RMF;

                    -- 6234  read interrupt buffer
                    when "010011100" =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_RIB;

                    -- 6xxx  generic IOT instructions
                    when others =>
                        OP_GROUP <= "110";
                        MACRO_OP <= MOP_IOT;

                end case;

            -- 7xxx  IOP instructions
            when "111" =>

                if (DECODE_IN(8) = '0') then

                    -- IOP GROUP 1
                    OP_GROUP <= "001";

                    case DECODE_IN(7 downto 0) is

                        -- 7000  no operation
                        when "00000000" =>
                            MACRO_OP <= MOP_NOP;

                        -- 7002  byte swap
                        when "00000010" =>
                            MACRO_OP <= MOP_BSW;

                        -- 7200  clear AC
                        when "10000000" =>
                            MACRO_OP <= MOP_CLA;

                        -- 7120  set link
                        when "01010000" =>
                            MACRO_OP <= MOP_STL;

                        -- 7100  clear link
                        when "01000000" =>
                            MACRO_OP <= MOP_CLL;

                        -- 7041  complement and increment AC
                        when "00100001" =>
                            MACRO_OP <= MOP_CIA;

                        -- 7040  complement AC
                        when "00100000" =>
                            MACRO_OP <= MOP_CMA;

                        -- 7020  complement link
                        when "00010000" =>
                            MACRO_OP <= MOP_CML;

                        -- 7010  rotate AC and link right one
                        when "00001000" =>
                            MACRO_OP <= MOP_RAR;

                        -- 7004  rotate AC and link left one
                        when "00000100" =>
                            MACRO_OP <= MOP_RAL;

                        -- 7012  rotate AC and link right two
                        when "00001010" =>
                            MACRO_OP <= MOP_RTR;

                        -- 7006  rotate AC and link left two
                        when "00000110" =>
                            MACRO_OP <= MOP_RTL;

                        -- 7001  increment AC
                        when "00000001" =>
                            MACRO_OP <= MOP_IAC;

                        -- IOP group 1 combined opcodes
                        when others =>
                            MACRO_OP <= MOP_IOP1;

                    end case;

                else

                    if (DECODE_IN(0) = '0') then

                    -- IOP GROUP 2
                    OP_GROUP <= "010";

                    case DECODE_IN(7 downto 1) is

                        -- 7510  skip on plus AC
                        when "0100100" =>
                            MACRO_OP <= MOP_SPA;

                        -- 7500  skip on minus AC
                        when "0100000" =>
                            MACRO_OP <= MOP_SMA;

                        -- 7440  skip on zero AC
                        when "0010000" =>
                            MACRO_OP <= MOP_SZA;

                        -- 7450  skip on non zero AC
                        when "0010100" =>
                            MACRO_OP <= MOP_SNA;

                        -- 7420  skip on non-zero link
                        when "0001000" =>
                            MACRO_OP <= MOP_SNL;

                        -- 7430  skip on zero link
                        when "0001100" =>
                            MACRO_OP <= MOP_SZL;

                        -- 7410  skip unconditionally
                        when "0000100" =>
                            MACRO_OP <= MOP_SKP;

                        -- 7404  inclusive OR, switch register with AC
                        when "0000010" =>
                            MACRO_OP <= MOP_OSR;

                        -- 7402  halt the program
                        when "0000001" =>
                            MACRO_OP <= MOP_HLT;

                        -- 7400  no operation
                        when "0000000" =>
                            MACRO_OP <= MOP_NOP;

                        -- 7604  load AC with switch register
                        when "1000010" =>
                            MACRO_OP <= MOP_LAS;

                        -- 7600  clear AC
                        when "1000000" =>
                            MACRO_OP <= MOP_CLA2;

                        -- IOP group 2 combined opcodes
                        when others =>
                            MACRO_OP <= MOP_IOP2;

                    end case;
                    else

                    -- EAE type
                    OP_GROUP <= "100";

                    case DECODE_IN(7 downto 1) is

                        -- 7407  divide
                        when "0000011" =>
                            MACRO_OP <= MOP_DVI;

                        -- 7411  normalize
                        when "0000100" =>
                            MACRO_OP <= MOP_NMI;

                        -- 7413  shift left
                        when "0000101" =>
                            MACRO_OP <= MOP_SHL;

                        -- 7415  arithmetic shift right
                        when "0000110" =>
                            MACRO_OP <= MOP_ASR;

                        -- 7417  logical shift right
                        when "0000111" =>
                            MACRO_OP <= MOP_LSR;

                        -- 7421  load AC into MQ,
                        when "0001000" =>
                            MACRO_OP <= MOP_MQL;

                        -- 7405  multiply
                        when "0000010" =>
                            MACRO_OP <= MOP_MUY;

                        -- 7501  load AC with AC or MQ
                        when "0100000" =>
                            MACRO_OP <= MOP_MQA;

                        -- 7721  clear AC and MQ
                        when "1101000" =>
                            MACRO_OP <= MOP_CAM;

                        -- 7621  clear AC and MQ
                        when "1001000" =>
                            MACRO_OP <= MOP_CAM;

                        -- 7521  swap AC and MQ
                        when "0101000" =>
                            MACRO_OP <= MOP_SWP;

                        -- 7441  read SC into AC
                        when "0010000" =>
                            MACRO_OP <= MOP_SCA;

                        -- 7701  read MQ into AC
                        when "1100000" =>
                            MACRO_OP <= MOP_AQL;

                        -- undefined
                        when others =>
                            MACRO_OP <= MOP_EAE;

                    end case;
                    end if;
                end if;

            when others =>
                MACRO_OP <= MOP_UII;
       
        end case;

    end process;

end BEHAVIORAL;
