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

signal instaddr : std_logic_vector(23 downto 3);
signal cachedata : std_logic_vector(63 downto 0);

signal hit : std_logic;
signal rdlsb : std_logic_vector(1 downto 0);
signal wrlsb : std_logic_vector(1 downto 0);
signal rw_out : std_logic;

type cachestate is (idle,readwait,writewait,nop,ack);
signal cstate : cachestate := idle;

begin
	process(clk)
	begin
		-- We match omitting the lower 3 bits of the address,
		rdlsb(1 downto 0)<=addrin(2 downto 1);
		if instaddr(23 downto 3) = addrin(23 downto 3) then
			hit<='1';
		else
			hit<='0';
		end if;

		if rdlsb="00" then
--			data_out <= cachedata(15 downto 0);
		elsif rdlsb="01" then
--			data_out <= cachedata(31 downto 16);
		elsif rdlsb="10" then
--			data_out <= cachedata(47 downto 32);
		elsif rdlsb="11" then
--			data_out <= cachedata(63 downto 48);
		end if;
		
		if reset='0' then
			instaddr(23 downto 3)<=X"fffff"&'1';
			req_out<='0';
			rw_out<='0';
			wrlsb<="00";
			cstate<=idle;
			dtack<='1';
		elsif rising_edge(clk) then
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
								instaddr(23 downto 3)<=X"FFFFF"&'1';	-- Mark cacheline as invalid.
							end if;
							addrout<=addrin;
							rw_out<=rw_in;
							req_out<='1';
							cstate<=writewait;
						elsif hit='1' then -- read cycle, in cache
							cstate<=ack;
						else	-- not in cache, so read it in.
							addrout<=addrin;
							instaddr(23 downto 3)<=addrin(23 downto 3);
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
						if wrlsb=addrin(2 downto 1) then
							data_out<=data_in;
						end if;
--						case wrlsb is
--							when "00" =>
--								cachedata(15 downto 0)<=data_in;
--							when "01" =>
--								cachedata(31 downto 16)<=data_in;
--							when "10" =>
--								cachedata(47 downto 32)<=data_in;
--							when "11" =>
--								cachedata(63 downto 48)<=data_in;
--						end case;
						if wrlsb(1 downto 0)="11" then
							req_out<='0';
							cstate<=ack;
						end if;
						wrlsb<=(wrlsb(1) xor wrlsb(0)) & (not wrlsb(0));  -- +1
					end if;
				when others =>
					null;
			end case;
		end if;
	end process;
end architecture;
