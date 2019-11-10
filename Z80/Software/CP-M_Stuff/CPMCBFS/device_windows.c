/*

device_windows.c - Modern Windows device layer

cpmtools comes with device_posix.c, which uses open, close, read, write and
lseek style APIs to get the job done. On Linux this can access files and
physical devices. It works fine on Windows, but only with files.

cpmtools comes with device_win32.c, which understands Win95 style disk I/O
functions, MS-DOS style datastructures, and the INT-13 interface.
I would think this is long dead, and indeed, I am unable to get my Windows
copy of cpmtools to access a physical device (testing on Windows 8.1 x64).

This is a merge of device_posix.c and device_win32.c, without the Win95 disk
I/O, modified to find suitable disks and to do block aligned transfers.
Only works if you are running as Administrator.
http://support.microsoft.com/kb/100027

*/

/*...sincludes:0:*/
#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "device.h"

#ifdef USE_DMALLOC
#include <dmalloc.h>
#endif

#include <windows.h>
#include <winioctl.h>
/*...e*/

/*...sDevice_open:0:*/
/*...sshow:0:*/
/*...smediaTypeName \45\ 9 characters:0:*/
static const char *mediaTypeName(enum MEDIA_TYPE mt)
	{
	switch ( mt )
		{
		case Unknown:		return "unknown";
		case RemovableMedia:	return "removable";
		case FixedMedia:	return "fixed";
		}
	if ( mt >= F5_1Pt2_512 && mt <= F3_32M_512 )
		return "floppy";
	return "?";
	}
/*...e*/
/*...sshowSize \45\ usually 6 characters:0:*/
/* 1.23MB */

#define	K 1024LL

static void showSize(char *s, long long n)
	{
	if ( n >= K*K*K*K )
		sprintf(s, "%4.2lfTB", (double)n/(K*K*K*K));
	else if ( n >= K*K*K )
		sprintf(s, "%4.2lfGB", (double)n/(K*K*K));
	else if ( n >= K*K )
		sprintf(s, "%4.2lfMB", (double)n/(K*K));
	else if ( n >= K )
		sprintf(s, "%4.2lfKB", (double)n/(K));
	else
		sprintf(s, "%dB ", (int) n);
	}
/*...e*/
/*...svalidBytesPerSector:0:*/
static BOOLEAN validBytesPerSector(int bps)
	{
	return bps ==  128 ||
	       bps ==  256 ||
	       bps ==  512 ||
	       bps == 1024 ||
	       bps == 2048 ||
	       bps == 4096 ;
	}
/*...e*/

static void show(const char *deviceName)
	{
	HANDLE h;
	DISK_GEOMETRY dg;
	DWORD dwResult;
	if ( (h = CreateFileA(
		deviceName,
		GENERIC_READ,
		FILE_SHARE_READ|FILE_SHARE_WRITE,
		NULL,
		OPEN_EXISTING,
		0,
		NULL
		)) == INVALID_HANDLE_VALUE )
		return;
	if ( DeviceIoControl(
		h,
		IOCTL_DISK_GET_DRIVE_GEOMETRY,
		NULL,
		0,
		&dg,
		sizeof(dg),
		&dwResult,
		NULL) &&
	     validBytesPerSector(dg.BytesPerSector) )
		{
		char ss[20+1];
		showSize(ss, dg.Cylinders.QuadPart*dg.TracksPerCylinder*dg.SectorsPerTrack*dg.BytesPerSector);
		fprintf(stdout, "%-40s %-9s %7lld %3d %2d %4d %8s\n",
			deviceName,
			mediaTypeName(dg.MediaType),
			dg.Cylinders.QuadPart,
			dg.TracksPerCylinder,
			dg.SectorsPerTrack,
			dg.BytesPerSector,
			ss
			);
		}
	CloseHandle(h);
	}
/*...e*/

const char *Device_open(struct Device *d, const char *filename, int mode, const char *deviceOpts)
	{
	if ( !strcmp(filename, "?") )
		{
		int i;
		char s[100+1];
		for ( i = 0; i < 64; i++ )
			{
			sprintf(s, "\\\\.\\PhysicalDrive%d", i); 
			show(s);
			}
/*
		for ( i = 0; i < 64; i++ )
			{
			int j;
			for ( j = 0; j < 32; j++ )
				{
				sprintf(s, "\\Device\\Harddisk%d\\Partition%d", i, j);
				show(s);
				}
			}
		for ( i = 0; i < 8; i++ )
			{
			sprintf(s, "\\Device\\Floppy%d", i);
			show(s);
			}
		show("\\Device\\Ramdisk");
*/
		for ( i = 0; i < 26; i++ )
			{
			sprintf(s, "\\\\.\\%c:", 'A'+i);
			show(s);
			}
		return "available devices were enumerated instead";
		}
	if ( !strncmp(filename, "\\\\.\\", 4) )
		{
		DWORD dwResult;
		DISK_GEOMETRY dg;
		int w32mode;
		switch ( mode & ~O_BINARY )
			{
			case O_RDONLY:
				w32mode = GENERIC_READ;
				break;
			case O_WRONLY:
				w32mode = GENERIC_WRITE;
				break;
			case O_RDWR:
				w32mode = GENERIC_READ|GENERIC_WRITE;
				break;
			default:
				return "invalid file mode";
			}
		if ( (d->hdisk = CreateFileA(
			filename,
			w32mode,
			FILE_SHARE_READ|FILE_SHARE_WRITE,
			NULL,
			OPEN_EXISTING,
			0,
			NULL)) == INVALID_HANDLE_VALUE )
			{
			d->opened = 0;
			return "CreateFile failed";
			}
		if ( ! DeviceIoControl(
			d->hdisk,
			IOCTL_DISK_GET_DRIVE_GEOMETRY,
			NULL,
			0,
			&dg,
			sizeof(dg),
			&dwResult,
			NULL) )
			{
			CloseHandle(d->hdisk);
			d->opened = 0;
			return "DeviceIoControl IOCTL_DISK_GET_DRIVE_GEOMETRY failed";
			}
		if ( !validBytesPerSector(dg.BytesPerSector) )
			{
			CloseHandle(d->hdisk);
			d->opened = 0;
			return "invalid BytesPerSector";
			}
		if ( ! DeviceIoControl(
			d->hdisk, FSCTL_LOCK_VOLUME,
			NULL,
			0,
			NULL,
			0,
			&dwResult,
			NULL) )
			{
			CloseHandle(d->hdisk);
			d->opened = 0;
			return "DeviceIoControl FSCTL_LOCK_VOLUME failed";
			}
		d->fd      = dg.BytesPerSector;
		d->drvtype = CPMDRV_WINNT;
		}
	else
		{
		if ( (d->fd = open(filename, mode)) == -1 )
			{
			d->opened = 0;
			return strerror(errno);
			}
		d->drvtype = CPMDRV_FILE;
		}
	d->opened = 1;
	return NULL;
	}
/*...e*/
/*...sDevice_setGeometry:0:*/
void Device_setGeometry(struct Device *d, int secLength, int sectrk, int tracks, off_t offset)
	{
	d->secLength = secLength;
	d->sectrk    = sectrk;
	d->tracks    = tracks;
	d->offset    = offset;
	}
/*...e*/
/*...sDevice_close:0:*/
const char *Device_close(struct Device *d)
	{
	switch ( d->drvtype )
		{
		case CPMDRV_WINNT:
			{
			DWORD dwResult;
			if ( d->hdisk == INVALID_HANDLE_VALUE )
				return "handle already closed";
			DeviceIoControl(
				d->hdisk, FSCTL_UNLOCK_VOLUME,
				NULL,
				0,
				NULL,
				0,
				&dwResult,
				NULL);
			DeviceIoControl(
				d->hdisk, FSCTL_DISMOUNT_VOLUME,
				NULL,
				0,
				NULL,
				0,
				&dwResult,
				NULL);
			CloseHandle(d->hdisk);
			}
			break;
		case CPMDRV_FILE:
			if ( d->fd == -1 )
				return "handle already closed";
			close(d->fd);
			break;
		}
	d->hdisk  = INVALID_HANDLE_VALUE;
	d->fd     = -1;
	d->opened = 0;
	return NULL;
	}
/*...e*/
/*...sDevice_readSector:0:*/
const char *Device_readSector(const struct Device *d, int track, int sector, char *buf)
	{
	off_t offset = (off_t) (((sector+track*d->sectrk)*d->secLength)+d->offset);
	switch ( d->drvtype )
		{
		case CPMDRV_WINNT:
			{
			DWORD dwBytes;
			int bps = d->fd;
			off_t offset_sec = (offset/bps)*bps;
			char buf_sec[4096];
			if ( bps % d->secLength )
				return "device block size must be a multiple of CP/M sector size";
			if ( SetFilePointer(
				d->hdisk,
				offset_sec,
				NULL,
				FILE_BEGIN) == INVALID_FILE_SIZE )
				return "bad seek prior to read";
			if ( ! ReadFile(
				d->hdisk,
				buf_sec,
				bps,
				&dwBytes,
				NULL) )
				return "error reading";
			if ( (int) dwBytes < bps )
				/* hit end of disk image */
				memset(buf_sec+dwBytes,0,bps-dwBytes);
			memcpy(buf, buf_sec+offset-offset_sec, d->secLength);
			}
			break;
		case CPMDRV_FILE:
			{
			int res;
			if ( lseek(d->fd,offset,SEEK_SET)==-1 ) 
				return strerror(errno);
			if ( (res=read(d->fd, buf, d->secLength)) == -1 )
				return strerror(errno);
			if ( res < d->secLength )
				/* hit end of disk image */
				memset(buf+res,0,d->secLength-res);
			}
			break;
		}
	return NULL;
	}
/*...e*/
/*...sDevice_writeSector:0:*/
const char *Device_writeSector(const struct Device *d, int track, int sector, const char *buf)
	{
	off_t offset = (off_t) (((sector+track*d->sectrk)*d->secLength)+d->offset);
	switch ( d->drvtype )
		{
		case CPMDRV_WINNT:
			{
			DWORD dwBytes;
			int bps = d->fd;
			off_t offset_sec = (offset/bps)*bps;
			char buf_sec[4096];
			if ( bps % d->secLength )
				return "device block size must be a multiple of CP/M sector size";
			if ( SetFilePointer(
				d->hdisk,
				offset_sec,
				NULL,
				FILE_BEGIN) == INVALID_FILE_SIZE )
				return "bad seek prior to read";
			if ( ! ReadFile(
				d->hdisk,
				buf_sec,
				bps,
				&dwBytes,
				NULL) )
				return "error reading";
			if ( (int) dwBytes < bps )
				/* hit end of disk image */
				memset(buf_sec+dwBytes,0,bps-dwBytes);
			memcpy(buf_sec+offset-offset_sec, buf, d->secLength);
			if ( SetFilePointer(
				d->hdisk,
				offset_sec,
				NULL,
				FILE_BEGIN) == INVALID_FILE_SIZE )
				return "bad seek prior to write";
			if ( ! WriteFile(
				d->hdisk,
				buf_sec,
				bps,
				&dwBytes,
				NULL) )
				return "error writing";
			if ( (int) dwBytes < d->secLength )
				return "error writing";
			}
			break;
		case CPMDRV_FILE:
			{
			if ( lseek(d->fd,offset,SEEK_SET)==-1 )
				return strerror(errno);
			if ( write(d->fd, buf, d->secLength) != d->secLength )
				return strerror(errno);
			}
			break;
		}
	return NULL;
	}
/*...e*/
