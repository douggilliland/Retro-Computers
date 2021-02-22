
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

entity qsseg is
    Port ( d3 : in std_logic_vector(3 downto 0);
           d2 : in std_logic_vector(3 downto 0);
           d1 : in std_logic_vector(3 downto 0);
           d0 : in std_logic_vector(3 downto 0);
			  dp3 : in std_logic;
			  dp2 : in std_logic;
			  dp1 : in std_logic;
			  dp0 : in std_logic;
           seg : out std_logic_vector(6 downto 0);
           an : out std_logic_vector(3 downto 0);
			  dp : out std_logic;
           clk : in std_logic;
			  reset : in std_logic);
end;

architecture Behavioral of qsseg is

signal ancount : std_logic_vector(1 downto 0);

begin
	process(clk, reset)
	variable dn : std_logic_vector(3 downto 0);
	variable decpoint : std_logic;
	begin
		if reset='1' then
			seg <= "0111111";
			an<="0000";
			ancount<="00";
			dn:="1111";
		else

			if clk='1' and clk'event then
				ancount<=ancount+1;

			   case ancount is
   			   when "00" =>
      			   an<="0111";
						dn:=d3;
						decpoint:=dp3;
	      		when "01" =>
		      	   an<="1011";
						dn:=d2;
						decpoint:=dp2;
	   		   when "10" =>
      			   an<="1101";
						dn:=d1;
						decpoint:=dp1;
		      	when "11" =>
   		   	   an<="1110";
						dn:=d0;
						decpoint:=dp0;
	      		when others =>
   	   		   an<="1111";
						dn:="0000";
			   end case;

				dp<=not decpoint;
				case dn is
					when "0000" => seg <= "1000000";
					when "0001" => seg <= "1111001";
					when "0010" => seg <= "0100100";
					when "0011" => seg <= "0110000";
					when "0100" => seg <= "0011001";
					when "0101" => seg <= "0010010";
					when "0110" => seg <= "0000010";
					when "0111" => seg <= "1111000";
					when "1000" => seg <= "0000000";
					when "1001" => seg <= "0010000";
					when "1010" => seg <= "0001000";
					when "1011" => seg <= "0000011";
					when "1100" => seg <= "1000110";
					when "1101" => seg <= "0100001";
					when "1110" => seg <= "0000110";
					when "1111" => seg <= "0001110";
					when others =>	seg <= "1111111";
				end case;

			end if;
		end if;

	end process;

end Behavioral;
