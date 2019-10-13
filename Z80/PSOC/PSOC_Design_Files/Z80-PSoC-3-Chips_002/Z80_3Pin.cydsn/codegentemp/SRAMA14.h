/*******************************************************************************
* File Name: SRAMA14.h  
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

#if !defined(CY_PINS_SRAMA14_H) /* Pins SRAMA14_H */
#define CY_PINS_SRAMA14_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA14_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA14__PORT == 15 && ((SRAMA14__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA14_Write(uint8 value);
void    SRAMA14_SetDriveMode(uint8 mode);
uint8   SRAMA14_ReadDataReg(void);
uint8   SRAMA14_Read(void);
void    SRAMA14_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA14_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA14_SetDriveMode() function.
     *  @{
     */
        #define SRAMA14_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA14_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA14_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA14_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA14_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA14_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA14_DM_STRONG          PIN_DM_STRONG
        #define SRAMA14_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA14_MASK               SRAMA14__MASK
#define SRAMA14_SHIFT              SRAMA14__SHIFT
#define SRAMA14_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA14__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA14_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA14_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA14_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA14_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA14_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA14_INTR_MASK      (0x01u) 
#endif /* (SRAMA14__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA14_PS                     (* (reg8 *) SRAMA14__PS)
/* Data Register */
#define SRAMA14_DR                     (* (reg8 *) SRAMA14__DR)
/* Port Number */
#define SRAMA14_PRT_NUM                (* (reg8 *) SRAMA14__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA14_AG                     (* (reg8 *) SRAMA14__AG)                       
/* Analog MUX bux enable */
#define SRAMA14_AMUX                   (* (reg8 *) SRAMA14__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA14_BIE                    (* (reg8 *) SRAMA14__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA14_BIT_MASK               (* (reg8 *) SRAMA14__BIT_MASK)
/* Bypass Enable */
#define SRAMA14_BYP                    (* (reg8 *) SRAMA14__BYP)
/* Port wide control signals */                                                   
#define SRAMA14_CTL                    (* (reg8 *) SRAMA14__CTL)
/* Drive Modes */
#define SRAMA14_DM0                    (* (reg8 *) SRAMA14__DM0) 
#define SRAMA14_DM1                    (* (reg8 *) SRAMA14__DM1)
#define SRAMA14_DM2                    (* (reg8 *) SRAMA14__DM2) 
/* Input Buffer Disable Override */
#define SRAMA14_INP_DIS                (* (reg8 *) SRAMA14__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA14_LCD_COM_SEG            (* (reg8 *) SRAMA14__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA14_LCD_EN                 (* (reg8 *) SRAMA14__LCD_EN)
/* Slew Rate Control */
#define SRAMA14_SLW                    (* (reg8 *) SRAMA14__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA14_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA14__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA14_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA14__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA14_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA14__PRTDSI__OE_SEL0) 
#define SRAMA14_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA14__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA14_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA14__PRTDSI__OUT_SEL0) 
#define SRAMA14_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA14__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA14_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA14__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA14__SIO_CFG)
    #define SRAMA14_SIO_HYST_EN        (* (reg8 *) SRAMA14__SIO_HYST_EN)
    #define SRAMA14_SIO_REG_HIFREQ     (* (reg8 *) SRAMA14__SIO_REG_HIFREQ)
    #define SRAMA14_SIO_CFG            (* (reg8 *) SRAMA14__SIO_CFG)
    #define SRAMA14_SIO_DIFF           (* (reg8 *) SRAMA14__SIO_DIFF)
#endif /* (SRAMA14__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA14__INTSTAT)
    #define SRAMA14_INTSTAT            (* (reg8 *) SRAMA14__INTSTAT)
    #define SRAMA14_SNAP               (* (reg8 *) SRAMA14__SNAP)
    
	#define SRAMA14_0_INTTYPE_REG 		(* (reg8 *) SRAMA14__0__INTTYPE)
#endif /* (SRAMA14__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA14_H */


/* [] END OF FILE */
