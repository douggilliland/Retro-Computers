library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity TG68Test is
	port (
		clk : in std_logic;
		src : in std_logic_vector(9 downto 0);
		counter : out std_logic_vector(15 downto 0);
		reset : in std_logic
	);
end entity;


architecture rtl of TG68Test is
signal cpu_datain : std_logic_vector(15 downto 0);	-- Data provided by us to CPU
signal cpu_dataout : std_logic_vector(15 downto 0); -- Data received from the CPU
signal cpu_addr : std_logic_vector(31 downto 0); -- CPU's current address
signal cpu_as : std_logic; -- Address strobe
signal cpu_uds : std_logic; -- upper data strobe
signal cpu_lds : std_logic; -- lower data strobe
signal cpu_r_w : std_logic; -- read(high)/write(low)
signal busstate : std_logic_vector(1 downto 0);
signal slowdown : unsigned(11 downto 0);

begin

process(clk)
begin
	if rising_edge(clk) then
		slowdown <= slowdown+1;
	end if;
end process;


myTG68 : entity work.TG68KdotC_Kernel
   port map
	(
		clk => slowdown(11),
      nReset => not reset,
      clkena_in => '1',
      data_in => cpu_datain,
		IPL => "111",
		IPL_autovector => '0',
		CPU => "00",
		addr => cpu_addr,
		data_write => cpu_dataout,
		nWr => cpu_r_w,
		nUDS => cpu_uds,
		nLDS => cpu_lds,
		busstate => busstate,
		nResetOut => open,
		FC => open,
-- for debug		
		skipFetch => open,
		regin => open
);


-- Test program: 
--	move.l	#$11,d0	; $7011
--.loop
--	move.l	d0,d1	; $2200
--	mulu	#$1234,d1	; $C2FC,$1234
--	move.l	d1,$100	; $21C1,$0100
--	bra.s	.loop	; $60F4

-- Address decoding
process(clk,cpu_addr)
begin
	if rising_edge(clk) then
		case cpu_addr(11 downto 0) is
			-- We have a simple program encoded here...
			-- (longword at 0 is initial stack pointer (0), while
			-- longword at 4 is initial program counter, 0x00000008)
			when X"006" =>
				cpu_datain <= X"0008";
			when X"008" =>
				cpu_datain <= X"7011";  -- move.l #$11,d0
			when X"00A" =>
				cpu_datain <= X"2200";  -- move.l d0,d1
			when X"00C" =>
				cpu_datain <= X"c2fc";  -- mulu ....,d1
			when X"00E" =>
				cpu_datain <= "000000"&src;
			when X"010" =>
				cpu_datain <= X"31c1";  -- move.w d1,...
			when X"012" =>
				cpu_datain <= X"0100";  -- $100
			when X"014" =>
				cpu_datain <= X"60f4";  -- bra.s .loop
			when X"100" =>
				counter<=cpu_dataout;
				cpu_datain <= X"0000";
			when others =>
				cpu_datain <= X"0000";
		end case;
	end if;
end process;

end architecture;
