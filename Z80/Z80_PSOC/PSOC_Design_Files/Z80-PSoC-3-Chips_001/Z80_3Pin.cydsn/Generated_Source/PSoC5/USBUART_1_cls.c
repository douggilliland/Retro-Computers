/***************************************************************************//**
* \file USBUART_1_cls.c
* \version 3.20
*
* \brief
*  This file contains the USB Class request handler.
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_1_pvt.h"
#include "cyapicallbacks.h"

#if(USBUART_1_EXTERN_CLS == USBUART_1_FALSE)

/***************************************
* User Implemented Class Driver Declarations.
***************************************/
/* `#START USER_DEFINED_CLASS_DECLARATIONS` Place your declaration here */

/* `#END` */


/*******************************************************************************
* Function Name: USBUART_1_DispatchClassRqst
****************************************************************************//**
*  This routine dispatches class specific requests depend on interface class.
*
* \return
*  requestHandled.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_1_DispatchClassRqst(void) 
{
    uint8 interfaceNumber;
    uint8 requestHandled = USBUART_1_FALSE;

    /* Get interface to which request is intended. */
    switch (USBUART_1_bmRequestTypeReg & USBUART_1_RQST_RCPT_MASK)
    {
        case USBUART_1_RQST_RCPT_IFC:
            /* Class-specific request directed to interface: wIndexLoReg 
            * contains interface number.
            */
            interfaceNumber = (uint8) USBUART_1_wIndexLoReg;
            break;
        
        case USBUART_1_RQST_RCPT_EP:
            /* Class-specific request directed to endpoint: wIndexLoReg contains 
            * endpoint number. Find interface related to endpoint. 
            */
            interfaceNumber = USBUART_1_EP[USBUART_1_wIndexLoReg & USBUART_1_DIR_UNUSED].interface;
            break;
            
        default:
            /* Default interface is zero. */
            interfaceNumber = 0u;
            break;
    }
    
    /* Check that interface is within acceptable range */
    if (interfaceNumber <= USBUART_1_MAX_INTERFACES_NUMBER)
    {
    #if (defined(USBUART_1_ENABLE_HID_CLASS)   || \
         defined(USBUART_1_ENABLE_AUDIO_CLASS) || \
         defined(USBUART_1_ENABLE_CDC_CLASS)   || \
         USBUART_1_ENABLE_MSC_CLASS)

        /* Handle class request depends on interface type. */
        switch (USBUART_1_interfaceClass[interfaceNumber])
        {
        #if defined(USBUART_1_ENABLE_HID_CLASS)
            case USBUART_1_CLASS_HID:
                requestHandled = USBUART_1_DispatchHIDClassRqst();
                break;
        #endif /* (USBUART_1_ENABLE_HID_CLASS) */
                
        #if defined(USBUART_1_ENABLE_AUDIO_CLASS)
            case USBUART_1_CLASS_AUDIO:
                requestHandled = USBUART_1_DispatchAUDIOClassRqst();
                break;
        #endif /* (USBUART_1_CLASS_AUDIO) */
                
        #if defined(USBUART_1_ENABLE_CDC_CLASS)
            case USBUART_1_CLASS_CDC:
                requestHandled = USBUART_1_DispatchCDCClassRqst();
                break;
        #endif /* (USBUART_1_ENABLE_CDC_CLASS) */
            
        #if (USBUART_1_ENABLE_MSC_CLASS)
            case USBUART_1_CLASS_MSD:
            #if (USBUART_1_HANDLE_MSC_REQUESTS)
                /* MSC requests are handled by the component. */
                requestHandled = USBUART_1_DispatchMSCClassRqst();
            #elif defined(USBUART_1_DISPATCH_MSC_CLASS_RQST_CALLBACK)
                /* MSC requests are handled by user defined callbcak. */
                requestHandled = USBUART_1_DispatchMSCClassRqst_Callback();
            #else
                /* MSC requests are not handled. */
                requestHandled = USBUART_1_FALSE;
            #endif /* (USBUART_1_HANDLE_MSC_REQUESTS) */
                break;
        #endif /* (USBUART_1_ENABLE_MSC_CLASS) */
            
            default:
                /* Request is not handled: unknown class request type. */
                requestHandled = USBUART_1_FALSE;
                break;
        }
    #endif /* Class support is enabled */
    }
    
    /* `#START USER_DEFINED_CLASS_CODE` Place your Class request here */

    /* `#END` */

#ifdef USBUART_1_DISPATCH_CLASS_RQST_CALLBACK
    if (USBUART_1_FALSE == requestHandled)
    {
        requestHandled = USBUART_1_DispatchClassRqst_Callback(interfaceNumber);
    }
#endif /* (USBUART_1_DISPATCH_CLASS_RQST_CALLBACK) */

    return (requestHandled);
}


/*******************************************************************************
* Additional user functions supporting Class Specific Requests
********************************************************************************/

/* `#START CLASS_SPECIFIC_FUNCTIONS` Place any additional functions here */

/* `#END` */

#endif /* USBUART_1_EXTERN_CLS */


/* [] END OF FILE */
