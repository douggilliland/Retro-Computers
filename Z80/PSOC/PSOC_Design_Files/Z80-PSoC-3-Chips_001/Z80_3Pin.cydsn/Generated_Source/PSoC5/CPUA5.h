/*******************************************************************************
* File Name: CPUA5.h  
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

#if !defined(CY_PINS_CPUA5_H) /* Pins CPUA5_H */
#define CY_PINS_CPUA5_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA5_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA5__PORT == 15 && ((CPUA5__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA5_Write(uint8 value);
void    CPUA5_SetDriveMode(uint8 mode);
uint8   CPUA5_ReadDataReg(void);
uint8   CPUA5_Read(void);
void    CPUA5_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA5_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA5_SetDriveMode() function.
     *  @{
     */
        #define CPUA5_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA5_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA5_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA5_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA5_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA5_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA5_DM_STRONG          PIN_DM_STRONG
        #define CPUA5_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA5_MASK               CPUA5__MASK
#define CPUA5_SHIFT              CPUA5__SHIFT
#define CPUA5_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA5__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA5_SetInterruptMode() function.
     *  @{
     */
        #define CPUA5_INTR_NONE      (uint16)(0x0000u)
        #define CPUA5_INTR_RISING    (uint16)(0x0001u)
        #define CPUA5_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA5_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA5_INTR_MASK      (0x01u) 
#endif /* (CPUA5__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA5_PS                     (* (reg8 *) CPUA5__PS)
/* Data Register */
#define CPUA5_DR                     (* (reg8 *) CPUA5__DR)
/* Port Number */
#define CPUA5_PRT_NUM                (* (reg8 *) CPUA5__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA5_AG                     (* (reg8 *) CPUA5__AG)                       
/* Analog MUX bux enable */
#define CPUA5_AMUX                   (* (reg8 *) CPUA5__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA5_BIE                    (* (reg8 *) CPUA5__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA5_BIT_MASK               (* (reg8 *) CPUA5__BIT_MASK)
/* Bypass Enable */
#define CPUA5_BYP                    (* (reg8 *) CPUA5__BYP)
/* Port wide control signals */                                                   
#define CPUA5_CTL                    (* (reg8 *) CPUA5__CTL)
/* Drive Modes */
#define CPUA5_DM0                    (* (reg8 *) CPUA5__DM0) 
#define CPUA5_DM1                    (* (reg8 *) CPUA5__DM1)
#define CPUA5_DM2                    (* (reg8 *) CPUA5__DM2) 
/* Input Buffer Disable Override */
#define CPUA5_INP_DIS                (* (reg8 *) CPUA5__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA5_LCD_COM_SEG            (* (reg8 *) CPUA5__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA5_LCD_EN                 (* (reg8 *) CPUA5__LCD_EN)
/* Slew Rate Control */
#define CPUA5_SLW                    (* (reg8 *) CPUA5__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA5_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA5__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA5_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA5__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA5_PRTDSI__OE_SEL0        (* (reg8 *) CPUA5__PRTDSI__OE_SEL0) 
#define CPUA5_PRTDSI__OE_SEL1        (* (reg8 *) CPUA5__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA5_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA5__PRTDSI__OUT_SEL0) 
#define CPUA5_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA5__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA5_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA5__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA5__SIO_CFG)
    #define CPUA5_SIO_HYST_EN        (* (reg8 *) CPUA5__SIO_HYST_EN)
    #define CPUA5_SIO_REG_HIFREQ     (* (reg8 *) CPUA5__SIO_REG_HIFREQ)
    #define CPUA5_SIO_CFG            (* (reg8 *) CPUA5__SIO_CFG)
    #define CPUA5_SIO_DIFF           (* (reg8 *) CPUA5__SIO_DIFF)
#endif /* (CPUA5__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA5__INTSTAT)
    #define CPUA5_INTSTAT            (* (reg8 *) CPUA5__INTSTAT)
    #define CPUA5_SNAP               (* (reg8 *) CPUA5__SNAP)
    
	#define CPUA5_0_INTTYPE_REG 		(* (reg8 *) CPUA5__0__INTTYPE)
#endif /* (CPUA5__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA5_H */


/* [] END OF FILE */
