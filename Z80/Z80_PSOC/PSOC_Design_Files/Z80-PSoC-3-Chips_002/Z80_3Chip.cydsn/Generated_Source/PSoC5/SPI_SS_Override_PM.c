/*******************************************************************************
* File Name: SPI_SS_Override_PM.c
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

#include "SPI_SS_Override.h"

/* Check for removal by optimization */
#if !defined(SPI_SS_Override_Sync_ctrl_reg__REMOVED)

static SPI_SS_Override_BACKUP_STRUCT  SPI_SS_Override_backup = {0u};

    
/*******************************************************************************
* Function Name: SPI_SS_Override_SaveConfig
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
void SPI_SS_Override_SaveConfig(void) 
{
    SPI_SS_Override_backup.controlState = SPI_SS_Override_Control;
}


/*******************************************************************************
* Function Name: SPI_SS_Override_RestoreConfig
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
void SPI_SS_Override_RestoreConfig(void) 
{
     SPI_SS_Override_Control = SPI_SS_Override_backup.controlState;
}


/*******************************************************************************
* Function Name: SPI_SS_Override_Sleep
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
void SPI_SS_Override_Sleep(void) 
{
    SPI_SS_Override_SaveConfig();
}


/*******************************************************************************
* Function Name: SPI_SS_Override_Wakeup
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
void SPI_SS_Override_Wakeup(void)  
{
    SPI_SS_Override_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
