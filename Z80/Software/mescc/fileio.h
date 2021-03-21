/**
 * @file   fileio.h
 * @brief  File I/O.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * File I/O for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Support standard macros:
 *  - FILE
 *  - EOF
 *  - FILENAME_MAX
 *
 * Supports following macros:
 *  - #define CC_STDIO        To support stdin, stdout & stderr.
 *  - #define CC_FCX          To support FCX (user number in file names, see cpm.h).
 *  - #define CC_FCX_DIR      To support named directories in file names (see cpm.h).
 *  - #define CC_FILEIO_SMALL To exclude fread(), fwrite() and fgets(). ===DEPRECATED===
 *  - #define CC_FOPEN_A      To include "a" and "ab" modes for fopen().
 *  - #define CC_FREAD        To include fread().
 *  - #define CC_FWRITE       To include fwrite().
 *  - #define CC_FGETS        To include fgets().
 *  - #define CC_FPUTS        To include fputs().
 *  - #define CC_FSIZE        To include fsize().
 *
 * Revisions:
 *  - 19 Mar 2001 : Last revision.
 *  - 17 Apr 2004 : Added functions: fread, fwrite, remove, rename.
 *  - 16 Apr 2007 : GPL'd.
 *  - 20 Apr 2007 : Quit "rt" and "wt" modes. Now "r" and "w" are text modes.
 *  - 10 Nov 2013 : Solved bug related to DMA in fopen, rename, remove.
 *  - 19 Nov 2013 : Reworked for UX.
 *  - 11 Dec 2013 : Added function: fgets.
 *  - 08 Dec 2014 : Added stdin, stdout, stderr support if CC_STDIO is defined.
 *  - 09 Dec 2014 : Added support to FCX if CC_FCX defined.
 *  - 18 Dec 2014 : Modified #define EOF (-1) to -1.
 *  - 16 Jan 2015 : Solved related memory bug in rename.
 *  - 16 Jan 2015 : Added FILENAME_MAX ANSI C definition.
 *  - 17 Feb 2015 : Solved bug in rename.
 *  - 07 Mar 2015 : Modified FILENAME_MAX value (now includes ZERO according to ANSI).
 *  - 09 Apr 2015 : Test ambiguous file names in fopen().
 *  - 03 May 2015 : Solved bug in fgets - last character was lost in long lines.
 *  - 17 Nov 2015 : Added FILENAME_MAX value when CC_FCX_DIR is defined.
 *  - 24 Dec 2015 : Added CC_FILEIO_SMALL define to exclude fread(), fwrite() and fgets().
 *  - 04 Jan 2016 : Removed some code from fread() and fwrite().
 *  - 08 Jan 2016 : Include mem.h library.
 *  - 19 Jul 2016 : Added "a" and "ab" modes.
 *                  Added support for CC_FOPEN_A, CC_FREAD, CC_FWRITE and CC_FGETS defines.
 *                  Removed CC_FILEIO_SMALL define.
 *  - 23 Jul 2016 : Added fputs() and support for CC_FPUTS define.
 *  - 10 Dec 2016 : Documented. Optimized. GPL v3.
 *  - 15 Dec 2016 : Optimize NULL comparisons, fgetc(), fputc().
 *  - 18 Feb 2018 : Document public macros. Rename internal macros and include them in cleaning. Rework remove() and rename(). Added FOPEN_MAX.
 *  - 03 May 2018 : Make CC_FPUTS effective (use #ifdef instead of #if).
 *  - 27 Dec 2018 : Added fsize().
 *
 * Copyright (c) 1999-2018 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef FILEIO_H

#define FILEIO_H

/* Dependencies
   ------------
*/
#ifndef CPM_H
	#include <cpm.h>
#endif

#ifndef ALLOC_H
	#include <alloc.h>
#endif

#ifndef MEM_H
	#include <mem.h>
#endif

#ifdef CC_STDIO
#ifndef CONIO_H
	#include <conio.h>
#endif
#endif

/* Public defines
   --------------
*/
#define FILE      unsigned char
#define EOF       -1
#define FOPEN_MAX 99

#ifdef CC_FCX
#ifdef CC_FCX_DIR
#define FILENAME_MAX 22  /* dusrname:filename.typ + ZERO */
#else
#define FILENAME_MAX 17  /* duu:filename.typ + ZERO */
#endif
#else
#define FILENAME_MAX 15  /* d:filename.typ + ZERO */
#endif

/* Private defines
   ---------------
*/
#define _XF_READ  1   /* Read mode */
#define _XF_WRITE 2   /* Write mode */
#define _XF_BIN   4   /* Binary mode */
#define _XF_EOF   8   /* End of file */
#define _XF_ERR   16  /* I/O error */

#define _XF_IMOD  0   /* Mode (1 byte) */
#define _XF_IPOS  1   /* Position in buffer (1 byte) */
#define _XF_IBUF  2   /* Buffer (128 bytes) */
#define _XF_IFCX  130 /* FCX (37 bytes: USER (1) + FCB (36)) */

#ifdef CC_FCX

#define _XF_ISIZ  167 /* Data block size */
#define _XF_IRND  164 /* Random record # in FCX */

#define _FILEOP   bdos_fcx_a
#define _MAKEFCB  setfcx

#define _FCB_SIZE 37

#else

#define _XF_ISIZ  166 /* Data block size */
#define _XF_IRND  163 /* Random record # in FCB */

#define _FILEOP   bdos_a
#define _MAKEFCB  setfcb

#define _FCB_SIZE 36

#endif

/**
 * @fn     FILE *fopen(char *fname, char *fmode)
 * @brief  Open file.
 *
 * Valid 'fmode' values are:
 *  - "rb" : Binary reading.
 *  - "r"  : Text reading.
 *  - "wb" : Binary writing.
 *  - "w"  : Text writing.
 *  - "a"  : Append text writing.
 *  - "ab" : Append binary writing.
 *
 * In text mode, the following translations are performed:
 *  - Reading: '\r' is ignored, '\n' is end of line.
 *  - Writing: '\n' is converted to '\r' + '\n'.
 *
 * @param  fname - filename
 * @param  fmode - file access mode
 * @return Pointer to FILE on success, else NULL.
 */
fopen(fname,fmode)
char *fname, *fmode;
{
	int mode;
	FILE *fp;

#ifdef CC_FOPEN_A
	int i;
	unsigned int *wp;
#endif

	// Mode
	if(*fmode == 'r')
		mode = _XF_READ;
	else if(*fmode=='w')
		mode = _XF_WRITE;
#ifdef CC_FOPEN_A
	else if(*fmode == 'a')
		mode = _XF_WRITE;
#endif
	else
		return NULL;

	if(*(fmode + 1) == 'b')
		mode |= _XF_BIN;
	else if(*(fmode + 1))
		return NULL;

	// Filename can't be ambiguous
	if(xfnamb(fname))
		return NULL;

	// Get memory
	if(!(fp = malloc(_XF_ISIZ)))
		return NULL;

	// Make FCB
	if(_MAKEFCB(fname, fp + _XF_IFCX))
	{
		free(fp);
		return NULL;
	}

	// Open file
	bdos_hl(BF_DMA, fp+_XF_IBUF);

	if(mode & _XF_READ)
	{
		if(_FILEOP(BF_OPEN, fp + _XF_IFCX) == 255)
		{
			free(fp);
			return NULL;
		}

		fp[_XF_IPOS] = 128;  // No data in buffer
	}
#ifdef CC_FOPEN_A
	else if(*fmode == 'a')
	{
		fp[_XF_IPOS] = 0;  // No data in buffer

		if(_FILEOP(BF_OPEN, fp + _XF_IFCX) != 255)
		{
			_FILEOP(BF_FSIZE, fp + _XF_IFCX);

			wp = fp + _XF_IRND;

			if(*(fmode + 1) != 'b' && *wp)
			{
				--(*wp);

				_FILEOP(BF_READRND, fp + _XF_IFCX);

				for(i = 0; i < 128; ++i)
				{
					if(*(fp + _XF_IBUF + fp[_XF_IPOS]++) == 0x1A)
					{
						--fp[_XF_IPOS];
						break;
					}
				}

				if(i == 128)
					++(*wp);
			}
		}
		else if(_FILEOP(BF_CREATE, fp + _XF_IFCX) == 255)
		{
			free(fp);
			return NULL;
		}
	}
#endif
	else
	{
		if(_FILEOP(BF_FIND1ST, fp + _XF_IFCX) != 255)
		{
			if(_FILEOP(BF_DELETE, fp + _XF_IFCX) == 255)
			{
				free(fp);
				return NULL;
			}
		}

		if(_FILEOP(BF_CREATE, fp + _XF_IFCX) == 255)
		{
			free(fp);
			return NULL;
		}

		fp[_XF_IPOS] = 0;  // No data in buffer
	}

	// Set file mode
	fp[_XF_IMOD] = mode;

	// Return pointer to FILE
	return fp;
}

/**
 * @fn     int fgetc(FILE *fp)
 * @brief  Read character from file.
 * @param  fp - pointer to FILE
 * @return character on success, else EOF on end of file or error
 */
fgetc(fp)
FILE *fp;
{
	int c;

#ifdef CC_STDIO

	// Console?
	if(!fp)
	{
		if((c = getch()) == '\r')
			c = '\n';
		else if (c == 0x1A)
			return EOF;

		if(c == '\n')
			putch('\r');

		return putch(c);
	}
#endif

	// File opened for reading and without errors?
	if(!(fp[_XF_IMOD] & _XF_READ) || fp[_XF_IMOD] & (_XF_EOF + _XF_ERR))
		return EOF;

	// Read binary
	if((fp[_XF_IMOD] & _XF_BIN))
		return xfgetc(fp);

	// Read text
	while((c = xfgetc(fp)) == '\r')
		;

	if(c == 0x1A)
	{
		fp[_XF_IMOD] |= _XF_EOF;
		c = EOF;
	}

	// Return character
	return c;
}

// int xfgetc(FILE *fp) : Helper for fgetc() - return next character, or EOF on end of file or error.

xfgetc(fp)
FILE *fp;
{
#ifdef CC_FOPEN_A
	unsigned int *wp;
#endif
	// Read next record if needed
	if(fp[_XF_IPOS] == 128)
	{
		bdos_hl(BF_DMA, fp+_XF_IBUF);

#ifdef CC_FOPEN_A
		if(_FILEOP(BF_READRND, fp + _XF_IFCX))
#else
		if(_FILEOP(BF_READSEQ, fp + _XF_IFCX))
#endif
		{
			fp[_XF_IMOD] |= _XF_EOF;
			return EOF;
		}

#ifdef CC_FOPEN_A
		wp = fp + _XF_IRND; ++(*wp);
#endif

		fp[_XF_IPOS] = 0;
	}

	// Get character from buffer and increment pointer
	return *(fp + _XF_IBUF + fp[_XF_IPOS]++);
}

/**
 * @fn     int fputc(int c, FILE *fp)
 * @brief  Write character to file.
 * @param  c - character
 * @param  fp - pointer to FILE
 * @return c on success, else EOF
 */
fputc(c,fp)
int c;
FILE *fp;
{

#ifdef CC_STDIO

	// Console?
	if(!fp)
	{
		if(c == '\n')
			putch('\r');

		return putch(c);
	}
#endif

	// File opened for writing and without errors?
	if(!(fp[_XF_IMOD] & _XF_WRITE) || fp[_XF_IMOD] & (_XF_EOF + _XF_ERR))
		return EOF;

	// Write binary
	if((fp[_XF_IMOD] & _XF_BIN))
		return xfputc(c, fp);

	// Write text
	if(c == '\n')
	{
		if(xfputc('\r', fp) == EOF)
			return EOF;
	}

	return xfputc(c, fp);
}

// int xfputc(int c, FILE *fp) : Helper for fputc() - return character, or EOF on error.

xfputc(c,fp)
int c;
FILE *fp;
{
#ifdef CC_FOPEN_A
	unsigned int *wp;
#endif

	// Store character in buffer and increment pointer
	*(fp + _XF_IBUF + fp[_XF_IPOS]++) = c;

	// Write record if needed
	if(fp[_XF_IPOS] == 128)
	{
		bdos_hl(BF_DMA, fp + _XF_IBUF);

#ifdef CC_FOPEN_A
		if(_FILEOP(BF_WRITERND, fp + _XF_IFCX))
#else
		if(_FILEOP(BF_WRITESEQ, fp + _XF_IFCX))
#endif
		{
			fp[_XF_IMOD] |= _XF_ERR;
			return EOF;
		}

#ifdef CC_FOPEN_A
		wp = fp + _XF_IRND; ++(*wp);
#endif

		fp[_XF_IPOS] = 0;
	}

	// Return character
	return c;
}

/**
 * @fn     int fclose(FILE *fp)
 * @brief  Close file.
 * @param  fp - pointer to FILE
 * @return 0 on success, else EOF
 */
fclose(fp)
FILE *fp;
{

#ifdef CC_STDIO

	// Console?
	if(!fp)
		return 0;
#endif

	// Writing mode?
	if(fp[_XF_IMOD] & _XF_WRITE)
	{
		while(fp[_XF_IPOS])
		{
			if(xfputc(0x1A, fp) == EOF)
				return EOF;
		}
	}

	// Close file
	bdos_hl(BF_DMA, fp + _XF_IBUF);

	if(_FILEOP(BF_CLOSE, fp + _XF_IFCX) == 255)
		return EOF;

	// Free buffer memory
	free(fp);

	// Success
	return 0;
}

/**
 * @fn     int feof(FILE *fp)
 * @brief  Test end of file.
 * @param  fp - pointer to FILE
 * @return != 0 if true, else 0
 */
feof(fp)
FILE *fp;
{

#ifdef CC_STDIO

	// Console?
	if(!fp)
		return 0;
#endif

	return fp[_XF_IMOD] & _XF_EOF;
}

/**
 * @fn     int ferror(FILE *fp)
 * @brief  Test file error.
 * @param  fp - pointer to FILE
 * @return != 0 if true, else 0
 */
ferror(fp)
FILE *fp;
{

#ifdef CC_STDIO

	// Console?
	if(!fp)
		return 0;
#endif

	return fp[_XF_IMOD] & _XF_ERR;
}

#ifdef CC_FREAD

/**
 * @fn     int fread(char *ptr, int size, int nobj, FILE *fp)
 * @brief  Read from file.
 * @param  ptr - destination buffer
 * @param  size - object size in bytes
 * @param  nobj - # of objects to read
 * @param  fp - pointer to FILE
 * @return # of objects read
 */
fread(ptr, size, nobj, fp)
unsigned char *ptr;
int size, nobj;
FILE *fp;
{
	int cobj, csize, c;

	for(cobj = 0; cobj != nobj; ++cobj)
	{
		for(csize = 0; csize != size; ++csize)
		{
			if((c = fgetc(fp)) == EOF)
				return cobj;

			*ptr++ = c;
		}
	}

	return cobj;
}

#endif

#ifdef CC_FWRITE

/**
 * @fn     int fwrite(char *ptr, int size, int nobj, FILE *fp)
 * @brief  Write to file.
 * @param  ptr - source buffer
 * @param  size - object size in bytes
 * @param  nobj - # of objects to write
 * @param  fp - pointer to FILE
 * @return # of objects written
 */
fwrite(ptr, size, nobj, fp)
unsigned char *ptr;
int size, nobj;
FILE *fp;
{
	int cobj, csize;

	for(cobj = 0; cobj != nobj; ++cobj)
	{
		for(csize = 0; csize != size; ++csize)
		{
			if(fputc(*ptr++, fp) == EOF)
				return cobj;
		}
	}

	return cobj;
}

#endif

#ifdef CC_FGETS

/**
 * @fn     char *fgets(char *str, int size, FILE *fp)
 * @brief  Read string from file.
 * @param  str - destination buffer
 * @param  size - # of max. characters to read
 * @param  fp - pointer to FILE
 * @return address of 'str' on success, else NULL
 */
fgets(str, size, fp)
char *str; int size; FILE *fp;
{
	int c;
	char *cs;

	cs = str;

	while(--size)
	{
		if((c = fgetc(fp)) == EOF)
			break;

		if((*cs++ = c) == '\n')
			break;
	}

	if(c == EOF && cs == str)
		return NULL;

	*cs = '\0';

	return str;
}

#endif

#ifdef CC_FPUTS

/**
 * @fn     int fputs(char *str, FILE *fp)
 * @brief  Write string to file.
 * @param  str - source buffer
 * @param  fp - pointer to FILE
 * @return # of characters written on success, else EOF
 */
fputs(str, fp)
char *str; FILE *fp;
{
	int i;

	for(i = 0; *str; ++i) {
		if(fputc(*str++, fp) == EOF)
			return EOF;
	}

	return i;
}

#endif

/**
 * @fn     int remove(char *fname)
 * @brief  Delete a file.
 * @param  fname - filename
 * @return 0 on success, else != 0
 */
remove(fname)
char *fname;
{
	BYTE *fc;
	int code;

	code = 0xFF; /* Error by default */

	if((fc = malloc(_FCB_SIZE)))
	{
		if(!_MAKEFCB(fname, fc))
		{
			bdos_hl(BF_DMA, 0x80);

			code = _FILEOP(BF_DELETE, fc);
		}

		free(fc);
	}

	return code != 0xFF ? 0 : -1;
}

#ifdef CC_FCX
#define _REN_BUF_SIZE 54 /* 37 + 17 */
#define _REN_OFFSET   17
#else
#define _REN_BUF_SIZE 52 /* 36 + 16 */
#define _REN_OFFSET   16
#endif

/**
 * @fn     int rename(char *oldname, char *newname)
 * @brief  Rename a file.
 * @param  oldname - old filename
 * @param  newname - new filename
 * @return 0 on success, else != 0
 */
rename(oldname, newname)
char *oldname, *newname;
{
	BYTE *fcb;
	int code;

	code = 0xFF; /* Error by default */

	if((fcb = malloc(_REN_BUF_SIZE)))
	{
		if(!_MAKEFCB(oldname, fcb))
		{
			if(!_MAKEFCB(newname, fcb + _REN_OFFSET))
			{
				/* FIXME : drive + user unchecked -- must match! */
#ifdef CC_FCX
				memcpy(fcb + 17, fcb + 18, 16);
#endif
				bdos_hl(BF_DMA, 0x0080);

				code = _FILEOP(BF_RENAME, fcb);
			}
		}

		free(fcb);
	}

	return code != 0xFF ? 0 : -1;
}

#undef _REN_BUF_SIZE
#undef _REN_OFFSET

#ifdef CC_FSIZE

#ifdef CC_FCX
#define _FSZ_RR 34
#else
#define _FSZ_RR 33
#endif

/**
 * @fn     int fsize(char *fname)
 * @brief  Get the file size in units of 128 bytes.
 * @param  fname - filename
 * @return file size on success, else -1
 */
fsize(fname)
char *fname;
{
	BYTE *fc;
	int recs;

	recs = -1; /* Error by default */

	if((fc = malloc(_FCB_SIZE)))
	{
		if(!_MAKEFCB(fname, fc))
		{
			bdos_hl(BF_DMA, 0x80);

			if(_FILEOP(BF_FSIZE, fc) != 0xFF)
			{
				recs = fc[_FSZ_RR] + (fc[_FSZ_RR + 1] << 8);
			}
		}

		free(fc);
	}

	return recs;
}

#undef _FSZ_RR

#endif

// int xfnamb(char *fn) : check if fn is an ambiguous filename -- return 1 if true, else 0.
xfnamb(fn)
char *fn;
{
#ifdef STRING_H
	if(strchr(fn, '?') || strchr(fn, '*'))
		return 1;
#else
	while(*fn)
	{
		if(*fn == '?' || *fn == '*')
			return 1;

		++fn;
	}
#endif

	return 0;
}

// Cleaning
#undef _XF_READ
#undef _XF_WRITE
#undef _XF_BIN
#undef _XF_EOF
#undef _XF_ERR

#undef _XF_IMOD
#undef _XF_IPOS
#undef _XF_IBUF
#undef _XF_IFCX

#undef _XF_ISIZ
#undef _XF_IRND

#undef _FILEOP
#undef _MAKEFCB
#undef _FCB_SIZE

#endif

