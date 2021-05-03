/*	@(#)normbios.h	1.5		*/
#define LOADER  0
#define CTLTYPE 0
#define MEMDSK	4
#define DISKB	0
#define DISKC	5
#define DISKD	0
#define	NO_ASM_SUPPORT	0

/*
 *	the preprocessor variable MVME410 controls assignment
 *	of the lst: device in bios.c.  if the variable is defined
 *	== 1 code is included to support an mvme-410 parallel
 *	port card, if == 0 the lst: device is assumed to be
 *	the second port of the mvme-400 serial card.
 *
 *	the initialization sequence of the mvme-410 will not prevent 
 *	booting if the code is included and the card is not installed.
 *	factory default settings are assumed.
 */

#define MVME410	1
