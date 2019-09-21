/*******************************************************************************
* File Name: SRAMA17.h  
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

#if !defined(CY_PINS_SRAMA17_H) /* Pins SRAMA17_H */
#define CY_PINS_SRAMA17_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMA17_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMA17__PORT == 15 && ((SRAMA17__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMA17_Write(uint8 value);
void    SRAMA17_SetDriveMode(uint8 mode);
uint8   SRAMA17_ReadDataReg(void);
uint8   SRAMA17_Read(void);
void    SRAMA17_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMA17_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMA17_SetDriveMode() function.
     *  @{
     */
        #define SRAMA17_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMA17_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMA17_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMA17_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMA17_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMA17_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMA17_DM_STRONG          PIN_DM_STRONG
        #define SRAMA17_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMA17_MASK               SRAMA17__MASK
#define SRAMA17_SHIFT              SRAMA17__SHIFT
#define SRAMA17_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMA17__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMA17_SetInterruptMode() function.
     *  @{
     */
        #define SRAMA17_INTR_NONE      (uint16)(0x0000u)
        #define SRAMA17_INTR_RISING    (uint16)(0x0001u)
        #define SRAMA17_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMA17_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMA17_INTR_MASK      (0x01u) 
#endif /* (SRAMA17__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMA17_PS                     (* (reg8 *) SRAMA17__PS)
/* Data Register */
#define SRAMA17_DR                     (* (reg8 *) SRAMA17__DR)
/* Port Number */
#define SRAMA17_PRT_NUM                (* (reg8 *) SRAMA17__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMA17_AG                     (* (reg8 *) SRAMA17__AG)                       
/* Analog MUX bux enable */
#define SRAMA17_AMUX                   (* (reg8 *) SRAMA17__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMA17_BIE                    (* (reg8 *) SRAMA17__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMA17_BIT_MASK               (* (reg8 *) SRAMA17__BIT_MASK)
/* Bypass Enable */
#define SRAMA17_BYP                    (* (reg8 *) SRAMA17__BYP)
/* Port wide control signals */                                                   
#define SRAMA17_CTL                    (* (reg8 *) SRAMA17__CTL)
/* Drive Modes */
#define SRAMA17_DM0                    (* (reg8 *) SRAMA17__DM0) 
#define SRAMA17_DM1                    (* (reg8 *) SRAMA17__DM1)
#define SRAMA17_DM2                    (* (reg8 *) SRAMA17__DM2) 
/* Input Buffer Disable Override */
#define SRAMA17_INP_DIS                (* (reg8 *) SRAMA17__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMA17_LCD_COM_SEG            (* (reg8 *) SRAMA17__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMA17_LCD_EN                 (* (reg8 *) SRAMA17__LCD_EN)
/* Slew Rate Control */
#define SRAMA17_SLW                    (* (reg8 *) SRAMA17__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMA17_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMA17__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMA17_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMA17__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMA17_PRTDSI__OE_SEL0        (* (reg8 *) SRAMA17__PRTDSI__OE_SEL0) 
#define SRAMA17_PRTDSI__OE_SEL1        (* (reg8 *) SRAMA17__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMA17_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMA17__PRTDSI__OUT_SEL0) 
#define SRAMA17_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMA17__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMA17_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMA17__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMA17__SIO_CFG)
    #define SRAMA17_SIO_HYST_EN        (* (reg8 *) SRAMA17__SIO_HYST_EN)
    #define SRAMA17_SIO_REG_HIFREQ     (* (reg8 *) SRAMA17__SIO_REG_HIFREQ)
    #define SRAMA17_SIO_CFG            (* (reg8 *) SRAMA17__SIO_CFG)
    #define SRAMA17_SIO_DIFF           (* (reg8 *) SRAMA17__SIO_DIFF)
#endif /* (SRAMA17__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMA17__INTSTAT)
    #define SRAMA17_INTSTAT            (* (reg8 *) SRAMA17__INTSTAT)
    #define SRAMA17_SNAP               (* (reg8 *) SRAMA17__SNAP)
    
	#define SRAMA17_0_INTTYPE_REG 		(* (reg8 *) SRAMA17__0__INTTYPE)
#endif /* (SRAMA17__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMA17_H */


/* [] END OF FILE */
