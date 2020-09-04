library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity VirtualToplevel is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000; -- Sysclk frequency * 10
		vga_bits : integer := 8
	);
	port (
		clk 			: in std_logic;
		clk_fast 	: in std_logic;
		reset_in 	: in std_logic;

		-- VGA
		vga_red 		: out unsigned(vga_bits-1 downto 0);
		vga_green 	: out unsigned(vga_bits-1 downto 0);
		vga_blue 	: out unsigned(vga_bits-1 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: buffer std_logic;
		vga_window	: out std_logic;

		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector((sdram_rows-1) downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic;
		sdr_cke		: out std_logic;

		-- PS/2 keyboard / mouse
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2m_clk_in : in std_logic;
		ps2m_dat_in : in std_logic;
		ps2m_clk_out : out std_logic;
		ps2m_dat_out : out std_logic;

		-- SPI signals
		spi_miso		: in std_logic := '1'; -- Allow the SPI interface not to be plumbed in.
		spi_mosi		: out std_logic;
		spi_clk		: out std_logic;
		spi_cs 		: out std_logic;
		
		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;
		
		-- Audio
		audio_l : out signed(15 downto 0);
		audio_r : out signed(15 downto 0);

		-- Misc IO
		hex : out std_logic_vector(15 downto 0)
);
end entity;

architecture rtl of VirtualToplevel is

constant sysclk_hz : integer := sysclk_frequency*1000;
constant uart_divisor : integer := sysclk_hz/1152;

signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";

-- UART signals

signal ser_txdata : std_logic_vector(7 downto 0);
signal ser_txready : std_logic;
signal ser_rxdata : std_logic_vector(7 downto 0);
signal ser_rxrecv : std_logic;
signal ser_txgo : std_logic;
signal ser_rxint : std_logic;
signal ser_ferr : std_logic;

-- TG68 signals

signal mem_busy	: std_logic;
signal mem_read	: std_logic_vector(15 downto 0);
signal mem_write	: std_logic_vector(15 downto 0);
signal mem_addr	: std_logic_vector(31 downto 0);
signal mem_we_n	: std_logic; 
signal mem_uds_n	: std_logic; 
signal mem_lds_n	: std_logic; 
signal clk_ena		: std_logic;
signal cpu_state  : std_logic_vector(1 downto 0);
signal cpu_ready  : std_logic;

signal rom_we_n : std_logic;
signal rom_read : std_logic_vector(15 downto 0);

type soc_states is (delay1, enable, delay2, main, romread);
signal soc_state : soc_states := main;

begin

spi_mosi<='1';
spi_clk<='1';

audio_l <= X"0000";
audio_r <= X"0000";

sdr_cke <='0'; -- Disable SDRAM for now
sdr_cs <='1'; -- Disable SDRAM for now
sdr_data <=(others => 'Z');
sdr_addr <=(others => '1');
sdr_dqm <=(others => '1');
sdr_we <= '1';
sdr_cas <='1';
sdr_ras <='1';
sdr_ba <=(others => '1');


-- Reset counter.

process(clk)
begin
	if reset_in='0' then
		reset_counter<=X"FFFF";
		reset<='0';
	elsif rising_edge(clk) then
		reset_counter<=reset_counter-1;
		if reset_counter=X"0000" then
			reset<='1';
		end if;
	end if;
end process;


-- UART

myuart : entity work.simple_uart
	generic map(
		enable_tx=>true,
		enable_rx=>true
	)
	port map(
		clk => clk,
		reset => reset, -- active low
		txdata => ser_txdata,
		txready => ser_txready,
		txgo => ser_txgo,
		rxdata => ser_rxdata,
		rxint => ser_rxint,
		txint => open,
		framingerror => ser_ferr,
		clock_divisor => to_unsigned(uart_divisor,16),
		rxd => rxd,
		txd => txd
	);


-- Hello World ROM

	myrom : entity work.HelloWorld_ROM
	generic map
	(
		maxAddrBitBRAM => 12
	)
	port map (
		clk => clk,
		addr => mem_addr(12 downto 0),
		q => rom_read,
		d => mem_write,
		we_n => rom_we_n,
		uds_n => mem_uds_n,
		lds_n => mem_lds_n
	);


-- Main CPU

mytg68 : entity work.TG68KdotC_Kernel
	generic map(
		SR_Read => 2,         --0=>user,   1=>privileged,      2=>switchable with CPU(0)
		VBR_Stackframe => 2,  --0=>no,     1=>yes/extended,    2=>switchable with CPU(0)
		extAddr_Mode => 2,   --0=>no,     1=>yes,    2=>switchable with CPU(1)
		MUL_Mode => 2,	   --0=>16Bit,  1=>32Bit,  2=>switchable with CPU(1),  3=>no MUL,  
		DIV_Mode => 2,	   --0=>16Bit,  1=>32Bit,  2=>switchable with CPU(1),  3=>no DIV,  
		BitField => 2		   --0=>no,     1=>yes,    2=>switchable with CPU(1)  
	)
   port map(
		clk => clk,
		nReset => reset,
		clkena_in => clk_ena,
		data_in => mem_read,
		IPL => "111",
		IPL_autovector => '0',
		CPU => "00",
		addr => mem_addr,
		data_write => mem_write,
		nWr => mem_we_n,
		nUDS => mem_uds_n,
		nLDS => mem_lds_n,
		busstate => cpu_state,
		nResetOut => cpu_ready,
		FC => open,
		-- for debug		
		skipFetch => open,
		regin => open
	);

process(clk)
begin
	if reset='0' then
		spi_cs<='1';
	elsif rising_edge(clk) then
		mem_busy<='1';
		ser_txgo<='0';
		rom_we_n<='1';
		clk_ena<='0';

		case soc_state is
			when main =>
				if cpu_ready='1' then
					case cpu_state is
						when "11" => -- Write from CPU
							case mem_addr(31 downto 28) is
								when X"F" =>	-- Peripherals
									case mem_addr(7 downto 0) is
										when X"C0" => -- UART
											ser_txdata<=mem_write(7 downto 0);
											ser_txgo<='1';
											soc_state<=delay1;
											
										when others =>
											soc_state<=delay1;
											null;
									end case;
								when others =>
									rom_we_n<='0';
									soc_state<=delay1;
									null;
							end case;
						when "01" => -- decode
							soc_state<=delay1;
						when others => -- read instruction or data
						
							case mem_addr(31 downto 28) is

								when X"F" =>	-- Peripherals
									case mem_addr(7 downto 0) is
										when X"C0" => -- UART
											mem_read<=(others=>'X');
											mem_read(12 downto 0)<=ser_ferr&"00"&ser_rxrecv&ser_txready&ser_rxdata;
											ser_rxrecv<='0';	-- Clear rx flag.
											soc_state<=delay1;

										when others =>
											soc_state<=delay1;
											null;
									end case;

								when others =>
									soc_state<=romread;
							end case;
					end case;
				end if;

			when romread =>
				mem_read<=rom_read;
				soc_state<=delay1;

			when delay1 =>
				soc_state<=enable;
				
			when enable =>
				clk_ena<='1';
				soc_state<=delay2;

			when delay2 =>
				soc_state<=main;
		end case;


		-- Set this after the read operation has potentially cleared it.
		if ser_rxint='1' then
			ser_rxrecv<='1';
		end if;

	end if; -- rising-edge(clk)

end process;
	
end architecture;
