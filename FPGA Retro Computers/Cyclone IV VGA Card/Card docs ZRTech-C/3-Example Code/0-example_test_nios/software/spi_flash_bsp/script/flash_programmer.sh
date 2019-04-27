#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: E:\work\ESPIER_I\demo\zr_200\ESPIER_I_niosII_standard.sof to: "..\flash/ESPIER_I_niosII_standard_epcs_controller.flash"
#
$SOPC_KIT_NIOS2/bin/sof2flash --input="E:/work/ESPIER_I/demo/zr_200/ESPIER_I_niosII_standard.sof" --output="../flash/ESPIER_I_niosII_standard_epcs_controller.flash" --epcs --verbose 

#
# Programming File: "..\flash/ESPIER_I_niosII_standard_epcs_controller.flash" To Device: epcs_controller
#
$SOPC_KIT_NIOS2/bin/nios2-flash-programmer "../flash/ESPIER_I_niosII_standard_epcs_controller.flash" --base=0x0 --epcs --sidp=0x3970 --id=0x0 --timestamp=1382618285 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

#
# Converting ELF File: E:\work\ESPIER_I\demo\zr_200\software\spi_flash\spi_flash.elf to: "..\flash/spi_flash_epcs_controller.flash"
#
$SOPC_KIT_NIOS2/bin/elf2flash --input="E:/work/ESPIER_I/demo/zr_200/software/spi_flash/spi_flash.elf" --output="../flash/spi_flash_epcs_controller.flash" --epcs --after="../flash/ESPIER_I_niosII_standard_epcs_controller.flash" --verbose 

#
# Programming File: "..\flash/spi_flash_epcs_controller.flash" To Device: epcs_controller
#
$SOPC_KIT_NIOS2/bin/nios2-flash-programmer "../flash/spi_flash_epcs_controller.flash" --base=0x0 --epcs --sidp=0x3970 --id=0x0 --timestamp=1382618285 --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

