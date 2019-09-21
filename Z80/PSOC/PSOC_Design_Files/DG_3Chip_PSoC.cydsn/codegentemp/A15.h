/*******************************************************************************
* File Name: A15.h  
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

#if !defined(CY_PINS_A15_H) /* Pins A15_H */
#define CY_PINS_A15_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A15_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A15__PORT == 15 && ((A15__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A15_Write(uint8 value);
void    A15_SetDriveMode(uint8 mode);
uint8   A15_ReadDataReg(void);
uint8   A15_Read(void);
void    A15_SetInterruptMode(uint16 position, uint16 mode);
uint8   A15_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A15_SetDriveMode() function.
     *  @{
     */
        #define A15_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A15_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A15_DM_RES_UP          PIN_DM_RES_UP
        #define A15_DM_RES_DWN         PIN_DM_RES_DWN
        #define A15_DM_OD_LO           PIN_DM_OD_LO
        #define A15_DM_OD_HI           PIN_DM_OD_HI
        #define A15_DM_STRONG          PIN_DM_STRONG
        #define A15_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A15_MASK               A15__MASK
#define A15_SHIFT              A15__SHIFT
#define A15_WIDTH              1u

/* Interrupt constants */
#if defined(A15__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A15_SetInterruptMode() function.
     *  @{
     */
        #define A15_INTR_NONE      (uint16)(0x0000u)
        #define A15_INTR_RISING    (uint16)(0x0001u)
        #define A15_INTR_FALLING   (uint16)(0x0002u)
        #define A15_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A15_INTR_MASK      (0x01u) 
#endif /* (A15__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A15_PS                     (* (reg8 *) A15__PS)
/* Data Register */
#define A15_DR                     (* (reg8 *) A15__DR)
/* Port Number */
#define A15_PRT_NUM                (* (reg8 *) A15__PRT) 
/* Connect to Analog Globals */                                                  
#define A15_AG                     (* (reg8 *) A15__AG)                       
/* Analog MUX bux enable */
#define A15_AMUX                   (* (reg8 *) A15__AMUX) 
/* Bidirectional Enable */                                                        
#define A15_BIE                    (* (reg8 *) A15__BIE)
/* Bit-mask for Aliased Register Access */
#define A15_BIT_MASK               (* (reg8 *) A15__BIT_MASK)
/* Bypass Enable */
#define A15_BYP                    (* (reg8 *) A15__BYP)
/* Port wide control signals */                                                   
#define A15_CTL                    (* (reg8 *) A15__CTL)
/* Drive Modes */
#define A15_DM0                    (* (reg8 *) A15__DM0) 
#define A15_DM1                    (* (reg8 *) A15__DM1)
#define A15_DM2                    (* (reg8 *) A15__DM2) 
/* Input Buffer Disable Override */
#define A15_INP_DIS                (* (reg8 *) A15__INP_DIS)
/* LCD Common or Segment Drive */
#define A15_LCD_COM_SEG            (* (reg8 *) A15__LCD_COM_SEG)
/* Enable Segment LCD */
#define A15_LCD_EN                 (* (reg8 *) A15__LCD_EN)
/* Slew Rate Control */
#define A15_SLW                    (* (reg8 *) A15__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A15_PRTDSI__CAPS_SEL       (* (reg8 *) A15__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A15_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A15__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A15_PRTDSI__OE_SEL0        (* (reg8 *) A15__PRTDSI__OE_SEL0) 
#define A15_PRTDSI__OE_SEL1        (* (reg8 *) A15__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A15_PRTDSI__OUT_SEL0       (* (reg8 *) A15__PRTDSI__OUT_SEL0) 
#define A15_PRTDSI__OUT_SEL1       (* (reg8 *) A15__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A15_PRTDSI__SYNC_OUT       (* (reg8 *) A15__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A15__SIO_CFG)
    #define A15_SIO_HYST_EN        (* (reg8 *) A15__SIO_HYST_EN)
    #define A15_SIO_REG_HIFREQ     (* (reg8 *) A15__SIO_REG_HIFREQ)
    #define A15_SIO_CFG            (* (reg8 *) A15__SIO_CFG)
    #define A15_SIO_DIFF           (* (reg8 *) A15__SIO_DIFF)
#endif /* (A15__SIO_CFG) */

/* Interrupt Registers */
#if defined(A15__INTSTAT)
    #define A15_INTSTAT            (* (reg8 *) A15__INTSTAT)
    #define A15_SNAP               (* (reg8 *) A15__SNAP)
    
	#define A15_0_INTTYPE_REG 		(* (reg8 *) A15__0__INTTYPE)
#endif /* (A15__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A15_H */


/* [] END OF FILE */
