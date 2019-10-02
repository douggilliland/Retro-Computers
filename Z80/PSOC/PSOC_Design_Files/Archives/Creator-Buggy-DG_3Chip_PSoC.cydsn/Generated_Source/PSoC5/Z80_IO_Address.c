/*******************************************************************************
* File Name: Z80_IO_Address.c  
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

#include "Z80_IO_Address.h"

#if !defined(Z80_IO_Address_sts_sts_reg__REMOVED) /* Check for removal by optimization */


/*******************************************************************************
* Function Name: Z80_IO_Address_Read
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
uint8 Z80_IO_Address_Read(void) 
{ 
    return Z80_IO_Address_Status;
}


/*******************************************************************************
* Function Name: Z80_IO_Address_InterruptEnable
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
void Z80_IO_Address_InterruptEnable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    Z80_IO_Address_Status_Aux_Ctrl |= Z80_IO_Address_STATUS_INTR_ENBL;
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: Z80_IO_Address_InterruptDisable
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
void Z80_IO_Address_InterruptDisable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    Z80_IO_Address_Status_Aux_Ctrl &= (uint8)(~Z80_IO_Address_STATUS_INTR_ENBL);
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: Z80_IO_Address_WriteMask
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
void Z80_IO_Address_WriteMask(uint8 mask) 
{
    #if(Z80_IO_Address_INPUTS < 8u)
    	mask &= ((uint8)(1u << Z80_IO_Address_INPUTS) - 1u);
	#endif /* End Z80_IO_Address_INPUTS < 8u */
    Z80_IO_Address_Status_Mask = mask;
}


/*******************************************************************************
* Function Name: Z80_IO_Address_ReadMask
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
uint8 Z80_IO_Address_ReadMask(void) 
{
    return Z80_IO_Address_Status_Mask;
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
