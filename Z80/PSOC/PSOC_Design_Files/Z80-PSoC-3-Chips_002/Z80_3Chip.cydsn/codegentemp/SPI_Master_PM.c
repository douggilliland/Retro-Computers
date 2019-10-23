/*******************************************************************************
* File Name: SPI_Master_PM.c
* Version 2.50
*
* Description:
*  This file contains the setup, control and status commands to support
*  component operations in low power mode.
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "SPI_Master_PVT.h"

static SPI_Master_BACKUP_STRUCT SPI_Master_backup =
{
    SPI_Master_DISABLED,
    SPI_Master_BITCTR_INIT,
};


/*******************************************************************************
* Function Name: SPI_Master_SaveConfig
********************************************************************************
*
* Summary:
*  Empty function. Included for consistency with other components.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void SPI_Master_SaveConfig(void) 
{

}


/*******************************************************************************
* Function Name: SPI_Master_RestoreConfig
********************************************************************************
*
* Summary:
*  Empty function. Included for consistency with other components.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void SPI_Master_RestoreConfig(void) 
{

}


/*******************************************************************************
* Function Name: SPI_Master_Sleep
********************************************************************************
*
* Summary:
*  Prepare SPIM Component goes to sleep.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  SPI_Master_backup - modified when non-retention registers are saved.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void SPI_Master_Sleep(void) 
{
    /* Save components enable state */
    SPI_Master_backup.enableState = ((uint8) SPI_Master_IS_ENABLED);

    SPI_Master_Stop();
}


/*******************************************************************************
* Function Name: SPI_Master_Wakeup
********************************************************************************
*
* Summary:
*  Prepare SPIM Component to wake up.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global Variables:
*  SPI_Master_backup - used when non-retention registers are restored.
*  SPI_Master_txBufferWrite - modified every function call - resets to
*  zero.
*  SPI_Master_txBufferRead - modified every function call - resets to
*  zero.
*  SPI_Master_rxBufferWrite - modified every function call - resets to
*  zero.
*  SPI_Master_rxBufferRead - modified every function call - resets to
*  zero.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void SPI_Master_Wakeup(void) 
{
    #if(SPI_Master_RX_SOFTWARE_BUF_ENABLED)
        SPI_Master_rxBufferFull  = 0u;
        SPI_Master_rxBufferRead  = 0u;
        SPI_Master_rxBufferWrite = 0u;
    #endif /* (SPI_Master_RX_SOFTWARE_BUF_ENABLED) */

    #if(SPI_Master_TX_SOFTWARE_BUF_ENABLED)
        SPI_Master_txBufferFull  = 0u;
        SPI_Master_txBufferRead  = 0u;
        SPI_Master_txBufferWrite = 0u;
    #endif /* (SPI_Master_TX_SOFTWARE_BUF_ENABLED) */

    /* Clear any data from the RX and TX FIFO */
    SPI_Master_ClearFIFO();

    /* Restore components block enable state */
    if(0u != SPI_Master_backup.enableState)
    {
        SPI_Master_Enable();
    }
}


/* [] END OF FILE */
