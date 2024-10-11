/*******************************************************************************
* File Name: A8.h  
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

#if !defined(CY_PINS_A8_H) /* Pins A8_H */
#define CY_PINS_A8_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A8_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A8__PORT == 15 && ((A8__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A8_Write(uint8 value);
void    A8_SetDriveMode(uint8 mode);
uint8   A8_ReadDataReg(void);
uint8   A8_Read(void);
void    A8_SetInterruptMode(uint16 position, uint16 mode);
uint8   A8_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A8_SetDriveMode() function.
     *  @{
     */
        #define A8_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A8_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A8_DM_RES_UP          PIN_DM_RES_UP
        #define A8_DM_RES_DWN         PIN_DM_RES_DWN
        #define A8_DM_OD_LO           PIN_DM_OD_LO
        #define A8_DM_OD_HI           PIN_DM_OD_HI
        #define A8_DM_STRONG          PIN_DM_STRONG
        #define A8_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A8_MASK               A8__MASK
#define A8_SHIFT              A8__SHIFT
#define A8_WIDTH              1u

/* Interrupt constants */
#if defined(A8__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A8_SetInterruptMode() function.
     *  @{
     */
        #define A8_INTR_NONE      (uint16)(0x0000u)
        #define A8_INTR_RISING    (uint16)(0x0001u)
        #define A8_INTR_FALLING   (uint16)(0x0002u)
        #define A8_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A8_INTR_MASK      (0x01u) 
#endif /* (A8__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A8_PS                     (* (reg8 *) A8__PS)
/* Data Register */
#define A8_DR                     (* (reg8 *) A8__DR)
/* Port Number */
#define A8_PRT_NUM                (* (reg8 *) A8__PRT) 
/* Connect to Analog Globals */                                                  
#define A8_AG                     (* (reg8 *) A8__AG)                       
/* Analog MUX bux enable */
#define A8_AMUX                   (* (reg8 *) A8__AMUX) 
/* Bidirectional Enable */                                                        
#define A8_BIE                    (* (reg8 *) A8__BIE)
/* Bit-mask for Aliased Register Access */
#define A8_BIT_MASK               (* (reg8 *) A8__BIT_MASK)
/* Bypass Enable */
#define A8_BYP                    (* (reg8 *) A8__BYP)
/* Port wide control signals */                                                   
#define A8_CTL                    (* (reg8 *) A8__CTL)
/* Drive Modes */
#define A8_DM0                    (* (reg8 *) A8__DM0) 
#define A8_DM1                    (* (reg8 *) A8__DM1)
#define A8_DM2                    (* (reg8 *) A8__DM2) 
/* Input Buffer Disable Override */
#define A8_INP_DIS                (* (reg8 *) A8__INP_DIS)
/* LCD Common or Segment Drive */
#define A8_LCD_COM_SEG            (* (reg8 *) A8__LCD_COM_SEG)
/* Enable Segment LCD */
#define A8_LCD_EN                 (* (reg8 *) A8__LCD_EN)
/* Slew Rate Control */
#define A8_SLW                    (* (reg8 *) A8__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A8_PRTDSI__CAPS_SEL       (* (reg8 *) A8__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A8_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A8__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A8_PRTDSI__OE_SEL0        (* (reg8 *) A8__PRTDSI__OE_SEL0) 
#define A8_PRTDSI__OE_SEL1        (* (reg8 *) A8__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A8_PRTDSI__OUT_SEL0       (* (reg8 *) A8__PRTDSI__OUT_SEL0) 
#define A8_PRTDSI__OUT_SEL1       (* (reg8 *) A8__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A8_PRTDSI__SYNC_OUT       (* (reg8 *) A8__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A8__SIO_CFG)
    #define A8_SIO_HYST_EN        (* (reg8 *) A8__SIO_HYST_EN)
    #define A8_SIO_REG_HIFREQ     (* (reg8 *) A8__SIO_REG_HIFREQ)
    #define A8_SIO_CFG            (* (reg8 *) A8__SIO_CFG)
    #define A8_SIO_DIFF           (* (reg8 *) A8__SIO_DIFF)
#endif /* (A8__SIO_CFG) */

/* Interrupt Registers */
#if defined(A8__INTSTAT)
    #define A8_INTSTAT            (* (reg8 *) A8__INTSTAT)
    #define A8_SNAP               (* (reg8 *) A8__SNAP)
    
	#define A8_0_INTTYPE_REG 		(* (reg8 *) A8__0__INTTYPE)
#endif /* (A8__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A8_H */


/* [] END OF FILE */
