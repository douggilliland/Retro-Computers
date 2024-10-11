/*******************************************************************************
* File Name: CPUA11_1.h  
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

#if !defined(CY_PINS_CPUA11_1_H) /* Pins CPUA11_1_H */
#define CY_PINS_CPUA11_1_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA11_1_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA11_1__PORT == 15 && ((CPUA11_1__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA11_1_Write(uint8 value);
void    CPUA11_1_SetDriveMode(uint8 mode);
uint8   CPUA11_1_ReadDataReg(void);
uint8   CPUA11_1_Read(void);
void    CPUA11_1_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA11_1_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA11_1_SetDriveMode() function.
     *  @{
     */
        #define CPUA11_1_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA11_1_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA11_1_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA11_1_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA11_1_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA11_1_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA11_1_DM_STRONG          PIN_DM_STRONG
        #define CPUA11_1_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA11_1_MASK               CPUA11_1__MASK
#define CPUA11_1_SHIFT              CPUA11_1__SHIFT
#define CPUA11_1_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA11_1__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA11_1_SetInterruptMode() function.
     *  @{
     */
        #define CPUA11_1_INTR_NONE      (uint16)(0x0000u)
        #define CPUA11_1_INTR_RISING    (uint16)(0x0001u)
        #define CPUA11_1_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA11_1_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA11_1_INTR_MASK      (0x01u) 
#endif /* (CPUA11_1__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA11_1_PS                     (* (reg8 *) CPUA11_1__PS)
/* Data Register */
#define CPUA11_1_DR                     (* (reg8 *) CPUA11_1__DR)
/* Port Number */
#define CPUA11_1_PRT_NUM                (* (reg8 *) CPUA11_1__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA11_1_AG                     (* (reg8 *) CPUA11_1__AG)                       
/* Analog MUX bux enable */
#define CPUA11_1_AMUX                   (* (reg8 *) CPUA11_1__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA11_1_BIE                    (* (reg8 *) CPUA11_1__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA11_1_BIT_MASK               (* (reg8 *) CPUA11_1__BIT_MASK)
/* Bypass Enable */
#define CPUA11_1_BYP                    (* (reg8 *) CPUA11_1__BYP)
/* Port wide control signals */                                                   
#define CPUA11_1_CTL                    (* (reg8 *) CPUA11_1__CTL)
/* Drive Modes */
#define CPUA11_1_DM0                    (* (reg8 *) CPUA11_1__DM0) 
#define CPUA11_1_DM1                    (* (reg8 *) CPUA11_1__DM1)
#define CPUA11_1_DM2                    (* (reg8 *) CPUA11_1__DM2) 
/* Input Buffer Disable Override */
#define CPUA11_1_INP_DIS                (* (reg8 *) CPUA11_1__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA11_1_LCD_COM_SEG            (* (reg8 *) CPUA11_1__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA11_1_LCD_EN                 (* (reg8 *) CPUA11_1__LCD_EN)
/* Slew Rate Control */
#define CPUA11_1_SLW                    (* (reg8 *) CPUA11_1__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA11_1_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA11_1__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA11_1_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA11_1__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA11_1_PRTDSI__OE_SEL0        (* (reg8 *) CPUA11_1__PRTDSI__OE_SEL0) 
#define CPUA11_1_PRTDSI__OE_SEL1        (* (reg8 *) CPUA11_1__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA11_1_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA11_1__PRTDSI__OUT_SEL0) 
#define CPUA11_1_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA11_1__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA11_1_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA11_1__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA11_1__SIO_CFG)
    #define CPUA11_1_SIO_HYST_EN        (* (reg8 *) CPUA11_1__SIO_HYST_EN)
    #define CPUA11_1_SIO_REG_HIFREQ     (* (reg8 *) CPUA11_1__SIO_REG_HIFREQ)
    #define CPUA11_1_SIO_CFG            (* (reg8 *) CPUA11_1__SIO_CFG)
    #define CPUA11_1_SIO_DIFF           (* (reg8 *) CPUA11_1__SIO_DIFF)
#endif /* (CPUA11_1__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA11_1__INTSTAT)
    #define CPUA11_1_INTSTAT            (* (reg8 *) CPUA11_1__INTSTAT)
    #define CPUA11_1_SNAP               (* (reg8 *) CPUA11_1__SNAP)
    
	#define CPUA11_1_0_INTTYPE_REG 		(* (reg8 *) CPUA11_1__0__INTTYPE)
#endif /* (CPUA11_1__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA11_1_H */


/* [] END OF FILE */
