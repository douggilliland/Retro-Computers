/* ========================================
 *
 * Copyright Land Boards, LLC, 2019.
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF LAND BOARDS. LLC.
 *
 * ========================================
*/

#include <project.h>
#include "FrontPanel.h"

#define MCP23017_IODIR_DEFVAL    0xff       // Initially set all channels to inputs
#define MCP23017_IODIR_ALL_INS   0xff
#define MCP23017_IODIR_ALL_OUTS  0x00

#define MCP23017_IPOL_INVERT     0xFF       // Input polarity = invert jumpers
#define MCP23017_GPINTEN_DISABLE 0x00       // Disable GPIO for interrupt on change
#define MCP23017_GPINTEN_ENABLE  0xFF       // Enable GPIO for interrupt on change
#define MCP23017_INTCON_DEFVAL   0x00       // Int for change from previous pin
#define MCP23017_IOCON_DEFVAL    0x04       // Disable sequential,  active-low
#define MCP23017_GPPU_DISABLE    0x00       // Disable pull-ups
#define MCP23017_GPPU_ENABLE     0xFF       // Enable pull-ups

//////////////////////////////////////////////////////////////////////////////
// Front Panel Handler
// Starts at CPU address = 0
//////////////////////////////////////////////////////////////////////////////

// Global variables
uint8 FPData;       // Data that is on the Front Panel (bottom 8 LEDs)
uint16 FPAddr;      // Address that is on the Front Panel (middle 16 lEDs)
uint8 FPCtrl;       // Control that is on the Front Panel (top 8 LEDs)
uint32 FPLong;      // Long value of the Front Panel

// Bits of FPCtrl
#define INC_ADDR    0x01    // Increment address and read memory value at next address
#define ST_INC      0x02    // Store data value, increment address and read next memory 
#define LD_ADDR     0x04    // Load address bits and read memory
#define RUN_SW      0x80    // Run Switch

//////////////////////////////////////////////////////////////////////////////
// Function prototypes


//////////////////////////////////////////////////////////////////////////////
// init_FrontPanel() - Switches are on Port A, LEDs are on Port B

void init_FrontPanel(void)
{
    uint8 chipAddr;
    for (chipAddr = 0x24; chipAddr < 0x28; chipAddr++)
    {
        writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);     // IO: Port A is switches = inputs
        writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_OUTS);    // IO: Port B is LEDs = outputs
        writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);        // IP: Invert input pins on Port A
        writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_ENABLE);  // GPINT: Enable interrupts for switches
        writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE); // GPINT: Disable interrupts for LED outputs
        writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,0xFF);                      // Default value for pin (interrupt)
        writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_DEFVAL);    // Int for change from previous pin
        writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      // BANK: Register addresses are sequential
                                                                                            // MIRROR: Int pins not connected
                                                                                            // SEQOP: Enable sequential operation
                                                                                            // HAEN: (Not used on MCP23017)
                                                                                            // ODR: Open Drain output (over-rides INTPOL)
                                                                                            // INTPOL: Over-ridden by ODR
        writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);      // Int for change from previous pin
        writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);        // Pull-up to switches
        readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
    }
    FPData = 0;
    FPAddr = 0;
    FPCtrl = 0;
    FPLong = 0;
}

//////////////////////////////////////////////////////////////////////////////////////
// readFrontPanelSwitchesRegistered
//  Handler for the Pushbuttons and LEDs
//  Toggles the LED
//  Reads all four MCP23017 Port A's to make a 32-bit result
//  Looks for the switch to be pressed for 3 samples in a row
// Returns: 0 if there was no key pressed
//          1 if there was a key pressed

uint32 readFrontPanelSwitchesRegistered(void)
{
    uint32 rdVal;
    uint32 retVal = 0;
    uint32 valMin1 = 0;
    uint32 valMin2 = 0;
    uint32 valMin3 = 0;
    uint8 keyPressed = 0;
    rdVal = readFrontPanelSwitchesStatic();
    if (rdVal  == 0x00)     // No key is pressed at this polling
    {
        valMin1 = 0;
        valMin2 = 0;
        valMin3 = 0;
        return(0);
    }
    else    // key is now pressed
    {
        keyPressed = 1;
        while (keyPressed)  // stick around until key is no longer pressed
        {
            rdVal = readFrontPanelSwitchesStatic();
            if (rdVal == 0)
            {
                keyPressed = 0;
                valMin1 = 0;
                valMin2 = 0;
                valMin3 = 0;
                return(retVal);
            }
            valMin3 = valMin2;
            valMin2 = valMin1;
            valMin1 = rdVal;
            if ((valMin3 == 0) && (valMin2 != 0) && (valMin1 != 0) && (rdVal != 0))
            {
                return(valMin2);
            }
            CyDelay(10);    // 10 mS sampling for debouncing
        }
    }
    return (retVal);
}

//////////////////////////////////////////////////////////////////////////////////////
// waitFrontPanelSwitchesPressed() - Wait for switch to be pressed and return value

uint32 waitFrontPanelSwitchesPressed(void)
{
    uint32 switchVals = 0;
    while (readFrontPanelSwitchesRegistered() != 0);    // wait for previous key release
    while (switchVals == 0)
    {   
        switchVals = readFrontPanelSwitchesRegistered();
        if (switchVals != 0x0)
            return (switchVals);
    }
    return (0);
}

//////////////////////////////////////////////////////////////////////////////////////
// readFrontPanelSwitchesStatic() - Reads the current value of the actual switches
//  Reads all four MCP23017 Port A's to make a 32-bit result

uint32 readFrontPanelSwitchesStatic(void)
{
    uint32 switchVals = 0;
    switchVals = readRegister_MCP23017(MCP23017_0,MCP23017_GPIOA_REGADR);
    switchVals = switchVals<<8;
    switchVals |= readRegister_MCP23017(MCP23017_1,MCP23017_GPIOA_REGADR);
    switchVals = switchVals<<8;
    switchVals |= readRegister_MCP23017(MCP23017_2,MCP23017_GPIOA_REGADR);
    switchVals = switchVals<<8;
    switchVals |= readRegister_MCP23017(MCP23017_3,MCP23017_GPIOA_REGADR);
    return (switchVals);
}

//////////////////////////////////////////////////////////////////////////////////////
// writeFrontPanelLEDs(uint32) - Write a 32-bit value to the Front Panel LEDs

void writeFrontPanelLEDs(uint32 ledsVal)
{
    writeRegister_MCP23017(MCP23017_0,MCP23017_OLATB_REGADR,((ledsVal>>24) & 0xff));
    writeRegister_MCP23017(MCP23017_1,MCP23017_OLATB_REGADR,((ledsVal>>16) & 0xff));
    writeRegister_MCP23017(MCP23017_2,MCP23017_OLATB_REGADR,((ledsVal>>8) & 0xff));
    writeRegister_MCP23017(MCP23017_3,MCP23017_OLATB_REGADR,ledsVal&0xff);
}

//////////////////////////////////////////////////////////////////////////////////////
// I2C Low Level Hardware access functions

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint8 readRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr)
{
    uint8 rdBuff;

    I2C_MasterClearStatus();
    I2C_MasterSendStart(chipAddr,I2C_WRITE_XFER_MODE);
    I2C_MasterWriteByte(ctrlAdr);
    I2C_MasterSendStop();
    I2C_MasterSendStart(chipAddr,I2C_READ_XFER_MODE);
    rdBuff = I2C_MasterReadByte(I2C_NAK_DATA);
    I2C_MasterSendStop();
    I2C_MasterClearStatus();
    return rdBuff;

}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

void writeRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr, uint8 ctrlVal)
{
uint8 MCP23017_WrBuffer[2];
    I2C_MasterClearStatus();
    MCP23017_WrBuffer[0] = ctrlAdr;
    MCP23017_WrBuffer[1] = ctrlVal;
    I2C_MasterWriteBuf(chipAddr, MCP23017_WrBuffer, 2, I2C_MODE_COMPLETE_XFER);
    while (0u == (I2C_MasterStatus() & I2C_MSTAT_WR_CMPLT));
    I2C_MasterClearStatus();
}

/* [] END OF FILE */
