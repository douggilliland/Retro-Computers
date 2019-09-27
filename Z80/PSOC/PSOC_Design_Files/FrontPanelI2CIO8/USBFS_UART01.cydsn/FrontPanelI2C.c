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

#include <project.h>
#include "stdio.h"

uint32 ledsVal = 0;

void initDIGIO8Card(void);
void writeDIGIO8Card(uint8 outData);
uint8 readDIGIO8Card(void);

void initFrontPanelI2CIO8(void)
{
    ledsVal = 0;
    writeDIGIO8Card(ledsVal);
}

void keysAndLEDs(void)
{
    uint32 rdVal;
    uint32 valMin1, valMin2,valMin3;
    uint8 keyPressed = 0; 
    rdVal = readDIGIO8Card() ^ 0x0f;
    if (rdVal  == 0x00)     // No key is pressed at this polling
    {
        if (keyPressed == 0)    // No key press is in progress
            return;
        else    // key was pressed in the past but is no longer pressed
        {
            valMin1 = 0;
            valMin2 = 0;
            valMin3 = 0;
            return;
        }
    }
    else    // key is now pressed
    {
        keyPressed = 1;
        while (keyPressed)  // stick around until key is no longer pressed
        {
            rdVal = readDIGIO8Card() ^ 0x0f;
            if (rdVal == 0)
            {
                keyPressed = 0;
                valMin1 = 0;
                valMin2 = 0;
                valMin3 = 0;
                return;
            }
            valMin3 = valMin2;
            valMin2 = valMin1;
            valMin1 = rdVal;
            if ((valMin3 == 0) && (valMin2 != 0) && (valMin1 != 0) && (rdVal != 0))
            {
                ledsVal ^= rdVal;   // toggle the read value 3 samples later
                writeDIGIO8Card(ledsVal);
            }
            CyDelay(25);    // 10 mS sampling for debouncing
        }
    }
}
/* [] END OF FILE */
