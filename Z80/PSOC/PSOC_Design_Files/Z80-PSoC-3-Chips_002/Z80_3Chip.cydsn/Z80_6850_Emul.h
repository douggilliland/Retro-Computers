#if !defined(Z806850EMU_H)
#define Z806850EMU_H
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

void M6850ReadData(void);
void M6850WriteData(void);
void M6850ReadStatus(void);
void M6850WriteCtrl(void);
uint8 checkSerialReceiverBusy(void);
void sendCharToZ80(uint8);
void M6850ReadIntReg(void);
void initM6850StatusRegister(void);

/* [] END OF FILE */
#endif
