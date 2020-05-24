setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Dev/Apple1Display/simulation/simulation.adf"]} { 
	design create simulation "C:/Dev/Apple1Display"
  set newDesign 1
}
design open "C:/Dev/Apple1Display/simulation"
cd "C:/Dev/Apple1Display"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo2
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "C:/Dev/Apple1Display/ttl/court161.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74161.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74175.vhd"
addfile "C:/Dev/Apple1Display/impl1/Apple1Display.vhd"
addfile "C:/Dev/Apple1Display/impl1/divider.vhd"
addfile "C:/Dev/Apple1Display/impl1/master_clk.vhd"
addfile "C:/Dev/Apple1Display/impl1/source/FleaFPGA_Uno_Top.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7402.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7404.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7408.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7410.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7427.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7432.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7450.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74157.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74160.vhd"
addfile "C:/Dev/Apple1Display/tests/divider_tb.vhd"
addfile "C:/Dev/Apple1Display/tests/dm74175_tb.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm7400.vhd"
addfile "C:/Dev/Apple1Display/tests/dm7400_tb.vhd"
addfile "C:/Dev/Apple1Display/tests/dm74161_tb.vhd"
addfile "C:/Dev/Apple1Display/impl1/source/ntsc.vhd"
addfile "C:/Dev/Apple1Display/tests/ntsc_tb.vhd"
addfile "C:/Dev/Apple1Display/tests/Apple1Display_tb.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74166.vhd"
addfile "C:/Dev/Apple1Display/ttl/dm74174.vhd"
addfile "C:/Dev/Apple1Display/ttl/2504.vhd"
addfile "C:/Dev/Apple1Display/ttl/2519.vhd"
vlib "C:/Dev/Apple1Display/simulation/work"
set worklib work
adel -all
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/court161.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74161.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74175.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/impl1/Apple1Display.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/impl1/divider.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/impl1/master_clk.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/impl1/source/FleaFPGA_Uno_Top.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7402.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7404.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7408.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7410.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7427.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7432.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7450.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74157.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74160.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/divider_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/dm74175_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm7400.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/dm7400_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/dm74161_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/impl1/source/ntsc.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/ntsc_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/tests/Apple1Display_tb.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74166.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/dm74174.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/2504.vhd"
vcom -dbg -work work "C:/Dev/Apple1Display/ttl/2519.vhd"
entity FleaFPGA_Uno_E1
vsim  +access +r FleaFPGA_Uno_E1   -PL pmi_work -L ovi_machxo2
add wave *
run 1000ns
