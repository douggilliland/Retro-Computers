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
#include <Z80_PSoC_3Chips.h>

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
	ioZ80Addr = AdrLowIn_Read();        // gets the I/O address that the Z80 is accessing
	switch (ioZ80Addr)                  // call appropriate functions based on the address
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
	case RTC_DATA:
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			readRTC();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			writeRTC();
		}
		break;
	case RTC_CSR:
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			readCmdRTC();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			writeCmdRTC();
		}
		break;            
	case DAC_DATA:
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			readDAC();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			writeDAC();
		}
		break;
	case DAC_CSR:
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			readStatDAC();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			writeCmdDAC();
		}
		break;            
#ifdef USING_SDCARD
	case SD_CONTROL: // 0x89 - write command also also includes read status
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			SDReadStatus();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			SDWriteCommand();
		}
		break;
	case SD_DATA:           // 0x88
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
		{
			SDReadData();
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			SDWriteData();
		}
		break;
	case SD_LBA0:    // 0x8A
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			SDWriteLBA0();
		}
		break;
	case SD_LBA1:   // 0x8B
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			SDWriteLBA1();
		}
		break;
	case SD_LBA2:    // 0x8C
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			SDWriteLBA2();
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
        #ifdef MULTIBOOT_CPM
        case M6850_B:   // Baud rate register - do nothing in this configuration
            {
                ackIO();
            }
            break;
        #endif
#endif
#ifdef USING_6850_2
	case M6850_2_D:
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
		{
			M6850_2_ReadData();
			return;
		}
		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			M6850_2_WriteData();
			return;
		}
		break;
	case  M6850_2_C:    // Control register
		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
		{
			M6850_2_ReadStatus();
			return;
		}
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			M6850_2_WriteCtrl();
			return;
		}
		break;
        #ifdef MULTIBOOT_CPM
        case M6850_2_B: // Baud rate register - do nothing in this configuration
            {
                ackIO();
            }
            break;
        #endif
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
#ifdef USING_MEM_MAP_1
	case MEM_MAP_SWAP:
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			swap_out_ROM_space();
			return;
		}
#endif
#ifdef USING_MMU4
	case MMUSELECT:
		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
		{
			wrMMU4SelectReg();
			return;
		}
        break;
    case MMUFRAME:
        {
            wrMMU4Bank();
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
			PioWriteDataB();
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
                // If I ackIO() then it would makes cases which are not handled
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
