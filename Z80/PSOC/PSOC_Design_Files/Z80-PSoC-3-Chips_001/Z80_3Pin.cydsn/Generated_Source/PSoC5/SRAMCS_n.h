/*******************************************************************************
* File Name: SRAMCS_n.h  
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

#if !defined(CY_PINS_SRAMCS_n_H) /* Pins SRAMCS_n_H */
#define CY_PINS_SRAMCS_n_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SRAMCS_n_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SRAMCS_n__PORT == 15 && ((SRAMCS_n__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SRAMCS_n_Write(uint8 value);
void    SRAMCS_n_SetDriveMode(uint8 mode);
uint8   SRAMCS_n_ReadDataReg(void);
uint8   SRAMCS_n_Read(void);
void    SRAMCS_n_SetInterruptMode(uint16 position, uint16 mode);
uint8   SRAMCS_n_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SRAMCS_n_SetDriveMode() function.
     *  @{
     */
        #define SRAMCS_n_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SRAMCS_n_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SRAMCS_n_DM_RES_UP          PIN_DM_RES_UP
        #define SRAMCS_n_DM_RES_DWN         PIN_DM_RES_DWN
        #define SRAMCS_n_DM_OD_LO           PIN_DM_OD_LO
        #define SRAMCS_n_DM_OD_HI           PIN_DM_OD_HI
        #define SRAMCS_n_DM_STRONG          PIN_DM_STRONG
        #define SRAMCS_n_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SRAMCS_n_MASK               SRAMCS_n__MASK
#define SRAMCS_n_SHIFT              SRAMCS_n__SHIFT
#define SRAMCS_n_WIDTH              1u

/* Interrupt constants */
#if defined(SRAMCS_n__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SRAMCS_n_SetInterruptMode() function.
     *  @{
     */
        #define SRAMCS_n_INTR_NONE      (uint16)(0x0000u)
        #define SRAMCS_n_INTR_RISING    (uint16)(0x0001u)
        #define SRAMCS_n_INTR_FALLING   (uint16)(0x0002u)
        #define SRAMCS_n_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SRAMCS_n_INTR_MASK      (0x01u) 
#endif /* (SRAMCS_n__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SRAMCS_n_PS                     (* (reg8 *) SRAMCS_n__PS)
/* Data Register */
#define SRAMCS_n_DR                     (* (reg8 *) SRAMCS_n__DR)
/* Port Number */
#define SRAMCS_n_PRT_NUM                (* (reg8 *) SRAMCS_n__PRT) 
/* Connect to Analog Globals */                                                  
#define SRAMCS_n_AG                     (* (reg8 *) SRAMCS_n__AG)                       
/* Analog MUX bux enable */
#define SRAMCS_n_AMUX                   (* (reg8 *) SRAMCS_n__AMUX) 
/* Bidirectional Enable */                                                        
#define SRAMCS_n_BIE                    (* (reg8 *) SRAMCS_n__BIE)
/* Bit-mask for Aliased Register Access */
#define SRAMCS_n_BIT_MASK               (* (reg8 *) SRAMCS_n__BIT_MASK)
/* Bypass Enable */
#define SRAMCS_n_BYP                    (* (reg8 *) SRAMCS_n__BYP)
/* Port wide control signals */                                                   
#define SRAMCS_n_CTL                    (* (reg8 *) SRAMCS_n__CTL)
/* Drive Modes */
#define SRAMCS_n_DM0                    (* (reg8 *) SRAMCS_n__DM0) 
#define SRAMCS_n_DM1                    (* (reg8 *) SRAMCS_n__DM1)
#define SRAMCS_n_DM2                    (* (reg8 *) SRAMCS_n__DM2) 
/* Input Buffer Disable Override */
#define SRAMCS_n_INP_DIS                (* (reg8 *) SRAMCS_n__INP_DIS)
/* LCD Common or Segment Drive */
#define SRAMCS_n_LCD_COM_SEG            (* (reg8 *) SRAMCS_n__LCD_COM_SEG)
/* Enable Segment LCD */
#define SRAMCS_n_LCD_EN                 (* (reg8 *) SRAMCS_n__LCD_EN)
/* Slew Rate Control */
#define SRAMCS_n_SLW                    (* (reg8 *) SRAMCS_n__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SRAMCS_n_PRTDSI__CAPS_SEL       (* (reg8 *) SRAMCS_n__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SRAMCS_n_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SRAMCS_n__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SRAMCS_n_PRTDSI__OE_SEL0        (* (reg8 *) SRAMCS_n__PRTDSI__OE_SEL0) 
#define SRAMCS_n_PRTDSI__OE_SEL1        (* (reg8 *) SRAMCS_n__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SRAMCS_n_PRTDSI__OUT_SEL0       (* (reg8 *) SRAMCS_n__PRTDSI__OUT_SEL0) 
#define SRAMCS_n_PRTDSI__OUT_SEL1       (* (reg8 *) SRAMCS_n__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SRAMCS_n_PRTDSI__SYNC_OUT       (* (reg8 *) SRAMCS_n__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SRAMCS_n__SIO_CFG)
    #define SRAMCS_n_SIO_HYST_EN        (* (reg8 *) SRAMCS_n__SIO_HYST_EN)
    #define SRAMCS_n_SIO_REG_HIFREQ     (* (reg8 *) SRAMCS_n__SIO_REG_HIFREQ)
    #define SRAMCS_n_SIO_CFG            (* (reg8 *) SRAMCS_n__SIO_CFG)
    #define SRAMCS_n_SIO_DIFF           (* (reg8 *) SRAMCS_n__SIO_DIFF)
#endif /* (SRAMCS_n__SIO_CFG) */

/* Interrupt Registers */
#if defined(SRAMCS_n__INTSTAT)
    #define SRAMCS_n_INTSTAT            (* (reg8 *) SRAMCS_n__INTSTAT)
    #define SRAMCS_n_SNAP               (* (reg8 *) SRAMCS_n__SNAP)
    
	#define SRAMCS_n_0_INTTYPE_REG 		(* (reg8 *) SRAMCS_n__0__INTTYPE)
#endif /* (SRAMCS_n__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SRAMCS_n_H */


/* [] END OF FILE */
