/*---------------------------------------------------------------------------/
/  FatFs - FAT file system module include R0.11     (C)ChaN, 2015
/    Modified by Nick Burns for use as a PSoC library header
/      Contains excerpts from ff.h, diskio.h, integer.h
/----------------------------------------------------------------------------/
/ FatFs module is a free software that opened under license policy of
/ following conditions.
/
/ Copyright (C) 2015, ChaN, all right reserved.
/
/ 1. Redistributions of source code must retain the above copyright notice,
/    this condition and the following disclaimer.
/
/ This software is provided by the copyright holder and contributors "AS IS"
/ and any warranties related to this software are DISCLAIMED.
/ The copyright owner or contributors be NOT LIABLE for any damages caused
/ by use of this software.
/---------------------------------------------------------------------------/
/ For use with fixed configuration (listed at bottom)
/---------------------------------------------------------------------------*/
#include "stdint.h"

#ifndef _FF_INTEGER
#define _FF_INTEGER

/* This type MUST be 8 bit */
typedef unsigned char	BYTE;

/* These types MUST be 16 bit */
typedef short			SHORT;
typedef unsigned short	WORD;
typedef unsigned short	WCHAR;

/* These types MUST be 16 bit or 32 bit */
typedef int				INT;
typedef unsigned int	UINT;

/* These types MUST be 32 bit */
typedef long			LONG;
typedef unsigned long	DWORD;

#endif

#ifndef _DISKIO_DEFINED
#define _DISKIO_DEFINED
typedef BYTE	DSTATUS;
// Results of Disk Functions
typedef enum {
	RES_OK = 0,		// 0: Successful
	RES_ERROR,		// 1: R/W Error
	RES_WRPRT,		// 2: Write Protected
	RES_NOTRDY,		// 3: Not Ready
	RES_PARERR		// 4: Invalid Parameter
} DRESULT;

#define STA_NOINIT		0x01	// Drive not initialized
#define STA_NODISK		0x02	// No medium in the drive
#define STA_PROTECT		0x04	// Write protected

/* Command code for disk_ioctrl fucntion */

/* Generic command (Used by FatFs) */
#define CTRL_SYNC			0	/* Complete pending write process (needed at _FS_READONLY == 0) */
#define GET_SECTOR_COUNT	1	/* Get media size (needed at _USE_MKFS == 1) */
#define GET_SECTOR_SIZE		2	/* Get sector size (needed at _MAX_SS != _MIN_SS) */
#define GET_BLOCK_SIZE		3	/* Get erase block size (needed at _USE_MKFS == 1) */
#define CTRL_TRIM			4	/* Inform device that the data on the block of sectors is no longer used (needed at _USE_TRIM == 1) */

/* Generic command (Not used by FatFs) */
#define CTRL_POWER			5	/* Get/Set power status */
#define CTRL_LOCK			6	/* Lock/Unlock media removal */
#define CTRL_EJECT			7	/* Eject media */
#define CTRL_FORMAT			8	/* Create physical format on the media */

/* MMC/SDC specific ioctl command */
#define MMC_GET_TYPE		10	/* Get card type */
#define MMC_GET_CSD			11	/* Get CSD */
#define MMC_GET_CID			12	/* Get CID */
#define MMC_GET_OCR			13	/* Get OCR */
#define MMC_GET_SDSTAT		14	/* Get SD status */

/* ATA/CF specific ioctl command */
#define ATA_GET_REV			20	/* Get F/W revision */
#define ATA_GET_MODEL		21	/* Get model name */
#define ATA_GET_SN			22	/* Get serial number */

/* MMC card type flags (MMC_GET_TYPE) */
#define CT_MMC		0x01		/* MMC ver 3 */
#define CT_SD1		0x02		/* SD ver 1 */
#define CT_SD2		0x04		/* SD ver 2 */
#define CT_SDC		(CT_SD1|CT_SD2)	/* SD */
#define CT_BLOCK	0x08		/* Block addressing */

#endif

#ifndef _FATFS
#define _FATFS	32020	/* Revision ID */

/* Definitions of volume management */
#define LD2PD(vol) (BYTE)(vol)	/* Each logical drive is bound to the same physical drive number */
#define LD2PT(vol) 0			/* Find first valid partition or in SFD */


/* Type of path name strings on FatFs API */
#ifndef _INC_TCHAR
typedef char TCHAR;
#define _T(x) x
#define _TEXT(x) x
#endif

/* File system object structure (FATFS) */
typedef struct {
	BYTE	fs_type;		/* FAT sub-type (0:Not mounted) */
	BYTE	drv;			/* Physical drive number */
	BYTE	csize;			/* Sectors per cluster (1,2,4...128) */
	BYTE	n_fats;			/* Number of FAT copies (1 or 2) */
	BYTE	wflag;			/* win[] flag (b0:dirty) */
	BYTE	fsi_flag;		/* FSINFO flags (b7:disabled, b0:dirty) */
	WORD	id;				/* File system mount ID */
	WORD	n_rootdir;		/* Number of root directory entries (FAT12/16) */
	DWORD	last_clust;		/* Last allocated cluster */
	DWORD	free_clust;		/* Number of free clusters */
	DWORD	n_fatent;		/* Number of FAT entries, = number of clusters + 2 */
	DWORD	fsize;			/* Sectors per FAT */
	DWORD	volbase;		/* Volume start sector */
	DWORD	fatbase;		/* FAT start sector */
	DWORD	dirbase;		/* Root directory start sector (FAT32:Cluster#) */
	DWORD	database;		/* Data start sector */
	DWORD	winsect;		/* Current sector appearing in the win[] */
	BYTE	win[512];	/* Disk access window for Directory, FAT (and file data at tiny cfg) */
} FATFS;

/* File object structure (FIL) */
typedef struct {
	FATFS*	fs;				/* Pointer to the related file system object (**do not change order**) */
	WORD	id;				/* Owner file system mount ID (**do not change order**) */
	BYTE	flag;			/* Status flags */
	BYTE	err;			/* Abort flag (error code) */
	DWORD	fptr;			/* File read/write pointer (Zeroed on file open) */
	DWORD	fsize;			/* File size */
	DWORD	sclust;			/* File start cluster (0:no cluster chain, always 0 when fsize is 0) */
	DWORD	clust;			/* Current cluster of fpter (not valid when fprt is 0) */
	DWORD	dsect;			/* Sector number appearing in buf[] (0:invalid) */
	DWORD	dir_sect;		/* Sector number containing the directory entry */
	BYTE*	dir_ptr;		/* Pointer to the directory entry in the win[] */
	BYTE	buf[512];	/* File private data read/write window */
} FIL;

/* Directory object structure (DIR) */
typedef struct {
	FATFS*	fs;				/* Pointer to the owner file system object (**do not change order**) */
	WORD	id;				/* Owner file system mount ID (**do not change order**) */
	WORD	index;			/* Current read/write index number */
	DWORD	sclust;			/* Table start cluster (0:Root dir) */
	DWORD	clust;			/* Current cluster */
	DWORD	sect;			/* Current sector */
	BYTE*	dir;			/* Pointer to the current SFN entry in the win[] */
	BYTE*	fn;				/* Pointer to the SFN (in/out) {file[8],ext[3],status[1]} */
	WCHAR*	lfn;			/* Pointer to the LFN working buffer */
	WORD	lfn_idx;		/* Last matched LFN index number (0xFFFF:No LFN) */
} DIR;

/* File information structure (FILINFO) */
typedef struct {
	DWORD	fsize;			/* File size */
	WORD	fdate;			/* Last modified date */
	WORD	ftime;			/* Last modified time */
	BYTE	fattrib;		/* Attribute */
	TCHAR	fname[13];		/* Short file name (8.3 format) */
	TCHAR*	lfname;			/* Pointer to the LFN buffer */
	UINT 	lfsize;			/* Size of LFN buffer in TCHAR */
} FILINFO;

/* File function return code (FRESULT) */
typedef enum {
	FR_OK = 0,				/* (0) Succeeded */
	FR_DISK_ERR,			/* (1) A hard error occurred in the low level disk I/O layer */
	FR_INT_ERR,				/* (2) Assertion failed */
	FR_NOT_READY,			/* (3) The physical drive cannot work */
	FR_NO_FILE,				/* (4) Could not find the file */
	FR_NO_PATH,				/* (5) Could not find the path */
	FR_INVALID_NAME,		/* (6) The path name format is invalid */
	FR_DENIED,				/* (7) Access denied due to prohibited access or directory full */
	FR_EXIST,				/* (8) Access denied due to prohibited access */
	FR_INVALID_OBJECT,		/* (9) The file/directory object is invalid */
	FR_WRITE_PROTECTED,		/* (10) The physical drive is write protected */
	FR_INVALID_DRIVE,		/* (11) The logical drive number is invalid */
	FR_NOT_ENABLED,			/* (12) The volume has no work area */
	FR_NO_FILESYSTEM,		/* (13) There is no valid FAT volume */
	FR_MKFS_ABORTED,		/* (14) The f_mkfs() aborted due to any parameter error */
	FR_TIMEOUT,				/* (15) Could not get a grant to access the volume within defined period */
	FR_LOCKED,				/* (16) The operation is rejected according to the file sharing policy */
	FR_NOT_ENOUGH_CORE,		/* (17) LFN working buffer could not be allocated */
	FR_TOO_MANY_OPEN_FILES,	/* (18) Number of open files > _FS_SHARE */
	FR_INVALID_PARAMETER	/* (19) Given parameter is invalid */
} FRESULT;

/*--------------------------------------------------------------*/
/* FatFs module application interface                           */
extern FRESULT f_open (FIL* fp, const TCHAR* path, BYTE mode);				/* Open or create a file */
extern FRESULT f_close (FIL* fp);											/* Close an open file object */
extern FRESULT f_read (FIL* fp, void* buff, UINT btr, UINT* br);			/* Read data from a file */
extern FRESULT f_write (FIL* fp, const void* buff, UINT btw, UINT* bw);	/* Write data to a file */
extern FRESULT f_forward (FIL* fp, UINT(*func)(const BYTE*,UINT), UINT btf, UINT* bf);	/* Forward data to the stream */
extern FRESULT f_lseek (FIL* fp, DWORD ofs);								/* Move file pointer of a file object */
extern FRESULT f_truncate (FIL* fp);										/* Truncate file */
extern FRESULT f_sync (FIL* fp);											/* Flush cached data of a writing file */
extern FRESULT f_opendir (DIR* dp, const TCHAR* path);						/* Open a directory */
extern FRESULT f_closedir (DIR* dp);										/* Close an open directory */
extern FRESULT f_readdir (DIR* dp, FILINFO* fno);							/* Read a directory item */
extern FRESULT f_findfirst (DIR* dp, FILINFO* fno, const TCHAR* path, const TCHAR* pattern);	/* Find first file */
extern FRESULT f_findnext (DIR* dp, FILINFO* fno);							/* Find next file */
extern FRESULT f_mkdir (const TCHAR* path);								/* Create a sub directory */
extern FRESULT f_unlink (const TCHAR* path);								/* Delete an existing file or directory */
extern FRESULT f_rename (const TCHAR* path_old, const TCHAR* path_new);	/* Rename/Move a file or directory */
extern FRESULT f_stat (const TCHAR* path, FILINFO* fno);					/* Get file status */
extern FRESULT f_chmod (const TCHAR* path, BYTE attr, BYTE mask);			/* Change attribute of the file/dir */
extern FRESULT f_utime (const TCHAR* path, const FILINFO* fno);			/* Change times-tamp of the file/dir */
extern FRESULT f_chdir (const TCHAR* path);								/* Change current directory */
extern FRESULT f_chdrive (const TCHAR* path);								/* Change current drive */
extern FRESULT f_getcwd (TCHAR* buff, UINT len);							/* Get current directory */
extern FRESULT f_getfree (const TCHAR* path, DWORD* nclst, FATFS** fatfs);	/* Get number of free clusters on the drive */
extern FRESULT f_getlabel (const TCHAR* path, TCHAR* label, DWORD* vsn);	/* Get volume label */
extern FRESULT f_setlabel (const TCHAR* label);							/* Set volume label */
extern FRESULT f_mount (FATFS* fs, const TCHAR* path, BYTE opt);			/* Mount/Unmount a logical drive */
extern FRESULT f_mkfs (const TCHAR* path, BYTE sfd, UINT au);				/* Create a file system on the volume */
extern FRESULT f_fdisk (BYTE pdrv, const DWORD szt[], void* work);			/* Divide a physical drive into some partitions */
extern int f_putc (TCHAR c, FIL* fp);										/* Put a character to the file */
extern int f_puts (const TCHAR* str, FIL* cp);								/* Put a string to the file */
extern int f_printf (FIL* fp, const TCHAR* str, ...);						/* Put a formatted string to the file */
extern TCHAR* f_gets (TCHAR* buff, int len, FIL* fp);						/* Get a string from the file */

#define f_eof(fp) ((int)((fp)->fptr == (fp)->fsize))
#define f_error(fp) ((fp)->err)
#define f_tell(fp) ((fp)->fptr)
#define f_size(fp) ((fp)->fsize)
#define f_rewind(fp) f_lseek((fp), 0)
#define f_rewinddir(dp) f_readdir((dp), 0)

#ifndef EOF
#define EOF (-1)
#endif

/* Unicode support functions */
extern WCHAR ff_convert(WCHAR chr, UINT dir);	/* OEM-Unicode bidirectional conversion */
extern WCHAR ff_wtoupper(WCHAR chr);			/* Unicode upper-case conversion */

/*--------------------------------------------------------------*/
/* Flags and offset address                                     */

/* File access control and file status flags (FIL.flag) */
#define	FA_READ				0x01
#define	FA_OPEN_EXISTING	0x00

#define	FA_WRITE			0x02
#define	FA_CREATE_NEW		0x04
#define	FA_CREATE_ALWAYS	0x08
#define	FA_OPEN_ALWAYS		0x10
#define FA__WRITTEN			0x20
#define FA__DIRTY			0x40

/* FAT sub type (FATFS.fs_type) */
#define FS_FAT12	1
#define FS_FAT16	2
#define FS_FAT32	3

/* File attribute bits for directory entry */
#define	AM_RDO	0x01	/* Read only */
#define	AM_HID	0x02	/* Hidden */
#define	AM_SYS	0x04	/* System */
#define	AM_VOL	0x08	/* Volume label */
#define AM_LFN	0x0F	/* LFN entry */
#define AM_DIR	0x10	/* Directory */
#define AM_ARC	0x20	/* Archive */
#define AM_MASK	0x3F	/* Mask of defined bits */

/* Fast seek feature */
#define CREATE_LINKMAP	0xFFFFFFFF



/*--------------------------------*/
/* Multi-byte word access macros  */
#define	LD_WORD(ptr)		(WORD)(((WORD)*((BYTE*)(ptr)+1)<<8)|(WORD)*(BYTE*)(ptr))
#define	LD_DWORD(ptr)		(DWORD)(((DWORD)*((BYTE*)(ptr)+3)<<24)|((DWORD)*((BYTE*)(ptr)+2)<<16)|((WORD)*((BYTE*)(ptr)+1)<<8)|*(BYTE*)(ptr))
#define	ST_WORD(ptr,val)	*(BYTE*)(ptr)=(BYTE)(val); *((BYTE*)(ptr)+1)=(BYTE)((WORD)(val)>>8)
#define	ST_DWORD(ptr,val)	*(BYTE*)(ptr)=(BYTE)(val); *((BYTE*)(ptr)+1)=(BYTE)((WORD)(val)>>8); *((BYTE*)(ptr)+2)=(BYTE)((DWORD)(val)>>16); *((BYTE*)(ptr)+3)=(BYTE)((DWORD)(val)>>24)

#endif /* _FATFS */

#ifndef _FF_SYSINTEGRATION
#define _FF_SYSINTEGRATION

/* Finally, define functions / types for integration as a library (Nick's additions)*/
typedef struct SPI_FUNCTIONS{       //PSOC SPI Functions needed


    void (*SPSELECTCARD)(void);
    void (*SPDESELECTCARD)(void);   //Link these to CS activation/deactivation funcs
    void (*SPSLOWCK)(void);
    void (*SPFASTCK)(void);         //Link these to clock selector funcs

    void (*SPSTART)(void);
    void (*SPSTOP)(void);           //Link these to communication hardware start / stop funcs

    BYTE (*SPEXCHANGE)(BYTE);           //link to xchg function byte rx = xchg(byte tx)
    void (*SPRXSTREAM)(BYTE*, UINT);    //link to bulk RX function: void bulkrx(ptr, len)
    void (*SPTXSTREAM)(BYTE*, UINT);    //link to bulk TX function: void bulktx(ptr, len)

    void (*PRINT)(char*);           //For debugging purposes
}SPI_FUNCTIONS;


extern void disk_attach_spifuncs(SPI_FUNCTIONS*);   //Call to attach SPI control functions
extern void disk_timerproc(void);   //To be attached to an ISR

extern DSTATUS disk_initialize(BYTE);
extern DRESULT disk_ioctl(BYTE, BYTE, void*);
extern BYTE disk_carddtype(void);

extern FRESULT scan_files (char*);

#endif // _FF_SYSINTEGRATION

/* Definitions used in ffconf to compile library:
   (and hence definitions for which above was tailored)

#define _FFCONF 32020
#define	_FS_TINY		0
#define _FS_READONLY	0
#define _FS_MINIMIZE	0
#define	_USE_STRFUNC	0
#define _USE_FIND		0
#define	_USE_MKFS		0
#define	_USE_FASTSEEK	0
#define _USE_LABEL		0
#define	_USE_FORWARD	0
#define _CODE_PAGE	437
#define	_USE_LFN	2
#define	_MAX_LFN	255
#define	_LFN_UNICODE	0
#define _STRF_ENCODE	3
#define _FS_RPATH	0
#define _VOLUMES	1
#define _STR_VOLUME_ID	0
#define _VOLUME_STRS	"RAM","NAND","CF","SD1","SD2","USB1","USB2","USB3"
#define	_MULTI_PARTITION	0
#define	_MIN_SS		512
#define	_MAX_SS		512
#define	_USE_TRIM	0
#define _FS_NOFSINFO	0
#define _FS_NORTC	1
#define _NORTC_MON	2
#define _NORTC_MDAY	1
#define _NORTC_YEAR	2015
#define	_FS_LOCK	0
#define _FS_REENTRANT	0
#define _FS_TIMEOUT		1000
#define	_SYNC_t			HANDLE
#define _WORD_ACCESS	0
*/
