/*******************************************************************************
* File Name: IOCS_n.h  
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

#if !defined(CY_PINS_IOCS_n_H) /* Pins IOCS_n_H */
#define CY_PINS_IOCS_n_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "IOCS_n_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 IOCS_n__PORT == 15 && ((IOCS_n__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    IOCS_n_Write(uint8 value);
void    IOCS_n_SetDriveMode(uint8 mode);
uint8   IOCS_n_ReadDataReg(void);
uint8   IOCS_n_Read(void);
void    IOCS_n_SetInterruptMode(uint16 position, uint16 mode);
uint8   IOCS_n_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the IOCS_n_SetDriveMode() function.
     *  @{
     */
        #define IOCS_n_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define IOCS_n_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define IOCS_n_DM_RES_UP          PIN_DM_RES_UP
        #define IOCS_n_DM_RES_DWN         PIN_DM_RES_DWN
        #define IOCS_n_DM_OD_LO           PIN_DM_OD_LO
        #define IOCS_n_DM_OD_HI           PIN_DM_OD_HI
        #define IOCS_n_DM_STRONG          PIN_DM_STRONG
        #define IOCS_n_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define IOCS_n_MASK               IOCS_n__MASK
#define IOCS_n_SHIFT              IOCS_n__SHIFT
#define IOCS_n_WIDTH              1u

/* Interrupt constants */
#if defined(IOCS_n__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in IOCS_n_SetInterruptMode() function.
     *  @{
     */
        #define IOCS_n_INTR_NONE      (uint16)(0x0000u)
        #define IOCS_n_INTR_RISING    (uint16)(0x0001u)
        #define IOCS_n_INTR_FALLING   (uint16)(0x0002u)
        #define IOCS_n_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define IOCS_n_INTR_MASK      (0x01u) 
#endif /* (IOCS_n__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define IOCS_n_PS                     (* (reg8 *) IOCS_n__PS)
/* Data Register */
#define IOCS_n_DR                     (* (reg8 *) IOCS_n__DR)
/* Port Number */
#define IOCS_n_PRT_NUM                (* (reg8 *) IOCS_n__PRT) 
/* Connect to Analog Globals */                                                  
#define IOCS_n_AG                     (* (reg8 *) IOCS_n__AG)                       
/* Analog MUX bux enable */
#define IOCS_n_AMUX                   (* (reg8 *) IOCS_n__AMUX) 
/* Bidirectional Enable */                                                        
#define IOCS_n_BIE                    (* (reg8 *) IOCS_n__BIE)
/* Bit-mask for Aliased Register Access */
#define IOCS_n_BIT_MASK               (* (reg8 *) IOCS_n__BIT_MASK)
/* Bypass Enable */
#define IOCS_n_BYP                    (* (reg8 *) IOCS_n__BYP)
/* Port wide control signals */                                                   
#define IOCS_n_CTL                    (* (reg8 *) IOCS_n__CTL)
/* Drive Modes */
#define IOCS_n_DM0                    (* (reg8 *) IOCS_n__DM0) 
#define IOCS_n_DM1                    (* (reg8 *) IOCS_n__DM1)
#define IOCS_n_DM2                    (* (reg8 *) IOCS_n__DM2) 
/* Input Buffer Disable Override */
#define IOCS_n_INP_DIS                (* (reg8 *) IOCS_n__INP_DIS)
/* LCD Common or Segment Drive */
#define IOCS_n_LCD_COM_SEG            (* (reg8 *) IOCS_n__LCD_COM_SEG)
/* Enable Segment LCD */
#define IOCS_n_LCD_EN                 (* (reg8 *) IOCS_n__LCD_EN)
/* Slew Rate Control */
#define IOCS_n_SLW                    (* (reg8 *) IOCS_n__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define IOCS_n_PRTDSI__CAPS_SEL       (* (reg8 *) IOCS_n__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define IOCS_n_PRTDSI__DBL_SYNC_IN    (* (reg8 *) IOCS_n__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define IOCS_n_PRTDSI__OE_SEL0        (* (reg8 *) IOCS_n__PRTDSI__OE_SEL0) 
#define IOCS_n_PRTDSI__OE_SEL1        (* (reg8 *) IOCS_n__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define IOCS_n_PRTDSI__OUT_SEL0       (* (reg8 *) IOCS_n__PRTDSI__OUT_SEL0) 
#define IOCS_n_PRTDSI__OUT_SEL1       (* (reg8 *) IOCS_n__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define IOCS_n_PRTDSI__SYNC_OUT       (* (reg8 *) IOCS_n__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(IOCS_n__SIO_CFG)
    #define IOCS_n_SIO_HYST_EN        (* (reg8 *) IOCS_n__SIO_HYST_EN)
    #define IOCS_n_SIO_REG_HIFREQ     (* (reg8 *) IOCS_n__SIO_REG_HIFREQ)
    #define IOCS_n_SIO_CFG            (* (reg8 *) IOCS_n__SIO_CFG)
    #define IOCS_n_SIO_DIFF           (* (reg8 *) IOCS_n__SIO_DIFF)
#endif /* (IOCS_n__SIO_CFG) */

/* Interrupt Registers */
#if defined(IOCS_n__INTSTAT)
    #define IOCS_n_INTSTAT            (* (reg8 *) IOCS_n__INTSTAT)
    #define IOCS_n_SNAP               (* (reg8 *) IOCS_n__SNAP)
    
	#define IOCS_n_0_INTTYPE_REG 		(* (reg8 *) IOCS_n__0__INTTYPE)
#endif /* (IOCS_n__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_IOCS_n_H */


/* [] END OF FILE */
