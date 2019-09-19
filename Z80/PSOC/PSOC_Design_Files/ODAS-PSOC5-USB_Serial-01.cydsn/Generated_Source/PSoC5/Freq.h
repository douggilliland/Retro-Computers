/*******************************************************************************
* File Name: Freq.h  
* Version 1.80
*
* Description:
*  This file containts Control Register function prototypes and register defines
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_CONTROL_REG_Freq_H) /* CY_CONTROL_REG_Freq_H */
#define CY_CONTROL_REG_Freq_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} Freq_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    Freq_Write(uint8 control) ;
uint8   Freq_Read(void) ;

void Freq_SaveConfig(void) ;
void Freq_RestoreConfig(void) ;
void Freq_Sleep(void) ; 
void Freq_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define Freq_Control        (* (reg8 *) Freq_Sync_ctrl_reg__CONTROL_REG )
#define Freq_Control_PTR    (  (reg8 *) Freq_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_Freq_H */


/* [] END OF FILE */
