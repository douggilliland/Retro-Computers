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

uint8 mmu4select;
uint8 mmu4Reg0;
uint8 mmu4Reg1;
uint8 mmu4Reg2;
uint8 mmu4Reg3;

#ifdef USING_MEM_MAP_1       // Memory mapper for Grant's CPM in FPGA code

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
    MMU_Sel_Write(0x0);
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

#ifdef USING_MEM_MAP_4       // Memory mapper for Multiboot code

/////////////////////////////////////////////////////////////////////////////////
// Memory Mapper version 4 has four banks of 16KB each with 64 total banks (1M SRAM) or 32 banks (512KB SRAM)
// Points to the first four SRAM banks

void init_mem_map_4(void)
{
    MMU_Sel_Write(0x1);
    MMU4_Addr_0_Write(0x0);
    MMU4_Addr_1_Write(0x1);
    MMU4_Addr_2_Write(0x2);
    MMU4_Addr_3_Write(0x3);
}

/////////////////////////////////////////////////////////////////////////////////
// void wrMMU4SelectReg(void) - Sets the address of the next MMU accesses
// Used with Memory Map 1 scheme where there's a single 8KB bank starting at 0x0000
// which is switched out when an I/O location is written.

void wrMMU4SelectReg(void)
{
    mmu4select = Z80_Data_In_Read() & 0x03;
	ackIO();
}

/////////////////////////////////////////////////////////////////////////////////
// void wrMMU4Bank(void) - Write to the bank register in MMU4

void wrMMU4Bank(void)
{
    switch (mmu4select)
    {
        case 0:
            MMU4_Addr_0_Write(Z80_Data_In_Read());
            break;
        case 1:
            MMU4_Addr_1_Write(Z80_Data_In_Read());
            break;
        case 2:
            MMU4_Addr_2_Write(Z80_Data_In_Read());
        case 3:
            MMU4_Addr_3_Write(Z80_Data_In_Read());
    }
	ackIO();
}

#endif

/* [] END OF FILE */
