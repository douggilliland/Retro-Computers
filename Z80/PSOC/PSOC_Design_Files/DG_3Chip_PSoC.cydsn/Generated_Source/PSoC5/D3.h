/*******************************************************************************
* File Name: D3.h  
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

#if !defined(CY_PINS_D3_H) /* Pins D3_H */
#define CY_PINS_D3_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "D3_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 D3__PORT == 15 && ((D3__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    D3_Write(uint8 value);
void    D3_SetDriveMode(uint8 mode);
uint8   D3_ReadDataReg(void);
uint8   D3_Read(void);
void    D3_SetInterruptMode(uint16 position, uint16 mode);
uint8   D3_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the D3_SetDriveMode() function.
     *  @{
     */
        #define D3_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define D3_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define D3_DM_RES_UP          PIN_DM_RES_UP
        #define D3_DM_RES_DWN         PIN_DM_RES_DWN
        #define D3_DM_OD_LO           PIN_DM_OD_LO
        #define D3_DM_OD_HI           PIN_DM_OD_HI
        #define D3_DM_STRONG          PIN_DM_STRONG
        #define D3_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define D3_MASK               D3__MASK
#define D3_SHIFT              D3__SHIFT
#define D3_WIDTH              1u

/* Interrupt constants */
#if defined(D3__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in D3_SetInterruptMode() function.
     *  @{
     */
        #define D3_INTR_NONE      (uint16)(0x0000u)
        #define D3_INTR_RISING    (uint16)(0x0001u)
        #define D3_INTR_FALLING   (uint16)(0x0002u)
        #define D3_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define D3_INTR_MASK      (0x01u) 
#endif /* (D3__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define D3_PS                     (* (reg8 *) D3__PS)
/* Data Register */
#define D3_DR                     (* (reg8 *) D3__DR)
/* Port Number */
#define D3_PRT_NUM                (* (reg8 *) D3__PRT) 
/* Connect to Analog Globals */                                                  
#define D3_AG                     (* (reg8 *) D3__AG)                       
/* Analog MUX bux enable */
#define D3_AMUX                   (* (reg8 *) D3__AMUX) 
/* Bidirectional Enable */                                                        
#define D3_BIE                    (* (reg8 *) D3__BIE)
/* Bit-mask for Aliased Register Access */
#define D3_BIT_MASK               (* (reg8 *) D3__BIT_MASK)
/* Bypass Enable */
#define D3_BYP                    (* (reg8 *) D3__BYP)
/* Port wide control signals */                                                   
#define D3_CTL                    (* (reg8 *) D3__CTL)
/* Drive Modes */
#define D3_DM0                    (* (reg8 *) D3__DM0) 
#define D3_DM1                    (* (reg8 *) D3__DM1)
#define D3_DM2                    (* (reg8 *) D3__DM2) 
/* Input Buffer Disable Override */
#define D3_INP_DIS                (* (reg8 *) D3__INP_DIS)
/* LCD Common or Segment Drive */
#define D3_LCD_COM_SEG            (* (reg8 *) D3__LCD_COM_SEG)
/* Enable Segment LCD */
#define D3_LCD_EN                 (* (reg8 *) D3__LCD_EN)
/* Slew Rate Control */
#define D3_SLW                    (* (reg8 *) D3__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define D3_PRTDSI__CAPS_SEL       (* (reg8 *) D3__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define D3_PRTDSI__DBL_SYNC_IN    (* (reg8 *) D3__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define D3_PRTDSI__OE_SEL0        (* (reg8 *) D3__PRTDSI__OE_SEL0) 
#define D3_PRTDSI__OE_SEL1        (* (reg8 *) D3__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define D3_PRTDSI__OUT_SEL0       (* (reg8 *) D3__PRTDSI__OUT_SEL0) 
#define D3_PRTDSI__OUT_SEL1       (* (reg8 *) D3__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define D3_PRTDSI__SYNC_OUT       (* (reg8 *) D3__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(D3__SIO_CFG)
    #define D3_SIO_HYST_EN        (* (reg8 *) D3__SIO_HYST_EN)
    #define D3_SIO_REG_HIFREQ     (* (reg8 *) D3__SIO_REG_HIFREQ)
    #define D3_SIO_CFG            (* (reg8 *) D3__SIO_CFG)
    #define D3_SIO_DIFF           (* (reg8 *) D3__SIO_DIFF)
#endif /* (D3__SIO_CFG) */

/* Interrupt Registers */
#if defined(D3__INTSTAT)
    #define D3_INTSTAT            (* (reg8 *) D3__INTSTAT)
    #define D3_SNAP               (* (reg8 *) D3__SNAP)
    
	#define D3_0_INTTYPE_REG 		(* (reg8 *) D3__0__INTTYPE)
#endif /* (D3__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_D3_H */


/* [] END OF FILE */
