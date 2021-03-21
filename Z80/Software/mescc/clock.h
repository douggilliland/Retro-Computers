/**
 * @file   clock.h
 * @brief  Date & time functions for CP/M Plus.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Date & time functions for CP/M Plus, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Defined macros:
 *   - CLOCK_LEN - size of clk array in bytes
 *   - DATE_LEN  - size of dt array in words
 *
 * CP/M clock array - BYTE clk[CLOCK_LEN]:
 *   - BYTE day-low-byte   Day 1 is Sunday, 1 Jan 1978
 *   - BYTE day-high-byte
 *   - BYTE hour           BCD
 *   - BYTE minute         BCD
 *   - BYTE second         BCD
 *
 * Date array - WORD dt[DATE_LEN]:
 *   - WORD year
 *   - WORD month   = 0 is January, 1 is February, etc.
 *   - WORD day
 *   - WORD hour
 *   - WORD minute
 *   - WORD second
 *   - WORD weekday = 0 is Sunday, 1 is Monday, etc.
 *
 * Revisions:
 *  - 07 Apr 2015 : 1st version.
 *  - 23 Apr 2015 : Solved bug in setdate() - bad check in day.
 *  - 15 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 2015-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef CLOCK_H

#define CLOCK_H

char xd_mdays[] = {  // Days per month
	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
	};

#define CLOCK_LEN 5  // CP/M clock array lenght in BYTES - ie: unsigned char clk[5]
#define DATE_LEN  7  // Date array lenght in WORDS - ie: int dt[7]

/**
 * @fn     unsigned char *getclock(unsigned char *clk)
 * @brief  Get CP/M clock.
 *
 * This function fills the clk array with the current CP/M clock values.
 *
 * @param  clk - pointer to clock array
 * @return pointer to clk
 */
getclock(clk)
unsigned char *clk;
{
	// CP/M fills day, hour & minute; the A register holds the second.

	clk[4] = bdos_a(105, clk);

	return clk;
}

/**
 * @fn     void setclock(unsigned char *clk)
 * @brief  Set CP/M clock.
 *
 * This function sets the CP/M clock with the values in clk.
 *
 * @param  clk - pointer to clock array
 */
setclock(clk)
unsigned char *clk;
{
	unsigned char b[8];
	int i;

	// We don't use the BDOS function, because it resets the seconds to 0

	// Disable interrupts to avoid unwanted clock changes
	
#asm
	di
#endasm

	// Set the clock fields in SCB

	b[1] = 0xFF; // Set byte

	for(i = 0; i < 5; ++i)
	{
		b[0] = 0x58 + i; b[2] = clk[i]; bdos_a(49, b);
	}

	// Tell the BIOS that we have changed the clock

	b[0] = 26; b[2] = 0xFF;	bdos_a(50, b);

	// Enable interrupts
	
#asm
	ei
#endasm

}

/**
 * @fn     int *getdate(unsigned char *clk, int *dt)
 * @brief  Return date values from clock values.
 *
 * This funcion converts CP/M clock values to date values.
 *
 * @param  clk - pointer to clock array
 * @param  dt  - pointer to date array
 * @return pointer to dt
 */
getdate(clk, dt)
unsigned char *clk; int *dt;
{
	unsigned int date;
	int year, month, leap, wday;

	// Get days from CP/M clock

	date = clk[0] + (clk[1] << 8);

	// Compute weekday: 0 is Sunday, 1 is Monday, etc.

	wday = (date + 6) % 7;

	// Compute year

	for(year = 1978; date >= 365 + (leap = xd_isleap(year)); ++year)
		date -= (365 + leap);

	// Set days for February

	xd_mdays[1] = 28 + leap;

	// Compute month

	for(month = 0; date >= xd_mdays[month]; ++month)
		date -= xd_mdays[month];

	// Now, date has the day

	// Set date array fields

	dt[0] = year;   // year
	dt[1] = month;  // month
	dt[2] = date;   // day
	dt[3] = xd_getbcd(clk[2]); // hour
	dt[4] = xd_getbcd(clk[3]); // minute
	dt[5] = xd_getbcd(clk[4]); // second
	dt[6] = wday;   // Weekday

	// Return date array

	return dt;
}

/**
 * @fn     unsigned char *setdate(unsigned char *clk, int *dt)
 * @brief  Return clock values from date values.
 *
 * This funcion converts date values into CP/M clock values.
 *
 * @param  clk - pointer to clock array
 * @param  dt  - pointer to date array
 * @return pointer to clk, or NULL on failure
 */
setdate(clk, dt)
unsigned char *clk; int *dt;
{
	unsigned int days;
	int i;

	// Check year and month

	if(dt[0] < 1978 || dt[0] > 2150 || dt[1] < 0 || dt[1] > 11)
		return NULL;

	// Set days for February

	xd_mdays[1] = 28 + xd_isleap(dt[0]);

	// Check day

	if(dt[2] < 1 || dt[2] > xd_mdays[dt[1]])
		return NULL;

	// Check hour, minute and second

	if(dt[3] < 0 || dt[3] > 23 || dt[4] < 0 || dt[4] > 59 || dt[5] < 0 || dt[5] > 59)
		return NULL;

	// Compute CP/M days

	days = 0;

	for(i = 1978; i < dt[0]; ++i)
		days += (365 + xd_isleap(i));

	for(i = 0; i < dt[1]; ++i)
		days += xd_mdays[i];

	days += dt[2];

	// Set array

	clk[0] = days & 0xFF;
	clk[1] = (days >> 8) & 0xFF;
	clk[2] = xd_setbcd(dt[3]);
	clk[3] = xd_setbcd(dt[4]);
	clk[4] = xd_setbcd(dt[5]);

	// Success

	return clk;
}

// int xd_isleap(int year) : return 1 if year is leap, else 0.

xd_isleap(year)
int year;
{
	if(!(year % 4))
	{
		if(year % 100)
			return 1;

		if(!(year % 400))
			return 1;
	}

	return 0;
}

// int xd_getbcd(int bcd) : convert a BCD date field to an integer.

xd_getbcd(bcd)
int bcd;
{
	return (bcd >> 4) * 10 + (bcd & 0x0F);
}

// int xd_setbcd(int i) : convert an integer to a BCD date field.

xd_setbcd(i)
int i;
{
	return ((i / 10) << 4)	+ (i % 10);
}

#endif

