/*******************************************************************************
* File Name: CyScBoostClk.h
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

#if !defined(CY_CLOCK_CyScBoostClk_H)
#define CY_CLOCK_CyScBoostClk_H

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

void CyScBoostClk_Start(void) ;
void CyScBoostClk_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void CyScBoostClk_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void CyScBoostClk_StandbyPower(uint8 state) ;
void CyScBoostClk_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 CyScBoostClk_GetDividerRegister(void) ;
void CyScBoostClk_SetModeRegister(uint8 modeBitMask) ;
void CyScBoostClk_ClearModeRegister(uint8 modeBitMask) ;
uint8 CyScBoostClk_GetModeRegister(void) ;
void CyScBoostClk_SetSourceRegister(uint8 clkSource) ;
uint8 CyScBoostClk_GetSourceRegister(void) ;
#if defined(CyScBoostClk__CFG3)
void CyScBoostClk_SetPhaseRegister(uint8 clkPhase) ;
uint8 CyScBoostClk_GetPhaseRegister(void) ;
#endif /* defined(CyScBoostClk__CFG3) */

#define CyScBoostClk_Enable()                       CyScBoostClk_Start()
#define CyScBoostClk_Disable()                      CyScBoostClk_Stop()
#define CyScBoostClk_SetDivider(clkDivider)         CyScBoostClk_SetDividerRegister(clkDivider, 1u)
#define CyScBoostClk_SetDividerValue(clkDivider)    CyScBoostClk_SetDividerRegister((clkDivider) - 1u, 1u)
#define CyScBoostClk_SetMode(clkMode)               CyScBoostClk_SetModeRegister(clkMode)
#define CyScBoostClk_SetSource(clkSource)           CyScBoostClk_SetSourceRegister(clkSource)
#if defined(CyScBoostClk__CFG3)
#define CyScBoostClk_SetPhase(clkPhase)             CyScBoostClk_SetPhaseRegister(clkPhase)
#define CyScBoostClk_SetPhaseValue(clkPhase)        CyScBoostClk_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(CyScBoostClk__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define CyScBoostClk_CLKEN              (* (reg8 *) CyScBoostClk__PM_ACT_CFG)
#define CyScBoostClk_CLKEN_PTR          ((reg8 *) CyScBoostClk__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define CyScBoostClk_CLKSTBY            (* (reg8 *) CyScBoostClk__PM_STBY_CFG)
#define CyScBoostClk_CLKSTBY_PTR        ((reg8 *) CyScBoostClk__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define CyScBoostClk_DIV_LSB            (* (reg8 *) CyScBoostClk__CFG0)
#define CyScBoostClk_DIV_LSB_PTR        ((reg8 *) CyScBoostClk__CFG0)
#define CyScBoostClk_DIV_PTR            ((reg16 *) CyScBoostClk__CFG0)

/* Clock MSB divider configuration register. */
#define CyScBoostClk_DIV_MSB            (* (reg8 *) CyScBoostClk__CFG1)
#define CyScBoostClk_DIV_MSB_PTR        ((reg8 *) CyScBoostClk__CFG1)

/* Mode and source configuration register */
#define CyScBoostClk_MOD_SRC            (* (reg8 *) CyScBoostClk__CFG2)
#define CyScBoostClk_MOD_SRC_PTR        ((reg8 *) CyScBoostClk__CFG2)

#if defined(CyScBoostClk__CFG3)
/* Analog clock phase configuration register */
#define CyScBoostClk_PHASE              (* (reg8 *) CyScBoostClk__CFG3)
#define CyScBoostClk_PHASE_PTR          ((reg8 *) CyScBoostClk__CFG3)
#endif /* defined(CyScBoostClk__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define CyScBoostClk_CLKEN_MASK         CyScBoostClk__PM_ACT_MSK
#define CyScBoostClk_CLKSTBY_MASK       CyScBoostClk__PM_STBY_MSK

/* CFG2 field masks */
#define CyScBoostClk_SRC_SEL_MSK        CyScBoostClk__CFG2_SRC_SEL_MASK
#define CyScBoostClk_MODE_MASK          (~(CyScBoostClk_SRC_SEL_MSK))

#if defined(CyScBoostClk__CFG3)
/* CFG3 phase mask */
#define CyScBoostClk_PHASE_MASK         CyScBoostClk__CFG3_PHASE_DLY_MASK
#endif /* defined(CyScBoostClk__CFG3) */

#endif /* CY_CLOCK_CyScBoostClk_H */


/* [] END OF FILE */
