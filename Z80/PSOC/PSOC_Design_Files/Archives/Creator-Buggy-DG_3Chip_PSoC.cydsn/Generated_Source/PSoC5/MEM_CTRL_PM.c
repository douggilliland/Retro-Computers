/*******************************************************************************
* File Name: MEM_CTRL_PM.c
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

#include "MEM_CTRL.h"

/* Check for removal by optimization */
#if !defined(MEM_CTRL_Sync_ctrl_reg__REMOVED)

static MEM_CTRL_BACKUP_STRUCT  MEM_CTRL_backup = {0u};

    
/*******************************************************************************
* Function Name: MEM_CTRL_SaveConfig
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
void MEM_CTRL_SaveConfig(void) 
{
    MEM_CTRL_backup.controlState = MEM_CTRL_Control;
}


/*******************************************************************************
* Function Name: MEM_CTRL_RestoreConfig
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
void MEM_CTRL_RestoreConfig(void) 
{
     MEM_CTRL_Control = MEM_CTRL_backup.controlState;
}


/*******************************************************************************
* Function Name: MEM_CTRL_Sleep
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
void MEM_CTRL_Sleep(void) 
{
    MEM_CTRL_SaveConfig();
}


/*******************************************************************************
* Function Name: MEM_CTRL_Wakeup
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
void MEM_CTRL_Wakeup(void)  
{
    MEM_CTRL_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
