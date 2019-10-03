/*******************************************************************************
* File Name: I2C_BOOT.c
* Version 3.50
*
* Description:
*  This file provides the source code of the bootloader communication APIs for the
*  I2C component.
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "I2C_PVT.h"

#if defined(CYDEV_BOOTLOADER_IO_COMP) && (I2C_BOOTLOADER_INTERFACE_ENABLED)


/***************************************
*    Bootloader Internal Variables
***************************************/

/* I2C write buffer - The host writes commands here */
static uint8 XDATA I2C_slReadBuf[I2C_BTLDR_SIZEOF_READ_BUFFER];

/* I2C read buffer - The host reads responses from it */
static uint8 XDATA I2C_slWriteBuf[I2C_BTLDR_SIZEOF_WRITE_BUFFER];


/*******************************************************************************
* Function Name: I2C_CyBtldrCommStart
********************************************************************************
*
* Summary:
*  Starts the communication component and enables the interrupt.
*  The read buffer initial state is full and the read always is 0xFFu.
*  The write buffer is clear and ready to receive a commmand.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Side Effects:
*  This function enables the component interrupt. If I2C is enabled
*  without the interrupt enabled, it can lock up the I2C bus.
*
* Global variables:
*  I2C_slWriteBuf - The global variable used to store a received
*                                command.
*  I2C_slReadBuf -  The global variable used to store a response.
*  I2C_slRdBufIndex - The global variable used to store a current
*                                  index within the slave read buffer.
*
*******************************************************************************/
void I2C_CyBtldrCommStart(void) CYSMALL 
{
    /* Read returns 0xFF when buffer is zero. Write transaction is expected. */
    I2C_SlaveInitWriteBuf(I2C_slWriteBuf, I2C_BTLDR_SIZEOF_WRITE_BUFFER);
    I2C_SlaveInitReadBuf (I2C_slReadBuf, 0u);

    I2C_Start();
}


/*******************************************************************************
* Function Name: I2C_CyBtldrCommStop
********************************************************************************
*
* Summary:
*  Disables the communication component and disables the interrupt.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void I2C_CyBtldrCommStop(void) CYSMALL 
{
    I2C_Stop();
}


/*******************************************************************************
* Function Name: I2C_CyBtldrCommReset
********************************************************************************
*
* Summary:
*  Set buffers to the initial state and reset the statuses.
*  The read buffer initial state is full and the read always is 0xFFu.
*  The write buffer is clear and ready to receive a command.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  I2C_slRdBufIndex - The global variable used to store a current
*                                  index within the slave read buffer.
*
*******************************************************************************/
void I2C_CyBtldrCommReset(void) CYSMALL 
{
    /* Make Read buffer full */
    I2C_slRdBufSize = 0u;

    /* Reset Write buffer and Read buffer */
    I2C_slRdBufIndex = 0u;
    I2C_slWrBufIndex = 0u;

    /* Clear read and write status */
    I2C_slStatus = 0u;
}


/*******************************************************************************
* Function Name: I2C_CyBtldrCommWrite
********************************************************************************
*
* Summary:
*  Transmits the status of executed command to the Host.
*  The function updates the I2C read buffer with response and realeases it to
*  the host. All reads return 0xFF till the buffer will be released. All bytes
*  are transfered by the I2C ISR.
*  The function waits with timeout till all bytes will be read.
*  After exist this function the reads return 0xFF.
*
* Parameters:
*  pData:    pointer to data buffer with response command.
*  size:     number of bytes required to be transmitted.
*  count:    actual size of data was transmitted.
*  timeOut:  timeout value in tries of 10uS.
*
* Return:
*  The status of transmit operation.
*
* Global variables:
*  I2C_slReadBuf - The global variable used to store a response.
*  I2C_slRdBufIndex - The global variable used to store a current
*                                  index within the slave read buffer.
*
*******************************************************************************/
cystatus I2C_CyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 * count, uint8 timeOut) CYSMALL
         
{
    cystatus status;
    uint16 timeoutMs;

    status = CYRET_BAD_PARAM;

    if((NULL != pData) && (size > 0u))
    {
        status = CYRET_TIMEOUT;
        timeoutMs = ((uint16) 10u * timeOut);  /* Convert from 10mS check to 1mS checks */

        /* Copy pData to component buffer */
        (void) memcpy((void *) I2C_slReadBuf, (void *) pData, size);
        *count = size;  /* Buffer was copied to I2C buffer */

        /* Buffer is free to be read */
        I2C_slRdBufSize = ((uint8) size);

        while(0u != timeoutMs)  /* Wait till response is read */
        {
            /* Check if host complete read */
            if(I2C_slRdBufIndex == ((uint8) size))
            {
                I2C_slRdBufSize  = 0u;
                I2C_slRdBufIndex = 0u;

                status = CYRET_SUCCESS;
                break;
            }

            CyDelay(I2C_WAIT_1_MS);
            timeoutMs--;
        }
    }

    return(status);
}


/*******************************************************************************
* Function Name: I2C_CyBtldrCommRead
********************************************************************************
*
* Summary:
*  Receives the command from the Host.
*  All bytes are received by the I2C ISR and stored in internal I2C buffer. The
*  function checks status with timeout to detemine the end of transfer and
*  then copy data to bootloader buffer.
*  After exist this function the I2C ISR is able to receive more data.
*
* Parameters:
*  pData:    pointer to data buffer to store command.
*  size:     maximum number of bytes which could to be passed back.
*  count:    actual size of data was received.
*  timeOut:  timeout value in tries of 10uS.
*
* Return:
*  The status of receive operation.
*
* Global variables:
*  I2C_slWriteBuf - The global variable used to store a
*                                received command.
*
*******************************************************************************/
cystatus I2C_CyBtldrCommRead(uint8 pData[], uint16 size, uint16 * count, uint8 timeOut) CYSMALL
         
{
    cystatus status;
    uint16 timeoutMs;
    uint8 byteCount;

    status = CYRET_BAD_PARAM;

    if((NULL != pData) && (size > 0u))
    {
        status = CYRET_TIMEOUT;
        timeoutMs = ((uint16) 10u * timeOut);  /* Convert from 10mS checks to 1mS checks */

        while(0u != timeoutMs)  /* Wait for command from host */
        {
            /* Check if host completes write */
            if(0u != (I2C_slStatus & I2C_SSTAT_WR_CMPLT))
            {
                /* Define how many bytes host has been written */
                byteCount = I2C_slWrBufIndex;
                *count = (uint16) byteCount;

                /* Copy command to pData buffer */
                (void) memcpy((void *) pData, (void *) I2C_slWriteBuf,
                              I2C_MIN_UNT16(byteCount, size));

                /* Clear I2C write buffer and status */
                I2C_slStatus     = 0u;
                I2C_slWrBufIndex = 0u;

                status = CYRET_SUCCESS;
                break;
            }

            CyDelay(I2C_WAIT_1_MS);
            timeoutMs--;
        }
    }

    return(status);
}

#endif /* defined(CYDEV_BOOTLOADER_IO_COMP) && (I2C_BOOTLOADER_INTERFACE_ENABLED) */


/* [] END OF FILE */
