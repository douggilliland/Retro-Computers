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

#define MCP23017_0  0x24    // Base address of the first MCP23017 (status/control bits)
#define MCP23017_1  0x25    // Base address of the second MCP23017 (address bus a8-a15)
#define MCP23017_2  0x26    // Base address of the third MCP23017 (address bus a0-a7)
#define MCP23017_3  0x27    // Base address of the fourth MCP23017 (data bus d0-d7)

void init_FrontPanel(void);
void runFrontPanel(void);
uint32 readFrontPanelSwitchesStatic(void);
uint32 readFrontPanelSwitchesRegistered(void);
uint32 waitFrontPanelSwitchesPressed();
void writeFrontPanelLEDs(uint32);
uint8 readRegister_MCP23017(uint8, uint8);
void writeRegister_MCP23017(uint8, uint8, uint8);
void FrontPanelZ80Read(void);
void FrontPanelZ80Write(void);

/* [] END OF FILE */
