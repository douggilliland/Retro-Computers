#if !defined(Z80SIOEMU_H)
#define Z80SIOEMU_H
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

#ifdef USING_SIO

#define SIOA_CHAR_RDY   0x1
#define SIO_RTS 0x2

void sendCharToZ80(uint8 rxChar);
void SioReadDataA(void);
void SioWriteDataA(void);
void SioReadStatusA(uint8 regNum);
void SioReadIntRegA();
void SioWriteCtrlA(void);
void SioReadDataB(void);
void SioWriteDataB(void);
void SioReadStatusB(uint8 regNum);
void SioReadIntRegB();
void SioWriteCtrlB(void);
uint8 checkSerialReceiverBusy(void);

#endif

/* [] END OF FILE */
#endif
