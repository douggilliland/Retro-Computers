/*******************************************************************************
* File Name: WaveDAC8_1_PM.c  
* Version 2.10
*
* Description:
*  This file provides the power manager source code to the API for 
*  the WaveDAC8 component.
*
********************************************************************************
* Copyright 2013, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions, 
* disclaimers, and limitations in the end user license agreement accompanying 
* the software package with which this file was provided.
*******************************************************************************/

#include "WaveDAC8_1.h"

static WaveDAC8_1_BACKUP_STRUCT  WaveDAC8_1_backup;


/*******************************************************************************
* Function Name: WaveDAC8_1_Sleep
********************************************************************************
*
* Summary:
*  Stops the component and saves its configuration. Should be called 
*  just prior to entering sleep.
*  
* Parameters:  
*  None
*
* Return: 
*  None
*
* Global variables:
*  WaveDAC8_1_backup:  The structure field 'enableState' is modified 
*  depending on the enable state of the block before entering to sleep mode.
*
* Reentrant:
*  No
*
*******************************************************************************/
void WaveDAC8_1_Sleep(void) 
{
	/* Save DAC8's enable state */

	WaveDAC8_1_backup.enableState = (WaveDAC8_1_VDAC8_ACT_PWR_EN == 
		(WaveDAC8_1_VDAC8_PWRMGR_REG & WaveDAC8_1_VDAC8_ACT_PWR_EN)) ? 1u : 0u ;
	
	WaveDAC8_1_Stop();
	WaveDAC8_1_SaveConfig();
}


/*******************************************************************************
* Function Name: WaveDAC8_1_Wakeup
********************************************************************************
*
* Summary:
*  Restores the component configuration. Should be called
*  just after awaking from sleep.
*  
* Parameters:  
*  None
*
* Return: 
*  void
*
* Global variables:
*  WaveDAC8_1_backup:  The structure field 'enableState' is used to 
*  restore the enable state of block after wakeup from sleep mode.
*
* Reentrant:
*  No
*
*******************************************************************************/
void WaveDAC8_1_Wakeup(void) 
{
	WaveDAC8_1_RestoreConfig();

	if(WaveDAC8_1_backup.enableState == 1u)
	{
		WaveDAC8_1_Enable();
	}
}


/* [] END OF FILE */
