/*******************************************************************************
* File Name: EndPWMB_PM.c
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

#include "EndPWMB.h"

/* Check for removal by optimization */
#if !defined(EndPWMB_Sync_ctrl_reg__REMOVED)

static EndPWMB_BACKUP_STRUCT  EndPWMB_backup = {0u};

    
/*******************************************************************************
* Function Name: EndPWMB_SaveConfig
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
void EndPWMB_SaveConfig(void) 
{
    EndPWMB_backup.controlState = EndPWMB_Control;
}


/*******************************************************************************
* Function Name: EndPWMB_RestoreConfig
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
void EndPWMB_RestoreConfig(void) 
{
     EndPWMB_Control = EndPWMB_backup.controlState;
}


/*******************************************************************************
* Function Name: EndPWMB_Sleep
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
void EndPWMB_Sleep(void) 
{
    EndPWMB_SaveConfig();
}


/*******************************************************************************
* Function Name: EndPWMB_Wakeup
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
void EndPWMB_Wakeup(void)  
{
    EndPWMB_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
