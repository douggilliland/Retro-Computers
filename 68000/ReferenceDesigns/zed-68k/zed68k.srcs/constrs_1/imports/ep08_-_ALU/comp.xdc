# This file is specific for the Zedboard board.


set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports videoR1]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports videoR0]
set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33} [get_ports videoG1]
set_property -dict {PACKAGE_PIN AB22 IOSTANDARD LVCMOS33} [get_ports videoG0]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports videoB1]
set_property -dict {PACKAGE_PIN Y21 IOSTANDARD LVCMOS33} [get_ports videoB0]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports hSync]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports vSync]

#NET BTNC          LOC = P16  | IOSTANDARD=LVCMOS18;  # "BTNC"
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports reset]

#JA PMOD has a ps2 pmod
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports ps2Data] 
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports ps2Clk]
set_property PULLUP true [get_ports ps2Clk]
set_property PULLUP true [get_ports ps2Data]

#UART JB
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33 } [get_ports {rxd1}]
#NET JB1           LOC = W12  | IOSTANDARD=LVCMOS33;  # "JB1"
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33 } [get_ports {txd1}]
#NET JB2           LOC = W11  | IOSTANDARD=LVCMOS33;  # "JB2"
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports {rts1}]
#NET JB3           LOC = V10  | IOSTANDARD=LVCMOS33;  # "JB3"

#JD PMOD has a sd card pmod, led 0 is drive led
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33 } [get_ports driveLED]

set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {sdMOSI}]
#NET JD1_N         LOC = W7   | IOSTANDARD=LVCMOS33;  # "JD1_N"
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports {sdCS}]
#NET JD1_P         LOC = V7   | IOSTANDARD=LVCMOS33;  # "JD1_P"
set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports {sdSCLK}]
#NET JD2_N         LOC = V4   | IOSTANDARD=LVCMOS33;  # "JD2_N"
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {sdMISO}]
#NET JD2_P         LOC = V5   | IOSTANDARD=LVCMOS33;  # "JD2_P"

# Configuration Bank Voltage Select
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property PACKAGE_PIN Y9 [get_ports sys_clock]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clock]

# Clock definition
create_clock -name sys_clk -period 10.00 [get_ports {sys_clock}];                          # 100 MHz
