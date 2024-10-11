/*******************************************************************************
* File Name: A12.h  
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

#if !defined(CY_PINS_A12_H) /* Pins A12_H */
#define CY_PINS_A12_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A12_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A12__PORT == 15 && ((A12__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A12_Write(uint8 value);
void    A12_SetDriveMode(uint8 mode);
uint8   A12_ReadDataReg(void);
uint8   A12_Read(void);
void    A12_SetInterruptMode(uint16 position, uint16 mode);
uint8   A12_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A12_SetDriveMode() function.
     *  @{
     */
        #define A12_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A12_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A12_DM_RES_UP          PIN_DM_RES_UP
        #define A12_DM_RES_DWN         PIN_DM_RES_DWN
        #define A12_DM_OD_LO           PIN_DM_OD_LO
        #define A12_DM_OD_HI           PIN_DM_OD_HI
        #define A12_DM_STRONG          PIN_DM_STRONG
        #define A12_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A12_MASK               A12__MASK
#define A12_SHIFT              A12__SHIFT
#define A12_WIDTH              1u

/* Interrupt constants */
#if defined(A12__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A12_SetInterruptMode() function.
     *  @{
     */
        #define A12_INTR_NONE      (uint16)(0x0000u)
        #define A12_INTR_RISING    (uint16)(0x0001u)
        #define A12_INTR_FALLING   (uint16)(0x0002u)
        #define A12_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A12_INTR_MASK      (0x01u) 
#endif /* (A12__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A12_PS                     (* (reg8 *) A12__PS)
/* Data Register */
#define A12_DR                     (* (reg8 *) A12__DR)
/* Port Number */
#define A12_PRT_NUM                (* (reg8 *) A12__PRT) 
/* Connect to Analog Globals */                                                  
#define A12_AG                     (* (reg8 *) A12__AG)                       
/* Analog MUX bux enable */
#define A12_AMUX                   (* (reg8 *) A12__AMUX) 
/* Bidirectional Enable */                                                        
#define A12_BIE                    (* (reg8 *) A12__BIE)
/* Bit-mask for Aliased Register Access */
#define A12_BIT_MASK               (* (reg8 *) A12__BIT_MASK)
/* Bypass Enable */
#define A12_BYP                    (* (reg8 *) A12__BYP)
/* Port wide control signals */                                                   
#define A12_CTL                    (* (reg8 *) A12__CTL)
/* Drive Modes */
#define A12_DM0                    (* (reg8 *) A12__DM0) 
#define A12_DM1                    (* (reg8 *) A12__DM1)
#define A12_DM2                    (* (reg8 *) A12__DM2) 
/* Input Buffer Disable Override */
#define A12_INP_DIS                (* (reg8 *) A12__INP_DIS)
/* LCD Common or Segment Drive */
#define A12_LCD_COM_SEG            (* (reg8 *) A12__LCD_COM_SEG)
/* Enable Segment LCD */
#define A12_LCD_EN                 (* (reg8 *) A12__LCD_EN)
/* Slew Rate Control */
#define A12_SLW                    (* (reg8 *) A12__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A12_PRTDSI__CAPS_SEL       (* (reg8 *) A12__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A12_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A12__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A12_PRTDSI__OE_SEL0        (* (reg8 *) A12__PRTDSI__OE_SEL0) 
#define A12_PRTDSI__OE_SEL1        (* (reg8 *) A12__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A12_PRTDSI__OUT_SEL0       (* (reg8 *) A12__PRTDSI__OUT_SEL0) 
#define A12_PRTDSI__OUT_SEL1       (* (reg8 *) A12__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A12_PRTDSI__SYNC_OUT       (* (reg8 *) A12__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A12__SIO_CFG)
    #define A12_SIO_HYST_EN        (* (reg8 *) A12__SIO_HYST_EN)
    #define A12_SIO_REG_HIFREQ     (* (reg8 *) A12__SIO_REG_HIFREQ)
    #define A12_SIO_CFG            (* (reg8 *) A12__SIO_CFG)
    #define A12_SIO_DIFF           (* (reg8 *) A12__SIO_DIFF)
#endif /* (A12__SIO_CFG) */

/* Interrupt Registers */
#if defined(A12__INTSTAT)
    #define A12_INTSTAT            (* (reg8 *) A12__INTSTAT)
    #define A12_SNAP               (* (reg8 *) A12__SNAP)
    
	#define A12_0_INTTYPE_REG 		(* (reg8 *) A12__0__INTTYPE)
#endif /* (A12__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A12_H */


/* [] END OF FILE */
