/*******************************************************************************
* File Name: AdrLowIn.c  
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

#include "AdrLowIn.h"

#if !defined(AdrLowIn_sts_sts_reg__REMOVED) /* Check for removal by optimization */


/*******************************************************************************
* Function Name: AdrLowIn_Read
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
uint8 AdrLowIn_Read(void) 
{ 
    return AdrLowIn_Status;
}


/*******************************************************************************
* Function Name: AdrLowIn_InterruptEnable
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
void AdrLowIn_InterruptEnable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    AdrLowIn_Status_Aux_Ctrl |= AdrLowIn_STATUS_INTR_ENBL;
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: AdrLowIn_InterruptDisable
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
void AdrLowIn_InterruptDisable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    AdrLowIn_Status_Aux_Ctrl &= (uint8)(~AdrLowIn_STATUS_INTR_ENBL);
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: AdrLowIn_WriteMask
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
void AdrLowIn_WriteMask(uint8 mask) 
{
    #if(AdrLowIn_INPUTS < 8u)
    	mask &= ((uint8)(1u << AdrLowIn_INPUTS) - 1u);
	#endif /* End AdrLowIn_INPUTS < 8u */
    AdrLowIn_Status_Mask = mask;
}


/*******************************************************************************
* Function Name: AdrLowIn_ReadMask
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
uint8 AdrLowIn_ReadMask(void) 
{
    return AdrLowIn_Status_Mask;
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
