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

#include "NSDSPI_CTRL.h"
#include "NSDSPI_RX_BYTE_COUNTER.h"
#include "NSDSPI_RX_dma.h"
#include "NSDSPI_RX_DMA_ISR.h"
#include "NSDSPI_RX_ISR.h"
#include "NSDSPI_TX_dma.h"
#include "NSDSPI_TX_DMA_ISR.h"
#include "NSDSPI_UDB_defs.h"
#include "NSDSPI_UDB_Bit_Counter.h"

#if !defined(NSDSPI_FUNCS_H)
#define NSDSPI_FUNCS_H

uint8 NSDSPI_bEnableDMA;
    
/* Variable declarations for NSDSPI_RX */
/* Move these variable declarations to the top of the function */
uint8 NSDSPI_RX_Chan;
uint8 NSDSPI_RX_TD[1];

/* DMA Configuration for NSDSPI_RX */
#define NSDSPI_RX_BYTES_PER_BURST 1
#define NSDSPI_RX_REQUEST_PER_BURST 1
#define NSDSPI_RX_SRC_BASE (CYDEV_PERIPH_BASE)
#define NSDSPI_RX_DST_BASE (CYDEV_SRAM_BASE)

/* Variable declarations for NSDSPI_TX */
/* Move these variable declarations to the top of the function */
uint8 NSDSPI_TX_Chan;
uint8 NSDSPI_TX_TD[1];

/* DMA Configuration for NSDSPI_TX */
#define NSDSPI_TX_BYTES_PER_BURST 1
#define NSDSPI_TX_REQUEST_PER_BURST 1
#define NSDSPI_TX_SRC_BASE (CYDEV_SRAM_BASE)
#define NSDSPI_TX_DST_BASE (CYDEV_PERIPH_BASE)

typedef void (*NSDSPI_VOIDFXN)(void);
typedef void (*NSDSPI_PRNTFXN)(char*);
    
#define NSDSPI_TRANSFER_WAIT_RXISR        1
#define NSDSPI_TRANSFER_WAIT_RXDMAISR     2
#define NSDSPI_TRANSFER_WAIT_TXDMAISR     4

volatile unsigned char NSDSPI_g_nTransferFlags;
volatile unsigned char NSDSPI_g_nCtrlState;

//Start component (preferred method - this sets up the filesystem too!)
void NSDSPI_Start(NSDSPI_VOIDFXN FnSelSlowCk, NSDSPI_VOIDFXN FnSelFastCk, NSDSPI_PRNTFXN FnPrint);
//initialise component, attach ISRs, etc.
void NSDSPI_StartInterface(void);
//Disable component, release DMAs, stop ISRs, etc
void NSDSPI_Stop();

//Control the CS line
void NSDSPI_SelectCard();
void NSDSPI_DeselectCard();
//Send a block of data and discard received bytes.
void NSDSPI_SendData(unsigned char* pBuffer, unsigned int nLength);
//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void NSDSPI_ReceiveData(unsigned char* pBuffer, unsigned int nLength);
//Swap a single byte (send it, and receive RX byte)
unsigned char NSDSPI_SwapByte(unsigned char nByte);
//Enable / Disable DMA transfers
void NSDSPI_SetDMAMode(unsigned char bEnableDMA);





#endif
/* [] END OF FILE */
