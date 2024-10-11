/*******************************************************************************
* File Name: StartPWMA.h  
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

#if !defined(CY_CONTROL_REG_StartPWMA_H) /* CY_CONTROL_REG_StartPWMA_H */
#define CY_CONTROL_REG_StartPWMA_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} StartPWMA_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    StartPWMA_Write(uint8 control) ;
uint8   StartPWMA_Read(void) ;

void StartPWMA_SaveConfig(void) ;
void StartPWMA_RestoreConfig(void) ;
void StartPWMA_Sleep(void) ; 
void StartPWMA_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define StartPWMA_Control        (* (reg8 *) StartPWMA_Sync_ctrl_reg__CONTROL_REG )
#define StartPWMA_Control_PTR    (  (reg8 *) StartPWMA_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_StartPWMA_H */


/* [] END OF FILE */
