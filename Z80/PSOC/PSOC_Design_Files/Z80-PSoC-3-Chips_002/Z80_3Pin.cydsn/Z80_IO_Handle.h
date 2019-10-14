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

// I/O Space Address Map follow
#define SIOA_D              0x00
#define SIOA_C              0x02
#define SIOB_D              0x01
#define SIOB_C              0x03
#define FR_PNL_IO_LO        0x18    // decimal 24
#define FR_PNL_IO_LO_MID    0x19    // decimal 25
#define FR_PNL_IO_HI_MID    0x1A    // decimal 26
#define FR_PNL_IO_HI        0x1B    // decimal 27

// Function Prototypes follow

void HandleZ80IO(void);
void putBufferToZ80(uint16, uint8 buffer[]);
void ackIO(void);
void waitNextIORq(void);

/* [] END OF FILE */
