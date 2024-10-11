/*******************************************************************************
* File Name: I2C_MASTER.c
* Version 3.50
*
* Description:
*  This file provides the source code of APIs for the I2C component master mode.
*
*******************************************************************************
* Copyright 2012-2015, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "I2C_PVT.h"

#if(I2C_MODE_MASTER_ENABLED)

/**********************************
*      System variables
**********************************/

volatile uint8 I2C_mstrStatus;     /* Master Status byte  */
volatile uint8 I2C_mstrControl;    /* Master Control byte */

/* Transmit buffer variables */
volatile uint8 * I2C_mstrRdBufPtr;     /* Pointer to Master Read buffer */
volatile uint8   I2C_mstrRdBufSize;    /* Master Read buffer size       */
volatile uint8   I2C_mstrRdBufIndex;   /* Master Read buffer Index      */

/* Receive buffer variables */
volatile uint8 * I2C_mstrWrBufPtr;     /* Pointer to Master Write buffer */
volatile uint8   I2C_mstrWrBufSize;    /* Master Write buffer size       */
volatile uint8   I2C_mstrWrBufIndex;   /* Master Write buffer Index      */


/*******************************************************************************
* Function Name: I2C_MasterWriteBuf
********************************************************************************
*
* Summary:
*  Automatically writes an entire buffer of data to a slave device. Once the
*  data transfer is initiated by this function, further data transfer is handled
*  by the included ISR in byte by byte mode.
*
* Parameters:
*  slaveAddr: 7-bit slave address.
*  xferData:  Pointer to buffer of data to be sent.
*  cnt:       Size of buffer to send.
*  mode:      Transfer mode defines: start or restart condition generation at
*             begin of the transfer and complete the transfer or halt before
*             generating a stop.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  The included ISR will start a transfer after a start or restart condition is
*  generated.
*
* Global variables:
*  I2C_mstrStatus  - The global variable used to store a current
*                                 status of the I2C Master.
*  I2C_state       - The global variable used to store a current
*                                 state of the software FSM.
*  I2C_mstrControl - The global variable used to control the master
*                                 end of a transaction with or without Stop
*                                 generation.
*  I2C_mstrWrBufPtr - The global variable used to store a pointer
*                                  to the master write buffer.
*  I2C_mstrWrBufIndex - The global variable used to store current
*                                    index within the master write buffer.
*  I2C_mstrWrBufSize - The global variable used to store a master
*                                   write buffer size.
*
* Reentrant:
*  No
*
*******************************************************************************/
uint8 I2C_MasterWriteBuf(uint8 slaveAddress, uint8 * wrData, uint8 cnt, uint8 mode)
      
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    if(NULL != wrData)
    {
        /* Check I2C state to allow transfer: valid states are IDLE or HALT */
        if(I2C_SM_IDLE == I2C_state)
        {
            /* Master is ready for transaction: check if bus is free */
            if(I2C_CHECK_BUS_FREE(I2C_MCSR_REG))
            {
                errStatus = I2C_MSTR_NO_ERROR;
            }
            else
            {
                errStatus = I2C_MSTR_BUS_BUSY;
            }
        }
        else if(I2C_SM_MSTR_HALT == I2C_state)
        {
            /* Master is ready and waiting for ReStart */
            errStatus = I2C_MSTR_NO_ERROR;

            I2C_ClearPendingInt();
            I2C_mstrStatus &= (uint8) ~I2C_MSTAT_XFER_HALT;
        }
        else
        {
            /* errStatus = I2C_MSTR_NOT_READY was send before */
        }

        if(I2C_MSTR_NO_ERROR == errStatus)
        {
            /* Set state to start write transaction */
            I2C_state = I2C_SM_MSTR_WR_ADDR;

            /* Prepare write buffer */
            I2C_mstrWrBufIndex = 0u;
            I2C_mstrWrBufSize  = cnt;
            I2C_mstrWrBufPtr   = (volatile uint8 *) wrData;

            /* Set end of transaction flag: Stop or Halt (following ReStart) */
            I2C_mstrControl = mode;

            /* Clear write status history */
            I2C_mstrStatus &= (uint8) ~I2C_MSTAT_WR_CMPLT;

            /* Hardware actions: write address and generate Start or ReStart */
            I2C_DATA_REG = (uint8) (slaveAddress << I2C_SLAVE_ADDR_SHIFT);

            if(I2C_CHECK_RESTART(mode))
            {
                I2C_GENERATE_RESTART;
            }
            else
            {
                I2C_GENERATE_START;
            }

            /* Enable interrupt to complete transfer */
            I2C_EnableInt();
        }
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterReadBuf
********************************************************************************
*
* Summary:
*  Automatically writes an entire buffer of data to a slave device. Once the
*  data transfer is initiated by this function, further data transfer is handled
*  by the included ISR in byte by byte mode.
*
* Parameters:
*  slaveAddr: 7-bit slave address.
*  xferData:  Pointer to buffer where to put data from slave.
*  cnt:       Size of buffer to read.
*  mode:      Transfer mode defines: start or restart condition generation at
*             begin of the transfer and complete the transfer or halt before
*             generating a stop.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  The included ISR will start a transfer after start or restart condition is
*  generated.
*
* Global variables:
*  I2C_mstrStatus  - The global variable used to store a current
*                                 status of the I2C Master.
*  I2C_state       - The global variable used to store a current
*                                 state of the software FSM.
*  I2C_mstrControl - The global variable used to control the master
*                                 end of a transaction with or without
*                                 Stop generation.
*  I2C_mstrRdBufPtr - The global variable used to store a pointer
*                                  to the master write buffer.
*  I2C_mstrRdBufIndex - The global variable  used to store a
*                                    current index within the master
*                                    write buffer.
*  I2C_mstrRdBufSize - The global variable used to store a master
*                                   write buffer size.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterReadBuf(uint8 slaveAddress, uint8 * rdData, uint8 cnt, uint8 mode)
      
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    if(NULL != rdData)
    {
        /* Check I2C state to allow transfer: valid states are IDLE or HALT */
        if(I2C_SM_IDLE == I2C_state)
        {
            /* Master is ready to transaction: check if bus is free */
            if(I2C_CHECK_BUS_FREE(I2C_MCSR_REG))
            {
                errStatus = I2C_MSTR_NO_ERROR;
            }
            else
            {
                errStatus = I2C_MSTR_BUS_BUSY;
            }
        }
        else if(I2C_SM_MSTR_HALT == I2C_state)
        {
            /* Master is ready and waiting for ReStart */
            errStatus = I2C_MSTR_NO_ERROR;

            I2C_ClearPendingInt();
            I2C_mstrStatus &= (uint8) ~I2C_MSTAT_XFER_HALT;
        }
        else
        {
            /* errStatus = I2C_MSTR_NOT_READY was set before */
        }

        if(I2C_MSTR_NO_ERROR == errStatus)
        {
            /* Set state to start write transaction */
            I2C_state = I2C_SM_MSTR_RD_ADDR;

            /* Prepare read buffer */
            I2C_mstrRdBufIndex  = 0u;
            I2C_mstrRdBufSize   = cnt;
            I2C_mstrRdBufPtr    = (volatile uint8 *) rdData;

            /* Set end of transaction flag: Stop or Halt (following ReStart) */
            I2C_mstrControl = mode;

            /* Clear read status history */
            I2C_mstrStatus &= (uint8) ~I2C_MSTAT_RD_CMPLT;

            /* Hardware actions: write address and generate Start or ReStart */
            I2C_DATA_REG = ((uint8) (slaveAddress << I2C_SLAVE_ADDR_SHIFT) |
                                                  I2C_READ_FLAG);

            if(I2C_CHECK_RESTART(mode))
            {
                I2C_GENERATE_RESTART;
            }
            else
            {
                I2C_GENERATE_START;
            }

            /* Enable interrupt to complete transfer */
            I2C_EnableInt();
        }
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterSendStart
********************************************************************************
*
* Summary:
*  Generates Start condition and sends slave address with read/write bit.
*
* Parameters:
*  slaveAddress:  7-bit slave address.
*  R_nW:          Zero, send write command, non-zero send read command.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  This function is entered without a "byte complete" bit set in the I2C_CSR
*  register. It does not exit until it is set.
*
* Global variables:
*  I2C_state - The global variable used to store a current state of
*                           the software FSM.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterSendStart(uint8 slaveAddress, uint8 R_nW)
      
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    /* If IDLE, check if bus is free */
    if(I2C_SM_IDLE == I2C_state)
    {
        /* If bus is free, generate Start condition */
        if(I2C_CHECK_BUS_FREE(I2C_MCSR_REG))
        {
            /* Disable interrupt for manual master operation */
            I2C_DisableInt();

            /* Set address and read/write flag */
            slaveAddress = (uint8) (slaveAddress << I2C_SLAVE_ADDR_SHIFT);
            if(0u != R_nW)
            {
                slaveAddress |= I2C_READ_FLAG;
                I2C_state = I2C_SM_MSTR_RD_ADDR;
            }
            else
            {
                I2C_state = I2C_SM_MSTR_WR_ADDR;
            }

            /* Hardware actions: write address and generate Start */
            I2C_DATA_REG = slaveAddress;
            I2C_GENERATE_START_MANUAL;

            /* Wait until address is transferred */
            while(I2C_WAIT_BYTE_COMPLETE(I2C_CSR_REG))
            {
            }

        #if(I2C_MODE_MULTI_MASTER_SLAVE_ENABLED)
            if(I2C_CHECK_START_GEN(I2C_MCSR_REG))
            {
                I2C_CLEAR_START_GEN;

                /* Start condition was not generated: reset FSM to IDLE */
                I2C_state = I2C_SM_IDLE;
                errStatus = I2C_MSTR_ERR_ABORT_START_GEN;
            }
            else
        #endif /* (I2C_MODE_MULTI_MASTER_SLAVE_ENABLED) */

        #if(I2C_MODE_MULTI_MASTER_ENABLED)
            if(I2C_CHECK_LOST_ARB(I2C_CSR_REG))
            {
                I2C_BUS_RELEASE_MANUAL;

                /* Master lost arbitrage: reset FSM to IDLE */
                I2C_state = I2C_SM_IDLE;
                errStatus = I2C_MSTR_ERR_ARB_LOST;
            }
            else
        #endif /* (I2C_MODE_MULTI_MASTER_ENABLED) */

            if(I2C_CHECK_ADDR_NAK(I2C_CSR_REG))
            {
                /* Address has been NACKed: reset FSM to IDLE */
                I2C_state = I2C_SM_IDLE;
                errStatus = I2C_MSTR_ERR_LB_NAK;
            }
            else
            {
                /* Start was sent without errors */
                errStatus = I2C_MSTR_NO_ERROR;
            }
        }
        else
        {
            errStatus = I2C_MSTR_BUS_BUSY;
        }
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterSendRestart
********************************************************************************
*
* Summary:
*  Generates ReStart condition and sends slave address with read/write bit.
*
* Parameters:
*  slaveAddress:  7-bit slave address.
*  R_nW:          Zero, send write command, non-zero send read command.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  This function is entered without a "byte complete" bit set in the I2C_CSR
*  register. It does not exit until it is set.
*
* Global variables:
*  I2C_state - The global variable used to store a current state of
*                           the software FSM.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterSendRestart(uint8 slaveAddress, uint8 R_nW)
      
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    /* Check if START condition was generated */
    if(I2C_CHECK_MASTER_MODE(I2C_MCSR_REG))
    {
        /* Set address and read/write flag */
        slaveAddress = (uint8) (slaveAddress << I2C_SLAVE_ADDR_SHIFT);
        if(0u != R_nW)
        {
            slaveAddress |= I2C_READ_FLAG;
            I2C_state = I2C_SM_MSTR_RD_ADDR;
        }
        else
        {
            I2C_state = I2C_SM_MSTR_WR_ADDR;
        }

        /* Hardware actions: write address and generate ReStart */
        I2C_DATA_REG = slaveAddress;
        I2C_GENERATE_RESTART_MANUAL;

        /* Wait until address has been transferred */
        while(I2C_WAIT_BYTE_COMPLETE(I2C_CSR_REG))
        {
        }

    #if(I2C_MODE_MULTI_MASTER_ENABLED)
        if(I2C_CHECK_LOST_ARB(I2C_CSR_REG))
        {
            I2C_BUS_RELEASE_MANUAL;

            /* Master lost arbitrage: reset FSM to IDLE */
            I2C_state = I2C_SM_IDLE;
            errStatus = I2C_MSTR_ERR_ARB_LOST;
        }
        else
    #endif /* (I2C_MODE_MULTI_MASTER_ENABLED) */

        if(I2C_CHECK_ADDR_NAK(I2C_CSR_REG))
        {
            /* Address has been NACKed: reset FSM to IDLE */
            I2C_state = I2C_SM_IDLE;
            errStatus = I2C_MSTR_ERR_LB_NAK;
        }
        else
        {
            /* ReStart was sent without errors */
            errStatus = I2C_MSTR_NO_ERROR;
        }
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterSendStop
********************************************************************************
*
* Summary:
*  Generates I2C Stop condition on bus. Function do nothing if Start or Restart
*  condition was failed before call this function.
*
* Parameters:
*  None.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  Stop generation is required to complete the transaction.
*  This function does not wait until a Stop condition is generated.
*
* Global variables:
*  I2C_state - The global variable used to store a current state of
*                           the software FSM.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterSendStop(void) 
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    /* Check if master is active on bus */
    if(I2C_CHECK_MASTER_MODE(I2C_MCSR_REG))
    {
        I2C_GENERATE_STOP_MANUAL;
        I2C_state = I2C_SM_IDLE;

        /* Wait until stop has been generated */
        while(I2C_WAIT_STOP_COMPLETE(I2C_CSR_REG))
        {
        }

        errStatus = I2C_MSTR_NO_ERROR;

    #if(I2C_MODE_MULTI_MASTER_ENABLED)
        if(I2C_CHECK_LOST_ARB(I2C_CSR_REG))
        {
            I2C_BUS_RELEASE_MANUAL;

            /* NACK was generated by instead Stop */
            errStatus = I2C_MSTR_ERR_ARB_LOST;
        }
    #endif /* (I2C_MODE_MULTI_MASTER_ENABLED) */
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterWriteByte
********************************************************************************
*
* Summary:
*  Sends one byte to a slave. A valid Start or ReStart condition must be
*  generated before this call this function. Function do nothing if Start or
*  Restart condition was failed before call this function.
*
* Parameters:
*  data:  The data byte to send to the slave.
*
* Return:
*  Status error - Zero means no errors.
*
* Side Effects:
*  This function is entered without a "byte complete" bit set in the I2C_CSR
*  register. It does not exit until it is set.
*
* Global variables:
*  I2C_state - The global variable used to store a current state of
*                           the software FSM.
*
*******************************************************************************/
uint8 I2C_MasterWriteByte(uint8 theByte) 
{
    uint8 errStatus;

    errStatus = I2C_MSTR_NOT_READY;

    /* Check if START condition was generated */
    if(I2C_CHECK_MASTER_MODE(I2C_MCSR_REG))
    {
        I2C_DATA_REG = theByte;   /* Write DATA register */
        I2C_TRANSMIT_DATA_MANUAL; /* Set transmit mode   */
        I2C_state = I2C_SM_MSTR_WR_DATA;

        /* Wait until data byte has been transmitted */
        while(I2C_WAIT_BYTE_COMPLETE(I2C_CSR_REG))
        {
        }

    #if(I2C_MODE_MULTI_MASTER_ENABLED)
        if(I2C_CHECK_LOST_ARB(I2C_CSR_REG))
        {
            I2C_BUS_RELEASE_MANUAL;

            /* Master lost arbitrage: reset FSM to IDLE */
            I2C_state = I2C_SM_IDLE;
            errStatus = I2C_MSTR_ERR_ARB_LOST;
        }
        /* Check LRB bit */
        else
    #endif /* (I2C_MODE_MULTI_MASTER_ENABLED) */

        if(I2C_CHECK_DATA_ACK(I2C_CSR_REG))
        {
            I2C_state = I2C_SM_MSTR_HALT;
            errStatus = I2C_MSTR_NO_ERROR;
        }
        else
        {
            I2C_state = I2C_SM_MSTR_HALT;
            errStatus = I2C_MSTR_ERR_LB_NAK;
        }
    }

    return(errStatus);
}


/*******************************************************************************
* Function Name: I2C_MasterReadByte
********************************************************************************
*
* Summary:
*  Reads one byte from a slave and ACK or NACK the transfer. A valid Start or
*  ReStart condition must be generated before this call this function. Function
*  do nothing if Start or Restart condition was failed before call this
*  function.
*
* Parameters:
*  acknNack:  Zero, response with NACK, if non-zero response with ACK.
*
* Return:
*  Byte read from slave.
*
* Side Effects:
*  This function is entered without a "byte complete" bit set in the I2C_CSR
*  register. It does not exit until it is set.
*
* Global variables:
*  I2C_state - The global variable used to store a current
*                           state of the software FSM.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterReadByte(uint8 acknNak) 
{
    uint8 theByte;

    theByte = 0u;

    /* Check if START condition was generated */
    if(I2C_CHECK_MASTER_MODE(I2C_MCSR_REG))
    {
        /* When address phase needs to release bus and receive byte,
        * then decide ACK or NACK
        */
        if(I2C_SM_MSTR_RD_ADDR == I2C_state)
        {
            I2C_READY_TO_READ_MANUAL;
            I2C_state = I2C_SM_MSTR_RD_DATA;
        }

        /* Wait until data byte has been received */
        while(I2C_WAIT_BYTE_COMPLETE(I2C_CSR_REG))
        {
        }

        theByte = I2C_DATA_REG;

        /* Command ACK to receive next byte and continue transfer.
        *  Do nothing for NACK. The NACK will be generated by
        *  Stop or ReStart routine.
        */
        if(acknNak != 0u) /* Generate ACK */
        {
            I2C_ACK_AND_RECEIVE_MANUAL;
        }
        else              /* Do nothing for the follwong NACK */
        {
            I2C_state = I2C_SM_MSTR_HALT;
        }
    }

    return(theByte);
}


/*******************************************************************************
* Function Name: I2C_MasterStatus
********************************************************************************
*
* Summary:
*  Returns the master's communication status.
*
* Parameters:
*  None.
*
* Return:
*  Current status of I2C master.
*
* Global variables:
*  I2C_mstrStatus - The global variable used to store a current
*                                status of the I2C Master.
*
*******************************************************************************/
uint8 I2C_MasterStatus(void) 
{
    uint8 status;

    I2C_DisableInt(); /* Lock from interrupt */

    /* Read master status */
    status = I2C_mstrStatus;

    if (I2C_CHECK_SM_MASTER)
    {
        /* Set transfer in progress flag in status */
        status |= I2C_MSTAT_XFER_INP;
    }

    I2C_EnableInt(); /* Release lock */

    return (status);
}


/*******************************************************************************
* Function Name: I2C_MasterClearStatus
********************************************************************************
*
* Summary:
*  Clears all status flags and returns the master status.
*
* Parameters:
*  None.
*
* Return:
*  Current status of I2C master.
*
* Global variables:
*  I2C_mstrStatus - The global variable used to store a current
*                                status of the I2C Master.
*
* Reentrant:
*  No.
*
*******************************************************************************/
uint8 I2C_MasterClearStatus(void) 
{
    uint8 status;

    I2C_DisableInt(); /* Lock from interrupt */

    /* Read and clear master status */
    status = I2C_mstrStatus;
    I2C_mstrStatus = I2C_MSTAT_CLEAR;

    I2C_EnableInt(); /* Release lock */

    return (status);
}


/*******************************************************************************
* Function Name: I2C_MasterGetReadBufSize
********************************************************************************
*
* Summary:
*  Returns the amount of bytes that has been transferred with an
*  I2C_MasterReadBuf command.
*
* Parameters:
*  None.
*
* Return:
*  Byte count of transfer. If the transfer is not yet complete, it will return
*  the byte count transferred so far.
*
* Global variables:
*  I2C_mstrRdBufIndex - The global variable stores current index
*                                    within the master read buffer.
*
*******************************************************************************/
uint8 I2C_MasterGetReadBufSize(void) 
{
    return (I2C_mstrRdBufIndex);
}


/*******************************************************************************
* Function Name: I2C_MasterGetWriteBufSize
********************************************************************************
*
* Summary:
*  Returns the amount of bytes that has been transferred with an
*  I2C_MasterWriteBuf command.
*
* Parameters:
*  None.
*
* Return:
*  Byte count of transfer. If the transfer is not yet complete, it will return
*  the byte count transferred so far.
*
* Global variables:
*  I2C_mstrWrBufIndex -  The global variable used to stores current
*                                     index within master write buffer.
*
*******************************************************************************/
uint8 I2C_MasterGetWriteBufSize(void) 
{
    return (I2C_mstrWrBufIndex);
}


/*******************************************************************************
* Function Name: I2C_MasterClearReadBuf
********************************************************************************
*
* Summary:
*  Resets the read buffer pointer back to the first byte in the buffer.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  I2C_mstrRdBufIndex - The global variable used to stores current
*                                    index within master read buffer.
*  I2C_mstrStatus - The global variable used to store a current
*                                status of the I2C Master.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void I2C_MasterClearReadBuf(void) 
{
    I2C_DisableInt(); /* Lock from interrupt */

    I2C_mstrRdBufIndex = 0u;
    I2C_mstrStatus    &= (uint8) ~I2C_MSTAT_RD_CMPLT;

    I2C_EnableInt(); /* Release lock */
}


/*******************************************************************************
* Function Name: I2C_MasterClearWriteBuf
********************************************************************************
*
* Summary:
*  Resets the write buffer pointer back to the first byte in the buffer.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
*  I2C_mstrRdBufIndex - The global variable used to stote current
*                                    index within master read buffer.
*  I2C_mstrStatus - The global variable used to store a current
*                                status of the I2C Master.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void I2C_MasterClearWriteBuf(void) 
{
    I2C_DisableInt(); /* Lock from interrupt */

    I2C_mstrWrBufIndex = 0u;
    I2C_mstrStatus    &= (uint8) ~I2C_MSTAT_WR_CMPLT;

    I2C_EnableInt(); /* Release lock */
}

#endif /* (I2C_MODE_MASTER_ENABLED) */


/* [] END OF FILE */
