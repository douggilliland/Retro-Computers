
--
-- Copyright (c) 2008-2019 Sytse van Slooten
--
-- Permission is hereby granted to any person obtaining a copy of these VHDL source files and
-- other language source files and associated documentation files ("the materials") to use
-- these materials solely for personal, non-commercial purposes.
-- You are also granted permission to make changes to the materials, on the condition that this
-- copyright notice is retained unchanged.
--
-- The materials are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--

-- $Revision: 1.7 $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dsseg is
   port(
      d1 : in std_logic_vector(3 downto 0);
      d0 : in std_logic_vector(3 downto 0);
      enable : in std_logic;
      output : out std_logic_vector(7 downto 0);
      clk : in std_logic;
      reset : in std_logic
   );
end;

architecture Behavioral of dsseg is

signal ancount : std_logic;
signal seg : std_logic_vector(6 downto 0);
signal cat : std_logic;
signal dr1 : std_logic_vector(3 downto 0);
signal dr0 : std_logic_vector(3 downto 0);

begin

   output <= cat & seg;

	process(clk, reset)
	variable dn : std_logic_vector(3 downto 0);
	variable decpoint : std_logic;
	begin
		if reset='1' then
			seg <= "0111111";
			cat<='0';
			ancount<='0';
			dn:="1111";
         dr1 <= "0000";
         dr0 <= "0000";
		else

			if clk='1' and clk'event then
				ancount<= not ancount;
            if enable = '1' then
               dr1 <= d1;
               dr0 <= d0;
            end if;

			   case ancount is
   			   when '0' =>
      			   cat<='0';
                  if enable = '1' then
                     dn:=d0;
                  else
                     dn:=dr0;
                  end if;
	      		when '1' =>
		      	   cat<='1';
                  if enable = '1' then
                     dn:=d1;
                  else
                     dn:=dr1;
                  end if;
	      		when others =>
   	   		   cat<='1';
						dn:="0000";
			   end case;

            case dn is
               when "0000" => seg <= "0111111";
               when "0001" => seg <= "0000110";
               when "0010" => seg <= "1011011";
               when "0011" => seg <= "1001111";
               when "0100" => seg <= "1100110";
               when "0101" => seg <= "1101101";
               when "0110" => seg <= "1111101";
               when "0111" => seg <= "0000111";
               when "1000" => seg <= "1111111";
               when "1001" => seg <= "1101111";
               when "1010" => seg <= "1110111";
               when "1011" => seg <= "1111100";
               when "1100" => seg <= "0111001";
               when "1101" => seg <= "1011110";
               when "1110" => seg <= "1111001";
               when "1111" => seg <= "1110001";
               when others =>	seg <= "1000000";
            end case;

			end if;
		end if;

	end process;

end Behavioral;
