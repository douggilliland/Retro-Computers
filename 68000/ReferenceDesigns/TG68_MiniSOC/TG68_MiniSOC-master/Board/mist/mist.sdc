## Generated SDC file "hello_led.out.sdc"

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

## DATE    "Fri Jul 06 23:05:47 2012"

##
## DEVICE  "EP3C25Q240C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_27} -period 37.037 -waveform { 0.000 0.500 } [get_ports {CLOCK_27[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks 
create_generated_clock -name sd1clk_pin -source [get_pins {mypll|altpll_component|auto_generated|pll1|clk[0]}] [get_ports {SDRAM_CLK}]
create_generated_clock -name sysclk -source [get_pins {mypll|altpll_component|auto_generated|pll1|clk[1]}]

#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty;

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock sd1clk_pin -max 5.8 [get_ports SDRAM_DQ*]
set_input_delay -clock sd1clk_pin -min 3.2 [get_ports SDRAM_DQ*]

# Delays for async signals - not necessary, but might as well avoid
# having unconstrained ports in the design
set_input_delay -clock sysclk -min 0.0 [get_ports {UART_RX}]
set_input_delay -clock sysclk -max 0.0 [get_ports {UART_RX}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock sd1clk_pin -max 1.5 [get_ports SDRAM_*]
set_output_delay -clock sd1clk_pin -min -0.8 [get_ports SDRAM_*]
set_output_delay -clock sd1clk_pin -max 0.5 [get_ports SDRAM_CLK]
set_output_delay -clock sd1clk_pin -min 0.5 [get_ports SDRAM_CLK]

# Delays for async signals - not necessary, but might as well avoid
# having unconstrained ports in the design
#set_output_delay -clock sysclk -min 0.0 [get_ports UART_TX]
#set_output_delay -clock sysclk -max 0.0 [get_ports UART_TX]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

# Asynchronous signal, so not important timing-wise
set_false_path -from {*uart|txd} -to {UART_TX}

#**************************************************************
# Set Multicycle Path
#**************************************************************

#set_multicycle_path -from [get_clocks {mypll|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sd2clk_pin}] -setup -end 2
#set_multicycle_path -from [get_clocks {mypll2|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sd2clk_pin}] -setup -end 2

set_multicycle_path -from [get_clocks {sd1clk_pin}] -to [get_clocks {mypll|altpll_component|auto_generated|pll1|clk[1]}] -setup -end 2

set_multicycle_path -through [get_nets {*zpu|Mult0*}] -setup -end 2
set_multicycle_path -through [get_nets {*zpu|Mult0*}] -hold -end 2

#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
