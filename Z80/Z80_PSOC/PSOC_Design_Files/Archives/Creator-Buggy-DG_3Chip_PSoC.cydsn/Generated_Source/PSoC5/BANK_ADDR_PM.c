/*******************************************************************************
* File Name: BANK_ADDR_PM.c
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

#include "BANK_ADDR.h"

/* Check for removal by optimization */
#if !defined(BANK_ADDR_Sync_ctrl_reg__REMOVED)

static BANK_ADDR_BACKUP_STRUCT  BANK_ADDR_backup = {0u};

    
/*******************************************************************************
* Function Name: BANK_ADDR_SaveConfig
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
void BANK_ADDR_SaveConfig(void) 
{
    BANK_ADDR_backup.controlState = BANK_ADDR_Control;
}


/*******************************************************************************
* Function Name: BANK_ADDR_RestoreConfig
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
void BANK_ADDR_RestoreConfig(void) 
{
     BANK_ADDR_Control = BANK_ADDR_backup.controlState;
}


/*******************************************************************************
* Function Name: BANK_ADDR_Sleep
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
void BANK_ADDR_Sleep(void) 
{
    BANK_ADDR_SaveConfig();
}


/*******************************************************************************
* Function Name: BANK_ADDR_Wakeup
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
void BANK_ADDR_Wakeup(void)  
{
    BANK_ADDR_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
