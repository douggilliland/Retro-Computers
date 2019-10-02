/*******************************************************************************
* File Name: A0.h  
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

#if !defined(CY_PINS_A0_H) /* Pins A0_H */
#define CY_PINS_A0_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A0_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A0__PORT == 15 && ((A0__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A0_Write(uint8 value);
void    A0_SetDriveMode(uint8 mode);
uint8   A0_ReadDataReg(void);
uint8   A0_Read(void);
void    A0_SetInterruptMode(uint16 position, uint16 mode);
uint8   A0_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A0_SetDriveMode() function.
     *  @{
     */
        #define A0_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A0_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A0_DM_RES_UP          PIN_DM_RES_UP
        #define A0_DM_RES_DWN         PIN_DM_RES_DWN
        #define A0_DM_OD_LO           PIN_DM_OD_LO
        #define A0_DM_OD_HI           PIN_DM_OD_HI
        #define A0_DM_STRONG          PIN_DM_STRONG
        #define A0_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A0_MASK               A0__MASK
#define A0_SHIFT              A0__SHIFT
#define A0_WIDTH              1u

/* Interrupt constants */
#if defined(A0__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A0_SetInterruptMode() function.
     *  @{
     */
        #define A0_INTR_NONE      (uint16)(0x0000u)
        #define A0_INTR_RISING    (uint16)(0x0001u)
        #define A0_INTR_FALLING   (uint16)(0x0002u)
        #define A0_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A0_INTR_MASK      (0x01u) 
#endif /* (A0__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A0_PS                     (* (reg8 *) A0__PS)
/* Data Register */
#define A0_DR                     (* (reg8 *) A0__DR)
/* Port Number */
#define A0_PRT_NUM                (* (reg8 *) A0__PRT) 
/* Connect to Analog Globals */                                                  
#define A0_AG                     (* (reg8 *) A0__AG)                       
/* Analog MUX bux enable */
#define A0_AMUX                   (* (reg8 *) A0__AMUX) 
/* Bidirectional Enable */                                                        
#define A0_BIE                    (* (reg8 *) A0__BIE)
/* Bit-mask for Aliased Register Access */
#define A0_BIT_MASK               (* (reg8 *) A0__BIT_MASK)
/* Bypass Enable */
#define A0_BYP                    (* (reg8 *) A0__BYP)
/* Port wide control signals */                                                   
#define A0_CTL                    (* (reg8 *) A0__CTL)
/* Drive Modes */
#define A0_DM0                    (* (reg8 *) A0__DM0) 
#define A0_DM1                    (* (reg8 *) A0__DM1)
#define A0_DM2                    (* (reg8 *) A0__DM2) 
/* Input Buffer Disable Override */
#define A0_INP_DIS                (* (reg8 *) A0__INP_DIS)
/* LCD Common or Segment Drive */
#define A0_LCD_COM_SEG            (* (reg8 *) A0__LCD_COM_SEG)
/* Enable Segment LCD */
#define A0_LCD_EN                 (* (reg8 *) A0__LCD_EN)
/* Slew Rate Control */
#define A0_SLW                    (* (reg8 *) A0__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A0_PRTDSI__CAPS_SEL       (* (reg8 *) A0__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A0_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A0__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A0_PRTDSI__OE_SEL0        (* (reg8 *) A0__PRTDSI__OE_SEL0) 
#define A0_PRTDSI__OE_SEL1        (* (reg8 *) A0__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A0_PRTDSI__OUT_SEL0       (* (reg8 *) A0__PRTDSI__OUT_SEL0) 
#define A0_PRTDSI__OUT_SEL1       (* (reg8 *) A0__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A0_PRTDSI__SYNC_OUT       (* (reg8 *) A0__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A0__SIO_CFG)
    #define A0_SIO_HYST_EN        (* (reg8 *) A0__SIO_HYST_EN)
    #define A0_SIO_REG_HIFREQ     (* (reg8 *) A0__SIO_REG_HIFREQ)
    #define A0_SIO_CFG            (* (reg8 *) A0__SIO_CFG)
    #define A0_SIO_DIFF           (* (reg8 *) A0__SIO_DIFF)
#endif /* (A0__SIO_CFG) */

/* Interrupt Registers */
#if defined(A0__INTSTAT)
    #define A0_INTSTAT            (* (reg8 *) A0__INTSTAT)
    #define A0_SNAP               (* (reg8 *) A0__SNAP)
    
	#define A0_0_INTTYPE_REG 		(* (reg8 *) A0__0__INTTYPE)
#endif /* (A0__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A0_H */


/* [] END OF FILE */
