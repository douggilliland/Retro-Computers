/*******************************************************************************
* File Name: SRAMA13.h  
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

#if !defined(CY_PINS_SRAMA13_H) /* Pins SRAMA13_H */
#define CY_PINS_SRAMA13_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA13_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA13__PORT == 15 && ((SRAMA13__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA13_Write(uint8 value);
void    SRAMA13_SetDriveMode(uint8 mode);
uint8   SRAMA13_ReadDataReg(void);
uint8   SRAMA13_Read(void);
void    SRAMA13_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA13_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA13_SetDriveMode() function.
     *  @{
     */
        #define SRAMA13_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA13_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA13_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA13_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA13_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA13_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA13_DM_STRONG          PIN_DM_STRONG
        #define SRAMA13_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA13_MASK               SRAMA13__MASK
#define SRAMA13_SHIFT              SRAMA13__SHIFT
#define SRAMA13_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA13__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA13_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA13_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA13_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA13_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA13_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA13_INTR_MASK      (0x01u) 
#endif /* (SRAMA13__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA13_PS                     (* (reg8 *) SRAMA13__PS)
/* Data Register */
#define SRAMA13_DR                     (* (reg8 *) SRAMA13__DR)
/* Port Number */
#define SRAMA13_PRT_NUM                (* (reg8 *) SRAMA13__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA13_AG                     (* (reg8 *) SRAMA13__AG)                       
/* Analog MUX bux enable */
#define SRAMA13_AMUX                   (* (reg8 *) SRAMA13__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA13_BIE                    (* (reg8 *) SRAMA13__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA13_BIT_MASK               (* (reg8 *) SRAMA13__BIT_MASK)
/* Bypass Enable */
#define SRAMA13_BYP                    (* (reg8 *) SRAMA13__BYP)
/* Port wide control signals */                                                   
#define SRAMA13_CTL                    (* (reg8 *) SRAMA13__CTL)
/* Drive Modes */
#define SRAMA13_DM0                    (* (reg8 *) SRAMA13__DM0) 
#define SRAMA13_DM1                    (* (reg8 *) SRAMA13__DM1)
#define SRAMA13_DM2                    (* (reg8 *) SRAMA13__DM2) 
/* Input Buffer Disable Override */
#define SRAMA13_INP_DIS                (* (reg8 *) SRAMA13__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA13_LCD_COM_SEG            (* (reg8 *) SRAMA13__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA13_LCD_EN                 (* (reg8 *) SRAMA13__LCD_EN)
/* Slew Rate Control */
#define SRAMA13_SLW                    (* (reg8 *) SRAMA13__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA13_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA13__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA13_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA13__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA13_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA13__PRTDSI__OE_SEL0) 
#define SRAMA13_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA13__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA13_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA13__PRTDSI__OUT_SEL0) 
#define SRAMA13_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA13__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA13_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA13__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA13__SIO_CFG)
    #define SRAMA13_SIO_HYST_EN        (* (reg8 *) SRAMA13__SIO_HYST_EN)
    #define SRAMA13_SIO_REG_HIFREQ     (* (reg8 *) SRAMA13__SIO_REG_HIFREQ)
    #define SRAMA13_SIO_CFG            (* (reg8 *) SRAMA13__SIO_CFG)
    #define SRAMA13_SIO_DIFF           (* (reg8 *) SRAMA13__SIO_DIFF)
#endif /* (SRAMA13__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA13__INTSTAT)
    #define SRAMA13_INTSTAT            (* (reg8 *) SRAMA13__INTSTAT)
    #define SRAMA13_SNAP               (* (reg8 *) SRAMA13__SNAP)
    
	#define SRAMA13_0_INTTYPE_REG 		(* (reg8 *) SRAMA13__0__INTTYPE)
#endif /* (SRAMA13__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA13_H */


/* [] END OF FILE */
