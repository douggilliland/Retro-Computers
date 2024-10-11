/*******************************************************************************
* File Name: I2CS_scl.h  
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

#if !defined(CY_PINS_I2CS_scl_ALIASES_H) /* Pins I2CS_scl_ALIASES_H */
#define CY_PINS_I2CS_scl_ALIASES_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"


/***************************************
*              Constants        
***************************************/
#define I2CS_scl_0			(I2CS_scl__0__PC)
#define I2CS_scl_0_PS		(I2CS_scl__0__PS)
#define I2CS_scl_0_PC		(I2CS_scl__0__PC)
#define I2CS_scl_0_DR		(I2CS_scl__0__DR)
#define I2CS_scl_0_SHIFT	(I2CS_scl__0__SHIFT)
#define I2CS_scl_0_INTR	((uint16)((uint16)0x0003u << (I2CS_scl__0__SHIFT*2u)))

#define I2CS_scl_INTR_ALL	 ((uint16)(I2CS_scl_0_INTR))


#endif /* End Pins I2CS_scl_ALIASES_H */


/* [] END OF FILE */
