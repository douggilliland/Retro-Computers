/*******************************************************************************
* File Name: DMA_A0_7_PM.c
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

#include "DMA_A0_7.h"

/* Check for removal by optimization */
#if !defined(DMA_A0_7_Sync_ctrl_reg__REMOVED)

static DMA_A0_7_BACKUP_STRUCT  DMA_A0_7_backup = {0u};

    
/*******************************************************************************
* Function Name: DMA_A0_7_SaveConfig
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
void DMA_A0_7_SaveConfig(void) 
{
    DMA_A0_7_backup.controlState = DMA_A0_7_Control;
}


/*******************************************************************************
* Function Name: DMA_A0_7_RestoreConfig
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
void DMA_A0_7_RestoreConfig(void) 
{
     DMA_A0_7_Control = DMA_A0_7_backup.controlState;
}


/*******************************************************************************
* Function Name: DMA_A0_7_Sleep
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
void DMA_A0_7_Sleep(void) 
{
    DMA_A0_7_SaveConfig();
}


/*******************************************************************************
* Function Name: DMA_A0_7_Wakeup
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
void DMA_A0_7_Wakeup(void)  
{
    DMA_A0_7_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
