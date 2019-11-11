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

void SetExtSRAMAddr(uint32);
void WriteExtSRAM(uint32, uint8);
uint32 TestSRAM(void);
uint8 ReadExtSRAM(uint32);
void loadSRAM(void);

/* [] END OF FILE */
#endif
