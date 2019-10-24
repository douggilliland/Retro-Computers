/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"            // all of the #includes from Cypress generated Hardware APIs
#include "stdio.h"              // sprintf needs this
#include <Z80_PSoC_3Chips.h>    // Combination of all of the .h Source file

#define USBFS_DEVICE    (0u)

/* The uartReadBuffer size is equal to the maximum packet size of the IN and OUT bulk
* endpoints.
*/
#define USBUART_uartBuffer_SIZE (64u)
#define LINE_STR_LENGTH     (20u)

void putStringToUSB(char *);


////////////////////////////////////////////////////////////////////////////
// Function prototypes

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
#define USBUART_Buffer_SIZE (64u)

////////////////////////////////////////////////////////////////////////////
// main() - Setup and Loop code goes in here

int main(void)
{
	uint16 USB_To_Z80_RxBytes_count = 0;    
	uint8 uartReadBuffer[USBUART_uartBuffer_SIZE];
	uint16 uartReadBufferOff = 0;
	uint32 postVal;
	uint8 Z80Running;
	uint16 inCount;
	uint8 inBuffer[USBUART_Buffer_SIZE];
    uint32 sectorNumber = 0;
	
	/* Start USBFS operation with 5-V operation. */
	USBUART_Start(USBFS_DEVICE, USBUART_5V_OPERATION);

	#ifdef USING_FRONT_PANEL
		I2C_Start();
	#else
		#ifdef USING_EXP_MCCP23017
		I2C_Start();
		#endif
	#endif
	#ifdef USING_SDCARD
		SDInit();
	#endif
	
	CyGlobalIntEnable;          /* Enable global interrupts. */
	
	// Do Power On Self Tests (POST)
	// SRAM POST
	postVal = TestSRAM();       // Run External SRAM POST
	PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
	if (postVal != 0)
		while(1);
#ifdef USING_MEM_MAP_1
	init_mem_map_1();           // Set up the address mapper
#endif
	loadSRAM();
	
	#ifdef USING_FRONT_PANEL
		Z80Running = runFrontPanel();            // Exits either by pressing EXitFrontPanel or RUN button on front panel
	#else
		ExtSRAMCtl_Control = 0;     // Auto Run if there's no Front Panel
	#endif

	if (Z80Running == 1)
	{
		#ifdef USING_6850
			initM6850StatusRegister();
		#endif
		#ifdef USING_6850_2
			initM6850_2_StatusRegister();
		#endif
		for(;;)
		{
			/* Host can send double SET_INTERFACE request. */
			if (0u != USBUART_IsConfigurationChanged())
			{
				/* Initialize IN endpoints when device is configured. */
				if (0u != USBUART_GetConfiguration())
				{
					/* Enumeration is done, enable OUT endpoint to receive data 
					 * from host. */
					USBUART_CDC_Init();
				}
			}

			/* Service USB CDC when device is configured. */
			if (0u != USBUART_GetConfiguration())
			{
				/* Check for input data from host. */
				/* Only do the check if the buffer is already empty */
				if ((0u != USBUART_DataIsReady()) & (USB_To_Z80_RxBytes_count == 0))
				{
					/* Read received data and re-enable OUT endpoint. */
					USB_To_Z80_RxBytes_count = USBUART_GetAll(uartReadBuffer);
					if ((USB_To_Z80_RxBytes_count == 1) & (checkSerialReceiverBusy() == 0))     // Input 1 character immediately
					{
						sendCharToZ80(uartReadBuffer[0]);
						USB_To_Z80_RxBytes_count = 0;
					}
				}
			}
			
			if (USB_To_Z80_RxBytes_count > 0)           // There are chars in the input uartReadBuffer (USB -> Z80)
			{
				if (checkSerialReceiverBusy() == 0)        // Check if receive uartReadBuffer can take another character
				{
					sendCharToZ80(uartReadBuffer[uartReadBufferOff]);   // Send received character to Z80 SIO interface
					uartReadBufferOff++;                                // ready for next character
					USB_To_Z80_RxBytes_count--;                         // worked off one character
					if (USB_To_Z80_RxBytes_count == 0)                  // Sent last character to Z80
					{
						uartReadBufferOff = 0;                          // point back to start of character in uartReadBuffer
					}
				}
			}
			if ((IO_Stat_Reg_Read() & IOBUSY_BIT) == IOBUSY_BIT)
			{
				HandleZ80IO();
			}
		}
	}
	else        // Z80 is not running
	{
		while(1)
		{
			/* Host can send double SET_INTERFACE request. */
			if (0u != USBUART_IsConfigurationChanged())
			{
				/* Initialize IN endpoints when device is configured. */
				if (0u != USBUART_GetConfiguration())
				{
					/* Enumeration is done, enable OUT endpoint to receive data 
					 * from host. */
					USBUART_CDC_Init();
				}
			}

			/* Service USB CDC when device is configured. */
			if (0u != USBUART_GetConfiguration())
			{
				/* Check for input data from host. */
				/* Only do the check if the buffer is already empty */
				if (0u != USBUART_DataIsReady())
				{
				/* Read received data and re-enable OUT endpoint. */
				inCount = USBUART_GetAll(inBuffer);

				if (0u != inCount)
				{
					/* Wait until component is ready to send data to host. */
					while (0u == USBUART_CDCIsReady());
					if ((inBuffer[0] == 'r') || (inBuffer[0] == 'R'))
					{
						putStringToUSB("Read from the SD Card\n\r");
                        readSDCard(sectorNumber);
                        sectorNumber++;
					}
					else
					{
						putStringToUSB("\n\rLand Boards, LLC - Z80_PSoC monitor\n\r");
						putStringToUSB("R - Read SD Card\n\r");
						putStringToUSB("? - Print this menu\n\r");
					}
					/* If the last sent packet is exactly the maximum packet 
					*  size, it is followed by a zero-length packet to assure
					*  that the end of the segment is properly identified by 
					*  the terminal.
					*/
					if (USBUART_Buffer_SIZE == inCount)
					{
						/* Wait until component is ready to send data to PC. */
						while (0u == USBUART_CDCIsReady())
						{
						}

						/* Send zero-length packet to PC. */
						USBUART_PutData(NULL, 0u);
					}
				}
			}
			
			if (USB_To_Z80_RxBytes_count > 0)           // There are chars in the input uartReadBuffer (USB -> Z80)
			{
				if (checkSerialReceiverBusy() == 0)        // Check if receive uartReadBuffer can take another character
				{
				}
			}
			}
		}
	}
}

/* [] END OF FILE */
