/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/
/* http://srecord.sourceforge.net/ */

#include "project.h"
#include "ExtSRAM.h"

#define MONITOR_TERMINATION 0x00000000
#define MONITOR_START       0x00000000
#define MONITOR_FINISH      0x00004000
#define MONITOR_LENGTH      0x00004000

extern unsigned char monitor_eprom[];

void loadSRAM(void)
{
    uint32 charCount;
    uint32 SRAMAddr = MONITOR_START;
    volatile uint8 dataVal;
    for (charCount = 0; charCount < MONITOR_LENGTH; charCount++)
    {
        dataVal = monitor_eprom[charCount];
        WriteExtSRAM(SRAMAddr,dataVal);
        SRAMAddr++;
    }
}

/* [] END OF FILE */
