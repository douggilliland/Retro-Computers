/*******************************************************************************
* File Name: P76.h  
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

#if !defined(CY_PINS_P76_H) /* Pins P76_H */
#define CY_PINS_P76_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "P76_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 P76__PORT == 15 && ((P76__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    P76_Write(uint8 value);
void    P76_SetDriveMode(uint8 mode);
uint8   P76_ReadDataReg(void);
uint8   P76_Read(void);
void    P76_SetInterruptMode(uint16 position, uint16 mode);
uint8   P76_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the P76_SetDriveMode() function.
     *  @{
     */
        #define P76_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define P76_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define P76_DM_RES_UP          PIN_DM_RES_UP
        #define P76_DM_RES_DWN         PIN_DM_RES_DWN
        #define P76_DM_OD_LO           PIN_DM_OD_LO
        #define P76_DM_OD_HI           PIN_DM_OD_HI
        #define P76_DM_STRONG          PIN_DM_STRONG
        #define P76_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define P76_MASK               P76__MASK
#define P76_SHIFT              P76__SHIFT
#define P76_WIDTH              1u

/* Interrupt constants */
#if defined(P76__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in P76_SetInterruptMode() function.
     *  @{
     */
        #define P76_INTR_NONE      (uint16)(0x0000u)
        #define P76_INTR_RISING    (uint16)(0x0001u)
        #define P76_INTR_FALLING   (uint16)(0x0002u)
        #define P76_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define P76_INTR_MASK      (0x01u) 
#endif /* (P76__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define P76_PS                     (* (reg8 *) P76__PS)
/* Data Register */
#define P76_DR                     (* (reg8 *) P76__DR)
/* Port Number */
#define P76_PRT_NUM                (* (reg8 *) P76__PRT) 
/* Connect to Analog Globals */                                                  
#define P76_AG                     (* (reg8 *) P76__AG)                       
/* Analog MUX bux enable */
#define P76_AMUX                   (* (reg8 *) P76__AMUX) 
/* Bidirectional Enable */                                                        
#define P76_BIE                    (* (reg8 *) P76__BIE)
/* Bit-mask for Aliased Register Access */
#define P76_BIT_MASK               (* (reg8 *) P76__BIT_MASK)
/* Bypass Enable */
#define P76_BYP                    (* (reg8 *) P76__BYP)
/* Port wide control signals */                                                   
#define P76_CTL                    (* (reg8 *) P76__CTL)
/* Drive Modes */
#define P76_DM0                    (* (reg8 *) P76__DM0) 
#define P76_DM1                    (* (reg8 *) P76__DM1)
#define P76_DM2                    (* (reg8 *) P76__DM2) 
/* Input Buffer Disable Override */
#define P76_INP_DIS                (* (reg8 *) P76__INP_DIS)
/* LCD Common or Segment Drive */
#define P76_LCD_COM_SEG            (* (reg8 *) P76__LCD_COM_SEG)
/* Enable Segment LCD */
#define P76_LCD_EN                 (* (reg8 *) P76__LCD_EN)
/* Slew Rate Control */
#define P76_SLW                    (* (reg8 *) P76__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define P76_PRTDSI__CAPS_SEL       (* (reg8 *) P76__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define P76_PRTDSI__DBL_SYNC_IN    (* (reg8 *) P76__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define P76_PRTDSI__OE_SEL0        (* (reg8 *) P76__PRTDSI__OE_SEL0) 
#define P76_PRTDSI__OE_SEL1        (* (reg8 *) P76__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define P76_PRTDSI__OUT_SEL0       (* (reg8 *) P76__PRTDSI__OUT_SEL0) 
#define P76_PRTDSI__OUT_SEL1       (* (reg8 *) P76__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define P76_PRTDSI__SYNC_OUT       (* (reg8 *) P76__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(P76__SIO_CFG)
    #define P76_SIO_HYST_EN        (* (reg8 *) P76__SIO_HYST_EN)
    #define P76_SIO_REG_HIFREQ     (* (reg8 *) P76__SIO_REG_HIFREQ)
    #define P76_SIO_CFG            (* (reg8 *) P76__SIO_CFG)
    #define P76_SIO_DIFF           (* (reg8 *) P76__SIO_DIFF)
#endif /* (P76__SIO_CFG) */

/* Interrupt Registers */
#if defined(P76__INTSTAT)
    #define P76_INTSTAT            (* (reg8 *) P76__INTSTAT)
    #define P76_SNAP               (* (reg8 *) P76__SNAP)
    
	#define P76_0_INTTYPE_REG 		(* (reg8 *) P76__0__INTTYPE)
#endif /* (P76__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_P76_H */


/* [] END OF FILE */
