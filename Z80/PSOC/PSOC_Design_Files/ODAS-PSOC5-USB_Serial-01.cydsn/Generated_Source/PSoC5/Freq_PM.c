/*******************************************************************************
* File Name: Freq_PM.c
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

#include "Freq.h"

/* Check for removal by optimization */
#if !defined(Freq_Sync_ctrl_reg__REMOVED)

static Freq_BACKUP_STRUCT  Freq_backup = {0u};

    
/*******************************************************************************
* Function Name: Freq_SaveConfig
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
void Freq_SaveConfig(void) 
{
    Freq_backup.controlState = Freq_Control;
}


/*******************************************************************************
* Function Name: Freq_RestoreConfig
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
void Freq_RestoreConfig(void) 
{
     Freq_Control = Freq_backup.controlState;
}


/*******************************************************************************
* Function Name: Freq_Sleep
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
void Freq_Sleep(void) 
{
    Freq_SaveConfig();
}


/*******************************************************************************
* Function Name: Freq_Wakeup
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
void Freq_Wakeup(void)  
{
    Freq_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
