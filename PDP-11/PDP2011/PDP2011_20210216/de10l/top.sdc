create_clock -period 20.000ns [get_ports clkin]
create_clock -period 100.000ns cpuclk
derive_pll_clocks -use_net_name
derive_clock_uncertainty

set_false_path -from * -to [get_ports {redled*}]
set_false_path -from * -to [get_ports {sseg*}]
set_false_path -from * -to [get_ports {sw*}]
set_false_path -from * -to [get_ports {tx*}]
set_false_path -from * -to [get_ports {rx*}]
set_false_path -from * -to [get_ports {panel_col*}]
set_false_path -from * -to [get_ports {panel_row*}]
set_false_path -from * -to [get_ports {panel_xled*}]
