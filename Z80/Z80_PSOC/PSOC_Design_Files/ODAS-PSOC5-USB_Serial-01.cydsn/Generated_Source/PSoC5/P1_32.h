/*******************************************************************************
* File Name: P1_32.h  
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

#if !defined(CY_PINS_P1_32_H) /* Pins P1_32_H */
#define CY_PINS_P1_32_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "P1_32_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 P1_32__PORT == 15 && ((P1_32__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    P1_32_Write(uint8 value);
void    P1_32_SetDriveMode(uint8 mode);
uint8   P1_32_ReadDataReg(void);
uint8   P1_32_Read(void);
void    P1_32_SetInterruptMode(uint16 position, uint16 mode);
uint8   P1_32_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the P1_32_SetDriveMode() function.
     *  @{
     */
        #define P1_32_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define P1_32_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define P1_32_DM_RES_UP          PIN_DM_RES_UP
        #define P1_32_DM_RES_DWN         PIN_DM_RES_DWN
        #define P1_32_DM_OD_LO           PIN_DM_OD_LO
        #define P1_32_DM_OD_HI           PIN_DM_OD_HI
        #define P1_32_DM_STRONG          PIN_DM_STRONG
        #define P1_32_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define P1_32_MASK               P1_32__MASK
#define P1_32_SHIFT              P1_32__SHIFT
#define P1_32_WIDTH              1u

/* Interrupt constants */
#if defined(P1_32__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in P1_32_SetInterruptMode() function.
     *  @{
     */
        #define P1_32_INTR_NONE      (uint16)(0x0000u)
        #define P1_32_INTR_RISING    (uint16)(0x0001u)
        #define P1_32_INTR_FALLING   (uint16)(0x0002u)
        #define P1_32_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define P1_32_INTR_MASK      (0x01u) 
#endif /* (P1_32__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define P1_32_PS                     (* (reg8 *) P1_32__PS)
/* Data Register */
#define P1_32_DR                     (* (reg8 *) P1_32__DR)
/* Port Number */
#define P1_32_PRT_NUM                (* (reg8 *) P1_32__PRT) 
/* Connect to Analog Globals */                                                  
#define P1_32_AG                     (* (reg8 *) P1_32__AG)                       
/* Analog MUX bux enable */
#define P1_32_AMUX                   (* (reg8 *) P1_32__AMUX) 
/* Bidirectional Enable */                                                        
#define P1_32_BIE                    (* (reg8 *) P1_32__BIE)
/* Bit-mask for Aliased Register Access */
#define P1_32_BIT_MASK               (* (reg8 *) P1_32__BIT_MASK)
/* Bypass Enable */
#define P1_32_BYP                    (* (reg8 *) P1_32__BYP)
/* Port wide control signals */                                                   
#define P1_32_CTL                    (* (reg8 *) P1_32__CTL)
/* Drive Modes */
#define P1_32_DM0                    (* (reg8 *) P1_32__DM0) 
#define P1_32_DM1                    (* (reg8 *) P1_32__DM1)
#define P1_32_DM2                    (* (reg8 *) P1_32__DM2) 
/* Input Buffer Disable Override */
#define P1_32_INP_DIS                (* (reg8 *) P1_32__INP_DIS)
/* LCD Common or Segment Drive */
#define P1_32_LCD_COM_SEG            (* (reg8 *) P1_32__LCD_COM_SEG)
/* Enable Segment LCD */
#define P1_32_LCD_EN                 (* (reg8 *) P1_32__LCD_EN)
/* Slew Rate Control */
#define P1_32_SLW                    (* (reg8 *) P1_32__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define P1_32_PRTDSI__CAPS_SEL       (* (reg8 *) P1_32__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define P1_32_PRTDSI__DBL_SYNC_IN    (* (reg8 *) P1_32__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define P1_32_PRTDSI__OE_SEL0        (* (reg8 *) P1_32__PRTDSI__OE_SEL0) 
#define P1_32_PRTDSI__OE_SEL1        (* (reg8 *) P1_32__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define P1_32_PRTDSI__OUT_SEL0       (* (reg8 *) P1_32__PRTDSI__OUT_SEL0) 
#define P1_32_PRTDSI__OUT_SEL1       (* (reg8 *) P1_32__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define P1_32_PRTDSI__SYNC_OUT       (* (reg8 *) P1_32__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(P1_32__SIO_CFG)
    #define P1_32_SIO_HYST_EN        (* (reg8 *) P1_32__SIO_HYST_EN)
    #define P1_32_SIO_REG_HIFREQ     (* (reg8 *) P1_32__SIO_REG_HIFREQ)
    #define P1_32_SIO_CFG            (* (reg8 *) P1_32__SIO_CFG)
    #define P1_32_SIO_DIFF           (* (reg8 *) P1_32__SIO_DIFF)
#endif /* (P1_32__SIO_CFG) */

/* Interrupt Registers */
#if defined(P1_32__INTSTAT)
    #define P1_32_INTSTAT            (* (reg8 *) P1_32__INTSTAT)
    #define P1_32_SNAP               (* (reg8 *) P1_32__SNAP)
    
	#define P1_32_0_INTTYPE_REG 		(* (reg8 *) P1_32__0__INTTYPE)
#endif /* (P1_32__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_P1_32_H */


/* [] END OF FILE */
