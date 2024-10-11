#if !defined(MCP23017_H)
#define MCP23017_H

/* ========================================
 *
 * Copyright Land Boards, LLC, 2017
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/
    
#include <project.h>
//#include "i2cAddressMap.h"

enum ABPORT {APORT, BPORT};
enum PINMODE {OUTPUT_MODE,INPUT_MODE,INPUT_PULLUP,INPUT_MODE_LEAVE_PUP};
 
#define MCP23017_IODIRA_REGADR   0x00
#define MCP23017_IODIRB_REGADR   0x01
#define MCP23017_IPOLA_REGADR    0x02
#define MCP23017_IPOLB_REGADR    0x03
#define MCP23017_GPINTENA_REGADR 0x04
#define MCP23017_GPINTENB_REGADR 0x05
#define MCP23017_DEFVALA_REGADR  0x06
#define MCP23017_DEFVALB_REGADR  0x07
#define MCP23017_INTCONA_REGADR  0x08
#define MCP23017_INTCONB_REGADR  0x09
#define MCP23017_IOCONA_REGADR   0x0a
#define MCP23017_IOCONB_REGADR   0x0b
#define MCP23017_GPPUA_REGADR    0x0c
#define MCP23017_GPPUB_REGADR    0x0d
#define MCP23017_INTFA_REGADR    0x0e
#define MCP23017_INTFB_REGADR    0x0f
#define MCP23017_INTCAPA_REGADR  0x10
#define MCP23017_INTCAPB_REGADR  0x11
#define MCP23017_GPIOA_REGADR    0x12
#define MCP23017_GPIOB_REGADR    0x13
#define MCP23017_OLATA_REGADR    0x14
#define MCP23017_OLATB_REGADR    0x15

#define MCP23017_IODIR_DEFVAL    0xff       // Initially set all channels to inputs
#define MCP23017_IODIR_ALL_INS   0xff
#define MCP23017_IODIR_ALL_OUTS  0x00

#define MCP23017_IPOL_DEFVAL     0x00       // Input polarity = invert jumpers
#define MCP23017_GPINTEN_DEFVAL  0x00       // Disable GPIO for interrupt on change
#define MCP23017_INTCON_DEFVAL   0x00       // Int for change from previous pin
#define MCP23017_IOCON_DEFVAL    0x00       // Disable sequential,  active-low
#define MCP23017_GPPU_DEFVAL     0x00

void init_MCP23017(uint8);

// Arduino-ish functions
void digitalWrite_MCP23017(uint8, uint8, uint8);
uint8 digitalRead_MCP23017(uint8, uint8);
void pinMode_MCP23017(uint8, uint8, uint8);

// Byte control/access functions
void pinModeByByte_MCP23017(uint8, uint8, uint8);
uint8 read8_MCP23017(uint8, uint8);
uint16 read16_MCP23017(uint8);
uint8 readBack8_MCP23017(uint8, uint8);
void write8_MCP23017(uint8, uint8, uint8);
void write16_MCP23017(uint8, uint16);

// I2C Low Level Hardware access functions
uint8 readRegister_MCP23017(uint8, uint8);
void writeRegister_MCP23017(uint8, uint8, uint8);

# endif

/* [] END OF FILE */
