/*******************************************************************************
* File Name: WAIT_n.h  
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

#if !defined(CY_PINS_WAIT_n_H) /* Pins WAIT_n_H */
#define CY_PINS_WAIT_n_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "WAIT_n_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 WAIT_n__PORT == 15 && ((WAIT_n__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    WAIT_n_Write(uint8 value);
void    WAIT_n_SetDriveMode(uint8 mode);
uint8   WAIT_n_ReadDataReg(void);
uint8   WAIT_n_Read(void);
void    WAIT_n_SetInterruptMode(uint16 position, uint16 mode);
uint8   WAIT_n_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the WAIT_n_SetDriveMode() function.
     *  @{
     */
        #define WAIT_n_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define WAIT_n_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define WAIT_n_DM_RES_UP          PIN_DM_RES_UP
        #define WAIT_n_DM_RES_DWN         PIN_DM_RES_DWN
        #define WAIT_n_DM_OD_LO           PIN_DM_OD_LO
        #define WAIT_n_DM_OD_HI           PIN_DM_OD_HI
        #define WAIT_n_DM_STRONG          PIN_DM_STRONG
        #define WAIT_n_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define WAIT_n_MASK               WAIT_n__MASK
#define WAIT_n_SHIFT              WAIT_n__SHIFT
#define WAIT_n_WIDTH              1u

/* Interrupt constants */
#if defined(WAIT_n__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in WAIT_n_SetInterruptMode() function.
     *  @{
     */
        #define WAIT_n_INTR_NONE      (uint16)(0x0000u)
        #define WAIT_n_INTR_RISING    (uint16)(0x0001u)
        #define WAIT_n_INTR_FALLING   (uint16)(0x0002u)
        #define WAIT_n_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define WAIT_n_INTR_MASK      (0x01u) 
#endif /* (WAIT_n__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define WAIT_n_PS                     (* (reg8 *) WAIT_n__PS)
/* Data Register */
#define WAIT_n_DR                     (* (reg8 *) WAIT_n__DR)
/* Port Number */
#define WAIT_n_PRT_NUM                (* (reg8 *) WAIT_n__PRT) 
/* Connect to Analog Globals */                                                  
#define WAIT_n_AG                     (* (reg8 *) WAIT_n__AG)                       
/* Analog MUX bux enable */
#define WAIT_n_AMUX                   (* (reg8 *) WAIT_n__AMUX) 
/* Bidirectional Enable */                                                        
#define WAIT_n_BIE                    (* (reg8 *) WAIT_n__BIE)
/* Bit-mask for Aliased Register Access */
#define WAIT_n_BIT_MASK               (* (reg8 *) WAIT_n__BIT_MASK)
/* Bypass Enable */
#define WAIT_n_BYP                    (* (reg8 *) WAIT_n__BYP)
/* Port wide control signals */                                                   
#define WAIT_n_CTL                    (* (reg8 *) WAIT_n__CTL)
/* Drive Modes */
#define WAIT_n_DM0                    (* (reg8 *) WAIT_n__DM0) 
#define WAIT_n_DM1                    (* (reg8 *) WAIT_n__DM1)
#define WAIT_n_DM2                    (* (reg8 *) WAIT_n__DM2) 
/* Input Buffer Disable Override */
#define WAIT_n_INP_DIS                (* (reg8 *) WAIT_n__INP_DIS)
/* LCD Common or Segment Drive */
#define WAIT_n_LCD_COM_SEG            (* (reg8 *) WAIT_n__LCD_COM_SEG)
/* Enable Segment LCD */
#define WAIT_n_LCD_EN                 (* (reg8 *) WAIT_n__LCD_EN)
/* Slew Rate Control */
#define WAIT_n_SLW                    (* (reg8 *) WAIT_n__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define WAIT_n_PRTDSI__CAPS_SEL       (* (reg8 *) WAIT_n__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define WAIT_n_PRTDSI__DBL_SYNC_IN    (* (reg8 *) WAIT_n__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define WAIT_n_PRTDSI__OE_SEL0        (* (reg8 *) WAIT_n__PRTDSI__OE_SEL0) 
#define WAIT_n_PRTDSI__OE_SEL1        (* (reg8 *) WAIT_n__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define WAIT_n_PRTDSI__OUT_SEL0       (* (reg8 *) WAIT_n__PRTDSI__OUT_SEL0) 
#define WAIT_n_PRTDSI__OUT_SEL1       (* (reg8 *) WAIT_n__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define WAIT_n_PRTDSI__SYNC_OUT       (* (reg8 *) WAIT_n__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(WAIT_n__SIO_CFG)
    #define WAIT_n_SIO_HYST_EN        (* (reg8 *) WAIT_n__SIO_HYST_EN)
    #define WAIT_n_SIO_REG_HIFREQ     (* (reg8 *) WAIT_n__SIO_REG_HIFREQ)
    #define WAIT_n_SIO_CFG            (* (reg8 *) WAIT_n__SIO_CFG)
    #define WAIT_n_SIO_DIFF           (* (reg8 *) WAIT_n__SIO_DIFF)
#endif /* (WAIT_n__SIO_CFG) */

/* Interrupt Registers */
#if defined(WAIT_n__INTSTAT)
    #define WAIT_n_INTSTAT            (* (reg8 *) WAIT_n__INTSTAT)
    #define WAIT_n_SNAP               (* (reg8 *) WAIT_n__SNAP)
    
	#define WAIT_n_0_INTTYPE_REG 		(* (reg8 *) WAIT_n__0__INTTYPE)
#endif /* (WAIT_n__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_WAIT_n_H */


/* [] END OF FILE */
