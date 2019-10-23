/*******************************************************************************
* File Name: emFile_1_Clock_1.h
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

#if !defined(CY_CLOCK_emFile_1_Clock_1_H)
#define CY_CLOCK_emFile_1_Clock_1_H

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

void emFile_1_Clock_1_Start(void) ;
void emFile_1_Clock_1_Stop(void) ;

#if(CY_PSOC3 || CY_PSOC5LP)
void emFile_1_Clock_1_StopBlock(void) ;
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

void emFile_1_Clock_1_StandbyPower(uint8 state) ;
void emFile_1_Clock_1_SetDividerRegister(uint16 clkDivider, uint8 restart) 
                                ;
uint16 emFile_1_Clock_1_GetDividerRegister(void) ;
void emFile_1_Clock_1_SetModeRegister(uint8 modeBitMask) ;
void emFile_1_Clock_1_ClearModeRegister(uint8 modeBitMask) ;
uint8 emFile_1_Clock_1_GetModeRegister(void) ;
void emFile_1_Clock_1_SetSourceRegister(uint8 clkSource) ;
uint8 emFile_1_Clock_1_GetSourceRegister(void) ;
#if defined(emFile_1_Clock_1__CFG3)
void emFile_1_Clock_1_SetPhaseRegister(uint8 clkPhase) ;
uint8 emFile_1_Clock_1_GetPhaseRegister(void) ;
#endif /* defined(emFile_1_Clock_1__CFG3) */

#define emFile_1_Clock_1_Enable()                       emFile_1_Clock_1_Start()
#define emFile_1_Clock_1_Disable()                      emFile_1_Clock_1_Stop()
#define emFile_1_Clock_1_SetDivider(clkDivider)         emFile_1_Clock_1_SetDividerRegister(clkDivider, 1u)
#define emFile_1_Clock_1_SetDividerValue(clkDivider)    emFile_1_Clock_1_SetDividerRegister((clkDivider) - 1u, 1u)
#define emFile_1_Clock_1_SetMode(clkMode)               emFile_1_Clock_1_SetModeRegister(clkMode)
#define emFile_1_Clock_1_SetSource(clkSource)           emFile_1_Clock_1_SetSourceRegister(clkSource)
#if defined(emFile_1_Clock_1__CFG3)
#define emFile_1_Clock_1_SetPhase(clkPhase)             emFile_1_Clock_1_SetPhaseRegister(clkPhase)
#define emFile_1_Clock_1_SetPhaseValue(clkPhase)        emFile_1_Clock_1_SetPhaseRegister((clkPhase) + 1u)
#endif /* defined(emFile_1_Clock_1__CFG3) */


/***************************************
*             Registers
***************************************/

/* Register to enable or disable the clock */
#define emFile_1_Clock_1_CLKEN              (* (reg8 *) emFile_1_Clock_1__PM_ACT_CFG)
#define emFile_1_Clock_1_CLKEN_PTR          ((reg8 *) emFile_1_Clock_1__PM_ACT_CFG)

/* Register to enable or disable the clock */
#define emFile_1_Clock_1_CLKSTBY            (* (reg8 *) emFile_1_Clock_1__PM_STBY_CFG)
#define emFile_1_Clock_1_CLKSTBY_PTR        ((reg8 *) emFile_1_Clock_1__PM_STBY_CFG)

/* Clock LSB divider configuration register. */
#define emFile_1_Clock_1_DIV_LSB            (* (reg8 *) emFile_1_Clock_1__CFG0)
#define emFile_1_Clock_1_DIV_LSB_PTR        ((reg8 *) emFile_1_Clock_1__CFG0)
#define emFile_1_Clock_1_DIV_PTR            ((reg16 *) emFile_1_Clock_1__CFG0)

/* Clock MSB divider configuration register. */
#define emFile_1_Clock_1_DIV_MSB            (* (reg8 *) emFile_1_Clock_1__CFG1)
#define emFile_1_Clock_1_DIV_MSB_PTR        ((reg8 *) emFile_1_Clock_1__CFG1)

/* Mode and source configuration register */
#define emFile_1_Clock_1_MOD_SRC            (* (reg8 *) emFile_1_Clock_1__CFG2)
#define emFile_1_Clock_1_MOD_SRC_PTR        ((reg8 *) emFile_1_Clock_1__CFG2)

#if defined(emFile_1_Clock_1__CFG3)
/* Analog clock phase configuration register */
#define emFile_1_Clock_1_PHASE              (* (reg8 *) emFile_1_Clock_1__CFG3)
#define emFile_1_Clock_1_PHASE_PTR          ((reg8 *) emFile_1_Clock_1__CFG3)
#endif /* defined(emFile_1_Clock_1__CFG3) */


/**************************************
*       Register Constants
**************************************/

/* Power manager register masks */
#define emFile_1_Clock_1_CLKEN_MASK         emFile_1_Clock_1__PM_ACT_MSK
#define emFile_1_Clock_1_CLKSTBY_MASK       emFile_1_Clock_1__PM_STBY_MSK

/* CFG2 field masks */
#define emFile_1_Clock_1_SRC_SEL_MSK        emFile_1_Clock_1__CFG2_SRC_SEL_MASK
#define emFile_1_Clock_1_MODE_MASK          (~(emFile_1_Clock_1_SRC_SEL_MSK))

#if defined(emFile_1_Clock_1__CFG3)
/* CFG3 phase mask */
#define emFile_1_Clock_1_PHASE_MASK         emFile_1_Clock_1__CFG3_PHASE_DLY_MASK
#endif /* defined(emFile_1_Clock_1__CFG3) */

#endif /* CY_CLOCK_emFile_1_Clock_1_H */


/* [] END OF FILE */
