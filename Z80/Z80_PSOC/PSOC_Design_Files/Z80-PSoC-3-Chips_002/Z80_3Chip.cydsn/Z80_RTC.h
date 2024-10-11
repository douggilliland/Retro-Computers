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

#if !defined(Z80RTC_H)
#define Z80RTC_H

#include <project.h>
#include <Z80_PSoC_3Chips.h>

enum rtcStates 
{
	RTC_SEC,    // 0
	RTC_MIN,    // 1
	RTC_HR,     // 2
	RTC_DAY,    // 3
	RTC_MON,    // 4
	RTC_YR_HI,  // 5
	RTC_YR_LO   // 6
};

void init_Z80_RTC(void);
void writeCmdRTC(void);
void writeRTC(void);
void readRTC(void);
void readCmdRTC(void);

#endif

/* [] END OF FILE */
