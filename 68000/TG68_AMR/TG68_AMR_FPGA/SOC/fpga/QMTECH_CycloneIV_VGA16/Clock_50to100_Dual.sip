set_global_assignment -entity "Clock_50to100_Dual" -library "lib_Clock_50to100_Dual" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "Clock_50to100_Dual" -library "lib_Clock_50to100_Dual" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "Clock_50to100_Dual" -library "lib_Clock_50to100_Dual" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_Clock_50to100_Dual" -name SPD_FILE [file join $::quartus(sip_path) "Clock_50to100_Dual.spd"]

set_global_assignment -library "lib_Clock_50to100_Dual" -name MISC_FILE [file join $::quartus(sip_path) "Clock_50to100_Dual_sim/Clock_50to100_Dual.vho"]
