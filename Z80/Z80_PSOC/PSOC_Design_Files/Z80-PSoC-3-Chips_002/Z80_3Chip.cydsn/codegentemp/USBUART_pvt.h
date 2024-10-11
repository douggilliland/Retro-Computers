/***************************************************************************//**
* \file .h
* \version 3.20
*
* \brief
*  This file provides private function prototypes and constants for the 
*  USBFS component. It is not intended to be used in the user project.
*
********************************************************************************
* \copyright
* Copyright 2013-2016, Cypress Semiconductor Corporation. All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_USBFS_USBUART_pvt_H)
#define CY_USBFS_USBUART_pvt_H

#include "USBUART.h"
   
#ifdef USBUART_ENABLE_AUDIO_CLASS
    #include "USBUART_audio.h"
#endif /* USBUART_ENABLE_AUDIO_CLASS */

#ifdef USBUART_ENABLE_CDC_CLASS
    #include "USBUART_cdc.h"
#endif /* USBUART_ENABLE_CDC_CLASS */

#if (USBUART_ENABLE_MIDI_CLASS)
    #include "USBUART_midi.h"
#endif /* (USBUART_ENABLE_MIDI_CLASS) */

#if (USBUART_ENABLE_MSC_CLASS)
    #include "USBUART_msc.h"
#endif /* (USBUART_ENABLE_MSC_CLASS) */

#if (USBUART_EP_MANAGEMENT_DMA)
    #if (CY_PSOC4)
        #include <CyDMA.h>
    #else
        #include <CyDmac.h>
        #if ((USBUART_EP_MANAGEMENT_DMA_AUTO) && (USBUART_EP_DMA_AUTO_OPT == 0u))
            #include "USBUART_EP_DMA_Done_isr.h"
            #include "USBUART_EP8_DMA_Done_SR.h"
            #include "USBUART_EP17_DMA_Done_SR.h"
        #endif /* ((USBUART_EP_MANAGEMENT_DMA_AUTO) && (USBUART_EP_DMA_AUTO_OPT == 0u)) */
    #endif /* (CY_PSOC4) */
#endif /* (USBUART_EP_MANAGEMENT_DMA) */

#if (USBUART_DMA1_ACTIVE)
    #include "USBUART_ep1_dma.h"
    #define USBUART_EP1_DMA_CH     (USBUART_ep1_dma_CHANNEL)
#endif /* (USBUART_DMA1_ACTIVE) */

#if (USBUART_DMA2_ACTIVE)
    #include "USBUART_ep2_dma.h"
    #define USBUART_EP2_DMA_CH     (USBUART_ep2_dma_CHANNEL)
#endif /* (USBUART_DMA2_ACTIVE) */

#if (USBUART_DMA3_ACTIVE)
    #include "USBUART_ep3_dma.h"
    #define USBUART_EP3_DMA_CH     (USBUART_ep3_dma_CHANNEL)
#endif /* (USBUART_DMA3_ACTIVE) */

#if (USBUART_DMA4_ACTIVE)
    #include "USBUART_ep4_dma.h"
    #define USBUART_EP4_DMA_CH     (USBUART_ep4_dma_CHANNEL)
#endif /* (USBUART_DMA4_ACTIVE) */

#if (USBUART_DMA5_ACTIVE)
    #include "USBUART_ep5_dma.h"
    #define USBUART_EP5_DMA_CH     (USBUART_ep5_dma_CHANNEL)
#endif /* (USBUART_DMA5_ACTIVE) */

#if (USBUART_DMA6_ACTIVE)
    #include "USBUART_ep6_dma.h"
    #define USBUART_EP6_DMA_CH     (USBUART_ep6_dma_CHANNEL)
#endif /* (USBUART_DMA6_ACTIVE) */

#if (USBUART_DMA7_ACTIVE)
    #include "USBUART_ep7_dma.h"
    #define USBUART_EP7_DMA_CH     (USBUART_ep7_dma_CHANNEL)
#endif /* (USBUART_DMA7_ACTIVE) */

#if (USBUART_DMA8_ACTIVE)
    #include "USBUART_ep8_dma.h"
    #define USBUART_EP8_DMA_CH     (USBUART_ep8_dma_CHANNEL)
#endif /* (USBUART_DMA8_ACTIVE) */


/***************************************
*     Private Variables
***************************************/

/* Generated external references for descriptors. */
extern const uint8 CYCODE USBUART_DEVICE0_DESCR[18u];
extern const uint8 CYCODE USBUART_DEVICE0_CONFIGURATION0_DESCR[67u];
extern const T_USBUART_EP_SETTINGS_BLOCK CYCODE USBUART_DEVICE0_CONFIGURATION0_EP_SETTINGS_TABLE[3u];
extern const uint8 CYCODE USBUART_DEVICE0_CONFIGURATION0_INTERFACE_CLASS[2u];
extern const T_USBUART_LUT CYCODE USBUART_DEVICE0_CONFIGURATION0_TABLE[5u];
extern const T_USBUART_LUT CYCODE USBUART_DEVICE0_TABLE[3u];
extern const T_USBUART_LUT CYCODE USBUART_TABLE[1u];
extern const uint8 CYCODE USBUART_SN_STRING_DESCRIPTOR[2];
extern const uint8 CYCODE USBUART_STRING_DESCRIPTORS[159u];


extern const uint8 CYCODE USBUART_MSOS_DESCRIPTOR[USBUART_MSOS_DESCRIPTOR_LENGTH];
extern const uint8 CYCODE USBUART_MSOS_CONFIGURATION_DESCR[USBUART_MSOS_CONF_DESCR_LENGTH];
#if defined(USBUART_ENABLE_IDSN_STRING)
    extern uint8 USBUART_idSerialNumberStringDescriptor[USBUART_IDSN_DESCR_LENGTH];
#endif /* (USBUART_ENABLE_IDSN_STRING) */

extern volatile uint8 USBUART_interfaceNumber;
extern volatile uint8 USBUART_interfaceSetting[USBUART_MAX_INTERFACES_NUMBER];
extern volatile uint8 USBUART_interfaceSettingLast[USBUART_MAX_INTERFACES_NUMBER];
extern volatile uint8 USBUART_deviceAddress;
extern volatile uint8 USBUART_interfaceStatus[USBUART_MAX_INTERFACES_NUMBER];
extern const uint8 CYCODE *USBUART_interfaceClass;

extern volatile T_USBUART_EP_CTL_BLOCK USBUART_EP[USBUART_MAX_EP];
extern volatile T_USBUART_TD USBUART_currentTD;

#if (USBUART_EP_MANAGEMENT_DMA)
    #if (CY_PSOC4)
        extern const uint8 USBUART_DmaChan[USBUART_MAX_EP];
    #else
        extern uint8 USBUART_DmaChan[USBUART_MAX_EP];
        extern uint8 USBUART_DmaTd  [USBUART_MAX_EP];
    #endif /* (CY_PSOC4) */
#endif /* (USBUART_EP_MANAGEMENT_DMA) */

#if (USBUART_EP_MANAGEMENT_DMA_AUTO)
#if (CY_PSOC4)
    extern uint8  USBUART_DmaEpBurstCnt   [USBUART_MAX_EP];
    extern uint8  USBUART_DmaEpLastBurstEl[USBUART_MAX_EP];

    extern uint8  USBUART_DmaEpBurstCntBackup  [USBUART_MAX_EP];
    extern uint32 USBUART_DmaEpBufferAddrBackup[USBUART_MAX_EP];
    
    extern const uint8 USBUART_DmaReqOut     [USBUART_MAX_EP];    
    extern const uint8 USBUART_DmaBurstEndOut[USBUART_MAX_EP];
#else
    #if (USBUART_EP_DMA_AUTO_OPT == 0u)
        extern uint8 USBUART_DmaNextTd[USBUART_MAX_EP];
        extern volatile uint16 USBUART_inLength [USBUART_MAX_EP];
        extern volatile uint8  USBUART_inBufFull[USBUART_MAX_EP];
        extern const uint8 USBUART_epX_TD_TERMOUT_EN[USBUART_MAX_EP];
        extern const uint8 *USBUART_inDataPointer[USBUART_MAX_EP];
    #endif /* (USBUART_EP_DMA_AUTO_OPT == 0u) */
#endif /* CY_PSOC4 */
#endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */

extern volatile uint8 USBUART_ep0Toggle;
extern volatile uint8 USBUART_lastPacketSize;
extern volatile uint8 USBUART_ep0Mode;
extern volatile uint8 USBUART_ep0Count;
extern volatile uint16 USBUART_transferByteCount;


/***************************************
*     Private Function Prototypes
***************************************/
void  USBUART_ReInitComponent(void)            ;
void  USBUART_HandleSetup(void)                ;
void  USBUART_HandleIN(void)                   ;
void  USBUART_HandleOUT(void)                  ;
void  USBUART_LoadEP0(void)                    ;
uint8 USBUART_InitControlRead(void)            ;
uint8 USBUART_InitControlWrite(void)           ;
void  USBUART_ControlReadDataStage(void)       ;
void  USBUART_ControlReadStatusStage(void)     ;
void  USBUART_ControlReadPrematureStatus(void) ;
uint8 USBUART_InitControlWrite(void)           ;
uint8 USBUART_InitZeroLengthControlTransfer(void) ;
void  USBUART_ControlWriteDataStage(void)      ;
void  USBUART_ControlWriteStatusStage(void)    ;
void  USBUART_ControlWritePrematureStatus(void);
uint8 USBUART_InitNoDataControlTransfer(void)  ;
void  USBUART_NoDataControlStatusStage(void)   ;
void  USBUART_InitializeStatusBlock(void)      ;
void  USBUART_UpdateStatusBlock(uint8 completionCode) ;
uint8 USBUART_DispatchClassRqst(void)          ;

void USBUART_Config(uint8 clearAltSetting) ;
void USBUART_ConfigAltChanged(void)        ;
void USBUART_ConfigReg(void)               ;
void USBUART_EpStateInit(void)             ;


const T_USBUART_LUT CYCODE *USBUART_GetConfigTablePtr(uint8 confIndex);
const T_USBUART_LUT CYCODE *USBUART_GetDeviceTablePtr(void)           ;
#if (USBUART_BOS_ENABLE)
    const T_USBUART_LUT CYCODE *USBUART_GetBOSPtr(void)               ;
#endif /* (USBUART_BOS_ENABLE) */
const uint8 CYCODE *USBUART_GetInterfaceClassTablePtr(void)                    ;
uint8 USBUART_ClearEndpointHalt(void)                                          ;
uint8 USBUART_SetEndpointHalt(void)                                            ;
uint8 USBUART_ValidateAlternateSetting(void)                                   ;

void USBUART_SaveConfig(void)      ;
void USBUART_RestoreConfig(void)   ;

#if (CY_PSOC3 || CY_PSOC5LP)
    #if (USBUART_EP_MANAGEMENT_DMA_AUTO && (USBUART_EP_DMA_AUTO_OPT == 0u))
        void USBUART_LoadNextInEP(uint8 epNumber, uint8 mode)  ;
    #endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO && (USBUART_EP_DMA_AUTO_OPT == 0u)) */
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

#if defined(USBUART_ENABLE_IDSN_STRING)
    void USBUART_ReadDieID(uint8 descr[])  ;
#endif /* USBUART_ENABLE_IDSN_STRING */

#if defined(USBUART_ENABLE_HID_CLASS)
    uint8 USBUART_DispatchHIDClassRqst(void) ;
#endif /* (USBUART_ENABLE_HID_CLASS) */

#if defined(USBUART_ENABLE_AUDIO_CLASS)
    uint8 USBUART_DispatchAUDIOClassRqst(void) ;
#endif /* (USBUART_ENABLE_AUDIO_CLASS) */

#if defined(USBUART_ENABLE_CDC_CLASS)
    uint8 USBUART_DispatchCDCClassRqst(void) ;
#endif /* (USBUART_ENABLE_CDC_CLASS) */

#if (USBUART_ENABLE_MSC_CLASS)
    #if (USBUART_HANDLE_MSC_REQUESTS)
        uint8 USBUART_DispatchMSCClassRqst(void) ;
    #endif /* (USBUART_HANDLE_MSC_REQUESTS) */
#endif /* (USBUART_ENABLE_MSC_CLASS */

CY_ISR_PROTO(USBUART_EP_0_ISR);
CY_ISR_PROTO(USBUART_BUS_RESET_ISR);

#if (USBUART_SOF_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_SOF_ISR);
#endif /* (USBUART_SOF_ISR_ACTIVE) */

#if (USBUART_EP1_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_1_ISR);
#endif /* (USBUART_EP1_ISR_ACTIVE) */

#if (USBUART_EP2_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_2_ISR);
#endif /* (USBUART_EP2_ISR_ACTIVE) */

#if (USBUART_EP3_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_3_ISR);
#endif /* (USBUART_EP3_ISR_ACTIVE) */

#if (USBUART_EP4_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_4_ISR);
#endif /* (USBUART_EP4_ISR_ACTIVE) */

#if (USBUART_EP5_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_5_ISR);
#endif /* (USBUART_EP5_ISR_ACTIVE) */

#if (USBUART_EP6_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_6_ISR);
#endif /* (USBUART_EP6_ISR_ACTIVE) */

#if (USBUART_EP7_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_7_ISR);
#endif /* (USBUART_EP7_ISR_ACTIVE) */

#if (USBUART_EP8_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_EP_8_ISR);
#endif /* (USBUART_EP8_ISR_ACTIVE) */

#if (USBUART_EP_MANAGEMENT_DMA)
    CY_ISR_PROTO(USBUART_ARB_ISR);
#endif /* (USBUART_EP_MANAGEMENT_DMA) */

#if (USBUART_DP_ISR_ACTIVE)
    CY_ISR_PROTO(USBUART_DP_ISR);
#endif /* (USBUART_DP_ISR_ACTIVE) */

#if (CY_PSOC4)
    CY_ISR_PROTO(USBUART_INTR_HI_ISR);
    CY_ISR_PROTO(USBUART_INTR_MED_ISR);
    CY_ISR_PROTO(USBUART_INTR_LO_ISR);
    #if (USBUART_LPM_ACTIVE)
        CY_ISR_PROTO(USBUART_LPM_ISR);
    #endif /* (USBUART_LPM_ACTIVE) */
#endif /* (CY_PSOC4) */

#if (USBUART_EP_MANAGEMENT_DMA_AUTO)
#if (CY_PSOC4)
    #if (USBUART_DMA1_ACTIVE)
        void USBUART_EP1_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA1_ACTIVE) */

    #if (USBUART_DMA2_ACTIVE)
        void USBUART_EP2_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA2_ACTIVE) */

    #if (USBUART_DMA3_ACTIVE)
        void USBUART_EP3_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA3_ACTIVE) */

    #if (USBUART_DMA4_ACTIVE)
        void USBUART_EP4_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA4_ACTIVE) */

    #if (USBUART_DMA5_ACTIVE)
        void USBUART_EP5_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA5_ACTIVE) */

    #if (USBUART_DMA6_ACTIVE)
        void USBUART_EP6_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA6_ACTIVE) */

    #if (USBUART_DMA7_ACTIVE)
        void USBUART_EP7_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA7_ACTIVE) */

    #if (USBUART_DMA8_ACTIVE)
        void USBUART_EP8_DMA_DONE_ISR(void);
    #endif /* (USBUART_DMA8_ACTIVE) */

#else
    #if (USBUART_EP_DMA_AUTO_OPT == 0u)
        CY_ISR_PROTO(USBUART_EP_DMA_DONE_ISR);
    #endif /* (USBUART_EP_DMA_AUTO_OPT == 0u) */
#endif /* (CY_PSOC4) */
#endif /* (USBUART_EP_MANAGEMENT_DMA_AUTO) */


/***************************************
*         Request Handlers
***************************************/

uint8 USBUART_HandleStandardRqst(void) ;
uint8 USBUART_DispatchClassRqst(void)  ;
uint8 USBUART_HandleVendorRqst(void)   ;


/***************************************
*    HID Internal references
***************************************/

#if defined(USBUART_ENABLE_HID_CLASS)
    void USBUART_FindReport(void)            ;
    void USBUART_FindReportDescriptor(void)  ;
    void USBUART_FindHidClassDecriptor(void) ;
#endif /* USBUART_ENABLE_HID_CLASS */


/***************************************
*    MIDI Internal references
***************************************/

#if defined(USBUART_ENABLE_MIDI_STREAMING)
    void USBUART_MIDI_IN_EP_Service(void)  ;
#endif /* (USBUART_ENABLE_MIDI_STREAMING) */


/***************************************
*    CDC Internal references
***************************************/

#if defined(USBUART_ENABLE_CDC_CLASS)

    typedef struct
    {
        uint8  bRequestType;
        uint8  bNotification;
        uint8  wValue;
        uint8  wValueMSB;
        uint8  wIndex;
        uint8  wIndexMSB;
        uint8  wLength;
        uint8  wLengthMSB;
        uint8  wSerialState;
        uint8  wSerialStateMSB;
    } t_USBUART_cdc_notification;

    uint8 USBUART_GetInterfaceComPort(uint8 interface) ;
    uint8 USBUART_Cdc_EpInit( const T_USBUART_EP_SETTINGS_BLOCK CYCODE *pEP, uint8 epNum, uint8 cdcComNums) ;

    extern volatile uint8  USBUART_cdc_dataInEpList[USBUART_MAX_MULTI_COM_NUM];
    extern volatile uint8  USBUART_cdc_dataOutEpList[USBUART_MAX_MULTI_COM_NUM];
    extern volatile uint8  USBUART_cdc_commInEpList[USBUART_MAX_MULTI_COM_NUM];
#endif /* (USBUART_ENABLE_CDC_CLASS) */


#endif /* CY_USBFS_USBUART_pvt_H */


/* [] END OF FILE */
