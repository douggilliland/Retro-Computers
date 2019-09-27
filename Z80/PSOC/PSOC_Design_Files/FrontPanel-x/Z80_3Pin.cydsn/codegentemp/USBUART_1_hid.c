/***************************************************************************//**
* \file USBUART_1_hid.c
* \version 3.20
*
* \brief
*  This file contains the USB HID Class request handler. 
*
* Related Document:
*  Device Class Definition for Human Interface Devices (HID) Version 1.11
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_1_hid.h"
#include "USBUART_1_pvt.h"
#include "cyapicallbacks.h"


#if defined(USBUART_1_ENABLE_HID_CLASS)

/***************************************
*    HID Variables
***************************************/
/** This variable is initialized in the USBFS_InitComponent() API to the 
 * PROTOCOL_REPORT value. It is controlled by the host using the 
 * HID_SET_PROTOCOL request. The value is returned to the user code by the 
 * USBFS_GetProtocol() API.*/
volatile uint8 USBUART_1_hidProtocol[USBUART_1_MAX_INTERFACES_NUMBER];

/** This variable controls the HID report rate. It is controlled by the host 
 * using the HID_SET_IDLE request and used by the USBFS_UpdateHIDTimer() API to 
 * reload timer.*/
volatile uint8 USBUART_1_hidIdleRate[USBUART_1_MAX_INTERFACES_NUMBER];

/** This variable contains the timer counter, which is decremented and reloaded 
 * by the USBFS_UpdateHIDTimer() API.*/
volatile uint8 USBUART_1_hidIdleTimer[USBUART_1_MAX_INTERFACES_NUMBER]; /* HID device idle rate value */


/***************************************
* Custom Declarations
***************************************/

/* `#START HID_CUSTOM_DECLARATIONS` Place your declaration here */

/* `#END` */


/*******************************************************************************
* Function Name: USBUART_1_UpdateHIDTimer
****************************************************************************//**
*
*  This function updates the HID Report idle timer and returns the status and 
*  reloads the timer if it expires.
*
*  \param interface Contains the interface number.
*
* \return
*  Returns the state of the HID timer. Symbolic names and their associated values are given here:
*  Return Value               |Notes
*  ---------------------------|------------------------------------------------
*  USBFS_IDLE_TIMER_EXPIRED   | The timer expired.
*  USBFS_IDLE_TIMER_RUNNING   | The timer is running.
*  USBFS_IDLE_TIMER_IDEFINITE | The report is sent when data or state changes.
*
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_1_UpdateHIDTimer(uint8 interface) 
{
    uint8 stat = USBUART_1_IDLE_TIMER_INDEFINITE;

    if(USBUART_1_hidIdleRate[interface] != 0u)
    {
        if(USBUART_1_hidIdleTimer[interface] > 0u)
        {
            USBUART_1_hidIdleTimer[interface]--;
            stat = USBUART_1_IDLE_TIMER_RUNNING;
        }
        else
        {
            USBUART_1_hidIdleTimer[interface] = USBUART_1_hidIdleRate[interface];
            stat = USBUART_1_IDLE_TIMER_EXPIRED;
        }
    }

    return((uint8)stat);
}


/*******************************************************************************
* Function Name: USBUART_1_GetProtocol
****************************************************************************//**
*
*  This function returns the HID protocol value for the selected interface.
*
*  \param interface:  Contains the interface number.
*
*  \return
*  Returns the protocol value. 
*
*******************************************************************************/
uint8 USBUART_1_GetProtocol(uint8 interface) 
{
    return(USBUART_1_hidProtocol[interface]);
}


/*******************************************************************************
* Function Name: USBUART_1_DispatchHIDClassRqst
****************************************************************************//**
*
*  This routine dispatches class requests
*
* \return
*  Results of HID Class request handling: 
*  - USBUART_1_TRUE  - request was handled without errors
*  - USBUART_1_FALSE - error occurs during handling of request  
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_1_DispatchHIDClassRqst(void) 
{
    uint8 requestHandled = USBUART_1_FALSE;

    uint8 interfaceNumber = (uint8) USBUART_1_wIndexLoReg;
    
    /* Check request direction: D2H or H2D. */
    if (0u != (USBUART_1_bmRequestTypeReg & USBUART_1_RQST_DIR_D2H))
    {
        /* Handle direction from device to host. */
        
        switch (USBUART_1_bRequestReg)
        {
            case USBUART_1_GET_DESCRIPTOR:
                if (USBUART_1_wValueHiReg == USBUART_1_DESCR_HID_CLASS)
                {
                    USBUART_1_FindHidClassDecriptor();
                    if (USBUART_1_currentTD.count != 0u)
                    {
                        requestHandled = USBUART_1_InitControlRead();
                    }
                }
                else if (USBUART_1_wValueHiReg == USBUART_1_DESCR_HID_REPORT)
                {
                    USBUART_1_FindReportDescriptor();
                    if (USBUART_1_currentTD.count != 0u)
                    {
                        requestHandled = USBUART_1_InitControlRead();
                    }
                }
                else
                {   
                    /* Do not handle this request. */
                }
                break;
                
            case USBUART_1_HID_GET_REPORT:
                USBUART_1_FindReport();
                if (USBUART_1_currentTD.count != 0u)
                {
                    requestHandled = USBUART_1_InitControlRead();
                }
                break;

            case USBUART_1_HID_GET_IDLE:
                /* This function does not support multiple reports per interface*/
                /* Validate interfaceNumber and Report ID (should be 0): Do not support Idle per Report ID */
                if ((interfaceNumber < USBUART_1_MAX_INTERFACES_NUMBER) && (USBUART_1_wValueLoReg == 0u)) 
                {
                    USBUART_1_currentTD.count = 1u;
                    USBUART_1_currentTD.pData = &USBUART_1_hidIdleRate[interfaceNumber];
                    requestHandled  = USBUART_1_InitControlRead();
                }
                break;
                
            case USBUART_1_HID_GET_PROTOCOL:
                /* Validate interfaceNumber */
                if( interfaceNumber < USBUART_1_MAX_INTERFACES_NUMBER)
                {
                    USBUART_1_currentTD.count = 1u;
                    USBUART_1_currentTD.pData = &USBUART_1_hidProtocol[interfaceNumber];
                    requestHandled  = USBUART_1_InitControlRead();
                }
                break;
                
            default:    /* requestHandled is initialized as FALSE by default */
                break;
        }
    }
    else
    {   
        /* Handle direction from host to device. */
        
        switch (USBUART_1_bRequestReg)
        {
            case USBUART_1_HID_SET_REPORT:
                USBUART_1_FindReport();
                if (USBUART_1_currentTD.count != 0u)
                {
                    requestHandled = USBUART_1_InitControlWrite();
                }
                break;
                
            case USBUART_1_HID_SET_IDLE:
                /* This function does not support multiple reports per interface */
                /* Validate interfaceNumber and Report ID (should be 0): Do not support Idle per Report ID */
                if ((interfaceNumber < USBUART_1_MAX_INTERFACES_NUMBER) && (USBUART_1_wValueLoReg == 0u))
                {
                    USBUART_1_hidIdleRate[interfaceNumber] = (uint8)USBUART_1_wValueHiReg;
                    /* With regards to HID spec: "7.2.4 Set_Idle Request"
                    *  Latency. If the current period has gone past the
                    *  newly proscribed time duration, then a report
                    *  will be generated immediately.
                    */
                    if(USBUART_1_hidIdleRate[interfaceNumber] <
                       USBUART_1_hidIdleTimer[interfaceNumber])
                    {
                        /* Set the timer to zero and let the UpdateHIDTimer() API return IDLE_TIMER_EXPIRED status*/
                        USBUART_1_hidIdleTimer[interfaceNumber] = 0u;
                    }
                    /* If the new request is received within 4 milliseconds
                    *  (1 count) of the end of the current period, then the
                    *  new request will have no effect until after the report.
                    */
                    else if(USBUART_1_hidIdleTimer[interfaceNumber] <= 1u)
                    {
                        /* Do nothing.
                        *  Let the UpdateHIDTimer() API continue to work and
                        *  return IDLE_TIMER_EXPIRED status
                        */
                    }
                    else
                    {   /* Reload the timer*/
                        USBUART_1_hidIdleTimer[interfaceNumber] =
                        USBUART_1_hidIdleRate[interfaceNumber];
                    }
                    requestHandled = USBUART_1_InitNoDataControlTransfer();
                }
                break;

            case USBUART_1_HID_SET_PROTOCOL:
                /* Validate interfaceNumber and protocol (must be 0 or 1) */
                if ((interfaceNumber < USBUART_1_MAX_INTERFACES_NUMBER) && (USBUART_1_wValueLoReg <= 1u))
                {
                    USBUART_1_hidProtocol[interfaceNumber] = (uint8)USBUART_1_wValueLoReg;
                    requestHandled = USBUART_1_InitNoDataControlTransfer();
                }
                break;
            
            default:    
                /* Unknown class request is not handled. */
                break;
        }
    }

    return (requestHandled);
}


/*******************************************************************************
* Function Name: USB_FindHidClassDescriptor
****************************************************************************//**
*
*  This routine find Hid Class Descriptor pointer based on the Interface number
*  and Alternate setting then loads the currentTD structure with the address of
*  the buffer and the size.
*  The HID Class Descriptor resides inside the config descriptor.
*
* \return
*  currentTD
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_1_FindHidClassDecriptor(void) 
{
    const T_USBUART_1_LUT CYCODE *pTmp;
    volatile uint8 *pDescr;
    uint8 interfaceN;

    pTmp = USBUART_1_GetConfigTablePtr(USBUART_1_configuration - 1u);
    
    interfaceN = (uint8) USBUART_1_wIndexLoReg;
    /* Third entry in the LUT starts the Interface Table pointers */
    /* Now use the request interface number*/
    pTmp = &pTmp[interfaceN + 2u];
    
    /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_TABLE */
    pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
    
    /* Now use Alternate setting number */
    pTmp = &pTmp[USBUART_1_interfaceSetting[interfaceN]];
    
    /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_ALTERNATEi_HID_TABLE */
    pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
    
    /* Fifth entry in the LUT points to Hid Class Descriptor in Configuration Descriptor */
    pTmp = &pTmp[4u];
    pDescr = (volatile uint8 *)pTmp->p_list;
    
    /* The first byte contains the descriptor length */
    USBUART_1_currentTD.count = *pDescr;
    USBUART_1_currentTD.pData = pDescr;
}


/*******************************************************************************
* Function Name: USB_FindReportDescriptor
****************************************************************************//**
*
*  This routine find Hid Report Descriptor pointer based on the Interface
*  number, then loads the currentTD structure with the address of the buffer
*  and the size.
*  Hid Report Descriptor is located after IN/OUT/FEATURE reports.
*
* \return
*  currentTD
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_1_FindReportDescriptor(void) 
{
    const T_USBUART_1_LUT CYCODE *pTmp;
    volatile uint8 *pDescr;
    uint8 interfaceN;

    pTmp = USBUART_1_GetConfigTablePtr(USBUART_1_configuration - 1u);
    interfaceN = (uint8) USBUART_1_wIndexLoReg;
    
    /* Third entry in the LUT starts the Interface Table pointers */
    /* Now use the request interface number */
    pTmp = &pTmp[interfaceN + 2u];
    
    /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_TABLE */
    pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
    
    /* Now use Alternate setting number */
    pTmp = &pTmp[USBUART_1_interfaceSetting[interfaceN]];
    
    /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_ALTERNATEi_HID_TABLE */
    pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
    
    /* Fourth entry in the LUT starts the Hid Report Descriptor */
    pTmp = &pTmp[3u];
    pDescr = (volatile uint8 *)pTmp->p_list;
    
    /* The 1st and 2nd bytes of descriptor contain its length. LSB is 1st. */
    USBUART_1_currentTD.count =  ((uint16)((uint16) pDescr[1u] << 8u) | pDescr[0u]);
    USBUART_1_currentTD.pData = &pDescr[2u];
}


/*******************************************************************************
* Function Name: USBUART_1_FindReport
****************************************************************************//**
*
*  This routine sets up a transfer based on the Interface number, Report Type
*  and Report ID, then loads the currentTD structure with the address of the
*  buffer and the size.  The caller has to decide if it is a control read or
*  control write.
*
* \return
*  currentTD
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_1_FindReport(void) 
{
    const T_USBUART_1_LUT CYCODE *pTmp;
    T_USBUART_1_TD *pTD;
    uint8 reportType;
    uint8 interfaceN;
 
    /* `#START HID_FINDREPORT` Place custom handling here */

    /* `#END` */
    
#ifdef USBUART_1_FIND_REPORT_CALLBACK
    USBUART_1_FindReport_Callback();
#endif /* (USBUART_1_FIND_REPORT_CALLBACK) */
    
    USBUART_1_currentTD.count = 0u;   /* Init not supported condition */
    pTmp = USBUART_1_GetConfigTablePtr(USBUART_1_configuration - 1u);
    reportType = (uint8) USBUART_1_wValueHiReg;
    interfaceN = (uint8) USBUART_1_wIndexLoReg;
    
    /* Third entry in the LUT Configuration Table starts the Interface Table pointers */
    /* Now use the request interface number */
    pTmp = &pTmp[interfaceN + 2u];
    
    /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_TABLE */
    pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
    if (interfaceN < USBUART_1_MAX_INTERFACES_NUMBER)
    {
        /* Now use Alternate setting number */
        pTmp = &pTmp[USBUART_1_interfaceSetting[interfaceN]];
        
        /* USB_DEVICEx_CONFIGURATIONy_INTERFACEz_ALTERNATEi_HID_TABLE */
        pTmp = (const T_USBUART_1_LUT CYCODE *) pTmp->p_list;
        
        /* Validate reportType to comply with "7.2.1 Get_Report Request" */
        if ((reportType >= USBUART_1_HID_GET_REPORT_INPUT) &&
            (reportType <= USBUART_1_HID_GET_REPORT_FEATURE))
        {
            /* Get the entry proper TD (IN, OUT or Feature Report Table)*/
            pTmp = &pTmp[reportType - 1u];
            
            /* Get reportID */
            reportType = (uint8) USBUART_1_wValueLoReg;
            
            /* Validate table support by the HID descriptor, compare table count with reportID */
            if (pTmp->c >= reportType)
            {
                pTD = (T_USBUART_1_TD *) pTmp->p_list;
                pTD = &pTD[reportType];                          /* select entry depend on report ID*/
                USBUART_1_currentTD.pData = pTD->pData;   /* Buffer pointer */
                USBUART_1_currentTD.count = pTD->count;   /* Buffer Size */
                USBUART_1_currentTD.pStatusBlock = pTD->pStatusBlock;
            }
        }
    }
}


/*******************************************************************************
* Additional user functions supporting HID Requests
********************************************************************************/

/* `#START HID_FUNCTIONS` Place any additional functions here */

/* `#END` */

#endif  /*  USBUART_1_ENABLE_HID_CLASS */


/* [] END OF FILE */
