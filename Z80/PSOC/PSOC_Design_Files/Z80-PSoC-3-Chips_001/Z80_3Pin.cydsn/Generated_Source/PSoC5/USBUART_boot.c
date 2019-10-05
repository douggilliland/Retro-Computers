/***************************************************************************//**
* \file USBUART_boot.c
* \version 3.20
*
* \brief
*  This file contains the Bootloader API for USBFS Component.
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_pvt.h"

#if defined(CYDEV_BOOTLOADER_IO_COMP) && ((CYDEV_BOOTLOADER_IO_COMP == CyBtldr_USBUART) || \
                                          (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_Custom_Interface))   

/***************************************
*    Bootloader Variables
***************************************/
    

static uint8  USBUART_started = 0u;


/*******************************************************************************
* Function Name: USBUART_CyBtldrCommStart
****************************************************************************//**
*
*  This function performs all required initialization for the USBFS component, 
*  waits on enumeration, and enables communication.
*
* \sideeffect
*  This function starts the USB with 3V or 5V operation.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_CyBtldrCommStart(void) 
{
    /* Enable Global Interrupts. Interrupts are mandatory for USBFS component operation. */
    CyGlobalIntEnable;

    /* Start USBFS Operation: device 0 and with 5V or 3V operation depend on Voltage Configuration in DWR. */
    USBUART_Start(0u, USBUART_DWR_POWER_OPERATION);

    /* USB component started, the correct enumeration will be checked in the first Read operation. */
    USBUART_started = 1u;
}


/*******************************************************************************
* Function Name: USBUART_CyBtldrCommStop.
****************************************************************************//**
*
*  This function performs all necessary shutdown tasks required for the USBFS 
*  component.
*  
*  \sideeffect
*   Calls the USBFS_Stop() function.
*
*******************************************************************************/
void USBUART_CyBtldrCommStop(void) 
{
    USBUART_Stop();
}


/*******************************************************************************
* Function Name: USBUART_CyBtldrCommReset.
****************************************************************************//**
*
*  This function resets receive and transmit communication buffers.
*
* \reentrant
*  No
*
*******************************************************************************/
void USBUART_CyBtldrCommReset(void) 
{
    USBUART_EnableOutEP(USBUART_BTLDR_OUT_EP); 
}


/*******************************************************************************
* Function Name: USBUART_CyBtldrCommWrite.
****************************************************************************//**
*
*  This function allows the caller to write data to the bootloader host. It 
*  handles polling to allow a block of data to be completely sent to the host 
*  device.
*
*  \param pData    A pointer to the block of data to send to the device
*  \param size     The number of bytes to write.
*  \param count    Pointer to an unsigned short variable to write the number of
*                  bytes actually written.
*  \param timeOut  Number of units to wait before returning because of a timeout.
*
* \return
*  Returns CYRET_SUCCESS if no problem was encountered or returns the value that 
*  best describes the problem. For more information, see the “Return Codes” 
*  section of the System Reference Guide.
*
* \reentrant
*  No
*
*******************************************************************************/
cystatus USBUART_CyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 *count, uint8 timeOut) CYSMALL
                                                            
{
    cystatus retCode;
    uint16 timeoutMs;

    /* Convert 10mS checks into 1mS checks. */
    timeoutMs = ((uint16) 10u * timeOut);

    /* Load data into IN endpoint to be read by host. */
    USBUART_LoadInEP(USBUART_BTLDR_IN_EP, pData, USBUART_BTLDR_SIZEOF_READ_BUFFER);

    /* Wait unitl host reads data from IN endpoint. */
    while ((USBUART_GetEPState(USBUART_BTLDR_IN_EP) == USBUART_IN_BUFFER_FULL) &&
           (0u != timeoutMs))
    {
        CyDelay(USBUART_BTLDR_WAIT_1_MS);
        timeoutMs--;
    }

    if (USBUART_GetEPState(USBUART_BTLDR_IN_EP) == USBUART_IN_BUFFER_FULL)
    {
        retCode = CYRET_TIMEOUT;
    }
    else
    {
        *count = size;
        retCode = CYRET_SUCCESS;
    }

    return (retCode);
}


/*******************************************************************************
* Function Name: USBUART_CyBtldrCommRead.
****************************************************************************//**
*
*  This function allows the caller to read data from the bootloader host. It 
*  handles polling to allow a block of data to be completely received from the 
*  host device.
*
*  \param pData    A pointer to the area to store the block of data received
*                  from the device.
*  \param size     The number of bytes to read.
*  \param count    Pointer to an unsigned short variable to write the number
*                  of bytes actually read.
*  \param timeOut  Number of units to wait before returning because of a timeOut.
*                  Timeout is measured in 10s of ms.
*
* \return
*  Returns CYRET_SUCCESS if no problem was encountered or returns the value that 
*  best describes the problem. For more information, see the “Return Codes” 
*  section of the System Reference Guide.
*
* \reentrant
*  No
*
*******************************************************************************/
cystatus USBUART_CyBtldrCommRead(uint8 pData[], uint16 size, uint16 *count, uint8 timeOut) CYSMALL
                                                            
{
    cystatus retCode;
    uint16 timeoutMs;

    /* Convert 10mS checks into 1mS checks. */
    timeoutMs = ((uint16) 10u * timeOut);

    if (size > USBUART_BTLDR_SIZEOF_WRITE_BUFFER)
    {
        size = USBUART_BTLDR_SIZEOF_WRITE_BUFFER;
    }

    /* Wait for enumeration first time. */
    if (0u != USBUART_started)
    {
        /* Wait for device enumeration. */
        while ((0u == USBUART_GetConfiguration()) && (0u != timeoutMs))
        {
            CyDelay(USBUART_BTLDR_WAIT_1_MS);
            timeoutMs--;
        }

        /* Enable OUT after enumeration. */
        if (0u != USBUART_GetConfiguration())
        {
            (void) USBUART_IsConfigurationChanged();  /* Clear configuration changes state status. */
            USBUART_CyBtldrCommReset();
            
            USBUART_started = 0u;
        }
    }
    else /* Check for configuration changes, has been done by Host. */
    {
        if (0u != USBUART_IsConfigurationChanged()) /* Host could send double SET_INTERFACE request or RESET. */
        {
            if (0u != USBUART_GetConfiguration())   /* Init OUT endpoints when device reconfigured. */
            {
                USBUART_CyBtldrCommReset();
            }
        }
    }

    timeoutMs = ((uint16) 10u * timeOut); /* Re-arm timeout */

    /* Wait unitl host writes data into OUT endpoint. */
    while ((USBUART_GetEPState(USBUART_BTLDR_OUT_EP) != USBUART_OUT_BUFFER_FULL) && \
           (0u != timeoutMs))
    {
        CyDelay(USBUART_BTLDR_WAIT_1_MS);
        timeoutMs--;
    }

    /* Read data from OUT endpoint if host wrote data into it. */
    if (USBUART_GetEPState(USBUART_BTLDR_OUT_EP) == USBUART_OUT_BUFFER_FULL)
    {
        *count = USBUART_ReadOutEP(USBUART_BTLDR_OUT_EP, pData, size);
        retCode = CYRET_SUCCESS;
    }
    else
    {
        *count = 0u;
        retCode = CYRET_TIMEOUT;
    }

    return (retCode);
}

#endif /* (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_USBUART) */


/* [] END OF FILE */
