/*******************************************************************************
* File Name: A9.h  
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

#if !defined(CY_PINS_A9_H) /* Pins A9_H */
#define CY_PINS_A9_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A9_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A9__PORT == 15 && ((A9__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A9_Write(uint8 value);
void    A9_SetDriveMode(uint8 mode);
uint8   A9_ReadDataReg(void);
uint8   A9_Read(void);
void    A9_SetInterruptMode(uint16 position, uint16 mode);
uint8   A9_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A9_SetDriveMode() function.
     *  @{
     */
        #define A9_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A9_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A9_DM_RES_UP          PIN_DM_RES_UP
        #define A9_DM_RES_DWN         PIN_DM_RES_DWN
        #define A9_DM_OD_LO           PIN_DM_OD_LO
        #define A9_DM_OD_HI           PIN_DM_OD_HI
        #define A9_DM_STRONG          PIN_DM_STRONG
        #define A9_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A9_MASK               A9__MASK
#define A9_SHIFT              A9__SHIFT
#define A9_WIDTH              1u

/* Interrupt constants */
#if defined(A9__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A9_SetInterruptMode() function.
     *  @{
     */
        #define A9_INTR_NONE      (uint16)(0x0000u)
        #define A9_INTR_RISING    (uint16)(0x0001u)
        #define A9_INTR_FALLING   (uint16)(0x0002u)
        #define A9_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A9_INTR_MASK      (0x01u) 
#endif /* (A9__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A9_PS                     (* (reg8 *) A9__PS)
/* Data Register */
#define A9_DR                     (* (reg8 *) A9__DR)
/* Port Number */
#define A9_PRT_NUM                (* (reg8 *) A9__PRT) 
/* Connect to Analog Globals */                                                  
#define A9_AG                     (* (reg8 *) A9__AG)                       
/* Analog MUX bux enable */
#define A9_AMUX                   (* (reg8 *) A9__AMUX) 
/* Bidirectional Enable */                                                        
#define A9_BIE                    (* (reg8 *) A9__BIE)
/* Bit-mask for Aliased Register Access */
#define A9_BIT_MASK               (* (reg8 *) A9__BIT_MASK)
/* Bypass Enable */
#define A9_BYP                    (* (reg8 *) A9__BYP)
/* Port wide control signals */                                                   
#define A9_CTL                    (* (reg8 *) A9__CTL)
/* Drive Modes */
#define A9_DM0                    (* (reg8 *) A9__DM0) 
#define A9_DM1                    (* (reg8 *) A9__DM1)
#define A9_DM2                    (* (reg8 *) A9__DM2) 
/* Input Buffer Disable Override */
#define A9_INP_DIS                (* (reg8 *) A9__INP_DIS)
/* LCD Common or Segment Drive */
#define A9_LCD_COM_SEG            (* (reg8 *) A9__LCD_COM_SEG)
/* Enable Segment LCD */
#define A9_LCD_EN                 (* (reg8 *) A9__LCD_EN)
/* Slew Rate Control */
#define A9_SLW                    (* (reg8 *) A9__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A9_PRTDSI__CAPS_SEL       (* (reg8 *) A9__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A9_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A9__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A9_PRTDSI__OE_SEL0        (* (reg8 *) A9__PRTDSI__OE_SEL0) 
#define A9_PRTDSI__OE_SEL1        (* (reg8 *) A9__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A9_PRTDSI__OUT_SEL0       (* (reg8 *) A9__PRTDSI__OUT_SEL0) 
#define A9_PRTDSI__OUT_SEL1       (* (reg8 *) A9__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A9_PRTDSI__SYNC_OUT       (* (reg8 *) A9__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A9__SIO_CFG)
    #define A9_SIO_HYST_EN        (* (reg8 *) A9__SIO_HYST_EN)
    #define A9_SIO_REG_HIFREQ     (* (reg8 *) A9__SIO_REG_HIFREQ)
    #define A9_SIO_CFG            (* (reg8 *) A9__SIO_CFG)
    #define A9_SIO_DIFF           (* (reg8 *) A9__SIO_DIFF)
#endif /* (A9__SIO_CFG) */

/* Interrupt Registers */
#if defined(A9__INTSTAT)
    #define A9_INTSTAT            (* (reg8 *) A9__INTSTAT)
    #define A9_SNAP               (* (reg8 *) A9__SNAP)
    
	#define A9_0_INTTYPE_REG 		(* (reg8 *) A9__0__INTTYPE)
#endif /* (A9__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A9_H */


/* [] END OF FILE */
