/***************************************************************************//**
* \file USBUART_std.c
* \version 3.20
*
* \brief
*  This file contains the USB Standard request handler.
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "USBUART_pvt.h"

/***************************************
*   Static data allocation
***************************************/

#if defined(USBUART_ENABLE_FWSN_STRING)
    static volatile uint8* USBUART_fwSerialNumberStringDescriptor;
    static volatile uint8  USBUART_snStringConfirm = USBUART_FALSE;
#endif  /* (USBUART_ENABLE_FWSN_STRING) */

#if defined(USBUART_ENABLE_FWSN_STRING)
    /***************************************************************************
    * Function Name: USBUART_SerialNumString
    ************************************************************************//**
    *
    *  This function is available only when the User Call Back option in the 
    *  Serial Number String descriptor properties is selected. Application 
    *  firmware can provide the source of the USB device serial number string 
    *  descriptor during run time. The default string is used if the application 
    *  firmware does not use this function or sets the wrong string descriptor.
    *
    *  \param snString:  Pointer to the user-defined string descriptor. The 
    *  string descriptor should meet the Universal Serial Bus Specification 
    *  revision 2.0 chapter 9.6.7
    *  Offset|Size|Value|Description
    *  ------|----|------|---------------------------------
    *  0     |1   |N     |Size of this descriptor in bytes
    *  1     |1   |0x03  |STRING Descriptor Type
    *  2     |N-2 |Number|UNICODE encoded string
    *  
    * *For example:* uint8 snString[16]={0x0E,0x03,'F',0,'W',0,'S',0,'N',0,'0',0,'1',0};
    *
    * \reentrant
    *  No.
    *
    ***************************************************************************/
    void  USBUART_SerialNumString(uint8 snString[]) 
    {
        USBUART_snStringConfirm = USBUART_FALSE;
        
        if (snString != NULL)
        {
            /* Check descriptor validation */
            if ((snString[0u] > 1u) && (snString[1u] == USBUART_DESCR_STRING))
            {
                USBUART_fwSerialNumberStringDescriptor = snString;
                USBUART_snStringConfirm = USBUART_TRUE;
            }
        }
    }
#endif  /* USBUART_ENABLE_FWSN_STRING */


/*******************************************************************************
* Function Name: USBUART_HandleStandardRqst
****************************************************************************//**
*
*  This Routine dispatches standard requests
*
*
* \return
*  TRUE if request handled.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_HandleStandardRqst(void) 
{
    uint8 requestHandled = USBUART_FALSE;
    uint8 interfaceNumber;
    uint8 configurationN;
    uint8 bmRequestType = USBUART_bmRequestTypeReg;

#if defined(USBUART_ENABLE_STRINGS)
    volatile uint8 *pStr = 0u;
    #if defined(USBUART_ENABLE_DESCRIPTOR_STRINGS)
        uint8 nStr;
        uint8 descrLength;
    #endif /* (USBUART_ENABLE_DESCRIPTOR_STRINGS) */
#endif /* (USBUART_ENABLE_STRINGS) */
    
    static volatile uint8 USBUART_tBuffer[USBUART_STATUS_LENGTH_MAX];
    const T_USBUART_LUT CYCODE *pTmp;

    USBUART_currentTD.count = 0u;

    if (USBUART_RQST_DIR_D2H == (bmRequestType & USBUART_RQST_DIR_MASK))
    {
        /* Control Read */
        switch (USBUART_bRequestReg)
        {
            case USBUART_GET_DESCRIPTOR:
                if (USBUART_DESCR_DEVICE ==USBUART_wValueHiReg)
                {
                    pTmp = USBUART_GetDeviceTablePtr();
                    USBUART_currentTD.pData = (volatile uint8 *)pTmp->p_list;
                    USBUART_currentTD.count = USBUART_DEVICE_DESCR_LENGTH;
                    
                    requestHandled  = USBUART_InitControlRead();
                }
                else if (USBUART_DESCR_CONFIG == USBUART_wValueHiReg)
                {
                    pTmp = USBUART_GetConfigTablePtr((uint8) USBUART_wValueLoReg);
                    
                    /* Verify that requested descriptor exists */
                    if (pTmp != NULL)
                    {
                        USBUART_currentTD.pData = (volatile uint8 *)pTmp->p_list;
                        USBUART_currentTD.count = (uint16)((uint16)(USBUART_currentTD.pData)[USBUART_CONFIG_DESCR_TOTAL_LENGTH_HI] << 8u) | \
                                                                            (USBUART_currentTD.pData)[USBUART_CONFIG_DESCR_TOTAL_LENGTH_LOW];
                        requestHandled  = USBUART_InitControlRead();
                    }
                }
                
            #if(USBUART_BOS_ENABLE)
                else if (USBUART_DESCR_BOS == USBUART_wValueHiReg)
                {
                    pTmp = USBUART_GetBOSPtr();
                    
                    /* Verify that requested descriptor exists */
                    if (pTmp != NULL)
                    {
                        USBUART_currentTD.pData = (volatile uint8 *)pTmp;
                        USBUART_currentTD.count = ((uint16)((uint16)(USBUART_currentTD.pData)[USBUART_BOS_DESCR_TOTAL_LENGTH_HI] << 8u)) | \
                                                                             (USBUART_currentTD.pData)[USBUART_BOS_DESCR_TOTAL_LENGTH_LOW];
                        requestHandled  = USBUART_InitControlRead();
                    }
                }
            #endif /*(USBUART_BOS_ENABLE)*/
            
            #if defined(USBUART_ENABLE_STRINGS)
                else if (USBUART_DESCR_STRING == USBUART_wValueHiReg)
                {
                /* Descriptor Strings */
                #if defined(USBUART_ENABLE_DESCRIPTOR_STRINGS)
                    nStr = 0u;
                    pStr = (volatile uint8 *) &USBUART_STRING_DESCRIPTORS[0u];
                    
                    while ((USBUART_wValueLoReg > nStr) && (*pStr != 0u))
                    {
                        /* Read descriptor length from 1st byte */
                        descrLength = *pStr;
                        /* Move to next string descriptor */
                        pStr = &pStr[descrLength];
                        nStr++;
                    }
                #endif /* (USBUART_ENABLE_DESCRIPTOR_STRINGS) */
                
                /* Microsoft OS String */
                #if defined(USBUART_ENABLE_MSOS_STRING)
                    if (USBUART_STRING_MSOS == USBUART_wValueLoReg)
                    {
                        pStr = (volatile uint8 *)& USBUART_MSOS_DESCRIPTOR[0u];
                    }
                #endif /* (USBUART_ENABLE_MSOS_STRING) */
                
                /* SN string */
                #if defined(USBUART_ENABLE_SN_STRING)
                    if ((USBUART_wValueLoReg != 0u) && 
                        (USBUART_wValueLoReg == USBUART_DEVICE0_DESCR[USBUART_DEVICE_DESCR_SN_SHIFT]))
                    {
                    #if defined(USBUART_ENABLE_IDSN_STRING)
                        /* Read DIE ID and generate string descriptor in RAM */
                        USBUART_ReadDieID(USBUART_idSerialNumberStringDescriptor);
                        pStr = USBUART_idSerialNumberStringDescriptor;
                    #elif defined(USBUART_ENABLE_FWSN_STRING)
                        
                        if(USBUART_snStringConfirm != USBUART_FALSE)
                        {
                            pStr = USBUART_fwSerialNumberStringDescriptor;
                        }
                        else
                        {
                            pStr = (volatile uint8 *)&USBUART_SN_STRING_DESCRIPTOR[0u];
                        }
                    #else
                        pStr = (volatile uint8 *)&USBUART_SN_STRING_DESCRIPTOR[0u];
                    #endif  /* (USBUART_ENABLE_IDSN_STRING) */
                    }
                #endif /* (USBUART_ENABLE_SN_STRING) */
                
                    if (*pStr != 0u)
                    {
                        USBUART_currentTD.count = *pStr;
                        USBUART_currentTD.pData = pStr;
                        requestHandled  = USBUART_InitControlRead();
                    }
                }
            #endif /*  USBUART_ENABLE_STRINGS */
                else
                {
                    requestHandled = USBUART_DispatchClassRqst();
                }
                break;
                
            case USBUART_GET_STATUS:
                switch (bmRequestType & USBUART_RQST_RCPT_MASK)
                {
                    case USBUART_RQST_RCPT_EP:
                        USBUART_currentTD.count = USBUART_EP_STATUS_LENGTH;
                        USBUART_tBuffer[0u]     = USBUART_EP[USBUART_wIndexLoReg & USBUART_DIR_UNUSED].hwEpState;
                        USBUART_tBuffer[1u]     = 0u;
                        USBUART_currentTD.pData = &USBUART_tBuffer[0u];
                        
                        requestHandled  = USBUART_InitControlRead();
                        break;
                    case USBUART_RQST_RCPT_DEV:
                        USBUART_currentTD.count = USBUART_DEVICE_STATUS_LENGTH;
                        USBUART_tBuffer[0u]     = USBUART_deviceStatus;
                        USBUART_tBuffer[1u]     = 0u;
                        USBUART_currentTD.pData = &USBUART_tBuffer[0u];
                        
                        requestHandled  = USBUART_InitControlRead();
                        break;
                    default:    /* requestHandled is initialized as FALSE by default */
                        break;
                }
                break;
                
            case USBUART_GET_CONFIGURATION:
                USBUART_currentTD.count = 1u;
                USBUART_currentTD.pData = (volatile uint8 *) &USBUART_configuration;
                requestHandled  = USBUART_InitControlRead();
                break;
                
            case USBUART_GET_INTERFACE:
                USBUART_currentTD.count = 1u;
                USBUART_currentTD.pData = (volatile uint8 *) &USBUART_interfaceSetting[USBUART_wIndexLoReg];
                requestHandled  = USBUART_InitControlRead();
                break;
                
            default: /* requestHandled is initialized as FALSE by default */
                break;
        }
    }
    else
    {
        /* Control Write */
        switch (USBUART_bRequestReg)
        {
            case USBUART_SET_ADDRESS:
                /* Store address to be set in USBUART_NoDataControlStatusStage(). */
                USBUART_deviceAddress = (uint8) USBUART_wValueLoReg;
                requestHandled = USBUART_InitNoDataControlTransfer();
                break;
                
            case USBUART_SET_CONFIGURATION:
                configurationN = USBUART_wValueLoReg;
                
                /* Verify that configuration descriptor exists */
                if(configurationN > 0u)
                {
                    pTmp = USBUART_GetConfigTablePtr((uint8) configurationN - 1u);
                }
                
                /* Responds with a Request Error when configuration number is invalid */
                if (((configurationN > 0u) && (pTmp != NULL)) || (configurationN == 0u))
                {
                    /* Set new configuration if it has been changed */
                    if(configurationN != USBUART_configuration)
                    {
                        USBUART_configuration = (uint8) configurationN;
                        USBUART_configurationChanged = USBUART_TRUE;
                        USBUART_Config(USBUART_TRUE);
                    }
                    requestHandled = USBUART_InitNoDataControlTransfer();
                }
                break;
                
            case USBUART_SET_INTERFACE:
                if (0u != USBUART_ValidateAlternateSetting())
                {
                    /* Get interface number from the request. */
                    interfaceNumber = USBUART_wIndexLoReg;
                    USBUART_interfaceNumber = (uint8) USBUART_wIndexLoReg;
                     
                    /* Check if alternate settings is changed for interface. */
                    if (USBUART_interfaceSettingLast[interfaceNumber] != USBUART_interfaceSetting[interfaceNumber])
                    {
                        USBUART_configurationChanged = USBUART_TRUE;
                    
                        /* Change alternate setting for the endpoints. */
                    #if (USBUART_EP_MANAGEMENT_MANUAL && USBUART_EP_ALLOC_DYNAMIC)
                        USBUART_Config(USBUART_FALSE);
                    #else
                        USBUART_ConfigAltChanged();
                    #endif /* (USBUART_EP_MANAGEMENT_MANUAL && USBUART_EP_ALLOC_DYNAMIC) */
                    }
                    
                    requestHandled = USBUART_InitNoDataControlTransfer();
                }
                break;
                
            case USBUART_CLEAR_FEATURE:
                switch (bmRequestType & USBUART_RQST_RCPT_MASK)
                {
                    case USBUART_RQST_RCPT_EP:
                        if (USBUART_wValueLoReg == USBUART_ENDPOINT_HALT)
                        {
                            requestHandled = USBUART_ClearEndpointHalt();
                        }
                        break;
                    case USBUART_RQST_RCPT_DEV:
                        /* Clear device REMOTE_WAKEUP */
                        if (USBUART_wValueLoReg == USBUART_DEVICE_REMOTE_WAKEUP)
                        {
                            USBUART_deviceStatus &= (uint8)~USBUART_DEVICE_STATUS_REMOTE_WAKEUP;
                            requestHandled = USBUART_InitNoDataControlTransfer();
                        }
                        break;
                    case USBUART_RQST_RCPT_IFC:
                        /* Validate interfaceNumber */
                        if (USBUART_wIndexLoReg < USBUART_MAX_INTERFACES_NUMBER)
                        {
                            USBUART_interfaceStatus[USBUART_wIndexLoReg] &= (uint8) ~USBUART_wValueLoReg;
                            requestHandled = USBUART_InitNoDataControlTransfer();
                        }
                        break;
                    default:    /* requestHandled is initialized as FALSE by default */
                        break;
                }
                break;
                
            case USBUART_SET_FEATURE:
                switch (bmRequestType & USBUART_RQST_RCPT_MASK)
                {
                    case USBUART_RQST_RCPT_EP:
                        if (USBUART_wValueLoReg == USBUART_ENDPOINT_HALT)
                        {
                            requestHandled = USBUART_SetEndpointHalt();
                        }
                        break;
                        
                    case USBUART_RQST_RCPT_DEV:
                        /* Set device REMOTE_WAKEUP */
                        if (USBUART_wValueLoReg == USBUART_DEVICE_REMOTE_WAKEUP)
                        {
                            USBUART_deviceStatus |= USBUART_DEVICE_STATUS_REMOTE_WAKEUP;
                            requestHandled = USBUART_InitNoDataControlTransfer();
                        }
                        break;
                        
                    case USBUART_RQST_RCPT_IFC:
                        /* Validate interfaceNumber */
                        if (USBUART_wIndexLoReg < USBUART_MAX_INTERFACES_NUMBER)
                        {
                            USBUART_interfaceStatus[USBUART_wIndexLoReg] &= (uint8) ~USBUART_wValueLoReg;
                            requestHandled = USBUART_InitNoDataControlTransfer();
                        }
                        break;
                    
                    default:    /* requestHandled is initialized as FALSE by default */
                        break;
                }
                break;
                
            default:    /* requestHandled is initialized as FALSE by default */
                break;
        }
    }
    
    return (requestHandled);
}


#if defined(USBUART_ENABLE_IDSN_STRING)
    /***************************************************************************
    * Function Name: USBUART_ReadDieID
    ************************************************************************//**
    *
    *  This routine read Die ID and generate Serial Number string descriptor.
    *
    *  \param descr:  pointer on string descriptor. This string size has to be equal or
    *          greater than USBUART_IDSN_DESCR_LENGTH.
    *
    *
    * \reentrant
    *  No.
    *
    ***************************************************************************/
    void USBUART_ReadDieID(uint8 descr[]) 
    {
        const char8 CYCODE hex[] = "0123456789ABCDEF";
        uint8 i;
        uint8 j = 0u;
        uint8 uniqueId[8u];

        if (NULL != descr)
        {
            /* Initialize descriptor header. */
            descr[0u] = USBUART_IDSN_DESCR_LENGTH;
            descr[1u] = USBUART_DESCR_STRING;
            
            /* Unique ID size is 8 bytes. */
            CyGetUniqueId((uint32 *) uniqueId);

            /* Fill descriptor with unique device ID. */
            for (i = 2u; i < USBUART_IDSN_DESCR_LENGTH; i += 4u)
            {
                descr[i]      = (uint8) hex[(uniqueId[j] >> 4u)];
                descr[i + 1u] = 0u;
                descr[i + 2u] = (uint8) hex[(uniqueId[j] & 0x0Fu)];
                descr[i + 3u] = 0u;
                ++j;
            }
        }
    }
#endif /* (USBUART_ENABLE_IDSN_STRING) */


/*******************************************************************************
* Function Name: USBUART_ConfigReg
****************************************************************************//**
*
*  This routine configures hardware registers from the variables.
*  It is called from USBUART_Config() function and from RestoreConfig
*  after Wakeup.
*
*******************************************************************************/
void USBUART_ConfigReg(void) 
{
    uint8 ep;

#if (USBUART_EP_MANAGEMENT_DMA_AUTO)
    uint8 epType = 0u;
#endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */

    /* Go thought all endpoints and set hardware configuration */
    for (ep = USBUART_EP1; ep < USBUART_MAX_EP; ++ep)
    {
        USBUART_ARB_EP_BASE.arbEp[ep].epCfg = USBUART_ARB_EPX_CFG_DEFAULT;
        
    #if (USBUART_EP_MANAGEMENT_DMA)
        /* Enable arbiter endpoint interrupt sources */
        USBUART_ARB_EP_BASE.arbEp[ep].epIntEn = USBUART_ARB_EPX_INT_MASK;
    #endif /* (USBUART_EP_MANAGEMENT_DMA) */
    
        if (USBUART_EP[ep].epMode != USBUART_MODE_DISABLE)
        {
            if (0u != (USBUART_EP[ep].addr & USBUART_DIR_IN))
            {
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_NAK_IN;
                
            #if (USBUART_EP_MANAGEMENT_DMA_AUTO && CY_PSOC4)
                /* Clear DMA_TERMIN for IN endpoint. */
                USBUART_ARB_EP_BASE.arbEp[ep].epIntEn &= (uint32) ~USBUART_ARB_EPX_INT_DMA_TERMIN;
            #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO && CY_PSOC4) */
            }
            else
            {
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_NAK_OUT;

            #if (USBUART_EP_MANAGEMENT_DMA_AUTO)
                /* (CY_PSOC4): DMA_TERMIN for OUT endpoint is set above. */
                
                /* Prepare endpoint type mask. */
                epType |= (uint8) (0x01u << (ep - USBUART_EP1));
            #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */
            }
        }
        else
        {
            USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_STALL_DATA_EP;
        }
        
    #if (!USBUART_EP_MANAGEMENT_DMA_AUTO)
        #if (CY_PSOC4)
            USBUART_ARB_EP16_BASE.arbEp[ep].rwRa16  = (uint32) USBUART_EP[ep].buffOffset;
            USBUART_ARB_EP16_BASE.arbEp[ep].rwWa16  = (uint32) USBUART_EP[ep].buffOffset;
        #else
            USBUART_ARB_EP_BASE.arbEp[ep].rwRa    = LO8(USBUART_EP[ep].buffOffset);
            USBUART_ARB_EP_BASE.arbEp[ep].rwRaMsb = HI8(USBUART_EP[ep].buffOffset);
            USBUART_ARB_EP_BASE.arbEp[ep].rwWa    = LO8(USBUART_EP[ep].buffOffset);
            USBUART_ARB_EP_BASE.arbEp[ep].rwWaMsb = HI8(USBUART_EP[ep].buffOffset);
        #endif /* (CY_PSOC4) */
    #endif /* (!USBUART_EP_MANAGEMENT_DMA_AUTO) */
    }

#if (USBUART_EP_MANAGEMENT_DMA_AUTO)
     /* BUF_SIZE depend on DMA_THRESS value:0x55-32 bytes  0x44-16 bytes 0x33-8 bytes 0x22-4 bytes 0x11-2 bytes */
    USBUART_BUF_SIZE_REG = USBUART_DMA_BUF_SIZE;

    /* Configure DMA burst threshold */
#if (CY_PSOC4)
    USBUART_DMA_THRES16_REG   = USBUART_DMA_BYTES_PER_BURST;
#else
    USBUART_DMA_THRES_REG     = USBUART_DMA_BYTES_PER_BURST;
    USBUART_DMA_THRES_MSB_REG = 0u;
#endif /* (CY_PSOC4) */
    USBUART_EP_ACTIVE_REG = USBUART_DEFAULT_ARB_INT_EN;
    USBUART_EP_TYPE_REG   = epType;
    
    /* Cfg_cmp bit set to 1 once configuration is complete. */
    /* Lock arbiter configtuation */
    USBUART_ARB_CFG_REG |= (uint8)  USBUART_ARB_CFG_CFG_CMP;
    /* Cfg_cmp bit set to 0 during configuration of PFSUSB Registers. */
    USBUART_ARB_CFG_REG &= (uint8) ~USBUART_ARB_CFG_CFG_CMP;

#endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */

    /* Enable interrupt SIE interurpt source from EP0-EP1 */
    USBUART_SIE_EP_INT_EN_REG = (uint8) USBUART_DEFAULT_SIE_EP_INT_EN;
}


/*******************************************************************************
* Function Name: USBUART_EpStateInit
****************************************************************************//**
*
*  This routine initialize state of Data end points based of its type: 
*   IN  - USBUART_IN_BUFFER_EMPTY (USBUART_EVENT_PENDING)
*   OUT - USBUART_OUT_BUFFER_EMPTY (USBUART_NO_EVENT_PENDING)
*
*******************************************************************************/
void USBUART_EpStateInit(void) 
{
    uint8 i;

    for (i = USBUART_EP1; i < USBUART_MAX_EP; i++)
    { 
        if (0u != (USBUART_EP[i].addr & USBUART_DIR_IN))
        {
            /* IN Endpoint */
            USBUART_EP[i].apiEpState = USBUART_EVENT_PENDING;
        }
        else
        {
            /* OUT Endpoint */
            USBUART_EP[i].apiEpState = USBUART_NO_EVENT_PENDING;
        }
    }
                    
}


/*******************************************************************************
* Function Name: USBUART_Config
****************************************************************************//**
*
*  This routine configures endpoints for the entire configuration by scanning
*  the configuration descriptor.
*
*  \param clearAltSetting: It configures the bAlternateSetting 0 for each interface.
*
* USBUART_interfaceClass - Initialized class array for each interface.
*   It is used for handling Class specific requests depend on interface class.
*   Different classes in multiple Alternate settings does not supported.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_Config(uint8 clearAltSetting) 
{
    uint8 ep;
    uint8 curEp;
    uint8 i;
    uint8 epType;
    const uint8 *pDescr;
    
    #if (!USBUART_EP_MANAGEMENT_DMA_AUTO)
        uint16 buffCount = 0u;
    #endif /* (!USBUART_EP_MANAGEMENT_DMA_AUTO) */

    const T_USBUART_LUT CYCODE *pTmp;
    const T_USBUART_EP_SETTINGS_BLOCK CYCODE *pEP;

    /* Clear endpoints settings */
    for (ep = 0u; ep < USBUART_MAX_EP; ++ep)
    {
        USBUART_EP[ep].attrib     = 0u;
        USBUART_EP[ep].hwEpState  = 0u;
        USBUART_EP[ep].epToggle   = 0u;
        USBUART_EP[ep].bufferSize = 0u;
        USBUART_EP[ep].interface  = 0u;
        USBUART_EP[ep].apiEpState = USBUART_NO_EVENT_PENDING;
        USBUART_EP[ep].epMode     = USBUART_MODE_DISABLE;   
    }

    /* Clear Alternate settings for all interfaces. */
    if (0u != clearAltSetting)
    {
        for (i = 0u; i < USBUART_MAX_INTERFACES_NUMBER; ++i)
        {
            USBUART_interfaceSetting[i]     = 0u;
            USBUART_interfaceSettingLast[i] = 0u;
        }
    }

    /* Init Endpoints and Device Status if configured */
    if (USBUART_configuration > 0u)
    {
        #if defined(USBUART_ENABLE_CDC_CLASS)
            uint8 cdcComNums = 0u;
        #endif  /* (USBUART_ENABLE_CDC_CLASS) */  

        pTmp = USBUART_GetConfigTablePtr(USBUART_configuration - 1u);
        
        /* Set Power status for current configuration */
        pDescr = (const uint8 *)pTmp->p_list;
        if ((pDescr[USBUART_CONFIG_DESCR_ATTRIB] & USBUART_CONFIG_DESCR_ATTRIB_SELF_POWERED) != 0u)
        {
            USBUART_deviceStatus |= (uint8)  USBUART_DEVICE_STATUS_SELF_POWERED;
        }
        else
        {
            USBUART_deviceStatus &= (uint8) ~USBUART_DEVICE_STATUS_SELF_POWERED;
        }
        
        /* Move to next element */
        pTmp = &pTmp[1u];
        ep = pTmp->c;  /* For this table, c is the number of endpoints configurations  */

        #if (USBUART_EP_MANAGEMENT_MANUAL && USBUART_EP_ALLOC_DYNAMIC)
            /* Configure for dynamic EP memory allocation */
            /* p_list points the endpoint setting table. */
            pEP = (T_USBUART_EP_SETTINGS_BLOCK *) pTmp->p_list;
            
            for (i = 0u; i < ep; i++)
            {     
                /* Compare current Alternate setting with EP Alt */
                if (USBUART_interfaceSetting[pEP->interface] == pEP->altSetting)
                {                                                          
                    curEp  = pEP->addr & USBUART_DIR_UNUSED;
                    epType = pEP->attributes & USBUART_EP_TYPE_MASK;
                    
                    USBUART_EP[curEp].addr       = pEP->addr;
                    USBUART_EP[curEp].attrib     = pEP->attributes;
                    USBUART_EP[curEp].bufferSize = pEP->bufferSize;

                    if (0u != (pEP->addr & USBUART_DIR_IN))
                    {
                        /* IN Endpoint */
                        USBUART_EP[curEp].epMode     = USBUART_GET_ACTIVE_IN_EP_CR0_MODE(epType);
                        USBUART_EP[curEp].apiEpState = USBUART_EVENT_PENDING;
                    
                    #if (defined(USBUART_ENABLE_MIDI_STREAMING) && (USBUART_MIDI_IN_BUFF_SIZE > 0))
                        if ((pEP->bMisc == USBUART_CLASS_AUDIO) && (epType == USBUART_EP_TYPE_BULK))
                        {
                            USBUART_midi_in_ep = curEp;
                        }
                    #endif  /* (USBUART_ENABLE_MIDI_STREAMING) */
                    }
                    else
                    {
                        /* OUT Endpoint */
                        USBUART_EP[curEp].epMode     = USBUART_GET_ACTIVE_OUT_EP_CR0_MODE(epType);
                        USBUART_EP[curEp].apiEpState = USBUART_NO_EVENT_PENDING;
                        
                    #if (defined(USBUART_ENABLE_MIDI_STREAMING) && (USBUART_MIDI_OUT_BUFF_SIZE > 0))
                        if ((pEP->bMisc == USBUART_CLASS_AUDIO) && (epType == USBUART_EP_TYPE_BULK))
                        {
                            USBUART_midi_out_ep = curEp;
                        }
                    #endif  /* (USBUART_ENABLE_MIDI_STREAMING) */
                    }

                #if(defined (USBUART_ENABLE_CDC_CLASS))
                    if((pEP->bMisc == USBUART_CLASS_CDC_DATA) ||(pEP->bMisc == USBUART_CLASS_CDC))
                    {
                        cdcComNums = USBUART_Cdc_EpInit(pEP, curEp, cdcComNums);
                    }
                #endif  /* (USBUART_ENABLE_CDC_CLASS) */
                }
                
                pEP = &pEP[1u];
            }
            
        #else
            for (i = USBUART_EP1; i < USBUART_MAX_EP; ++i)
            {
                /* p_list points the endpoint setting table. */
                pEP = (const T_USBUART_EP_SETTINGS_BLOCK CYCODE *) pTmp->p_list;
                /* Find max length for each EP and select it (length could be different in different Alt settings) */
                /* but other settings should be correct with regards to Interface alt Setting */
                
                for (curEp = 0u; curEp < ep; ++curEp)
                {
                    if (i == (pEP->addr & USBUART_DIR_UNUSED))
                    {
                        /* Compare endpoint buffers size with current size to find greater. */
                        if (USBUART_EP[i].bufferSize < pEP->bufferSize)
                        {
                            USBUART_EP[i].bufferSize = pEP->bufferSize;
                        }
                        
                        /* Compare current Alternate setting with EP Alt */
                        if (USBUART_interfaceSetting[pEP->interface] == pEP->altSetting)
                        {                            
                            USBUART_EP[i].addr = pEP->addr;
                            USBUART_EP[i].attrib = pEP->attributes;
                            
                            epType = pEP->attributes & USBUART_EP_TYPE_MASK;
                            
                            if (0u != (pEP->addr & USBUART_DIR_IN))
                            {
                                /* IN Endpoint */
                                USBUART_EP[i].epMode     = USBUART_GET_ACTIVE_IN_EP_CR0_MODE(epType);
                                USBUART_EP[i].apiEpState = USBUART_EVENT_PENDING;
                                
                            #if (defined(USBUART_ENABLE_MIDI_STREAMING) && (USBUART_MIDI_IN_BUFF_SIZE > 0))
                                if ((pEP->bMisc == USBUART_CLASS_AUDIO) && (epType == USBUART_EP_TYPE_BULK))
                                {
                                    USBUART_midi_in_ep = i;
                                }
                            #endif  /* (USBUART_ENABLE_MIDI_STREAMING) */
                            }
                            else
                            {
                                /* OUT Endpoint */
                                USBUART_EP[i].epMode     = USBUART_GET_ACTIVE_OUT_EP_CR0_MODE(epType);
                                USBUART_EP[i].apiEpState = USBUART_NO_EVENT_PENDING;
                                
                            #if (defined(USBUART_ENABLE_MIDI_STREAMING) && (USBUART_MIDI_OUT_BUFF_SIZE > 0))
                                if ((pEP->bMisc == USBUART_CLASS_AUDIO) && (epType == USBUART_EP_TYPE_BULK))
                                {
                                    USBUART_midi_out_ep = i;
                                }
                            #endif  /* (USBUART_ENABLE_MIDI_STREAMING) */
                            }

                        #if (defined(USBUART_ENABLE_CDC_CLASS))
                            if((pEP->bMisc == USBUART_CLASS_CDC_DATA) ||(pEP->bMisc == USBUART_CLASS_CDC))
                            {
                                cdcComNums = USBUART_Cdc_EpInit(pEP, i, cdcComNums);
                            }
                        #endif  /* (USBUART_ENABLE_CDC_CLASS) */

                            #if (USBUART_EP_MANAGEMENT_DMA_AUTO)
                                break;  /* Use first EP setting in Auto memory management */
                            #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */
                        }
                    }
                    
                    pEP = &pEP[1u];
                }
            }
        #endif /*  (USBUART_EP_MANAGEMENT_MANUAL && USBUART_EP_ALLOC_DYNAMIC) */

        /* Init class array for each interface and interface number for each EP.
        *  It is used for handling Class specific requests directed to either an
        *  interface or the endpoint.
        */
        /* p_list points the endpoint setting table. */
        pEP = (const T_USBUART_EP_SETTINGS_BLOCK CYCODE *) pTmp->p_list;
        for (i = 0u; i < ep; i++)
        {
            /* Configure interface number for each EP */
            USBUART_EP[pEP->addr & USBUART_DIR_UNUSED].interface = pEP->interface;
            pEP = &pEP[1u];
        }
        
        /* Init pointer on interface class table */
        USBUART_interfaceClass = USBUART_GetInterfaceClassTablePtr();
        
    /* Set the endpoint buffer addresses */
    #if (!USBUART_EP_MANAGEMENT_DMA_AUTO)
        buffCount = 0u;
        for (ep = USBUART_EP1; ep < USBUART_MAX_EP; ++ep)
        {
            USBUART_EP[ep].buffOffset = buffCount;        
            buffCount += USBUART_EP[ep].bufferSize;
            
        #if (USBUART_GEN_16BITS_EP_ACCESS)
            /* Align EP buffers to be event size to access 16-bits DR register. */
            buffCount += (0u != (buffCount & 0x01u)) ? 1u : 0u;
        #endif /* (USBUART_GEN_16BITS_EP_ACCESS) */            
        }
    #endif /* (!USBUART_EP_MANAGEMENT_DMA_AUTO) */

        /* Configure hardware registers */
        USBUART_ConfigReg();
    }
}


/*******************************************************************************
* Function Name: USBUART_ConfigAltChanged
****************************************************************************//**
*
*  This routine update configuration for the required endpoints only.
*  It is called after SET_INTERFACE request when Static memory allocation used.
*
* \reentrant
*  No.
*
*******************************************************************************/
void USBUART_ConfigAltChanged(void) 
{
    uint8 ep;
    uint8 curEp;
    uint8 epType;
    uint8 i;
    uint8 interfaceNum;

    const T_USBUART_LUT CYCODE *pTmp;
    const T_USBUART_EP_SETTINGS_BLOCK CYCODE *pEP;

    /* Init Endpoints and Device Status if configured */
    if (USBUART_configuration > 0u)
    {
        /* Get number of endpoints configurations (ep). */
        pTmp = USBUART_GetConfigTablePtr(USBUART_configuration - 1u);
        pTmp = &pTmp[1u];
        ep = pTmp->c;

        /* Get pointer to endpoints setting table (pEP). */
        pEP = (const T_USBUART_EP_SETTINGS_BLOCK CYCODE *) pTmp->p_list;
        
        /* Look through all possible endpoint configurations. Find endpoints 
        * which belong to current interface and alternate settings for 
        * re-configuration.
        */
        interfaceNum = USBUART_interfaceNumber;
        for (i = 0u; i < ep; i++)
        {
            /* Find endpoints which belong to current interface and alternate settings. */
            if ((interfaceNum == pEP->interface) && 
                (USBUART_interfaceSetting[interfaceNum] == pEP->altSetting))
            {
                curEp  = ((uint8) pEP->addr & USBUART_DIR_UNUSED);
                epType = ((uint8) pEP->attributes & USBUART_EP_TYPE_MASK);
                
                /* Change the SIE mode for the selected EP to NAK ALL */
                USBUART_EP[curEp].epToggle   = 0u;
                USBUART_EP[curEp].addr       = pEP->addr;
                USBUART_EP[curEp].attrib     = pEP->attributes;
                USBUART_EP[curEp].bufferSize = pEP->bufferSize;

                if (0u != (pEP->addr & USBUART_DIR_IN))
                {
                    /* IN Endpoint */
                    USBUART_EP[curEp].epMode     = USBUART_GET_ACTIVE_IN_EP_CR0_MODE(epType);
                    USBUART_EP[curEp].apiEpState = USBUART_EVENT_PENDING;
                }
                else
                {
                    /* OUT Endpoint */
                    USBUART_EP[curEp].epMode     = USBUART_GET_ACTIVE_OUT_EP_CR0_MODE(epType);
                    USBUART_EP[curEp].apiEpState = USBUART_NO_EVENT_PENDING;
                }
                
                /* Make SIE to NAK any endpoint requests */
                USBUART_SIE_EP_BASE.sieEp[curEp].epCr0 = USBUART_MODE_NAK_IN_OUT;

            #if (USBUART_EP_MANAGEMENT_DMA_AUTO)
                /* Clear IN data ready. */
                USBUART_ARB_EP_BASE.arbEp[curEp].epCfg &= (uint8) ~USBUART_ARB_EPX_CFG_IN_DATA_RDY;

                /* Select endpoint number of reconfiguration */
                USBUART_DYN_RECONFIG_REG = (uint8) ((curEp - 1u) << USBUART_DYN_RECONFIG_EP_SHIFT);
                
                /* Request for dynamic re-configuration of endpoint. */
                USBUART_DYN_RECONFIG_REG |= USBUART_DYN_RECONFIG_ENABLE;
                
                /* Wait until block is ready for re-configuration */
                while (0u == (USBUART_DYN_RECONFIG_REG & USBUART_DYN_RECONFIG_RDY_STS))
                {
                }
                
                /* Once DYN_RECONFIG_RDY_STS bit is set, FW can change the EP configuration. */
                /* Change EP Type with new direction */
                if (0u != (pEP->addr & USBUART_DIR_IN))
                {
                    /* Set endpoint type: 0 - IN and 1 - OUT. */
                    USBUART_EP_TYPE_REG &= (uint8) ~(uint8)((uint8) 0x01u << (curEp - 1u));
                    
                #if (CY_PSOC4)
                    /* Clear DMA_TERMIN for IN endpoint */
                    USBUART_ARB_EP_BASE.arbEp[curEp].epIntEn &= (uint32) ~USBUART_ARB_EPX_INT_DMA_TERMIN;
                #endif /* (CY_PSOC4) */
                }
                else
                {
                    /* Set endpoint type: 0 - IN and 1- OUT. */
                    USBUART_EP_TYPE_REG |= (uint8) ((uint8) 0x01u << (curEp - 1u));
                    
                #if (CY_PSOC4)
                    /* Set DMA_TERMIN for OUT endpoint */
                    USBUART_ARB_EP_BASE.arbEp[curEp].epIntEn |= (uint32) USBUART_ARB_EPX_INT_DMA_TERMIN;
                #endif /* (CY_PSOC4) */
                }
                
                /* Complete dynamic re-configuration: all endpoint related status and signals 
                * are set into the default state.
                */
                USBUART_DYN_RECONFIG_REG &= (uint8) ~USBUART_DYN_RECONFIG_ENABLE;

            #else
                USBUART_SIE_EP_BASE.sieEp[curEp].epCnt0 = HI8(USBUART_EP[curEp].bufferSize);
                USBUART_SIE_EP_BASE.sieEp[curEp].epCnt1 = LO8(USBUART_EP[curEp].bufferSize);
                
                #if (CY_PSOC4)
                    USBUART_ARB_EP16_BASE.arbEp[curEp].rwRa16  = (uint32) USBUART_EP[curEp].buffOffset;
                    USBUART_ARB_EP16_BASE.arbEp[curEp].rwWa16  = (uint32) USBUART_EP[curEp].buffOffset;
                #else
                    USBUART_ARB_EP_BASE.arbEp[curEp].rwRa    = LO8(USBUART_EP[curEp].buffOffset);
                    USBUART_ARB_EP_BASE.arbEp[curEp].rwRaMsb = HI8(USBUART_EP[curEp].buffOffset);
                    USBUART_ARB_EP_BASE.arbEp[curEp].rwWa    = LO8(USBUART_EP[curEp].buffOffset);
                    USBUART_ARB_EP_BASE.arbEp[curEp].rwWaMsb = HI8(USBUART_EP[curEp].buffOffset);
                #endif /* (CY_PSOC4) */                
            #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */
            }
            
            pEP = &pEP[1u]; /* Get next EP element */
        }
        
        /* The main loop has to re-enable DMA and OUT endpoint */
    }
}


/*******************************************************************************
* Function Name: USBUART_GetConfigTablePtr
****************************************************************************//**
*
*  This routine returns a pointer a configuration table entry
*
*  \param confIndex:  Configuration Index
*
* \return
*  Device Descriptor pointer or NULL when descriptor does not exist.
*
*******************************************************************************/
const T_USBUART_LUT CYCODE *USBUART_GetConfigTablePtr(uint8 confIndex)
                                                        
{
    /* Device Table */
    const T_USBUART_LUT CYCODE *pTmp;

    pTmp = (const T_USBUART_LUT CYCODE *) USBUART_TABLE[USBUART_device].p_list;

    /* The first entry points to the Device Descriptor,
    *  the second entry point to the BOS Descriptor
    *  the rest configuration entries.
    *  Set pointer to the first Configuration Descriptor
    */
    pTmp = &pTmp[2u];
    /* For this table, c is the number of configuration descriptors  */
    if(confIndex >= pTmp->c)   /* Verify that required configuration descriptor exists */
    {
        pTmp = (const T_USBUART_LUT CYCODE *) NULL;
    }
    else
    {
        pTmp = (const T_USBUART_LUT CYCODE *) pTmp[confIndex].p_list;
    }

    return (pTmp);
}


#if (USBUART_BOS_ENABLE)
    /*******************************************************************************
    * Function Name: USBUART_GetBOSPtr
    ****************************************************************************//**
    *
    *  This routine returns a pointer a BOS table entry
    *
    *  
    *
    * \return
    *  BOS Descriptor pointer or NULL when descriptor does not exist.
    *
    *******************************************************************************/
    const T_USBUART_LUT CYCODE *USBUART_GetBOSPtr(void)
                                                            
    {
        /* Device Table */
        const T_USBUART_LUT CYCODE *pTmp;

        pTmp = (const T_USBUART_LUT CYCODE *) USBUART_TABLE[USBUART_device].p_list;

        /* The first entry points to the Device Descriptor,
        *  the second entry points to the BOS Descriptor
        */
        pTmp = &pTmp[1u];
        pTmp = (const T_USBUART_LUT CYCODE *) pTmp->p_list;
        return (pTmp);
    }
#endif /* (USBUART_BOS_ENABLE) */


/*******************************************************************************
* Function Name: USBUART_GetDeviceTablePtr
****************************************************************************//**
*
*  This routine returns a pointer to the Device table
*
* \return
*  Device Table pointer
*
*******************************************************************************/
const T_USBUART_LUT CYCODE *USBUART_GetDeviceTablePtr(void)
                                                            
{
    /* Device Table */
    return( (const T_USBUART_LUT CYCODE *) USBUART_TABLE[USBUART_device].p_list );
}


/*******************************************************************************
* Function Name: USB_GetInterfaceClassTablePtr
****************************************************************************//**
*
*  This routine returns Interface Class table pointer, which contains
*  the relation between interface number and interface class.
*
* \return
*  Interface Class table pointer.
*
*******************************************************************************/
const uint8 CYCODE *USBUART_GetInterfaceClassTablePtr(void)
                                                        
{
    const T_USBUART_LUT CYCODE *pTmp;
    const uint8 CYCODE *pInterfaceClass;
    uint8 currentInterfacesNum;

    pTmp = USBUART_GetConfigTablePtr(USBUART_configuration - 1u);
    if (pTmp != NULL)
    {
        currentInterfacesNum  = ((const uint8 *) pTmp->p_list)[USBUART_CONFIG_DESCR_NUM_INTERFACES];
        /* Third entry in the LUT starts the Interface Table pointers */
        /* The INTERFACE_CLASS table is located after all interfaces */
        pTmp = &pTmp[currentInterfacesNum + 2u];
        pInterfaceClass = (const uint8 CYCODE *) pTmp->p_list;
    }
    else
    {
        pInterfaceClass = (const uint8 CYCODE *) NULL;
    }

    return (pInterfaceClass);
}


/*******************************************************************************
* Function Name: USBUART_TerminateEP
****************************************************************************//**
*
*  This function terminates the specified USBFS endpoint.
*  This function should be used before endpoint reconfiguration.
*
*  \param ep Contains the data endpoint number.
*
*  \reentrant
*  No.
*
* \sideeffect
* 
* The device responds with a NAK for any transactions on the selected endpoint.
*   
*******************************************************************************/
void USBUART_TerminateEP(uint8 epNumber) 
{
    /* Get endpoint number */
    epNumber &= USBUART_DIR_UNUSED;

    if ((epNumber > USBUART_EP0) && (epNumber < USBUART_MAX_EP))
    {
        /* Set the endpoint Halt */
        USBUART_EP[epNumber].hwEpState |= USBUART_ENDPOINT_STATUS_HALT;

        /* Clear the data toggle */
        USBUART_EP[epNumber].epToggle = 0u;
        USBUART_EP[epNumber].apiEpState = USBUART_NO_EVENT_ALLOWED;

        if ((USBUART_EP[epNumber].addr & USBUART_DIR_IN) != 0u)
        {   
            /* IN Endpoint */
            USBUART_SIE_EP_BASE.sieEp[epNumber].epCr0 = USBUART_MODE_NAK_IN;
        }
        else
        {
            /* OUT Endpoint */
            USBUART_SIE_EP_BASE.sieEp[epNumber].epCr0 = USBUART_MODE_NAK_OUT;
        }
    }
}


/*******************************************************************************
* Function Name: USBUART_SetEndpointHalt
****************************************************************************//**
*
*  This routine handles set endpoint halt.
*
* \return
*  requestHandled.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_SetEndpointHalt(void) 
{
    uint8 requestHandled = USBUART_FALSE;
    uint8 ep;
    
    /* Set endpoint halt */
    ep = USBUART_wIndexLoReg & USBUART_DIR_UNUSED;

    if ((ep > USBUART_EP0) && (ep < USBUART_MAX_EP))
    {
        /* Set the endpoint Halt */
        USBUART_EP[ep].hwEpState |= (USBUART_ENDPOINT_STATUS_HALT);

        /* Clear the data toggle */
        USBUART_EP[ep].epToggle = 0u;
        USBUART_EP[ep].apiEpState |= USBUART_NO_EVENT_ALLOWED;

        if ((USBUART_EP[ep].addr & USBUART_DIR_IN) != 0u)
        {
            /* IN Endpoint */
            USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = (USBUART_MODE_STALL_DATA_EP | 
                                                            USBUART_MODE_ACK_IN);
        }
        else
        {
            /* OUT Endpoint */
            USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = (USBUART_MODE_STALL_DATA_EP | 
                                                            USBUART_MODE_ACK_OUT);
        }
        requestHandled = USBUART_InitNoDataControlTransfer();
    }

    return (requestHandled);
}


/*******************************************************************************
* Function Name: USBUART_ClearEndpointHalt
****************************************************************************//**
*
*  This routine handles clear endpoint halt.
*
* \return
*  requestHandled.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_ClearEndpointHalt(void) 
{
    uint8 requestHandled = USBUART_FALSE;
    uint8 ep;

    /* Clear endpoint halt */
    ep = USBUART_wIndexLoReg & USBUART_DIR_UNUSED;

    if ((ep > USBUART_EP0) && (ep < USBUART_MAX_EP))
    {
        /* Clear the endpoint Halt */
        USBUART_EP[ep].hwEpState &= (uint8) ~USBUART_ENDPOINT_STATUS_HALT;

        /* Clear the data toggle */
        USBUART_EP[ep].epToggle = 0u;
        
        /* Clear toggle bit for already armed packet */
        USBUART_SIE_EP_BASE.sieEp[ep].epCnt0 &= (uint8) ~(uint8)USBUART_EPX_CNT_DATA_TOGGLE;
        
        /* Return API State as it was defined before */
        USBUART_EP[ep].apiEpState &= (uint8) ~USBUART_NO_EVENT_ALLOWED;

        if ((USBUART_EP[ep].addr & USBUART_DIR_IN) != 0u)
        {
            /* IN Endpoint */
            if(USBUART_EP[ep].apiEpState == USBUART_IN_BUFFER_EMPTY)
            {       
                /* Wait for next packet from application */
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_NAK_IN;
            }
            else    /* Continue armed transfer */
            {
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_ACK_IN;
            }
        }
        else
        {
            /* OUT Endpoint */
            if (USBUART_EP[ep].apiEpState == USBUART_OUT_BUFFER_FULL)
            {       
                /* Allow application to read full buffer */
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_NAK_OUT;
            }
            else    /* Mark endpoint as empty, so it will be reloaded */
            {
                USBUART_SIE_EP_BASE.sieEp[ep].epCr0 = USBUART_MODE_ACK_OUT;
            }
        }
        
        requestHandled = USBUART_InitNoDataControlTransfer();
    }

    return(requestHandled);
}


/*******************************************************************************
* Function Name: USBUART_ValidateAlternateSetting
****************************************************************************//**
*
*  Validates (and records) a SET INTERFACE request.
*
* \return
*  requestHandled.
*
* \reentrant
*  No.
*
*******************************************************************************/
uint8 USBUART_ValidateAlternateSetting(void) 
{
    uint8 requestHandled = USBUART_FALSE;
    
    uint8 interfaceNum;
    uint8 curInterfacesNum;
    const T_USBUART_LUT CYCODE *pTmp;
    
    /* Get interface number from the request. */
    interfaceNum = (uint8) USBUART_wIndexLoReg;
    
    /* Get number of interfaces for current configuration. */
    pTmp = USBUART_GetConfigTablePtr(USBUART_configuration - 1u);
    curInterfacesNum  = ((const uint8 *) pTmp->p_list)[USBUART_CONFIG_DESCR_NUM_INTERFACES];

    /* Validate that interface number is within range. */
    if ((interfaceNum <= curInterfacesNum) || (interfaceNum <= USBUART_MAX_INTERFACES_NUMBER))
    {
        /* Save current and new alternate settings (come with request) to make 
        * desicion about following endpoint re-configuration.
        */
        USBUART_interfaceSettingLast[interfaceNum] = USBUART_interfaceSetting[interfaceNum];
        USBUART_interfaceSetting[interfaceNum]     = (uint8) USBUART_wValueLoReg;
        
        requestHandled = USBUART_TRUE;
    }

    return (requestHandled);
}


/* [] END OF FILE */
