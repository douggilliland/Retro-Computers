/* ========================================
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF your company.
 *
 * ========================================
*/

#include "project.h"

uint8 Count;
uint8 Buffer[128];

int main()
{
    /* Initialization Code: */
    CYGlobalIntEnable; 
    USBUART_1_Start(0, USBUART_1_3V_OPERATION);
    //!!NOTE!! Make sure this matches your board voltage!
    while (!USBUART_1_bGetConfiguration());
    USBUART_1_CDC_Init();
    /* Main Loop: */
    for (;;)
    {
        Count = USBUART_1_GetCount();
        if (Count != 0)
        /* Check for input data from PC */
        {
            USBUART_1_GetAll(Buffer);
            USBUART_1_PutData(Buffer, Count);
            /* Echo data back to PC */
            while (!USBUART_1_CDCIsReady()){}
            /* Wait for Tx to finish */
        }
    }
}