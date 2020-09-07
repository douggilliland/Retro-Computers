-- Test rig for TG68 softcore processor.
-- Provides a very simple "ROM" containing a counter program,
-- and also implements a hardware register at the same location
-- as an Amiga's "colour 0" register.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity TG68Test is
	port (
		clk : in std_logic;

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
signal cpu_dtack : std_logic := '0'; -- data transfer acknowledge
begin


myTG68 : entity work.TG68
   port map
	(
		clk => clk,
      reset => reset,
      clkena_in => '1',
      data_in => cpu_datain,
		IPL => "111",	-- For this simple demo we'll ignore interrupts
		dtack => cpu_dtack,
		addr => cpu_addr,
		as => cpu_as,
		data_out => cpu_dataout,
		rw => cpu_r_w,
		uds => cpu_uds,
		lds => cpu_lds
);


-- Test program: 
--		0x5240 (loop: addq.w #1,d0)
--		0x33c0 (move.w d0,$dff180)
--		0x00DF 0xF180
--		0x60f6 (bra.s loop)

-- Address decoding
process(clk,cpu_addr)
begin
	if rising_edge(clk) then
		if cpu_as='0' then	-- The CPU has asserted Address Strobe, so decode the address...
			case cpu_addr(23 downto 0) is
				-- We have a simple program encoded into five words here...
				when X"000006" =>
					cpu_datain <= X"0008"; -- Initial program counter.  Initial stack pointer and high word of PC are zero.
					cpu_dtack<='0';	
				when X"000008" =>
					cpu_datain <= X"5240";  -- start: addq.w #1,d0
					cpu_dtack<='0';	
				when X"00000A" =>
					cpu_datain <= X"33c0";  -- move.w d0...
					cpu_dtack<='0';
				when X"00000C" =>
					cpu_datain <= X"00DF";  -- ...
					cpu_dtack<='0';	
				when X"00000E" =>
					cpu_datain <= X"F180";  -- ...,$dff180
					cpu_dtack<='0';	
				when X"000010" =>
					cpu_datain <= X"60f6";  -- bra.s start
					cpu_dtack<='0';

				-- Now a simple hardware register at 0xdff180, written to by the program:
				when X"dff180" =>
					if cpu_r_w='0' and cpu_uds='0' and cpu_lds='0' then	-- write cycle to the complete word...
						counter<=cpu_dataout;
						cpu_dtack<='0';
					end if;

				-- For any other address we simply return zero.
				when others =>
					cpu_datain <= X"0000";
					cpu_dtack<='0';
			end case;
		end if;

		-- When the CPU releases Data Strobe we release dtack.
		-- (No real need to do this, provided everything responds in a single cycle.  DTACK Grounded!)
		if cpu_uds='1' and cpu_lds='1' then
			cpu_dtack<='1';
		end if;
	end if;
end process;

end architecture;
