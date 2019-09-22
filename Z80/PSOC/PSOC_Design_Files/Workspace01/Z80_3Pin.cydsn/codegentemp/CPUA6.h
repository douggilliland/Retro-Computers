/*******************************************************************************
* File Name: CPUA6.h  
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

#if !defined(CY_PINS_CPUA6_H) /* Pins CPUA6_H */
#define CY_PINS_CPUA6_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA6_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA6__PORT == 15 && ((CPUA6__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA6_Write(uint8 value);
void    CPUA6_SetDriveMode(uint8 mode);
uint8   CPUA6_ReadDataReg(void);
uint8   CPUA6_Read(void);
void    CPUA6_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA6_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA6_SetDriveMode() function.
     *  @{
     */
        #define CPUA6_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA6_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA6_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA6_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA6_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA6_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA6_DM_STRONG          PIN_DM_STRONG
        #define CPUA6_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA6_MASK               CPUA6__MASK
#define CPUA6_SHIFT              CPUA6__SHIFT
#define CPUA6_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA6__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA6_SetInterruptMode() function.
     *  @{
     */
        #define CPUA6_INTR_NONE      (uint16)(0x0000u)
        #define CPUA6_INTR_RISING    (uint16)(0x0001u)
        #define CPUA6_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA6_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA6_INTR_MASK      (0x01u) 
#endif /* (CPUA6__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA6_PS                     (* (reg8 *) CPUA6__PS)
/* Data Register */
#define CPUA6_DR                     (* (reg8 *) CPUA6__DR)
/* Port Number */
#define CPUA6_PRT_NUM                (* (reg8 *) CPUA6__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA6_AG                     (* (reg8 *) CPUA6__AG)                       
/* Analog MUX bux enable */
#define CPUA6_AMUX                   (* (reg8 *) CPUA6__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA6_BIE                    (* (reg8 *) CPUA6__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA6_BIT_MASK               (* (reg8 *) CPUA6__BIT_MASK)
/* Bypass Enable */
#define CPUA6_BYP                    (* (reg8 *) CPUA6__BYP)
/* Port wide control signals */                                                   
#define CPUA6_CTL                    (* (reg8 *) CPUA6__CTL)
/* Drive Modes */
#define CPUA6_DM0                    (* (reg8 *) CPUA6__DM0) 
#define CPUA6_DM1                    (* (reg8 *) CPUA6__DM1)
#define CPUA6_DM2                    (* (reg8 *) CPUA6__DM2) 
/* Input Buffer Disable Override */
#define CPUA6_INP_DIS                (* (reg8 *) CPUA6__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA6_LCD_COM_SEG            (* (reg8 *) CPUA6__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA6_LCD_EN                 (* (reg8 *) CPUA6__LCD_EN)
/* Slew Rate Control */
#define CPUA6_SLW                    (* (reg8 *) CPUA6__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA6_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA6__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA6_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA6__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA6_PRTDSI__OE_SEL0        (* (reg8 *) CPUA6__PRTDSI__OE_SEL0) 
#define CPUA6_PRTDSI__OE_SEL1        (* (reg8 *) CPUA6__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA6_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA6__PRTDSI__OUT_SEL0) 
#define CPUA6_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA6__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA6_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA6__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA6__SIO_CFG)
    #define CPUA6_SIO_HYST_EN        (* (reg8 *) CPUA6__SIO_HYST_EN)
    #define CPUA6_SIO_REG_HIFREQ     (* (reg8 *) CPUA6__SIO_REG_HIFREQ)
    #define CPUA6_SIO_CFG            (* (reg8 *) CPUA6__SIO_CFG)
    #define CPUA6_SIO_DIFF           (* (reg8 *) CPUA6__SIO_DIFF)
#endif /* (CPUA6__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA6__INTSTAT)
    #define CPUA6_INTSTAT            (* (reg8 *) CPUA6__INTSTAT)
    #define CPUA6_SNAP               (* (reg8 *) CPUA6__SNAP)
    
	#define CPUA6_0_INTTYPE_REG 		(* (reg8 *) CPUA6__0__INTTYPE)
#endif /* (CPUA6__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA6_H */


/* [] END OF FILE */
