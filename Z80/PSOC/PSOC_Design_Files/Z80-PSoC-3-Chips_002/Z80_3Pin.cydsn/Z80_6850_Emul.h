/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include <project.h>
#include "Hardware_Config.h"

void M6850ReadData(void);
void M6850WriteData(void);
void M6850ReadStatus(void);
void M6850WriteCtrl(void);
uint8 checkSerialReceiverBusy(void);
void sendCharToZ80(uint8);
void M6850ReadIntReg(void);
void initM6850StatusRegister(void);

/* [] END OF FILE */
