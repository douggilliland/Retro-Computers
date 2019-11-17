/* ========================================
*
* Copyright LAND BOARDS, LLC, 2019
* All Rights Reserved
* UNPUBLISHED, LICENSED SOFTWARE.
*
* CONFIDENTIAL AND PROPRIETARY INFORMATION
* WHICH IS THE PROPERTY OF LAND BOARDS, LLC.
*
* ========================================
*/

#if !defined(HARDWARECONFIG_H)
#define HARDWARECONFIG_H

#include <project.h>

////////////////////////////////////////////////////////////////////////////
// This file is where the hardware gets configured
// I/O address map is here
// Select hardware to include using
//  #undef to remove hardware
//  #define to include hardware

////////////////////////////////////////////////////////////////////////////
// Select the build here
//  Only 1 build at a time is supported
//  All other builds are set to #undef

#undef GRANT_9_CHIP_Z80
//#define GRANT_9_CHIP_Z80

#undef GRANT_7_CHIP_Z80
//#define GRANT_7_CHIP_Z80
    
#undef GRANT_FPGA_CPM
//#define GRANT_FPGA_CPM

//#undef MULTIBOOT_CPM
#define MULTIBOOT_CPM

////////////////////////////////////////////////////////////////////////////
// These are the design specific Z80 peripherals
// Assume none of the supported I/O peripheral chips are used (all #undef)
// They are included in the specific builds if the build software uses them
// These are used to control Z80 I/O writes

#undef USING_FRONT_PANEL        // Assume no front panel
#undef USING_EXP_MCCP23017      // Assume no MCP23017 I2C I/O expansion part
#undef USING_MCP23017   // Set if either the Front Panel or Expansion MCP23017 is used
#undef USING_PIO
#undef USING_SIO
#undef USING_6850
#undef USING_6850_2
#undef USING_CF_SDCARD
#undef USING_MEM_MAP_1  // Swap out first 8KB
#undef USING_MMU4       // Four banks of 16KB per bank for entire SRAM
#undef USING_MMU4_SWAP
#undef USING_RTC
#undef USING_DAC

#define USING_SDCARD
#ifdef USING_SDCARD
    #define SD_DATA             0x88    // decimal 128
    #define SD_CONTROL	        0x89    // decimal 129
    #define SD_STATUS	        0x89    // decimal 129
    #define SD_LBA0		        0x8A    // decimal 130
    #define SD_LBA1		        0x8B    // decimal 131
    #define SD_LBA2		        0x8C    // decimal 132
#endif

////////////////////////////////////////////////////////////////////////////
// The individual memory maps follow
// There is a section for each build

////////////////////////////////////////////////////////////////////////////
// defines for building Grant Searle's 9-chip Z80 design

#ifdef GRANT_9_CHIP_Z80
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00004000      // 16K build
    // I/O Space Address Map follow
    #define USING_SIO
//    #define USING_CF_SDCARD
    #define USING_FRONT_PANEL
    #define USING_EXP_MCCP23017
    #define USING_MCP23017
    #ifdef USING_SIO
        #define SIOA_D              0x00
        #define SIOB_D              0x01
        #define SIOA_C              0x02
        #define SIOB_C              0x03
    #endif
    #ifdef USING_CF_SDCARD
        #define CF_DATA             0x10
        #define CF_FEATURES_ERROR   0x11
        #define CF_SECCOUNT         0x12
        #define CF_SECTOR_LAB0      0x13
        #define CF_CYL_LOW_LBA1     0x14
        #define CF_CYL_HI_LBA2      0x15
        #define CF_HEAD_LBA3        0x16
        #define CF_STATUS_COMMAND   0x17
    #endif
    #ifdef USING_FRONT_PANEL
        #define FR_PNL_IO_LO        0x18    // decimal 24
        #define FR_PNL_IO_LO_MID    0x19    // decimal 25
        #define FR_PNL_IO_HI_MID    0x1A    // decimal 26
        #define FR_PNL_IO_HI        0x1B    // decimal 27
    #endif
    #ifdef USING_EXP_MCCP23017
        #define PIOA_D              0x20    // decimal 32
        #define PIOA_C              0x22    // decimal 34
        #define PIOB_D              0x21    // decimal 33
        #define PIOB_C              0x23    // decimal 35
    #endif
#endif

////////////////////////////////////////////////////////////////////////////
// defines for building Grant Searle's 7-chip Z80 design
// http://zx80.netai.net/grant/z80/SimpleZ80.htm

#ifdef GRANT_7_CHIP_Z80
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00002000      // 8K build
    // I/O Space Address Map follow
    #define USING_FRONT_PANEL
    #define USING_EXP_MCCP23017
    #define USING_MCP23017
    #define USING_6850
    #define M6850_C              0x80       // Control/Status register
    #define M6850_D              0x81       // Data
    #ifdef USING_FRONT_PANEL
        #define FR_PNL_IO_LO        0x18    // decimal 24
        #define FR_PNL_IO_LO_MID    0x19    // decimal 25
        #define FR_PNL_IO_HI_MID    0x1A    // decimal 26
        #define FR_PNL_IO_HI        0x1B    // decimal 27
    #endif
    #ifdef USING_EXP_MCCP23017
        #define PIOA_D              0x20    // decimal 32
        #define PIOA_C              0x22    // decimal 34
        #define PIOB_D              0x21    // decimal 33
        #define PIOB_C              0x23    // decimal 35
    #endif
#endif

////////////////////////////////////////////////////////////////////////////
// defines for building Grant Searle's FPGA Z80 design
// http://zx80.netai.net/grant/Multicomp/index.html

#ifdef GRANT_FPGA_CPM
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00002000      // 8K build
    // I/O Space Address Map follow
    #define USING_SDCARD
    #define USING_6850
    #define USING_FRONT_PANEL     // Use front panel
    #define USING_EXP_MCCP23017   // Use MCP23017 I2C I/O expansion part
    #define USING_MCP23017
    #ifdef USING_FRONT_PANEL
        #define FR_PNL_IO_LO        0x18    // decimal 24
        #define FR_PNL_IO_LO_MID    0x19    // decimal 25
        #define FR_PNL_IO_HI_MID    0x1A    // decimal 26
        #define FR_PNL_IO_HI        0x1B    // decimal 27
    #endif
    #ifdef USING_EXP_MCCP23017
        #define PIOA_D              0x20    // decimal 32
        #define PIOA_C              0x22    // decimal 34
        #define PIOB_D              0x21    // decimal 33
        #define PIOB_C              0x23    // decimal 35
    #endif
    #define USING_MEM_MAP_1
    #ifdef USING_MEM_MAP_1
        #define MEM_MAP_SWAP        0x38
    #endif
    #ifdef USING_6850
        #define M6850_C              0x80       // Control/Status register
        #define M6850_D              0x81       // Data
        #define USING_6850_2
        #define M6850_2_C            0x82       // Control/Status register - 2nd 6850 part (faked)
        #define M6850_2_D            0x83       // Data
    #endif
#endif

////////////////////////////////////////////////////////////////////////////
// defines for building Multiboot Multicomp
// https://retrobrewcomputers.org/doku.php?id=builderpages:rhkoolstar:mc-2g-1024

#ifdef MULTIBOOT_CPM
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00000800      // 2K build
    // I/O Space Address Map follow
    #define USING_6850
    #define USING_SDCARD
    #define USING_MMU4
    #define USING_MMU4_SWAP
    #define USING_FRONT_PANEL
    #define USING_EXP_MCCP23017
    #define USING_MCP23017
    #define USING_RTC
    #define USING_DAC
    
    #ifdef USING_FRONT_PANEL
        #define FR_PNL_IO_LO        0x18    // decimal 24
        #define FR_PNL_IO_LO_MID    0x19    // decimal 25
        #define FR_PNL_IO_HI_MID    0x1A    // decimal 26
        #define FR_PNL_IO_HI        0x1B    // decimal 27
    #endif
    #ifdef USING_EXP_MCCP23017
        #define PIOA_D              0x20    // decimal 32
        #define PIOA_C              0x22    // decimal 34
        #define PIOB_D              0x21    // decimal 33
        #define PIOB_C              0x23    // decimal 35
    #endif
    #ifdef USING_MMU4_SWAP
        #define MEM_MAP_SWAP_OUT    0x38
        #define MEM_MAP_SWAP_BACK   0x39
    #endif
    #ifdef USING_RTC
        #define RTC_DATA            0x60    // 96 dec
        #define RTC_CSR             0x61    // 97 dec
    #endif
    #ifdef USING_DAC
        #define DAC_DATA            0x62    // 98 dec
        #define DAC_CSR             0x63    // 99 dec
    #endif
    #define M6850_B                 0x7B    // Baud Rate Select
    #define M6850_2_B               0x7C    // Baud Rate Select
    #define M6850_C                 0x80    // Control/Status register
    #define M6850_D                 0x81    // Data
    #define USING_6850_2
    #define M6850_2_C               0x82    // Control/Status register - 2nd 6850 part (faked)
    #define M6850_2_D               0x83    // Data
    #ifdef USING_SDCARD
        #define SD_DATA             0x88    // decimal 128
        #define SD_CONTROL	        0x89    // decimal 129
        #define SD_STATUS	        0x89    // decimal 129
        #define SD_LBA0		        0x8A    // decimal 130
        #define SD_LBA1		        0x8B    // decimal 131
        #define SD_LBA2		        0x8C    // decimal 132
    #endif
    #define USING_MMU4
    #ifdef USING_MMU4
        #define MMUSELECT           0xF8    // Selects which register is used
        #define MMUFRAME            0xFD    // Writes to the register
    #endif
#endif

#endif

/* [] END OF FILE */
