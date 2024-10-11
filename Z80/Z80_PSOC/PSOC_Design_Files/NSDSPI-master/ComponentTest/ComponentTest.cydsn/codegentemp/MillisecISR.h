/*******************************************************************************
* File Name: MillisecISR.h
* Version 1.70
*
*  Description:
*   Provides the function definitions for the Interrupt Controller.
*
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/
#if !defined(CY_ISR_MillisecISR_H)
#define CY_ISR_MillisecISR_H


#include <cytypes.h>
#include <cyfitter.h>

/* Interrupt Controller API. */
void MillisecISR_Start(void);
void MillisecISR_StartEx(cyisraddress address);
void MillisecISR_Stop(void);

CY_ISR_PROTO(MillisecISR_Interrupt);

void MillisecISR_SetVector(cyisraddress address);
cyisraddress MillisecISR_GetVector(void);

void MillisecISR_SetPriority(uint8 priority);
uint8 MillisecISR_GetPriority(void);

void MillisecISR_Enable(void);
uint8 MillisecISR_GetState(void);
void MillisecISR_Disable(void);

void MillisecISR_SetPending(void);
void MillisecISR_ClearPending(void);


/* Interrupt Controller Constants */

/* Address of the INTC.VECT[x] register that contains the Address of the MillisecISR ISR. */
#define MillisecISR_INTC_VECTOR            ((reg32 *) MillisecISR__INTC_VECT)

/* Address of the MillisecISR ISR priority. */
#define MillisecISR_INTC_PRIOR             ((reg8 *) MillisecISR__INTC_PRIOR_REG)

/* Priority of the MillisecISR interrupt. */
#define MillisecISR_INTC_PRIOR_NUMBER      MillisecISR__INTC_PRIOR_NUM

/* Address of the INTC.SET_EN[x] byte to bit enable MillisecISR interrupt. */
#define MillisecISR_INTC_SET_EN            ((reg32 *) MillisecISR__INTC_SET_EN_REG)

/* Address of the INTC.CLR_EN[x] register to bit clear the MillisecISR interrupt. */
#define MillisecISR_INTC_CLR_EN            ((reg32 *) MillisecISR__INTC_CLR_EN_REG)

/* Address of the INTC.SET_PD[x] register to set the MillisecISR interrupt state to pending. */
#define MillisecISR_INTC_SET_PD            ((reg32 *) MillisecISR__INTC_SET_PD_REG)

/* Address of the INTC.CLR_PD[x] register to clear the MillisecISR interrupt. */
#define MillisecISR_INTC_CLR_PD            ((reg32 *) MillisecISR__INTC_CLR_PD_REG)


#endif /* CY_ISR_MillisecISR_H */


/* [] END OF FILE */
