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
#include "Z80_IO_Handle.h"
#include "Z80_SIO_emul.h"
#include "FrontPanel.h"

void HandleZ80IO(void)
{
    volatile uint8 ioCrtlRegVal;
    volatile uint8 ioZ80Addr;
    
    ioCrtlRegVal = IO_Stat_Reg_Read();
    if ((ioCrtlRegVal & 0x19) == 0x10)
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
                FrontPanelZ80Read(0);
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                FrontPanelZ80Write(0);
                return;
            }
            break;
        case FR_PNL_IO_HI_MID:
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
        case FR_PNL_IO_HI:
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
        default:    // Handle other cases
            break;
    }
}

void putBufferToZ80(uint16 count, uint8 buffer[])
{
    
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
