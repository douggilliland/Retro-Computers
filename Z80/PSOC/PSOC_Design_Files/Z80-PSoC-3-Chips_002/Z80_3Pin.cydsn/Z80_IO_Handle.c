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
#include "Z80_IO_Handle.h"
#include "Z80_SIO_emul.h"
#include "Z80_PIO_emul.h"
#include "Z80_6850_Emul.h"
#include "Z80_CFCard_Emul.h"
#include "Hardware_Config.h"

void HandleZ80IO(void)
{
    volatile uint8 ioCrtlRegVal;
    volatile uint8 ioZ80Addr;
    
    ioCrtlRegVal = IO_Stat_Reg_Read();
#ifdef USING_SIO
    if ((ioCrtlRegVal & IACK_MASK) == IN_IACK_CYCLE)
    {
        SioReadIntRegB();
        return;
    }
#endif
#ifdef USING_6850
    if ((ioCrtlRegVal & IACK_MASK) == IN_IACK_CYCLE)
    {
        M6850ReadIntReg();
        return;
    }
#endif
    ioZ80Addr = AdrLowIn_Read();
    switch (ioZ80Addr)
    {
#ifdef USING_SIO
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
#endif
#ifdef USING_CFCARD
        case CF_DATA:           // 0x10
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadData();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteData();
            }
            break;
        case CF_FEATURES_ERROR: // 0x11
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadErrorStat();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteFeatures();
            }
            break;
        case CF_SECCOUNT:       // 0x12
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadSectorCount();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteSectorCount();
            }
            break;
        case CF_SECTOR_LAB0:    // 0x13
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadSector();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteLBA0();
            }
            break;
        case CF_CYL_LOW_LBA1:   // 0x14
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadCylLow();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteLBA1();
            }
            break;
        case CF_CYL_HI_LBA2:    // 0x15
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadCylHigh();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteLBA2();
            }
            break;
        case CF_HEAD_LBA3:    // 0x16
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadHead();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteLBA3();
            }
            break;
        case CF_STATUS_COMMAND: // 0x17
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
            {
                CFReadStatus();
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                CFWriteCommand();
            }
            break;
#endif
#ifdef USING_6850
        case M6850_D:
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
            {
                M6850ReadData();
                return;
            }
            else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                M6850WriteData();
                return;
            }
            break;
        case  M6850_C:    // Control register
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
            {
                M6850ReadStatus();
                return;
            }
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
            {
                M6850WriteCtrl();
                return;
            }
            break;
#endif
#ifdef USING_FRONT_PANEL
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
#endif
#ifdef USING_EXP_MCCP23017
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
#endif
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
