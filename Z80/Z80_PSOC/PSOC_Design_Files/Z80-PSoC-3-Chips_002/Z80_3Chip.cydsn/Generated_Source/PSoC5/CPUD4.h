/*******************************************************************************
* File Name: CPUD4.h  
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

#if !defined(CY_PINS_CPUD4_H) /* Pins CPUD4_H */
#define CY_PINS_CPUD4_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD4_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD4__PORT == 15 && ((CPUD4__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD4_Write(uint8 value);
void    CPUD4_SetDriveMode(uint8 mode);
uint8   CPUD4_ReadDataReg(void);
uint8   CPUD4_Read(void);
void    CPUD4_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD4_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD4_SetDriveMode() function.
     *  @{
     */
        #define CPUD4_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD4_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD4_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD4_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD4_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD4_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD4_DM_STRONG          PIN_DM_STRONG
        #define CPUD4_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD4_MASK               CPUD4__MASK
#define CPUD4_SHIFT              CPUD4__SHIFT
#define CPUD4_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD4__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD4_SetInterruptMode() function.
     *  @{
     */
        #define CPUD4_INTR_NONE      (uint16)(0x0000u)
        #define CPUD4_INTR_RISING    (uint16)(0x0001u)
        #define CPUD4_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD4_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD4_INTR_MASK      (0x01u) 
#endif /* (CPUD4__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD4_PS                     (* (reg8 *) CPUD4__PS)
/* Data Register */
#define CPUD4_DR                     (* (reg8 *) CPUD4__DR)
/* Port Number */
#define CPUD4_PRT_NUM                (* (reg8 *) CPUD4__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD4_AG                     (* (reg8 *) CPUD4__AG)                       
/* Analog MUX bux enable */
#define CPUD4_AMUX                   (* (reg8 *) CPUD4__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD4_BIE                    (* (reg8 *) CPUD4__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD4_BIT_MASK               (* (reg8 *) CPUD4__BIT_MASK)
/* Bypass Enable */
#define CPUD4_BYP                    (* (reg8 *) CPUD4__BYP)
/* Port wide control signals */                                                   
#define CPUD4_CTL                    (* (reg8 *) CPUD4__CTL)
/* Drive Modes */
#define CPUD4_DM0                    (* (reg8 *) CPUD4__DM0) 
#define CPUD4_DM1                    (* (reg8 *) CPUD4__DM1)
#define CPUD4_DM2                    (* (reg8 *) CPUD4__DM2) 
/* Input Buffer Disable Override */
#define CPUD4_INP_DIS                (* (reg8 *) CPUD4__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD4_LCD_COM_SEG            (* (reg8 *) CPUD4__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD4_LCD_EN                 (* (reg8 *) CPUD4__LCD_EN)
/* Slew Rate Control */
#define CPUD4_SLW                    (* (reg8 *) CPUD4__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD4_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD4__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD4_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD4__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD4_PRTDSI__OE_SEL0        (* (reg8 *) CPUD4__PRTDSI__OE_SEL0) 
#define CPUD4_PRTDSI__OE_SEL1        (* (reg8 *) CPUD4__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD4_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD4__PRTDSI__OUT_SEL0) 
#define CPUD4_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD4__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD4_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD4__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD4__SIO_CFG)
    #define CPUD4_SIO_HYST_EN        (* (reg8 *) CPUD4__SIO_HYST_EN)
    #define CPUD4_SIO_REG_HIFREQ     (* (reg8 *) CPUD4__SIO_REG_HIFREQ)
    #define CPUD4_SIO_CFG            (* (reg8 *) CPUD4__SIO_CFG)
    #define CPUD4_SIO_DIFF           (* (reg8 *) CPUD4__SIO_DIFF)
#endif /* (CPUD4__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD4__INTSTAT)
    #define CPUD4_INTSTAT            (* (reg8 *) CPUD4__INTSTAT)
    #define CPUD4_SNAP               (* (reg8 *) CPUD4__SNAP)
    
	#define CPUD4_0_INTTYPE_REG 		(* (reg8 *) CPUD4__0__INTTYPE)
#endif /* (CPUD4__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD4_H */


/* [] END OF FILE */
