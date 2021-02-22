
--========================================================================
-- addr.vhd ::  PDP-11 16-bit address adder
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.my_types.all;


entity ADDR is
    port (
        SX     : out std_logic_vector(15 downto 0);  -- result bus
        BX     : in  std_logic_vector(15 downto 0);  -- operand bus
        DISP   : in  std_logic_vector( 7 downto 0);  -- displacement
        OP     : in  SX_OP_TYPE                      -- micro op
    );
end ADDR;


architecture BEHAVIORAL of ADDR is

    --=================================================================
    -- Types, component, and signal definitions
    --=================================================================

    -- internal busses
    signal  AX   : std_logic_vector(15 downto 0);
    signal  DSE  : std_logic_vector( 6 downto 0);


begin

    --================================================================
    -- Start of the behavioral description
    --================================================================

    --====================
    -- Opcode Decoding
    --====================
    OPCODE_DECODING:
    process(OP, DSE, DISP)
    begin

        case OP is

            when OP_REL =>
                -- add relative offset
                AX <= DSE & DISP & '0';

            when OP_DEC2 =>
                -- decrement by 2
                AX <= "1111111111111110";

            when others =>
                -- increment by 2
                AX <= "0000000000000010";

        end case;

    end process;


    DSE <= (others => DISP(7));

    SX <= AX + BX;


end BEHAVIORAL;

