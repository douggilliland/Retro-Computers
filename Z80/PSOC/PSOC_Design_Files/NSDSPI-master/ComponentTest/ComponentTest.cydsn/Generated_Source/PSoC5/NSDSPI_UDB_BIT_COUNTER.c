/*******************************************************************************
* File Name: NSDSPI_UDB_BIT_COUNTER.c
* Version 1.0
*
* Description:
*  This file provides source code for the Count7 component's API.
*
* Note:
*
********************************************************************************
* Copyright 2013, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "NSDSPI_UDB_BIT_COUNTER.h"
#include "CyLib.h"


uint8 NSDSPI_UDB_BIT_COUNTER_initVar = 0u;


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_Init
********************************************************************************
*
* Summary:
*  Initializes or restores the component according to the parameter editor
*  settings.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Theory:
*  It is not necessary to call Count7_Init() because the Count7_Start() API
*  calls this function and is the preferred method to begin component
*  operation.
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_Init(void) 
{
    /* Set the initial period value from parameter editor */
    NSDSPI_UDB_BIT_COUNTER_PERIOD_REG = NSDSPI_UDB_BIT_COUNTER_INITIAL_PERIOD;
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_Enable
********************************************************************************
*
* Summary:
*  Enables the software enable of the counter.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Theory:
*  It is not necessary to call Count7_Enable() because the Count7_Start() API
*  calls this function, which is the preferred method to begin component
*  operation.
*  This API performs modification of auxiliary control register which is a
*  shared resource so it is required to disable interrupts until the
*  modification will complete.
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_Enable(void) 
{
    uint8 interruptState;

    interruptState = CyEnterCriticalSection();
    /* Set the counter start bit in auxiliary control. If routed enable
    * isn't used then this will immediately star the Count7 operation.
    */
    NSDSPI_UDB_BIT_COUNTER_AUX_CONTROL_REG |= NSDSPI_UDB_BIT_COUNTER_COUNTER_START;

    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_Start
********************************************************************************
*
* Summary:
*  Performs all of the required initialization for the component and enables
*  the counter. The first time the routine is executed, the period is set as
*  configured in the customizer. When called to restart the counter following a
*  Count7_Stop() call, the current period value is retained.
*
* Parameters:
*  None.
*
* Global Variables:
*  NSDSPI_UDB_BIT_COUNTER_initVar - global variable.
*
* Return:
*  None.
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_Start(void) 
{
    /* If not initialized then perform initialization */
    if(NSDSPI_UDB_BIT_COUNTER_initVar == 0u)
    {
        NSDSPI_UDB_BIT_COUNTER_Init();
        NSDSPI_UDB_BIT_COUNTER_initVar = 1u;
    }

    /* Enable Count7 */
    NSDSPI_UDB_BIT_COUNTER_Enable();
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_Stop
********************************************************************************
*
* Summary:
*  Disables the software enable of the counter.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_Stop(void) 
{
    uint8 interruptState;

    interruptState = CyEnterCriticalSection();
    /* Clear the counter start bit in auxiliary control. */
    NSDSPI_UDB_BIT_COUNTER_AUX_CONTROL_REG &= (uint8) ~((uint8) NSDSPI_UDB_BIT_COUNTER_COUNTER_START);

    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_WriteCounter
********************************************************************************
*
* Summary:
*  This function writes the counter directly. The counter should be disabled
*  before calling this function.
*
* Parameters:
*  count - Value to be written to counter.
*
* Return:
*  None
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_WriteCounter(uint8 count) 
{
    NSDSPI_UDB_BIT_COUNTER_COUNT_REG = (count & NSDSPI_UDB_BIT_COUNTER_COUNT_7BIT_MASK);
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_ReadCounter
********************************************************************************
*
* Summary:
*  This function reads the counter value.
*
* Parameters:
*  None
*
* Return:
*  None
*
*******************************************************************************/
uint8 NSDSPI_UDB_BIT_COUNTER_ReadCounter(void) 
{
    return(NSDSPI_UDB_BIT_COUNTER_COUNT_REG & NSDSPI_UDB_BIT_COUNTER_COUNT_7BIT_MASK);
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_WritePeriod
********************************************************************************
*
* Summary:
*  This function writes the period register. The actual period is one greater
*  than the value in the period register since the counting sequence starts
*  with the period register and counts down to 0 inclusive. The period of the
*  counter output does not change until the counter is reloaded following the
*  terminal count value of 0 or due to a hardware load signal.
*
* Parameters:
*  period - Period value to be written.
*
* Return:
*  None
*
*******************************************************************************/
void NSDSPI_UDB_BIT_COUNTER_WritePeriod(uint8 period) 
{
    NSDSPI_UDB_BIT_COUNTER_PERIOD_REG = period;
}


/*******************************************************************************
* Function Name: NSDSPI_UDB_BIT_COUNTER_ReadPeriod
********************************************************************************
*
* Summary:
*  This function reads the period register.
*
* Parameters:
*  None
*
* Return:
*  uint8 - Current period value.
*
*******************************************************************************/
uint8 NSDSPI_UDB_BIT_COUNTER_ReadPeriod(void) 
{
    return(NSDSPI_UDB_BIT_COUNTER_PERIOD_REG);
}


/* [] END OF FILE */
