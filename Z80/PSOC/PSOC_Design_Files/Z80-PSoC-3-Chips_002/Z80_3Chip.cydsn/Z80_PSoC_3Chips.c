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

uint8 receiveBuffer[80];
uint8 receiveBufferPtr;
uint8 gotCRorLF;
uint32 sectorNumber;

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
// void printMenu(void)

void printMenuScreen(void)
{
    putStringToUSB("\n\rLand Boards, LLC - Z80_PSoC monitor\n\r");
	putStringToUSB("I - Initialize SD Card\n\r");
	putStringToUSB("B - Blink LED\n\r");
    putStringToUSB("F - Read Front Panel\n\r");
	putStringToUSB("Rxxxxxxxx - Read sector xxxxxxxx from the SD Card\n\r");
	putStringToUSB("N - Read next sector from the SD Card\n\r");
	putStringToUSB("W - Write to the SD Card at 2GB - 1 sector\n\r");
	putStringToUSB("? - Print this menu\n\r");
}

////////////////////////////////////////////////////////////////////////////
// asciiNibbleToVal(uint8)

uint32 asciiNibbleToVal(uint8 charVal)
{
    if ((charVal >= '0') && (charVal <= '9'))
        return (charVal-'0');
    else if ((charVal >= 'A') && (charVal <= 'F'))
        return (charVal-'A'+10);
    else if ((charVal >= 'a') && (charVal <= 'f'))
        return (charVal-'a'+10);
    return(0);
}

////////////////////////////////////////////////////////////////////////////
// uint32 extractLong(uint8 *)

uint32 extractLong(uint8 * commandString)
{
    uint8 linePtr = 1;
    uint32 rVal = 0;
    while ((commandString[linePtr] != 0) && (linePtr < 32) && (commandString[linePtr] != '\n') && (commandString[linePtr] != '\r'))
    {
        rVal <<= 4;
        rVal |= asciiNibbleToVal(commandString[linePtr]);
        linePtr++;
    }
    return (rVal);
}

////////////////////////////////////////////////////////////////////////////
// void psocMenu(void)

void psocMenu(void)
{
	while (0u == USBUART_CDCIsReady()); // Wait until component is ready to send data to host
	if ((receiveBuffer[0] == 'r') || (receiveBuffer[0] == 'R'))
	{
		putStringToUSB("Read from the SD Card\n\r");
        sectorNumber = extractLong(receiveBuffer);
        readSDCard(sectorNumber);
	}
	else if ((receiveBuffer[0] == 'n') || (receiveBuffer[0] == 'N'))
	{
		putStringToUSB("Read next sector from the SD Card\n\r");
        sectorNumber++;
        readSDCard(sectorNumber);
	}
	else if ((receiveBuffer[0] == 'b') || (receiveBuffer[0] == 'B'))
	{
		putStringToUSB("Blink LED\n\r");
        PostLed(1);
	}
	else if ((receiveBuffer[0] == 'w') || (receiveBuffer[0] == 'W'))
	{
		putStringToUSB("Write to the SD Card at 2GB - 1 sector\n\r");
        writeSDCard(0x1FFFFF);
	}
	else if ((receiveBuffer[0] == 'i') || (receiveBuffer[0] == 'I'))
	{
		putStringToUSB("Initialize the SD Card\n\r");
        SDInit();
	}
	else if ((receiveBuffer[0] == 'f') || (receiveBuffer[0] == 'F'))
	{
        char lineString[16];
		putStringToUSB("Front Panel Value - ");
  		sprintf(lineString,"0x%08lx",fpIntVal);
        putStringToUSB(lineString);
        putStringToUSB("\n\r");
	}
	else
	{
        printMenuScreen();
	}
    clearReceiveBuffer();
}

////////////////////////////////////////////////////////////////////////////
// void clearReceiveBuffer(void)

void clearReceiveBuffer(void)
{
    receiveBufferPtr = 0;
    receiveBuffer[0] = 0;
    gotCRorLF = 0;
}

////////////////////////////////////////////////////////////////////////////
// void addToReceiveBuffer(uint16, uint8 *)

void addToReceiveBuffer(uint16 inCount, uint8 * inBuffer)
{
    uint8 echoString[80];
    echoString[0] = 0;
    for (uint8 receiveCt = 0; receiveCt < inCount; receiveCt++)
    {
        // First check if the character is an end of line
        if ((inBuffer[receiveCt] == 0x0a) || (inBuffer[receiveCt] == 0x0d))
        {
            gotCRorLF = 1;
            putStringToUSB("\n\r");
        }
        // check if the character is not a RUBOUT and if the line length is OK
        else if ((inBuffer[receiveCt] != 0x7f) && (receiveCt < 80))
        {
            receiveBuffer[receiveBufferPtr] = inBuffer[receiveCt];
            receiveBufferPtr++;
            echoString[inCount] = 0;
            echoString[receiveCt] = inBuffer[receiveCt];
            putStringToUSB((char *)echoString);
        }
        // If the character is rubout and not the 0th character
        else if ((receiveBufferPtr > 0) && (inBuffer[receiveCt] == 0x7f))
        {
            receiveBufferPtr--;
            echoString[0] = 0x08;       // Backspace
            echoString[1] = 0x20;       // Space
            echoString[2] = 0x08;       // Backspace
            echoString[3] = 0;
            putStringToUSB((char *)echoString);
        }
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
