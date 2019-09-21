/*******************************************************************************
* File Name: DMA_A8_15_PM.c
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

#include "DMA_A8_15.h"

/* Check for removal by optimization */
#if !defined(DMA_A8_15_Sync_ctrl_reg__REMOVED)

static DMA_A8_15_BACKUP_STRUCT  DMA_A8_15_backup = {0u};

    
/*******************************************************************************
* Function Name: DMA_A8_15_SaveConfig
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
void DMA_A8_15_SaveConfig(void) 
{
    DMA_A8_15_backup.controlState = DMA_A8_15_Control;
}


/*******************************************************************************
* Function Name: DMA_A8_15_RestoreConfig
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
void DMA_A8_15_RestoreConfig(void) 
{
     DMA_A8_15_Control = DMA_A8_15_backup.controlState;
}


/*******************************************************************************
* Function Name: DMA_A8_15_Sleep
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
void DMA_A8_15_Sleep(void) 
{
    DMA_A8_15_SaveConfig();
}


/*******************************************************************************
* Function Name: DMA_A8_15_Wakeup
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
void DMA_A8_15_Wakeup(void)  
{
    DMA_A8_15_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
