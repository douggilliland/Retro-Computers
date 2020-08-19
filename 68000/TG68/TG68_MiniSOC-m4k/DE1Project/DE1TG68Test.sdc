## Generated SDC file "DE1TG68Test.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition"

## DATE    "Wed Apr 18 18:56:03 2012"

##
## DEVICE  "EP2C20F484C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name CLOCK_50 -period 20 [get_ports {CLOCK_50}]
derive_pll_clocks

#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock { mypll|altpll_component|pll|clk[1] } 2 [get_ports DRAM_DQ*]



#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_DQ*]
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_ADDR*]
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_BA*]
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_LDQM]
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_UDQM]
set_output_delay -clock { mypll|altpll_component|pll|clk[1] } 4 [get_ports DRAM_*_N]

set_output_delay -clock { mypll|altpll_component|pll|clk[0] } 4 [get_ports DRAM_CLK]



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|data_write_tmp[*]} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|data_write_tmp[*]} 4

set_multicycle_path -setup -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|regfile*} 4
set_multicycle_path -hold -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|regfile*} 4
set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|regfile*} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|regfile*} 4

set_multicycle_path -setup -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -hold -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -setup -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -hold -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4

set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|altsyncram:regfile*} 4

set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68K_ALU:ALU|Flags*} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68K_ALU:ALU|Flags*} 4

set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|memaddr_delta*} 4
set_multicycle_path -setup -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|memaddr_delta*} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|memaddr_delta*} 4
set_multicycle_path -hold -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|memaddr_delta*} 4

set_multicycle_path -setup -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68K_ALU:ALU|asl_VFlag} 4
set_multicycle_path -hold -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68K_ALU:ALU|asl_VFlag} 4

set_multicycle_path -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|opcode[*]} -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68_PC[*]} -setup 4
set_multicycle_path -from {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|opcode[*]} -to {TG68Test:myTG68Test|TG68KdotC_Kernel:myTG68|TG68_PC[*]} -hold 4

#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

