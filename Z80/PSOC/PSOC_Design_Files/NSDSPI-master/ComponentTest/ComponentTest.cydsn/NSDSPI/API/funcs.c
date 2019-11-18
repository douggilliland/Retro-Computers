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
#include "`$INSTANCE_NAME`_funcs.h"
#include "`$INSTANCE_NAME`_LowLevelFileSys.h"

//Standard (non DMA receive) ISR
void `$INSTANCE_NAME`_RX_ISR()
{
    `$INSTANCE_NAME`_g_nTransferFlags &= ~`$INSTANCE_NAME`_TRANSFER_WAIT_RXISR;
    `$INSTANCE_NAME`_RX_ISR_Disable();
}

//DMA termination ISRs
void `$INSTANCE_NAME`_RX_DMA_ISR()
{   `$INSTANCE_NAME`_g_nTransferFlags &= ~`$INSTANCE_NAME`_TRANSFER_WAIT_RXDMAISR;}

void `$INSTANCE_NAME`_TX_DMA_ISR()
{   `$INSTANCE_NAME`_g_nTransferFlags &= ~`$INSTANCE_NAME`_TRANSFER_WAIT_TXDMAISR;}


void `$INSTANCE_NAME`_Start(`$INSTANCE_NAME`_VOIDFXN FnSelSlowCk, `$INSTANCE_NAME`_VOIDFXN FnSelFastCk, `$INSTANCE_NAME`_PRNTFXN FnPrint)
{
    `$INSTANCE_NAME`_bEnableDMA = 0;
    SPI_FUNCTIONS SpiFuncs;
    SpiFuncs.SPSTART = `$INSTANCE_NAME`_StartInterface;
    SpiFuncs.SPSTOP = `$INSTANCE_NAME`_Stop;
    SpiFuncs.SPRXSTREAM = `$INSTANCE_NAME`_ReceiveData;
    SpiFuncs.SPTXSTREAM = `$INSTANCE_NAME`_SendData;
    SpiFuncs.SPEXCHANGE = `$INSTANCE_NAME`_SwapByte;
    SpiFuncs.SPSELECTCARD = `$INSTANCE_NAME`_SelectCard;
    SpiFuncs.SPDESELECTCARD = `$INSTANCE_NAME`_DeselectCard;
    SpiFuncs.SPFASTCK = FnSelFastCk;
    SpiFuncs.SPSLOWCK = FnSelSlowCk;

    SpiFuncs.PRINT = FnPrint;
    disk_attach_spifuncs(&SpiFuncs);   
}


//initialise component, attach ISRs, etc.
void `$INSTANCE_NAME`_StartInterface(void)
{  
    `$INSTANCE_NAME`_UDB_BIT_COUNTER_Start();
    `$INSTANCE_NAME`_g_nTransferFlags = 0;
    `$INSTANCE_NAME`_g_nCtrlState = 1;
    `$INSTANCE_NAME`_CTRL_Write(0x05);      //reset pulse to make sure bulk receive isn't active
    `$INSTANCE_NAME`_UDB_SPI_DPTH_F0_CLEAR;
    `$INSTANCE_NAME`_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers
    `$INSTANCE_NAME`_RX_BYTE_COUNTER_Start();
    
    `$INSTANCE_NAME`_RX_ISR_StartEx(`$INSTANCE_NAME`_RX_ISR);
    
    `$INSTANCE_NAME`_UDB_SPI_DPTH_F0_CLEAR;
    `$INSTANCE_NAME`_UDB_SPI_DPTH_F1_CLEAR;     //clear FIFO buffers

    `$INSTANCE_NAME`_SetDMAMode(1);
}



void `$INSTANCE_NAME`_Stop()
{
    if(`$INSTANCE_NAME`_bEnableDMA)
    {
        `$INSTANCE_NAME`_RX_DMA_ISR_Stop();
        `$INSTANCE_NAME`_TX_DMA_ISR_Stop();
        `$INSTANCE_NAME`_RX_DmaRelease();
        `$INSTANCE_NAME`_TX_DmaRelease();
    }
    `$INSTANCE_NAME`_DeselectCard();
    `$INSTANCE_NAME`_RX_ISR_Stop();    
    `$INSTANCE_NAME`_RX_BYTE_COUNTER_Stop();
    `$INSTANCE_NAME`_UDB_BIT_COUNTER_Stop();
}


void `$INSTANCE_NAME`_SelectCard()
{
    `$INSTANCE_NAME`_g_nCtrlState &= ~0x01;
    `$INSTANCE_NAME`_CTRL_Write(`$INSTANCE_NAME`_g_nCtrlState);
}

void `$INSTANCE_NAME`_DeselectCard()
{
    `$INSTANCE_NAME`_g_nCtrlState |= 0x01;
    `$INSTANCE_NAME`_CTRL_Write(`$INSTANCE_NAME`_g_nCtrlState);
}

//Send a block of data and discard received bytes.
void `$INSTANCE_NAME`_SendData(unsigned char* pBuffer, unsigned int nLength)
{
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(`$INSTANCE_NAME`_bEnableDMA)
    {
        //Fast (DMA) implementation...
        
        `$INSTANCE_NAME`_TX_TD[0] = CyDmaTdAllocate();
        CyDmaTdSetConfiguration(`$INSTANCE_NAME`_TX_TD[0], nLength, CY_DMA_DISABLE_TD, `$INSTANCE_NAME`_TX__TD_TERMOUT_EN | TD_INC_SRC_ADR);
        CyDmaTdSetAddress(`$INSTANCE_NAME`_TX_TD[0], LO16((uint32)pBuffer), LO16((uint32)`$INSTANCE_NAME`_UDB_SPI_DPTH_F0_PTR));
        CyDmaChSetInitialTd(`$INSTANCE_NAME`_TX_Chan, `$INSTANCE_NAME`_TX_TD[0]);
    
        CyDmaClearPendingDrq(`$INSTANCE_NAME`_TX_Chan);
        `$INSTANCE_NAME`_g_nTransferFlags |= `$INSTANCE_NAME`_TRANSFER_WAIT_TXDMAISR;   //set flag
        CyDmaChEnable(`$INSTANCE_NAME`_TX_Chan, 1);         //this will start the transfer
        while(`$INSTANCE_NAME`_g_nTransferFlags & `$INSTANCE_NAME`_TRANSFER_WAIT_TXDMAISR); //wait for flag to clear
        
        CyDmaChSetRequest(`$INSTANCE_NAME`_TX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(`$INSTANCE_NAME`_TX_TD[0]);                       //Free Transfer Descriptor    
    
        `$INSTANCE_NAME`_UDB_SPI_DPTH_F1_CLEAR;     //clear output FIFO buffer
        `$INSTANCE_NAME`_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        `$INSTANCE_NAME`_SwapByte(pBuffer[i]);
}

//Send a block of NULL data (default 0xFF) and place received bytes into buffer.
void `$INSTANCE_NAME`_ReceiveData(unsigned char* pBuffer, unsigned int nLength)
{   
    if((nLength > 4095)||(nLength < 1))
        return; //this never happens - filesys transfers max. 512 bytes at a time
    if(`$INSTANCE_NAME`_bEnableDMA)
    {
        //DMA implementation...
   
        `$INSTANCE_NAME`_RX_BYTE_COUNTER_WriteCompare(nLength-1); //write byte counter
        `$INSTANCE_NAME`_RX_TD[0] = CyDmaTdAllocate();          //allocate a TD
       
        //setup TD and attach to channel
        CyDmaTdSetConfiguration(`$INSTANCE_NAME`_RX_TD[0], nLength, CY_DMA_DISABLE_TD, `$INSTANCE_NAME`_RX__TD_TERMOUT_EN | TD_INC_DST_ADR);
        CyDmaTdSetAddress(`$INSTANCE_NAME`_RX_TD[0], LO16((uint32)`$INSTANCE_NAME`_UDB_SPI_DPTH_F1_PTR), LO16((uint32)pBuffer));
        CyDmaChSetInitialTd(`$INSTANCE_NAME`_RX_Chan, `$INSTANCE_NAME`_RX_TD[0]);
        
        CyDmaClearPendingDrq(`$INSTANCE_NAME`_RX_Chan);
        CyDmaChEnable(`$INSTANCE_NAME`_RX_Chan, 1);
    
        `$INSTANCE_NAME`_g_nTransferFlags |= `$INSTANCE_NAME`_TRANSFER_WAIT_RXDMAISR;   //Set flag
        
        `$INSTANCE_NAME`_CTRL_Write(`$INSTANCE_NAME`_g_nCtrlState | 0x02);  //trigger transfer
        
        //wait until done.
        while(`$INSTANCE_NAME`_g_nTransferFlags & `$INSTANCE_NAME`_TRANSFER_WAIT_RXDMAISR);
        
        CyDmaChSetRequest(`$INSTANCE_NAME`_RX_Chan, CPU_TERM_CHAIN);
        CyDmaTdFree(`$INSTANCE_NAME`_RX_TD[0]);                       //Free Transfer Descriptor    
        
        `$INSTANCE_NAME`_RX_ISR_ClearPending(); //clear pending interrupt from RX_ISR (non-DMA)
        return;
    }    
    
    //Slow (non DMA) implementation...
    unsigned int i;
    for(i = 0; i < nLength; i++)
        pBuffer[i] = `$INSTANCE_NAME`_SwapByte(0xFF);    
        
}

//Swap a single byte (send it, and receive RX byte)
unsigned char `$INSTANCE_NAME`_SwapByte(unsigned char nByte)
{
    `$INSTANCE_NAME`_RX_ISR_Enable();   //will be disabled after being triggered
    //Set waiting flag...
    `$INSTANCE_NAME`_g_nTransferFlags |= `$INSTANCE_NAME`_TRANSFER_WAIT_RXISR;
    //write byte to TX
    CY_SET_REG8(`$INSTANCE_NAME`_UDB_SPI_DPTH_F0_PTR, nByte);
    //wait for RX interrupt
    while(`$INSTANCE_NAME`_g_nTransferFlags & `$INSTANCE_NAME`_TRANSFER_WAIT_RXISR);
    //read byte from RX
    unsigned char rv = CY_GET_REG8(`$INSTANCE_NAME`_UDB_SPI_DPTH_F1_PTR);
    //return byte
    return rv;
}
void `$INSTANCE_NAME`_SetDMAMode(unsigned char bEnableDMA)
{
    while(`$INSTANCE_NAME`_g_nTransferFlags);   //make absolutely sure no transfers are in progress
    
    if(`$INSTANCE_NAME`_bEnableDMA == bEnableDMA) return;
    
    if(bEnableDMA)
    {
        `$INSTANCE_NAME`_RX_DMA_ISR_StartEx(`$INSTANCE_NAME`_RX_DMA_ISR);
        `$INSTANCE_NAME`_TX_DMA_ISR_StartEx(`$INSTANCE_NAME`_TX_DMA_ISR);
        `$INSTANCE_NAME`_RX_Chan = NSDSPI_RX_DmaInitialize(`$INSTANCE_NAME`_RX_BYTES_PER_BURST, `$INSTANCE_NAME`_RX_REQUEST_PER_BURST, 
            HI16(`$INSTANCE_NAME`_RX_SRC_BASE), HI16(`$INSTANCE_NAME`_RX_DST_BASE));
        `$INSTANCE_NAME`_TX_Chan = `$INSTANCE_NAME`_TX_DmaInitialize(`$INSTANCE_NAME`_TX_BYTES_PER_BURST, `$INSTANCE_NAME`_TX_REQUEST_PER_BURST, 
            HI16(`$INSTANCE_NAME`_TX_SRC_BASE), HI16(`$INSTANCE_NAME`_TX_DST_BASE));
        CyDmaClearPendingDrq(`$INSTANCE_NAME`_RX_Chan);
        CyDmaClearPendingDrq(`$INSTANCE_NAME`_TX_Chan);    
    }
    else
    {
        `$INSTANCE_NAME`_RX_DMA_ISR_Stop();
        `$INSTANCE_NAME`_TX_DMA_ISR_Stop();
        `$INSTANCE_NAME`_RX_DmaRelease();
        `$INSTANCE_NAME`_TX_DmaRelease();
    }
    `$INSTANCE_NAME`_bEnableDMA = bEnableDMA;
}

/* [] END OF FILE */
