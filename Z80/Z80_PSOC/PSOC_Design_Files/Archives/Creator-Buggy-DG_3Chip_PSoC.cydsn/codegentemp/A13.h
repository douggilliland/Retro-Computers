/*******************************************************************************
* File Name: A13.h  
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

#if !defined(CY_PINS_A13_H) /* Pins A13_H */
#define CY_PINS_A13_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "A13_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 A13__PORT == 15 && ((A13__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    A13_Write(uint8 value);
void    A13_SetDriveMode(uint8 mode);
uint8   A13_ReadDataReg(void);
uint8   A13_Read(void);
void    A13_SetInterruptMode(uint16 position, uint16 mode);
uint8   A13_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the A13_SetDriveMode() function.
     *  @{
     */
        #define A13_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define A13_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define A13_DM_RES_UP          PIN_DM_RES_UP
        #define A13_DM_RES_DWN         PIN_DM_RES_DWN
        #define A13_DM_OD_LO           PIN_DM_OD_LO
        #define A13_DM_OD_HI           PIN_DM_OD_HI
        #define A13_DM_STRONG          PIN_DM_STRONG
        #define A13_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define A13_MASK               A13__MASK
#define A13_SHIFT              A13__SHIFT
#define A13_WIDTH              1u

/* Interrupt constants */
#if defined(A13__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in A13_SetInterruptMode() function.
     *  @{
     */
        #define A13_INTR_NONE      (uint16)(0x0000u)
        #define A13_INTR_RISING    (uint16)(0x0001u)
        #define A13_INTR_FALLING   (uint16)(0x0002u)
        #define A13_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define A13_INTR_MASK      (0x01u) 
#endif /* (A13__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define A13_PS                     (* (reg8 *) A13__PS)
/* Data Register */
#define A13_DR                     (* (reg8 *) A13__DR)
/* Port Number */
#define A13_PRT_NUM                (* (reg8 *) A13__PRT) 
/* Connect to Analog Globals */                                                  
#define A13_AG                     (* (reg8 *) A13__AG)                       
/* Analog MUX bux enable */
#define A13_AMUX                   (* (reg8 *) A13__AMUX) 
/* Bidirectional Enable */                                                        
#define A13_BIE                    (* (reg8 *) A13__BIE)
/* Bit-mask for Aliased Register Access */
#define A13_BIT_MASK               (* (reg8 *) A13__BIT_MASK)
/* Bypass Enable */
#define A13_BYP                    (* (reg8 *) A13__BYP)
/* Port wide control signals */                                                   
#define A13_CTL                    (* (reg8 *) A13__CTL)
/* Drive Modes */
#define A13_DM0                    (* (reg8 *) A13__DM0) 
#define A13_DM1                    (* (reg8 *) A13__DM1)
#define A13_DM2                    (* (reg8 *) A13__DM2) 
/* Input Buffer Disable Override */
#define A13_INP_DIS                (* (reg8 *) A13__INP_DIS)
/* LCD Common or Segment Drive */
#define A13_LCD_COM_SEG            (* (reg8 *) A13__LCD_COM_SEG)
/* Enable Segment LCD */
#define A13_LCD_EN                 (* (reg8 *) A13__LCD_EN)
/* Slew Rate Control */
#define A13_SLW                    (* (reg8 *) A13__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define A13_PRTDSI__CAPS_SEL       (* (reg8 *) A13__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define A13_PRTDSI__DBL_SYNC_IN    (* (reg8 *) A13__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define A13_PRTDSI__OE_SEL0        (* (reg8 *) A13__PRTDSI__OE_SEL0) 
#define A13_PRTDSI__OE_SEL1        (* (reg8 *) A13__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define A13_PRTDSI__OUT_SEL0       (* (reg8 *) A13__PRTDSI__OUT_SEL0) 
#define A13_PRTDSI__OUT_SEL1       (* (reg8 *) A13__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define A13_PRTDSI__SYNC_OUT       (* (reg8 *) A13__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(A13__SIO_CFG)
    #define A13_SIO_HYST_EN        (* (reg8 *) A13__SIO_HYST_EN)
    #define A13_SIO_REG_HIFREQ     (* (reg8 *) A13__SIO_REG_HIFREQ)
    #define A13_SIO_CFG            (* (reg8 *) A13__SIO_CFG)
    #define A13_SIO_DIFF           (* (reg8 *) A13__SIO_DIFF)
#endif /* (A13__SIO_CFG) */

/* Interrupt Registers */
#if defined(A13__INTSTAT)
    #define A13_INTSTAT            (* (reg8 *) A13__INTSTAT)
    #define A13_SNAP               (* (reg8 *) A13__SNAP)
    
	#define A13_0_INTTYPE_REG 		(* (reg8 *) A13__0__INTTYPE)
#endif /* (A13__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_A13_H */


/* [] END OF FILE */
