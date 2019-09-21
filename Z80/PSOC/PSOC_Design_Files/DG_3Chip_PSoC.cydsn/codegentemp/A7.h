/*******************************************************************************
* File Name: A7.h  
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

#if !defined(CY_PINS_A7_H) /* Pins A7_H */
#define CY_PINS_A7_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A7_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A7__PORT == 15 && ((A7__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A7_Write(uint8 value);
void    A7_SetDriveMode(uint8 mode);
uint8   A7_ReadDataReg(void);
uint8   A7_Read(void);
void    A7_SetInterruptMode(uint16 position, uint16 mode);
uint8   A7_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A7_SetDriveMode() function.
     *  @{
     */
        #define A7_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A7_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A7_DM_RES_UP          PIN_DM_RES_UP
        #define A7_DM_RES_DWN         PIN_DM_RES_DWN
        #define A7_DM_OD_LO           PIN_DM_OD_LO
        #define A7_DM_OD_HI           PIN_DM_OD_HI
        #define A7_DM_STRONG          PIN_DM_STRONG
        #define A7_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A7_MASK               A7__MASK
#define A7_SHIFT              A7__SHIFT
#define A7_WIDTH              1u

/* Interrupt constants */
#if defined(A7__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A7_SetInterruptMode() function.
     *  @{
     */
        #define A7_INTR_NONE      (uint16)(0x0000u)
        #define A7_INTR_RISING    (uint16)(0x0001u)
        #define A7_INTR_FALLING   (uint16)(0x0002u)
        #define A7_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A7_INTR_MASK      (0x01u) 
#endif /* (A7__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A7_PS                     (* (reg8 *) A7__PS)
/* Data Register */
#define A7_DR                     (* (reg8 *) A7__DR)
/* Port Number */
#define A7_PRT_NUM                (* (reg8 *) A7__PRT) 
/* Connect to Analog Globals */                                                  
#define A7_AG                     (* (reg8 *) A7__AG)                       
/* Analog MUX bux enable */
#define A7_AMUX                   (* (reg8 *) A7__AMUX) 
/* Bidirectional Enable */                                                        
#define A7_BIE                    (* (reg8 *) A7__BIE)
/* Bit-mask for Aliased Register Access */
#define A7_BIT_MASK               (* (reg8 *) A7__BIT_MASK)
/* Bypass Enable */
#define A7_BYP                    (* (reg8 *) A7__BYP)
/* Port wide control signals */                                                   
#define A7_CTL                    (* (reg8 *) A7__CTL)
/* Drive Modes */
#define A7_DM0                    (* (reg8 *) A7__DM0) 
#define A7_DM1                    (* (reg8 *) A7__DM1)
#define A7_DM2                    (* (reg8 *) A7__DM2) 
/* Input Buffer Disable Override */
#define A7_INP_DIS                (* (reg8 *) A7__INP_DIS)
/* LCD Common or Segment Drive */
#define A7_LCD_COM_SEG            (* (reg8 *) A7__LCD_COM_SEG)
/* Enable Segment LCD */
#define A7_LCD_EN                 (* (reg8 *) A7__LCD_EN)
/* Slew Rate Control */
#define A7_SLW                    (* (reg8 *) A7__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A7_PRTDSI__CAPS_SEL       (* (reg8 *) A7__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A7_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A7__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A7_PRTDSI__OE_SEL0        (* (reg8 *) A7__PRTDSI__OE_SEL0) 
#define A7_PRTDSI__OE_SEL1        (* (reg8 *) A7__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A7_PRTDSI__OUT_SEL0       (* (reg8 *) A7__PRTDSI__OUT_SEL0) 
#define A7_PRTDSI__OUT_SEL1       (* (reg8 *) A7__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A7_PRTDSI__SYNC_OUT       (* (reg8 *) A7__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A7__SIO_CFG)
    #define A7_SIO_HYST_EN        (* (reg8 *) A7__SIO_HYST_EN)
    #define A7_SIO_REG_HIFREQ     (* (reg8 *) A7__SIO_REG_HIFREQ)
    #define A7_SIO_CFG            (* (reg8 *) A7__SIO_CFG)
    #define A7_SIO_DIFF           (* (reg8 *) A7__SIO_DIFF)
#endif /* (A7__SIO_CFG) */

/* Interrupt Registers */
#if defined(A7__INTSTAT)
    #define A7_INTSTAT            (* (reg8 *) A7__INTSTAT)
    #define A7_SNAP               (* (reg8 *) A7__SNAP)
    
	#define A7_0_INTTYPE_REG 		(* (reg8 *) A7__0__INTTYPE)
#endif /* (A7__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A7_H */


/* [] END OF FILE */
