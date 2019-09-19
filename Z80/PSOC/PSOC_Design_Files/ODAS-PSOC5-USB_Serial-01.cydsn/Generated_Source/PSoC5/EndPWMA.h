/*******************************************************************************
* File Name: EndPWMA.h  
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

#if !defined(CY_CONTROL_REG_EndPWMA_H) /* CY_CONTROL_REG_EndPWMA_H */
#define CY_CONTROL_REG_EndPWMA_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} EndPWMA_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    EndPWMA_Write(uint8 control) ;
uint8   EndPWMA_Read(void) ;

void EndPWMA_SaveConfig(void) ;
void EndPWMA_RestoreConfig(void) ;
void EndPWMA_Sleep(void) ; 
void EndPWMA_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define EndPWMA_Control        (* (reg8 *) EndPWMA_Sync_ctrl_reg__CONTROL_REG )
#define EndPWMA_Control_PTR    (  (reg8 *) EndPWMA_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_EndPWMA_H */


/* [] END OF FILE */
