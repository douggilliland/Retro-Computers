/* ========================================
 *
 * Copyright LAND BOARDS, LLC, 2019
 * All Rights Reserved
 * UNPUBLISHED, LICENSED SOFTWARE.
 *
 * CONFIDENTIAL AND PROPRIETARY INFORMATION
 * WHICH IS THE PROPERTY OF Land Boards, LLC.
 *
 * ========================================
*/

#include <project.h>
#include "Z80_PIO_emul.h"
#include "Z80_IO_Handle.h"

volatile uint8 PIO_Mask_Port_0;
volatile uint8 PIO_Vector_Address_Port_0;       // Mode 2 interrupt vector
volatile uint8 PIO_Interrupt_Vector_Port_0;
volatile uint8 PIO_Output_Register_Port_0;

volatile uint8 PIO_Mask_Port_1;
volatile uint8 PIO_Vector_Address_Port_1;
volatile uint8 PIO_Interrupt_Vector_Port_1;
volatile uint8 PIO_Output_Register_Port_1;

void PioReadDataA(void)
{
    
}

void PioWriteDataA(void)
{
    
}

void PioWriteCtrlA(void)
{
    
}

void PioReadDataB(void)
{
    
}

void PioWriteDataB(void)
{
    
}

void PioWriteCtrlB(void)
{
    
}

/* [] END OF FILE */
