/*******************************************************************************
* File Name: CPUA13.h  
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

#if !defined(CY_PINS_CPUA13_H) /* Pins CPUA13_H */
#define CY_PINS_CPUA13_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "CPUA13_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 CPUA13__PORT == 15 && ((CPUA13__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    CPUA13_Write(uint8 value);
void    CPUA13_SetDriveMode(uint8 mode);
uint8   CPUA13_ReadDataReg(void);
uint8   CPUA13_Read(void);
void    CPUA13_SetInterruptMode(uint16 position, uint16 mode);
uint8   CPUA13_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the CPUA13_SetDriveMode() function.
     *  @{
     */
        #define CPUA13_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define CPUA13_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define CPUA13_DM_RES_UP          PIN_DM_RES_UP
        #define CPUA13_DM_RES_DWN         PIN_DM_RES_DWN
        #define CPUA13_DM_OD_LO           PIN_DM_OD_LO
        #define CPUA13_DM_OD_HI           PIN_DM_OD_HI
        #define CPUA13_DM_STRONG          PIN_DM_STRONG
        #define CPUA13_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define CPUA13_MASK               CPUA13__MASK
#define CPUA13_SHIFT              CPUA13__SHIFT
#define CPUA13_WIDTH              1u

/* Interrupt constants */
#if defined(CPUA13__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in CPUA13_SetInterruptMode() function.
     *  @{
     */
        #define CPUA13_INTR_NONE      (uint16)(0x0000u)
        #define CPUA13_INTR_RISING    (uint16)(0x0001u)
        #define CPUA13_INTR_FALLING   (uint16)(0x0002u)
        #define CPUA13_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define CPUA13_INTR_MASK      (0x01u) 
#endif /* (CPUA13__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define CPUA13_PS                     (* (reg8 *) CPUA13__PS)
/* Data Register */
#define CPUA13_DR                     (* (reg8 *) CPUA13__DR)
/* Port Number */
#define CPUA13_PRT_NUM                (* (reg8 *) CPUA13__PRT) 
/* Connect to Analog Globals */                                                  
#define CPUA13_AG                     (* (reg8 *) CPUA13__AG)                       
/* Analog MUX bux enable */
#define CPUA13_AMUX                   (* (reg8 *) CPUA13__AMUX) 
/* Bidirectional Enable */                                                        
#define CPUA13_BIE                    (* (reg8 *) CPUA13__BIE)
/* Bit-mask for Aliased Register Access */
#define CPUA13_BIT_MASK               (* (reg8 *) CPUA13__BIT_MASK)
/* Bypass Enable */
#define CPUA13_BYP                    (* (reg8 *) CPUA13__BYP)
/* Port wide control signals */                                                   
#define CPUA13_CTL                    (* (reg8 *) CPUA13__CTL)
/* Drive Modes */
#define CPUA13_DM0                    (* (reg8 *) CPUA13__DM0) 
#define CPUA13_DM1                    (* (reg8 *) CPUA13__DM1)
#define CPUA13_DM2                    (* (reg8 *) CPUA13__DM2) 
/* Input Buffer Disable Override */
#define CPUA13_INP_DIS                (* (reg8 *) CPUA13__INP_DIS)
/* LCD Common or Segment Drive */
#define CPUA13_LCD_COM_SEG            (* (reg8 *) CPUA13__LCD_COM_SEG)
/* Enable Segment LCD */
#define CPUA13_LCD_EN                 (* (reg8 *) CPUA13__LCD_EN)
/* Slew Rate Control */
#define CPUA13_SLW                    (* (reg8 *) CPUA13__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define CPUA13_PRTDSI__CAPS_SEL       (* (reg8 *) CPUA13__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define CPUA13_PRTDSI__DBL_SYNC_IN    (* (reg8 *) CPUA13__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define CPUA13_PRTDSI__OE_SEL0        (* (reg8 *) CPUA13__PRTDSI__OE_SEL0) 
#define CPUA13_PRTDSI__OE_SEL1        (* (reg8 *) CPUA13__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define CPUA13_PRTDSI__OUT_SEL0       (* (reg8 *) CPUA13__PRTDSI__OUT_SEL0) 
#define CPUA13_PRTDSI__OUT_SEL1       (* (reg8 *) CPUA13__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define CPUA13_PRTDSI__SYNC_OUT       (* (reg8 *) CPUA13__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(CPUA13__SIO_CFG)
    #define CPUA13_SIO_HYST_EN        (* (reg8 *) CPUA13__SIO_HYST_EN)
    #define CPUA13_SIO_REG_HIFREQ     (* (reg8 *) CPUA13__SIO_REG_HIFREQ)
    #define CPUA13_SIO_CFG            (* (reg8 *) CPUA13__SIO_CFG)
    #define CPUA13_SIO_DIFF           (* (reg8 *) CPUA13__SIO_DIFF)
#endif /* (CPUA13__SIO_CFG) */

/* Interrupt Registers */
#if defined(CPUA13__INTSTAT)
    #define CPUA13_INTSTAT            (* (reg8 *) CPUA13__INTSTAT)
    #define CPUA13_SNAP               (* (reg8 *) CPUA13__SNAP)
    
	#define CPUA13_0_INTTYPE_REG 		(* (reg8 *) CPUA13__0__INTTYPE)
#endif /* (CPUA13__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_CPUA13_H */


/* [] END OF FILE */
