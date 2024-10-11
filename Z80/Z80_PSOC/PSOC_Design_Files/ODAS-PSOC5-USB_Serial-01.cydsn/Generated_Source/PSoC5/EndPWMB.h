/*******************************************************************************
* File Name: EndPWMB.h  
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

#if !defined(CY_CONTROL_REG_EndPWMB_H) /* CY_CONTROL_REG_EndPWMB_H */
#define CY_CONTROL_REG_EndPWMB_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} EndPWMB_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    EndPWMB_Write(uint8 control) ;
uint8   EndPWMB_Read(void) ;

void EndPWMB_SaveConfig(void) ;
void EndPWMB_RestoreConfig(void) ;
void EndPWMB_Sleep(void) ; 
void EndPWMB_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define EndPWMB_Control        (* (reg8 *) EndPWMB_Sync_ctrl_reg__CONTROL_REG )
#define EndPWMB_Control_PTR    (  (reg8 *) EndPWMB_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_EndPWMB_H */


/* [] END OF FILE */
