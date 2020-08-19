library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;


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

type datacache is array(0 to 31) of std_logic_vector(15 downto 0);
signal cachedata : datacache;


--signal cachedata : std_logic_vector(63 downto 0);
-- signal delay : std_logic_vector(3 downto 0);
signal rdline : std_logic_vector(4 downto 0) := "00000";	-- cacheline
signal wrline : std_logic_vector(4 downto 0) := "00000";	-- cacheline
--signal wrlsb : std_logic_vector(1 downto 0);
signal hit : std_logic;
--signal rdlsb : std_logic_vector(1 downto 0);
signal rw_out : std_logic;
--signal fill_delay : std_logic;

type cachestate is (idle,readwait,readfill,writewait,nop,ack);
signal cstate : cachestate := idle;

begin
	process(clk)
	begin
		hit<='1';
		-- We match omitting the lower 3 bits of the address,
--		rdlsb(1 downto 0)<=addrin(2 downto 1);
		if cacheaddr(0)(23 downto 3) = addrin(23 downto 3) then
			rdline<="000"&addrin(2 downto 1);
		elsif cacheaddr(1)(23 downto 3) = addrin(23 downto 3) then
			rdline<="001"&addrin(2 downto 1);
		elsif cacheaddr(2)(23 downto 3) = addrin(23 downto 3) then
			rdline<="010"&addrin(2 downto 1);
		elsif cacheaddr(3)(23 downto 3) = addrin(23 downto 3) then
			rdline<="011"&addrin(2 downto 1);
		elsif cacheaddr(4)(23 downto 3) = addrin(23 downto 3) then
			rdline<="100"&addrin(2 downto 1);
		elsif cacheaddr(5)(23 downto 3) = addrin(23 downto 3) then
			rdline<="101"&addrin(2 downto 1);
		elsif cacheaddr(6)(23 downto 3) = addrin(23 downto 3) then
			rdline<="110"&addrin(2 downto 1);
		elsif cacheaddr(7)(23 downto 3) = addrin(23 downto 3) then
			rdline<="111"&addrin(2 downto 1);
		else
			hit<='0';
		end if;

		data_out<=cachedata(to_integer(unsigned(rdline)));
	
		if reset='0' then
			cacheaddr(0)<=X"fffff"&'1';
			cacheaddr(1)<=X"fffff"&'1';
			cacheaddr(2)<=X"fffff"&'1';
			cacheaddr(3)<=X"fffff"&'1';
			req_out<='0';
			rw_out<='0';
--			wrlsb<="00";
			rdline<="00000";
			wrline<="00000";
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
						if rw_in='0' then -- write cycle
							if hit='1' then
								cacheaddr(to_integer(unsigned(rdline(4 downto 2))))<=X"000000";	-- Mark cacheline as invalid.
							end if;
							addrout<=addrin;
							rw_out<=rw_in;
							req_out<='1';
							cstate<=writewait;
						elsif hit='1' then -- read cycle, in cache
							cstate<=ack;
						else	-- not in cache, so read it in.
							addrout<=addrin;
							cacheaddr(to_integer(unsigned(wrline(4 downto 2))))(23 downto 3)<=addrin(23 downto 3);
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
						cachedata(to_integer(unsigned(wrline)))<=data_in;
						if wrline(1 downto 0)="11" then
							req_out<='0';
							-- increment cacheline pointer; since lsbs are 1, this overflows and
							-- both increments the cacheline and resets the lsbs to 0.
							wrline<=std_logic_vector(unsigned(wrline)+1);
							cstate<=ack;
						else
							wrline(1 downto 0)<=(wrline(1) xor wrline(0)) & (not wrline(0));  -- +1
						end if;
					end if;
				when others =>
					null;
			end case;
		end if;
	end process;
end architecture;
