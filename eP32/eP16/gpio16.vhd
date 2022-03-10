-- **********************************************************
-- *		General Purpose Input Output Module				*
-- *========================================================*
-- * Project:			FG in PROASIC						*
-- * File:				gpio.vhd							*
-- * Author:			Chien-Chia Wu						*
-- * Description:		General Purpose Input Output block	*
-- *														*
-- * Hierarchy:parent:										*
-- *		child :											* 
-- *														*
-- * Revision History:										*
-- * 03/02/03	Chien-Chia Wu   Created.					* 
-- * 02/29/12	 Chen-Hanson Ting Back to eP16			   	  *
-- **********************************************************
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;

entity gpio is
  port(
	-- input port
	clr: 		in		std_logic;
	clk: 		in		std_logic;
	write: 		in		std_logic;
	read: 		in		std_logic;
	ce: 		in		std_logic;
	addr: 		in		std_logic_vector(1 downto 0);
	data_in: 	in		std_logic_vector(15 downto 0);
	gpio_in: 	in		std_logic_vector(15 downto 0); 
	-- output port
	data_out: 	out		std_logic_vector(15 downto 0);
	gpio_out: 	out		std_logic_vector(15 downto 0);
	gpio_dir: 	out		std_logic_vector(15 downto 0)
  );
end gpio;

architecture behavioral of gpio is
	signal gpio_reg:	std_logic_vector(15 downto 0);
	signal gpio_dir_reg:std_logic_vector(15 downto 0);
begin
	gpio_out <= gpio_reg;
	gpio_dir <= gpio_dir_reg;
	
-- **********************************************************	
--		GPIO Register Circuit for Read
-- **********************************************************	
	gpio_register_file_read:
	process(read, ce, addr, gpio_reg, gpio_dir_reg,gpio_in)  
	begin
		if (read='1' and ce='1') then 
		case addr is
			when "00" 	=>
				data_out<=gpio_reg;
			when "01"	=>
				data_out<=gpio_dir_reg;
			when others	=>
				data_out<=gpio_in;
		end case;
		else
			data_out <= (others=>'1');  
		end if;
	end process gpio_register_file_read;  

-- **********************************************************	
--		GPIO Register Circuit for Write 
-- **********************************************************	
	gpio_register_file_write:
	process(clr, clk)
	begin
	if (clr='1') then
		gpio_reg <= (others=>'0');
		gpio_dir_reg <= (others=>'0');
	elsif ( clk'event and clk='1') then
		if (write='1' and ce='1') then 
			case addr is
			when "01" => gpio_dir_reg <= data_in(15 downto 0);
			when others => gpio_reg <= data_in(15 downto 0);
			end case;
		end if;  
	end if;  
	end process gpio_register_file_write;
end behavioral;  

