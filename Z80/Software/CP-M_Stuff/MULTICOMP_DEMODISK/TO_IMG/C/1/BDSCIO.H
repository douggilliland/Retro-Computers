/*
	The BDS C Standard I/O header file 	v1.4	July 18, 1980

	This file contains global definitions, for use in all C programs
	in PLACE of (yechhh) CONSTANTS. Characteristics of your system such
	as video screen size, interface port numbers and masks, buffered I/O
	allocations, etc., should all be configured just once within this
	file. Any program which needs them should contain the preprocessor
	directive:

		#include "bdscio.h"

	near the beginning. 
	Go through and set all this stuff as soon as you get the package,
	and most terminal-dependent sample programs should run much better.
	Some games (such as STONE.C and RALLY.C), which were contributed and
	beyond the scope of my ablity (or patience) to generalize, may not
	bother to use the globals from this file, alas.

*/


/*******   Some console (video) terminal characteristics:   *******/

#define TWIDTH	80	/* # of columns	*/

#define TLENGTH	24	/* # of lines	*/

#define CSTAT	0	/* Console status port	*/

#define CDATA 1		/* Console data port	*/

#define CIMASK	0x40	/* Console input data ready mask   */

#define COMASK	0x80	/* Console output data ready mask  */

#define CAHI	1	/* True if console status active high	*/

#define CRESET	0	/* True if status port needs to be reset  */

#define CRESETVAL 0	/* If CRESET is true, this is the value to send	*/

#define CLEARS	"\033E"	/* String to clear screen on console	*/

#define INTOREV	"\033p"	/* String to switch console into reverse video	*/

#define OUTAREV "\033q"	/* String to switch console OUT of reverse video  */

#define CURSOROFF "\033x5"	/* String to turn cursor off	*/

#define CURSORON "\033y5"	/* String to turn cursor on	*/

#define ESC	'\033'	/* Standard ASCII 'escape' character	*/



/***** 	 Modem characteristics:	  *****/

#define	MSTAT	2	/* Modem status port	*/

#define MDATA	3	/* Modem data port	*/

#define MIMASK	0x40	/* Modem input data ready mask	*/

#define MOMASK	0x80	/* Modem ready to send a character mask	*/

#define MAHI	1	/* True if modem status logic active high  */

#define MRESET	0	/* True if modem status port needs to be reset */

#define MRESETVAL 0	/* If MRESET true, this is the byte to send */



/**********************************************************************
	General purpose Symbolic constants:
***********************************************************************/

#define BASE 0		/* Base of CP/M system RAM (0 or 0x4200)  */

#define NULL 0		/* Used by some functions to indicate zilch */

#define EOF -1		/* Physical EOF returned by low level I/O functions */

#define ERROR -1	/* General "on error" return value */

#define OK 0		/* General purpose "no error" return value */

#define CPMEOF 0x1a	/* CP/M End-of-text-file marker (sometimes!)  */

#define SECSIZ 128	/* Physical sector size for CP/M r/w calls */

#define MAXLINE 132	/* Longest line of input expected from the console */

/*******   Number of sectors to use for buffered I/O: ***********
 * The NSECTS symbol controls the compilation of the buffered   *
 * I/O routines within STDLIB2.C, allowing each user to set the *
 * buffer size most convenient for his system, while keeping    *
 * the numbers totally invisible to the C source programs using	*
 * buffered I/O (via the BUFSIZ defined symbol.) For larger     *
 * NSECTS, the disk I/O is faster...but more ram is taken up.   *
 * Note that prior (pre 1.4) versions of the library functions  *
 * were not set up to support this customizable buffer size,    *
 * and always compiled as if NSECTS was 1 in this version. To	*
 * change the buffer size allocation, follow these steps:	*
 *								*
 *   1) Alter NSECTS to the desired value here in bdscio.h	*
 *   2) Re-compile STDLIB1.C and STDLIB2.C			*
 *   3) Use CLIB to combine STDLIB1.CRL and STDLIB2.CRL to make *
 *	a new DEFF.CRL.						*
 *								*
 * Make sure you use declare all your I/O buffers with the a	*
 * statement such as:						*
 *		char buf_name[BUFSIZ];				*
 *	 instead of the older and now obsolete:			*
 *		char buf_name[134];				*
 * 	(and always #include "bdscio.h" in your programs!)	*
 ****************************************************************/

#define NSECTS 8	/* Number of sectors to buffer up in ram */

#define BUFSIZ (NSECTS * SECSIZ + 6 )	/* Don't touch this */

struct _buf {				/* Or this...	    */
	int _fd;
	int _nleft;
	char *_nextp;
	char _buff[NSECTS * SECSIZ];
};



/****************************************************************************
	If you plan to use the high-level storage allocation functions
	from the library ("alloc" and "free") then:

	  1) Uncomment (enable) the "ALLOC_ON" definition, and comment out the
	     "ALLOC_OFF" definition from this file.

	  2) Re-compile STDLIB1.C, and use CLIB to transfer "alloc"
	     and "free" into the DEFF.CRL library file.

	  3) THIS IS IMPORTANT!!! Include the statement:

		_allocp = NULL;	   /* initialize allocation pointer */

	     somewhere in your "main" function PRIOR to the first use
	     of the "alloc" function. DON'T FORGET THIS INITIALIZATION!!

	Remember to include bdscio.h in ALL files of your C program.

	The lack of static variables is the reason for all this messiness.
 ****************************************************************************/

#define ALLOC_OFF 1	/* disables storage allocation if uncommented */

			/* only ONE of these two lines should be uncommented */
/*
#define ALLOC_ON 1	/* enables storgage allocation if uncommented */
*/


#ifdef ALLOC_ON			/* if storage allocation enabled, */

struct _header  {
	struct _header *_ptr;
	unsigned _size;
 };

struct _header _base;		/* declare this external data to  */
struct _header *_allocp;	/* be used by alloc() and free()  */

#endif

/*******************************************************************
	This is the end of the header file. Happy hacking.
 *******************************************************************/

