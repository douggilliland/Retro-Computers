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

uint8 dacState;
uint8 outDataDAC;
uint8 inDataDAC;

///////////////////////////////////////////////////////////////////////////////
// void init_DAC(void) - Initialize the DAC

void init_DAC(void)
{
	WaveDAC8_Start();
	outDataDAC = 0;
	inDataDAC = 0;
}

///////////////////////////////////////////////////////////////////////////////
// void writeDAC(void) - Write to the DAC data

void writeDAC(void)
{
	outDataDAC = Z80_Data_Out_Read();
}

///////////////////////////////////////////////////////////////////////////////
// void readDAC(void) - Read the DAC data

void readDAC(void)
{
	Z80_Data_In_Write(outDataDAC);
	ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void readStatDAC(void) - Read the DAC Status

void readStatDAC(void)
{
	Z80_Data_In_Write(dacState);
	ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// void writeCmdDAC(void) - Write the DAC command
//  0 = Turn off DAC output
//  1 = Turn on DAC output

void writeCmdDAC(void)
{
	dacState = Z80_Data_Out_Read();
	if (dacState == 0)
	{
		WaveDAC8_Stop();
	}
	else if (dacState == 1)
	{
		WaveDAC8_Start();
	}
	ackIO();
}

/* [] END OF FILE */
