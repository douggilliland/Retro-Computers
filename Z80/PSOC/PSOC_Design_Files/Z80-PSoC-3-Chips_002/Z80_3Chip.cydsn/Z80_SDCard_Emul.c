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

    ///////////////////////////////////////////////////////////////////////////////
    // void CFInit(void)
    // SPI mode 0 is used with SD Cards
    // Helpful description of SD card initialization
    //  http://www.dejazzer.com/ee379/lecture_notes/lec12_sd_card.pdf
    // Helfpul description of SD cards with SPI
    //  http://elm-chan.org/docs/mmc/mmc_e.html
    //  MISO pull-up done at PSoC pin with Resisitive pull-up
    // Initialization sequence requires 74 clocks with SS high which means SS has to be
    //  controlled by the program, not the SPI_Master element.
        
    void SDInit(void)
    {
        SPI_SS_SetDriveMode(SPI_SS_DM_STRONG);
        SPI_SS_Override_Write(1);                            // Set the Slave select line high
        SPI_Master_Start();
        // Send at least 74 clocks with SS and MOSI high
        for (uint8 loopCount = 0; loopCount < 10; loopCount++)
        {
            while ((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_NOT_FULL) == 0);
            SPI_Master_WriteTxData(0xff);
        }
        while((SPI_Master_ReadTxStatus() & SPI_Master_STS_TX_FIFO_EMPTY) == 0x0);
        SPI_SS_Override_Write(0);                            // Allow the SPI_Master to control the SPI_SS line
        // Initialize the Z80 interface
        SD_DataOut = 0x0;
        SD_DataIn = 0x0;
        SD_Status = 0x0;
        SD_Command = 0x0;
        SD_LBA0_Val = 0x0;
        SD_LBA1_Val = 0x0;
        SD_LBA2_Val = 0x0;
        SD_LBA3_Val = 0x0;
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

#endif

/* [] END OF FILE */
