/*******************************************************************************
* File Name: AdrOutReg_PM.c
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

#include "AdrOutReg.h"

/* Check for removal by optimization */
#if !defined(AdrOutReg_Sync_ctrl_reg__REMOVED)

static AdrOutReg_BACKUP_STRUCT  AdrOutReg_backup = {0u};

    
/*******************************************************************************
* Function Name: AdrOutReg_SaveConfig
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
void AdrOutReg_SaveConfig(void) 
{
    AdrOutReg_backup.controlState = AdrOutReg_Control;
}


/*******************************************************************************
* Function Name: AdrOutReg_RestoreConfig
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
void AdrOutReg_RestoreConfig(void) 
{
     AdrOutReg_Control = AdrOutReg_backup.controlState;
}


/*******************************************************************************
* Function Name: AdrOutReg_Sleep
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
void AdrOutReg_Sleep(void) 
{
    AdrOutReg_SaveConfig();
}


/*******************************************************************************
* Function Name: AdrOutReg_Wakeup
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
void AdrOutReg_Wakeup(void)  
{
    AdrOutReg_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
