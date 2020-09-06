--IP Functional Simulation Model
--VERSION_BEGIN 20.1 cbx_mgl 2020:06:05:12:11:10:SJ cbx_simgen 2020:06:05:12:04:51:SJ  VERSION_END


-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Intel disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY altera_lnsim;
 USE altera_lnsim.altera_lnsim_components.all;

--synthesis_resources = altera_pll 1 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  Clock_50to100_Dual IS 
	 PORT 
	 ( 
		 locked	:	OUT  STD_LOGIC;
		 outclk_0	:	OUT  STD_LOGIC;
		 outclk_1	:	OUT  STD_LOGIC;
		 outclk_2	:	OUT  STD_LOGIC;
		 refclk	:	IN  STD_LOGIC;
		 rst	:	IN  STD_LOGIC
	 ); 
 END Clock_50to100_Dual;

 ARCHITECTURE RTL OF Clock_50to100_Dual IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_gnd	:	STD_LOGIC;
	 SIGNAL  wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_locked	:	STD_LOGIC;
	 SIGNAL  wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_outclk	:	STD_LOGIC_VECTOR (2 DOWNTO 0);
 BEGIN

	wire_gnd <= '0';
	locked <= wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_locked;
	outclk_0 <= wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_outclk(0);
	outclk_1 <= wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_outclk(1);
	outclk_2 <= wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_outclk(2);
	clock_50to100_dual_altera_pll_altera_pll_i_1557 :  altera_pll
	  GENERIC MAP (
		c_cnt_bypass_en0 => "false",
		c_cnt_bypass_en1 => "false",
		c_cnt_bypass_en10 => "false",
		c_cnt_bypass_en11 => "false",
		c_cnt_bypass_en12 => "false",
		c_cnt_bypass_en13 => "false",
		c_cnt_bypass_en14 => "false",
		c_cnt_bypass_en15 => "false",
		c_cnt_bypass_en16 => "false",
		c_cnt_bypass_en17 => "false",
		c_cnt_bypass_en2 => "false",
		c_cnt_bypass_en3 => "false",
		c_cnt_bypass_en4 => "false",
		c_cnt_bypass_en5 => "false",
		c_cnt_bypass_en6 => "false",
		c_cnt_bypass_en7 => "false",
		c_cnt_bypass_en8 => "false",
		c_cnt_bypass_en9 => "false",
		c_cnt_hi_div0 => 1,
		c_cnt_hi_div1 => 1,
		c_cnt_hi_div10 => 1,
		c_cnt_hi_div11 => 1,
		c_cnt_hi_div12 => 1,
		c_cnt_hi_div13 => 1,
		c_cnt_hi_div14 => 1,
		c_cnt_hi_div15 => 1,
		c_cnt_hi_div16 => 1,
		c_cnt_hi_div17 => 1,
		c_cnt_hi_div2 => 1,
		c_cnt_hi_div3 => 1,
		c_cnt_hi_div4 => 1,
		c_cnt_hi_div5 => 1,
		c_cnt_hi_div6 => 1,
		c_cnt_hi_div7 => 1,
		c_cnt_hi_div8 => 1,
		c_cnt_hi_div9 => 1,
		c_cnt_in_src0 => "ph_mux_clk",
		c_cnt_in_src1 => "ph_mux_clk",
		c_cnt_in_src10 => "ph_mux_clk",
		c_cnt_in_src11 => "ph_mux_clk",
		c_cnt_in_src12 => "ph_mux_clk",
		c_cnt_in_src13 => "ph_mux_clk",
		c_cnt_in_src14 => "ph_mux_clk",
		c_cnt_in_src15 => "ph_mux_clk",
		c_cnt_in_src16 => "ph_mux_clk",
		c_cnt_in_src17 => "ph_mux_clk",
		c_cnt_in_src2 => "ph_mux_clk",
		c_cnt_in_src3 => "ph_mux_clk",
		c_cnt_in_src4 => "ph_mux_clk",
		c_cnt_in_src5 => "ph_mux_clk",
		c_cnt_in_src6 => "ph_mux_clk",
		c_cnt_in_src7 => "ph_mux_clk",
		c_cnt_in_src8 => "ph_mux_clk",
		c_cnt_in_src9 => "ph_mux_clk",
		c_cnt_lo_div0 => 1,
		c_cnt_lo_div1 => 1,
		c_cnt_lo_div10 => 1,
		c_cnt_lo_div11 => 1,
		c_cnt_lo_div12 => 1,
		c_cnt_lo_div13 => 1,
		c_cnt_lo_div14 => 1,
		c_cnt_lo_div15 => 1,
		c_cnt_lo_div16 => 1,
		c_cnt_lo_div17 => 1,
		c_cnt_lo_div2 => 1,
		c_cnt_lo_div3 => 1,
		c_cnt_lo_div4 => 1,
		c_cnt_lo_div5 => 1,
		c_cnt_lo_div6 => 1,
		c_cnt_lo_div7 => 1,
		c_cnt_lo_div8 => 1,
		c_cnt_lo_div9 => 1,
		c_cnt_odd_div_duty_en0 => "false",
		c_cnt_odd_div_duty_en1 => "false",
		c_cnt_odd_div_duty_en10 => "false",
		c_cnt_odd_div_duty_en11 => "false",
		c_cnt_odd_div_duty_en12 => "false",
		c_cnt_odd_div_duty_en13 => "false",
		c_cnt_odd_div_duty_en14 => "false",
		c_cnt_odd_div_duty_en15 => "false",
		c_cnt_odd_div_duty_en16 => "false",
		c_cnt_odd_div_duty_en17 => "false",
		c_cnt_odd_div_duty_en2 => "false",
		c_cnt_odd_div_duty_en3 => "false",
		c_cnt_odd_div_duty_en4 => "false",
		c_cnt_odd_div_duty_en5 => "false",
		c_cnt_odd_div_duty_en6 => "false",
		c_cnt_odd_div_duty_en7 => "false",
		c_cnt_odd_div_duty_en8 => "false",
		c_cnt_odd_div_duty_en9 => "false",
		c_cnt_ph_mux_prst0 => 0,
		c_cnt_ph_mux_prst1 => 0,
		c_cnt_ph_mux_prst10 => 0,
		c_cnt_ph_mux_prst11 => 0,
		c_cnt_ph_mux_prst12 => 0,
		c_cnt_ph_mux_prst13 => 0,
		c_cnt_ph_mux_prst14 => 0,
		c_cnt_ph_mux_prst15 => 0,
		c_cnt_ph_mux_prst16 => 0,
		c_cnt_ph_mux_prst17 => 0,
		c_cnt_ph_mux_prst2 => 0,
		c_cnt_ph_mux_prst3 => 0,
		c_cnt_ph_mux_prst4 => 0,
		c_cnt_ph_mux_prst5 => 0,
		c_cnt_ph_mux_prst6 => 0,
		c_cnt_ph_mux_prst7 => 0,
		c_cnt_ph_mux_prst8 => 0,
		c_cnt_ph_mux_prst9 => 0,
		c_cnt_prst0 => 1,
		c_cnt_prst1 => 1,
		c_cnt_prst10 => 1,
		c_cnt_prst11 => 1,
		c_cnt_prst12 => 1,
		c_cnt_prst13 => 1,
		c_cnt_prst14 => 1,
		c_cnt_prst15 => 1,
		c_cnt_prst16 => 1,
		c_cnt_prst17 => 1,
		c_cnt_prst2 => 1,
		c_cnt_prst3 => 1,
		c_cnt_prst4 => 1,
		c_cnt_prst5 => 1,
		c_cnt_prst6 => 1,
		c_cnt_prst7 => 1,
		c_cnt_prst8 => 1,
		c_cnt_prst9 => 1,
		clock_name_0 => "UNUSED",
		clock_name_1 => "UNUSED",
		clock_name_2 => "UNUSED",
		clock_name_3 => "UNUSED",
		clock_name_4 => "UNUSED",
		clock_name_5 => "UNUSED",
		clock_name_6 => "UNUSED",
		clock_name_7 => "UNUSED",
		clock_name_8 => "UNUSED",
		clock_name_global_0 => "false",
		clock_name_global_1 => "false",
		clock_name_global_2 => "false",
		clock_name_global_3 => "false",
		clock_name_global_4 => "false",
		clock_name_global_5 => "false",
		clock_name_global_6 => "false",
		clock_name_global_7 => "false",
		clock_name_global_8 => "false",
		data_rate => 0,
		deserialization_factor => 4,
		duty_cycle0 => 50,
		duty_cycle1 => 50,
		duty_cycle10 => 50,
		duty_cycle11 => 50,
		duty_cycle12 => 50,
		duty_cycle13 => 50,
		duty_cycle14 => 50,
		duty_cycle15 => 50,
		duty_cycle16 => 50,
		duty_cycle17 => 50,
		duty_cycle2 => 50,
		duty_cycle3 => 50,
		duty_cycle4 => 50,
		duty_cycle5 => 50,
		duty_cycle6 => 50,
		duty_cycle7 => 50,
		duty_cycle8 => 50,
		duty_cycle9 => 50,
		fractional_vco_multiplier => "false",
		m_cnt_bypass_en => "false",
		m_cnt_hi_div => 1,
		m_cnt_lo_div => 1,
		m_cnt_odd_div_duty_en => "false",
		mimic_fbclk_type => "gclk",
		n_cnt_bypass_en => "false",
		n_cnt_hi_div => 1,
		n_cnt_lo_div => 1,
		n_cnt_odd_div_duty_en => "false",
		number_of_clocks => 3,
		operation_mode => "direct",
		output_clock_frequency0 => "100.000000 MHz",
		output_clock_frequency1 => "100.000000 MHz",
		output_clock_frequency10 => "0 MHz",
		output_clock_frequency11 => "0 MHz",
		output_clock_frequency12 => "0 MHz",
		output_clock_frequency13 => "0 MHz",
		output_clock_frequency14 => "0 MHz",
		output_clock_frequency15 => "0 MHz",
		output_clock_frequency16 => "0 MHz",
		output_clock_frequency17 => "0 MHz",
		output_clock_frequency2 => "25.000000 MHz",
		output_clock_frequency3 => "0 MHz",
		output_clock_frequency4 => "0 MHz",
		output_clock_frequency5 => "0 MHz",
		output_clock_frequency6 => "0 MHz",
		output_clock_frequency7 => "0 MHz",
		output_clock_frequency8 => "0 MHz",
		output_clock_frequency9 => "0 MHz",
		phase_shift0 => "0 ps",
		phase_shift1 => "0 ps",
		phase_shift10 => "0 ps",
		phase_shift11 => "0 ps",
		phase_shift12 => "0 ps",
		phase_shift13 => "0 ps",
		phase_shift14 => "0 ps",
		phase_shift15 => "0 ps",
		phase_shift16 => "0 ps",
		phase_shift17 => "0 ps",
		phase_shift2 => "0 ps",
		phase_shift3 => "0 ps",
		phase_shift4 => "0 ps",
		phase_shift5 => "0 ps",
		phase_shift6 => "0 ps",
		phase_shift7 => "0 ps",
		phase_shift8 => "0 ps",
		phase_shift9 => "0 ps",
		pll_auto_clk_sw_en => "false",
		pll_bw_sel => "low",
		pll_bwctrl => 0,
		pll_clk_loss_sw_en => "false",
		pll_clk_sw_dly => 0,
		pll_clkin_0_src => "clk_0",
		pll_clkin_1_src => "clk_0",
		pll_cp_current => 0,
		pll_dsm_out_sel => "1st_order",
		pll_extclk_0_cnt_src => "pll_extclk_cnt_src_vss",
		pll_extclk_1_cnt_src => "pll_extclk_cnt_src_vss",
		pll_fbclk_mux_1 => "glb",
		pll_fbclk_mux_2 => "fb_1",
		pll_fractional_cout => 24,
		pll_fractional_division => 1,
		pll_m_cnt_in_src => "ph_mux_clk",
		pll_manu_clk_sw_en => "false",
		pll_output_clk_frequency => "0 MHz",
		pll_slf_rst => "false",
		pll_subtype => "General",
		pll_type => "General",
		pll_vco_div => 1,
		pll_vcoph_div => 1,
		refclk1_frequency => "0 MHz",
		reference_clock_frequency => "50.0 MHz",
		sim_additional_refclk_cycles_to_lock => 0
	  )
	  PORT MAP ( 
		fbclk => wire_gnd,
		locked => wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_locked,
		outclk => wire_clock_50to100_dual_altera_pll_altera_pll_i_1557_outclk,
		refclk => refclk,
		rst => rst
	  );

 END RTL; --Clock_50to100_Dual
--synopsys translate_on
--VALID FILE
