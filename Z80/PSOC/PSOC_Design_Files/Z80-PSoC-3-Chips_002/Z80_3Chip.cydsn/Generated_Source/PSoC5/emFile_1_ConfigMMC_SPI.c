/*******************************************************************************
* File Name: emFile_1_MMC_HW_SPI.c
* Version 1.20
*
* Description:
*  Contains a set of File System APIs that implement SPI mode driver operation.
*
* Note:
*
********************************************************************************
* Copyright 2011-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/


/*********************************************************************
*                SEGGER MICROCONTROLLER GmbH & Co. KG                *
*        Solutions for real time microcontroller applications        *
**********************************************************************
*                                                                    *
*        (c) 2003-2010     SEGGER Microcontroller GmbH & Co KG       *
*                                                                    *
*        Internet: www.segger.com    Support:  support@segger.com    *
*                                                                    *
**********************************************************************

**** emFile file system for embedded applications ****
emFile is protected by international copyright laws. Knowledge of the
source code may not be used to write a similar product. This file may
only be used in accordance with a license and should not be re-
distributed in any way. We appreciate your understanding and fairness.
----------------------------------------------------------------------
----------------------------------------------------------------------
File        : ConfigMMC_SPI.c
Purpose     : Configuration file for FS with MMC SPI mode driver
---------------------------END-OF-HEADER------------------------------
*/

#include "FS.h"
#include "emFile_1.h"

/*********************************************************************
*
*       Defines, configurable
*
*       This section is the only section which requires changes
*       using the MMC/SD card mode disk driver as a single device.
*
**********************************************************************
*/
#define ALLOC_SIZE                 (0x1000)      /* Size defined in bytes */

/*********************************************************************
*
*       Static data
*
**********************************************************************
*/
static U32   _aMemBlock[ALLOC_SIZE / 4u];      /* Memory pool used for semi-dynamic allocation. */

/*********************************************************************
*
*       Public code
*
*       This section does not require modifications in most systems.
*
**********************************************************************
*/

/*********************************************************************
*
*       FS_X_AddDevices
*
*  Function description
*    This function is called by the FS during FS_Init().
*    It is supposed to add all devices, using primarily FS_AddDevice().
*
*  Note
*    (1) Other API functions
*        Other API functions may NOT be called, since this function is called
*        during initialization. The devices are not yet ready at this point.
*/
void FS_X_AddDevices(void)
{
    #if(CY_PSOC5)
        FS_AssignMemory(&_aMemBlock[0u], sizeof(_aMemBlock));
    #else
        FS_AssignMemory(&_aMemBlock[1u], sizeof(_aMemBlock));
    #endif/* (CY_PSOC5) */

    #if (emFile_1_NUMBER_SD_CARDS == 4u)
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
    #elif (emFile_1_NUMBER_SD_CARDS == 3u)
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
    #elif (emFile_1_NUMBER_SD_CARDS == 2u)
        FS_AddDevice(&FS_MMC_SPI_Driver);
        FS_AddDevice(&FS_MMC_SPI_Driver);
    #else
        FS_AddDevice(&FS_MMC_SPI_Driver);
    #endif /* (emFile_1_NUMBER_SD_CARDS == 4u) */
}

/*********************************************************************
*
*       FS_X_GetTimeDate
*
*  Description:
*    Current time and date in a format suitable for the file system.
*
*    Bit 0-4:   2-second count (0-29)
*    Bit 5-10:  Minutes (0-59)
*    Bit 11-15: Hours (0-23)
*    Bit 16-20: Day of month (1-31)
*    Bit 21-24: Month of year (1-12)
*    Bit 25-31: Count of years from 1980 (0-127)
*
*/
U32 FS_X_GetTimeDate(void)
{
  U32 r;
  U16 Sec, Min, Hour;
  U16 Day, Month, Year;

  Sec   = 0;        /* 0 based.  Valid range: 0..59 */
  Min   = 0;        /* 0 based.  Valid range: 0..59 */
  Hour  = 0;        /* 0 based.  Valid range: 0..23 */
  Day   = 1;        /* 1 based.    Means that 1 is 1. Valid range is 1..31 (depending on month) */
  Month = 1;        /* 1 based.    Means that January is 1. Valid range is 1..12. */
  Year  = 0;        /* 1980 based. Means that 2007 would be 27. */
  r   = Sec / 2 + (Min << 5) + (Hour  << 11);
  r  |= (U32)(Day + (Month << 5) + (Year  << 9)) << 16;
  return r;
}

/* [] END OF FILE */
