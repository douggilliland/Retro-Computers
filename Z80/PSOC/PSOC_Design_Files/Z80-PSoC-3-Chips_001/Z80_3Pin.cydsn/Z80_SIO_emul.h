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
void SioReadIntRegA(uint8 regNum);
void SioWriteCtrlA(void);
void SioReadDataB(void);
void SioWriteDataB(void);
void SioReadStatusB(uint8 regNum);
void SioReadIntRegB(uint8 regNum);
void SioWriteCtrlB(void);

#define IORQ_BIT    1
#define CPURD_BIT   2
#define CPUWR_BIT   4
#define M1_BIT      8
#define REGULAR_READ_CYCLE  0x0C
#define INTR_READ_CYCLE     0x04
#define REGULAR_WRITE_CYCLE 0x0A
    
#define SIOA_D      0x00
#define SIOA_C      0x02
#define SIOB_D      0x01
#define SIOB_C      0x03

/* [] END OF FILE */
