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
#include "NSDSPI_funcs.h"
#include "NSDSPI_LowLevelFileSys.h"

//Standard (non DMA receive) ISR
void NSDSPI_RX_ISR()
{
    NSDSPI_g_nTransferFlags &= ~NSDSPI_TRANSFER_WAIT_RXISR;
    NSDSPI_RX_ISR_Disable();
}

//DMA termination ISRs
void NSDSPI_RX_DMA_ISR()
{   NSDSPI_g_nTransferFlags &= ~NSDSPI_TRANSFER_WAIT_RXDMAISR;}

void NSDSPI_TX_DMA_ISR()
{   NSDSPI_g_nTransferFlags &= ~NSDSPI_TRANSFER_WAIT_TXDMAISR;}


void NSDSPI_Start(NSDSPI_VOIDFXN FnSelSlowCk, NSDSPI_VOIDFXN FnSelFastCk, NSDSPI_PRNTFXN FnPrint)
{
    NSDSPI_bEnableDMA = 0;
    SPI_FUNCTIONS SpiFuncs;
    SpiFuncs.SPSTART = NSDSPI_StartInterface;
    SpiFuncs.SPSTOP = NSDSPI_Stop;
    SpiFuncs.SPRXSTREAM = NSDSPI_ReceiveData;
    SpiFuncs.SPTXSTREAM = NSDSPI_SendData;
    SpiFuncs.SPEXCHANGE = NSDSPI_SwapByte;
    SpiFuncs.SPSELECTCARD = NSDSPI_SelectCard;
    SpiFuncs.SPDESELECTCARD = NSDSPI_DeselectCard;
    SpiFuncs.SPFASTCK = FnSelFastCk;
    SpiFuncs.SPSLOWCK = FnSelSlowCk;

    SpiFuncs.PRINT = FnPrint;
    disk_attach_spifuncs(&SpiFuncs);   
}


//initialise component, attach ISRs, etc.
void NSDSPI_StartInterface(void)
{  
    NSDSPI_UDB_BIT_COUNTER_Start();
    NSDSPI_g_nTransferFlags = 0;
    NSDSPI_g_nCtrlState = 1;
    NSDSPI_CTRL_Write(0x05);      //reset pulse to make sure bulk receive isn't active
    NSDSPI_UDB_SPI_DPTH_F0_CLEAR;
    NSDSPI_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers
    NSDSPI_RX_BYTE_COUNTER_Start();
    
    NSDSPI_RX_ISR_StartEx(NSDSPI_RX_ISR);
    
    NSDSPI_UDB_SPI_DPTH_F0_CLEAR;
    NSDSPI_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers

    NSDSPI_SetDMAMode(1);
}



void NSDSPI_Stop()
{
    if(NSDSPI_bEnableDMA)
    {
        NSDSPI_RX_DMA_ISR_Stop();
        NSDSPI_TX_DMA_ISR_Stop();
        NSDSPI_RX_DmaRelease();
        NSDSPI_TX_DmaRelease();
    }
    NSDSPI_DeselectCard();
    NSDSPI_RX_ISR_Stop();    
    NSDSPI_RX_BYTE_COUNTER_Stop();
    NSDSPI_UDB_BIT_COUNTER_Stop();
}


void NSDSPI_SelectCard()
{
    NSDSPI_g_nCtrlState &= ~0x01;
    NSDSPI_CTRL_Write(NSDSPI_g_nCtrlState);
}

void NSDSPI_DeselectCard()
{
    NSDSPI_g_nCtrlState |= 0x01;
    NSDSPI_CTRL_Write(NSDSPI_g_nCtrlState);
}

//Send a block of data and discard received bytes.
void NSDSPI_SendData(unsigned char* pBuffer, unsigned int nLength)
{
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(NSDSPI_bEnableDMA)
    {
        //Fast (DMA) implementation...
        
        NSDSPI_TX_TD[0] = CyDmaTdAllocate();
        CyDmaTdSetConfiguration(NSDSPI_TX_TD[0], nLength, CY_DMA_DISABLE_TD, NSDSPI_TX__TD_TERMOUT_EN | TD_INC_SRC_ADR);
        CyDmaTdSetAddress(NSDSPI_TX_TD[0], LO16((uint32)pBuffer), LO16((uint32)NSDSPI_UDB_SPI_DPTH_F0_PTR));
        CyDmaChSetInitialTd(NSDSPI_TX_Chan, NSDSPI_TX_TD[0]);
    
        CyDmaClearPendingDrq(NSDSPI_TX_Chan);
        NSDSPI_g_nTransferFlags |= NSDSPI_TRANSFER_WAIT_TXDMAISR;   //set flag
        CyDmaChEnable(NSDSPI_TX_Chan, 1);         //this will start the transfer
        while(NSDSPI_g_nTransferFlags & NSDSPI_TRANSFER_WAIT_TXDMAISR); //wait for flag to clear
        
        CyDmaChSetRequest(NSDSPI_TX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(NSDSPI_TX_TD[0]);                       //Free Transfer Descriptor    
    
        NSDSPI_UDB_SPI_DPTH_F1_CLEAR;     //clear output FIFO buffer
        NSDSPI_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        NSDSPI_SwapByte(pBuffer[i]);
}

//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void NSDSPI_ReceiveData(unsigned char* pBuffer, unsigned int nLength)
{   
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(NSDSPI_bEnableDMA)
    {
        //DMA implementation...
   
        NSDSPI_RX_BYTE_COUNTER_WriteCompare(nLength-1); //write byte counter
        NSDSPI_RX_TD[0] = CyDmaTdAllocate();          //allocate a TD
       
        //setup TD and attach to channel
        CyDmaTdSetConfiguration(NSDSPI_RX_TD[0], nLength, CY_DMA_DISABLE_TD, NSDSPI_RX__TD_TERMOUT_EN | TD_INC_DST_ADR);
        CyDmaTdSetAddress(NSDSPI_RX_TD[0], LO16((uint32)NSDSPI_UDB_SPI_DPTH_F1_PTR), LO16((uint32)pBuffer));
        CyDmaChSetInitialTd(NSDSPI_RX_Chan, NSDSPI_RX_TD[0]);
        
        CyDmaClearPendingDrq(NSDSPI_RX_Chan);
        CyDmaChEnable(NSDSPI_RX_Chan, 1);
    
        NSDSPI_g_nTransferFlags |= NSDSPI_TRANSFER_WAIT_RXDMAISR;   //Set flag
        
        NSDSPI_CTRL_Write(NSDSPI_g_nCtrlState | 0x02);  //trigger transfer
        
        //wait until done.
        while(NSDSPI_g_nTransferFlags & NSDSPI_TRANSFER_WAIT_RXDMAISR);
        
        CyDmaChSetRequest(NSDSPI_RX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(NSDSPI_RX_TD[0]);                       //Free Transfer Descriptor    
        
        NSDSPI_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }    
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        pBuffer[i] = NSDSPI_SwapByte(0xFF);    
        
}

//Swap a single byte (send it, and receive RX byte)
unsigned char NSDSPI_SwapByte(unsigned char nByte)
{
    NSDSPI_RX_ISR_Enable();   //will be disabled after being triggered
    //Set waiting flag...
    NSDSPI_g_nTransferFlags |= NSDSPI_TRANSFER_WAIT_RXISR;
    //write byte to TX
    CY_SET_REG8(NSDSPI_UDB_SPI_DPTH_F0_PTR, nByte);
    //wait for RX interrupt
    while(NSDSPI_g_nTransferFlags & NSDSPI_TRANSFER_WAIT_RXISR);
    //read byte from RX
    unsigned char rv = CY_GET_REG8(NSDSPI_UDB_SPI_DPTH_F1_PTR);
    //return byte
    return rv;
}
void NSDSPI_SetDMAMode(unsigned char bEnableDMA)
{
    while(NSDSPI_g_nTransferFlags);   //make absolutely sure no transfers are in progress
    
    if(NSDSPI_bEnableDMA == bEnableDMA) return;
    
    if(bEnableDMA)
    {
        NSDSPI_RX_DMA_ISR_StartEx(NSDSPI_RX_DMA_ISR);
        NSDSPI_TX_DMA_ISR_StartEx(NSDSPI_TX_DMA_ISR);
        NSDSPI_RX_Chan = NSDSPI_RX_DmaInitialize(NSDSPI_RX_BYTES_PER_BURST, NSDSPI_RX_REQUEST_PER_BURST, 
            HI16(NSDSPI_RX_SRC_BASE), HI16(NSDSPI_RX_DST_BASE));
        NSDSPI_TX_Chan = NSDSPI_TX_DmaInitialize(NSDSPI_TX_BYTES_PER_BURST, NSDSPI_TX_REQUEST_PER_BURST, 
            HI16(NSDSPI_TX_SRC_BASE), HI16(NSDSPI_TX_DST_BASE));
        CyDmaClearPendingDrq(NSDSPI_RX_Chan);
        CyDmaClearPendingDrq(NSDSPI_TX_Chan);    
    }
    else
    {
        NSDSPI_RX_DMA_ISR_Stop();
        NSDSPI_TX_DMA_ISR_Stop();
        NSDSPI_RX_DmaRelease();
        NSDSPI_TX_DmaRelease();
    }
    NSDSPI_bEnableDMA = bEnableDMA;
}

/* [] END OF FILE */
