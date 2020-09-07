library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

-- LED driver.
-- We have four LEDs fed via a single +3V3 line through a single resistor.
-- The FPGA pins sink current through the LEDs, so to avoid dimming of the LEDs when more than one LED is lit,
-- we PWM the leds, illuminating no more than one at a time.

entity statusleds_pwm is
	port(
		clk : in std_logic;
		power_led : in unsigned(5 downto 0);
		disk_led : in unsigned(5 downto 0);
		net_led : in unsigned(5 downto 0);
		odd_led : in unsigned(5 downto 0);
		leds_out : out std_logic_vector(3 downto 0)
	);
end statusleds_pwm;

architecture rtl of statusleds_pwm is
	signal counter : unsigned(7 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			counter <= counter+1;
			leds_out<="1111";
			case counter(7 downto 6) is
				when "00" =>
					if(counter(5 downto 0)<power_led) then
						leds_out(0)<='0';
					end if;
				when "01" =>
					if(counter(5 downto 0)<disk_led) then
						leds_out(1)<='0';
					end if;
				when "10" =>
					if(counter(5 downto 0)<net_led) then
						leds_out(2)<='0';
					end if;
				when "11" =>
					if(counter(5 downto 0)<odd_led) then
						leds_out(3)<='0';
					end if;
			end case;
		end if;
	end process;
end architecture;