#************************************************************
# THIS IS A WIZARD-GENERATED FILE.                           
#
# Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition
#
#************************************************************

# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.



# Clock constraints

create_clock -name "clk8" -period 125.000ns [get_ports {clk8}] -waveform {0.000 62.500}


# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# create_generated_clock -name spi_clk -source [get_nets {inst|altpll_component|auto_generated|wire_pll1_clk[0]}] -divide_by 2 [get_nets {inst3|sck}]

set sdram_genclk {pllInstance|altpll_component|auto_generated|wire_pll1_clk[1]}

create_generated_clock -name sdram_clk_pin -source $sdram_genclk [get_ports {sdram_clk}]


#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty;

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock sdram_clk_pin -max [expr 5.5 + 0.4] [get_ports *sd_data*]
set_input_delay -clock sdram_clk_pin -min [expr 2.5 + 0.2] [get_ports *sd_data*]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock sdram_clk_pin -max [expr 1.5 ] [get_ports *sd_*]
set_output_delay -clock sdram_clk_pin -min [expr -1.0 ] [get_ports *sd_*]


# Multicycles

#set_multicycle_path -from {sd_data[*]} -to {TG68Test:mytg68test|sdram:mysdram|vga_data[*]} -setup -end 2
#set_multicycle_path -from {sd_data[*]} -to {TG68Test:mytg68test|sdram:mysdram|sdata_reg[*]} -setup -end 2
