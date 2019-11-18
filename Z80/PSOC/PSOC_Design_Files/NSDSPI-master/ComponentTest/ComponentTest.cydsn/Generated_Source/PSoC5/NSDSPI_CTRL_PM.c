/*******************************************************************************
* File Name: NSDSPI_CTRL_PM.c
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

#include "NSDSPI_CTRL.h"

/* Check for removal by optimization */
#if !defined(NSDSPI_CTRL_Sync_ctrl_reg__REMOVED)

static NSDSPI_CTRL_BACKUP_STRUCT  NSDSPI_CTRL_backup = {0u};

    
/*******************************************************************************
* Function Name: NSDSPI_CTRL_SaveConfig
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
void NSDSPI_CTRL_SaveConfig(void) 
{
    NSDSPI_CTRL_backup.controlState = NSDSPI_CTRL_Control;
}


/*******************************************************************************
* Function Name: NSDSPI_CTRL_RestoreConfig
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
void NSDSPI_CTRL_RestoreConfig(void) 
{
     NSDSPI_CTRL_Control = NSDSPI_CTRL_backup.controlState;
}


/*******************************************************************************
* Function Name: NSDSPI_CTRL_Sleep
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
void NSDSPI_CTRL_Sleep(void) 
{
    NSDSPI_CTRL_SaveConfig();
}


/*******************************************************************************
* Function Name: NSDSPI_CTRL_Wakeup
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
void NSDSPI_CTRL_Wakeup(void)  
{
    NSDSPI_CTRL_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
