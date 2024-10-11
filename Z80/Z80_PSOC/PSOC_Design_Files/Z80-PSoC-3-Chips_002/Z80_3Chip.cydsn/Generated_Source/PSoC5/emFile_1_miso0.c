/*******************************************************************************
* File Name: emFile_1_miso0.c  
* Version 2.0
*
* Description:
*  This file contains API to enable firmware control of a Pins component.
*
* Note:
*
********************************************************************************
* Copyright 2008-2014, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#include "cytypes.h"
#include "emFile_1_miso0.h"

/* APIs are not generated for P15[7:6] on PSoC 5 */
#if !(CY_PSOC5A &&\
	 emFile_1_miso0__PORT == 15 && ((emFile_1_miso0__MASK & 0xC0) != 0))


/*******************************************************************************
* Function Name: emFile_1_miso0_Write
********************************************************************************
*
* Summary:
*  Assign a new value to the digital port's data output register.  
*
* Parameters:  
*  prtValue:  The value to be assigned to the Digital Port. 
*
* Return: 
*  None
*  
*******************************************************************************/
void emFile_1_miso0_Write(uint8 value) 
{
    uint8 staticBits = (emFile_1_miso0_DR & (uint8)(~emFile_1_miso0_MASK));
    emFile_1_miso0_DR = staticBits | ((uint8)(value << emFile_1_miso0_SHIFT) & emFile_1_miso0_MASK);
}


/*******************************************************************************
* Function Name: emFile_1_miso0_SetDriveMode
********************************************************************************
*
* Summary:
*  Change the drive mode on the pins of the port.
* 
* Parameters:  
*  mode:  Change the pins to one of the following drive modes.
*
*  emFile_1_miso0_DM_STRONG     Strong Drive 
*  emFile_1_miso0_DM_OD_HI      Open Drain, Drives High 
*  emFile_1_miso0_DM_OD_LO      Open Drain, Drives Low 
*  emFile_1_miso0_DM_RES_UP     Resistive Pull Up 
*  emFile_1_miso0_DM_RES_DWN    Resistive Pull Down 
*  emFile_1_miso0_DM_RES_UPDWN  Resistive Pull Up/Down 
*  emFile_1_miso0_DM_DIG_HIZ    High Impedance Digital 
*  emFile_1_miso0_DM_ALG_HIZ    High Impedance Analog 
*
* Return: 
*  None
*
*******************************************************************************/
void emFile_1_miso0_SetDriveMode(uint8 mode) 
{
	CyPins_SetPinDriveMode(emFile_1_miso0_0, mode);
}


/*******************************************************************************
* Function Name: emFile_1_miso0_Read
********************************************************************************
*
* Summary:
*  Read the current value on the pins of the Digital Port in right justified 
*  form.
*
* Parameters:  
*  None
*
* Return: 
*  Returns the current value of the Digital Port as a right justified number
*  
* Note:
*  Macro emFile_1_miso0_ReadPS calls this function. 
*  
*******************************************************************************/
uint8 emFile_1_miso0_Read(void) 
{
    return (emFile_1_miso0_PS & emFile_1_miso0_MASK) >> emFile_1_miso0_SHIFT;
}


/*******************************************************************************
* Function Name: emFile_1_miso0_ReadDataReg
********************************************************************************
*
* Summary:
*  Read the current value assigned to a Digital Port's data output register
*
* Parameters:  
*  None 
*
* Return: 
*  Returns the current value assigned to the Digital Port's data output register
*  
*******************************************************************************/
uint8 emFile_1_miso0_ReadDataReg(void) 
{
    return (emFile_1_miso0_DR & emFile_1_miso0_MASK) >> emFile_1_miso0_SHIFT;
}


/* If Interrupts Are Enabled for this Pins component */ 
#if defined(emFile_1_miso0_INTSTAT) 

    /*******************************************************************************
    * Function Name: emFile_1_miso0_ClearInterrupt
    ********************************************************************************
    * Summary:
    *  Clears any active interrupts attached to port and returns the value of the 
    *  interrupt status register.
    *
    * Parameters:  
    *  None 
    *
    * Return: 
    *  Returns the value of the interrupt status register
    *  
    *******************************************************************************/
    uint8 emFile_1_miso0_ClearInterrupt(void) 
    {
        return (emFile_1_miso0_INTSTAT & emFile_1_miso0_MASK) >> emFile_1_miso0_SHIFT;
    }

#endif /* If Interrupts Are Enabled for this Pins component */ 

#endif /* CY_PSOC5A... */

    
/* [] END OF FILE */
