library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std_unsigned.all;

-- This module models a single-port asynchronous RAM.
-- Even though there are separate signals for data
-- input and data output, simultaneous read and write
-- will not be used in this design.
--
-- Data read is present half way through the same clock cycle.
-- This is done by using a synchronous Block RAM, and reading
-- on the *falling* edge of the clock cycle.

entity ram16 is
   generic (
      -- Number of bits in the address bus. The size of the memory will
      -- be 2**G_ADDR_BITS bytes.
      G_ADDR_BITS : integer
   );
   port (
      clk_i  : in  std_logic;

      -- Current address selected.
      addr_i : in  std_logic_vector(G_ADDR_BITS-1 downto 0);

      -- Data contents at the selected address.
      -- Valid in same clock cycle.
      data_o : out std_logic_vector(15 downto 0);

      -- New data to (optionally) be written to the selected address.
      data_i : in  std_logic_vector(15 downto 0);

      -- '1' indicates we wish to perform a write at the selected address.
      wren_i : in  std_logic
   );
end ram16;

architecture structural of ram16 is

   -- This defines a type containing an array of bytes
   type mem_t is array (0 to 2**G_ADDR_BITS-1) of std_logic_vector(15 downto 0);

   -- Data read from memory.
   signal data : std_logic_vector(15 downto 0);
   
   signal init : std_logic := '0';
   
      -- This  sets up the initial vectors for the monitor
   impure function InitRamFromArray return mem_t is
      variable RAM : mem_t := (others => (others => '0'));
   begin
   
        RAM(0) := x"0000";
        RAM(2) := x"E000";
        RAM(4) := x"00A0";
        RAM(6) := x"0BB4";
      
      return RAM;
   end function;

 -- Initialize memory contents
   signal mem : mem_t := InitRamFromArray ;
   
begin

   -- Write process
   mem_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if wren_i = '1' then
            mem(to_integer(addr_i)) <= data_i;
         end if;
      end if;
   end process mem_proc;

   -- Read process.
   -- Triggered on the *falling* clock edge in order to mimick an asynchronous
   -- memory.
   data_proc : process (clk_i)
   begin
      if rising_edge(clk_i) then
         data <= mem(to_integer(addr_i));
      end if;
   end process data_proc;

   -- Drive output signals
   data_o <= data;

end structural;
