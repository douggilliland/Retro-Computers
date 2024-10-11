/*******************************************************************************
* File Name: CPUD5.h  
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

#if !defined(CY_PINS_CPUD5_H) /* Pins CPUD5_H */
#define CY_PINS_CPUD5_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD5_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD5__PORT == 15 && ((CPUD5__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD5_Write(uint8 value);
void    CPUD5_SetDriveMode(uint8 mode);
uint8   CPUD5_ReadDataReg(void);
uint8   CPUD5_Read(void);
void    CPUD5_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD5_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD5_SetDriveMode() function.
     *  @{
     */
        #define CPUD5_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD5_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD5_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD5_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD5_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD5_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD5_DM_STRONG          PIN_DM_STRONG
        #define CPUD5_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD5_MASK               CPUD5__MASK
#define CPUD5_SHIFT              CPUD5__SHIFT
#define CPUD5_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD5__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD5_SetInterruptMode() function.
     *  @{
     */
        #define CPUD5_INTR_NONE      (uint16)(0x0000u)
        #define CPUD5_INTR_RISING    (uint16)(0x0001u)
        #define CPUD5_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD5_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD5_INTR_MASK      (0x01u) 
#endif /* (CPUD5__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD5_PS                     (* (reg8 *) CPUD5__PS)
/* Data Register */
#define CPUD5_DR                     (* (reg8 *) CPUD5__DR)
/* Port Number */
#define CPUD5_PRT_NUM                (* (reg8 *) CPUD5__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD5_AG                     (* (reg8 *) CPUD5__AG)                       
/* Analog MUX bux enable */
#define CPUD5_AMUX                   (* (reg8 *) CPUD5__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD5_BIE                    (* (reg8 *) CPUD5__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD5_BIT_MASK               (* (reg8 *) CPUD5__BIT_MASK)
/* Bypass Enable */
#define CPUD5_BYP                    (* (reg8 *) CPUD5__BYP)
/* Port wide control signals */                                                   
#define CPUD5_CTL                    (* (reg8 *) CPUD5__CTL)
/* Drive Modes */
#define CPUD5_DM0                    (* (reg8 *) CPUD5__DM0) 
#define CPUD5_DM1                    (* (reg8 *) CPUD5__DM1)
#define CPUD5_DM2                    (* (reg8 *) CPUD5__DM2) 
/* Input Buffer Disable Override */
#define CPUD5_INP_DIS                (* (reg8 *) CPUD5__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD5_LCD_COM_SEG            (* (reg8 *) CPUD5__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD5_LCD_EN                 (* (reg8 *) CPUD5__LCD_EN)
/* Slew Rate Control */
#define CPUD5_SLW                    (* (reg8 *) CPUD5__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD5_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD5__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD5_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD5__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD5_PRTDSI__OE_SEL0        (* (reg8 *) CPUD5__PRTDSI__OE_SEL0) 
#define CPUD5_PRTDSI__OE_SEL1        (* (reg8 *) CPUD5__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD5_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD5__PRTDSI__OUT_SEL0) 
#define CPUD5_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD5__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD5_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD5__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD5__SIO_CFG)
    #define CPUD5_SIO_HYST_EN        (* (reg8 *) CPUD5__SIO_HYST_EN)
    #define CPUD5_SIO_REG_HIFREQ     (* (reg8 *) CPUD5__SIO_REG_HIFREQ)
    #define CPUD5_SIO_CFG            (* (reg8 *) CPUD5__SIO_CFG)
    #define CPUD5_SIO_DIFF           (* (reg8 *) CPUD5__SIO_DIFF)
#endif /* (CPUD5__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD5__INTSTAT)
    #define CPUD5_INTSTAT            (* (reg8 *) CPUD5__INTSTAT)
    #define CPUD5_SNAP               (* (reg8 *) CPUD5__SNAP)
    
	#define CPUD5_0_INTTYPE_REG 		(* (reg8 *) CPUD5__0__INTTYPE)
#endif /* (CPUD5__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD5_H */


/* [] END OF FILE */
