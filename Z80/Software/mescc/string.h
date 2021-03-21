/**
 * @file   string.h
 * @brief  String functions.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * String functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Revisions:
 *  - 19 Mar 2001 : Last revision.
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
#ifndef STRING_H

#define STRING_H
			
/**
 * @fn     int strlen(char *str)
 * @brief  Return string length.
 * @param  str - string
 * @return length in characters
 */
#asm
strlen:
	LD	D,H
	LD	E,L
	LD	BC,0FFFFH
	XOR	A
	CPIR
	OR	A
	SBC	HL,DE
	DEC	HL
	RET
#endasm

/**
 * @fn     char *strcpy(char *dst, char *src)
 * @brief  Copy string.
 * @param  dst - destination string
 * @param  src - source string
 * @return pointer to dst
 */
#asm
strcpy:
	POP  BC
	POP  HL
	POP  DE
	PUSH DE
	PUSH HL
	PUSH BC

	PUSH DE

strcpy2:
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	OR	A
	JR	NZ,strcpy2
	POP	HL
	RET
#endasm

/**
 * @fn     char *strcat(char *dst, char *src)
 * @brief  Copy string at the end of another string.
 * @param  dst - destination string
 * @param  src - source string
 * @return pointer to dst
 */
#asm
strcat:
	POP  BC
	POP  HL
	POP  DE
	PUSH DE
	PUSH HL
	PUSH BC

	PUSH DE

strcat2
	LD	A,(DE)
	OR	A
	JR	Z,strcpy2
	INC	DE
	JR	strcat2
#endasm
	
/**
 * @fn     int strcmp(char *str1, char *str2)
 * @brief  Compare two strings.
 * @param  str1 - a string
 * @param  str2 - a string
 * @return <0 on str1 < str2; =0 on str1 == str2; >0 on str1 > str2
 */
#asm
strcmp
	POP  BC
	POP  HL
	POP  DE
	PUSH DE
	PUSH HL
	PUSH BC
strcmp1
	LD	A,(DE)
	CP	(HL)
	JR	NZ,strcmp2

	OR	A
	JR	Z,strcmp2

	INC	DE
	INC	HL
	JR	strcmp1

strcmp2
	LD	HL,0
	RET	Z
	JR	NC,strcmp3
	DEC	HL
	RET
strcmp3
	INC	L
	RET
#endasm

/**
 * @fn     char *strchr(char *str, char ch)
 * @brief  Search a character in a string.
 * @param  str - the string where to search
 * @param  ch  - the character to find
 * @return pointer to ch in the string, or NULL on failure
 */
#asm
strchr
	POP  BC
	POP  DE
	POP  HL
	PUSH HL
	PUSH DE
	PUSH BC
	

strchr2
	LD	A,(HL)
	CP	E
	RET	Z

	INC	HL
	OR	A
	JR	NZ,strchr2

	LD	H,A
	LD	L,A
	RET
#endasm

/**
 * @fn     char *strupr(char *str)
 * @brief  Convert a string to upper case.
 * @param  str - a string
 * @return pointer to str
 */
#asm
strupr
	POP  BC
	POP  HL
	PUSH HL
	PUSH BC

	PUSH HL

strupr1
	LD	A,(HL)
	OR	A
	JR	Z,strupr3

	CP	'a'
	JR	C,strupr2
	CP	'z'+1
	JR	NC,strupr2
	SUB	32
	LD	(HL),A

strupr2
	INC	HL
	JR	strupr1

strupr3
	POP	HL
	RET
#endasm

/**
 * @fn     int atoi(char *s)
 * @brief  Convert string to a integer.
 *
 * This function parses a string, interpreting its content as
 * a decimal integer number, until the end of the string, or
 * a non decimal digit:
 *
 * [+|-][[0..9]...][ZERO|NON_DECIMAL_DIGIT]
 *
 * Examples:
 *  - "-256"       == -256
 *  - "64"         == 64
 *  - "1024 bytes" == 1024
 *  - "what?"      == 0
 *
 * @param  s - a string
 * @return integer value
 */
atoi(s)
char *s;
{
	int sign, val;

	if(*s == '+')
	{
		++s; sign = 1;
	}
	else if(*s == '-')
	{
		++s; sign = -1;
	}
	else
		sign = 1;

	val=0;

	while(*s >= '0' && *s <= '9')
		val = val * 10 + (*s++ - '0');

	return val * sign;
}
	
#endif

