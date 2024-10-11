/* ========================================
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#if !defined(ACCESSMEMORY_H)
#define ACCESSMEMORY_H

#include "project.h"
#include "proEnv.h"

void writeLong(uint32, uint32);
uint32 readLong(uint32);
uint16 readShort(uint32);
uint8 readByte(uint32);

void initMemArray(void);

#endif  /* ACCESSMEMORY_H */

/* [] END OF FILE */
