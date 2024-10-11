/*******************************************************************************
* File Name: StartPWMB_PM.c
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

#include "StartPWMB.h"

/* Check for removal by optimization */
#if !defined(StartPWMB_Sync_ctrl_reg__REMOVED)

static StartPWMB_BACKUP_STRUCT  StartPWMB_backup = {0u};

    
/*******************************************************************************
* Function Name: StartPWMB_SaveConfig
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
void StartPWMB_SaveConfig(void) 
{
    StartPWMB_backup.controlState = StartPWMB_Control;
}


/*******************************************************************************
* Function Name: StartPWMB_RestoreConfig
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
void StartPWMB_RestoreConfig(void) 
{
     StartPWMB_Control = StartPWMB_backup.controlState;
}


/*******************************************************************************
* Function Name: StartPWMB_Sleep
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
void StartPWMB_Sleep(void) 
{
    StartPWMB_SaveConfig();
}


/*******************************************************************************
* Function Name: StartPWMB_Wakeup
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
void StartPWMB_Wakeup(void)  
{
    StartPWMB_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
