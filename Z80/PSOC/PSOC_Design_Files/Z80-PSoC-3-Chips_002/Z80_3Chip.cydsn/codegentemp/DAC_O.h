/*******************************************************************************
* File Name: DAC_O.h  
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

#if !defined(CY_PINS_DAC_O_H) /* Pins DAC_O_H */
#define CY_PINS_DAC_O_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "DAC_O_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 DAC_O__PORT == 15 && ((DAC_O__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    DAC_O_Write(uint8 value);
void    DAC_O_SetDriveMode(uint8 mode);
uint8   DAC_O_ReadDataReg(void);
uint8   DAC_O_Read(void);
void    DAC_O_SetInterruptMode(uint16 position, uint16 mode);
uint8   DAC_O_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the DAC_O_SetDriveMode() function.
     *  @{
     */
        #define DAC_O_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define DAC_O_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define DAC_O_DM_RES_UP          PIN_DM_RES_UP
        #define DAC_O_DM_RES_DWN         PIN_DM_RES_DWN
        #define DAC_O_DM_OD_LO           PIN_DM_OD_LO
        #define DAC_O_DM_OD_HI           PIN_DM_OD_HI
        #define DAC_O_DM_STRONG          PIN_DM_STRONG
        #define DAC_O_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define DAC_O_MASK               DAC_O__MASK
#define DAC_O_SHIFT              DAC_O__SHIFT
#define DAC_O_WIDTH              1u

/* Interrupt constants */
#if defined(DAC_O__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in DAC_O_SetInterruptMode() function.
     *  @{
     */
        #define DAC_O_INTR_NONE      (uint16)(0x0000u)
        #define DAC_O_INTR_RISING    (uint16)(0x0001u)
        #define DAC_O_INTR_FALLING   (uint16)(0x0002u)
        #define DAC_O_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define DAC_O_INTR_MASK      (0x01u) 
#endif /* (DAC_O__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define DAC_O_PS                     (* (reg8 *) DAC_O__PS)
/* Data Register */
#define DAC_O_DR                     (* (reg8 *) DAC_O__DR)
/* Port Number */
#define DAC_O_PRT_NUM                (* (reg8 *) DAC_O__PRT) 
/* Connect to Analog Globals */                                                  
#define DAC_O_AG                     (* (reg8 *) DAC_O__AG)                       
/* Analog MUX bux enable */
#define DAC_O_AMUX                   (* (reg8 *) DAC_O__AMUX) 
/* Bidirectional Enable */                                                        
#define DAC_O_BIE                    (* (reg8 *) DAC_O__BIE)
/* Bit-mask for Aliased Register Access */
#define DAC_O_BIT_MASK               (* (reg8 *) DAC_O__BIT_MASK)
/* Bypass Enable */
#define DAC_O_BYP                    (* (reg8 *) DAC_O__BYP)
/* Port wide control signals */                                                   
#define DAC_O_CTL                    (* (reg8 *) DAC_O__CTL)
/* Drive Modes */
#define DAC_O_DM0                    (* (reg8 *) DAC_O__DM0) 
#define DAC_O_DM1                    (* (reg8 *) DAC_O__DM1)
#define DAC_O_DM2                    (* (reg8 *) DAC_O__DM2) 
/* Input Buffer Disable Override */
#define DAC_O_INP_DIS                (* (reg8 *) DAC_O__INP_DIS)
/* LCD Common or Segment Drive */
#define DAC_O_LCD_COM_SEG            (* (reg8 *) DAC_O__LCD_COM_SEG)
/* Enable Segment LCD */
#define DAC_O_LCD_EN                 (* (reg8 *) DAC_O__LCD_EN)
/* Slew Rate Control */
#define DAC_O_SLW                    (* (reg8 *) DAC_O__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define DAC_O_PRTDSI__CAPS_SEL       (* (reg8 *) DAC_O__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define DAC_O_PRTDSI__DBL_SYNC_IN    (* (reg8 *) DAC_O__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define DAC_O_PRTDSI__OE_SEL0        (* (reg8 *) DAC_O__PRTDSI__OE_SEL0) 
#define DAC_O_PRTDSI__OE_SEL1        (* (reg8 *) DAC_O__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define DAC_O_PRTDSI__OUT_SEL0       (* (reg8 *) DAC_O__PRTDSI__OUT_SEL0) 
#define DAC_O_PRTDSI__OUT_SEL1       (* (reg8 *) DAC_O__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define DAC_O_PRTDSI__SYNC_OUT       (* (reg8 *) DAC_O__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(DAC_O__SIO_CFG)
    #define DAC_O_SIO_HYST_EN        (* (reg8 *) DAC_O__SIO_HYST_EN)
    #define DAC_O_SIO_REG_HIFREQ     (* (reg8 *) DAC_O__SIO_REG_HIFREQ)
    #define DAC_O_SIO_CFG            (* (reg8 *) DAC_O__SIO_CFG)
    #define DAC_O_SIO_DIFF           (* (reg8 *) DAC_O__SIO_DIFF)
#endif /* (DAC_O__SIO_CFG) */

/* Interrupt Registers */
#if defined(DAC_O__INTSTAT)
    #define DAC_O_INTSTAT            (* (reg8 *) DAC_O__INTSTAT)
    #define DAC_O_SNAP               (* (reg8 *) DAC_O__SNAP)
    
	#define DAC_O_0_INTTYPE_REG 		(* (reg8 *) DAC_O__0__INTTYPE)
#endif /* (DAC_O__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_DAC_O_H */


/* [] END OF FILE */
