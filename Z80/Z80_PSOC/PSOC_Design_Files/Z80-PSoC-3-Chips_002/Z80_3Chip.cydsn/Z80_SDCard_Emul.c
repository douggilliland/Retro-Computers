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

/////////////////////////////////////////////////////////////////////////////////
// Routines to control SD and SDHC cards

#include <project.h>
#include <Z80_PSoC_3Chips.h>

#ifdef USING_SDCARD

volatile uint8 SD_DataOut;
volatile uint8 SD_DataIn;
volatile uint8 SD_Status;
volatile uint8 SD_Command;
volatile uint8 SD_LBA0_Val;
volatile uint8 SD_LBA1_Val;
volatile uint8 SD_LBA2_Val;
volatile uint8 SD_LBA3_Val;
volatile uint32 writeSectorNumber;

///////////////////////////////////////////////////////////////////////////////
// void SDReadData(void) - Read the data from the Z80 one byte at a time
// SD_DATA		.EQU	$88

void SDReadData(void)
{
	Z80_Data_In_Write(readSDBuffer[readPointer++]);
	if (readPointer == 512)
	{
		SD_Status = SD_CARD_READY;   // Read the last byte
		readPointer = 0;
	}
	ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void CFWriteData(void)
// SD_DATA		.EQU	$88
// The write of the 512th byte to the SD card holds the CPU in WAIT until done

void SDWriteData(void)
{
	if (writePointer < 512)
	{
		writeSDBuffer[writePointer++] = Z80_Data_Out_Read();    // put into the write buffer
		SD_Status = SD_CARD_TX_RDY;
	}
	if (writePointer == 512)    // triggger write after 512 bytes of data
	{
		SD_WriteSector(writeSectorNumber,writeSDBuffer);
		writePointer = 0;   // reset the write pointer when done
		SD_Status = SD_CARD_READY;
	}
	ackIO();    // Freeze Z80 until block write is done
}

///////////////////////////////////////////////////////////////////////////////
// void SDWriteCommand(void)
// SD_DATA		.EQU	$89
// In Grant's monitor code - 
// In 

void SDWriteCommand(void)
{
	SD_Command = Z80_Data_Out_Status;
	if (SD_Command == 0x00)         // Read command
	{
		ackIO();
		uint32 secNum = (SD_LBA3_Val << 24) | (SD_LBA2_Val << 16) | (SD_LBA1_Val << 8) | (SD_LBA0_Val);
		SD_ReadSector(secNum,readSDBuffer);
		SD_Status = SD_CARD_RX_READY;
		readPointer = 0;
	}
	else if (SD_Command == 0x01)    // Write command
	{
		writePointer = 0;
		readPointer = 0;
		writeSectorNumber = (SD_LBA3_Val << 24) | (SD_LBA2_Val << 16) | (SD_LBA1_Val << 8) | (SD_LBA0_Val);
		SD_Status = 160;
		ackIO();
	}
    else
    {
        ackIO();
    }
	return;
}

///////////////////////////////////////////////////////////////////////////////
// void SDReadStatus(void)
// SD_ERROR	.EQU	$89
// In Grant's monitor code - 
// In 

void SDReadStatus(void)
{
	Z80_Data_In_Control = SD_Status;
	ackIO();
	return;
}

///////////////////////////////////////////////////////////////////////////////
// void CFWriteLBA0(void)
// SD_LBA0		.EQU	$8A
// In Grant's monitor code 
// In 

void SDWriteLBA0(void)
{
	SD_LBA0_Val = Z80_Data_Out_Read();
	ackIO();
	return;
}

///////////////////////////////////////////////////////////////////////////////
// void CFWriteLBA1(void)
// SD_LBA1		.EQU	$8B
// In Grant's monitor code 
// In 

void    SDWriteLBA1(void)
{
	SD_LBA1_Val = Z80_Data_Out_Read();
	ackIO();
	return;
}

///////////////////////////////////////////////////////////////////////////////
// void CFWriteLBA2(void)
// SD_LBA2		.EQU	$8C
// In Grant's monitor code 
// In 

void    SDWriteLBA2(void)
{
	SD_LBA2_Val = Z80_Data_Out_Read();
	ackIO();
	return;
}

#endif

/* [] END OF FILE */
