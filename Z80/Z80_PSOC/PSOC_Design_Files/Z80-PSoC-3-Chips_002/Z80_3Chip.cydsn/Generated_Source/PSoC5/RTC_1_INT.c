/*******************************************************************************
* File Name: RTC_1_INT.c
* Version 2.0
*
* Description:
*  This file contains the Interrupt Service Routine (ISR) for the RTC component.
*  This interrupt routine has entry pointes to overflow on time or date.
*
********************************************************************************
* Copyright 2008-2013, Cypress Semiconductor Corporation.  All rights reserved.
* You may use this file only in accordance with the license, terms, conditions,
* disclaimers, and limitations in the end user license agreement accompanying
* the software package with which this file was provided.
*******************************************************************************/

#include "RTC_1.h"
#include "CyLib.h"
#include "cyapicallbacks.h"

/* Function Prototypes */
static void RTC_1_EverySecondHandler(void);
static void RTC_1_EveryMinuteHandler(void);
static void RTC_1_EveryHourHandler(void);
static void RTC_1_EveryDayHandler(void);
static void RTC_1_EveryWeekHandler(void);
static void RTC_1_EveryMonthHandler(void);
static void RTC_1_EveryYearHandler(void);


/*******************************************************************************
*  Place your includes, defines and code here
*******************************************************************************/
/* `#START RTC_ISR_DEFINITION` */

/* `#END` */


/*******************************************************************************
* Function Name:   RTC_1_EverySecondHandler
********************************************************************************
*
* Summary:
*  This function is called every second.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EverySecondHandler(void)
{
    /*  Place your every second handler code here. */
    /* `#START EVERY_SECOND_HANDLER_CODE` */

    /* `#END` */
    
    #ifdef RTC_1_EVERY_SECOND_HANDLER_CALLBACK
        RTC_1_EverySecondHandler_Callback();
    #endif /* RTC_1_EVERY_SECOND_HANDLER_CALLBACK */
}


/*******************************************************************************
* Function Name:   RTC_1_EveryMinuteHandler
********************************************************************************
*
* Summary:
*  This function is called every minute.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryMinuteHandler(void)
{
    /*  Place your every minute handler code here. */
    /* `#START EVERY_MINUTE_HANDLER_CODE` */

    /* `#END` */

    #ifdef RTC_1_EVERY_MINUTE_HANDLER_CALLBACK
        RTC_1_EveryMinuteHandler_Callback();
    #endif /* RTC_1_EVERY_MINUTE_HANDLER_CALLBACK */    
}


/*******************************************************************************
* Function Name:   RTC_1_EveryHourHandler
********************************************************************************
*
* Summary:
*  This function is called every hour.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryHourHandler(void)
{
    /*  Place your every hour handler code here. */
    /* `#START EVERY_HOUR_HANDLER_CODE` */

    /* `#END` */
    
    #ifdef RTC_1_EVERY_HOUR_HANDLER_CALLBACK
        RTC_1_EveryHourHandler_Callback();
    #endif /* RTC_1_EVERY_HOUR_HANDLER_CALLBACK */
}


/*******************************************************************************
* Function Name:   RTC_1_EveryDayHandler
********************************************************************************
*
* Summary:
*  This function is called every day.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryDayHandler(void)
{
    /*  Place your everyday handler code here. */
    /* `#START EVERY_DAY_HANDLER_CODE` */

    /* `#END` */
    
    #ifdef RTC_1_EVERY_DAY_HANDLER_CALLBACK
        RTC_1_EveryDayHandler_Callback();
    #endif /* RTC_1_EVERY_DAY_HANDLER_CALLBACK */
}


/*******************************************************************************
* Function Name:   RTC_1_EveryWeekHandler
********************************************************************************
*
* Summary:
*  This function is called every week.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryWeekHandler(void)
{
    /*  Place your every week handler code here. */
    /* `#START EVERY_WEEK_HANDLER_CODE` */

    /* `#END` */

    #ifdef RTC_1_EVERY_WEEK_HANDLER_CALLBACK
        RTC_1_EveryWeekHandler_Callback();
    #endif /* RTC_1_EVERY_WEEK_HANDLER_CALLBACK */
}


/*******************************************************************************
* Function Name:   RTC_1_EveryMonthHandler
********************************************************************************
*
* Summary:
*  This function is called every month.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryMonthHandler(void)
{
    /*  Place your every month handler code here. */
    /* `#START EVERY_MONTH_HANDLER_CODE` */

    /* `#END` */
    
    #ifdef RTC_1_EVERY_MONTH_HANDLER_CALLBACK
        RTC_1_EveryMonthHandler_Callback();
    #endif /* RTC_1_EVERY_MONTH_HANDLER_CALLBACK */
}


/*******************************************************************************
* Function Name:   RTC_1_EveryYearHandler
********************************************************************************
*
* Summary:
*  This function is called every year.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
*******************************************************************************/
static void RTC_1_EveryYearHandler(void)
{
    /*  Place your every year handler code here. */
    /* `#START EVERY_YEAR_HANDLER_CODE` */

    /* `#END` */

    #ifdef RTC_1_EVERY_YEAR_HANDLER_CALLBACK
        RTC_1_EveryYearHandler_Callback();
    #endif /* RTC_1_EVERY_YEAR_HANDLER_CALLBACK */    
}


/*******************************************************************************
* Function Name: RTC_1_ISR
********************************************************************************
*
* Summary:
*  This ISR is executed on 1PPS (one pulse per second) event.
*  Global interrupt must be enabled to invoke this ISR.
*  This interrupt trigs every second.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Global variables:
* RTC_1_currentTimeDate, RTC_1_dstTimeDateStart,
*  RTC_1_dstTimeDateStop, RTC_1_dstTimeDateStart,
*  RTC_1_alarmCfgTimeDate, RTC_1_statusDateTime,
*  RTC_1_dstStartStatus, RTC_1_dstStartStatus,
*  RTC_1_dstStopStatus, RTC_1_alarmCurStatus: global
*  variables are used for the time/date, DST and alarm update procedure.
*
*  RTC_1_dstTimeDateStart and RTC_1_currentTimeDate:
*  are modified with the updated values.
*
*  RTC_1_statusDateTime, RTC_1_dstStartStatus,
*  RTC_1_dstStartStatus, RTC_1_dstStopStatus,
*  RTC_1_alarmCurStatus: global variables could be modified while
*  current time/date is updated.
*
* Side Effects:
*  Clears all interrupt status bits (react_int, limact_int, onepps_int, ctw_int,
*  and  ftw_int) in Power Manager Interrupt Status Register. If an interrupt
*  gets generated at the same time as a clear, the bit will remain set (which
*  causes another interrupt).
*
*******************************************************************************/
CY_ISR(RTC_1_ISR)
{
    uint8 RTC_1_tmp;

    #ifdef RTC_1_ISR_ENTRY_CALLBACK
        RTC_1_ISR_EntryCallback();
    #endif /* RTC_1_ISR_ENTRY_CALLBACK */
    
    /* Clear OPPS interrupt status flag */
    (void) CyPmReadStatus(CY_PM_ONEPPS_INT);

    /* Increment seconds counter */
    RTC_1_currentTimeDate.Sec++;

    /* Check if minute elapsed */
    if(RTC_1_currentTimeDate.Sec > RTC_1_MINUTE_ELAPSED)
    {
        /* Inc Min */
        RTC_1_currentTimeDate.Min++;

        /* Clear Sec */
        RTC_1_currentTimeDate.Sec = 0u;

        if(RTC_1_currentTimeDate.Min > RTC_1_HOUR_ELAPSED)
        {
            /* Inc HOUR */
            RTC_1_currentTimeDate.Hour++;

            /* Clear Min */
            RTC_1_currentTimeDate.Min = 0u;

            /* Day roll over */
            if(RTC_1_currentTimeDate.Hour > RTC_1_DAY_ELAPSED)
            {
                /* Inc DayOfMonth */
                RTC_1_currentTimeDate.DayOfMonth++;

                /* Clear Hour */
                RTC_1_currentTimeDate.Hour = 0u;

                /* Inc DayOfYear */
                RTC_1_currentTimeDate.DayOfYear++;

                /* Inc DayOfWeek */
                RTC_1_currentTimeDate.DayOfWeek++;

                /* Check DayOfWeek */
                if(RTC_1_currentTimeDate.DayOfWeek > RTC_1_WEEK_ELAPSED)
                {
                    /* start new week */
                    RTC_1_currentTimeDate.DayOfWeek = 1u;
                }

                /* Day of month roll over.
                * Check if day of month greater than 29 in February of leap year or
                * if day of month greater than 28 NOT in February of NON leap year or
                * if day of month greater than it should be in every month in non leap year
                */
                if(((0u != (RTC_1_statusDateTime & RTC_1_STATUS_LY)) &&
                    (RTC_1_currentTimeDate.Month == RTC_1_FEBRUARY)  &&
                    (RTC_1_currentTimeDate.DayOfMonth >
                             (RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u] + 1u))) ||
                   ((0u != (RTC_1_statusDateTime & RTC_1_STATUS_LY))  &&
                    (RTC_1_currentTimeDate.Month != RTC_1_FEBRUARY) &&
                    (RTC_1_currentTimeDate.DayOfMonth >
                                    RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u])) ||
                   ((0u == (RTC_1_statusDateTime & RTC_1_STATUS_LY))  &&
                    (RTC_1_currentTimeDate.DayOfMonth >
                                    RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u])))
                {
                    /* Inc Month */
                    RTC_1_currentTimeDate.Month++;

                    /* Set first day of month */
                    RTC_1_currentTimeDate.DayOfMonth = 1u;

                    /* Year roll over */
                    if(RTC_1_currentTimeDate.Month > RTC_1_YEAR_ELAPSED)
                    {
                        /* Inc Year */
                        RTC_1_currentTimeDate.Year++;

                        /* Set first month of year */
                        RTC_1_currentTimeDate.Month = 1u;

                        /* Set first day of year */
                        RTC_1_currentTimeDate.DayOfYear = 1u;

                        /* Is this year leap */
                        if(1u == RTC_1_LEAP_YEAR(RTC_1_currentTimeDate.Year))
                        {
                            /* Set leap year flag */
                            RTC_1_statusDateTime |= RTC_1_STATUS_LY;
                        }
                        else    /* not leap year */
                        {
                            /* Clear leap year */
                            RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_LY);
                        }

                        /* Alarm YEAR */
                        if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                             RTC_1_ALARM_YEAR_MASK))
                        {
                            /* Years match */
                            if(RTC_1_alarmCfgTimeDate.Year == RTC_1_currentTimeDate.Year)
                            {
                                /* Rise year alarm */
                                RTC_1_alarmCurStatus |= RTC_1_ALARM_YEAR_MASK;
                            }
                            else    /* Years do not match */
                            {
                                /* Clear year alarm */
                                RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_YEAR_MASK);
                            }
                        } /* do not alarm year */

                        /* Set Alarm flag event */
                        RTC_1_tmp = RTC_1_alarmCfgMask;
                        RTC_1_SET_ALARM(RTC_1_tmp,
                                                   RTC_1_alarmCurStatus,
                                                   RTC_1_statusDateTime);

                        /* Every Year */
                        if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask,
                                                             RTC_1_INTERVAL_YEAR_MASK))
                        {
                            RTC_1_EveryYearHandler();
                        }

                    } /* Month > 12 */

                    /* Alarm MONTH */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_MONTH_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.Month == RTC_1_currentTimeDate.Month)
                        {
                            /* Set month alarm */
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_MONTH_MASK;
                        }
                        else
                        {
                            /* Clear month alarm */
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_MONTH_MASK);
                        }
                    }   /* Month alarm is masked */

                    #if (1u == RTC_1_DST_FUNC_ENABLE)
                        if(RTC_1_dstTimeDateStop.Month == RTC_1_currentTimeDate.Month)
                        {
                            RTC_1_dstStopStatus |= RTC_1_DST_MONTH;
                        }
                        else
                        {
                            RTC_1_dstStopStatus &= (uint8)(~RTC_1_DST_MONTH);
                        }

                        if(RTC_1_dstTimeDateStart.Month == RTC_1_currentTimeDate.Month)
                        {
                            RTC_1_dstStartStatus |= RTC_1_DST_MONTH;
                        }
                        else
                        {
                            RTC_1_dstStartStatus &= (uint8)(~RTC_1_DST_MONTH);
                        }
                    #endif /* 1u == RTC_1_DST_FUNC_ENABLE */

                    /* Set Alarm flag event */
                    RTC_1_tmp = RTC_1_alarmCfgMask;
                    RTC_1_SET_ALARM(RTC_1_tmp,
                                               RTC_1_alarmCurStatus,
                                               RTC_1_statusDateTime);

                    /* Every Month */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask,
                                                         RTC_1_INTERVAL_MONTH_MASK))
                    {
                        RTC_1_EveryMonthHandler();
                    }
                }   /* Day roll over */

                /* Alarm DAYOFWEEK */
                if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                     RTC_1_ALARM_DAYOFWEEK_MASK))
                {
                    if(RTC_1_alarmCfgTimeDate.DayOfWeek == RTC_1_currentTimeDate.DayOfWeek)
                    {
                        /* Set day of week alarm */
                        RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFWEEK_MASK;
                    }
                    else
                    {
                        /* Clear day of week alarm */
                        RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFWEEK_MASK);
                    }
                }   /* Day of week alarm is masked */

                /* Alarm DAYOFYEAR */
                if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                     RTC_1_ALARM_DAYOFYEAR_MASK))
                {
                    if(RTC_1_alarmCfgTimeDate.DayOfYear == RTC_1_currentTimeDate.DayOfYear)
                    {
                        /* Set day of year alarm */
                        RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFYEAR_MASK;
                    }
                    else
                    {
                        /* Clear day of year alarm */
                        RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFYEAR_MASK);
                    }
                }   /* Day of year alarm is masked */

                /* Alarm DAYOFMONTH */
                if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                         RTC_1_ALARM_DAYOFMONTH_MASK))
                {
                    if(RTC_1_alarmCfgTimeDate.DayOfMonth == RTC_1_currentTimeDate.DayOfMonth)
                    {
                        /* Set day of month alarm */
                        RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFMONTH_MASK;
                    }
                    else
                    {
                        /* Clear day of month alarm */
                        RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFMONTH_MASK);
                    }
                }   /* Day of month alarm is masked */

                #if (1u == RTC_1_DST_FUNC_ENABLE)
                    if(RTC_1_dstTimeDateStop.DayOfMonth == RTC_1_currentTimeDate.DayOfMonth)
                    {
                        RTC_1_dstStopStatus |= RTC_1_DST_DAYOFMONTH;
                    }
                    else
                    {
                        RTC_1_dstStopStatus &= (uint8)(~RTC_1_DST_DAYOFMONTH);
                    }

                    if(RTC_1_dstTimeDateStart.DayOfMonth == RTC_1_currentTimeDate.DayOfMonth)
                    {
                        RTC_1_dstStartStatus |= RTC_1_DST_DAYOFMONTH;
                    }
                    else
                    {
                        RTC_1_dstStartStatus &= (uint8)(~RTC_1_DST_DAYOFMONTH);
                    }
                #endif /* 1u == RTC_1_DST_FUNC_ENABLE */

                /* Set Alarm flag event */
                RTC_1_tmp = RTC_1_alarmCfgMask;
                RTC_1_SET_ALARM(RTC_1_tmp,
                                           RTC_1_alarmCurStatus,
                                           RTC_1_statusDateTime);

                /* Every Day */
                if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask,
                         RTC_1_INTERVAL_DAY_MASK))
                {
                    RTC_1_EveryDayHandler();
                }

                if(1u == RTC_1_currentTimeDate.DayOfWeek)
                {
                    /* Every Week */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask,
                                                         RTC_1_INTERVAL_WEEK_MASK))
                    {
                       RTC_1_EveryWeekHandler();
                    }
                }

            } /* End of day roll over */

            /* Status set PM/AM flag */
            if(RTC_1_currentTimeDate.Hour < RTC_1_HALF_OF_DAY_ELAPSED)
            {
                /* AM Hour 00:00-11:59, flag zero */
                RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_AM_PM);
            }
            else
            {
                /* PM Hour 12:00-23:59, flag set */
                RTC_1_statusDateTime |= RTC_1_STATUS_AM_PM;
            }

            #if (1u == RTC_1_DST_FUNC_ENABLE)
                if(RTC_1_dstTimeDateStop.Hour == RTC_1_currentTimeDate.Hour)
                {
                    RTC_1_dstStopStatus |= RTC_1_DST_HOUR;
                }
                else
                {
                    RTC_1_dstStopStatus &= (uint8)(~RTC_1_DST_HOUR);
                }

                if(RTC_1_dstTimeDateStart.Hour == RTC_1_currentTimeDate.Hour)
                {
                    RTC_1_dstStartStatus |= RTC_1_DST_HOUR;
                }
                else
                {
                RTC_1_dstStartStatus &= (uint8)(~RTC_1_DST_HOUR);
                }

                /* DST Enable ? */
                if(0u != RTC_1_IS_BIT_SET(RTC_1_dstModeType, RTC_1_DST_ENABLE))
                {
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_statusDateTime, RTC_1_STATUS_DST))
                    {
                        if(0u != RTC_1_IS_BIT_SET(RTC_1_dstStopStatus, RTC_1_DST_HOUR |
                                                       RTC_1_DST_DAYOFMONTH | RTC_1_DST_MONTH))
                        {
                            /* Substruct from current value of minutes, number of minutes
                            * in DST offset which is out of complete hour
                            */
                            RTC_1_currentTimeDate.Min -=
                                                RTC_1_dstOffsetMin % (RTC_1_HOUR_ELAPSED + 1u);

                            /* Is minute value negative? */
                            if(RTC_1_currentTimeDate.Min > RTC_1_HOUR_ELAPSED)
                            {
                                /* Convert to the positive.
                                * HOUR_ELAPSED -     (~currentTimeDate.Min    ) ==
                                * HOUR_ELAPSED + 1 - (~currentTimeDate.Min + 1)
                                */
                                RTC_1_currentTimeDate.Min = RTC_1_HOUR_ELAPSED -
                                                             ((uint8)(~RTC_1_currentTimeDate.Min));

                                RTC_1_currentTimeDate.Hour--;
                            }

                            RTC_1_currentTimeDate.Hour -= RTC_1_dstOffsetMin /
                                                                     (RTC_1_HOUR_ELAPSED + 1u);

                            /* Day roll over
                            * Is hour value negative? */
                            if(RTC_1_currentTimeDate.Hour > RTC_1_DAY_ELAPSED)
                            {
                                /* Convert to the positive.
                                * DAY_ELAPSED - (~currentTimeDate.Hour) ==
                                * DAY_ELAPSED + 1 - (~currentTimeDate.Hour + 1)
                                */
                                RTC_1_currentTimeDate.Hour = RTC_1_DAY_ELAPSED -
                                                              ((uint8)(~RTC_1_currentTimeDate.Hour));

                                /* Status set PM/AM flag */
                                if(RTC_1_currentTimeDate.Hour < RTC_1_HALF_OF_DAY_ELAPSED)
                                {
                                    /* AM Hour 00:00-11:59, flag zero */
                                    RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_AM_PM);
                                }
                                else
                                {
                                    /* PM Hour 12:00-23:59, flag set */
                                    RTC_1_statusDateTime |= RTC_1_STATUS_AM_PM;
                                }

                                RTC_1_currentTimeDate.DayOfMonth--;
                                RTC_1_currentTimeDate.DayOfYear--;
                                RTC_1_currentTimeDate.DayOfWeek--;

                                if(0u == RTC_1_currentTimeDate.DayOfWeek)
                                {
                                    RTC_1_currentTimeDate.DayOfWeek = RTC_1_DAYS_IN_WEEK;
                                }

                                if(0u == RTC_1_currentTimeDate.DayOfMonth)
                                {
                                    RTC_1_currentTimeDate.Month--;
                                    if(0u == RTC_1_currentTimeDate.Month)
                                    {
                                        RTC_1_currentTimeDate.Month = RTC_1_DECEMBER;

                                        RTC_1_currentTimeDate.DayOfMonth =
                                            RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u];

                                        RTC_1_currentTimeDate.Year--;

                                        if(1u == RTC_1_LEAP_YEAR(RTC_1_currentTimeDate.Year))
                                        {
                                            /* LP - true, else - false */
                                            RTC_1_statusDateTime |= RTC_1_STATUS_LY;
                                            RTC_1_currentTimeDate.DayOfYear =
                                                                                    RTC_1_DAYS_IN_LEAP_YEAR;
                                        }
                                        else
                                        {
                                            RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_LY);
                                            RTC_1_currentTimeDate.DayOfYear = RTC_1_DAYS_IN_YEAR;
                                        }
                                        RTC_1_EveryYearHandler();
                                    }
                                    else
                                    {
                                        /* Day of month roll over.
                                        * Check if day of month February 29 of leap year
                                        */
                                        if((0u != (RTC_1_statusDateTime & RTC_1_STATUS_LY)) &&
                                            (RTC_1_currentTimeDate.Month == RTC_1_FEBRUARY))
                                        {
                                            RTC_1_currentTimeDate.DayOfMonth =
                                            RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u]
                                            + 1u;
                                        }
                                        else
                                        {
                                            RTC_1_currentTimeDate.DayOfMonth =
                                            RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u];
                                        }
                                    }
                                    RTC_1_EveryMonthHandler();
                                }
                                RTC_1_EveryDayHandler();
                            }
                            RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_DST);
                            RTC_1_dstStopStatus = 0u;
                        }
                    }
                    else
                    {
                        if(0u != RTC_1_IS_BIT_SET(RTC_1_dstStartStatus,
                                                      (RTC_1_DST_HOUR | RTC_1_DST_DAYOFMONTH |
                                                       RTC_1_DST_MONTH)))
                        {
                            /* Add Hour and Min */
                            RTC_1_currentTimeDate.Min +=
                                                RTC_1_dstOffsetMin % (RTC_1_HOUR_ELAPSED + 1u);

                            if(RTC_1_currentTimeDate.Min > RTC_1_HOUR_ELAPSED)
                            {
                                /* Adjust Min */
                                RTC_1_currentTimeDate.Min -= (RTC_1_HOUR_ELAPSED + 1u);
                                RTC_1_currentTimeDate.Hour++;
                            }

                            RTC_1_currentTimeDate.Hour += RTC_1_dstOffsetMin /
                                                                     (RTC_1_HOUR_ELAPSED + 1u);

                            if(RTC_1_currentTimeDate.Hour > RTC_1_DAY_ELAPSED)
                            {
                                /* Adjust hour, add day */
                                RTC_1_currentTimeDate.Hour -= (RTC_1_DAY_ELAPSED + 1u);

                                /* Status set PM/AM flag */
                                if(RTC_1_currentTimeDate.Hour < RTC_1_HALF_OF_DAY_ELAPSED)
                                {
                                    /* AM Hour 00:00-11:59, flag zero */
                                    RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_AM_PM);
                                }
                                else
                                {
                                    /* PM Hour 12:00-23:59, flag set */
                                    RTC_1_statusDateTime |= RTC_1_STATUS_AM_PM;
                                }

                                RTC_1_currentTimeDate.DayOfMonth++;
                                RTC_1_currentTimeDate.DayOfYear++;
                                RTC_1_currentTimeDate.DayOfWeek++;

                                if(RTC_1_currentTimeDate.DayOfWeek > RTC_1_WEEK_ELAPSED)
                                {
                                    RTC_1_currentTimeDate.DayOfWeek = 1u;
                                }

                                /* Day of month roll over.
                                * Check if day of month greater than 29 in February of leap year or
                                * if day of month greater than 28 NOT in February of NON leap year or
                                * if day of month greater than it should be in every month in non leap year
                                */
                                if(((0u != (RTC_1_statusDateTime & RTC_1_STATUS_LY)) &&
                                    (RTC_1_currentTimeDate.Month == RTC_1_FEBRUARY)  &&
                                    (RTC_1_currentTimeDate.DayOfMonth >
                                  (RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u] + 1u))) ||
                                   ((0u != (RTC_1_statusDateTime & RTC_1_STATUS_LY)) &&
                                    (RTC_1_currentTimeDate.Month != RTC_1_FEBRUARY)  &&
                                    (RTC_1_currentTimeDate.DayOfMonth >
                                     RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u])) ||
                                   ((0u == (RTC_1_statusDateTime & RTC_1_STATUS_LY)) &&
                                    (RTC_1_currentTimeDate.DayOfMonth >
                                     RTC_1_daysInMonths[RTC_1_currentTimeDate.Month - 1u])))
                                {
                                    RTC_1_currentTimeDate.Month++;
                                    RTC_1_currentTimeDate.DayOfMonth = 1u;
                                    if(RTC_1_currentTimeDate.Month > RTC_1_YEAR_ELAPSED)
                                    {
                                        RTC_1_currentTimeDate.Month = RTC_1_JANUARY;
                                        RTC_1_currentTimeDate.Year++;

                                        if(1u == RTC_1_LEAP_YEAR(RTC_1_currentTimeDate.Year))
                                        {
                                            /* LP - true, else - false */
                                            RTC_1_statusDateTime |= RTC_1_STATUS_LY;
                                        }
                                        else
                                        {
                                            RTC_1_statusDateTime &= (uint8)(~RTC_1_STATUS_LY);
                                        }
                                        RTC_1_currentTimeDate.DayOfYear = 1u;

                                        RTC_1_EveryYearHandler();
                                    }
                                    RTC_1_EveryMonthHandler();
                                }
                                RTC_1_EveryDayHandler();
                            }
                            RTC_1_statusDateTime |= RTC_1_STATUS_DST;
                            RTC_1_dstStartStatus = 0u;

                            /* Month */
                            if(RTC_1_dstTimeDateStop.Month == RTC_1_currentTimeDate.Month)
                            {
                                RTC_1_dstStopStatus |= RTC_1_DST_MONTH;
                            }
                            else
                            {
                                RTC_1_dstStopStatus &= (uint8)(~RTC_1_DST_MONTH);
                            }

                            /* DayOfMonth */
                            if(RTC_1_dstTimeDateStop.DayOfMonth ==
                                                                            RTC_1_currentTimeDate.DayOfMonth)
                            {
                                RTC_1_dstStopStatus |= RTC_1_DST_DAYOFMONTH;
                            }
                            else
                            {
                                RTC_1_dstStopStatus &= (uint8)(~RTC_1_DST_DAYOFMONTH);
                            }
                        }
                    }

                    /* Alarm DAYOFWEEK */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_DAYOFWEEK_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.DayOfWeek == RTC_1_currentTimeDate.DayOfWeek)
                        {
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFWEEK_MASK;
                        }
                        else
                        {
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFWEEK_MASK);
                        }
                    }

                    /* Alarm DAYOFYEAR */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_DAYOFYEAR_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.DayOfYear == RTC_1_currentTimeDate.DayOfYear)
                        {
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFYEAR_MASK;
                        }
                        else
                        {
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFYEAR_MASK);
                        }
                    }

                    /* Alarm DAYOFMONTH */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_DAYOFMONTH_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.DayOfMonth == RTC_1_currentTimeDate.DayOfMonth)
                        {
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_DAYOFMONTH_MASK;
                        }
                        else
                        {
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_DAYOFMONTH_MASK);
                        }
                    }

                    /* Alarm MONTH */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_MONTH_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.Month == RTC_1_currentTimeDate.Month)
                        {
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_MONTH_MASK;
                        }
                        else
                        {
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_MONTH_MASK);
                        }
                    }

                    /* Alarm YEAR */
                    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask,
                                                         RTC_1_ALARM_YEAR_MASK))
                    {
                        if(RTC_1_alarmCfgTimeDate.Year == RTC_1_currentTimeDate.Year)
                        {
                            RTC_1_alarmCurStatus |= RTC_1_ALARM_YEAR_MASK;
                        }
                        else
                        {
                            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_YEAR_MASK);
                        }
                    }

                    /* Set Alarm flag event */
                    RTC_1_tmp = RTC_1_alarmCfgMask;
                    RTC_1_SET_ALARM(RTC_1_tmp,
                                               RTC_1_alarmCurStatus,
                                               RTC_1_statusDateTime);
                }
            #endif /* 1u == RTC_1_DST_FUNC_ENABLE */

            /* Alarm HOUR */
            if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask, RTC_1_ALARM_HOUR_MASK))
            {
                if(RTC_1_alarmCfgTimeDate.Hour == RTC_1_currentTimeDate.Hour)
                {
                    RTC_1_alarmCurStatus |= RTC_1_ALARM_HOUR_MASK;
                }
                else
                {
                    RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_HOUR_MASK);
                }
            }

            /* Set Alarm flag event */
            RTC_1_tmp = RTC_1_alarmCfgMask;
            RTC_1_SET_ALARM(RTC_1_tmp,
                                       RTC_1_alarmCurStatus,
                                       RTC_1_statusDateTime);

            /* Every Hour */
            if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask, RTC_1_INTERVAL_HOUR_MASK))
            {
                RTC_1_EveryHourHandler();
            }
        } /* Min > 59 = Hour */

        /* Alarm MIN */
        if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask, RTC_1_ALARM_MIN_MASK))
        {
            if(RTC_1_alarmCfgTimeDate.Min == RTC_1_currentTimeDate.Min)
            {
                RTC_1_alarmCurStatus |= RTC_1_ALARM_MIN_MASK;
            }
            else
            {
                RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_MIN_MASK);
            }
        }

        /* Set Alarm flag event */
        RTC_1_tmp = RTC_1_alarmCfgMask;
        RTC_1_SET_ALARM(RTC_1_tmp,
                                   RTC_1_alarmCurStatus,
                                   RTC_1_statusDateTime);

        /* Every Min */
        if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask, RTC_1_INTERVAL_MIN_MASK))
        {
            RTC_1_EveryMinuteHandler();
        }
    } /* Sec */

    /* Alarm SEC */
    if(0u != RTC_1_IS_BIT_SET(RTC_1_alarmCfgMask, RTC_1_ALARM_SEC_MASK))
    {
        if(RTC_1_alarmCfgTimeDate.Sec == RTC_1_currentTimeDate.Sec)
        {
            RTC_1_alarmCurStatus |= RTC_1_ALARM_SEC_MASK;
        }
        else
        {
            RTC_1_alarmCurStatus &= (uint8)(~RTC_1_ALARM_SEC_MASK);
        }
    }

    /* Set Alarm flag event */
    RTC_1_tmp = RTC_1_alarmCfgMask;
    RTC_1_SET_ALARM(RTC_1_tmp, RTC_1_alarmCurStatus, RTC_1_statusDateTime);

    /* Execute every second handler if needed */
    if(0u != RTC_1_IS_BIT_SET(RTC_1_intervalCfgMask, RTC_1_INTERVAL_SEC_MASK))
    {
        RTC_1_EverySecondHandler();
    }
    
    #ifdef RTC_1_ISR_EXIT_CALLBACK
        RTC_1_ISR_ExitCallback();
    #endif /* RTC_1_ISR_EXIT_CALLBACK */
}


/* [] END OF FILE */
