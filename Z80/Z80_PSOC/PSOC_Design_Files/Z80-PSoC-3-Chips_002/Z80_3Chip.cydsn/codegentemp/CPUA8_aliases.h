/*******************************************************************************
* File Name: CPUA8.h  
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

#if !defined(CY_PINS_CPUA8_ALIASES_H) /* Pins CPUA8_ALIASES_H */
#define CY_PINS_CPUA8_ALIASES_H

#include "cytypes.h"
#include "cyfitter.h"


/***************************************
*              Constants        
***************************************/
#define CPUA8_0			(CPUA8__0__PC)
#define CPUA8_0_INTR	((uint16)((uint16)0x0001u << CPUA8__0__SHIFT))

#define CPUA8_INTR_ALL	 ((uint16)(CPUA8_0_INTR))

#endif /* End Pins CPUA8_ALIASES_H */


/* [] END OF FILE */
