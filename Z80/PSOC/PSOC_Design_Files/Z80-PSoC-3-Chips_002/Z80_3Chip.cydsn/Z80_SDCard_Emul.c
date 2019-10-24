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
    
    uint8 readSDBuffer[512];
    uint8 writeSDBuffer[512];

    ///////////////////////////////////////////////////////////////////////////////
    // void SDInit(void)
    // SPI mode 0 is used with SD Cards
    // Helpful description of SD card initialization
    //  http://www.dejazzer.com/ee379/lecture_notes/lec12_sd_card.pdf
    // Helfpul description of SD cards with SPI
    //  http://elm-chan.org/docs/mmc/mmc_e.html
    //  MISO pull-up done at PSoC pin with Resisitive pull-up
    // Very helpful worked four part tutorial of using SPI with SD cards on a Microprocessor
    //  https://codeandlife.com/2012/04/02/simple-fat-and-sd-tutorial-part-1/
    // Initialization sequence requires 74 clocks with SS high which means SS has to be
    //  high for the duration (using SS override control register).
        
    void SDInit(void)
    {
        SPI_Master_Start();

        // p 5 of http://www.dejazzer.com/ee379/lecture_notes/lec12_sd_card.pdf
        //
        // https://codeandlife.com/2012/04/25/simple-fat-and-sd-tutorial-part-3/
        // Send at least 74 clocks with SS and MOSI high
        
        SPI_SS_Override_Write(1);                   // Force SPI_SS line high
        for (uint8 loopCount = 0; loopCount < 10; loopCount++)
        {
            while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) == 0);
            SPI_Master_WriteTxData(0xff);   // Hang around while the FIFO is full
        }
        // Wait around for the FIFO to get empty
        while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) == 0x0);
        SPI_SS_Override_Write(0);                   // Allow the SPI_Master to control the SPI_SS line
        

        SD_command(0x40, 0x00000000, 0x95, 8);
        
        // Initialize the Z80 interface
        SD_DataOut = 0x0;
        SD_DataIn = 0x0;
        SD_Status = 0x0;
        SD_Command = 0x0;
        SD_LBA0_Val = 0x0;
        SD_LBA1_Val = 0x0;
        SD_LBA2_Val = 0x0;
        SD_LBA3_Val = 0x0;
        
        // Dummy fill the read/write buffers
        for (uint16 loopCount=0; loopCount<512; loopCount++)
        {
            readSDBuffer[loopCount] = (uint8)loopCount;
            writeSDBuffer[loopCount] = ~(uint8)loopCount;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    //
    
    void SD_command(unsigned char cmd, unsigned long arg, unsigned char crc, unsigned char read)
    {
    	unsigned char i;
    	SPI_write(cmd);
    	SPI_write(arg>>24);
    	SPI_write(arg>>16);
    	SPI_write(arg>>8);
    	SPI_write(arg);
    	SPI_write(crc);
    	for(i=0; i<read; i++)
    		SPI_write(0xFF);
        while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) == 0x0);
	}

    ///////////////////////////////////////////////////////////////////////////////
    // 
    
    void SPI_write(uint8 charToWrite)
    {
        while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) == 0);
        SPI_Master_WriteTxData(charToWrite);   // Hang around while the FIFO is full
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // void SDReadData(void)
    // SD_DATA		.EQU	$88
    // In Grant's monitor code - 
    // In 

    void SDReadData(void)
    {
        Z80_Data_In_Write(SD_DataIn);
        ackIO();
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteData(void)
    // SD_DATA		.EQU	$88
    // In Grant's monitor code - 
    // In 
        
    void SDWriteData(void)
    {
        SD_DataOut = Z80_Data_Out_Read();
        ackIO();
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void SDWriteCommand(void)
    // SD_DATA		.EQU	$89
    // In Grant's monitor code - 
    // In 
        
    void SDWriteCommand(void)
    {
        SD_Command = Z80_Data_Out_Read();
        ackIO();
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
    
    ///////////////////////////////////////////////////////////////////////////////
    // 
    
    void readSDCard(uint32 sectorNumber)
    {
        dumpBuffer(readSDBuffer);
    }

    ///////////////////////////////////////////////////////////////////////////////
    // dumpBuffer(uint8 *) - Dump a 512-byte buffer to the screen
    
    void dumpBuffer(uint8 * dumpBuffer)
    {
        char lineBuffer[8];
        lineBuffer[0] = 0;
        uint16 linesLoop = 0;
        uint16 charsLoop = 0;
        for (linesLoop = 0; linesLoop < 32; linesLoop++)
        {
            char lineString[65];    // The whole line buffered up
            lineString[0] = 0;
            sprintf(lineString,"%04x ",linesLoop<<4);
            for (charsLoop = 0; charsLoop < 16; charsLoop++)
            {
                sprintf(lineBuffer, " %02x",dumpBuffer[(linesLoop<<4)+charsLoop]);
                strcat(lineString, lineBuffer);
            }
            strcat(lineString, "  ");
            putStringToUSB(lineString);
            lineString[0] = 0;
            // Form a character string for the 
            for (uint16 charCol = 0; charCol < 16; charCol++)
            {
                // print if the char is printable
                if ((dumpBuffer[(linesLoop<<4)+charCol] >= 0x21) && (dumpBuffer[(linesLoop<<4)+charCol] <= 0x7E))
                {
                    lineString[charCol] = dumpBuffer[(linesLoop<<4)+charCol];
                }
                else
                {
                    lineString[charCol] = '.';
                }
                lineString[charCol+1] = 0;
            }
            strcat(lineString, "\n\r");
            putStringToUSB(lineString);
        }
    }

void putStringToUSB(char * stringToPutOutUSB)
{
	USBUART_PutData((uint8 *)stringToPutOutUSB, strlen(stringToPutOutUSB));
	while (0u == USBUART_CDCIsReady());
}

#endif

/* [] END OF FILE */
