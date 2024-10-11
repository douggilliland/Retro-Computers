/*******************************************************************************
* File Name: emFile_1_SPI0.h
* Version 2.40
*
* Description:
*  Contains the function prototypes, constants and register definition
*  of the SPI Master Component.
*
* Note:
*  None
*
********************************************************************************
* Copyright 2008-2012, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_SPIM_emFile_1_SPI0_H)
#define CY_SPIM_emFile_1_SPI0_H

#include "cytypes.h"
#include "cyfitter.h"
#include "CyLib.h"

/* Check to see if required defines such as CY_PSOC5A are available */
/* They are defined starting with cy_boot v3.0 */
#if !defined (CY_PSOC5A)
    #error Component SPI_Master_v2_40 requires cy_boot v3.0 or later
#endif /* (CY_PSOC5A) */


/***************************************
*   Conditional Compilation Parameters
***************************************/

#define emFile_1_SPI0_INTERNAL_CLOCK             (0u)

#if(0u != emFile_1_SPI0_INTERNAL_CLOCK)
    #include "emFile_1_SPI0_IntClock.h"
#endif /* (0u != emFile_1_SPI0_INTERNAL_CLOCK) */

#define emFile_1_SPI0_MODE                       (1u)
#define emFile_1_SPI0_DATA_WIDTH                 (8u)
#define emFile_1_SPI0_MODE_USE_ZERO              (1u)
#define emFile_1_SPI0_BIDIRECTIONAL_MODE         (0u)

/* Internal interrupt handling */
#define emFile_1_SPI0_TX_BUFFER_SIZE             (4u)
#define emFile_1_SPI0_RX_BUFFER_SIZE             (4u)
#define emFile_1_SPI0_INTERNAL_TX_INT_ENABLED    (0u)
#define emFile_1_SPI0_INTERNAL_RX_INT_ENABLED    (0u)

#define emFile_1_SPI0_SINGLE_REG_SIZE            (8u)
#define emFile_1_SPI0_USE_SECOND_DATAPATH        (emFile_1_SPI0_DATA_WIDTH > emFile_1_SPI0_SINGLE_REG_SIZE)

#define emFile_1_SPI0_FIFO_SIZE                  (4u)
#define emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED    ((0u != emFile_1_SPI0_INTERNAL_TX_INT_ENABLED) && \
                                                     (emFile_1_SPI0_TX_BUFFER_SIZE > emFile_1_SPI0_FIFO_SIZE))

#define emFile_1_SPI0_RX_SOFTWARE_BUF_ENABLED    ((0u != emFile_1_SPI0_INTERNAL_RX_INT_ENABLED) && \
                                                     (emFile_1_SPI0_RX_BUFFER_SIZE > emFile_1_SPI0_FIFO_SIZE))


/***************************************
*        Data Struct Definition
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 enableState;
    uint8 cntrPeriod;
    #if(CY_UDB_V0)
        uint8 saveSrTxIntMask;
        uint8 saveSrRxIntMask;
    #endif /* (CY_UDB_V0) */

} emFile_1_SPI0_BACKUP_STRUCT;


/***************************************
*        Function Prototypes
***************************************/

void  emFile_1_SPI0_Init(void)                           ;
void  emFile_1_SPI0_Enable(void)                         ;
void  emFile_1_SPI0_Start(void)                          ;
void  emFile_1_SPI0_Stop(void)                           ;

void  emFile_1_SPI0_EnableTxInt(void)                    ;
void  emFile_1_SPI0_EnableRxInt(void)                    ;
void  emFile_1_SPI0_DisableTxInt(void)                   ;
void  emFile_1_SPI0_DisableRxInt(void)                   ;

void  emFile_1_SPI0_Sleep(void)                          ;
void  emFile_1_SPI0_Wakeup(void)                         ;
void  emFile_1_SPI0_SaveConfig(void)                     ;
void  emFile_1_SPI0_RestoreConfig(void)                  ;

void  emFile_1_SPI0_SetTxInterruptMode(uint8 intSrc)     ;
void  emFile_1_SPI0_SetRxInterruptMode(uint8 intSrc)     ;
uint8 emFile_1_SPI0_ReadTxStatus(void)                   ;
uint8 emFile_1_SPI0_ReadRxStatus(void)                   ;
void  emFile_1_SPI0_WriteTxData(uint8 txData)  \
                                                            ;
uint8 emFile_1_SPI0_ReadRxData(void) \
                                                            ;
uint8 emFile_1_SPI0_GetRxBufferSize(void)                ;
uint8 emFile_1_SPI0_GetTxBufferSize(void)                ;
void  emFile_1_SPI0_ClearRxBuffer(void)                  ;
void  emFile_1_SPI0_ClearTxBuffer(void)                  ;
void  emFile_1_SPI0_ClearFIFO(void)                              ;
void  emFile_1_SPI0_PutArray(const uint8 buffer[], uint8 byteCount) \
                                                            ;

#if(0u != emFile_1_SPI0_BIDIRECTIONAL_MODE)
    void  emFile_1_SPI0_TxEnable(void)                   ;
    void  emFile_1_SPI0_TxDisable(void)                  ;
#endif /* (0u != emFile_1_SPI0_BIDIRECTIONAL_MODE) */

CY_ISR_PROTO(emFile_1_SPI0_TX_ISR);
CY_ISR_PROTO(emFile_1_SPI0_RX_ISR);


/**********************************
*   Variable with external linkage
**********************************/

extern uint8 emFile_1_SPI0_initVar;


/***************************************
*           API Constants
***************************************/

#define emFile_1_SPI0_TX_ISR_NUMBER     ((uint8) (emFile_1_SPI0_TxInternalInterrupt__INTC_NUMBER))
#define emFile_1_SPI0_RX_ISR_NUMBER     ((uint8) (emFile_1_SPI0_RxInternalInterrupt__INTC_NUMBER))

#define emFile_1_SPI0_TX_ISR_PRIORITY   ((uint8) (emFile_1_SPI0_TxInternalInterrupt__INTC_PRIOR_NUM))
#define emFile_1_SPI0_RX_ISR_PRIORITY   ((uint8) (emFile_1_SPI0_RxInternalInterrupt__INTC_PRIOR_NUM))


/***************************************
*    Initial Parameter Constants
***************************************/

#define emFile_1_SPI0_INT_ON_SPI_DONE    ((uint8) (0u   << emFile_1_SPI0_STS_SPI_DONE_SHIFT))
#define emFile_1_SPI0_INT_ON_TX_EMPTY    ((uint8) (0u   << emFile_1_SPI0_STS_TX_FIFO_EMPTY_SHIFT))
#define emFile_1_SPI0_INT_ON_TX_NOT_FULL ((uint8) (0u << \
                                                                           emFile_1_SPI0_STS_TX_FIFO_NOT_FULL_SHIFT))
#define emFile_1_SPI0_INT_ON_BYTE_COMP   ((uint8) (0u  << emFile_1_SPI0_STS_BYTE_COMPLETE_SHIFT))
#define emFile_1_SPI0_INT_ON_SPI_IDLE    ((uint8) (0u   << emFile_1_SPI0_STS_SPI_IDLE_SHIFT))

/* Disable TX_NOT_FULL if software buffer is used */
#define emFile_1_SPI0_INT_ON_TX_NOT_FULL_DEF ((emFile_1_SPI0_TX_SOFTWARE_BUF_ENABLED) ? \
                                                                        (0u) : (emFile_1_SPI0_INT_ON_TX_NOT_FULL))

/* TX interrupt mask */
#define emFile_1_SPI0_TX_INIT_INTERRUPTS_MASK    (emFile_1_SPI0_INT_ON_SPI_DONE  | \
                                                     emFile_1_SPI0_INT_ON_TX_EMPTY  | \
                                                     emFile_1_SPI0_INT_ON_TX_NOT_FULL_DEF | \
                                                     emFile_1_SPI0_INT_ON_BYTE_COMP | \
                                                     emFile_1_SPI0_INT_ON_SPI_IDLE)

#define emFile_1_SPI0_INT_ON_RX_FULL         ((uint8) (0u << \
                                                                          emFile_1_SPI0_STS_RX_FIFO_FULL_SHIFT))
#define emFile_1_SPI0_INT_ON_RX_NOT_EMPTY    ((uint8) (0u << \
                                                                          emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY_SHIFT))
#define emFile_1_SPI0_INT_ON_RX_OVER         ((uint8) (0u << \
                                                                          emFile_1_SPI0_STS_RX_FIFO_OVERRUN_SHIFT))

/* RX interrupt mask */
#define emFile_1_SPI0_RX_INIT_INTERRUPTS_MASK    (emFile_1_SPI0_INT_ON_RX_FULL      | \
                                                     emFile_1_SPI0_INT_ON_RX_NOT_EMPTY | \
                                                     emFile_1_SPI0_INT_ON_RX_OVER)
/* Nubmer of bits to receive/transmit */
#define emFile_1_SPI0_BITCTR_INIT            (((uint8) (emFile_1_SPI0_DATA_WIDTH << 1u)) - 1u)


/***************************************
*             Registers
***************************************/

#if(CY_PSOC3 || CY_PSOC5)
    #define emFile_1_SPI0_TXDATA_REG (* (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F0_REG)
    #define emFile_1_SPI0_TXDATA_PTR (  (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F0_REG)
    #define emFile_1_SPI0_RXDATA_REG (* (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F1_REG)
    #define emFile_1_SPI0_RXDATA_PTR (  (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F1_REG)
#else   /* PSOC4 */
    #if(emFile_1_SPI0_USE_SECOND_DATAPATH)
        #define emFile_1_SPI0_TXDATA_REG (* (reg16 *) \
                                          emFile_1_SPI0_BSPIM_sR8_Dp_u0__16BIT_F0_REG)
        #define emFile_1_SPI0_TXDATA_PTR (  (reg16 *) \
                                          emFile_1_SPI0_BSPIM_sR8_Dp_u0__16BIT_F0_REG)
        #define emFile_1_SPI0_RXDATA_REG (* (reg16 *) \
                                          emFile_1_SPI0_BSPIM_sR8_Dp_u0__16BIT_F1_REG)
        #define emFile_1_SPI0_RXDATA_PTR         (  (reg16 *) \
                                          emFile_1_SPI0_BSPIM_sR8_Dp_u0__16BIT_F1_REG)
    #else
        #define emFile_1_SPI0_TXDATA_REG (* (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F0_REG)
        #define emFile_1_SPI0_TXDATA_PTR (  (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F0_REG)
        #define emFile_1_SPI0_RXDATA_REG (* (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F1_REG)
        #define emFile_1_SPI0_RXDATA_PTR (  (reg8 *) \
                                                emFile_1_SPI0_BSPIM_sR8_Dp_u0__F1_REG)
    #endif /* (emFile_1_SPI0_USE_SECOND_DATAPATH) */
#endif     /* (CY_PSOC3 || CY_PSOC5) */

#define emFile_1_SPI0_AUX_CONTROL_DP0_REG (* (reg8 *) \
                                        emFile_1_SPI0_BSPIM_sR8_Dp_u0__DP_AUX_CTL_REG)
#define emFile_1_SPI0_AUX_CONTROL_DP0_PTR (  (reg8 *) \
                                        emFile_1_SPI0_BSPIM_sR8_Dp_u0__DP_AUX_CTL_REG)

#if(emFile_1_SPI0_USE_SECOND_DATAPATH)
    #define emFile_1_SPI0_AUX_CONTROL_DP1_REG  (* (reg8 *) \
                                        emFile_1_SPI0_BSPIM_sR8_Dp_u1__DP_AUX_CTL_REG)
    #define emFile_1_SPI0_AUX_CONTROL_DP1_PTR  (  (reg8 *) \
                                        emFile_1_SPI0_BSPIM_sR8_Dp_u1__DP_AUX_CTL_REG)
#endif /* (emFile_1_SPI0_USE_SECOND_DATAPATH) */

#define emFile_1_SPI0_COUNTER_PERIOD_REG     (* (reg8 *) emFile_1_SPI0_BSPIM_BitCounter__PERIOD_REG)
#define emFile_1_SPI0_COUNTER_PERIOD_PTR     (  (reg8 *) emFile_1_SPI0_BSPIM_BitCounter__PERIOD_REG)
#define emFile_1_SPI0_COUNTER_CONTROL_REG    (* (reg8 *) emFile_1_SPI0_BSPIM_BitCounter__CONTROL_AUX_CTL_REG)
#define emFile_1_SPI0_COUNTER_CONTROL_PTR    (  (reg8 *) emFile_1_SPI0_BSPIM_BitCounter__CONTROL_AUX_CTL_REG)

#define emFile_1_SPI0_TX_STATUS_REG          (* (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__STATUS_REG)
#define emFile_1_SPI0_TX_STATUS_PTR          (  (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__STATUS_REG)
#define emFile_1_SPI0_RX_STATUS_REG          (* (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__STATUS_REG)
#define emFile_1_SPI0_RX_STATUS_PTR          (  (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__STATUS_REG)

#define emFile_1_SPI0_CONTROL_REG            (* (reg8 *) \
                                      emFile_1_SPI0_BSPIM_BidirMode_SyncCtl_CtrlReg__CONTROL_REG)
#define emFile_1_SPI0_CONTROL_PTR            (  (reg8 *) \
                                      emFile_1_SPI0_BSPIM_BidirMode_SyncCtl_CtrlReg__CONTROL_REG)

#define emFile_1_SPI0_TX_STATUS_MASK_REG     (* (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__MASK_REG)
#define emFile_1_SPI0_TX_STATUS_MASK_PTR     (  (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__MASK_REG)
#define emFile_1_SPI0_RX_STATUS_MASK_REG     (* (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__MASK_REG)
#define emFile_1_SPI0_RX_STATUS_MASK_PTR     (  (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__MASK_REG)

#define emFile_1_SPI0_TX_STATUS_ACTL_REG     (* (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__STATUS_AUX_CTL_REG)
#define emFile_1_SPI0_TX_STATUS_ACTL_PTR     (  (reg8 *) emFile_1_SPI0_BSPIM_TxStsReg__STATUS_AUX_CTL_REG)
#define emFile_1_SPI0_RX_STATUS_ACTL_REG     (* (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__STATUS_AUX_CTL_REG)
#define emFile_1_SPI0_RX_STATUS_ACTL_PTR     (  (reg8 *) emFile_1_SPI0_BSPIM_RxStsReg__STATUS_AUX_CTL_REG)

#if(emFile_1_SPI0_USE_SECOND_DATAPATH)
    #define emFile_1_SPI0_AUX_CONTROLDP1     (emFile_1_SPI0_AUX_CONTROL_DP1_REG)
#endif /* (emFile_1_SPI0_USE_SECOND_DATAPATH) */


/***************************************
*       Register Constants
***************************************/

/* Status Register Definitions */
#define emFile_1_SPI0_STS_SPI_DONE_SHIFT             (0x00u)
#define emFile_1_SPI0_STS_TX_FIFO_EMPTY_SHIFT        (0x01u)
#define emFile_1_SPI0_STS_TX_FIFO_NOT_FULL_SHIFT     (0x02u)
#define emFile_1_SPI0_STS_BYTE_COMPLETE_SHIFT        (0x03u)
#define emFile_1_SPI0_STS_SPI_IDLE_SHIFT             (0x04u)
#define emFile_1_SPI0_STS_RX_FIFO_FULL_SHIFT         (0x04u)
#define emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY_SHIFT    (0x05u)
#define emFile_1_SPI0_STS_RX_FIFO_OVERRUN_SHIFT      (0x06u)

#define emFile_1_SPI0_STS_SPI_DONE           ((uint8) (0x01u << emFile_1_SPI0_STS_SPI_DONE_SHIFT))
#define emFile_1_SPI0_STS_TX_FIFO_EMPTY      ((uint8) (0x01u << emFile_1_SPI0_STS_TX_FIFO_EMPTY_SHIFT))
#define emFile_1_SPI0_STS_TX_FIFO_NOT_FULL   ((uint8) (0x01u << emFile_1_SPI0_STS_TX_FIFO_NOT_FULL_SHIFT))
#define emFile_1_SPI0_STS_BYTE_COMPLETE      ((uint8) (0x01u << emFile_1_SPI0_STS_BYTE_COMPLETE_SHIFT))
#define emFile_1_SPI0_STS_SPI_IDLE           ((uint8) (0x01u << emFile_1_SPI0_STS_SPI_IDLE_SHIFT))
#define emFile_1_SPI0_STS_RX_FIFO_FULL       ((uint8) (0x01u << emFile_1_SPI0_STS_RX_FIFO_FULL_SHIFT))
#define emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY  ((uint8) (0x01u << emFile_1_SPI0_STS_RX_FIFO_NOT_EMPTY_SHIFT))
#define emFile_1_SPI0_STS_RX_FIFO_OVERRUN    ((uint8) (0x01u << emFile_1_SPI0_STS_RX_FIFO_OVERRUN_SHIFT))

/* TX and RX masks for clear on read bits */
#define emFile_1_SPI0_TX_STS_CLR_ON_RD_BYTES_MASK    (0x09u)
#define emFile_1_SPI0_RX_STS_CLR_ON_RD_BYTES_MASK    (0x40u)

/* StatusI Register Interrupt Enable Control Bits */
/* As defined by the Register map for the AUX Control Register */
#define emFile_1_SPI0_INT_ENABLE     (0x10u) /* Enable interrupt from statusi */
#define emFile_1_SPI0_TX_FIFO_CLR    (0x01u) /* F0 - TX FIFO */
#define emFile_1_SPI0_RX_FIFO_CLR    (0x02u) /* F1 - RX FIFO */
#define emFile_1_SPI0_FIFO_CLR       (emFile_1_SPI0_TX_FIFO_CLR | emFile_1_SPI0_RX_FIFO_CLR)

/* Bit Counter (7-bit) Control Register Bit Definitions */
/* As defined by the Register map for the AUX Control Register */
#define emFile_1_SPI0_CNTR_ENABLE    (0x20u) /* Enable CNT7 */

/* Bi-Directional mode control bit */
#define emFile_1_SPI0_CTRL_TX_SIGNAL_EN  (0x01u)

/* Datapath Auxillary Control Register definitions */
#define emFile_1_SPI0_AUX_CTRL_FIFO0_CLR         (0x01u)
#define emFile_1_SPI0_AUX_CTRL_FIFO1_CLR         (0x02u)
#define emFile_1_SPI0_AUX_CTRL_FIFO0_LVL         (0x04u)
#define emFile_1_SPI0_AUX_CTRL_FIFO1_LVL         (0x08u)
#define emFile_1_SPI0_STATUS_ACTL_INT_EN_MASK    (0x10u)

/* Component disabled */
#define emFile_1_SPI0_DISABLED   (0u)


/***************************************
*       Macros
***************************************/

/* Returns true if componentn enabled */
#define emFile_1_SPI0_IS_ENABLED (0u != (emFile_1_SPI0_TX_STATUS_ACTL_REG & emFile_1_SPI0_INT_ENABLE))

/* Retuns TX status register */
#define emFile_1_SPI0_GET_STATUS_TX(swTxSts) ( (uint8)(emFile_1_SPI0_TX_STATUS_REG | \
                                                          ((swTxSts) & emFile_1_SPI0_TX_STS_CLR_ON_RD_BYTES_MASK)) )
/* Retuns RX status register */
#define emFile_1_SPI0_GET_STATUS_RX(swRxSts) ( (uint8)(emFile_1_SPI0_RX_STATUS_REG | \
                                                          ((swRxSts) & emFile_1_SPI0_RX_STS_CLR_ON_RD_BYTES_MASK)) )


/***************************************
*       Obsolete definitions
***************************************/

/* Following definitions are for version compatibility.
*  They are obsolete in SPIM v2_30.
*  Please do not use it in new projects
*/

#define emFile_1_SPI0_WriteByte   emFile_1_SPI0_WriteTxData
#define emFile_1_SPI0_ReadByte    emFile_1_SPI0_ReadRxData
void  emFile_1_SPI0_SetInterruptMode(uint8 intSrc)       ;
uint8 emFile_1_SPI0_ReadStatus(void)                     ;
void  emFile_1_SPI0_EnableInt(void)                      ;
void  emFile_1_SPI0_DisableInt(void)                     ;

/* Obsolete register names. Not to be used in new designs */
#define emFile_1_SPI0_TXDATA                 (emFile_1_SPI0_TXDATA_REG)
#define emFile_1_SPI0_RXDATA                 (emFile_1_SPI0_RXDATA_REG)
#define emFile_1_SPI0_AUX_CONTROLDP0         (emFile_1_SPI0_AUX_CONTROL_DP0_REG)
#define emFile_1_SPI0_TXBUFFERREAD           (emFile_1_SPI0_txBufferRead)
#define emFile_1_SPI0_TXBUFFERWRITE          (emFile_1_SPI0_txBufferWrite)
#define emFile_1_SPI0_RXBUFFERREAD           (emFile_1_SPI0_rxBufferRead)
#define emFile_1_SPI0_RXBUFFERWRITE          (emFile_1_SPI0_rxBufferWrite)

#define emFile_1_SPI0_COUNTER_PERIOD         (emFile_1_SPI0_COUNTER_PERIOD_REG)
#define emFile_1_SPI0_COUNTER_CONTROL        (emFile_1_SPI0_COUNTER_CONTROL_REG)
#define emFile_1_SPI0_STATUS                 (emFile_1_SPI0_TX_STATUS_REG)
#define emFile_1_SPI0_CONTROL                (emFile_1_SPI0_CONTROL_REG)
#define emFile_1_SPI0_STATUS_MASK            (emFile_1_SPI0_TX_STATUS_MASK_REG)
#define emFile_1_SPI0_STATUS_ACTL            (emFile_1_SPI0_TX_STATUS_ACTL_REG)

#define emFile_1_SPI0_INIT_INTERRUPTS_MASK  (emFile_1_SPI0_INT_ON_SPI_DONE     | \
                                                emFile_1_SPI0_INT_ON_TX_EMPTY     | \
                                                emFile_1_SPI0_INT_ON_TX_NOT_FULL_DEF  | \
                                                emFile_1_SPI0_INT_ON_RX_FULL      | \
                                                emFile_1_SPI0_INT_ON_RX_NOT_EMPTY | \
                                                emFile_1_SPI0_INT_ON_RX_OVER      | \
                                                emFile_1_SPI0_INT_ON_BYTE_COMP)
                                                
/* Following definitions are for version Compatibility.
*  They are obsolete in SPIM v2_40.
*  Please do not use it in new projects
*/

#define emFile_1_SPI0_DataWidth                  (emFile_1_SPI0_DATA_WIDTH)
#define emFile_1_SPI0_InternalClockUsed          (emFile_1_SPI0_INTERNAL_CLOCK)
#define emFile_1_SPI0_InternalTxInterruptEnabled (emFile_1_SPI0_INTERNAL_TX_INT_ENABLED)
#define emFile_1_SPI0_InternalRxInterruptEnabled (emFile_1_SPI0_INTERNAL_RX_INT_ENABLED)
#define emFile_1_SPI0_ModeUseZero                (emFile_1_SPI0_MODE_USE_ZERO)
#define emFile_1_SPI0_BidirectionalMode          (emFile_1_SPI0_BIDIRECTIONAL_MODE)
#define emFile_1_SPI0_Mode                       (emFile_1_SPI0_MODE)
#define emFile_1_SPI0_DATAWIDHT                  (emFile_1_SPI0_DATA_WIDTH)
#define emFile_1_SPI0_InternalInterruptEnabled   (0u)

#define emFile_1_SPI0_TXBUFFERSIZE   (emFile_1_SPI0_TX_BUFFER_SIZE)
#define emFile_1_SPI0_RXBUFFERSIZE   (emFile_1_SPI0_RX_BUFFER_SIZE)

#define emFile_1_SPI0_TXBUFFER       emFile_1_SPI0_txBuffer
#define emFile_1_SPI0_RXBUFFER       emFile_1_SPI0_rxBuffer

#endif /* (CY_SPIM_emFile_1_SPI0_H) */


/* [] END OF FILE */
