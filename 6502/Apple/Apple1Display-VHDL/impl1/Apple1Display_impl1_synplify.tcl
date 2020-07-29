#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology MACHXO2
set_option -part LCMXO2_7000HC
set_option -package TG144C
set_option -speed_grade -4

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false
set_option -frequency 1
set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
add_file -vhdl {C:/lscc/diamond/3.10_x64/cae_library/synthesis/vhdl/machxo2.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/impl1/source/FleaFPGA_Uno_Top.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/impl1/Apple1Display.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/impl1/source/ntsc.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/impl1/divider.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/impl1/master_clk.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7400.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7402.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7404.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7408.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7410.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7427.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7432.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm7450.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74157.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74160.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74161.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74166.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74174.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm74175.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/2504.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/2519.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/dm2513.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/CharacterRom.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ScreenRom.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ShiftReg40.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/test_entity.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ShiftReg1024.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ScreenRom2.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ScreenRam.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/CursorRam.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/UART_RX.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/ttl/ne555.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/sig2504.vhd}
add_file -vhdl -lib "work" {C:/Dev/Apple1Display/sig2513.vhd}

#-- top module name
set_option -top_module FleaFPGA_Uno_E1

#-- set result format/file last
project -result_file {C:/Dev/Apple1Display/impl1/Apple1Display_impl1.edi}

#-- error message log file
project -log_file {Apple1Display_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
