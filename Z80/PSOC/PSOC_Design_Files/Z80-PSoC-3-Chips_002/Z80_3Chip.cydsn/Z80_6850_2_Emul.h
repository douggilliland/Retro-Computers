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

#if !defined(Z8068502EMU_H)
#define Z8068502EMU_H
    
#include <project.h>

#define SIO_CHAR_RDY                0x01
#define M6850_INT_RTS_MASK          0x60
#define M6850_RTS_LOW__INT_EN       0x20    // Not used by Grant's 7-chip code
#define M6850_RTS_HI__INT_DIS       0x40
#define M6850_RTS_LOW__INT_DIS_BK   0x60    // Not used by Grant's 7-chip code

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
