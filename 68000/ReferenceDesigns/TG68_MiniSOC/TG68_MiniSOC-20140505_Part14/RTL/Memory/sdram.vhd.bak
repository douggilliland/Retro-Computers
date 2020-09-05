------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                                                                          --
-- Copyright (c) 2009 Tobias Gubener                                        -- 
-- Subdesign fAMpIGA by TobiFlex                                            --
--                                                                          --
-- This source file is free software: you can redistribute it and/or modify --
-- it under the terms of the GNU General Public License as published        --
-- by the Free Software Foundation, either version 3 of the License, or     --
-- (at your option) any later version.                                      --
--                                                                          --
-- This source file is distributed in the hope that it will be useful,      --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of           --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            --
-- GNU General Public License for more details.                             --
--                                                                          --
-- You should have received a copy of the GNU General Public License        --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.    --
--                                                                          --
------------------------------------------------------------------------------
------------------------------------------------------------------------------

 
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity sdram is
generic
	(
		rows : integer := 12;	-- FIXME - change access sizes according to number of rows
		cols : integer := 8
	);
port
	(
-- Physical connections to the SDRAM
	sdata		: inout std_logic_vector(15 downto 0);
	sdaddr		: out std_logic_vector((rows-1) downto 0);
	sd_we		: out std_logic;	-- Write enable, active low
	sd_ras		: out std_logic;	-- Row Address Strobe, active low
	sd_cas		: out std_logic;	-- Column Address Strobe, active low
	sd_cs		: out std_logic;	-- Chip select - only the lsb does anything.
	dqm			: out std_logic_vector(1 downto 0);	-- Data mask, upper and lower byte
	ba			: buffer std_logic_vector(1 downto 0); -- Bank?

-- Housekeeping
	sysclk		: in std_logic;
	reset		: in std_logic;
	reset_out	: out std_logic;
	reinit : in std_logic :='0';

-- Port 0 - VGA
	vga_addr : in std_logic_vector(31 downto 0);
	vga_data	: out std_logic_vector(15 downto 0);
	vga_req : in std_logic;
	vga_fill : out std_logic;
	vga_ack : out std_logic;
	vga_newframe : in std_logic;
	vga_refresh : in std_logic; -- SDRAM won't come out of reset without this.
	vga_reservebank : in std_logic; -- Keep a bank clear for instant access in slot 1
	vga_reserveaddr : in std_logic_vector(31 downto 0);

	-- Port 1
	datawr1		: in std_logic_vector(15 downto 0);	-- Data in from minimig
	Addr1		: in std_logic_vector(31 downto 0);	-- Address in from Minimig - FIXME case
	req1		: in std_logic;
	cachesel	: in std_logic :='0'; -- 1 => data cache, 0 => instruction cache
	wr1			: in std_logic;	-- Read/write from Minimig
	wrL1		: in std_logic;	-- Minimig write lower byte
	wrU1		: in std_logic;	-- Minimig write upper byte
	dataout1		: out std_logic_vector(15 downto 0); -- Data destined for Minimig
	dtack1	: buffer std_logic
	);
end;

architecture rtl of sdram is


signal initstate	:unsigned(3 downto 0);	-- Counter used to initialise the RAM
signal cas_sd_cs	:std_logic;	-- Temp registers...
signal cas_sd_ras	:std_logic;
signal cas_sd_cas	:std_logic;
signal cas_sd_we 	:std_logic;
signal cas_dqm		:std_logic_vector(1 downto 0);	-- ...mask register for entire burst
signal init_done	:std_logic;
signal datain		:std_logic_vector(15 downto 0);
signal casaddr		:std_logic_vector(31 downto 0);
signal sdwrite 		:std_logic;
signal sdata_reg	:std_logic_vector(15 downto 0);

signal refreshcycle :std_logic;
signal qvalid		:std_logic;
signal qdataout0	:std_logic_vector(15 downto 0); -- temp data for Minimig
signal qdataout1	:std_logic_vector(15 downto 0); -- temp data for Minimig

type sdram_states is (ph0,ph1,ph1_1,ph1_2,ph1_3,ph1_4,ph2,ph3,ph4,ph5,ph6,ph7,ph8,
								ph9,ph9_1,ph9_2,ph9_3,ph9_4,ph10,ph11,ph12,ph13,ph14,ph15);
signal sdram_state		: sdram_states;

type sdram_ports is (idle,refresh,port0,port1,writecache);

signal sdram_slot1 : sdram_ports :=refresh;
signal sdram_slot1_readwrite : std_logic;
signal sdram_slot2 : sdram_ports :=idle;
signal sdram_slot2_readwrite : std_logic;

-- Since VGA has absolute priority, we keep track of the next bank and disallow accesses
-- to either the current or next bank in the interleaved access slots.
signal slot1_bank : std_logic_vector(1 downto 0) := "00";
signal slot2_bank : std_logic_vector(1 downto 0) := "11";

signal slot1_fill : std_logic;
signal slot2_fill : std_logic;


-- refresh timer - once per scanline, so don't need the counter...
-- signal refreshcounter : unsigned(12 downto 0);	-- 13 bits gives us 8192 cycles between refreshes => pretty conservative.
signal refreshpending : std_logic :='0';

signal port1_dtack : std_logic;

type writecache_states is (waitwrite,fill,finish);
signal writecache_state : writecache_states;

signal writecache_addr : std_logic_vector(31 downto 2);
signal writecache_word0 : std_logic_vector(15 downto 0);
signal writecache_word1 : std_logic_vector(15 downto 0);
--signal writecache_word2 : std_logic_vector(15 downto 0);
--signal writecache_word3 : std_logic_vector(15 downto 0);
--signal writecache_word4 : std_logic_vector(15 downto 0);
--signal writecache_word5 : std_logic_vector(15 downto 0);
--signal writecache_word6 : std_logic_vector(15 downto 0);
--signal writecache_word7 : std_logic_vector(15 downto 0);
signal writecache_dqm : std_logic_vector(7 downto 0);
signal writecache_req : std_logic;
signal writecache_dirty : std_logic;
signal writecache_dtack : std_logic;
signal writecache_burst : std_logic;

type readcache_states is (waitread,req,fill1,fill2,fill3,fill4,fill2_1,fill2_2,fill2_3,fill2_4,finish);
signal readcache_state : readcache_states;

signal readcache_addr : std_logic_vector(31 downto 3);
signal readcache_word0 : std_logic_vector(15 downto 0);
signal readcache_word1 : std_logic_vector(15 downto 0);
signal readcache_word2 : std_logic_vector(15 downto 0);
signal readcache_word3 : std_logic_vector(15 downto 0);
signal readcache_dirty : std_logic;
signal readcache_req : std_logic;
signal readcache_dtack : std_logic;
signal readcache_fill : std_logic;

signal cache_ready : std_logic;

COMPONENT TwoWayCache
	PORT
	(
		clk		:	 IN STD_LOGIC;
		reset	: IN std_logic;
		ready : out std_logic;
		cpu_addr		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		cpu_req		:	 IN STD_LOGIC;
		cpu_ack		:	 OUT STD_LOGIC;
		cpu_rw		:	 IN STD_LOGIC;
		cpu_rwl	: in std_logic;
		cpu_rwu : in std_logic;
		data_from_cpu		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		data_to_cpu		:	 OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--		sdram_addr		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_from_sdram		:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		data_to_sdram		:	 OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		sdram_req		:	 OUT STD_LOGIC;
		sdram_fill		:	 IN STD_LOGIC;
		sdram_rw		:	 OUT STD_LOGIC
	);
END COMPONENT;


begin

	readcache_fill <= '1' when (slot1_fill='1' and sdram_slot1=port1)
								or (slot2_fill='1' and sdram_slot2=port1)
									else '0';

	vga_fill <= '1' when (slot1_fill='1' and sdram_slot1=port0)
								or (slot2_fill='1' and sdram_slot2=port0)
									else '0';

	process(sysclk)
	begin
	
	dtack1 <= port1_dtack and writecache_dtack and not readcache_dtack;

-- Write cache implementation: (AMR)
-- states:
--    main:	wait for req1='1' and wr1='0'
--				Compare addrin(23 downto 3) with stored address, or stored address is FFFFFF
--					if equal, store data and DQM according to LSBs, assert dtack,
--				if stored address/=X"FFFFFF" assert req_sdram, set data/dqm for first word
--				if fill from SDRAM
--					write second word/dqm
--					goto state fill3
--		fill3
--			write third word / dqm
--			goto state fill4
--		fill4
--			write fourth word / dqm
--			goto state finish
--		finish
--			addr<=X"FFFFFF";
--			dqms<=X"11111111";
--			goto state main
	

	if reset='0' then
		writecache_req<='0';
		writecache_dirty<='0';
		writecache_dqm<=(others => '1');
		writecache_state<=waitwrite;
	elsif rising_edge(sysclk) then

		writecache_dtack<='1';
		case writecache_state is
			when waitwrite =>
				if req1='1' and wr1='0' then -- write request
					-- Need to be careful with write merges; if we byte-write to an address
					-- that already has a pending word write, we must be sure not to cancel
					-- the other half of the existing word write.
					if writecache_dirty='0' or addr1(31 downto 2)=writecache_addr(31 downto 2) then
						writecache_addr(31 downto 2)<=addr1(31 downto 2);
						case addr1(1) is
							when '0' =>
								if wrU1='0' then
									writecache_word0(15 downto 8)<=datawr1(15 downto 8);
									writecache_dqm(1)<='0';
								end if;
								if wrL1='0' then
									writecache_word0(7 downto 0)<=datawr1(7 downto 0);
									writecache_dqm(0)<='0';
								end if;
							when '1' =>
								if wrU1='0' then
									writecache_word1(15 downto 8)<=datawr1(15 downto 8);
									writecache_dqm(3)<='0';
								end if;
								if wrL1='0' then
									writecache_word1(7 downto 0)<=datawr1(7 downto 0);
									writecache_dqm(2)<='0';
								end if;
--							when "10" =>
--								if wrU1='0' then
--									writecache_word2(15 downto 8)<=datawr1(15 downto 8);
--									writecache_dqm(5)<='0';
--								end if;
--								if wrL1='0' then
--									writecache_word2(7 downto 0)<=datawr1(7 downto 0);
--									writecache_dqm(4)<='0';
--								end if;
--							when "11" =>
--								if wrU1='0' then
--									writecache_word3(15 downto 8)<=datawr1(15 downto 8);
--									writecache_dqm(7)<='0';
--								end if;
--								if wrL1='0' then
--									writecache_word3(7 downto 0)<=datawr1(7 downto 0);
--									writecache_dqm(6)<='0';
--								end if;
							when others =>
								null;
						end case;
						writecache_req<='1';

						writecache_dtack<='0';
						writecache_dirty<='1';
					end if;
				end if;
				if writecache_burst='1' and writecache_dirty='1' then
					writecache_req<='0';
					writecache_state<=fill;
				end if;
			when fill =>
				if writecache_burst='0' then
					writecache_dirty<='0';
					writecache_dqm<=(others => '1');
					writecache_state<=waitwrite;
				end if;
			when others =>
				null;
		end case;
				
	end if;
end process;


mytwc : component TwoWayCache
	PORT map
	(
		clk => sysclk,
		reset => reset,
		ready => cache_ready,
		cpu_addr => addr1,
		cpu_req => req1,
		cpu_ack => readcache_dtack,
		cpu_rw => wr1,
		cpu_rwl => wrL1,
		cpu_rwu => wrU1,
		data_from_cpu => datawr1,
		data_to_cpu => dataout1,
		data_from_sdram => sdata_reg,
		data_to_sdram => open,
		sdram_req => readcache_req,
		sdram_fill => readcache_fill,
		sdram_rw => open
	);

	
-------------------------------------------------------------------------
-- SDRAM Basic
-------------------------------------------------------------------------
	reset_out <= init_done and cache_ready;


	process (sysclk, reset, sdwrite, datain) begin
		IF sdwrite='1' THEN	-- Keep sdram data high impedence if not writing to it.
			sdata <= datain;
		ELSE
			sdata <= "ZZZZZZZZZZZZZZZZ";
		END IF;

		--   sample SDRAM data
		if rising_edge(sysclk) then
			sdata_reg <= sdata;
			vga_data <= sdata;
		END IF;	
		
		if reset = '0' then
			initstate <= (others => '0');
			init_done <= '0';
			sdram_state <= ph0;
		ELSIF rising_edge(sysclk) THEN

			if reinit='1' then
				init_done<='0';
				initstate<="1111";
			end if;			
			

			case sdram_state is	--LATENCY=3
				when ph0 =>	sdram_state <= ph1;
				when ph1 =>	sdram_state <= ph2;
					slot1_fill<='0';
					slot2_fill<='1';
--				when ph1_1 => sdram_state <= ph1_2;
--				when ph1_2 => sdram_state <= ph1_3;
--				when ph1_3 => sdram_state <= ph1_4;
--				when ph1_4 => sdram_state <= ph2;
				when ph2 => sdram_state <= ph3;
				when ph3 =>	sdram_state <= ph4;
				when ph4 =>	sdram_state <= ph5;
				when ph5 => sdram_state <= ph6;
				when ph6 =>	sdram_state <= ph7;
				when ph7 =>	sdram_state <= ph8;
				when ph8 =>	sdram_state <= ph9;
				when ph9 =>	sdram_state <= ph10;
					slot2_fill<='0';
					slot1_fill<='1';
--				when ph9_1 => sdram_state <= ph9_2;
--				when ph9_2 => sdram_state <= ph9_3;
--				when ph9_3 => sdram_state <= ph9_4;
--				when ph9_4 => sdram_state <= ph10;
				when ph10 => sdram_state <= ph11;
				when ph11 => sdram_state <= ph12;
				when ph12 => sdram_state <= ph13;
				when ph13 => sdram_state <= ph14;
				when ph14 =>
						if initstate /= "1111" THEN -- 16 complete phase cycles before we allow the rest of the design to come out of reset.
							initstate <= initstate+1;
							sdram_state <= ph15;
						elsif init_done='1' then
							sdram_state <= ph15;
						elsif vga_refresh='1' then -- Delay here to establish phase relationship between SDRAM and VGA
							init_done <='1';
							sdram_state <= ph0;
						end if;
				when ph15 => sdram_state <= ph0;
				when others => sdram_state <= ph0;
			end case;	
		END IF;	
	end process;		


	
	process (sysclk, initstate, datain, init_done, casaddr, refreshcycle) begin


		if reset='0' then
			sdram_slot1<=refresh;
			sdram_slot2<=idle;
			slot1_bank<="00";
			slot2_bank<="11";
			writecache_burst<='0';
			sdwrite<='0';
		elsif rising_edge(sysclk) THEN -- rising edge
	
			-- FIXME - need to make sure refresh happens often enough
--			refreshcounter<=refreshcounter+"0000000000001";
			if sdram_slot1=refresh then
				refreshpending<='0';
--			elsif refreshcounter(12 downto 4)="000000000" then
--				refreshpending<='1';
			elsif vga_refresh='1' then
				refreshpending<='1';
			end if;

			sdwrite<='0';
			sd_cs <='1';
			sd_ras <= '1';
			sd_cas <= '1';
			sd_we <= '1';
			sdaddr <= (others => 'X');
			ba <= "00";
			dqm <= "00";  -- safe defaults for everything...

			port1_dtack<='1';

			-- The following block only happens during reset.
			if init_done='0' then
				if sdram_state =ph2 then
					case initstate is
						when "0010" => --PRECHARGE
							sdaddr(10) <= '1'; 	--all banks
							sd_cs <='0';
							sd_ras <= '0';
							sd_cas <= '1';
							sd_we <= '0';
						when "0011"|"0100"|"0101"|"0110"|"0111"|"1000"|"1001"|"1010"|"1011"|"1100" => --AUTOREFRESH
							sd_cs <='0'; 
							sd_ras <= '0';
							sd_cas <= '0';
							sd_we <= '1';
						when "1101" => --LOAD MODE REGISTER
							sd_cs <='0';
							sd_ras <= '0';
							sd_cas <= '0';
							sd_we <= '0';
--							ba <= "00";
	--						sdaddr <= "001000100010"; --BURST=4 LATENCY=2
--							sdaddr <= "001000110010"; --BURST=4 LATENCY=3
--							sdaddr <= "001000110000"; --noBURST LATENCY=3
							sdaddr <= (others => '0');
							sdaddr(5 downto 0) <= "110011";  --BURST=8, LATENCY=3, BURST WRITES
--							sdaddr <= "000000110010"; --BURST=4 LATENCY=3, BURST WRITES
						when others =>	null;	--NOP
					end case;
				END IF;
			else		


-- Time slot control			

				vga_ack<='0';
				case sdram_state is

					when ph2 => -- ACTIVE for first access slot
						cas_sd_cs <= '0';  -- Only the lowest bit has any significance...
						cas_sd_ras <= '1';
						cas_sd_cas <= '1';
						cas_sd_we <= '1';

						cas_dqm <= "00";

						sdram_slot1<=idle;
						if refreshpending='1' and sdram_slot2=idle then	-- refreshcycle
							sdram_slot1<=refresh;
							sd_cs <= '0'; --ACTIVE
							sd_ras <= '0';
							sd_cas <= '0'; --AUTOREFRESH
						elsif vga_req='1' then
							if vga_addr(5 downto 4)/=slot2_bank or sdram_slot2=idle then
								sdram_slot1<=port0;
								sdaddr <= vga_addr((rows+cols+2) downto (cols+3));
								ba <= vga_addr(5 downto 4);
								slot1_bank <= vga_addr(5 downto 4);
								casaddr <= vga_addr(31 downto 4) & "0000"; -- read whole cache line in burst mode.
								cas_sd_cas <= '0';
								cas_sd_we <= '1';
								sd_cs <= '0'; --ACTIVE
								sd_ras <= '0';
								vga_ack<='1'; -- Signal to VGA controller that it can bump bankreserve
							end if;
						elsif writecache_req='1'
								and sdram_slot2/=writecache
								and (writecache_addr(5 downto 4)/=slot2_bank or sdram_slot2=idle)
									then
							sdram_slot1<=writecache;
							sdaddr <= writecache_addr((rows+cols+2) downto (cols+3));
							ba <= writecache_addr(5 downto 4);
							slot1_bank <= writecache_addr(5 downto 4);
							cas_dqm <= wrU1&wrL1;
							casaddr <= writecache_addr&"00";
							cas_sd_cas <= '0';
							cas_sd_we <= '0';
							sdram_slot1_readwrite <= '0';
							sd_cs <= '0'; --ACTIVE
							sd_ras <= '0';
						elsif readcache_req='1' --req1='1' and wr1='1'
								and (Addr1(5 downto 4)/=slot2_bank or sdram_slot2=idle) then
							sdram_slot1<=port1;
							sdaddr <= Addr1((rows+cols+2) downto (cols+3));
							ba <= Addr1(5 downto 4);
							slot1_bank <= Addr1(5 downto 4); -- slot1 bank
							cas_dqm <= "00";
							casaddr <= Addr1(31 downto 1) & "0";
							cas_sd_cas <= '0';
							cas_sd_we <= '1';
							sdram_slot1_readwrite <= '1';
							sd_cs <= '0'; --ACTIVE
							sd_ras <= '0';
						end if;
						
						-- SLOT 2
						 -- Second word of burst write
						if sdram_slot2=writecache then
							sdwrite<='1';
							datain <= writecache_word1;
							dqm <= writecache_dqm(3 downto 2);
							writecache_burst<='0';
						end if;


					when ph3 =>
						-- Third word of burst write
						if sdram_slot2=writecache then
							dqm <= "11"; -- Mask off end of write burst
						end if;


					when ph4 =>
						 -- Final word of burst write
						if sdram_slot2=writecache then
							-- Issue precharge command to terminate the burst.
							sd_we<='0';
							sd_ras<='0';
							sd_cs<='0'; -- Chip select
							ba<=slot2_bank;
							dqm <= "11"; -- Mask off end of write burst
						end if;


					when ph5 => -- Read command	
						if sdram_slot1=port0 or sdram_slot1=port1 then
							sdaddr <= (others=>'0');
							sdaddr((cols-1) downto 0) <= casaddr((cols+2) downto 6) & casaddr(3 downto 1) ;--auto precharge
--							sdaddr(10) <= cas_sd_we;  -- Don't use auto-precharge for writes.
							sdaddr(10) <= '1'; -- Auto precharge.
							ba <= slot1_bank;
							sd_cs <= '0';

							dqm <= cas_dqm;

							sd_ras <= '1';
							sd_cas <= '0'; -- CAS
							sd_we  <= '1'; -- Read
						end if;

					when ph6 =>

					when ph7 =>
						if sdram_slot1=writecache then
							writecache_burst<='1';	-- Close the door on new write data
						end if;
				
					when ph8 =>

					when ph9 =>
						if sdram_slot1=writecache then -- Write command
							sdaddr <= (others=>'0');
							sdaddr((cols-1) downto 0) <= casaddr((cols+2) downto 6) & casaddr(3 downto 1) ;--auto precharge
							sdaddr(10) <= '0';  -- Don't use auto-precharge for writes.							ba <= slot1_bank;
							sd_cs <= '0';
							ba<=slot1_bank;

							sd_ras <= '1';
							sd_cas <= '0'; -- CAS
							sd_we  <= '0'; -- Write

							sdwrite<='1';
							datain <= writecache_word0;
							dqm <= writecache_dqm(1 downto 0);
						end if;

					when ph9_1 =>

					when ph9_2 =>

					when ph9_3 =>
						
					when ph9_4 =>

					when ph10 =>
						-- Slot 1
						-- Next word of burst write
						if sdram_slot1=writecache then
							sdwrite<='1';
							datain <= writecache_word1;
							dqm <= writecache_dqm(3 downto 2);
							writecache_burst<='0';
						end if;					
						
						-- Slot 2, active command
						cas_sd_cs <= '0';  -- Only the lowest bit has any significance...
						cas_sd_ras <= '1';
						cas_sd_cas <= '1';
						cas_sd_we <= '1';
						
						cas_dqm <= "00";

						sdram_slot2<=idle;
						if refreshpending='1' or sdram_slot1=refresh then
							sdram_slot2<=idle;
						elsif writecache_req='1'
								and sdram_slot1/=writecache
								and (writecache_addr(5 downto 4)/=slot1_bank or sdram_slot1=idle)
								and (writecache_addr(5 downto 4)/=vga_reserveaddr(5 downto 4)
									or vga_reservebank='0') then  -- Safe to use this slot with this bank?
							sdram_slot2<=writecache;
							sdaddr <= writecache_addr((rows+cols+2) downto (cols+3));
							ba <= writecache_addr(5 downto 4);
							slot2_bank <= writecache_addr(5 downto 4);
							cas_dqm <= wrU1&wrL1;
							casaddr <= writecache_addr&"00";
							cas_sd_cas <= '0';
							cas_sd_we <= '0';
							sdram_slot2_readwrite <= '0';
							sd_cs <= '0'; --ACTIVE
							sd_ras <= '0';
						elsif readcache_req='1' -- req1='1' and wr1='1'
								and (Addr1(5 downto 4)/=slot1_bank or sdram_slot1=idle)
								and (Addr1(5 downto 4)/=vga_reserveaddr(5 downto 4)
									or vga_reservebank='0') then  -- Safe to use this slot with this bank?
							sdram_slot2<=port1;
							sdaddr <= Addr1((rows+cols+2) downto (cols+3));
							ba <= Addr1(5 downto 4);
							slot2_bank <= Addr1(5 downto 4);
							cas_dqm <= "00";
							casaddr <= Addr1(31 downto 1) & "0"; -- We no longer mask off LSBs for burst read
							cas_sd_cas <= '0';
							cas_sd_we <= '1';
							sdram_slot2_readwrite <= '1';
							sd_cs <= '0'; --ACTIVE
							sd_ras <= '0';
						end if;
				
					when ph11 =>
						-- third word of burst write
						if sdram_slot1=writecache then
							dqm<="11"; -- Mask off end of burst
						end if;


					when ph12 =>
						if sdram_slot1=writecache then
							-- Issue precharge command to terminate the burst.
							sd_we<='0';
							sd_ras<='0';
							sd_cs<='0'; -- Chip select
							ba<=slot1_bank;
							dqm<="11"; -- Mask off end of burst
						end if;

					
					-- Phase 13 - CAS for second window...
					when ph13 =>
						if sdram_slot2=port1 then
							sdaddr <= (others=>'0');
							sdaddr((cols-1) downto 0) <= casaddr((cols+2) downto 6) & casaddr(3 downto 1) ;--auto precharge
--							sdaddr(10) <= cas_sd_we;  -- Don't use auto-precharge for writes.
							sdaddr(10) <= '1'; -- Auto precharge.
							ba <= slot2_bank;
							sd_cs <= '0';

							dqm <= "00";

							sd_ras <= '1';
							sd_cas <= '0'; -- CAS
							sd_we  <= '1'; -- Read
						end if;

					when ph14 =>

					when ph15 =>
						if sdram_slot2=writecache then
							writecache_burst<='1';  -- close the door on new write data
						end if;

					when ph0 =>

					when ph1 =>
						if sdram_slot2=writecache then
							sdaddr <= (others=>'0');
							sdaddr((cols-1) downto 0) <= casaddr((cols+2) downto 6) & casaddr(3 downto 1) ;--auto precharge
							sdaddr(10) <= '0';  -- Don't use auto-precharge for writes.
							ba <= slot2_bank;
							sd_cs <= '0';

							sd_ras <= '1';
							sd_cas <= '0'; -- CAS
							sd_we  <= '0'; -- Write
							
							sdwrite<='1';
							datain <= writecache_word0;
							dqm <= writecache_dqm(1 downto 0);
						end if;

					when ph1_1 =>

					when ph1_2 =>

					when ph1_3 =>

					when ph1_4 =>

					when others =>
						null;
						
				end case;

			END IF;	
		END IF;	
	END process;		
END;
