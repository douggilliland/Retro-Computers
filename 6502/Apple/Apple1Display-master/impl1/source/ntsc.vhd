library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- NTSC composite DAC output voltages
-- 0000 -> 0.00V
-- 0001 -> 0.07V
-- 0010 -> 0.15V
-- 0011 -> 0.22V
-- 0100 -> 0.30V
-- 0101 -> 0.38V
-- 0110 -> 0.45V
-- 0111 -> 0.52V
-- 1000 -> 0.60V
-- 1001 -> 0.68V
-- 1010 -> 0.75V
-- 1011 -> 0.83V
-- 1100 -> 0.91V
-- 1101 -> 0.98V
-- 1110 -> 1.05V
-- 1111 -> 1.13V


entity ntsc is

  port(
		clk: in  std_logic;
		ntsc: out std_logic_vector(3 downto 0)
		);

end ntsc; 
  
architecture behavior OF ntsc IS

constant HORZ_RES: natural := 1587; -- 1587
constant VERT_RES: natural := 525; -- 525
signal hsync : std_logic := '0';
signal vsync : std_logic := '0';
signal image : std_logic  := '0';
signal sync : std_logic;
begin

	process(clk)
		variable hcount : integer range 0 to HORZ_RES-1 := 0;
		variable vcount : integer range 0 to VERT_RES-1 := 0;		
		variable dot_clock : std_logic := '0';
	begin
		if rising_edge(clk) then
			if dot_clock = '0' then
				if (hcount < HORZ_RES-1) then
					hcount := hcount + 1;
				else
					-- new line
					hcount := 0;
					if (vcount < VERT_RES-1) then
						vcount := vcount + 1;
					else
						vcount := 0;
					end if;
				end if;
		 	end if;
			dot_clock := not dot_clock;
			
			if (hcount > 0) then
				hsync <= '1';
			else
				hsync <= '0';
			end if;
			
			if (vcount = 0) then
				vsync <= '1';
			else
				vsync <= '0';
			end if;
			
			if (vcount > 0) and (hcount = 2) then
				image <= '1';
			else
				image <= '0';
			end if;
			
		end if;
		
	end process;
   
	sync <= vsync or hsync;
	ntsc(0) <= sync;
	ntsc(1) <= image;
	ntsc(2) <= sync;
	ntsc(3) <= image;
   
end architecture;
