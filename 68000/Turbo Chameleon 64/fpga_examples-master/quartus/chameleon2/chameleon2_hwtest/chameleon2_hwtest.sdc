set_time_format -unit ns -decimal_places 3
create_clock -period 20.000 [get_ports {clk50m}]
derive_pll_clocks
derive_clock_uncertainty

create_generated_clock -name ram_clk_pin -source [get_pins {\pll_blk:pll_inst|altpll_component|auto_generated|pll1|clk[3]}] [get_ports {ram_clk}]

#set_output_delay -clock {\pll_blk:pll_inst|altpll_component|auto_generated|pll1|clk[3]} 0.000 ram_clk
set_output_delay -clock ram_clk_pin -max  1.000 ram_a[*]
set_output_delay -clock ram_clk_pin -min -1.000 ram_a[*]

set_output_delay -clock ram_clk_pin -max  1.000 ram_we
set_output_delay -clock ram_clk_pin -min -1.000 ram_we

set_output_delay -clock ram_clk_pin -max  1.000 ram_ras
set_output_delay -clock ram_clk_pin -min -1.000 ram_ras

set_output_delay -clock ram_clk_pin -max  1.000 ram_cas
set_output_delay -clock ram_clk_pin -min -1.000 ram_cas

set_output_delay -clock ram_clk_pin -max  1.000 ram_ba[*]
set_output_delay -clock ram_clk_pin -min -1.000 ram_ba[*]

set_output_delay -clock ram_clk_pin -max  1.000 ram_ldqm
set_output_delay -clock ram_clk_pin -min -1.000 ram_ldqm

set_output_delay -clock ram_clk_pin -max  1.000 ram_udqm
set_output_delay -clock ram_clk_pin -min -1.000 ram_udqm

set_output_delay -clock ram_clk_pin -max  1.000 ram_d[*]
set_output_delay -clock ram_clk_pin -min -1.000 ram_d[*]

set_input_delay -clock ram_clk_pin -min 1.500 ram_d[*]
set_input_delay -clock ram_clk_pin -max 3.000 ram_d[*]

set_multicycle_path -from [get_clocks {ram_clk_pin}] -to [get_clocks {\pll_blk:pll_inst|altpll_component|auto_generated|pll1|clk[2]}] -setup -end 2
