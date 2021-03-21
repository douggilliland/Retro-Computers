/**
 * @file   cpm.h
 * @brief  CP/M functions.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * CP/M functions for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Supports following #defines:
 *  - CC_FCX     To support FCX (user number in file names).
 *  - CC_FCX_DIR To support named directories in file names.
 *
 * When CC_FCX_DIR is defined, you must supply a function that
 * translates a directory name (string in upper case, up to 8
 * characters in length + ZERO), into a drive & user number
 * specification (string in upper case, up to 3 characters in
 * length + ZERO):
 *
 * char *DirToDrvUsr(char *s)
 *
 * ie - DirToDrvUsr("ROOT") == "A0"
 *
 * It must to return NULL on unknown directory names.
 *
 * See UxGetDrvUsr() for an example.
 *
 * Definitions for BDOS functions:
 *  - BF_GETDRV   25
 *  - BF_SETDRV   14
 *  - BF_USER     32
 *  - BF_DMA      26
 *  - BF_FIND1ST  17
 *  - BF_FINDNEXT 18
 *  - BF_OSVER    12
 *  - BF_CONST    11
 *  - BF_FSIZE    35
 *  - BF_OPEN     15
 *  - BF_DELETE   19
 *  - BF_CREATE   22
 *  - BF_READSEQ  20
 *  - BF_WRITESEQ 21
 *  - BF_RENAME   23
 *  - BF_CLOSE    16
 *  - BF_ATTRIB   30
 *  - BF_READRND  33
 *  - BF_WRITERND 34
 *
 * Revisions:
 *  - 19 Oct 2000 : Last revision.
 *  - 17 Apr 2004 : Added renfile function.
 *  - 16 Apr 2007 : GPL'd.
 *  - 12 Dec 2014 : Added FCX support.
 *  - 11 Feb 2015 : Added some BDOS #defines.
 *  - 03 Sep 2015 : Added FCX_DIR support (names for user areas, a sort of alias).
 *  - 08 Jan 2016 : Include ctype.h, mem.h libraries if CC_FCX is defined.
 *  - 18 Jul 2016 : Added #defines BF_READRND and BF_WRITERND.
 *  - 11 Dec 2016 : Documented. Optimized. GPL v3.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef CPM_H

#define CPM_H

// Dependencies
// ------------

#ifdef CC_FCX

#ifndef CTYPE_H
	#include <ctype.h>
#endif

#ifndef MEM_H
	#include <mem.h>
#endif

#endif

// BDOS FUNCTIONS
// --------------

#define BF_GETDRV   25
#define BF_SETDRV   14
#define BF_USER     32
#define BF_DMA      26
#define BF_FIND1ST  17
#define BF_FINDNEXT 18
#define BF_OSVER    12
#define BF_CONST    11
#define BF_FSIZE    35
#define BF_OPEN     15
#define BF_DELETE   19
#define BF_CREATE   22
#define BF_READSEQ  20
#define BF_WRITESEQ 21
#define BF_RENAME   23
#define BF_CLOSE    16
#define BF_ATTRIB   30
#define BF_READRND  33
#define BF_WRITERND 34

/**
 * @fn     unsigned int bdos_hl(unsigned int bc, unsigned int de)
 * @brief  Call to BDOS.
 * @param  bc - bc register
 * @param  de - de register
 * @return value of hl register
 */
#asm

bdos_hl
	POP	HL
	POP	DE
	POP	BC
	PUSH	BC
	PUSH	DE
	PUSH	HL
	JP	5
#endasm

/**
 * @fn     unsigned char bdos_a(unsigned int bc, unsigned int de)
 * @brief  Call to BDOS.
 * @param  bc - bc register
 * @param  de - de register
 * @return value of a register
 */
#asm

bdos_a
	POP	HL
	POP	DE
	POP	BC
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	5
	LD	H,0
	LD	L,A
	RET
#endasm


// FCX functions
// -------------

#ifdef CC_FCX

#define UX_FCX_SIZ 37
#define UX_FCX_USR 0
#define UX_FCX_DRV 1
#define UX_FCX_RRC 34	/* Random Record Number */

/**
 * @fn     unsigned char bdos_fcx_a(unsigned int bc, unsigned int de)
 * @brief  Call to BDOS with a FCX as parameter.
 *
 * This function is available if CC_FCX is defined.
 *
 * @param  bc - bc register
 * @param  de - de register
 * @return value of a register
 */
bdos_fcx_a(fun, fcx)
int fun; BYTE *fcx;
{
	int val, old_user;

	if(*fcx)
	{
		if((old_user = bdos_a(BF_USER, 0xFFFF)) != *fcx - 1)
		{
			bdos_a(BF_USER, *fcx - 1);	/* Set user to FCX user */
			val = bdos_a(fun, fcx + 1);	/* Call BDOS function */
			bdos_a(BF_USER, old_user);	/* Set old user */

			return val;
		}
	}

	return bdos_a(fun, fcx + 1);
}

/* -----------------------------------------------------
   This is an example, you must define your own funcion.
   -----------------------------------------------------

   char *DirToDrvUsr(char *s)

   Translate a directory name in upper case, to a drive
   and user name specification in upper case.

   Return NULL on unknown directory name.

DirToDrvUsr(s)
char *s;
{
	if(!strcmp(s, "ROOT"))
		return "A0";
	else if(!strcmp(s, "MESCC"))
		return "A1";
	else if(!strcmp(s, "TEMP"))
		return "M0";

	return NULL;
}
   -----------------------------------------------------
*/

/**
 * @fn     int setfcx(char *fname, char *fcx)
 * @brief  Make FCX.
 *
 * This function is available if CC_FCX is defined.
 *
 * @param  fname - filename
 * @param  fcx - destination FCX
 * @return 0 on success, else != 0
 */
setfcx(s, fcx)
char *s; BYTE *fcx;
{
	char f[9]; WORD path; BYTE drv, usr;

	memset(fcx, 0, UX_FCX_SIZ);

	s = UxField(s, f);

	if(*s == ':' && *f)
	{
		if((path = UxGetDrvUsr(f)) == -1)
			return -1;

		drv = (path >> 8) & 0xFF;
		usr = path & 0xFF;

		fcx[UX_FCX_DRV] = (drv == 0xDD ? 0 : drv + 1);
		fcx[UX_FCX_USR] = (usr == 0xDD ? 0 : usr + 1);

		s = UxField(++s, f);
	}

	if((!(*s) || *s=='.') && *f)
	{
		if(UxPad(f, fcx + 2, 8))
			return -1;

		if(*s)
			s = UxField(++s, f);
		else
			*f = 0;

		if(UxPad(f, fcx + 10, 3))
			return -1;
	}

	return *s || !fcx[2] ? -1 : 0;
}

// unsigned int UxGetDrvUsr(char *s) : get drive + user specification, or -1 on error.

UxGetDrvUsr(s)
char *s;
{
	int drv, usr;

#ifdef CC_FCX_DIR
	char *du;

	if((du = DirToDrvUsr(s)))
		s = du;
#endif

	drv = usr = 0xDD;

	if(*s >= 'A' && *s <= 'P')
		drv = *s++ -'A';

	if(isdigit(*s))
	{
			usr = 0;

			do
			{
				if((usr = usr * 10 + *s - '0') > 15)
					break;
			} while(isdigit(*++s));
	}

	if(*s)
		return -1;

	return (drv << 8) | usr;
}

// int UxPad(char *s, char *d, int n) : pad field with spaces -- return 0 on success, else -1.

UxPad(s, d, n)
char *s, *d; int n;
{
	int i; char f;

	f = ' ';

	for(i = 0; i != n; ++i)
	{
		if(*s == '*')
		{
			f = '?'; ++s; break;
		}
		else if(*s)
			*d++ = *s++;
		else
			break;
	}

	if(*s)
		return -1;

	while(i != n)
	{
		*d++ = f; ++i;
	}

	return 0;
}

// char *UxField(char *s, char *d) : get field -- return pointer to delimiter, else NULL.

// Max. length of field is 8.
// Field can be empty (zero length).
// Delimiters: ':', '.', '\0'.

UxField(s, d)
char *s, *d;
{
	char c; int i;

	for(i = 0; i != 8; ++i)
	{
		c = toupper(*s);

		if((c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '$' || c == '_' || c == '*' || c == '?')
		{
			*d++ = c; ++s;
		}
		else
			break;
	}

	*d = 0; c = *s;

	if(c == ':' || c == '.' || c == '\0')
		return s;

	return NULL;
}

/************************
UxFcxIsAmb(fcx)
BYTE *fcx;
{
	int i;

	for(i = 0; i < 11; ++i)
	{
		if(*++fcx == '?')
			return 1;
	}

	return 0;
}
*******************/

// unsigned int UxGetPath(char *path) : get user + drive spec. from path, or -1 on error.

// UxGetPath("A1:")   --> 0x0001
// UxGetPath("root:") --> ?

UxGetPath(path)
char *path;
{
	char s[9];

	path = UxField(path, s);

	if(*path == ':' && !path[1] && *s)
		return UxGetDrvUsr(s);

	return -1;
}

// unsigned int UxChdir(char *path) : change drive + user from path -- return drive + user, or -1 on error.

// UxChdir("A1:")   --> 0x0001
// UxChdir("root:") --> ?

UxChdir(path)
char *path;
{
	int du, drv, usr;

	if((du = UxGetPath(path)) != -1)
	{
		drv = (du >> 8) & 0xFF;
		usr = du & 0xFF;

		if(drv != 0xDD && drv != bdos_a(BF_GETDRV, 0))
			bdos_hl(BF_SETDRV, drv);

		if(usr != 0xDD && usr != bdos_a(BF_USER, 0xFFFF))
			bdos_hl(BF_USER, usr);

		return du;
	}

	return -1;
}

#else

/**
 * @fn     int setfcb(char *fname, char *fcb)
 * @brief  Make FCB.
 *
 * This function is available if CC_FCX is not defined.
 *
 * @param  fname - filename
 * @param  fcb - destination FCB
 * @return 0 on success, else != 0
 */
#asm

setfcb:
	POP	BC
	POP	DE
	POP	HL
	PUSH	HL		;HL = fname address
	PUSH	DE		;DE = fcb address
	PUSH	BC

	INC	HL		;Check for optional A: ... P: drive
	LD	A,(HL)
	DEC	HL
	CP	':'
	JR	NZ,sfcbdef
	LD	A,(HL)
	CALL	sfcbupp
	CP	'A'
	JR	C,sfcberr
	CP	'P' + 1
	JR	NC,sfcberr
	SUB	'A' - 1
	INC	HL
	INC	HL
	JR	sfcbdrv

sfcbdef
	XOR	A		;Default drive

sfcbdrv
	LD	(DE),A		;Set drive in fcb
	INC	DE

sfcbnam
	LD	C,'.'		;Set name in fcb
	LD	B,8
	CALL	sfcbtok
	LD	A,B
	CP	8
	JR	Z,sfcberr
	LD	A,(HL)
	OR	A
	JR	Z,sfcbtyp
	CP	'.'
	JR	NZ,sfcberr
	INC	HL

sfcbtyp
	LD	C,0		;Set type in fcb
	LD	B,3
	CALL	sfcbtok
	LD	A,(HL)
	OR	A
	JR	NZ,sfcberr

	LD	A,0		;Fill the rest of the fcb with zeroes
	LD	B,24
	CALL	sfcbset

	LD	HL,0		;Success
	RET

	;Error entry for sfcbtok

sfcbtke
	POP	HL		;Remove address from stack

sfcberr
	LD	HL,1		;Error
	RET

	;Set field (name or type)
	;
	;In:
	;	C = delimiter ('.' for name, 0 for type)
	;	B = Max. field length (8 for name, 3 for type)
	;
	;Out:
	;	B = Remain length

sfcbtok
	LD	A,(HL)		;End of string?
	OR	A
	JR	Z,sfcbspc
	CP	C		;Delimiter?
	JR	Z,sfcbspc
	CP	'*'		;Wildcard?
	JR	Z,sfcbamb

	;Accept only valid characters

	CP	'#'		;# $ %
	JR	C,sfcbtke
	CP	'%' + 1
	JR	C,sfcbtks
	CP	'0'		;0 ... 9
	JR	C,sfcbtke
	CP	'9' + 1
	JR	C,sfcbtks
	CALL	sfcbupp		;? @ A ... Z
	CP	'?'
	JR	C,sfcbtke
	CP	'Z' + 1
	JR	C,sfcbtks
	CP	'_'		;_
	JR	NZ,sfcbtke

sfcbtks
	LD	(DE),A		;Set character in fcb
	INC	HL
	INC	DE
	DJNZ	sfcbtok		;Continue upto max. length
	RET

	;Fill the remain field length with spaces,
	;and return the remain length.

sfcbspc
	LD	A,' '
	LD	C,B
	CALL	sfcbset
	LD	B,C
	RET

	;Fill the remain field length with '?'
	;and set remain length to 0.

sfcbamb
	LD	A,'?'
	INC	HL

	;Fill memory
	;
	;In:
	;	DE = address
	;	B  = length
	;	A  = value

sfcbset
	LD	(DE),A
	INC	DE
	DJNZ	sfcbset
	RET

	;Convert character to uppercase
	;
	;In:
	;	A = Character
	;
	;Out:
	;	A = Character converted to uppercase if it was: a ... z

sfcbupp
	CP	'a'
	RET	C
	CP	'z' + 1
	RET	NC
	SUB	32
	RET

#endasm

#endif

#endif

