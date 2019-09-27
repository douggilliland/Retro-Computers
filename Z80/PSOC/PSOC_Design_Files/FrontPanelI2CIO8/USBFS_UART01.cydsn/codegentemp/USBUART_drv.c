/***************************************************************************//**
* \file USBUART_drv.c
* \version 3.20
*
* \brief
*  This file contains the Endpoint 0 Driver for the USBFS Component.  
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_pvt.h"
#include "cyapicallbacks.h"


/***************************************
* Global data allocation
***************************************/

volatile T_USBUART_EP_CTL_BLOCK USBUART_EP[USBUART_MAX_EP];

/** Contains the current configuration number, which is set by the host using a 
 * SET_CONFIGURATION request. This variable is initialized to zero in 
 * USBFS_InitComponent() API and can be read by the USBFS_GetConfiguration() 
 * API.*/
volatile uint8 USBUART_configuration;

/** Contains the current interface number.*/
volatile uint8 USBUART_interfaceNumber;

/** This variable is set to one after SET_CONFIGURATION and SET_INTERFACE 
 *requests. It can be read by the USBFS_IsConfigurationChanged() API */
volatile uint8 USBUART_configurationChanged;

/** Contains the current device address.*/
volatile uint8 USBUART_deviceAddress;

/** This is a two-bit variable that contains power status in the bit 0 
 * (DEVICE_STATUS_BUS_POWERED or DEVICE_STATUS_SELF_POWERED) and remote wakeup 
 * status (DEVICE_STATUS_REMOTE_WAKEUP) in the bit 1. This variable is 
 * initialized to zero in USBFS_InitComponent() API, configured by the 
 * USBFS_SetPowerStatus() API. The remote wakeup status cannot be set using the 
 * API SetPowerStatus(). */
volatile uint8 USBUART_deviceStatus;

volatile uint8 USBUART_interfaceSetting[USBUART_MAX_INTERFACES_NUMBER];
volatile uint8 USBUART_interfaceSetting_last[USBUART_MAX_INTERFACES_NUMBER];
volatile uint8 USBUART_interfaceStatus[USBUART_MAX_INTERFACES_NUMBER];

/** Contains the started device number. This variable is set by the 
 * USBFS_Start() or USBFS_InitComponent() APIs.*/
volatile uint8 USBUART_device;

/** Initialized class array for each interface. It is used for handling Class 
 * specific requests depend on interface class. Different classes in multiple 
 * alternate settings are not supported.*/
const uint8 CYCODE *USBUART_interfaceClass;


/***************************************
* Local data allocation
***************************************/

volatile uint8  USBUART_ep0Toggle;
volatile uint8  USBUART_lastPacketSize;

/** This variable is used by the communication functions to handle the current 
* transfer state.
* Initialized to TRANS_STATE_IDLE in the USBFS_InitComponent() API and after a 
* complete transfer in the status stage.
* Changed to the TRANS_STATE_CONTROL_READ or TRANS_STATE_CONTROL_WRITE in setup 
* transaction depending on the request type.
*/
volatile uint8  USBUART_transferState;
volatile T_USBUART_TD USBUART_currentTD;
volatile uint8  USBUART_ep0Mode;
volatile uint8  USBUART_ep0Count;
volatile uint16 USBUART_transferByteCount;


/*******************************************************************************
* Function Name: USBUART_ep_0_Interrupt
****************************************************************************//**
*
*  This Interrupt Service Routine handles Endpoint 0 (Control Pipe) traffic.
*  It dispatches setup requests and handles the data and status stages.
*
*
*******************************************************************************/
CY_ISR(USBUART_EP_0_ISR)
{
    uint8 tempReg;
    uint8 modifyReg;

#ifdef USBUART_EP_0_ISR_ENTRY_CALLBACK
    USBUART_EP_0_ISR_EntryCallback();
#endif /* (USBUART_EP_0_ISR_ENTRY_CALLBACK) */
    
    tempReg = USBUART_EP0_CR_REG;
    if ((tempReg & USBUART_MODE_ACKD) != 0u)
    {
        modifyReg = 1u;
        if ((tempReg & USBUART_MODE_SETUP_RCVD) != 0u)
        {
            if ((tempReg & USBUART_MODE_MASK) != USBUART_MODE_NAK_IN_OUT)
            {
                /* Mode not equal to NAK_IN_OUT: invalid setup */
                modifyReg = 0u;
            }
            else
            {
                USBUART_HandleSetup();
                
                if ((USBUART_ep0Mode & USBUART_MODE_SETUP_RCVD) != 0u)
                {
                    /* SETUP bit set: exit without mode modificaiton */
                    modifyReg = 0u;
                }
            }
        }
        else if ((tempReg & USBUART_MODE_IN_RCVD) != 0u)
        {
            USBUART_HandleIN();
        }
        else if ((tempReg & USBUART_MODE_OUT_RCVD) != 0u)
        {
            USBUART_HandleOUT();
        }
        else
        {
            modifyReg = 0u;
        }
        
        /* Modify the EP0_CR register */
        if (modifyReg != 0u)
        {
            
            tempReg = USBUART_EP0_CR_REG;
            
            /* Make sure that SETUP bit is cleared before modification */
            if ((tempReg & USBUART_MODE_SETUP_RCVD) == 0u)
            {
                /* Update count register */
                tempReg = (uint8) USBUART_ep0Toggle | USBUART_ep0Count;
                USBUART_EP0_CNT_REG = tempReg;
               
                /* Make sure that previous write operaiton was successful */
                if (tempReg == USBUART_EP0_CNT_REG)
                {
                    /* Repeat until next successful write operation */
                    do
                    {
                        /* Init temporary variable */
                        modifyReg = USBUART_ep0Mode;
                        
                        /* Unlock register */
                        tempReg = (uint8) (USBUART_EP0_CR_REG & USBUART_MODE_SETUP_RCVD);
                        
                        /* Check if SETUP bit is not set */
                        if (0u == tempReg)
                        {
                            /* Set the Mode Register  */
                            USBUART_EP0_CR_REG = USBUART_ep0Mode;
                            
                            /* Writing check */
                            modifyReg = USBUART_EP0_CR_REG & USBUART_MODE_MASK;
                        }
                    }
                    while (modifyReg != USBUART_ep0Mode);
                }
            }
        }
    }

    USBUART_ClearSieInterruptSource(USBUART_INTR_SIE_EP0_INTR);
	
#ifdef USBUART_EP_0_ISR_EXIT_CALLBACK
    USBUART_EP_0_ISR_ExitCallback();
#endif /* (USBUART_EP_0_ISR_EXIT_CALLBACK) */
}


/*******************************************************************************
* Function Name: USBUART_HandleSetup
****************************************************************************//**
*
*  This Routine dispatches requests for the four USB request types
*
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_HandleSetup(void) 
{
    uint8 requestHandled;
    
    /* Clear register lock by SIE (read register) and clear setup bit 
    * (write any value in register).
    */
    requestHandled = (uint8) USBUART_EP0_CR_REG;
    USBUART_EP0_CR_REG = (uint8) requestHandled;
    requestHandled = (uint8) USBUART_EP0_CR_REG;

    if ((requestHandled & USBUART_MODE_SETUP_RCVD) != 0u)
    {
        /* SETUP bit is set: exit without mode modification. */
        USBUART_ep0Mode = requestHandled;
    }
    else
    {
        /* In case the previous transfer did not complete, close it out */
        USBUART_UpdateStatusBlock(USBUART_XFER_PREMATURE);

        /* Check request type. */
        switch (USBUART_bmRequestTypeReg & USBUART_RQST_TYPE_MASK)
        {
            case USBUART_RQST_TYPE_STD:
                requestHandled = USBUART_HandleStandardRqst();
                break;
                
            case USBUART_RQST_TYPE_CLS:
                requestHandled = USBUART_DispatchClassRqst();
                break;
                
            case USBUART_RQST_TYPE_VND:
                requestHandled = USBUART_HandleVendorRqst();
                break;
                
            default:
                requestHandled = USBUART_FALSE;
                break;
        }
        
        /* If request is not recognized. Stall endpoint 0 IN and OUT. */
        if (requestHandled == USBUART_FALSE)
        {
            USBUART_ep0Mode = USBUART_MODE_STALL_IN_OUT;
        }
    }
}


/*******************************************************************************
* Function Name: USBUART_HandleIN
****************************************************************************//**
*
*  This routine handles EP0 IN transfers.
*
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_HandleIN(void) 
{
    switch (USBUART_transferState)
    {
        case USBUART_TRANS_STATE_IDLE:
            break;
        
        case USBUART_TRANS_STATE_CONTROL_READ:
            USBUART_ControlReadDataStage();
            break;
            
        case USBUART_TRANS_STATE_CONTROL_WRITE:
            USBUART_ControlWriteStatusStage();
            break;
            
        case USBUART_TRANS_STATE_NO_DATA_CONTROL:
            USBUART_NoDataControlStatusStage();
            break;
            
        default:    /* there are no more states */
            break;
    }
}


/*******************************************************************************
* Function Name: USBUART_HandleOUT
****************************************************************************//**
*
*  This routine handles EP0 OUT transfers.
*
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_HandleOUT(void) 
{
    switch (USBUART_transferState)
    {
        case USBUART_TRANS_STATE_IDLE:
            break;
        
        case USBUART_TRANS_STATE_CONTROL_READ:
            USBUART_ControlReadStatusStage();
            break;
            
        case USBUART_TRANS_STATE_CONTROL_WRITE:
            USBUART_ControlWriteDataStage();
            break;
            
        case USBUART_TRANS_STATE_NO_DATA_CONTROL:
            /* Update the completion block */
            USBUART_UpdateStatusBlock(USBUART_XFER_ERROR);
            
            /* We expect no more data, so stall INs and OUTs */
            USBUART_ep0Mode = USBUART_MODE_STALL_IN_OUT;
            break;
            
        default:    
            /* There are no more states */
            break;
    }
}


/*******************************************************************************
* Function Name: USBUART_LoadEP0
****************************************************************************//**
*
*  This routine loads the EP0 data registers for OUT transfers. It uses the
*  currentTD (previously initialized by the _InitControlWrite function and
*  updated for each OUT transfer, and the bLastPacketSize) to determine how
*  many uint8s to transfer on the current OUT.
*
*  If the number of uint8s remaining is zero and the last transfer was full,
*  we need to send a zero length packet.  Otherwise we send the minimum
*  of the control endpoint size (8) or remaining number of uint8s for the
*  transaction.
*
*
* \globalvars
*  USBUART_transferByteCount - Update the transfer byte count from the
*     last transaction.
*  USBUART_ep0Count - counts the data loaded to the SIE memory in
*     current packet.
*  USBUART_lastPacketSize - remembers the USBFS_ep0Count value for the
*     next packet.
*  USBUART_transferByteCount - sum of the previous bytes transferred
*     on previous packets(sum of USBFS_lastPacketSize)
*  USBUART_ep0Toggle - inverted
*  USBUART_ep0Mode  - prepare for mode register content.
*  USBUART_transferState - set to TRANS_STATE_CONTROL_READ
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_LoadEP0(void) 
{
    uint8 ep0Count = 0u;

    /* Update the transfer byte count from the last transaction */
    USBUART_transferByteCount += USBUART_lastPacketSize;

    /* Now load the next transaction */
    while ((USBUART_currentTD.count > 0u) && (ep0Count < 8u))
    {
        USBUART_EP0_DR_BASE.epData[ep0Count] = (uint8) *USBUART_currentTD.pData;
        USBUART_currentTD.pData = &USBUART_currentTD.pData[1u];
        ep0Count++;
        USBUART_currentTD.count--;
    }

    /* Support zero-length packet */
    if ((USBUART_lastPacketSize == 8u) || (ep0Count > 0u))
    {
        /* Update the data toggle */
        USBUART_ep0Toggle ^= USBUART_EP0_CNT_DATA_TOGGLE;
        /* Set the Mode Register  */
        USBUART_ep0Mode = USBUART_MODE_ACK_IN_STATUS_OUT;
        /* Update the state (or stay the same) */
        USBUART_transferState = USBUART_TRANS_STATE_CONTROL_READ;
    }
    else
    {
        /* Expect Status Stage Out */
        USBUART_ep0Mode = USBUART_MODE_STATUS_OUT_ONLY;
        /* Update the state (or stay the same) */
        USBUART_transferState = USBUART_TRANS_STATE_CONTROL_READ;
    }

    /* Save the packet size for next time */
    USBUART_ep0Count =       (uint8) ep0Count;
    USBUART_lastPacketSize = (uint8) ep0Count;
}


/*******************************************************************************
* Function Name: USBUART_InitControlRead
****************************************************************************//**
*
*  Initialize a control read transaction. It is used to send data to the host.
*  The following global variables should be initialized before this function
*  called. To send zero length packet use InitZeroLengthControlTransfer
*  function.
*
*
* \return
*  requestHandled state.
*
* \globalvars
*  USBUART_currentTD.count - counts of data to be sent.
*  USBUART_currentTD.pData - data pointer.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_InitControlRead(void) 
{
    uint16 xferCount;

    if (USBUART_currentTD.count == 0u)
    {
        (void) USBUART_InitZeroLengthControlTransfer();
    }
    else
    {
        /* Set up the state machine */
        USBUART_transferState = USBUART_TRANS_STATE_CONTROL_READ;
        
        /* Set the toggle, it gets updated in LoadEP */
        USBUART_ep0Toggle = 0u;
        
        /* Initialize the Status Block */
        USBUART_InitializeStatusBlock();
        
        xferCount = ((uint16)((uint16) USBUART_lengthHiReg << 8u) | ((uint16) USBUART_lengthLoReg));

        if (USBUART_currentTD.count > xferCount)
        {
            USBUART_currentTD.count = xferCount;
        }
        
        USBUART_LoadEP0();
    }

    return (USBUART_TRUE);
}


/*******************************************************************************
* Function Name: USBUART_InitZeroLengthControlTransfer
****************************************************************************//**
*
*  Initialize a zero length data IN transfer.
*
* \return
*  requestHandled state.
*
* \globalvars
*  USBUART_ep0Toggle - set to EP0_CNT_DATA_TOGGLE
*  USBUART_ep0Mode  - prepare for mode register content.
*  USBUART_transferState - set to TRANS_STATE_CONTROL_READ
*  USBUART_ep0Count - cleared, means the zero-length packet.
*  USBUART_lastPacketSize - cleared.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_InitZeroLengthControlTransfer(void)
                                                
{
    /* Update the state */
    USBUART_transferState = USBUART_TRANS_STATE_CONTROL_READ;
    
    /* Set the data toggle */
    USBUART_ep0Toggle = USBUART_EP0_CNT_DATA_TOGGLE;
    
    /* Set the Mode Register  */
    USBUART_ep0Mode = USBUART_MODE_ACK_IN_STATUS_OUT;
    
    /* Save the packet size for next time */
    USBUART_lastPacketSize = 0u;
    
    USBUART_ep0Count = 0u;

    return (USBUART_TRUE);
}


/*******************************************************************************
* Function Name: USBUART_ControlReadDataStage
****************************************************************************//**
*
*  Handle the Data Stage of a control read transfer.
*
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_ControlReadDataStage(void) 

{
    USBUART_LoadEP0();
}


/*******************************************************************************
* Function Name: USBUART_ControlReadStatusStage
****************************************************************************//**
*
*  Handle the Status Stage of a control read transfer.
*
*
* \globalvars
*  USBUART_USBFS_transferByteCount - updated with last packet size.
*  USBUART_transferState - set to TRANS_STATE_IDLE.
*  USBUART_ep0Mode  - set to MODE_STALL_IN_OUT.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_ControlReadStatusStage(void) 
{
    /* Update the transfer byte count */
    USBUART_transferByteCount += USBUART_lastPacketSize;
    
    /* Go Idle */
    USBUART_transferState = USBUART_TRANS_STATE_IDLE;
    
    /* Update the completion block */
    USBUART_UpdateStatusBlock(USBUART_XFER_STATUS_ACK);
    
    /* We expect no more data, so stall INs and OUTs */
    USBUART_ep0Mode = USBUART_MODE_STALL_IN_OUT;
}


/*******************************************************************************
* Function Name: USBUART_InitControlWrite
****************************************************************************//**
*
*  Initialize a control write transaction
*
* \return
*  requestHandled state.
*
* \globalvars
*  USBUART_USBFS_transferState - set to TRANS_STATE_CONTROL_WRITE
*  USBUART_ep0Toggle - set to EP0_CNT_DATA_TOGGLE
*  USBUART_ep0Mode  - set to MODE_ACK_OUT_STATUS_IN
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_InitControlWrite(void) 
{
    uint16 xferCount;

    /* Set up the state machine */
    USBUART_transferState = USBUART_TRANS_STATE_CONTROL_WRITE;
    
    /* This might not be necessary */
    USBUART_ep0Toggle = USBUART_EP0_CNT_DATA_TOGGLE;
    
    /* Initialize the Status Block */
    USBUART_InitializeStatusBlock();

    xferCount = ((uint16)((uint16) USBUART_lengthHiReg << 8u) | ((uint16) USBUART_lengthLoReg));

    if (USBUART_currentTD.count > xferCount)
    {
        USBUART_currentTD.count = xferCount;
    }

    /* Expect Data or Status Stage */
    USBUART_ep0Mode = USBUART_MODE_ACK_OUT_STATUS_IN;

    return(USBUART_TRUE);
}


/*******************************************************************************
* Function Name: USBUART_ControlWriteDataStage
****************************************************************************//**
*
*  Handle the Data Stage of a control write transfer
*       1. Get the data (We assume the destination was validated previously)
*       2. Update the count and data toggle
*       3. Update the mode register for the next transaction
*
*
* \globalvars
*  USBUART_transferByteCount - Update the transfer byte count from the
*    last transaction.
*  USBUART_ep0Count - counts the data loaded from the SIE memory
*    in current packet.
*  USBUART_transferByteCount - sum of the previous bytes transferred
*    on previous packets(sum of USBFS_lastPacketSize)
*  USBUART_ep0Toggle - inverted
*  USBUART_ep0Mode  - set to MODE_ACK_OUT_STATUS_IN.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_ControlWriteDataStage(void) 
{
    uint8 ep0Count;
    uint8 regIndex = 0u;

    ep0Count = (USBUART_EP0_CNT_REG & USBUART_EPX_CNT0_MASK) - USBUART_EPX_CNTX_CRC_COUNT;

    USBUART_transferByteCount += (uint8)ep0Count;

    while ((USBUART_currentTD.count > 0u) && (ep0Count > 0u))
    {
        *USBUART_currentTD.pData = (uint8) USBUART_EP0_DR_BASE.epData[regIndex];
        USBUART_currentTD.pData = &USBUART_currentTD.pData[1u];
        regIndex++;
        ep0Count--;
        USBUART_currentTD.count--;
    }
    
    USBUART_ep0Count = (uint8)ep0Count;
    
    /* Update the data toggle */
    USBUART_ep0Toggle ^= USBUART_EP0_CNT_DATA_TOGGLE;
    
    /* Expect Data or Status Stage */
    USBUART_ep0Mode = USBUART_MODE_ACK_OUT_STATUS_IN;
}


/*******************************************************************************
* Function Name: USBUART_ControlWriteStatusStage
****************************************************************************//**
*
*  Handle the Status Stage of a control write transfer
*
* \globalvars
*  USBUART_transferState - set to TRANS_STATE_IDLE.
*  USBUART_USBFS_ep0Mode  - set to MODE_STALL_IN_OUT.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_ControlWriteStatusStage(void) 
{
    /* Go Idle */
    USBUART_transferState = USBUART_TRANS_STATE_IDLE;
    
    /* Update the completion block */    
    USBUART_UpdateStatusBlock(USBUART_XFER_STATUS_ACK);
    
    /* We expect no more data, so stall INs and OUTs */
    USBUART_ep0Mode = USBUART_MODE_STALL_IN_OUT;
}


/*******************************************************************************
* Function Name: USBUART_InitNoDataControlTransfer
****************************************************************************//**
*
*  Initialize a no data control transfer
*
* \return
*  requestHandled state.
*
* \globalvars
*  USBUART_transferState - set to TRANS_STATE_NO_DATA_CONTROL.
*  USBUART_ep0Mode  - set to MODE_STATUS_IN_ONLY.
*  USBUART_ep0Count - cleared.
*  USBUART_ep0Toggle - set to EP0_CNT_DATA_TOGGLE
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_InitNoDataControlTransfer(void) 
{
    USBUART_transferState = USBUART_TRANS_STATE_NO_DATA_CONTROL;
    USBUART_ep0Mode       = USBUART_MODE_STATUS_IN_ONLY;
    USBUART_ep0Toggle     = USBUART_EP0_CNT_DATA_TOGGLE;
    USBUART_ep0Count      = 0u;

    return (USBUART_TRUE);
}


/*******************************************************************************
* Function Name: USBUART_NoDataControlStatusStage
****************************************************************************//**
*  Handle the Status Stage of a no data control transfer.
*
*  SET_ADDRESS is special, since we need to receive the status stage with
*  the old address.
*
* \globalvars
*  USBUART_transferState - set to TRANS_STATE_IDLE.
*  USBUART_ep0Mode  - set to MODE_STALL_IN_OUT.
*  USBUART_ep0Toggle - set to EP0_CNT_DATA_TOGGLE
*  USBUART_deviceAddress - used to set new address and cleared
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_NoDataControlStatusStage(void) 
{
    if (0u != USBUART_deviceAddress)
    {
        /* Update device address if we got new address. */
        USBUART_CR0_REG = (uint8) USBUART_deviceAddress | USBUART_CR0_ENABLE;
        USBUART_deviceAddress = 0u;
    }

    USBUART_transferState = USBUART_TRANS_STATE_IDLE;
    
    /* Update the completion block. */
    USBUART_UpdateStatusBlock(USBUART_XFER_STATUS_ACK);
    
    /* Stall IN and OUT, no more data is expected. */
    USBUART_ep0Mode = USBUART_MODE_STALL_IN_OUT;
}


/*******************************************************************************
* Function Name: USBUART_UpdateStatusBlock
****************************************************************************//**
*
*  Update the Completion Status Block for a Request.  The block is updated
*  with the completion code the USBUART_transferByteCount.  The
*  StatusBlock Pointer is set to NULL.
*
*  completionCode - status.
*
*
* \globalvars
*  USBUART_currentTD.pStatusBlock->status - updated by the
*    completionCode parameter.
*  USBUART_currentTD.pStatusBlock->length - updated.
*  USBUART_currentTD.pStatusBlock - cleared.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_UpdateStatusBlock(uint8 completionCode) 
{
    if (USBUART_currentTD.pStatusBlock != NULL)
    {
        USBUART_currentTD.pStatusBlock->status = completionCode;
        USBUART_currentTD.pStatusBlock->length = USBUART_transferByteCount;
        USBUART_currentTD.pStatusBlock = NULL;
    }
}


/*******************************************************************************
* Function Name: USBUART_InitializeStatusBlock
****************************************************************************//**
*
*  Initialize the Completion Status Block for a Request.  The completion
*  code is set to USB_XFER_IDLE.
*
*  Also, initializes USBUART_transferByteCount.  Save some space,
*  this is the only consumer.
*
* \globalvars
*  USBUART_currentTD.pStatusBlock->status - set to XFER_IDLE.
*  USBUART_currentTD.pStatusBlock->length - cleared.
*  USBUART_transferByteCount - cleared.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_InitializeStatusBlock(void) 
{
    USBUART_transferByteCount = 0u;
    
    if (USBUART_currentTD.pStatusBlock != NULL)
    {
        USBUART_currentTD.pStatusBlock->status = USBUART_XFER_IDLE;
        USBUART_currentTD.pStatusBlock->length = 0u;
    }
}


/* [] END OF FILE */
