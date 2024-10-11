/*******************************************************************************
* File Name: AdrMidOut_PM.c
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

#include "AdrMidOut.h"

/* Check for removal by optimization */
#if !defined(AdrMidOut_Sync_ctrl_reg__REMOVED)

static AdrMidOut_BACKUP_STRUCT  AdrMidOut_backup = {0u};

    
/*******************************************************************************
* Function Name: AdrMidOut_SaveConfig
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
void AdrMidOut_SaveConfig(void) 
{
    AdrMidOut_backup.controlState = AdrMidOut_Control;
}


/*******************************************************************************
* Function Name: AdrMidOut_RestoreConfig
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
void AdrMidOut_RestoreConfig(void) 
{
     AdrMidOut_Control = AdrMidOut_backup.controlState;
}


/*******************************************************************************
* Function Name: AdrMidOut_Sleep
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
void AdrMidOut_Sleep(void) 
{
    AdrMidOut_SaveConfig();
}


/*******************************************************************************
* Function Name: AdrMidOut_Wakeup
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
void AdrMidOut_Wakeup(void)  
{
    AdrMidOut_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
