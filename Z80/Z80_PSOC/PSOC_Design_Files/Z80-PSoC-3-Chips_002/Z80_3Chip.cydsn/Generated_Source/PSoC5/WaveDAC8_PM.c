/*******************************************************************************
* File Name: WaveDAC8_PM.c  
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

#include "WaveDAC8.h"

static WaveDAC8_BACKUP_STRUCT  WaveDAC8_backup;


/*******************************************************************************
* Function Name: WaveDAC8_Sleep
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
*  WaveDAC8_backup:  The structure field 'enableState' is modified 
*  depending on the enable state of the block before entering to sleep mode.
*
* Reentrant:
*  No
*
*******************************************************************************/
void WaveDAC8_Sleep(void) 
{
	/* Save DAC8's enable state */

	WaveDAC8_backup.enableState = (WaveDAC8_VDAC8_ACT_PWR_EN == 
		(WaveDAC8_VDAC8_PWRMGR_REG & WaveDAC8_VDAC8_ACT_PWR_EN)) ? 1u : 0u ;
	
	WaveDAC8_Stop();
	WaveDAC8_SaveConfig();
}


/*******************************************************************************
* Function Name: WaveDAC8_Wakeup
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
*  WaveDAC8_backup:  The structure field 'enableState' is used to 
*  restore the enable state of block after wakeup from sleep mode.
*
* Reentrant:
*  No
*
*******************************************************************************/
void WaveDAC8_Wakeup(void) 
{
	WaveDAC8_RestoreConfig();

	if(WaveDAC8_backup.enableState == 1u)
	{
		WaveDAC8_Enable();
	}
}


/* [] END OF FILE */
