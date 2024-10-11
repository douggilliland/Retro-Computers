/*******************************************************************************
* File Name: DAC_Clock.h
* Version 2.20
*
*  Description:
*   Provides the function and constant definitions for the clock component.
*
*  Note:
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_CLOCK_DAC_Clock_H)
#define CY_CLOCK_DAC_Clock_H

#include <cytypes.h>
#include <cyfitter.h>


/***************************************
* Conditional Compilation Parameters
***************************************/

/* Check to see if required defines such as CY_PSOC5LP are available */
/* They are defined starting with cy_boot v3.0 */
#if !defined (CY_PSOC5LP)
    #error Component cy_clock_v2_20 requires cy_boot v3.0 or later
#endif /* (CY_PSOC5LP) */


/***************************************
*        Function Prototypes
***************************************/

void DAC_Clock_Start(void) ;
void DAC_Clock_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void DAC_Clock_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void DAC_Clock_StandbyPower(uint8 state) ;
void DAC_Clock_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 DAC_Clock_GetDividerRegister(void) ;
void DAC_Clock_SetModeRegister(uint8 modeBitMask) ;
void DAC_Clock_ClearModeRegister(uint8 modeBitMask) ;
uint8 DAC_Clock_GetModeRegister(void) ;
void DAC_Clock_SetSourceRegister(uint8 clkSource) ;
uint8 DAC_Clock_GetSourceRegister(void) ;
#if defined(DAC_Clock__CFG3)
void DAC_Clock_SetPhaseRegister(uint8 clkPhase) ;
uint8 DAC_Clock_GetPhaseRegister(void) ;
#endif /* defined(DAC_Clock__CFG3) */

#define DAC_Clock_Enable()                       DAC_Clock_Start()
#define DAC_Clock_Disable()                      DAC_Clock_Stop()
#define DAC_Clock_SetDivider(clkDivider)         DAC_Clock_SetDividerRegister(clkDivider, 1u)
#define DAC_Clock_SetDividerValue(clkDivider)    DAC_Clock_SetDividerRegister((clkDivider) - 1u, 1u)
#define DAC_Clock_SetMode(clkMode)               DAC_Clock_SetModeRegister(clkMode)
#define DAC_Clock_SetSource(clkSource)           DAC_Clock_SetSourceRegister(clkSource)
#if defined(DAC_Clock__CFG3)
#define DAC_Clock_SetPhase(clkPhase)             DAC_Clock_SetPhaseRegister(clkPhase)
#define DAC_Clock_SetPhaseValue(clkPhase)        DAC_Clock_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(DAC_Clock__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define DAC_Clock_CLKEN              (* (reg8 *) DAC_Clock__PM_ACT_CFG)
#define DAC_Clock_CLKEN_PTR          ((reg8 *) DAC_Clock__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define DAC_Clock_CLKSTBY            (* (reg8 *) DAC_Clock__PM_STBY_CFG)
#define DAC_Clock_CLKSTBY_PTR        ((reg8 *) DAC_Clock__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define DAC_Clock_DIV_LSB            (* (reg8 *) DAC_Clock__CFG0)
#define DAC_Clock_DIV_LSB_PTR        ((reg8 *) DAC_Clock__CFG0)
#define DAC_Clock_DIV_PTR            ((reg16 *) DAC_Clock__CFG0)

/* Clock MSB divider configuration register. */
#define DAC_Clock_DIV_MSB            (* (reg8 *) DAC_Clock__CFG1)
#define DAC_Clock_DIV_MSB_PTR        ((reg8 *) DAC_Clock__CFG1)

/* Mode and source configuration register */
#define DAC_Clock_MOD_SRC            (* (reg8 *) DAC_Clock__CFG2)
#define DAC_Clock_MOD_SRC_PTR        ((reg8 *) DAC_Clock__CFG2)

#if defined(DAC_Clock__CFG3)
/* Analog clock phase configuration register */
#define DAC_Clock_PHASE              (* (reg8 *) DAC_Clock__CFG3)
#define DAC_Clock_PHASE_PTR          ((reg8 *) DAC_Clock__CFG3)
#endif /* defined(DAC_Clock__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define DAC_Clock_CLKEN_MASK         DAC_Clock__PM_ACT_MSK
#define DAC_Clock_CLKSTBY_MASK       DAC_Clock__PM_STBY_MSK

/* CFG2 field masks */
#define DAC_Clock_SRC_SEL_MSK        DAC_Clock__CFG2_SRC_SEL_MASK
#define DAC_Clock_MODE_MASK          (~(DAC_Clock_SRC_SEL_MSK))

#if defined(DAC_Clock__CFG3)
/* CFG3 phase mask */
#define DAC_Clock_PHASE_MASK         DAC_Clock__CFG3_PHASE_DLY_MASK
#endif /* defined(DAC_Clock__CFG3) */

#endif /* CY_CLOCK_DAC_Clock_H */


/* [] END OF FILE */
