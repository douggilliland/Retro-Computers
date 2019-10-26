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
    RTC_SEC,
    RTC_MIN,
    RTC_HR,
    RTC_DAY,
    RTC_MON,
    RTC_YR_HI,
    RTC_YR_LO
};

void init_Z80_RTC(void);
void commandRTC(void);
void writeRTC(void);
void readRTC(void);
void readRTCCmd(void);

    #endif

/* [] END OF FILE */
