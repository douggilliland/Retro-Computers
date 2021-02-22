
--========================================================================
-- alu.vhd ::  PDP-11 16-bit ALU
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;

use work.my_types.all;

entity ALU is
    port (
          COUT     : out std_logic;                      -- carry out
          ZERO     : out std_logic;                      -- zero
          OVFL     : out std_logic;                      -- overflow
          SIGN     : out std_logic;                      -- sign bit
          RBUS     : out std_logic_vector(15 downto 0);  -- result bus
          A        : in  std_logic_vector(15 downto 0);  -- operand A
          B        : in  std_logic_vector(15 downto 0);  -- operand B
          OP       : in  ALU_OP_TYPE;                    -- micro op
          BYTE_OP  : in  std_logic;                      -- 1=byte/0=word
          DIV_OP   : in  std_logic;                      -- divide op
          DIV_SBIT : in  std_logic;                      -- divide sign bit
          CIN      : in  std_logic                       -- carry in
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
        SWAP,       -- swap bytes
        BUF,        -- buffer
        INV         -- invert
    );


    --=================================================================
    -- B input mux selects  (buffer, invert, or supply a constant)
    --=================================================================
    type  BMUX_SEL_TYPE is (
        ALL_ZERO,   -- all zeros
        TWO,        -- two
        MINUS1,     -- all ones
        MINUS2,     -- minus two
        BUF,        -- buffer
        INV         -- invert
    );


    --=================================================================
    -- Ouput mux selects  ( xor, or, and, shift, or sum)
    --=================================================================
    type  OMUX_SEL_TYPE is (
        SEL_XOR,    -- logical xor
        SEL_OR,     -- logical or
        SEL_AND,    -- logical and
        SEL_SUM,    -- arithmetic sum
        SEL_ASL,    -- arithmetic shift left
        SEL_ASR,    -- arithmetic shift right
        SEL_LSR,    -- logical shift right
        SEL_ROR     -- rotate right
    );

    -- ALU mux selects
    signal  ASEL : AMUX_SEL_TYPE;
    signal  BSEL : BMUX_SEL_TYPE;
    signal  RSEL : OMUX_SEL_TYPE;

    -- ALU busses
    signal  AX   : std_logic_vector(16 downto 0);
    signal  BX   : std_logic_vector(16 downto 0);
    signal  AXB  : std_logic_vector(16 downto 0);
    signal  SUM  : std_logic_vector(16 downto 0);
    signal  RBI  : std_logic_vector(15 downto 0);

    -- propagate and generate
    signal  P    : std_logic_vector(15 downto 0);
    signal  G    : std_logic_vector(15 downto 0);

    -- flags
    signal  V    : std_logic;   -- overflow
    signal  Z    : std_logic;   -- zero
    signal  N    : std_logic;   -- sign bit

    -- internal carries
    signal  CO   : std_logic;
    signal  CIN1 : std_logic;
    signal  CX   : std_logic_vector(16 downto 0);

    -- misc
    signal  ASE  : std_logic_vector(8 downto 0);
    signal  BSE  : std_logic_vector(8 downto 0);


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
        RSEL <= SEL_SUM;
        CIN1 <= '0';

        case OP is

            when OP_ADD =>
                -- A plus B

            when OP_ADC =>
                -- A plus Cin
                BSEL <= ALL_ZERO;
                CIN1 <= CIN;

            when OP_SUBB =>
                -- A minus B
                BSEL <= INV;
                CIN1 <= '1';

            when OP_SUBA =>
                -- B minus A
                ASEL <= INV;
                CIN1 <= '1';

            when OP_SBC =>
                -- A minus CIN
                BSEL <= MINUS1;
                CIN1 <= not CIN;

            when OP_INCA1 =>
                -- increment A
                BSEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_INCA2 =>
                -- increment A by 2
                BSEL <= TWO;
                CIN1 <= '0';

            when OP_DECA1 =>
                -- decrement A
                BSEL <= MINUS1;

            when OP_DECA2 =>
                -- decrement A by 2
                BSEL <= MINUS2;

            when OP_INV =>
                -- 1's complement A
                ASEL <= INV;
                BSEL <= ALL_ZERO;
                RSEL <= SEL_OR;

            when OP_NEG =>
                -- 2's complement A
                ASEL <= INV;
                BSEL <= ALL_ZERO;
                CIN1 <= '1';

            when OP_AND =>
                -- A and B
                RSEL <= SEL_AND;

            when OP_BIC =>
                -- not A and B
                ASEL <= INV;
                RSEL <= SEL_AND;

            when OP_CZC =>
                -- A and not B
                BSEL <= INV;
                RSEL <= SEL_AND;

            when OP_SZC =>
                -- not A and B
                ASEL <= INV;
                RSEL <= SEL_AND;

            when OP_OR =>
                -- A or B
                RSEL <= SEL_OR;

            when OP_XOR =>
                -- A xor B
                RSEL <= SEL_XOR;

            when OP_TA =>
                -- transfer A
                BSEL <= ALL_ZERO;
                RSEL <= SEL_OR;

            when OP_TB =>
                -- transfer B
                ASEL <= ALL_ZERO;
                RSEL <= SEL_OR;

            when OP_SWP =>
                -- swap bytes of A
                BSEL <= ALL_ZERO;
                ASEL <= SWAP;
                RSEL <= SEL_OR;

            when OP_ASL =>
                -- arithmetic shift left A
                BSEL <= ALL_ZERO;
                RSEL <= SEL_ASL;

            when OP_LSR =>
                -- logical shift right A
                BSEL <= ALL_ZERO;
                RSEL <= SEL_LSR;

            when OP_ASR =>
                -- logical shift right A
                BSEL <= ALL_ZERO;
                RSEL <= SEL_ASR;

            when OP_ROR =>
                -- rotate right A
                BSEL <= ALL_ZERO;
                RSEL <= SEL_ROR;

            when OP_ONES =>
                -- output all ones
                ASEL <= ALL_ZERO;
                BSEL <= MINUS1;
                RSEL <= SEL_OR;

            when others =>
                -- output all zeros
                ASEL <= ALL_ZERO;
                BSEL <= ALL_ZERO;
                RSEL <= SEL_OR;

        end case;

    end process;


    BSE <= (others => B(7));
    ASE <= (others => A(7));

    --=========================
    -- Operand A mux
    --=========================
    OPERAND_A_MUX:
    process(ASEL, A, ASE, BYTE_OP)
    begin

        case ASEL is

            when BUF =>
                -- A
                AX <= A(15) & A;
                if (BYTE_OP = '1') then
                    AX <= ASE & A(7 downto 0);
                end if;

            when INV =>
                -- not A
                AX <= not (A(15) & A);
                if (BYTE_OP = '1') then
                    AX <= not (ASE & A(7 downto 0));
                end if;

            when SWAP =>
                -- swap bytes
                AX <= '0' & A(7 downto 0) & A(15 downto 8);

            when others =>
                -- zero
                AX <= (others => '0');

        end case;

    end process;


    --=========================
    -- Operand B mux
    --=========================
    OPERAND_B_MUX:
    process(BSEL, B, BSE, BYTE_OP, DIV_OP, DIV_SBIT)
    begin

        case BSEL is

            when MINUS1 =>
                -- for decrement
                BX <= (others => '1');

            when MINUS2 =>
                -- for decrement by 2
                BX <= "11111111111111110";

            when TWO =>
                -- for increment by 2
                BX <= "00000000000000010";

            when BUF =>
                -- B
                BX <= B(15) & B;
                if (BYTE_OP = '1') then
                    BX <= BSE & B(7 downto 0);
                end if;
                if (DIV_OP = '1') then
                    BX <= (DIV_SBIT or B(15)) & B;
                end if;

            when INV =>
                -- not B
                BX <= not(B(15) & B);
                if (BYTE_OP = '1') then
                    BX <= not (BSE & B(7 downto 0));
                end if;

            when others =>
                -- zero
                BX <= (others => '0');

        end case;

    end process;


    --================================================
    -- ALU output mux
    --================================================
    ALU_OUTPUT_MUX:
    process(RSEL, AXB, SUM, B, P, G, CX, BYTE_OP, DIV_OP, DIV_SBIT)
    begin

        case RSEL is

            when SEL_ASL =>
                -- arithmetic shift left
                RBI <= P(14 downto 0) & '0';
                CO  <= P(15);

            when SEL_LSR =>
                -- logical shift right
                RBI <= '0' & P(15 downto 1);
                CO  <= P(0);

            when SEL_ASR =>
                -- arithmetic shift right
                RBI <= P(15) & P(15 downto 1);
                CO  <= P(0);

            when SEL_ROR =>
                -- right rotate
                RBI <= P(0) & P(15 downto 1);
                CO  <= P(0);

            when SEL_XOR =>
                -- A xor B
                RBI <= AXB(15 downto 0);
                CO  <= P(15);

            when SEL_OR =>
                -- A or B
                RBI <= P(15 downto 0);
                CO  <= P(15);

            when SEL_AND =>
                -- A and B
                RBI <= G(15 downto 0);
                CO  <= P(15);

            when others =>
                -- Arithmetic ops
                RBI <= SUM(15 downto 0);
                CO <= CX(16);

        end case;

        -- for byte operations
        if (BYTE_OP = '1') then
            CO <= CX(8);
        end if;

        -- for divide
        if (DIV_OP = '1') then
            CO <= CX(16) or DIV_SBIT;
        end if;

    end process;

    RBUS <= RBI;


    --=====================================
    -- Propagate and Generate
    --=====================================
    G <= AX(15 downto 0) and BX(15 downto 0);
    P <= AX(15 downto 0) or  BX(15 downto 0);


    --=====================================
    -- carry look-ahead logic
    --=====================================
    CX(16) <= G(15) or (P(15) and CX(15));
    CX(15) <= G(14) or (P(14) and CX(14));
    CX(14) <= G(13) or (P(13) and CX(13));
    CX(13) <= G(12) or (P(12) and CX(12));
    CX(12) <= G(11) or (P(11) and CX(11));
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


    --=========================
    -- ALU SUM
    --=========================
    AXB <= AX xor BX;
    SUM <= CX xor AXB;


    --=========================
    -- Overflow flag
    --=========================
    OVERFLOW_FLAG:
    process(BYTE_OP, A, RSEL, SUM)
    begin
        V <= '0';
        if (RSEL = SEL_SUM) then
            V <= SUM(16) xor SUM(15);
            if (BYTE_OP = '1') then
                V <= SUM(8) xor SUM(7);
            end if;
        end if;
        -- for left shifts set when sign changes
        if (RSEL = SEL_ASL) then
            V <= A(15) xor SUM(14);
        end if;
    end process;


    --=========================
    -- Zero flag
    --=========================
    ZERO_FLAG:
    process(BYTE_OP, RBI)
    begin
        Z <= (not(RBI(15) or RBI(14) or RBI(13) or RBI(12) or
                  RBI(11) or RBI(10) or RBI(9)  or RBI(8) or
                  RBI(7)  or RBI(6)  or RBI(5)  or RBI(4) or
                  RBI(3)  or RBI(2)  or RBI(1)  or RBI(0)));
        if (BYTE_OP = '1') then
            Z <= (not(RBI(7)  or RBI(6)  or RBI(5)  or RBI(4) or
                      RBI(3)  or RBI(2)  or RBI(1)  or RBI(0)));
        end if;
    end process;


    --=========================
    -- Sign-bit Flag
    --=========================
    SIGN_FLAG:
    process(BYTE_OP, RBI)
    begin
        N <= RBI(15);
        if (BYTE_OP = '1') then
            N <= RBI(7);
        end if;
    end process;


    --=========================
    -- Flags
    --=========================

    -- zero
    ZERO <= Z;
    -- carry out
    COUT <= CO;
    -- overflow
    OVFL <= V;
    -- sign
    SIGN <= N;


end BEHAVIORAL;

