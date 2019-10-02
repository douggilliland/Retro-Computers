/* ========================================
 *
 * Copyright YOUR COMPANY, THE YEAR
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/
#include "project.h"

////////////////////////////////////////////////////////////////////////////
// PostLed(postVal) - Blink the LED the number of times (postVal)

void PostLed(uint32 postVal)
{
    uint32 blinkCount = postVal;
    while(blinkCount > 0)
    {
        LED_Write(1);
        CyDelay(250);
        LED_Write(0);
        CyDelay(250);
        blinkCount--;
    }
}

int main(void)
{
    CyGlobalIntEnable; /* Enable global interrupts. */

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */
    if (TestSRAM() == 1)
        PostLed(0x2);

    for(;;)
    {
    }
}

/* [] END OF FILE */
