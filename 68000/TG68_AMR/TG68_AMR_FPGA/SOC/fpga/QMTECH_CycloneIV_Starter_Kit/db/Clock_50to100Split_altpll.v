//altpll bandwidth_type="AUTO" CBX_DECLARE_ALL_CONNECTED_PORTS="OFF" clk0_divide_by=1 clk0_duty_cycle=50 clk0_multiply_by=2 clk0_phase_shift="0" clk1_divide_by=1 clk1_duty_cycle=50 clk1_multiply_by=2 clk1_phase_shift="-1000" clk2_divide_by=2 clk2_duty_cycle=50 clk2_multiply_by=1 clk2_phase_shift="0" compensate_clock="CLK0" device_family="Cyclone V" inclk0_input_frequency=20000 intended_device_family="Cyclone III" lpm_hint="CBX_MODULE_PREFIX=Clock_50to100Split" operation_mode="normal" pll_type="AUTO" port_clk0="PORT_USED" port_clk1="PORT_USED" port_clk2="PORT_USED" port_clk3="PORT_UNUSED" port_clk4="PORT_UNUSED" port_clk5="PORT_UNUSED" port_extclk0="PORT_UNUSED" port_extclk1="PORT_UNUSED" port_extclk2="PORT_UNUSED" port_extclk3="PORT_UNUSED" port_inclk1="PORT_UNUSED" port_phasecounterselect="PORT_UNUSED" port_phasedone="PORT_UNUSED" port_scandata="PORT_UNUSED" port_scandataout="PORT_UNUSED" self_reset_on_loss_lock="OFF" width_clock=5 areset clk inclk locked CARRY_CHAIN="MANUAL" CARRY_CHAIN_LENGTH=48
//VERSION_BEGIN 20.1 cbx_altclkbuf 2020:06:05:12:04:51:SJ cbx_altiobuf_bidir 2020:06:05:12:04:51:SJ cbx_altiobuf_in 2020:06:05:12:04:51:SJ cbx_altiobuf_out 2020:06:05:12:04:51:SJ cbx_altpll 2020:06:05:12:04:51:SJ cbx_cycloneii 2020:06:05:12:04:51:SJ cbx_lpm_add_sub 2020:06:05:12:04:51:SJ cbx_lpm_compare 2020:06:05:12:04:51:SJ cbx_lpm_counter 2020:06:05:12:04:51:SJ cbx_lpm_decode 2020:06:05:12:04:51:SJ cbx_lpm_mux 2020:06:05:12:04:51:SJ cbx_mgl 2020:06:05:12:11:10:SJ cbx_nadder 2020:06:05:12:04:51:SJ cbx_stratix 2020:06:05:12:04:51:SJ cbx_stratixii 2020:06:05:12:04:51:SJ cbx_stratixiii 2020:06:05:12:04:51:SJ cbx_stratixv 2020:06:05:12:04:51:SJ cbx_util_mgl 2020:06:05:12:04:51:SJ  VERSION_END
//CBXI_INSTANCE_NAME="C3BoardToplevel_Clock_50to100Split_mypll_altpll_altpll_component"
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2020  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and any partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details, at
//  https://fpgasoftware.intel.com/eula.



//synthesis_resources = generic_pll 3 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  Clock_50to100Split_altpll
	( 
	areset,
	clk,
	fbout,
	inclk,
	locked) /* synthesis synthesis_clearbox=1 */;
	input   areset;
	output   [4:0]  clk;
	output   fbout;
	input   [1:0]  inclk;
	output   locked;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   areset;
	tri0   [1:0]  inclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  wire_generic_pll1_fboutclk;
	wire  wire_generic_pll1_locked;
	wire  wire_generic_pll1_outclk;
	wire  wire_generic_pll2_outclk;
	wire  wire_generic_pll3_outclk;
	wire  fb_clkin;

	generic_pll   generic_pll1
	( 
	.fbclk(fb_clkin),
	.fboutclk(wire_generic_pll1_fboutclk),
	.locked(wire_generic_pll1_locked),
	.outclk(wire_generic_pll1_outclk),
	.refclk(inclk[0]),
	.rst(areset));
	defparam
		generic_pll1.duty_cycle = 50,
		generic_pll1.output_clock_frequency = "10000 ps",
		generic_pll1.phase_shift = "0 ps",
		generic_pll1.reference_clock_frequency = "20000 ps",
		generic_pll1.lpm_type = "generic_pll";
	generic_pll   generic_pll2
	( 
	.fbclk(fb_clkin),
	.fboutclk(),
	.locked(),
	.outclk(wire_generic_pll2_outclk),
	.refclk(inclk[0]),
	.rst(areset));
	defparam
		generic_pll2.duty_cycle = 50,
		generic_pll2.output_clock_frequency = "10000 ps",
		generic_pll2.phase_shift = "9000 ps",
		generic_pll2.reference_clock_frequency = "20000 ps",
		generic_pll2.lpm_type = "generic_pll";
	generic_pll   generic_pll3
	( 
	.fbclk(fb_clkin),
	.fboutclk(),
	.locked(),
	.outclk(wire_generic_pll3_outclk),
	.refclk(inclk[0]),
	.rst(areset));
	defparam
		generic_pll3.duty_cycle = 50,
		generic_pll3.output_clock_frequency = "40000 ps",
		generic_pll3.phase_shift = "0 ps",
		generic_pll3.reference_clock_frequency = "20000 ps",
		generic_pll3.lpm_type = "generic_pll";
	assign
		clk = {{2{1'b0}}, wire_generic_pll3_outclk, wire_generic_pll2_outclk, wire_generic_pll1_outclk},
		fb_clkin = wire_generic_pll1_fboutclk,
		fbout = fb_clkin,
		locked = wire_generic_pll1_locked;
endmodule //Clock_50to100Split_altpll
//VALID FILE
