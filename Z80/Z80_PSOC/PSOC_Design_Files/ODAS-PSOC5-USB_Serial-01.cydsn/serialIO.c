/* ========================================
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"
#undef DEBUG_ON_PC
#include "serialIO.h"

////////////////////////////////////////////////////////////////
// void initSerial(void)
////////////////////////////////////////////////////////////////

void initSerial(void)
{
    UART_1_Start();
}

////////////////////////////////////////////////////////////////
// outSingleChar(char)
////////////////////////////////////////////////////////////////

void outSingleChar(char8 txChar)
{
    uint8 txStat;
    do
    {
        txStat = UART_1_ReadTxStatus();
    }
    while (txStat & UART_1_TX_STS_FIFO_FULL);
    UART_1_PutChar(txChar);
}

////////////////////////////////////////////////////////////////
// void writeLineNoLF(char * lineBuffer)
////////////////////////////////////////////////////////////////

void writeLineNoLF(char * lineBuffer)
{
    char * linePtr;
    linePtr = lineBuffer;
    while (*linePtr != 0)
        outSingleChar(*linePtr++);
}

////////////////////////////////////////////////////////////////
// void writeLine(char *)
////////////////////////////////////////////////////////////////

void writeLine(char * lineBuffer)
{
   writeLineNoLF(lineBuffer);
   outSingleChar(0x0d);
   outSingleChar(0x0a);
}

////////////////////////////////////////////////////////////////
// char8 getSingleChar(void)
////////////////////////////////////////////////////////////////

char8 getSingleChar(void)
{
    uint8 rxStat;
    char8 rxChar;       /* Data received from the Serial port */
    while(1)
    {
        rxStat = UART_1_ReadRxStatus(); 
        if (rxStat & UART_1_RX_STS_FIFO_NOTEMPTY)
        {
            rxChar = UART_1_GetChar();
            return rxChar;
        }
    }
}

////////////////////////////////////////////////////////////////
// uint8 readLine(char * lineBuffer)
////////////////////////////////////////////////////////////////

uint8 readLine(char * lineBuffer)
{
    uint8 byteCount=0;
    char * linePtr;
    uint8 rxStat;
    char8 rxChar;       /* Data received from the Serial port */
    uint8 endOfLine = 0;
    linePtr = lineBuffer;
    do
    {
        rxStat = UART_1_ReadRxStatus(); 
        if (rxStat & UART_1_RX_STS_FIFO_NOTEMPTY)
        {
            rxChar = UART_1_GetChar();
            if (rxChar == 0x0a || rxChar == 0x0d)
            {
                outSingleChar(rxChar);
                endOfLine = 1;
                *linePtr = 0;
                byteCount++;
                return byteCount;
            }
            else if ((rxChar == 0x08) ||(rxChar == 0x7f))
            {
                if (byteCount > 0)
                {
                    outSingleChar(0x08);
                    outSingleChar(' ');
                    outSingleChar(0x08);
                    linePtr--;
                    byteCount--;
                }
            }
            else if (byteCount > MAXLINELENGTH-2)
            {
                endOfLine = 1;
                *linePtr = 0;
            }
            else
            {
                outSingleChar(rxChar);
                *linePtr = rxChar;
                linePtr++;
                byteCount++;
            }
        }    
    }
    while(endOfLine == 0);
    return byteCount;
}

/* [] END OF FILE */
