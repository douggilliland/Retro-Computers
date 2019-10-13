/*******************************************************************************
* File Name: USBUART_Dm.h  
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

#if !defined(CY_PINS_USBUART_Dm_H) /* Pins USBUART_Dm_H */
#define CY_PINS_USBUART_Dm_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "USBUART_Dm_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 USBUART_Dm__PORT == 15 && ((USBUART_Dm__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    USBUART_Dm_Write(uint8 value);
void    USBUART_Dm_SetDriveMode(uint8 mode);
uint8   USBUART_Dm_ReadDataReg(void);
uint8   USBUART_Dm_Read(void);
void    USBUART_Dm_SetInterruptMode(uint16 position, uint16 mode);
uint8   USBUART_Dm_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the USBUART_Dm_SetDriveMode() function.
     *  @{
     */
        #define USBUART_Dm_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define USBUART_Dm_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define USBUART_Dm_DM_RES_UP          PIN_DM_RES_UP
        #define USBUART_Dm_DM_RES_DWN         PIN_DM_RES_DWN
        #define USBUART_Dm_DM_OD_LO           PIN_DM_OD_LO
        #define USBUART_Dm_DM_OD_HI           PIN_DM_OD_HI
        #define USBUART_Dm_DM_STRONG          PIN_DM_STRONG
        #define USBUART_Dm_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define USBUART_Dm_MASK               USBUART_Dm__MASK
#define USBUART_Dm_SHIFT              USBUART_Dm__SHIFT
#define USBUART_Dm_WIDTH              1u

/* Interrupt constants */
#if defined(USBUART_Dm__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in USBUART_Dm_SetInterruptMode() function.
     *  @{
     */
        #define USBUART_Dm_INTR_NONE      (uint16)(0x0000u)
        #define USBUART_Dm_INTR_RISING    (uint16)(0x0001u)
        #define USBUART_Dm_INTR_FALLING   (uint16)(0x0002u)
        #define USBUART_Dm_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define USBUART_Dm_INTR_MASK      (0x01u) 
#endif /* (USBUART_Dm__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define USBUART_Dm_PS                     (* (reg8 *) USBUART_Dm__PS)
/* Data Register */
#define USBUART_Dm_DR                     (* (reg8 *) USBUART_Dm__DR)
/* Port Number */
#define USBUART_Dm_PRT_NUM                (* (reg8 *) USBUART_Dm__PRT) 
/* Connect to Analog Globals */                                                  
#define USBUART_Dm_AG                     (* (reg8 *) USBUART_Dm__AG)                       
/* Analog MUX bux enable */
#define USBUART_Dm_AMUX                   (* (reg8 *) USBUART_Dm__AMUX) 
/* Bidirectional Enable */                                                        
#define USBUART_Dm_BIE                    (* (reg8 *) USBUART_Dm__BIE)
/* Bit-mask for Aliased Register Access */
#define USBUART_Dm_BIT_MASK               (* (reg8 *) USBUART_Dm__BIT_MASK)
/* Bypass Enable */
#define USBUART_Dm_BYP                    (* (reg8 *) USBUART_Dm__BYP)
/* Port wide control signals */                                                   
#define USBUART_Dm_CTL                    (* (reg8 *) USBUART_Dm__CTL)
/* Drive Modes */
#define USBUART_Dm_DM0                    (* (reg8 *) USBUART_Dm__DM0) 
#define USBUART_Dm_DM1                    (* (reg8 *) USBUART_Dm__DM1)
#define USBUART_Dm_DM2                    (* (reg8 *) USBUART_Dm__DM2) 
/* Input Buffer Disable Override */
#define USBUART_Dm_INP_DIS                (* (reg8 *) USBUART_Dm__INP_DIS)
/* LCD Common or Segment Drive */
#define USBUART_Dm_LCD_COM_SEG            (* (reg8 *) USBUART_Dm__LCD_COM_SEG)
/* Enable Segment LCD */
#define USBUART_Dm_LCD_EN                 (* (reg8 *) USBUART_Dm__LCD_EN)
/* Slew Rate Control */
#define USBUART_Dm_SLW                    (* (reg8 *) USBUART_Dm__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define USBUART_Dm_PRTDSI__CAPS_SEL       (* (reg8 *) USBUART_Dm__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define USBUART_Dm_PRTDSI__DBL_SYNC_IN    (* (reg8 *) USBUART_Dm__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define USBUART_Dm_PRTDSI__OE_SEL0        (* (reg8 *) USBUART_Dm__PRTDSI__OE_SEL0) 
#define USBUART_Dm_PRTDSI__OE_SEL1        (* (reg8 *) USBUART_Dm__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define USBUART_Dm_PRTDSI__OUT_SEL0       (* (reg8 *) USBUART_Dm__PRTDSI__OUT_SEL0) 
#define USBUART_Dm_PRTDSI__OUT_SEL1       (* (reg8 *) USBUART_Dm__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define USBUART_Dm_PRTDSI__SYNC_OUT       (* (reg8 *) USBUART_Dm__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(USBUART_Dm__SIO_CFG)
    #define USBUART_Dm_SIO_HYST_EN        (* (reg8 *) USBUART_Dm__SIO_HYST_EN)
    #define USBUART_Dm_SIO_REG_HIFREQ     (* (reg8 *) USBUART_Dm__SIO_REG_HIFREQ)
    #define USBUART_Dm_SIO_CFG            (* (reg8 *) USBUART_Dm__SIO_CFG)
    #define USBUART_Dm_SIO_DIFF           (* (reg8 *) USBUART_Dm__SIO_DIFF)
#endif /* (USBUART_Dm__SIO_CFG) */

/* Interrupt Registers */
#if defined(USBUART_Dm__INTSTAT)
    #define USBUART_Dm_INTSTAT            (* (reg8 *) USBUART_Dm__INTSTAT)
    #define USBUART_Dm_SNAP               (* (reg8 *) USBUART_Dm__SNAP)
    
	#define USBUART_Dm_0_INTTYPE_REG 		(* (reg8 *) USBUART_Dm__0__INTTYPE)
#endif /* (USBUART_Dm__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_USBUART_Dm_H */


/* [] END OF FILE */
