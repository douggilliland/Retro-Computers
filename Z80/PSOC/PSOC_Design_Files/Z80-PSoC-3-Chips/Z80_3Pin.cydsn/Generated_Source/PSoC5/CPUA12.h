/*******************************************************************************
* File Name: CPUA12.h  
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

#if !defined(CY_PINS_CPUA12_H) /* Pins CPUA12_H */
#define CY_PINS_CPUA12_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA12_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA12__PORT == 15 && ((CPUA12__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA12_Write(uint8 value);
void    CPUA12_SetDriveMode(uint8 mode);
uint8   CPUA12_ReadDataReg(void);
uint8   CPUA12_Read(void);
void    CPUA12_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA12_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA12_SetDriveMode() function.
     *  @{
     */
        #define CPUA12_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA12_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA12_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA12_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA12_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA12_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA12_DM_STRONG          PIN_DM_STRONG
        #define CPUA12_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA12_MASK               CPUA12__MASK
#define CPUA12_SHIFT              CPUA12__SHIFT
#define CPUA12_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA12__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA12_SetInterruptMode() function.
     *  @{
     */
        #define CPUA12_INTR_NONE      (uint16)(0x0000u)
        #define CPUA12_INTR_RISING    (uint16)(0x0001u)
        #define CPUA12_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA12_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA12_INTR_MASK      (0x01u) 
#endif /* (CPUA12__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA12_PS                     (* (reg8 *) CPUA12__PS)
/* Data Register */
#define CPUA12_DR                     (* (reg8 *) CPUA12__DR)
/* Port Number */
#define CPUA12_PRT_NUM                (* (reg8 *) CPUA12__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA12_AG                     (* (reg8 *) CPUA12__AG)                       
/* Analog MUX bux enable */
#define CPUA12_AMUX                   (* (reg8 *) CPUA12__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA12_BIE                    (* (reg8 *) CPUA12__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA12_BIT_MASK               (* (reg8 *) CPUA12__BIT_MASK)
/* Bypass Enable */
#define CPUA12_BYP                    (* (reg8 *) CPUA12__BYP)
/* Port wide control signals */                                                   
#define CPUA12_CTL                    (* (reg8 *) CPUA12__CTL)
/* Drive Modes */
#define CPUA12_DM0                    (* (reg8 *) CPUA12__DM0) 
#define CPUA12_DM1                    (* (reg8 *) CPUA12__DM1)
#define CPUA12_DM2                    (* (reg8 *) CPUA12__DM2) 
/* Input Buffer Disable Override */
#define CPUA12_INP_DIS                (* (reg8 *) CPUA12__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA12_LCD_COM_SEG            (* (reg8 *) CPUA12__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA12_LCD_EN                 (* (reg8 *) CPUA12__LCD_EN)
/* Slew Rate Control */
#define CPUA12_SLW                    (* (reg8 *) CPUA12__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA12_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA12__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA12_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA12__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA12_PRTDSI__OE_SEL0        (* (reg8 *) CPUA12__PRTDSI__OE_SEL0) 
#define CPUA12_PRTDSI__OE_SEL1        (* (reg8 *) CPUA12__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA12_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA12__PRTDSI__OUT_SEL0) 
#define CPUA12_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA12__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA12_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA12__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA12__SIO_CFG)
    #define CPUA12_SIO_HYST_EN        (* (reg8 *) CPUA12__SIO_HYST_EN)
    #define CPUA12_SIO_REG_HIFREQ     (* (reg8 *) CPUA12__SIO_REG_HIFREQ)
    #define CPUA12_SIO_CFG            (* (reg8 *) CPUA12__SIO_CFG)
    #define CPUA12_SIO_DIFF           (* (reg8 *) CPUA12__SIO_DIFF)
#endif /* (CPUA12__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA12__INTSTAT)
    #define CPUA12_INTSTAT            (* (reg8 *) CPUA12__INTSTAT)
    #define CPUA12_SNAP               (* (reg8 *) CPUA12__SNAP)
    
	#define CPUA12_0_INTTYPE_REG 		(* (reg8 *) CPUA12__0__INTTYPE)
#endif /* (CPUA12__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA12_H */


/* [] END OF FILE */
