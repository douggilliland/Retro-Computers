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

#include "`$INSTANCE_NAME`_CTRL.h"
#include "`$INSTANCE_NAME`_RX_BYTE_COUNTER.h"
#include "`$INSTANCE_NAME`_RX_dma.h"
#include "`$INSTANCE_NAME`_RX_DMA_ISR.h"
#include "`$INSTANCE_NAME`_RX_ISR.h"
#include "`$INSTANCE_NAME`_TX_dma.h"
#include "`$INSTANCE_NAME`_TX_DMA_ISR.h"
#include "`$INSTANCE_NAME`_UDB_defs.h"
#include "`$INSTANCE_NAME`_UDB_Bit_Counter.h"

#if !defined(`$INSTANCE_NAME`_FUNCS_H)
#define `$INSTANCE_NAME`_FUNCS_H

uint8 `$INSTANCE_NAME`_bEnableDMA;
    
/* Variable declarations for NSDSPI_RX */
/* Move these variable declarations to the top of the function */
uint8 `$INSTANCE_NAME`_RX_Chan;
uint8 `$INSTANCE_NAME`_RX_TD[1];

/* DMA Configuration for NSDSPI_RX */
#define `$INSTANCE_NAME`_RX_BYTES_PER_BURST 1
#define `$INSTANCE_NAME`_RX_REQUEST_PER_BURST 1
#define `$INSTANCE_NAME`_RX_SRC_BASE (CYDEV_PERIPH_BASE)
#define `$INSTANCE_NAME`_RX_DST_BASE (CYDEV_SRAM_BASE)

/* Variable declarations for NSDSPI_TX */
/* Move these variable declarations to the top of the function */
uint8 `$INSTANCE_NAME`_TX_Chan;
uint8 `$INSTANCE_NAME`_TX_TD[1];

/* DMA Configuration for NSDSPI_TX */
#define `$INSTANCE_NAME`_TX_BYTES_PER_BURST 1
#define `$INSTANCE_NAME`_TX_REQUEST_PER_BURST 1
#define `$INSTANCE_NAME`_TX_SRC_BASE (CYDEV_SRAM_BASE)
#define `$INSTANCE_NAME`_TX_DST_BASE (CYDEV_PERIPH_BASE)

typedef void (*`$INSTANCE_NAME`_VOIDFXN)(void);
typedef void (*`$INSTANCE_NAME`_PRNTFXN)(char*);
    
#define `$INSTANCE_NAME`_TRANSFER_WAIT_RXISR        1
#define `$INSTANCE_NAME`_TRANSFER_WAIT_RXDMAISR     2
#define `$INSTANCE_NAME`_TRANSFER_WAIT_TXDMAISR     4

volatile unsigned char `$INSTANCE_NAME`_g_nTransferFlags;
volatile unsigned char `$INSTANCE_NAME`_g_nCtrlState;

//Start component (preferred method - this sets up the filesystem too!)
void `$INSTANCE_NAME`_Start(`$INSTANCE_NAME`_VOIDFXN FnSelSlowCk, `$INSTANCE_NAME`_VOIDFXN FnSelFastCk, `$INSTANCE_NAME`_PRNTFXN FnPrint);
//initialise component, attach ISRs, etc.
void `$INSTANCE_NAME`_StartInterface(void);
//Disable component, release DMAs, stop ISRs, etc
void `$INSTANCE_NAME`_Stop();

//Control the CS line
void `$INSTANCE_NAME`_SelectCard();
void `$INSTANCE_NAME`_DeselectCard();
//Send a block of data and discard received bytes.
void `$INSTANCE_NAME`_SendData(unsigned char* pBuffer, unsigned int nLength);
//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void `$INSTANCE_NAME`_ReceiveData(unsigned char* pBuffer, unsigned int nLength);
//Swap a single byte (send it, and receive RX byte)
unsigned char `$INSTANCE_NAME`_SwapByte(unsigned char nByte);
//Enable / Disable DMA transfers
void `$INSTANCE_NAME`_SetDMAMode(unsigned char bEnableDMA);





#endif
/* [] END OF FILE */
