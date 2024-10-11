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

#if !defined(Z80DAC_H)
#define Z80DAC_H

#include <project.h>

void init_DAC(void);
void writeDAC(void);
void readDAC(void);
void readStatDAC(void);
void writeCmdDAC(void);

#endif

/* [] END OF FILE */
