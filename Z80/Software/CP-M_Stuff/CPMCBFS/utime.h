/*

utime.h - enough of the equivalent on UNIX to keep cpmfs.c happy

*/

#ifndef FAKE_UTIME_H
#define	FAKE_UTIME_H

struct utimbuf
	{
	time_t actime;
	time_t modtime;
	};

#endif
