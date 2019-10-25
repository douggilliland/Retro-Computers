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
#include "stdio.h"
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
    
///////////////////////////////////////////////////////////////////////////////
// void SDReadData(void)
// SD_DATA		.EQU	$88

void SDReadData(void)
{
    Z80_Data_In_Write(readSDBuffer[readPointer++]);
    if (readPointer == 512)
        SD_Status = 0x80;   // Read the last byte
    ackIO();
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void CFWriteData(void)
// SD_DATA		.EQU	$88
    
void SDWriteData(void)
{
    writeSDBuffer[writePointer++] = Z80_Data_Out_Read();
    ackIO();
    if (writePointer > 511)
        writePointer = 511;
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void SDWriteCommand(void)
// SD_DATA		.EQU	$89
// In Grant's monitor code - 
// In 
    
void SDWriteCommand(void)
{
    uint32 secNum;
    SD_Command = Z80_Data_Out_Read();
    if (SD_Command == 0x00)
    {
        ackIO();
        secNum = (SD_LBA3_Val << 24) | (SD_LBA2_Val << 16) | (SD_LBA1_Val << 8) | (SD_LBA0_Val);
        SD_readSector(secNum,readSDBuffer);
        readPointer = 0;
        SD_Status = 224;
    }
    else if (SD_Command == 0x01)
    {
        secNum = (SD_LBA3_Val << 24) | (SD_LBA2_Val << 16) | (SD_LBA1_Val << 8) | (SD_LBA0_Val);
        SD_WriteSector(secNum,writeSDBuffer);
        readPointer = 0;
        SD_Status = 160;
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
    Z80_Data_In_Write(SD_Status);
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
    
void putStringToUSB(char * stringToPutOutUSB)
{
	USBUART_PutData((uint8 *)stringToPutOutUSB, strlen(stringToPutOutUSB));
	while (0u == USBUART_CDCIsReady());
}

#endif

/* [] END OF FILE */
