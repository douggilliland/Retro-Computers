/*******************************************************************************
* File Name: SRAMA15.h  
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

#if !defined(CY_PINS_SRAMA15_H) /* Pins SRAMA15_H */
#define CY_PINS_SRAMA15_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA15_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA15__PORT == 15 && ((SRAMA15__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA15_Write(uint8 value);
void    SRAMA15_SetDriveMode(uint8 mode);
uint8   SRAMA15_ReadDataReg(void);
uint8   SRAMA15_Read(void);
void    SRAMA15_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA15_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA15_SetDriveMode() function.
     *  @{
     */
        #define SRAMA15_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA15_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA15_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA15_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA15_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA15_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA15_DM_STRONG          PIN_DM_STRONG
        #define SRAMA15_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA15_MASK               SRAMA15__MASK
#define SRAMA15_SHIFT              SRAMA15__SHIFT
#define SRAMA15_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA15__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA15_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA15_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA15_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA15_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA15_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA15_INTR_MASK      (0x01u) 
#endif /* (SRAMA15__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA15_PS                     (* (reg8 *) SRAMA15__PS)
/* Data Register */
#define SRAMA15_DR                     (* (reg8 *) SRAMA15__DR)
/* Port Number */
#define SRAMA15_PRT_NUM                (* (reg8 *) SRAMA15__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA15_AG                     (* (reg8 *) SRAMA15__AG)                       
/* Analog MUX bux enable */
#define SRAMA15_AMUX                   (* (reg8 *) SRAMA15__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA15_BIE                    (* (reg8 *) SRAMA15__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA15_BIT_MASK               (* (reg8 *) SRAMA15__BIT_MASK)
/* Bypass Enable */
#define SRAMA15_BYP                    (* (reg8 *) SRAMA15__BYP)
/* Port wide control signals */                                                   
#define SRAMA15_CTL                    (* (reg8 *) SRAMA15__CTL)
/* Drive Modes */
#define SRAMA15_DM0                    (* (reg8 *) SRAMA15__DM0) 
#define SRAMA15_DM1                    (* (reg8 *) SRAMA15__DM1)
#define SRAMA15_DM2                    (* (reg8 *) SRAMA15__DM2) 
/* Input Buffer Disable Override */
#define SRAMA15_INP_DIS                (* (reg8 *) SRAMA15__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA15_LCD_COM_SEG            (* (reg8 *) SRAMA15__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA15_LCD_EN                 (* (reg8 *) SRAMA15__LCD_EN)
/* Slew Rate Control */
#define SRAMA15_SLW                    (* (reg8 *) SRAMA15__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA15_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA15__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA15_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA15__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA15_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA15__PRTDSI__OE_SEL0) 
#define SRAMA15_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA15__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA15_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA15__PRTDSI__OUT_SEL0) 
#define SRAMA15_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA15__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA15_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA15__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA15__SIO_CFG)
    #define SRAMA15_SIO_HYST_EN        (* (reg8 *) SRAMA15__SIO_HYST_EN)
    #define SRAMA15_SIO_REG_HIFREQ     (* (reg8 *) SRAMA15__SIO_REG_HIFREQ)
    #define SRAMA15_SIO_CFG            (* (reg8 *) SRAMA15__SIO_CFG)
    #define SRAMA15_SIO_DIFF           (* (reg8 *) SRAMA15__SIO_DIFF)
#endif /* (SRAMA15__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA15__INTSTAT)
    #define SRAMA15_INTSTAT            (* (reg8 *) SRAMA15__INTSTAT)
    #define SRAMA15_SNAP               (* (reg8 *) SRAMA15__SNAP)
    
	#define SRAMA15_0_INTTYPE_REG 		(* (reg8 *) SRAMA15__0__INTTYPE)
#endif /* (SRAMA15__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA15_H */


/* [] END OF FILE */
