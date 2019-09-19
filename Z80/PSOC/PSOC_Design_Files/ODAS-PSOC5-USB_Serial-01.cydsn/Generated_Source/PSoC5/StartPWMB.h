/*******************************************************************************
* File Name: StartPWMB.h  
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

#if !defined(CY_CONTROL_REG_StartPWMB_H) /* CY_CONTROL_REG_StartPWMB_H */
#define CY_CONTROL_REG_StartPWMB_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} StartPWMB_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    StartPWMB_Write(uint8 control) ;
uint8   StartPWMB_Read(void) ;

void StartPWMB_SaveConfig(void) ;
void StartPWMB_RestoreConfig(void) ;
void StartPWMB_Sleep(void) ; 
void StartPWMB_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define StartPWMB_Control        (* (reg8 *) StartPWMB_Sync_ctrl_reg__CONTROL_REG )
#define StartPWMB_Control_PTR    (  (reg8 *) StartPWMB_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_StartPWMB_H */


/* [] END OF FILE */
