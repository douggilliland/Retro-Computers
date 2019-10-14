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
#include "Z80_SIO_emul.h"
#include "Z80_IO_Handle.h"

volatile uint8 SIO_A_Ctrl1;
volatile uint8 SIO_A_Ctrl2;
volatile uint8 SIO_A_Status;
volatile uint8 SIO_A_DataOut;
volatile uint8 SIO_A_DataIn;
volatile uint8 SIO_A_Ctrl_Count;
volatile uint8 SIO_A_WR0;
volatile uint8 SIO_A_WR1;
volatile uint8 SIO_A_WR2;
volatile uint8 SIO_A_WR3;
volatile uint8 SIO_A_WR4;
volatile uint8 SIO_A_WR5;
volatile uint8 SIO_A_WR6;
volatile uint8 SIO_A_WR7;
volatile uint8 SIO_A_RD0;
volatile uint8 SIO_A_RD1;
volatile uint8 SIO_A_RD2;
volatile uint8 UART_A_TXD;
volatile uint8 UART_A_TXD_BUSY;

volatile uint8 SIO_B_Ctrl1;
volatile uint8 SIO_B_Ctrl2;
volatile uint8 SIO_B_Status;
volatile uint8 SIO_B_DataOut;
volatile uint8 SIO_B_DataIn;
volatile uint8 SIO_B_Ctrl_Count;
volatile uint8 SIO_B_WR0;
volatile uint8 SIO_B_WR1;
volatile uint8 SIO_B_WR2;
volatile uint8 SIO_B_WR3;
volatile uint8 SIO_B_WR4;
volatile uint8 SIO_B_WR5;
volatile uint8 SIO_B_WR6;
volatile uint8 SIO_B_WR7;
volatile uint8 SIO_B_RD0;
volatile uint8 SIO_B_RD1;
volatile uint8 SIO_B_RD2;
volatile uint8 UART_B_TXD;
volatile uint8 UART_B_TXD_BUSY;

void sendCharToZ80(uint8 rxChar)
{
    SIO_A_DataIn = rxChar;                          // Put the char into the buffer
    SIO_A_RD0 |= 0x1;                               // Rx Character Available
    IO_Ctrl_Reg_Write(IO_Ctrl_Reg_Read() | 0x04);   // Set IRQ* line
}

void SioReadDataA(void)
{
    Z80_Data_In_Write(SIO_A_DataIn);
    SIO_A_RD0 &= 0xFE;                              // No Rx Character Available
    ackIO();
}

void SioWriteDataA(void)
{
    uint8 buffer[64];
    uint16 count = 1;
    while (0u == USBUART_CDCIsReady());
    buffer[0] = Z80_Data_Out_Read();
    USBUART_PutData(buffer, count);
    ackIO();
    UART_A_TXD_BUSY = 1;
}

void SioReadStatusA(uint8 regNum)
{
    switch (regNum)
    {
        // SIO_A_WR0 bottom bits determine which read register is read
        case 0x00:
        {
            // p 292 of um0081
            // D0 - Receive character ready - 1 at least one char in receiver
            // D1 - Interrupt Pending (Channel A register only) 
            // D2 - Transmit Buffer Empty - 1 = Tx Buffer is empty
            // D3 - DCD - not used
            // D4 - Sync/Hunt - ignored
            // D5 - CTS - 
            // D6 - Tx Underrun
            // D7 - Break/Abort
            Z80_Data_In_Write(SIO_A_RD0);
            ackIO();
            return;
            break;
        }
        case 0x01:
        {
            // p 297 of um0081
            // SIO_RD1
            //  D0 - All tx chars have been sent
            // Special Rx condition status - not used
            Z80_Data_In_Write(SIO_A_RD1);
            ackIO();
            return;
            break;
        }
        case 0x02:
        {
            // p 300 of um0081
            // Only used in status register B
            Z80_Data_In_Write(SIO_A_RD2);
            ackIO();
            return;
            break;
        }
    }
}

void SioReadIntRegA()
{
    Z80_Data_In_Write(SIO_B_WR2);
    IO_Ctrl_Reg_Write(IO_Ctrl_Reg_Read() & 0xFB);   // Clear IRQ* line
    ackIO();
}

void SioWriteCtrlA(void)
{
    uint8 regNum;
    SIO_A_Ctrl1 = Z80_Data_Out_Read();   // Get the first command which selects register of second command
    ackIO();
    regNum = SIO_A_Ctrl1 & 0x7;          // bottom 3 bits are the address of the next access
    waitNextIORq();                       // wait for next IO cycle since it's the contents
    if (IO_Stat_Reg_Read() == REGULAR_READ_CYCLE)
    {
        SioReadStatusA(regNum);
        return;
    }
    // Not a read cycle, therefore a write cycle
    SIO_A_Ctrl2 = Z80_Data_Out_Read();
    ackIO();
    switch(regNum)
    {
        case 0x0:
            SIO_A_WR0 = SIO_A_Ctrl2;
            // Only implementing the reset command
            // p 275 of um0081 - All control registers for the channel must be rewritten after a Channel Reset command.
            if ((SIO_A_WR0 & 0x18) == 0x18)     // Channel reset clears registers 
            {
                SIO_A_WR0 = 0x0;
                SIO_A_WR1 = 0x0;
                SIO_A_WR2 = 0x0;
                SIO_A_WR3 = 0x0;
                SIO_A_WR4 = 0x0;
                SIO_A_WR5 = 0x0;
                SIO_A_WR6 = 0x0;
                SIO_A_WR7 = 0x0;
                SIO_A_RD0 = 0x44;
                SIO_A_RD1 = 0x01;
                SIO_A_RD2 = 0x00;
                UART_A_TXD_BUSY = 0;
            }
            break;
        case 0x1:               
            // p 277 of um0081
            /// D0 - Ext int enable - not using interrupt on CTS
            // D1 - Tx Int Enable - Not using
            // D2 - Status affect vector is only active on Channel B
            // D3, D4 - 00 = Rx Int disabled, 01 = Rx Int on first char, 10 = Rx Int on all chars (parity), 11 = Rx Int on all chars
            // D5, D6 - Wait/RDY function select - ignoring
            // D7 - Use Wait/RDY function - ignoring
            SIO_A_WR1 = SIO_A_Ctrl2;
            break;
        case 0x2:
            // p 281 of um0081
            // Interrupt vector - only used in channel B
            SIO_A_WR2 = SIO_A_Ctrl2;
            break;
        case 0x3:
            // p 282 
            // D0 - Receiver enable - always used
            // D1 - Sync char load inhibit - not used
            // D2 - Address Search Mode SDLC mode - not used
            // D3 - Receiver CRC enable - not used
            // D4 - Enter hunt phase Synch or SDLC - not used
            // D5 - Auto enables - polled vs automatic use of CTS - not needed for USB-Serial for port A (maybe B?)
            // D6, D7 - Rx Bits/char - 11 = 8 bits/char - normal value expected
            SIO_A_WR3 = SIO_A_Ctrl2;
            break;
        case 0x4:
            // p 284 D0 = Parity - Not used
            // D1 = Parity odd/even - Not used
            // D2,D3 - 01 = 1 stop bit per character
            // D4, D5 - Sync modes - Ignored
            // D6, D7 - Clock rate - set by USB-Serial interface automatically so ignored for Port A
            // Grant has 7.2738 MHz - divided by 64 = 115,200 baud
            SIO_A_WR4 = SIO_A_Ctrl2;
            break;
        case 0x5:
            // p 287
            // Grant's code sets this to 0xEA
            // D0 - Tx CRC enable
            // D1 - RTS - allows RTS to be manually set
            // D2 - CRC-16/SDLC - Not used
            // D3 - Transmit Enable
            // D4 - Send break - not used
            // D5, D6 - SYNC mode - Not used
            // D7 - DTR - allows DTR to be manually set
            SIO_A_WR5 = SIO_A_Ctrl2;
            break;
        case 0x6:
            // D90D7 - SYNC bits - not used
            SIO_A_WR6 = SIO_A_Ctrl2;
            break;
        case 0x7:
            // D0-D7 - receive sync character - not used
            SIO_A_WR7 = SIO_A_Ctrl2;
            break;
    }
}

void SioReadDataB(void)
{
    Z80_Data_In_Write(SIO_B_DataIn);
    SIO_B_RD0 &= 0xFE;                              // No Rx Character Available
    ackIO();    
}

void SioWriteDataB(void)
{
    UART_B_TXD = 0;
    ackIO();
}

void SioReadStatusB(uint8 regNum)
{
    switch (regNum)
    {
        // SIO_B_WR0 bottom bits determine which read register is read
        case 0x00:
        {
            // p 292 of um0081
            // D0 - Receive character ready - 1 at least one char in receiver
            // D1 - Interrupt Pending (Channel A register only) 
            // D2 - Transmit Buffer Empty - 1 = Tx Buffer is empty
            // D3 - DCD - not used
            // D4 - Sync/Hunt - ignored
            // D5 - CTS - 
            // D6 - Tx Underrun
            // D7 - Break/Abort
            Z80_Data_In_Write(SIO_B_RD0);
            ackIO();
            return;
            break;
        }
        case 0x01:
        {
            // p 297 of um0081
            // SIO_RD1
            //  D0 - All tx chars have been sent
            // Special Rx condition status - not used
            Z80_Data_In_Write(SIO_B_RD1);
            ackIO();
            break;
            return;
        }
        case 0x02:
        {
            // p 300 of um0081
            // Only used in status register B
            Z80_Data_In_Write(SIO_B_RD2);
            ackIO();
            return;
            break;
        }
    }
    ackIO();    
}

void SioReadIntRegB(void)
{
    Z80_Data_In_Write(SIO_B_WR2);
    IO_Ctrl_Reg_Write(IO_Ctrl_Reg_Read() & 0xFB);   // Clear IRQ* line
    ackIO();
}

void SioWriteCtrlB(void)
{
    uint8 regNum;
    SIO_B_Ctrl1 = Z80_Data_Out_Read();   // Get the first command which selects register of second command
    ackIO();
    regNum = SIO_B_Ctrl1 & 0x7;          // bottom 3 bits are the address of the next access
    waitNextIORq();                     // wait for next IO cycle since it's the contents
    if (IO_Stat_Reg_Status == REGULAR_READ_CYCLE)
    {
        SioReadStatusB(regNum);
        return;
    }
    // Not a read cycle, therefore a write cycle
    SIO_B_Ctrl2 = Z80_Data_Out_Read();
    ackIO();
    switch(regNum)
    {
        case 0x0:
            SIO_B_WR0 = SIO_B_Ctrl2;
            // Only implementing the reset command
            // p 275 of um0081 - All control registers for the channel must be rewritten after a Channel Reset command.
            if ((SIO_B_WR0 & 0x18) == 0x18)     // Channel reset clears registers 
            {
                SIO_B_WR0 = 0x0;
                SIO_B_WR1 = 0x0;
                SIO_B_WR2 = 0x0;
                SIO_B_WR3 = 0x0;
                SIO_B_WR4 = 0x0;
                SIO_B_WR5 = 0x0;
                SIO_B_WR6 = 0x0;
                SIO_B_WR7 = 0x0;
                SIO_B_RD0 = 0x44;
                SIO_B_RD1 = 0x01;
                SIO_B_RD2 = 0x00;
                UART_B_TXD_BUSY = 0;
            }
            break;
        case 0x1:               
            // p 277 of um0081
            // D0 - Ext int enable - not using interrupt on CTS
            // D1 - Tx Int Enable - Not using
            // D2 - Status affect vector is only active on Channel B
            // D3, D4 - 00 = Rx Int disabled, 01 = Rx Int on first char, 10 = Rx Int on all chars (parity), 11 = Rx Int on all chars
            // D5, D6 - Wait/RDY function select - ignoring
            // D7 - Use Wait/RDY function - ignoring
            SIO_B_WR1 = SIO_B_Ctrl2;
            break;
        case 0x2:
            // p 281 of um0081
            // Interrupt vector - only used in channel B
            SIO_B_WR2 = SIO_B_Ctrl2;
            break;
        case 0x3:
            // p 282 
            // D0 - Receiver enable - always used
            // D1 - Sync char load inhibit - not used
            // D2 - Address Search Mode SDLC mode - not used
            // D3 - Receiver CRC enable - not used
            // D4 - Enter hunt phase Synch or SDLC - not used
            // D5 - Auto enables - polled vs automatic use of CTS - not used for port A (maybe B?)
            // D6, D7 - Rx Bits/char - 11 = 8 bits/char - normal value expected
            SIO_B_WR3 = SIO_B_Ctrl2;
            break;
        case 0x4:
            // p 284 D0 = Parity - Not used
            // D0 = Parity - Not used
            // D1 = Parity odd/even - Not used
            // D2,D3 - 01 = 1 stop bit per character
            // D4, D5 - Sync modes - Ignored
            // D6, D7 - Clock rate - set by USB-Serial interface automatically so ignored for Port A
            // Grant has 7.2738 MHz - divided by 64 = 115,200 baud
            SIO_B_WR4 = SIO_B_Ctrl2;
            break;
        case 0x5:
            // p 287
            // D0 - Tx CRC enable
            // D1 - RTS - allows RTS to be manually set
            // D2 - CRC-16/SDLC - Not used
            // D3 - Transmit Enable
            // D4 - Send break - not used
            // D5, D6 - SYNC mode - Not used
            // D7 - DTR - allows DTR to be manually set
            SIO_B_WR5 = SIO_B_Ctrl2;
            break;
        case 0x6:
            // D90D7 - SYNC bits - not used
            SIO_B_WR6 = SIO_B_Ctrl2;
            break;
        case 0x7:
            // D0-D7 - receive sync character - not used
            SIO_B_WR7 = SIO_B_Ctrl2;
            break;
    }
}

/* [] END OF FILE */
