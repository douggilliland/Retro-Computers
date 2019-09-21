/*******************************************************************************
* File Name: UART_Data_Tx.c  
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

#include "UART_Data_Tx.h"

#if !defined(UART_Data_Tx_sts_sts_reg__REMOVED) /* Check for removal by optimization */


/*******************************************************************************
* Function Name: UART_Data_Tx_Read
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
uint8 UART_Data_Tx_Read(void) 
{ 
    return UART_Data_Tx_Status;
}


/*******************************************************************************
* Function Name: UART_Data_Tx_InterruptEnable
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
void UART_Data_Tx_InterruptEnable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    UART_Data_Tx_Status_Aux_Ctrl |= UART_Data_Tx_STATUS_INTR_ENBL;
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: UART_Data_Tx_InterruptDisable
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
void UART_Data_Tx_InterruptDisable(void) 
{
    uint8 interruptState;
    interruptState = CyEnterCriticalSection();
    UART_Data_Tx_Status_Aux_Ctrl &= (uint8)(~UART_Data_Tx_STATUS_INTR_ENBL);
    CyExitCriticalSection(interruptState);
}


/*******************************************************************************
* Function Name: UART_Data_Tx_WriteMask
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
void UART_Data_Tx_WriteMask(uint8 mask) 
{
    #if(UART_Data_Tx_INPUTS < 8u)
    	mask &= ((uint8)(1u << UART_Data_Tx_INPUTS) - 1u);
	#endif /* End UART_Data_Tx_INPUTS < 8u */
    UART_Data_Tx_Status_Mask = mask;
}


/*******************************************************************************
* Function Name: UART_Data_Tx_ReadMask
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
uint8 UART_Data_Tx_ReadMask(void) 
{
    return UART_Data_Tx_Status_Mask;
}

#endif /* End check for removal by optimization */


/* [] END OF FILE */
