/*******************************************************************************
* File Name: P79.h  
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

#if !defined(CY_PINS_P79_H) /* Pins P79_H */
#define CY_PINS_P79_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "P79_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 P79__PORT == 15 && ((P79__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    P79_Write(uint8 value);
void    P79_SetDriveMode(uint8 mode);
uint8   P79_ReadDataReg(void);
uint8   P79_Read(void);
void    P79_SetInterruptMode(uint16 position, uint16 mode);
uint8   P79_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the P79_SetDriveMode() function.
     *  @{
     */
        #define P79_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define P79_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define P79_DM_RES_UP          PIN_DM_RES_UP
        #define P79_DM_RES_DWN         PIN_DM_RES_DWN
        #define P79_DM_OD_LO           PIN_DM_OD_LO
        #define P79_DM_OD_HI           PIN_DM_OD_HI
        #define P79_DM_STRONG          PIN_DM_STRONG
        #define P79_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define P79_MASK               P79__MASK
#define P79_SHIFT              P79__SHIFT
#define P79_WIDTH              1u

/* Interrupt constants */
#if defined(P79__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in P79_SetInterruptMode() function.
     *  @{
     */
        #define P79_INTR_NONE      (uint16)(0x0000u)
        #define P79_INTR_RISING    (uint16)(0x0001u)
        #define P79_INTR_FALLING   (uint16)(0x0002u)
        #define P79_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define P79_INTR_MASK      (0x01u) 
#endif /* (P79__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define P79_PS                     (* (reg8 *) P79__PS)
/* Data Register */
#define P79_DR                     (* (reg8 *) P79__DR)
/* Port Number */
#define P79_PRT_NUM                (* (reg8 *) P79__PRT) 
/* Connect to Analog Globals */                                                  
#define P79_AG                     (* (reg8 *) P79__AG)                       
/* Analog MUX bux enable */
#define P79_AMUX                   (* (reg8 *) P79__AMUX) 
/* Bidirectional Enable */                                                        
#define P79_BIE                    (* (reg8 *) P79__BIE)
/* Bit-mask for Aliased Register Access */
#define P79_BIT_MASK               (* (reg8 *) P79__BIT_MASK)
/* Bypass Enable */
#define P79_BYP                    (* (reg8 *) P79__BYP)
/* Port wide control signals */                                                   
#define P79_CTL                    (* (reg8 *) P79__CTL)
/* Drive Modes */
#define P79_DM0                    (* (reg8 *) P79__DM0) 
#define P79_DM1                    (* (reg8 *) P79__DM1)
#define P79_DM2                    (* (reg8 *) P79__DM2) 
/* Input Buffer Disable Override */
#define P79_INP_DIS                (* (reg8 *) P79__INP_DIS)
/* LCD Common or Segment Drive */
#define P79_LCD_COM_SEG            (* (reg8 *) P79__LCD_COM_SEG)
/* Enable Segment LCD */
#define P79_LCD_EN                 (* (reg8 *) P79__LCD_EN)
/* Slew Rate Control */
#define P79_SLW                    (* (reg8 *) P79__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define P79_PRTDSI__CAPS_SEL       (* (reg8 *) P79__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define P79_PRTDSI__DBL_SYNC_IN    (* (reg8 *) P79__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define P79_PRTDSI__OE_SEL0        (* (reg8 *) P79__PRTDSI__OE_SEL0) 
#define P79_PRTDSI__OE_SEL1        (* (reg8 *) P79__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define P79_PRTDSI__OUT_SEL0       (* (reg8 *) P79__PRTDSI__OUT_SEL0) 
#define P79_PRTDSI__OUT_SEL1       (* (reg8 *) P79__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define P79_PRTDSI__SYNC_OUT       (* (reg8 *) P79__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(P79__SIO_CFG)
    #define P79_SIO_HYST_EN        (* (reg8 *) P79__SIO_HYST_EN)
    #define P79_SIO_REG_HIFREQ     (* (reg8 *) P79__SIO_REG_HIFREQ)
    #define P79_SIO_CFG            (* (reg8 *) P79__SIO_CFG)
    #define P79_SIO_DIFF           (* (reg8 *) P79__SIO_DIFF)
#endif /* (P79__SIO_CFG) */

/* Interrupt Registers */
#if defined(P79__INTSTAT)
    #define P79_INTSTAT            (* (reg8 *) P79__INTSTAT)
    #define P79_SNAP               (* (reg8 *) P79__SNAP)
    
	#define P79_0_INTTYPE_REG 		(* (reg8 *) P79__0__INTTYPE)
#endif /* (P79__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_P79_H */


/* [] END OF FILE */
