/**
 * @file   ctype.h
 * @brief  Character tests and conversion functions.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Character tests and conversion functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 19 Dec 2000 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 15 Aug 2016 : Documented. GPL v3.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef CTYPE_H

#define CTYPE_H

/**
 * @fn     int isalpha(char ch)
 * @brief  Test if ch is a letter.
 * @param  ch - character to test
 * @return true or false
 */
#asm

isalpha
	ld a,l
	ld hl,0
	cp 'A'
	ret c
	cp 'Z'+1
	jr  c,isalpha1
	cp 'a'
	ret c
	cp 'z'+1
	ret nc
isalpha1
	inc l
	ret

#endasm

/**
 * @fn     int isdigit(char ch)
 * @brief  Test if ch is a decimal digit.
 * @param  ch - character to test
 * @return true or false
 */
#asm

isdigit
	ld a,l
    ld hl,0
	cp '0'
	ret c
	cp '9'+1
	ret nc
	inc l
	ret

#endasm

/**
 * @fn     int isxdigit(char ch)
 * @brief  Test if ch is an hexadecimal digit.
 * @param  ch - character to test
 * @return true or false
 */
#asm

isxdigit
	LD	C,L
	CALL isdigit
	RET	C
	LD	HL,0
	LD	A,C
	CP	'A'
	RET	C
	CP	'G'
	JR	C,isxdigit1
	CP	'a'
	RET	C
	CP	'g'
	RET	NC
isxdigit1
	INC	L
	RET

#endasm

/**
 * @fn     int isalnum(char ch)
 * @brief  Test if ch is a letter or a decimal digit.
 * @param  ch - character to test
 * @return true or false
 */
#asm

isalnum
	LD	C,L
	CALL isdigit
	RET	C
	LD	L,C
	JP	isalpha

#endasm

/**
 * @fn     int isupper(char ch)
 * @brief  Test if ch is a letter in uppercase.
 * @param  ch - character to test
 * @return true or false
 */
#asm

isupper
	ld a,l
	ld hl,0
	cp 'A'
	ret c
	cp 'Z'+1
	ret nc
	inc l
	ret

#endasm

/**
 * @fn     int islower(char ch)
 * @brief  Test if ch is a letter in lowercase.
 * @param  ch - character to test
 * @return true or false
 */
#asm

islower
	ld a,l
	ld hl,0
	cp 'a'
	ret c
	cp 'z'+1
	ret nc
	inc l
	ret
	
#endasm

/**
 * @fn     int toupper(char ch)
 * @brief  Convert letter to uppercase.
 *
 * If ch is not a letter in lowercase, returns ch unchanged.
 *
 * @param  ch - character to convert
 * @return ch in uppercase
 */
#asm

toupper
	ld a,l
	cp 'a'
	ret c
	cp 'z'+1
	ret nc
	sub 20h
	ld l,a
	ret
	
#endasm

/**
 * @fn     int tolower(char ch)
 * @brief  Convert letter to lowercase.
 *
 * If ch is not a letter in uppercase, returns ch unchanged.
 *
 * @param  ch - character to convert
 * @return ch in lowercase
 */
#asm

tolower
	ld a,l
	cp 'A'
	ret c
	cp 'Z'+1
	ret nc
	add 20h
	ld l,a
	ret
	
#endasm

#endif

