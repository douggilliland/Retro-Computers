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
//  d3 = CPU_RESETn
//      0 = Reset the Z80 (default at power up)
//      1 = Remove reset from the Z80
////////////////////////////////////////////////////////////////////////////

#include <project.h>

#define SRAMRW_MASK     0x01
#define SRAM_WRITE      0x00
#define SRAM_READ       0x01
#define DRVRAM_MASK     0x02
#define DRV_RAM_NO      0x00
#define DRV_RAM_YES     0x02
#define SRAMCS_MASK     0x04
#define SRAM_ACT        0x00
#define SRAM_UNACT      0x04
#define CPU_RST_MASK    0x08
#define CPU_RST_ON      0x00
#define CPU_RST_OFF     0x08

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
//  Z80 is held in CPU_RESET during this action

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
//  Z80 is held in CPU_RESET during this action

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
//  Z80 is held in CPU_RESET during this action
// Returns 
//  0 if POST passed
//  1 if POST Failed single location test
//  2 if POST failed address ramp test

uint32 TestSRAM(void)
{
    uint32 sramAddr;
    uint8 sramData;
    ExtSRAMCtl_Write(0x5);              // Make sure Z80 is in reset
    // Do a single write/read of the first location as a quick test
    WriteExtSRAM(0x0,0x55);             // Write 0x55 to the SRAM
    if (ReadExtSRAM(0x0) != 0x55)       // Read the SRAM
        return(0x1);   // Post failed
    // Write/read a data ramp to exercise address lines (step in address bits)
    sramData = 1;
    for (sramAddr = 0; sramAddr < 0x80000; sramAddr <<= 1)
    {
        WriteExtSRAM(sramAddr,sramData);
        sramAddr <<= 1;
        sramData++;
    }
    sramData = 1;
    for (sramAddr = 0; sramAddr < 0x80000; sramAddr <<= 1)
    {
        if (ReadExtSRAM(sramAddr) != sramData)
            return(0x2);
        sramAddr <<= 1;
        sramData++;
    }
    return(0);
}

/* [] END OF FILE */
