LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity OneShot is
   generic (
      shotLength  :  integer
      );
    port (
    clk: in std_logic;
    trig: in std_logic;
    output: out std_logic
    );
end OneShot;

architecture OneShot_rtl of OneShot is

   signal shiftReg   : std_logic_vector(shotLength-1 downto 0);

begin

   process (clk)
   begin
   
      if (clk'event and clk = '1') then
         
         shiftReg <= trig & shiftReg(shotLength-1 downto 1);
      
      end if;
   end process;

   output <= trig and not shiftReg(0);

end architecture;