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
#include "MCP23017.h"

uint8 MCP23017_WrBuffer[2];

//////////////////////////////////////////////////////////////////////////////////////
// void init_MCP23017(uint8 chipAddr) - Initialize the MCP23017
// chipAddr - the base address of the MCP23017
// Need the base address since there are no C++ Constructors in PSOC Creator C
// Can use a higher level interface to set up the card/parts stack
//////////////////////////////////////////////////////////////////////////////////////

void init_MCP23017(uint8 chipAddr)
{
//    if (verboseFlag == VERBOSEMODE)
//    {
//        debugPrintStringLong("Initializing chip offset: ",chipAddr);
//    }
    writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_INTCONB_REGADR,MCP23017_INTCON_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_DEFVAL);
    writeRegister_MCP23017(chipAddr,MCP23017_GPPUB_REGADR,MCP23017_GPPU_DEFVAL);
    readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);
    readRegister_MCP23017(chipAddr,MCP23017_INTCAPB_REGADR);
}

///////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

// Arduino-ish functions
void digitalWrite_MCP23017(uint8 chipAddr, uint8 bit, uint8 val)
{
    uint8_t abVal;
    uint8_t port;
    uint8_t rVal;
    abVal = (bit>>3) & 0x01;
    port = bit & 0x7;
    rVal = readBack8_MCP23017(chipAddr,abVal);
//    debugPrintStringLong("digitalWrite_MCP23017() - chipAddr: ",chipAddr);
//    debugPrintStringLong("digitalWrite_MCP23017() - bit     : ",bit);
//    debugPrintStringLong("digitalWrite_MCP23017() - val     : ",val);
//    debugPrintStringLong("digitalWrite_MCP23017() - rVal    : ",rVal);
    if (val == 0)
        rVal &= ~(1<<port);
    else
        rVal |= (1<<port);
    
    write8_MCP23017(chipAddr,abVal,rVal);
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint8 digitalRead_MCP23017(uint8 chipAddr, uint8 bit)
{
    uint8_t abVal;
    uint8_t port;
    uint8_t readVal;
    uint8_t retVal;
    abVal = (bit>>3) & 0x01;
    readVal = read8_MCP23017(chipAddr, abVal);
    port = bit & 0x7;
    retVal = (readVal >> port)&0x1;
//    debugPrintStringLong("digitalRead_MCP23017() - readVal    : ",readVal);
//    debugPrintStringLong("digitalRead_MCP23017() - retVal    : ",readVal);
    return(retVal);
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

void pinMode_MCP23017(uint8 chipAddr, uint8 bit, uint8 val)
{
    uint8_t abVal;
    uint8_t changeBit;
    uint8_t selIODIRReg;
    uint8_t selPUPReg;
    uint8_t dirRegVal;
    uint8_t pupRegVal;
    abVal = (bit>>3) & 0x01;
    changeBit = 1 << (bit & 0x7);
//    debugPrintStringLong("pinModeDIGIO32(): chipAddr value is: ",chipAddr);
//    debugPrintStringLong("pinModeDIGIO32(): abVal value is: ",abVal);
//    debugPrintStringLong("pinModeDIGIO32(): changeBit value is: ",changeBit);
//    debugPrintStringLong("pinModeDIGIO32(): val value is: ",val);
    if (abVal == 0)
    {
        selIODIRReg = MCP23017_IODIRA_REGADR;
        selPUPReg = MCP23017_GPPUA_REGADR;
    }
    else
    {
        selIODIRReg = MCP23017_IODIRB_REGADR;
        selPUPReg = MCP23017_GPPUB_REGADR;
    }
    
    dirRegVal = readRegister_MCP23017(chipAddr, selIODIRReg);
    pupRegVal = readRegister_MCP23017(chipAddr, selPUPReg);
//        debugPrintStringLong("pinModeDIGIO32(): MCP23017_IODIRA_REGADR (before) is: ", (uint32) regVal);
    if (val == OUTPUT_MODE)
    {
        dirRegVal &= ~changeBit;
        writeRegister_MCP23017(chipAddr, selIODIRReg, dirRegVal);
    }
    else if (val == INPUT_MODE)   // INPUT_MODE
    {
        dirRegVal |= changeBit;
        writeRegister_MCP23017(chipAddr, selIODIRReg, dirRegVal);
        pupRegVal &= ~changeBit; // Disable the pullup.
        writeRegister_MCP23017(chipAddr, selPUPReg, pupRegVal);
    }
    else if (val == INPUT_PULLUP)
    {
        dirRegVal |= changeBit;
        writeRegister_MCP23017(chipAddr, selIODIRReg, dirRegVal);
        pupRegVal |= changeBit; // Enable the pullup.
        writeRegister_MCP23017(chipAddr, selPUPReg, pupRegVal);
    }
    else if (val == INPUT_MODE_LEAVE_PUP)   // Leave the pull-up resistor alone
    {
        dirRegVal |= changeBit;
        writeRegister_MCP23017(chipAddr, selIODIRReg, dirRegVal);
    }
//        debugPrintStringLong("pinModeDIGIO32(): MCP23017_IODIRA_REGADR (after) is: ", (uint32) regVal);
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

// Byte control/access functions
void pinModeByByte_MCP23017(uint8 chipAddr, uint8 a0b1, uint8 polarity)
{
    uint8 polMask;
    if (polarity == INPUT_MODE)
        polMask = 0xff;
    else if (polarity == INPUT_MODE_LEAVE_PUP)
        polMask = 0xff;
    else polMask = 0x00;
    if (a0b1 == APORT)
        writeRegister_MCP23017(chipAddr, MCP23017_IODIRA_REGADR, polMask);
    else
        writeRegister_MCP23017(chipAddr, MCP23017_IODIRB_REGADR, polMask);
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint8 read8_MCP23017(uint8 chipAddr, uint8 a0b1)
{
    uint8 rdBuff;
    if (a0b1 ==0)
        rdBuff = readRegister_MCP23017(chipAddr,MCP23017_GPIOA_REGADR);
    else
        rdBuff = readRegister_MCP23017(chipAddr,MCP23017_GPIOB_REGADR);
    return rdBuff;
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint16 read16_MCP23017(uint8 chipAddr)
{
    uint16 rdBuff;
    rdBuff = readRegister_MCP23017(chipAddr,MCP23017_GPIOB_REGADR);
    rdBuff <<= 8;
    rdBuff |= readRegister_MCP23017(chipAddr,MCP23017_GPIOA_REGADR);
    return rdBuff;
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint8 readBack8_MCP23017(uint8 chipAddr, uint8 a0b1)
{
    uint8 rdBuff;
    if (a0b1 ==0)
        rdBuff = readRegister_MCP23017(chipAddr,MCP23017_OLATA_REGADR);
    else
        rdBuff = readRegister_MCP23017(chipAddr,MCP23017_OLATB_REGADR);
    return rdBuff;
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

void write8_MCP23017(uint8 chipAddr, uint8 a0b1, uint8 wrVal)
{
    if (a0b1 == 0)
        writeRegister_MCP23017(chipAddr,MCP23017_OLATA_REGADR,wrVal);
    else
        writeRegister_MCP23017(chipAddr,MCP23017_OLATB_REGADR,wrVal);
}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

void write16_MCP23017(uint8 chipAddr, uint16 wrVal)
{
    writeRegister_MCP23017(chipAddr,MCP23017_OLATA_REGADR,wrVal&0xff);
    writeRegister_MCP23017(chipAddr,MCP23017_OLATB_REGADR,(wrVal>>8)&0xff);
}


//////////////////////////////////////////////////////////////////////////////////////
// I2C Low Level Hardware access functions

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

uint8 readRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr)
{
    uint8 rdBuff;
    uint8 i2cAddress = MCP23017BASE + chipAddr;

    I2C_MasterClearStatus();
    I2C_MasterSendStart(i2cAddress,I2C_WRITE_XFER_MODE);
    I2C_MasterWriteByte(ctrlAdr);
    I2C_MasterSendStop();
    I2C_MasterSendStart(i2cAddress,I2C_READ_XFER_MODE);
    rdBuff = I2C_MasterReadByte(I2C_NAK_DATA);
    I2C_MasterSendStop();
    I2C_MasterClearStatus();
//    debugPrintStringLong("readRegister_MCP23017(): i2cAddress value is       : ",i2cAddress);
//    debugPrintStringLong("readRegister_MCP23017(): ctrlRegisterAdr value is  : ",ctrlAdr);
//    debugPrintStringLong("readRegister_MCP23017(): rdBuff value is           : ",rdBuff);
    return rdBuff;

}

//////////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////////

void writeRegister_MCP23017(uint8 chipAddr, uint8 ctrlAdr, uint8 ctrlVal)
{
    uint8 i2cAddress = MCP23017BASE + chipAddr;
//    debugPrintStringLong("writeRegister_MCP23017(): i2cAddress value is       : ",i2cAddress);
//    debugPrintStringLong("writeRegister_MCP23017(): ctrlRegisterAdr value is  : ",ctrlAdr);
//    debugPrintStringLong("writeRegister_MCP23017(): ctrlWriteDateVal value is : ",ctrlVal);
    I2C_MasterClearStatus();
    MCP23017_WrBuffer[0] = ctrlAdr;
    MCP23017_WrBuffer[1] = ctrlVal;
    I2C_MasterWriteBuf(i2cAddress, MCP23017_WrBuffer, 2, I2C_MODE_COMPLETE_XFER);
    while (0u == (I2C_MasterStatus() & I2C_MSTAT_WR_CMPLT));
    I2C_MasterClearStatus();
}

/* [] END OF FILE */
