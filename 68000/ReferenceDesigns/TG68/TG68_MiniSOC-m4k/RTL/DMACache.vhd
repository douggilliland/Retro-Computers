library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity DMACache is
	port(
		clk : in std_logic;
		reset_n : in std_logic;
		-- DMA channel address strobes
		addr_in : in std_logic_vector(31 downto 0);
		setaddr_vga : in std_logic;
		setaddr_sprite0 : in std_logic;
		setaddr_audio0 : in std_logic;
		setaddr_audio1 : in std_logic;

		req_length : unsigned(11 downto 0);
		setreqlen_vga : in std_logic;
		setreqlen_sprite0 : in std_logic;
		setreqlen_audio0 : in std_logic;
		setreqlen_audio1 : in std_logic;

		-- Read requests
		req_vga : in std_logic;
		req_sprite0 : in std_logic;
		req_audio0 : in std_logic;
		req_audio1 : in std_logic;

		-- DMA channel output and valid flags.
		data_out : out std_logic_vector(15 downto 0);
		valid_vga : out std_logic;
		valid_sprite0 : out std_logic;
		valid_audio0 : out std_logic;
		valid_audio1 : out std_logic;
		
		-- SDRAM interface
		sdram_addr : out std_logic_vector(31 downto 0);
		sdram_reserveaddr : out std_logic_vector(31 downto 0);
		sdram_reserve : out std_logic;
		sdram_req : out std_logic;
		sdram_ack : in std_logic; -- Set when the request has been acknowledged.
		sdram_fill : in std_logic;
		sdram_data : in std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of dmacache is


type inputstate_t is (rd1,rcv1,rcv2,rcv3,rcv4);
signal inputstate : inputstate_t := rd1;

type updatestate_t is (vga,spr0,aud0,aud1);
signal update : updatestate_t := vga;

constant vga_base : std_logic_vector(1 downto 0) := "00";
constant spr0_base : std_logic_vector(1 downto 0) := "01";
constant spr1_base : std_logic_vector(1 downto 0) := "10";
constant aud0_base : std_logic_vector(1 downto 0) := "11";
-- constant aud1_base : std_logic_vector(2 downto 0) := "100";

-- DMA channel state information

signal valid_vga_d : std_logic;
signal valid_sprite0_d : std_logic;
signal valid_audio0_d : std_logic;

signal vga_wrptr : unsigned(5 downto 0);
signal vga_wrptr_next : unsigned(5 downto 0);
signal vga_rdptr : unsigned(5 downto 0);
signal vga_addr : std_logic_vector(31 downto 0);
signal vga_count : unsigned(11 downto 0);

signal spr0_wrptr : unsigned(5 downto 0);
signal spr0_wrptr_next : unsigned(5 downto 0);
signal spr0_rdptr : unsigned(5 downto 0);
signal spr0_addr : std_logic_vector(31 downto 0);
signal spr0_count : unsigned(11 downto 0);
signal spr0_pending : std_logic;

signal aud0_wrptr : unsigned(5 downto 0);
signal aud0_wrptr_next : unsigned(5 downto 0);
signal aud0_rdptr : unsigned(5 downto 0);
signal aud0_addr : std_logic_vector(31 downto 0);
signal aud0_count : unsigned(11 downto 0);
signal aud0_pending : std_logic;

signal aud1_wrptr : unsigned(5 downto 0);
signal aud1_wrptr_next : unsigned(5 downto 0);
signal aud1_rdptr : unsigned(5 downto 0);
signal aud1_addr : std_logic_vector(31 downto 0);
signal aud1_count : unsigned(11 downto 0);
signal aud1_pending : std_logic;

-- interface to the blockram

signal cache_wraddr : std_logic_vector(7 downto 0);
signal cache_rdaddr : std_logic_vector(7 downto 0);
signal cache_wren : std_logic;
signal data_from_ram : std_logic_vector(15 downto 0);

begin

myDMACacheRAM : entity work.DMACacheRAM
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
-- FIXME - use pointer comparison to turn off reserve when not needed.
sdram_reserve<='1' when vga_count/=X"000" else '0';

process(clk)
begin
	if rising_edge(clk) then
		if reset_n='0' then
			inputstate<=rd1;
			vga_count<=X"000";
			vga_wrptr<=(others => '0');
			vga_wrptr_next<="000100";
			spr0_count<=X"000";
			spr0_wrptr<=(others => '0');
			spr0_wrptr_next<="000100";
		end if;

		cache_wren<='0';
		
		if sdram_ack='1' then
			sdram_reserveaddr<=vga_addr;
--			sdram_reserveaddr<=std_logic_vector(unsigned(vga_addr)+8);
			sdram_req<='0';
		end if;

		-- Request and receive data from SDRAM:
		case inputstate is
			-- First state: Read.  Check the channels in priority order.
			-- VGA has absolutel priority, and the others won't do anything until the VGA buffer is
			-- full.
			when rd1 =>
				if vga_rdptr(5 downto 2)/=vga_wrptr_next(5 downto 2) and vga_count/=X"000" then
					cache_wraddr<=vga_base&std_logic_vector(vga_wrptr);
					sdram_req<='1';
					sdram_addr<=vga_addr;
					vga_addr<=std_logic_vector(unsigned(vga_addr)+8);
					inputstate<=rcv1;
					update<=vga;
					vga_count<=vga_count-4;
				elsif spr0_rdptr(5 downto 2)/=spr0_wrptr_next(5 downto 2) and spr0_count/=X"000" then
					cache_wraddr<=spr0_base&std_logic_vector(spr0_wrptr);
					sdram_req<='1';
					sdram_addr<=spr0_addr;
					spr0_addr<=std_logic_vector(unsigned(spr0_addr)+8);
					inputstate<=rcv1;
					update<=spr0;
					spr0_count<=spr0_count-4;
				end if;
				-- FIXME - other channels here
			-- Wait for SDRAM, fill first word.
			when rcv1 =>
				if sdram_fill='1' then
					data_from_ram<=sdram_data;
					cache_wren<='1';
					inputstate<=rcv2;
--					cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				end if;
			when rcv2 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rcv3;
			when rcv3 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rcv4;
			when rcv4 =>
				data_from_ram<=sdram_data;
				cache_wren<='1';
				cache_wraddr<=std_logic_vector(unsigned(cache_wraddr)+1);
				inputstate<=rd1;
				case update is
					when vga =>
						vga_wrptr<=vga_wrptr_next;
						vga_wrptr_next<=vga_wrptr_next+4;
					when spr0 =>
						spr0_wrptr<=spr0_wrptr_next;
						spr0_wrptr_next<=spr0_wrptr_next+4;
				-- FIXME - other channels here
					when others =>
						null;
				end case;
			when others =>
				null;
		end case;
		
		if setaddr_vga='1' then
			vga_addr<=addr_in;
			vga_wrptr<="000000";
			vga_wrptr_next<="000100";
		end if;
		if setaddr_sprite0='1' then
			spr0_addr<=addr_in;
			spr0_wrptr<="000000";
			spr0_wrptr_next<="000100";
		end if;

		if setreqlen_vga='1' then
			vga_count<=req_length;
		end if;
		if setreqlen_sprite0='1' then
			spr0_count<=req_length;
		end if;

	end if;
end process;


process(clk)
begin
	if rising_edge(clk) then
		if reset_n='0' then
			vga_rdptr<=(others => '0');
			spr0_rdptr<=(others => '0');
		end if;

	-- Reset read pointers when a new address is set
		if setaddr_vga='1' then
			vga_rdptr<="000000";
		end if;
		if setaddr_sprite0='1' then
			spr0_rdptr<="000000";
		end if;
		
	-- Handle timeslicing of output registers
	-- We prioritise simply by testing in order of priority.
	-- req signals should always be a single pulse; need to latch all but VGA, since it may be several
	-- cycles since they're serviced.

		if req_sprite0='1' then
			spr0_pending<='1';
		end if;
		if req_audio0='1' then
			aud0_pending<='1';
		end if;

		valid_vga<=valid_vga_d;
		valid_sprite0<=valid_sprite0_d;
		valid_audio0<=valid_audio0_d;

		valid_vga_d<='0';
		valid_sprite0_d<='0';
		valid_audio0_d<='0';
		
		if req_vga='1' then -- and vga_rdptr/=vga_wrptr then -- This test should never fail.
			cache_rdaddr<=vga_base&std_logic_vector(vga_rdptr);
			vga_rdptr<=vga_rdptr+1;
			valid_vga_d<='1';
		elsif spr0_pending='1' and spr0_rdptr/=spr0_wrptr then
			cache_rdaddr<=spr0_base&std_logic_vector(spr0_rdptr);
			spr0_rdptr<=spr0_rdptr+1;
			valid_sprite0_d<='1';
			spr0_pending<='0';
		elsif aud0_pending='1' and aud0_rdptr/=aud0_wrptr then
			cache_rdaddr<=aud0_base&std_logic_vector(aud0_rdptr);
			aud0_rdptr<=aud0_rdptr+1;
			valid_audio0_d<='1';
			aud0_pending<='0';
		end if;
	end if;
end process;
		
end rtl;

