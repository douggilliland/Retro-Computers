/*******************************************************************************
* File Name: P77.h  
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

#if !defined(CY_PINS_P77_H) /* Pins P77_H */
#define CY_PINS_P77_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "P77_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 P77__PORT == 15 && ((P77__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    P77_Write(uint8 value);
void    P77_SetDriveMode(uint8 mode);
uint8   P77_ReadDataReg(void);
uint8   P77_Read(void);
void    P77_SetInterruptMode(uint16 position, uint16 mode);
uint8   P77_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the P77_SetDriveMode() function.
     *  @{
     */
        #define P77_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define P77_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define P77_DM_RES_UP          PIN_DM_RES_UP
        #define P77_DM_RES_DWN         PIN_DM_RES_DWN
        #define P77_DM_OD_LO           PIN_DM_OD_LO
        #define P77_DM_OD_HI           PIN_DM_OD_HI
        #define P77_DM_STRONG          PIN_DM_STRONG
        #define P77_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define P77_MASK               P77__MASK
#define P77_SHIFT              P77__SHIFT
#define P77_WIDTH              1u

/* Interrupt constants */
#if defined(P77__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in P77_SetInterruptMode() function.
     *  @{
     */
        #define P77_INTR_NONE      (uint16)(0x0000u)
        #define P77_INTR_RISING    (uint16)(0x0001u)
        #define P77_INTR_FALLING   (uint16)(0x0002u)
        #define P77_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define P77_INTR_MASK      (0x01u) 
#endif /* (P77__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define P77_PS                     (* (reg8 *) P77__PS)
/* Data Register */
#define P77_DR                     (* (reg8 *) P77__DR)
/* Port Number */
#define P77_PRT_NUM                (* (reg8 *) P77__PRT) 
/* Connect to Analog Globals */                                                  
#define P77_AG                     (* (reg8 *) P77__AG)                       
/* Analog MUX bux enable */
#define P77_AMUX                   (* (reg8 *) P77__AMUX) 
/* Bidirectional Enable */                                                        
#define P77_BIE                    (* (reg8 *) P77__BIE)
/* Bit-mask for Aliased Register Access */
#define P77_BIT_MASK               (* (reg8 *) P77__BIT_MASK)
/* Bypass Enable */
#define P77_BYP                    (* (reg8 *) P77__BYP)
/* Port wide control signals */                                                   
#define P77_CTL                    (* (reg8 *) P77__CTL)
/* Drive Modes */
#define P77_DM0                    (* (reg8 *) P77__DM0) 
#define P77_DM1                    (* (reg8 *) P77__DM1)
#define P77_DM2                    (* (reg8 *) P77__DM2) 
/* Input Buffer Disable Override */
#define P77_INP_DIS                (* (reg8 *) P77__INP_DIS)
/* LCD Common or Segment Drive */
#define P77_LCD_COM_SEG            (* (reg8 *) P77__LCD_COM_SEG)
/* Enable Segment LCD */
#define P77_LCD_EN                 (* (reg8 *) P77__LCD_EN)
/* Slew Rate Control */
#define P77_SLW                    (* (reg8 *) P77__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define P77_PRTDSI__CAPS_SEL       (* (reg8 *) P77__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define P77_PRTDSI__DBL_SYNC_IN    (* (reg8 *) P77__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define P77_PRTDSI__OE_SEL0        (* (reg8 *) P77__PRTDSI__OE_SEL0) 
#define P77_PRTDSI__OE_SEL1        (* (reg8 *) P77__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define P77_PRTDSI__OUT_SEL0       (* (reg8 *) P77__PRTDSI__OUT_SEL0) 
#define P77_PRTDSI__OUT_SEL1       (* (reg8 *) P77__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define P77_PRTDSI__SYNC_OUT       (* (reg8 *) P77__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(P77__SIO_CFG)
    #define P77_SIO_HYST_EN        (* (reg8 *) P77__SIO_HYST_EN)
    #define P77_SIO_REG_HIFREQ     (* (reg8 *) P77__SIO_REG_HIFREQ)
    #define P77_SIO_CFG            (* (reg8 *) P77__SIO_CFG)
    #define P77_SIO_DIFF           (* (reg8 *) P77__SIO_DIFF)
#endif /* (P77__SIO_CFG) */

/* Interrupt Registers */
#if defined(P77__INTSTAT)
    #define P77_INTSTAT            (* (reg8 *) P77__INTSTAT)
    #define P77_SNAP               (* (reg8 *) P77__SNAP)
    
	#define P77_0_INTTYPE_REG 		(* (reg8 *) P77__0__INTTYPE)
#endif /* (P77__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_P77_H */


/* [] END OF FILE */
