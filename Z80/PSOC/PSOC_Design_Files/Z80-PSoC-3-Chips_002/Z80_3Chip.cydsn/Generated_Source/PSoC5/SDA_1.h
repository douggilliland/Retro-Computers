/*******************************************************************************
* File Name: SDA_1.h  
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

#if !defined(CY_PINS_SDA_1_H) /* Pins SDA_1_H */
#define CY_PINS_SDA_1_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SDA_1_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SDA_1__PORT == 15 && ((SDA_1__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SDA_1_Write(uint8 value);
void    SDA_1_SetDriveMode(uint8 mode);
uint8   SDA_1_ReadDataReg(void);
uint8   SDA_1_Read(void);
void    SDA_1_SetInterruptMode(uint16 position, uint16 mode);
uint8   SDA_1_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SDA_1_SetDriveMode() function.
     *  @{
     */
        #define SDA_1_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SDA_1_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SDA_1_DM_RES_UP          PIN_DM_RES_UP
        #define SDA_1_DM_RES_DWN         PIN_DM_RES_DWN
        #define SDA_1_DM_OD_LO           PIN_DM_OD_LO
        #define SDA_1_DM_OD_HI           PIN_DM_OD_HI
        #define SDA_1_DM_STRONG          PIN_DM_STRONG
        #define SDA_1_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SDA_1_MASK               SDA_1__MASK
#define SDA_1_SHIFT              SDA_1__SHIFT
#define SDA_1_WIDTH              1u

/* Interrupt constants */
#if defined(SDA_1__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SDA_1_SetInterruptMode() function.
     *  @{
     */
        #define SDA_1_INTR_NONE      (uint16)(0x0000u)
        #define SDA_1_INTR_RISING    (uint16)(0x0001u)
        #define SDA_1_INTR_FALLING   (uint16)(0x0002u)
        #define SDA_1_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SDA_1_INTR_MASK      (0x01u) 
#endif /* (SDA_1__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SDA_1_PS                     (* (reg8 *) SDA_1__PS)
/* Data Register */
#define SDA_1_DR                     (* (reg8 *) SDA_1__DR)
/* Port Number */
#define SDA_1_PRT_NUM                (* (reg8 *) SDA_1__PRT) 
/* Connect to Analog Globals */                                                  
#define SDA_1_AG                     (* (reg8 *) SDA_1__AG)                       
/* Analog MUX bux enable */
#define SDA_1_AMUX                   (* (reg8 *) SDA_1__AMUX) 
/* Bidirectional Enable */                                                        
#define SDA_1_BIE                    (* (reg8 *) SDA_1__BIE)
/* Bit-mask for Aliased Register Access */
#define SDA_1_BIT_MASK               (* (reg8 *) SDA_1__BIT_MASK)
/* Bypass Enable */
#define SDA_1_BYP                    (* (reg8 *) SDA_1__BYP)
/* Port wide control signals */                                                   
#define SDA_1_CTL                    (* (reg8 *) SDA_1__CTL)
/* Drive Modes */
#define SDA_1_DM0                    (* (reg8 *) SDA_1__DM0) 
#define SDA_1_DM1                    (* (reg8 *) SDA_1__DM1)
#define SDA_1_DM2                    (* (reg8 *) SDA_1__DM2) 
/* Input Buffer Disable Override */
#define SDA_1_INP_DIS                (* (reg8 *) SDA_1__INP_DIS)
/* LCD Common or Segment Drive */
#define SDA_1_LCD_COM_SEG            (* (reg8 *) SDA_1__LCD_COM_SEG)
/* Enable Segment LCD */
#define SDA_1_LCD_EN                 (* (reg8 *) SDA_1__LCD_EN)
/* Slew Rate Control */
#define SDA_1_SLW                    (* (reg8 *) SDA_1__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SDA_1_PRTDSI__CAPS_SEL       (* (reg8 *) SDA_1__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SDA_1_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SDA_1__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SDA_1_PRTDSI__OE_SEL0        (* (reg8 *) SDA_1__PRTDSI__OE_SEL0) 
#define SDA_1_PRTDSI__OE_SEL1        (* (reg8 *) SDA_1__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SDA_1_PRTDSI__OUT_SEL0       (* (reg8 *) SDA_1__PRTDSI__OUT_SEL0) 
#define SDA_1_PRTDSI__OUT_SEL1       (* (reg8 *) SDA_1__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SDA_1_PRTDSI__SYNC_OUT       (* (reg8 *) SDA_1__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SDA_1__SIO_CFG)
    #define SDA_1_SIO_HYST_EN        (* (reg8 *) SDA_1__SIO_HYST_EN)
    #define SDA_1_SIO_REG_HIFREQ     (* (reg8 *) SDA_1__SIO_REG_HIFREQ)
    #define SDA_1_SIO_CFG            (* (reg8 *) SDA_1__SIO_CFG)
    #define SDA_1_SIO_DIFF           (* (reg8 *) SDA_1__SIO_DIFF)
#endif /* (SDA_1__SIO_CFG) */

/* Interrupt Registers */
#if defined(SDA_1__INTSTAT)
    #define SDA_1_INTSTAT            (* (reg8 *) SDA_1__INTSTAT)
    #define SDA_1_SNAP               (* (reg8 *) SDA_1__SNAP)
    
	#define SDA_1_0_INTTYPE_REG 		(* (reg8 *) SDA_1__0__INTTYPE)
#endif /* (SDA_1__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SDA_1_H */


/* [] END OF FILE */
