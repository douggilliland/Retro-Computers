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

// Select hardware to include using
//  Undef to remove hardware
//  define to include hardware

// Global choices based on hardware used/not used
// To include the function comment out the undef and use the include
//#undef USING_FRONT_PANEL        // Assume no front panel
#define USING_FRONT_PANEL     // Use front panel
#undef USING_EXP_MCCP23017      // Assume no MCP23017 I2C I/O expansion part
//#define USING_EXP_MCCP23017   // Use MCP23017 I2C I/O expansion part

// These are the Z80 peripherals
// Assume none of the supported I/O peripheral chips are used
// They are included in the specific builds if the build software uses them
#undef USING_PIO
#undef USING_SIO
#undef USING_6850

// Select the build here. 
//  Only 1 build at a time is supported.
//  All other builds are set to undef
#undef GRANT_9_CHIP_Z80
//#define GRANT_9_CHIP_Z80
#define GRANT_7_CHIP_Z80
//#undef GRANT_7_CHIP_Z80

// defines for building Grant Searle's 9-chip Z80 design
#ifdef GRANT_9_CHIP_Z80
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00004000      // 16K build
    // I/O Space Address Map follow
    #define USING_SIO
        #define SIOA_D              0x00
        #define SIOA_C              0x02
        #define SIOB_D              0x01
        #define SIOB_C              0x03
    #ifdef USING_FRONT_PANEL
        #define FR_PNL_IO_LO        0x18    // decimal 24
        #define FR_PNL_IO_LO_MID    0x19    // decimal 25
        #define FR_PNL_IO_HI_MID    0x1A    // decimal 26
        #define FR_PNL_IO_HI        0x1B    // decimal 27
    #endif
    #ifdef USING_EXP_MCCP23017
        #define PIOA_D              0x20
        #define PIOA_C              0x22
        #define PIOB_D              0x21
        #define PIOB_C              0x23
    #endif
#endif

// defines for building Grant Searle's 7-chip Z80 design
// http://zx80.netai.net/grant/z80/SimpleZ80.htm
#ifdef GRANT_7_CHIP_Z80
    #define MONITOR_START       0x00000000      // EEPROM loads to address 0
    #define MONITOR_LENGTH      0x00002000      // 8K build
    // I/O Space Address Map follow
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
        #define PIOA_D              0x20
        #define PIOA_C              0x22
        #define PIOB_D              0x21
        #define PIOB_C              0x23
    #endif
#endif

/* [] END OF FILE */
