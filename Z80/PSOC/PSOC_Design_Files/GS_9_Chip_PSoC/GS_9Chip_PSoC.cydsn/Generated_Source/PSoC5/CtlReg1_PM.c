/*******************************************************************************
* File Name: CtlReg1_PM.c
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

#include "CtlReg1.h"

/* Check for removal by optimization */
#if !defined(CtlReg1_Sync_ctrl_reg__REMOVED)

static CtlReg1_BACKUP_STRUCT  CtlReg1_backup = {0u};

    
/*******************************************************************************
* Function Name: CtlReg1_SaveConfig
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
void CtlReg1_SaveConfig(void) 
{
    CtlReg1_backup.controlState = CtlReg1_Control;
}


/*******************************************************************************
* Function Name: CtlReg1_RestoreConfig
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
void CtlReg1_RestoreConfig(void) 
{
     CtlReg1_Control = CtlReg1_backup.controlState;
}


/*******************************************************************************
* Function Name: CtlReg1_Sleep
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
void CtlReg1_Sleep(void) 
{
    CtlReg1_SaveConfig();
}


/*******************************************************************************
* Function Name: CtlReg1_Wakeup
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
void CtlReg1_Wakeup(void)  
{
    CtlReg1_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
