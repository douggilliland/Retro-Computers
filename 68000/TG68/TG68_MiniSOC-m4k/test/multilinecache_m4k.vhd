library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

-- TODO:	prefetching variant
-- 		Multiple ports
--       Release DTACK quicker
--       Respond to address change quicker (or drop DTACK for 1 cycle.)

entity multilinecache is
	port(
		clk : in std_logic;
		reset : in std_logic;
		-- Interface to system
		addrin : in std_logic_vector(23 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		dtack	: out std_logic;	-- Goes low to indicate valid data on data_out
		req_in : in std_logic; -- Read request from system
		rw_in : in std_logic;
		-- Interface to SDRAM
		addrout : out std_logic_vector(23 downto 0);
		data_in : in std_logic_vector(15 downto 0);	
		req_out : buffer std_logic; -- Request service from SDRAM controller
		fill : in std_logic; -- High when data is being written from SDRAM controller
		wrack : in std_logic
	);
end entity;

architecture rtl of multilinecache is

type addresscache is array(0 to 7) of std_logic_vector(23 downto 3); -- round to nearest cacheline, hence downto 3
signal cacheaddr : addresscache;

--signal cachedata : std_logic_vector(63 downto 0);
-- signal delay : std_logic_vector(3 downto 0);
signal rdline : std_logic_vector(5 downto 0) := "000000";	-- cacheline
signal wrline : std_logic_vector(2 downto 0) := "000";	-- cacheline
signal wrlsb : std_logic_vector(1 downto 0);
signal hit : std_logic;
signal rdlsb : std_logic_vector(1 downto 0);
signal rw_out : std_logic;

type cachestate is (idle,readwait,readfill,writewait,nop,ack);
signal cstate : cachestate := idle;

begin

myM4K : entity work.DualPortM4k
	port map
	(
		clock => clk,
		rdaddress => rdline & addrin(2 downto 1),
		wraddress => "000" & wrline & wrlsb(1 downto 0),
		data => "00" & data_in,
		wren => fill,
		q(15 downto 0) => data_out
	);

	process(clk)
	begin
		hit<='1';
		-- FIXME - need to drop DTACK when address changes - RAM fetch will take about 2 cycles.
		-- We match omitting the lower 3 bits of the address, 
		if cacheaddr(0)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000000";
		elsif cacheaddr(1)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000001";
		elsif cacheaddr(2)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000010";
		elsif cacheaddr(3)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000011";
		elsif cacheaddr(4)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000100";
		elsif cacheaddr(5)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000101";
		elsif cacheaddr(6)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000110";
		elsif cacheaddr(7)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000111";
		else
			hit<='0';
		end if;

--		if(addrin(2 downto 1)/=rdlsb(1 downto 0)) then -- drop DTACK as soon as the address changes
--			dtack<='1';
--		end if;
	
		if reset='0' then
			cacheaddr(0)<=X"fffff"&'1';
			cacheaddr(1)<=X"fffff"&'1';
			cacheaddr(2)<=X"fffff"&'1';
			cacheaddr(3)<=X"fffff"&'1';
			req_out<='0';
			rw_out<='0';
			wrlsb<="11";
			rdline<="000000";
			wrline<="000";
			cstate<=idle;
			dtack<='1';
		elsif rising_edge(clk) then
			-- Handle propogation of the DTACK signal
--			if delay(2)/='1' then	-- Assert dtack 3 cycles late.
--				delay<=delay(2 downto 0) & '0';
--			end if;

			case cstate is
				when ack =>
					dtack<='0';
					cstate<=nop;
				when nop =>
					dtack<='1';
					cstate<=idle;
				when idle =>
					if req_in='1' then
						rdlsb(1 downto 0)<=addrin(2 downto 1);
						if rw_in='0' then -- write cycle
							cacheaddr(to_integer(unsigned(rdline)))<=X"000000";	-- Mark cacheline as invalid.
							addrout<=addrin;
							rw_out<=rw_in;
							req_out<='1';
							cstate<=writewait;
						elsif hit='1' then -- read cycle, in cache
							if addrin(2 downto 1)=rdlsb(1 downto 0) and rdline/=wrline then
								-- in cache on the currently selected word.
								dtack<='0';
								cstate<=nop;
							else
							-- in cache, but on a different word, so 1 cycle delay
								cstate<=ack;
							end if;
						else	-- not in cache, so read it in.
							addrout<=addrin;
							cacheaddr(to_integer(unsigned(wrline)))(23 downto 3)<=addrin(23 downto 3);
							req_out<='1';
							cstate<=readwait;
						end if;
					end if;
				when writewait =>
					if wrack='1' then
						dtack<='0';
						req_out<='0';
						rw_out<='1';
						cstate<=nop;
					end if;
				when readwait =>
					if fill='1' then	-- Are we currently receiving data from SDRAM?	
						wrlsb(1 downto 0)<=(wrlsb(1) xor wrlsb(0)) & (not wrlsb(0));  -- +1
						if wrlsb(1 downto 0)="10" then -- 1 cycle early.
							req_out<='0';
							dtack<='0'; -- delay by two cycles.
						end if;
						if wrlsb(1 downto 0)="11" then
							wrline<=std_logic_vector(unsigned(wrline)+1); -- increment cacheline pointer
							cstate<=nop;
						end if;
					end if;
				when others =>
					null;
			end case;
		end if;
	end process;
end architecture;
