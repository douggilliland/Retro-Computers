/*******************************************************************************
* File Name: IO_Stat_Reg.c  
* Version 1.90
*
* Description:
*  This file contains API to enable firmware to read the value of a Status 
*  Register.
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#include "IO_Stat_Reg.h"

#if !defined(IO_Stat_Reg_sts_sts_reg__REMOVED) /* Check for removal by optimization */


/*******************************************************************************
* Function Name: IO_Stat_Reg_Read
********************************************************************************
*
* Summary:
*  Reads the current value assigned to the Status Register.
*
* Parameters:
*  None.
*
* Return:
*  The current value in the Status Register.
*
*******************************************************************************/
uint8 IO_Stat_Reg_Read(void) 
{ 
    return IO_Stat_Reg_Status;
}


/*******************************************************************************
* Function Name: IO_Stat_Reg_InterruptEnable
********************************************************************************
*
* Summary:
*  Enables the Status Register interrupt.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void IO_Stat_Reg_InterruptEnable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    IO_Stat_Reg_Status_Aux_Ctrl |= IO_Stat_Reg_STATUS_INTR_ENBL;
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: IO_Stat_Reg_InterruptDisable
********************************************************************************
*
* Summary:
*  Disables the Status Register interrupt.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
void IO_Stat_Reg_InterruptDisable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    IO_Stat_Reg_Status_Aux_Ctrl &= (uint8)(~IO_Stat_Reg_STATUS_INTR_ENBL);
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: IO_Stat_Reg_WriteMask
********************************************************************************
*
* Summary:
*  Writes the current mask value assigned to the Status Register.
*
* Parameters:
*  mask:  Value to write into the mask register.
*
* Return:
*  None.
*
*******************************************************************************/
void IO_Stat_Reg_WriteMask(uint8 mask) 
{
    #if(IO_Stat_Reg_INPUTS < 8u)
    	mask &= ((uint8)(1u << IO_Stat_Reg_INPUTS) - 1u);
	#endif /* End IO_Stat_Reg_INPUTS < 8u */
    IO_Stat_Reg_Status_Mask = mask;
}


/*******************************************************************************
* Function Name: IO_Stat_Reg_ReadMask
********************************************************************************
*
* Summary:
*  Reads the current interrupt mask assigned to the Status Register.
*
* Parameters:
*  None.
*
* Return:
*  The value of the interrupt mask of the Status Register.
*
*******************************************************************************/
uint8 IO_Stat_Reg_ReadMask(void) 
{
    return IO_Stat_Reg_Status_Mask;
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
