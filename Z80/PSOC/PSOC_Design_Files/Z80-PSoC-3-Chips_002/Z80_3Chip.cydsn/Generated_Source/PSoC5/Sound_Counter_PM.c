/*******************************************************************************
* File Name: Sound_Counter_PM.c  
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

#include "Sound_Counter.h"

static Sound_Counter_backupStruct Sound_Counter_backup;


/*******************************************************************************
* Function Name: Sound_Counter_SaveConfig
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
*  Sound_Counter_backup:  Variables of this global structure are modified to 
*  store the values of non retention configuration registers when Sleep() API is 
*  called.
*
*******************************************************************************/
void Sound_Counter_SaveConfig(void) 
{
    #if (!Sound_Counter_UsingFixedFunction)

        Sound_Counter_backup.CounterUdb = Sound_Counter_ReadCounter();

        #if(!Sound_Counter_ControlRegRemoved)
            Sound_Counter_backup.CounterControlRegister = Sound_Counter_ReadControlRegister();
        #endif /* (!Sound_Counter_ControlRegRemoved) */

    #endif /* (!Sound_Counter_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: Sound_Counter_RestoreConfig
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
*  Sound_Counter_backup:  Variables of this global structure are used to 
*  restore the values of non retention registers on wakeup from sleep mode.
*
*******************************************************************************/
void Sound_Counter_RestoreConfig(void) 
{      
    #if (!Sound_Counter_UsingFixedFunction)

       Sound_Counter_WriteCounter(Sound_Counter_backup.CounterUdb);

        #if(!Sound_Counter_ControlRegRemoved)
            Sound_Counter_WriteControlRegister(Sound_Counter_backup.CounterControlRegister);
        #endif /* (!Sound_Counter_ControlRegRemoved) */

    #endif /* (!Sound_Counter_UsingFixedFunction) */
}


/*******************************************************************************
* Function Name: Sound_Counter_Sleep
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
*  Sound_Counter_backup.enableState:  Is modified depending on the enable 
*  state of the block before entering sleep mode.
*
*******************************************************************************/
void Sound_Counter_Sleep(void) 
{
    #if(!Sound_Counter_ControlRegRemoved)
        /* Save Counter's enable state */
        if(Sound_Counter_CTRL_ENABLE == (Sound_Counter_CONTROL & Sound_Counter_CTRL_ENABLE))
        {
            /* Counter is enabled */
            Sound_Counter_backup.CounterEnableState = 1u;
        }
        else
        {
            /* Counter is disabled */
            Sound_Counter_backup.CounterEnableState = 0u;
        }
    #else
        Sound_Counter_backup.CounterEnableState = 1u;
        if(Sound_Counter_backup.CounterEnableState != 0u)
        {
            Sound_Counter_backup.CounterEnableState = 0u;
        }
    #endif /* (!Sound_Counter_ControlRegRemoved) */
    
    Sound_Counter_Stop();
    Sound_Counter_SaveConfig();
}


/*******************************************************************************
* Function Name: Sound_Counter_Wakeup
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
*  Sound_Counter_backup.enableState:  Is used to restore the enable state of 
*  block on wakeup from sleep mode.
*
*******************************************************************************/
void Sound_Counter_Wakeup(void) 
{
    Sound_Counter_RestoreConfig();
    #if(!Sound_Counter_ControlRegRemoved)
        if(Sound_Counter_backup.CounterEnableState == 1u)
        {
            /* Enable Counter's operation */
            Sound_Counter_Enable();
        } /* Do nothing if Counter was disabled before */    
    #endif /* (!Sound_Counter_ControlRegRemoved) */
    
}


/* [] END OF FILE */
