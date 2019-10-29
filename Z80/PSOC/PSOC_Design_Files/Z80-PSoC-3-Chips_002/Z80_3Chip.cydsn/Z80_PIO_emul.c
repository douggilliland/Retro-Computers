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
#include <Z80_PSoC_3Chips.h>

volatile uint8 PIO_Mask_Port_A;
volatile uint8 PIO_Vector_Address_Port_A;       // Mode 2 interrupt vector
volatile uint8 PIO_Interrupt_Vector_Port_A;
volatile uint8 PIO_Output_Register_Port_A;

volatile uint8 PIO_Mask_Port_B;
volatile uint8 PIO_Vector_Address_Port_B;
volatile uint8 PIO_Interrupt_Vector_Port_B;
volatile uint8 PIO_Output_Register_Port_B;

volatile uint8 PIO_State_A;
volatile uint8 PIO_State_B;

//////////////////////////////////////////////////////////////////////////////////////////////
// void init_PIO(void) - Initialize the PIO and the MCP23017
// From the PIO datasheet
//  The Z8O-PIO automatically enters a reset state when power is applied. The reset state
//  performs the following functions:
//      1 Both port mask registers are reset to inhibit All port data bits.
//      2. Port data bus lines are set to a high-impedance state and the Ready „handshake“
//      signals are inactive (Low) Mode 1 is automatically selected.
//      3. The vector address registers are not reset.
//      4. Both port interrupt enable flip-flops are reset.
//      5. Both port output registers are reset.
//  In addition to the automatic power-on reset, the PIO can be reset by applying an /M1 signal
//  without the presence of a /RD or /IORQ signal. If no /RD or /IORQ is detected during /M1,
//  the PlO will enter the reset state immediately after the /M1 signal goes inactive. The
//  purpose of this reset is to allow a single external gate to generate a reset without a power
//  down sequence. This approach was required due to the 40-pin packaging limitation.
//  Once the PlO has entered the internal reset state, it is held there until the PIO receives a
//  control word from the CPU.

void init_PIO(void)
{
    PIO_State_A = PIO_INIT;
    PIO_State_B = PIO_INIT;
}

void PioReadDataA(void)
{
	
}

void PioWriteDataA(void)
{
	
}

void PioWriteCtrlA(void)
{
    volatile uint8 dataFromZ80 = Z80_Data_Out_Read();
	if (PIO_State_A == PIO_CTRL)
    {
        if ((dataFromZ80 & 0x1) == 0x0)
        {
            PIO_Vector_Address_Port_A = dataFromZ80;
        }
    }
    else if (PIO_State_A == PIO_INIT)
    {
    }
}

void PioReadDataB(void)
{
	
}

void PioWriteDataB(void)
{
	
}

void PioWriteCtrlB(void)
{
	if (PIO_State_B == PIO_CTRL)
    {
        
    }
    else if (PIO_State_B == PIO_INIT)
    {
        
    }
}

/* [] END OF FILE */
