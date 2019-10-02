/*******************************************************************************
* File Name: D4.h  
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

#if !defined(CY_PINS_D4_H) /* Pins D4_H */
#define CY_PINS_D4_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "D4_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 D4__PORT == 15 && ((D4__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    D4_Write(uint8 value);
void    D4_SetDriveMode(uint8 mode);
uint8   D4_ReadDataReg(void);
uint8   D4_Read(void);
void    D4_SetInterruptMode(uint16 position, uint16 mode);
uint8   D4_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the D4_SetDriveMode() function.
     *  @{
     */
        #define D4_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define D4_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define D4_DM_RES_UP          PIN_DM_RES_UP
        #define D4_DM_RES_DWN         PIN_DM_RES_DWN
        #define D4_DM_OD_LO           PIN_DM_OD_LO
        #define D4_DM_OD_HI           PIN_DM_OD_HI
        #define D4_DM_STRONG          PIN_DM_STRONG
        #define D4_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define D4_MASK               D4__MASK
#define D4_SHIFT              D4__SHIFT
#define D4_WIDTH              1u

/* Interrupt constants */
#if defined(D4__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in D4_SetInterruptMode() function.
     *  @{
     */
        #define D4_INTR_NONE      (uint16)(0x0000u)
        #define D4_INTR_RISING    (uint16)(0x0001u)
        #define D4_INTR_FALLING   (uint16)(0x0002u)
        #define D4_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define D4_INTR_MASK      (0x01u) 
#endif /* (D4__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define D4_PS                     (* (reg8 *) D4__PS)
/* Data Register */
#define D4_DR                     (* (reg8 *) D4__DR)
/* Port Number */
#define D4_PRT_NUM                (* (reg8 *) D4__PRT) 
/* Connect to Analog Globals */                                                  
#define D4_AG                     (* (reg8 *) D4__AG)                       
/* Analog MUX bux enable */
#define D4_AMUX                   (* (reg8 *) D4__AMUX) 
/* Bidirectional Enable */                                                        
#define D4_BIE                    (* (reg8 *) D4__BIE)
/* Bit-mask for Aliased Register Access */
#define D4_BIT_MASK               (* (reg8 *) D4__BIT_MASK)
/* Bypass Enable */
#define D4_BYP                    (* (reg8 *) D4__BYP)
/* Port wide control signals */                                                   
#define D4_CTL                    (* (reg8 *) D4__CTL)
/* Drive Modes */
#define D4_DM0                    (* (reg8 *) D4__DM0) 
#define D4_DM1                    (* (reg8 *) D4__DM1)
#define D4_DM2                    (* (reg8 *) D4__DM2) 
/* Input Buffer Disable Override */
#define D4_INP_DIS                (* (reg8 *) D4__INP_DIS)
/* LCD Common or Segment Drive */
#define D4_LCD_COM_SEG            (* (reg8 *) D4__LCD_COM_SEG)
/* Enable Segment LCD */
#define D4_LCD_EN                 (* (reg8 *) D4__LCD_EN)
/* Slew Rate Control */
#define D4_SLW                    (* (reg8 *) D4__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define D4_PRTDSI__CAPS_SEL       (* (reg8 *) D4__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define D4_PRTDSI__DBL_SYNC_IN    (* (reg8 *) D4__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define D4_PRTDSI__OE_SEL0        (* (reg8 *) D4__PRTDSI__OE_SEL0) 
#define D4_PRTDSI__OE_SEL1        (* (reg8 *) D4__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define D4_PRTDSI__OUT_SEL0       (* (reg8 *) D4__PRTDSI__OUT_SEL0) 
#define D4_PRTDSI__OUT_SEL1       (* (reg8 *) D4__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define D4_PRTDSI__SYNC_OUT       (* (reg8 *) D4__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(D4__SIO_CFG)
    #define D4_SIO_HYST_EN        (* (reg8 *) D4__SIO_HYST_EN)
    #define D4_SIO_REG_HIFREQ     (* (reg8 *) D4__SIO_REG_HIFREQ)
    #define D4_SIO_CFG            (* (reg8 *) D4__SIO_CFG)
    #define D4_SIO_DIFF           (* (reg8 *) D4__SIO_DIFF)
#endif /* (D4__SIO_CFG) */

/* Interrupt Registers */
#if defined(D4__INTSTAT)
    #define D4_INTSTAT            (* (reg8 *) D4__INTSTAT)
    #define D4_SNAP               (* (reg8 *) D4__SNAP)
    
	#define D4_0_INTTYPE_REG 		(* (reg8 *) D4__0__INTTYPE)
#endif /* (D4__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_D4_H */


/* [] END OF FILE */
