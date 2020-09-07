-- Adapted by AMR from the Chameleon Minimig cfide.vhd file,
-- originally by Tobias Gubener.

-- spi_to_host contains data received from slave device.
-- Busy bit now has a signal of its own.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity spi_interface is
	port (
		sysclk : in std_logic;
		reset : in std_logic;

		-- Host interface
		spiclk_in : in std_logic;	-- Momentary high pulse
		host_to_spi : in std_logic_vector(15 downto 0);
		spi_to_host : out std_logic_vector(15 downto 0);
		wide : in std_logic; -- 16-bit transfer (in only, 0xff will be transmitted for the second byte)
		trigger : in std_logic;  -- Momentary high pulse
		busy : buffer std_logic;

		-- Hardware interface
		miso : in std_logic;
		mosi : out std_logic;
		spiclk_out : out std_logic -- 50% duty cycle
	);
end entity;

architecture rtl of spi_interface is
signal sck : std_logic;
signal sd_out : std_logic_vector(15 downto 0);
signal sd_in_shift : std_logic_vector(15 downto 0);
signal shiftcnt : std_logic_vector(13 downto 0);
begin

-----------------------------------------------------------------
-- SPI-Interface
-----------------------------------------------------------------	
	spiclk_out <= sck;
	mosi <= sd_out(15);
	busy <= shiftcnt(13);
	
	PROCESS (sysclk, reset) BEGIN

		IF reset ='0' THEN 
			shiftcnt <= (OTHERS => '0');
			sck <= '0';
			sd_out<=X"0000";
			spi_to_host(15 downto 0)<=X"0000";
		ELSIF rising_edge(sysclk) then
			IF trigger='1' then
				shiftcnt <= "1000000000" & wide & "111";  -- shift out 8 (or 16) bits, underflow will clear bit 13, mapped to busy
				sd_out <= host_to_spi(7 downto 0) & X"FF";
				sck <= '0';
			ELSE
				IF spiclk_in='1' and busy='1' THEN
					IF sck='1' THEN
						if shiftcnt(12 downto 0)="0000000000000" then
							spi_to_host(15 downto 0)<=sd_in_shift(15 downto 0);
						else
							sd_out <= sd_out(14 downto 0)&sd_out(0);
						END IF;
						sck <='0';
						shiftcnt <= shiftcnt-1;
					ELSE	
						sck <='1';
						sd_in_shift <= sd_in_shift(14 downto 0)&miso;
					END IF;
				END IF;
			END IF;
		end if;
	END PROCESS;

end architecture;
