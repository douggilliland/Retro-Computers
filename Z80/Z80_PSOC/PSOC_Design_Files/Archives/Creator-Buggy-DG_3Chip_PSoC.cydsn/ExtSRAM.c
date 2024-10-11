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

#include <project.h>

void SetExtSRAMAddr(uint32 addr)
{
    DMA_A0_7_Write(addr & 0xff);
    DMA_A8_15_Write((addr>>8) & 0x1F);
    BANK_ADDR_Write(((addr>>13) & 0x3F) | 0x80);    
}

// ReadExtSRAM(addr) - Read the external SRAM at address = addr

uint8 ReadExtSRAM(uint32 addr)
{
    SetExtSRAMAddr(addr);
    return(0);
}

// WriteExtSRAM(addr,data) - Write to the external SRAM at address = addr

void WriteExtSRAM(uint32 addr, uint8 data)
{
    SetExtSRAMAddr(addr);
}

/* [] END OF FILE */
