/*******************************************************************************
* File Name: CPURSTn.h  
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

#if !defined(CY_PINS_CPURSTn_H) /* Pins CPURSTn_H */
#define CY_PINS_CPURSTn_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPURSTn_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPURSTn__PORT == 15 && ((CPURSTn__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPURSTn_Write(uint8 value);
void    CPURSTn_SetDriveMode(uint8 mode);
uint8   CPURSTn_ReadDataReg(void);
uint8   CPURSTn_Read(void);
void    CPURSTn_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPURSTn_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPURSTn_SetDriveMode() function.
     *  @{
     */
        #define CPURSTn_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPURSTn_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPURSTn_DM_RES_UP          PIN_DM_RES_UP
        #define CPURSTn_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPURSTn_DM_OD_LO           PIN_DM_OD_LO
        #define CPURSTn_DM_OD_HI           PIN_DM_OD_HI
        #define CPURSTn_DM_STRONG          PIN_DM_STRONG
        #define CPURSTn_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPURSTn_MASK               CPURSTn__MASK
#define CPURSTn_SHIFT              CPURSTn__SHIFT
#define CPURSTn_WIDTH              1u

/* Interrupt constants */
#if defined(CPURSTn__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPURSTn_SetInterruptMode() function.
     *  @{
     */
        #define CPURSTn_INTR_NONE      (uint16)(0x0000u)
        #define CPURSTn_INTR_RISING    (uint16)(0x0001u)
        #define CPURSTn_INTR_FALLING   (uint16)(0x0002u)
        #define CPURSTn_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPURSTn_INTR_MASK      (0x01u) 
#endif /* (CPURSTn__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPURSTn_PS                     (* (reg8 *) CPURSTn__PS)
/* Data Register */
#define CPURSTn_DR                     (* (reg8 *) CPURSTn__DR)
/* Port Number */
#define CPURSTn_PRT_NUM                (* (reg8 *) CPURSTn__PRT) 
/* Connect to Analog Globals */                                                  
#define CPURSTn_AG                     (* (reg8 *) CPURSTn__AG)                       
/* Analog MUX bux enable */
#define CPURSTn_AMUX                   (* (reg8 *) CPURSTn__AMUX) 
/* Bidirectional Enable */                                                        
#define CPURSTn_BIE                    (* (reg8 *) CPURSTn__BIE)
/* Bit-mask for Aliased Register Access */
#define CPURSTn_BIT_MASK               (* (reg8 *) CPURSTn__BIT_MASK)
/* Bypass Enable */
#define CPURSTn_BYP                    (* (reg8 *) CPURSTn__BYP)
/* Port wide control signals */                                                   
#define CPURSTn_CTL                    (* (reg8 *) CPURSTn__CTL)
/* Drive Modes */
#define CPURSTn_DM0                    (* (reg8 *) CPURSTn__DM0) 
#define CPURSTn_DM1                    (* (reg8 *) CPURSTn__DM1)
#define CPURSTn_DM2                    (* (reg8 *) CPURSTn__DM2) 
/* Input Buffer Disable Override */
#define CPURSTn_INP_DIS                (* (reg8 *) CPURSTn__INP_DIS)
/* LCD Common or Segment Drive */
#define CPURSTn_LCD_COM_SEG            (* (reg8 *) CPURSTn__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPURSTn_LCD_EN                 (* (reg8 *) CPURSTn__LCD_EN)
/* Slew Rate Control */
#define CPURSTn_SLW                    (* (reg8 *) CPURSTn__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPURSTn_PRTDSI__CAPS_SEL       (* (reg8 *) CPURSTn__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPURSTn_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPURSTn__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPURSTn_PRTDSI__OE_SEL0        (* (reg8 *) CPURSTn__PRTDSI__OE_SEL0) 
#define CPURSTn_PRTDSI__OE_SEL1        (* (reg8 *) CPURSTn__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPURSTn_PRTDSI__OUT_SEL0       (* (reg8 *) CPURSTn__PRTDSI__OUT_SEL0) 
#define CPURSTn_PRTDSI__OUT_SEL1       (* (reg8 *) CPURSTn__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPURSTn_PRTDSI__SYNC_OUT       (* (reg8 *) CPURSTn__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPURSTn__SIO_CFG)
    #define CPURSTn_SIO_HYST_EN        (* (reg8 *) CPURSTn__SIO_HYST_EN)
    #define CPURSTn_SIO_REG_HIFREQ     (* (reg8 *) CPURSTn__SIO_REG_HIFREQ)
    #define CPURSTn_SIO_CFG            (* (reg8 *) CPURSTn__SIO_CFG)
    #define CPURSTn_SIO_DIFF           (* (reg8 *) CPURSTn__SIO_DIFF)
#endif /* (CPURSTn__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPURSTn__INTSTAT)
    #define CPURSTn_INTSTAT            (* (reg8 *) CPURSTn__INTSTAT)
    #define CPURSTn_SNAP               (* (reg8 *) CPURSTn__SNAP)
    
	#define CPURSTn_0_INTTYPE_REG 		(* (reg8 *) CPURSTn__0__INTTYPE)
#endif /* (CPURSTn__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPURSTn_H */


/* [] END OF FILE */
