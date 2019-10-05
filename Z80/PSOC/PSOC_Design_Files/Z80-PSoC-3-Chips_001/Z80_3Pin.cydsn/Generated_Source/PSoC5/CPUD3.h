/*******************************************************************************
* File Name: CPUD3.h  
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

#if !defined(CY_PINS_CPUD3_H) /* Pins CPUD3_H */
#define CY_PINS_CPUD3_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD3_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD3__PORT == 15 && ((CPUD3__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD3_Write(uint8 value);
void    CPUD3_SetDriveMode(uint8 mode);
uint8   CPUD3_ReadDataReg(void);
uint8   CPUD3_Read(void);
void    CPUD3_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD3_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD3_SetDriveMode() function.
     *  @{
     */
        #define CPUD3_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD3_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD3_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD3_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD3_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD3_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD3_DM_STRONG          PIN_DM_STRONG
        #define CPUD3_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD3_MASK               CPUD3__MASK
#define CPUD3_SHIFT              CPUD3__SHIFT
#define CPUD3_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD3__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD3_SetInterruptMode() function.
     *  @{
     */
        #define CPUD3_INTR_NONE      (uint16)(0x0000u)
        #define CPUD3_INTR_RISING    (uint16)(0x0001u)
        #define CPUD3_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD3_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD3_INTR_MASK      (0x01u) 
#endif /* (CPUD3__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD3_PS                     (* (reg8 *) CPUD3__PS)
/* Data Register */
#define CPUD3_DR                     (* (reg8 *) CPUD3__DR)
/* Port Number */
#define CPUD3_PRT_NUM                (* (reg8 *) CPUD3__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD3_AG                     (* (reg8 *) CPUD3__AG)                       
/* Analog MUX bux enable */
#define CPUD3_AMUX                   (* (reg8 *) CPUD3__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD3_BIE                    (* (reg8 *) CPUD3__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD3_BIT_MASK               (* (reg8 *) CPUD3__BIT_MASK)
/* Bypass Enable */
#define CPUD3_BYP                    (* (reg8 *) CPUD3__BYP)
/* Port wide control signals */                                                   
#define CPUD3_CTL                    (* (reg8 *) CPUD3__CTL)
/* Drive Modes */
#define CPUD3_DM0                    (* (reg8 *) CPUD3__DM0) 
#define CPUD3_DM1                    (* (reg8 *) CPUD3__DM1)
#define CPUD3_DM2                    (* (reg8 *) CPUD3__DM2) 
/* Input Buffer Disable Override */
#define CPUD3_INP_DIS                (* (reg8 *) CPUD3__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD3_LCD_COM_SEG            (* (reg8 *) CPUD3__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD3_LCD_EN                 (* (reg8 *) CPUD3__LCD_EN)
/* Slew Rate Control */
#define CPUD3_SLW                    (* (reg8 *) CPUD3__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD3_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD3__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD3_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD3__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD3_PRTDSI__OE_SEL0        (* (reg8 *) CPUD3__PRTDSI__OE_SEL0) 
#define CPUD3_PRTDSI__OE_SEL1        (* (reg8 *) CPUD3__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD3_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD3__PRTDSI__OUT_SEL0) 
#define CPUD3_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD3__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD3_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD3__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD3__SIO_CFG)
    #define CPUD3_SIO_HYST_EN        (* (reg8 *) CPUD3__SIO_HYST_EN)
    #define CPUD3_SIO_REG_HIFREQ     (* (reg8 *) CPUD3__SIO_REG_HIFREQ)
    #define CPUD3_SIO_CFG            (* (reg8 *) CPUD3__SIO_CFG)
    #define CPUD3_SIO_DIFF           (* (reg8 *) CPUD3__SIO_DIFF)
#endif /* (CPUD3__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD3__INTSTAT)
    #define CPUD3_INTSTAT            (* (reg8 *) CPUD3__INTSTAT)
    #define CPUD3_SNAP               (* (reg8 *) CPUD3__SNAP)
    
	#define CPUD3_0_INTTYPE_REG 		(* (reg8 *) CPUD3__0__INTTYPE)
#endif /* (CPUD3__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD3_H */


/* [] END OF FILE */
