/*******************************************************************************
* File Name: Status_Reg_2.h  
* Version 1.90
*
* Description:
*  This file containts Status Register function prototypes and register defines
*
* Note:
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_STATUS_REG_Status_Reg_2_H) /* CY_STATUS_REG_Status_Reg_2_H */
#define CY_STATUS_REG_Status_Reg_2_H

#include "cyfitter.h"

#if ((CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC3) || \
     (CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC4) || \
     (CYDEV_CHIP_FAMILY_USED == CYDEV_CHIP_FAMILY_PSOC5))
    #include "cytypes.h"
    #include "CyLib.h"
#else
    #include "syslib/cy_syslib.h"
#endif

    
/***************************************
*     Data Struct Definitions
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 statusState;

} Status_Reg_2_BACKUP_STRUCT;


/***************************************
*        Function Prototypes
***************************************/

uint8 Status_Reg_2_Read(void) ;
void Status_Reg_2_InterruptEnable(void) ;
void Status_Reg_2_InterruptDisable(void) ;
void Status_Reg_2_WriteMask(uint8 mask) ;
uint8 Status_Reg_2_ReadMask(void) ;


/***************************************
*           API Constants
***************************************/

#define Status_Reg_2_STATUS_INTR_ENBL    0x10u


/***************************************
*         Parameter Constants
***************************************/

/* Status Register Inputs */
#define Status_Reg_2_INPUTS              8


/***************************************
*             Registers
***************************************/

/* Status Register */
#define Status_Reg_2_Status             (* (reg8 *) Status_Reg_2_sts_sts_reg__STATUS_REG )
#define Status_Reg_2_Status_PTR         (  (reg8 *) Status_Reg_2_sts_sts_reg__STATUS_REG )
#define Status_Reg_2_Status_Mask        (* (reg8 *) Status_Reg_2_sts_sts_reg__MASK_REG )
#define Status_Reg_2_Status_Aux_Ctrl    (* (reg8 *) Status_Reg_2_sts_sts_reg__STATUS_AUX_CTL_REG )

#endif /* End CY_STATUS_REG_Status_Reg_2_H */


/* [] END OF FILE */
