/*******************************************************************************
* File Name: SRAMA11.h  
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

#if !defined(CY_PINS_SRAMA11_H) /* Pins SRAMA11_H */
#define CY_PINS_SRAMA11_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA11_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA11__PORT == 15 && ((SRAMA11__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA11_Write(uint8 value);
void    SRAMA11_SetDriveMode(uint8 mode);
uint8   SRAMA11_ReadDataReg(void);
uint8   SRAMA11_Read(void);
void    SRAMA11_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA11_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA11_SetDriveMode() function.
     *  @{
     */
        #define SRAMA11_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA11_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA11_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA11_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA11_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA11_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA11_DM_STRONG          PIN_DM_STRONG
        #define SRAMA11_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA11_MASK               SRAMA11__MASK
#define SRAMA11_SHIFT              SRAMA11__SHIFT
#define SRAMA11_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA11__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA11_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA11_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA11_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA11_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA11_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA11_INTR_MASK      (0x01u) 
#endif /* (SRAMA11__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA11_PS                     (* (reg8 *) SRAMA11__PS)
/* Data Register */
#define SRAMA11_DR                     (* (reg8 *) SRAMA11__DR)
/* Port Number */
#define SRAMA11_PRT_NUM                (* (reg8 *) SRAMA11__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA11_AG                     (* (reg8 *) SRAMA11__AG)                       
/* Analog MUX bux enable */
#define SRAMA11_AMUX                   (* (reg8 *) SRAMA11__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA11_BIE                    (* (reg8 *) SRAMA11__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA11_BIT_MASK               (* (reg8 *) SRAMA11__BIT_MASK)
/* Bypass Enable */
#define SRAMA11_BYP                    (* (reg8 *) SRAMA11__BYP)
/* Port wide control signals */                                                   
#define SRAMA11_CTL                    (* (reg8 *) SRAMA11__CTL)
/* Drive Modes */
#define SRAMA11_DM0                    (* (reg8 *) SRAMA11__DM0) 
#define SRAMA11_DM1                    (* (reg8 *) SRAMA11__DM1)
#define SRAMA11_DM2                    (* (reg8 *) SRAMA11__DM2) 
/* Input Buffer Disable Override */
#define SRAMA11_INP_DIS                (* (reg8 *) SRAMA11__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA11_LCD_COM_SEG            (* (reg8 *) SRAMA11__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA11_LCD_EN                 (* (reg8 *) SRAMA11__LCD_EN)
/* Slew Rate Control */
#define SRAMA11_SLW                    (* (reg8 *) SRAMA11__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA11_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA11__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA11_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA11__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA11_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA11__PRTDSI__OE_SEL0) 
#define SRAMA11_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA11__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA11_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA11__PRTDSI__OUT_SEL0) 
#define SRAMA11_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA11__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA11_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA11__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA11__SIO_CFG)
    #define SRAMA11_SIO_HYST_EN        (* (reg8 *) SRAMA11__SIO_HYST_EN)
    #define SRAMA11_SIO_REG_HIFREQ     (* (reg8 *) SRAMA11__SIO_REG_HIFREQ)
    #define SRAMA11_SIO_CFG            (* (reg8 *) SRAMA11__SIO_CFG)
    #define SRAMA11_SIO_DIFF           (* (reg8 *) SRAMA11__SIO_DIFF)
#endif /* (SRAMA11__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA11__INTSTAT)
    #define SRAMA11_INTSTAT            (* (reg8 *) SRAMA11__INTSTAT)
    #define SRAMA11_SNAP               (* (reg8 *) SRAMA11__SNAP)
    
	#define SRAMA11_0_INTTYPE_REG 		(* (reg8 *) SRAMA11__0__INTTYPE)
#endif /* (SRAMA11__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA11_H */


/* [] END OF FILE */
