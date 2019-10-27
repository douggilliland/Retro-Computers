/*******************************************************************************
* File Name: WaveDAC8_DacClk.h
* Version 2.10
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

#if !defined(CY_CLOCK_WaveDAC8_DacClk_H)
#define CY_CLOCK_WaveDAC8_DacClk_H

#include <cytypes.h>
#include <cyfitter.h>


/***************************************
* Conditional Compilation Parameters
***************************************/

/* Check to see if required defines such as CY_PSOC5LP are available */
/* They are defined starting with cy_boot v3.0 */
#if !defined (CY_PSOC5LP)
    #error Component cy_clock_v2_10 requires cy_boot v3.0 or later
#endif /* (CY_PSOC5LP) */


/***************************************
*        Function Prototypes
***************************************/

void WaveDAC8_DacClk_Start(void) ;
void WaveDAC8_DacClk_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void WaveDAC8_DacClk_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void WaveDAC8_DacClk_StandbyPower(uint8 state) ;
void WaveDAC8_DacClk_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 WaveDAC8_DacClk_GetDividerRegister(void) ;
void WaveDAC8_DacClk_SetModeRegister(uint8 modeBitMask) ;
void WaveDAC8_DacClk_ClearModeRegister(uint8 modeBitMask) ;
uint8 WaveDAC8_DacClk_GetModeRegister(void) ;
void WaveDAC8_DacClk_SetSourceRegister(uint8 clkSource) ;
uint8 WaveDAC8_DacClk_GetSourceRegister(void) ;
#if defined(WaveDAC8_DacClk__CFG3)
void WaveDAC8_DacClk_SetPhaseRegister(uint8 clkPhase) ;
uint8 WaveDAC8_DacClk_GetPhaseRegister(void) ;
#endif /* defined(WaveDAC8_DacClk__CFG3) */

#define WaveDAC8_DacClk_Enable()                       WaveDAC8_DacClk_Start()
#define WaveDAC8_DacClk_Disable()                      WaveDAC8_DacClk_Stop()
#define WaveDAC8_DacClk_SetDivider(clkDivider)         WaveDAC8_DacClk_SetDividerRegister(clkDivider, 1u)
#define WaveDAC8_DacClk_SetDividerValue(clkDivider)    WaveDAC8_DacClk_SetDividerRegister((clkDivider) - 1u, 1u)
#define WaveDAC8_DacClk_SetMode(clkMode)               WaveDAC8_DacClk_SetModeRegister(clkMode)
#define WaveDAC8_DacClk_SetSource(clkSource)           WaveDAC8_DacClk_SetSourceRegister(clkSource)
#if defined(WaveDAC8_DacClk__CFG3)
#define WaveDAC8_DacClk_SetPhase(clkPhase)             WaveDAC8_DacClk_SetPhaseRegister(clkPhase)
#define WaveDAC8_DacClk_SetPhaseValue(clkPhase)        WaveDAC8_DacClk_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(WaveDAC8_DacClk__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define WaveDAC8_DacClk_CLKEN              (* (reg8 *) WaveDAC8_DacClk__PM_ACT_CFG)
#define WaveDAC8_DacClk_CLKEN_PTR          ((reg8 *) WaveDAC8_DacClk__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define WaveDAC8_DacClk_CLKSTBY            (* (reg8 *) WaveDAC8_DacClk__PM_STBY_CFG)
#define WaveDAC8_DacClk_CLKSTBY_PTR        ((reg8 *) WaveDAC8_DacClk__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define WaveDAC8_DacClk_DIV_LSB            (* (reg8 *) WaveDAC8_DacClk__CFG0)
#define WaveDAC8_DacClk_DIV_LSB_PTR        ((reg8 *) WaveDAC8_DacClk__CFG0)
#define WaveDAC8_DacClk_DIV_PTR            ((reg16 *) WaveDAC8_DacClk__CFG0)

/* Clock MSB divider configuration register. */
#define WaveDAC8_DacClk_DIV_MSB            (* (reg8 *) WaveDAC8_DacClk__CFG1)
#define WaveDAC8_DacClk_DIV_MSB_PTR        ((reg8 *) WaveDAC8_DacClk__CFG1)

/* Mode and source configuration register */
#define WaveDAC8_DacClk_MOD_SRC            (* (reg8 *) WaveDAC8_DacClk__CFG2)
#define WaveDAC8_DacClk_MOD_SRC_PTR        ((reg8 *) WaveDAC8_DacClk__CFG2)

#if defined(WaveDAC8_DacClk__CFG3)
/* Analog clock phase configuration register */
#define WaveDAC8_DacClk_PHASE              (* (reg8 *) WaveDAC8_DacClk__CFG3)
#define WaveDAC8_DacClk_PHASE_PTR          ((reg8 *) WaveDAC8_DacClk__CFG3)
#endif /* defined(WaveDAC8_DacClk__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define WaveDAC8_DacClk_CLKEN_MASK         WaveDAC8_DacClk__PM_ACT_MSK
#define WaveDAC8_DacClk_CLKSTBY_MASK       WaveDAC8_DacClk__PM_STBY_MSK

/* CFG2 field masks */
#define WaveDAC8_DacClk_SRC_SEL_MSK        WaveDAC8_DacClk__CFG2_SRC_SEL_MASK
#define WaveDAC8_DacClk_MODE_MASK          (~(WaveDAC8_DacClk_SRC_SEL_MSK))

#if defined(WaveDAC8_DacClk__CFG3)
/* CFG3 phase mask */
#define WaveDAC8_DacClk_PHASE_MASK         WaveDAC8_DacClk__CFG3_PHASE_DLY_MASK
#endif /* defined(WaveDAC8_DacClk__CFG3) */

#endif /* CY_CLOCK_WaveDAC8_DacClk_H */


/* [] END OF FILE */
