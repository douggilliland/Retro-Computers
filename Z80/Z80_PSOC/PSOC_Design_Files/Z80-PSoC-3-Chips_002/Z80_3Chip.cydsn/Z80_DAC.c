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

const uint16 notes[] = {12000, 10909, 10297, 9719, 9173, 8659, 8173, 7714, 7281, 6872,
    6487, 6123, 5779, 5455, 5148, 4859, 4587, 4329, 4086, 3857, 3640, 3436,
    3243, 3061, 2889, 2727, 2574, 2430, 2293, 2165, 2043, 1928, 1820, 1718,
    1622, 1531, 1445, 1364, 1287, 1215, 1147, 1082, 1022, 964, 910, 859,
    811, 765, 722, 682, 644, 607, 573, 541, 511, 482, 455, 430, 405, 383,
    361, 341, 322, 304, 287, 271, 255, 241, 228, 215, 203, 191, 181, 170,
    161, 152, 143, 135, 128, 121, 114, 107, 101, 96, 90, 85, 80, 76, 72,
    68, 64, 60, 57, 54, 51, 48, 45, 43, 40, 38};

///////////////////////////////////////////////////////////////////////////////
// void init_DAC(void) - Initialize the DAC

void init_DAC(void)
{
	WaveDAC8_Start();
    WaveDAC8_SetSpeed(WaveDAC8_LOWSPEED);
    Sound_Counter_Start();
	outDataDAC = 0;
	inDataDAC = 0;
}

///////////////////////////////////////////////////////////////////////////////
// void writeDAC(void) - Write to the DAC data

void writeDAC(void)
{
	outDataDAC = Z80_Data_Out_Read();
    Sound_Counter_WritePeriod(notes[outDataDAC]);
	ackIO();
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
	else if (dacState == 2)
	{
		WaveDAC8_SetRange(WaveDAC8_VDAC8_RANGE_1V);
	}
	else if (dacState == 3)
	{
		WaveDAC8_SetRange(WaveDAC8_VDAC8_RANGE_4V);
	}
	else if (dacState == 4)
	{
		DAC_Control_Write(0);
	}
	else if (dacState == 5)
	{
		DAC_Control_Write(1);
	}
	else if (dacState == 6)
	{
        Sound_Counter_WritePeriod(0x0100);
	}
	else if (dacState == 7)
	{
        Sound_Counter_WritePeriod(0xFFFF);
	}
	ackIO();
}

/* [] END OF FILE */
