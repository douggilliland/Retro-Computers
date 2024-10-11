/*******************************************************************************
* File Name: SPIM_1_PM.c
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

#include "SPIM_1_PVT.h"

static SPIM_1_BACKUP_STRUCT SPIM_1_backup =
{
    SPIM_1_DISABLED,
    SPIM_1_BITCTR_INIT,
};


/*******************************************************************************
* Function Name: SPIM_1_SaveConfig
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
void SPIM_1_SaveConfig(void) 
{

}


/*******************************************************************************
* Function Name: SPIM_1_RestoreConfig
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
void SPIM_1_RestoreConfig(void) 
{

}


/*******************************************************************************
* Function Name: SPIM_1_Sleep
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
*  SPIM_1_backup - modified when non-retention registers are saved.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void SPIM_1_Sleep(void) 
{
    /* Save components enable state */
    SPIM_1_backup.enableState = ((uint8) SPIM_1_IS_ENABLED);

    SPIM_1_Stop();
}


/*******************************************************************************
* Function Name: SPIM_1_Wakeup
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
*  SPIM_1_backup - used when non-retention registers are restored.
*  SPIM_1_txBufferWrite - modified every function call - resets to
*  zero.
*  SPIM_1_txBufferRead - modified every function call - resets to
*  zero.
*  SPIM_1_rxBufferWrite - modified every function call - resets to
*  zero.
*  SPIM_1_rxBufferRead - modified every function call - resets to
*  zero.
*
* Reentrant:
*  No.
*
*******************************************************************************/
void SPIM_1_Wakeup(void) 
{
    #if(SPIM_1_RX_SOFTWARE_BUF_ENABLED)
        SPIM_1_rxBufferFull  = 0u;
        SPIM_1_rxBufferRead  = 0u;
        SPIM_1_rxBufferWrite = 0u;
    #endif /* (SPIM_1_RX_SOFTWARE_BUF_ENABLED) */

    #if(SPIM_1_TX_SOFTWARE_BUF_ENABLED)
        SPIM_1_txBufferFull  = 0u;
        SPIM_1_txBufferRead  = 0u;
        SPIM_1_txBufferWrite = 0u;
    #endif /* (SPIM_1_TX_SOFTWARE_BUF_ENABLED) */

    /* Clear any data from the RX and TX FIFO */
    SPIM_1_ClearFIFO();

    /* Restore components block enable state */
    if(0u != SPIM_1_backup.enableState)
    {
        SPIM_1_Enable();
    }
}


/* [] END OF FILE */
