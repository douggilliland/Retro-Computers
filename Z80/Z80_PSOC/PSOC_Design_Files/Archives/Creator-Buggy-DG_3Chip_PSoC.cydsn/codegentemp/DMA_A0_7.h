/*******************************************************************************
* File Name: DMA_A0_7.h  
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

#if !defined(CY_CONTROL_REG_DMA_A0_7_H) /* CY_CONTROL_REG_DMA_A0_7_H */
#define CY_CONTROL_REG_DMA_A0_7_H

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

} DMA_A0_7_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    DMA_A0_7_Write(uint8 control) ;
uint8   DMA_A0_7_Read(void) ;

void DMA_A0_7_SaveConfig(void) ;
void DMA_A0_7_RestoreConfig(void) ;
void DMA_A0_7_Sleep(void) ; 
void DMA_A0_7_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define DMA_A0_7_Control        (* (reg8 *) DMA_A0_7_Sync_ctrl_reg__CONTROL_REG )
#define DMA_A0_7_Control_PTR    (  (reg8 *) DMA_A0_7_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_DMA_A0_7_H */


/* [] END OF FILE */
