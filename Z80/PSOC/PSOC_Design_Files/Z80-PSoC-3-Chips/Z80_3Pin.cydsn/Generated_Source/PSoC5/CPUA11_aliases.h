/*******************************************************************************
* File Name: CPUA11.h  
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

#if !defined(CY_PINS_CPUA11_ALIASES_H) /* Pins CPUA11_ALIASES_H */
#define CY_PINS_CPUA11_ALIASES_H

#include "cytypes.h"
#include "cyfitter.h"


/***************************************
*              Constants        
***************************************/
#define CPUA11_0			(CPUA11__0__PC)
#define CPUA11_0_INTR	((uint16)((uint16)0x0001u << CPUA11__0__SHIFT))

#define CPUA11_INTR_ALL	 ((uint16)(CPUA11_0_INTR))

#endif /* End Pins CPUA11_ALIASES_H */


/* [] END OF FILE */
