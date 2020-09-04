library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity TG68Test is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000; -- Sysclk frequency * 10
		spi_maxspeed : integer := 4	-- lowest acceptable timer DIV7 value
	);
	port (
		clk 			: in std_logic;
		reset_in 	: in std_logic;
		switches		: in std_logic_vector(9 downto 0);
		counter 		: buffer std_logic_vector(15 downto 0);
		pausecpu		: in std_logic;
		pausevga		: in std_logic;
		buttons		: in std_logic_vector(2 downto 0);

		-- VGA
		vga_red 		: out unsigned(7 downto 0);
		vga_green 	: out unsigned(7 downto 0);
		vga_blue 	: out unsigned(7 downto 0);
		vga_hsync 	: out std_logic;
		vga_vsync 	: out std_logic;
		vga_window	: out std_logic;
		
		-- SDRAM
		sdr_data		: inout std_logic_vector(15 downto 0);
		sdr_addr		: out std_logic_vector(11 downto 0);
		sdr_dqm 		: out std_logic_vector(1 downto 0);
		sdr_we 		: out std_logic;
		sdr_cas 		: out std_logic;
		sdr_ras 		: out std_logic;
		sdr_cs		: out std_logic;
		sdr_ba		: out std_logic_vector(1 downto 0);
--		sdr_clk		: out std_logic; -- Board specific, from the PLL
		sdr_cke	: out std_logic;
		
		-- UART
		rxd	: in std_logic;
		txd	: out std_logic;

		-- PS/2 keyboard / mouse
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2m_clk_in : in std_logic;
		ps2m_dat_in : in std_logic;
		ps2m_clk_out : out std_logic;
		ps2m_dat_out : out std_logic;
		
		-- SPI interface (SD card)
		sd_cs : out std_logic;
		sd_miso : in std_logic;
		sd_mosi : out std_logic;
		sd_clk : out std_logic
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
signal cpu_clkena : std_logic :='0';

-- VGA
signal currentX : unsigned(11 downto 0);
signal currentY : unsigned(11 downto 0);
signal wred : unsigned(7 downto 0);
signal wgreen : unsigned(7 downto 0);
signal wblue : unsigned(7 downto 0);
signal end_of_pixel : std_logic;
signal refresh :std_logic;
signal end_of_frame :std_logic;
signal vga_data : std_logic_vector(15 downto 0);
signal chargen_pixel : std_logic;
signal chargen_window : std_logic;

--
signal reset_reg : std_logic;
signal reset : std_logic := '0';
signal reset_counter : unsigned(15 downto 0) := X"FFFF";
signal tg68_ready : std_logic;
signal sdr_ready : std_logic;
signal write_address : std_logic_vector(31 downto 0);
signal req_pending : std_logic :='0';
--signal write_pending : std_logic :='0';
signal dtack1 : std_logic;

signal vga_addr : std_logic_vector(31 downto 0);
signal vga_req : std_logic;
signal vga_fill : std_logic;
signal vga_refresh : std_logic;
signal vga_newframe : std_logic;
signal vga_reservebank : std_logic; -- Keep bank clear for instant access.
signal vga_reserveaddr : std_logic_vector(31 downto 0); -- to SDRAM

-- VGA register block signals

signal vga_reg_addr : std_logic_vector(11 downto 0);
signal vga_reg_dataout : std_logic_vector(15 downto 0);
signal vga_reg_datain : std_logic_vector(15 downto 0);
signal vga_reg_rw : std_logic;
signal vga_reg_req : std_logic;
signal vga_reg_dtack : std_logic;
signal vga_ack : std_logic;
signal vblank_int : std_logic;

-- Peripheral register block signals

signal per_reg_addr : std_logic_vector(11 downto 0);
signal per_reg_dataout : std_logic_vector(15 downto 0);
signal per_reg_datain : std_logic_vector(15 downto 0);
signal per_reg_rw : std_logic;
signal per_reg_req : std_logic;
signal per_reg_dtack : std_logic;
signal per_uart_int : std_logic;
signal per_timer_int : std_logic;
signal per_ps2_int : std_logic;
signal per_spi_int : std_logic;

signal int_ack : std_logic;
signal ints : std_logic_vector(2 downto 0);

signal romdata : std_logic_vector(15 downto 0);
signal ramdata : std_logic_vector(15 downto 0);

signal framectr : unsigned(15 downto 0);
signal resetctr : std_logic;

signal bootrom_overlay : std_logic;

signal ps2m_clk_db : std_logic;
signal ps2k_clk_db : std_logic;

type prgstates is (run,pause,mem,rom,waitread,waitwrite,wait0,wait1,wait2,wait3,waitvga,vga,peripheral);
signal prgstate : prgstates :=wait2;
begin

sdr_cke <='1';
process(clk)
begin
	if rising_edge(clk) then
		reset <= tg68_ready and sdr_ready and reset_in;
	end if;
end process;

sdr_cke<='1';


ps2m_db: entity work.Debounce
	port map(
	clk => clk,
	signal_in => ps2m_clk_in,
	signal_out => ps2m_clk_db
);

ps2k_db: entity work.Debounce
	port map(
	clk => clk,
	signal_in => ps2k_clk_in,
	signal_out => ps2k_clk_db
);



myint : entity work.interrupt_controller
	port map(
		clk => clk,
		reset => reset,
		int7 => not buttons(2),
		int1 => vblank_int,
		int2 => per_uart_int,
		int3 => per_timer_int,
		int4 => per_ps2_int,
		int5 => per_spi_int,
		int6 => '0',
		int_out => ints,
		ack => int_ack
	);


myTG68 : entity work.TG68KdotC_Kernel
	generic map
	(
		MUL_Mode => 1
	)
   port map
	(
		clk => clk,
      nReset => reset_in and sdr_ready,  -- Contributes to reset, so have to use reset_in here.
      clkena_in => cpu_clkena and pausecpu,
      data_in => cpu_datain,
		IPL => ints,
		IPL_autovector => '0',
		CPU => "00",
		addr => cpu_addr,
		data_write => cpu_dataout,
		nWr => cpu_r_w,
		nUDS => cpu_uds,
		nLDS => cpu_lds,
		busstate => busstate,
		nResetOut => tg68_ready,
		FC => open,
-- for debug		
		skipFetch => open,
		regin => open
	);


mybootrom : entity work.BootRom
	port map (
		clock => clk,
		address => cpu_addr(11 downto 1),
		q => romdata
		);


-- Make use of boot rom
process(clk,cpu_addr)
begin
	if reset_in='0' then
		prgstate<=wait2;
		req_pending<='0';
		vga_reg_datain<=X"0000";
	elsif rising_edge(clk) then
		int_ack<='0';
		vga_reg_rw<='1';
		vga_reg_req<='0';
		per_reg_rw<='1';
		per_reg_req<='0';
		case prgstate is
			when run =>
				cpu_clkena<='0';
				prgstate<=pause;
			when pause =>
				prgstate<=mem;
			when mem =>
				if busstate="01" then
					prgstate<=wait0;
				else
					case cpu_addr(31 downto 16) is
						when X"FFFF" => -- Interrupt acknowledge cycle
							-- CPU address bits 3 downto 1 contain the int number,
							-- we respond with that number.  (Could just use autovectoring, of course.)
							cpu_datain <= "0000000000000" & cpu_addr(3 downto 1);
							int_ack<='1';
							prgstate<=wait0;
						when X"8000" => -- hardware registers - VGA controller
							vga_reg_addr<=cpu_addr(11 downto 1)&'0';
							vga_reg_rw<=cpu_r_w;
							vga_reg_req<='1';
							vga_reg_datain<=cpu_dataout;
							prgstate<=vga;
						when X"8100" => -- more hardware registers - peripherals
--							per_reg_addr<=cpu_addr(11 downto 1)&'0';
							per_reg_rw<=cpu_r_w;
							per_reg_req<='1';
--							per_reg_datain<=cpu_dataout;
							prgstate<=peripheral;
						when X"0000" => -- ROM access
							-- We replace the first page of RAM with the bootrom if the bootrom_overlay flag is set.
							if cpu_r_w='0' then	-- Pass writes through to RAM.
								req_pending<='1';
								prgstate<=waitwrite;
							elsif bootrom_overlay='0' then
								req_pending<='1';
								prgstate<=waitread;	-- overlay disabled.
							else
--								cpu_datain<=romdata;
								prgstate<=rom;
							end if;
						when others =>
--							datatoram<=cpu_dataout;
--							counter<=unsigned(cpu_dataout); -- Remove this...
--							write_address<=cpu_addr( downto 0);
							req_pending<='1';
							if cpu_r_w='0' then
								prgstate<=waitwrite;
							else	-- SDRAM read
								prgstate<=waitread;
							end if;
					end case;
				end if;
			when waitread =>
				req_pending<='1';
				if dtack1='0' then
					cpu_datain<=ramdata;
					req_pending<='0';
					prgstate<=wait0;
--					cpu_clkena<='1';
--					prgstate<=run;
				end if;
			when waitwrite =>
				req_pending<='1';
				if dtack1='0' then
					req_pending<='0';
					prgstate<=wait0;
--					cpu_clkena<='1';
--					prgstate<=run;
				end if;
			when rom =>
				cpu_datain<=romdata;
--				prgstate<=wait2;
				prgstate<=wait0;
			when vga =>
				cpu_datain<=vga_reg_dataout;
				vga_reg_rw<=cpu_r_w;
				if vga_reg_dtack='0' then
--					cpu_clkena<='1';
--					prgstate<=run;
					prgstate<=wait0;
				end if;
			when peripheral =>
				per_reg_req<='1';
				cpu_datain<=per_reg_dataout;
				per_reg_rw<=cpu_r_w;
				if per_reg_dtack='0' then
--					cpu_clkena<='1';
--					prgstate<=run;
					prgstate<=wait0;
				end if;
			when wait0 =>
				prgstate<=wait3;
			when wait1 =>
				prgstate<=wait3;
			when wait2 =>
				prgstate<=wait3;
			when wait3 =>
				if (reset or not tg68_ready)='1' then
					cpu_clkena<='1';
					prgstate<=run;
				end if;
			when others =>
				null;
		end case;
--		elsif busstate/="01" then	-- Does this cycle involve mem access if so, wait?
--			cpu_clkena<='0';
--		end if;
--		cpu_clkena<=(not cpu_clkena) and (ready or not tg68_ready);	-- Don't let TG68 start until the SDRAM is ready
	end if;
end process;

	
-- SDRAM
mysdram : entity work.sdram 
	generic map
	(
		rows => sdram_rows,
		cols => sdram_cols
	)
	port map
	(
	-- Physical connections to the SDRAM
		sdata => sdr_data,
		sdaddr => sdr_addr,
		sd_we	=> sdr_we,
		sd_ras => sdr_ras,
		sd_cas => sdr_cas,
		sd_cs	=> sdr_cs,
		dqm => sdr_dqm,
		ba	=> sdr_ba,

	-- Housekeeping
		sysclk => clk,
		reset => reset_in,  -- Contributes to reset, so have to use reset_in here.
		reset_out => sdr_ready,
		reinit => '0',

		vga_addr => vga_addr,
		vga_data => vga_data,
		vga_fill => vga_fill,
		vga_req => vga_req,
		vga_ack => vga_ack,
		vga_refresh => vga_refresh,
		vga_reservebank => vga_reservebank,
		vga_reserveaddr => vga_reserveaddr,

		vga_newframe => vga_newframe,

		datawr1 => cpu_dataout,
		Addr1 => cpu_addr,
		req1 => req_pending,
		wr1 => cpu_r_w,
		wrL1 => cpu_lds,
		wrU1 => cpu_uds,
		cachesel => busstate(1), -- Use separate caches for instruction and data.  0 => inst, 1 => data
		dataout1 => ramdata,
		dtack1 => dtack1
	);

	myvga : entity work.vga_controller
		port map (
		clk => clk,
		reset => reset,

		reg_addr_in => vga_reg_addr,
		reg_data_in => vga_reg_datain,
		reg_data_out => vga_reg_dataout,
		reg_rw => vga_reg_rw,
		reg_uds => cpu_uds,
		reg_lds => cpu_lds,
		reg_dtack => vga_reg_dtack,
		reg_req => vga_reg_req,

		sdr_addrout => vga_addr,
		sdr_datain => vga_data, 
		sdr_fill => vga_fill,
		sdr_req => vga_req,
		sdr_ack => vga_ack,
		sdr_reservebank => vga_reservebank,
		sdr_reserveaddr => vga_reserveaddr,
		sdr_refresh => vga_refresh,

		hsync => vga_hsync,
		vsync => vga_vsync,
		vblank_int => vblank_int,
		red => vga_red,
		green => vga_green,
		blue => vga_blue,
		vga_window => vga_window
	);
	
	myperipheral : entity work.peripheral_controller
		generic map(
			sdram_rows => sdram_rows,
			sdram_cols => sdram_cols,
			sysclk_frequency => sysclk_frequency,
			spi_maxspeed => spi_maxspeed
		)
		port map (
		clk => clk,
		reset => reset,
		
--		reg_addr_in => per_reg_addr,
		reg_addr_in => cpu_addr(11 downto 1)&'0',
--		reg_data_in => per_reg_datain,
		reg_data_in => cpu_dataout,
		reg_data_out => per_reg_dataout,
		reg_rw => per_reg_rw,
		reg_uds => cpu_uds,
		reg_lds => cpu_lds,
		reg_dtack => per_reg_dtack,
		reg_req => per_reg_req,

		uart_int => per_uart_int,
		timer_int => per_timer_int,
		ps2_int => per_ps2_int,
		spi_int => per_spi_int,

		uart_txd => txd,
		uart_rxd => rxd,

		ps2k_clk_in => ps2k_clk_db,
		ps2k_dat_in => ps2k_dat_in,
		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_out => ps2k_dat_out,
		ps2m_clk_in => ps2m_clk_db,
		ps2m_dat_in => ps2m_dat_in,
		ps2m_clk_out => ps2m_clk_out,
		ps2m_dat_out => ps2m_dat_out,

		miso => sd_miso,
		mosi => sd_mosi,
		spiclk_out => sd_clk,
		spi_cs => sd_cs,
		
		bootrom_overlay => bootrom_overlay,
		switches => switches,
		hex => counter
	);

	
end architecture;
