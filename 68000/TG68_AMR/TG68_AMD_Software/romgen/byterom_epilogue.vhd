	others => x"00"
);

begin

process (clock)
begin
	if (clock'event and clock = '1') then
		q(7 downto 0) <= rom(to_integer(unsigned(address(addrbits-1 downto 0))));
	end if;
end process;

end arch;

