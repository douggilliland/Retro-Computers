/*******************************************************************************
* File Name: NSDSPI_1_CTRL.h  
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

#if !defined(CY_CONTROL_REG_NSDSPI_1_CTRL_H) /* CY_CONTROL_REG_NSDSPI_1_CTRL_H */
#define CY_CONTROL_REG_NSDSPI_1_CTRL_H

#include "cytypes.h"

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} NSDSPI_1_CTRL_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    NSDSPI_1_CTRL_Write(uint8 control) ;
uint8   NSDSPI_1_CTRL_Read(void) ;

void NSDSPI_1_CTRL_SaveConfig(void) ;
void NSDSPI_1_CTRL_RestoreConfig(void) ;
void NSDSPI_1_CTRL_Sleep(void) ; 
void NSDSPI_1_CTRL_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define NSDSPI_1_CTRL_Control        (* (reg8 *) NSDSPI_1_CTRL_Sync_ctrl_reg__CONTROL_REG )
#define NSDSPI_1_CTRL_Control_PTR    (  (reg8 *) NSDSPI_1_CTRL_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_NSDSPI_1_CTRL_H */


/* [] END OF FILE */
