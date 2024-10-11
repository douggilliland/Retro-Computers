/*******************************************************************************
* File Name: emFile_1_PM.c
* Version 1.20
*
* Description:
*  This file provides the API source code for Power Management of the emFile
*  component.
*
* Note:
*
*******************************************************************************
* Copyright 2011-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include <project.h>
#include "emFile_1.h"


/*******************************************************************************
* Function Name: emFile_1_SaveConfig
********************************************************************************
*
* Summary:
*  Saves SPI Masters configuration.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Reentrant:
*  No
*
*******************************************************************************/
void emFile_1_SaveConfig(void) 
{
    #if(emFile_1_NUMBER_SD_CARDS == 4u)
        emFile_1_SPI0_SaveConfig();
        emFile_1_SPI1_SaveConfig();
        emFile_1_SPI2_SaveConfig();
        emFile_1_SPI3_SaveConfig();
    #elif(emFile_1_NUMBER_SD_CARDS == 3u)
        emFile_1_SPI0_SaveConfig();
        emFile_1_SPI1_SaveConfig();
        emFile_1_SPI2_SaveConfig();
    #elif(emFile_1_NUMBER_SD_CARDS == 2u)
        emFile_1_SPI0_SaveConfig();
        emFile_1_SPI1_SaveConfig();
    #else
        emFile_1_SPI0_SaveConfig();
    #endif /* (emFile_1_NUMBER_SD_CARDS == 4u) */
}


/*******************************************************************************
* Function Name: emFile_1_RestoreConfig
********************************************************************************
*
* Summary:
*  Restores SPI Masters configuration.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Side Effects:
*  If this API is called without first calling SaveConfig then in the following
*  registers will be default values from Customizer:
*
*******************************************************************************/
void emFile_1_RestoreConfig(void) 
{
    #if(emFile_1_NUMBER_SD_CARDS == 4u)
        emFile_1_SPI0_RestoreConfig();
        emFile_1_SPI1_RestoreConfig();
        emFile_1_SPI2_RestoreConfig();
        emFile_1_SPI3_RestoreConfig();
    #elif(emFile_1_NUMBER_SD_CARDS == 3u)
        emFile_1_SPI0_SaveConfig();
        emFile_1_SPI1_SaveConfig();
        emFile_1_SPI2_SaveConfig();
    #elif(emFile_1_NUMBER_SD_CARDS == 2u)
        emFile_1_SPI0_SaveConfig();
        emFile_1_SPI1_SaveConfig();
    #else
        emFile_1_SPI0_SaveConfig();
    #endif /* (emFile_1_NUMBER_SD_CARDS == 4u) */
}


/*******************************************************************************
* Function Name: emFile_1_Sleep
********************************************************************************
*
* Summary:
*  Prepare emFile to go to sleep.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Reentrant:
*  No
*
*******************************************************************************/
void emFile_1_Sleep(void) 
{
    #if(emFile_1_NUMBER_SD_CARDS == 4u)
        emFile_1_SPI0_Sleep();
        emFile_1_SPI1_Sleep();
        emFile_1_SPI2_Sleep();
        emFile_1_SPI3_Sleep();
    #elif(emFile_1_NUMBER_SD_CARDS == 3u)
        emFile_1_SPI0_Sleep();
        emFile_1_SPI1_Sleep();
        emFile_1_SPI2_Sleep();
    #elif(emFile_1_NUMBER_SD_CARDS == 2u)
        emFile_1_SPI0_Sleep();
        emFile_1_SPI1_Sleep();
    #else
        emFile_1_SPI0_Sleep();
    #endif /* (emFile_1_NUMBER_SD_CARDS == 4u) */
}


/*******************************************************************************
* Function Name: emFile_1_Wakeup
********************************************************************************
*
* Summary:
*  Prepare SPIM Components to wake up.
*
* Parameters:
*  None
*
* Return:
*  None
*
* Reentrant:
*  No
*
*******************************************************************************/
void emFile_1_Wakeup(void) 
{
    #if(emFile_1_NUMBER_SD_CARDS == 4u)
        emFile_1_SPI0_Wakeup();
        emFile_1_SPI1_Wakeup();
        emFile_1_SPI2_Wakeup();
        emFile_1_SPI3_Wakeup();
    #elif(emFile_1_NUMBER_SD_CARDS == 3u)
        emFile_1_SPI0_Wakeup();
        emFile_1_SPI1_Wakeup();
        emFile_1_SPI2_Wakeup();
    #elif(emFile_1_NUMBER_SD_CARDS == 2u)
        emFile_1_SPI0_Wakeup();
        emFile_1_SPI1_Wakeup();
    #else
        emFile_1_SPI0_Wakeup();
    #endif /* (emFile_1_NUMBER_SD_CARDS == 4u) */
}


/* [] END OF FILE */
