/*******************************************************************************
* File Name: CPUA2.h  
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

#if !defined(CY_PINS_CPUA2_H) /* Pins CPUA2_H */
#define CY_PINS_CPUA2_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA2_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA2__PORT == 15 && ((CPUA2__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA2_Write(uint8 value);
void    CPUA2_SetDriveMode(uint8 mode);
uint8   CPUA2_ReadDataReg(void);
uint8   CPUA2_Read(void);
void    CPUA2_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA2_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA2_SetDriveMode() function.
     *  @{
     */
        #define CPUA2_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA2_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA2_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA2_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA2_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA2_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA2_DM_STRONG          PIN_DM_STRONG
        #define CPUA2_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA2_MASK               CPUA2__MASK
#define CPUA2_SHIFT              CPUA2__SHIFT
#define CPUA2_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA2__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA2_SetInterruptMode() function.
     *  @{
     */
        #define CPUA2_INTR_NONE      (uint16)(0x0000u)
        #define CPUA2_INTR_RISING    (uint16)(0x0001u)
        #define CPUA2_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA2_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA2_INTR_MASK      (0x01u) 
#endif /* (CPUA2__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA2_PS                     (* (reg8 *) CPUA2__PS)
/* Data Register */
#define CPUA2_DR                     (* (reg8 *) CPUA2__DR)
/* Port Number */
#define CPUA2_PRT_NUM                (* (reg8 *) CPUA2__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA2_AG                     (* (reg8 *) CPUA2__AG)                       
/* Analog MUX bux enable */
#define CPUA2_AMUX                   (* (reg8 *) CPUA2__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA2_BIE                    (* (reg8 *) CPUA2__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA2_BIT_MASK               (* (reg8 *) CPUA2__BIT_MASK)
/* Bypass Enable */
#define CPUA2_BYP                    (* (reg8 *) CPUA2__BYP)
/* Port wide control signals */                                                   
#define CPUA2_CTL                    (* (reg8 *) CPUA2__CTL)
/* Drive Modes */
#define CPUA2_DM0                    (* (reg8 *) CPUA2__DM0) 
#define CPUA2_DM1                    (* (reg8 *) CPUA2__DM1)
#define CPUA2_DM2                    (* (reg8 *) CPUA2__DM2) 
/* Input Buffer Disable Override */
#define CPUA2_INP_DIS                (* (reg8 *) CPUA2__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA2_LCD_COM_SEG            (* (reg8 *) CPUA2__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA2_LCD_EN                 (* (reg8 *) CPUA2__LCD_EN)
/* Slew Rate Control */
#define CPUA2_SLW                    (* (reg8 *) CPUA2__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA2_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA2__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA2_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA2__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA2_PRTDSI__OE_SEL0        (* (reg8 *) CPUA2__PRTDSI__OE_SEL0) 
#define CPUA2_PRTDSI__OE_SEL1        (* (reg8 *) CPUA2__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA2_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA2__PRTDSI__OUT_SEL0) 
#define CPUA2_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA2__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA2_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA2__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA2__SIO_CFG)
    #define CPUA2_SIO_HYST_EN        (* (reg8 *) CPUA2__SIO_HYST_EN)
    #define CPUA2_SIO_REG_HIFREQ     (* (reg8 *) CPUA2__SIO_REG_HIFREQ)
    #define CPUA2_SIO_CFG            (* (reg8 *) CPUA2__SIO_CFG)
    #define CPUA2_SIO_DIFF           (* (reg8 *) CPUA2__SIO_DIFF)
#endif /* (CPUA2__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA2__INTSTAT)
    #define CPUA2_INTSTAT            (* (reg8 *) CPUA2__INTSTAT)
    #define CPUA2_SNAP               (* (reg8 *) CPUA2__SNAP)
    
	#define CPUA2_0_INTTYPE_REG 		(* (reg8 *) CPUA2__0__INTTYPE)
#endif /* (CPUA2__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA2_H */


/* [] END OF FILE */
