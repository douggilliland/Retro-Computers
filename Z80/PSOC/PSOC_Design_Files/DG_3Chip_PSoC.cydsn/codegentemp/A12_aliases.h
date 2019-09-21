/*******************************************************************************
* File Name: A12.h  
* Version 2.20
*
* Description:
*  This file contains the Alias definitions for Per-Pin APIs in cypins.h. 
*  Information on using these APIs can be found in the System Reference Guide.
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_PINS_A12_ALIASES_H) /* Pins A12_ALIASES_H */
#define CY_PINS_A12_ALIASES_H

#include "cytypes.h"
#include "cyfitter.h"


/***************************************
*              Constants        
***************************************/
#define A12_0			(A12__0__PC)
#define A12_0_INTR	((uint16)((uint16)0x0001u << A12__0__SHIFT))

#define A12_INTR_ALL	 ((uint16)(A12_0_INTR))

#endif /* End Pins A12_ALIASES_H */


/* [] END OF FILE */
