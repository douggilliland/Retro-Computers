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
// Controls test and loading of the SRAM image from EPROM space of the PSoC.

#include <project.h>
#include <Z80_PSoC_3Chips.h>

////////////////////////////////////////////////////////////////////////////
// Bits in the SRAM direct control register 

#define DRVRAM_BIT      0x01    // 1 = Drive SRAM bus from PSoC
#define SRAMCS_BIT      0x02    // 1 = Drive SRAMCS
#define SRAMRD_BIT      0x04    // 1 = SRAM read
#define SRAMWR_BIT      0x08    // 1 = SRAM write
#define CPURESET_BIT    0x10    // 1 = Z80 held in reset

////////////////////////////////////////////////////////////////////////////
// externs for the EPROM images

#ifdef GRANT_9_CHIP_Z80
extern unsigned char monitor_basic_eprom[];
#endif
#ifdef GRANT_7_CHIP_Z80
extern unsigned char gs7chip_basic_eeprom[];
#endif
#ifdef GRANT_FPGA_CPM
extern const unsigned char gs_fpga_basic_eeprom[];
#endif
#ifdef MULTIBOOT_CPM
extern const unsigned char multi_boot_eprom[];
#endif

////////////////////////////////////////////////////////////////////////////
// SetExtSRAMAddr(addr) - Set the address registers for the SRAM

void SetExtSRAMAddr(uint32 addr)
{
	AdrLowOut_Write(addr & 0xff);           // bottom 8-bits of the address A0..A7
	AdrMidOut_Write((addr>>8) & 0x7);       // middle 3-bits of the address A8..A10
	AdrHighOut_Write((addr>>11) & 0xFF);    // Upper bits of the address A11..A18
}

////////////////////////////////////////////////////////////////////////////
// ReadExtSRAM(addr) - Read the external SRAM at address = addr
//  Z80 is held in CPU_RESET during this action

uint8 ReadExtSRAM(uint32 addr)
{
	uint8 rdVal;
	SetExtSRAMAddr(addr);
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT | SRAMRD_BIT);               // Set R/W* to Read
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT | SRAMRD_BIT | SRAMCS_BIT);  // Assert SRAMCS
	rdVal = Z80_Data_Out_Status;
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT);                        // Remove SRAMCS
	return(rdVal);
}

////////////////////////////////////////////////////////////////////////////
// WriteExtSRAM(addr,data) - Write to the external SRAM at address = addr
//  Z80 is held in CPU_RESET during this action

void WriteExtSRAM(uint32 addr, uint8 data)
{
	SetExtSRAMAddr(addr);
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT | SRAMWR_BIT);               // Set R/W* to Write
	Z80_Data_In_Write(data);                                                // Provide value to SRAM data bus
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT | SRAMWR_BIT | SRAMCS_BIT);  // Assert SRAMCSn
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT);                            // De-assert SRAMCSn, Set to read
}

////////////////////////////////////////////////////////////////////////////
// TestSRAM() - Test the 512KB External SRAM
//  Z80 is held in CPU_RESET during this action
// Returns 
//  0 if POST passed
//  1 if POST Failed single location test
//  2 if POST failed test of first 256 locations
//  3 if POST failed address ramp test

#define POST_PASSED                         0
#define POST_FAILED_SINGLE_LOCATION_TEST    1
#define POST_FAILED_ADDRESS_RAMP            2
#define POST_FAILED_TEST_ALL_RAM            3

uint32 TestSRAM(void)
{
	volatile uint32 sramAddr;
	volatile uint8 sramData;
	volatile uint8 sramReadData;
    MMU_Sel_Write(0x0); // PSoC to SRAM path is through MMU1 - path
	ExtSRAMCtl_Write(CPURESET_BIT | DRVRAM_BIT);              // Z80 in reset, SRAM deselected, DRV_RAM asserted
	// Do a single write/read of the first location as a quick test
	WriteExtSRAM(0x0,0x55);             // Write 0x55 to the SRAM
	if (ReadExtSRAM(0x0) != 0x55)       // Read the SRAM
	return(POST_FAILED_SINGLE_LOCATION_TEST);   // Post failed
	// Write/read a data ramp to exercise address lines (step in address bits)
	sramData = 1;
	for (sramAddr = 1; sramAddr < 0x80000; sramAddr <<= 1)
	{
		WriteExtSRAM(sramAddr,sramData);
		sramData++;
	}
	// Bounce a one across the address lines to test all 512KB
	sramData = 1;
	for (sramAddr = 1; sramAddr < 0x80000; sramAddr <<= 1)
	{
		sramReadData = ReadExtSRAM(sramAddr);
		if (sramReadData != sramData)
		return(POST_FAILED_ADDRESS_RAMP);
		sramData++;
	}
	// Fill all of the SRAM with data = bottom of 8 bits of address
	sramData = 0;
	for (sramAddr = 0; sramAddr < 0x80000; sramAddr++)
	{
		WriteExtSRAM(sramAddr,sramData);
		sramData++;
	}
	// Verify the SRAM has data=address
	sramData = 0;
	for (sramAddr = 0; sramAddr < 0x80000; sramAddr++)
	{
		sramReadData = ReadExtSRAM(sramAddr);
		if (sramReadData != sramData)
		return(POST_FAILED_TEST_ALL_RAM);
		sramData++;
	}
	ExtSRAMCtl_Write(CPURESET_BIT);              // Leave Z80 in reset
	return(POST_PASSED);
}

////////////////////////////////////////////////////////////////////////////
// void loadSRAM(void) - Load the SRAM on the card with the ROM code
// Supports all builds
// Create the C array using srec_cat and put into a .c file
//  Hex files:      srec_cat.exe HexFile.hex -I -o cmon32.c -C-Array
//  Object files:   srec_cat.exe ObjFile.o -binary -o CCode.c -C-Array

void loadSRAM(void)
{
	uint32 SRAMAddr = MONITOR_START;    // Should all start at 0x0000 for Z80
    uint8 dataVal;
	for (uint32 charCount = 0; charCount < MONITOR_LENGTH; charCount++)
	{
#ifdef GRANT_9_CHIP_Z80
		dataVal = monitor_basic_eprom[charCount];
#endif
#ifdef GRANT_7_CHIP_Z80
		dataVal = gs7chip_basic_eeprom[charCount];
#endif
#ifdef GRANT_FPGA_CPM
		dataVal = gs_fpga_basic_eeprom[charCount];
#endif
#ifdef MULTIBOOT_CPM
		dataVal = multi_boot_eprom[charCount];
#endif
		WriteExtSRAM(SRAMAddr,dataVal);
		SRAMAddr++;
	}
}

/* [] END OF FILE */
