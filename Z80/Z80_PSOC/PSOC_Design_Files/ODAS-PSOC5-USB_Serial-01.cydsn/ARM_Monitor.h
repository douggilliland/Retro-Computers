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
#if !defined(ARM_MONITOR_H)
#define ARM_MONITOR_H

#include "project.h"
#include "proEnv.h"
    
void ARM_Monitor(void);
uint8 countParms(char *);
uint32 extractParm(char *, uint8);
int8 checkParmCount(char *, uint8);
void dumpMem(uint32);
void readMemByte(uint32);
void readMemShort(uint32);
void readMemLong(uint32);
void writeMemByte(uint32, uint8);
void writeMemShort(uint32, uint16);
void writeMemLong(uint32, uint32);

#endif  /* ARM_MONITOR_H */

/* [] END OF FILE */
