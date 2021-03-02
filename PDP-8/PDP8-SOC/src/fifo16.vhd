
--========================================================================
-- fifo.vhd ::  FIFO   (16-deep)
--
-- (c) Scott L. Baker, Sierra Circuit Design
--========================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity FIFO is
    port(
        FIFO_OUT    : out std_logic_vector(7 downto 0);
        FIFO_IN     : in  std_logic_vector(7 downto 0);
        OVFL        : out std_logic;     -- overflow
        LAST        : out std_logic;     -- nearly full
        EMPTY       : out std_logic;     -- empty
        FPUSH       : in  std_logic;     -- fifo push
        FPOP        : in  std_logic;     -- fifo pop
        CKEN        : in  std_logic;     -- clock enable
        CLK         : in  std_logic;     -- clock
        RESET       : in  std_logic      -- Reset
    );
end FIFO;


architecture BEHAVIORAL of FIFO is

    signal RD_ADDR  : std_logic_vector(3 downto 0);
    signal WR_ADDR  : std_logic_vector(3 downto 0);
    signal DEPTH    : std_logic_vector(3 downto 0);

    type Memtype is array (integer range 0 to 15) of std_logic_vector(7 downto 0);
    signal  MEM     : Memtype;

begin


    --================================================================
    -- FIFO pointers
    --================================================================
    FIFO_POINTERS:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then

            -- increment write pointer on push
            -- and increment the depth.. if not full (no overflow)
            if ((FPUSH = '1') and (CKEN = '1') and (DEPTH /= "1111")) then
                WR_ADDR <= WR_ADDR + 1;
                -- check for simultaneous push/pop
                if (not((FPOP = '1') and (DEPTH /= "0000"))) then
                    DEPTH <= DEPTH + 1;
                end if;
            end if;

            -- increment read pointer on pop
            -- and decrement the depth.. if not empty (no underflow)
            if ((FPOP = '1') and (CKEN = '1') and (DEPTH /= "0000")) then
                RD_ADDR <= RD_ADDR + 1;
                -- check for simultaneous push/pop
                if (not((FPUSH = '1') and (DEPTH /= "1111"))) then
                    DEPTH <= DEPTH - 1;
                end if;
            end if;

            -- reset state
            if (RESET = '1') then
                WR_ADDR <= (others => '0');
                RD_ADDR <= (others => '0');
                DEPTH   <= (others => '0');
            end if;

        end if;
    end process;


    --================================================================
    -- FIFO flags
    --================================================================
    FIFO_FLAGS:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then

            OVFL  <= '0';
            LAST  <= '0';
            EMPTY <= '0';

            if (DEPTH = "1111") then
                OVFL <= '1';
            end if;

            if ((DEPTH = "1110") or (DEPTH = "1111")) then
                LAST <= '1';
            end if;

            if (DEPTH = "0000") then
                EMPTY <= '1';
            end if;
        end if;

    end process;


    --================================================================
    -- Fifo RAM
    --================================================================
    FIFO_RAM:
    process(CLK)
    begin
        if (CLK = '0' and CLK'event) then
            if ((CKEN = '1') and (FPUSH = '1')) then
                MEM(conv_integer(WR_ADDR)) <= FIFO_IN;
            end if;
            if (RESET = '1') then
                MEM(0)  <= (others => '0');
                MEM(2)  <= (others => '0');
                MEM(3)  <= (others => '0');
                MEM(4)  <= (others => '0');
                MEM(5)  <= (others => '0');
                MEM(6)  <= (others => '0');
                MEM(7)  <= (others => '0');
                MEM(8)  <= (others => '0');
                MEM(9)  <= (others => '0');
                MEM(10) <= (others => '0');
                MEM(11) <= (others => '0');
                MEM(12) <= (others => '0');
                MEM(13) <= (others => '0');
                MEM(14) <= (others => '0');
                MEM(15) <= (others => '0');
            end if;
        end if;
    end process;

    FIFO_OUT <= MEM(conv_integer(RD_ADDR));

end BEHAVIORAL;
