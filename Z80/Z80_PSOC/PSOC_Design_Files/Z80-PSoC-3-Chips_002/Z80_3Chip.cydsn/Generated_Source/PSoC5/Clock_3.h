/*******************************************************************************
* File Name: Clock_3.h
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

#if !defined(CY_CLOCK_Clock_3_H)
#define CY_CLOCK_Clock_3_H

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

void Clock_3_Start(void) ;
void Clock_3_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void Clock_3_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void Clock_3_StandbyPower(uint8 state) ;
void Clock_3_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 Clock_3_GetDividerRegister(void) ;
void Clock_3_SetModeRegister(uint8 modeBitMask) ;
void Clock_3_ClearModeRegister(uint8 modeBitMask) ;
uint8 Clock_3_GetModeRegister(void) ;
void Clock_3_SetSourceRegister(uint8 clkSource) ;
uint8 Clock_3_GetSourceRegister(void) ;
#if defined(Clock_3__CFG3)
void Clock_3_SetPhaseRegister(uint8 clkPhase) ;
uint8 Clock_3_GetPhaseRegister(void) ;
#endif /* defined(Clock_3__CFG3) */

#define Clock_3_Enable()                       Clock_3_Start()
#define Clock_3_Disable()                      Clock_3_Stop()
#define Clock_3_SetDivider(clkDivider)         Clock_3_SetDividerRegister(clkDivider, 1u)
#define Clock_3_SetDividerValue(clkDivider)    Clock_3_SetDividerRegister((clkDivider) - 1u, 1u)
#define Clock_3_SetMode(clkMode)               Clock_3_SetModeRegister(clkMode)
#define Clock_3_SetSource(clkSource)           Clock_3_SetSourceRegister(clkSource)
#if defined(Clock_3__CFG3)
#define Clock_3_SetPhase(clkPhase)             Clock_3_SetPhaseRegister(clkPhase)
#define Clock_3_SetPhaseValue(clkPhase)        Clock_3_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(Clock_3__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define Clock_3_CLKEN              (* (reg8 *) Clock_3__PM_ACT_CFG)
#define Clock_3_CLKEN_PTR          ((reg8 *) Clock_3__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define Clock_3_CLKSTBY            (* (reg8 *) Clock_3__PM_STBY_CFG)
#define Clock_3_CLKSTBY_PTR        ((reg8 *) Clock_3__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define Clock_3_DIV_LSB            (* (reg8 *) Clock_3__CFG0)
#define Clock_3_DIV_LSB_PTR        ((reg8 *) Clock_3__CFG0)
#define Clock_3_DIV_PTR            ((reg16 *) Clock_3__CFG0)

/* Clock MSB divider configuration register. */
#define Clock_3_DIV_MSB            (* (reg8 *) Clock_3__CFG1)
#define Clock_3_DIV_MSB_PTR        ((reg8 *) Clock_3__CFG1)

/* Mode and source configuration register */
#define Clock_3_MOD_SRC            (* (reg8 *) Clock_3__CFG2)
#define Clock_3_MOD_SRC_PTR        ((reg8 *) Clock_3__CFG2)

#if defined(Clock_3__CFG3)
/* Analog clock phase configuration register */
#define Clock_3_PHASE              (* (reg8 *) Clock_3__CFG3)
#define Clock_3_PHASE_PTR          ((reg8 *) Clock_3__CFG3)
#endif /* defined(Clock_3__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define Clock_3_CLKEN_MASK         Clock_3__PM_ACT_MSK
#define Clock_3_CLKSTBY_MASK       Clock_3__PM_STBY_MSK

/* CFG2 field masks */
#define Clock_3_SRC_SEL_MSK        Clock_3__CFG2_SRC_SEL_MASK
#define Clock_3_MODE_MASK          (~(Clock_3_SRC_SEL_MSK))

#if defined(Clock_3__CFG3)
/* CFG3 phase mask */
#define Clock_3_PHASE_MASK         Clock_3__CFG3_PHASE_DLY_MASK
#endif /* defined(Clock_3__CFG3) */

#endif /* CY_CLOCK_Clock_3_H */


/* [] END OF FILE */
