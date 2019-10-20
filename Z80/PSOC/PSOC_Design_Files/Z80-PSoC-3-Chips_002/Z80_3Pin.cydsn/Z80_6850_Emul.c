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

#include <project.h>
#include "Z80_6850_emul.h"
#include "Z80_IO_Handle.h"

#define SIOA_CHAR_RDY               0x01
#define M6850_INT_RTS_MASK          0x60
#define M6850_RTS_LOW__INT_DIS      0x00
#define M6850_RTS_LOW__INT_EN       0x20
#define M6850_RTS_HI__INT_DIS       0x40
#define M6850_RTS_LOW__INT_DIS_BK   0x60

volatile uint8 M6850_Ctrl;
volatile uint8 M6850_Status;
volatile uint8 M6850_DataOut;
volatile uint8 M6850_DataIn;

///////////////////////////////////////////////////////////////////////////////
// M6850ReadData(void)- Z80 is reading data from Serial Port

void M6850ReadData(void)
{
    Z80_Data_In_Write(M6850_DataIn);
    M6850_Status &= 0xFE;                              // No Rx Character Available
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void M6850WriteData(void) - Send a single byte from the Z80 to the USB

void M6850WriteData(void)
{
    uint8 buffer[64];
    uint16 count = 1;
    while (0u == USBUART_CDCIsReady());
    buffer[0] = Z80_Data_Out_Read();
    USBUART_PutData(buffer, count);
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void M6850ReadStatus(void) - Read the Status registers

void M6850ReadStatus(void)
{
    Z80_Data_In_Write(M6850_Status);
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void M6850WriteCtrl(void) - Write to the SIO Port A control registers

void M6850WriteCtrl(void)
{
    uint8 regNum;
    M6850_Ctrl = Z80_Data_Out_Read();
    // TBD - This is where the side effects of changing control codes are handled
    ackIO();
}



/* [] END OF FILE */
