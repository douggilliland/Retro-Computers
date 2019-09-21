/*******************************************************************************
* File Name: MEM_CTRL.h  
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

#if !defined(CY_CONTROL_REG_MEM_CTRL_H) /* CY_CONTROL_REG_MEM_CTRL_H */
#define CY_CONTROL_REG_MEM_CTRL_H

#include "cyfitter.h"

#if ((CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC3) || \
     (CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC4) || \
     (CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC5))
    #include "cytypes.h"
#else
    #include "syslib/cy_syslib.h"
#endif

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 controlState;

} MEM_CTRL_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    MEM_CTRL_Write(uint8 control) ;
uint8   MEM_CTRL_Read(void) ;

void MEM_CTRL_SaveConfig(void) ;
void MEM_CTRL_RestoreConfig(void) ;
void MEM_CTRL_Sleep(void) ; 
void MEM_CTRL_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define MEM_CTRL_Control        (* (reg8 *) MEM_CTRL_Sync_ctrl_reg__CONTROL_REG )
#define MEM_CTRL_Control_PTR    (  (reg8 *) MEM_CTRL_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_MEM_CTRL_H */


/* [] END OF FILE */
