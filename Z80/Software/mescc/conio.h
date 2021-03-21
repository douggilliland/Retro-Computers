/**
 * @file   conio.h
 * @brief  Console I/O.
 * @author Miguel I. Garcia Lopez / FloppySoftware
 *
 * Console I/O functions, for MESCC (Mike's Enhanced
 * Small C Compiler for Z80 & CP/M).
 *
 * Supports following #defines:
 *  - CC_STDIO      Support for stdin, stdout & stderr.
 *  - CC_CONIO_BIOS Support for direct console I/O.
 *
 * Revisions:
 *  - 22 Jan 2001 : Last revision.
 *  - 16 Apr 2007 : GPL'd.
 *  - 21 Apr 2007 : Changed puts for ANSI compatibility.
 *  - 15 May 2007 : Bug solved - added LF output to puts.
 *  - 13 Jul 2014 : Added kbhit().
 *  - 08 Dec 2014 : Added support for stdin, stdout & stderr.
 *  - 31 Dec 2014 : Solved bug in putstr when characters are > 0x7F.
 *  - 20 Dec 2015 : Added macro CC_CONIO_BIOS to support direct console I/O using BIOS, instead of BDOS.
 *  - 08 Jan 2015 : Modified getch() when access BDOS (fn. 6 instead of 1).
 *  - 10 Dec 2016 : Documented. GPL v3.
 *
 * Copyright (c) 1999-2016 Miguel I. Garcia Lopez / FloppySoftware.
 *
 * Licensed under the GNU General Public License v3.
 *
 * http://www.floppysoftware.es
 * floppysoftware@gmail.com
 */
#ifndef CONIO_H

#define CONIO_H

/**
 * @fn     int putch(int ch)
 * @brief  Send character to the console.
 * @param  ch - character
 * @return ch
 */
#ifdef CC_CONIO_BIOS
#asm

putch
	PUSH HL
	LD   C,L
	LD   E,9
	CALL xbios
	POP  HL
	RET

xbios
	LD   HL,(1)
	LD   D,0
	ADD  HL,DE
	JP   (HL)

#endasm
#else
#asm

putch
	PUSH	HL
	LD	C,2
	LD	E,L
	CALL	5
	POP	HL
	RET
#endasm
#endif

/**
 * @fn     int getch(void)
 * @brief  Get character from the console without echo. 
 *
 * Waits until a character is available.
 *
 * @return character
 */
#ifdef CC_CONIO_BIOS
#asm

getch
	LD   E,6
	CALL xbios
	LD   H,0
	LD   L,A
	RET

#endasm
#else
#asm

getch
	LD	C,6
	LD	E,255
	CALL	5
	OR	A
	JR	Z,getch
	LD	H,0
	LD	L,A
	RET
#endasm
#endif

/**
 * @fn     int kbhit(void)
 * @brief  Tests console input status.
 * @return != 0 if a character is available, else 0.
 */
#ifdef CC_CONIO_BIOS
#asm

kbhit
	LD   E, 3
	CALL xbios
	LD   H,A
	LD   L,A
	RET

#endasm
#else
#asm

kbhit
	LD	C,11
	CALL	5
	LD	H,A
	LD	L,A
	RET
#endasm
#endif

/**
 * @fn     int getchar(void)
 * @brief  Get character from the console or stdin.
 *
 * Waits until a character is available.
 *
 * #ifdef  CC_STDIO: Returns a character from stdin, or EOF on end of file or error.
 * #ifndef CC_STDIO: Returns a character from the console. Echoes the character.
 *
 * @return character on success, else EOF.
 */
getchar()
{

#ifdef CC_STDIO

	return fgetc(stdin);

#else

	return putchar(getch());

#endif

}

/**
 * @fn     int putchar(int ch)
 * @brief  Send character to the console or stdout.
 *
 * #ifdef  CC_STDIO: Returns ch, or EOF on error.
 * #ifndef CC_STDIO: Returns ch.
 *
 * @param  ch - character
 * @return ch on success, else EOF.
 */
putchar(ch)
int ch;
{

#ifdef CC_STDIO

	return fputc(ch, stdout);

#else

	if(ch == '\n')
		putch('\r');

	return putch(ch);

#endif

}

/**
 * @fn     int putstr(char *s)
 * @brief  Send string to the console or stdout.
 *
 * #ifdef  CC_STDIO: Returns the number of characters sent, or EOF on error.
 * #ifndef CC_STDIO: Returns a non-negative value to indicate success.
 *
 * @param  s - string
 * @return number of characters sent on success, else EOF.
 */
putstr(s)
char *s;
{

#ifdef CC_STDIO

	/* FIXME : Better if call to fputs (if available) */

	int i, c;

	i = 0;

	while(*s)
	{
		/* FIXME : -1 hardcoded -- < 0 causes strange
 		   behaviour if ch > 0x7F */

		if((c = putchar(*s++)) == -1)
			return c;
		++i;
	}

	return i;
#else
	while(*s)
		putchar(*s++);

	return 0;
#endif

}

/**
 * @fn     int puts(char *s)
 * @brief  Send string + '\n' to the console or stdout.
 *
 * #ifdef  CC_STDIO: Returns the number of characters sent, or EOF on error.
 * #ifndef CC_STDIO: Returns a non-negative value to indicate success.
 *
 * @param  s - string
 * @return number of characters sent on success, else EOF.
 */
puts(s)
char *s;
{
	putstr(s);

	return putchar('\n');  /* FIXME */
}

#endif

