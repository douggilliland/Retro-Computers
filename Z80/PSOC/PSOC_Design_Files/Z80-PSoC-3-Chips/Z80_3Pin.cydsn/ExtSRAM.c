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

////////////////////////////////////////////////////////////////////////////
// External SRAM is controlled by ExtSRAMCtl register
//  d0 = SRAM_R1_W0
//  d1 = DRV_RAM
//      0 = Don't drive the SRAM address/controls
//      1 = Drive the SRAM address/controls
//  d2 = SRAMCSn
//      0 = Chip Select enabled
//      1 = Chip Select disabled (default at power up)
////////////////////////////////////////////////////////////////////////////

#include <project.h>

////////////////////////////////////////////////////////////////////////////
// SetExtSRAMAddr(addr) - Set the address registers for the SRAM

void SetExtSRAMAddr(uint32 addr)
{
    AdrLowOut_Write(addr & 0xff);           // bottom 8-bits of the address A0..A7
    AdrMidOut_Write((addr>>8) & 0x7);       // middle 3-bits of the address A8..A1
    AdrHighOut_Write((addr>>13) & 0xFF);    
}

////////////////////////////////////////////////////////////////////////////
// ReadExtSRAM(addr) - Read the external SRAM at address = addr

uint8 ReadExtSRAM(uint32 addr)
{
    uint8 rdVal;
    SetExtSRAMAddr(addr);
    ExtSRAMCtl_Write(0x5);          // Set R/W* to Read
    ExtSRAMCtl_Write(0x7);          // Assert DRV_RAM
    ExtSRAMCtl_Write(0x3);          // Assert SRAMCS
    rdVal = Z80_Data_Out_Read();
    ExtSRAMCtl_Write(0x7);          // Remove SRAMCS
    ExtSRAMCtl_Write(0x5);          // Remove DRV_RAM
    return(rdVal);
}

////////////////////////////////////////////////////////////////////////////
// WriteExtSRAM(addr,data) - Write to the external SRAM at address = addr

void WriteExtSRAM(uint32 addr, uint8 data)
{
    SetExtSRAMAddr(addr);
    ExtSRAMCtl_Write(0x4);          // Set R/W* to Write
    ExtSRAMCtl_Write(0x6);          // Assert DRV_RAM
    Z80_Data_In_Write(data);        // Provide value to SRAM data bus
    ExtSRAMCtl_Write(0x2);          // De-assert SRAMCS
    ExtSRAMCtl_Write(0x5);          // De-assert DRV_RAM, Set to read
    
}

////////////////////////////////////////////////////////////////////////////
// TestSRAM()
// Returns 
//  0 if POST passed
//  1 if Post Failed

uint32 TestSRAM(void)
{
    WriteExtSRAM(0x0,0x55);             // Write 0x55 to the SRAM
    if (ReadExtSRAM(0x0) != 0x55)       // Read the SRAM
        return(0x1);   // Post failed
    else
        return(0x0);
}

/* [] END OF FILE */
