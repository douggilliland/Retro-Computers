/*******************************************************************************
* File Name: CPUA15.h  
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

#if !defined(CY_PINS_CPUA15_H) /* Pins CPUA15_H */
#define CY_PINS_CPUA15_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA15_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA15__PORT == 15 && ((CPUA15__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA15_Write(uint8 value);
void    CPUA15_SetDriveMode(uint8 mode);
uint8   CPUA15_ReadDataReg(void);
uint8   CPUA15_Read(void);
void    CPUA15_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA15_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA15_SetDriveMode() function.
     *  @{
     */
        #define CPUA15_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA15_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA15_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA15_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA15_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA15_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA15_DM_STRONG          PIN_DM_STRONG
        #define CPUA15_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA15_MASK               CPUA15__MASK
#define CPUA15_SHIFT              CPUA15__SHIFT
#define CPUA15_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA15__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA15_SetInterruptMode() function.
     *  @{
     */
        #define CPUA15_INTR_NONE      (uint16)(0x0000u)
        #define CPUA15_INTR_RISING    (uint16)(0x0001u)
        #define CPUA15_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA15_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA15_INTR_MASK      (0x01u) 
#endif /* (CPUA15__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA15_PS                     (* (reg8 *) CPUA15__PS)
/* Data Register */
#define CPUA15_DR                     (* (reg8 *) CPUA15__DR)
/* Port Number */
#define CPUA15_PRT_NUM                (* (reg8 *) CPUA15__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA15_AG                     (* (reg8 *) CPUA15__AG)                       
/* Analog MUX bux enable */
#define CPUA15_AMUX                   (* (reg8 *) CPUA15__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA15_BIE                    (* (reg8 *) CPUA15__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA15_BIT_MASK               (* (reg8 *) CPUA15__BIT_MASK)
/* Bypass Enable */
#define CPUA15_BYP                    (* (reg8 *) CPUA15__BYP)
/* Port wide control signals */                                                   
#define CPUA15_CTL                    (* (reg8 *) CPUA15__CTL)
/* Drive Modes */
#define CPUA15_DM0                    (* (reg8 *) CPUA15__DM0) 
#define CPUA15_DM1                    (* (reg8 *) CPUA15__DM1)
#define CPUA15_DM2                    (* (reg8 *) CPUA15__DM2) 
/* Input Buffer Disable Override */
#define CPUA15_INP_DIS                (* (reg8 *) CPUA15__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA15_LCD_COM_SEG            (* (reg8 *) CPUA15__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA15_LCD_EN                 (* (reg8 *) CPUA15__LCD_EN)
/* Slew Rate Control */
#define CPUA15_SLW                    (* (reg8 *) CPUA15__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA15_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA15__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA15_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA15__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA15_PRTDSI__OE_SEL0        (* (reg8 *) CPUA15__PRTDSI__OE_SEL0) 
#define CPUA15_PRTDSI__OE_SEL1        (* (reg8 *) CPUA15__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA15_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA15__PRTDSI__OUT_SEL0) 
#define CPUA15_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA15__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA15_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA15__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA15__SIO_CFG)
    #define CPUA15_SIO_HYST_EN        (* (reg8 *) CPUA15__SIO_HYST_EN)
    #define CPUA15_SIO_REG_HIFREQ     (* (reg8 *) CPUA15__SIO_REG_HIFREQ)
    #define CPUA15_SIO_CFG            (* (reg8 *) CPUA15__SIO_CFG)
    #define CPUA15_SIO_DIFF           (* (reg8 *) CPUA15__SIO_DIFF)
#endif /* (CPUA15__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA15__INTSTAT)
    #define CPUA15_INTSTAT            (* (reg8 *) CPUA15__INTSTAT)
    #define CPUA15_SNAP               (* (reg8 *) CPUA15__SNAP)
    
	#define CPUA15_0_INTTYPE_REG 		(* (reg8 *) CPUA15__0__INTTYPE)
#endif /* (CPUA15__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA15_H */


/* [] END OF FILE */
