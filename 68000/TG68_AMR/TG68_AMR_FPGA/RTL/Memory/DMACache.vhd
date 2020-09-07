library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.DMACache_pkg.ALL;
use work.DMACache_config.ALL;


entity DMACache is
	port(
		clk : in std_logic;
		reset_n : in std_logic;
		-- DMA channel address strobes

		channels_from_host : in DMAChannels_FromHost
			:= (others =>
					(
						addr => (others =>'X'),
						setaddr => '0',
						reqlen => (others =>'X'),
						setreqlen => '0',
						req => '0'
					)); -- Yes, I know - ick.
		channels_to_host : out DMAChannels_ToHost;

		data_out : out std_logic_vector(15 downto 0);

		-- SDRAM interface
		sdram_addr : out std_logic_vector(31 downto 0);
		sdram_reserveaddr : out std_logic_vector(31 downto 0);
		sdram_reserve : out std_logic;
		sdram_req : out std_logic;
		sdram_ack : in std_logic; -- Set when the request has been acknowledged.
		sdram_nak : in std_logic; -- Set when bank collisions prevent the request being serviced
		sdram_fill : in std_logic;
		sdram_data : in std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of dmacache is

type inputstate_t is (rd1,rcv1,rcv2,rcv3,rcv4,rcv5,rcv6,rcv7,rcv8);
signal inputstate : inputstate_t := rd1;


-- DMA channel state information
type DMAChannel_Internal is record
	valid_d : std_logic; -- Used to delay the valid flag
	wrptr : unsigned(DMACache_MaxCacheBit downto 0);
	wrptr_next : unsigned(DMACache_MaxCacheBit downto 0);
	rdptr : unsigned(DMACache_MaxCacheBit downto 0);
	addr : std_logic_vector(31 downto 0); -- Current RAM address
	count : unsigned(16 downto 0); -- Number of words to transfer.
	pending : std_logic; -- Host has a request pending on this channel
	fill : std_logic;	-- Add a word to the FIFO
	full : std_logic; -- Is the FIFO full?
	drain : std_logic; -- Drain a word from the FIFO
	empty : std_logic; -- Is the FIFO completely empty?
	extend : std_logic;
end record;

type DMAChannels_Internal is array (DMACache_MaxChannel downto 0) of DMAChannel_Internal;

signal internals : DMAChannels_Internal;

-- interface to the blockram

signal cache_wraddr : std_logic_vector(8 downto 0);
signal cache_wraddr_lsb : std_logic_vector(2 downto 0);
signal cache_rdaddr : std_logic_vector(8 downto 0);
signal cache_wren : std_logic;
signal data_from_ram : std_logic_vector(15 downto 0);

signal activechannel : integer range 0 to DMACache_MaxChannel;

begin

FIFOCounters:
for CHANNEL in 0 to DMACache_MaxChannel generate
	myfifocounter : entity work.FIFO_Counter
	generic map(
		maxbit=>5
	)
	port map(
		clk => clk,
		reset => channels_from_host(CHANNEL).setaddr,
		fill => internals(CHANNEL).fill,
		drain => internals(CHANNEL).drain,
		full => internals(CHANNEL).full,
		empty => internals(CHANNEL).empty
	);
end generate;

myDMACacheRAM : entity work.DMACacheRAM
	generic map
	(
		CacheAddrBits => 9
	)
	port map
	(
		clock => clk,
		data => data_from_ram,
		rdaddress => cache_rdaddr,
		wraddress => cache_wraddr,
		wren => cache_wren,
		q => data_out
	);

-- Employ bank reserve for SDRAM.
sdram_reserve<='1' when internals(0).count(15 downto 0)/=X"0000"
								and internals(0).full='0' else '0';


process(clk)
begin

	-- We update these outside the clock edge
	sdram_addr<=internals(activechannel).addr;
	sdram_reserveaddr<=internals(0).addr;
	cache_wraddr(2 downto 0)<=cache_wraddr_lsb;

	if rising_edge(clk) then
		if reset_n='0' then
			inputstate<=rd1;
			for I in 0 to DMACache_MaxChannel loop
				internals(I).count<=(others => '0');
			end loop;
		end if;

		-- We do this inside the clock edge otherwise last word of the burst is lost due to the write pointer being updated.
		cache_wraddr(8 downto 3)<=std_logic_vector(to_unsigned(activechannel,3))&std_logic_vector(internals(activechannel).wrptr(5 downto 3));

		cache_wren<='0';
		
		if sdram_ack='1' then
			sdram_req<='0';
			internals(activechannel).addr<=std_logic_vector(unsigned(internals(activechannel).addr)+16);
			if internals(activechannel).extend='1' then -- Read an extra word for non-aligned reads.
				internals(activechannel).extend<='0';
			else
				internals(activechannel).count<=internals(activechannel).count-8;
			end if;
		end if;
		

		for I in 0 to DMACache_MaxChannel loop
			internals(I).fill<='0';
		end loop;

		-- Request and receive data from SDRAM:
		case inputstate is
			-- First state: Read.  Check the channels in priority order.
			-- VGA has absolute priority, and the others won't do anything until the VGA buffer is
			-- full.
			when rd1 =>
				for I in DMACache_MaxChannel downto 0 loop
					if internals(I).full='0'
						and internals(I).count(15 downto 0)/=X"0000"
							and internals(I).count(16)='0' then
						activechannel <= I;
						sdram_req<='1';
						inputstate<=rcv1;
					end if;
				end loop;


			-- Wait for SDRAM, fill first word.
			when rcv1 =>
				if sdram_nak='1' then -- Back out of a read request if the cycle's not serviced
					sdram_req<='0';	-- (Allows priorities to be reconsidered.)
					inputstate<=rd1;
				end if;
				if sdram_fill='1' then
					data_from_ram<=sdram_data;
					cache_wren<='1';
					inputstate<=rcv2;
					cache_wraddr_lsb<="000";
					internals(activechannel).fill<='1';
				end if;
			when rcv2 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="001";
				internals(activechannel).fill<='1';
				inputstate<=rcv3;
			when rcv3 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="010";
				internals(activechannel).fill<='1';
				inputstate<=rcv4;
			when rcv4 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="011";
				internals(activechannel).fill<='1';
				inputstate<=rcv5;
			when rcv5 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="100";
				internals(activechannel).fill<='1';
				inputstate<=rcv6;
			when rcv6 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="101";
				internals(activechannel).fill<='1';
				inputstate<=rcv7;
			when rcv7 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="110";
				internals(activechannel).fill<='1';
				inputstate<=rcv8;
			when rcv8 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr_lsb<="111";
				internals(activechannel).fill<='1';
				inputstate<=rd1;

				internals(activechannel).wrptr<=internals(activechannel).wrptr_next;
				internals(activechannel).wrptr_next<=internals(activechannel).wrptr_next+8;

				for I in DMACache_MaxChannel downto 0 loop
					if internals(I).full='0'
						and internals(I).count(15 downto 0)/=X"0000"
							and internals(I).count(16)='0' then
						activechannel <= I;
						sdram_req<='1';
						inputstate<=rcv1;
					end if;
				end loop;
	
			when others =>
				null;
		end case;
	
		for I in 0 to DMACache_MaxChannel loop
			if channels_from_host(I).setaddr='1' then
				internals(I).addr<=channels_from_host(I).addr;
				internals(I).wrptr<=(others =>'0');
				internals(I).wrptr_next<=(3=>'1', others =>'0');
				internals(I).count<=(others=>'0');
			end if;
			if channels_from_host(I).setreqlen='1' then
				internals(I).count(15 downto 0)<=channels_from_host(I).reqlen;
				internals(I).count(16)<='0';
				internals(I).extend<='1'; -- If the data isn't burst-aligned we need to read an extra burst.
				if internals(I).addr(2 downto 0)="000" then
					internals(I).extend<='0';
				end if;
			end if;
		end loop;

	end if;
end process;


process(clk)
	variable servicechannel : integer range 0 to DMACache_MaxChannel;
	variable serviceactive : std_logic;
begin
	if rising_edge(clk) then

	-- Handle timeslicing of output registers
	-- We prioritise simply by testing in order of priority.
	-- req signals should always be a single pulse; need to latch all but VGA, since it may be several
	-- cycles since they're serviced.

		for I in 0 to DMACache_MaxChannel loop -- Channel 0 has priority, so is never held pending.
			if channels_from_host(I).req='1' then
				internals(I).pending<='1';
			end if;

			internals(I).drain<='0';
			channels_to_host(I).valid<='0';
		end loop;
		
		serviceactive := '0';
		for I in DMACache_MaxChannel downto 0 loop
			if internals(I).pending='1' and internals(I).empty='0' then
				serviceactive := '1';
				servicechannel := I;
			end if;
		end loop;

		if serviceactive='1' then
			cache_rdaddr<=std_logic_vector(to_unsigned(servicechannel,3))&std_logic_vector(internals(servicechannel).rdptr);
			internals(servicechannel).rdptr<=internals(servicechannel).rdptr+1;
			channels_to_host(servicechannel).valid<='1';
			internals(servicechannel).drain<='1';
			internals(servicechannel).pending<='0';
		end if;

		-- Reset read pointers when a new address is set
		for I in 0 to DMACache_MaxChannel loop
			if channels_from_host(I).setaddr='1' then
				internals(I).rdptr<=(others => '0');
				internals(I).rdptr(2 downto 0)<=
					unsigned(channels_from_host(I).addr(3 downto 1));	-- Offset to allow non-aligned accesses.
				internals(I).pending<='0';
			end if;
		end loop;

	end if;
end process;
		
end rtl;

