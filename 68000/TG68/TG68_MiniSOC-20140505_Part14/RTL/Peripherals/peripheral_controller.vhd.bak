library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

-- Peripheral controller

-- Need to provide:
-- 	UART
--    X"000" - UART_IO
--    	On Write: Sends lower 8 bits.
--    	On Read:  Bit1 10: txint, bit 9: rxint, Bit 8: txready.  Bits 7-0: received data.
--		X"002" - UART_CLKDIV
--			R/W - Gets/Sets current clock divisor for baud rate generator
--		X"004" - Flags
--			bit 0 : ROM Overlay
--		X"006" - Hex display

-- 	PS/2 keyboard
--		PS/2 Mouse
--    X"008" - Keyboard port: xxxx recv, ready to send, data(10 downto 1).  Write: xxxxxxxx data
--    X"00A" - Mouse port: xxxx recv, ready to send, data(10 downto 1).  Write: xxxxxxxx data

-- 	Timers:
--		Control word
--		X"00E"   X X en5 en4 en3 en2 en1 X X X t5 t4 t3 t2 t1 X
--					enx - interrupt enable bit, tx - trigger flag - Cleared on read
--    X"010"   16-bit timer divisor for t0.  t1, 2 and 3 are derived from t0, which divides sysclk.
--    X"012"   16-bit timer divisor for t1   Read only
--    X"014"   16-bit timer divisor for t2
--    X"016"   16-bit timer divisor for t3
--    X"018"   16-bit timer divisor for t4
--    X"01A"   16-bit timer divisor for t5
--    X"01C"   16-bit timer divisor for t6
--    X"01E"   16-bit timer divisor for t7

--    X"020"	SPI register
--    X"022"	SPI CS register
--    X"024"	Blocking version of the SPI register

entity peripheral_controller is
	generic (
		sdram_rows : integer := 12;
		sdram_cols : integer := 8;
		sysclk_frequency : integer := 1000; -- Sysclk frequency * 10
		spi_maxspeed : integer := 4	-- lowest acceptable timer DIV7 value
	);
  port (
		clk : in std_logic;
		reset : in std_logic;
		
		-- CPU interface

		reg_addr_in : in std_logic_vector(11 downto 0);
		reg_data_in: in std_logic_vector(15 downto 0);
		reg_data_out: out std_logic_vector(15 downto 0);
		reg_rw : in std_logic;
		reg_uds : in std_logic;
		reg_lds : in std_logic;
		reg_dtack : out std_logic;	-- Needed for char ram access.
		reg_req : in std_logic;

		-- Interrupts
		
		uart_int : out std_logic;
		timer_int : out std_logic;
		ps2_int : out std_logic;
		spi_int : out std_logic;

		-- UART
		uart_rxd : in std_logic;
		uart_txd : out std_logic;

		-- PS/2 keyboard / mouse
		ps2k_clk_in : in std_logic;
		ps2k_dat_in : in std_logic;
		ps2k_clk_out : out std_logic;
		ps2k_dat_out : out std_logic;
		ps2m_clk_in : in std_logic;
		ps2m_dat_in : in std_logic;
		ps2m_clk_out : out std_logic;
		ps2m_dat_out : out std_logic;

		-- SPI (SD Card)
		spi_cs : out std_logic;
		miso : in std_logic;
		mosi : out std_logic;
		spiclk_out : out std_logic;

		-- Misc

		bootrom_overlay : out std_logic;
		switches : in std_logic_vector(9 downto 0);
		hex : out std_logic_vector(15 downto 0)
	);
end entity;
	
architecture rtl of peripheral_controller is

signal extend_cycle : std_logic :='0'; -- Used for blocking SPI access
signal extend_rw : std_logic :='1';

signal ser_txdata : std_logic_vector(7 downto 0);
signal ser_txready : std_logic;
signal ser_txgo : std_logic :='0';
signal ser_rxdata : std_logic_vector(7 downto 0);
signal ser_rxint : std_logic;
signal ser_txint : std_logic;
signal ser_ints : std_logic_vector(1 downto 0);
--signal ser_clock_divisor : unsigned(15 downto 0) := X"16E3";	-- 19200 baud @ 112.5MHz
--signal ser_clock_divisor : unsigned(15 downto 0) := X"2DC6";	-- 9600 baud @ 112.5MHz
signal ser_clock_divisor : unsigned(15 downto 0) := X"03D0";	-- 115200 baud @ 112.5MHz


signal flags : std_logic_vector(15 downto 0) :=X"0001" ; -- Bootrom overlay enabled by default

signal timer_set : std_logic :='0';
signal timer_divisor : std_logic_vector(2 downto 0);
signal timer_trigger : std_logic_vector(7 downto 0);
signal timer_flags : std_logic_vector(15 downto 0);

signal kbdidle : std_logic;
signal kbdrecv : std_logic;
signal kbdrecvreg : std_logic;
signal kbdsendbusy : std_logic;
signal kbdsendtrigger : std_logic;
signal kbdsenddone : std_logic;
signal kbdsendbyte : std_logic_vector(7 downto 0);
signal kbdrecvbyte : std_logic_vector(10 downto 0);

signal mouseidle : std_logic;
signal mouserecv : std_logic;
signal mouserecvreg : std_logic;
signal mousesendbusy : std_logic;
signal mousesenddone : std_logic;
signal mousesendtrigger : std_logic;
signal mousesendbyte : std_logic_vector(7 downto 0);
signal mouserecvbyte : std_logic_vector(10 downto 0);

signal host_to_spi : std_logic_vector(15 downto 0);
signal spi_to_host : std_logic_vector(15 downto 0);
signal spiclk_in : std_logic;
signal spi_trigger : std_logic;
signal spi_busy : std_logic;
signal spi_wide : std_logic;

COMPONENT ps2_io
	PORT
	(
		clk		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		ps2_dat		:	 IN STD_LOGIC;
		ps2_clk		:	 IN STD_LOGIC;
		ps2_dato		:	 OUT STD_LOGIC;
		ps2_clko		:	 OUT STD_LOGIC;
		senddata		:	 IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		sendtrigger		:	 IN STD_LOGIC;
		sendready		:	 OUT STD_LOGIC;
		recvdata		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		recvtrigger		:	 OUT STD_LOGIC;
		recvack		:	 IN STD_LOGIC
	);
END COMPONENT;

begin

	bootrom_overlay <= flags(0);

	-- Handle CPU access to hardware registers

	myspi : entity work.spi_interface 
		port map (
			sysclk =>clk,
			reset => reset,

			-- Host interface
			spiclk_in => timer_trigger(7),
			host_to_spi => host_to_spi(15 downto 0),
			spi_to_host => spi_to_host,
			wide => spi_wide,
			busy => spi_busy,
			trigger => spi_trigger,

			-- Hardware interface
			miso => miso,
			mosi => mosi,
			spiclk_out => spiclk_out
	);


	myuart : entity work.simple_uart
		port map(
			clk => clk,
			reset => reset,
			txdata => ser_txdata,
			txready => ser_txready,
			txgo => ser_txgo,
			rxdata => ser_rxdata,
			rxint => ser_rxint,
			txint => ser_txint,
			clock_divisor => ser_clock_divisor,
			rxd => uart_rxd,
			txd => uart_txd
		);
	
	mytimer : entity work.cascade_timer
		port map(
			clk => clk,
			reset => reset,
			setdiv => timer_set,
			divisor => timer_divisor,
			divin => unsigned(reg_data_in),
			trigger => timer_trigger
		);
		
	mykeyboard : entity work.io_ps2_com
		generic map (
			clockFilter => 15,
			ticksPerUsec => sysclk_frequency/10
		)
		port map (
			clk => clk,
			reset => not reset, -- active high!
			ps2_clk_in => ps2k_clk_in,
			ps2_dat_in => ps2k_dat_in,
			ps2_clk_out => ps2k_clk_out,
			ps2_dat_out => ps2k_dat_out,
			
			inIdle => open,	-- Probably don't need this
			sendTrigger => kbdsendtrigger,
			sendByte => kbdsendbyte,
			sendBusy => kbdsendbusy,
			sendDone => kbdsenddone,
			recvTrigger => kbdrecv,
			recvByte => kbdrecvbyte
		);

--	mymouse : component ps2_io
--        port map (
--                clk => clk,
--                reset => not reset,
-- 
--                recvdata => mouserecvbyte(7 downto 0),
--                senddata => mousesendbyte(7 downto 0),
--                recvack => mouserecvack,
--                sendtrigger => mousesendtrigger,
--                recvtrigger => mouserecv,
--                sendready => mousesendbusy,
--
--                ps2_clk => ps2m_clk_in,
--                ps2_dat => ps2m_dat_in,
--                ps2_clko => ps2m_clk_out,
--                ps2_dato => ps2m_dat_out
--					);

	mymouse : entity work.io_ps2_com
		generic map (
			clockFilter => 15,
			ticksPerUsec => sysclk_frequency/10
		)
		port map (
			clk => clk,
			reset => not reset, -- active high!
			ps2_clk_in => ps2m_clk_in,
			ps2_dat_in => ps2m_dat_in,
			ps2_clk_out => ps2m_clk_out,
			ps2_dat_out => ps2m_dat_out,
			
			inIdle => open,	-- Probably don't need this
			sendTrigger => mousesendtrigger,
			sendByte => mousesendbyte,
			sendBusy => mousesendbusy,
			sendDone => mousesenddone,
			recvTrigger => mouserecv,
			recvByte => mouserecvbyte
		);

	process(clk,reset)
	begin
		if reset='0' then
			extend_cycle<='0';
			extend_rw<='1';
			uart_int<='0';
			ser_ints<="00";
			timer_int<='0';
			ps2_int<='0';
			flags<=X"0001";	-- Re-enable overlay on reset
			timer_flags<=X"0000";
			kbdrecvreg <='0';
			mouserecvreg <='0';
			spi_cs<='1';
		elsif rising_edge(clk) then
			reg_dtack<='1';
			ser_txgo<='0';
			
			timer_set<='0';
			kbdsendtrigger<='0';

			mousesendtrigger<='0';
			
			spi_trigger<='0';

			extend_cycle<='0';
			extend_rw<='1';
			
			if reg_req='1' or extend_cycle='1' then

				reg_dtack<='0';	-- None of these registers takes more than one cycle to respond.
										-- (Exception: blocking SPI register)

				if reg_rw='0' or extend_rw='0' then -- write cycle:
					case reg_addr_in is

						-- RS232 writes
					
						when X"000" => -- Serial data
							if ser_txready='1' then  -- write
								ser_txdata<=reg_data_in(7 downto 0);
								ser_txgo<='1';
							end if;
						when X"002" => -- Baud rate (clock divisor)
							ser_clock_divisor<=unsigned(reg_data_in);

						-- Write to misc regs (ROM overlay, hex display)
							
						when X"004" => -- Flags
							flags<=reg_data_in;
						when X"006" => -- HEX display
							hex<=reg_data_in;

						-- Write to PS/2 registers
						when X"008" =>
							kbdsendbyte<=reg_data_in(7 downto 0);
							kbdsendtrigger<='1';
						when X"00A" =>
							mousesendbyte<=reg_data_in(7 downto 0);
							mousesendtrigger<='1';
							
						-- Writes to timer registers
						
						when X"00E" => -- Timer control register - lower 4 bits form a mask to clear trigger flags
							timer_flags<=reg_data_in(15 downto 8)&timer_flags(7 downto 0);
						when X"010" =>
							timer_divisor<="000";
							timer_set<='1';
						when X"012" =>
							timer_divisor<="001";
							timer_set<='1';
						when X"014" =>
							timer_divisor<="010";
							timer_set<='1';
						when X"016" =>
							timer_divisor<="011";
							timer_set<='1';
						when X"018" =>
							timer_divisor<="100";
							timer_set<='1';
						when X"01A" =>
							timer_divisor<="101";
							timer_set<='1';
						when X"01C" =>
							timer_divisor<="110";
							timer_set<='1';
						when X"01E" =>
							timer_divisor<="111";
							timer_set<='1';
							
						-- Write to SPI register:
						when X"020" =>
							spi_wide<='0';
							spi_trigger<='1';
							host_to_spi<=reg_data_in;

						-- Write to SPI CS register:
						when X"022" =>
							spi_cs<=not reg_data_in(0);

						-- Blocking write to SPI register
						when X"024" =>
							if spi_busy='1' then
								reg_dtack<='1';
								extend_cycle<='1';
								extend_rw<='0';
							else
								spi_wide<='0';
								spi_trigger<='1';
								host_to_spi<=reg_data_in;
							end if;

						when others =>
							reg_data_out<=X"0000";
					end case;
				else  -- read cycle
					if reg_addr_in(8)='0' then
						case reg_addr_in is

							-- Read from RS232
							when X"000" => -- Serial data
								reg_data_out<="00000"&ser_ints&ser_txready&ser_rxdata(7 downto 0);
								ser_ints<="00"; -- Clear int flags (Do this before setting them, or we miss bytes!)
							when X"002" => -- Baud rate (clock divisor)
								reg_data_out<=std_logic_vector(ser_clock_divisor);

							-- Read from misc regs
							when X"004" => -- Flags
								reg_data_out<=switches & flags(5 downto 0);
								
							-- Read from PS/2 regs
							when X"008" =>
								reg_data_out<="0000" & kbdrecvreg & not kbdsendbusy & kbdrecvbyte(10 downto 1);
								kbdrecvreg<='0';
								
							when X"00A" =>
								reg_data_out<="0000" & mouserecvreg & not mousesendbusy & mouserecvbyte(10 downto 1);
								mouserecvreg<='0';

							-- Read from timer regs

							when X"00E" => -- Timer control register
								reg_data_out<=timer_flags;
								timer_flags(7 downto 0)<=X"00";	-- Clear int flags on read.

							-- Read from SD register
							when X"020" =>
--								host_to_spi<=X"FFFF";
								reg_data_out<=spi_to_host;
							
							-- Read from SD CS register
							when X"022" =>
								reg_data_out<=spi_busy & "000" & X"000";

							-- Blocking read from SD register.
							when X"024" =>
--								host_to_spi<=X"FFFF";
								reg_data_out<=spi_to_host;
								if spi_busy='1' then
									reg_dtack<='1';
									extend_cycle<='1';
								end if;
							
							-- Memory size register
							when X"028" =>
								reg_data_out<=std_logic_vector(to_unsigned(sdram_rows+sdram_cols+3,16));

							-- System clock frequency
							when X"02A" =>
								reg_data_out<=std_logic_vector(to_unsigned(sysclk_frequency,16));

							--	SPI Speed
							when X"02C" =>
								reg_data_out<=std_logic_vector(to_unsigned(spi_maxspeed,16));

							when others =>
								reg_data_out<=X"0000";
						end case;
					else	-- 0x100 onwards, devote to SPI transfers.
						reg_data_out<=spi_to_host;
						if spi_busy='1' then	-- Wait for previous transfer to finish
							extend_cycle<='1';
							reg_dtack<='1';
						else
							host_to_spi<=X"FFFF";	-- Pump new data.
							spi_wide<='1';
							spi_trigger<='1';
						end if;				
					end if;
				end if;
			end if;
				
			-- Handle serial interrupts.  We map both Rx and Tx interrupts onto a single interrupt
			-- signal, but keep track of which has occured.
			-- When the CPU reads the register these are cleared.
			uart_int<=ser_rxint or ser_txint;
			if ser_rxint='1' then
				ser_ints(0)<='1';
			end if;
			if ser_txint='1' then
				ser_ints(1)<='1';
			end if;
			
			-- Store trigger flags.  These will be cleared on read.
			timer_flags(7 downto 0) <= timer_flags(7 downto 0) or timer_trigger;

			-- Handle timer interrupts
			timer_int<=(timer_trigger(5) and timer_flags(13))
				or (timer_trigger(4) and timer_flags(12))
				or (timer_trigger(3) and timer_flags(11))
				or (timer_trigger(2) and timer_flags(10))
				or	(timer_trigger(1) and timer_flags(9));	-- We don't trigger interrupts for the base timer.

			-- PS2 interrupt
			ps2_int <= kbdrecv or kbdsenddone
				or mouserecv or mousesenddone;
				-- mouserecv or kbdsenddone or mousesenddone ; -- Momentary high pulses to indicate retrieved data.
			if kbdrecv='1' then
				kbdrecvreg <= '1'; -- remains high until cleared by a read
			end if;
			if mouserecv='1' then
				mouserecvreg <= '1'; -- remains high until cleared by a read
			end if;
			
			spi_int<='0';
		end if;
	end process;
		
end architecture;