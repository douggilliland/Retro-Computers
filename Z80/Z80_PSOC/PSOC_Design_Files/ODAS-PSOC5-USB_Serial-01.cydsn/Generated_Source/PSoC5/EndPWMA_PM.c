/*******************************************************************************
* File Name: EndPWMA_PM.c
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

#include "EndPWMA.h"

/* Check for removal by optimization */
#if !defined(EndPWMA_Sync_ctrl_reg__REMOVED)

static EndPWMA_BACKUP_STRUCT  EndPWMA_backup = {0u};

    
/*******************************************************************************
* Function Name: EndPWMA_SaveConfig
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
void EndPWMA_SaveConfig(void) 
{
    EndPWMA_backup.controlState = EndPWMA_Control;
}


/*******************************************************************************
* Function Name: EndPWMA_RestoreConfig
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
void EndPWMA_RestoreConfig(void) 
{
     EndPWMA_Control = EndPWMA_backup.controlState;
}


/*******************************************************************************
* Function Name: EndPWMA_Sleep
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
void EndPWMA_Sleep(void) 
{
    EndPWMA_SaveConfig();
}


/*******************************************************************************
* Function Name: EndPWMA_Wakeup
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
void EndPWMA_Wakeup(void)  
{
    EndPWMA_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
