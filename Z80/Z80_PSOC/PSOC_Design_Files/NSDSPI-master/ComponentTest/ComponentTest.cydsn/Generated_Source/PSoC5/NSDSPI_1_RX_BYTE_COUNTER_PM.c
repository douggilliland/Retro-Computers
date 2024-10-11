/*******************************************************************************
* File Name: NSDSPI_1_RX_BYTE_COUNTER_PM.c  
* Version 3.0
*
*  Description:
*    This file provides the power management source code to API for the
*    Counter.  
*
*   Note:
*     None
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#include "NSDSPI_1_RX_BYTE_COUNTER.h"

static NSDSPI_1_RX_BYTE_COUNTER_backupStruct NSDSPI_1_RX_BYTE_COUNTER_backup;


/*******************************************************************************
* Function Name: NSDSPI_1_RX_BYTE_COUNTER_SaveConfig
********************************************************************************
* Summary:
*     Save the current user configuration
*
* Parameters:  
*  void
*
* Return: 
*  void
*
* Global variables:
*  NSDSPI_1_RX_BYTE_COUNTER_backup:  Variables of this global structure are modified to 
*  store the values of non retention configuration registers when Sleep() API is 
*  called.
*
*******************************************************************************/
void NSDSPI_1_RX_BYTE_COUNTER_SaveConfig(void) 
{
    #if (!NSDSPI_1_RX_BYTE_COUNTER_UsingFixedFunction)

        NSDSPI_1_RX_BYTE_COUNTER_backup.CounterUdb = NSDSPI_1_RX_BYTE_COUNTER_ReadCounter();

        #if(!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved)
            NSDSPI_1_RX_BYTE_COUNTER_backup.CounterControlRegister = NSDSPI_1_RX_BYTE_COUNTER_ReadControlRegister();
        #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved) */

    #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: NSDSPI_1_RX_BYTE_COUNTER_RestoreConfig
********************************************************************************
*
* Summary:
*  Restores the current user configuration.
*
* Parameters:  
*  void
*
* Return: 
*  void
*
* Global variables:
*  NSDSPI_1_RX_BYTE_COUNTER_backup:  Variables of this global structure are used to 
*  restore the values of non retention registers on wakeup from sleep mode.
*
*******************************************************************************/
void NSDSPI_1_RX_BYTE_COUNTER_RestoreConfig(void) 
{      
    #if (!NSDSPI_1_RX_BYTE_COUNTER_UsingFixedFunction)

       NSDSPI_1_RX_BYTE_COUNTER_WriteCounter(NSDSPI_1_RX_BYTE_COUNTER_backup.CounterUdb);

        #if(!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved)
            NSDSPI_1_RX_BYTE_COUNTER_WriteControlRegister(NSDSPI_1_RX_BYTE_COUNTER_backup.CounterControlRegister);
        #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved) */

    #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: NSDSPI_1_RX_BYTE_COUNTER_Sleep
********************************************************************************
* Summary:
*     Stop and Save the user configuration
*
* Parameters:  
*  void
*
* Return: 
*  void
*
* Global variables:
*  NSDSPI_1_RX_BYTE_COUNTER_backup.enableState:  Is modified depending on the enable 
*  state of the block before entering sleep mode.
*
*******************************************************************************/
void NSDSPI_1_RX_BYTE_COUNTER_Sleep(void) 
{
    #if(!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved)
        /* Save Counter's enable state */
        if(NSDSPI_1_RX_BYTE_COUNTER_CTRL_ENABLE == (NSDSPI_1_RX_BYTE_COUNTER_CONTROL & NSDSPI_1_RX_BYTE_COUNTER_CTRL_ENABLE))
        {
            /* Counter is enabled */
            NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState = 1u;
        }
        else
        {
            /* Counter is disabled */
            NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState = 0u;
        }
    #else
        NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState = 1u;
        if(NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState != 0u)
        {
            NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState = 0u;
        }
    #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved) */
    
    NSDSPI_1_RX_BYTE_COUNTER_Stop();
    NSDSPI_1_RX_BYTE_COUNTER_SaveConfig();
}


/*******************************************************************************
* Function Name: NSDSPI_1_RX_BYTE_COUNTER_Wakeup
********************************************************************************
*
* Summary:
*  Restores and enables the user configuration
*  
* Parameters:  
*  void
*
* Return: 
*  void
*
* Global variables:
*  NSDSPI_1_RX_BYTE_COUNTER_backup.enableState:  Is used to restore the enable state of 
*  block on wakeup from sleep mode.
*
*******************************************************************************/
void NSDSPI_1_RX_BYTE_COUNTER_Wakeup(void) 
{
    NSDSPI_1_RX_BYTE_COUNTER_RestoreConfig();
    #if(!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved)
        if(NSDSPI_1_RX_BYTE_COUNTER_backup.CounterEnableState == 1u)
        {
            /* Enable Counter's operation */
            NSDSPI_1_RX_BYTE_COUNTER_Enable();
        } /* Do nothing if Counter was disabled before */    
    #endif /* (!NSDSPI_1_RX_BYTE_COUNTER_ControlRegRemoved) */
    
}


/* [] END OF FILE */
