/***************************************************************************//**
* \file  USBUART_1.h
* \version 3.20
*
* \brief
*  This file provides function prototypes and constants for the USBFS component. 
*
********************************************************************************
* \copyright
* Copyright 2008-2016, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_USBFS_USBUART_1_H)
#define CY_USBFS_USBUART_1_H

#include "cydevice_trm.h"
#include "cyfitter.h"
#include "cytypes.h"
#include "CyLib.h"
#include "cyapicallbacks.h"

/*  User supplied definitions. */
/* `#START USER_DEFINITIONS` Place your declaration here */

/* `#END` */

/***************************************
* Enumerated Types and Parameters
***************************************/

/* USB IP memory management options. */
#define USBUART_1__EP_MANUAL    (0u)
#define USBUART_1__EP_DMAMANUAL (1u)
#define USBUART_1__EP_DMAAUTO   (2u)

/* USB IP memory allocation options. */
#define USBUART_1__MA_STATIC    (0u)
#define USBUART_1__MA_DYNAMIC   (1u)


/***************************************
*    Initial Parameter Constants
***************************************/

#define USBUART_1_NUM_DEVICES                  (1u)
#define USBUART_1_ENABLE_CDC_CLASS             
#define USBUART_1_ENABLE_MIDI_CLASS            (0u)
#define USBUART_1_ENABLE_MSC_CLASS             (0u)
#define USBUART_1_BOS_ENABLE                   (0u)
#define USBUART_1_ENABLE_DESCRIPTOR_STRINGS    
#define USBUART_1_ENABLE_SN_STRING             
#define USBUART_1_ENABLE_IDSN_STRING           
#define USBUART_1_ENABLE_STRINGS               
#define USBUART_1_MAX_REPORTID_NUMBER          (0u)

#define USBUART_1_MON_VBUS               (0u)
#define USBUART_1_EXTERN_VBUS            (0u)
#define USBUART_1_POWER_PAD_VBUS         (0u)
#define USBUART_1_EXTERN_VND             (0u)
#define USBUART_1_EXTERN_CLS             (0u)
#define USBUART_1_MAX_INTERFACES_NUMBER  (2u)
#define USBUART_1_EP_MM                  (0u)
#define USBUART_1_EP_MA                  (0u)
#define USBUART_1_ENABLE_BATT_CHARG_DET  (0u)
#define USBUART_1_GEN_16BITS_EP_ACCESS   (1u)

/* Enable Class APIs: MIDI, CDC, MSC. */         
#define USBUART_1_ENABLE_CDC_CLASS_API   (0u != (1u))

/* General parameters */
#define USBUART_1_EP_ALLOC_STATIC            (USBUART_1_EP_MA == USBUART_1__MA_STATIC)
#define USBUART_1_EP_ALLOC_DYNAMIC           (USBUART_1_EP_MA == USBUART_1__MA_DYNAMIC)
#define USBUART_1_EP_MANAGEMENT_MANUAL       (USBUART_1_EP_MM == USBUART_1__EP_MANUAL)
#define USBUART_1_EP_MANAGEMENT_DMA          (USBUART_1_EP_MM != USBUART_1__EP_MANUAL)
#define USBUART_1_EP_MANAGEMENT_DMA_MANUAL   (USBUART_1_EP_MM == USBUART_1__EP_DMAMANUAL)
#define USBUART_1_EP_MANAGEMENT_DMA_AUTO     (USBUART_1_EP_MM == USBUART_1__EP_DMAAUTO)
#define USBUART_1_BATT_CHARG_DET_ENABLE      (CY_PSOC4 && (0u != USBUART_1_ENABLE_BATT_CHARG_DET))
#define USBUART_1_16BITS_EP_ACCESS_ENABLE    (CY_PSOC4 && (0u != USBUART_1_GEN_16BITS_EP_ACCESS))
#define USBUART_1_VBUS_MONITORING_ENABLE     (0u != USBUART_1_MON_VBUS)
#define USBUART_1_VBUS_MONITORING_INTERNAL   (0u == USBUART_1_EXTERN_VBUS)
#define USBUART_1_VBUS_POWER_PAD_ENABLE      (0u != USBUART_1_POWER_PAD_VBUS)

/* Control endpoints availability */
#define USBUART_1_SOF_ISR_REMOVE       (0u)
#define USBUART_1_BUS_RESET_ISR_REMOVE (0u)
#define USBUART_1_EP0_ISR_REMOVE       (0u)
#define USBUART_1_ARB_ISR_REMOVE       (0u)
#define USBUART_1_DP_ISR_REMOVE        (0u)
#define USBUART_1_LPM_REMOVE           (1u)
#define USBUART_1_SOF_ISR_ACTIVE       ((0u == USBUART_1_SOF_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_BUS_RESET_ISR_ACTIVE ((0u == USBUART_1_BUS_RESET_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP0_ISR_ACTIVE       ((0u == USBUART_1_EP0_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_ARB_ISR_ACTIVE       ((0u == USBUART_1_ARB_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_DP_ISR_ACTIVE        ((0u == USBUART_1_DP_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_LPM_ACTIVE           ((CY_PSOC4 && (0u == USBUART_1_LPM_REMOVE)) ? 1u: 0u)

/* Data endpoints availability */
#define USBUART_1_EP1_ISR_REMOVE     (0u)
#define USBUART_1_EP2_ISR_REMOVE     (0u)
#define USBUART_1_EP3_ISR_REMOVE     (0u)
#define USBUART_1_EP4_ISR_REMOVE     (1u)
#define USBUART_1_EP5_ISR_REMOVE     (1u)
#define USBUART_1_EP6_ISR_REMOVE     (1u)
#define USBUART_1_EP7_ISR_REMOVE     (1u)
#define USBUART_1_EP8_ISR_REMOVE     (1u)
#define USBUART_1_EP1_ISR_ACTIVE     ((0u == USBUART_1_EP1_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP2_ISR_ACTIVE     ((0u == USBUART_1_EP2_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP3_ISR_ACTIVE     ((0u == USBUART_1_EP3_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP4_ISR_ACTIVE     ((0u == USBUART_1_EP4_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP5_ISR_ACTIVE     ((0u == USBUART_1_EP5_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP6_ISR_ACTIVE     ((0u == USBUART_1_EP6_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP7_ISR_ACTIVE     ((0u == USBUART_1_EP7_ISR_REMOVE) ? 1u: 0u)
#define USBUART_1_EP8_ISR_ACTIVE     ((0u == USBUART_1_EP8_ISR_REMOVE) ? 1u: 0u)

#define USBUART_1_EP_DMA_AUTO_OPT    ((CY_PSOC4) ? (1u) : (0u))
#define USBUART_1_DMA1_REMOVE        (1u)
#define USBUART_1_DMA2_REMOVE        (1u)
#define USBUART_1_DMA3_REMOVE        (1u)
#define USBUART_1_DMA4_REMOVE        (1u)
#define USBUART_1_DMA5_REMOVE        (1u)
#define USBUART_1_DMA6_REMOVE        (1u)
#define USBUART_1_DMA7_REMOVE        (1u)
#define USBUART_1_DMA8_REMOVE        (1u)
#define USBUART_1_DMA1_ACTIVE        ((0u == USBUART_1_DMA1_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA2_ACTIVE        ((0u == USBUART_1_DMA2_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA3_ACTIVE        ((0u == USBUART_1_DMA3_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA4_ACTIVE        ((0u == USBUART_1_DMA4_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA5_ACTIVE        ((0u == USBUART_1_DMA5_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA6_ACTIVE        ((0u == USBUART_1_DMA6_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA7_ACTIVE        ((0u == USBUART_1_DMA7_REMOVE) ? 1u: 0u)
#define USBUART_1_DMA8_ACTIVE        ((0u == USBUART_1_DMA8_REMOVE) ? 1u: 0u)


/***************************************
*    Data Structures Definition
***************************************/

typedef struct
{
    uint8  attrib;
    uint8  apiEpState;
    uint8  hwEpState;
    uint8  epToggle;
    uint8  addr;
    uint8  epMode;
    uint16 buffOffset;
    uint16 bufferSize;
    uint8  interface;
} T_USBUART_1_EP_CTL_BLOCK;

typedef struct
{
    uint8  interface;
    uint8  altSetting;
    uint8  addr;
    uint8  attributes;
    uint16 bufferSize;
    uint8  bMisc;
} T_USBUART_1_EP_SETTINGS_BLOCK;

typedef struct
{
    uint8  status;
    uint16 length;
} T_USBUART_1_XFER_STATUS_BLOCK;

typedef struct
{
    uint16  count;
    volatile uint8 *pData;
    T_USBUART_1_XFER_STATUS_BLOCK *pStatusBlock;
} T_USBUART_1_TD;

typedef struct
{
    uint8   c;
    const void *p_list;
} T_USBUART_1_LUT;

/* Resume/Suspend API Support */
typedef struct
{
    uint8 enableState;
    uint8 mode;
#if (CY_PSOC4)
    uint8 intrSeiMask;
#endif /* (CY_PSOC4) */
} USBUART_1_BACKUP_STRUCT;

/* Number of endpoint 0 data registers. */
#define USBUART_1_EP0_DR_MAPPED_REG_CNT  (8u)

/* Structure to access data registers for EP0. */
typedef struct
{
    uint8 epData[USBUART_1_EP0_DR_MAPPED_REG_CNT];
} USBUART_1_ep0_data_struct;

/* Number of SIE endpoint registers group. */
#define USBUART_1_SIE_EP_REG_SIZE   (USBUART_1_USB__SIE_EP1_CR0 - \
                                            USBUART_1_USB__SIE_EP1_CNT0)

/* Size of gap between SIE endpoint registers groups. */
#define USBUART_1_SIE_GAP_CNT        (((USBUART_1_USB__SIE_EP2_CNT0 - \
                                             (USBUART_1_USB__SIE_EP1_CNT0 + \
                                              USBUART_1_SIE_EP_REG_SIZE)) / sizeof(reg8)) - 1u)

/* Structure to access to SIE registers for endpoint. */
typedef struct
{
    uint8 epCnt0;
    uint8 epCnt1;
    uint8 epCr0;
    uint8 gap[USBUART_1_SIE_GAP_CNT];
} USBUART_1_sie_ep_struct;

/* Number of ARB endpoint registers group. */
#define USBUART_1_ARB_EP_REG_SIZE    (USBUART_1_USB__ARB_RW1_DR - \
                                             USBUART_1_USB__ARB_EP1_CFG)

/* Size of gap between ARB endpoint registers groups. */
#define USBUART_1_ARB_GAP_CNT        (((USBUART_1_USB__ARB_EP2_CFG - \
                                             (USBUART_1_USB__ARB_EP1_CFG + \
                                              USBUART_1_ARB_EP_REG_SIZE)) / sizeof(reg8)) - 1u)

/* Structure to access to ARB registers for endpoint. */
typedef struct
{
    uint8 epCfg;
    uint8 epIntEn;
    uint8 epSr;
    uint8 reserved;
    uint8 rwWa;
    uint8 rwWaMsb;
    uint8 rwRa;
    uint8 rwRaMsb;
    uint8 rwDr;
    uint8 gap[USBUART_1_ARB_GAP_CNT];
} USBUART_1_arb_ep_struct;

#if (CY_PSOC4)
    /* Number of ARB endpoint registers group (16-bits access). */
    #define USBUART_1_ARB_EP_REG16_SIZE      (USBUART_1_USB__ARB_RW1_DR16 - \
                                                     USBUART_1_USB__ARB_RW1_WA16)

    /* Size of gap between ARB endpoint registers groups (16-bits access). */
    #define USBUART_1_ARB_EP_REG16_GAP_CNT   (((USBUART_1_USB__ARB_RW2_WA16 - \
                                                     (USBUART_1_USB__ARB_RW1_WA16 + \
                                                      USBUART_1_ARB_EP_REG16_SIZE)) / sizeof(reg8)) - 1u)

    /* Structure to access to ARB registers for endpoint (16-bits access). */
    typedef struct
    {
        uint8 rwWa16;
        uint8 reserved0;
        uint8 rwRa16;
        uint8 reserved1;
        uint8 rwDr16;
        uint8 gap[USBUART_1_ARB_EP_REG16_GAP_CNT];
    } USBUART_1_arb_ep_reg16_struct;
#endif /* (CY_PSOC4) */

/* Number of endpoint (takes to account that endpoints numbers are 1-8). */
#define USBUART_1_NUMBER_EP  (9u)

/* Consoled SIE register groups for endpoints 1-8. */
typedef struct
{
    USBUART_1_sie_ep_struct sieEp[USBUART_1_NUMBER_EP];
} USBUART_1_sie_eps_struct;

/* Consolidate ARB register groups for endpoints 1-8.*/
typedef struct
{
    USBUART_1_arb_ep_struct arbEp[USBUART_1_NUMBER_EP];
} USBUART_1_arb_eps_struct;

#if (CY_PSOC4)
    /* Consolidate ARB register groups for endpoints 1-8 (16-bits access). */
    typedef struct
    {
        USBUART_1_arb_ep_reg16_struct arbEp[USBUART_1_NUMBER_EP];
    } USBUART_1_arb_eps_reg16_struct;
#endif /* (CY_PSOC4) */


/***************************************
*       Function Prototypes
***************************************/
/**
* \addtogroup group_general
* @{
*/
void   USBUART_1_InitComponent(uint8 device, uint8 mode) ;
void   USBUART_1_Start(uint8 device, uint8 mode)         ;
void   USBUART_1_Init(void)                              ;
void   USBUART_1_Stop(void)                              ;
uint8  USBUART_1_GetConfiguration(void)                  ;
uint8  USBUART_1_IsConfigurationChanged(void)            ;
uint8  USBUART_1_GetInterfaceSetting(uint8 interfaceNumber) ;
uint8  USBUART_1_GetEPState(uint8 epNumber)              ;
uint16 USBUART_1_GetEPCount(uint8 epNumber)              ;
void   USBUART_1_LoadInEP(uint8 epNumber, const uint8 pData[], uint16 length)
                                                                ;
uint16 USBUART_1_ReadOutEP(uint8 epNumber, uint8 pData[], uint16 length)
                                                                ;
void   USBUART_1_EnableOutEP(uint8 epNumber)             ;
void   USBUART_1_DisableOutEP(uint8 epNumber)            ;
void   USBUART_1_Force(uint8 bState)                     ;
uint8  USBUART_1_GetEPAckState(uint8 epNumber)           ;
void   USBUART_1_SetPowerStatus(uint8 powerStatus)       ;
void   USBUART_1_TerminateEP(uint8 epNumber)             ;

uint8 USBUART_1_GetDeviceAddress(void) ;

void USBUART_1_EnableSofInt(void)  ;
void USBUART_1_DisableSofInt(void) ;


#if defined(USBUART_1_ENABLE_FWSN_STRING)
    void   USBUART_1_SerialNumString(uint8 snString[]) ;
#endif  /* USBUART_1_ENABLE_FWSN_STRING */

#if (USBUART_1_VBUS_MONITORING_ENABLE)
    uint8  USBUART_1_VBusPresent(void) ;
#endif /*  (USBUART_1_VBUS_MONITORING_ENABLE) */

#if (USBUART_1_16BITS_EP_ACCESS_ENABLE)
    /* PSoC4 specific functions for 16-bit data register access. */
    void   USBUART_1_LoadInEP16 (uint8 epNumber, const uint8 pData[], uint16 length);
    uint16 USBUART_1_ReadOutEP16(uint8 epNumber,       uint8 pData[], uint16 length);
#endif /* (USBUART_1_16BITS_EP_ACCESS_ENABLE) */

#if (USBUART_1_BATT_CHARG_DET_ENABLE)
        uint8 USBUART_1_Bcd_DetectPortType(void);
#endif /* (USBUART_1_BATT_CHARG_DET_ENABLE) */

#if (USBUART_1_EP_MANAGEMENT_DMA)
    void USBUART_1_InitEP_DMA(uint8 epNumber, const uint8 *pData) ;   
    void USBUART_1_Stop_DMA(uint8 epNumber) ;
/** @} general */ 
#endif /* (USBUART_1_EP_MANAGEMENT_DMA) */

/**
* \addtogroup group_power
* @{
*/
uint8  USBUART_1_CheckActivity(void) ;
void   USBUART_1_Suspend(void)       ;
void   USBUART_1_Resume(void)        ;
uint8  USBUART_1_RWUEnabled(void)    ;

#if (USBUART_1_LPM_ACTIVE)
    uint32 USBUART_1_Lpm_GetBeslValue(void);
    uint32 USBUART_1_Lpm_RemoteWakeUpAllowed(void);
    void   USBUART_1_Lpm_SetResponse(uint32 response);
    uint32 USBUART_1_Lpm_GetResponse(void);
#endif /* (USBUART_1_LPM_ACTIVE) */

/** @} power */


#if defined(CYDEV_BOOTLOADER_IO_COMP) && ((CYDEV_BOOTLOADER_IO_COMP == CyBtldr_USBUART_1) || \
                                          (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_Custom_Interface))
/**
* \addtogroup group_bootloader
* @{
*/
    void USBUART_1_CyBtldrCommStart(void)        ;
    void USBUART_1_CyBtldrCommStop(void)         ;
    void USBUART_1_CyBtldrCommReset(void)        ;
    cystatus USBUART_1_CyBtldrCommWrite(const uint8 pData[], uint16 size, uint16 *count, uint8 timeOut) CYSMALL
                                                        ;
    cystatus USBUART_1_CyBtldrCommRead       (uint8 pData[], uint16 size, uint16 *count, uint8 timeOut) CYSMALL
                                                        ;
/** @} bootloader */

    #define USBUART_1_BTLDR_OUT_EP   (0x01u)
    #define USBUART_1_BTLDR_IN_EP    (0x02u)

    #define USBUART_1_BTLDR_SIZEOF_WRITE_BUFFER  (64u)   /* Endpoint 1 (OUT) buffer size. */
    #define USBUART_1_BTLDR_SIZEOF_READ_BUFFER   (64u)   /* Endpoint 2 (IN)  buffer size. */
    #define USBUART_1_BTLDR_MAX_PACKET_SIZE      USBUART_1_BTLDR_SIZEOF_WRITE_BUFFER

    #define USBUART_1_BTLDR_WAIT_1_MS            (1u)    /* Time Out quantity equal 1mS */

    /* Map-specific USB bootloader communication functions to common bootloader functions */
    #if (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_USBUART_1)
        #define CyBtldrCommStart        USBUART_1_CyBtldrCommStart
        #define CyBtldrCommStop         USBUART_1_CyBtldrCommStop
        #define CyBtldrCommReset        USBUART_1_CyBtldrCommReset
        #define CyBtldrCommWrite        USBUART_1_CyBtldrCommWrite
        #define CyBtldrCommRead         USBUART_1_CyBtldrCommRead
    #endif /* (CYDEV_BOOTLOADER_IO_COMP == CyBtldr_USBUART_1) */
#endif /* CYDEV_BOOTLOADER_IO_COMP */


/***************************************
*          API Constants
***************************************/

#define USBUART_1_EP0                        (0u)
#define USBUART_1_EP1                        (1u)
#define USBUART_1_EP2                        (2u)
#define USBUART_1_EP3                        (3u)
#define USBUART_1_EP4                        (4u)
#define USBUART_1_EP5                        (5u)
#define USBUART_1_EP6                        (6u)
#define USBUART_1_EP7                        (7u)
#define USBUART_1_EP8                        (8u)
#define USBUART_1_MAX_EP                     (9u)

#define USBUART_1_TRUE                       (1u)
#define USBUART_1_FALSE                      (0u)

#define USBUART_1_NO_EVENT_ALLOWED           (2u)
#define USBUART_1_EVENT_PENDING              (1u)
#define USBUART_1_NO_EVENT_PENDING           (0u)

#define USBUART_1_IN_BUFFER_FULL             USBUART_1_NO_EVENT_PENDING
#define USBUART_1_IN_BUFFER_EMPTY            USBUART_1_EVENT_PENDING
#define USBUART_1_OUT_BUFFER_FULL            USBUART_1_EVENT_PENDING
#define USBUART_1_OUT_BUFFER_EMPTY           USBUART_1_NO_EVENT_PENDING

#define USBUART_1_FORCE_J                    (0xA0u)
#define USBUART_1_FORCE_K                    (0x80u)
#define USBUART_1_FORCE_SE0                  (0xC0u)
#define USBUART_1_FORCE_NONE                 (0x00u)

#define USBUART_1_IDLE_TIMER_RUNNING         (0x02u)
#define USBUART_1_IDLE_TIMER_EXPIRED         (0x01u)
#define USBUART_1_IDLE_TIMER_INDEFINITE      (0x00u)

#define USBUART_1_DEVICE_STATUS_BUS_POWERED  (0x00u)
#define USBUART_1_DEVICE_STATUS_SELF_POWERED (0x01u)

#define USBUART_1_3V_OPERATION               (0x00u)
#define USBUART_1_5V_OPERATION               (0x01u)
#define USBUART_1_DWR_POWER_OPERATION        (0x02u)

#define USBUART_1_MODE_DISABLE               (0x00u)
#define USBUART_1_MODE_NAK_IN_OUT            (0x01u)
#define USBUART_1_MODE_STATUS_OUT_ONLY       (0x02u)
#define USBUART_1_MODE_STALL_IN_OUT          (0x03u)
#define USBUART_1_MODE_RESERVED_0100         (0x04u)
#define USBUART_1_MODE_ISO_OUT               (0x05u)
#define USBUART_1_MODE_STATUS_IN_ONLY        (0x06u)
#define USBUART_1_MODE_ISO_IN                (0x07u)
#define USBUART_1_MODE_NAK_OUT               (0x08u)
#define USBUART_1_MODE_ACK_OUT               (0x09u)
#define USBUART_1_MODE_RESERVED_1010         (0x0Au)
#define USBUART_1_MODE_ACK_OUT_STATUS_IN     (0x0Bu)
#define USBUART_1_MODE_NAK_IN                (0x0Cu)
#define USBUART_1_MODE_ACK_IN                (0x0Du)
#define USBUART_1_MODE_RESERVED_1110         (0x0Eu)
#define USBUART_1_MODE_ACK_IN_STATUS_OUT     (0x0Fu)
#define USBUART_1_MODE_MASK                  (0x0Fu)
#define USBUART_1_MODE_STALL_DATA_EP         (0x80u)

#define USBUART_1_MODE_ACKD                  (0x10u)
#define USBUART_1_MODE_OUT_RCVD              (0x20u)
#define USBUART_1_MODE_IN_RCVD               (0x40u)
#define USBUART_1_MODE_SETUP_RCVD            (0x80u)

#define USBUART_1_RQST_TYPE_MASK             (0x60u)
#define USBUART_1_RQST_TYPE_STD              (0x00u)
#define USBUART_1_RQST_TYPE_CLS              (0x20u)
#define USBUART_1_RQST_TYPE_VND              (0x40u)
#define USBUART_1_RQST_DIR_MASK              (0x80u)
#define USBUART_1_RQST_DIR_D2H               (0x80u)
#define USBUART_1_RQST_DIR_H2D               (0x00u)
#define USBUART_1_RQST_RCPT_MASK             (0x03u)
#define USBUART_1_RQST_RCPT_DEV              (0x00u)
#define USBUART_1_RQST_RCPT_IFC              (0x01u)
#define USBUART_1_RQST_RCPT_EP               (0x02u)
#define USBUART_1_RQST_RCPT_OTHER            (0x03u)

#if (USBUART_1_LPM_ACTIVE)
    #define USBUART_1_LPM_REQ_ACK            (0x01u << USBUART_1_LPM_CTRL_LPM_ACK_RESP_POS)
    #define USBUART_1_LPM_REQ_NACK           (0x00u)
    #define USBUART_1_LPM_REQ_NYET           (0x01u << USBUART_1_LPM_CTRL_NYET_EN_POS)
#endif /*(USBUART_1_LPM_ACTIVE)*/

/* USB Class Codes */
#define USBUART_1_CLASS_DEVICE               (0x00u)     /* Use class code info from Interface Descriptors */
#define USBUART_1_CLASS_AUDIO                (0x01u)     /* Audio device */
#define USBUART_1_CLASS_CDC                  (0x02u)     /* Communication device class */
#define USBUART_1_CLASS_HID                  (0x03u)     /* Human Interface Device */
#define USBUART_1_CLASS_PDC                  (0x05u)     /* Physical device class */
#define USBUART_1_CLASS_IMAGE                (0x06u)     /* Still Imaging device */
#define USBUART_1_CLASS_PRINTER              (0x07u)     /* Printer device  */
#define USBUART_1_CLASS_MSD                  (0x08u)     /* Mass Storage device  */
#define USBUART_1_CLASS_HUB                  (0x09u)     /* Full/Hi speed Hub */
#define USBUART_1_CLASS_CDC_DATA             (0x0Au)     /* CDC data device */
#define USBUART_1_CLASS_SMART_CARD           (0x0Bu)     /* Smart Card device */
#define USBUART_1_CLASS_CSD                  (0x0Du)     /* Content Security device */
#define USBUART_1_CLASS_VIDEO                (0x0Eu)     /* Video device */
#define USBUART_1_CLASS_PHD                  (0x0Fu)     /* Personal Health care device */
#define USBUART_1_CLASS_WIRELESSD            (0xDCu)     /* Wireless Controller */
#define USBUART_1_CLASS_MIS                  (0xE0u)     /* Miscellaneous */
#define USBUART_1_CLASS_APP                  (0xEFu)     /* Application Specific */
#define USBUART_1_CLASS_VENDOR               (0xFFu)     /* Vendor specific */

/* Standard Request Types (Table 9-4) */
#define USBUART_1_GET_STATUS                 (0x00u)
#define USBUART_1_CLEAR_FEATURE              (0x01u)
#define USBUART_1_SET_FEATURE                (0x03u)
#define USBUART_1_SET_ADDRESS                (0x05u)
#define USBUART_1_GET_DESCRIPTOR             (0x06u)
#define USBUART_1_SET_DESCRIPTOR             (0x07u)
#define USBUART_1_GET_CONFIGURATION          (0x08u)
#define USBUART_1_SET_CONFIGURATION          (0x09u)
#define USBUART_1_GET_INTERFACE              (0x0Au)
#define USBUART_1_SET_INTERFACE              (0x0Bu)
#define USBUART_1_SYNCH_FRAME                (0x0Cu)

/* Vendor Specific Request Types */
/* Request for Microsoft OS String Descriptor */
#define USBUART_1_GET_EXTENDED_CONFIG_DESCRIPTOR (0x01u)

/* Descriptor Types (Table 9-5) */
#define USBUART_1_DESCR_DEVICE                   (1u)
#define USBUART_1_DESCR_CONFIG                   (2u)
#define USBUART_1_DESCR_STRING                   (3u)
#define USBUART_1_DESCR_INTERFACE                (4u)
#define USBUART_1_DESCR_ENDPOINT                 (5u)
#define USBUART_1_DESCR_DEVICE_QUALIFIER         (6u)
#define USBUART_1_DESCR_OTHER_SPEED              (7u)
#define USBUART_1_DESCR_INTERFACE_POWER          (8u)
#if (USBUART_1_BOS_ENABLE)
    #define USBUART_1_DESCR_BOS                  (15u)
#endif /* (USBUART_1_BOS_ENABLE) */
/* Device Descriptor Defines */
#define USBUART_1_DEVICE_DESCR_LENGTH            (18u)
#define USBUART_1_DEVICE_DESCR_SN_SHIFT          (16u)

/* Config Descriptor Shifts and Masks */
#define USBUART_1_CONFIG_DESCR_LENGTH                (0u)
#define USBUART_1_CONFIG_DESCR_TYPE                  (1u)
#define USBUART_1_CONFIG_DESCR_TOTAL_LENGTH_LOW      (2u)
#define USBUART_1_CONFIG_DESCR_TOTAL_LENGTH_HI       (3u)
#define USBUART_1_CONFIG_DESCR_NUM_INTERFACES        (4u)
#define USBUART_1_CONFIG_DESCR_CONFIG_VALUE          (5u)
#define USBUART_1_CONFIG_DESCR_CONFIGURATION         (6u)
#define USBUART_1_CONFIG_DESCR_ATTRIB                (7u)
#define USBUART_1_CONFIG_DESCR_ATTRIB_SELF_POWERED   (0x40u)
#define USBUART_1_CONFIG_DESCR_ATTRIB_RWU_EN         (0x20u)

#if (USBUART_1_BOS_ENABLE)
    /* Config Descriptor BOS */
    #define USBUART_1_BOS_DESCR_LENGTH               (0u)
    #define USBUART_1_BOS_DESCR_TYPE                 (1u)
    #define USBUART_1_BOS_DESCR_TOTAL_LENGTH_LOW     (2u)
    #define USBUART_1_BOS_DESCR_TOTAL_LENGTH_HI      (3u)
    #define USBUART_1_BOS_DESCR_NUM_DEV_CAPS         (4u)
#endif /* (USBUART_1_BOS_ENABLE) */

/* Feature Selectors (Table 9-6) */
#define USBUART_1_DEVICE_REMOTE_WAKEUP           (0x01u)
#define USBUART_1_ENDPOINT_HALT                  (0x00u)
#define USBUART_1_TEST_MODE                      (0x02u)

/* USB Device Status (Figure 9-4) */
#define USBUART_1_DEVICE_STATUS_BUS_POWERED      (0x00u)
#define USBUART_1_DEVICE_STATUS_SELF_POWERED     (0x01u)
#define USBUART_1_DEVICE_STATUS_REMOTE_WAKEUP    (0x02u)

/* USB Endpoint Status (Figure 9-4) */
#define USBUART_1_ENDPOINT_STATUS_HALT           (0x01u)

/* USB Endpoint Directions */
#define USBUART_1_DIR_IN                         (0x80u)
#define USBUART_1_DIR_OUT                        (0x00u)
#define USBUART_1_DIR_UNUSED                     (0x7Fu)

/* USB Endpoint Attributes */
#define USBUART_1_EP_TYPE_CTRL                   (0x00u)
#define USBUART_1_EP_TYPE_ISOC                   (0x01u)
#define USBUART_1_EP_TYPE_BULK                   (0x02u)
#define USBUART_1_EP_TYPE_INT                    (0x03u)
#define USBUART_1_EP_TYPE_MASK                   (0x03u)

#define USBUART_1_EP_SYNC_TYPE_NO_SYNC           (0x00u)
#define USBUART_1_EP_SYNC_TYPE_ASYNC             (0x04u)
#define USBUART_1_EP_SYNC_TYPE_ADAPTIVE          (0x08u)
#define USBUART_1_EP_SYNC_TYPE_SYNCHRONOUS       (0x0Cu)
#define USBUART_1_EP_SYNC_TYPE_MASK              (0x0Cu)

#define USBUART_1_EP_USAGE_TYPE_DATA             (0x00u)
#define USBUART_1_EP_USAGE_TYPE_FEEDBACK         (0x10u)
#define USBUART_1_EP_USAGE_TYPE_IMPLICIT         (0x20u)
#define USBUART_1_EP_USAGE_TYPE_RESERVED         (0x30u)
#define USBUART_1_EP_USAGE_TYPE_MASK             (0x30u)

/* Point Status defines */
#define USBUART_1_EP_STATUS_LENGTH               (0x02u)

/* Point Device defines */
#define USBUART_1_DEVICE_STATUS_LENGTH           (0x02u)

#define USBUART_1_STATUS_LENGTH_MAX \
                 ((USBUART_1_EP_STATUS_LENGTH > USBUART_1_DEVICE_STATUS_LENGTH) ? \
                        USBUART_1_EP_STATUS_LENGTH : USBUART_1_DEVICE_STATUS_LENGTH)

/* Transfer Completion Notification */
#define USBUART_1_XFER_IDLE                      (0x00u)
#define USBUART_1_XFER_STATUS_ACK                (0x01u)
#define USBUART_1_XFER_PREMATURE                 (0x02u)
#define USBUART_1_XFER_ERROR                     (0x03u)

/* Driver State defines */
#define USBUART_1_TRANS_STATE_IDLE               (0x00u)
#define USBUART_1_TRANS_STATE_CONTROL_READ       (0x02u)
#define USBUART_1_TRANS_STATE_CONTROL_WRITE      (0x04u)
#define USBUART_1_TRANS_STATE_NO_DATA_CONTROL    (0x06u)

/* String Descriptor defines */
#define USBUART_1_STRING_MSOS                    (0xEEu)
#define USBUART_1_MSOS_DESCRIPTOR_LENGTH         (18u)
#define USBUART_1_MSOS_CONF_DESCR_LENGTH         (40u)

/* Return values */
#define USBUART_1_BCD_PORT_SDP       (1u) /* Standard downstream port detected */
#define USBUART_1_BCD_PORT_CDP       (2u) /* Charging downstream port detected */
#define USBUART_1_BCD_PORT_DCP       (3u) /* Dedicated charging port detected */
#define USBUART_1_BCD_PORT_UNKNOWN   (0u) /* Unable to detect charging port */
#define USBUART_1_BCD_PORT_ERR       (4u) /* Error condition in detection process*/


/* Timeouts for BCD */
#define USBUART_1_BCD_TIMEOUT                (400u)  /* Copied from PBK#163 TIMEOUT (300 ms) */
#define USBUART_1_BCD_TDCD_DBNC              (10u)  /*BCD v1.2: DCD debounce time 10 ms*/
#define USBUART_1_BCD_PRIMARY_WAIT           (40u)   /* Copied from PBK#163 TIMEOUT (40 ms)  */
#define USBUART_1_BCD_SECONDARY_WAIT         (47u)   /* Copied from PBK#163 TIMEOUT (40 ms)  */
#define USBUART_1_BCD_SUSPEND_DISABLE_WAIT   (2u)    /* Copied from PBK#163 TIMEOUT (2 us)   */

/* Wait cycles required before clearing SUSPEND_DEL in POWER_CTRL: 2us */
#define USBUART_1_WAIT_SUSPEND_DEL_DISABLE   (2u)

/* Wait cycles required for USB regulator stabilization after it is enabled : 50ns */
#define USBUART_1_WAIT_VREF_STABILITY        (0u)

#if (CY_PSOC3 || CY_PSOC5LP)
/* Wait cycles required for USB reference restore: 40us */
#define USBUART_1_WAIT_VREF_RESTORE          (40u)

/* Wait cycles required for stabilization after register is written : 50ns */
#define USBUART_1_WAIT_REG_STABILITY_50NS    (0u)
#define USBUART_1_WAIT_REG_STABILITY_1US     (1u)

/* Wait cycles required after CR0 register write: 1 cycle */
#define USBUART_1_WAIT_CR0_REG_STABILITY     (1u)

/* Wait cycles required after PD_PULLUP_N bit is set in PM_USB_CR0: 2us */
#define USBUART_1_WAIT_PD_PULLUP_N_ENABLE    (2u)
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

#if (CY_PSOC4)
    #if (USBUART_1_EP_MANAGEMENT_DMA)
        #define USBUART_1_DMA_DESCR0         (0u)
        #define USBUART_1_DMA_DESCR1         (1u)
    #endif /* (USBUART_1_EP_MANAGEMENT_DMA) */

    #if (USBUART_1_EP_MANAGEMENT_DMA_AUTO)
        /* BUF_SIZE-BYTES_PER_BURST examples: 0x55 - 32 bytes, 0x44 - 16 bytes, 0x33 - 8 bytes, etc. */
        #define USBUART_1_DMA_BUF_SIZE             (0x55u)
        #define USBUART_1_DMA_BYTES_PER_BURST      (32u)
        #define USBUART_1_DMA_HALFWORDS_PER_BURST  (16u)
        #define USBUART_1_DMA_BURST_BYTES_MASK     (USBUART_1_DMA_BYTES_PER_BURST - 1u)

        #define USBUART_1_DMA_DESCR0_MASK        (0x00u)
        #define USBUART_1_DMA_DESCR1_MASK        (0x80u)
        #define USBUART_1_DMA_DESCR_REVERT       (0x40u)
        #define USBUART_1_DMA_DESCR_16BITS       (0x20u)
        #define USBUART_1_DMA_DESCR_SHIFT        (7u)

        #define USBUART_1_DMA_GET_DESCR_NUM(desrc)
        #define USBUART_1_DMA_GET_BURST_CNT(dmaBurstCnt) \
                    (((dmaBurstCnt) > 2u)? ((dmaBurstCnt) - 2u) : 0u)

        #define USBUART_1_DMA_GET_MAX_ELEM_PER_BURST(dmaLastBurstEl) \
                    ((0u != ((dmaLastBurstEl) & USBUART_1_DMA_DESCR_16BITS)) ? \
                                (USBUART_1_DMA_HALFWORDS_PER_BURST - 1u) : (USBUART_1_DMA_BYTES_PER_BURST - 1u))
    #endif /* (USBUART_1_EP_MANAGEMENT_DMA_AUTO) */
#else
    #if (USBUART_1_EP_MANAGEMENT_DMA_MANUAL)
        #define USBUART_1_DMA_BYTES_PER_BURST    (0u)
        #define USBUART_1_DMA_REQUEST_PER_BURST  (0u)
    #endif /* (USBUART_1_EP_MANAGEMENT_DMA_MANUAL) */

    #if (USBUART_1_EP_MANAGEMENT_DMA_AUTO)
        #define USBUART_1_DMA_BYTES_PER_BURST    (32u)
        #define USBUART_1_DMA_BYTES_REPEAT       (2u)

        /* BUF_SIZE-BYTES_PER_BURST examples: 0x55 - 32 bytes, 0x44 - 16 bytes, 0x33 - 8 bytes, etc. */
        #define USBUART_1_DMA_BUF_SIZE           (0x55u)
        #define USBUART_1_DMA_REQUEST_PER_BURST  (1u)

        #define USBUART_1_EP17_SR_MASK           (0x7Fu)
        #define USBUART_1_EP8_SR_MASK            (0x03u)
    #endif /* (USBUART_1_EP_MANAGEMENT_DMA_AUTO) */
#endif /* (CY_PSOC4) */

/* DIE ID string descriptor defines */
#if defined(USBUART_1_ENABLE_IDSN_STRING)
    #define USBUART_1_IDSN_DESCR_LENGTH      (0x22u)
#endif /* (USBUART_1_ENABLE_IDSN_STRING) */


/***************************************
*     Vars with External Linkage
***************************************/

/**
* \addtogroup group_globals
* @{
*/
extern uint8 USBUART_1_initVar;
extern volatile uint8 USBUART_1_device;
extern volatile uint8 USBUART_1_transferState;
extern volatile uint8 USBUART_1_configuration;
extern volatile uint8 USBUART_1_configurationChanged;
extern volatile uint8 USBUART_1_deviceStatus;
/** @} globals */

/**
* \addtogroup group_hid
* @{
*/
/* HID Variables */
#if defined(USBUART_1_ENABLE_HID_CLASS)
    extern volatile uint8 USBUART_1_hidProtocol [USBUART_1_MAX_INTERFACES_NUMBER]; 
    extern volatile uint8 USBUART_1_hidIdleRate [USBUART_1_MAX_INTERFACES_NUMBER];
    extern volatile uint8 USBUART_1_hidIdleTimer[USBUART_1_MAX_INTERFACES_NUMBER];
#endif /* (USBUART_1_ENABLE_HID_CLASS) */
/** @} hid */


/***************************************
*              Registers
***************************************/

/* Common registers for all PSoCs: 3/4/5LP */
#define USBUART_1_ARB_CFG_PTR        ( (reg8 *) USBUART_1_USB__ARB_CFG)
#define USBUART_1_ARB_CFG_REG        (*(reg8 *) USBUART_1_USB__ARB_CFG)

#define USBUART_1_ARB_EP1_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP1_CFG)
#define USBUART_1_ARB_EP1_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP1_CFG)
#define USBUART_1_ARB_EP1_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP1_INT_EN)
#define USBUART_1_ARB_EP1_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP1_INT_EN)
#define USBUART_1_ARB_EP1_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP1_SR)
#define USBUART_1_ARB_EP1_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP1_SR)
#define USBUART_1_ARB_EP1_CFG_IND    USBUART_1_USB__ARB_EP1_CFG
#define USBUART_1_ARB_EP1_INT_EN_IND USBUART_1_USB__ARB_EP1_INT_EN
#define USBUART_1_ARB_EP1_SR_IND     USBUART_1_USB__ARB_EP1_SR
#define USBUART_1_ARB_EP_BASE        (*(volatile USBUART_1_arb_eps_struct CYXDATA *) \
                                            (USBUART_1_USB__ARB_EP1_CFG - sizeof(USBUART_1_arb_ep_struct)))

#define USBUART_1_ARB_EP2_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP2_CFG)
#define USBUART_1_ARB_EP2_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP2_CFG)
#define USBUART_1_ARB_EP2_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP2_INT_EN)
#define USBUART_1_ARB_EP2_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP2_INT_EN)
#define USBUART_1_ARB_EP2_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP2_SR)
#define USBUART_1_ARB_EP2_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP2_SR)

#define USBUART_1_ARB_EP3_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP3_CFG)
#define USBUART_1_ARB_EP3_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP3_CFG)
#define USBUART_1_ARB_EP3_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP3_INT_EN)
#define USBUART_1_ARB_EP3_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP3_INT_EN)
#define USBUART_1_ARB_EP3_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP3_SR)
#define USBUART_1_ARB_EP3_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP3_SR)

#define USBUART_1_ARB_EP4_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP4_CFG)
#define USBUART_1_ARB_EP4_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP4_CFG)
#define USBUART_1_ARB_EP4_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP4_INT_EN)
#define USBUART_1_ARB_EP4_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP4_INT_EN)
#define USBUART_1_ARB_EP4_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP4_SR)
#define USBUART_1_ARB_EP4_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP4_SR)

#define USBUART_1_ARB_EP5_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP5_CFG)
#define USBUART_1_ARB_EP5_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP5_CFG)
#define USBUART_1_ARB_EP5_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP5_INT_EN)
#define USBUART_1_ARB_EP5_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP5_INT_EN)
#define USBUART_1_ARB_EP5_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP5_SR)
#define USBUART_1_ARB_EP5_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP5_SR)

#define USBUART_1_ARB_EP6_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP6_CFG)
#define USBUART_1_ARB_EP6_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP6_CFG)
#define USBUART_1_ARB_EP6_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP6_INT_EN)
#define USBUART_1_ARB_EP6_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP6_INT_EN)
#define USBUART_1_ARB_EP6_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP6_SR)
#define USBUART_1_ARB_EP6_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP6_SR)

#define USBUART_1_ARB_EP7_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP7_CFG)
#define USBUART_1_ARB_EP7_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP7_CFG)
#define USBUART_1_ARB_EP7_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP7_INT_EN)
#define USBUART_1_ARB_EP7_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP7_INT_EN)
#define USBUART_1_ARB_EP7_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP7_SR)
#define USBUART_1_ARB_EP7_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP7_SR)

#define USBUART_1_ARB_EP8_CFG_PTR    ( (reg8 *) USBUART_1_USB__ARB_EP8_CFG)
#define USBUART_1_ARB_EP8_CFG_REG    (*(reg8 *) USBUART_1_USB__ARB_EP8_CFG)
#define USBUART_1_ARB_EP8_INT_EN_PTR ( (reg8 *) USBUART_1_USB__ARB_EP8_INT_EN)
#define USBUART_1_ARB_EP8_INT_EN_REG (*(reg8 *) USBUART_1_USB__ARB_EP8_INT_EN)
#define USBUART_1_ARB_EP8_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_EP8_SR)
#define USBUART_1_ARB_EP8_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_EP8_SR)

#define USBUART_1_ARB_INT_EN_PTR     ( (reg8 *) USBUART_1_USB__ARB_INT_EN)
#define USBUART_1_ARB_INT_EN_REG     (*(reg8 *) USBUART_1_USB__ARB_INT_EN)
#define USBUART_1_ARB_INT_SR_PTR     ( (reg8 *) USBUART_1_USB__ARB_INT_SR)
#define USBUART_1_ARB_INT_SR_REG     (*(reg8 *) USBUART_1_USB__ARB_INT_SR)

#define USBUART_1_ARB_RW1_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW1_DR)
#define USBUART_1_ARB_RW1_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW1_RA)

#define USBUART_1_ARB_RW1_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW1_RA_MSB)
#define USBUART_1_ARB_RW1_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW1_WA)
#define USBUART_1_ARB_RW1_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW1_WA_MSB)
#define USBUART_1_ARB_RW1_DR_IND     USBUART_1_USB__ARB_RW1_DR
#define USBUART_1_ARB_RW1_RA_IND     USBUART_1_USB__ARB_RW1_RA
#define USBUART_1_ARB_RW1_RA_MSB_IND USBUART_1_USB__ARB_RW1_RA_MSB
#define USBUART_1_ARB_RW1_WA_IND     USBUART_1_USB__ARB_RW1_WA
#define USBUART_1_ARB_RW1_WA_MSB_IND USBUART_1_USB__ARB_RW1_WA_MSB

#define USBUART_1_ARB_RW2_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW2_DR)
#define USBUART_1_ARB_RW2_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW2_RA)
#define USBUART_1_ARB_RW2_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW2_RA_MSB)
#define USBUART_1_ARB_RW2_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW2_WA)
#define USBUART_1_ARB_RW2_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW2_WA_MSB)

#define USBUART_1_ARB_RW3_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW3_DR)
#define USBUART_1_ARB_RW3_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW3_RA)
#define USBUART_1_ARB_RW3_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW3_RA_MSB)
#define USBUART_1_ARB_RW3_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW3_WA)
#define USBUART_1_ARB_RW3_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW3_WA_MSB)

#define USBUART_1_ARB_RW4_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW4_DR)
#define USBUART_1_ARB_RW4_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW4_RA)
#define USBUART_1_ARB_RW4_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW4_RA_MSB)
#define USBUART_1_ARB_RW4_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW4_WA)
#define USBUART_1_ARB_RW4_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW4_WA_MSB)

#define USBUART_1_ARB_RW5_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW5_DR)
#define USBUART_1_ARB_RW5_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW5_RA)
#define USBUART_1_ARB_RW5_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW5_RA_MSB)
#define USBUART_1_ARB_RW5_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW5_WA)
#define USBUART_1_ARB_RW5_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW5_WA_MSB)

#define USBUART_1_ARB_RW6_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW6_DR)
#define USBUART_1_ARB_RW6_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW6_RA)
#define USBUART_1_ARB_RW6_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW6_RA_MSB)
#define USBUART_1_ARB_RW6_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW6_WA)
#define USBUART_1_ARB_RW6_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW6_WA_MSB)

#define USBUART_1_ARB_RW7_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW7_DR)
#define USBUART_1_ARB_RW7_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW7_RA)
#define USBUART_1_ARB_RW7_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW7_RA_MSB)
#define USBUART_1_ARB_RW7_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW7_WA)
#define USBUART_1_ARB_RW7_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW7_WA_MSB)

#define USBUART_1_ARB_RW8_DR_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW8_DR)
#define USBUART_1_ARB_RW8_RA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW8_RA)
#define USBUART_1_ARB_RW8_RA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW8_RA_MSB)
#define USBUART_1_ARB_RW8_WA_PTR     ( (reg8 *) USBUART_1_USB__ARB_RW8_WA)
#define USBUART_1_ARB_RW8_WA_MSB_PTR ( (reg8 *) USBUART_1_USB__ARB_RW8_WA_MSB)

#define USBUART_1_BUF_SIZE_PTR       ( (reg8 *) USBUART_1_USB__BUF_SIZE)
#define USBUART_1_BUF_SIZE_REG       (*(reg8 *) USBUART_1_USB__BUF_SIZE)
#define USBUART_1_BUS_RST_CNT_PTR    ( (reg8 *) USBUART_1_USB__BUS_RST_CNT)
#define USBUART_1_BUS_RST_CNT_REG    (*(reg8 *) USBUART_1_USB__BUS_RST_CNT)
#define USBUART_1_CWA_PTR            ( (reg8 *) USBUART_1_USB__CWA)
#define USBUART_1_CWA_REG            (*(reg8 *) USBUART_1_USB__CWA)
#define USBUART_1_CWA_MSB_PTR        ( (reg8 *) USBUART_1_USB__CWA_MSB)
#define USBUART_1_CWA_MSB_REG        (*(reg8 *) USBUART_1_USB__CWA_MSB)
#define USBUART_1_CR0_PTR            ( (reg8 *) USBUART_1_USB__CR0)
#define USBUART_1_CR0_REG            (*(reg8 *) USBUART_1_USB__CR0)
#define USBUART_1_CR1_PTR            ( (reg8 *) USBUART_1_USB__CR1)
#define USBUART_1_CR1_REG            (*(reg8 *) USBUART_1_USB__CR1)

#define USBUART_1_DMA_THRES_PTR      ( (reg8 *) USBUART_1_USB__DMA_THRES)
#define USBUART_1_DMA_THRES_REG      (*(reg8 *) USBUART_1_USB__DMA_THRES)
#define USBUART_1_DMA_THRES_MSB_PTR  ( (reg8 *) USBUART_1_USB__DMA_THRES_MSB)
#define USBUART_1_DMA_THRES_MSB_REG  (*(reg8 *) USBUART_1_USB__DMA_THRES_MSB)

#define USBUART_1_EP_ACTIVE_PTR      ( (reg8 *) USBUART_1_USB__EP_ACTIVE)
#define USBUART_1_EP_ACTIVE_REG      (*(reg8 *) USBUART_1_USB__EP_ACTIVE)
#define USBUART_1_EP_TYPE_PTR        ( (reg8 *) USBUART_1_USB__EP_TYPE)
#define USBUART_1_EP_TYPE_REG        (*(reg8 *) USBUART_1_USB__EP_TYPE)

#define USBUART_1_EP0_CNT_PTR        ( (reg8 *) USBUART_1_USB__EP0_CNT)
#define USBUART_1_EP0_CNT_REG        (*(reg8 *) USBUART_1_USB__EP0_CNT)
#define USBUART_1_EP0_CR_PTR         ( (reg8 *) USBUART_1_USB__EP0_CR)
#define USBUART_1_EP0_CR_REG         (*(reg8 *) USBUART_1_USB__EP0_CR)
#define USBUART_1_EP0_DR0_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR0)
#define USBUART_1_EP0_DR0_REG        (*(reg8 *) USBUART_1_USB__EP0_DR0)
#define USBUART_1_EP0_DR1_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR1)
#define USBUART_1_EP0_DR1_REG        (*(reg8 *) USBUART_1_USB__EP0_DR1)
#define USBUART_1_EP0_DR2_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR2)
#define USBUART_1_EP0_DR2_REG        (*(reg8 *) USBUART_1_USB__EP0_DR2)
#define USBUART_1_EP0_DR3_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR3)
#define USBUART_1_EP0_DR3_REG        (*(reg8 *) USBUART_1_USB__EP0_DR3)
#define USBUART_1_EP0_DR4_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR4)
#define USBUART_1_EP0_DR4_REG        (*(reg8 *) USBUART_1_USB__EP0_DR4)
#define USBUART_1_EP0_DR5_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR5)
#define USBUART_1_EP0_DR5_REG        (*(reg8 *) USBUART_1_USB__EP0_DR5)
#define USBUART_1_EP0_DR6_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR6)
#define USBUART_1_EP0_DR6_REG        (*(reg8 *) USBUART_1_USB__EP0_DR6)
#define USBUART_1_EP0_DR7_PTR        ( (reg8 *) USBUART_1_USB__EP0_DR7)
#define USBUART_1_EP0_DR7_REG        (*(reg8 *) USBUART_1_USB__EP0_DR7)
#define USBUART_1_EP0_DR0_IND        USBUART_1_USB__EP0_DR0
#define USBUART_1_EP0_DR_BASE        (*(volatile USBUART_1_ep0_data_struct CYXDATA *) USBUART_1_USB__EP0_DR0)

#define USBUART_1_OSCLK_DR0_PTR      ( (reg8 *) USBUART_1_USB__OSCLK_DR0)
#define USBUART_1_OSCLK_DR0_REG      (*(reg8 *) USBUART_1_USB__OSCLK_DR0)
#define USBUART_1_OSCLK_DR1_PTR      ( (reg8 *) USBUART_1_USB__OSCLK_DR1)
#define USBUART_1_OSCLK_DR1_REG      (*(reg8 *) USBUART_1_USB__OSCLK_DR1)

#define USBUART_1_SIE_EP_INT_EN_PTR  ( (reg8 *) USBUART_1_USB__SIE_EP_INT_EN)
#define USBUART_1_SIE_EP_INT_EN_REG  (*(reg8 *) USBUART_1_USB__SIE_EP_INT_EN)
#define USBUART_1_SIE_EP_INT_SR_PTR  ( (reg8 *) USBUART_1_USB__SIE_EP_INT_SR)
#define USBUART_1_SIE_EP_INT_SR_REG  (*(reg8 *) USBUART_1_USB__SIE_EP_INT_SR)

#define USBUART_1_SIE_EP1_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP1_CNT0)
#define USBUART_1_SIE_EP1_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP1_CNT0)
#define USBUART_1_SIE_EP1_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP1_CNT1)
#define USBUART_1_SIE_EP1_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP1_CNT1)
#define USBUART_1_SIE_EP1_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP1_CR0)
#define USBUART_1_SIE_EP1_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP1_CR0)
#define USBUART_1_SIE_EP1_CNT1_IND   USBUART_1_USB__SIE_EP1_CNT1
#define USBUART_1_SIE_EP1_CNT0_IND   USBUART_1_USB__SIE_EP1_CNT0
#define USBUART_1_SIE_EP1_CR0_IND    USBUART_1_USB__SIE_EP1_CR0
#define USBUART_1_SIE_EP_BASE        (*(volatile USBUART_1_sie_eps_struct CYXDATA *) \
                                            (USBUART_1_USB__SIE_EP1_CNT0 - sizeof(USBUART_1_sie_ep_struct)))

#define USBUART_1_SIE_EP2_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP2_CNT0)
#define USBUART_1_SIE_EP2_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP2_CNT0)
#define USBUART_1_SIE_EP2_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP2_CNT1)
#define USBUART_1_SIE_EP2_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP2_CNT1)
#define USBUART_1_SIE_EP2_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP2_CR0)
#define USBUART_1_SIE_EP2_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP2_CR0)

#define USBUART_1_SIE_EP3_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP3_CNT0)
#define USBUART_1_SIE_EP3_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP3_CNT0)
#define USBUART_1_SIE_EP3_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP3_CNT1)
#define USBUART_1_SIE_EP3_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP3_CNT1)
#define USBUART_1_SIE_EP3_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP3_CR0)
#define USBUART_1_SIE_EP3_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP3_CR0)

#define USBUART_1_SIE_EP4_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP4_CNT0)
#define USBUART_1_SIE_EP4_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP4_CNT0)
#define USBUART_1_SIE_EP4_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP4_CNT1)
#define USBUART_1_SIE_EP4_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP4_CNT1)
#define USBUART_1_SIE_EP4_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP4_CR0)
#define USBUART_1_SIE_EP4_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP4_CR0)

#define USBUART_1_SIE_EP5_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP5_CNT0)
#define USBUART_1_SIE_EP5_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP5_CNT0)
#define USBUART_1_SIE_EP5_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP5_CNT1)
#define USBUART_1_SIE_EP5_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP5_CNT1)
#define USBUART_1_SIE_EP5_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP5_CR0)
#define USBUART_1_SIE_EP5_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP5_CR0)

#define USBUART_1_SIE_EP6_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP6_CNT0)
#define USBUART_1_SIE_EP6_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP6_CNT0)
#define USBUART_1_SIE_EP6_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP6_CNT1)
#define USBUART_1_SIE_EP6_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP6_CNT1)
#define USBUART_1_SIE_EP6_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP6_CR0)
#define USBUART_1_SIE_EP6_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP6_CR0)

#define USBUART_1_SIE_EP7_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP7_CNT0)
#define USBUART_1_SIE_EP7_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP7_CNT0)
#define USBUART_1_SIE_EP7_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP7_CNT1)
#define USBUART_1_SIE_EP7_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP7_CNT1)
#define USBUART_1_SIE_EP7_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP7_CR0)
#define USBUART_1_SIE_EP7_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP7_CR0)

#define USBUART_1_SIE_EP8_CNT0_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP8_CNT0)
#define USBUART_1_SIE_EP8_CNT0_REG   (*(reg8 *) USBUART_1_USB__SIE_EP8_CNT0)
#define USBUART_1_SIE_EP8_CNT1_PTR   ( (reg8 *) USBUART_1_USB__SIE_EP8_CNT1)
#define USBUART_1_SIE_EP8_CNT1_REG   (*(reg8 *) USBUART_1_USB__SIE_EP8_CNT1)
#define USBUART_1_SIE_EP8_CR0_PTR    ( (reg8 *) USBUART_1_USB__SIE_EP8_CR0)
#define USBUART_1_SIE_EP8_CR0_REG    (*(reg8 *) USBUART_1_USB__SIE_EP8_CR0)

#define USBUART_1_SOF0_PTR           ( (reg8 *) USBUART_1_USB__SOF0)
#define USBUART_1_SOF0_REG           (*(reg8 *) USBUART_1_USB__SOF0)
#define USBUART_1_SOF1_PTR           ( (reg8 *) USBUART_1_USB__SOF1)
#define USBUART_1_SOF1_REG           (*(reg8 *) USBUART_1_USB__SOF1)

#define USBUART_1_USB_CLK_EN_PTR     ( (reg8 *) USBUART_1_USB__USB_CLK_EN)
#define USBUART_1_USB_CLK_EN_REG     (*(reg8 *) USBUART_1_USB__USB_CLK_EN)

#define USBUART_1_USBIO_CR0_PTR      ( (reg8 *) USBUART_1_USB__USBIO_CR0)
#define USBUART_1_USBIO_CR0_REG      (*(reg8 *) USBUART_1_USB__USBIO_CR0)
#define USBUART_1_USBIO_CR1_PTR      ( (reg8 *) USBUART_1_USB__USBIO_CR1)
#define USBUART_1_USBIO_CR1_REG      (*(reg8 *) USBUART_1_USB__USBIO_CR1)

#define USBUART_1_DYN_RECONFIG_PTR   ( (reg8 *) USBUART_1_USB__DYN_RECONFIG)
#define USBUART_1_DYN_RECONFIG_REG   (*(reg8 *) USBUART_1_USB__DYN_RECONFIG)

#if (CY_PSOC4)
    #define USBUART_1_ARB_RW1_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_RA16)
    #define USBUART_1_ARB_RW1_RA16_REG   (*(reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_RA16)
    #define USBUART_1_ARB_RW1_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_WA16)
    #define USBUART_1_ARB_RW1_WA16_REG   (*(reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_WA16)
    #define USBUART_1_ARB_RW1_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_DR16)
    #define USBUART_1_ARB_RW1_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW1_DR16)
    #define USBUART_1_ARB_EP16_BASE      (*(volatile USBUART_1_arb_eps_reg16_struct CYXDATA *) \
                                                (USBUART_1_USB__ARB_RW1_WA16 - sizeof(USBUART_1_arb_ep_reg16_struct)))

    #define USBUART_1_ARB_RW2_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW2_DR16)
    #define USBUART_1_ARB_RW2_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW2_RA16)
    #define USBUART_1_ARB_RW2_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW2_WA16)

    #define USBUART_1_ARB_RW3_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW3_DR16)
    #define USBUART_1_ARB_RW3_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW3_RA16)
    #define USBUART_1_ARB_RW3_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW3_WA16)

    #define USBUART_1_ARB_RW4_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW4_DR16)
    #define USBUART_1_ARB_RW4_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW4_RA16)
    #define USBUART_1_ARB_RW4_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW4_WA16)

    #define USBUART_1_ARB_RW5_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW5_DR16)
    #define USBUART_1_ARB_RW5_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW5_RA16)
    #define USBUART_1_ARB_RW5_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW5_WA16)

    #define USBUART_1_ARB_RW6_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW6_DR16)
    #define USBUART_1_ARB_RW6_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW6_RA16)
    #define USBUART_1_ARB_RW6_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW6_WA16)

    #define USBUART_1_ARB_RW7_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW7_DR16)
    #define USBUART_1_ARB_RW7_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW7_RA16)
    #define USBUART_1_ARB_RW7_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW7_WA16)

    #define USBUART_1_ARB_RW8_DR16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW8_DR16)
    #define USBUART_1_ARB_RW8_RA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW8_RA16)
    #define USBUART_1_ARB_RW8_WA16_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__ARB_RW8_WA16)

    #define USBUART_1_OSCLK_DR16_PTR     ( (reg32 *) USBUART_1_cy_m0s8_usb__OSCLK_DR16)
    #define USBUART_1_OSCLK_DR16_REG     (*(reg32 *) USBUART_1_cy_m0s8_usb__OSCLK_DR16)

    #define USBUART_1_SOF16_PTR          ( (reg32 *) USBUART_1_cy_m0s8_usb__SOF16)
    #define USBUART_1_SOF16_REG          (*(reg32 *) USBUART_1_cy_m0s8_usb__SOF16)
    
    #define USBUART_1_CWA16_PTR          ( (reg32 *) USBUART_1_cy_m0s8_usb__CWA16)
    #define USBUART_1_CWA16_REG          (*(reg32 *) USBUART_1_cy_m0s8_usb__CWA16)

    #define USBUART_1_DMA_THRES16_PTR    ( (reg32 *) USBUART_1_cy_m0s8_usb__DMA_THRES16)
    #define USBUART_1_DMA_THRES16_REG    (*(reg32 *) USBUART_1_cy_m0s8_usb__DMA_THRES16)

    #define USBUART_1_USB_CLK_EN_PTR     ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_CLK_EN)
    #define USBUART_1_USB_CLK_EN_REG     (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_CLK_EN)

    #define USBUART_1_USBIO_CR2_PTR      ( (reg32 *) USBUART_1_cy_m0s8_usb__USBIO_CR2)
    #define USBUART_1_USBIO_CR2_REG      (*(reg32 *) USBUART_1_cy_m0s8_usb__USBIO_CR2)

    #define USBUART_1_USB_MEM            ( (reg32 *) USBUART_1_cy_m0s8_usb__MEM_DATA0)

    #define USBUART_1_POWER_CTRL_REG      (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_POWER_CTRL)
    #define USBUART_1_POWER_CTRL_PTR      ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_POWER_CTRL)

    #define USBUART_1_CHGDET_CTRL_REG     (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_CHGDET_CTRL)
    #define USBUART_1_CHGDET_CTRL_PTR     ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_CHGDET_CTRL)

    #define USBUART_1_USBIO_CTRL_REG      (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_USBIO_CTRL)
    #define USBUART_1_USBIO_CTRL_PTR      ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_USBIO_CTRL)

    #define USBUART_1_FLOW_CTRL_REG       (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_FLOW_CTRL)
    #define USBUART_1_FLOW_CTRL_PTR       ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_FLOW_CTRL)

    #define USBUART_1_LPM_CTRL_REG        (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_LPM_CTRL)
    #define USBUART_1_LPM_CTRL_PTR        ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_LPM_CTRL)

    #define USBUART_1_LPM_STAT_REG        (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_LPM_STAT)
    #define USBUART_1_LPM_STAT_PTR        ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_LPM_STAT)

    #define USBUART_1_PHY_CONTROL_REG     (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_PHY_CONTROL)
    #define USBUART_1_PHY_CONTROL_PTR     ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_PHY_CONTROL)

    #define USBUART_1_INTR_SIE_REG        (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE)
    #define USBUART_1_INTR_SIE_PTR        ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE)

    #define USBUART_1_INTR_SIE_SET_REG    (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_SET)
    #define USBUART_1_INTR_SIE_SET_PTR    ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_SET)

    #define USBUART_1_INTR_SIE_MASK_REG   (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_MASK)
    #define USBUART_1_INTR_SIE_MASK_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_MASK)

    #define USBUART_1_INTR_SIE_MASKED_REG (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_MASKED)
    #define USBUART_1_INTR_SIE_MASKED_PTR ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_SIE_MASKED)

    #define USBUART_1_INTR_LVL_SEL_REG    (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_LVL_SEL)
    #define USBUART_1_INTR_LVL_SEL_PTR    ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_LVL_SEL)

    #define USBUART_1_INTR_CAUSE_HI_REG   (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_HI)
    #define USBUART_1_INTR_CAUSE_HI_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_HI)

    #define USBUART_1_INTR_CAUSE_LO_REG   (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_LO)
    #define USBUART_1_INTR_CAUSE_LO_PTR   ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_LO)

    #define USBUART_1_INTR_CAUSE_MED_REG  (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_MED)
    #define USBUART_1_INTR_CAUSE_MED_PTR  ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_INTR_CAUSE_MED)

    #define USBUART_1_DFT_CTRL_REG        (*(reg32 *) USBUART_1_cy_m0s8_usb__USB_DFT_CTRL)
    #define USBUART_1_DFT_CTRL_PTR        ( (reg32 *) USBUART_1_cy_m0s8_usb__USB_DFT_CTRL)

    #if (USBUART_1_VBUS_MONITORING_ENABLE)
        #if (USBUART_1_VBUS_POWER_PAD_ENABLE)
            /* Vbus power pad pin is hard wired to P13[2] */
            #define USBUART_1_VBUS_STATUS_REG    (*(reg32 *) CYREG_GPIO_PRT13_PS)
            #define USBUART_1_VBUS_STATUS_PTR    ( (reg32 *) CYREG_GPIO_PRT13_PS)
            #define USBUART_1_VBUS_VALID         (0x04u)
        #else
            /* Vbus valid pin is hard wired to P0[0] */
            #define USBUART_1_VBUS_STATUS_REG    (*(reg32 *) CYREG_GPIO_PRT0_PS)
            #define USBUART_1_VBUS_STATUS_PTR    ( (reg32 *) CYREG_GPIO_PRT0_PS)
            #define USBUART_1_VBUS_VALID         (0x01u)
        #endif
    #endif /*(USBUART_1_VBUS_MONITORING_ENABLE) */

    #define USBUART_1_BURSTEND_0_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND0_TR_OUTPUT)
    #define USBUART_1_BURSTEND_1_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND1_TR_OUTPUT)
    #define USBUART_1_BURSTEND_2_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND2_TR_OUTPUT)
    #define USBUART_1_BURSTEND_3_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND3_TR_OUTPUT)
    #define USBUART_1_BURSTEND_4_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND4_TR_OUTPUT)
    #define USBUART_1_BURSTEND_5_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND5_TR_OUTPUT)
    #define USBUART_1_BURSTEND_6_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND6_TR_OUTPUT)
    #define USBUART_1_BURSTEND_7_TR_OUTPUT    (USBUART_1_cy_m0s8_usb__BURSTEND7_TR_OUTPUT)
    
#else /* (CY_PSOC3 || CY_PSOC5LP) */

    /* USBUART_1_PM_USB_CR0 */
    #define USBUART_1_PM_USB_CR0_PTR     ( (reg8 *) CYREG_PM_USB_CR0)
    #define USBUART_1_PM_USB_CR0_REG     (*(reg8 *) CYREG_PM_USB_CR0)

    /* USBUART_1_PM_ACT/STBY_CFG */
    #define USBUART_1_PM_ACT_CFG_PTR     ( (reg8 *) USBUART_1_USB__PM_ACT_CFG)
    #define USBUART_1_PM_ACT_CFG_REG     (*(reg8 *) USBUART_1_USB__PM_ACT_CFG)
    #define USBUART_1_PM_STBY_CFG_PTR    ( (reg8 *) USBUART_1_USB__PM_STBY_CFG)
    #define USBUART_1_PM_STBY_CFG_REG    (*(reg8 *) USBUART_1_USB__PM_STBY_CFG)

    #if (!CY_PSOC5LP)
        #define USBUART_1_USBIO_CR2_PTR  (  (reg8 *) USBUART_1_USB__USBIO_CR2)
        #define USBUART_1_USBIO_CR2_REG  (* (reg8 *) USBUART_1_USB__USBIO_CR2)
    #endif /* (!CY_PSOC5LP) */

    /* USBUART_1_USB_MEM - USB IP memory buffer */
    #define USBUART_1_USB_MEM            ((reg8 *) CYDEV_USB_MEM_BASE)

    #if (USBUART_1_VBUS_MONITORING_ENABLE)
        #if (USBUART_1_VBUS_MONITORING_INTERNAL)
            #define USBUART_1_VBUS_STATUS_REG    (*(reg8 *) USBUART_1_VBUS__PS)
            #define USBUART_1_VBUS_STATUS_PTR    ( (reg8 *) USBUART_1_VBUS__PS)
            #define USBUART_1_VBUS_VALID         (USBUART_1_VBUS__MASK)
        #else
            #define USBUART_1_VBUS_STATUS_REG    (*(reg8 *) USBUART_1_Vbus_ps_sts_sts_reg__STATUS_REG)
            #define USBUART_1_VBUS_STATUS_PTR    ( (reg8 *) USBUART_1_Vbus_ps_sts_sts_reg__STATUS_REG)
            #define USBUART_1_VBUS_VALID         (USBUART_1_Vbus_ps_sts_sts_reg__MASK)
        #endif /* (USBUART_1_VBUS_MONITORING_INTERNAL) */
    #endif /*(USBUART_1_VBUS_MONITORING_ENABLE) */
#endif /* (CY_PSOC4) */


/***************************************
*       Interrupt source constants
***************************************/

#define USBUART_1_DP_INTC_PRIORITY       USBUART_1_dp_int__INTC_PRIOR_NUM
#define USBUART_1_DP_INTC_VECT_NUM       USBUART_1_dp_int__INTC_NUMBER

#if (CY_PSOC4)
    #define USBUART_1_DMA_AUTO_INTR_PRIO (0u)
    
    #define USBUART_1_INTR_HI_PRIORITY   USBUART_1_high_int__INTC_PRIOR_NUM
    #define USBUART_1_INTR_HI_VECT_NUM   USBUART_1_high_int__INTC_NUMBER

    #define USBUART_1_INTR_MED_PRIORITY  USBUART_1_med_int__INTC_PRIOR_NUM
    #define USBUART_1_INTR_MED_VECT_NUM  USBUART_1_med_int__INTC_NUMBER

    #define USBUART_1_INTR_LO_PRIORITY   USBUART_1_lo_int__INTC_PRIOR_NUM
    #define USBUART_1_INTR_LO_VECT_NUM   USBUART_1_lo_int__INTC_NUMBER

    /* Interrupt sources in USBUART_1_isrCallbacks[] table */
    #define USBUART_1_SOF_INTR_NUM       (0u)
    #define USBUART_1_BUS_RESET_INT_NUM  (1u)
    #define USBUART_1_EP0_INTR_NUM       (2u)
    #define USBUART_1_LPM_INTR_NUM       (3u)
    #define USBUART_1_ARB_EP_INTR_NUM    (4u)
    #define USBUART_1_EP1_INTR_NUM       (5u)
    #define USBUART_1_EP2_INTR_NUM       (6u)
    #define USBUART_1_EP3_INTR_NUM       (7u)
    #define USBUART_1_EP4_INTR_NUM       (8u)
    #define USBUART_1_EP5_INTR_NUM       (9u)
    #define USBUART_1_EP6_INTR_NUM       (10u)
    #define USBUART_1_EP7_INTR_NUM       (11u)
    #define USBUART_1_EP8_INTR_NUM       (12u)

#else
    #define USBUART_1_BUS_RESET_PRIOR    USBUART_1_bus_reset__INTC_PRIOR_NUM
    #define USBUART_1_BUS_RESET_MASK     USBUART_1_bus_reset__INTC_MASK
    #define USBUART_1_BUS_RESET_VECT_NUM USBUART_1_bus_reset__INTC_NUMBER

    #define USBUART_1_SOF_PRIOR          USBUART_1_sof_int__INTC_PRIOR_NUM
    #define USBUART_1_SOF_MASK           USBUART_1_sof_int__INTC_MASK
    #define USBUART_1_SOF_VECT_NUM       USBUART_1_sof_int__INTC_NUMBER

    #define USBUART_1_EP_0_PRIOR         USBUART_1_ep_0__INTC_PRIOR_NUM
    #define USBUART_1_EP_0_MASK          USBUART_1_ep_0__INTC_MASK
    #define USBUART_1_EP_0_VECT_NUM      USBUART_1_ep_0__INTC_NUMBER

    #define USBUART_1_EP_1_PRIOR         USBUART_1_ep_1__INTC_PRIOR_NUM
    #define USBUART_1_EP_1_MASK          USBUART_1_ep_1__INTC_MASK
    #define USBUART_1_EP_1_VECT_NUM      USBUART_1_ep_1__INTC_NUMBER

    #define USBUART_1_EP_2_PRIOR         USBUART_1_ep_2__INTC_PRIOR_NUM
    #define USBUART_1_EP_2_MASK          USBUART_1_ep_2__INTC_MASK
    #define USBUART_1_EP_2_VECT_NUM      USBUART_1_ep_2__INTC_NUMBER

    #define USBUART_1_EP_3_PRIOR         USBUART_1_ep_3__INTC_PRIOR_NUM
    #define USBUART_1_EP_3_MASK          USBUART_1_ep_3__INTC_MASK
    #define USBUART_1_EP_3_VECT_NUM      USBUART_1_ep_3__INTC_NUMBER

    #define USBUART_1_EP_4_PRIOR         USBUART_1_ep_4__INTC_PRIOR_NUM
    #define USBUART_1_EP_4_MASK          USBUART_1_ep_4__INTC_MASK
    #define USBUART_1_EP_4_VECT_NUM      USBUART_1_ep_4__INTC_NUMBER

    #define USBUART_1_EP_5_PRIOR         USBUART_1_ep_5__INTC_PRIOR_NUM
    #define USBUART_1_EP_5_MASK          USBUART_1_ep_5__INTC_MASK
    #define USBUART_1_EP_5_VECT_NUM      USBUART_1_ep_5__INTC_NUMBER

    #define USBUART_1_EP_6_PRIOR         USBUART_1_ep_6__INTC_PRIOR_NUM
    #define USBUART_1_EP_6_MASK          USBUART_1_ep_6__INTC_MASK
    #define USBUART_1_EP_6_VECT_NUM      USBUART_1_ep_6__INTC_NUMBER

    #define USBUART_1_EP_7_PRIOR         USBUART_1_ep_7__INTC_PRIOR_NUM
    #define USBUART_1_EP_7_MASK          USBUART_1_ep_7__INTC_MASK
    #define USBUART_1_EP_7_VECT_NUM      USBUART_1_ep_7__INTC_NUMBER

    #define USBUART_1_EP_8_PRIOR         USBUART_1_ep_8__INTC_PRIOR_NUM
    #define USBUART_1_EP_8_MASK          USBUART_1_ep_8__INTC_MASK
    #define USBUART_1_EP_8_VECT_NUM      USBUART_1_ep_8__INTC_NUMBER

    /* Set ARB ISR priority 0 to be highest for all EPX ISRs. */
    #define USBUART_1_ARB_PRIOR          (0u)
    #define USBUART_1_ARB_MASK           USBUART_1_arb_int__INTC_MASK
    #define USBUART_1_ARB_VECT_NUM       USBUART_1_arb_int__INTC_NUMBER
#endif /* (CY_PSOC4) */


/***************************************
*       Endpoint 0 offsets (Table 9-2)
***************************************/
#define USBUART_1_bmRequestTypeReg      USBUART_1_EP0_DR_BASE.epData[0u]
#define USBUART_1_bRequestReg           USBUART_1_EP0_DR_BASE.epData[1u]
#define USBUART_1_wValueLoReg           USBUART_1_EP0_DR_BASE.epData[2u]
#define USBUART_1_wValueHiReg           USBUART_1_EP0_DR_BASE.epData[3u]
#define USBUART_1_wIndexLoReg           USBUART_1_EP0_DR_BASE.epData[4u]
#define USBUART_1_wIndexHiReg           USBUART_1_EP0_DR_BASE.epData[5u]
#define USBUART_1_wLengthLoReg          USBUART_1_EP0_DR_BASE.epData[6u]
#define USBUART_1_wLengthHiReg          USBUART_1_EP0_DR_BASE.epData[7u]

/* Compatibility defines */
#define USBUART_1_lengthLoReg           USBUART_1_EP0_DR_BASE.epData[6u]
#define USBUART_1_lengthHiReg           USBUART_1_EP0_DR_BASE.epData[7u]


/***************************************
*       Register Constants
***************************************/

#define USBUART_1_3500MV     (3500u)
#if (CY_PSOC4)
    #define USBUART_1_VDDD_MV    (CYDEV_VBUS_MV)
#else
    #define USBUART_1_VDDD_MV    (CYDEV_VDDD_MV)
#endif /* (CY_PSOC4) */


/* USBUART_1_USB_CLK */
#define USBUART_1_USB_CLK_CSR_CLK_EN_POS (0u)
#define USBUART_1_USB_CLK_CSR_CLK_EN     ((uint8) ((uint8) 0x1u << USBUART_1_USB_CLK_CSR_CLK_EN_POS))
#define USBUART_1_USB_CLK_ENABLE         (USBUART_1_USB_CLK_CSR_CLK_EN)

/* USBUART_1_CR0 */
#define USBUART_1_CR0_DEVICE_ADDRESS_POS     (0u)
#define USBUART_1_CR0_ENABLE_POS             (7u)
#define USBUART_1_CR0_DEVICE_ADDRESS_MASK    ((uint8) ((uint8) 0x7Fu << USBUART_1_CR0_DEVICE_ADDRESS_POS))
#define USBUART_1_CR0_ENABLE                 ((uint8) ((uint8) 0x01u << USBUART_1_CR0_ENABLE_POS))


/* USBUART_1_CR1 */
#define USBUART_1_CR1_REG_ENABLE_POS         (0u)
#define USBUART_1_CR1_ENABLE_LOCK_POS        (1u)
#define USBUART_1_CR1_BUS_ACTIVITY_POS       (2u)
#define USBUART_1_CR1_TRIM_OFFSET_MSB_POS    (3u)
#define USBUART_1_CR1_REG_ENABLE             ((uint8) ((uint8) 0x1u << USBUART_1_CR1_REG_ENABLE_POS))
#define USBUART_1_CR1_ENABLE_LOCK            ((uint8) ((uint8) 0x1u << USBUART_1_CR1_ENABLE_LOCK_POS))
#define USBUART_1_CR1_BUS_ACTIVITY           ((uint8) ((uint8) 0x1u << USBUART_1_CR1_BUS_ACTIVITY_POS))
#define USBUART_1_CR1_TRIM_OFFSET_MSB        ((uint8) ((uint8) 0x1u << USBUART_1_CR1_TRIM_OFFSET_MSB_POS))

/* USBUART_1_EPX_CNT */
#define USBUART_1_EP0_CNT_DATA_TOGGLE        (0x80u)
#define USBUART_1_EPX_CNT_DATA_TOGGLE        (0x80u)
#define USBUART_1_EPX_CNT0_MASK              (0x0Fu)
#define USBUART_1_EPX_CNTX_MSB_MASK          (0x07u)
#define USBUART_1_EPX_CNTX_ADDR_SHIFT        (0x04u)
#define USBUART_1_EPX_CNTX_ADDR_OFFSET       (0x10u)
#define USBUART_1_EPX_CNTX_CRC_COUNT         (0x02u)
#define USBUART_1_EPX_DATA_BUF_MAX           (512u)

/* USBUART_1_USBIO_CR0 */

#define USBUART_1_USBIO_CR0_TEN              (0x80u)
#define USBUART_1_USBIO_CR0_TSE0             (0x40u)
#define USBUART_1_USBIO_CR0_TD               (0x20u)
#define USBUART_1_USBIO_CR0_RD               (0x01u)

/* USBUART_1_USBIO_CR1 */
#define USBUART_1_USBIO_CR1_DM0_POS      (0u)
#define USBUART_1_USBIO_CR1_DP0_POS      (1u)
#define USBUART_1_USBIO_CR1_USBPUEN_POS  (2u)
#define USBUART_1_USBIO_CR1_IOMODE_POS   (5u)
#define USBUART_1_USBIO_CR1_DM0          ((uint8) ((uint8) 0x1u << USBUART_1_USBIO_CR1_DM0_POS))
#define USBUART_1_USBIO_CR1_DP0          ((uint8) ((uint8) 0x1u << USBUART_1_USBIO_CR1_DP0_POS))
#define USBUART_1_USBIO_CR1_USBPUEN      ((uint8) ((uint8) 0x1u << USBUART_1_USBIO_CR1_USBPUEN_POS))
#define USBUART_1_USBIO_CR1_IOMODE       ((uint8) ((uint8) 0x1u << USBUART_1_USBIO_CR1_IOMODE_POS))

/* USBUART_1_FASTCLK_IMO_CR */
#define USBUART_1_FASTCLK_IMO_CR_USBCLK_ON   (0x40u)
#define USBUART_1_FASTCLK_IMO_CR_XCLKEN      (0x20u)
#define USBUART_1_FASTCLK_IMO_CR_FX2ON       (0x10u)

/* USBUART_1_ARB_EPX_CFG */
#define USBUART_1_ARB_EPX_CFG_IN_DATA_RDY_POS    (0u)
#define USBUART_1_ARB_EPX_CFG_DMA_REQ_POS        (1u)
#define USBUART_1_ARB_EPX_CFG_CRC_BYPASS_POS     (2u)
#define USBUART_1_ARB_EPX_CFG_RESET_POS          (3u)
#define USBUART_1_ARB_EPX_CFG_IN_DATA_RDY        ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_CFG_IN_DATA_RDY_POS))
#define USBUART_1_ARB_EPX_CFG_DMA_REQ            ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_CFG_DMA_REQ_POS))
#define USBUART_1_ARB_EPX_CFG_CRC_BYPASS         ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_CFG_CRC_BYPASS_POS))
#define USBUART_1_ARB_EPX_CFG_RESET              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_CFG_RESET_POS))

/* USBUART_1_ARB_EPX_INT / SR */
#define USBUART_1_ARB_EPX_INT_IN_BUF_FULL_POS    (0u)
#define USBUART_1_ARB_EPX_INT_DMA_GNT_POS        (1u)
#define USBUART_1_ARB_EPX_INT_BUF_OVER_POS       (2u)
#define USBUART_1_ARB_EPX_INT_BUF_UNDER_POS      (3u)
#define USBUART_1_ARB_EPX_INT_ERR_INT_POS        (4u)
#define USBUART_1_ARB_EPX_INT_IN_BUF_FULL        ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_IN_BUF_FULL_POS))
#define USBUART_1_ARB_EPX_INT_DMA_GNT            ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_DMA_GNT_POS))
#define USBUART_1_ARB_EPX_INT_BUF_OVER           ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_BUF_OVER_POS))
#define USBUART_1_ARB_EPX_INT_BUF_UNDER          ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_BUF_UNDER_POS))
#define USBUART_1_ARB_EPX_INT_ERR_INT            ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_ERR_INT_POS))

#if (CY_PSOC4)
#define USBUART_1_ARB_EPX_INT_DMA_TERMIN_POS     (5u)
#define USBUART_1_ARB_EPX_INT_DMA_TERMIN         ((uint8) ((uint8) 0x1u << USBUART_1_ARB_EPX_INT_DMA_TERMIN_POS))
#endif /* (CY_PSOC4) */

/* Common arbiter interrupt sources for all PSoC devices. */
#define USBUART_1_ARB_EPX_INT_COMMON    (USBUART_1_ARB_EPX_INT_IN_BUF_FULL | \
                                                USBUART_1_ARB_EPX_INT_DMA_GNT     | \
                                                USBUART_1_ARB_EPX_INT_BUF_OVER    | \
                                                USBUART_1_ARB_EPX_INT_BUF_UNDER   | \
                                                USBUART_1_ARB_EPX_INT_ERR_INT)

#if (CY_PSOC4)
    #define USBUART_1_ARB_EPX_INT_ALL    (USBUART_1_ARB_EPX_INT_COMMON | USBUART_1_ARB_EPX_INT_DMA_TERMIN)
#else
    #define USBUART_1_ARB_EPX_INT_ALL    (USBUART_1_ARB_EPX_INT_COMMON)
#endif /* (CY_PSOC4) */

/* USBUART_1_ARB_CFG */
#define USBUART_1_ARB_CFG_AUTO_MEM_POS   (4u)
#define USBUART_1_ARB_CFG_DMA_CFG_POS    (5u)
#define USBUART_1_ARB_CFG_CFG_CMP_POS    (7u)
#define USBUART_1_ARB_CFG_AUTO_MEM       ((uint8) ((uint8) 0x1u << USBUART_1_ARB_CFG_AUTO_MEM_POS))
#define USBUART_1_ARB_CFG_DMA_CFG_MASK   ((uint8) ((uint8) 0x3u << USBUART_1_ARB_CFG_DMA_CFG_POS))
#define USBUART_1_ARB_CFG_DMA_CFG_NONE   ((uint8) ((uint8) 0x0u << USBUART_1_ARB_CFG_DMA_CFG_POS))
#define USBUART_1_ARB_CFG_DMA_CFG_MANUAL ((uint8) ((uint8) 0x1u << USBUART_1_ARB_CFG_DMA_CFG_POS))
#define USBUART_1_ARB_CFG_DMA_CFG_AUTO   ((uint8) ((uint8) 0x2u << USBUART_1_ARB_CFG_DMA_CFG_POS))
#define USBUART_1_ARB_CFG_CFG_CMP        ((uint8) ((uint8) 0x1u << USBUART_1_ARB_CFG_CFG_CMP_POS))

/* USBUART_1_DYN_RECONFIG */
#define USBUART_1_DYN_RECONFIG_EP_SHIFT      (1u)
#define USBUART_1_DYN_RECONFIG_ENABLE_POS    (0u)
#define USBUART_1_DYN_RECONFIG_EPNO_POS      (1u)
#define USBUART_1_DYN_RECONFIG_RDY_STS_POS   (4u)
#define USBUART_1_DYN_RECONFIG_ENABLE        ((uint8) ((uint8) 0x1u << USBUART_1_DYN_RECONFIG_ENABLE_POS))
#define USBUART_1_DYN_RECONFIG_EPNO_MASK     ((uint8) ((uint8) 0x7u << USBUART_1_DYN_RECONFIG_EPNO_POS))
#define USBUART_1_DYN_RECONFIG_RDY_STS       ((uint8) ((uint8) 0x1u << USBUART_1_DYN_RECONFIG_RDY_STS_POS))

/* USBUART_1_ARB_INT */
#define USBUART_1_ARB_INT_EP1_INTR_POS          (0u) /* [0] Interrupt for USB EP1 */
#define USBUART_1_ARB_INT_EP2_INTR_POS          (1u) /* [1] Interrupt for USB EP2 */
#define USBUART_1_ARB_INT_EP3_INTR_POS          (2u) /* [2] Interrupt for USB EP3 */
#define USBUART_1_ARB_INT_EP4_INTR_POS          (3u) /* [3] Interrupt for USB EP4 */
#define USBUART_1_ARB_INT_EP5_INTR_POS          (4u) /* [4] Interrupt for USB EP5 */
#define USBUART_1_ARB_INT_EP6_INTR_POS          (5u) /* [5] Interrupt for USB EP6 */
#define USBUART_1_ARB_INT_EP7_INTR_POS          (6u) /* [6] Interrupt for USB EP7 */
#define USBUART_1_ARB_INT_EP8_INTR_POS          (7u) /* [7] Interrupt for USB EP8 */
#define USBUART_1_ARB_INT_EP1_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP1_INTR_POS))
#define USBUART_1_ARB_INT_EP2_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP2_INTR_POS))
#define USBUART_1_ARB_INT_EP3_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP3_INTR_POS))
#define USBUART_1_ARB_INT_EP4_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP4_INTR_POS))
#define USBUART_1_ARB_INT_EP5_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP5_INTR_POS))
#define USBUART_1_ARB_INT_EP6_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP6_INTR_POS))
#define USBUART_1_ARB_INT_EP7_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP7_INTR_POS))
#define USBUART_1_ARB_INT_EP8_INTR              ((uint8) ((uint8) 0x1u << USBUART_1_ARB_INT_EP8_INTR_POS))

/* USBUART_1_SIE_INT */
#define USBUART_1_SIE_INT_EP1_INTR_POS          (0u) /* [0] Interrupt for USB EP1 */
#define USBUART_1_SIE_INT_EP2_INTR_POS          (1u) /* [1] Interrupt for USB EP2 */
#define USBUART_1_SIE_INT_EP3_INTR_POS          (2u) /* [2] Interrupt for USB EP3 */
#define USBUART_1_SIE_INT_EP4_INTR_POS          (3u) /* [3] Interrupt for USB EP4 */
#define USBUART_1_SIE_INT_EP5_INTR_POS          (4u) /* [4] Interrupt for USB EP5 */
#define USBUART_1_SIE_INT_EP6_INTR_POS          (5u) /* [5] Interrupt for USB EP6 */
#define USBUART_1_SIE_INT_EP7_INTR_POS          (6u) /* [6] Interrupt for USB EP7 */
#define USBUART_1_SIE_INT_EP8_INTR_POS          (7u) /* [7] Interrupt for USB EP8 */
#define USBUART_1_SIE_INT_EP1_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP1_INTR_POS))
#define USBUART_1_SIE_INT_EP2_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP2_INTR_POS))
#define USBUART_1_SIE_INT_EP3_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP3_INTR_POS))
#define USBUART_1_SIE_INT_EP4_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP4_INTR_POS))
#define USBUART_1_SIE_INT_EP5_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP5_INTR_POS))
#define USBUART_1_SIE_INT_EP6_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP6_INTR_POS))
#define USBUART_1_SIE_INT_EP7_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP7_INTR_POS))
#define USBUART_1_SIE_INT_EP8_INTR              ((uint8) ((uint8) 0x01u << USBUART_1_SIE_INT_EP8_INTR_POS))

#if (CY_PSOC4)
    /* USBUART_1_POWER_CTRL_REG */
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS       (0u)  /* [0] */
    #define USBUART_1_POWER_CTRL_SUSPEND_POS              (2u)  /* [1] */
    #define USBUART_1_POWER_CTRL_SUSPEND_DEL_POS          (3u)  /* [3] */
    #define USBUART_1_POWER_CTRL_ISOLATE_POS              (4u)  /* [4] */
    #define USBUART_1_POWER_CTRL_CHDET_PWR_CTL_POS        (5u)  /* [5] */
    #define USBUART_1_POWER_CTRL_ENABLE_DM_PULLDOWN_POS   (25u) /* [25] */
    #define USBUART_1_POWER_CTRL_ENABLE_VBUS_PULLDOWN_POS (26u) /* [26] */
    #define USBUART_1_POWER_CTRL_ENABLE_RCVR_POS          (27u) /* [27] */
    #define USBUART_1_POWER_CTRL_ENABLE_DPO_POS           (28u) /* [28] */
    #define USBUART_1_POWER_CTRL_ENABLE_DMO_POS           (29u) /* [29] */
    #define USBUART_1_POWER_CTRL_ENABLE_CHGDET_POS        (30u) /* [30] */
    #define USBUART_1_POWER_CTRL_ENABLE_POS               (31u) /* [31] */
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_MASK      ((uint32) 0x03u << USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS)
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_0         ((uint32) 0x00u << USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS)
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_1         ((uint32) 0x01u << USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS)
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_GPIO      ((uint32) 0x02u << USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS)
    #define USBUART_1_POWER_CTRL_VBUS_VALID_OVR_PHY       ((uint32) 0x03u << USBUART_1_POWER_CTRL_VBUS_VALID_OVR_POS)
    #define USBUART_1_POWER_CTRL_SUSPEND                  ((uint32) 0x01u << USBUART_1_POWER_CTRL_SUSPEND_POS)
    #define USBUART_1_POWER_CTRL_SUSPEND_DEL              ((uint32) 0x01u << USBUART_1_POWER_CTRL_SUSPEND_DEL_POS)
    #define USBUART_1_POWER_CTRL_ISOLATE                  ((uint32) 0x01u << USBUART_1_POWER_CTRL_ISOLATE_POS)
    #define USBUART_1_POWER_CTRL_CHDET_PWR_CTL_MASK       ((uint32) 0x03u << USBUART_1_POWER_CTRL_CHDET_PWR_CTL_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_DM_PULLDOWN       ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_DM_PULLDOWN_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_VBUS_PULLDOWN     ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_VBUS_PULLDOWN_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_RCVR              ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_RCVR_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_DPO               ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_DPO_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_DMO               ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_DMO_POS)
    #define USBUART_1_POWER_CTRL_ENABLE_CHGDET            ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_CHGDET_POS)
    #define USBUART_1_POWER_CTRL_ENABLE                   ((uint32) 0x01u << USBUART_1_POWER_CTRL_ENABLE_POS)

    /* USBUART_1_CHGDET_CTRL_REG */
    #define USBUART_1_CHGDET_CTRL_COMP_DP_POS        (0u)  /* [0] */
    #define USBUART_1_CHGDET_CTRL_COMP_DM_POS        (1u)  /* [1] */
    #define USBUART_1_CHGDET_CTRL_COMP_EN_POS        (2u)  /* [2] */
    #define USBUART_1_CHGDET_CTRL_REF_DP_POS         (3u)  /* [3] */
    #define USBUART_1_CHGDET_CTRL_REF_DM_POS         (4u)  /* [4] */
    #define USBUART_1_CHGDET_CTRL_REF_EN_POS         (5u)  /* [5] */
    #define USBUART_1_CHGDET_CTRL_DCD_SRC_EN_POS     (6u)  /* [6] */
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS      (12u) /* [12] */
    #define USBUART_1_CHGDET_CTRL_COMP_OUT_POS       (31u) /* [31] */
    #define USBUART_1_CHGDET_CTRL_COMP_DP            ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_COMP_DP_POS)
    #define USBUART_1_CHGDET_CTRL_COMP_DM            ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_COMP_DM_POS)
    #define USBUART_1_CHGDET_CTRL_COMP_EN            ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_COMP_EN_POS)
    #define USBUART_1_CHGDET_CTRL_REF_DP             ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_REF_DP_POS)
    #define USBUART_1_CHGDET_CTRL_REF_DM             ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_REF_DM_POS)
    #define USBUART_1_CHGDET_CTRL_REF_EN             ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_REF_EN_POS)
    #define USBUART_1_CHGDET_CTRL_DCD_SRC_EN         ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_DCD_SRC_EN_POS)
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_MASK     ((uint32) 0x03u << USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS)
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_NORMAL   ((uint32) 0x00u << USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS)
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_VBG      ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS)
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_DONTUSE  ((uint32) 0x02u << USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS)
    #define USBUART_1_CHGDET_CTRL_ADFT_CTRL_ADFTIN   ((uint32) 0x03u << USBUART_1_CHGDET_CTRL_ADFT_CTRL_POS)
    #define USBUART_1_CHGDET_CTRL_COMP_OUT           ((uint32) 0x01u << USBUART_1_CHGDET_CTRL_COMP_OUT_POS)

    /* USBUART_1_LPM_CTRL */
    #define USBUART_1_LPM_CTRL_LPM_EN_POS        (0u)
    #define USBUART_1_LPM_CTRL_LPM_ACK_RESP_POS  (1u)
    #define USBUART_1_LPM_CTRL_NYET_EN_POS       (2u)
    #define USBUART_1_LPM_CTRL_SUB_RESP_POS      (4u)
    #define USBUART_1_LPM_CTRL_LPM_EN            ((uint32) 0x01u << USBUART_1_LPM_CTRL_LPM_EN_POS)
    #define USBUART_1_LPM_CTRL_LPM_ACK_RESP      ((uint32) 0x01u << USBUART_1_LPM_CTRL_LPM_ACK_RESP_POS)
    #define USBUART_1_LPM_CTRL_NYET_EN           ((uint32) 0x01u << USBUART_1_LPM_CTRL_NYET_EN_POS)
    #define USBUART_1_LPM_CTRL_ACK_NYET_MASK     ((uint32) 0x03u << USBUART_1_LPM_CTRL_LPM_ACK_RESP_POS)
    #define USBUART_1_LPM_CTRL_SUB_RESP          ((uint32) 0x01u << USBUART_1_LPM_CTRL_SUB_RESP_POS)

    #define USBUART_1_LPM_STAT_LPM_BESL_POS          (0u)
    #define USBUART_1_LPM_STAT_LPM_REMOTE_WAKE_POS   (4u)
    #define USBUART_1_LPM_STAT_LPM_BESL_MASK         ((uint32) 0x0Fu << USBUART_1_LPM_STAT_LPM_BESL_POS)
    #define USBUART_1_LPM_STAT_LPM_REMOTE_WAKE       ((uint32) 0x01u << USBUART_1_LPM_STAT_LPM_REMOTE_WAKE_POS)

    /* USBUART_1_INTR_SIE */
    #define USBUART_1_INTR_SIE_SOF_INTR_POS          (0u) /* [0] Interrupt for USB SOF   */
    #define USBUART_1_INTR_SIE_BUS_RESET_INTR_POS    (1u) /* [1] Interrupt for BUS RESET */
    #define USBUART_1_INTR_SIE_EP0_INTR_POS          (2u) /* [2] Interrupt for EP0       */
    #define USBUART_1_INTR_SIE_LPM_INTR_POS          (3u) /* [3] Interrupt for LPM       */
    #define USBUART_1_INTR_SIE_RESUME_INTR_POS       (4u) /* [4] Interrupt for RESUME (not used by component) */
    #define USBUART_1_INTR_SIE_SOF_INTR              ((uint32) 0x01u << USBUART_1_INTR_SIE_SOF_INTR_POS)
    #define USBUART_1_INTR_SIE_BUS_RESET_INTR        ((uint32) 0x01u << USBUART_1_INTR_SIE_BUS_RESET_INTR_POS)
    #define USBUART_1_INTR_SIE_EP0_INTR              ((uint32) 0x01u << USBUART_1_INTR_SIE_EP0_INTR_POS)
    #define USBUART_1_INTR_SIE_LPM_INTR              ((uint32) 0x01u << USBUART_1_INTR_SIE_LPM_INTR_POS)
    #define USBUART_1_INTR_SIE_RESUME_INTR           ((uint32) 0x01u << USBUART_1_INTR_SIE_RESUME_INTR_POS)

    /* USBUART_1_INTR_CAUSE_LO, MED and HI */
    #define USBUART_1_INTR_CAUSE_SOF_INTR_POS       (0u)  /* [0] Interrupt status for USB SOF    */
    #define USBUART_1_INTR_CAUSE_BUS_RESET_INTR_POS (1u)  /* [1] Interrupt status for USB BUS RSET */
    #define USBUART_1_INTR_CAUSE_EP0_INTR_POS       (2u)  /* [2] Interrupt status for USB EP0    */
    #define USBUART_1_INTR_CAUSE_LPM_INTR_POS       (3u)  /* [3] Interrupt status for USB LPM    */
    #define USBUART_1_INTR_CAUSE_RESUME_INTR_POS    (4u)  /* [4] Interrupt status for USB RESUME */
    #define USBUART_1_INTR_CAUSE_ARB_INTR_POS       (7u)  /* [7] Interrupt status for USB ARB    */
    #define USBUART_1_INTR_CAUSE_EP1_INTR_POS       (8u)  /* [8] Interrupt status for USB EP1    */
    #define USBUART_1_INTR_CAUSE_EP2_INTR_POS       (9u)  /* [9] Interrupt status for USB EP2    */
    #define USBUART_1_INTR_CAUSE_EP3_INTR_POS       (10u) /* [10] Interrupt status for USB EP3   */
    #define USBUART_1_INTR_CAUSE_EP4_INTR_POS       (11u) /* [11] Interrupt status for USB EP4   */
    #define USBUART_1_INTR_CAUSE_EP5_INTR_POS       (12u) /* [12] Interrupt status for USB EP5   */
    #define USBUART_1_INTR_CAUSE_EP6_INTR_POS       (13u) /* [13] Interrupt status for USB EP6   */
    #define USBUART_1_INTR_CAUSE_EP7_INTR_POS       (14u) /* [14] Interrupt status for USB EP7   */
    #define USBUART_1_INTR_CAUSE_EP8_INTR_POS       (15u) /* [15] Interrupt status for USB EP8   */
    #define USBUART_1_INTR_CAUSE_SOF_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_SOF_INTR_POS)
    #define USBUART_1_INTR_CAUSE_BUS_RESET_INTR     ((uint32) 0x01u << USBUART_1_INTR_CAUSE_BUS_RESET_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP0_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP0_INTR_POS)
    #define USBUART_1_INTR_CAUSE_LPM_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_LPM_INTR_POS)
    #define USBUART_1_INTR_CAUSE_RESUME_INTR        ((uint32) 0x01u << USBUART_1_INTR_CAUSE_RESUME_INTR_POS)
    #define USBUART_1_INTR_CAUSE_ARB_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_ARB_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP1_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP1_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP2_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP2_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP3_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP3_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP4_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP4_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP5_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP5_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP6_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP6_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP7_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP7_INTR_POS)
    #define USBUART_1_INTR_CAUSE_EP8_INTR           ((uint32) 0x01u << USBUART_1_INTR_CAUSE_EP8_INTR_POS)

    #define USBUART_1_INTR_CAUSE_CTRL_INTR_MASK     (USBUART_1_INTR_CAUSE_SOF_INTR       | \
                                                            USBUART_1_INTR_CAUSE_BUS_RESET_INTR | \
                                                            USBUART_1_INTR_CAUSE_EP0_INTR       | \
                                                            USBUART_1_INTR_CAUSE_LPM_INTR)

    #define USBUART_1_INTR_CAUSE_EP1_8_INTR_MASK    (USBUART_1_INTR_CAUSE_EP1_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP2_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP3_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP4_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP5_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP6_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP7_INTR       | \
                                                            USBUART_1_INTR_CAUSE_EP8_INTR)

    #define USBUART_1_INTR_CAUSE_EP_INTR_SHIFT      (USBUART_1_INTR_CAUSE_ARB_INTR_POS - \
                                                           (USBUART_1_INTR_CAUSE_LPM_INTR_POS + 1u))
    #define USBUART_1_INTR_CAUSE_SRC_COUNT          (13u)

    #define USBUART_1_CHGDET_CTRL_PRIMARY    (USBUART_1_CHGDET_CTRL_COMP_EN | \
                                                     USBUART_1_CHGDET_CTRL_COMP_DM | \
                                                     USBUART_1_CHGDET_CTRL_REF_EN  | \
                                                     USBUART_1_CHGDET_CTRL_REF_DP)

    #define USBUART_1_CHGDET_CTRL_SECONDARY  (USBUART_1_CHGDET_CTRL_COMP_EN | \
                                                     USBUART_1_CHGDET_CTRL_COMP_DP | \
                                                     USBUART_1_CHGDET_CTRL_REF_EN  | \
                                                     USBUART_1_CHGDET_CTRL_REF_DM)

    #define USBUART_1_CHGDET_CTRL_DEFAULT    (0x00000900u)


#else /* (CY_PSOC3 || CY_PSOC5LP) */
    #define USBUART_1_PM_ACT_EN_FSUSB            USBUART_1_USB__PM_ACT_MSK
    #define USBUART_1_PM_STBY_EN_FSUSB           USBUART_1_USB__PM_STBY_MSK
    #define USBUART_1_PM_AVAIL_EN_FSUSBIO        (0x10u)

    #define USBUART_1_PM_USB_CR0_REF_EN          (0x01u)
    #define USBUART_1_PM_USB_CR0_PD_N            (0x02u)
    #define USBUART_1_PM_USB_CR0_PD_PULLUP_N     (0x04u)
#endif /* (CY_PSOC4) */


/***************************************
*       Macros Definitions
***************************************/

#if (CY_PSOC4)
    #define USBUART_1_ClearSieInterruptSource(intMask) \
                do{ \
                    USBUART_1_INTR_SIE_REG = (uint32) (intMask); \
                }while(0)
#else
    #define USBUART_1_ClearSieInterruptSource(intMask) \
                do{ /* Does nothing. */ }while(0)
#endif /* (CY_PSOC4) */

#define USBUART_1_ClearSieEpInterruptSource(intMask) \
            do{ \
                USBUART_1_SIE_EP_INT_SR_REG = (uint8) (intMask); \
            }while(0)

#define USBUART_1_GET_ACTIVE_IN_EP_CR0_MODE(epType)  (((epType) == USBUART_1_EP_TYPE_ISOC) ? \
                                                                (USBUART_1_MODE_ISO_IN) : (USBUART_1_MODE_ACK_IN))

#define USBUART_1_GET_ACTIVE_OUT_EP_CR0_MODE(epType) (((epType) == USBUART_1_EP_TYPE_ISOC) ? \
                                                                (USBUART_1_MODE_ISO_OUT) : (USBUART_1_MODE_ACK_OUT))

#define USBUART_1_GET_EP_TYPE(epNumber)  (USBUART_1_EP[epNumber].attrib & USBUART_1_EP_TYPE_MASK)

#define USBUART_1_GET_UINT16(hi, low)    (((uint16) ((uint16) (hi) << 8u)) | ((uint16) (low) & 0xFFu))


/***************************************
*    Initialization Register Settings
***************************************/

/* Clear device address and enable USB IP respond to USB traffic. */
#define USBUART_1_DEFUALT_CR0    (USBUART_1_CR0_ENABLE)

/* Arbiter configuration depends on memory management mode. */
#define USBUART_1_DEFAULT_ARB_CFG    ((USBUART_1_EP_MANAGEMENT_MANUAL) ? (USBUART_1_ARB_CFG_DMA_CFG_NONE) : \
                                                ((USBUART_1_EP_MANAGEMENT_DMA_MANUAL) ? \
                                                    (USBUART_1_ARB_CFG_DMA_CFG_MANUAL) : \
                                                        (USBUART_1_ARB_CFG_AUTO_MEM | USBUART_1_ARB_CFG_DMA_CFG_AUTO)))

/* Enable arbiter interrupt for active endpoints only */
#define USBUART_1_DEFAULT_ARB_INT_EN \
        ((uint8) ((uint8) USBUART_1_DMA1_ACTIVE << USBUART_1_ARB_INT_EP1_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA2_ACTIVE << USBUART_1_ARB_INT_EP2_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA3_ACTIVE << USBUART_1_ARB_INT_EP3_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA4_ACTIVE << USBUART_1_ARB_INT_EP4_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA5_ACTIVE << USBUART_1_ARB_INT_EP5_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA6_ACTIVE << USBUART_1_ARB_INT_EP6_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA7_ACTIVE << USBUART_1_ARB_INT_EP7_INTR_POS) | \
         (uint8) ((uint8) USBUART_1_DMA8_ACTIVE << USBUART_1_ARB_INT_EP8_INTR_POS))

/* Enable all SIE endpoints interrupts */
#define USBUART_1_DEFAULT_SIE_EP_INT_EN  (USBUART_1_SIE_INT_EP1_INTR | \
                                                 USBUART_1_SIE_INT_EP2_INTR | \
                                                 USBUART_1_SIE_INT_EP3_INTR | \
                                                 USBUART_1_SIE_INT_EP4_INTR | \
                                                 USBUART_1_SIE_INT_EP5_INTR | \
                                                 USBUART_1_SIE_INT_EP6_INTR | \
                                                 USBUART_1_SIE_INT_EP7_INTR | \
                                                 USBUART_1_SIE_INT_EP8_INTR)

#define USBUART_1_ARB_EPX_CFG_DEFAULT    (USBUART_1_ARB_EPX_CFG_RESET | \
                                                 USBUART_1_ARB_EPX_CFG_CRC_BYPASS)

/* Default EP arbiter interrupt source register */
#define USBUART_1_ARB_EPX_INT_COMMON_MASK   (USBUART_1_ARB_EPX_INT_IN_BUF_FULL | \
                                                    USBUART_1_ARB_EPX_INT_BUF_OVER    | \
                                                    USBUART_1_ARB_EPX_INT_BUF_UNDER   | \
                                                    USBUART_1_ARB_EPX_INT_ERR_INT     | \
                                                    (USBUART_1_EP_MANAGEMENT_DMA_MANUAL ? USBUART_1_ARB_EPX_INT_DMA_GNT : 0u))

#define USBUART_1_CLEAR_REG      (0u)

#if (CY_PSOC4)
    /* Set USB lock option when IMO is locked to USB traffic. */
    #define USBUART_1_DEFUALT_CR1    ((0u != CySysClkImoGetUsbLock()) ? (USBUART_1_CR1_ENABLE_LOCK) : (0u))

    /* Recommended value is increased from 3 to 10 due to suppress glitch on  
     * RSE0 with USB2.0 hubs (LF CLK = 32kHz equal to 350us). */
    #define USBUART_1_DEFUALT_BUS_RST_CNT  (10u)

    /* Select VBUS sources as: valid, PHY of GPIO, and clears isolate bit. */
    /* Application level must ensure that VBUS is valid valid to use. */
    #define USBUART_1_DEFAULT_POWER_CTRL_VBUS    (USBUART_1_POWER_CTRL_ENABLE_VBUS_PULLDOWN | \
                                                         ((!USBUART_1_VBUS_MONITORING_ENABLE) ? \
                                                            (USBUART_1_POWER_CTRL_VBUS_VALID_OVR_1) : \
                                                                (USBUART_1_VBUS_POWER_PAD_ENABLE ? \
                                                                    (USBUART_1_POWER_CTRL_VBUS_VALID_OVR_PHY) : \
                                                                    (USBUART_1_POWER_CTRL_VBUS_VALID_OVR_GPIO))))
    /* Enable USB IP. */
    #define USBUART_1_DEFAULT_POWER_CTRL_PHY (USBUART_1_POWER_CTRL_SUSPEND     | \
                                                     USBUART_1_POWER_CTRL_SUSPEND_DEL | \
                                                     USBUART_1_POWER_CTRL_ENABLE_RCVR | \
                                                     USBUART_1_POWER_CTRL_ENABLE_DPO  | \
                                                     USBUART_1_POWER_CTRL_ENABLE_DMO  | \
                                                     USBUART_1_POWER_CTRL_ENABLE)

    /* Assign interrupt between levels lo, med, hi. */
    #define USBUART_1_DEFAULT_INTR_LVL_SEL   ((uint32) (USBUART_1_INTR_LVL_SEL))

    /* Enable interrupt source in the INTR_SIE. The SOF is always disabled and EP0 is enabled. */
    #define USBUART_1_DEFAULT_INTR_SIE_MASK \
                ((uint32) ((uint32) USBUART_1_BUS_RESET_ISR_ACTIVE << USBUART_1_INTR_SIE_BUS_RESET_INTR_POS) | \
                 (uint32) ((uint32) USBUART_1_SOF_ISR_ACTIVE       << USBUART_1_INTR_SIE_SOF_INTR_POS)       | \
                 (uint32) ((uint32) USBUART_1_LPM_ACTIVE           << USBUART_1_INTR_SIE_LPM_INTR_POS)       | \
                 (uint32) ((uint32) USBUART_1_INTR_SIE_EP0_INTR))

    /* Arbiter interrupt sources */
    #define USBUART_1_ARB_EPX_INT_MASK   (USBUART_1_ARB_EPX_INT_COMMON_MASK | \
                                                (USBUART_1_EP_MANAGEMENT_DMA_AUTO ? USBUART_1_ARB_EPX_INT_DMA_TERMIN : 0u))

    /* Common DMA configuration */
    #define USBUART_1_DMA_COMMON_CFG     (CYDMA_PULSE | CYDMA_ENTIRE_DESCRIPTOR | \
                                                 CYDMA_NON_PREEMPTABLE)


#else
    #define USBUART_1_ARB_EPX_INT_MASK   (USBUART_1_ARB_EPX_INT_COMMON_MASK)

    #define USBUART_1_DEFUALT_CR1        (USBUART_1_CR1_ENABLE_LOCK)

    /* Recommended value is 3 for LF CLK = 100kHz equal to 100us. */
    #define USBUART_1_DEFUALT_BUS_RST_CNT    (10u)
#endif /* (CY_PSOC4) */

/*
* \addtogroup group_deprecated
* @{
*/

/***************************************
* The following code is DEPRECATED and
* must not be used.
***************************************/

/* Renamed type definitions */
#define USBUART_1_CODE CYCODE
#define USBUART_1_FAR CYFAR
#if defined(__C51__) || defined(__CX51__)
    #define USBUART_1_DATA data
    #define USBUART_1_XDATA xdata
#else
    #define USBUART_1_DATA
    #define USBUART_1_XDATA
#endif /*  __C51__ */
#define USBUART_1_NULL       NULL
/** @} deprecated */
/* Renamed structure fields */
#define wBuffOffset         buffOffset
#define wBufferSize         bufferSize
#define bStatus             status
#define wLength             length
#define wCount              count

/* Renamed global variable */
#define CurrentTD           USBUART_1_currentTD
#define USBUART_1_interfaceSetting_last       USBUART_1_interfaceSettingLast

/* Renamed global constants */
#define USBUART_1_DWR_VDDD_OPERATION         (USBUART_1_DWR_POWER_OPERATION)

/* Renamed functions */
#define USBUART_1_bCheckActivity             USBUART_1_CheckActivity
#define USBUART_1_bGetConfiguration          USBUART_1_GetConfiguration
#define USBUART_1_bGetInterfaceSetting       USBUART_1_GetInterfaceSetting
#define USBUART_1_bGetEPState                USBUART_1_GetEPState
#define USBUART_1_wGetEPCount                USBUART_1_GetEPCount
#define USBUART_1_bGetEPAckState             USBUART_1_GetEPAckState
#define USBUART_1_bRWUEnabled                USBUART_1_RWUEnabled
#define USBUART_1_bVBusPresent               USBUART_1_VBusPresent

#define USBUART_1_bConfiguration             USBUART_1_configuration
#define USBUART_1_bInterfaceSetting          USBUART_1_interfaceSetting
#define USBUART_1_bDeviceAddress             USBUART_1_deviceAddress
#define USBUART_1_bDeviceStatus              USBUART_1_deviceStatus
#define USBUART_1_bDevice                    USBUART_1_device
#define USBUART_1_bTransferState             USBUART_1_transferState
#define USBUART_1_bLastPacketSize            USBUART_1_lastPacketSize

#define USBUART_1_LoadEP                     USBUART_1_LoadInEP
#define USBUART_1_LoadInISOCEP               USBUART_1_LoadInEP
#define USBUART_1_EnableOutISOCEP            USBUART_1_EnableOutEP

#define USBUART_1_SetVector                  CyIntSetVector
#define USBUART_1_SetPriority                CyIntSetPriority
#define USBUART_1_EnableInt                  CyIntEnable

/* Replace with register access. */
#define USBUART_1_bmRequestType      USBUART_1_EP0_DR0_PTR
#define USBUART_1_bRequest           USBUART_1_EP0_DR1_PTR
#define USBUART_1_wValue             USBUART_1_EP0_DR2_PTR
#define USBUART_1_wValueHi           USBUART_1_EP0_DR3_PTR
#define USBUART_1_wValueLo           USBUART_1_EP0_DR2_PTR
#define USBUART_1_wIndex             USBUART_1_EP0_DR4_PTR
#define USBUART_1_wIndexHi           USBUART_1_EP0_DR5_PTR
#define USBUART_1_wIndexLo           USBUART_1_EP0_DR4_PTR
#define USBUART_1_length             USBUART_1_EP0_DR6_PTR
#define USBUART_1_lengthHi           USBUART_1_EP0_DR7_PTR
#define USBUART_1_lengthLo           USBUART_1_EP0_DR6_PTR

/* Rename VBUS monitoring registers. */
#if (CY_PSOC3 || CY_PSOC5LP)
    #if (USBUART_1_VBUS_MONITORING_ENABLE)
        #if (USBUART_1_VBUS_MONITORING_INTERNAL)
            #define USBUART_1_VBUS_DR_PTR    ( (reg8 *) USBUART_1_VBUS__DR)
            #define USBUART_1_VBUS_DR_REG    (*(reg8 *) USBUART_1_VBUS__DR)
            #define USBUART_1_VBUS_PS_PTR    ( (reg8 *) USBUART_1_VBUS__PS)
            #define USBUART_1_VBUS_PS_REG    (*(reg8 *) USBUART_1_VBUS__PS)
            #define USBUART_1_VBUS_MASK          USBUART_1_VBUS__MASK
        #else
            #define USBUART_1_VBUS_PS_PTR    ( (reg8 *) USBUART_1_Vbus_ps_sts_sts_reg__STATUS_REG)
            #define USBUART_1_VBUS_MASK      (0x01u)
        #endif /* (USBUART_1_VBUS_MONITORING_INTERNAL) */
    #endif /*(USBUART_1_VBUS_MONITORING_ENABLE) */
        
    /* Pointer DIE structure in flash (8 bytes): Y and X location, wafer, lot msb, lot lsb, 
    *  work week, fab/year, minor. */
    #define USBUART_1_DIE_ID             CYDEV_FLSHID_CUST_TABLES_BASE

     #if (USBUART_1_EP_MANAGEMENT_DMA_AUTO)
        #if (USBUART_1_DMA1_ACTIVE)
            #define USBUART_1_ep1_TD_TERMOUT_EN  (USBUART_1_ep1__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep1_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA1_ACTIVE) */

        #if (USBUART_1_DMA2_ACTIVE)
            #define USBUART_1_ep2_TD_TERMOUT_EN  (USBUART_1_ep2__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep2_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA2_ACTIVE) */

        #if (USBUART_1_DMA3_ACTIVE)
            #define USBUART_1_ep3_TD_TERMOUT_EN  (USBUART_1_ep3__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep3_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA3_ACTIVE) */

        #if (USBUART_1_DMA4_ACTIVE)
            #define USBUART_1_ep4_TD_TERMOUT_EN  (USBUART_1_ep4__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep4_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA4_ACTIVE) */

        #if (USBUART_1_DMA5_ACTIVE)
            #define USBUART_1_ep5_TD_TERMOUT_EN  (USBUART_1_ep5__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep5_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA5_ACTIVE) */

        #if (USBUART_1_DMA6_ACTIVE)
            #define USBUART_1_ep6_TD_TERMOUT_EN  (USBUART_1_ep6__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep6_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA6_ACTIVE) */

        #if (USBUART_1_DMA7_ACTIVE)
            #define USBUART_1_ep7_TD_TERMOUT_EN  (USBUART_1_ep7__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep7_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA7_ACTIVE) */

        #if (USBUART_1_DMA8_ACTIVE)
            #define USBUART_1_ep8_TD_TERMOUT_EN  (USBUART_1_ep8__TD_TERMOUT_EN)
        #else
            #define USBUART_1_ep8_TD_TERMOUT_EN  (0u)
        #endif /* (USBUART_1_DMA8_ACTIVE) */
    #endif /* (USBUART_1_EP_MANAGEMENT_DMA_AUTO) */   
#endif /* (CY_PSOC3 || CY_PSOC5LP) */

/* Rename USB IP registers. */
#define USBUART_1_ARB_CFG        USBUART_1_ARB_CFG_PTR

#define USBUART_1_ARB_EP1_CFG    USBUART_1_ARB_EP1_CFG_PTR
#define USBUART_1_ARB_EP1_INT_EN USBUART_1_ARB_EP1_INT_EN_PTR
#define USBUART_1_ARB_EP1_SR     USBUART_1_ARB_EP1_SR_PTR

#define USBUART_1_ARB_EP2_CFG    USBUART_1_ARB_EP2_CFG_PTR
#define USBUART_1_ARB_EP2_INT_EN USBUART_1_ARB_EP2_INT_EN_PTR
#define USBUART_1_ARB_EP2_SR     USBUART_1_ARB_EP2_SR_PTR

#define USBUART_1_ARB_EP3_CFG    USBUART_1_ARB_EP3_CFG_PTR
#define USBUART_1_ARB_EP3_INT_EN USBUART_1_ARB_EP3_INT_EN_PTR
#define USBUART_1_ARB_EP3_SR     USBUART_1_ARB_EP3_SR_PTR

#define USBUART_1_ARB_EP4_CFG    USBUART_1_ARB_EP4_CFG_PTR
#define USBUART_1_ARB_EP4_INT_EN USBUART_1_ARB_EP4_INT_EN_PTR
#define USBUART_1_ARB_EP4_SR     USBUART_1_ARB_EP4_SR_PTR

#define USBUART_1_ARB_EP5_CFG    USBUART_1_ARB_EP5_CFG_PTR
#define USBUART_1_ARB_EP5_INT_EN USBUART_1_ARB_EP5_INT_EN_PTR
#define USBUART_1_ARB_EP5_SR     USBUART_1_ARB_EP5_SR_PTR

#define USBUART_1_ARB_EP6_CFG    USBUART_1_ARB_EP6_CFG_PTR
#define USBUART_1_ARB_EP6_INT_EN USBUART_1_ARB_EP6_INT_EN_PTR
#define USBUART_1_ARB_EP6_SR     USBUART_1_ARB_EP6_SR_PTR

#define USBUART_1_ARB_EP7_CFG    USBUART_1_ARB_EP7_CFG_PTR
#define USBUART_1_ARB_EP7_INT_EN USBUART_1_ARB_EP7_INT_EN_PTR
#define USBUART_1_ARB_EP7_SR     USBUART_1_ARB_EP7_SR_PTR

#define USBUART_1_ARB_EP8_CFG    USBUART_1_ARB_EP8_CFG_PTR
#define USBUART_1_ARB_EP8_INT_EN USBUART_1_ARB_EP8_INT_EN_PTR
#define USBUART_1_ARB_EP8_SR     USBUART_1_ARB_EP8_SR_PTR

#define USBUART_1_ARB_INT_EN     USBUART_1_ARB_INT_EN_PTR
#define USBUART_1_ARB_INT_SR     USBUART_1_ARB_INT_SR_PTR

#define USBUART_1_ARB_RW1_DR     USBUART_1_ARB_RW1_DR_PTR
#define USBUART_1_ARB_RW1_RA     USBUART_1_ARB_RW1_RA_PTR
#define USBUART_1_ARB_RW1_RA_MSB USBUART_1_ARB_RW1_RA_MSB_PTR
#define USBUART_1_ARB_RW1_WA     USBUART_1_ARB_RW1_WA_PTR
#define USBUART_1_ARB_RW1_WA_MSB USBUART_1_ARB_RW1_WA_MSB_PTR

#define USBUART_1_ARB_RW2_DR     USBUART_1_ARB_RW2_DR_PTR
#define USBUART_1_ARB_RW2_RA     USBUART_1_ARB_RW2_RA_PTR
#define USBUART_1_ARB_RW2_RA_MSB USBUART_1_ARB_RW2_RA_MSB_PTR
#define USBUART_1_ARB_RW2_WA     USBUART_1_ARB_RW2_WA_PTR
#define USBUART_1_ARB_RW2_WA_MSB USBUART_1_ARB_RW2_WA_MSB_PTR

#define USBUART_1_ARB_RW3_DR     USBUART_1_ARB_RW3_DR_PTR
#define USBUART_1_ARB_RW3_RA     USBUART_1_ARB_RW3_RA_PTR
#define USBUART_1_ARB_RW3_RA_MSB USBUART_1_ARB_RW3_RA_MSB_PTR
#define USBUART_1_ARB_RW3_WA     USBUART_1_ARB_RW3_WA_PTR
#define USBUART_1_ARB_RW3_WA_MSB USBUART_1_ARB_RW3_WA_MSB_PTR

#define USBUART_1_ARB_RW4_DR     USBUART_1_ARB_RW4_DR_PTR
#define USBUART_1_ARB_RW4_RA     USBUART_1_ARB_RW4_RA_PTR
#define USBUART_1_ARB_RW4_RA_MSB USBUART_1_ARB_RW4_RA_MSB_PTR
#define USBUART_1_ARB_RW4_WA     USBUART_1_ARB_RW4_WA_PTR
#define USBUART_1_ARB_RW4_WA_MSB USBUART_1_ARB_RW4_WA_MSB_PTR

#define USBUART_1_ARB_RW5_DR     USBUART_1_ARB_RW5_DR_PTR
#define USBUART_1_ARB_RW5_RA     USBUART_1_ARB_RW5_RA_PTR
#define USBUART_1_ARB_RW5_RA_MSB USBUART_1_ARB_RW5_RA_MSB_PTR
#define USBUART_1_ARB_RW5_WA     USBUART_1_ARB_RW5_WA_PTR
#define USBUART_1_ARB_RW5_WA_MSB USBUART_1_ARB_RW5_WA_MSB_PTR

#define USBUART_1_ARB_RW6_DR     USBUART_1_ARB_RW6_DR_PTR
#define USBUART_1_ARB_RW6_RA     USBUART_1_ARB_RW6_RA_PTR
#define USBUART_1_ARB_RW6_RA_MSB USBUART_1_ARB_RW6_RA_MSB_PTR
#define USBUART_1_ARB_RW6_WA     USBUART_1_ARB_RW6_WA_PTR
#define USBUART_1_ARB_RW6_WA_MSB USBUART_1_ARB_RW6_WA_MSB_PTR

#define USBUART_1_ARB_RW7_DR     USBUART_1_ARB_RW7_DR_PTR
#define USBUART_1_ARB_RW7_RA     USBUART_1_ARB_RW7_RA_PTR
#define USBUART_1_ARB_RW7_RA_MSB USBUART_1_ARB_RW7_RA_MSB_PTR
#define USBUART_1_ARB_RW7_WA     USBUART_1_ARB_RW7_WA_PTR
#define USBUART_1_ARB_RW7_WA_MSB USBUART_1_ARB_RW7_WA_MSB_PTR

#define USBUART_1_ARB_RW8_DR     USBUART_1_ARB_RW8_DR_PTR
#define USBUART_1_ARB_RW8_RA     USBUART_1_ARB_RW8_RA_PTR
#define USBUART_1_ARB_RW8_RA_MSB USBUART_1_ARB_RW8_RA_MSB_PTR
#define USBUART_1_ARB_RW8_WA     USBUART_1_ARB_RW8_WA_PTR
#define USBUART_1_ARB_RW8_WA_MSB USBUART_1_ARB_RW8_WA_MSB_PTR

#define USBUART_1_BUF_SIZE       USBUART_1_BUF_SIZE_PTR
#define USBUART_1_BUS_RST_CNT    USBUART_1_BUS_RST_CNT_PTR
#define USBUART_1_CR0            USBUART_1_CR0_PTR
#define USBUART_1_CR1            USBUART_1_CR1_PTR
#define USBUART_1_CWA            USBUART_1_CWA_PTR
#define USBUART_1_CWA_MSB        USBUART_1_CWA_MSB_PTR

#define USBUART_1_DMA_THRES      USBUART_1_DMA_THRES_PTR
#define USBUART_1_DMA_THRES_MSB  USBUART_1_DMA_THRES_MSB_PTR

#define USBUART_1_EP_ACTIVE      USBUART_1_EP_ACTIVE_PTR
#define USBUART_1_EP_TYPE        USBUART_1_EP_TYPE_PTR

#define USBUART_1_EP0_CNT        USBUART_1_EP0_CNT_PTR
#define USBUART_1_EP0_CR         USBUART_1_EP0_CR_PTR
#define USBUART_1_EP0_DR0        USBUART_1_EP0_DR0_PTR
#define USBUART_1_EP0_DR1        USBUART_1_EP0_DR1_PTR
#define USBUART_1_EP0_DR2        USBUART_1_EP0_DR2_PTR
#define USBUART_1_EP0_DR3        USBUART_1_EP0_DR3_PTR
#define USBUART_1_EP0_DR4        USBUART_1_EP0_DR4_PTR
#define USBUART_1_EP0_DR5        USBUART_1_EP0_DR5_PTR
#define USBUART_1_EP0_DR6        USBUART_1_EP0_DR6_PTR
#define USBUART_1_EP0_DR7        USBUART_1_EP0_DR7_PTR

#define USBUART_1_OSCLK_DR0      USBUART_1_OSCLK_DR0_PTR
#define USBUART_1_OSCLK_DR1      USBUART_1_OSCLK_DR1_PTR

#define USBUART_1_PM_ACT_CFG     USBUART_1_PM_ACT_CFG_PTR
#define USBUART_1_PM_STBY_CFG    USBUART_1_PM_STBY_CFG_PTR

#define USBUART_1_SIE_EP_INT_EN  USBUART_1_SIE_EP_INT_EN_PTR
#define USBUART_1_SIE_EP_INT_SR  USBUART_1_SIE_EP_INT_SR_PTR

#define USBUART_1_SIE_EP1_CNT0   USBUART_1_SIE_EP1_CNT0_PTR
#define USBUART_1_SIE_EP1_CNT1   USBUART_1_SIE_EP1_CNT1_PTR
#define USBUART_1_SIE_EP1_CR0    USBUART_1_SIE_EP1_CR0_PTR

#define USBUART_1_SIE_EP2_CNT0   USBUART_1_SIE_EP2_CNT0_PTR
#define USBUART_1_SIE_EP2_CNT1   USBUART_1_SIE_EP2_CNT1_PTR
#define USBUART_1_SIE_EP2_CR0    USBUART_1_SIE_EP2_CR0_PTR

#define USBUART_1_SIE_EP3_CNT0   USBUART_1_SIE_EP3_CNT0_PTR
#define USBUART_1_SIE_EP3_CNT1   USBUART_1_SIE_EP3_CNT1_PTR
#define USBUART_1_SIE_EP3_CR0    USBUART_1_SIE_EP3_CR0_PTR

#define USBUART_1_SIE_EP4_CNT0   USBUART_1_SIE_EP4_CNT0_PTR
#define USBUART_1_SIE_EP4_CNT1   USBUART_1_SIE_EP4_CNT1_PTR
#define USBUART_1_SIE_EP4_CR0    USBUART_1_SIE_EP4_CR0_PTR

#define USBUART_1_SIE_EP5_CNT0   USBUART_1_SIE_EP5_CNT0_PTR
#define USBUART_1_SIE_EP5_CNT1   USBUART_1_SIE_EP5_CNT1_PTR
#define USBUART_1_SIE_EP5_CR0    USBUART_1_SIE_EP5_CR0_PTR

#define USBUART_1_SIE_EP6_CNT0   USBUART_1_SIE_EP6_CNT0_PTR
#define USBUART_1_SIE_EP6_CNT1   USBUART_1_SIE_EP6_CNT1_PTR
#define USBUART_1_SIE_EP6_CR0    USBUART_1_SIE_EP6_CR0_PTR

#define USBUART_1_SIE_EP7_CNT0   USBUART_1_SIE_EP7_CNT0_PTR
#define USBUART_1_SIE_EP7_CNT1   USBUART_1_SIE_EP7_CNT1_PTR
#define USBUART_1_SIE_EP7_CR0    USBUART_1_SIE_EP7_CR0_PTR

#define USBUART_1_SIE_EP8_CNT0   USBUART_1_SIE_EP8_CNT0_PTR
#define USBUART_1_SIE_EP8_CNT1   USBUART_1_SIE_EP8_CNT1_PTR
#define USBUART_1_SIE_EP8_CR0    USBUART_1_SIE_EP8_CR0_PTR

#define USBUART_1_SOF0           USBUART_1_SOF0_PTR
#define USBUART_1_SOF1           USBUART_1_SOF1_PTR

#define USBUART_1_USB_CLK_EN     USBUART_1_USB_CLK_EN_PTR

#define USBUART_1_USBIO_CR0      USBUART_1_USBIO_CR0_PTR
#define USBUART_1_USBIO_CR1      USBUART_1_USBIO_CR1_PTR
#define USBUART_1_USBIO_CR2      USBUART_1_USBIO_CR2_PTR

#define USBUART_1_DM_INP_DIS_PTR     ( (reg8 *) USBUART_1_Dm__INP_DIS)
#define USBUART_1_DM_INP_DIS_REG     (*(reg8 *) USBUART_1_Dm__INP_DIS)
#define USBUART_1_DP_INP_DIS_PTR     ( (reg8 *) USBUART_1_Dp__INP_DIS)
#define USBUART_1_DP_INP_DIS_REG     (*(reg8 *) USBUART_1_Dp__INP_DIS)
#define USBUART_1_DP_INTSTAT_PTR     ( (reg8 *) USBUART_1_Dp__INTSTAT)
#define USBUART_1_DP_INTSTAT_REG     (*(reg8 *) USBUART_1_Dp__INTSTAT)
#define USBUART_1_DM_MASK            USBUART_1_Dm__0__MASK
#define USBUART_1_DP_MASK            USBUART_1_Dp__0__MASK

#define USBFS_SIE_EP_INT_EP1_MASK        (0x01u)
#define USBFS_SIE_EP_INT_EP2_MASK        (0x02u)
#define USBFS_SIE_EP_INT_EP3_MASK        (0x04u)
#define USBFS_SIE_EP_INT_EP4_MASK        (0x08u)
#define USBFS_SIE_EP_INT_EP5_MASK        (0x10u)
#define USBFS_SIE_EP_INT_EP6_MASK        (0x20u)
#define USBFS_SIE_EP_INT_EP7_MASK        (0x40u)
#define USBFS_SIE_EP_INT_EP8_MASK        (0x80u)

#define USBUART_1_ARB_EPX_SR_IN_BUF_FULL     (0x01u)
#define USBUART_1_ARB_EPX_SR_DMA_GNT         (0x02u)
#define USBUART_1_ARB_EPX_SR_BUF_OVER        (0x04u)
#define USBUART_1_ARB_EPX_SR_BUF_UNDER       (0x08u)

#define USBUART_1_ARB_EPX_INT_EN_ALL USBUART_1_ARB_EPX_INT_ALL

#define USBUART_1_CR1_BUS_ACTIVITY_SHIFT     (0x02u)

#define USBUART_1_BUS_RST_COUNT      USBUART_1_DEFUALT_BUS_RST_CNT

#define USBUART_1_ARB_INT_MASK       USBUART_1_DEFAULT_ARB_INT_EN

#if (CYDEV_CHIP_DIE_EXPECT == CYDEV_CHIP_DIE_LEOPARD)
    /* CY_PSOC3 interrupt registers */
    #define USBUART_1_USB_ISR_PRIOR  ((reg8 *) CYDEV_INTC_PRIOR0)
    #define USBUART_1_USB_ISR_SET_EN ((reg8 *) CYDEV_INTC_SET_EN0)
    #define USBUART_1_USB_ISR_CLR_EN ((reg8 *) CYDEV_INTC_CLR_EN0)
    #define USBUART_1_USB_ISR_VECT   ((cyisraddress *) CYDEV_INTC_VECT_MBASE)
#elif (CYDEV_CHIP_DIE_EXPECT == CYDEV_CHIP_DIE_PANTHER)
    /* CY_PSOC5LP interrupt registers */
    #define USBUART_1_USB_ISR_PRIOR  ((reg8 *) CYDEV_NVIC_PRI_0)
    #define USBUART_1_USB_ISR_SET_EN ((reg8 *) CYDEV_NVIC_SETENA0)
    #define USBUART_1_USB_ISR_CLR_EN ((reg8 *) CYDEV_NVIC_CLRENA0)
    #define USBUART_1_USB_ISR_VECT   ((cyisraddress *) CYDEV_NVIC_VECT_OFFSET)
#endif /*  CYDEV_CHIP_DIE_EXPECT */


#endif /* (CY_USBFS_USBUART_1_H) */


/* [] END OF FILE */
