create_clock -period 20.000ns [get_ports clkin]
create_clock -period 100.000ns cpuclk
create_clock -period 100.000ns [get_ports dram_clk]
derive_pll_clocks -use_net_name
derive_clock_uncertainty

set_false_path -from * -to [get_ports {greenled*}]
set_false_path -to * -from [get_ports {key0}]
set_false_path -to * -from [get_ports {key1}]
set_false_path -from * -to [get_ports {panel_col*}]
set_false_path -from * -to [get_ports {panel_xled*}]
