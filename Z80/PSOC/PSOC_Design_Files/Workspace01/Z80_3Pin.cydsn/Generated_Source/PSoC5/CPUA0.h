/*******************************************************************************
* File Name: CPUA0.h  
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

#if !defined(CY_PINS_CPUA0_H) /* Pins CPUA0_H */
#define CY_PINS_CPUA0_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA0_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA0__PORT == 15 && ((CPUA0__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA0_Write(uint8 value);
void    CPUA0_SetDriveMode(uint8 mode);
uint8   CPUA0_ReadDataReg(void);
uint8   CPUA0_Read(void);
void    CPUA0_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA0_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA0_SetDriveMode() function.
     *  @{
     */
        #define CPUA0_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA0_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA0_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA0_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA0_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA0_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA0_DM_STRONG          PIN_DM_STRONG
        #define CPUA0_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA0_MASK               CPUA0__MASK
#define CPUA0_SHIFT              CPUA0__SHIFT
#define CPUA0_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA0__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA0_SetInterruptMode() function.
     *  @{
     */
        #define CPUA0_INTR_NONE      (uint16)(0x0000u)
        #define CPUA0_INTR_RISING    (uint16)(0x0001u)
        #define CPUA0_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA0_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA0_INTR_MASK      (0x01u) 
#endif /* (CPUA0__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA0_PS                     (* (reg8 *) CPUA0__PS)
/* Data Register */
#define CPUA0_DR                     (* (reg8 *) CPUA0__DR)
/* Port Number */
#define CPUA0_PRT_NUM                (* (reg8 *) CPUA0__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA0_AG                     (* (reg8 *) CPUA0__AG)                       
/* Analog MUX bux enable */
#define CPUA0_AMUX                   (* (reg8 *) CPUA0__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA0_BIE                    (* (reg8 *) CPUA0__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA0_BIT_MASK               (* (reg8 *) CPUA0__BIT_MASK)
/* Bypass Enable */
#define CPUA0_BYP                    (* (reg8 *) CPUA0__BYP)
/* Port wide control signals */                                                   
#define CPUA0_CTL                    (* (reg8 *) CPUA0__CTL)
/* Drive Modes */
#define CPUA0_DM0                    (* (reg8 *) CPUA0__DM0) 
#define CPUA0_DM1                    (* (reg8 *) CPUA0__DM1)
#define CPUA0_DM2                    (* (reg8 *) CPUA0__DM2) 
/* Input Buffer Disable Override */
#define CPUA0_INP_DIS                (* (reg8 *) CPUA0__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA0_LCD_COM_SEG            (* (reg8 *) CPUA0__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA0_LCD_EN                 (* (reg8 *) CPUA0__LCD_EN)
/* Slew Rate Control */
#define CPUA0_SLW                    (* (reg8 *) CPUA0__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA0_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA0__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA0_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA0__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA0_PRTDSI__OE_SEL0        (* (reg8 *) CPUA0__PRTDSI__OE_SEL0) 
#define CPUA0_PRTDSI__OE_SEL1        (* (reg8 *) CPUA0__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA0_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA0__PRTDSI__OUT_SEL0) 
#define CPUA0_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA0__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA0_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA0__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA0__SIO_CFG)
    #define CPUA0_SIO_HYST_EN        (* (reg8 *) CPUA0__SIO_HYST_EN)
    #define CPUA0_SIO_REG_HIFREQ     (* (reg8 *) CPUA0__SIO_REG_HIFREQ)
    #define CPUA0_SIO_CFG            (* (reg8 *) CPUA0__SIO_CFG)
    #define CPUA0_SIO_DIFF           (* (reg8 *) CPUA0__SIO_DIFF)
#endif /* (CPUA0__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA0__INTSTAT)
    #define CPUA0_INTSTAT            (* (reg8 *) CPUA0__INTSTAT)
    #define CPUA0_SNAP               (* (reg8 *) CPUA0__SNAP)
    
	#define CPUA0_0_INTTYPE_REG 		(* (reg8 *) CPUA0__0__INTTYPE)
#endif /* (CPUA0__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA0_H */


/* [] END OF FILE */
