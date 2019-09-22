/*******************************************************************************
* File Name: MemCtlReg_PM.c
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

#include "MemCtlReg.h"

/* Check for removal by optimization */
#if !defined(MemCtlReg_Sync_ctrl_reg__REMOVED)

static MemCtlReg_BACKUP_STRUCT  MemCtlReg_backup = {0u};

    
/*******************************************************************************
* Function Name: MemCtlReg_SaveConfig
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
void MemCtlReg_SaveConfig(void) 
{
    MemCtlReg_backup.controlState = MemCtlReg_Control;
}


/*******************************************************************************
* Function Name: MemCtlReg_RestoreConfig
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
void MemCtlReg_RestoreConfig(void) 
{
     MemCtlReg_Control = MemCtlReg_backup.controlState;
}


/*******************************************************************************
* Function Name: MemCtlReg_Sleep
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
void MemCtlReg_Sleep(void) 
{
    MemCtlReg_SaveConfig();
}


/*******************************************************************************
* Function Name: MemCtlReg_Wakeup
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
void MemCtlReg_Wakeup(void)  
{
    MemCtlReg_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
