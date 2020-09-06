-- Generic RTL expression of Dual port RAM with one read and one write port, unregistered output.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DMACacheRAM is
	generic
		(
			CacheAddrBits : integer := 8;
			CacheWidth : integer :=16
		);
	port (
		clock : in std_logic;
		data : in std_logic_vector(CacheWidth-1 downto 0);
		rdaddress : in std_logic_vector(CacheAddrBits-1 downto 0);
		wraddress : in std_logic_vector(CacheAddrBits-1 downto 0);
		wren : in std_logic;
		q : out std_logic_vector(CacheWidth-1 downto 0)
	);
end DMACacheRAM;

architecture RTL of DMACacheRAM is

type ram_type is array(natural range ((2**CacheAddrBits)-1) downto 0) of std_logic_vector(CacheWidth-1 downto 0);
shared variable ram : ram_type;

begin

process (clock)
begin
	if (clock'event and clock = '1') then
		if wren='1' then
			ram(to_integer(unsigned(wraddress))) := data;
		end if;
	end if;
end process;

process (clock)
begin
	q <= ram(to_integer(unsigned(rdaddress)));
end process;

end rtl;

