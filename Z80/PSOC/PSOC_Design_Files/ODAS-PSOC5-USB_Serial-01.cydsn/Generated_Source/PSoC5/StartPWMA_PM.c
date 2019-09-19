/*******************************************************************************
* File Name: StartPWMA_PM.c
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

#include "StartPWMA.h"

/* Check for removal by optimization */
#if !defined(StartPWMA_Sync_ctrl_reg__REMOVED)

static StartPWMA_BACKUP_STRUCT  StartPWMA_backup = {0u};

    
/*******************************************************************************
* Function Name: StartPWMA_SaveConfig
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
void StartPWMA_SaveConfig(void) 
{
    StartPWMA_backup.controlState = StartPWMA_Control;
}


/*******************************************************************************
* Function Name: StartPWMA_RestoreConfig
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
void StartPWMA_RestoreConfig(void) 
{
     StartPWMA_Control = StartPWMA_backup.controlState;
}


/*******************************************************************************
* Function Name: StartPWMA_Sleep
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
void StartPWMA_Sleep(void) 
{
    StartPWMA_SaveConfig();
}


/*******************************************************************************
* Function Name: StartPWMA_Wakeup
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
void StartPWMA_Wakeup(void)  
{
    StartPWMA_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
