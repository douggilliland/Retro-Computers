/*******************************************************************************
* File Name: AdrLowOut_PM.c
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

#include "AdrLowOut.h"

/* Check for removal by optimization */
#if !defined(AdrLowOut_Sync_ctrl_reg__REMOVED)

static AdrLowOut_BACKUP_STRUCT  AdrLowOut_backup = {0u};

    
/*******************************************************************************
* Function Name: AdrLowOut_SaveConfig
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
void AdrLowOut_SaveConfig(void) 
{
    AdrLowOut_backup.controlState = AdrLowOut_Control;
}


/*******************************************************************************
* Function Name: AdrLowOut_RestoreConfig
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
void AdrLowOut_RestoreConfig(void) 
{
     AdrLowOut_Control = AdrLowOut_backup.controlState;
}


/*******************************************************************************
* Function Name: AdrLowOut_Sleep
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
void AdrLowOut_Sleep(void) 
{
    AdrLowOut_SaveConfig();
}


/*******************************************************************************
* Function Name: AdrLowOut_Wakeup
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
void AdrLowOut_Wakeup(void)  
{
    AdrLowOut_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
