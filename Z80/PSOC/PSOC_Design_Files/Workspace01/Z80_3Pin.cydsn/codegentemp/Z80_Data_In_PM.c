/*******************************************************************************
* File Name: Z80_Data_In_PM.c
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

#include "Z80_Data_In.h"

/* Check for removal by optimization */
#if !defined(Z80_Data_In_Sync_ctrl_reg__REMOVED)

static Z80_Data_In_BACKUP_STRUCT  Z80_Data_In_backup = {0u};

    
/*******************************************************************************
* Function Name: Z80_Data_In_SaveConfig
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
void Z80_Data_In_SaveConfig(void) 
{
    Z80_Data_In_backup.controlState = Z80_Data_In_Control;
}


/*******************************************************************************
* Function Name: Z80_Data_In_RestoreConfig
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
void Z80_Data_In_RestoreConfig(void) 
{
     Z80_Data_In_Control = Z80_Data_In_backup.controlState;
}


/*******************************************************************************
* Function Name: Z80_Data_In_Sleep
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
void Z80_Data_In_Sleep(void) 
{
    Z80_Data_In_SaveConfig();
}


/*******************************************************************************
* Function Name: Z80_Data_In_Wakeup
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
void Z80_Data_In_Wakeup(void)  
{
    Z80_Data_In_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
