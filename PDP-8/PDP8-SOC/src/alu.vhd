
--========================================================================
-- alu.vhd ::  PDP-8 12-bit ALU
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_types.all;


entity ALU is
    port (
          RBUS   : out std_logic_vector(11 downto 0);  -- result bus
          COUT   : out std_logic;                      -- carry out
          ZERO   : out std_logic;                      -- zero
          A      : in  std_logic_vector(11 downto 0);  -- operand A
          B      : in  std_logic_vector(11 downto 0);  -- operand B
          OP     : in  ALU_OP_TYPE;                    -- ALU micro op
          CIN    : in  std_logic                       -- carry bit
         );
end ALU;


architecture BEHAVIORAL of ALU is

    --=================================================================
    -- Types, component, and signal definitions
    --=================================================================

    --=================================================================
    -- A input mux selects  (buffer, invert, or supply a constant)
    --=================================================================
    type  AMUX_SEL_TYPE is (
        ALL_ZERO,   -- all zeros
        ALL_ONES,   -- all ones
        BUF,        -- buffer
        SWAP,       -- swap
        INV         -- invert
    );


    --=================================================================
    -- B input mux selects  (buffer, invert, or supply a constant)
    --=================================================================
    type  BMUX_SEL_TYPE is (
        ALL_ZERO,   -- all zeros
        ALL_ONES,   -- all ones
        BUF,        -- buffer
        INV         -- invert
    );


    --=================================================================
    -- Ouput mux selects  ( xor, or, and, shift, or sum)
    --=================================================================
    type  RMUX_SEL_TYPE is (
        SEL_XOR,    -- logical xor
        SEL_OR,     -- logical or
        SEL_AND,    -- logical and
        SEL_SUM,    -- arithmetic sum
        SEL_ROL,    -- rotate left
        SEL_ROR     -- rotate right
    );

    -- ALU mux selects
    signal  ASEL : AMUX_SEL_TYPE;
    signal  BSEL : BMUX_SEL_TYPE;
    signal  MSEL : RMUX_SEL_TYPE;

    -- ALU busses
    signal  AX   : std_logic_vector(11 downto 0);
    signal  BX   : std_logic_vector(11 downto 0);
    signal  CX   : std_logic_vector(11 downto 0);
    signal  SUM  : std_logic_vector(11 downto 0);
    signal  MBUS : std_logic_vector(11 downto 0);
    signal  AXB  : std_logic_vector(11 downto 0);

    -- propagate and generate
    signal  P    : std_logic_vector(11 downto 0);
    signal  G    : std_logic_vector(11 downto 0);

    -- internal carries
    signal  CIN1      : std_logic;
    signal  ALU_COUT  : std_logic;

begin

    --================================================================
    -- Start of the behavioral description
    --================================================================

    --====================
    -- Opcode Decoding
    --====================
    OPCODE_DECODING:
    process(OP, CIN)
    begin

        -- Default values
        ASEL <= BUF;
        BSEL <= BUF;
        MSEL <= SEL_SUM;
        CIN1 <= '0';

        case OP is

            when OP_ADD =>
                -- A plus B
                CIN1 <= '0';

            when OP_ADC =>
                -- A plus B plus Cin
                CIN1 <= CIN;

            when OP_SUB =>
                -- A minus B
                BSEL <= INV;
                CIN1 <= '1';

            when OP_SBC =>
                -- A minus B minus CIN
                BSEL <= INV;
                CIN1 <= not CIN;

            when OP_INCA =>
                -- A plus 1
                BSEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_INCB =>
                -- A plus 1
                ASEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_DECA =>
                -- A minus 1
                BSEL <= ALL_ONES;
                CIN1 <= '0';

            when OP_DECB =>
                -- B minus 1
                ASEL <= ALL_ONES;
                CIN1 <= '0';

            when OP_AND =>
                -- A and B
                MSEL <= SEL_AND;

            when OP_COM =>
                -- 1's complement A
                ASEL <= INV;
                BSEL <= ALL_ZERO;
                MSEL <= SEL_OR;

            when OP_NEG =>
                -- 2's complement A
                ASEL <= INV;
                BSEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_OR =>
                -- A or B
                MSEL <= SEL_OR;

            when OP_XOR =>
                -- A xor B
                MSEL <= SEL_XOR;

            when OP_TA =>
                -- transfer A
                BSEL <= ALL_ZERO;
                MSEL <= SEL_OR;

            when OP_TB =>
                -- transfer B
                ASEL <= ALL_ZERO;
                MSEL <= SEL_OR;

            when OP_ROL =>
                -- rotate left A
                BSEL <= ALL_ZERO;
                MSEL <= SEL_ROL;

            when OP_ROR =>
                -- rotate right A
                BSEL <= ALL_ZERO;
                MSEL <= SEL_ROR;

            when OP_SWAP =>
                -- swap A
                ASEL <= SWAP;
                BSEL <= ALL_ZERO;
                MSEL <= SEL_OR;

            when OP_ONE =>
                -- output one
                ASEL <= ALL_ZERO;
                BSEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_ONES =>
                -- output all ones
                ASEL <= ALL_ZERO;
                BSEL <= ALL_ONES;
                CIN1 <= '0';

            when others =>
                -- output all zeros
                ASEL <= ALL_ZERO;
                BSEL <= ALL_ZERO;
                MSEL <= SEL_OR;

        end case;

    end process;


    --=========================
    -- Operand A (shift) mux
    --=========================
    OPERAND_A_MUX:
    process(ASEL, A)
    begin

        case ASEL is

            when BUF =>
                -- A
                AX <= A;

            when INV =>
                -- not A
                AX <= not A;

            when SWAP =>
                -- swap A
                AX <= A(5 downto 0) & A(11 downto 6);

            when ALL_ONES =>
                -- minus 1
                AX <= (others => '1');

            when others =>
                -- zero
                AX <= (others => '0');

        end case;

    end process;


    --=========================
    -- Operand B mux
    --=========================
    OPERAND_B_MUX:
    process(BSEL, B)
    begin

        case BSEL is

            when BUF =>
                -- B
                BX <= B;

            when INV =>
                -- not B
                BX <= not B;

            when ALL_ONES =>
                -- minus 1
                BX <= (others => '1');

            when others =>
                -- zero
                BX <= (others => '0');

        end case;

    end process;


    --================================================
    -- ALU output mux
    --================================================
    ALU_OUTPUT_MUX:
    process(MSEL, AXB, SUM, A, P, G, CIN, ALU_COUT)
    begin

        case MSEL is

            when SEL_ROL =>
                -- left rotate
                MBUS  <= A(10 downto 0) & CIN;
                COUT  <= A(11);

            when SEL_ROR =>
                -- right rotate
                MBUS  <= CIN & A(11 downto 1);
                COUT  <= A(0);

            when SEL_XOR =>
                -- A xor B
                MBUS  <= AXB;
                COUT  <= '0';

            when SEL_OR =>
                -- A or B
                MBUS  <= P;
                COUT  <= '0';

            when SEL_AND =>
                -- A and B
                MBUS  <= G;
                COUT  <= '0';

            when others =>
                -- Arithmetic ops
                MBUS  <= SUM;
                COUT  <= ALU_COUT;

        end case;

    end process;


    --=====================================
    -- ALU Logic
    --=====================================

    G   <= AX and BX;
    P   <= AX or  BX;

    AXB <= AX xor BX;
    SUM <= CX xor AXB;

    --=========================
    -- carry look-ahead logic
    --=========================
    CX(11) <= G(10) or (P(10) and CX(10));
    CX(10) <= G(9)  or (P(9)  and CX(9));
    CX(9)  <= G(8)  or (P(8)  and CX(8));
    CX(8)  <= G(7)  or (P(7)  and CX(7));
    CX(7)  <= G(6)  or (P(6)  and CX(6));
    CX(6)  <= G(5)  or (P(5)  and CX(5));
    CX(5)  <= G(4)  or (P(4)  and CX(4));
    CX(4)  <= G(3)  or (P(3)  and CX(3));
    CX(3)  <= G(2)  or (P(2)  and CX(2));
    CX(2)  <= G(1)  or (P(1)  and CX(1));
    CX(1)  <= G(0)  or (P(0)  and CX(0));
    CX(0)  <= CIN1;

    ALU_COUT  <= G(11) or (P(11) and CX(11));

    ZERO <= (not
       (MBUS(11) or MBUS(10) or MBUS(9) or MBUS(8) or
        MBUS(7)  or MBUS(6)  or MBUS(5) or MBUS(4) or
        MBUS(3)  or MBUS(2)  or MBUS(1) or MBUS(0) ));

    RBUS <= MBUS;


end BEHAVIORAL;

