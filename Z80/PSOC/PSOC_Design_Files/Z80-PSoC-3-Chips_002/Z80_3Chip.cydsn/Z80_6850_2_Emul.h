#if !defined(Z8068502EMU_H)
#define Z8068502EMU_H
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

void M6850_2_ReadData(void);
void M6850_2_WriteData(void);
void M6850_2_ReadStatus(void);
void M6850_2_WriteCtrl(void);
uint8 checkSerial_2_ReceiverBusy(void);
void sendCharToZ80_2(uint8);
void M6850_2_ReadIntReg(void);
void initM6850_2_StatusRegister(void);

/* [] END OF FILE */
#endif
