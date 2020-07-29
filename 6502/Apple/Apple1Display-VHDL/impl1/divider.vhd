library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity divider is

	generic(div : natural := 2);
	port(
		input: in  std_logic;
		output: out std_logic);

end divider;
  
architecture behavior OF divider IS
signal toggle : std_logic := '0';
begin

	process(input)
	variable count : integer range 0 to (div/2)-1 := 0;	
	begin
      if rising_edge(input) then
         if count /= 0 then
            count := count - 1;
         else
		    count := (div/2)-1;
			toggle <= not toggle;
         end if;
      end if;	  
   end process;
   
   output <= toggle;
  
end architecture;
