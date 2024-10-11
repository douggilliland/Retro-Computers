/*******************************************************************************
* File Name: SPI_SS_Override.h  
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

#if !defined(CY_CONTROL_REG_SPI_SS_Override_H) /* CY_CONTROL_REG_SPI_SS_Override_H */
#define CY_CONTROL_REG_SPI_SS_Override_H

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

} SPI_SS_Override_BACKUP_STRUCT;


/***************************************
*         Function Prototypes 
***************************************/

void    SPI_SS_Override_Write(uint8 control) ;
uint8   SPI_SS_Override_Read(void) ;

void SPI_SS_Override_SaveConfig(void) ;
void SPI_SS_Override_RestoreConfig(void) ;
void SPI_SS_Override_Sleep(void) ; 
void SPI_SS_Override_Wakeup(void) ;


/***************************************
*            Registers        
***************************************/

/* Control Register */
#define SPI_SS_Override_Control        (* (reg8 *) SPI_SS_Override_Sync_ctrl_reg__CONTROL_REG )
#define SPI_SS_Override_Control_PTR    (  (reg8 *) SPI_SS_Override_Sync_ctrl_reg__CONTROL_REG )

#endif /* End CY_CONTROL_REG_SPI_SS_Override_H */


/* [] END OF FILE */
