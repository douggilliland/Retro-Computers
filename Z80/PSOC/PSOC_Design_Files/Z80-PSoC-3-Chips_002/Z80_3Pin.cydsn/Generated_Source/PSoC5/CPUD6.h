/*******************************************************************************
* File Name: CPUD6.h  
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

#if !defined(CY_PINS_CPUD6_H) /* Pins CPUD6_H */
#define CY_PINS_CPUD6_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD6_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD6__PORT == 15 && ((CPUD6__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD6_Write(uint8 value);
void    CPUD6_SetDriveMode(uint8 mode);
uint8   CPUD6_ReadDataReg(void);
uint8   CPUD6_Read(void);
void    CPUD6_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD6_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD6_SetDriveMode() function.
     *  @{
     */
        #define CPUD6_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD6_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD6_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD6_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD6_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD6_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD6_DM_STRONG          PIN_DM_STRONG
        #define CPUD6_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD6_MASK               CPUD6__MASK
#define CPUD6_SHIFT              CPUD6__SHIFT
#define CPUD6_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD6__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD6_SetInterruptMode() function.
     *  @{
     */
        #define CPUD6_INTR_NONE      (uint16)(0x0000u)
        #define CPUD6_INTR_RISING    (uint16)(0x0001u)
        #define CPUD6_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD6_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD6_INTR_MASK      (0x01u) 
#endif /* (CPUD6__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD6_PS                     (* (reg8 *) CPUD6__PS)
/* Data Register */
#define CPUD6_DR                     (* (reg8 *) CPUD6__DR)
/* Port Number */
#define CPUD6_PRT_NUM                (* (reg8 *) CPUD6__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD6_AG                     (* (reg8 *) CPUD6__AG)                       
/* Analog MUX bux enable */
#define CPUD6_AMUX                   (* (reg8 *) CPUD6__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD6_BIE                    (* (reg8 *) CPUD6__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD6_BIT_MASK               (* (reg8 *) CPUD6__BIT_MASK)
/* Bypass Enable */
#define CPUD6_BYP                    (* (reg8 *) CPUD6__BYP)
/* Port wide control signals */                                                   
#define CPUD6_CTL                    (* (reg8 *) CPUD6__CTL)
/* Drive Modes */
#define CPUD6_DM0                    (* (reg8 *) CPUD6__DM0) 
#define CPUD6_DM1                    (* (reg8 *) CPUD6__DM1)
#define CPUD6_DM2                    (* (reg8 *) CPUD6__DM2) 
/* Input Buffer Disable Override */
#define CPUD6_INP_DIS                (* (reg8 *) CPUD6__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD6_LCD_COM_SEG            (* (reg8 *) CPUD6__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD6_LCD_EN                 (* (reg8 *) CPUD6__LCD_EN)
/* Slew Rate Control */
#define CPUD6_SLW                    (* (reg8 *) CPUD6__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD6_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD6__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD6_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD6__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD6_PRTDSI__OE_SEL0        (* (reg8 *) CPUD6__PRTDSI__OE_SEL0) 
#define CPUD6_PRTDSI__OE_SEL1        (* (reg8 *) CPUD6__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD6_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD6__PRTDSI__OUT_SEL0) 
#define CPUD6_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD6__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD6_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD6__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD6__SIO_CFG)
    #define CPUD6_SIO_HYST_EN        (* (reg8 *) CPUD6__SIO_HYST_EN)
    #define CPUD6_SIO_REG_HIFREQ     (* (reg8 *) CPUD6__SIO_REG_HIFREQ)
    #define CPUD6_SIO_CFG            (* (reg8 *) CPUD6__SIO_CFG)
    #define CPUD6_SIO_DIFF           (* (reg8 *) CPUD6__SIO_DIFF)
#endif /* (CPUD6__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD6__INTSTAT)
    #define CPUD6_INTSTAT            (* (reg8 *) CPUD6__INTSTAT)
    #define CPUD6_SNAP               (* (reg8 *) CPUD6__SNAP)
    
	#define CPUD6_0_INTTYPE_REG 		(* (reg8 *) CPUD6__0__INTTYPE)
#endif /* (CPUD6__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD6_H */


/* [] END OF FILE */
