	others => x"00"
);

begin

-- We use a dual-port RAM here - one port for the lower byte, one for the upper byte.  This allows us to
-- present a 16-bit interface while allowing byte writes.

process (clk)
begin
	if (clk'event and clk = '1') then
		if we_n = '0' and lds_n='0' then
			ram(to_integer(unsigned(addr(maxAddrBitBRAM downto 1)&'1'))) := d(7 downto 0);
			q(7 downto 0) <= d(7 downto 0);
		else
			q(7 downto 0) <= ram(to_integer(unsigned(addr(maxAddrBitBRAM downto 1)&'1')));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if we_n = '0' and uds_n='0' then
			ram(to_integer(unsigned(addr(maxAddrBitBRAM downto 1)&'0'))) := d(15 downto 8);
			q(15 downto 8) <= d(15 downto 8);
		else
			q(15 downto 8) <= ram(to_integer(unsigned(addr(maxAddrBitBRAM downto 1)&'0')));
		end if;
	end if;
end process;

end arch;

