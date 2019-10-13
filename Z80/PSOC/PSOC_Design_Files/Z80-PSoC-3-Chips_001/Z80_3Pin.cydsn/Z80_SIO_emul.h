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

void ackIO(void);
void waitNextIORq(void);
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
void sendCharToZ80(uint8 rxChar);

#define IORQ_BIT    0X01
#define CPURD_BIT   0X02
#define CPUWR_BIT   0X04
#define M1_BIT      0X08
#define IOBUSY      0X10
#define REGULAR_READ_CYCLE  0x1C
#define INTR_READ_CYCLE     0x14
#define REGULAR_WRITE_CYCLE 0x1A
    
#define CLR_IO_INT_BIT 1

#define SIOA_D      0x00
#define SIOA_C      0x02
#define SIOB_D      0x01
#define SIOB_C      0x03

/* [] END OF FILE */
