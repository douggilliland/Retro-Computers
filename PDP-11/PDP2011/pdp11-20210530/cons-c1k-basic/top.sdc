create_clock -period 20.000ns [get_ports clkin]
create_clock -period 100.000ns cpuclk
create_clock -period 40.000ns unibus:pdp11|rh11:rh0|sdspi:sd1|clk 
create_clock -period 40.000ns unibus:pdp11|rk11:rk0|sdspi:sd1|clk 
create_clock -period 40.000ns unibus:pdp11|rl11:rl0|sdspi:sd1|clk 
derive_pll_clocks -use_net_name
derive_clock_uncertainty

set_false_path -from * -to [get_ports {redled*}]
set_false_path -to * -from [get_ports {key0}]
set_false_path -from * -to [get_ports {panel_row*}]
set_false_path -from * -to [get_ports {panel_col*}]
set_false_path -from * -to [get_ports {panel_xled*}]
