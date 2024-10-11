/*******************************************************************************
* File Name: CPUA8.h  
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

#if !defined(CY_PINS_CPUA8_H) /* Pins CPUA8_H */
#define CY_PINS_CPUA8_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA8_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA8__PORT == 15 && ((CPUA8__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA8_Write(uint8 value);
void    CPUA8_SetDriveMode(uint8 mode);
uint8   CPUA8_ReadDataReg(void);
uint8   CPUA8_Read(void);
void    CPUA8_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA8_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA8_SetDriveMode() function.
     *  @{
     */
        #define CPUA8_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA8_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA8_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA8_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA8_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA8_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA8_DM_STRONG          PIN_DM_STRONG
        #define CPUA8_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA8_MASK               CPUA8__MASK
#define CPUA8_SHIFT              CPUA8__SHIFT
#define CPUA8_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA8__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA8_SetInterruptMode() function.
     *  @{
     */
        #define CPUA8_INTR_NONE      (uint16)(0x0000u)
        #define CPUA8_INTR_RISING    (uint16)(0x0001u)
        #define CPUA8_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA8_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA8_INTR_MASK      (0x01u) 
#endif /* (CPUA8__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA8_PS                     (* (reg8 *) CPUA8__PS)
/* Data Register */
#define CPUA8_DR                     (* (reg8 *) CPUA8__DR)
/* Port Number */
#define CPUA8_PRT_NUM                (* (reg8 *) CPUA8__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA8_AG                     (* (reg8 *) CPUA8__AG)                       
/* Analog MUX bux enable */
#define CPUA8_AMUX                   (* (reg8 *) CPUA8__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA8_BIE                    (* (reg8 *) CPUA8__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA8_BIT_MASK               (* (reg8 *) CPUA8__BIT_MASK)
/* Bypass Enable */
#define CPUA8_BYP                    (* (reg8 *) CPUA8__BYP)
/* Port wide control signals */                                                   
#define CPUA8_CTL                    (* (reg8 *) CPUA8__CTL)
/* Drive Modes */
#define CPUA8_DM0                    (* (reg8 *) CPUA8__DM0) 
#define CPUA8_DM1                    (* (reg8 *) CPUA8__DM1)
#define CPUA8_DM2                    (* (reg8 *) CPUA8__DM2) 
/* Input Buffer Disable Override */
#define CPUA8_INP_DIS                (* (reg8 *) CPUA8__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA8_LCD_COM_SEG            (* (reg8 *) CPUA8__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA8_LCD_EN                 (* (reg8 *) CPUA8__LCD_EN)
/* Slew Rate Control */
#define CPUA8_SLW                    (* (reg8 *) CPUA8__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA8_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA8__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA8_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA8__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA8_PRTDSI__OE_SEL0        (* (reg8 *) CPUA8__PRTDSI__OE_SEL0) 
#define CPUA8_PRTDSI__OE_SEL1        (* (reg8 *) CPUA8__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA8_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA8__PRTDSI__OUT_SEL0) 
#define CPUA8_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA8__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA8_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA8__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA8__SIO_CFG)
    #define CPUA8_SIO_HYST_EN        (* (reg8 *) CPUA8__SIO_HYST_EN)
    #define CPUA8_SIO_REG_HIFREQ     (* (reg8 *) CPUA8__SIO_REG_HIFREQ)
    #define CPUA8_SIO_CFG            (* (reg8 *) CPUA8__SIO_CFG)
    #define CPUA8_SIO_DIFF           (* (reg8 *) CPUA8__SIO_DIFF)
#endif /* (CPUA8__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA8__INTSTAT)
    #define CPUA8_INTSTAT            (* (reg8 *) CPUA8__INTSTAT)
    #define CPUA8_SNAP               (* (reg8 *) CPUA8__SNAP)
    
	#define CPUA8_0_INTTYPE_REG 		(* (reg8 *) CPUA8__0__INTTYPE)
#endif /* (CPUA8__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA8_H */


/* [] END OF FILE */
