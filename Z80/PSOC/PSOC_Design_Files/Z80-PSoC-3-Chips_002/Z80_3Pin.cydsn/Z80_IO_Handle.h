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
#include "FrontPanel.h"
#include "Z80_SIO_emul.h"
#include "Z80_6850_Emul.h"
#include "Z80_6850_2_Emul.h"
#include "Z80_SDCard_Emul.h"

#define CLR_IO_INT_BIT 1
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
