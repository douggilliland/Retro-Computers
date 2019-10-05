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
#include "project.h"
#include "FrontPanel.h"

////////////////////////////////////////////////////////////////////////////
// Function prototypes

uint32 TestSRAM(void);

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
    uint32 postVal;
    uint32 switchesVal = 0;
    uint32 LEDsVal = 0;
    
    CyGlobalIntEnable;          /* Enable global interrupts. */
    
    // Do Power On Self Tests (POST)
    // SRAM POST
    postVal = TestSRAM();       // Run External SRAM POST
    PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
    if (postVal != 0)
        while(1);
    
    I2C_Start();
    init_FrontPanel();
    writeFrontPanelLEDs(LEDsVal);       // clears LEDs

    for(;;)                     // Loop forever
    {
        switchesVal = waitFrontPanelSwitchesPressed();
        if ((switchesVal & 0xff000000) != 0)    // Control switch on top row was pressed
        {
            if ((switchesVal & 0x01000000) == 0x01000000)       // Incr address and read memory
            {
                LEDsVal += 0x00000100;
                LEDsVal &= 0xffffff00;
                LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
                writeFrontPanelLEDs(LEDsVal);
            }
            else if ((switchesVal & 0x02000000) == 0x02000000)  // Store to addr, incr address and read memory
            {
                WriteExtSRAM((LEDsVal >> 8) & 0xffff,LEDsVal&0xff);
                LEDsVal += 0x00000100;
                LEDsVal &= 0xffffff00;
                LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
                writeFrontPanelLEDs(LEDsVal);
            }
            else if ((switchesVal & 0x04000000) == 0x04000000)  //Load address and read memory
            {
                LEDsVal &= 0xffffff00;
                LEDsVal |= ReadExtSRAM((LEDsVal >> 8) & 0xffff);
                writeFrontPanelLEDs(LEDsVal);
            }
            else if ((switchesVal & 0x08000000) == 0x08000000)  // Run program
            {
                
            }
            
        }
        else    // Non-control switch was pressed
        {
            LEDsVal ^= switchesVal;
            writeFrontPanelLEDs(LEDsVal);
        }
    }
}

/* [] END OF FILE */
