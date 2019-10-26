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
// void putStringToUSB(char * stringToPutOutUSB)

void putStringToUSB(char * stringToPutOutUSB)
{
	USBUART_PutData((uint8 *)stringToPutOutUSB, strlen(stringToPutOutUSB));
	while (0u == USBUART_CDCIsReady());
}


/* [] END OF FILE */
