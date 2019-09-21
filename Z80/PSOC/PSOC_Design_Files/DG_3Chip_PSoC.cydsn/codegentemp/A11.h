/*******************************************************************************
* File Name: A11.h  
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

#if !defined(CY_PINS_A11_H) /* Pins A11_H */
#define CY_PINS_A11_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A11_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A11__PORT == 15 && ((A11__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A11_Write(uint8 value);
void    A11_SetDriveMode(uint8 mode);
uint8   A11_ReadDataReg(void);
uint8   A11_Read(void);
void    A11_SetInterruptMode(uint16 position, uint16 mode);
uint8   A11_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A11_SetDriveMode() function.
     *  @{
     */
        #define A11_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A11_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A11_DM_RES_UP          PIN_DM_RES_UP
        #define A11_DM_RES_DWN         PIN_DM_RES_DWN
        #define A11_DM_OD_LO           PIN_DM_OD_LO
        #define A11_DM_OD_HI           PIN_DM_OD_HI
        #define A11_DM_STRONG          PIN_DM_STRONG
        #define A11_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A11_MASK               A11__MASK
#define A11_SHIFT              A11__SHIFT
#define A11_WIDTH              1u

/* Interrupt constants */
#if defined(A11__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A11_SetInterruptMode() function.
     *  @{
     */
        #define A11_INTR_NONE      (uint16)(0x0000u)
        #define A11_INTR_RISING    (uint16)(0x0001u)
        #define A11_INTR_FALLING   (uint16)(0x0002u)
        #define A11_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A11_INTR_MASK      (0x01u) 
#endif /* (A11__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A11_PS                     (* (reg8 *) A11__PS)
/* Data Register */
#define A11_DR                     (* (reg8 *) A11__DR)
/* Port Number */
#define A11_PRT_NUM                (* (reg8 *) A11__PRT) 
/* Connect to Analog Globals */                                                  
#define A11_AG                     (* (reg8 *) A11__AG)                       
/* Analog MUX bux enable */
#define A11_AMUX                   (* (reg8 *) A11__AMUX) 
/* Bidirectional Enable */                                                        
#define A11_BIE                    (* (reg8 *) A11__BIE)
/* Bit-mask for Aliased Register Access */
#define A11_BIT_MASK               (* (reg8 *) A11__BIT_MASK)
/* Bypass Enable */
#define A11_BYP                    (* (reg8 *) A11__BYP)
/* Port wide control signals */                                                   
#define A11_CTL                    (* (reg8 *) A11__CTL)
/* Drive Modes */
#define A11_DM0                    (* (reg8 *) A11__DM0) 
#define A11_DM1                    (* (reg8 *) A11__DM1)
#define A11_DM2                    (* (reg8 *) A11__DM2) 
/* Input Buffer Disable Override */
#define A11_INP_DIS                (* (reg8 *) A11__INP_DIS)
/* LCD Common or Segment Drive */
#define A11_LCD_COM_SEG            (* (reg8 *) A11__LCD_COM_SEG)
/* Enable Segment LCD */
#define A11_LCD_EN                 (* (reg8 *) A11__LCD_EN)
/* Slew Rate Control */
#define A11_SLW                    (* (reg8 *) A11__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A11_PRTDSI__CAPS_SEL       (* (reg8 *) A11__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A11_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A11__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A11_PRTDSI__OE_SEL0        (* (reg8 *) A11__PRTDSI__OE_SEL0) 
#define A11_PRTDSI__OE_SEL1        (* (reg8 *) A11__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A11_PRTDSI__OUT_SEL0       (* (reg8 *) A11__PRTDSI__OUT_SEL0) 
#define A11_PRTDSI__OUT_SEL1       (* (reg8 *) A11__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A11_PRTDSI__SYNC_OUT       (* (reg8 *) A11__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A11__SIO_CFG)
    #define A11_SIO_HYST_EN        (* (reg8 *) A11__SIO_HYST_EN)
    #define A11_SIO_REG_HIFREQ     (* (reg8 *) A11__SIO_REG_HIFREQ)
    #define A11_SIO_CFG            (* (reg8 *) A11__SIO_CFG)
    #define A11_SIO_DIFF           (* (reg8 *) A11__SIO_DIFF)
#endif /* (A11__SIO_CFG) */

/* Interrupt Registers */
#if defined(A11__INTSTAT)
    #define A11_INTSTAT            (* (reg8 *) A11__INTSTAT)
    #define A11_SNAP               (* (reg8 *) A11__SNAP)
    
	#define A11_0_INTTYPE_REG 		(* (reg8 *) A11__0__INTTYPE)
#endif /* (A11__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A11_H */


/* [] END OF FILE */
