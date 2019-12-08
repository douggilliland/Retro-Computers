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

#if !defined(FRONTPANEL_H)
#define FRONTPANEL_H

#include <project.h>

#define MCP23017_IODIR_DEFVAL    0xff       // Initially set all channels to inputs
#define MCP23017_IODIR_ALL_INS   0xff
#define MCP23017_IODIR_ALL_OUTS  0x00

#define MCP23017_IPOL_INVERT     0xFF       // Input polarity = invert jumpers
#define MCP23017_GPINTEN_DISABLE 0x00       // Disable GPIO for interrupt on change
#define MCP23017_GPINTEN_ENABLE  0xFF       // Enable GPIO for interrupt on change
#define MCP23017_DEFVALA_DEFVAL  0x00       // Default vales of interrupt state
#define MCP23017_INTCON_DEFVAL   0xFF       // Int for different from default value
#define MCP23017_INTCON_PREVPIN  0x00       // Int for change from previous pin
#define MCP23017_IOCON_DEFVAL    0x04       // Disable sequential,  active-low
#define MCP23017_GPPU_DISABLE    0x00       // Disable pull-ups
#define MCP23017_GPPU_ENABLE     0xFF       // Enable pull-ups

#define MCP23017_0  0x24    // Base address of the first MCP23017 (status/control bits)
#define MCP23017_1  0x25    // Base address of the second MCP23017 (address bus a8-a15)
#define MCP23017_2  0x26    // Base address of the third MCP23017 (address bus a0-a7)
#define MCP23017_3  0x27    // Base address of the fourth MCP23017 (data bus d0-d7)

// Bits of FPCtrl
#define INC_ADDR    0x01    // Increment address and read memory value at next address
#define ST_INC      0x02    // Store data value, increment address and read next memory 
#define LD_ADDR     0x04    // Load address bits and read memory
#define RUN_SW      0x80    // Run Switch

// Function Prototypes

void init_FrontPanel(void);
uint8 runFrontPanel(void);
void FrontPanelZ80Read(uint8);
void FrontPanelZ80Write(uint8);
uint32 readFrontPanelSwitchesRegistered(void);
uint32 waitFrontPanelSwitchesPressed();
uint32 readFrontPanelSwitchesStatic(void);
void writeFrontPanelLEDs(uint32);
void writeRegister_MCP23017(uint8, uint8, uint8);
uint8 readRegister_MCP23017(uint8, uint8);

#endif

/* [] END OF FILE */
