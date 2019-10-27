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

///////////////////////////////////////////////////////////////////////////////
// Real Time Clock access from the Z80
// Status returns pointer into enum struc
// Command sets the pointer into enum struc
// Read data - gets the current field and auto-increments to the next field
// Write data - sets the current field and auto-increments to the next field

#include "Z80_RTC.h"

///////////////////////////////////////////////////////////////////////////////
// RTC State machine
// Reads and writes to the data register use these state bits
//enum rtcStates 
//{
//    RTC_SEC,
//    RTC_MIN,
//    RTC_HR,
//    RTC_DAY,
//    RTC_MON,
//    RTC_YR_HI,
//    RTC_YR_LO
//};

uint8 rtcState;

///////////////////////////////////////////////////////////////////////////////
// 

void init_Z80_RTC()
{
    RTC_Start();
    rtcState = RTC_SEC;
}

///////////////////////////////////////////////////////////////////////////////
// void commandRTC() - Set the RTC state pointer
// Normally would set to 0

void commandRTC(void)
{
    rtcState = Z80_Data_Out_Read();
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// readRTCCmd() - Send the current state pointer to the Z80

void readRTCCmd(void)
{
    Z80_Data_In_Write(rtcState);
    ackIO();

}

///////////////////////////////////////////////////////////////////////////////
// void writeRTC(uint8) - Write to RTC
// Auto-increment to the next field

void writeRTC(void)
{
    uint16 year;
    uint8 wrVal = Z80_Data_Out_Read();
    
    switch (rtcState)
    {
        case RTC_SEC:
            RTC_WriteSecond(wrVal);
            rtcState = RTC_MIN;
            break;
        case RTC_MIN:
            RTC_WriteMinute(wrVal);
            rtcState = RTC_HR;
            break;
        case RTC_HR:
            RTC_WriteHour(wrVal);
            rtcState = RTC_DAY;
            break;
        case RTC_DAY:
            RTC_WriteDayOfMonth(wrVal);
            rtcState = RTC_MON;
            break;
        case RTC_MON:
            RTC_WriteMonth(wrVal);
            rtcState = RTC_YR_LO;
            break;
        case RTC_YR_LO:
            year = wrVal;
            RTC_WriteYear(year);
            rtcState = RTC_YR_HI;
            break;
        case RTC_YR_HI:
            year = RTC_ReadYear() + (wrVal<<8);
            RTC_WriteYear(year);
            rtcState = RTC_SEC;
            break;
    }
    ackIO();
}

///////////////////////////////////////////////////////////////////////////////
// uint8 readRTC() - Read RTC
// Auto-increment to the next field

void readRTC(void)
{
    uint8 retVal = 0;
    switch (rtcState)
    {
        case RTC_SEC:
            retVal = RTC_ReadSecond();
            rtcState = RTC_MIN;
            break;
        case RTC_MIN:
            retVal = RTC_ReadMinute();
            rtcState = RTC_HR;
            break;
        case RTC_HR:
            retVal = RTC_ReadHour();
            rtcState = RTC_DAY;
            break;
        case RTC_DAY:
            retVal = RTC_ReadDayOfMonth();
            rtcState = RTC_MON;
            break;
        case RTC_MON:
            retVal = RTC_ReadMonth();
            rtcState = RTC_YR_LO;
            break;
        case RTC_YR_LO:
            retVal = (uint8)(RTC_ReadYear() & 0xff);
            rtcState = RTC_YR_HI;
            break;
        case RTC_YR_HI:
            retVal = (uint8)(RTC_ReadYear() >> 8);
            rtcState = RTC_SEC;
            break;
    }
    Z80_Data_In_Write(retVal);
    ackIO();
}
/* [] END OF FILE */
