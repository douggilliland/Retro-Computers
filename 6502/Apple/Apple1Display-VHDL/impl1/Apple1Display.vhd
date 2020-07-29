library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;

entity apple1display is

	port(
		reset: in std_logic;
		clk: in std_logic;
		sync: out std_logic;
		luma: out std_logic;
		rd: in std_logic_vector(7 downto 1);
		da: in std_logic;
		rda_i: out std_logic
	);

end apple1display;
  
architecture behavior of apple1display is

signal dot_rate: std_logic;
signal char_rate: std_logic;
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
signal cur_char:std_logic_vector(4 downto 0);
signal pixels:std_logic_vector(4 downto 0);
signal screen_char:std_logic_vector(5 downto 0);
signal buffer_char_out:std_logic_vector(5 downto 0);
signal buffer_char_out_0, buffer_char_out_1, buffer_char_out_2, buffer_char_out_3, buffer_char_out_4, buffer_char_out_5: std_logic_vector(0 downto 0);
signal buffer_char_in:std_logic_vector(5 downto 0);
signal buffer_char_in_0, buffer_char_in_1, buffer_char_in_2, buffer_char_in_3, buffer_char_in_4, buffer_char_in_5: std_logic_vector(0 downto 0);
signal line_clock: std_logic;
signal line7: std_logic;
signal cl: std_logic;
signal mem0: std_logic;
signal msb: std_logic;
signal line_char: std_logic_vector(5 downto 0);
signal mem_curs_in: std_logic_vector(0 downto 0);
signal mem_curs_out: std_logic_vector(0 downto 0);
signal line_curs: std_logic := '1';
signal next_curs: std_logic := '0';
signal curs: std_logic := '1';
signal clr: std_logic := '0';
signal write_i: std_logic := '1';
signal wc1_i: std_logic := '1';
signal wc2_i: std_logic;
signal char_ready: std_logic;
signal unconnected_0: std_logic;
signal unconnected_1: std_logic;
signal accept_char: std_logic;
signal whitespace: std_logic;
signal cr_1: std_logic;
signal cr_2: std_logic;
signal cr_3: std_logic;
signal cleared_last : std_logic;
signal clear_char : std_logic;
signal clear_screen: std_logic;
signal screen_clear_inhibit : std_logic;
signal line_clear_inhibit : std_logic;
signal clear_curs : std_logic;
signal cursor_flash: std_logic;
signal vert_count_34_i: std_logic;
signal luma_temp: std_logic;
signal cross_talk: std_logic;

signal load_v: std_logic;

begin
	
	cl <= char_column(2);
	char_rate <= char_column(3);
	hbl_i <= horz_count_upper(2);
	vinh_l <= sync_count(1);
	vsynch_i <= sync_count(3);	
	char_address <= screen_char & vert_count_lower(2 downto 0);
	
	vinh_start <= vert_count_34_i and vert_count_upper(1) and vbl; -- diodes
	
	load_v <= vbl_i or wc1_i;
	clear_screen <= clear_char or reset;
	
	-- todo: move these last
	msb <= (not buffer_char_in(5)) xor (cursor_flash and line_curs);
	line_char <= msb & buffer_char_in(4 downto 0);
	--pixels <= cur_char when vbl='0' else "00000";
	pixels <= cur_char;
	
	buffer_char_in <= buffer_char_in_5(0) & buffer_char_in_4(0) & buffer_char_in_3(0) & buffer_char_in_2(0) & buffer_char_in_1(0) & buffer_char_in_0(0);
	buffer_char_out <= buffer_char_out_5(0) & buffer_char_out_4(0) & buffer_char_out_3(0) & buffer_char_out_2(0) & buffer_char_out_1(0) & buffer_char_out_0(0);
	
	-- cross talk
	--luma <= luma_temp or (mem0 and horz(0);
	--luma <= mem0 and horz_count_lower(0);
	
	-- create dot rate
	C13 : entity work.dm74175
	generic map(s0 => '0', s1 => '0', s2 => '0', s3 => '1')
	port map(
		cp => clk,
		mr => '1',
		d0=>dot_rate, q0 => open, q0_i=>dot_rate,
		d1=>sync_i, q1 => open, q1_i=>sync,
		d2=>line_curs, q2 => open, q2_i=>next_curs,
		d3=>mem_curs_out(0), q3 => open, q3_i=>curs
	);
	
	-- create char rate
	D11 : entity work.dm74161
	port map(
		clk => dot_rate,
		clr_l => '1',
		load_l => char_rate,
		cet => char_rate,
		cep => char_rate,
		d3=>'1', d2=>'0', d1=>'1', d0=>'0',
		q3=>char_column(3), q2=>char_column(2), q1=>char_column(1), q0=>char_column(0),
		carry => col_reset
	);
	
	-- horz counter
	
	D6 : entity work.dm74160
	port map(
		clk => char_rate,
		clr_l => '1',
		load_l => load_h,
		cet => '1',
		cep => '1',
		d3=>'0', d2=>horz_count_upper(3), d1=>'0', d0=>horz_count_upper(3),
		q3=>horz_count_lower(3), q2=>horz_count_lower(2), q1=>horz_count_lower(1), q0=>horz_count_lower(0),
		carry => h_carry
	);
	
	D7 : entity work.dm74161
	port map(
		clk => char_rate,
		clr_l => '1',
		load_l => load_h,
		cet => h_carry,
		cep => h_carry,
		d3=>horz_count_upper(3), d2=>'0', d1=>'0', d0=>horz_count_upper(3),
		q3=>horz_count_upper(3), q2=>horz_count_upper(2), q1=>horz_count_upper(1), q0=>horz_count_upper(0),
		carry => last_h
	);
	
	-- vert counter
	
	D8 : entity work.dm74161
	port map(
		clk => char_rate,
		clr_l => horz_count_upper(3),
		load_l => load_v,
		cet => last_h,
		cep => vinh_l,
		d3=>vert_in, d2=>vert_in, d1=>vert_in, d0=>vert_in,
		q3=>vert_count_lower(3), q2=>vert_count_lower(2), q1=>vert_count_lower(1), q0=>vert_count_lower(0),
		carry => v_carry
	);
	
	D9 : entity work.dm74161
	port map(
		clk => char_rate,
		clr_l => horz_count_upper(3),
		load_l => load_v,
		cet => v_carry,
		cep => vinh_l,
		d3=>vert_in, d2=>'0', d1=>vert_in, d0=>vert_in,
		q3=>vert_count_upper(3), q2=>vert_count_upper(2), q1=>vert_count_upper(1), q0=>vert_count_upper(0),
		carry => last
	);
	
	-- sync and vert inhibit
	
	
	D15: entity work.dm74161
	port map(
		clk => char_rate,
		clr_l => '1',
		load_l => vinh_start,
		cet => last_h,
		cep => last_h,
		d3=>'1', d2=>'0', d1=>'1', d0=>'0',
		q3=>sync_count(3), q2=>sync_count(2), q1=>sync_count(1), q0=>sync_count(0)
	);
	
	
	D2 : entity sig2513
	port map(
		Address => char_address,
		OutClock => clk,
		OutClockEn => '1', 
        Reset => '0',
		Q => cur_char
	);
	
	D1 : entity work.dm74166
	port map(
		clk1 => dot_rate,
		clk2 => '0',
		input => '0',
		ld => load_char,
		clr_l => '1',
		a=>'0', b=>'0', c=>'0', d=>pixels(0), e=>pixels(1), f=>pixels(2), g=>pixels(3), h=>pixels(4),
		output => luma_temp
	);
	
	-- glue logic
	
	-- DM7402 Quad 2-Input NOR Gates
	C10 : entity work.dm7402
	port map(
		A3 => horz_count_lower(3), B3 => vbl_i, Y3 => vert_in,
		A4 => vert_count_upper(0), B4 => vert_count_lower(3), Y4 => vert_count_34_i
	);
	
	-- DM7404 Hex Inverting Gates
	D12 : entity work.dm7404
	port map(
		A1 => cr_3, Y1 => clear_char,
		A4 => vbl_i, Y4 => vbl,
		A6 => last_h, Y6 => load_h
	);
	
	-- DM7400 Quad 2-Input NAND Gate
	D10 : entity work.dm7400
	port map(
		A1 => cl, B1 => hbl_i, Y1 => line_clock,
		A2 => hbl_i, B2 => col_reset, Y2 => load_char,
		A3 => vert_count_upper(3), B3 => vert_count_upper(2), Y3 => vbl_i
	);
	
	-- line buffer
	C3 : entity work.ttl2519
	port map(
		cl => line_clock,
		rc => line7,
		i => line_char,
		q => screen_char
	);
	
	-- screen and cursor buffers and selectors
	
	--ScreenBuffer : entity ScreenRam
	--port map(
		--Din => buffer_char_in,
        --Clock => mem0,
        --ClockEn => '1',
        --Reset => '0',
        --Q => buffer_char_out
	--);
	D5a : entity sig2504 port map(Din => buffer_char_in_0, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_0);
	D5b : entity sig2504 port map(Din => buffer_char_in_1, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_1);
	D4a : entity sig2504 port map(Din => buffer_char_in_2, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_2);
	D4b : entity sig2504 port map(Din => buffer_char_in_3, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_3);
	D14a : entity sig2504 port map(Din => buffer_char_in_4, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_4);
	D14b : entity sig2504 port map(Din => buffer_char_in_5, Clock => mem0, ClockEn => '1', Reset => '0', Q => buffer_char_out_5);
	
	--CursorBuffer : entity CursorRam
	--port map(
		--Din => mem_curs_in,
        --Clock => mem0,
        --ClockEn => '1',
        --Reset => '0',
		--Q => mem_curs_out
	--);
	
	C11b : entity sig2504
	port map(
		Din => mem_curs_in,
        Clock => mem0,
        ClockEn => '1',
        Reset => '0',
		Q => mem_curs_out
	);
	
	C4: entity dm74157
	port map(
		enable => clr,
		sel => write_i,
		A => rd(4 downto 1),
		B => buffer_char_out(3 downto 0),
		Y => buffer_char_in(3 downto 0)
	);
	
	C14: entity dm74157
	port map(
		enable => clr,
		sel => write_i,
		A(0) => rd(5),
		A(1) => '0',
		A(2) => rd(7),
		A(3) => '0',
		B(0) => buffer_char_out(4),
		B(1) => '0',
		B(2) => buffer_char_out(5),
		B(3) => curs,
		Y(0) => buffer_char_in(4),
		Y(1) => unconnected_0,
		Y(2) => buffer_char_in(5),
		Y(3) => line_curs
	);
	
	-- cursor latches
	
	C7: entity dm74174
	generic map(s0 => '0', s1 => '0', s2 => '1', s3 => '0', s4 => '0', s5 => '1')
	port map(
		cp => mem0,
		mr => '1',
		d0 => last,
		d1 => da,
		d2 => accept_char,
		d3 => clear_char,
		d4 => last_h,
		d5 => wc1_i,
		q0 => screen_clear_inhibit,
		q1 => char_ready,
		q2 => rda_i,
		q3 => cleared_last,
		q4 => line_clear_inhibit,
		q5 => wc2_i
	);
	
	-- cursor flash
	
	D13: entity ne555
	port map(clk_in => vbl, clk_out => cursor_flash);
	
	-- cursor gates
	
	C5: entity dm7427
	port map(
		A1 => vert_in, B1 => line_clock, C1 => line7, Y1 => mem0,
		A2 => rd(7), B2 => rd(6), C2 => accept_char, Y2 => whitespace,
		A3 => cr_1, B3 => rd(5), C3 => rd(2), Y3 => cr_2
	);
	
	C6: entity dm7410
	port map(
		-- gate 1 not used
		A2 => curs, B2 => char_ready, C2 => char_ready, Y2 => accept_char,
		A3 => rd(3), B3 => rd(4), C3 => rd(1), Y3 => cr_1
	);
	
	C8: entity dm7450
	port map(
		A1 => clear_screen, B1 => screen_clear_inhibit, C1 => clear_char, D1 => line_clear_inhibit, Y1 => clear_curs,
		A2 => whitespace, B2 => cr_2, C2 => wc2_i, D2 => cleared_last, Y2 => cr_3
	);
	
	C12: entity dm7408
	port map(
		--A1 => flash_counter(5), B1 => line_curs, Y1 => 
		A2 => write_i, B2 => clear_curs, Y2 => wc1_i,
		A3 => next_curs, B3 => wc2_i, Y3 => mem_curs_in(0)
	);
	
	C9: entity dm7432
	port map(
		A1 => vbl, B1 => clear_screen, Y1 => clr,
		A2 => horz_count_upper(2), B2 => horz_count_upper(0), Y2 => hsync_i,
		A4 => whitespace, B4 => accept_char, Y4 => write_i
	);
	
	B2: entity dm7410
	port map(
		A2 => vert_count_lower(0), B2 => vert_count_lower(1), C2 => vert_count_lower(2), Y2 => line7
	);
	
	C15: entity dm7400
	port map(
		A3 => vsynch_i, B3 => hsync_i, Y3 => sync_i
	);
	
	luma <= '1' when (mem0='1') and (horz_count_lower(0)='1') and (char_column="1111")
		else luma_temp;
	
end architecture;
