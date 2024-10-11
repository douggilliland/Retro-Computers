/*******************************************************************************
* File Name: NSDSPI_1_UDB_BIT_COUNTER_PM.c
* Version 1.0
*
* Description:
*  This file provides Low power mode APIs for Count7 component.
*
* Note:
*  None
*
********************************************************************************
* Copyright 2013, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "NSDSPI_1_UDB_BIT_COUNTER.h"


NSDSPI_1_UDB_BIT_COUNTER_BACKUP_STRUCT NSDSPI_1_UDB_BIT_COUNTER_backup;


/*******************************************************************************
* Function Name: NSDSPI_1_UDB_BIT_COUNTER_SaveConfig
********************************************************************************
*
* Summary:
*  This function saves the component configuration and non-retention registers.
*  This function is called by the Count7_Sleep() function.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Global Variables:
*  NSDSPI_1_UDB_BIT_COUNTER_backup - used to save component configuration and non-
*  retention registers before enter sleep mode.
*
*******************************************************************************/
void NSDSPI_1_UDB_BIT_COUNTER_SaveConfig(void) 
{
    NSDSPI_1_UDB_BIT_COUNTER_backup.count = NSDSPI_1_UDB_BIT_COUNTER_COUNT_REG;
}


/*******************************************************************************
* Function Name: NSDSPI_1_UDB_BIT_COUNTER_Sleep
********************************************************************************
*
* Summary:
*  This is the preferred API to prepare the component for low power mode
*  operation. The Count7_Sleep() API saves the current component state using
*  Count7_SaveConfig() and disables the counter.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void NSDSPI_1_UDB_BIT_COUNTER_Sleep(void) 
{
    if(0u != (NSDSPI_1_UDB_BIT_COUNTER_AUX_CONTROL_REG & NSDSPI_1_UDB_BIT_COUNTER_COUNTER_START))
    {
        NSDSPI_1_UDB_BIT_COUNTER_backup.enableState = 1u;
        NSDSPI_1_UDB_BIT_COUNTER_Stop();
    }
    else
    {
        NSDSPI_1_UDB_BIT_COUNTER_backup.enableState = 0u;
    }

    NSDSPI_1_UDB_BIT_COUNTER_SaveConfig();
}


/*******************************************************************************
* Function Name: NSDSPI_1_UDB_BIT_COUNTER_RestoreConfig
********************************************************************************
*
* Summary:
*  This function restores the component configuration and non-retention
*  registers. This function is called by the Count7_Wakeup() function.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Global Variables:
*  NSDSPI_1_UDB_BIT_COUNTER_backup - used to save component configuration and
*  non-retention registers before exit sleep mode.
*
*******************************************************************************/
void NSDSPI_1_UDB_BIT_COUNTER_RestoreConfig(void) 
{
    NSDSPI_1_UDB_BIT_COUNTER_COUNT_REG = NSDSPI_1_UDB_BIT_COUNTER_backup.count;
}


/*******************************************************************************
* Function Name: NSDSPI_1_UDB_BIT_COUNTER_Wakeup
********************************************************************************
*
* Summary:
*  This is the preferred API to restore the component to the state when
*  Count7_Sleep() was called. The Count7_Wakeup() function calls the
*  Count7_RestoreConfig() function to restore the configuration.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void NSDSPI_1_UDB_BIT_COUNTER_Wakeup(void) 
{
    NSDSPI_1_UDB_BIT_COUNTER_RestoreConfig();

    /* Restore enable state */
    if (NSDSPI_1_UDB_BIT_COUNTER_backup.enableState != 0u)
    {
        NSDSPI_1_UDB_BIT_COUNTER_Enable();
    }
}


/* [] END OF FILE */
