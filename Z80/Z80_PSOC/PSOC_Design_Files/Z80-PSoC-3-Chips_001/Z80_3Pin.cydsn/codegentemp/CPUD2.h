/*******************************************************************************
* File Name: CPUD2.h  
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

#if !defined(CY_PINS_CPUD2_H) /* Pins CPUD2_H */
#define CY_PINS_CPUD2_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUD2_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUD2__PORT == 15 && ((CPUD2__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUD2_Write(uint8 value);
void    CPUD2_SetDriveMode(uint8 mode);
uint8   CPUD2_ReadDataReg(void);
uint8   CPUD2_Read(void);
void    CPUD2_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUD2_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUD2_SetDriveMode() function.
     *  @{
     */
        #define CPUD2_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUD2_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUD2_DM_RES_UP          PIN_DM_RES_UP
        #define CPUD2_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUD2_DM_OD_LO           PIN_DM_OD_LO
        #define CPUD2_DM_OD_HI           PIN_DM_OD_HI
        #define CPUD2_DM_STRONG          PIN_DM_STRONG
        #define CPUD2_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUD2_MASK               CPUD2__MASK
#define CPUD2_SHIFT              CPUD2__SHIFT
#define CPUD2_WIDTH              1u

/* Interrupt constants */
#if defined(CPUD2__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUD2_SetInterruptMode() function.
     *  @{
     */
        #define CPUD2_INTR_NONE      (uint16)(0x0000u)
        #define CPUD2_INTR_RISING    (uint16)(0x0001u)
        #define CPUD2_INTR_FALLING   (uint16)(0x0002u)
        #define CPUD2_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUD2_INTR_MASK      (0x01u) 
#endif /* (CPUD2__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUD2_PS                     (* (reg8 *) CPUD2__PS)
/* Data Register */
#define CPUD2_DR                     (* (reg8 *) CPUD2__DR)
/* Port Number */
#define CPUD2_PRT_NUM                (* (reg8 *) CPUD2__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUD2_AG                     (* (reg8 *) CPUD2__AG)                       
/* Analog MUX bux enable */
#define CPUD2_AMUX                   (* (reg8 *) CPUD2__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUD2_BIE                    (* (reg8 *) CPUD2__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUD2_BIT_MASK               (* (reg8 *) CPUD2__BIT_MASK)
/* Bypass Enable */
#define CPUD2_BYP                    (* (reg8 *) CPUD2__BYP)
/* Port wide control signals */                                                   
#define CPUD2_CTL                    (* (reg8 *) CPUD2__CTL)
/* Drive Modes */
#define CPUD2_DM0                    (* (reg8 *) CPUD2__DM0) 
#define CPUD2_DM1                    (* (reg8 *) CPUD2__DM1)
#define CPUD2_DM2                    (* (reg8 *) CPUD2__DM2) 
/* Input Buffer Disable Override */
#define CPUD2_INP_DIS                (* (reg8 *) CPUD2__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUD2_LCD_COM_SEG            (* (reg8 *) CPUD2__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUD2_LCD_EN                 (* (reg8 *) CPUD2__LCD_EN)
/* Slew Rate Control */
#define CPUD2_SLW                    (* (reg8 *) CPUD2__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUD2_PRTDSI__CAPS_SEL       (* (reg8 *) CPUD2__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUD2_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUD2__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUD2_PRTDSI__OE_SEL0        (* (reg8 *) CPUD2__PRTDSI__OE_SEL0) 
#define CPUD2_PRTDSI__OE_SEL1        (* (reg8 *) CPUD2__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUD2_PRTDSI__OUT_SEL0       (* (reg8 *) CPUD2__PRTDSI__OUT_SEL0) 
#define CPUD2_PRTDSI__OUT_SEL1       (* (reg8 *) CPUD2__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUD2_PRTDSI__SYNC_OUT       (* (reg8 *) CPUD2__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUD2__SIO_CFG)
    #define CPUD2_SIO_HYST_EN        (* (reg8 *) CPUD2__SIO_HYST_EN)
    #define CPUD2_SIO_REG_HIFREQ     (* (reg8 *) CPUD2__SIO_REG_HIFREQ)
    #define CPUD2_SIO_CFG            (* (reg8 *) CPUD2__SIO_CFG)
    #define CPUD2_SIO_DIFF           (* (reg8 *) CPUD2__SIO_DIFF)
#endif /* (CPUD2__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUD2__INTSTAT)
    #define CPUD2_INTSTAT            (* (reg8 *) CPUD2__INTSTAT)
    #define CPUD2_SNAP               (* (reg8 *) CPUD2__SNAP)
    
	#define CPUD2_0_INTTYPE_REG 		(* (reg8 *) CPUD2__0__INTTYPE)
#endif /* (CPUD2__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUD2_H */


/* [] END OF FILE */
