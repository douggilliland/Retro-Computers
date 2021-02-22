
architecture main of LEDMatrix is
    signal led_state : machine_state_type; -- RO here
    signal virt_clk  : STD_LOGIC := '0';
    signal led_run   : STD_LOGIC := '0';
    signal led_data  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin



    vclock : entity utils.virtual_clock 
		 PORT MAP (
	--	 RESET => RESET,
		 CLOCK_50 => CLOCK_50, 
		 virt_clk => virt_clk
	 );

    led_matrix : entity work.max7219 PORT MAP (
		  RESET => RESET,
        CLOCK_50 => CLOCK_50, 
		  DIN => LED_DIN, 
		  CS => LED_CS, 
		  CLK => LED_CLK,
        state => led_state, 
		  virt_clk => virt_clk, 
		  input => led_data, 
		  run => led_run
    );

    process(virt_clk, led_state)
--        variable sleep              : unsigned(15 downto 0) := (others => '0');
        variable sleep              : unsigned( 15 downto 0) := (others => '0');
        variable led_addr           : unsigned( 3 downto 0) := (others => '0');
        variable tens, single       : integer := 0;
        variable updating_display,
                 counter_updated    : boolean := false;
			variable segments          : unsigned( 6 downto 0) := (others => '0');
			variable digit             : unsigned( 4 downto 0) := (others => '0');


        procedure update_display(led_addr, digit_data: unsigned) is
        begin
				 case digit_data is
				 when "00000" => segments := "1111110"; -- "0"     
				 when "00001" => segments := "0110000"; -- "1" 
				 when "00010" => segments := "1101101"; -- "2" 
				 when "00011" => segments := "1111001"; -- "3" 
				 when "00100" => segments := "0110011"; -- "4" 
				 when "00101" => segments := "1011011"; -- "5" 
				 when "00110" => segments := "1011111"; -- "6" 
				 when "00111" => segments := "1110000"; -- "7" 
				 when "01000" => segments := "1111111"; -- "8"     
				 when "01001" => segments := "1111011"; -- "9" 
				 when "01010" => segments := "1111101"; -- a
				 when "01011" => segments := "0011111"; -- b
				 when "01100" => segments := "1001110"; -- C
				 when "01101" => segments := "0111101"; -- d
				 when "01110" => segments := "1001111"; -- E
				 when "01111" => segments := "1000111"; -- F
				 when "11111" => segments := "0000000"; -- blank
				 when others  => segments := "0000001"; -- -

				 end case;
            -- set the address and data
            led_data <= "0000"  & led_addr(3) & led_addr(2) & led_addr(1) & led_addr(0) & '0' &segments(6)& segments(5)& segments(4)& segments(3)& segments(2)& segments(1)& segments(0);
        end update_display;

    begin
        -- check if state allows us to do anything
        if rising_edge(virt_clk) then
            -- handle LED Matrix
            if led_state /= ready and led_run = '1' then
                -- reset control signal
                led_run <= '0';
            elsif led_state = ready and led_run = '0' and updating_display then
                updating_display := (led_addr <= 8);
                if updating_display then
                    -- run the update procedure
							case led_addr is
							when "0001" => digit := "00" & unsigned(LED_DIGITS(  2 downto  0 ));
							when "0010" => digit := "00" & unsigned(LED_DIGITS(  5 downto  3 ));
							when "0011" => digit := "00" & unsigned(LED_DIGITS(  8 downto  6 ));
							when "0100" => digit := "00" & unsigned(LED_DIGITS( 11 downto  9 ));
							when "0101" => digit := "00" & unsigned(LED_DIGITS( 14 downto 12 ));
							when "0110" => digit := "00" & unsigned(LED_DIGITS( 17 downto 15 ));
							when "0111" => digit := "00" & unsigned(LED_DIGITS( 20 downto 18 ));
							when "1000" => digit := "0000" & LED_DIGITS( 21 );
							when others => digit := "11111"; -- all segments off
							end case;
							  update_display(led_addr, digit );
                    -- increment the address
                    led_addr := led_addr + 1;
                    -- set control signal
                    led_run <= '1';
                end if;
            elsif led_state = ready and led_run = '0' and not updating_display and counter_updated then
                -- reset led_addr
                led_addr := ( 0 => '1', others => '0');
                -- set display update flag
                updating_display := true;
                -- unset the update flag
--                counter_updated := false;
                counter_updated := true; -- alternative free running display
            end if;

            -- increment the counter
            sleep := sleep + 1;
            if sleep = 0 then
                -- set flag to refresh the display
                counter_updated := true;
            end if;
        end if;
    end process;

end main;