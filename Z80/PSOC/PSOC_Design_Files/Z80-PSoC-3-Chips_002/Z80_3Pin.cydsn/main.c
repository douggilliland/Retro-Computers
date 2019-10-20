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
#include "project.h"        // all of the #includes from Cypress generated Hardware APIs
#include "stdio.h"
#include "ExtSRAM.h"
#include "FrontPanel.h"
#include "Z80_IO_Handle.h"
#include "Z80_SIO_emul.h"
#include "Hardware_Config.h"

#define USBFS_DEVICE    (0u)

/* The buffer size is equal to the maximum packet size of the IN and OUT bulk
* endpoints.
*/
#define USBUART_BUFFER_SIZE (64u)
#define LINE_STR_LENGTH     (20u)

////////////////////////////////////////////////////////////////////////////
// Function prototypes

////////////////////////////////////////////////////////////////////////////
// PostLed(postVal) - Blink the LED the number of times (postVal)

void PostLed(uint32 postVal)
{
    uint32 blinkCount = postVal;
    while(blinkCount > 0)
    {
        IO_Ctrl_Reg_Write(2);   // Turn on the LED
        CyDelay(500);
        IO_Ctrl_Reg_Write(0);   // Turn off the LED
        CyDelay(250);
        blinkCount--;   // loop as many times as the POST code
    }
}
////////////////////////////////////////////////////////////////////////////
// main() - Setup and Loop code goes in here

int main(void)
{
    uint16 USB_To_Z80_RxBytes_count = 0;    
    uint8 buffer[USBUART_BUFFER_SIZE];
    uint16 bufferOff = 0;
    
    uint32 postVal;
    
    /* Start USBFS operation with 5-V operation. */
    USBUART_Start(USBFS_DEVICE, USBUART_5V_OPERATION);

    #ifdef USING_FRONT_PANEL
        I2C_Start();
    #else
        #ifdef USING_EXP_MCCP23017
            I2C_Start();
        #endif
    #endif
    
    CyGlobalIntEnable;          /* Enable global interrupts. */
    
    // Do Power On Self Tests (POST)
    // SRAM POST
    postVal = TestSRAM();       // Run External SRAM POST
    PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
    if (postVal != 0)
        while(1);
    loadSRAM();
    
    #ifdef USING_FRONT_PANEL
        runFrontPanel();            // Exits either by pressing EXitFrontPanel or RUN button on front panel
    #else
        ExtSRAMCtl_Control = 0;     // Run if there's no Front Panel
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
                USB_To_Z80_RxBytes_count = USBUART_GetAll(buffer);
                if ((USB_To_Z80_RxBytes_count == 1) & (checkSIOReceiverBusy() == 0))     // Input 1 character immediately
                {
                    sendCharToZ80(buffer[0]);
                    USB_To_Z80_RxBytes_count = 0;
                }
            }
        }
        if (USB_To_Z80_RxBytes_count > 0)           // There are chars in the input buffer (USB -> Z80)
        {
            if (checkSIOReceiverBusy() == 0)        // Check if receive buffer can take another character
            {
                sendCharToZ80(buffer[bufferOff]);   // Send received character to Z80 SIO interface
                bufferOff++;                        // ready for next character
                USB_To_Z80_RxBytes_count--;         // worked off one character
                if (USB_To_Z80_RxBytes_count == 0)  // Sent last character to Z80
                {
                    bufferOff = 0;                  // point back to start of character in buffer
                }
            }
        }
        if ((IO_Stat_Reg_Read() & IOBUSY_BIT) == IOBUSY_BIT)
        {
            HandleZ80IO();
        }
    }
}


/* [] END OF FILE */
