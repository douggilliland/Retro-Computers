/*******************************************************************************
* File Name: emFile_1_SPI0.c
* Version 2.40
*
* Description:
*  This file provides all API functionality of the SPI Master component.
*
* Note:
*  None.
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "emFile_1_SPI0_PVT.h"

#if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)
    volatile uint8 emFile_1_SPI0_txBuffer[emFile_1_SPI0_TX_BUFFER_SIZE] = {0u};
    volatile uint8 emFile_1_SPI0_txBufferFull;
    volatile uint8 emFile_1_SPI0_txBufferRead;
    volatile uint8 emFile_1_SPI0_txBufferWrite;
#endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */

#if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)
    volatile uint8 emFile_1_SPI0_rxBuffer[emFile_1_SPI0_RX_BUFFER_SIZE] = {0u};
    volatile uint8 emFile_1_SPI0_rxBufferFull;
    volatile uint8 emFile_1_SPI0_rxBufferRead;
    volatile uint8 emFile_1_SPI0_rxBufferWrite;
#endif /* (emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */

uint8 emFile_1_SPI0_initVar = 0u;

volatile uint8 emFile_1_SPI0_swStatusTx;
volatile uint8 emFile_1_SPI0_swStatusRx;


/*******************************************************************************
* Function Name: emFile_1_SPI0_Init
********************************************************************************
*
* Summary:
*  Inits/Restores default SPIM configuration provided with customizer.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Side Effects:
*  When this function is called it initializes all of the necessary parameters
*  for execution. i.e. setting the initial interrupt mask, configuring the
*  interrupt service routine, configuring the bit-counter parameters and
*  clearing the FIFO and Status Register.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_Init(void) 
{
    /* Initialize the Bit counter */
    emFile_1_SPI0_COUNTER_PERIOD_REG = emFile_1_SPI0_BITCTR_INIT;

    /* Init TX ISR  */
    #if(0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED)
        CyIntDisable         (emFile_1_SPI0_TX_ISR_NUMBER);
        CyIntSetPriority     (emFile_1_SPI0_TX_ISR_NUMBER,  emFile_1_SPI0_TX_ISR_PRIORITY);
        (void) CyIntSetVector(emFile_1_SPI0_TX_ISR_NUMBER, &emFile_1_SPI0_TX_ISR);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED) */

    /* Init RX ISR  */
    #if(0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED)
        CyIntDisable         (emFile_1_SPI0_RX_ISR_NUMBER);
        CyIntSetPriority     (emFile_1_SPI0_RX_ISR_NUMBER,  emFile_1_SPI0_RX_ISR_PRIORITY);
        (void) CyIntSetVector(emFile_1_SPI0_RX_ISR_NUMBER, &emFile_1_SPI0_RX_ISR);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED) */

    /* Clear any stray data from the RX and TX FIFO */
    emFile_1_SPI0_ClearFIFO();

    #if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)
        emFile_1_SPI0_rxBufferFull  = 0u;
        emFile_1_SPI0_rxBufferRead  = 0u;
        emFile_1_SPI0_rxBufferWrite = 0u;
    #endif /* (emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */

    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)
        emFile_1_SPI0_txBufferFull  = 0u;
        emFile_1_SPI0_txBufferRead  = 0u;
        emFile_1_SPI0_txBufferWrite = 0u;
    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */

    (void) emFile_1_SPI0_ReadTxStatus(); /* Clear Tx status and swStatusTx */
    (void) emFile_1_SPI0_ReadRxStatus(); /* Clear Rx status and swStatusRx */

    /* Configure TX and RX interrupt mask */
    emFile_1_SPI0_TX_STATUS_MASK_REG = emFile_1_SPI0_TX_INIT_INTERRUPTS_MASK;
    emFile_1_SPI0_RX_STATUS_MASK_REG = emFile_1_SPI0_RX_INIT_INTERRUPTS_MASK;
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_Enable
********************************************************************************
*
* Summary:
*  Enable SPIM component.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void emFile_1_SPI0_Enable(void) 
{
    uint8 enableInterrupts;

    enableInterrupts = CyEnterCriticalSection();
    emFile_1_SPI0_COUNTER_CONTROL_REG |= emFile_1_SPI0_CNTR_ENABLE;
    emFile_1_SPI0_TX_STATUS_ACTL_REG  |= emFile_1_SPI0_INT_ENABLE;
    emFile_1_SPI0_RX_STATUS_ACTL_REG  |= emFile_1_SPI0_INT_ENABLE;
    CyExitCriticalSection(enableInterrupts);

    #if(0u != emFile_1_SPI0_INTERNAL_CLOCK)
        emFile_1_SPI0_IntClock_Enable();
    #endif /* (0u != emFile_1_SPI0_INTERNAL_CLOCK) */

    emFile_1_SPI0_EnableTxInt();
    emFile_1_SPI0_EnableRxInt();
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_Start
********************************************************************************
*
* Summary:
*  Initialize and Enable the SPI Master component.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  emFile_1_SPI0_initVar - used to check initial configuration, modified on
*  first function call.
*
* Theory:
*  Enable the clock input to enable operation.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_Start(void) 
{
    if(0u == emFile_1_SPI0_initVar)
    {
        emFile_1_SPI0_Init();
        emFile_1_SPI0_initVar = 1u;
    }

    emFile_1_SPI0_Enable();
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_Stop
********************************************************************************
*
* Summary:
*  Disable the SPI Master component.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Disable the clock input to enable operation.
*
*******************************************************************************/
void emFile_1_SPI0_Stop(void) 
{
    uint8 enableInterrupts;

    enableInterrupts = CyEnterCriticalSection();
    emFile_1_SPI0_TX_STATUS_ACTL_REG &= ((uint8) ~emFile_1_SPI0_INT_ENABLE);
    emFile_1_SPI0_RX_STATUS_ACTL_REG &= ((uint8) ~emFile_1_SPI0_INT_ENABLE);
    CyExitCriticalSection(enableInterrupts);

    #if(0u != emFile_1_SPI0_INTERNAL_CLOCK)
        emFile_1_SPI0_IntClock_Disable();
    #endif /* (0u != emFile_1_SPI0_INTERNAL_CLOCK) */

    emFile_1_SPI0_DisableTxInt();
    emFile_1_SPI0_DisableRxInt();
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_EnableTxInt
********************************************************************************
*
* Summary:
*  Enable internal Tx interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Enable the internal Tx interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_EnableTxInt(void) 
{
    #if(0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED)
        CyIntEnable(emFile_1_SPI0_TX_ISR_NUMBER);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_EnableRxInt
********************************************************************************
*
* Summary:
*  Enable internal Rx interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Enable the internal Rx interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_EnableRxInt(void) 
{
    #if(0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED)
        CyIntEnable(emFile_1_SPI0_RX_ISR_NUMBER);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_DisableTxInt
********************************************************************************
*
* Summary:
*  Disable internal Tx interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Disable the internal Tx interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_DisableTxInt(void) 
{
    #if(0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED)
        CyIntDisable(emFile_1_SPI0_TX_ISR_NUMBER);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_DisableRxInt
********************************************************************************
*
* Summary:
*  Disable internal Rx interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Disable the internal Rx interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_DisableRxInt(void) 
{
    #if(0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED)
        CyIntDisable(emFile_1_SPI0_RX_ISR_NUMBER);
    #endif /* (0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_SetTxInterruptMode
********************************************************************************
*
* Summary:
*  Configure which status bits trigger an interrupt event.
*
* Parameters:
*  intSrc: An or'd combination of the desired status bit masks (defined in the
*  header file).
*
* Return:
*  None.
*
* Theory:
*  Enables the output of specific status bits to the interrupt controller.
*
*******************************************************************************/
void emFile_1_SPI0_SetTxInterruptMode(uint8 intSrc) 
{
    emFile_1_SPI0_TX_STATUS_MASK_REG = intSrc;
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_SetRxInterruptMode
********************************************************************************
*
* Summary:
*  Configure which status bits trigger an interrupt event.
*
* Parameters:
*  intSrc: An or'd combination of the desired status bit masks (defined in the
*  header file).
*
* Return:
*  None.
*
* Theory:
*  Enables the output of specific status bits to the interrupt controller.
*
*******************************************************************************/
void emFile_1_SPI0_SetRxInterruptMode(uint8 intSrc) 
{
    emFile_1_SPI0_RX_STATUS_MASK_REG  = intSrc;
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ReadTxStatus
********************************************************************************
*
* Summary:
*  Read the Tx status register for the component.
*
* Parameters:
*  None.
*
* Return:
*  Contents of the Tx status register.
*
* Global variables:
*  emFile_1_SPI0_swStatusTx - used to store in software status register,
*  modified every function call - resets to zero.
*
* Theory:
*  Allows the user and the API to read the Tx status register for error
*  detection and flow control.
*
* Side Effects:
*  Clear Tx status register of the component.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 emFile_1_SPI0_ReadTxStatus(void) 
{
    uint8 tmpStatus;

    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)
        /* Disable TX interrupt to protect global veriables */
        emFile_1_SPI0_DisableTxInt();

        tmpStatus = emFile_1_SPI0_GET_STATUS_TX(emFile_1_SPI0_swStatusTx);
        emFile_1_SPI0_swStatusTx = 0u;

        emFile_1_SPI0_EnableTxInt();

    #else

        tmpStatus = emFile_1_SPI0_TX_STATUS_REG;

    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */

    return(tmpStatus);
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ReadRxStatus
********************************************************************************
*
* Summary:
*  Read the Rx status register for the component.
*
* Parameters:
*  None.
*
* Return:
*  Contents of the Rx status register.
*
* Global variables:
*  emFile_1_SPI0_swStatusRx - used to store in software Rx status register,
*  modified every function call - resets to zero.
*
* Theory:
*  Allows the user and the API to read the Rx status register for error
*  detection and flow control.
*
* Side Effects:
*  Clear Rx status register of the component.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 emFile_1_SPI0_ReadRxStatus(void) 
{
    uint8 tmpStatus;

    #if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)
        /* Disable RX interrupt to protect global veriables */
        emFile_1_SPI0_DisableRxInt();

        tmpStatus = emFile_1_SPI0_GET_STATUS_RX(emFile_1_SPI0_swStatusRx);
        emFile_1_SPI0_swStatusRx = 0u;

        emFile_1_SPI0_EnableRxInt();

    #else

        tmpStatus = emFile_1_SPI0_RX_STATUS_REG;

    #endif /* (emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */

    return(tmpStatus);
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_WriteTxData
********************************************************************************
*
* Summary:
*  Write a byte of data to be sent across the SPI.
*
* Parameters:
*  txDataByte: The data value to send across the SPI.
*
* Return:
*  None.
*
* Global variables:
*  emFile_1_SPI0_txBufferWrite - used for the account of the bytes which
*  have been written down in the TX software buffer, modified every function
*  call if TX Software Buffer is used.
*  emFile_1_SPI0_txBufferRead - used for the account of the bytes which
*  have been read from the TX software buffer.
*  emFile_1_SPI0_txBuffer[emFile_1_SPI0_TX_BUFFER_SIZE] - used to store
*  data to sending, modified every function call if TX Software Buffer is used.
*
* Theory:
*  Allows the user to transmit any byte of data in a single transfer.
*
* Side Effects:
*  If this function is called again before the previous byte is finished then
*  the next byte will be appended to the transfer with no time between
*  the byte transfers. Clear Tx status register of the component.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_WriteTxData(uint8 txData) 
{
    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)

        uint8 tempStatus;
        uint8 tmpTxBufferRead;

        /* Block if TX buffer is FULL: don't overwrite */
        do
        {
            tmpTxBufferRead = emFile_1_SPI0_txBufferRead;
            if(0u == tmpTxBufferRead)
            {
                tmpTxBufferRead = (emFile_1_SPI0_TX_BUFFER_SIZE - 1u);
            }
            else
            {
                tmpTxBufferRead--;
            }

        }while(tmpTxBufferRead == emFile_1_SPI0_txBufferWrite);

        /* Disable TX interrupt to protect global veriables */
        emFile_1_SPI0_DisableTxInt();

        tempStatus = emFile_1_SPI0_GET_STATUS_TX(emFile_1_SPI0_swStatusTx);
        emFile_1_SPI0_swStatusTx = tempStatus;


        if((emFile_1_SPI0_txBufferRead == emFile_1_SPI0_txBufferWrite) &&
           (0u != (emFile_1_SPI0_swStatusTx & emFile_1_SPI0_STS_TX_FIFO_NOT_FULL)))
        {
            /* Add directly to the TX FIFO */
            CY_SET_REG8(emFile_1_SPI0_TXDATA_PTR, txData);
        }
        else
        {
            /* Add to the TX software buffer */
            emFile_1_SPI0_txBufferWrite++;
            if(emFile_1_SPI0_txBufferWrite >= emFile_1_SPI0_TX_BUFFER_SIZE)
            {
                emFile_1_SPI0_txBufferWrite = 0u;
            }

            if(emFile_1_SPI0_txBufferWrite == emFile_1_SPI0_txBufferRead)
            {
                emFile_1_SPI0_txBufferRead++;
                if(emFile_1_SPI0_txBufferRead >= emFile_1_SPI0_TX_BUFFER_SIZE)
                {
                    emFile_1_SPI0_txBufferRead = 0u;
                }
                emFile_1_SPI0_txBufferFull = 1u;
            }

            emFile_1_SPI0_txBuffer[emFile_1_SPI0_txBufferWrite] = txData;

            emFile_1_SPI0_TX_STATUS_MASK_REG |= emFile_1_SPI0_STS_TX_FIFO_NOT_FULL;
        }

        emFile_1_SPI0_EnableTxInt();

    #else

        while(0u == (emFile_1_SPI0_TX_STATUS_REG & emFile_1_SPI0_STS_TX_FIFO_NOT_FULL))
        {
            ; /* Wait for room in FIFO */
        }

        /* Put byte in TX FIFO */
        CY_SET_REG8(emFile_1_SPI0_TXDATA_PTR, txData);

    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ReadRxData
********************************************************************************
*
* Summary:
*  Read the next byte of data received across the SPI.
*
* Parameters:
*  None.
*
* Return:
*  The next byte of data read from the FIFO.
*
* Global variables:
*  emFile_1_SPI0_rxBufferWrite - used for the account of the bytes which
*  have been written down in the RX software buffer.
*  emFile_1_SPI0_rxBufferRead - used for the account of the bytes which
*  have been read from the RX software buffer, modified every function
*  call if RX Software Buffer is used.
*  emFile_1_SPI0_rxBuffer[emFile_1_SPI0_RX_BUFFER_SIZE] - used to store
*  received data.
*
* Theory:
*  Allows the user to read a byte of data received.
*
* Side Effects:
*  Will return invalid data if the FIFO is empty. The user should Call
*  GetRxBufferSize() and if it returns a non-zero value then it is safe to call
*  ReadByte() function.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 emFile_1_SPI0_ReadRxData(void) 
{
    uint8 rxData;

    #if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)

        /* Disable RX interrupt to protect global veriables */
        emFile_1_SPI0_DisableRxInt();

        if(emFile_1_SPI0_rxBufferRead != emFile_1_SPI0_rxBufferWrite)
        {
            if(0u == emFile_1_SPI0_rxBufferFull)
            {
                emFile_1_SPI0_rxBufferRead++;
                if(emFile_1_SPI0_rxBufferRead >= emFile_1_SPI0_RX_BUFFER_SIZE)
                {
                    emFile_1_SPI0_rxBufferRead = 0u;
                }
            }
            else
            {
                emFile_1_SPI0_rxBufferFull = 0u;
            }
        }

        rxData = emFile_1_SPI0_rxBuffer[emFile_1_SPI0_rxBufferRead];

        emFile_1_SPI0_EnableRxInt();

    #else

        rxData = CY_GET_REG8(emFile_1_SPI0_RXDATA_PTR);

    #endif /* (emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */

    return(rxData);
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_GetRxBufferSize
********************************************************************************
*
* Summary:
*  Returns the number of bytes/words of data currently held in the RX buffer.
*  If RX Software Buffer not used then function return 0 if FIFO empty or 1 if
*  FIFO not empty. In another case function return size of RX Software Buffer.
*
* Parameters:
*  None.
*
* Return:
*  Integer count of the number of bytes/words in the RX buffer.
*
* Global variables:
*  emFile_1_SPI0_rxBufferWrite - used for the account of the bytes which
*  have been written down in the RX software buffer.
*  emFile_1_SPI0_rxBufferRead - used for the account of the bytes which
*  have been read from the RX software buffer.
*
* Side Effects:
*  Clear status register of the component.
*
*******************************************************************************/
uint8 emFile_1_SPI0_GetRxBufferSize(void) 
{
    uint8 size;

    #if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)

        /* Disable RX interrupt to protect global veriables */
        emFile_1_SPI0_DisableRxInt();

        if(emFile_1_SPI0_rxBufferRead == emFile_1_SPI0_rxBufferWrite)
        {
            size = 0u;
        }
        else if(emFile_1_SPI0_rxBufferRead < emFile_1_SPI0_rxBufferWrite)
        {
            size = (emFile_1_SPI0_rxBufferWrite - emFile_1_SPI0_rxBufferRead);
        }
        else
        {
            size = (emFile_1_SPI0_RX_BUFFER_SIZE - emFile_1_SPI0_rxBufferRead) + emFile_1_SPI0_rxBufferWrite;
        }

        emFile_1_SPI0_EnableRxInt();

    #else

        /* We can only know if there is data in the RX FIFO */
        size = (0u != (emFile_1_SPI0_RX_STATUS_REG & emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY)) ? 1u : 0u;

    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */

    return(size);
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_GetTxBufferSize
********************************************************************************
*
* Summary:
*  Returns the number of bytes/words of data currently held in the TX buffer.
*  If TX Software Buffer not used then function return 0 - if FIFO empty, 1 - if
*  FIFO not full, 4 - if FIFO full. In another case function return size of TX
*  Software Buffer.
*
* Parameters:
*  None.
*
* Return:
*  Integer count of the number of bytes/words in the TX buffer.
*
* Global variables:
*  emFile_1_SPI0_txBufferWrite - used for the account of the bytes which
*  have been written down in the TX software buffer.
*  emFile_1_SPI0_txBufferRead - used for the account of the bytes which
*  have been read from the TX software buffer.
*
* Side Effects:
*  Clear status register of the component.
*
*******************************************************************************/
uint8  emFile_1_SPI0_GetTxBufferSize(void) 
{
    uint8 size;

    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)
        /* Disable TX interrupt to protect global veriables */
        emFile_1_SPI0_DisableTxInt();

        if(emFile_1_SPI0_txBufferRead == emFile_1_SPI0_txBufferWrite)
        {
            size = 0u;
        }
        else if(emFile_1_SPI0_txBufferRead < emFile_1_SPI0_txBufferWrite)
        {
            size = (emFile_1_SPI0_txBufferWrite - emFile_1_SPI0_txBufferRead);
        }
        else
        {
            size = (emFile_1_SPI0_TX_BUFFER_SIZE - emFile_1_SPI0_txBufferRead) + emFile_1_SPI0_txBufferWrite;
        }

        emFile_1_SPI0_EnableTxInt();

    #else

        size = emFile_1_SPI0_TX_STATUS_REG;

        if(0u != (size & emFile_1_SPI0_STS_TX_FIFO_EMPTY))
        {
            size = 0u;
        }
        else if(0u != (size & emFile_1_SPI0_STS_TX_FIFO_NOT_FULL))
        {
            size = 1u;
        }
        else
        {
            size = emFile_1_SPI0_FIFO_SIZE;
        }

    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */

    return(size);
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ClearRxBuffer
********************************************************************************
*
* Summary:
*  Clear the RX RAM buffer by setting the read and write pointers both to zero.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  emFile_1_SPI0_rxBufferWrite - used for the account of the bytes which
*  have been written down in the RX software buffer, modified every function
*  call - resets to zero.
*  emFile_1_SPI0_rxBufferRead - used for the account of the bytes which
*  have been read from the RX software buffer, modified every function call -
*  resets to zero.
*
* Theory:
*  Setting the pointers to zero makes the system believe there is no data to
*  read and writing will resume at address 0 overwriting any data that may have
*  remained in the RAM.
*
* Side Effects:
*  Any received data not read from the RAM buffer will be lost when overwritten.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_ClearRxBuffer(void) 
{
    /* Clear Hardware RX FIFO */
    while(0u !=(emFile_1_SPI0_RX_STATUS_REG & emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY))
    {
        (void) CY_GET_REG8(emFile_1_SPI0_RXDATA_PTR);
    }

    #if(emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)
        /* Disable RX interrupt to protect global veriables */
        emFile_1_SPI0_DisableRxInt();

        emFile_1_SPI0_rxBufferFull  = 0u;
        emFile_1_SPI0_rxBufferRead  = 0u;
        emFile_1_SPI0_rxBufferWrite = 0u;

        emFile_1_SPI0_EnableRxInt();
    #endif /* (emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ClearTxBuffer
********************************************************************************
*
* Summary:
*  Clear the TX RAM buffer by setting the read and write pointers both to zero.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  emFile_1_SPI0_txBufferWrite - used for the account of the bytes which
*  have been written down in the TX software buffer, modified every function
*  call - resets to zero.
*  emFile_1_SPI0_txBufferRead - used for the account of the bytes which
*  have been read from the TX software buffer, modified every function call -
*  resets to zero.
*
* Theory:
*  Setting the pointers to zero makes the system believe there is no data to
*  read and writing will resume at address 0 overwriting any data that may have
*  remained in the RAM.
*
* Side Effects:
*  Any data not yet transmitted from the RAM buffer will be lost when
*  overwritten.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_ClearTxBuffer(void) 
{
    uint8 enableInterrupts;

    enableInterrupts = CyEnterCriticalSection();
    /* Clear TX FIFO */
    emFile_1_SPI0_AUX_CONTROL_DP0_REG |= ((uint8)  emFile_1_SPI0_TX_FIFO_CLR);
    emFile_1_SPI0_AUX_CONTROL_DP0_REG &= ((uint8) ~emFile_1_SPI0_TX_FIFO_CLR);

    #if(emFile_1_SPI0_USE_SECOND_DATAPATH)
        /* Clear TX FIFO for 2nd Datapath */
        emFile_1_SPI0_AUX_CONTROL_DP1_REG |= ((uint8)  emFile_1_SPI0_TX_FIFO_CLR);
        emFile_1_SPI0_AUX_CONTROL_DP1_REG &= ((uint8) ~emFile_1_SPI0_TX_FIFO_CLR);
    #endif /* (emFile_1_SPI0_USE_SECOND_DATAPATH) */
    CyExitCriticalSection(enableInterrupts);

    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED)
        /* Disable TX interrupt to protect global veriables */
        emFile_1_SPI0_DisableTxInt();

        emFile_1_SPI0_txBufferFull  = 0u;
        emFile_1_SPI0_txBufferRead  = 0u;
        emFile_1_SPI0_txBufferWrite = 0u;

        /* Buffer is EMPTY: disable TX FIFO NOT FULL interrupt */
        emFile_1_SPI0_TX_STATUS_MASK_REG &= ((uint8) ~emFile_1_SPI0_STS_TX_FIFO_NOT_FULL);

        emFile_1_SPI0_EnableTxInt();
    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) */
}


#if(0u != emFile_1_SPI0_BIDIRECTIONAL_MODE)
    /*******************************************************************************
    * Function Name: emFile_1_SPI0_TxEnable
    ********************************************************************************
    *
    * Summary:
    *  If the SPI master is configured to use a single bi-directional pin then this
    *  will set the bi-directional pin to transmit.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    *******************************************************************************/
    void emFile_1_SPI0_TxEnable(void) 
    {
        emFile_1_SPI0_CONTROL_REG |= emFile_1_SPI0_CTRL_TX_SIGNAL_EN;
    }


    /*******************************************************************************
    * Function Name: emFile_1_SPI0_TxDisable
    ********************************************************************************
    *
    * Summary:
    *  If the SPI master is configured to use a single bi-directional pin then this
    *  will set the bi-directional pin to receive.
    *
    * Parameters:
    *  None.
    *
    * Return:
    *  None.
    *
    *******************************************************************************/
    void emFile_1_SPI0_TxDisable(void) 
    {
        emFile_1_SPI0_CONTROL_REG &= ((uint8) ~emFile_1_SPI0_CTRL_TX_SIGNAL_EN);
    }

#endif /* (0u != emFile_1_SPI0_BIDIRECTIONAL_MODE) */


/*******************************************************************************
* Function Name: emFile_1_SPI0_PutArray
********************************************************************************
*
* Summary:
*  Write available data from ROM/RAM to the TX buffer while space is available
*  in the TX buffer. Keep trying until all data is passed to the TX buffer.
*
* Parameters:
*  *buffer: Pointer to the location in RAM containing the data to send
*  byteCount: The number of bytes to move to the transmit buffer.
*
* Return:
*  None.
*
* Side Effects:
*  Will stay in this routine until all data has been sent.  May get locked in
*  this loop if data is not being initiated by the master if there is not
*  enough room in the TX FIFO.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void emFile_1_SPI0_PutArray(const uint8 buffer[], uint8 byteCount)
                                                                          
{
    uint8 bufIndex;

    bufIndex = 0u;

    while(byteCount > 0u)
    {
        emFile_1_SPI0_WriteTxData(buffer[bufIndex]);
        bufIndex++;
        byteCount--;
    }
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ClearFIFO
********************************************************************************
*
* Summary:
*  Clear the RX and TX FIFO's of all data for a fresh start.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Side Effects:
*  Clear status register of the component.
*
*******************************************************************************/
void emFile_1_SPI0_ClearFIFO(void) 
{
    uint8 enableInterrupts;

    /* Clear Hardware RX FIFO */
    while(0u !=(emFile_1_SPI0_RX_STATUS_REG & emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY))
    {
        (void) CY_GET_REG8(emFile_1_SPI0_RXDATA_PTR);
    }

    enableInterrupts = CyEnterCriticalSection();
    /* Clear TX FIFO */
    emFile_1_SPI0_AUX_CONTROL_DP0_REG |= ((uint8)  emFile_1_SPI0_TX_FIFO_CLR);
    emFile_1_SPI0_AUX_CONTROL_DP0_REG &= ((uint8) ~emFile_1_SPI0_TX_FIFO_CLR);

    #if(emFile_1_SPI0_USE_SECOND_DATAPATH)
        /* Clear TX FIFO for 2nd Datapath */
        emFile_1_SPI0_AUX_CONTROL_DP1_REG |= ((uint8)  emFile_1_SPI0_TX_FIFO_CLR);
        emFile_1_SPI0_AUX_CONTROL_DP1_REG &= ((uint8) ~emFile_1_SPI0_TX_FIFO_CLR);
    #endif /* (emFile_1_SPI0_USE_SECOND_DATAPATH) */
    CyExitCriticalSection(enableInterrupts);
}


/* Following functions are for version Compatibility, they are obsolete.
*  Please do not use it in new projects.
*/


/*******************************************************************************
* Function Name: emFile_1_SPI0_EnableInt
********************************************************************************
*
* Summary:
*  Enable internal interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Enable the internal interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_EnableInt(void) 
{
    emFile_1_SPI0_EnableRxInt();
    emFile_1_SPI0_EnableTxInt();
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_DisableInt
********************************************************************************
*
* Summary:
*  Disable internal interrupt generation.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Theory:
*  Disable the internal interrupt output -or- the interrupt component itself.
*
*******************************************************************************/
void emFile_1_SPI0_DisableInt(void) 
{
    emFile_1_SPI0_DisableTxInt();
    emFile_1_SPI0_DisableRxInt();
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_SetInterruptMode
********************************************************************************
*
* Summary:
*  Configure which status bits trigger an interrupt event.
*
* Parameters:
*  intSrc: An or'd combination of the desired status bit masks (defined in the
*  header file).
*
* Return:
*  None.
*
* Theory:
*  Enables the output of specific status bits to the interrupt controller.
*
*******************************************************************************/
void emFile_1_SPI0_SetInterruptMode(uint8 intSrc) 
{
    emFile_1_SPI0_TX_STATUS_MASK_REG  = (intSrc & ((uint8) ~emFile_1_SPI0_STS_SPI_IDLE));
    emFile_1_SPI0_RX_STATUS_MASK_REG  =  intSrc;
}


/*******************************************************************************
* Function Name: emFile_1_SPI0_ReadStatus
********************************************************************************
*
* Summary:
*  Read the status register for the component.
*
* Parameters:
*  None.
*
* Return:
*  Contents of the status register.
*
* Global variables:
*  emFile_1_SPI0_swStatus - used to store in software status register,
*  modified every function call - resets to zero.
*
* Theory:
*  Allows the user and the API to read the status register for error detection
*  and flow control.
*
* Side Effects:
*  Clear status register of the component.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 emFile_1_SPI0_ReadStatus(void) 
{
    uint8 tmpStatus;

    #if(emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED || emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED)

        emFile_1_SPI0_DisableInt();

        tmpStatus  = emFile_1_SPI0_GET_STATUS_RX(emFile_1_SPI0_swStatusRx);
        tmpStatus |= emFile_1_SPI0_GET_STATUS_TX(emFile_1_SPI0_swStatusTx);
        tmpStatus &= ((uint8) ~emFile_1_SPI0_STS_SPI_IDLE);

        emFile_1_SPI0_swStatusTx = 0u;
        emFile_1_SPI0_swStatusRx = 0u;

        emFile_1_SPI0_EnableInt();

    #else

        tmpStatus  = emFile_1_SPI0_RX_STATUS_REG;
        tmpStatus |= emFile_1_SPI0_TX_STATUS_REG;
        tmpStatus &= ((uint8) ~emFile_1_SPI0_STS_SPI_IDLE);

    #endif /* (emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED || emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED) */

    return(tmpStatus);
}


/* [] END OF FILE */
