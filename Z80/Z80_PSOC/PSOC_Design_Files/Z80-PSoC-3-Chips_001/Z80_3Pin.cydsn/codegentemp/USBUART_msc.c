/***************************************************************************//**
* \file USBUART_cdc.c
* \version 3.20
*
* \brief
*  This file contains the USB MSC Class request handler and global API for MSC 
*  class.
*
* Related Document:
*  Universal Serial Bus Class Definitions for Communication Devices Version 1.1
*
********************************************************************************
* \copyright
* Copyright 2012-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_msc.h"
#include "USBUART_pvt.h"
#include "cyapicallbacks.h"

#if (USBUART_HANDLE_MSC_REQUESTS)

/***************************************
*          Internal variables
***************************************/

static uint8 USBUART_lunCount = USBUART_MSC_LUN_NUMBER;


/*******************************************************************************
* Function Name: USBUART_DispatchMSCClassRqst
****************************************************************************//**
*   
*  \internal 
*  This routine dispatches MSC class requests.
*
* \return
*  Status of request processing: handled or not handled.
*
* \globalvars
*  USBUART_lunCount - stores number of LUN (logical units).
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_DispatchMSCClassRqst(void) 
{
    uint8 requestHandled = USBUART_FALSE;
    
    /* Get request data. */
    uint16 value  = USBUART_GET_UINT16(USBUART_wValueHiReg,  USBUART_wValueLoReg);
    uint16 dataLength = USBUART_GET_UINT16(USBUART_wLengthHiReg, USBUART_wLengthLoReg);
       
    /* Check request direction: D2H or H2D. */
    if (0u != (USBUART_bmRequestTypeReg & USBUART_RQST_DIR_D2H))
    {
        /* Handle direction from device to host. */
        
        if (USBUART_MSC_GET_MAX_LUN == USBUART_bRequestReg)
        {
            /* Check request fields. */
            if ((value  == USBUART_MSC_GET_MAX_LUN_WVALUE) &&
                (dataLength == USBUART_MSC_GET_MAX_LUN_WLENGTH))
            {
                /* Reply to Get Max LUN request: setup control read. */
                USBUART_currentTD.pData = &USBUART_lunCount;
                USBUART_currentTD.count =  USBUART_MSC_GET_MAX_LUN_WLENGTH;
                
                requestHandled  = USBUART_InitControlRead();
            }
        }
    }
    else
    {
        /* Handle direction from host to device. */
        
        if (USBUART_MSC_RESET == USBUART_bRequestReg)
        {
            /* Check request fields. */
            if ((value  == USBUART_MSC_RESET_WVALUE) &&
                (dataLength == USBUART_MSC_RESET_WLENGTH))
            {
                /* Handle to Bulk-Only Reset request: no data control transfer. */
                USBUART_currentTD.count = USBUART_MSC_RESET_WLENGTH;
                
            #ifdef USBUART_DISPATCH_MSC_CLASS_MSC_RESET_RQST_CALLBACK
                USBUART_DispatchMSCClass_MSC_RESET_RQST_Callback();
            #endif /* (USBUART_DISPATCH_MSC_CLASS_MSC_RESET_RQST_CALLBACK) */
                
                requestHandled = USBUART_InitNoDataControlTransfer();
            }
        }
    }
    
    return (requestHandled);
}


/*******************************************************************************
* Function Name: USBUART_MSC_SetLunCount
****************************************************************************//**
*
*  This function sets the number of logical units supported in the application. 
*  The default number of logical units is set in the component customizer.
*
*  \param lunCount: Count of the logical units. Valid range is between 1 and 16.
*
*
* \globalvars
*  USBUART_lunCount - stores number of LUN (logical units).
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_MSC_SetLunCount(uint8 lunCount) 
{
    USBUART_lunCount = (lunCount - 1u);
}


/*******************************************************************************
* Function Name: USBUART_MSC_GetLunCount
****************************************************************************//**
*
*  This function returns the number of logical units.
*
* \return
*   Number of the logical units.
*
* \globalvars
*  USBUART_lunCount - stores number of LUN (logical units).
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_MSC_GetLunCount(void) 
{
    return (USBUART_lunCount + 1u);
}   

#endif /* (USBUART_HANDLE_MSC_REQUESTS) */


/* [] END OF FILE */
