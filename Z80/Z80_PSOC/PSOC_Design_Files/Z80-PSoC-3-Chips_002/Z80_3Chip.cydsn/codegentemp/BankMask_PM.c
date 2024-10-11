/*******************************************************************************
* File Name: BankMask_PM.c
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

#include "BankMask.h"

/* Check for removal by optimization */
#if !defined(BankMask_Sync_ctrl_reg__REMOVED)

static BankMask_BACKUP_STRUCT  BankMask_backup = {0u};

    
/*******************************************************************************
* Function Name: BankMask_SaveConfig
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
void BankMask_SaveConfig(void) 
{
    BankMask_backup.controlState = BankMask_Control;
}


/*******************************************************************************
* Function Name: BankMask_RestoreConfig
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
void BankMask_RestoreConfig(void) 
{
     BankMask_Control = BankMask_backup.controlState;
}


/*******************************************************************************
* Function Name: BankMask_Sleep
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
void BankMask_Sleep(void) 
{
    BankMask_SaveConfig();
}


/*******************************************************************************
* Function Name: BankMask_Wakeup
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
void BankMask_Wakeup(void)  
{
    BankMask_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
