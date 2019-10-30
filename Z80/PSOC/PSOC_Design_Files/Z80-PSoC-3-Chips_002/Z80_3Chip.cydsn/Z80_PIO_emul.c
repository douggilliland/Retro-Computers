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
	uint8 chipAddr = 0x20;
    PIO_State_A = PIO_INIT;
    PIO_State_B = PIO_INIT;
    // Initialize the MCP23017
	writeRegister_MCP23017(chipAddr,MCP23017_IODIRA_REGADR,MCP23017_IODIR_ALL_INS);     // IO: Port A is inputs
	writeRegister_MCP23017(chipAddr,MCP23017_IODIRB_REGADR,MCP23017_IODIR_ALL_INS);     // IO: Port B is inputs
	writeRegister_MCP23017(chipAddr,MCP23017_IPOLA_REGADR,MCP23017_IPOL_INVERT);        // IP: Invert input pins on Port A
	writeRegister_MCP23017(chipAddr,MCP23017_IPOLB_REGADR,MCP23017_IPOL_INVERT);        // IP: Invert input pins on Port B
	writeRegister_MCP23017(chipAddr,MCP23017_GPINTENA_REGADR,MCP23017_GPINTEN_DISABLE); // GPINT: Disable interrupts
	writeRegister_MCP23017(chipAddr,MCP23017_GPINTENB_REGADR,MCP23017_GPINTEN_DISABLE); // GPINT: Disable interrupts
	writeRegister_MCP23017(chipAddr,MCP23017_DEFVALA_REGADR,0xFF);                      // Default value for pin (interrupt)
	writeRegister_MCP23017(chipAddr,MCP23017_DEFVALB_REGADR,0xFF);                      // Default value for pin (interrupt)
	writeRegister_MCP23017(chipAddr,MCP23017_INTCONA_REGADR,MCP23017_INTCON_DEFVAL);    // Int for change from previous pin
	writeRegister_MCP23017(chipAddr,MCP23017_INTCONB_REGADR,MCP23017_INTCON_DEFVAL);    // Int for change from previous pin
	// MIRROR: Int pins not connected
	// SEQOP: Enable sequential operation
	// HAEN: (Not used on MCP23017)
	// ODR: Open Drain output (over-rides INTPOL)
	// INTPOL: Over-ridden by ODR
	writeRegister_MCP23017(chipAddr,MCP23017_IOCONA_REGADR,MCP23017_IOCON_DEFVAL);      // BANK: Register addresses are sequential
	writeRegister_MCP23017(chipAddr,MCP23017_IOCONB_REGADR,MCP23017_IOCON_DEFVAL);      // Int for change from previous pin
	writeRegister_MCP23017(chipAddr,MCP23017_GPPUA_REGADR,MCP23017_GPPU_ENABLE);        // Pull-up to inputs
	writeRegister_MCP23017(chipAddr,MCP23017_GPPUB_REGADR,MCP23017_GPPU_ENABLE);        // Pull-up to inputs
	readRegister_MCP23017(chipAddr,MCP23017_INTCAPA_REGADR);                            // Clears interrupt
	readRegister_MCP23017(chipAddr,MCP23017_INTCAPB_REGADR);                            // Clears interrupt
}

void PioReadDataA(void)
{
    Z80_Data_In_Write(readRegister_MCP23017(MCP23017_PIO_ADDR,MCP23017_GPIOA_REGADR));
}

void PioWriteDataA(void)
{
    writeRegister_MCP23017(MCP23017_PIO_ADDR,MCP23017_OLATA_REGADR,Z80_Data_Out_Read());
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
    Z80_Data_In_Write(readRegister_MCP23017(MCP23017_PIO_ADDR,MCP23017_GPIOB_REGADR));
}

void PioWriteDataB(void)
{
    writeRegister_MCP23017(MCP23017_PIO_ADDR,MCP23017_OLATB_REGADR,Z80_Data_Out_Read());	
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
