
--========================================================================
-- cmpr.vhd ::  4-bit comparator
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;


entity CMPR is
    port (
          A_LE_B : out std_logic;                     -- A <= B
          A      : in  std_logic_vector(3 downto 0);  -- operand A
          B      : in  std_logic_vector(3 downto 0)   -- operand B
         );
end CMPR;


architecture BEHAVIORAL of CMPR is

    signal  P    : std_logic_vector(3 downto 0);
    signal  G    : std_logic_vector(3 downto 0);
    signal  CX   : std_logic_vector(3 downto 1);

begin

    --=====================================
    -- Propagate and Generate
    --=====================================
    G <= (not A(3 downto 0)) and B(3 downto 0);
    P <= (not A(3 downto 0)) or  B(3 downto 0);

    A_LE_B <= G(3)  or (P(3)  and CX(3));
    CX(3)  <= G(2)  or (P(2)  and CX(2));
    CX(2)  <= G(1)  or (P(1)  and CX(1));
    CX(1)  <= G(0)  or  P(0);


end BEHAVIORAL;

