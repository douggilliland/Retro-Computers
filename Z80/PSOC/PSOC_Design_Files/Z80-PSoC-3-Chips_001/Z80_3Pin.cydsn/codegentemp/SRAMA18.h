/*******************************************************************************
* File Name: SRAMA18.h  
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

#if !defined(CY_PINS_SRAMA18_H) /* Pins SRAMA18_H */
#define CY_PINS_SRAMA18_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA18_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA18__PORT == 15 && ((SRAMA18__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA18_Write(uint8 value);
void    SRAMA18_SetDriveMode(uint8 mode);
uint8   SRAMA18_ReadDataReg(void);
uint8   SRAMA18_Read(void);
void    SRAMA18_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA18_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA18_SetDriveMode() function.
     *  @{
     */
        #define SRAMA18_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA18_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA18_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA18_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA18_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA18_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA18_DM_STRONG          PIN_DM_STRONG
        #define SRAMA18_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA18_MASK               SRAMA18__MASK
#define SRAMA18_SHIFT              SRAMA18__SHIFT
#define SRAMA18_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA18__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA18_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA18_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA18_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA18_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA18_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA18_INTR_MASK      (0x01u) 
#endif /* (SRAMA18__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA18_PS                     (* (reg8 *) SRAMA18__PS)
/* Data Register */
#define SRAMA18_DR                     (* (reg8 *) SRAMA18__DR)
/* Port Number */
#define SRAMA18_PRT_NUM                (* (reg8 *) SRAMA18__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA18_AG                     (* (reg8 *) SRAMA18__AG)                       
/* Analog MUX bux enable */
#define SRAMA18_AMUX                   (* (reg8 *) SRAMA18__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA18_BIE                    (* (reg8 *) SRAMA18__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA18_BIT_MASK               (* (reg8 *) SRAMA18__BIT_MASK)
/* Bypass Enable */
#define SRAMA18_BYP                    (* (reg8 *) SRAMA18__BYP)
/* Port wide control signals */                                                   
#define SRAMA18_CTL                    (* (reg8 *) SRAMA18__CTL)
/* Drive Modes */
#define SRAMA18_DM0                    (* (reg8 *) SRAMA18__DM0) 
#define SRAMA18_DM1                    (* (reg8 *) SRAMA18__DM1)
#define SRAMA18_DM2                    (* (reg8 *) SRAMA18__DM2) 
/* Input Buffer Disable Override */
#define SRAMA18_INP_DIS                (* (reg8 *) SRAMA18__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA18_LCD_COM_SEG            (* (reg8 *) SRAMA18__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA18_LCD_EN                 (* (reg8 *) SRAMA18__LCD_EN)
/* Slew Rate Control */
#define SRAMA18_SLW                    (* (reg8 *) SRAMA18__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA18_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA18__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA18_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA18__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA18_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA18__PRTDSI__OE_SEL0) 
#define SRAMA18_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA18__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA18_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA18__PRTDSI__OUT_SEL0) 
#define SRAMA18_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA18__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA18_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA18__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA18__SIO_CFG)
    #define SRAMA18_SIO_HYST_EN        (* (reg8 *) SRAMA18__SIO_HYST_EN)
    #define SRAMA18_SIO_REG_HIFREQ     (* (reg8 *) SRAMA18__SIO_REG_HIFREQ)
    #define SRAMA18_SIO_CFG            (* (reg8 *) SRAMA18__SIO_CFG)
    #define SRAMA18_SIO_DIFF           (* (reg8 *) SRAMA18__SIO_DIFF)
#endif /* (SRAMA18__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA18__INTSTAT)
    #define SRAMA18_INTSTAT            (* (reg8 *) SRAMA18__INTSTAT)
    #define SRAMA18_SNAP               (* (reg8 *) SRAMA18__SNAP)
    
	#define SRAMA18_0_INTTYPE_REG 		(* (reg8 *) SRAMA18__0__INTTYPE)
#endif /* (SRAMA18__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA18_H */


/* [] END OF FILE */
