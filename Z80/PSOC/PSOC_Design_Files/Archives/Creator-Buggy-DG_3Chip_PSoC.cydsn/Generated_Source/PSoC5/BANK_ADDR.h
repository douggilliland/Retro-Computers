/*******************************************************************************
* File Name: BANK_ADDR.h  
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

#if !defined(CY_CONTROL_REG_BANK_ADDR_H) /* CY_CONTROL_REG_BANK_ADDR_H */
#define CY_CONTROL_REG_BANK_ADDR_H

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

} BANK_ADDR_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    BANK_ADDR_Write(uint8 control) ;
uint8   BANK_ADDR_Read(void) ;

void BANK_ADDR_SaveConfig(void) ;
void BANK_ADDR_RestoreConfig(void) ;
void BANK_ADDR_Sleep(void) ; 
void BANK_ADDR_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define BANK_ADDR_Control        (* (reg8 *) BANK_ADDR_Sync_ctrl_reg__CONTROL_REG )
#define BANK_ADDR_Control_PTR    (  (reg8 *) BANK_ADDR_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_BANK_ADDR_H */


/* [] END OF FILE */
