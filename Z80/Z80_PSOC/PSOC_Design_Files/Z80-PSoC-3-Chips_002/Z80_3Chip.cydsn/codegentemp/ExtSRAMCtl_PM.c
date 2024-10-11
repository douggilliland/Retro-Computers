/*******************************************************************************
* File Name: ExtSRAMCtl_PM.c
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

#include "ExtSRAMCtl.h"

/* Check for removal by optimization */
#if !defined(ExtSRAMCtl_Sync_ctrl_reg__REMOVED)

static ExtSRAMCtl_BACKUP_STRUCT  ExtSRAMCtl_backup = {0u};

    
/*******************************************************************************
* Function Name: ExtSRAMCtl_SaveConfig
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
void ExtSRAMCtl_SaveConfig(void) 
{
    ExtSRAMCtl_backup.controlState = ExtSRAMCtl_Control;
}


/*******************************************************************************
* Function Name: ExtSRAMCtl_RestoreConfig
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
void ExtSRAMCtl_RestoreConfig(void) 
{
     ExtSRAMCtl_Control = ExtSRAMCtl_backup.controlState;
}


/*******************************************************************************
* Function Name: ExtSRAMCtl_Sleep
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
void ExtSRAMCtl_Sleep(void) 
{
    ExtSRAMCtl_SaveConfig();
}


/*******************************************************************************
* Function Name: ExtSRAMCtl_Wakeup
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
void ExtSRAMCtl_Wakeup(void)  
{
    ExtSRAMCtl_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
