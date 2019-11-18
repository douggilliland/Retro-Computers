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
#include "NSDSPI_1_funcs.h"
#include "NSDSPI_1_LowLevelFileSys.h"

//Standard (non DMA receive) ISR
void NSDSPI_1_RX_ISR()
{
    NSDSPI_1_g_nTransferFlags &= ~NSDSPI_1_TRANSFER_WAIT_RXISR;
    NSDSPI_1_RX_ISR_Disable();
}

//DMA termination ISRs
void NSDSPI_1_RX_DMA_ISR()
{   NSDSPI_1_g_nTransferFlags &= ~NSDSPI_1_TRANSFER_WAIT_RXDMAISR;}

void NSDSPI_1_TX_DMA_ISR()
{   NSDSPI_1_g_nTransferFlags &= ~NSDSPI_1_TRANSFER_WAIT_TXDMAISR;}


void NSDSPI_1_Start(NSDSPI_1_VOIDFXN FnSelSlowCk, NSDSPI_1_VOIDFXN FnSelFastCk, NSDSPI_1_PRNTFXN FnPrint)
{
    SPI_FUNCTIONS SpiFuncs;
    SpiFuncs.SPSTART = NSDSPI_1_StartInterface;
    SpiFuncs.SPSTOP = NSDSPI_1_Stop;
    SpiFuncs.SPRXSTREAM = NSDSPI_1_ReceiveData;
    SpiFuncs.SPTXSTREAM = NSDSPI_1_SendData;
    SpiFuncs.SPEXCHANGE = NSDSPI_1_SwapByte;
    SpiFuncs.SPSELECTCARD = NSDSPI_1_SelectCard;
    SpiFuncs.SPDESELECTCARD = NSDSPI_1_DeselectCard;
    SpiFuncs.SPFASTCK = FnSelFastCk;
    SpiFuncs.SPSLOWCK = FnSelSlowCk;

    SpiFuncs.PRINT = FnPrint;
    disk_attach_spifuncs(&SpiFuncs);
    
}


//initialise component, attach ISRs, etc.
void NSDSPI_1_StartInterface(void)
{
    NSDSPI_1_bEnableDMA = 0;
    
    NSDSPI_1_UDB_BIT_COUNTER_Start();
    NSDSPI_1_g_nTransferFlags = 0;
    NSDSPI_1_g_nCtrlState = 1;
    NSDSPI_1_CTRL_Write(0x05);      //reset pulse to make sure bulk receive isn't active
    NSDSPI_1_UDB_SPI_DPTH_F0_CLEAR;
    NSDSPI_1_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers
    NSDSPI_1_RX_BYTE_COUNTER_Start();
    
    NSDSPI_1_RX_ISR_StartEx(NSDSPI_1_RX_ISR);
    

    NSDSPI_1_UDB_SPI_DPTH_F0_CLEAR;
    NSDSPI_1_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers

}



void NSDSPI_1_Stop()
{
    if(NSDSPI_1_bEnableDMA)
    {
        NSDSPI_1_RX_DMA_ISR_Stop();
        NSDSPI_1_TX_DMA_ISR_Stop();
        NSDSPI_1_RX_DmaRelease();
        NSDSPI_1_TX_DmaRelease();
    }
    NSDSPI_1_DeselectCard();
    NSDSPI_1_RX_ISR_Stop();    
    NSDSPI_1_RX_BYTE_COUNTER_Stop();
    NSDSPI_1_UDB_BIT_COUNTER_Stop();
}


void NSDSPI_1_SelectCard()
{
    NSDSPI_1_g_nCtrlState &= ~0x01;
    NSDSPI_1_CTRL_Write(NSDSPI_1_g_nCtrlState);
}

void NSDSPI_1_DeselectCard()
{
    NSDSPI_1_g_nCtrlState |= 0x01;
    NSDSPI_1_CTRL_Write(NSDSPI_1_g_nCtrlState);
}

//Send a block of data and discard received bytes.
void NSDSPI_1_SendData(unsigned char* pBuffer, unsigned int nLength)
{
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(NSDSPI_1_bEnableDMA)
    {
        //Fast (DMA) implementation...
        
        NSDSPI_1_TX_TD[0] = CyDmaTdAllocate();
        CyDmaTdSetConfiguration(NSDSPI_1_TX_TD[0], nLength, CY_DMA_DISABLE_TD, NSDSPI_1_TX__TD_TERMOUT_EN | TD_INC_SRC_ADR);
        CyDmaTdSetAddress(NSDSPI_1_TX_TD[0], LO16((uint32)pBuffer), LO16((uint32)NSDSPI_1_UDB_SPI_DPTH_F0_PTR));
        CyDmaChSetInitialTd(NSDSPI_1_TX_Chan, NSDSPI_1_TX_TD[0]);
    
        CyDmaClearPendingDrq(NSDSPI_1_TX_Chan);
        NSDSPI_1_g_nTransferFlags |= NSDSPI_1_TRANSFER_WAIT_TXDMAISR;   //set flag
        CyDmaChEnable(NSDSPI_1_TX_Chan, 1);         //this will start the transfer
        while(NSDSPI_1_g_nTransferFlags & NSDSPI_1_TRANSFER_WAIT_TXDMAISR); //wait for flag to clear
        
        CyDmaChSetRequest(NSDSPI_1_TX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(NSDSPI_1_TX_TD[0]);                       //Free Transfer Descriptor    
    
        NSDSPI_1_UDB_SPI_DPTH_F1_CLEAR;     //clear output FIFO buffer
        NSDSPI_1_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        NSDSPI_1_SwapByte(pBuffer[i]);
}

//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void NSDSPI_1_ReceiveData(unsigned char* pBuffer, unsigned int nLength)
{   
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(NSDSPI_1_bEnableDMA)
    {
        //DMA implementation...
   
        NSDSPI_1_RX_BYTE_COUNTER_WriteCompare(nLength-1); //write byte counter
        NSDSPI_1_RX_TD[0] = CyDmaTdAllocate();          //allocate a TD
       
        //setup TD and attach to channel
        CyDmaTdSetConfiguration(NSDSPI_1_RX_TD[0], nLength, CY_DMA_DISABLE_TD, NSDSPI_1_RX__TD_TERMOUT_EN | TD_INC_DST_ADR);
        CyDmaTdSetAddress(NSDSPI_1_RX_TD[0], LO16((uint32)NSDSPI_1_UDB_SPI_DPTH_F1_PTR), LO16((uint32)pBuffer));
        CyDmaChSetInitialTd(NSDSPI_1_RX_Chan, NSDSPI_1_RX_TD[0]);
        
        CyDmaClearPendingDrq(NSDSPI_1_RX_Chan);
        CyDmaChEnable(NSDSPI_1_RX_Chan, 1);
    
        NSDSPI_1_g_nTransferFlags |= NSDSPI_1_TRANSFER_WAIT_RXDMAISR;   //Set flag
        
        NSDSPI_1_CTRL_Write(NSDSPI_1_g_nCtrlState | 0x02);  //trigger transfer
        
        //wait until done.
        while(NSDSPI_1_g_nTransferFlags & NSDSPI_1_TRANSFER_WAIT_RXDMAISR);
        
        CyDmaChSetRequest(NSDSPI_1_RX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(NSDSPI_1_RX_TD[0]);                       //Free Transfer Descriptor    
        
        NSDSPI_1_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }    
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        pBuffer[i] = NSDSPI_1_SwapByte(0xFF);    
        
}

//Swap a single byte (send it, and receive RX byte)
unsigned char NSDSPI_1_SwapByte(unsigned char nByte)
{
    NSDSPI_1_RX_ISR_Enable();   //will be disabled after being triggered
    //Set waiting flag...
    NSDSPI_1_g_nTransferFlags |= NSDSPI_1_TRANSFER_WAIT_RXISR;
    //write byte to TX
    CY_SET_REG8(NSDSPI_1_UDB_SPI_DPTH_F0_PTR, nByte);
    //wait for RX interrupt
    while(NSDSPI_1_g_nTransferFlags & NSDSPI_1_TRANSFER_WAIT_RXISR);
    //read byte from RX
    unsigned char rv = CY_GET_REG8(NSDSPI_1_UDB_SPI_DPTH_F1_PTR);
    //return byte
    return rv;
}
void NSDSPI_1_SetDMAMode(unsigned char bEnableDMA)
{
    while(NSDSPI_1_g_nTransferFlags);   //make absolutely sure no transfers are in progress
    
    if(NSDSPI_1_bEnableDMA == bEnableDMA) return;
    
    if(bEnableDMA)
    {
        NSDSPI_1_RX_DMA_ISR_StartEx(NSDSPI_1_RX_DMA_ISR);
        NSDSPI_1_TX_DMA_ISR_StartEx(NSDSPI_1_TX_DMA_ISR);
        NSDSPI_1_RX_Chan = NSDSPI_RX_DmaInitialize(NSDSPI_1_RX_BYTES_PER_BURST, NSDSPI_1_RX_REQUEST_PER_BURST, 
            HI16(NSDSPI_1_RX_SRC_BASE), HI16(NSDSPI_1_RX_DST_BASE));
        NSDSPI_1_TX_Chan = NSDSPI_1_TX_DmaInitialize(NSDSPI_1_TX_BYTES_PER_BURST, NSDSPI_1_TX_REQUEST_PER_BURST, 
            HI16(NSDSPI_1_TX_SRC_BASE), HI16(NSDSPI_1_TX_DST_BASE));
        CyDmaClearPendingDrq(NSDSPI_1_RX_Chan);
        CyDmaClearPendingDrq(NSDSPI_1_TX_Chan);    
    }
    else
    {
        NSDSPI_1_RX_DMA_ISR_Stop();
        NSDSPI_1_TX_DMA_ISR_Stop();
        NSDSPI_1_RX_DmaRelease();
        NSDSPI_1_TX_DmaRelease();
    }
    NSDSPI_1_bEnableDMA = bEnableDMA;
}

/* [] END OF FILE */
