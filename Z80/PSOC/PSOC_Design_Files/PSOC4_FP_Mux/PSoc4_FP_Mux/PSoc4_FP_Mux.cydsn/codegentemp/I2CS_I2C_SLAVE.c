/***************************************************************************//**
* \file I2CS_I2C_SLAVE.c
* \version 4.0
*
* \brief
*  This file provides the source code to the API for the SCB Component in
*  I2C Slave mode.
*
* Note:
*
*******************************************************************************
* \copyright
* Copyright 2013-2017, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "I2CS_I2C_PVT.h"

#if(I2CS_I2C_SLAVE_CONST)

/***************************************
*      I2C Slave Private Vars
***************************************/

volatile uint8 I2CS_slStatus;          /* Slave Status */

/* Receive buffer variables */
volatile uint8 * I2CS_slWrBufPtr;      /* Pointer to Receive buffer  */
volatile uint32  I2CS_slWrBufSize;     /* Slave Receive buffer size  */
volatile uint32  I2CS_slWrBufIndex;    /* Slave Receive buffer Index */

/* Transmit buffer variables */
volatile uint8 * I2CS_slRdBufPtr;      /* Pointer to Transmit buffer  */
volatile uint32  I2CS_slRdBufSize;     /* Slave Transmit buffer size  */
volatile uint32  I2CS_slRdBufIndex;    /* Slave Transmit buffer Index */
volatile uint32  I2CS_slRdBufIndexTmp; /* Slave Transmit buffer Index Tmp */
volatile uint8   I2CS_slOverFlowCount; /* Slave Transmit Overflow counter */

#if (I2CS_I2C_CUSTOM_ADDRESS_HANDLER_CONST)

    uint32 (*I2CS_customAddressHandler)(void) = NULL;

    /*******************************************************************************
    * Function Name: I2CS_SetI2cAddressCustomInterruptHandler
    ****************************************************************************//**
    *
    *  Registers a function to be called by the I2C slave interrupt handler during
    *  the I2C interrupt address processing. This function should be used when
    *  multiple I2C addresses need to be decoded or general call address supported.
    *  The registered function must return decision whether to ACK or NACK address.
    *  Only one I2C address handler is supported, which is the function provided
    *  by the most recent call.
    *  At initialization time no I2C address handler is registered.
    *
    *  \param func: Pointer to the function to register.
    *   The value NULL indicates to remove the current custom interrupt
    *   handler.
    *   The registered function must return decision whether to ACK or NACK 
    *   accepted address: 0 – ACK, other values – NACK. The registered 
    *   callback function does not perform the ACK/NACK, this operation is 
    *   performed in the I2C ISR.
    *
    *******************************************************************************/
    void I2CS_SetI2cAddressCustomInterruptHandler(uint32 (*func) (void))
    {
        /* Register custom address handler */
        I2CS_customAddressHandler = func;
    }
#endif /* (I2CS_I2C_CUSTOM_ADDRESS_HANDLER_CONST) */


/*******************************************************************************
* Function Name: I2CS_I2CSlaveStatus
****************************************************************************//**
*
*  Returns the I2C slave's communication status.
*
* \return
*  Current status of I2C slave.
*  This status incorporates read and write status constants. 
*  Each constant is a bit field value. The value returned may have multiple 
*  bits set to indicate the status of the read or write transfer.
*   - I2CS_I2C_SSTAT_RD_CMPLT - Slave read transfer complete. 
*     Set when master indicates it is done reading by sending a NAK.
*     The read error condition status bit must be checked to ensure that 
*     the read transfer was completed successfully.
*   - I2CS_I2C_SSTAT_RD_BUSY - Slave read transfer is in progress. 
*     Set when master addresses slave with a read, cleared when 
*    I2CS_I2C_SSTAT_RD_CMPLT is set.
*   - I2CS_I2C_SSTAT_RD_OVFL - Master attempted to read more bytes
*     than are in buffer. Slave continually returns 0xFF byte in this case.
*   - I2CS_I2C_SSTAT_RD_ERR - Slave captured error on the bus during 
*     a read transfer. The sources of error are: misplaced Start or Stop 
*     condition or lost arbitration while slave drives SDA.
*   - I2CS_I2C_SSTAT_WR_CMPLT - Slave write transfer complete. 
*     Set at reception of a Stop or ReStart condition. The write error condition
*     status bit must be checked to ensure that write transfer was completed
*     successfully.
*   - I2CS_I2C_SSTAT_WR_BUSY - Slave write transfer is in progress. 
*     Set when the master addresses the slave with a write, cleared when 
*    I2CS_I2C_SSTAT_WR_CMPLT is set.
*   - I2CS_I2C_SSTAT_WR_OVFL - Master attempted to write past end of 
*     buffer. Further bytes are ignored.
*   - I2CS_I2C_SSTAT_WR_ERR - Slave captured error on the bus during
*     write transfer. The sources of error are: misplaced Start or Stop condition
*     or lost arbitration while slave drives SDA.
*     The write buffer may contain invalid bytes or part of the data transfer when 
*     I2CS_I2C_SSTAT_WR_ERR is set. It is recommended to discard write 
*     buffer content in this case.
*
* \globalvars
*  I2CS_slStatus  - used to store current status of I2C slave.
*
*******************************************************************************/
uint32 I2CS_I2CSlaveStatus(void)
{
    return((uint32) I2CS_slStatus);
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveClearReadStatus
****************************************************************************//**
*
*  Clears the read status flags and returns their values. No other status flags
*  are affected.
*
* \return
*  Current read status of slave. See the SCB_I2CSlaveStatus() function for 
*  constants.
*
* \sideeffect
*  This function does not clear I2CS_I2C_SSTAT_RD_BUSY.
*
* \globalvars
*  I2CS_slStatus  - used to store current status of I2C slave.
*
*******************************************************************************/
uint32 I2CS_I2CSlaveClearReadStatus(void)
{
    uint32 status;

    I2CS_DisableInt();  /* Lock from interruption */

    /* Mask of transfer complete flag and error status */
    status = ((uint32) I2CS_slStatus & I2CS_I2C_SSTAT_RD_MASK);
    I2CS_slStatus &= (uint8) ~I2CS_I2C_SSTAT_RD_CLEAR;

    I2CS_EnableInt();   /* Release lock */

    return(status);
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveClearWriteStatus
****************************************************************************//**
*
*  Clears the write status flags and returns their values. No other status flags
*  are affected.
*
* \return
*  Current write status of slave. See the SCB_I2CSlaveStatus() function 
*  for constants.
*
* \sideeffect
*  This function does not clear I2CS_I2C_SSTAT_WR_BUSY.*
*
* \globalvars
*  I2CS_slStatus  - used to store current status of I2C slave.
*
*******************************************************************************/
uint32 I2CS_I2CSlaveClearWriteStatus(void)
{
    uint32 status;

    I2CS_DisableInt();  /* Lock from interruption */

    /* Mask of transfer complete flag and Error status */
    status = ((uint32) I2CS_slStatus & I2CS_I2C_SSTAT_WR_MASK);
    I2CS_slStatus &= (uint8) ~I2CS_I2C_SSTAT_WR_CLEAR;

    I2CS_EnableInt();   /* Release lock */

    return(status);
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveSetAddress
****************************************************************************//**
*
* Sets the I2C slave address.
*
* \param address: I2C slave address for the primary device.
*  This address is the 7-bit right-justified slave address and does not 
*  include the R/W bit.
*  The address value is not checked to see if it violates the I2C spec. 
*  The preferred addresses are between 8 and 120 (0x08 to 0x78).
*
*******************************************************************************/
void I2CS_I2CSlaveSetAddress(uint32 address)
{
    uint32 matchReg;

    matchReg = I2CS_RX_MATCH_REG;

    matchReg &= ((uint32) ~I2CS_RX_MATCH_ADDR_MASK); /* Clear address bits */
    matchReg |= ((uint32)  I2CS_GET_I2C_8BIT_ADDRESS(address));

    I2CS_RX_MATCH_REG = matchReg;
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveSetAddressMask
****************************************************************************//**
*
*  Sets the I2C slave address mask.
*
* \param addressMask: I2C slave address mask.
*  - Bit value 0 – excludes bit from address comparison.
*  - Bit value 1 – the bit needs to match with the corresponding bit of the 
*  I2C slave address.
*
*  The range of valid values is between 0 and 254 (0x00 to 0xFE). 
*  The LSB of the address mask must be 0 because it corresponds to R/W bit 
*  within I2C slave address byte.
*
*******************************************************************************/
void I2CS_I2CSlaveSetAddressMask(uint32 addressMask)
{
    uint32 matchReg;

    matchReg = I2CS_RX_MATCH_REG;

    matchReg &= ((uint32) ~I2CS_RX_MATCH_MASK_MASK);
    matchReg |= ((uint32) (addressMask << I2CS_RX_MATCH_MASK_POS));

    I2CS_RX_MATCH_REG = matchReg;
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveInitReadBuf
****************************************************************************//**
*
*  Sets the buffer pointer and size of the read buffer. This function also
*  resets the transfer count returned with the 
*  I2CS_SlaveGetReadBufSize() function.
*
* \param readBuf: Pointer to the data buffer to be read by the master.
* \param bufSize: Size of the read buffer exposed to the I2C master.
*
* \sideeffect
*  If this function is called during a bus transaction, data from the previous
*  buffer location and the beginning of current buffer may be transmitted.
*
* \globalvars
*  I2CS_slRdBufPtr   - used to store pointer to slave read buffer.
*  I2CS_slRdBufSize  - used to store salve read buffer size.
*  I2CS_slRdBufIndex - used to store current index within slave
*  read buffer.
*
*******************************************************************************/
void I2CS_I2CSlaveInitReadBuf(uint8 * rdBuf, uint32 bufSize)
{
    /* Check for proper buffer */
    if(NULL != rdBuf)
    {
        I2CS_DisableInt();  /* Lock from interruption */

        I2CS_slRdBufPtr      = (volatile uint8 *) rdBuf; /* Set buffer pointer  */
        I2CS_slRdBufSize     = bufSize;                  /* Set buffer size     */
        I2CS_slRdBufIndex    = 0u;                       /* Clear buffer index  */
        I2CS_slRdBufIndexTmp = 0u;                       /* Clear buffer index  */

        I2CS_EnableInt();   /* Release lock */
    }
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveInitWriteBuf
****************************************************************************//**
*
*  Sets the buffer pointer and size of the write buffer. This function also 
*  resets the transfer count returned with the 
*  I2CS_I2CSlaveGetWriteBufSize() function.
*
* \param writeBuf: Pointer to the data buffer to be written by the master.
* \param bufSize:  Size of the write buffer exposed to the I2C master.
*
* \sideeffect
*  If this function is called during a bus transaction, data may be received in 
*  the previous buffer and the current buffer location.
*
* \globalvars
*  I2CS_slWrBufPtr   - used to store pointer to slave write buffer.
*  I2CS_slWrBufSize  - used to store salve write buffer size.
*  I2CS_slWrBufIndex - used to store current index within slave
*   write buffer.
*
*******************************************************************************/
void I2CS_I2CSlaveInitWriteBuf(uint8 * wrBuf, uint32 bufSize)
{
    /* Check buffer pointer */
    if(NULL != wrBuf)
    {
        I2CS_DisableInt();  /* Lock from interruption */

        I2CS_slWrBufPtr   = (volatile uint8 *) wrBuf; /* Set buffer pointer  */
        I2CS_slWrBufSize  = bufSize;                  /* Set buffer size     */
        I2CS_slWrBufIndex = 0u;                       /* Clear buffer index  */

        I2CS_EnableInt();   /* Release lock */
    }
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveGetReadBufSize
****************************************************************************//**
*
*  Returns the number of bytes read by the I2C master since an
*  I2CS_I2CSlaveInitReadBuf() or 
*  I2CS_I2CSlaveClearReadBuf() function was executed.
*  The maximum return value is the size of the read buffer.
*
* \return
*  Bytes read by master. If the transfer is not yet complete, it returns 
*  zero until transfer completion.
*
* \sideeffect
*  The returned value is not valid if I2CS_I2C_SSTAT_RD_ERR was 
*  captured by the slave.
*
* \globalvars
*  I2CS_slRdBufIndex - used to store current index within slave
*  read buffer.
*
*******************************************************************************/
uint32 I2CS_I2CSlaveGetReadBufSize(void)
{
    return(I2CS_slRdBufIndex);
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveGetWriteBufSize
****************************************************************************//**
*
*  Returns the number of bytes written by the I2C master since an
*  I2CS_I2CSlaveInitWriteBuf() or 
*  I2CS_I2CSlaveClearWriteBuf() function was executed.
*  The maximum return value is the size of the write buffer.
*
* \return
*  Bytes written by master.
*
* \sideeffect
*  The returned value is not valid if I2CS_I2C_SSTAT_WR_ERR was 
*  captured by the slave.
*
* \globalvars
*  I2CS_slWrBufIndex - used to store current index within slave
*   write buffer.
*
*******************************************************************************/
uint32 I2CS_I2CSlaveGetWriteBufSize(void)
{
    return(I2CS_slWrBufIndex);
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveClearReadBuf
****************************************************************************//**
*
*  Resets the read pointer to the first byte in the read buffer. The next byte
*  read by the master will be the first byte in the read buffer.
*
* \globalvars
*  I2CS_slRdBufIndex - used to store current index within slave
*  read buffer.
*
*******************************************************************************/
void I2CS_I2CSlaveClearReadBuf(void)
{
    I2CS_slRdBufIndex = 0u;
}


/*******************************************************************************
* Function Name: I2CS_I2CSlaveClearWriteBuf
****************************************************************************//**
*
*  Resets the write pointer to the first byte in the write buffer. The next byte
*  written by the master will be the first byte in the write buffer.
*
* \globalvars
*  I2CS_slWrBufIndex - used to store current index within slave
*  write buffer.
*
*******************************************************************************/
void I2CS_I2CSlaveClearWriteBuf(void)
{
    I2CS_slWrBufIndex = 0u;
}

#endif /* (I2CS_I2C_SLAVE_CONST) */


/* [] END OF FILE */
