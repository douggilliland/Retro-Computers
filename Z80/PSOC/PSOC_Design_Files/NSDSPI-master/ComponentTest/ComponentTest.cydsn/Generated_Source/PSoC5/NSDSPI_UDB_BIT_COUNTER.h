/*******************************************************************************
* File Name: NSDSPI_UDB_BIT_COUNTER.h
* Version 1.0
*
* Description:
*  This header file contains registers and constants associated with the
*  Count7 component.
*
* Note:
*
********************************************************************************
* Copyright 2013, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_COUNT7_NSDSPI_UDB_BIT_COUNTER_H)
#define CY_COUNT7_NSDSPI_UDB_BIT_COUNTER_H

#include "cytypes.h"
#include "cyfitter.h"


/***************************************
* Function Prototypes
***************************************/
void  NSDSPI_UDB_BIT_COUNTER_Init(void) ;
void  NSDSPI_UDB_BIT_COUNTER_Enable(void) ;
void  NSDSPI_UDB_BIT_COUNTER_Start(void) ;
void  NSDSPI_UDB_BIT_COUNTER_Stop(void) ;
void  NSDSPI_UDB_BIT_COUNTER_WriteCounter(uint8 count) ;
uint8 NSDSPI_UDB_BIT_COUNTER_ReadCounter(void) ;
void  NSDSPI_UDB_BIT_COUNTER_WritePeriod(uint8 period) ;
uint8 NSDSPI_UDB_BIT_COUNTER_ReadPeriod(void) ;
void  NSDSPI_UDB_BIT_COUNTER_SaveConfig(void) ;
void  NSDSPI_UDB_BIT_COUNTER_RestoreConfig(void) ;
void  NSDSPI_UDB_BIT_COUNTER_Sleep(void) ;
void  NSDSPI_UDB_BIT_COUNTER_Wakeup(void) ;


/***************************************
*     Data Struct Definitions
***************************************/
/* Structure to save registers before go to sleep */
typedef struct
{
    uint8 enableState;
    uint8 count;
} NSDSPI_UDB_BIT_COUNTER_BACKUP_STRUCT;


/***************************************
*           Global Variables
***************************************/
extern NSDSPI_UDB_BIT_COUNTER_BACKUP_STRUCT NSDSPI_UDB_BIT_COUNTER_backup;
extern uint8 NSDSPI_UDB_BIT_COUNTER_initVar;


/***************************************
* Initial Parameter
***************************************/
#define NSDSPI_UDB_BIT_COUNTER_INITIAL_PERIOD               (6u)


/***************************************
* Registers
***************************************/
#define NSDSPI_UDB_BIT_COUNTER_COUNT_REG                    (*(reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__COUNT_REG)
#define NSDSPI_UDB_BIT_COUNTER_COUNT_PTR                    ( (reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__COUNT_REG)
#define NSDSPI_UDB_BIT_COUNTER_PERIOD_REG                   (*(reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__PERIOD_REG)
#define NSDSPI_UDB_BIT_COUNTER_PERIOD_PTR                   ( (reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__PERIOD_REG)
#define NSDSPI_UDB_BIT_COUNTER_AUX_CONTROL_REG              (*(reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__CONTROL_AUX_CTL_REG)
#define NSDSPI_UDB_BIT_COUNTER_AUX_CONTROL_PTR              ( (reg8 *) NSDSPI_UDB_BIT_COUNTER_Counter7__CONTROL_AUX_CTL_REG)


/***************************************
* Register Constants
***************************************/
#define NSDSPI_UDB_BIT_COUNTER_COUNTER_START                (0x20u)

/* This constant is used to mask the TC bit (bit#7) in the Count register */
#define NSDSPI_UDB_BIT_COUNTER_COUNT_7BIT_MASK              (0x7Fu)


#endif /* CY_COUNT7_NSDSPI_UDB_BIT_COUNTER_H */


/* [] END OF FILE */
