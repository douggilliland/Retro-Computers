/*******************************************************************************
* File Name: CPUD0.h  
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

#if !defined(CY_PINS_CPUD0_H) /* Pins CPUD0_H */
#define CY_PINS_CPUD0_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD0_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD0__PORT == 15 && ((CPUD0__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD0_Write(uint8 value);
void    CPUD0_SetDriveMode(uint8 mode);
uint8   CPUD0_ReadDataReg(void);
uint8   CPUD0_Read(void);
void    CPUD0_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD0_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD0_SetDriveMode() function.
     *  @{
     */
        #define CPUD0_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD0_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD0_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD0_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD0_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD0_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD0_DM_STRONG          PIN_DM_STRONG
        #define CPUD0_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD0_MASK               CPUD0__MASK
#define CPUD0_SHIFT              CPUD0__SHIFT
#define CPUD0_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD0__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD0_SetInterruptMode() function.
     *  @{
     */
        #define CPUD0_INTR_NONE      (uint16)(0x0000u)
        #define CPUD0_INTR_RISING    (uint16)(0x0001u)
        #define CPUD0_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD0_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD0_INTR_MASK      (0x01u) 
#endif /* (CPUD0__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD0_PS                     (* (reg8 *) CPUD0__PS)
/* Data Register */
#define CPUD0_DR                     (* (reg8 *) CPUD0__DR)
/* Port Number */
#define CPUD0_PRT_NUM                (* (reg8 *) CPUD0__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD0_AG                     (* (reg8 *) CPUD0__AG)                       
/* Analog MUX bux enable */
#define CPUD0_AMUX                   (* (reg8 *) CPUD0__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD0_BIE                    (* (reg8 *) CPUD0__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD0_BIT_MASK               (* (reg8 *) CPUD0__BIT_MASK)
/* Bypass Enable */
#define CPUD0_BYP                    (* (reg8 *) CPUD0__BYP)
/* Port wide control signals */                                                   
#define CPUD0_CTL                    (* (reg8 *) CPUD0__CTL)
/* Drive Modes */
#define CPUD0_DM0                    (* (reg8 *) CPUD0__DM0) 
#define CPUD0_DM1                    (* (reg8 *) CPUD0__DM1)
#define CPUD0_DM2                    (* (reg8 *) CPUD0__DM2) 
/* Input Buffer Disable Override */
#define CPUD0_INP_DIS                (* (reg8 *) CPUD0__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD0_LCD_COM_SEG            (* (reg8 *) CPUD0__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD0_LCD_EN                 (* (reg8 *) CPUD0__LCD_EN)
/* Slew Rate Control */
#define CPUD0_SLW                    (* (reg8 *) CPUD0__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD0_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD0__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD0_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD0__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD0_PRTDSI__OE_SEL0        (* (reg8 *) CPUD0__PRTDSI__OE_SEL0) 
#define CPUD0_PRTDSI__OE_SEL1        (* (reg8 *) CPUD0__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD0_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD0__PRTDSI__OUT_SEL0) 
#define CPUD0_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD0__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD0_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD0__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD0__SIO_CFG)
    #define CPUD0_SIO_HYST_EN        (* (reg8 *) CPUD0__SIO_HYST_EN)
    #define CPUD0_SIO_REG_HIFREQ     (* (reg8 *) CPUD0__SIO_REG_HIFREQ)
    #define CPUD0_SIO_CFG            (* (reg8 *) CPUD0__SIO_CFG)
    #define CPUD0_SIO_DIFF           (* (reg8 *) CPUD0__SIO_DIFF)
#endif /* (CPUD0__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD0__INTSTAT)
    #define CPUD0_INTSTAT            (* (reg8 *) CPUD0__INTSTAT)
    #define CPUD0_SNAP               (* (reg8 *) CPUD0__SNAP)
    
	#define CPUD0_0_INTTYPE_REG 		(* (reg8 *) CPUD0__0__INTTYPE)
#endif /* (CPUD0__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD0_H */


/* [] END OF FILE */
