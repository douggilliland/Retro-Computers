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

#include "project.h"            // All of the #includes from Cypress generated Hardware APIs
#include "stdio.h"              // sprintf needs this
#include <Z80_PSoC_3Chips.h>    // Combination of all of the .h Source file

#define USBFS_DEVICE            (0u)
#define USBUART_uartBuffer_SIZE (64u)
#define LINE_STR_LENGTH         (20u)
#define USBUART_Buffer_SIZE     (64u)

#ifdef USING_FRONT_PANEL
    uint32 fpIntVal;
#endif
#ifdef USING_EXP_MCCP23017
    uint8 pioAIntVals;
    uint8 pioBIntVals;
#endif

////////////////////////////////////////////////////////////////////////////
// initZ80PSOC() - Initialize the PSoC for Z80 operations

uint8 initZ80PSOC(void)
{
	uint32 postVal;
	uint8 Z80Running;
    
#ifdef USING_FRONT_PANEL
    fpIntVal = 0;
#endif

#ifdef USING_EXP_MCCP23017
    pioAIntVals = 0;
    pioBIntVals = 0;
#endif
	
	USBUART_Start(USBFS_DEVICE, USBUART_5V_OPERATION);  // Start USBFS operation with 5-V operation.

    // Memory Map/MMU initialization
    #ifdef USING_MEM_MAP_1
	    init_mem_map_1();       // Set up the address mapper
    #endif
        
	CyGlobalIntEnable;          /* Enable global interrupts. */
    
    // I2C_Start() if either External MPC23017 or Front Panel or both are present
    // I2C interrupts have to be enabled prior to starting up the PIO it uses interrupts
	#ifdef USING_MCP23017
		I2C_Start();                                // Start up the I2C interface
    	I2CINT_n_SetDriveMode(I2CINT_n_DM_RES_UP);  // Pull-up the I2C interrupt line
        I2CINT_ISR_Start();                         // Start up I2C interface interrupts
        I2CINT_ISR_Disable();
	#endif  
    
	#ifdef USING_FRONT_PANEL
        init_FrontPanel();
    #endif
  	
    #ifdef USING_EXP_MCCP23017
    	init_PIO();
	#endif
    
	#ifdef USING_SDCARD
		SDInit();
	#endif
    	
    #ifdef USING_RTC
        init_Z80_RTC();
    #endif
    
    #ifdef USING_DAC
        init_DAC();
    #endif
    
	// Do Power On Self Tests (POST)
	// SRAM POST
	postVal = TestSRAM();       // Run External SRAM POST
	PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
	if (postVal != 0)           // Halt on POST failure (could do something better here)
		while(1);
        
    // Load SRAM with BIOS and/or language image
	loadSRAM();
	
	// Front Panel Initialization
    #ifdef USING_FRONT_PANEL
		Z80Running = runFrontPanel();            // Exits either by pressing EXitFrontPanel or RUN button on front panel
 	#else
		ExtSRAMCtl_Control = 0;     // Auto Run if there's no Front Panel
	#endif
    
    #ifdef USING_MMU4
	    init_mem_map_4();       // Set up the address mapper - will be over-written by the BIOS
    #endif
	#ifdef USING_6850
		initM6850StatusRegister();
	#endif
	#ifdef USING_6850_2
		initM6850_2_StatusRegister();
	#endif
    
    return(Z80Running);
}

////////////////////////////////////////////////////////////////////////////
// main() - Setup and Loop code goes in here

int main(void)
{
	uint16 USB_To_Z80_RxBytes_count = 0;    
	uint8 inBuffer[USBUART_Buffer_SIZE];
	uint8 uartReadBuffer[USBUART_uartBuffer_SIZE];
    uint16 uartReadBufferOff = 0;
	uint8 Z80Running;
	uint16 inCount;
    uint32 sectorNumber = 0;
    
    Z80Running = initZ80PSOC();
    // Code has two loops - one for when Z80 is running with PSoC as Z80 I/O handler - other as PSoC monitor with Z80 in reset
    if (Z80Running == 1)    // Z80 Running (RUN front panel switch pushed)
	{
		for(;;)
		{
			if (0u != USBUART_IsConfigurationChanged()) // Host can send double SET_INTERFACE request.
			{
				/* Initialize IN endpoints when device is configured. */
				if (0u != USBUART_GetConfiguration())
				{
					/* Enumeration is done, enable OUT endpoint to receive data 
					 * from host. */
					USBUART_CDC_Init();
				}
			}
			if (0u != USBUART_GetConfiguration())       // Service USB CDC when device is configured.
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
			if ((IO_Stat_Reg_Status & IOBUSY_BIT) == IOBUSY_BIT)
			{
				HandleZ80IO();
			}
            // Window for the I2C Interrupt
            #ifdef USING_MCP23017
                I2CINT_ISR_Enable();
                I2CINT_ISR_Disable();
		    #endif
		}
	}
	else                    // Z80 is not running (EXFP front panel switch pushed)
	{
		while(1)
		{			
			if (0u != USBUART_IsConfigurationChanged()) // Host can send double SET_INTERFACE request
			{
				if (0u != USBUART_GetConfiguration())   // Initialize IN endpoints when device is configured
				{
					USBUART_CDC_Init();                 // Enumeration is done, enable OUT endpoint to receive data from host
				}
			}
			
			if (0u != USBUART_GetConfiguration())       // Service USB CDC when device is configured
			{
				if (0u != USBUART_DataIsReady())        // Check for input data from host
				{
    				inCount = USBUART_GetAll(inBuffer);     // Read received data and re-enable OUT endpoint
    				if (0u != inCount)
    				{
    					while (0u == USBUART_CDCIsReady()); // Wait until component is ready to send data to host
    					if ((inBuffer[0] == 'r') || (inBuffer[0] == 'R'))
    					{
    						putStringToUSB("Read from the SD Card at 0x4000\n\r");
                            sectorNumber = 0x4000;
                            readSDCard(sectorNumber);
    					}
    					else if (inBuffer[0] == '1')
    					{
    						putStringToUSB("Read first sector from the SD Card\n\r");
                            sectorNumber = 0x0;
                            readSDCard(sectorNumber);
    					}
    					else if ((inBuffer[0] == 'n') || (inBuffer[0] == 'N'))
    					{
    						putStringToUSB("Read next sector from the SD Card\n\r");
                            sectorNumber++;
                            readSDCard(sectorNumber);
                            
    					}
    					else if ((inBuffer[0] == 'w') || (inBuffer[0] == 'W'))
    					{
    						putStringToUSB("Write to the SD Card at 2GB - 1 sector\n\r");
                            writeSDCard(0x1FFFFF);
    					}
    					else if ((inBuffer[0] == 'i') || (inBuffer[0] == 'I'))
    					{
    						putStringToUSB("Initialize the SD Card\n\r");
                            SDInit();
    					}
    					else if ((inBuffer[0] == 'f') || (inBuffer[0] == 'F'))
    					{
                            char lineString[16];
    						putStringToUSB("Front Panel Value - ");
                      		sprintf(lineString,"0x%08lx",fpIntVal);
                            putStringToUSB(lineString);
                            putStringToUSB("\n\r");
                            SDInit();
    					}
    					else
    					{
    						putStringToUSB("\n\rLand Boards, LLC - Z80_PSoC monitor\n\r");
    						putStringToUSB("1 - Read first sector from the SD Card\n\r");
    						putStringToUSB("N - Read next sector from the SD Card\n\r");
    						putStringToUSB("R - Read from the SD Card at 0x4000\n\r");
    						putStringToUSB("W - Write to the SD Card at 2GB - 1 sector\n\r");
    						putStringToUSB("I - Initialize SD Card\n\r");
                            putStringToUSB("F - Read Front Panel\n\r");
    						putStringToUSB("? - Print this menu\n\r");
    					}
    					/* If the last sent packet is exactly the maximum packet size, it is followed by a 
                        zero-length packet to assure that the end of the segment is properly identified by 
    					*  the terminal. */
    					if (USBUART_Buffer_SIZE == inCount)
    					{
    						while (0u == USBUART_CDCIsReady()); // Wait until component is ready to send data to PC						
    						USBUART_PutData(NULL, 0u);          // Send zero-length packet to PC
    					}
    				}
    			}
			}
            // Window for the I2C Interrupt
            #ifdef USING_MCP23017
                I2CINT_ISR_Enable();
                I2CINT_ISR_Disable();
		    #endif
		}
	}
}

/* [] END OF FILE */
