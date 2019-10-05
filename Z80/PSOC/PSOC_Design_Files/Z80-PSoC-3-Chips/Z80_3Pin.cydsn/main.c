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
    
    CyGlobalIntEnable;          /* Enable global interrupts. */
    
    // Do Power On Self Tests (POST)
    // SRAM POST
    postVal = TestSRAM();       // Run External SRAM POST
    PostLed(postVal+1);         // 1 blink = pass, more than 1 = fail
    if (postVal != 0)
        while(1);
    
    I2C_Start();
    init_FrontPanel();

    for(;;)                     // Loop forever
    {
//        writeFrontPanelLEDs(readFrontPanelSwitchesStatic());
        switchesVal ^= waitFrontPanelSwitchesPressed();
        writeFrontPanelLEDs(switchesVal);
    }
}

/* [] END OF FILE */
