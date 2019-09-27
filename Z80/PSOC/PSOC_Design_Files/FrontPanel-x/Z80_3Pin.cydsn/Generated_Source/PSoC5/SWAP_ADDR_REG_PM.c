/*******************************************************************************
* File Name: SWAP_ADDR_REG_PM.c
* Version 1.80
*
* Description:
*  This file contains the setup, control, and status commands to support 
*  the component operation in the low power mode. 
*
* Note:
*
********************************************************************************
* Copyright 2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#include "SWAP_ADDR_REG.h"

/* Check for removal by optimization */
#if !defined(SWAP_ADDR_REG_Sync_ctrl_reg__REMOVED)

static SWAP_ADDR_REG_BACKUP_STRUCT  SWAP_ADDR_REG_backup = {0u};

    
/*******************************************************************************
* Function Name: SWAP_ADDR_REG_SaveConfig
********************************************************************************
*
* Summary:
*  Saves the control register value.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void SWAP_ADDR_REG_SaveConfig(void) 
{
    SWAP_ADDR_REG_backup.controlState = SWAP_ADDR_REG_Control;
}


/*******************************************************************************
* Function Name: SWAP_ADDR_REG_RestoreConfig
********************************************************************************
*
* Summary:
*  Restores the control register value.
*
* Parameters:
*  None
*
* Return:
*  None
*
*
*******************************************************************************/
void SWAP_ADDR_REG_RestoreConfig(void) 
{
     SWAP_ADDR_REG_Control = SWAP_ADDR_REG_backup.controlState;
}


/*******************************************************************************
* Function Name: SWAP_ADDR_REG_Sleep
********************************************************************************
*
* Summary:
*  Prepares the component for entering the low power mode.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void SWAP_ADDR_REG_Sleep(void) 
{
    SWAP_ADDR_REG_SaveConfig();
}


/*******************************************************************************
* Function Name: SWAP_ADDR_REG_Wakeup
********************************************************************************
*
* Summary:
*  Restores the component after waking up from the low power mode.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void SWAP_ADDR_REG_Wakeup(void)  
{
    SWAP_ADDR_REG_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
