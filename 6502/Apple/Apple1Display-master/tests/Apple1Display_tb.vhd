library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity apple1display_tb is
end apple1display_tb;

architecture behavior OF apple1display_tb is
	signal clk: std_logic;
	constant freq: natural := 14_318_180;
	constant period: time := 1 sec / FREQ;
	
	-- watches
	signal sync : std_logic;
	signal luma : std_logic;
	signal dot_rate : std_logic;
	signal char_rate : std_logic;
	signal col_reset : std_logic;
	signal char_column: std_logic_vector(3 downto 0);
	signal char_address : std_logic_vector(8 downto 0);
	signal horz_count_lower: std_logic_vector(3 downto 0);
	signal horz_count_upper: std_logic_vector(3 downto 0);
	signal vert_count_lower: std_logic_vector(3 downto 0);
	signal vert_count_upper: std_logic_vector(3 downto 0);
	signal sync_count: std_logic_vector(3 downto 0);
	signal h_carry, last_h, load_h: std_logic;
	signal v_carry, last: std_logic;
	signal vbl, vbl_i: std_logic;
	signal hbl_i: std_logic;
	signal vert_in: std_logic;
	signal vinh_start, vinh_l: std_logic;
	signal hsync_i, vsynch_i, sync_i: std_logic;
	signal load_char:std_logic;
	signal load_char_delayed:std_logic;
	signal cur_char:std_logic_vector(4 downto 0);
	signal screen_char:std_logic_vector(5 downto 0);
	signal horz_count :std_logic_vector(7 downto 0);
	signal vert_count :std_logic_vector(7 downto 0);
	signal line_clock:std_logic;
	signal line7:std_logic;
	signal cl:std_logic;
	signal mem0:std_logic;	
	signal rd :std_logic_vector(7 downto 0);
	signal da:std_logic := '0';
	signal rda_i:std_logic := '1';
	
begin
	
	dot_rate <= <<signal .apple1display_tb.dut.dot_rate : std_logic>>;
	char_rate <= <<signal .apple1display_tb.dut.char_rate: std_logic>>;
	col_reset <= <<signal .apple1display_tb.dut.col_reset: std_logic>>;
	char_column <= <<signal .apple1display_tb.dut.char_column: std_logic_vector(3 downto 0)>>;
	char_address <= <<signal .apple1display_tb.dut.char_address: std_logic_vector(8 downto 0)>>;
	horz_count_lower <= <<signal .apple1display_tb.dut.horz_count_lower: std_logic_vector(3 downto 0)>>;
	horz_count_upper <= <<signal .apple1display_tb.dut.horz_count_upper: std_logic_vector(3 downto 0)>>;
	horz_count <= <<signal .apple1display_tb.dut.horz_count_upper: std_logic_vector(3 downto 0)>> & <<signal .apple1display_tb.dut.horz_count_lower: std_logic_vector(3 downto 0)>>;
	vert_count_lower <= <<signal .apple1display_tb.dut.vert_count_lower: std_logic_vector(3 downto 0)>>;
	vert_count_upper <= <<signal .apple1display_tb.dut.vert_count_upper: std_logic_vector(3 downto 0)>>;
	vert_count <= <<signal .apple1display_tb.dut.vert_count_upper: std_logic_vector(3 downto 0)>> & <<signal .apple1display_tb.dut.vert_count_lower: std_logic_vector(3 downto 0)>>;
	sync_count <= <<signal .apple1display_tb.dut.sync_count: std_logic_vector(3 downto 0)>>;
	h_carry <= <<signal .apple1display_tb.dut.h_carry: std_logic>>;
	last_h <= <<signal .apple1display_tb.dut.last_h: std_logic>>;
	load_h <= <<signal .apple1display_tb.dut.load_h: std_logic>>;
	v_carry <= <<signal .apple1display_tb.dut.v_carry: std_logic>>;
	last <= <<signal .apple1display_tb.dut.last: std_logic>>;
	vbl <= <<signal .apple1display_tb.dut.vbl: std_logic>>;
	vbl_i <= <<signal .apple1display_tb.dut.vbl_i: std_logic>>;
	hbl_i <= <<signal .apple1display_tb.dut.hbl_i: std_logic>>;
	vert_in <= <<signal .apple1display_tb.dut.vert_in: std_logic>>;
	vinh_start <= <<signal .apple1display_tb.dut.vinh_start: std_logic>>;
	vinh_l <= <<signal .apple1display_tb.dut.vinh_l: std_logic>>;
	hsync_i <= <<signal .apple1display_tb.dut.hsync_i: std_logic>>;
	vsynch_i <= <<signal .apple1display_tb.dut.vsynch_i: std_logic>>;
	sync_i <= <<signal .apple1display_tb.dut.sync_i : std_logic>>;
	load_char <= <<signal .apple1display_tb.dut.load_char:std_logic>>;
	cur_char <= <<signal .apple1display_tb.dut.cur_char:std_logic_vector(4 downto 0)>>;
	screen_char <= <<signal .apple1display_tb.dut.screen_char: std_logic_vector(5 downto 0)>>;
	line_clock <= <<signal .apple1display_tb.dut.line_clock: std_logic>>;
	line7 <= <<signal .apple1display_tb.dut.line7: std_logic>>;
	cl <= <<signal .apple1display_tb.dut.cl: std_logic>>;
	mem0 <= <<signal .apple1display_tb.dut.mem0: std_logic>>;
	
	dut: entity work.apple1display
		port map(reset => '0', clk => clk, sync => sync, luma => luma, rd => rd(7 downto 1), da => da, rda_i => rda_i);
	  
	process
	
	-- inject a single master clock pulse
	procedure clock is
    begin
		clk <= '0';
		wait for period/2;
		clk <= '1';
		wait for period/2;
    end procedure clock;
	
	-- two clocks make a dot pulse
	procedure dot_pulse is
    begin
		clock;
		clock;
    end procedure dot_pulse;
	
	-- six dot pulses make a char pulse
	procedure char_pulse is
    begin
		dot_pulse;
		dot_pulse;
		dot_pulse;
		dot_pulse;
		dot_pulse;
		dot_pulse;
    end procedure char_pulse;

	begin
		char_pulse;
		char_pulse;
	end process;
	
end architecture;

