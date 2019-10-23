#if !defined(Z80MEMMAPPERS_H)
#define Z80MEMMAPPERS_H

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

#define BANK_SIZE_32K   0x10
#define BANK_SIZE_16K   0x18
#define BANK_SIZE_8K    0x1c
#define BANK_SIZE_4K    0x1E
#define BANK_SIZE_2K    0x1F

void init_mem_map_1(void);
void swap_out_ROM_space(void);

/* [] END OF FILE */

#endif
