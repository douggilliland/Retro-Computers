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

////////////////////////////////////////////////////////////////////////////
// General support functions for the Z80_PSOC card

#include <project.h>
#include "stdio.h"
#include <Z80_PSoC_3Chips.h>

////////////////////////////////////////////////////////////////////////////
// PostLed(postVal) - Blink the LED the number of times (postVal)

void PostLed(uint32 postVal)
{
	uint32 blinkCount = postVal;
	while(blinkCount > 0)
	{
		LED_Write(0);   // Turn on the LED
		CyDelay(500);
		LED_Write(1);   // Turn off the LED
		CyDelay(250);
		blinkCount--;   // loop as many times as the POST code
	}
}

////////////////////////////////////////////////////////////////////////////
// void putStringToUSB(char * stringToPutOutUSB) - Print string out USB-Serial to host
// Blocking function

void putStringToUSB(char * stringToPutOutUSB)
{
	USBUART_PutData((uint8 *)stringToPutOutUSB, strlen(stringToPutOutUSB));
	while (0u == USBUART_CDCIsReady());
}

////////////////////////////////////////////////////////////////////////////
// void I2CIntISR(void) - Handle the I2CINT* line
// The routine is called when a button on the front panel is pressed or 
//  Expansion MCP23017 pin is toggle by a JOYPAD or General Purpose Input

void I2CIntISR(void)
{
    uint32 lFPVal;
    uint8 bPortA;
    uint8 bPortB;
    I2CINT_ISR_Disable();       // Cause an implicit delay between interrupts
	#ifdef USING_FRONT_PANEL
  		lFPVal = readRegister_MCP23017(0x24,MCP23017_GPIOA_REGADR) << 8;                  // Clears interrupt
  		lFPVal = ((readRegister_MCP23017(0x25,MCP23017_GPIOA_REGADR) | lFPVal) << 8);     // Clears interrupt
  		lFPVal = ((readRegister_MCP23017(0x26,MCP23017_GPIOA_REGADR) | lFPVal) << 8);     // Clears interrupt
  		lFPVal = readRegister_MCP23017(0x27,MCP23017_GPIOA_REGADR)   | lFPVal;            // Clears interrupt
        fpIntVal = fpIntVal ^ lFPVal;
	#endif
	#ifdef USING_EXP_MCCP23017
  		bPortA = readRegister_MCP23017(0x20,MCP23017_GPIOA_REGADR);                      // Clears interrupt
        PIO_Input_Register_Port_A = bPortA;
        pioAIntVals = pioAIntVals ^ bPortA;
  		bPortB = readRegister_MCP23017(0x20,MCP23017_GPIOB_REGADR);                      // Clears interrupt
        PIO_Input_Register_Port_B = bPortB;
        pioBIntVals = pioBIntVals ^ bPortB;
	#endif
}

/* [] END OF FILE */
