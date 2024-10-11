/*******************************************************************************
* File Name: CPUA7.h  
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

#if !defined(CY_PINS_CPUA7_H) /* Pins CPUA7_H */
#define CY_PINS_CPUA7_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA7_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA7__PORT == 15 && ((CPUA7__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA7_Write(uint8 value);
void    CPUA7_SetDriveMode(uint8 mode);
uint8   CPUA7_ReadDataReg(void);
uint8   CPUA7_Read(void);
void    CPUA7_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA7_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA7_SetDriveMode() function.
     *  @{
     */
        #define CPUA7_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA7_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA7_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA7_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA7_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA7_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA7_DM_STRONG          PIN_DM_STRONG
        #define CPUA7_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA7_MASK               CPUA7__MASK
#define CPUA7_SHIFT              CPUA7__SHIFT
#define CPUA7_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA7__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA7_SetInterruptMode() function.
     *  @{
     */
        #define CPUA7_INTR_NONE      (uint16)(0x0000u)
        #define CPUA7_INTR_RISING    (uint16)(0x0001u)
        #define CPUA7_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA7_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA7_INTR_MASK      (0x01u) 
#endif /* (CPUA7__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA7_PS                     (* (reg8 *) CPUA7__PS)
/* Data Register */
#define CPUA7_DR                     (* (reg8 *) CPUA7__DR)
/* Port Number */
#define CPUA7_PRT_NUM                (* (reg8 *) CPUA7__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA7_AG                     (* (reg8 *) CPUA7__AG)                       
/* Analog MUX bux enable */
#define CPUA7_AMUX                   (* (reg8 *) CPUA7__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA7_BIE                    (* (reg8 *) CPUA7__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA7_BIT_MASK               (* (reg8 *) CPUA7__BIT_MASK)
/* Bypass Enable */
#define CPUA7_BYP                    (* (reg8 *) CPUA7__BYP)
/* Port wide control signals */                                                   
#define CPUA7_CTL                    (* (reg8 *) CPUA7__CTL)
/* Drive Modes */
#define CPUA7_DM0                    (* (reg8 *) CPUA7__DM0) 
#define CPUA7_DM1                    (* (reg8 *) CPUA7__DM1)
#define CPUA7_DM2                    (* (reg8 *) CPUA7__DM2) 
/* Input Buffer Disable Override */
#define CPUA7_INP_DIS                (* (reg8 *) CPUA7__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA7_LCD_COM_SEG            (* (reg8 *) CPUA7__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA7_LCD_EN                 (* (reg8 *) CPUA7__LCD_EN)
/* Slew Rate Control */
#define CPUA7_SLW                    (* (reg8 *) CPUA7__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA7_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA7__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA7_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA7__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA7_PRTDSI__OE_SEL0        (* (reg8 *) CPUA7__PRTDSI__OE_SEL0) 
#define CPUA7_PRTDSI__OE_SEL1        (* (reg8 *) CPUA7__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA7_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA7__PRTDSI__OUT_SEL0) 
#define CPUA7_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA7__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA7_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA7__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA7__SIO_CFG)
    #define CPUA7_SIO_HYST_EN        (* (reg8 *) CPUA7__SIO_HYST_EN)
    #define CPUA7_SIO_REG_HIFREQ     (* (reg8 *) CPUA7__SIO_REG_HIFREQ)
    #define CPUA7_SIO_CFG            (* (reg8 *) CPUA7__SIO_CFG)
    #define CPUA7_SIO_DIFF           (* (reg8 *) CPUA7__SIO_DIFF)
#endif /* (CPUA7__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA7__INTSTAT)
    #define CPUA7_INTSTAT            (* (reg8 *) CPUA7__INTSTAT)
    #define CPUA7_SNAP               (* (reg8 *) CPUA7__SNAP)
    
	#define CPUA7_0_INTTYPE_REG 		(* (reg8 *) CPUA7__0__INTTYPE)
#endif /* (CPUA7__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA7_H */


/* [] END OF FILE */
