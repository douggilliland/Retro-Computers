/*******************************************************************************
* File Name: UART_Data_P2Z_PM.c
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

#include "UART_Data_P2Z.h"

/* Check for removal by optimization */
#if !defined(UART_Data_P2Z_Sync_ctrl_reg__REMOVED)

static UART_Data_P2Z_BACKUP_STRUCT  UART_Data_P2Z_backup = {0u};

    
/*******************************************************************************
* Function Name: UART_Data_P2Z_SaveConfig
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
void UART_Data_P2Z_SaveConfig(void) 
{
    UART_Data_P2Z_backup.controlState = UART_Data_P2Z_Control;
}


/*******************************************************************************
* Function Name: UART_Data_P2Z_RestoreConfig
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
void UART_Data_P2Z_RestoreConfig(void) 
{
     UART_Data_P2Z_Control = UART_Data_P2Z_backup.controlState;
}


/*******************************************************************************
* Function Name: UART_Data_P2Z_Sleep
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
void UART_Data_P2Z_Sleep(void) 
{
    UART_Data_P2Z_SaveConfig();
}


/*******************************************************************************
* Function Name: UART_Data_P2Z_Wakeup
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
void UART_Data_P2Z_Wakeup(void)  
{
    UART_Data_P2Z_RestoreConfig();
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
