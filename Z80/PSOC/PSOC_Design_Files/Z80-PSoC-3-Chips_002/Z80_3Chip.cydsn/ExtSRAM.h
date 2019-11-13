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

#if !defined(EXTSRAM_H)
#define EXTSRAM_H

#include <project.h>

////////////////////////////////////////////////////////////////////////////
// Bits in the SRAM direct control register 

#define DRVRAM_BIT      0x01    // 1 = Drive SRAM bus from PSoC
#define SRAMCS_BIT      0x02    // 1 = Drive SRAM Chip Select
#define SRAMRD_BIT      0x04    // 1 = Drive SRAM read
#define SRAMWR_BIT      0x08    // 1 = Drive SRAM write
#define CPURESET_BIT    0x10    // 1 = Z80 held in reset
    
#define SRAM_SIZE       0x80000 // 512KB

#define POST_PASSED                         0
#define POST_FAILED_SINGLE_LOCATION_TEST    1
#define POST_FAILED_ADDRESS_RAMP            2
#define POST_FAILED_TEST_ALL_RAM            3

////////////////////////////////////////////////////////////////////////////
// Function prototypes

void    SetExtSRAMAddr(uint32);
void    WriteExtSRAM(uint32, uint8);
uint32  TestSRAM(void);
uint8   ReadExtSRAM(uint32);
void    loadSRAM(void);

#endif

/* [] END OF FILE */
