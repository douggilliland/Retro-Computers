/*******************************************************************************
* File Name: CPUA10.h  
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

#if !defined(CY_PINS_CPUA10_H) /* Pins CPUA10_H */
#define CY_PINS_CPUA10_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA10_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA10__PORT == 15 && ((CPUA10__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA10_Write(uint8 value);
void    CPUA10_SetDriveMode(uint8 mode);
uint8   CPUA10_ReadDataReg(void);
uint8   CPUA10_Read(void);
void    CPUA10_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA10_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA10_SetDriveMode() function.
     *  @{
     */
        #define CPUA10_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA10_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA10_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA10_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA10_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA10_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA10_DM_STRONG          PIN_DM_STRONG
        #define CPUA10_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA10_MASK               CPUA10__MASK
#define CPUA10_SHIFT              CPUA10__SHIFT
#define CPUA10_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA10__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA10_SetInterruptMode() function.
     *  @{
     */
        #define CPUA10_INTR_NONE      (uint16)(0x0000u)
        #define CPUA10_INTR_RISING    (uint16)(0x0001u)
        #define CPUA10_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA10_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA10_INTR_MASK      (0x01u) 
#endif /* (CPUA10__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA10_PS                     (* (reg8 *) CPUA10__PS)
/* Data Register */
#define CPUA10_DR                     (* (reg8 *) CPUA10__DR)
/* Port Number */
#define CPUA10_PRT_NUM                (* (reg8 *) CPUA10__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA10_AG                     (* (reg8 *) CPUA10__AG)                       
/* Analog MUX bux enable */
#define CPUA10_AMUX                   (* (reg8 *) CPUA10__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA10_BIE                    (* (reg8 *) CPUA10__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA10_BIT_MASK               (* (reg8 *) CPUA10__BIT_MASK)
/* Bypass Enable */
#define CPUA10_BYP                    (* (reg8 *) CPUA10__BYP)
/* Port wide control signals */                                                   
#define CPUA10_CTL                    (* (reg8 *) CPUA10__CTL)
/* Drive Modes */
#define CPUA10_DM0                    (* (reg8 *) CPUA10__DM0) 
#define CPUA10_DM1                    (* (reg8 *) CPUA10__DM1)
#define CPUA10_DM2                    (* (reg8 *) CPUA10__DM2) 
/* Input Buffer Disable Override */
#define CPUA10_INP_DIS                (* (reg8 *) CPUA10__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA10_LCD_COM_SEG            (* (reg8 *) CPUA10__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA10_LCD_EN                 (* (reg8 *) CPUA10__LCD_EN)
/* Slew Rate Control */
#define CPUA10_SLW                    (* (reg8 *) CPUA10__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA10_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA10__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA10_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA10__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA10_PRTDSI__OE_SEL0        (* (reg8 *) CPUA10__PRTDSI__OE_SEL0) 
#define CPUA10_PRTDSI__OE_SEL1        (* (reg8 *) CPUA10__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA10_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA10__PRTDSI__OUT_SEL0) 
#define CPUA10_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA10__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA10_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA10__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA10__SIO_CFG)
    #define CPUA10_SIO_HYST_EN        (* (reg8 *) CPUA10__SIO_HYST_EN)
    #define CPUA10_SIO_REG_HIFREQ     (* (reg8 *) CPUA10__SIO_REG_HIFREQ)
    #define CPUA10_SIO_CFG            (* (reg8 *) CPUA10__SIO_CFG)
    #define CPUA10_SIO_DIFF           (* (reg8 *) CPUA10__SIO_DIFF)
#endif /* (CPUA10__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA10__INTSTAT)
    #define CPUA10_INTSTAT            (* (reg8 *) CPUA10__INTSTAT)
    #define CPUA10_SNAP               (* (reg8 *) CPUA10__SNAP)
    
	#define CPUA10_0_INTTYPE_REG 		(* (reg8 *) CPUA10__0__INTTYPE)
#endif /* (CPUA10__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA10_H */


/* [] END OF FILE */
