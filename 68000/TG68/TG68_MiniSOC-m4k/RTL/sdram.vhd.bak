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
 
-- Dual-port SDRAM controller.
-- Note: references to SPIHost here actually refer to the 2nd TG68 processor
 
-- TODO: cacheline 
-- Need a multi-word cacheline to deal with burst writes from the SDRAM controller
-- Ideally would be as transparent as possible - would prefer not to need the
-- tight timing between different parts of the design; would like to decouple
-- the Minimig clock from the SDRAM controller's phase.
-- The SDRAM controller is already using 4-word bursts, so 4-words, or 64 bits
-- would be a sensible size to use for cachelines.

-- Implementing a single cacheline is easy - just need to round down the address
-- to the nearest cacheline boundary, and delay the transaction until the requested
-- word is in cache.

-- What's trickier is implementing multiple cache lines.  Need a multi-port SDRAM
-- controller for a start. 

-- * Each cacheline should present itself to the SDRAM controller with an address and a request bit.

-- * The SDRam controller will scan them in order of priority and service the first
-- port to require attention.

-- All cachelines will be aware of the current input address, and will all have a "clear"
-- signal.  For simplicity and LE count, the cacheline will simply invalidate itself if a
-- write occurs on a cached address; the next read will then pull the newly-written data back in
-- from SDRAM.

-- The trickiest part is deciding which cacheline to use for a new read.
-- * Maybe maintain a counter for each cacheline, and bump the counter for every
--   cache hit?  Then decrement the counter once per cycle.  (or perhaps an n-bit shift register?)
--   Then when a new read cycle comes in, fill the first cacheline with zero counter?

 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdram is
port
	(
-- Physical connections to the SDRAM
	sdata		: inout std_logic_vector(15 downto 0);
	sdaddr		: out std_logic_vector(11 downto 0);
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

-- Port 0
	datawr0		: in std_logic_vector(15 downto 0);	-- Data in from minimig
	Addr0		: in std_logic_vector(23 downto 0);	-- Address in from Minimig
	wr0			: in std_logic;	-- Read/write from Minimig
	wrL0		: in std_logic;	-- Minimig write lower byte
	wrU0		: in std_logic;	-- Minimig write upper byte
	dataout0		: out std_logic_vector(15 downto 0); -- Data destined for Minimig
	dtack0	: buffer std_logic;

	-- Port 1
	datawr1		: in std_logic_vector(15 downto 0);	-- Data in from minimig
	Addr1		: in std_logic_vector(23 downto 0);	-- Address in from Minimig
	wr1			: in std_logic;	-- Read/write from Minimig
	wrL1		: in std_logic;	-- Minimig write lower byte
	wrU1		: in std_logic;	-- Minimig write upper byte
	dataout1		: out std_logic_vector(15 downto 0); -- Data destined for Minimig
	dtack1	: buffer std_logic

	);
end;

architecture rtl of sdram is


signal initstate	:std_logic_vector(3 downto 0);	-- Counter used to initialise the RAM
signal cas_sd_cs	:std_logic;	-- Temp registers...
signal cas_sd_ras	:std_logic;
signal cas_sd_cas	:std_logic;
signal cas_sd_we 	:std_logic;
signal cas_dqm		:std_logic_vector(1 downto 0);	-- ...Temp registers
signal init_done	:std_logic;
signal datain		:std_logic_vector(15 downto 0);
signal casaddr		:std_logic_vector(23 downto 0);
signal sdwrite 		:std_logic;
signal sdata_reg	:std_logic_vector(15 downto 0);

signal refreshcycle :std_logic;
signal qvalid		:std_logic;
signal qdataout0	:std_logic_vector(15 downto 0); -- temp data for Minimig
signal qdataout1	:std_logic_vector(15 downto 0); -- temp data for Minimig

type sdram_states is (ph0,ph1,ph2,ph3,ph4,ph5,ph6,ph7,ph8,ph9,ph10,ph11,ph12,ph13,ph14,ph15);
signal sdram_state		: sdram_states;

type sdram_ports is (refresh,port0,port1);
signal sdram_port : sdram_ports :=refresh;

begin
	process (sysclk, reset) begin
		dataout0 <= qdataout0;	-- Forward data from holding register
		dataout1 <= qdataout1;	-- Forward data from holding register
		if reset = '0' THEN
			null;
		elsif rising_edge(sysclk) THEN
					case sdram_state is	
						when ph7 =>	
								-- Data should be ready at phase 10
						when ph8 =>	
								if cas_sd_we='1' then
									-- Read cycle...
									-- Mark cache line to be filled here
								end if;
						when ph10 =>	-- Burst mode - first word
							case sdram_port is
								when port0 =>
									qdataout0 <= sdata_reg;
								when port1 =>
									qdataout1 <= sdata_reg;
								when others =>
									null;
							end case;
--								if zcache_fill='1' THEN
--									zcache(63 downto 48) <= sdata_reg;
--								end if;
						when ph11 =>	-- Second word
--										if zcache_fill='1' THEN
--											zcache(47 downto 32) <= sdata_reg;
--										end if;
						when ph12 =>	-- Third word
--										if zcache_fill='1' THEN
--											zcache(31 downto 16) <= sdata_reg;
--										end if;
						when ph13 =>	-- Fourth word
--										if zcache_fill='1' THEN
--											zcache(15 downto 0) <= sdata_reg;
--										end if;
--										zcache_fill <= '0';
						when ph15 =>
--										zena <= '0';
--										zvalid <= "1111"; -- Cache now contains valid data
--										Could do this a clock earlier, yes?
						when others =>	null;
					end case;	
			end if;
	end process;		
	
	
-------------------------------------------------------------------------
-- SDRAM Basic
-------------------------------------------------------------------------
	reset_out <= init_done;

	process (sysclk, reset, sdwrite, datain) begin
		IF sdwrite='1' THEN	-- Keep sdram data high impedence if not writing to it.
			sdata <= datain;
		ELSE
			sdata <= "ZZZZZZZZZZZZZZZZ";
		END IF;
		
--   sample SDRAM data
		if rising_edge(sysclk) then
			sdata_reg <= sdata;
		END IF;	
		
		if reset = '0' then
			initstate <= (others => '0');
			init_done <= '0';
			sdram_state <= ph0;
			sdwrite <= '0';
		ELSIF rising_edge(sysclk) THEN
			sdwrite <= '0';
			

--                          (sync)
-- Phase     :  0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15
-- sysclk    :/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__

-- _RAS      :            \_____/
-- _CAS      :           (\auto/)           \_____/

-- SDWrite   :________________________/                 \_________________________________________

			case sdram_state is	--LATENCY=3
				when ph0 =>	
							sdram_state <= ph1;
				when ph1 =>	
							sdram_state <= ph2;
				when ph2 =>
							sdram_state <= ph3;
--								enaRDreg <= '1';
				when ph3 =>
							sdram_state <= ph4;
				when ph4 =>	sdram_state <= ph5;
							sdwrite <= '1';
				when ph5 => sdram_state <= ph6;
							sdwrite <= '1';
				when ph6 =>	sdram_state <= ph7;
							sdwrite <= '1';
--							enaWRreg <= '1';
--							ena7RDreg <= '1';
				when ph7 =>	sdram_state <= ph8;
				when ph8 =>	sdram_state <= ph9;
				when ph9 =>	sdram_state <= ph10;
				when ph10 => sdram_state <= ph11;
--							enaRDreg <= '1';
				when ph11 => sdram_state <= ph12;
				when ph12 => sdram_state <= ph13;
				when ph13 => sdram_state <= ph14;
				when ph14 => sdram_state <= ph15;
--							enaWRreg <= '1';
--							ena7WRreg <= '1';
				when ph15 => sdram_state <= ph0;
						if initstate /= "1111" THEN -- 16 complete phase cycles before we allow the rest of the design to come out of reset.
							initstate <= initstate+1;
						else
							init_done <='1';	
						end if;
				when others => sdram_state <= ph0;
			end case;	
		END IF;	
	end process;		


	
	process (sysclk, initstate, datain, init_done, casaddr, refreshcycle) begin

		if (sysclk'event and sysclk='1') THEN -- rising edge
--		ba <= Addr(22 downto 21);
			sd_cs <='1';
			sd_ras <= '1';
			sd_cas <= '1';
			sd_we <= '1';
			sdaddr <= "XXXXXXXXXXXX";
			ba <= "00";
			dqm <= "00";  -- safe defaults for everything...
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
							sdaddr <= "001000110010"; --BURST=4 LATENCY=3
--							sdaddr <= "001000110000"; --noBURST LATENCY=3
						when others =>	null;	--NOP
					end case;
				END IF;
			else		

			
-- We have 8 megabytes to play with, addressed with bits 22 downto 0
-- bits 22 and 21 are used as bank select
-- bits 20 downto 9 are the row address, set in phase 2.
-- bits 23, 8 downto 1

-- Time slot control					
				-- Phase 1: figure out which port to service.
				if sdram_state=ph1 then
					if wr1='0' and sdram_port/=port1 then
						sdram_port<=port1;
					else
						refreshcycle <= not refreshcycle;
--						if refreshcycle='1' then
--							sdram_port<=refresh;
--						else
							sdram_port<=port0;
--						end if;
					end if;
				end if;
				-- Phase 2: set defaults and set chip select in temp registers.			
				if sdram_state=ph2 THEN
					cas_sd_cs <= '0';  -- Only the lowest bit has any significance...
					cas_sd_ras <= '1';
					cas_sd_cas <= '1';
					cas_sd_we <= '1';

					sd_cs <= '0'; --ACTIVE
					sd_ras <= '0';
					case sdram_port is
						when refresh =>
							sd_ras <= '0';
							sd_cas <= '0'; --AUTOREFRESH
						when port0 =>
							sdaddr <= Addr0(20 downto 9);
							ba <= Addr0(22 downto 21);
							cas_dqm <= wrU0& wrL0;
							casaddr <= Addr0;-- (23 downto 3) & "000"; -- read whole cache line in burst mode.
							datain <= datawr0;
							cas_sd_cas <= '0';
							cas_sd_we <= wr0;
						when port1 =>
							sdaddr <= Addr1(20 downto 9);
							ba <= Addr1(22 downto 21);
							cas_dqm <= wrU1& wrL1;
							casaddr <= Addr1;-- (23 downto 3) & "000"; -- read whole cache line in burst mode.
							datain <= datawr1;
							cas_sd_cas <= '0';
							cas_sd_we <= wr1;
						when others =>
							null;
					end case;
				END IF;
				-- Phase 5: set column address strobe
				if sdram_state=ph5 then
					-- Why do we fold bit 23 in here? That would give us 9 bits of column address, but we only have 8?
--					sdaddr <=  '0' & '1' & '0' & casaddr(23)&casaddr(8 downto 1);--auto precharge
					sdaddr <=  "0100" & casaddr(8 downto 1);--auto precharge
					ba <= casaddr(22 downto 21);
					sd_cs <= cas_sd_cs; 
					IF cas_sd_we='0' THEN
						dqm <= cas_dqm;
					END IF;
					sd_ras <= cas_sd_ras;
					sd_cas <= cas_sd_cas;
					sd_we  <= cas_sd_we;
				END IF;

				dtack0<='1';
				dtack1<='1';
				if sdram_state=ph15 then
					case sdram_port is
						when port0 =>
							dtack0<='0';
						when port1 =>
							dtack1<='0';
						when others =>
							null;
					end case;
				end if;
							
			END IF;	
		END IF;	
	END process;		
END;
