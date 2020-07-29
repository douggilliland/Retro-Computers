library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- DM7400 Quad 2-Input NAND Gate

entity dm2513 is

	port(
		addr: in std_logic_vector(8 downto 0);
		output: out std_logic_vector(4 downto 0)
	);

end dm2513;  
  
architecture behavior of dm2513 is
begin

	output <=         
	
        -- @
        "00000" when addr = "000000000" else
        "01110" when addr = "000000001" else
        "10001" when addr = "000000010" else
        "10101" when addr = "000000011" else
        "10111" when addr = "000000100" else
        "10110" when addr = "000000101" else
        "10000" when addr = "000000110" else
        "01111" when addr = "000000111" else

        -- A
        "00000" when addr = "000001000" else
        "00100" when addr = "000001001" else
        "01010" when addr = "000001010" else
        "10001" when addr = "000001011" else
        "10001" when addr = "000001100" else
        "11111" when addr = "000001101" else
        "10001" when addr = "000001110" else
        "10001" when addr = "000001111" else

        -- B
        "00000" when addr = "000010000" else
        "11110" when addr = "000010001" else
        "10001" when addr = "000010010" else
        "10001" when addr = "000010011" else
        "11110" when addr = "000010100" else
        "10001" when addr = "000010101" else
        "10001" when addr = "000010110" else
        "11110" when addr = "000010111" else

        -- C
        "00000" when addr = "000011000" else
        "01110" when addr = "000011001" else
        "10001" when addr = "000011010" else
        "10000" when addr = "000011011" else
        "10000" when addr = "000011100" else
        "10000" when addr = "000011101" else
        "10001" when addr = "000011110" else
        "01110" when addr = "000011111" else

        -- D
        "00000" when addr = "000100000" else
        "11110" when addr = "000100001" else
        "10001" when addr = "000100010" else
        "10001" when addr = "000100011" else
        "10001" when addr = "000100100" else
        "10001" when addr = "000100101" else
        "10001" when addr = "000100110" else
        "11110" when addr = "000100111" else

        -- E
        "00000" when addr = "000101000" else
        "11111" when addr = "000101001" else
        "10000" when addr = "000101010" else
        "10000" when addr = "000101011" else
        "11110" when addr = "000101100" else
        "10000" when addr = "000101101" else
        "10000" when addr = "000101110" else
        "11111" when addr = "000101111" else

        -- F
        "00000" when addr = "000110000" else
        "11111" when addr = "000110001" else
        "10000" when addr = "000110010" else
        "10000" when addr = "000110011" else
        "11110" when addr = "000110100" else
        "10000" when addr = "000110101" else
        "10000" when addr = "000110110" else
        "10000" when addr = "000110111" else

        -- G
        "00000" when addr = "000111000" else
        "01111" when addr = "000111001" else
        "10000" when addr = "000111010" else
        "10000" when addr = "000111011" else
        "10000" when addr = "000111100" else
        "10011" when addr = "000111101" else
        "10001" when addr = "000111110" else
        "01111" when addr = "000111111" else

        -- H
        "00000" when addr = "001000000" else
        "10001" when addr = "001000001" else
        "10001" when addr = "001000010" else
        "10001" when addr = "001000011" else
        "11111" when addr = "001000100" else
        "10001" when addr = "001000101" else
        "10001" when addr = "001000110" else
        "10001" when addr = "001000111" else

        -- I
        "00000" when addr = "001001000" else
        "01110" when addr = "001001001" else
        "00100" when addr = "001001010" else
        "00100" when addr = "001001011" else
        "00100" when addr = "001001100" else
        "00100" when addr = "001001101" else
        "00100" when addr = "001001110" else
        "01110" when addr = "001001111" else

        -- J
        "00000" when addr = "001010000" else
        "00001" when addr = "001010001" else
        "00001" when addr = "001010010" else
        "00001" when addr = "001010011" else
        "00001" when addr = "001010100" else
        "00001" when addr = "001010101" else
        "10001" when addr = "001010110" else
        "01110" when addr = "001010111" else

        -- K
        "00000" when addr = "001011000" else
        "10001" when addr = "001011001" else
        "10010" when addr = "001011010" else
        "10100" when addr = "001011011" else
        "11000" when addr = "001011100" else
        "10100" when addr = "001011101" else
        "10010" when addr = "001011110" else
        "10001" when addr = "001011111" else

        -- L
        "00000" when addr = "001100000" else
        "10000" when addr = "001100001" else
        "10000" when addr = "001100010" else
        "10000" when addr = "001100011" else
        "10000" when addr = "001100100" else
        "10000" when addr = "001100101" else
        "10000" when addr = "001100110" else
        "11111" when addr = "001100111" else

        -- M
        "00000" when addr = "001101000" else
        "10001" when addr = "001101001" else
        "11011" when addr = "001101010" else
        "10101" when addr = "001101011" else
        "10101" when addr = "001101100" else
        "10001" when addr = "001101101" else
        "10001" when addr = "001101110" else
        "10001" when addr = "001101111" else

        -- N
        "00000" when addr = "001110000" else
        "10001" when addr = "001110001" else
        "10001" when addr = "001110010" else
        "11001" when addr = "001110011" else
        "10101" when addr = "001110100" else
        "10011" when addr = "001110101" else
        "10001" when addr = "001110110" else
        "10001" when addr = "001110111" else

        -- O
        "00000" when addr = "001111000" else
        "01110" when addr = "001111001" else
        "10001" when addr = "001111010" else
        "10001" when addr = "001111011" else
        "10001" when addr = "001111100" else
        "10001" when addr = "001111101" else
        "10001" when addr = "001111110" else
        "01110" when addr = "001111111" else

        -- P
        "00000" when addr = "010000000" else
        "11110" when addr = "010000001" else
        "10001" when addr = "010000010" else
        "10001" when addr = "010000011" else
        "11110" when addr = "010000100" else
        "10000" when addr = "010000101" else
        "10000" when addr = "010000110" else
        "10000" when addr = "010000111" else

        -- Q
        "00000" when addr = "010001000" else
        "01110" when addr = "010001001" else
        "10001" when addr = "010001010" else
        "10001" when addr = "010001011" else
        "10001" when addr = "010001100" else
        "10101" when addr = "010001101" else
        "10010" when addr = "010001110" else
        "01101" when addr = "010001111" else

        -- R
        "00000" when addr = "010010000" else
        "11110" when addr = "010010001" else
        "10001" when addr = "010010010" else
        "10001" when addr = "010010011" else
        "11110" when addr = "010010100" else
        "10100" when addr = "010010101" else
        "10010" when addr = "010010110" else
        "10001" when addr = "010010111" else

        -- S
        "00000" when addr = "010011000" else
        "01110" when addr = "010011001" else
        "10001" when addr = "010011010" else
        "10000" when addr = "010011011" else
        "01110" when addr = "010011100" else
        "00001" when addr = "010011101" else
        "10001" when addr = "010011110" else
        "01110" when addr = "010011111" else

        -- T
        "00000" when addr = "010100000" else
        "11111" when addr = "010100001" else
        "00100" when addr = "010100010" else
        "00100" when addr = "010100011" else
        "00100" when addr = "010100100" else
        "00100" when addr = "010100101" else
        "00100" when addr = "010100110" else
        "00100" when addr = "010100111" else

        -- U
        "00000" when addr = "010101000" else
        "10001" when addr = "010101001" else
        "10001" when addr = "010101010" else
        "10001" when addr = "010101011" else
        "10001" when addr = "010101100" else
        "10001" when addr = "010101101" else
        "10001" when addr = "010101110" else
        "01110" when addr = "010101111" else

        -- V
        "00000" when addr = "010110000" else
        "10001" when addr = "010110001" else
        "10001" when addr = "010110010" else
        "10001" when addr = "010110011" else
        "10001" when addr = "010110100" else
        "10001" when addr = "010110101" else
        "01010" when addr = "010110110" else
        "00100" when addr = "010110111" else

        -- W
        "00000" when addr = "010111000" else
        "10001" when addr = "010111001" else
        "10001" when addr = "010111010" else
        "10001" when addr = "010111011" else
        "10101" when addr = "010111100" else
        "10101" when addr = "010111101" else
        "11011" when addr = "010111110" else
        "10001" when addr = "010111111" else

        -- X
        "00000" when addr = "011000000" else
        "10001" when addr = "011000001" else
        "10001" when addr = "011000010" else
        "01010" when addr = "011000011" else
        "00100" when addr = "011000100" else
        "01010" when addr = "011000101" else
        "10001" when addr = "011000110" else
        "10001" when addr = "011000111" else

        -- Y
        "00000" when addr = "011001000" else
        "10001" when addr = "011001001" else
        "10001" when addr = "011001010" else
        "01010" when addr = "011001011" else
        "00100" when addr = "011001100" else
        "00100" when addr = "011001101" else
        "00100" when addr = "011001110" else
        "00100" when addr = "011001111" else

        -- Z
        "00000" when addr = "011010000" else
        "11111" when addr = "011010001" else
        "00001" when addr = "011010010" else
        "00010" when addr = "011010011" else
        "00100" when addr = "011010100" else
        "01000" when addr = "011010101" else
        "10000" when addr = "011010110" else
        "11111" when addr = "011010111" else

        -- [
        "00000" when addr = "011011000" else
        "11111" when addr = "011011001" else
        "11000" when addr = "011011010" else
        "11000" when addr = "011011011" else
        "11000" when addr = "011011100" else
        "11000" when addr = "011011101" else
        "11000" when addr = "011011110" else
        "11111" when addr = "011011111" else

        -- \
        "00000" when addr = "011100000" else
        "00000" when addr = "011100001" else
        "10000" when addr = "011100010" else
        "01000" when addr = "011100011" else
        "00100" when addr = "011100100" else
        "00010" when addr = "011100101" else
        "00001" when addr = "011100110" else
        "00000" when addr = "011100111" else

        -- ]
        "00000" when addr = "011101000" else
        "11111" when addr = "011101001" else
        "00011" when addr = "011101010" else
        "00011" when addr = "011101011" else
        "00011" when addr = "011101100" else
        "00011" when addr = "011101101" else
        "00011" when addr = "011101110" else
        "11111" when addr = "011101111" else

        -- ^
        "00000" when addr = "011110000" else
        "00000" when addr = "011110001" else
        "00000" when addr = "011110010" else
        "00100" when addr = "011110011" else
        "01010" when addr = "011110100" else
        "10001" when addr = "011110101" else
        "00000" when addr = "011110110" else
        "00000" when addr = "011110111" else

        -- _
        "00000" when addr = "011111000" else
        "00000" when addr = "011111001" else
        "00000" when addr = "011111010" else
        "00000" when addr = "011111011" else
        "00000" when addr = "011111100" else
        "00000" when addr = "011111101" else
        "00000" when addr = "011111110" else
        "11111" when addr = "011111111" else

        --
        "00000" when addr = "100000000" else
        "00000" when addr = "100000001" else
        "00000" when addr = "100000010" else
        "00000" when addr = "100000011" else
        "00000" when addr = "100000100" else
        "00000" when addr = "100000101" else
        "00000" when addr = "100000110" else
        "00000" when addr = "100000111" else

        -- !
        "00000" when addr = "100001000" else
        "00100" when addr = "100001001" else
        "00100" when addr = "100001010" else
        "00100" when addr = "100001011" else
        "00100" when addr = "100001100" else
        "00100" when addr = "100001101" else
        "00000" when addr = "100001110" else
        "00100" when addr = "100001111" else

        -- "
        "00000" when addr = "100010000" else
        "01010" when addr = "100010001" else
        "01010" when addr = "100010010" else
        "01010" when addr = "100010011" else
        "00000" when addr = "100010100" else
        "00000" when addr = "100010101" else
        "00000" when addr = "100010110" else
        "00000" when addr = "100010111" else

        -- #
        "00000" when addr = "100011000" else
        "01010" when addr = "100011001" else
        "01010" when addr = "100011010" else
        "11111" when addr = "100011011" else
        "01010" when addr = "100011100" else
        "11111" when addr = "100011101" else
        "01010" when addr = "100011110" else
        "01010" when addr = "100011111" else

        -- $
        "00000" when addr = "100100000" else
        "00100" when addr = "100100001" else
        "01111" when addr = "100100010" else
        "10100" when addr = "100100011" else
        "01110" when addr = "100100100" else
        "00101" when addr = "100100101" else
        "11110" when addr = "100100110" else
        "00100" when addr = "100100111" else

        -- %
        "00000" when addr = "100101000" else
        "11000" when addr = "100101001" else
        "11001" when addr = "100101010" else
        "00010" when addr = "100101011" else
        "00100" when addr = "100101100" else
        "01000" when addr = "100101101" else
        "10011" when addr = "100101110" else
        "00011" when addr = "100101111" else

        -- &
        "00000" when addr = "100110000" else
        "01000" when addr = "100110001" else
        "10100" when addr = "100110010" else
        "10100" when addr = "100110011" else
        "01000" when addr = "100110100" else
        "10101" when addr = "100110101" else
        "10010" when addr = "100110110" else
        "01101" when addr = "100110111" else

        -- '
        "00000" when addr = "100111000" else
        "00100" when addr = "100111001" else
        "00100" when addr = "100111010" else
        "00100" when addr = "100111011" else
        "00000" when addr = "100111100" else
        "00000" when addr = "100111101" else
        "00000" when addr = "100111110" else
        "00000" when addr = "100111111" else

        -- (
        "00000" when addr = "101000000" else
        "00100" when addr = "101000001" else
        "01000" when addr = "101000010" else
        "10000" when addr = "101000011" else
        "10000" when addr = "101000100" else
        "10000" when addr = "101000101" else
        "01000" when addr = "101000110" else
        "00100" when addr = "101000111" else

        -- )
        "00000" when addr = "101001000" else
        "00100" when addr = "101001001" else
        "00010" when addr = "101001010" else
        "00001" when addr = "101001011" else
        "00001" when addr = "101001100" else
        "00001" when addr = "101001101" else
        "00010" when addr = "101001110" else
        "00100" when addr = "101001111" else

        -- *
        "00000" when addr = "101010000" else
        "00100" when addr = "101010001" else
        "10101" when addr = "101010010" else
        "01110" when addr = "101010011" else
        "00100" when addr = "101010100" else
        "01110" when addr = "101010101" else
        "10101" when addr = "101010110" else
        "00100" when addr = "101010111" else

        -- +
        "00000" when addr = "101011000" else
        "00000" when addr = "101011001" else
        "00100" when addr = "101011010" else
        "00100" when addr = "101011011" else
        "11111" when addr = "101011100" else
        "00100" when addr = "101011101" else
        "00100" when addr = "101011110" else
        "00000" when addr = "101011111" else

        -- ,
        "00000" when addr = "101100000" else
        "00000" when addr = "101100001" else
        "00000" when addr = "101100010" else
        "00000" when addr = "101100011" else
        "00000" when addr = "101100100" else
        "00100" when addr = "101100101" else
        "00100" when addr = "101100110" else
        "01000" when addr = "101100111" else

        -- -
        "00000" when addr = "101101000" else
        "00000" when addr = "101101001" else
        "00000" when addr = "101101010" else
        "00000" when addr = "101101011" else
        "11111" when addr = "101101100" else
        "00000" when addr = "101101101" else
        "00000" when addr = "101101110" else
        "00000" when addr = "101101111" else

        -- .
        "00000" when addr = "101110000" else
        "00000" when addr = "101110001" else
        "00000" when addr = "101110010" else
        "00000" when addr = "101110011" else
        "00000" when addr = "101110100" else
        "00000" when addr = "101110101" else
        "00000" when addr = "101110110" else
        "00100" when addr = "101110111" else

        -- /
        "00000" when addr = "101111000" else
        "00000" when addr = "101111001" else
        "00001" when addr = "101111010" else
        "00010" when addr = "101111011" else
        "00100" when addr = "101111100" else
        "01000" when addr = "101111101" else
        "10000" when addr = "101111110" else
        "00000" when addr = "101111111" else

        -- 0
        "00000" when addr = "110000000" else
        "01110" when addr = "110000001" else
        "10001" when addr = "110000010" else
        "10011" when addr = "110000011" else
        "10101" when addr = "110000100" else
        "11001" when addr = "110000101" else
        "10001" when addr = "110000110" else
        "01110" when addr = "110000111" else

        -- 1
        "00000" when addr = "110001000" else
        "00100" when addr = "110001001" else
        "01100" when addr = "110001010" else
        "00100" when addr = "110001011" else
        "00100" when addr = "110001100" else
        "00100" when addr = "110001101" else
        "00100" when addr = "110001110" else
        "01110" when addr = "110001111" else

        -- 2
        "00000" when addr = "110010000" else
        "01110" when addr = "110010001" else
        "10001" when addr = "110010010" else
        "00001" when addr = "110010011" else
        "00110" when addr = "110010100" else
        "01000" when addr = "110010101" else
        "10000" when addr = "110010110" else
        "11110" when addr = "110010111" else

        -- 3
        "00000" when addr = "110011000" else
        "11111" when addr = "110011001" else
        "00001" when addr = "110011010" else
        "00010" when addr = "110011011" else
        "00110" when addr = "110011100" else
        "00001" when addr = "110011101" else
        "10001" when addr = "110011110" else
        "01110" when addr = "110011111" else

        -- 4
        "00000" when addr = "110100000" else
        "00010" when addr = "110100001" else
        "00110" when addr = "110100010" else
        "01010" when addr = "110100011" else
        "10010" when addr = "110100100" else
        "11111" when addr = "110100101" else
        "00010" when addr = "110100110" else
        "00010" when addr = "110100111" else

        -- 5
        "00000" when addr = "110101000" else
        "11111" when addr = "110101001" else
        "10000" when addr = "110101010" else
        "11110" when addr = "110101011" else
        "00001" when addr = "110101100" else
        "00001" when addr = "110101101" else
        "10001" when addr = "110101110" else
        "01110" when addr = "110101111" else

        -- 6
        "00000" when addr = "110110000" else
        "00111" when addr = "110110001" else
        "01000" when addr = "110110010" else
        "10000" when addr = "110110011" else
        "11110" when addr = "110110100" else
        "10001" when addr = "110110101" else
        "10001" when addr = "110110110" else
        "01110" when addr = "110110111" else

        -- 7
        "00000" when addr = "110111000" else
        "11111" when addr = "110111001" else
        "00001" when addr = "110111010" else
        "00010" when addr = "110111011" else
        "00100" when addr = "110111100" else
        "01000" when addr = "110111101" else
        "01000" when addr = "110111110" else
        "01000" when addr = "110111111" else

        -- 8
        "00000" when addr = "111000000" else
        "01110" when addr = "111000001" else
        "10001" when addr = "111000010" else
        "10001" when addr = "111000011" else
        "01110" when addr = "111000100" else
        "10001" when addr = "111000101" else
        "10001" when addr = "111000110" else
        "01110" when addr = "111000111" else

        -- 9
        "00000" when addr = "111001000" else
        "01110" when addr = "111001001" else
        "10001" when addr = "111001010" else
        "10001" when addr = "111001011" else
        "01111" when addr = "111001100" else
        "00001" when addr = "111001101" else
        "00010" when addr = "111001110" else
        "11100" when addr = "111001111" else

        -- :
        "00000" when addr = "111010000" else
        "00000" when addr = "111010001" else
        "00000" when addr = "111010010" else
        "00100" when addr = "111010011" else
        "00000" when addr = "111010100" else
        "00100" when addr = "111010101" else
        "00000" when addr = "111010110" else
        "00000" when addr = "111010111" else

        -- ;
        "00000" when addr = "111011000" else
        "00000" when addr = "111011001" else
        "00000" when addr = "111011010" else
        "00100" when addr = "111011011" else
        "00000" when addr = "111011100" else
        "00100" when addr = "111011101" else
        "00100" when addr = "111011110" else
        "01000" when addr = "111011111" else

        -- <
        "00000" when addr = "111100000" else
        "00010" when addr = "111100001" else
        "00100" when addr = "111100010" else
        "01000" when addr = "111100011" else
        "10000" when addr = "111100100" else
        "01000" when addr = "111100101" else
        "00100" when addr = "111100110" else
        "00010" when addr = "111100111" else

        -- =
        "00000" when addr = "111101000" else
        "00000" when addr = "111101001" else
        "00000" when addr = "111101010" else
        "11111" when addr = "111101011" else
        "00000" when addr = "111101100" else
        "11111" when addr = "111101101" else
        "00000" when addr = "111101110" else
        "00000" when addr = "111101111" else

        -- >
        "00000" when addr = "111110000" else
        "01000" when addr = "111110001" else
        "00100" when addr = "111110010" else
        "00010" when addr = "111110011" else
        "00001" when addr = "111110100" else
        "00010" when addr = "111110101" else
        "00100" when addr = "111110110" else
        "01000" when addr = "111110111" else

        -- ?
        "00000" when addr = "111111000" else
        "01110" when addr = "111111001" else
        "10001" when addr = "111111010" else
        "00010" when addr = "111111011" else
        "00100" when addr = "111111100" else
        "00100" when addr = "111111101" else
        "00000" when addr = "111111110" else
        "00100" when addr = "111111111";
  
end architecture;
