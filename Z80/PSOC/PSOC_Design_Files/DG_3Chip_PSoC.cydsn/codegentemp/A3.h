/*******************************************************************************
* File Name: A3.h  
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

#if !defined(CY_PINS_A3_H) /* Pins A3_H */
#define CY_PINS_A3_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A3_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A3__PORT == 15 && ((A3__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A3_Write(uint8 value);
void    A3_SetDriveMode(uint8 mode);
uint8   A3_ReadDataReg(void);
uint8   A3_Read(void);
void    A3_SetInterruptMode(uint16 position, uint16 mode);
uint8   A3_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A3_SetDriveMode() function.
     *  @{
     */
        #define A3_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A3_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A3_DM_RES_UP          PIN_DM_RES_UP
        #define A3_DM_RES_DWN         PIN_DM_RES_DWN
        #define A3_DM_OD_LO           PIN_DM_OD_LO
        #define A3_DM_OD_HI           PIN_DM_OD_HI
        #define A3_DM_STRONG          PIN_DM_STRONG
        #define A3_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A3_MASK               A3__MASK
#define A3_SHIFT              A3__SHIFT
#define A3_WIDTH              1u

/* Interrupt constants */
#if defined(A3__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A3_SetInterruptMode() function.
     *  @{
     */
        #define A3_INTR_NONE      (uint16)(0x0000u)
        #define A3_INTR_RISING    (uint16)(0x0001u)
        #define A3_INTR_FALLING   (uint16)(0x0002u)
        #define A3_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A3_INTR_MASK      (0x01u) 
#endif /* (A3__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A3_PS                     (* (reg8 *) A3__PS)
/* Data Register */
#define A3_DR                     (* (reg8 *) A3__DR)
/* Port Number */
#define A3_PRT_NUM                (* (reg8 *) A3__PRT) 
/* Connect to Analog Globals */                                                  
#define A3_AG                     (* (reg8 *) A3__AG)                       
/* Analog MUX bux enable */
#define A3_AMUX                   (* (reg8 *) A3__AMUX) 
/* Bidirectional Enable */                                                        
#define A3_BIE                    (* (reg8 *) A3__BIE)
/* Bit-mask for Aliased Register Access */
#define A3_BIT_MASK               (* (reg8 *) A3__BIT_MASK)
/* Bypass Enable */
#define A3_BYP                    (* (reg8 *) A3__BYP)
/* Port wide control signals */                                                   
#define A3_CTL                    (* (reg8 *) A3__CTL)
/* Drive Modes */
#define A3_DM0                    (* (reg8 *) A3__DM0) 
#define A3_DM1                    (* (reg8 *) A3__DM1)
#define A3_DM2                    (* (reg8 *) A3__DM2) 
/* Input Buffer Disable Override */
#define A3_INP_DIS                (* (reg8 *) A3__INP_DIS)
/* LCD Common or Segment Drive */
#define A3_LCD_COM_SEG            (* (reg8 *) A3__LCD_COM_SEG)
/* Enable Segment LCD */
#define A3_LCD_EN                 (* (reg8 *) A3__LCD_EN)
/* Slew Rate Control */
#define A3_SLW                    (* (reg8 *) A3__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A3_PRTDSI__CAPS_SEL       (* (reg8 *) A3__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A3_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A3__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A3_PRTDSI__OE_SEL0        (* (reg8 *) A3__PRTDSI__OE_SEL0) 
#define A3_PRTDSI__OE_SEL1        (* (reg8 *) A3__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A3_PRTDSI__OUT_SEL0       (* (reg8 *) A3__PRTDSI__OUT_SEL0) 
#define A3_PRTDSI__OUT_SEL1       (* (reg8 *) A3__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A3_PRTDSI__SYNC_OUT       (* (reg8 *) A3__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A3__SIO_CFG)
    #define A3_SIO_HYST_EN        (* (reg8 *) A3__SIO_HYST_EN)
    #define A3_SIO_REG_HIFREQ     (* (reg8 *) A3__SIO_REG_HIFREQ)
    #define A3_SIO_CFG            (* (reg8 *) A3__SIO_CFG)
    #define A3_SIO_DIFF           (* (reg8 *) A3__SIO_DIFF)
#endif /* (A3__SIO_CFG) */

/* Interrupt Registers */
#if defined(A3__INTSTAT)
    #define A3_INTSTAT            (* (reg8 *) A3__INTSTAT)
    #define A3_SNAP               (* (reg8 *) A3__SNAP)
    
	#define A3_0_INTTYPE_REG 		(* (reg8 *) A3__0__INTTYPE)
#endif /* (A3__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A3_H */


/* [] END OF FILE */
