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
#include "stdio.h"
#include <Z80_PSoC_3Chips.h>

uint16 readPointer;
uint16 writePointer;

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
    uint8 iter;
    // Dummy fill the read/write buffers
    // Read buffer is initialized with data = address
    // Write buffere is initialized with data = ~address
    for (uint16 loopCount=0; loopCount<512; loopCount++)
    {
        readSDBuffer[loopCount] = ~(uint8)(loopCount);
        writeSDBuffer[loopCount] = (uint8)loopCount;
    }

    // p 5 of http://www.dejazzer.com/ee379/lecture_notes/lec12_sd_card.pdf
    //
    // https://codeandlife.com/2012/04/25/simple-fat-and-sd-tutorial-part-3/
    // Init and go to SPI mode: ]r:10 [0x40 0x00 0x00 0x00 0x00 0x95 r:8]
    
    // Send at least 74 clocks with SS and MOSI high
    SPI_SS_Out_Write(1);                   // Force SPI_SS line high
    SPI_Master_Start();
    for (uint8 loopCount = 0; loopCount < 10; loopCount++)
    {
        // Hang around while the FIFO is full
        while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) == 0);
        SPI_Master_WriteTxData(0xff);   
    }
    // Wait around for the Tx FIFO to get empty
    while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
    SPI_Master_ClearRxBuffer();
    SPI_SS_Out_Write(0);                   // Allow the SPI_Master to control the SPI_SS line
    
    // Init and go to SPI mode: ]r:10 [0x40 0x00 0x00 0x00 0x00 0x95 r:8]
    // 100 mS delay between tries
	for(iter=0; iter<10 && SD_command(0x40, 0x00000000, 0x95, 8) != 1; iter++)
		CyDelay(100);
    
    // Initialize card: [0x41 0x00 0x00 0x00 0x00 0xFF r:8]
    // 100 mS delay between tries
	for(iter=0; iter<10 && SD_command(0x41, 0x00000000, 0xFF, 8) != 0; iter++)
		CyDelay(100);
    
    // Set transfer size: [0x50 0x00 0x00 0x02 0x00 0xFF r:8]
    // 100 mS delay between tries
    SD_command(0x50, 0x00000200, 0xFF, 8);
    
    // Set the read and write pointers to the start of the buffers at the start
    readPointer = 0;
    writePointer = 0;
    
    // Initialize the Z80 SD card interface
    // CP/M expects the SD_Status to be 0x80 when the card has been initialized
    SD_DataOut = 0x0;
    SD_DataIn = 0x0;
    SD_Command = 0x0;
    SD_LBA0_Val = 0x0;
    SD_LBA1_Val = 0x0;
    SD_LBA2_Val = 0x0;
    SD_LBA3_Val = 0x0;
    while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_SPI_DONE) != SPI_Master_STS_SPI_DONE);
    SPI_Master_ClearFIFO();
    SPI_SS_Out_Write(1);
    SD_Status = 0x80;   // Set to SD card ready  
}

///////////////////////////////////////////////////////////////////////////////
// void SD_command(uint8 cmd, uint32 arg, uint8 crc, uint8 timeOutCount)

uint8 SD_command(uint8 cmd, uint32 arg, uint8 crc, uint8 timeOutCount)
{
    uint8 readChar;
    uint8 gotDone=0xFF;
    
	SPI_write_byte(cmd);
	SPI_write_byte(arg>>24);
	SPI_write_byte(arg>>16);
	SPI_write_byte(arg>>8);
	SPI_write_byte(arg);
	SPI_write_byte(crc);
    // Wait around for the Tx FIFO to get empty
    while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
    CyDelayUs(20);
	for(uint8 i=0; i<timeOutCount; i++)
    {
    	SPI_write_byte(0xFF);
        // Wait around for a receive character
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		readChar = SPI_Master_ReadRxData();
        if (readChar != 0xFF)
            gotDone = readChar;
    }
    return(gotDone);
}

///////////////////////////////////////////////////////////////////////////////
// void SPI_write_byte(uint8 charToWrite) - Write a byte to the SPI bus
// Waits until the transmit FIFO is not full before writing

void SPI_write_byte(uint8 charToWrite)
{
    // Wait until the FIFO is not full (should not be a this point)
    while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) != SPI_Master_STS_TX_FIFO_NOT_FULL);
    SPI_Master_WriteTxData(charToWrite);
    return;
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
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void readSDCard(uint32 sectorNumber) - Read a sector of the SD card into 
// the readSDBuffer

void readSDCard(uint32 sectorNumber)
{
    SD_ReadSector(sectorNumber, readSDBuffer);
    dumpBuffer(readSDBuffer);
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void writeSDCard(uint32 sectorNumber) - Write a sector of the SD card from 
// the writeSDBuffer.
// Read the sector back and dump it to the serial port.

void writeSDCard(uint32 sectorNumber)
{
    uint8 retVal;
    char lineBuffer[8];
    retVal = SD_WriteSector(sectorNumber, writeSDBuffer);
    if (retVal != 0)
    {
        putStringToUSB("Error writing to the SD Card\n\rError - ");
        sprintf(lineBuffer,"%02x\n\r",retVal);
        putStringToUSB(lineBuffer);
        return;
    }
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void SD_ReadSector(uint32 sector, uint8 * buffPtr)

void SD_ReadSector(uint32 sector, uint8 * buffPtr)
{
    uint16 loopCount = 0;
    volatile uint8 junk;
    SPI_SS_Out_Write(0);
	SPI_write_byte(CMD17);
	SPI_write_byte(sector>>15); // >>24 + <<9 = >>15
	SPI_write_byte(sector>>7);  // >>16 + <<9 = >>7
	SPI_write_byte(sector<<1);  // >>8 + <<9 = <<1
	SPI_write_byte(0);          // bottom bits are 0's
	SPI_write_byte(0xFF);
    // wait for 0 to be returned on the SPI bus
	for(loopCount=0; loopCount<100; loopCount++)
    {
    	SPI_write_byte(0xFF);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
        // Wait for receive character to be present
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		if (SPI_Master_ReadRxData() == 0)
            break;
    }
    // wait for 0xFE to be returned on the SPI bus
	for(loopCount=0; loopCount<100; loopCount++)
    {
    	SPI_write_byte(0xFF);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
        // Wait for receive character to be present
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		if (SPI_Master_ReadRxData() == 0xFE)
            break;
    }
	for(loopCount=0; loopCount<512; loopCount++)    // load into the receive buffer
    {
    	SPI_write_byte(0xFF);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
        // Wait for receive character to be present
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		buffPtr[loopCount] = SPI_Master_ReadRxData();
    }
    // Do 2 dummy reads at the end
	SPI_write_byte(0xFF);
    while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
	junk = SPI_Master_ReadRxData();
    
	SPI_write_byte(0xFF);
    while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
	junk = SPI_Master_ReadRxData();
    SPI_SS_Out_Write(1);
    
	SPI_write_byte(0xFF);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
    // Wait for receive character to be present
    while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
	SPI_Master_ReadRxData();
        
    return;
}

///////////////////////////////////////////////////////////////////////////////
// void SD_WriteSector(uint32 sector, uint8 * buffPtr)
// Write a 512-byte sector to the SD card
// The top byte of the sector number is in d15..d22
// 0x200000 is: b'0010 0000 0000 0000 0000
// A 1111 1111 1100 0000 0000
// A 9876 5432 1098 7654 3210
// S 0010 0000 0000 0000 0000
// U 0010 0                     = 0x04
// M       000 0000 0           = 0x00
// L              0 0000 000    = 0x00

uint8 SD_WriteSector(uint32 sector, uint8 * buffPtr)
{
    uint8 breakOut = 0;
    uint16 loopCount = 0;
    uint8 junk;
    SPI_Master_ClearFIFO();
    SPI_SS_Out_Write(0x0);
    SPI_write_byte(CMD24);      // CMD24
	SPI_write_byte(sector>>15); // >>24 + <<9 = >>15
	SPI_write_byte(sector>>7);  // >>16 + <<9 = >>7
	SPI_write_byte(sector<<1);  // >>8 + <<9 = <<1
	SPI_write_byte(0);          // bottom bits are 0's
	SPI_write_byte(0xFF);
    // Wait until the entire transmit buffer has been sent out
//    while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
    // Clear the buffers next
//    SPI_Master_ClearFIFO();
//    SPI_Master_ClearRxBuffer();

    // wait for 0 to be returned on the SPI bus
	for(loopCount=0; ((breakOut == 0) & (loopCount<20)); loopCount++)
    {
        while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
    	SPI_write_byte(0xFF);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
        // Wait for receive character to be present
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) == SPI_Master_STS_RX_FIFO_NOT_EMPTY)
        {
            junk = SPI_Master_ReadRxData();
       		if (junk != 0xFF)
            {
                if (junk == 0x00)
                    breakOut = 1;
                else
                {
                    SPI_SS_Out_Write(0x1);
                    return(junk);
                }
            }
        }
        if (breakOut == 0)
            break;
    }
  	SPI_write_byte(0x00);   // Shift in dummy 1's into the transit causes receive clocks on the SPI
    // write 512-bytes
	for(loopCount=0; loopCount<512; loopCount++)
    {
    	SPI_write_byte(buffPtr[loopCount]);
        // Wait until the 8bits come back to know the transmit was done
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) == SPI_Master_STS_RX_FIFO_NOT_EMPTY)
    		junk = SPI_Master_ReadRxData();
    }
    
	SPI_write_byte(0xFF);
    while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
	junk = SPI_Master_ReadRxData();
    
	SPI_write_byte(0xFF);
    while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
	junk = SPI_Master_ReadRxData();

    while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_SPI_DONE) != SPI_Master_STS_SPI_DONE);
    SPI_Master_ClearFIFO();
    SPI_SS_Out_Write(1);
    SDInit();
    return (0);
}

/* [] END OF FILE */
