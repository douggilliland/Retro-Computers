/* ========================================
 *
 * RPPSOC Example 1 Code
 *
 * Copyright Land Boards, LLC, 2016
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF LAND BOARDS.
 * MAY BE USED FOR ANY RPPSOC DEVELOPMENT.
 * 
 * This code does next to nothing.
 * It is intended to be used where there is
 * no code running on the processor.
 *
 * ========================================
*/

#include <project.h>

int main()
{
    CyGlobalIntEnable; /* Enable global interrupts. */

    /* Place your initialization/startup code here (e.g. MyInst_Start()) */

    for(;;)
    {
    }
}

/* [] END OF FILE */
