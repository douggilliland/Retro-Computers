architecture SPI of max7219 is
    signal data   : STD_LOGIC_VECTOR(15 downto 0);
    signal enable : STD_LOGIC := '0';

    subtype cfgLine is std_logic_vector(15 downto 0);
    type cfgSet is array(natural range <>) of cfgLine;
begin
    spi_driver : entity work.spi_master GENERIC MAP (slaves => 1, d_width => 16) PORT MAP (
        clock => CLOCK_50, 
		  enable => enable, 
--		  busy => CS, 
		  n_busy => CS, 
		  cont => '0',
--        reset_n => '1', 
        reset_n => RESET, 
		  cpol => '0', 
		  cpha => '0', 
		  addr => 0,
        tx_data => 
		  data, miso => 'Z', 
		  mosi => DIN, 
		  sclk => CLK, 
		  clk_div => 5
    );

    process(virt_clk, state)
        variable setup_step : integer := 0;
        variable last_state : machine_state_type;
        constant setup_steps : cfgSet := (
            -- disable display test
            (8 => '1', 9 => '1', 10 => '1', 11 => '1', others => '0'),
            -- reduce intensivity to 8
            (3 => '1', 2 => '0', 9 => '1', 11 => '1', others => '0'),
            -- enable scan for digit '0'
            (0 => '1', 1 => '1', 2 => '1', 8 => '1', 9 => '1', 11 => '1', others => '0'),
            -- disable decode
            (8 => '1', 11 => '1', others => '0'),
            -- clear screen (8 rows)
            (8 => '1', 9 => '0', 10 => '0', others => '0'),
            (8 => '0', 9 => '1', 10 => '0', others => '0'),
            (8 => '1', 9 => '1', 10 => '0', others => '0'),
            (8 => '0', 9 => '0', 10 => '1', others => '0'),
            (8 => '1', 9 => '0', 10 => '1', others => '0'),
            (8 => '0', 9 => '1', 10 => '1', others => '0'),
            (8 => '1', 9 => '1', 10 => '1', others => '0'),
            (8 => '0', 9 => '0', 10 => '0', 11 => '1', others => '0'),
            -- disable shutdown
            (0 => '1', 10 => '1', 11 => '1', others => '0')
        );

        function run_setup(setup_step : integer) return boolean is
        begin
            return (setup_step < setup_steps'length);
        end run_setup;

        function get_next_setup_step(step : integer) return cfgLine is
        begin
            return setup_steps(step);
        end get_next_setup_step;
    begin
        if rising_edge(virt_clk) then
				if(RESET = '0') then
					last_state := initialize;
					state <= busy;
					setup_step := 0;
					enable <= '1';
				end if;
            CASE state IS
                WHEN ready =>
                    last_state := ready;
                    if run = '1' then
                        state <= execute;
                    end if;
                WHEN busy =>
                    enable <= '0';
                    state <= last_state;
                WHEN initialize =>
                    last_state := initialize;
                    if run_setup(setup_step) then
                        data <= get_next_setup_step(setup_step);
                        state <= busy;
                        enable <= '1';
                        setup_step := setup_step + 1;
                    else
                        state <= ready;
                    end if;
                WHEN execute =>
                    data <= input;
                    state <= busy;
                    enable <= '1';
            end CASE;
        end if;
    end process;
end SPI;
