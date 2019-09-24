/*******************************************************************************
* File Name: SRAMA12.h  
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

#if !defined(CY_PINS_SRAMA12_H) /* Pins SRAMA12_H */
#define CY_PINS_SRAMA12_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA12_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA12__PORT == 15 && ((SRAMA12__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA12_Write(uint8 value);
void    SRAMA12_SetDriveMode(uint8 mode);
uint8   SRAMA12_ReadDataReg(void);
uint8   SRAMA12_Read(void);
void    SRAMA12_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA12_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA12_SetDriveMode() function.
     *  @{
     */
        #define SRAMA12_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA12_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA12_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA12_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA12_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA12_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA12_DM_STRONG          PIN_DM_STRONG
        #define SRAMA12_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA12_MASK               SRAMA12__MASK
#define SRAMA12_SHIFT              SRAMA12__SHIFT
#define SRAMA12_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA12__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA12_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA12_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA12_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA12_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA12_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA12_INTR_MASK      (0x01u) 
#endif /* (SRAMA12__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA12_PS                     (* (reg8 *) SRAMA12__PS)
/* Data Register */
#define SRAMA12_DR                     (* (reg8 *) SRAMA12__DR)
/* Port Number */
#define SRAMA12_PRT_NUM                (* (reg8 *) SRAMA12__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA12_AG                     (* (reg8 *) SRAMA12__AG)                       
/* Analog MUX bux enable */
#define SRAMA12_AMUX                   (* (reg8 *) SRAMA12__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA12_BIE                    (* (reg8 *) SRAMA12__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA12_BIT_MASK               (* (reg8 *) SRAMA12__BIT_MASK)
/* Bypass Enable */
#define SRAMA12_BYP                    (* (reg8 *) SRAMA12__BYP)
/* Port wide control signals */                                                   
#define SRAMA12_CTL                    (* (reg8 *) SRAMA12__CTL)
/* Drive Modes */
#define SRAMA12_DM0                    (* (reg8 *) SRAMA12__DM0) 
#define SRAMA12_DM1                    (* (reg8 *) SRAMA12__DM1)
#define SRAMA12_DM2                    (* (reg8 *) SRAMA12__DM2) 
/* Input Buffer Disable Override */
#define SRAMA12_INP_DIS                (* (reg8 *) SRAMA12__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA12_LCD_COM_SEG            (* (reg8 *) SRAMA12__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA12_LCD_EN                 (* (reg8 *) SRAMA12__LCD_EN)
/* Slew Rate Control */
#define SRAMA12_SLW                    (* (reg8 *) SRAMA12__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA12_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA12__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA12_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA12__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA12_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA12__PRTDSI__OE_SEL0) 
#define SRAMA12_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA12__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA12_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA12__PRTDSI__OUT_SEL0) 
#define SRAMA12_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA12__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA12_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA12__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA12__SIO_CFG)
    #define SRAMA12_SIO_HYST_EN        (* (reg8 *) SRAMA12__SIO_HYST_EN)
    #define SRAMA12_SIO_REG_HIFREQ     (* (reg8 *) SRAMA12__SIO_REG_HIFREQ)
    #define SRAMA12_SIO_CFG            (* (reg8 *) SRAMA12__SIO_CFG)
    #define SRAMA12_SIO_DIFF           (* (reg8 *) SRAMA12__SIO_DIFF)
#endif /* (SRAMA12__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA12__INTSTAT)
    #define SRAMA12_INTSTAT            (* (reg8 *) SRAMA12__INTSTAT)
    #define SRAMA12_SNAP               (* (reg8 *) SRAMA12__SNAP)
    
	#define SRAMA12_0_INTTYPE_REG 		(* (reg8 *) SRAMA12__0__INTTYPE)
#endif /* (SRAMA12__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA12_H */


/* [] END OF FILE */
