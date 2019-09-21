/*******************************************************************************
* File Name: CPUWR_n.h  
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

#if !defined(CY_PINS_CPUWR_n_H) /* Pins CPUWR_n_H */
#define CY_PINS_CPUWR_n_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUWR_n_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUWR_n__PORT == 15 && ((CPUWR_n__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUWR_n_Write(uint8 value);
void    CPUWR_n_SetDriveMode(uint8 mode);
uint8   CPUWR_n_ReadDataReg(void);
uint8   CPUWR_n_Read(void);
void    CPUWR_n_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUWR_n_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUWR_n_SetDriveMode() function.
     *  @{
     */
        #define CPUWR_n_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUWR_n_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUWR_n_DM_RES_UP          PIN_DM_RES_UP
        #define CPUWR_n_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUWR_n_DM_OD_LO           PIN_DM_OD_LO
        #define CPUWR_n_DM_OD_HI           PIN_DM_OD_HI
        #define CPUWR_n_DM_STRONG          PIN_DM_STRONG
        #define CPUWR_n_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUWR_n_MASK               CPUWR_n__MASK
#define CPUWR_n_SHIFT              CPUWR_n__SHIFT
#define CPUWR_n_WIDTH              1u

/* Interrupt constants */
#if defined(CPUWR_n__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUWR_n_SetInterruptMode() function.
     *  @{
     */
        #define CPUWR_n_INTR_NONE      (uint16)(0x0000u)
        #define CPUWR_n_INTR_RISING    (uint16)(0x0001u)
        #define CPUWR_n_INTR_FALLING   (uint16)(0x0002u)
        #define CPUWR_n_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUWR_n_INTR_MASK      (0x01u) 
#endif /* (CPUWR_n__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUWR_n_PS                     (* (reg8 *) CPUWR_n__PS)
/* Data Register */
#define CPUWR_n_DR                     (* (reg8 *) CPUWR_n__DR)
/* Port Number */
#define CPUWR_n_PRT_NUM                (* (reg8 *) CPUWR_n__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUWR_n_AG                     (* (reg8 *) CPUWR_n__AG)                       
/* Analog MUX bux enable */
#define CPUWR_n_AMUX                   (* (reg8 *) CPUWR_n__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUWR_n_BIE                    (* (reg8 *) CPUWR_n__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUWR_n_BIT_MASK               (* (reg8 *) CPUWR_n__BIT_MASK)
/* Bypass Enable */
#define CPUWR_n_BYP                    (* (reg8 *) CPUWR_n__BYP)
/* Port wide control signals */                                                   
#define CPUWR_n_CTL                    (* (reg8 *) CPUWR_n__CTL)
/* Drive Modes */
#define CPUWR_n_DM0                    (* (reg8 *) CPUWR_n__DM0) 
#define CPUWR_n_DM1                    (* (reg8 *) CPUWR_n__DM1)
#define CPUWR_n_DM2                    (* (reg8 *) CPUWR_n__DM2) 
/* Input Buffer Disable Override */
#define CPUWR_n_INP_DIS                (* (reg8 *) CPUWR_n__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUWR_n_LCD_COM_SEG            (* (reg8 *) CPUWR_n__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUWR_n_LCD_EN                 (* (reg8 *) CPUWR_n__LCD_EN)
/* Slew Rate Control */
#define CPUWR_n_SLW                    (* (reg8 *) CPUWR_n__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUWR_n_PRTDSI__CAPS_SEL       (* (reg8 *) CPUWR_n__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUWR_n_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUWR_n__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUWR_n_PRTDSI__OE_SEL0        (* (reg8 *) CPUWR_n__PRTDSI__OE_SEL0) 
#define CPUWR_n_PRTDSI__OE_SEL1        (* (reg8 *) CPUWR_n__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUWR_n_PRTDSI__OUT_SEL0       (* (reg8 *) CPUWR_n__PRTDSI__OUT_SEL0) 
#define CPUWR_n_PRTDSI__OUT_SEL1       (* (reg8 *) CPUWR_n__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUWR_n_PRTDSI__SYNC_OUT       (* (reg8 *) CPUWR_n__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUWR_n__SIO_CFG)
    #define CPUWR_n_SIO_HYST_EN        (* (reg8 *) CPUWR_n__SIO_HYST_EN)
    #define CPUWR_n_SIO_REG_HIFREQ     (* (reg8 *) CPUWR_n__SIO_REG_HIFREQ)
    #define CPUWR_n_SIO_CFG            (* (reg8 *) CPUWR_n__SIO_CFG)
    #define CPUWR_n_SIO_DIFF           (* (reg8 *) CPUWR_n__SIO_DIFF)
#endif /* (CPUWR_n__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUWR_n__INTSTAT)
    #define CPUWR_n_INTSTAT            (* (reg8 *) CPUWR_n__INTSTAT)
    #define CPUWR_n_SNAP               (* (reg8 *) CPUWR_n__SNAP)
    
	#define CPUWR_n_0_INTTYPE_REG 		(* (reg8 *) CPUWR_n__0__INTTYPE)
#endif /* (CPUWR_n__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUWR_n_H */


/* [] END OF FILE */
