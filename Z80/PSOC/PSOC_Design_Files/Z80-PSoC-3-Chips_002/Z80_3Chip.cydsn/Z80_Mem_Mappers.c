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

/////////////////////////////////////////////////////////////////////////////////
// Routines to do memory mapping
// Mem Map 1 swaps out an 8KB block when CP/M is run

#include <project.h>
#include <Z80_PSoC_3Chips.h>

void init_mem_map_1(void)
{
    BankBaseAdr_Write(0x00);
    BankMask_Write(0x1c);
    AdrHighOut_Write(0x00);
}

void swap_out_ROM_space(void)
{
    AdrHighOut_Write(0x20);     // Set A18..A16 to 0x1
    ackIO();
}

/* [] END OF FILE */
