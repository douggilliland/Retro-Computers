/*******************************************************************************
* File Name: BankBaseAdr_PM.c
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

#include "BankBaseAdr.h"

/* Check for removal by optimization */
#if !defined(BankBaseAdr_Sync_ctrl_reg__REMOVED)

static BankBaseAdr_BACKUP_STRUCT  BankBaseAdr_backup = {0u};

    
/*******************************************************************************
* Function Name: BankBaseAdr_SaveConfig
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
void BankBaseAdr_SaveConfig(void) 
{
    BankBaseAdr_backup.controlState = BankBaseAdr_Control;
}


/*******************************************************************************
* Function Name: BankBaseAdr_RestoreConfig
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
void BankBaseAdr_RestoreConfig(void) 
{
     BankBaseAdr_Control = BankBaseAdr_backup.controlState;
}


/*******************************************************************************
* Function Name: BankBaseAdr_Sleep
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
void BankBaseAdr_Sleep(void) 
{
    BankBaseAdr_SaveConfig();
}


/*******************************************************************************
* Function Name: BankBaseAdr_Wakeup
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
void BankBaseAdr_Wakeup(void)  
{
    BankBaseAdr_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
