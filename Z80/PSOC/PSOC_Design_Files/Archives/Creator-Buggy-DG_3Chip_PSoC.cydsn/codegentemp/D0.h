/*******************************************************************************
* File Name: D0.h  
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

#if !defined(CY_PINS_D0_H) /* Pins D0_H */
#define CY_PINS_D0_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "D0_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 D0__PORT == 15 && ((D0__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    D0_Write(uint8 value);
void    D0_SetDriveMode(uint8 mode);
uint8   D0_ReadDataReg(void);
uint8   D0_Read(void);
void    D0_SetInterruptMode(uint16 position, uint16 mode);
uint8   D0_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the D0_SetDriveMode() function.
     *  @{
     */
        #define D0_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define D0_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define D0_DM_RES_UP          PIN_DM_RES_UP
        #define D0_DM_RES_DWN         PIN_DM_RES_DWN
        #define D0_DM_OD_LO           PIN_DM_OD_LO
        #define D0_DM_OD_HI           PIN_DM_OD_HI
        #define D0_DM_STRONG          PIN_DM_STRONG
        #define D0_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define D0_MASK               D0__MASK
#define D0_SHIFT              D0__SHIFT
#define D0_WIDTH              1u

/* Interrupt constants */
#if defined(D0__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in D0_SetInterruptMode() function.
     *  @{
     */
        #define D0_INTR_NONE      (uint16)(0x0000u)
        #define D0_INTR_RISING    (uint16)(0x0001u)
        #define D0_INTR_FALLING   (uint16)(0x0002u)
        #define D0_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define D0_INTR_MASK      (0x01u) 
#endif /* (D0__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define D0_PS                     (* (reg8 *) D0__PS)
/* Data Register */
#define D0_DR                     (* (reg8 *) D0__DR)
/* Port Number */
#define D0_PRT_NUM                (* (reg8 *) D0__PRT) 
/* Connect to Analog Globals */                                                  
#define D0_AG                     (* (reg8 *) D0__AG)                       
/* Analog MUX bux enable */
#define D0_AMUX                   (* (reg8 *) D0__AMUX) 
/* Bidirectional Enable */                                                        
#define D0_BIE                    (* (reg8 *) D0__BIE)
/* Bit-mask for Aliased Register Access */
#define D0_BIT_MASK               (* (reg8 *) D0__BIT_MASK)
/* Bypass Enable */
#define D0_BYP                    (* (reg8 *) D0__BYP)
/* Port wide control signals */                                                   
#define D0_CTL                    (* (reg8 *) D0__CTL)
/* Drive Modes */
#define D0_DM0                    (* (reg8 *) D0__DM0) 
#define D0_DM1                    (* (reg8 *) D0__DM1)
#define D0_DM2                    (* (reg8 *) D0__DM2) 
/* Input Buffer Disable Override */
#define D0_INP_DIS                (* (reg8 *) D0__INP_DIS)
/* LCD Common or Segment Drive */
#define D0_LCD_COM_SEG            (* (reg8 *) D0__LCD_COM_SEG)
/* Enable Segment LCD */
#define D0_LCD_EN                 (* (reg8 *) D0__LCD_EN)
/* Slew Rate Control */
#define D0_SLW                    (* (reg8 *) D0__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define D0_PRTDSI__CAPS_SEL       (* (reg8 *) D0__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define D0_PRTDSI__DBL_SYNC_IN    (* (reg8 *) D0__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define D0_PRTDSI__OE_SEL0        (* (reg8 *) D0__PRTDSI__OE_SEL0) 
#define D0_PRTDSI__OE_SEL1        (* (reg8 *) D0__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define D0_PRTDSI__OUT_SEL0       (* (reg8 *) D0__PRTDSI__OUT_SEL0) 
#define D0_PRTDSI__OUT_SEL1       (* (reg8 *) D0__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define D0_PRTDSI__SYNC_OUT       (* (reg8 *) D0__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(D0__SIO_CFG)
    #define D0_SIO_HYST_EN        (* (reg8 *) D0__SIO_HYST_EN)
    #define D0_SIO_REG_HIFREQ     (* (reg8 *) D0__SIO_REG_HIFREQ)
    #define D0_SIO_CFG            (* (reg8 *) D0__SIO_CFG)
    #define D0_SIO_DIFF           (* (reg8 *) D0__SIO_DIFF)
#endif /* (D0__SIO_CFG) */

/* Interrupt Registers */
#if defined(D0__INTSTAT)
    #define D0_INTSTAT            (* (reg8 *) D0__INTSTAT)
    #define D0_SNAP               (* (reg8 *) D0__SNAP)
    
	#define D0_0_INTTYPE_REG 		(* (reg8 *) D0__0__INTTYPE)
#endif /* (D0__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_D0_H */


/* [] END OF FILE */
