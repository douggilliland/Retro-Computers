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

// I/O Space Address Map follow
#define SIOA_D              0x00
#define SIOA_C              0x02
#define SIOB_D              0x01
#define SIOB_C              0x03
#define FR_PNL_IO_LO        0x18    // decimal 24
#define FR_PNL_IO_LO_MID    0x19    // decimal 25
#define FR_PNL_IO_HI_MID    0x1A    // decimal 26
#define FR_PNL_IO_HI        0x1B    // decimal 27
#define PIOA_D              0x20
#define PIOA_C              0x22
#define PIOB_D              0x21
#define PIOB_C              0x23

#define IORQ_BIT    0X01
#define CPURD_BIT   0X02
#define CPUWR_BIT   0X04
#define M1_BIT      0X08
#define IOBUSY_BIT  0X10
#define REGULAR_READ_CYCLE  0x1C
#define INTR_READ_CYCLE     0x14
#define REGULAR_WRITE_CYCLE 0x1A
#define IACK_MASK           0x19
#define IN_IACK_CYCLE       0x10
    
// Function Prototypes follow

void HandleZ80IO(void);
void ackIO(void);
void waitNextIORq(void);

/* [] END OF FILE */
