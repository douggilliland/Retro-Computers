/*******************************************************************************
* File Name: A4.h  
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

#if !defined(CY_PINS_A4_H) /* Pins A4_H */
#define CY_PINS_A4_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A4_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A4__PORT == 15 && ((A4__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A4_Write(uint8 value);
void    A4_SetDriveMode(uint8 mode);
uint8   A4_ReadDataReg(void);
uint8   A4_Read(void);
void    A4_SetInterruptMode(uint16 position, uint16 mode);
uint8   A4_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A4_SetDriveMode() function.
     *  @{
     */
        #define A4_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A4_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A4_DM_RES_UP          PIN_DM_RES_UP
        #define A4_DM_RES_DWN         PIN_DM_RES_DWN
        #define A4_DM_OD_LO           PIN_DM_OD_LO
        #define A4_DM_OD_HI           PIN_DM_OD_HI
        #define A4_DM_STRONG          PIN_DM_STRONG
        #define A4_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A4_MASK               A4__MASK
#define A4_SHIFT              A4__SHIFT
#define A4_WIDTH              1u

/* Interrupt constants */
#if defined(A4__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A4_SetInterruptMode() function.
     *  @{
     */
        #define A4_INTR_NONE      (uint16)(0x0000u)
        #define A4_INTR_RISING    (uint16)(0x0001u)
        #define A4_INTR_FALLING   (uint16)(0x0002u)
        #define A4_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A4_INTR_MASK      (0x01u) 
#endif /* (A4__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A4_PS                     (* (reg8 *) A4__PS)
/* Data Register */
#define A4_DR                     (* (reg8 *) A4__DR)
/* Port Number */
#define A4_PRT_NUM                (* (reg8 *) A4__PRT) 
/* Connect to Analog Globals */                                                  
#define A4_AG                     (* (reg8 *) A4__AG)                       
/* Analog MUX bux enable */
#define A4_AMUX                   (* (reg8 *) A4__AMUX) 
/* Bidirectional Enable */                                                        
#define A4_BIE                    (* (reg8 *) A4__BIE)
/* Bit-mask for Aliased Register Access */
#define A4_BIT_MASK               (* (reg8 *) A4__BIT_MASK)
/* Bypass Enable */
#define A4_BYP                    (* (reg8 *) A4__BYP)
/* Port wide control signals */                                                   
#define A4_CTL                    (* (reg8 *) A4__CTL)
/* Drive Modes */
#define A4_DM0                    (* (reg8 *) A4__DM0) 
#define A4_DM1                    (* (reg8 *) A4__DM1)
#define A4_DM2                    (* (reg8 *) A4__DM2) 
/* Input Buffer Disable Override */
#define A4_INP_DIS                (* (reg8 *) A4__INP_DIS)
/* LCD Common or Segment Drive */
#define A4_LCD_COM_SEG            (* (reg8 *) A4__LCD_COM_SEG)
/* Enable Segment LCD */
#define A4_LCD_EN                 (* (reg8 *) A4__LCD_EN)
/* Slew Rate Control */
#define A4_SLW                    (* (reg8 *) A4__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A4_PRTDSI__CAPS_SEL       (* (reg8 *) A4__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A4_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A4__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A4_PRTDSI__OE_SEL0        (* (reg8 *) A4__PRTDSI__OE_SEL0) 
#define A4_PRTDSI__OE_SEL1        (* (reg8 *) A4__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A4_PRTDSI__OUT_SEL0       (* (reg8 *) A4__PRTDSI__OUT_SEL0) 
#define A4_PRTDSI__OUT_SEL1       (* (reg8 *) A4__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A4_PRTDSI__SYNC_OUT       (* (reg8 *) A4__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A4__SIO_CFG)
    #define A4_SIO_HYST_EN        (* (reg8 *) A4__SIO_HYST_EN)
    #define A4_SIO_REG_HIFREQ     (* (reg8 *) A4__SIO_REG_HIFREQ)
    #define A4_SIO_CFG            (* (reg8 *) A4__SIO_CFG)
    #define A4_SIO_DIFF           (* (reg8 *) A4__SIO_DIFF)
#endif /* (A4__SIO_CFG) */

/* Interrupt Registers */
#if defined(A4__INTSTAT)
    #define A4_INTSTAT            (* (reg8 *) A4__INTSTAT)
    #define A4_SNAP               (* (reg8 *) A4__SNAP)
    
	#define A4_0_INTTYPE_REG 		(* (reg8 *) A4__0__INTTYPE)
#endif /* (A4__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A4_H */


/* [] END OF FILE */
