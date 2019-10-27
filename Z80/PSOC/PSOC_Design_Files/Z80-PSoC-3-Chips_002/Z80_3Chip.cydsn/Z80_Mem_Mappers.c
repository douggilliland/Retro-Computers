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

#include <project.h>
#include <Z80_PSoC_3Chips.h>

#ifdef GRANT_FPGA_CPM       // Memory mapper for Grant's CPM in FPGA code

/////////////////////////////////////////////////////////////////////////////////
// Routines to do memory mapping
// Mem Map 1 swaps out an 8KB block when CP/M is run

/////////////////////////////////////////////////////////////////////////////////
// Memory Mapper version 1 sets bank size to 8KB
// Points to the first SRAM bank

void init_mem_map_1(void)
{
	BankBaseAdr_Write(0x00);
	BankMask_Write(BANK_SIZE_8K);
	AdrHighOut_Write(0x00);
}

/////////////////////////////////////////////////////////////////////////////////
// void swap_out_ROM_space(void) - When called switches to the 2nd bank
// Used with Memory Map 1 scheme where there's a single 8KB bank starting at 0x0000
// which is switched out when an I/O location is written.

void swap_out_ROM_space(void)
{
	AdrHighOut_Write(0x20);     // Set A18..A16 to 0x1
	ackIO();
}
#endif

/* [] END OF FILE */
