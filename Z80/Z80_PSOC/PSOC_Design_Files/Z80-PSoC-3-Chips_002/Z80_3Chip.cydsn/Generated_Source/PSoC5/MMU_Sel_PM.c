/*******************************************************************************
* File Name: MMU_Sel_PM.c
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

#include "MMU_Sel.h"

/* Check for removal by optimization */
#if !defined(MMU_Sel_Sync_ctrl_reg__REMOVED)

static MMU_Sel_BACKUP_STRUCT  MMU_Sel_backup = {0u};

    
/*******************************************************************************
* Function Name: MMU_Sel_SaveConfig
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
void MMU_Sel_SaveConfig(void) 
{
    MMU_Sel_backup.controlState = MMU_Sel_Control;
}


/*******************************************************************************
* Function Name: MMU_Sel_RestoreConfig
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
void MMU_Sel_RestoreConfig(void) 
{
     MMU_Sel_Control = MMU_Sel_backup.controlState;
}


/*******************************************************************************
* Function Name: MMU_Sel_Sleep
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
void MMU_Sel_Sleep(void) 
{
    MMU_Sel_SaveConfig();
}


/*******************************************************************************
* Function Name: MMU_Sel_Wakeup
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
void MMU_Sel_Wakeup(void)  
{
    MMU_Sel_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
