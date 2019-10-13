/*******************************************************************************
* File Name: P78.h  
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

#if !defined(CY_PINS_P78_H) /* Pins P78_H */
#define CY_PINS_P78_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "P78_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 P78__PORT == 15 && ((P78__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    P78_Write(uint8 value);
void    P78_SetDriveMode(uint8 mode);
uint8   P78_ReadDataReg(void);
uint8   P78_Read(void);
void    P78_SetInterruptMode(uint16 position, uint16 mode);
uint8   P78_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the P78_SetDriveMode() function.
     *  @{
     */
        #define P78_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define P78_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define P78_DM_RES_UP          PIN_DM_RES_UP
        #define P78_DM_RES_DWN         PIN_DM_RES_DWN
        #define P78_DM_OD_LO           PIN_DM_OD_LO
        #define P78_DM_OD_HI           PIN_DM_OD_HI
        #define P78_DM_STRONG          PIN_DM_STRONG
        #define P78_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define P78_MASK               P78__MASK
#define P78_SHIFT              P78__SHIFT
#define P78_WIDTH              1u

/* Interrupt constants */
#if defined(P78__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in P78_SetInterruptMode() function.
     *  @{
     */
        #define P78_INTR_NONE      (uint16)(0x0000u)
        #define P78_INTR_RISING    (uint16)(0x0001u)
        #define P78_INTR_FALLING   (uint16)(0x0002u)
        #define P78_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define P78_INTR_MASK      (0x01u) 
#endif /* (P78__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define P78_PS                     (* (reg8 *) P78__PS)
/* Data Register */
#define P78_DR                     (* (reg8 *) P78__DR)
/* Port Number */
#define P78_PRT_NUM                (* (reg8 *) P78__PRT) 
/* Connect to Analog Globals */                                                  
#define P78_AG                     (* (reg8 *) P78__AG)                       
/* Analog MUX bux enable */
#define P78_AMUX                   (* (reg8 *) P78__AMUX) 
/* Bidirectional Enable */                                                        
#define P78_BIE                    (* (reg8 *) P78__BIE)
/* Bit-mask for Aliased Register Access */
#define P78_BIT_MASK               (* (reg8 *) P78__BIT_MASK)
/* Bypass Enable */
#define P78_BYP                    (* (reg8 *) P78__BYP)
/* Port wide control signals */                                                   
#define P78_CTL                    (* (reg8 *) P78__CTL)
/* Drive Modes */
#define P78_DM0                    (* (reg8 *) P78__DM0) 
#define P78_DM1                    (* (reg8 *) P78__DM1)
#define P78_DM2                    (* (reg8 *) P78__DM2) 
/* Input Buffer Disable Override */
#define P78_INP_DIS                (* (reg8 *) P78__INP_DIS)
/* LCD Common or Segment Drive */
#define P78_LCD_COM_SEG            (* (reg8 *) P78__LCD_COM_SEG)
/* Enable Segment LCD */
#define P78_LCD_EN                 (* (reg8 *) P78__LCD_EN)
/* Slew Rate Control */
#define P78_SLW                    (* (reg8 *) P78__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define P78_PRTDSI__CAPS_SEL       (* (reg8 *) P78__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define P78_PRTDSI__DBL_SYNC_IN    (* (reg8 *) P78__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define P78_PRTDSI__OE_SEL0        (* (reg8 *) P78__PRTDSI__OE_SEL0) 
#define P78_PRTDSI__OE_SEL1        (* (reg8 *) P78__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define P78_PRTDSI__OUT_SEL0       (* (reg8 *) P78__PRTDSI__OUT_SEL0) 
#define P78_PRTDSI__OUT_SEL1       (* (reg8 *) P78__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define P78_PRTDSI__SYNC_OUT       (* (reg8 *) P78__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(P78__SIO_CFG)
    #define P78_SIO_HYST_EN        (* (reg8 *) P78__SIO_HYST_EN)
    #define P78_SIO_REG_HIFREQ     (* (reg8 *) P78__SIO_REG_HIFREQ)
    #define P78_SIO_CFG            (* (reg8 *) P78__SIO_CFG)
    #define P78_SIO_DIFF           (* (reg8 *) P78__SIO_DIFF)
#endif /* (P78__SIO_CFG) */

/* Interrupt Registers */
#if defined(P78__INTSTAT)
    #define P78_INTSTAT            (* (reg8 *) P78__INTSTAT)
    #define P78_SNAP               (* (reg8 *) P78__SNAP)
    
	#define P78_0_INTTYPE_REG 		(* (reg8 *) P78__0__INTTYPE)
#endif /* (P78__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_P78_H */


/* [] END OF FILE */
