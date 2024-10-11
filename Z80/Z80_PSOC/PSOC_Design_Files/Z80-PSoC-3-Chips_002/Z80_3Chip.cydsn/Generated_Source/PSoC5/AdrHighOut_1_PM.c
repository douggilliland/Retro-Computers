/*******************************************************************************
* File Name: AdrHighOut_1_PM.c
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

#include "AdrHighOut_1.h"

/* Check for removal by optimization */
#if !defined(AdrHighOut_1_Sync_ctrl_reg__REMOVED)

static AdrHighOut_1_BACKUP_STRUCT  AdrHighOut_1_backup = {0u};

    
/*******************************************************************************
* Function Name: AdrHighOut_1_SaveConfig
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
void AdrHighOut_1_SaveConfig(void) 
{
    AdrHighOut_1_backup.controlState = AdrHighOut_1_Control;
}


/*******************************************************************************
* Function Name: AdrHighOut_1_RestoreConfig
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
void AdrHighOut_1_RestoreConfig(void) 
{
     AdrHighOut_1_Control = AdrHighOut_1_backup.controlState;
}


/*******************************************************************************
* Function Name: AdrHighOut_1_Sleep
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
void AdrHighOut_1_Sleep(void) 
{
    AdrHighOut_1_SaveConfig();
}


/*******************************************************************************
* Function Name: AdrHighOut_1_Wakeup
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
void AdrHighOut_1_Wakeup(void)  
{
    AdrHighOut_1_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
