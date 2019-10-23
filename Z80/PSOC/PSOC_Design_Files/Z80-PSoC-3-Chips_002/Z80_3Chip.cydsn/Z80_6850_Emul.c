/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/

#include <project.h>
#include <Z80_PSoC_3Chips.h>

#ifdef USING_6850

#define SIO_CHAR_RDY                0x01
#define M6850_INT_RTS_MASK          0x60
#define M6850_RTS_LOW__INT_EN       0x20    // Not used by Grant's 7-chip code
#define M6850_RTS_HI__INT_DIS       0x40
#define M6850_RTS_LOW__INT_DIS_BK   0x60    // Not used by Grant's 7-chip code

volatile uint8 M6850_Ctrl;
volatile uint8 M6850_Status;
volatile uint8 M6850_DataOut;
volatile uint8 M6850_DataIn;

///////////////////////////////////////////////////////////////////////////////
// void initM6850StatusRegister(void) - Set the initial value of the status reg
    
void initM6850StatusRegister(void)
{
    M6850_Status = 0x2;
}

///////////////////////////////////////////////////////////////////////////////
// void M6850ReadIntReg(void) - Read the Interrupt vector

void M6850ReadIntReg(void)
{
    Z80_Data_In_Write(0xFF);
    INT_n_Write(INT_OFF);   // Clear IRQ* line
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void sendCharToZ80(uint8 rxChar) - Get ready to send a character to the Z80 
// by placing it into the SIO_A_DataIn register and making the 
// RxCharacterAvailable active.

void sendCharToZ80(uint8 rxChar)
{
    M6850_DataIn = rxChar;                                          // Put the char into the buffer
    M6850_Status |= SIO_CHAR_RDY;                                   // Rx Character Available
    if ((M6850_Ctrl & M6850_INT_RTS_MASK) != M6850_RTS_LOW__INT_EN) // Only set IRQ if it is enabled from the WR1 bits
        INT_n_Write(INT_ON);               // Set IRQ* line
}

///////////////////////////////////////////////////////////////////////////////
// uint8 checkSerialReceiverBusy(void) - Check the Serial port receiver status
// Returns: 
//  0 if the port can take another character
//  1 if the port is busy and can't take another character

uint8 checkSerialReceiverBusy(void)
{
    if ((M6850_Ctrl & M6850_INT_RTS_MASK) == M6850_RTS_HI__INT_DIS)
    {
        return(1);
    }
    return (M6850_Status & SIO_CHAR_RDY);
}

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
    M6850_Ctrl = Z80_Data_Out_Read();
    // TBD - This is where the side effects of changing control codes are handled
    ackIO();
}

#endif

/* [] END OF FILE */
