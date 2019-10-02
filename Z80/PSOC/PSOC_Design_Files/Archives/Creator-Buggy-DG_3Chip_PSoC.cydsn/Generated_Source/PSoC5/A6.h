/*******************************************************************************
* File Name: A6.h  
* Version 2.20
*
* Description:
*  This file contains Pin function prototypes and register defines
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_PINS_A6_H) /* Pins A6_H */
#define CY_PINS_A6_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A6_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A6__PORT == 15 && ((A6__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A6_Write(uint8 value);
void    A6_SetDriveMode(uint8 mode);
uint8   A6_ReadDataReg(void);
uint8   A6_Read(void);
void    A6_SetInterruptMode(uint16 position, uint16 mode);
uint8   A6_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A6_SetDriveMode() function.
     *  @{
     */
        #define A6_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A6_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A6_DM_RES_UP          PIN_DM_RES_UP
        #define A6_DM_RES_DWN         PIN_DM_RES_DWN
        #define A6_DM_OD_LO           PIN_DM_OD_LO
        #define A6_DM_OD_HI           PIN_DM_OD_HI
        #define A6_DM_STRONG          PIN_DM_STRONG
        #define A6_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A6_MASK               A6__MASK
#define A6_SHIFT              A6__SHIFT
#define A6_WIDTH              1u

/* Interrupt constants */
#if defined(A6__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A6_SetInterruptMode() function.
     *  @{
     */
        #define A6_INTR_NONE      (uint16)(0x0000u)
        #define A6_INTR_RISING    (uint16)(0x0001u)
        #define A6_INTR_FALLING   (uint16)(0x0002u)
        #define A6_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A6_INTR_MASK      (0x01u) 
#endif /* (A6__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A6_PS                     (* (reg8 *) A6__PS)
/* Data Register */
#define A6_DR                     (* (reg8 *) A6__DR)
/* Port Number */
#define A6_PRT_NUM                (* (reg8 *) A6__PRT) 
/* Connect to Analog Globals */                                                  
#define A6_AG                     (* (reg8 *) A6__AG)                       
/* Analog MUX bux enable */
#define A6_AMUX                   (* (reg8 *) A6__AMUX) 
/* Bidirectional Enable */                                                        
#define A6_BIE                    (* (reg8 *) A6__BIE)
/* Bit-mask for Aliased Register Access */
#define A6_BIT_MASK               (* (reg8 *) A6__BIT_MASK)
/* Bypass Enable */
#define A6_BYP                    (* (reg8 *) A6__BYP)
/* Port wide control signals */                                                   
#define A6_CTL                    (* (reg8 *) A6__CTL)
/* Drive Modes */
#define A6_DM0                    (* (reg8 *) A6__DM0) 
#define A6_DM1                    (* (reg8 *) A6__DM1)
#define A6_DM2                    (* (reg8 *) A6__DM2) 
/* Input Buffer Disable Override */
#define A6_INP_DIS                (* (reg8 *) A6__INP_DIS)
/* LCD Common or Segment Drive */
#define A6_LCD_COM_SEG            (* (reg8 *) A6__LCD_COM_SEG)
/* Enable Segment LCD */
#define A6_LCD_EN                 (* (reg8 *) A6__LCD_EN)
/* Slew Rate Control */
#define A6_SLW                    (* (reg8 *) A6__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A6_PRTDSI__CAPS_SEL       (* (reg8 *) A6__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A6_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A6__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A6_PRTDSI__OE_SEL0        (* (reg8 *) A6__PRTDSI__OE_SEL0) 
#define A6_PRTDSI__OE_SEL1        (* (reg8 *) A6__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A6_PRTDSI__OUT_SEL0       (* (reg8 *) A6__PRTDSI__OUT_SEL0) 
#define A6_PRTDSI__OUT_SEL1       (* (reg8 *) A6__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A6_PRTDSI__SYNC_OUT       (* (reg8 *) A6__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A6__SIO_CFG)
    #define A6_SIO_HYST_EN        (* (reg8 *) A6__SIO_HYST_EN)
    #define A6_SIO_REG_HIFREQ     (* (reg8 *) A6__SIO_REG_HIFREQ)
    #define A6_SIO_CFG            (* (reg8 *) A6__SIO_CFG)
    #define A6_SIO_DIFF           (* (reg8 *) A6__SIO_DIFF)
#endif /* (A6__SIO_CFG) */

/* Interrupt Registers */
#if defined(A6__INTSTAT)
    #define A6_INTSTAT            (* (reg8 *) A6__INTSTAT)
    #define A6_SNAP               (* (reg8 *) A6__SNAP)
    
	#define A6_0_INTTYPE_REG 		(* (reg8 *) A6__0__INTTYPE)
#endif /* (A6__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A6_H */


/* [] END OF FILE */
