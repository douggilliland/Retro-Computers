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
#include "Z80_IO_Handle.h"
#include "Z80_SIO_emul.h"
#include "Z80_PIO_emul.h"

#include "FrontPanel.h"

void HandleZ80IO(void)
{
    volatile uint8 ioCrtlRegVal;
    volatile uint8 ioZ80Addr;
    
    ioCrtlRegVal = IO_Stat_Reg_Read();
    if ((ioCrtlRegVal & IACK_MASK) == IN_IACK_CYCLE)
    {
        SioReadIntRegB();
        return;
    }
    ioZ80Addr = AdrLowIn_Read();
    switch (ioZ80Addr)
    {
        case SIOA_D:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
            {
                SioReadDataA();
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                SioWriteDataA();
                return;
            }
            break;
        case SIOA_C:    // Control register
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                SioWriteCtrlA();
                return;
            }
            break;
        case SIOB_D:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                SioReadDataB();
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                SioWriteDataB();
                return;
            }
            break;
        case SIOB_C:
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                SioWriteCtrlB();
                return;
            }
            break;
        case FR_PNL_IO_LO:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                FrontPanelZ80Read(0);
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                FrontPanelZ80Write(0);
                return;
            }
            break;
        case FR_PNL_IO_LO_MID:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                FrontPanelZ80Read(1);
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                FrontPanelZ80Write(1);
                return;
            }
            break;
        case FR_PNL_IO_HI_MID:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                FrontPanelZ80Read(2);
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                FrontPanelZ80Write(2);
                return;
            }
            break;
        case FR_PNL_IO_HI:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                FrontPanelZ80Read(3);
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                FrontPanelZ80Write(3);
                return;
            }
            break;
        case PIOA_D:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
            {
                PioReadDataA();
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                PioWriteDataA();
                return;
            }
            break;
        case PIOA_C:    // Control register
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                PioWriteCtrlA();
                return;
            }
            break;
        case PIOB_D:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                PioReadDataB();
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                SioWriteDataB();
                return;
            }
            break;
        case PIOB_C:
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                PioWriteCtrlB();
                return;
            }
            break;
        default:    // Handle other cases
            break;
    }
}

void ackIO(void)
{
    IO_Ctrl_Reg_Write(IO_Ctrl_Reg_Read() | CLR_IO_INT_BIT);
}

void waitNextIORq(void)
{
    while ((IO_Stat_Reg_Read() & IOBUSY_BIT) == 0x00);
}


/* [] END OF FILE */
