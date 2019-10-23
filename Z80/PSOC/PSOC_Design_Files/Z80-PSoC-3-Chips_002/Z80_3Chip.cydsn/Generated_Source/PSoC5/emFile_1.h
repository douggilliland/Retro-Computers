/*******************************************************************************
* File Name: emFile_1.h
* Version 1.20
*
* Description:
*  This file contains the function prototypes and constants used in the emFile
*  component.
*
* Note:
*
********************************************************************************
* Copyright 2011-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_EM_FILE_emFile_1_H)
#define CY_EM_FILE_emFile_1_H

#include <cytypes.h>
#include "cyfitter.h"
#include "MMC_X_HW.h"


/***************************************
*   Conditional Compilation Parameters
***************************************/

/* Number of configured SD cards */
#define emFile_1_NUMBER_SD_CARDS    (1u)

/* Max frequency in KHz */
#define emFile_1_MAX_SPI_FREQ       (4000u)

/* Enable Write Protect */
#define emFile_1_WP0_EN             (0u)
#define emFile_1_WP1_EN             (0u)
#define emFile_1_WP2_EN             (0u)
#define emFile_1_WP3_EN             (0u)


/***************************************
*        Function Prototypes
***************************************/

void emFile_1_SaveConfig(void) ;
void emFile_1_RestoreConfig(void) ;
void emFile_1_Sleep(void) ;
void emFile_1_Wakeup(void) ;


/***************************************
*           API Constants
***************************************/

#define emFile_1_RET_SUCCCESS       (0x01u)
#define emFile_1_RET_FAIL           (0x00u)

#endif /* CY_EM_FILE_emFile_1_H */


/* [] END OF FILE */
