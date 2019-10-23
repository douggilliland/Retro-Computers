/*******************************************************************************
* File Name: SPI_Master.h
* Version 2.50
*
* Description:
*  Contains the function prototypes, constants and register definition
*  of the SPI Master Component.
*
* Note:
*  None
*
********************************************************************************
* Copyright 2008-2015, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#if !defined(CY_SPIM_SPI_Master_H)
#define CY_SPIM_SPI_Master_H

#include "cyfitter.h"
#include "cytypes.h"
#include "CyLib.h" /* For CyEnterCriticalSection() and CyExitCriticalSection() functions */


/***************************************
*   Conditional Compilation Parameters
***************************************/

#define SPI_Master_INTERNAL_CLOCK             (1u)

#if(0u != SPI_Master_INTERNAL_CLOCK)
    #include "SPI_Master_IntClock.h"
#endif /* (0u != SPI_Master_INTERNAL_CLOCK) */

#define SPI_Master_MODE                       (1u)
#define SPI_Master_DATA_WIDTH                 (8u)
#define SPI_Master_MODE_USE_ZERO              (1u)
#define SPI_Master_BIDIRECTIONAL_MODE         (0u)

/* Internal interrupt handling */
#define SPI_Master_TX_BUFFER_SIZE             (4u)
#define SPI_Master_RX_BUFFER_SIZE             (4u)
#define SPI_Master_INTERNAL_TX_INT_ENABLED    (0u)
#define SPI_Master_INTERNAL_RX_INT_ENABLED    (0u)

#define SPI_Master_SINGLE_REG_SIZE            (8u)
#define SPI_Master_USE_SECOND_DATAPATH        (SPI_Master_DATA_WIDTH > SPI_Master_SINGLE_REG_SIZE)

#define SPI_Master_FIFO_SIZE                  (4u)
#define SPI_Master_TX_SOFTWARE_BUF_ENABLED    ((0u != SPI_Master_INTERNAL_TX_INT_ENABLED) && \
                                                     (SPI_Master_TX_BUFFER_SIZE > SPI_Master_FIFO_SIZE))

#define SPI_Master_RX_SOFTWARE_BUF_ENABLED    ((0u != SPI_Master_INTERNAL_RX_INT_ENABLED) && \
                                                     (SPI_Master_RX_BUFFER_SIZE > SPI_Master_FIFO_SIZE))


/***************************************
*        Data Struct Definition
***************************************/

/* Sleep Mode API Support */
typedef struct
{
    uint8 enableState;
    uint8 cntrPeriod;
} SPI_Master_BACKUP_STRUCT;


/***************************************
*        Function Prototypes
***************************************/

void  SPI_Master_Init(void)                           ;
void  SPI_Master_Enable(void)                         ;
void  SPI_Master_Start(void)                          ;
void  SPI_Master_Stop(void)                           ;

void  SPI_Master_EnableTxInt(void)                    ;
void  SPI_Master_EnableRxInt(void)                    ;
void  SPI_Master_DisableTxInt(void)                   ;
void  SPI_Master_DisableRxInt(void)                   ;

void  SPI_Master_Sleep(void)                          ;
void  SPI_Master_Wakeup(void)                         ;
void  SPI_Master_SaveConfig(void)                     ;
void  SPI_Master_RestoreConfig(void)                  ;

void  SPI_Master_SetTxInterruptMode(uint8 intSrc)     ;
void  SPI_Master_SetRxInterruptMode(uint8 intSrc)     ;
uint8 SPI_Master_ReadTxStatus(void)                   ;
uint8 SPI_Master_ReadRxStatus(void)                   ;
void  SPI_Master_WriteTxData(uint8 txData)  \
                                                            ;
uint8 SPI_Master_ReadRxData(void) \
                                                            ;
uint8 SPI_Master_GetRxBufferSize(void)                ;
uint8 SPI_Master_GetTxBufferSize(void)                ;
void  SPI_Master_ClearRxBuffer(void)                  ;
void  SPI_Master_ClearTxBuffer(void)                  ;
void  SPI_Master_ClearFIFO(void)                              ;
void  SPI_Master_PutArray(const uint8 buffer[], uint8 byteCount) \
                                                            ;

#if(0u != SPI_Master_BIDIRECTIONAL_MODE)
    void  SPI_Master_TxEnable(void)                   ;
    void  SPI_Master_TxDisable(void)                  ;
#endif /* (0u != SPI_Master_BIDIRECTIONAL_MODE) */

CY_ISR_PROTO(SPI_Master_TX_ISR);
CY_ISR_PROTO(SPI_Master_RX_ISR);


/***************************************
*   Variable with external linkage
***************************************/

extern uint8 SPI_Master_initVar;


/***************************************
*           API Constants
***************************************/

#define SPI_Master_TX_ISR_NUMBER     ((uint8) (SPI_Master_TxInternalInterrupt__INTC_NUMBER))
#define SPI_Master_RX_ISR_NUMBER     ((uint8) (SPI_Master_RxInternalInterrupt__INTC_NUMBER))

#define SPI_Master_TX_ISR_PRIORITY   ((uint8) (SPI_Master_TxInternalInterrupt__INTC_PRIOR_NUM))
#define SPI_Master_RX_ISR_PRIORITY   ((uint8) (SPI_Master_RxInternalInterrupt__INTC_PRIOR_NUM))


/***************************************
*    Initial Parameter Constants
***************************************/

#define SPI_Master_INT_ON_SPI_DONE    ((uint8) (0u   << SPI_Master_STS_SPI_DONE_SHIFT))
#define SPI_Master_INT_ON_TX_EMPTY    ((uint8) (0u   << SPI_Master_STS_TX_FIFO_EMPTY_SHIFT))
#define SPI_Master_INT_ON_TX_NOT_FULL ((uint8) (0u << \
                                                                           SPI_Master_STS_TX_FIFO_NOT_FULL_SHIFT))
#define SPI_Master_INT_ON_BYTE_COMP   ((uint8) (0u  << SPI_Master_STS_BYTE_COMPLETE_SHIFT))
#define SPI_Master_INT_ON_SPI_IDLE    ((uint8) (0u   << SPI_Master_STS_SPI_IDLE_SHIFT))

/* Disable TX_NOT_FULL if software buffer is used */
#define SPI_Master_INT_ON_TX_NOT_FULL_DEF ((SPI_Master_TX_SOFTWARE_BUF_ENABLED) ? \
                                                                        (0u) : (SPI_Master_INT_ON_TX_NOT_FULL))

/* TX interrupt mask */
#define SPI_Master_TX_INIT_INTERRUPTS_MASK    (SPI_Master_INT_ON_SPI_DONE  | \
                                                     SPI_Master_INT_ON_TX_EMPTY  | \
                                                     SPI_Master_INT_ON_TX_NOT_FULL_DEF | \
                                                     SPI_Master_INT_ON_BYTE_COMP | \
                                                     SPI_Master_INT_ON_SPI_IDLE)

#define SPI_Master_INT_ON_RX_FULL         ((uint8) (0u << \
                                                                          SPI_Master_STS_RX_FIFO_FULL_SHIFT))
#define SPI_Master_INT_ON_RX_NOT_EMPTY    ((uint8) (0u << \
                                                                          SPI_Master_STS_RX_FIFO_NOT_EMPTY_SHIFT))
#define SPI_Master_INT_ON_RX_OVER         ((uint8) (0u << \
                                                                          SPI_Master_STS_RX_FIFO_OVERRUN_SHIFT))

/* RX interrupt mask */
#define SPI_Master_RX_INIT_INTERRUPTS_MASK    (SPI_Master_INT_ON_RX_FULL      | \
                                                     SPI_Master_INT_ON_RX_NOT_EMPTY | \
                                                     SPI_Master_INT_ON_RX_OVER)
/* Nubmer of bits to receive/transmit */
#define SPI_Master_BITCTR_INIT            (((uint8) (SPI_Master_DATA_WIDTH << 1u)) - 1u)


/***************************************
*             Registers
***************************************/
#if(CY_PSOC3 || CY_PSOC5)
    #define SPI_Master_TXDATA_REG (* (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F0_REG)
    #define SPI_Master_TXDATA_PTR (  (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F0_REG)
    #define SPI_Master_RXDATA_REG (* (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F1_REG)
    #define SPI_Master_RXDATA_PTR (  (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F1_REG)
#else   /* PSOC4 */
    #if(SPI_Master_USE_SECOND_DATAPATH)
        #define SPI_Master_TXDATA_REG (* (reg16 *) \
                                          SPI_Master_BSPIM_sR8_Dp_u0__16BIT_F0_REG)
        #define SPI_Master_TXDATA_PTR (  (reg16 *) \
                                          SPI_Master_BSPIM_sR8_Dp_u0__16BIT_F0_REG)
        #define SPI_Master_RXDATA_REG (* (reg16 *) \
                                          SPI_Master_BSPIM_sR8_Dp_u0__16BIT_F1_REG)
        #define SPI_Master_RXDATA_PTR (  (reg16 *) \
                                          SPI_Master_BSPIM_sR8_Dp_u0__16BIT_F1_REG)
    #else
        #define SPI_Master_TXDATA_REG (* (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F0_REG)
        #define SPI_Master_TXDATA_PTR (  (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F0_REG)
        #define SPI_Master_RXDATA_REG (* (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F1_REG)
        #define SPI_Master_RXDATA_PTR (  (reg8 *) \
                                                SPI_Master_BSPIM_sR8_Dp_u0__F1_REG)
    #endif /* (SPI_Master_USE_SECOND_DATAPATH) */
#endif     /* (CY_PSOC3 || CY_PSOC5) */

#define SPI_Master_AUX_CONTROL_DP0_REG (* (reg8 *) \
                                        SPI_Master_BSPIM_sR8_Dp_u0__DP_AUX_CTL_REG)
#define SPI_Master_AUX_CONTROL_DP0_PTR (  (reg8 *) \
                                        SPI_Master_BSPIM_sR8_Dp_u0__DP_AUX_CTL_REG)

#if(SPI_Master_USE_SECOND_DATAPATH)
    #define SPI_Master_AUX_CONTROL_DP1_REG  (* (reg8 *) \
                                        SPI_Master_BSPIM_sR8_Dp_u1__DP_AUX_CTL_REG)
    #define SPI_Master_AUX_CONTROL_DP1_PTR  (  (reg8 *) \
                                        SPI_Master_BSPIM_sR8_Dp_u1__DP_AUX_CTL_REG)
#endif /* (SPI_Master_USE_SECOND_DATAPATH) */

#define SPI_Master_COUNTER_PERIOD_REG     (* (reg8 *) SPI_Master_BSPIM_BitCounter__PERIOD_REG)
#define SPI_Master_COUNTER_PERIOD_PTR     (  (reg8 *) SPI_Master_BSPIM_BitCounter__PERIOD_REG)
#define SPI_Master_COUNTER_CONTROL_REG    (* (reg8 *) SPI_Master_BSPIM_BitCounter__CONTROL_AUX_CTL_REG)
#define SPI_Master_COUNTER_CONTROL_PTR    (  (reg8 *) SPI_Master_BSPIM_BitCounter__CONTROL_AUX_CTL_REG)

#define SPI_Master_TX_STATUS_REG          (* (reg8 *) SPI_Master_BSPIM_TxStsReg__STATUS_REG)
#define SPI_Master_TX_STATUS_PTR          (  (reg8 *) SPI_Master_BSPIM_TxStsReg__STATUS_REG)
#define SPI_Master_RX_STATUS_REG          (* (reg8 *) SPI_Master_BSPIM_RxStsReg__STATUS_REG)
#define SPI_Master_RX_STATUS_PTR          (  (reg8 *) SPI_Master_BSPIM_RxStsReg__STATUS_REG)

#define SPI_Master_CONTROL_REG            (* (reg8 *) \
                                      SPI_Master_BSPIM_BidirMode_CtrlReg__CONTROL_REG)
#define SPI_Master_CONTROL_PTR            (  (reg8 *) \
                                      SPI_Master_BSPIM_BidirMode_CtrlReg__CONTROL_REG)

#define SPI_Master_TX_STATUS_MASK_REG     (* (reg8 *) SPI_Master_BSPIM_TxStsReg__MASK_REG)
#define SPI_Master_TX_STATUS_MASK_PTR     (  (reg8 *) SPI_Master_BSPIM_TxStsReg__MASK_REG)
#define SPI_Master_RX_STATUS_MASK_REG     (* (reg8 *) SPI_Master_BSPIM_RxStsReg__MASK_REG)
#define SPI_Master_RX_STATUS_MASK_PTR     (  (reg8 *) SPI_Master_BSPIM_RxStsReg__MASK_REG)

#define SPI_Master_TX_STATUS_ACTL_REG     (* (reg8 *) SPI_Master_BSPIM_TxStsReg__STATUS_AUX_CTL_REG)
#define SPI_Master_TX_STATUS_ACTL_PTR     (  (reg8 *) SPI_Master_BSPIM_TxStsReg__STATUS_AUX_CTL_REG)
#define SPI_Master_RX_STATUS_ACTL_REG     (* (reg8 *) SPI_Master_BSPIM_RxStsReg__STATUS_AUX_CTL_REG)
#define SPI_Master_RX_STATUS_ACTL_PTR     (  (reg8 *) SPI_Master_BSPIM_RxStsReg__STATUS_AUX_CTL_REG)

#if(SPI_Master_USE_SECOND_DATAPATH)
    #define SPI_Master_AUX_CONTROLDP1     (SPI_Master_AUX_CONTROL_DP1_REG)
#endif /* (SPI_Master_USE_SECOND_DATAPATH) */


/***************************************
*       Register Constants
***************************************/

/* Status Register Definitions */
#define SPI_Master_STS_SPI_DONE_SHIFT             (0x00u)
#define SPI_Master_STS_TX_FIFO_EMPTY_SHIFT        (0x01u)
#define SPI_Master_STS_TX_FIFO_NOT_FULL_SHIFT     (0x02u)
#define SPI_Master_STS_BYTE_COMPLETE_SHIFT        (0x03u)
#define SPI_Master_STS_SPI_IDLE_SHIFT             (0x04u)
#define SPI_Master_STS_RX_FIFO_FULL_SHIFT         (0x04u)
#define SPI_Master_STS_RX_FIFO_NOT_EMPTY_SHIFT    (0x05u)
#define SPI_Master_STS_RX_FIFO_OVERRUN_SHIFT      (0x06u)

#define SPI_Master_STS_SPI_DONE           ((uint8) (0x01u << SPI_Master_STS_SPI_DONE_SHIFT))
#define SPI_Master_STS_TX_FIFO_EMPTY      ((uint8) (0x01u << SPI_Master_STS_TX_FIFO_EMPTY_SHIFT))
#define SPI_Master_STS_TX_FIFO_NOT_FULL   ((uint8) (0x01u << SPI_Master_STS_TX_FIFO_NOT_FULL_SHIFT))
#define SPI_Master_STS_BYTE_COMPLETE      ((uint8) (0x01u << SPI_Master_STS_BYTE_COMPLETE_SHIFT))
#define SPI_Master_STS_SPI_IDLE           ((uint8) (0x01u << SPI_Master_STS_SPI_IDLE_SHIFT))
#define SPI_Master_STS_RX_FIFO_FULL       ((uint8) (0x01u << SPI_Master_STS_RX_FIFO_FULL_SHIFT))
#define SPI_Master_STS_RX_FIFO_NOT_EMPTY  ((uint8) (0x01u << SPI_Master_STS_RX_FIFO_NOT_EMPTY_SHIFT))
#define SPI_Master_STS_RX_FIFO_OVERRUN    ((uint8) (0x01u << SPI_Master_STS_RX_FIFO_OVERRUN_SHIFT))

/* TX and RX masks for clear on read bits */
#define SPI_Master_TX_STS_CLR_ON_RD_BYTES_MASK    (0x09u)
#define SPI_Master_RX_STS_CLR_ON_RD_BYTES_MASK    (0x40u)

/* StatusI Register Interrupt Enable Control Bits */
/* As defined by the Register map for the AUX Control Register */
#define SPI_Master_INT_ENABLE     (0x10u) /* Enable interrupt from statusi */
#define SPI_Master_TX_FIFO_CLR    (0x01u) /* F0 - TX FIFO */
#define SPI_Master_RX_FIFO_CLR    (0x02u) /* F1 - RX FIFO */
#define SPI_Master_FIFO_CLR       (SPI_Master_TX_FIFO_CLR | SPI_Master_RX_FIFO_CLR)

/* Bit Counter (7-bit) Control Register Bit Definitions */
/* As defined by the Register map for the AUX Control Register */
#define SPI_Master_CNTR_ENABLE    (0x20u) /* Enable CNT7 */

/* Bi-Directional mode control bit */
#define SPI_Master_CTRL_TX_SIGNAL_EN  (0x01u)

/* Datapath Auxillary Control Register definitions */
#define SPI_Master_AUX_CTRL_FIFO0_CLR         (0x01u)
#define SPI_Master_AUX_CTRL_FIFO1_CLR         (0x02u)
#define SPI_Master_AUX_CTRL_FIFO0_LVL         (0x04u)
#define SPI_Master_AUX_CTRL_FIFO1_LVL         (0x08u)
#define SPI_Master_STATUS_ACTL_INT_EN_MASK    (0x10u)

/* Component disabled */
#define SPI_Master_DISABLED   (0u)


/***************************************
*       Macros
***************************************/

/* Returns true if componentn enabled */
#define SPI_Master_IS_ENABLED (0u != (SPI_Master_TX_STATUS_ACTL_REG & SPI_Master_INT_ENABLE))

/* Retuns TX status register */
#define SPI_Master_GET_STATUS_TX(swTxSts) ( (uint8)(SPI_Master_TX_STATUS_REG | \
                                                          ((swTxSts) & SPI_Master_TX_STS_CLR_ON_RD_BYTES_MASK)) )
/* Retuns RX status register */
#define SPI_Master_GET_STATUS_RX(swRxSts) ( (uint8)(SPI_Master_RX_STATUS_REG | \
                                                          ((swRxSts) & SPI_Master_RX_STS_CLR_ON_RD_BYTES_MASK)) )


/***************************************
* The following code is DEPRECATED and 
* should not be used in new projects.
***************************************/

#define SPI_Master_WriteByte   SPI_Master_WriteTxData
#define SPI_Master_ReadByte    SPI_Master_ReadRxData
void  SPI_Master_SetInterruptMode(uint8 intSrc)       ;
uint8 SPI_Master_ReadStatus(void)                     ;
void  SPI_Master_EnableInt(void)                      ;
void  SPI_Master_DisableInt(void)                     ;

#define SPI_Master_TXDATA                 (SPI_Master_TXDATA_REG)
#define SPI_Master_RXDATA                 (SPI_Master_RXDATA_REG)
#define SPI_Master_AUX_CONTROLDP0         (SPI_Master_AUX_CONTROL_DP0_REG)
#define SPI_Master_TXBUFFERREAD           (SPI_Master_txBufferRead)
#define SPI_Master_TXBUFFERWRITE          (SPI_Master_txBufferWrite)
#define SPI_Master_RXBUFFERREAD           (SPI_Master_rxBufferRead)
#define SPI_Master_RXBUFFERWRITE          (SPI_Master_rxBufferWrite)

#define SPI_Master_COUNTER_PERIOD         (SPI_Master_COUNTER_PERIOD_REG)
#define SPI_Master_COUNTER_CONTROL        (SPI_Master_COUNTER_CONTROL_REG)
#define SPI_Master_STATUS                 (SPI_Master_TX_STATUS_REG)
#define SPI_Master_CONTROL                (SPI_Master_CONTROL_REG)
#define SPI_Master_STATUS_MASK            (SPI_Master_TX_STATUS_MASK_REG)
#define SPI_Master_STATUS_ACTL            (SPI_Master_TX_STATUS_ACTL_REG)

#define SPI_Master_INIT_INTERRUPTS_MASK  (SPI_Master_INT_ON_SPI_DONE     | \
                                                SPI_Master_INT_ON_TX_EMPTY     | \
                                                SPI_Master_INT_ON_TX_NOT_FULL_DEF  | \
                                                SPI_Master_INT_ON_RX_FULL      | \
                                                SPI_Master_INT_ON_RX_NOT_EMPTY | \
                                                SPI_Master_INT_ON_RX_OVER      | \
                                                SPI_Master_INT_ON_BYTE_COMP)
                                                
#define SPI_Master_DataWidth                  (SPI_Master_DATA_WIDTH)
#define SPI_Master_InternalClockUsed          (SPI_Master_INTERNAL_CLOCK)
#define SPI_Master_InternalTxInterruptEnabled (SPI_Master_INTERNAL_TX_INT_ENABLED)
#define SPI_Master_InternalRxInterruptEnabled (SPI_Master_INTERNAL_RX_INT_ENABLED)
#define SPI_Master_ModeUseZero                (SPI_Master_MODE_USE_ZERO)
#define SPI_Master_BidirectionalMode          (SPI_Master_BIDIRECTIONAL_MODE)
#define SPI_Master_Mode                       (SPI_Master_MODE)
#define SPI_Master_DATAWIDHT                  (SPI_Master_DATA_WIDTH)
#define SPI_Master_InternalInterruptEnabled   (0u)

#define SPI_Master_TXBUFFERSIZE   (SPI_Master_TX_BUFFER_SIZE)
#define SPI_Master_RXBUFFERSIZE   (SPI_Master_RX_BUFFER_SIZE)

#define SPI_Master_TXBUFFER       SPI_Master_txBuffer
#define SPI_Master_RXBUFFER       SPI_Master_rxBuffer

#endif /* (CY_SPIM_SPI_Master_H) */


/* [] END OF FILE */
