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
        for (uint16 loopCount=0; loopCount<512; loopCount++)
        {
            readSDBuffer[loopCount] = (uint8)loopCount;
            writeSDBuffer[loopCount] = ~(uint8)loopCount;
        }

        // p 5 of http://www.dejazzer.com/ee379/lecture_notes/lec12_sd_card.pdf
        //
        // https://codeandlife.com/2012/04/25/simple-fat-and-sd-tutorial-part-3/
        // Init and go to SPI mode: ]r:10 [0x40 0x00 0x00 0x00 0x00 0x95 r:8]
        
        // Send at least 74 clocks with SS and MOSI high
        SPI_SS_Override_Write(1);                   // Force SPI_SS line high
        SPI_Master_Start();
        for (uint8 loopCount = 0; loopCount < 10; loopCount++)
        {
            while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) == 0);
            SPI_Master_WriteTxData(0xff);   // Hang around while the FIFO is full
        }
        // Wait around for the FIFO to get empty
        while((SPI_Master_ReadTxStatus() & SPI_Master_TX_FIFO_CLR) != SPI_Master_TX_FIFO_CLR);
        SPI_SS_Override_Write(0);                   // Allow the SPI_Master to control the SPI_SS line
        CyDelayUs(10);
        SPI_Master_ClearRxBuffer();
        
        // Initialize card: [0x41 0x00 0x00 0x00 0x00 0xFF r:8]
    	for(iter=0; iter<10 && SD_command(0x40, 0x00000000, 0x95, 8) != 1; iter++)
    		CyDelay(100);
        
        // Set transfer size: [0x50 0x00 0x00 0x02 0x00 0xFF r:8]
    	for(iter=0; iter<10 && SD_command(0x41, 0x00000000, 0xFF, 8) != 0; iter++)
    		CyDelay(100);
        
        // Read sector: [0x51 0x00 0x00 0x00 0x00 0xFF r:520]
        SD_command(0x50, 0x00000200, 0xFF, 8);
        
        // Initialize the Z80 interface
        SD_DataOut = 0x0;
        SD_DataIn = 0x0;
        SD_Command = 0x0;
        SD_LBA0_Val = 0x0;
        SD_LBA1_Val = 0x0;
        SD_LBA2_Val = 0x0;
        SD_LBA3_Val = 0x0;
        SD_Status = 0x80;   // Set to SD card ready  
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // void SD_command(uint8 cmd, uint32 arg, uint8 crc, uint8 read)
    
    uint8 SD_command(uint8 cmd, uint32 arg, uint8 crc, uint8 read)
    {
    	uint8 i;
        uint8 readChar;
        uint8 gotDone=0xFF;
    	SPI_write(cmd);
    	SPI_write(arg>>24);
    	SPI_write(arg>>16);
    	SPI_write(arg>>8);
    	SPI_write(arg);
    	SPI_write(crc);
        while((SPI_Master_ReadTxStatus() & SPI_Master_TX_FIFO_CLR) != SPI_Master_TX_FIFO_CLR);
        CyDelayUs(20);
    	for(i=0; i<read; i++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_RX_FIFO_CLR) == SPI_Master_RX_FIFO_CLR);
    		readChar = SPI_Master_ReadRxData();
            if (readChar != 0xFF)
                gotDone = readChar;
        }
        return(gotDone);
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

    ///////////////////////////////////////////////////////////////////////////////
    // 
    
    void readSDCard(uint32 sectorNumber)
    {
        SD_readSector(sectorNumber, readSDBuffer);
        dumpBuffer(readSDBuffer);
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void SD_readSector(uint32 sector, uint8 * buffPtr)
    
    void SD_readSector(uint32 sector, uint8 * buffPtr)
    {
        uint16 loopCount = 0;
        volatile uint8 junk;
    	SPI_write(CMD17);
    	SPI_write(sector>>15);
    	SPI_write(sector>>7);
    	SPI_write(sector<<1);
    	SPI_write(0);
    	SPI_write(0xFF);
        while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
        SPI_Master_ClearFIFO();
        CyDelayUs(20);
        // wait for 0
    	for(loopCount=0; loopCount<100; loopCount++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		if (SPI_Master_ReadRxData() == 0)
                break;
        }
        // wait for 0xFE
    	for(loopCount=0; loopCount<100; loopCount++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		if (SPI_Master_ReadRxData() == 0xFE)
                break;
        }
    	for(loopCount=0; loopCount<512; loopCount++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		buffPtr[loopCount] = SPI_Master_ReadRxData();
        }
        
    	SPI_write(0xFF);
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		junk = SPI_Master_ReadRxData();
        
    	SPI_write(0xFF);
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		junk = SPI_Master_ReadRxData();
        
        //   Command(0X4C,0X00000000,0X00); //COMMAND12. Stop To Read
        // proceed();
        //  do{  
        //    buff = response();
        //  }while(buff!=0xFF);
//    	SPI_write(CMD12);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//    	SPI_write(0x00);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//    	SPI_write(0x00);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//    	SPI_write(0x00);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//    	SPI_write(0x00);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//    	SPI_write(0x00);
//      while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
// 		junk = SPI_Master_ReadRxData();
//      do
//      {
//        	SPI_write(0xFF);
//          while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
//    		junk = SPI_Master_ReadRxData();
//      }
//      while(junk!=0xFF);
//      return;
	}

    ///////////////////////////////////////////////////////////////////////////////
    // void sdWriteSector(uint32 sector, uint8 * buffPtr)
    // Write a 512-byte sector to the SD card
    
    void SD_WriteSector(uint32 sector, uint8 * buffPtr)
    {
        uint16 loopCount = 0;
        uint8 junk;
    	SPI_write(CMD24);            // CMD24
    	SPI_write(sector>>15);
    	SPI_write(sector>>7);
    	SPI_write(sector<<1);
    	SPI_write(0);
    	SPI_write(0xFF);
        while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) != SPI_Master_STS_TX_FIFO_EMPTY);
        SPI_Master_ClearFIFO();
        CyDelayUs(20);
        // wait for 0
    	for(loopCount=0; loopCount<100; loopCount++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		if (SPI_Master_ReadRxData() == 0)
                break;
        }
        // wait for 0xFE
    	for(loopCount=0; loopCount<100; loopCount++)
        {
        	SPI_write(0xFF);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		if (SPI_Master_ReadRxData() == 0xFE)
                break;
        }
        // write 512-bytes
    	for(loopCount=0; loopCount<512; loopCount++)
        {
        	SPI_write(buffPtr[loopCount++]);
            while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
    		junk = SPI_Master_ReadRxData();
        }
        
    	SPI_write(0xFF);
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		junk = SPI_Master_ReadRxData();
        
    	SPI_write(0xFF);
        while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
		junk = SPI_Master_ReadRxData();
        
        // Command(0x4D,0X00000000,0XFF);
        // proceed();
        // do{  
        //   buff = response();
        // }while(buff!=0x00);
//    	SPI_write(CMD13);        // CMD13
//    	SPI_write(0x00);
//    	SPI_write(0x00);
//    	SPI_write(0x00);
//    	SPI_write(0x00);
//    	SPI_write(0xFF);
//        junk = 0xff;
//        while(junk!=0x00)
//        {
//        	SPI_write(0xFF);
//          while ((SPI_Master_ReadRxStatus() & SPI_Master_STS_RX_FIFO_NOT_EMPTY) != SPI_Master_STS_RX_FIFO_NOT_EMPTY);
//    		junk = SPI_Master_ReadRxData();
//        }
        return;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // void SPI_write(uint8 charToWrite) - Write a byte to the SPI bus
    // Waits until the transmit FIFO is not full before writing
    
    void SPI_write(uint8 charToWrite)
    {
        // Hang around while the FIFO is full
        while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) != SPI_Master_STS_TX_FIFO_NOT_FULL);
        SPI_Master_WriteTxData(charToWrite);
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // void SDReadData(void)
    // SD_DATA		.EQU	$88
    // In Grant's monitor code - 
    // In 

    void SDReadData(void)
    {
        Z80_Data_In_Write(readSDBuffer[readPointer++]);
        if (readPointer == 512)
            SD_Status = 0x80;   // Read the last byte
        ackIO();
    }

    ///////////////////////////////////////////////////////////////////////////////
    // void CFWriteData(void)
    // SD_DATA		.EQU	$88
    // In Grant's monitor code - 
    // In 
        
    void SDWriteData(void)
    {
        writeSDBuffer[writePointer++] = Z80_Data_Out_Read();
        ackIO();
        if (writePointer > 511)
            writePointer = 511;
        return;
    }


/* [] END OF FILE */
