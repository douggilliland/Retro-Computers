/*******************************************************************************
* File Name: Pin_12.h  
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

#if !defined(CY_PINS_Pin_12_H) /* Pins Pin_12_H */
#define CY_PINS_Pin_12_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "Pin_12_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 Pin_12__PORT == 15 && ((Pin_12__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    Pin_12_Write(uint8 value);
void    Pin_12_SetDriveMode(uint8 mode);
uint8   Pin_12_ReadDataReg(void);
uint8   Pin_12_Read(void);
void    Pin_12_SetInterruptMode(uint16 position, uint16 mode);
uint8   Pin_12_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the Pin_12_SetDriveMode() function.
     *  @{
     */
        #define Pin_12_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define Pin_12_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define Pin_12_DM_RES_UP          PIN_DM_RES_UP
        #define Pin_12_DM_RES_DWN         PIN_DM_RES_DWN
        #define Pin_12_DM_OD_LO           PIN_DM_OD_LO
        #define Pin_12_DM_OD_HI           PIN_DM_OD_HI
        #define Pin_12_DM_STRONG          PIN_DM_STRONG
        #define Pin_12_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define Pin_12_MASK               Pin_12__MASK
#define Pin_12_SHIFT              Pin_12__SHIFT
#define Pin_12_WIDTH              1u

/* Interrupt constants */
#if defined(Pin_12__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in Pin_12_SetInterruptMode() function.
     *  @{
     */
        #define Pin_12_INTR_NONE      (uint16)(0x0000u)
        #define Pin_12_INTR_RISING    (uint16)(0x0001u)
        #define Pin_12_INTR_FALLING   (uint16)(0x0002u)
        #define Pin_12_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define Pin_12_INTR_MASK      (0x01u) 
#endif /* (Pin_12__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define Pin_12_PS                     (* (reg8 *) Pin_12__PS)
/* Data Register */
#define Pin_12_DR                     (* (reg8 *) Pin_12__DR)
/* Port Number */
#define Pin_12_PRT_NUM                (* (reg8 *) Pin_12__PRT) 
/* Connect to Analog Globals */                                                  
#define Pin_12_AG                     (* (reg8 *) Pin_12__AG)                       
/* Analog MUX bux enable */
#define Pin_12_AMUX                   (* (reg8 *) Pin_12__AMUX) 
/* Bidirectional Enable */                                                        
#define Pin_12_BIE                    (* (reg8 *) Pin_12__BIE)
/* Bit-mask for Aliased Register Access */
#define Pin_12_BIT_MASK               (* (reg8 *) Pin_12__BIT_MASK)
/* Bypass Enable */
#define Pin_12_BYP                    (* (reg8 *) Pin_12__BYP)
/* Port wide control signals */                                                   
#define Pin_12_CTL                    (* (reg8 *) Pin_12__CTL)
/* Drive Modes */
#define Pin_12_DM0                    (* (reg8 *) Pin_12__DM0) 
#define Pin_12_DM1                    (* (reg8 *) Pin_12__DM1)
#define Pin_12_DM2                    (* (reg8 *) Pin_12__DM2) 
/* Input Buffer Disable Override */
#define Pin_12_INP_DIS                (* (reg8 *) Pin_12__INP_DIS)
/* LCD Common or Segment Drive */
#define Pin_12_LCD_COM_SEG            (* (reg8 *) Pin_12__LCD_COM_SEG)
/* Enable Segment LCD */
#define Pin_12_LCD_EN                 (* (reg8 *) Pin_12__LCD_EN)
/* Slew Rate Control */
#define Pin_12_SLW                    (* (reg8 *) Pin_12__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define Pin_12_PRTDSI__CAPS_SEL       (* (reg8 *) Pin_12__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define Pin_12_PRTDSI__DBL_SYNC_IN    (* (reg8 *) Pin_12__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define Pin_12_PRTDSI__OE_SEL0        (* (reg8 *) Pin_12__PRTDSI__OE_SEL0) 
#define Pin_12_PRTDSI__OE_SEL1        (* (reg8 *) Pin_12__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define Pin_12_PRTDSI__OUT_SEL0       (* (reg8 *) Pin_12__PRTDSI__OUT_SEL0) 
#define Pin_12_PRTDSI__OUT_SEL1       (* (reg8 *) Pin_12__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define Pin_12_PRTDSI__SYNC_OUT       (* (reg8 *) Pin_12__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(Pin_12__SIO_CFG)
    #define Pin_12_SIO_HYST_EN        (* (reg8 *) Pin_12__SIO_HYST_EN)
    #define Pin_12_SIO_REG_HIFREQ     (* (reg8 *) Pin_12__SIO_REG_HIFREQ)
    #define Pin_12_SIO_CFG            (* (reg8 *) Pin_12__SIO_CFG)
    #define Pin_12_SIO_DIFF           (* (reg8 *) Pin_12__SIO_DIFF)
#endif /* (Pin_12__SIO_CFG) */

/* Interrupt Registers */
#if defined(Pin_12__INTSTAT)
    #define Pin_12_INTSTAT            (* (reg8 *) Pin_12__INTSTAT)
    #define Pin_12_SNAP               (* (reg8 *) Pin_12__SNAP)
    
	#define Pin_12_0_INTTYPE_REG 		(* (reg8 *) Pin_12__0__INTTYPE)
#endif /* (Pin_12__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_Pin_12_H */


/* [] END OF FILE */
