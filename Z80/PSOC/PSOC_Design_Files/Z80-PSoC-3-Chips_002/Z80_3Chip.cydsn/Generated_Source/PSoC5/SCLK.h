/*******************************************************************************
* File Name: SCLK.h  
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

#if !defined(CY_PINS_SCLK_H) /* Pins SCLK_H */
#define CY_PINS_SCLK_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SCLK_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SCLK__PORT == 15 && ((SCLK__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SCLK_Write(uint8 value);
void    SCLK_SetDriveMode(uint8 mode);
uint8   SCLK_ReadDataReg(void);
uint8   SCLK_Read(void);
void    SCLK_SetInterruptMode(uint16 position, uint16 mode);
uint8   SCLK_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SCLK_SetDriveMode() function.
     *  @{
     */
        #define SCLK_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SCLK_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SCLK_DM_RES_UP          PIN_DM_RES_UP
        #define SCLK_DM_RES_DWN         PIN_DM_RES_DWN
        #define SCLK_DM_OD_LO           PIN_DM_OD_LO
        #define SCLK_DM_OD_HI           PIN_DM_OD_HI
        #define SCLK_DM_STRONG          PIN_DM_STRONG
        #define SCLK_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SCLK_MASK               SCLK__MASK
#define SCLK_SHIFT              SCLK__SHIFT
#define SCLK_WIDTH              1u

/* Interrupt constants */
#if defined(SCLK__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SCLK_SetInterruptMode() function.
     *  @{
     */
        #define SCLK_INTR_NONE      (uint16)(0x0000u)
        #define SCLK_INTR_RISING    (uint16)(0x0001u)
        #define SCLK_INTR_FALLING   (uint16)(0x0002u)
        #define SCLK_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SCLK_INTR_MASK      (0x01u) 
#endif /* (SCLK__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SCLK_PS                     (* (reg8 *) SCLK__PS)
/* Data Register */
#define SCLK_DR                     (* (reg8 *) SCLK__DR)
/* Port Number */
#define SCLK_PRT_NUM                (* (reg8 *) SCLK__PRT) 
/* Connect to Analog Globals */                                                  
#define SCLK_AG                     (* (reg8 *) SCLK__AG)                       
/* Analog MUX bux enable */
#define SCLK_AMUX                   (* (reg8 *) SCLK__AMUX) 
/* Bidirectional Enable */                                                        
#define SCLK_BIE                    (* (reg8 *) SCLK__BIE)
/* Bit-mask for Aliased Register Access */
#define SCLK_BIT_MASK               (* (reg8 *) SCLK__BIT_MASK)
/* Bypass Enable */
#define SCLK_BYP                    (* (reg8 *) SCLK__BYP)
/* Port wide control signals */                                                   
#define SCLK_CTL                    (* (reg8 *) SCLK__CTL)
/* Drive Modes */
#define SCLK_DM0                    (* (reg8 *) SCLK__DM0) 
#define SCLK_DM1                    (* (reg8 *) SCLK__DM1)
#define SCLK_DM2                    (* (reg8 *) SCLK__DM2) 
/* Input Buffer Disable Override */
#define SCLK_INP_DIS                (* (reg8 *) SCLK__INP_DIS)
/* LCD Common or Segment Drive */
#define SCLK_LCD_COM_SEG            (* (reg8 *) SCLK__LCD_COM_SEG)
/* Enable Segment LCD */
#define SCLK_LCD_EN                 (* (reg8 *) SCLK__LCD_EN)
/* Slew Rate Control */
#define SCLK_SLW                    (* (reg8 *) SCLK__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SCLK_PRTDSI__CAPS_SEL       (* (reg8 *) SCLK__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SCLK_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SCLK__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SCLK_PRTDSI__OE_SEL0        (* (reg8 *) SCLK__PRTDSI__OE_SEL0) 
#define SCLK_PRTDSI__OE_SEL1        (* (reg8 *) SCLK__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SCLK_PRTDSI__OUT_SEL0       (* (reg8 *) SCLK__PRTDSI__OUT_SEL0) 
#define SCLK_PRTDSI__OUT_SEL1       (* (reg8 *) SCLK__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SCLK_PRTDSI__SYNC_OUT       (* (reg8 *) SCLK__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SCLK__SIO_CFG)
    #define SCLK_SIO_HYST_EN        (* (reg8 *) SCLK__SIO_HYST_EN)
    #define SCLK_SIO_REG_HIFREQ     (* (reg8 *) SCLK__SIO_REG_HIFREQ)
    #define SCLK_SIO_CFG            (* (reg8 *) SCLK__SIO_CFG)
    #define SCLK_SIO_DIFF           (* (reg8 *) SCLK__SIO_DIFF)
#endif /* (SCLK__SIO_CFG) */

/* Interrupt Registers */
#if defined(SCLK__INTSTAT)
    #define SCLK_INTSTAT            (* (reg8 *) SCLK__INTSTAT)
    #define SCLK_SNAP               (* (reg8 *) SCLK__SNAP)
    
	#define SCLK_0_INTTYPE_REG 		(* (reg8 *) SCLK__0__INTTYPE)
#endif /* (SCLK__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SCLK_H */


/* [] END OF FILE */
