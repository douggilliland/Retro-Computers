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
	
	ioCrtlRegVal = IO_Stat_Reg_Status;
// Only 1 interrupt source in this configuration
// If there are more than 1 interrupt sources the code below could be replaced with priority encoder
#ifdef USING_SIO
	if ((ioCrtlRegVal & IACK_MASK) == IN_IACK_CYCLE)
	{
		SioReadIntRegB();
		return;
	}
#else
    #ifdef USING_6850
    	if ((ioCrtlRegVal & IACK_MASK) == IN_IACK_CYCLE)
    	{
    		M6850ReadIntReg();
    		return;
    	}
    #endif
#endif
	ioZ80Addr = AdrLowIn_Status;        // gets the I/O address that the Z80 is accessing
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
    #ifdef USING_FRONT_PANEL
    	case FR_PNL_IO_LO:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			FrontPanelZ80Read(0);
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			FrontPanelZ80Write(0);
    			break;
    		}
    		break;
        }
    	case FR_PNL_IO_LO_MID:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			FrontPanelZ80Read(1);
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			FrontPanelZ80Write(1);
    			break;
    		}
        }
    	case FR_PNL_IO_HI_MID:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			FrontPanelZ80Read(2);
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			FrontPanelZ80Write(2);
    			break;
    		}
        }
    	case FR_PNL_IO_HI:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			FrontPanelZ80Read(3);
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			FrontPanelZ80Write(3);
    			break;
    		}
        }
    #endif
    #ifdef USING_EXP_MCCP23017
    	case PIOA_D:
    	{
            if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
    		{
    			PioReadDataA();
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			PioWriteDataA();
    			break;
    		}
        }
    	case PIOA_C:    // Control register
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			PioWriteCtrlA();
    			break;
    		}
        }
    	case PIOB_D:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			PioReadDataB();
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			PioWriteDataB();
    			break;
    		}
        }
    	case PIOB_C:
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			PioWriteCtrlB();
    			break;
    		}
        }
    #endif
    #ifdef USING_MMU4_SWAP
        case MEM_MAP_SWAP_OUT:
        {
            ackIO();
            break;
        }
        case MEM_MAP_SWAP_BACK:
        {
            // Copy back the original code in the original BIOS here
            // This allows restarting the BIOS cleanly
            // Use busreq / busack to get ahold of the Z80 bus
            BUSRQ_n_Write(0);
            // ack the transfer
            ackIO();
            while (BUSACK_n_Read() == 1);
            // wait for busack
            loadSRAM();
            // Remove the busreq
            BUSRQ_n_Write(1);
            break;
        }
    #endif
    #ifdef USING_RTC
    	case RTC_DATA:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			readRTC();
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			writeRTC();
    		}
    		break;
        }
    	case RTC_CSR:
        {
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
        }
    #endif
    #ifdef USING_DAC
    	case DAC_CSR:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    		{
    			readStatDAC();
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			writeCmdDAC();
    		}
    		break;            
        }
    #endif
    #ifdef USING_6850
    	case M6850_D:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
    		{
    			M6850ReadData();
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			M6850WriteData();
    			break;
    		}
    	}
        case  M6850_C:    // Control register
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
    		{
    			M6850ReadStatus();
    			break;
    		}
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			M6850WriteCtrl();
    			break;
    		}
        }
        #ifdef MULTIBOOT_CPM
            case M6850_B:   // Baud rate register - do nothing in this configuration
            {
                    ackIO();
                    break;
            }
        #endif
    #endif
    #ifdef USING_6850_2
    	case M6850_2_D:
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
    		{
    			M6850_2_ReadData();
    			break;
    		}
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			M6850_2_WriteData();
    			break;
    		}
    		break;
        }
    	case  M6850_2_C:    // Control register
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)             // regular read cycle
    		{
    			M6850_2_ReadStatus();
    			break;
    		}
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			M6850_2_WriteCtrl();
    			break;
    		}
        }
            #ifdef MULTIBOOT_CPM
                case M6850_2_B: // Baud rate register - do nothing in this configuration
                    {
                        ackIO();
                        break;
                    }
            #endif
    #endif
    #ifdef USING_SDCARD
    	case SD_CONTROL: // 0x89 - write command also also includes read status
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    			SDReadStatus();
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    			SDWriteCommand();
    		break;
        }
        case SD_DATA:           // 0x88
        {
    		if (ioCrtlRegVal == REGULAR_READ_CYCLE)            // regular read cycle
    			SDReadData();
    		else if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    			SDWriteData();
    		break;
        }
    	case SD_LBA0:    // 0x8A
    	{
            if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    			SDWriteLBA0();
    		break;
        }
    	case SD_LBA1:   // 0x8B
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    			SDWriteLBA1();
    		break;
        }
    	case SD_LBA2:    // 0x8C
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			SDWriteLBA2();
    		}
    		break;
        }
    #endif
    #ifdef USING_MMU4
    	case MMUSELECT:
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			wrMMU4SelectReg();
    			break;
    		}
            break;
        case MMUFRAME:
            {
                wrMMU4Bank();
                break;
            }
        }
    #endif
    #ifdef USING_MEM_MAP_1
    	case MEM_MAP_SWAP:
        {
    		if (ioCrtlRegVal == REGULAR_WRITE_CYCLE)      // regular write cycle
    		{
    			swap_out_ROM_space();
    			break;
    		}
        }
    #endif
    	default:    // Handle other cases
        {
                    // If I ackIO() then it would makes cases which are not handled
            while(1);
    		break;
        }
    }
}

void ackIO(void)
{
	IO_Ctrl_Reg_Control = (IO_Ctrl_Reg_Control | CLR_IO_INT_BIT);
}

void waitNextIORq(void)
{
	while ((IO_Stat_Reg_Status & IOBUSY_BIT) == 0x00);
}


/* [] END OF FILE */
