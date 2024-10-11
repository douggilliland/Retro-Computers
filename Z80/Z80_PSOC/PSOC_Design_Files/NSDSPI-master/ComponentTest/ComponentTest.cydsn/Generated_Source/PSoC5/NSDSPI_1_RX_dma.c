/***************************************************************************
* File Name: NSDSPI_1_RX_dma.c  
* Version 1.70
*
*  Description:
*   Provides an API for the DMAC component. The API includes functions
*   for the DMA controller, DMA channels and Transfer Descriptors.
*
*
*   Note:
*     This module requires the developer to finish or fill in the auto
*     generated funcions and setup the dma channel and TD's.
*
********************************************************************************
* Copyright 2008-2010, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
********************************************************************************/
#include <CYLIB.H>
#include <CYDMAC.H>
#include <NSDSPI_1_RX_dma.H>



/****************************************************************************
* 
* The following defines are available in Cyfitter.h
* 
* 
* 
* NSDSPI_1_RX__DRQ_CTL_REG
* 
* 
* NSDSPI_1_RX__DRQ_NUMBER
* 
* Number of TD's used by this channel.
* NSDSPI_1_RX__NUMBEROF_TDS
* 
* Priority of this channel.
* NSDSPI_1_RX__PRIORITY
* 
* True if NSDSPI_1_RX_TERMIN_SEL is used.
* NSDSPI_1_RX__TERMIN_EN
* 
* TERMIN interrupt line to signal terminate.
* NSDSPI_1_RX__TERMIN_SEL
* 
* 
* True if NSDSPI_1_RX_TERMOUT0_SEL is used.
* NSDSPI_1_RX__TERMOUT0_EN
* 
* 
* TERMOUT0 interrupt line to signal completion.
* NSDSPI_1_RX__TERMOUT0_SEL
* 
* 
* True if NSDSPI_1_RX_TERMOUT1_SEL is used.
* NSDSPI_1_RX__TERMOUT1_EN
* 
* 
* TERMOUT1 interrupt line to signal completion.
* NSDSPI_1_RX__TERMOUT1_SEL
* 
****************************************************************************/


/* Zero based index of NSDSPI_1_RX dma channel */
uint8 NSDSPI_1_RX_DmaHandle = DMA_INVALID_CHANNEL;

/*********************************************************************
* Function Name: uint8 NSDSPI_1_RX_DmaInitalize
**********************************************************************
* Summary:
*   Allocates and initialises a channel of the DMAC to be used by the
*   caller.
*
* Parameters:
*   BurstCount.
*       
*       
*   ReqestPerBurst.
*       
*       
*   UpperSrcAddress.
*       
*       
*   UpperDestAddress.
*       
*
* Return:
*   The channel that can be used by the caller for DMA activity.
*   DMA_INVALID_CHANNEL (0xFF) if there are no channels left. 
*
*
*******************************************************************/
uint8 NSDSPI_1_RX_DmaInitialize(uint8 BurstCount, uint8 ReqestPerBurst, uint16 UpperSrcAddress, uint16 UpperDestAddress) 
{

    /* Allocate a DMA channel. */
    NSDSPI_1_RX_DmaHandle = (uint8)NSDSPI_1_RX__DRQ_NUMBER;

    /* Configure the channel. */
    (void)CyDmaChSetConfiguration(NSDSPI_1_RX_DmaHandle,
                                  BurstCount,
                                  ReqestPerBurst,
                                  (uint8)NSDSPI_1_RX__TERMOUT0_SEL,
                                  (uint8)NSDSPI_1_RX__TERMOUT1_SEL,
                                  (uint8)NSDSPI_1_RX__TERMIN_SEL);

    /* Set the extended address for the transfers */
    (void)CyDmaChSetExtendedAddress(NSDSPI_1_RX_DmaHandle, UpperSrcAddress, UpperDestAddress);

    /* Set the priority for this channel */
    (void)CyDmaChPriority(NSDSPI_1_RX_DmaHandle, (uint8)NSDSPI_1_RX__PRIORITY);
    
    return NSDSPI_1_RX_DmaHandle;
}

/*********************************************************************
* Function Name: void NSDSPI_1_RX_DmaRelease
**********************************************************************
* Summary:
*   Frees the channel associated with NSDSPI_1_RX.
*
*
* Parameters:
*   void.
*
*
*
* Return:
*   void.
*
*******************************************************************/
void NSDSPI_1_RX_DmaRelease(void) 
{
    /* Disable the channel */
    (void)CyDmaChDisable(NSDSPI_1_RX_DmaHandle);
}

