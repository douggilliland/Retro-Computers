/*******************************************************************************
* File Name: A5.h  
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

#if !defined(CY_PINS_A5_H) /* Pins A5_H */
#define CY_PINS_A5_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A5_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A5__PORT == 15 && ((A5__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A5_Write(uint8 value);
void    A5_SetDriveMode(uint8 mode);
uint8   A5_ReadDataReg(void);
uint8   A5_Read(void);
void    A5_SetInterruptMode(uint16 position, uint16 mode);
uint8   A5_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A5_SetDriveMode() function.
     *  @{
     */
        #define A5_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A5_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A5_DM_RES_UP          PIN_DM_RES_UP
        #define A5_DM_RES_DWN         PIN_DM_RES_DWN
        #define A5_DM_OD_LO           PIN_DM_OD_LO
        #define A5_DM_OD_HI           PIN_DM_OD_HI
        #define A5_DM_STRONG          PIN_DM_STRONG
        #define A5_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A5_MASK               A5__MASK
#define A5_SHIFT              A5__SHIFT
#define A5_WIDTH              1u

/* Interrupt constants */
#if defined(A5__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A5_SetInterruptMode() function.
     *  @{
     */
        #define A5_INTR_NONE      (uint16)(0x0000u)
        #define A5_INTR_RISING    (uint16)(0x0001u)
        #define A5_INTR_FALLING   (uint16)(0x0002u)
        #define A5_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A5_INTR_MASK      (0x01u) 
#endif /* (A5__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A5_PS                     (* (reg8 *) A5__PS)
/* Data Register */
#define A5_DR                     (* (reg8 *) A5__DR)
/* Port Number */
#define A5_PRT_NUM                (* (reg8 *) A5__PRT) 
/* Connect to Analog Globals */                                                  
#define A5_AG                     (* (reg8 *) A5__AG)                       
/* Analog MUX bux enable */
#define A5_AMUX                   (* (reg8 *) A5__AMUX) 
/* Bidirectional Enable */                                                        
#define A5_BIE                    (* (reg8 *) A5__BIE)
/* Bit-mask for Aliased Register Access */
#define A5_BIT_MASK               (* (reg8 *) A5__BIT_MASK)
/* Bypass Enable */
#define A5_BYP                    (* (reg8 *) A5__BYP)
/* Port wide control signals */                                                   
#define A5_CTL                    (* (reg8 *) A5__CTL)
/* Drive Modes */
#define A5_DM0                    (* (reg8 *) A5__DM0) 
#define A5_DM1                    (* (reg8 *) A5__DM1)
#define A5_DM2                    (* (reg8 *) A5__DM2) 
/* Input Buffer Disable Override */
#define A5_INP_DIS                (* (reg8 *) A5__INP_DIS)
/* LCD Common or Segment Drive */
#define A5_LCD_COM_SEG            (* (reg8 *) A5__LCD_COM_SEG)
/* Enable Segment LCD */
#define A5_LCD_EN                 (* (reg8 *) A5__LCD_EN)
/* Slew Rate Control */
#define A5_SLW                    (* (reg8 *) A5__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A5_PRTDSI__CAPS_SEL       (* (reg8 *) A5__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A5_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A5__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A5_PRTDSI__OE_SEL0        (* (reg8 *) A5__PRTDSI__OE_SEL0) 
#define A5_PRTDSI__OE_SEL1        (* (reg8 *) A5__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A5_PRTDSI__OUT_SEL0       (* (reg8 *) A5__PRTDSI__OUT_SEL0) 
#define A5_PRTDSI__OUT_SEL1       (* (reg8 *) A5__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A5_PRTDSI__SYNC_OUT       (* (reg8 *) A5__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A5__SIO_CFG)
    #define A5_SIO_HYST_EN        (* (reg8 *) A5__SIO_HYST_EN)
    #define A5_SIO_REG_HIFREQ     (* (reg8 *) A5__SIO_REG_HIFREQ)
    #define A5_SIO_CFG            (* (reg8 *) A5__SIO_CFG)
    #define A5_SIO_DIFF           (* (reg8 *) A5__SIO_DIFF)
#endif /* (A5__SIO_CFG) */

/* Interrupt Registers */
#if defined(A5__INTSTAT)
    #define A5_INTSTAT            (* (reg8 *) A5__INTSTAT)
    #define A5_SNAP               (* (reg8 *) A5__SNAP)
    
	#define A5_0_INTTYPE_REG 		(* (reg8 *) A5__0__INTTYPE)
#endif /* (A5__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A5_H */


/* [] END OF FILE */
