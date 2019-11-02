/*******************************************************************************
* File Name: CPUCLK.h
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

#if !defined(CY_CLOCK_CPUCLK_H)
#define CY_CLOCK_CPUCLK_H

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

void CPUCLK_Start(void) ;
void CPUCLK_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void CPUCLK_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void CPUCLK_StandbyPower(uint8 state) ;
void CPUCLK_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 CPUCLK_GetDividerRegister(void) ;
void CPUCLK_SetModeRegister(uint8 modeBitMask) ;
void CPUCLK_ClearModeRegister(uint8 modeBitMask) ;
uint8 CPUCLK_GetModeRegister(void) ;
void CPUCLK_SetSourceRegister(uint8 clkSource) ;
uint8 CPUCLK_GetSourceRegister(void) ;
#if defined(CPUCLK__CFG3)
void CPUCLK_SetPhaseRegister(uint8 clkPhase) ;
uint8 CPUCLK_GetPhaseRegister(void) ;
#endif /* defined(CPUCLK__CFG3) */

#define CPUCLK_Enable()                       CPUCLK_Start()
#define CPUCLK_Disable()                      CPUCLK_Stop()
#define CPUCLK_SetDivider(clkDivider)         CPUCLK_SetDividerRegister(clkDivider, 1u)
#define CPUCLK_SetDividerValue(clkDivider)    CPUCLK_SetDividerRegister((clkDivider) - 1u, 1u)
#define CPUCLK_SetMode(clkMode)               CPUCLK_SetModeRegister(clkMode)
#define CPUCLK_SetSource(clkSource)           CPUCLK_SetSourceRegister(clkSource)
#if defined(CPUCLK__CFG3)
#define CPUCLK_SetPhase(clkPhase)             CPUCLK_SetPhaseRegister(clkPhase)
#define CPUCLK_SetPhaseValue(clkPhase)        CPUCLK_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(CPUCLK__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define CPUCLK_CLKEN              (* (reg8 *) CPUCLK__PM_ACT_CFG)
#define CPUCLK_CLKEN_PTR          ((reg8 *) CPUCLK__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define CPUCLK_CLKSTBY            (* (reg8 *) CPUCLK__PM_STBY_CFG)
#define CPUCLK_CLKSTBY_PTR        ((reg8 *) CPUCLK__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define CPUCLK_DIV_LSB            (* (reg8 *) CPUCLK__CFG0)
#define CPUCLK_DIV_LSB_PTR        ((reg8 *) CPUCLK__CFG0)
#define CPUCLK_DIV_PTR            ((reg16 *) CPUCLK__CFG0)

/* Clock MSB divider configuration register. */
#define CPUCLK_DIV_MSB            (* (reg8 *) CPUCLK__CFG1)
#define CPUCLK_DIV_MSB_PTR        ((reg8 *) CPUCLK__CFG1)

/* Mode and source configuration register */
#define CPUCLK_MOD_SRC            (* (reg8 *) CPUCLK__CFG2)
#define CPUCLK_MOD_SRC_PTR        ((reg8 *) CPUCLK__CFG2)

#if defined(CPUCLK__CFG3)
/* Analog clock phase configuration register */
#define CPUCLK_PHASE              (* (reg8 *) CPUCLK__CFG3)
#define CPUCLK_PHASE_PTR          ((reg8 *) CPUCLK__CFG3)
#endif /* defined(CPUCLK__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define CPUCLK_CLKEN_MASK         CPUCLK__PM_ACT_MSK
#define CPUCLK_CLKSTBY_MASK       CPUCLK__PM_STBY_MSK

/* CFG2 field masks */
#define CPUCLK_SRC_SEL_MSK        CPUCLK__CFG2_SRC_SEL_MASK
#define CPUCLK_MODE_MASK          (~(CPUCLK_SRC_SEL_MSK))

#if defined(CPUCLK__CFG3)
/* CFG3 phase mask */
#define CPUCLK_PHASE_MASK         CPUCLK__CFG3_PHASE_DLY_MASK
#endif /* defined(CPUCLK__CFG3) */

#endif /* CY_CLOCK_CPUCLK_H */


/* [] END OF FILE */
