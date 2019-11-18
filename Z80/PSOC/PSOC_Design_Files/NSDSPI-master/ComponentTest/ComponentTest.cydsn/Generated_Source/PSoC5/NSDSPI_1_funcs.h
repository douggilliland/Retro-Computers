/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "NSDSPI_1_CTRL.h"
#include "NSDSPI_1_RX_BYTE_COUNTER.h"
#include "NSDSPI_1_RX_dma.h"
#include "NSDSPI_1_RX_DMA_ISR.h"
#include "NSDSPI_1_RX_ISR.h"
#include "NSDSPI_1_TX_dma.h"
#include "NSDSPI_1_TX_DMA_ISR.h"
#include "NSDSPI_1_UDB_defs.h"
#include "NSDSPI_1_UDB_Bit_Counter.h"

#if !defined(NSDSPI_1_FUNCS_H)
#define NSDSPI_1_FUNCS_H

uint8 NSDSPI_1_bEnableDMA;
    
/* Variable declarations for NSDSPI_RX */
/* Move these variable declarations to the top of the function */
uint8 NSDSPI_1_RX_Chan;
uint8 NSDSPI_1_RX_TD[1];

/* DMA Configuration for NSDSPI_RX */
#define NSDSPI_1_RX_BYTES_PER_BURST 1
#define NSDSPI_1_RX_REQUEST_PER_BURST 1
#define NSDSPI_1_RX_SRC_BASE (CYDEV_PERIPH_BASE)
#define NSDSPI_1_RX_DST_BASE (CYDEV_SRAM_BASE)

/* Variable declarations for NSDSPI_TX */
/* Move these variable declarations to the top of the function */
uint8 NSDSPI_1_TX_Chan;
uint8 NSDSPI_1_TX_TD[1];

/* DMA Configuration for NSDSPI_TX */
#define NSDSPI_1_TX_BYTES_PER_BURST 1
#define NSDSPI_1_TX_REQUEST_PER_BURST 1
#define NSDSPI_1_TX_SRC_BASE (CYDEV_SRAM_BASE)
#define NSDSPI_1_TX_DST_BASE (CYDEV_PERIPH_BASE)

typedef void (*NSDSPI_1_VOIDFXN)(void);
typedef void (*NSDSPI_1_PRNTFXN)(char*);
    
#define NSDSPI_1_TRANSFER_WAIT_RXISR        1
#define NSDSPI_1_TRANSFER_WAIT_RXDMAISR     2
#define NSDSPI_1_TRANSFER_WAIT_TXDMAISR     4

volatile unsigned char NSDSPI_1_g_nTransferFlags;
volatile unsigned char NSDSPI_1_g_nCtrlState;

//Start component (preferred method - this sets up the filesystem too!)
void NSDSPI_1_Start(NSDSPI_1_VOIDFXN FnSelSlowCk, NSDSPI_1_VOIDFXN FnSelFastCk, NSDSPI_1_PRNTFXN FnPrint);
//initialise component, attach ISRs, etc.
void NSDSPI_1_StartInterface(void);
//Disable component, release DMAs, stop ISRs, etc
void NSDSPI_1_Stop();

//Control the CS line
void NSDSPI_1_SelectCard();
void NSDSPI_1_DeselectCard();
//Send a block of data and discard received bytes.
void NSDSPI_1_SendData(unsigned char* pBuffer, unsigned int nLength);
//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void NSDSPI_1_ReceiveData(unsigned char* pBuffer, unsigned int nLength);
//Swap a single byte (send it, and receive RX byte)
unsigned char NSDSPI_1_SwapByte(unsigned char nByte);
//Enable / Disable DMA transfers
void SetDMAMode(unsigned char bEnableDMA);





#endif
/* [] END OF FILE */
