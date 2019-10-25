/*******************************************************************************
* File Name: main.c
*
* Version: 1.10
*
* Description:
*  This is source code for example project of the SCB in SPI
*  (Master, Slave) modes.
*  Parameters used:
*   Mode               (CPHA = 0, CPOL = 0)
*   Bit order           MSB First
*   TX/RX data bits     8 
*   TX/RX buffer size   16
*   Data rate           1Mbit/s
*
*  SCB in SPI mode communication test using software buffer. 
*  16 bytes are transmitted between SPI Master and SPI Slave.
*  Received data are displayed on LCD. 
*
********************************************************************************
* Copyright 2013, Cypress Semiconductor Corporation. All rights reserved.
* This software is owned by Cypress Semiconductor Corporation and is protected
* by and subject to worldwide patent and copyright laws and treaties.
* Therefore, you may use this software only as provided in the license agreement
* accompanying the software package from which you obtained this software.
* CYPRESS AND ITS SUPPLIERS MAKE NO WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
* WITH REGARD TO THIS SOFTWARE, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT,
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
*******************************************************************************/

#include <device.h>

void main()
{
   uint8 i = 0u;
    
    /* 
    * Software buffers use internal interrupt functionality to interact with
    * hardware buffers. Thus global interrupt enable command is called.
    */
    CyGlobalIntEnable;
    
    /* We need to start Character LCD, SPI Master and Slave components */
    LCD_Start();
    SPIM_Start();
    SPIS_Start();
    
    /* Writing data into the SPIS TX software buffer */
    SPIS_SpiUartWriteTxData(0x11u);
    SPIS_SpiUartWriteTxData(0x22u);
    SPIS_SpiUartWriteTxData(0x33u);
    SPIS_SpiUartWriteTxData(0x44u);
    SPIS_SpiUartWriteTxData(0x55u);
    SPIS_SpiUartWriteTxData(0x66u);
    SPIS_SpiUartWriteTxData(0x77u);
    SPIS_SpiUartWriteTxData(0x88u);
    
    SPIM_ClearMasterInterruptSource(SPIM_INTR_MASTER_SPI_DONE);
     
    /* Writing data into the SPIM software buffer */
    SPIM_SpiUartWriteTxData(0x99u);
    SPIM_SpiUartWriteTxData(0xAAu);
    SPIM_SpiUartWriteTxData(0xBBu);
    SPIM_SpiUartWriteTxData(0xCCu);
    SPIM_SpiUartWriteTxData(0xDDu);
    SPIM_SpiUartWriteTxData(0xEEu);
    SPIM_SpiUartWriteTxData(0xFFu);
    SPIM_SpiUartWriteTxData(0x12u);
    

    /* 
    * We need to know the moment when SPI communication is completed
    * to display received data. SPIM_INTR_MASTER_SPI_DONE status should be polled. 
    */
    while(0u == (SPIM_GetMasterInterruptSource() & SPIM_INTR_MASTER_SPI_DONE))
    {
        /* Wait while Master completes transaction */
    }
    
    /* SPI communication is complete so we can display received data */
    LCD_Position(0u, 0u);
    LCD_PrintString("SPIM Rx data:");
    
    LCD_Position(1u, 0u);
    for(i=0u; i<8u; i++)
    {
        /* Read from SPIM RX software buffer */
        LCD_PrintHexUint8(SPIM_SpiUartReadRxData());
    }
    
    CyDelay(4000u);
    LCD_ClearDisplay();
    
    LCD_Position(0u, 0u);
    LCD_PrintString("SPIS Rx data:");
    
    LCD_Position(1u, 0u);
    for(i=0u; i<8u; i++)
    {
        /* Read data from SPIS RX software buffer */
        LCD_PrintHexUint8(SPIS_SpiUartReadRxData());
    }
    
    for(;;)
    {
        /* End of example project */
    }
}

/* [] END OF FILE */
