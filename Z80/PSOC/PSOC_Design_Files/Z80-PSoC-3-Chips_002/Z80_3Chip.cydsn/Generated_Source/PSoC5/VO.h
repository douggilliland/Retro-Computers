/*******************************************************************************
* File Name: VO.h  
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

#if !defined(CY_PINS_VO_H) /* Pins VO_H */
#define CY_PINS_VO_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "VO_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 VO__PORT == 15 && ((VO__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    VO_Write(uint8 value);
void    VO_SetDriveMode(uint8 mode);
uint8   VO_ReadDataReg(void);
uint8   VO_Read(void);
void    VO_SetInterruptMode(uint16 position, uint16 mode);
uint8   VO_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the VO_SetDriveMode() function.
     *  @{
     */
        #define VO_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define VO_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define VO_DM_RES_UP          PIN_DM_RES_UP
        #define VO_DM_RES_DWN         PIN_DM_RES_DWN
        #define VO_DM_OD_LO           PIN_DM_OD_LO
        #define VO_DM_OD_HI           PIN_DM_OD_HI
        #define VO_DM_STRONG          PIN_DM_STRONG
        #define VO_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define VO_MASK               VO__MASK
#define VO_SHIFT              VO__SHIFT
#define VO_WIDTH              1u

/* Interrupt constants */
#if defined(VO__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in VO_SetInterruptMode() function.
     *  @{
     */
        #define VO_INTR_NONE      (uint16)(0x0000u)
        #define VO_INTR_RISING    (uint16)(0x0001u)
        #define VO_INTR_FALLING   (uint16)(0x0002u)
        #define VO_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define VO_INTR_MASK      (0x01u) 
#endif /* (VO__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define VO_PS                     (* (reg8 *) VO__PS)
/* Data Register */
#define VO_DR                     (* (reg8 *) VO__DR)
/* Port Number */
#define VO_PRT_NUM                (* (reg8 *) VO__PRT) 
/* Connect to Analog Globals */                                                  
#define VO_AG                     (* (reg8 *) VO__AG)                       
/* Analog MUX bux enable */
#define VO_AMUX                   (* (reg8 *) VO__AMUX) 
/* Bidirectional Enable */                                                        
#define VO_BIE                    (* (reg8 *) VO__BIE)
/* Bit-mask for Aliased Register Access */
#define VO_BIT_MASK               (* (reg8 *) VO__BIT_MASK)
/* Bypass Enable */
#define VO_BYP                    (* (reg8 *) VO__BYP)
/* Port wide control signals */                                                   
#define VO_CTL                    (* (reg8 *) VO__CTL)
/* Drive Modes */
#define VO_DM0                    (* (reg8 *) VO__DM0) 
#define VO_DM1                    (* (reg8 *) VO__DM1)
#define VO_DM2                    (* (reg8 *) VO__DM2) 
/* Input Buffer Disable Override */
#define VO_INP_DIS                (* (reg8 *) VO__INP_DIS)
/* LCD Common or Segment Drive */
#define VO_LCD_COM_SEG            (* (reg8 *) VO__LCD_COM_SEG)
/* Enable Segment LCD */
#define VO_LCD_EN                 (* (reg8 *) VO__LCD_EN)
/* Slew Rate Control */
#define VO_SLW                    (* (reg8 *) VO__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define VO_PRTDSI__CAPS_SEL       (* (reg8 *) VO__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define VO_PRTDSI__DBL_SYNC_IN    (* (reg8 *) VO__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define VO_PRTDSI__OE_SEL0        (* (reg8 *) VO__PRTDSI__OE_SEL0) 
#define VO_PRTDSI__OE_SEL1        (* (reg8 *) VO__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define VO_PRTDSI__OUT_SEL0       (* (reg8 *) VO__PRTDSI__OUT_SEL0) 
#define VO_PRTDSI__OUT_SEL1       (* (reg8 *) VO__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define VO_PRTDSI__SYNC_OUT       (* (reg8 *) VO__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(VO__SIO_CFG)
    #define VO_SIO_HYST_EN        (* (reg8 *) VO__SIO_HYST_EN)
    #define VO_SIO_REG_HIFREQ     (* (reg8 *) VO__SIO_REG_HIFREQ)
    #define VO_SIO_CFG            (* (reg8 *) VO__SIO_CFG)
    #define VO_SIO_DIFF           (* (reg8 *) VO__SIO_DIFF)
#endif /* (VO__SIO_CFG) */

/* Interrupt Registers */
#if defined(VO__INTSTAT)
    #define VO_INTSTAT            (* (reg8 *) VO__INTSTAT)
    #define VO_SNAP               (* (reg8 *) VO__SNAP)
    
	#define VO_0_INTTYPE_REG 		(* (reg8 *) VO__0__INTTYPE)
#endif /* (VO__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_VO_H */


/* [] END OF FILE */
