/*******************************************************************************
* File Name: CPUD7.h  
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

#if !defined(CY_PINS_CPUD7_H) /* Pins CPUD7_H */
#define CY_PINS_CPUD7_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD7_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD7__PORT == 15 && ((CPUD7__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD7_Write(uint8 value);
void    CPUD7_SetDriveMode(uint8 mode);
uint8   CPUD7_ReadDataReg(void);
uint8   CPUD7_Read(void);
void    CPUD7_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD7_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD7_SetDriveMode() function.
     *  @{
     */
        #define CPUD7_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD7_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD7_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD7_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD7_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD7_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD7_DM_STRONG          PIN_DM_STRONG
        #define CPUD7_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD7_MASK               CPUD7__MASK
#define CPUD7_SHIFT              CPUD7__SHIFT
#define CPUD7_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD7__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD7_SetInterruptMode() function.
     *  @{
     */
        #define CPUD7_INTR_NONE      (uint16)(0x0000u)
        #define CPUD7_INTR_RISING    (uint16)(0x0001u)
        #define CPUD7_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD7_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD7_INTR_MASK      (0x01u) 
#endif /* (CPUD7__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD7_PS                     (* (reg8 *) CPUD7__PS)
/* Data Register */
#define CPUD7_DR                     (* (reg8 *) CPUD7__DR)
/* Port Number */
#define CPUD7_PRT_NUM                (* (reg8 *) CPUD7__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD7_AG                     (* (reg8 *) CPUD7__AG)                       
/* Analog MUX bux enable */
#define CPUD7_AMUX                   (* (reg8 *) CPUD7__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD7_BIE                    (* (reg8 *) CPUD7__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD7_BIT_MASK               (* (reg8 *) CPUD7__BIT_MASK)
/* Bypass Enable */
#define CPUD7_BYP                    (* (reg8 *) CPUD7__BYP)
/* Port wide control signals */                                                   
#define CPUD7_CTL                    (* (reg8 *) CPUD7__CTL)
/* Drive Modes */
#define CPUD7_DM0                    (* (reg8 *) CPUD7__DM0) 
#define CPUD7_DM1                    (* (reg8 *) CPUD7__DM1)
#define CPUD7_DM2                    (* (reg8 *) CPUD7__DM2) 
/* Input Buffer Disable Override */
#define CPUD7_INP_DIS                (* (reg8 *) CPUD7__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD7_LCD_COM_SEG            (* (reg8 *) CPUD7__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD7_LCD_EN                 (* (reg8 *) CPUD7__LCD_EN)
/* Slew Rate Control */
#define CPUD7_SLW                    (* (reg8 *) CPUD7__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD7_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD7__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD7_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD7__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD7_PRTDSI__OE_SEL0        (* (reg8 *) CPUD7__PRTDSI__OE_SEL0) 
#define CPUD7_PRTDSI__OE_SEL1        (* (reg8 *) CPUD7__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD7_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD7__PRTDSI__OUT_SEL0) 
#define CPUD7_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD7__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD7_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD7__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD7__SIO_CFG)
    #define CPUD7_SIO_HYST_EN        (* (reg8 *) CPUD7__SIO_HYST_EN)
    #define CPUD7_SIO_REG_HIFREQ     (* (reg8 *) CPUD7__SIO_REG_HIFREQ)
    #define CPUD7_SIO_CFG            (* (reg8 *) CPUD7__SIO_CFG)
    #define CPUD7_SIO_DIFF           (* (reg8 *) CPUD7__SIO_DIFF)
#endif /* (CPUD7__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD7__INTSTAT)
    #define CPUD7_INTSTAT            (* (reg8 *) CPUD7__INTSTAT)
    #define CPUD7_SNAP               (* (reg8 *) CPUD7__SNAP)
    
	#define CPUD7_0_INTTYPE_REG 		(* (reg8 *) CPUD7__0__INTTYPE)
#endif /* (CPUD7__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD7_H */


/* [] END OF FILE */
