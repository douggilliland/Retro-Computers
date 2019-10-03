/* ========================================
 * DIGIO8Driver.c
 * Copyright Land Boards LLC, 2017
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/

#include <project.h>

uint8 myWrBuffer[2];
 
#define MCP23008_IODIR_REGADR    0x00
#define MCP23008_IPOL_REGADR     0x01
#define MCP23008_GPINTEN_REGADR  0x02
#define MCP23008_DEFVAL_REGADR   0x03
#define MCP23008_INTCON_REGADR   0x04
#define MCP23008_IOCON_REGADR    0x05
#define MCP23008_GPPU_REGADR     0x06
#define MCP23008_INTF_REGADR     0x07
#define MCP23008_INTCAP_REGADR   0x08
#define MCP23008_GPIO_REGADR     0x09
#define MCP23008_OLAT_REGADR     0x0a

#define MCP23008_IODIR_DEFVAL    0xf0       // Upper 4 bits=JumperIns, lower=LEDS
#define MCP23008_IPOL_DEFVAL     0xf0       // Input polarity = invert jumpers
#define MCP23008_GPINTEN_DEFVAL  0x00       // Disable GPIO for interrupt on change
#define MCP23008_INTCON_DEFVAL   0x00       // Int for change from previous pin
#define MCP23008_IOCON_DEFVAL    0x00       // Disable sequential,  active-low
#define MCP23008_GPPU_DEFVAL     0xf0       // Default pullups

//////////////////////////////////////////////////////////////////////////////
// uint8 readRegisterDIGIO8Card(ctrlAdr) - 
//////////////////////////////////////////////////////////////////////////////

uint8 readRegisterDIGIO8Card(uint8 ctrlAdr)
{
    uint8 rdBuff;
    I2C_MasterClearStatus();
    I2C_MasterSendStart(0x20,I2C_WRITE_XFER_MODE);
    I2C_MasterWriteByte(ctrlAdr);
    I2C_MasterSendStop();
//    while ((I2C_MasterStatus() & I2C_MSTAT_WR_CMPLT) == 0);
    I2C_MasterSendStart(0x20,I2C_READ_XFER_MODE);
    rdBuff = I2C_MasterReadByte(I2C_NAK_DATA);
    I2C_MasterSendStop();
//    while ((I2C_MasterStatus() & I2C_MSTAT_RD_CMPLT) == 0);
    I2C_MasterClearStatus();
    return rdBuff;
}

//////////////////////////////////////////////////////////////////////////////
// writeRegisterDIGIO8Card(ctrlAdr, ctrlVal) - 
//////////////////////////////////////////////////////////////////////////////

void writeRegisterDIGIO8Card(uint8 ctrlAdr, uint8 ctrlVal)
{
    I2C_MasterClearStatus();
    myWrBuffer[0] = ctrlAdr;
    myWrBuffer[1] = ctrlVal;
    I2C_MasterWriteBuf(0x20, myWrBuffer, 2, I2C_MODE_COMPLETE_XFER);
    while (0u == (I2C_MasterStatus() & I2C_MSTAT_WR_CMPLT));
    I2C_MasterClearStatus();
}

//////////////////////////////////////////////////////////////////////////////
// writeDIGIO8Card(uint8_t outData) - 
//////////////////////////////////////////////////////////////////////////////

void writeDIGIO8Card(uint8 outData)
{
     writeRegisterDIGIO8Card(MCP23008_OLAT_REGADR,outData);
}

//////////////////////////////////////////////////////////////////////////////
// readDIGIO8Card(void)
//////////////////////////////////////////////////////////////////////////////

uint8 readDIGIO8Card(void)
{
    uint8 rdBuff;
    rdBuff = readRegisterDIGIO8Card(MCP23008_GPIO_REGADR);
    return rdBuff>>4;
}

//////////////////////////////////////////////////////////////////////////////
// initDIGIO8Card(void) - 
//////////////////////////////////////////////////////////////////////////////

void initDIGIO8Card(void)
{
    I2C_Start();    // Kick off the I2C interface
    writeRegisterDIGIO8Card(MCP23008_IOCON_REGADR,MCP23008_IOCON_DEFVAL);
    writeRegisterDIGIO8Card(MCP23008_IODIR_REGADR,MCP23008_IODIR_DEFVAL);
    writeRegisterDIGIO8Card(MCP23008_GPINTEN_REGADR,MCP23008_GPINTEN_DEFVAL);
    writeRegisterDIGIO8Card(MCP23008_INTCON_REGADR,MCP23008_INTCON_DEFVAL);
    writeRegisterDIGIO8Card(MCP23008_GPPU_REGADR,MCP23008_GPPU_DEFVAL);
    readRegisterDIGIO8Card(MCP23008_INTCAP_REGADR); // Clear interrupt LED
}


/* [] END OF FILE */
