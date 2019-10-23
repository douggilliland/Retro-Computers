/*******************************************************************************
* File Name: SPI_SS.h  
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

#if !defined(CY_PINS_SPI_SS_H) /* Pins SPI_SS_H */
#define CY_PINS_SPI_SS_H

#include "cytypes.h"
#include "cyfitter.h"
#include "cypins.h"
#include "SPI_SS_aliases.h"

/* APIs are not generated for P15[7:6] */
#if !(CY_PSOC5A &&\
	 SPI_SS__PORT == 15 && ((SPI_SS__MASK & 0xC0) != 0))


/***************************************
*        Function Prototypes             
***************************************/    

/**
* \addtogroup group_general
* @{
*/
void    SPI_SS_Write(uint8 value);
void    SPI_SS_SetDriveMode(uint8 mode);
uint8   SPI_SS_ReadDataReg(void);
uint8   SPI_SS_Read(void);
void    SPI_SS_SetInterruptMode(uint16 position, uint16 mode);
uint8   SPI_SS_ClearInterrupt(void);
/** @} general */

/***************************************
*           API Constants        
***************************************/
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup driveMode Drive mode constants
     * \brief Constants to be passed as "mode" parameter in the SPI_SS_SetDriveMode() function.
     *  @{
     */
        #define SPI_SS_DM_ALG_HIZ         PIN_DM_ALG_HIZ
        #define SPI_SS_DM_DIG_HIZ         PIN_DM_DIG_HIZ
        #define SPI_SS_DM_RES_UP          PIN_DM_RES_UP
        #define SPI_SS_DM_RES_DWN         PIN_DM_RES_DWN
        #define SPI_SS_DM_OD_LO           PIN_DM_OD_LO
        #define SPI_SS_DM_OD_HI           PIN_DM_OD_HI
        #define SPI_SS_DM_STRONG          PIN_DM_STRONG
        #define SPI_SS_DM_RES_UPDWN       PIN_DM_RES_UPDWN
    /** @} driveMode */
/** @} group_constants */
    
/* Digital Port Constants */
#define SPI_SS_MASK               SPI_SS__MASK
#define SPI_SS_SHIFT              SPI_SS__SHIFT
#define SPI_SS_WIDTH              1u

/* Interrupt constants */
#if defined(SPI_SS__INTSTAT)
/**
* \addtogroup group_constants
* @{
*/
    /** \addtogroup intrMode Interrupt constants
     * \brief Constants to be passed as "mode" parameter in SPI_SS_SetInterruptMode() function.
     *  @{
     */
        #define SPI_SS_INTR_NONE      (uint16)(0x0000u)
        #define SPI_SS_INTR_RISING    (uint16)(0x0001u)
        #define SPI_SS_INTR_FALLING   (uint16)(0x0002u)
        #define SPI_SS_INTR_BOTH      (uint16)(0x0003u) 
    /** @} intrMode */
/** @} group_constants */

    #define SPI_SS_INTR_MASK      (0x01u) 
#endif /* (SPI_SS__INTSTAT) */


/***************************************
*             Registers        
***************************************/

/* Main Port Registers */
/* Pin State */
#define SPI_SS_PS                     (* (reg8 *) SPI_SS__PS)
/* Data Register */
#define SPI_SS_DR                     (* (reg8 *) SPI_SS__DR)
/* Port Number */
#define SPI_SS_PRT_NUM                (* (reg8 *) SPI_SS__PRT) 
/* Connect to Analog Globals */                                                  
#define SPI_SS_AG                     (* (reg8 *) SPI_SS__AG)                       
/* Analog MUX bux enable */
#define SPI_SS_AMUX                   (* (reg8 *) SPI_SS__AMUX) 
/* Bidirectional Enable */                                                        
#define SPI_SS_BIE                    (* (reg8 *) SPI_SS__BIE)
/* Bit-mask for Aliased Register Access */
#define SPI_SS_BIT_MASK               (* (reg8 *) SPI_SS__BIT_MASK)
/* Bypass Enable */
#define SPI_SS_BYP                    (* (reg8 *) SPI_SS__BYP)
/* Port wide control signals */                                                   
#define SPI_SS_CTL                    (* (reg8 *) SPI_SS__CTL)
/* Drive Modes */
#define SPI_SS_DM0                    (* (reg8 *) SPI_SS__DM0) 
#define SPI_SS_DM1                    (* (reg8 *) SPI_SS__DM1)
#define SPI_SS_DM2                    (* (reg8 *) SPI_SS__DM2) 
/* Input Buffer Disable Override */
#define SPI_SS_INP_DIS                (* (reg8 *) SPI_SS__INP_DIS)
/* LCD Common or Segment Drive */
#define SPI_SS_LCD_COM_SEG            (* (reg8 *) SPI_SS__LCD_COM_SEG)
/* Enable Segment LCD */
#define SPI_SS_LCD_EN                 (* (reg8 *) SPI_SS__LCD_EN)
/* Slew Rate Control */
#define SPI_SS_SLW                    (* (reg8 *) SPI_SS__SLW)

/* DSI Port Registers */
/* Global DSI Select Register */
#define SPI_SS_PRTDSI__CAPS_SEL       (* (reg8 *) SPI_SS__PRTDSI__CAPS_SEL) 
/* Double Sync Enable */
#define SPI_SS_PRTDSI__DBL_SYNC_IN    (* (reg8 *) SPI_SS__PRTDSI__DBL_SYNC_IN) 
/* Output Enable Select Drive Strength */
#define SPI_SS_PRTDSI__OE_SEL0        (* (reg8 *) SPI_SS__PRTDSI__OE_SEL0) 
#define SPI_SS_PRTDSI__OE_SEL1        (* (reg8 *) SPI_SS__PRTDSI__OE_SEL1) 
/* Port Pin Output Select Registers */
#define SPI_SS_PRTDSI__OUT_SEL0       (* (reg8 *) SPI_SS__PRTDSI__OUT_SEL0) 
#define SPI_SS_PRTDSI__OUT_SEL1       (* (reg8 *) SPI_SS__PRTDSI__OUT_SEL1) 
/* Sync Output Enable Registers */
#define SPI_SS_PRTDSI__SYNC_OUT       (* (reg8 *) SPI_SS__PRTDSI__SYNC_OUT) 

/* SIO registers */
#if defined(SPI_SS__SIO_CFG)
    #define SPI_SS_SIO_HYST_EN        (* (reg8 *) SPI_SS__SIO_HYST_EN)
    #define SPI_SS_SIO_REG_HIFREQ     (* (reg8 *) SPI_SS__SIO_REG_HIFREQ)
    #define SPI_SS_SIO_CFG            (* (reg8 *) SPI_SS__SIO_CFG)
    #define SPI_SS_SIO_DIFF           (* (reg8 *) SPI_SS__SIO_DIFF)
#endif /* (SPI_SS__SIO_CFG) */

/* Interrupt Registers */
#if defined(SPI_SS__INTSTAT)
    #define SPI_SS_INTSTAT            (* (reg8 *) SPI_SS__INTSTAT)
    #define SPI_SS_SNAP               (* (reg8 *) SPI_SS__SNAP)
    
	#define SPI_SS_0_INTTYPE_REG 		(* (reg8 *) SPI_SS__0__INTTYPE)
#endif /* (SPI_SS__INTSTAT) */

#endif /* CY_PSOC5A... */

#endif /*  CY_PINS_SPI_SS_H */


/* [] END OF FILE */
