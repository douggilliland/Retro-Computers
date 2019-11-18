/******************************************************************************
* File Name: NSDSPI_TX_dma.h  
* Version 1.70
*
*  Description:
*   Provides the function definitions for the DMA Controller.
*
*
********************************************************************************
* Copyright 2008-2010, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
********************************************************************************/
#if !defined(CY_DMA_NSDSPI_TX_DMA_H__)
#define CY_DMA_NSDSPI_TX_DMA_H__



#include <CYDMAC.H>
#include <CYFITTER.H>

#define NSDSPI_TX__TD_TERMOUT_EN (((0 != NSDSPI_TX__TERMOUT0_EN) ? TD_TERMOUT0_EN : 0) | \
    (NSDSPI_TX__TERMOUT1_EN ? TD_TERMOUT1_EN : 0))

/* Zero based index of NSDSPI_TX dma channel */
extern uint8 NSDSPI_TX_DmaHandle;


uint8 NSDSPI_TX_DmaInitialize(uint8 BurstCount, uint8 ReqestPerBurst, uint16 UpperSrcAddress, uint16 UpperDestAddress) ;
void  NSDSPI_TX_DmaRelease(void) ;


/* CY_DMA_NSDSPI_TX_DMA_H__ */
#endif
