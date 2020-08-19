set_global_assignment -name FAMILY "Cyclone 10 LP"
set_global_assignment -name DEVICE 10CL025YU256C8G
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name GENERATE_RBF_FILE ON

set_global_assignment -name CYCLONEIII_CONFIGURATION_SCHEME "PASSIVE SERIAL"
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "PASSIVE SERIAL"
set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS PROGRAMMING PIN"
