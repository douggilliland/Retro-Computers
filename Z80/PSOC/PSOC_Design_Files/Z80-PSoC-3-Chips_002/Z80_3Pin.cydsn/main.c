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

extern void loadSRAM(void);

#define USBFS_DEVICE    (0u)

/* The buffer size is equal to the maximum packet size of the IN and OUT bulk
* endpoints.
*/
#define USBUART_BUFFER_SIZE (64u)
#define LINE_STR_LENGTH     (20u)

////////////////////////////////////////////////////////////////////////////
// Function prototypes

uint32 TestSRAM(void);
void HandleZ80IO(void);

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
    uint16 count;
    
    uint8 buffer[USBUART_BUFFER_SIZE];
    uint32 postVal;
    
    /* Start USBFS operation with 5-V operation. */
    USBUART_Start(USBFS_DEVICE, USBUART_5V_OPERATION);
    I2C_Start();
    
    CyGlobalIntEnable;          /* Enable global interrupts. */
    
    // Do Power On Self Tests (POST)
    // SRAM POST
    postVal = TestSRAM();       // Run External SRAM POST
    PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
    if (postVal != 0)
        while(1);
    loadSRAM();
    runFrontPanel();            // Exits either by pressing EXitFrontPanel or RUN button on front panel

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
            if (0u != USBUART_DataIsReady())
            {
                /* Read received data and re-enable OUT endpoint. */
                count = USBUART_GetAll(buffer);
                if (count == 1)     // Input 1 character immediately
                {
                    sendCharToZ80(buffer[0]);
                }
                else                // more than 1 char was in the USB packet received from the host
                {
                    putBufferToZ80(count,buffer);
                }

//                if (0u != count)
//                {
//                    /* Wait until component is ready to send data to host. */
//                    while (0u == USBUART_CDCIsReady())
//                    {
//                    }
//
//                    /* Send data back to host. */
//                    USBUART_PutData(buffer, count);
//
//                    /* If the last sent packet is exactly the maximum packet 
//                    *  size, it is followed by a zero-length packet to assure
//                    *  that the end of the segment is properly identified by 
//                    *  the terminal.
//                    */
//                    if (USBUART_BUFFER_SIZE == count)
//                    {
//                        /* Wait until component is ready to send data to PC. */
//                        while (0u == USBUART_CDCIsReady())
//                        {
//                        }
//
//                        /* Send zero-length packet to PC. */
//                        USBUART_PutData(NULL, 0u);
//                    }
//                }
                
            }
        }

        if ((IO_Stat_Reg_Read() & IOBUSY_BIT) == IOBUSY_BIT)
        {
            HandleZ80IO();
        }
    }
}


/* [] END OF FILE */
