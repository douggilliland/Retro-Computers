/*******************************************************************************
* File Name: NSDSPI_RX_BYTE_COUNTER_PM.c  
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

#include "NSDSPI_RX_BYTE_COUNTER.h"

static NSDSPI_RX_BYTE_COUNTER_backupStruct NSDSPI_RX_BYTE_COUNTER_backup;


/*******************************************************************************
* Function Name: NSDSPI_RX_BYTE_COUNTER_SaveConfig
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
*  NSDSPI_RX_BYTE_COUNTER_backup:  Variables of this global structure are modified to 
*  store the values of non retention configuration registers when Sleep() API is 
*  called.
*
*******************************************************************************/
void NSDSPI_RX_BYTE_COUNTER_SaveConfig(void) 
{
    #if (!NSDSPI_RX_BYTE_COUNTER_UsingFixedFunction)

        NSDSPI_RX_BYTE_COUNTER_backup.CounterUdb = NSDSPI_RX_BYTE_COUNTER_ReadCounter();

        #if(!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved)
            NSDSPI_RX_BYTE_COUNTER_backup.CounterControlRegister = NSDSPI_RX_BYTE_COUNTER_ReadControlRegister();
        #endif /* (!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved) */

    #endif /* (!NSDSPI_RX_BYTE_COUNTER_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: NSDSPI_RX_BYTE_COUNTER_RestoreConfig
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
*  NSDSPI_RX_BYTE_COUNTER_backup:  Variables of this global structure are used to 
*  restore the values of non retention registers on wakeup from sleep mode.
*
*******************************************************************************/
void NSDSPI_RX_BYTE_COUNTER_RestoreConfig(void) 
{      
    #if (!NSDSPI_RX_BYTE_COUNTER_UsingFixedFunction)

       NSDSPI_RX_BYTE_COUNTER_WriteCounter(NSDSPI_RX_BYTE_COUNTER_backup.CounterUdb);

        #if(!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved)
            NSDSPI_RX_BYTE_COUNTER_WriteControlRegister(NSDSPI_RX_BYTE_COUNTER_backup.CounterControlRegister);
        #endif /* (!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved) */

    #endif /* (!NSDSPI_RX_BYTE_COUNTER_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: NSDSPI_RX_BYTE_COUNTER_Sleep
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
*  NSDSPI_RX_BYTE_COUNTER_backup.enableState:  Is modified depending on the enable 
*  state of the block before entering sleep mode.
*
*******************************************************************************/
void NSDSPI_RX_BYTE_COUNTER_Sleep(void) 
{
    #if(!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved)
        /* Save Counter's enable state */
        if(NSDSPI_RX_BYTE_COUNTER_CTRL_ENABLE == (NSDSPI_RX_BYTE_COUNTER_CONTROL & NSDSPI_RX_BYTE_COUNTER_CTRL_ENABLE))
        {
            /* Counter is enabled */
            NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState = 1u;
        }
        else
        {
            /* Counter is disabled */
            NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState = 0u;
        }
    #else
        NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState = 1u;
        if(NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState != 0u)
        {
            NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState = 0u;
        }
    #endif /* (!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved) */
    
    NSDSPI_RX_BYTE_COUNTER_Stop();
    NSDSPI_RX_BYTE_COUNTER_SaveConfig();
}


/*******************************************************************************
* Function Name: NSDSPI_RX_BYTE_COUNTER_Wakeup
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
*  NSDSPI_RX_BYTE_COUNTER_backup.enableState:  Is used to restore the enable state of 
*  block on wakeup from sleep mode.
*
*******************************************************************************/
void NSDSPI_RX_BYTE_COUNTER_Wakeup(void) 
{
    NSDSPI_RX_BYTE_COUNTER_RestoreConfig();
    #if(!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved)
        if(NSDSPI_RX_BYTE_COUNTER_backup.CounterEnableState == 1u)
        {
            /* Enable Counter's operation */
            NSDSPI_RX_BYTE_COUNTER_Enable();
        } /* Do nothing if Counter was disabled before */    
    #endif /* (!NSDSPI_RX_BYTE_COUNTER_ControlRegRemoved) */
    
}


/* [] END OF FILE */
