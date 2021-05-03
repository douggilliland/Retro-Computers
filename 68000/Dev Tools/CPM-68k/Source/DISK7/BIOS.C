/*	@(#)bios.c	2.15		*/
/*=======================================================================*/
/*/---------------------------------------------------------------------\*/
/*|									|*/
/*|     CP/M-68K(tm) BIOS for the MOTOROLA VME/10			|*/
/*|									|*/
/*|     Copyright 1984, Motorola Inc.        				|*/
/*|									|*/
/*|	Created 1/27/83 lrj, jek, bjp					|*/
/*|									|*/
/*\---------------------------------------------------------------------/*/
/*=======================================================================*/

#include "biostype.h"	/* defines LOADER : 0-> normal bios, 1->loader bios */
			/* MEMDSK: 0 -> no memory disk			    */
			/*	   4 -> memory disk(sized at boot, drive E:)*/
			/* DISKB:  0 -> no disk B: (second floppy)	    */
			/*	   1 -> disk B: present			    */
			/* DISKC:  5 -> 5 megabyte hard disk for disk C:    */
			/*	  15 -> 15 megabyte hard disk for disk C:   */
			/* DISKD:  0 -> no disk D: (second hard disk)	    */
			/*	   5 -> 5 megabyte hard disk for disk D:    */
			/*	  15 -> 15 megabyte hard disk for disk D:   */

#include "biostyps.h"	/* defines portable variable types */

char copyright[] = "Copyright 1984, Motorola Inc.";
char biosrev[] = "BIOS 2.15";

#define NULL	(0L)

/************************************************************************/ 
/*      I/O Device Definitions						*/
/************************************************************************/

/*	for VME-10 defined separately with each module below		*/

/************************************************************************/
/*	Memory Region Table						*/
/************************************************************************/

struct mrt {	WORD count;
		LONG tpalow;
		LONG tpalen;
	   }
	memtab;				/* Initialized in BIOSA.S	*/


#if   MEMDSK
BYTE *memdsk;				/* Initialized in BIOSA.S	*/
#endif

#if ! LOADER

/************************************************************************/
/*	IOBYTE								*/
/************************************************************************/

WORD iobyte;	/* The I/O Byte is defined, but not used */

/*
 *	used to interface cons_stat() with cons_in().  in_char
 *	is a one character buffer.
 */

char	in_char = '\0';
char	char_avail = 0;

/************************************************************************/
/*	Port initialization						*/
/************************************************************************/

/*
 *	VME/10 Console interface
 */

/* defines used for VME/10 Control Register #2
 * initial values for CR2:
 *
 *	bit 0 - enable MMU interface
 *	bit 1 - disable keyboard transmit interrupt
 *	bit 2 - enable BCLR line
 *	bit 3 - ?
 *	bit 4 - disable keyboard RESET	
 *	bit 5 - disable RAM writes by other devices
 *	bit 6 - enable SYSFAIL interrupts
 *	bit 7 - enable keyboard recieve interrupt
 */

#define CR2_INIT	0xdd
#define CR2_ADDR	0xf19f09	/* address of control register 2  */

extern VOID	keybd_init();		/* vme/10 keyboard initialization */

VOID c_init()				/* INITIALIZE THE SYSTEM CONSOLE  */
{
	*((char *)CR2_ADDR) = CR2_INIT;	/* initialize Control Register 2; 
					   ostensibly to disable transmit 
					   interrupts from the keyboard   */
	keybd_init();			/* initialize the keyboard	  */
}


/************************************************************************/ 
/*	VME-10 keyboard input						*/
/************************************************************************/

/*
 *
 *	KEYBOARD -- ROUTINES FOR HANDLING THE VME/10 KEYBOARD.   
 *
 *	ENVIRONMENT:  This is part of the VME/10 keyboard/screen driver,  
 *
 *	FUNCTION:  These routines provide initialization and interrupt      
 *	  service for the VME/10 keyboard, which is connected to the        
 *	  processor board through a 2661 half-duplex serial port.           
 *
 *	NOTES:  This module is very much table-driven, so pains have been   
 *	  taken to reduce the size of the tables.  You will find byte and   
 *	  word offsets instead of longword addresses, and where feasible    
 *	  functions are used instead of tables to generate characters.      
 *
 */

/*	DIAGRAM DEPICTING THE ROLES OF THE VARIOUS TABLES
 *
 * 
 *                                        routine
 *                                        offsets
 *         scan                             ---
 *         code            - is routine    |   |
 *         table               index       |   |
 *          ---             ,------------->|   |-------------> BSR  ....
 *  scan   |   |           /               |   |               TST  ....
 *  code   |   |          /                 ---                etc.
 * ------->|   |---------<
 *         |   |   \      \                 ---
 *          ---     |      \               |   |
 *                  |       `------------->|   |--------.
 *                  |       + is group     |   |        |      char
 *                  |          index       |   |        |      table
 *                  |                       ---         `-----> ---
 *                  |                      group               |   |
 *                  | parameter           offsets              |   |
 *                  |                                  .------>|   |
 *                  |                                  |       |   |
 *                  `----------------------------------'        ---
 *
 *
 *
 * When a scan code is received, it is used as an index into the SCAN CODE
 * TABLE to get a group/routine index and a parameter.
 *
 * If the group/routine index is positive, then it is a group index.  The
 * corresponding offset is taken from the GROUP TABLE, giving the address
 * of the character table currently in effect for that group.  The parameter
 * is used as an index into the character table to retrieve the character.
 * If the entry in the character table is 0, no character is generated.    
 */

VOID		mode_chg();

typedef struct				/* entry in the scan code table	     */
{
	char	grp_rout_x;		/* group/routine index		     */
	char	arg;			/* a parameter			     */
} sc_tbl;

/* MODE TYPES								     */
 
#define BLANK	0x01		 	/* blank locking mode key is down    */
#define CTRL	0x02			/* CTRL is down.		     */
#define SHIFT	0x04			/* one or both of shift keys is down */
#define PAD	0x08			/* FUNC/PAD is down (PAD).	     */
#define ALPHA_LOCK 0x10			/* ALPHA LOCK is down. 		     */
#define ALT	0x20			/* ALT is down.			     */
#define ALOCK_OR_SHIFT 0x14		/* either lock of shift are down     */

	/* values generated by function keys. */
 
#define FNKEY_F1   	0xa0		/* Value to generate for func. key 1 */
#define FNKEY_S1   	0xb0		/* Value for shifted func. key 1.    */
 
#define STATUS_REG      0xf19f85 	/* Address of VMEC1 status register. */
#define KBD_UNLOCK 	0x10		/* status of the lock on the front 
					   panel, which we interpret as a 
					   keyboard lock: 0 if keyboard 
					   locked; 1 if unlocked  	     */

#define LEFT		0x01		/* left shift key is down	     */
#define RIGHT		0x02		/* right shift key is down	     */

static char	 modes;			/* value of modes reflect the status
					   (up | down) of mode keys on 	     */
static char	 shift_keys;		/* Bits in this byte reflect status
					   (up * or down) of two SHIFT keys. */

	/* Declarations for the 2661 (EPCI) connecting us to the keyboard.   */
 
#define EPCI_ADDR	0xf1a031	/* Base address of the 2661.	     */
 
typedef struct  			/* map of the 2661 registers	     */
{
	char	data;			/* data register		     */
	char	fill2, status;		/* status register		     */
	char	fill4, mode;		/* mode register		     */
	char	fill6, command;		/* command register		     */
} epci_map;
 
	/* Bit definitions for the 2661 status register.		     */
 
#define CHAR_AVAIL 	0x02		/* a received char is in DATA reg.   */
#define PARITY		0x08 		/* received char had a parity error. */
#define OVERRUN		0x010		/* receive buffer was overrun.	     */
#define FRAMING		0x020		/* received char had a framing error.*/
#define ANY_ERROR	0x038		/* Mask selecting all 3 errors.      */
 
	/*  Initialization values for the 2661 control registers.	     */
 
#define MODE1_INIT	0x5e		/* Initialization for mode reg 1     */
#define MODE2_INIT	0x7b		/* Initialization for mode reg 2     */
#define COMM_INIT	0x15		/* Initialization for command reg    */
 
	/* Commands for keyboard.  In each, bits 0-3 = $0 are keyboard's ID. */
 
#define SELECT_KB	0x80		/* SELECT command.		     */
#define READ_KB		0xa0		/* READ   command.		     */
#define AGAIN_KB	0xd0		/* AGAIN  command; this causes last
                                           scan code sent to be repeated.    */
 
	/* Declarations for control register 2 on the VME/10 processor board.*/
 
typedef struct				/* description of control register 2 */
{
	char	cr2;
} cr2_map;

#define CR2_ADDR	0xf19f09	/* Location of control register 2.   */
#define KB_RESET	0x10		/* when low, holds keyboard in reset.*/
#define KB_ENABLE	0x80		/* when high, enables receipt 
					   interrupts from the 2661 which 
					   connects us to the keyboard.	     */
 
	/* status values returned by keybd_read	     */

#define NOCHAR		0		/* no character was returned	     */
#define BREAK		1		/* break key was struck		     */
#define KYBD_LOCKED	2		/* key on front panel in lock pos.   */
#define IN_CHAR		3		/* a real live character available   */

#define WAIT_COUNT	2		/* Initial loop value for timing loop 
					   in keyboard reset.		     */
 
#define AT_CHAR		'@'
#define TWO_CHAR	'2'
 

/******************************************************************************
   
	ROUTINE AND GROUP OFFSET TABLES
   
	FUNCTION:  Each entry in the scan code table contains a byte value
	  called the group/routine index.  If it is negative it is a routine 
	  index and is used as the index in a switch statement.
	  If is is positive, it is a group index and is
	  an offset into GRP_TBL.  These tables contain word offsets to
	  routines or tables in this module.  The whole purpose for these guys
	  is to allow each scan code table entry to be just 2 bytes long.

******************************************************************************/
/*
 * If the group/routine index is negative, then it is a routine index.  The
 * index is one of the enumerated types "rtn_index" and is used as the 
 * switch index in a switch statement.  The parameter may or may not be 
 * used by the routine.
 *
 * Also note that rtn_index starts at 1 so that there is no entry #0 in 
 * the routine table; this is necessary since negative 0 is 0 and that index
 * would be indistinguishable from the positive 0 index in the group table.
 *
 * Note: the NONLOCKABLE enumerated type.  Routine indexes which
 * are above that type will not be executed while the keyboard lock on the front
 * panel is in the LOCKED position--only when it is UNLOCKED.  Routines indexes
 * below that point are called regardless of the keyboard lock's status.
 */
 
#define TWO_AT		1
#define ESC_RESET	2
#define BREAK_CLEAR	3
#define GEN_ALPHA	4
#define FNKEY		5
#define NONLOCKABLE	5
#define SET_SHIFT	6
#define CLR_SHIFT	7
#define SET_MODE	8
#define CLR_MODE	9
#define IGNORE		10

typedef int rtn_index;
 
/******************************************************************************
   
	SCAN CODE TABLE -- CONVERTS A SCAN CODE TO GROUP/ROUTINE INDEX
			   & PARAMETER.

	FUNCTION:  The scan code taken from the 2661, multiplied by 2, is
	  used as an index into this table.  This table contains a 2-byte
	  entry for each possible scan code:  a 1-byte group/routine index
	  (see the offset table, OFF_TBL) and a parameter.

******************************************************************************/
 
/*
 * The rtn macro is used to make entries in the scan code table for those
 * scan codes which will result in an entry in a switch statement being 
 * invoked.  The format is
 *
 *	 RTN (<routine_index>, <arguments>)
 *
 * The first argument is the name of the routine to go to when this scan
 * code is received.  The second argument, which is optional, is a parameter
 * to pass to the routine.  That is, the same routine may be used with many
 * different scan codes, each passing a different argument.
 */
 
#define RTN(ri, mode)	-ri, mode,

/*
 * The ALPHA macro is used to make entries in the scan code table for those
 * scan codes which will generate alphabetic characters.  The format is
 *
 *	ALPHA <uppercase alphabetic character>
 */
 
#define ALPHA(c)	-GEN_ALPHA,c,

/*
 * The GROUP macro is used to make entries in the scan code table for those
 * scan codes which have entries in character tables.  The format is
 *
 *   GROUP <group index>,<element # within group>
 *
 * Both arguments are required.  The first is 0,1,...whatever the highest
 * group index is.  The second argument is the index into the chosen 
 * character table for this scan code.
 */
#define GROUP(grpnm, index)	grpnm, index,

static char			/* scan code      key		*/
	c_scan_code_tbl[] = {	/*   ----      ---------------	*/
	RTN(IGNORE,0)		/* 00 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 01 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 02 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 03 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 04 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 05 -- Ignore it.		*/
	RTN(IGNORE,0)		/* 06 -- Ignore it.		*/
	RTN(SET_MODE,ALPHA_LOCK)/* 07 -- ALPHA LOCK depressed.	*/
	RTN(SET_SHIFT,LEFT)	/* 08 -- Left  SHIFT depressed.	*/
	RTN(SET_SHIFT,RIGHT)	/* 09 -- Right SHIFT depressed.	*/
	RTN(SET_MODE,CTRL)	/* 0A -- CTRL depressed.	*/
	RTN(SET_MODE, ALT)	/* 0B -- ALT  depressed.	*/
	RTN(SET_MODE, BLANK)	/* 0C -- Blank locking mode key */
	RTN(IGNORE,0)		/* 0D -- Clacker mode key	*/ 
	RTN(SET_MODE, PAD)	/* 0E -- FUNC_PAD depressed.	*/
	RTN(CLR_MODE,ALPHA_LOCK)/* 0F -- ALPHA LOCK released.	*/
	RTN(IGNORE,0)		/* 10 -- Ignore it.		*/
	GROUP(1,0 )		/* 11 -- ` ~ key.		*/
	GROUP(1,1 )		/* 12 -- 1 ! key.		*/
	RTN(TWO_AT, 0)		/* 13 -- 2 @ key.		*/
	GROUP(1,2 )		/* 14 -- 3 # key.		*/
	GROUP(1,13)		/* 15 -- TAB key on main keybd.	*/
	ALPHA('Q')		/* 16 -- Q key.			*/
	ALPHA('W')		/* 17 -- W key.			*/
	ALPHA('E')		/* 18 -- E key.			*/
	ALPHA('A')		/* 19 -- A key.			*/
	ALPHA('S')		/* 1A -- S key.			*/
	ALPHA('D')		/* 1B -- D key.			*/
	ALPHA('Z')		/* 1C -- Z key.			*/
	ALPHA('X')		/* 1D -- X key.			*/
	GROUP(1,23)		/* 1E -- Space bar.		*/
	RTN(CLR_SHIFT, LEFT)	/* 1F -- Left SHIFT key released.*/
	RTN(IGNORE,0)		/* 20 -- Ignore it.		*/
	RTN(FNKEY, 1)		/* 21 -- Function key 1.	*/
	RTN(FNKEY, 2)		/* 22 -- Function key 2.	*/
	RTN(FNKEY, 3)		/* 23 -- Function key 3.	*/
	GROUP(1,3 )		/* 24 -- 4 $ key.		*/
	GROUP(1,4 )		/* 25 -- 5 % key.		*/
	GROUP(1,5 )		/* 26 -- 6 ^ key.		*/
	ALPHA('R')		/* 27 -- R key.			*/
	ALPHA('T')		/* 28 -- T key.			*/
	ALPHA('Y')		/* 29 -- Y key.			*/
	ALPHA('F')		/* 2A -- F key.			*/
	ALPHA('G')		/* 2B -- G key.			*/
	ALPHA('C')		/* 2C -- C key.			*/
	ALPHA('V')		/* 2D -- V key.			*/
	ALPHA('B')		/* 2E -- B key.			*/
	RTN(CLR_SHIFT, RIGHT)	/* 2F -- Right SHIFT key released*/
	RTN(IGNORE,0)		/* 30 -- Ignore it.		*/
	RTN(FNKEY,4)		/* 31 -- Function key 4.	*/
	RTN(FNKEY,5)		/* 32 -- Function key 5.	*/
	RTN(FNKEY,6)		/* 33 -- Function key 6.	*/
	GROUP(1,6 )		/* 34 -- 7 & key.		*/
	GROUP(1,7 )		/* 35 -- 8 * key.		*/
	GROUP(1,8 )		/* 36 -- 9 ( key.		*/
	ALPHA('U')		/* 37 -- U key.			*/
	ALPHA('I')		/* 38 -- I key.			*/
	ALPHA('H')		/* 39 -- H key.			*/
	ALPHA('J')		/* 3A -- J key.			*/
	ALPHA('K')		/* 3B -- K key.			*/
	ALPHA('N')		/* 3C -- N key.			*/
	ALPHA('M')		/* 3D -- M key.			*/
	GROUP(1,20)		/* 3E -- , < key.		*/
	RTN(CLR_MODE,CTRL)	/* 3F -- CTRL key released.	*/
	RTN(IGNORE,0)		/* 40 -- Ignore it.		*/
	RTN(FNKEY,7)		/* 41 -- Function key 7.	*/
	RTN(FNKEY,8)		/* 42 -- Function key 8.	*/
	GROUP(1,9 )		/* 43 -- 0 ) key.		*/
	GROUP(1,10)		/* 44 -- - _ key.		*/
	GROUP(1,11)		/* 45 -- = + key.		*/
	ALPHA('O')		/* 46 -- O key.			*/
	ALPHA('P')		/* 47 -- P key.			*/
	GROUP(1,14)		/* 48 -- [ { key.		*/
	ALPHA('L')		/* 49 -- L key.			*/
	GROUP(1,17)		/* 4A -- : ; key.		*/
	GROUP(1,18)		/* 4B -- ' " key.		*/
	GROUP(1,21)		/* 4C -- .			*/
	GROUP(1,22)		/* 4D -- / ? key.		*/
	RTN(IGNORE,0)		/* 4E -- Ignore it.		*/
	RTN(CLR_MODE,ALT)	/* 4F -- ALT key released.	*/
	RTN(IGNORE,0)		/* 50 -- Ignore it.		*/
	RTN(FNKEY,9)		/* 51 -- Function key 9.	*/
	RTN(FNKEY,10)		/* 52 -- Function key 10.	*/
	RTN(FNKEY,11)		/* 53 -- Function key 11.	*/
	RTN(FNKEY,12)		/* 54 -- Function key 12.	*/
	GROUP(1,12)		/* 55 -- DEL key.		*/
	RTN(BREAK_CLEAR, 0)	/* 56 -- BREAK CLEAR key.	*/
	GROUP(1,15)		/* 57 -- ] } key.		*/
	GROUP(1,16)		/* 58 -- \ | key.		*/
	GROUP(0,1 )		/* 59 -- Home key.		*/
	GROUP(1,19)		/* 5A -- Return key.		*/
	GROUP(0,3 )		/* 5B -- Backarrow key.		*/
	RTN(IGNORE,0)		/* 5C -- SEL key.		*/
	GROUP(0,5 )		/* 5D -- Backtab key.		*/
	GROUP(0,6 )		/* 5E -- Downarrow key.		*/
	RTN(CLR_MODE,BLANK)	/* 5F -- lock mode key released.*/
	RTN(CLR_MODE,PAD)	/* 60 -- PAD key released.	*/
	RTN(FNKEY,13)		/* 61 -- Function key 13.	*/
	RTN(FNKEY,14)		/* 62 -- Function key 14.	*/
	RTN(FNKEY,15)		/* 63 -- Function key 15.	*/
	RTN(FNKEY,16)		/* 64 -- Function key 16.	*/
	RTN(ESC_RESET, 0)	/* 65 -- ESC RESET key.		*/
	GROUP(2,10)		/* 66 -- A DCHR key.		*/
	GROUP(0,2 )		/* 67 -- Uparrow key.		*/
	RTN(IGNORE,0)		/* 68 -- CLR TAB SET key.	*/
	GROUP(2,7 )		/* 69 -- 7 EOF key.		*/
	GROUP(0,4 )		/* 6A -- Rightarrow key.	*/
	GROUP(2,4 )		/* 6B -- 4 key on hexpad.	*/
	GROUP(0,7 )		/* 6C -- Tab key on cursor pad.	*/
	GROUP(2,1 )		/* 6D -- 1 ICHR key.		*/
	GROUP(2,0 )		/* 6E -- 0 on hexpad.		*/
	RTN(IGNORE,0)		/* 6F -- Clacker mode key release*/
	RTN(IGNORE,0)		/* 70 -- Ignore it.		*/
	GROUP(2,11)		/* 71 -- B DLINE key.		*/
	GROUP(2,12)		/* 72 -- C on hexpad.		*/
	GROUP(2,13)		/* 73 -- D on hexpad.		*/
	GROUP(2,8 )		/* 74 -- 8 EOL key.		*/
	GROUP(2,9 )		/* 75 -- 9 EOP key.		*/
	GROUP(2,14)		/* 76 -- E EAU key.		*/
	GROUP(2,5 )		/* 77 -- 5 on hexpad.		*/
	GROUP(2,6 )		/* 78 -- 6 on hexpad.		*/
	GROUP(2,15)		/* 79 -- F on hexpad.		*/
	GROUP(2,2 )		/* 7A -- 2 ILINE key.		*/
	GROUP(2,3 )		/* 7B -- 3 on hexpad.		*/
	GROUP(2,16)		/* 7C -- TEST , key.		*/
	GROUP(2,17)		/* 7D -- HELP .			*/
	GROUP(0,0 )		/* 7E -- ENTER key.		*/
	RTN(IGNORE,0)		/* 7F -- Ignore it.		*/
};

/*
 *	NOTE:  DUE TO A COMPILER BUG WE ARE UNABLE TO INITIALIZE
 *	CHAR VARIABLES AS MEMBERS OF A STRUCTURE, SO WE HAVE DECLARED
 *	THE TABLES AS CONTIGUOUS CHAR ARRAYS AND ASSIGN THE ORIGINAL
 *	STRUCTURE ARRAY AS A PTR TO THE CHAR ARRAY OF INITIALIZED 
 *	DATA.  THIS WAS FELT TO BE THE MOST DIRECT SOLUTION.
 */

static sc_tbl	*scan_code_tbl = (sc_tbl *)c_scan_code_tbl;

/******************************************************************************
   
        GROUP 0 CHARACTER TABLE -- KEYS UNAFFECTED BY MODE KEYS
   
        FUNCTION:  This table contains the characters to return for scan
          codes which fall into group 0.  Use the parameter obtained from
          the scan code table as an index into this table.  A value of 0
          will cause no character to result.
   
          Table TBL.___ is used regardless of any mode keys.
   
******************************************************************************/

				/* element #			     */
static char	tbl___[] = {	/* ---------			     */
	0x0d,			/* 0 -- CR (from the ENTER key).     */
	0xc0,			/* 1 -- Home.			     */
	0x0b,			/* 2 -- VT (from the uparrow key).   */
	0x08,			/* 3 -- BS (from the leftarrow key). */
	0x0c,			/* 4 -- FF (from the rightarrow key).*/
	0xdb,			/* 5 -- Backtab.		     */
	0x0a,			/* 6 -- LF (from the downarrow key). */
	0x09,			/* 7 -- HT (from the tab key on the  */
};
/******************************************************************************

	GROUP 1 CHARACTER TABLES -- KEYS AFFECTED BY SHIFT AND CTRL KEYS.

	FUNCTION:  These tables contain the characters to return for scan
	  codes which fall into group 1.  Use the parameter obtained from
	  the scan code table as an index into these tables.  A value of 0
	  will cause no character to result.

	  Table TBL.NN_ is used when we're in neither SHIFT nor CTRL .
	  Table TBL.XY_ is used when we're in CTRL mode (SHIFTed or ).
	  Table TBL.YN_ is used when we're in SHIFT but not CTRL  mode.

******************************************************************************/
 
				/* element #			*/
static char	tblnn_[] = {	/* ---------			*/
	'`' ,			/* 0.				*/
	'1' ,			/* 1.				*/
	'3' ,			/* 2.				*/
	'4' ,			/* 3.				*/
	'5' ,			/* 4.				*/
	'6' ,			/* 5.				*/
	'7' ,			/* 6.				*/
	'8' ,			/* 7.				*/
	'9' ,			/* 8.				*/
	'0' ,			/* 9.				*/
	'-' ,			/* 10.				*/
	'=' ,			/* 11.				*/
	0x7F ,			/* 12 -- DEL.			*/
	0x09 ,			/* 13 -- HT (tab key on keyboard).   */
	'[' ,			/* 14.				*/
	']' ,			/* 15.				*/
	'\\' ,			/* 16.				*/
	';' ,			/* 17.				*/
	0x27 ,			/* 18 -- Apostrophe.		*/
	0x0D ,			/* 19 -- CR (from return key).	*/
	',' ,			/* 20.				*/
	'.' ,			/* 21.				*/
	'/' ,			/* 22.				*/
	' ' ,			/* 23.				*/
};

				/* element #			*/
static char	tblxy_[] = {	/* ---------			*/
	0   ,			/* 0.				*/
	0   ,			/* .				*/
	0   ,			/* 2.				*/
	0   ,			/* 3.				*/
	0   ,			/* 4.				*/
	0x1e ,			/* 5  -- CTRL ^.		*/
	0   ,			/* 6.				*/
	0   ,			/* 7.				*/
	0   ,			/* 8.				*/
	0   ,			/* 9.				*/
	0x1f ,			/* 10 -- CTRL _.		*/
	0   ,			/* 11.				*/
	0   ,			/* 12.				*/
	0   ,			/* 13.				*/
	0x1b ,			/* 14 -- CTRL [.		*/
	0x1d ,			/* 15 -- CTRL ].		*/
	0x1c ,			/* 16 -- CTRL \.		*/
	0   ,			/* 17.				*/
	0   ,			/* 18.				*/
	0   ,			/* 19.				*/
	0   ,			/* 20.				*/
	0   ,			/* 21.				*/
	0   ,			/* 22.				*/
	0   ,			/* 23.				*/
		};

static char	tblyn_[] = {
	                      /* element #			*/
	                      /* ---------			*/
	'~' ,			/* 0.				*/
	'!' ,			/* 1.				*/
	'#' ,			/* 2.				*/
	'$' ,			/* 3.				*/
	'%' ,			/* 4.				*/
	'^' ,			/* 5.				*/
	'&' ,			/* 6.				*/
	'*' ,			/* 7.				*/
	'(' ,			/* 8.				*/
	')' ,			/* 9.				*/
	'_' ,			/* 10.				*/
	'+' ,			/* 11.				*/
	0x7f ,                /* 12 -- DEL.			*/
	0x09 ,                /* 13 -- HT (tab key on main keyboard)*/
	'{' ,			/* 14.				*/
	'}' ,			/* 15.				*/
	'|' ,			/* 16.				*/
	':' ,			/* 17.				*/
	'"' ,			/* 18.				*/
	0x0d ,                /* 19 -- CR (from return key).	*/
	'<' ,			/* 20.				*/
	'>' ,			/* 21.				*/
	'?' ,			/* 22.				*/
	' ' ,			/* 23.				*/
		};
/******************************************************************************

     GROUP 2 CHARACTER TABLES -- KEYS AFFECTED ONLY BY FUNC/PAD KEY.

     FUNCTION:  These tables contain the characters to return for scan
       codes which fall into group 2.  Use the parameter obtained from
       the scan code table as an index into these tables.  A value of 0
       will cause no character to result.

       Table TBL.__N is used when we're not in PAD mode.
       Table TBL.__Y is used when we are in PAD mode.

       These tables contain characters associated with the hexpad.  Note,
       however, that the ENTER key is not in these tables.

******************************************************************************/
 
static char	tbl__n[] = {
	                   	/* element #			*/
	                   	/* ---------			*/
	0   ,			/* 0.				*/
	0xD0 ,			/* 1  -- ICHR.			*/
	0xD6 ,			/* 2  -- ILINE.			*/
	0   ,			/* 3.				*/
	0   ,			/* 4.				*/
	0   ,			/* 5.				*/
	0   ,			/* 6.				*/
	0   ,			/* 7.				*/
	0xD5 ,			/* 8  -- EOL.			*/
	0xD4 ,			/* 9  -- EOP.			*/
	0xD1 ,			/* 10 -- DCHR.			*/
	0xD7 ,			/* 11 -- DLINE.			*/
	0   ,			/* 12 -- PMODE.			*/
	0   ,			/* 13.				*/
	0   ,			/* 14.				*/
	0   ,			/* 15.				*/
	0   ,			/* 16.				*/
	0   ,			/* 17.				*/
};

	                   	/* element #			*/
static char	tbl__y[] = {	/* ---------			*/
	'0' ,			/* 0.				*/
	'1' ,			/* 1.				*/
	'2' ,			/* 2.				*/
	'3' ,			/* 3.				*/
	'4' ,			/* 4.				*/
	'5' ,			/* 5.				*/
	'6' ,			/* 6.				*/
	'7' ,			/* 7.				*/
	'8' ,			/* 8.				*/
	'9' ,			/* 9.				*/
	'A' ,			/* 10.				*/
	'B' ,			/* 11.				*/
	'C' ,			/* 12.				*/
	'D' ,			/* 13.				*/
	'E' ,			/* 14.				*/
	'F' ,			/* 15.				*/
	',' ,			/* 16.				*/
	'.' ,			/* 17.				*/
};

/*
 * grp_tbl_ptr is used when the group/routine index for a scan code is 
 * positive ( >=0 ). As mode keys are pressed, the address in the table
 * may get replaced.
 */
static char	*grp_tbl_ptr[3] = { 
	tbl___,			/* Group 0: no mode keys affect these.*/
	tblnn_,			/* Group 1: SHIFT and CTRL affect     */
	tbl__n 			/* Group 2: PAD affects these.	      */
};

					/* table of offsets for group 1. One is
					selected based on CTRL and SHIFT keys*/
static char	*grp1_off[] = {
	tblnn_,			/* no SHIFT, no CTRL		     */
	tblxy_,			/* no SHIFT,    CTRL		     */
	tblyn_,			/*    SHIFT, no CTRL		     */
	tblxy_,			/*    SHIFT,    CTRL		     */
};
			 
/* delay for a multiple of 4 usecs;  which is the time it takes to 
 * traverse the loop once on MC68010  
 *
 * since the CP/M compiler doesn't support blocked variables
 * we need to declare a register int in the function
 * itself
 */
#define DELAY(n)	delayvar=n; do; while(--delayvar);

/******************************************************************************

               keybd_init -- INITIALIZE THE VME/10 KEYBOARD              

	FUNCTION:  This routine, which is XDEFed, resets the keyboard,      
	  configures the 2661 so we can communicate with the keyboard,      
	  selects the keyboard, and disables keyboard interrupts.            

	  Currently, however, we are not checking the self-test status,     
	  and therefore there is no possibility of an error return.  The    
	  hooks are left in to facilitate later enhancements.               


******************************************************************************/
 
keybd_init() 
   {
   register LONG	delayvar;	/* req'd for DELAY macro!!!	*/
   register epci_map	*epci_base;
   register cr2_map	*cr2_base;
   register char	cr2_state;
   register char 	cr;		/* to hold contents of control reg.   */
   int			reg;		/* dummy to hold data register value  */

   epci_base = (epci_map *)EPCI_ADDR;
   cr2_base  = (cr2_map *)CR2_ADDR;
 
   /* reset the keyboard */

   cr2_base->cr2 &= (char)(~KB_ENABLE);	 /* disable keyboard interrupts	     */
   cr2_base->cr2 &= (~KB_RESET);	 /* set RESET line to keyboard	     */
   DELAY(2);				 /* need to wait about 5 usecs	     */
   cr2_base->cr2 |= KB_RESET;
   DELAY(100000);			 /* allow keyboard to get it's act 
					   together; about 1/2 second	     */
   /* Initialize the 2661.  Because 2661 mode register is really two registers
      and the one you're writing to depends upon sequence of prior writes, we
      must do this with interrupts disabled.				     */
   
   cr = epci_base->command;		/* read command register, which causes 
					  the mode reg. to point to reg 1.   */
   epci_base->mode = MODE1_INIT;	/* initialize mode register 1	     */
   epci_base->mode = MODE2_INIT;	/* initialize mode register 2	     */
   epci_base->command = COMM_INIT;	/* initialize the command register   */
 
   /* Select the keyboard. */
   epci_base->data = SELECT_KB;		/* send command to select keyboard   */

   for (;!(epci_base->status & CHAR_AVAIL);)  /* wait for reception of char */
		;

   reg = epci_base->data;		/* Read response; if it's not an ACK (0)
                                           the keyboard failed its self-test;
                                           ignore the status since it is
                                           possible that the self-test failed
                                           'cause someone was holding down a key
                                           and we don't want such a minor thing 
					   to prevent the system from booting.*/
   epci_base->data = READ_KB;		/* send a READ command so keyboard will
					   send us first scan code	    */
   }
 
/******************************************************************************

		keybd_read -- ROUTINE TO GET A CHAR FROM THE KEYBOARD          

	FUNCTION:  This routine is called when a we want to read a code    
	  from the 2661.  It gets the code from the 2661, sends  
	  another READ to the keyboard, and either JMPs to a routine or     
	  converts the scan code into a char, depending on the scan code.   

******************************************************************************/

char 	keybd_read(status)
   int	*status;	/* used to indicate a brk was struck */
   {
   register epci_map	*epci_base;	/* pointer to the keyboard registers  */
   register char	scn_code;	/* scan code recieved from keyboard   */
   register char	scn_tbl_arg;	/* save the scan table argument field */
   register char 	group_x;	/* group/routine index from scan table*/
   register rtn_index	rtn_x;		/* index in switch statement	      */
   register char	rv;		/* return value			      */

   epci_base = (epci_map *)EPCI_ADDR;
 
   /* Get scan code and check for errors. */

	/*
	 *	if we just make a mode change, we immediately
	 *	try again to read a character.  we don't pass any
	 *	SHIFT codes and such up.
	 */

   if (!(epci_base->status & ANY_ERROR))/* NO errors from the keyboard	     */
      {
      scn_code = epci_base->data;	/* get scan code from the keyboard   */

      /* save arg from the scan table entry for later use		     */
      scn_tbl_arg = scan_code_tbl[scn_code].arg;
      if (scn_code >= 0)		/* Verify that bit 8 is 0	     */
	 {
	 epci_base->data = READ_KB;	/* send another READ to the keyboard  */
         group_x = scan_code_tbl[scn_code].grp_rout_x; /* Use scan code to get
					   group/routine index and parameter. */
	 rv = 0;			/* initialize return value here	      */
	 *status = NOCHAR;	        /* initialize status to not character
					  returned to the caller	     */
	 if (group_x < 0)		/* negative group_x indicates a switch 
					  routine is invoked		     */
	    {				/* ROUTINE TO INTERPRET SCAN CODE    */
	    rtn_x = (rtn_index)(group_x);/* negate to get switch index */
	    rtn_x = -rtn_x;		/* compiler BUG work around */
	    if (-group_x <= (char)NONLOCKABLE)	/* routine affected by front 
						  panel lock		     */
	       {
	       if (!(*((char *)STATUS_REG) & KBD_UNLOCK))
		  rtn_x = IGNORE;	/* if lock is on then ignore keystroke*/
	       }
	    switch ((int)rtn_x)
	       {
	       case TWO_AT :
   
        	/* TWO_AT -- HANDLE THE 2 @ KEY.
   
          	This code is entered when the 2 @ key is pressed.  Its purpose
		is to generate the appropriate character code depending on the 
		state of the SHIFT and CTRL mode keys.  The reason this key
          	can't be handled by the tables is that if CTRL is pressed, a NUL
          	($00) character must be generated.  A value of 0 in the tables
          	is reserved to mean NO CHARACTER.			     */

		  if (!(modes & CTRL))		/* is the CTRL key down?     */
		     {				/* No, so look further	    */
		     if (modes & SHIFT)		/* is one of SHIFT keys down */
			rv = '@';		/* return @ character	    */
		     else
			rv = '2';		/* return 2 character	    */
		     }
		  *status = IN_CHAR;
		  break;

	       case ESC_RESET :
   
               /*  ESC_RESET -- HANDLE ESC RESET KEY.
   
                 This code is entered when the ESC RESET key is pressed.
          	 Its purpose is to generate the appropriate character code 
		 depending on the state of the SHIFT mode keys.		     */
		  
		  if (modes & SHIFT)		/* is a SHIFT key down	     */
		     /*reset_screen()*/;	/* NOT IMPLEMENTED YET	     */
		  else
		  {
		     rv = 0x1b;			/* character is an esc	     */
		     *status = IN_CHAR;
		  }
		  break;
 
	       case BREAK_CLEAR :
   
        	/* BREAK_CLEAR -- HANDLE BREAK CLEAR KEY
   
          	   This code is entered when the BREAK CLEAR key is pressed.
          	   Its purpose is to generate the appropriate character code
		   depending on the state of the SHIFT mode keys. 	     */
  
		  if (modes & SHIFT)
		     /*clear_screen()*/;	/* NOT IMPLEMENTED YET	     */
		  else
		     *status = BREAK;		/* tell caller break was hit  */
		  break;

	       case GEN_ALPHA :
   
        	/* GEN_ALPHA -- HANDLE ALPHABETIC KEYS.
   
          	   This code is entered when an alphabetic key is pressed.
          	   Its purpose is to generate the appropriate character code
		   depending on the state of the SHIFT, ALPHA LOCK, and CTRL
		   mode keys.						     */

		  if (modes & CTRL)
		     rv = scn_tbl_arg - ('A' - 1);
		  else
		     if (!(modes & ALOCK_OR_SHIFT)) /* is a shift key down? */
			rv = scn_tbl_arg + ('a' -'A'); /* lower case letter */
		     else
			rv = scn_tbl_arg;	/* vanilla upper case letter*/
		  
		  *status = IN_CHAR;
		  break;
 
	       case FNKEY :
   
        	/* FNKEY -- HANDLE FUNCTION KEYS.
   
          	   This code is entered when a function key is pressed.
          	   Its purpose is to generate the appropriate character code
		   depending on the state of the SHIFT mode keys.	     */
   
		  if (modes & SHIFT)
		     rv = scn_tbl_arg + FNKEY_S1 - 1;
		  else
		     rv = scn_tbl_arg + FNKEY_F1 - 1;
		  *status = IN_CHAR;
		  break;
 
	       case SET_SHIFT :
   
               /* SET_SHIFT AND CLR_SHIFT -- SET OR CLEAR 1 OF THE 2 SHIFT KEYS.
   
          	  Use these routines when a shift key is pressed or released
          	  to update the SHIFT_KEYS byte and make a mode change for 
		  SHIFT if necessary.					     */

		  shift_keys |= scn_tbl_arg;	/* which shift keys was hit   */
		  modes |= SHIFT;
		  mode_chg();
		  break;

	       case CLR_SHIFT :

		  shift_keys &= (~scn_tbl_arg);	/* clear previous key	     */
		  if (shift_keys == 0)		/* both shift keys released   */
		     {
		     modes &= (~SHIFT);		/* clear the shift mode	     */
		     mode_chg();
		     }
		  break;

	       case SET_MODE :
   
        	/* SET_MODE AND CLR_MODE -- SET OR CLEAR A MODE (E.G., SHIFT).
   
          	   Use these routines when a mode key is pressed or released
          	   to update the MODES byte and set the appropriate table 
		   offsets in the GRP_TBL.				     */
   
		  modes |= scn_tbl_arg;
		  mode_chg();
		  break;
 
	       case CLR_MODE :
 
		  modes &= (~scn_tbl_arg);	/* Clear the specified mode   */
		  mode_chg();
		  break;

	       case IGNORE :

		  break;
	       }  /* end of switch ((int)rtn_x)*/

	    return(rv);
	    }
	 else
   	    /* It's not a routine, it's a group, so use the parameter to get 
               the char from the table currently in effect for that group.   */
	    {				/* CHARACTER DESIGNATED BY SCAN CODE */
	    if ((*(char *)STATUS_REG) & KBD_UNLOCK) /* is keyboard locked    */
	       {	
      	       rv = (grp_tbl_ptr[group_x])[scn_tbl_arg];
	       *status = IN_CHAR;
	       return(rv);
	       }
	    else			/* if keyboard is locked, ignore code */
	       {
	       *status = KYBD_LOCKED;	/* tell caller the keyboard is locked*/
	       return(0);
	       }
	    }
	 }
      }
   /* Some kind of error was detected in getting the scan code--try again.   */
 
   epci_base->data;			/* read char if haven't done it yet   */
   epci_base->command = COMM_INIT;	/* reset the error in the 2661	     */
   epci_base->data = AGAIN_KB;		/* tell keyboard to send last scan code
					  again; just ignore the present one */
   return(0);
   }


VOID		mode_chg()
   {
   int 		i;			/* used as index into grp1_off	     */

   i = (modes & 0x6) >> 1;		/* use SHIFT and CTRL bits in mode as
					   an index to reference grp1_off    */
   grp_tbl_ptr[1] = grp1_off[i];

   if (modes & PAD)			/* is PAD key down		     */
      grp_tbl_ptr[2] = tbl__y;		/* get address of table for Pad chars*/
   else
      grp_tbl_ptr[2] = tbl__n;		/* get address of table for no PAD   */
   
   return;
   }


/************************************************************************/ 
/*	VME-10 input status						*/
/************************************************************************/
 
cons_stat()
{
	register char	ret;
	int	status;
	register epci_map	*epci_base;

	/*
	 *	first check to see if a character is already available
	 *	in one character buffer and hasn't been picked up.
	 */

	if( char_avail )
		return(0xff);

	/*
	 *	no char was already available so check if there
	 *	is something from the keyboard.
	 */

	epci_base = (epci_map *)EPCI_ADDR;
	if ( !(epci_base->status & CHAR_AVAIL) )
		return(0x00);

	ret = keybd_read(&status);

	/*
	 *	there are four status returns from keybd_read()
	 *
	 *		BREAK - a break character was returned
	 *			return 0x00.
	 *		IN_CHAR - we have a character returned
	 *			  return 0xff.
	 *		NOCHAR - there is no character currently 
	 *			  available from the keyboard.
	 *		KYBD_LOCKED - there is no character available
	 *			  as the keyboard lock is on.
	 */

	if( status == NOCHAR )
        	return(0x00);
	else if( status == KYBD_LOCKED )
		return(0x00);
	else if( status == BREAK )
		return(0x00);
	else if( status == IN_CHAR )
	{
		in_char = ret;
		char_avail = 0xff;
		return(0xff);
	}
}
 

/*	
 *	end of keyboard code
 */

/************************************************************************/
/*									*/
/*	BIOS Interface to keyboard functions				*/
/*									*/
/************************************************************************/

/************************************************************************/
/*	VME-10 Keyboard Input						*/
/************************************************************************/

BYTE	cons_in()
{
	while( ! cons_stat() )		/* wait for input */
		;

	char_avail = 0;
	return( in_char );
}
#endif /* ! LOADER */ 
 
/************************************************************************/ 
/*	VME-10 Console output						*/
/************************************************************************/
 
/*	assembly language routine "cons_out" in biosa.s			*/
 
/************************************************************************/ 
/*      Error procedure for BIOS					*/
/************************************************************************/

#if ! LOADER

bioserr(errmsg)
REG BYTE *errmsg;
{
        printstr("\n\rBIOS ERROR -- ");
        printstr(errmsg);
        printstr(".\n\r");
}
 
printstr(s)     /* used by bioserr */
REG BYTE *s;
{ 
        while (*s)
		cons_out(*s++);
}

#else

bioserr()	/* minimal error procedure for loader BIOS */
{
	l : goto l;
}

#endif

/************************************************************************/
/*	Disk I/O Procedures and Definitions				*/
/************************************************************************/

/************************************************************************/
/* Define Disk I/O Addresses and Related Constants			*/
/************************************************************************/

#define	DSKCNTL	((struct dio *) 0xf1c0d1)	/* controller address */

#define	LSCTSZ	128		/* logical sector size - 128 bytes */
#define	DCXFER	128		/* bytes per dsk controller transfer request */

#define	FDRM	127		/* floppy disk directory maximum */
#define	FDSM96	313		/* floppy disk storage maximum - 96 tpi */
#define	FDSM48	153		/* floppy disk storage maximum - 48 tpi */

#if DISKC == 5
#define HDRMC	1023		/* hard disk C: directory maximum */
#define	HDSMC	1215		/* hard disk C: storage maximum - 5 MB */
#define CMCYL	305		/* hard disk C: maximum cylinder */
#define CMHD	1		/* hard disk C: maximum head */
#endif

#if DISKC == 15
#define HDRMC	2047		/* hard disk C: directory maximum */
#define	HDSMC	3655		/* hard disk C: storage maximum - 15 MB */
#define CMCYL	305		/* hard disk C: maximum cylinder */
#define CMHD	5		/* hard disk C: maximum head */
#endif

#if DISKD == 5
#define HDRMD	1023		/* hard disk D: directory maximum */
#define	HDSMD	1215		/* hard disk D: storage maximum - 5 MB */
#define DMCYL	305		/* hard disk D: maximum cylinder */
#define DMHD	1		/* hard disk D: maximum head */
#endif

#if DISKD == 15
#define HDRMD	2047		/* hard disk D: directory maximum */
#define	HDSMD	3655		/* hard disk D: storage maximum - 15 MB */
#define CMCYL	305		/* hard disk D: maximum cylinder */
#define DMHD	5		/* hard disk D: maximum head */
#endif

#define	FCSVSIZE	((FDRM / 4) + 1)	/* floppy csv size */
#define	FALVSIZE	((FDSM96 / 8) + 1)	/* floppy alv size */
#define	HCSVSIZC	((HDRMC / 4) + 1)	/* hard C: csv size */
#define	HALVSIZC	((HDSMC / 8) + 1)	/* hard C: alv size */
#define	HCSVSIZD	((HDRMD / 4) + 1)	/* hard D: csv size */
#define	HALVSIZD	((HDSMD / 8) + 1)	/* hard D: alv size */

#define	TKBUFSZ	(32 * 128)	/* number of bytes in track buffer */
				/* at least as large as a floppy track */

#define	DSKSTAT		0x00	/* commands */
#define	DSKRECAL	0x01
#define	DSKDFRMT	0x04	/* format disk */
#define	DSKTFRMT	0x06	/* format track */
#define	DSKREAD		0x08
#define	DSKSCAN		0x09
#define DSKWRITE	0x0a
#define	DSKCONFG	0xc0

#define	CTL512DD	0x34	/* default command control byte: 48 tpi */
				/* IBM sn, DD, 512 bps, DS, no ci, blk drq */
#define	CTL128SD	0x04	/* command control byte: 48 tpi */
				/* IBM sn, SD, 128 bps, DS, no ci, blk drq */

#define	BUSY		0x80	/* status bits */
#define	DRQ		0x08	/* data request - can xfer DCXFER bytes */
#define	RST		0x80	/* sense status bit - reset */
#define	RDY		0x08	/* sense status bit - drive ready */
#define	NOERR		0x00	/* sense error code - no error */
#define	IDNTFND		0x06	/* sense error code - ID header not found */
#define	CORRDER		0x13	/* sense error code - correctable read error */

#define	TPI96	0x80
#define	TPI48	0

#if ! MEMDSK
#define NUMDSKS 4		/* number of disks defined */
#else
#define NUMDSKS 5
#endif

/* default number of logical sectors per physical sector for each drive */
WORD lperp[NUMDSKS] = { 512/LSCTSZ, 512/LSCTSZ, 256/LSCTSZ, 256/LSCTSZ};


/************************************************************************/
/* BIOS  Table Definitions						*/
/************************************************************************/

/* Disk Parameter Block Structure */

struct dpb
{
	WORD	spt;
	BYTE	bsh;
	BYTE	blm;
	BYTE	exm;
	BYTE	dpbjunk;
	WORD	dsm;
	WORD	drm;
	BYTE	al0;
	BYTE	al1;
	WORD	cks;
	WORD	off;
};


/* Disk Parameter Header Structure */

struct dph
{
	BYTE	*xltp;
	WORD	 dphscr[3];
	BYTE	*dirbufp;
struct	dpb	*dpbp;
	BYTE	*csvp;
	BYTE	*alvp;
};



/************************************************************************/
/*	Directory Buffer for use by the BDOS				*/
/************************************************************************/

BYTE dirbuf[LSCTSZ];

#if ! LOADER

/************************************************************************/
/*	CSV's								*/
/************************************************************************/

BYTE	csv0[FCSVSIZE];
#if DISKB
BYTE	csv1[FCSVSIZE];
#endif
BYTE	csv2[HCSVSIZC];
#if DISKD
BYTE	csv3[HCSVSIZD];
#endif

#if	MEMDSK
BYTE	csv4[16];
#endif

/************************************************************************/
/*	ALV's								*/
/************************************************************************/

BYTE	alv0[FALVSIZE];
#if DISKB
BYTE	alv1[FALVSIZE];
#endif
BYTE	alv2[HALVSIZC];
#if DISKD
BYTE	alv3[HALVSIZD];
#endif

#if	MEMDSK
BYTE	alv4[48];	/* (dsm4 / 8) + 1	*/
#endif

#endif
 
/************************************************************************/
/*	Disk Parameter Blocks						*/
/************************************************************************/

/*************    spt, bsh, blm, exm, jnk,   dsm,  drm, */
	/* al0, al1, cks, off */

#if   MEMDSK
struct dpb dpb3 =	/* memory disk */
	{ 32, 4, 15, 0, 0, 191, 63,
	0, 0, 0, 0};
#endif

struct dpb dpb96 =	/* 96 tpi floppy disk - BLS = 2048 */
	{ 32, 4, 15, 0, 0, FDSM96, FDRM,
	0xc0, 0, FCSVSIZE, 2};

struct dpb dpb48 =	/* 48 tpi floppy disk - BLS = 2048 */
	{ 32, 4, 15, 1, 0, FDSM48, FDRM,
	0xc0, 0, FCSVSIZE, 2};

struct dpb dpbwdc =	/* winchester disk C: - BLS = 4096 */
	{ 32, 5, 31, 1, 0, HDSMC, HDRMC,
	0xff, 0, HCSVSIZC, 4};

#if DISKD
struct dpb dpbwdd =	/* winchester disk D: - BLS = 4096 */
	{ 32, 5, 31, 1, 0, HDSMD, HDRMD,
	0xff, 0, HCSVSIZD, 4};
#endif

/************************************************************************/
/* Sector Translate Table for Floppy Disks				*/ 
/************************************************************************/

/*	No translation for 5-1/4" floppy disks */

 
/************************************************************************/
/* Disk Parameter Headers						*/
/*									*/
/* Four disks are defined : dsk a: diskno=0, (Motorola's #fd02)		*/
/* 			  : dsk b: diskno=1, (Motorola's #fd03)		*/
/*			  : dsk c: diskno=2, (Motorola's #hd00)		*/
/*			  : dsk d: diskno=3, (Motorola's #hd01)		*/
/*									*/
/************************************************************************/

#if ! LOADER

/* Disk Parameter Headers */
struct dph dphtab[] =

	{ { NULL, 0, 0, 0, dirbuf,  &dpb96, csv0, alv0},	/* dsk a */
#if DISKB
	  { NULL, 0, 0, 0, dirbuf,  &dpb96, csv1, alv1},	/* dsk b */
#else
	  { NULL, 0, 0, 0, dirbuf,  &dpb96, NULL, NULL},	/* dsk b */
#endif
	  { NULL, 0, 0, 0, dirbuf, &dpbwdc, csv2, alv2},	/* dsk c */
#if DISKD
	  { NULL, 0, 0, 0, dirbuf, &dpbwdd, csv3, alv3},	/* dsk d */
#else
	  { NULL, 0, 0, 0, dirbuf,    NULL, NULL, NULL},	/* dsk d */
#endif

#if   MEMDSK
	  {  0L, 0, 0, 0, dirbuf, &dpb3, csv4, alv4}  /*dsk e*/
#endif
	};

#else

struct dph dphtab[4] =

	{ { NULL, 0, 0, 0, dirbuf,  &dpb96, NULL, NULL},	/* dsk a */
	  { NULL, 0, 0, 0, dirbuf,  &dpb96, NULL, NULL},	/* dsk b */
	  { NULL, 0, 0, 0, dirbuf, &dpbwdc, NULL, NULL},	/* dsk c */
#if DISKD
	  { NULL, 0, 0, 0, dirbuf, &dpbwdd, NULL, NULL},	/* dsk d */
#endif
	};
#endif

/************************************************************************/
/*	Currently Selected Disk Stuff					*/
/************************************************************************/

WORD settrk, setsec, setdsk;	/* Currently set track, sector, disk */
BYTE *setdma;			/* Currently set dma address */

/* 48/96 tpi flags for floppies: 0x80-> 96 tpi, 0-> 48 tpi */
WORD	tkflg[NUMDSKS];

/* last psn referenced on each drive - used to speed up determination */
/* of floppy diskette type when logging a new diskette */
LONG	lstpsn[NUMDSKS];

/* flag indicating configuration has been done */
WORD	config = 0;

#if LOADER
/* disk that booter was loaded from - set by booter - load cpm.sys from it */
WORD	bootdsk = 2;		/* disk number is controller lun (first fd) */
#endif


/************************************************************************/
/*	Track Buffering Definitions and Variables			*/
/************************************************************************/

#if ! LOADER

#define	NUMTB	3 /* Number of track buffers -- must be at least 3	*/
		  /* for the algorithms in this BIOS to work properly	*/

/* Define the track buffer structure */

struct	tbstr {	
		struct	tbstr  *nextbuf;     /* form linked list for LRU  */
			BYTE	buf[TKBUFSZ]; /* at least fd trk */
			WORD	dsk;	     /* disk for this buffer  */
			WORD	trk;	     /* track for this buffer */
			BYTE	valid;	     /* buffer valid flag     */
			BYTE	dirty;	     /* true if a BIOS write has   */
					     /*	put data in this buffer,   */
					     /*	but the buffer hasn't been */
					     /* flushed yet.		   */
};

struct tbstr *firstbuf;	/* head of linked list of track buffers */
struct tbstr *lastbuf;  /* tail of ditto */

struct tbstr tbuf[NUMTB];	/* array of track buffers */

#else

/* the loader bios uses only 1 track buffer */

BYTE buf1trk[TKBUFSZ];	/* at least fd trk */
BYTE bufvalid;
WORD buftrk;

#endif


/************************************************************************/
/*	Define the number of disks supported and other disk stuff	*/
/************************************************************************/

#define MAXDSK  (NUMDSKS-1)	/* maximum disk number 	   */

BYTE cnvdsk[NUMDSKS]  = { 2, 3, 0, 1 };  /* convert CP/M dsk# to Motorola */
BYTE rcnvdsk[NUMDSKS] = { 2, 3, 0, 1 };	 /* and vice versa */


/************************************************************************/
/*	Disk I/O Packets and Variables					*/
/************************************************************************/

struct dio			/* disk controller registers */
{
	BYTE	cmdsns;		/* command/sense byte */
	BYTE	diofl1;		/* fill byte */
	BYTE	intstt;		/* interrupt/status byte */
	BYTE	diofl2;		/* fill byte */
	BYTE	rst;		/* reset */
	BYTE	diofl3;		/* fill byte */
	BYTE	ntusd;		/* not used */
	BYTE	diofl4;		/* fill byte */
	BYTE	data;		/* data */
};

struct snsstr			/* sense packet */
{
	BYTE	ercode;		/* error code */
	BYTE	lun;		/* CP/M logical unit number */
	BYTE	status;		/* status includes controller lun */
	WORD	pcylnm;		/* physical cylinder number */
	BYTE	headnm;		/* head number */
	BYTE	sectnm;		/* sector number */
	BYTE	n;		/* number sectors left to process */
	BYTE	snsbt6;		/* sense packet byte 6 */
	BYTE	snsbt7;		/* sense packet byte 7 */
	BYTE	snsbt8;		/* sense packet byte 8 */
	BYTE	snsbt9;		/* sense packet byte 9 */
};

struct snsstr sns;		/* last sense packet read form disk */

/************************************************************************/
/*	Send disk command packet					*/
/************************************************************************/

sndcmd(dsk, psn, n, ctl, cmd)
REG WORD dsk, n, ctl, cmd;
REG LONG psn;
{
	/* write the packet to the controller */
	/* the DSKCNTL references must NOT be reordered */

	/* update last psn referenced */
	switch (cmd)
	{
	case DSKREAD:
	case DSKWRITE:
	case DSKSCAN:
	case DSKTFRMT:
		lstpsn[dsk] = psn;
		break;
	case DSKRECAL:
		lstpsn[dsk] = 0;
		break;
	}

	/* correction for reading or writing track 0 */
	/* track 0 is sd, 128 bytes/sector, 16 sectors */
	/* correction assumes reads and writes are done on a track basis */
	if ( (dsk < 2) && ((cmd == DSKREAD) || (cmd == DSKWRITE)) )
		if ( psn == 0 )
		{
			ctl = CTL128SD;
			n = 16;
		}

	DSKCNTL->cmdsns = cmd;	/* command - byte 0 */
	/* following line assumes psn <= 21 bits long */
	DSKCNTL->cmdsns = (cnvdsk[dsk] << 5) | (psn >> 16);	/* byte 1 */
	DSKCNTL->cmdsns = (psn >> 8);	/* byte 2 */
	DSKCNTL->cmdsns = psn;		/* byte 3 */
	DSKCNTL->cmdsns = n;		/* byte 4 */
	DSKCNTL->cmdsns = ctl | tkflg[dsk];	/* byte 5 */
}

/************************************************************************/
/*	Send disk configuration packet					*/
/************************************************************************/

sndcnf(dsk, mxhd, mxcl, prcmp)
REG WORD dsk, mxhd, mxcl, prcmp;
{
	WORD zero;

	zero = 0;	/* so clr.b won't be generated for byte 5 */

	/* write the configuration packet to the controller */
	/* the DSKCNTL references must NOT be reordered */

	DSKCNTL->cmdsns = DSKCONFG;	/* command - byte 0 */
	DSKCNTL->cmdsns = (cnvdsk[dsk] << 5);	/* byte 1 */
	/* following line assumes mxcl <= 13 bits long */
	DSKCNTL->cmdsns = (mxhd << 5) | (mxcl >> 8);	/* byte 2 */
	DSKCNTL->cmdsns = mxcl;		/* byte 3 */
	DSKCNTL->cmdsns = prcmp;	/* byte 4 */
	DSKCNTL->cmdsns = zero;		/* byte 5 */

	/* performs automatic recalibration - set last psn to 0 */
	lstpsn[dsk] = 0;
}

/************************************************************************/
/*	Get disk sense							*/
/************************************************************************/

gtsns()
{
	/* read the sense block from the controller */
	/* the DSKCNTL references must NOT be reordered */

	while ( DSKCNTL->intstt & BUSY )
		;	/* wait while controller busy */

	sns.ercode = DSKCNTL->cmdsns;
	sns.status = DSKCNTL->cmdsns;
	sns.lun = rcnvdsk[(sns.status >> 5) & 0x3];
	sns.pcylnm = DSKCNTL->cmdsns;
	sns.pcylnm = (sns.pcylnm << 8) + DSKCNTL->cmdsns;
	sns.headnm = DSKCNTL->cmdsns;
	sns.sectnm = sns.headnm & 0x1f;
	sns.headnm = sns.headnm >> 5;
	sns.n = DSKCNTL->cmdsns;
	sns.snsbt6 = DSKCNTL->cmdsns;
	sns.snsbt7 = DSKCNTL->cmdsns;
	sns.snsbt8 = DSKCNTL->cmdsns;
	sns.snsbt9 = DSKCNTL->cmdsns;
}


#if NO_ASM_SUPPORT

/************************************************************************/
/*	Disk read data transfer						*/
/************************************************************************/

rddat(bp)
REG BYTE *bp;
{
	/* This routine should be written in assembly language later. */

	REG WORD cnt;
	for ( cnt = DCXFER; cnt; cnt-- )
		*bp++ = DSKCNTL->data;
}

/************************************************************************/
/*	Disk write data transfer					*/
/************************************************************************/

wrdat(bp)
REG BYTE *bp;
{
	/* This routine should be written in assembly language later. */

	REG WORD cnt;
	for ( cnt = DCXFER; cnt; cnt-- )
		DSKCNTL->data = *bp++;
}

#endif	/* NO_ASM_SUPPORT	*/

/************************************************************************/
/*	Translate track number to physical sector number		*/
/************************************************************************/

LONG tk2psn(dsk, trk)
REG WORD dsk, trk;
{
	REG struct dpb *pp;
	REG WORD ttrks;

	pp = dphtab[dsk].dpbp;
	if ( dsk >= 2 )
		return(trk*((pp->spt)/lperp[dsk]));
	ttrks = 80;
	if ( pp == &dpb96 ) ttrks = 160;
	if ( trk < ttrks/2 )
		return(trk*((pp->spt)/lperp[dsk])*2);
	return(((ttrks-trk)*2-1)*(pp->spt/lperp[dsk]));
}

/************************************************************************/
/*	Disk Read with error correction					*/
/************************************************************************/

WORD rddsk(dsk, psn, pscnt, bufp)
REG WORD  dsk, pscnt;
REG LONG  psn;
REG BYTE *bufp;
{
	LONG erofst;	/* offset from bp of location to correct */
	BYTE *bp;	/* address of last sector read - for correction */

	sndcmd(dsk, psn, pscnt, CTL512DD, DSKREAD);
	while ( 1 )
	{
		while ( DSKCNTL->intstt & BUSY )
			if ( DSKCNTL->intstt & DRQ )
			{
				rddat(bufp);
				bufp += DCXFER;
			}
		gtsns();	/* check for error */
		if ( sns.ercode != CORRDER )
			return (sns.ercode);
		else
		{		/* correct the data - winchester only */
			erofst = (sns.snsbt6 << 8) + sns.snsbt7;
			bp = (BYTE *)((LONG)bufp - 256);
			bp[erofst] ^= sns.snsbt8;
			bp[erofst+1] ^= sns.snsbt9;
			if ( sns.n )	/* more to read - reissue command */
				sndcmd(dsk, psn+pscnt-sns.n, sns.n,
					CTL512DD, DSKREAD);
			else return (0);	/* done - no error to report */

			/* Should probably check for consistent correctable
			error (snsbt6-9 same twice) then write corrected
			sector back to disk.  Refer to Winchester Disk
			Controller User's Manual section 4.3 Disk Error
			Recovery page 4-15. */
		}
	}
}

/************************************************************************/
/*	Disk Transfer							*/
/************************************************************************/

dskxfer(dsk, trk, bufp, cmd)
REG WORD  dsk, trk, cmd;
REG BYTE *bufp;
{
	WORD  rcnt;	/* retry count */
	LONG  psn;	/* physical sector number */
	WORD  pscnt;	/* physical sector count */
	WORD  scnt;	/* # of xfer blocks (= # logical sectors) */
	BYTE *bp;	/* buffer pointer for retries */
	WORD  error;	/* error flag */

	/* set up */
	psn = tk2psn(dsk, trk);
	scnt = dphtab[dsk].dpbp->spt;
	pscnt = scnt/lperp[dsk]; /* # phys sctrs */
	bp = bufp;		/* save buffer addr */
	rcnt = 10;		/* retry count */

	do			/* error retry loop */
	{
		/* handle command */
		switch (cmd)
		{
		case DSKREAD:
			error = rddsk(dsk, psn, pscnt, bufp);
			break;
		case DSKWRITE:
			sndcmd(dsk, psn, pscnt, CTL512DD, cmd);
			while ( DSKCNTL->intstt & BUSY )
				if ( (DSKCNTL->intstt & DRQ) && scnt )
				{
					wrdat(bufp);
					bufp += DCXFER;
					scnt--;
				}
			gtsns();
			error = sns.ercode;
			break;
		default:
			sndcmd(dsk, psn, pscnt, CTL512DD, cmd);
			gtsns();
			error = sns.ercode;
			break;
		}
		bufp = bp;		/* restore buffer addr */
	} while (error && --rcnt);

	/* return pass/fail indication */
	if (error) return(0); /* failure */
	else 	   return(1); /* success */
}

#if ! LOADER
/************************************************************************/
/*	Mark all buffers for a disk as not valid			*/
/************************************************************************/

setinvld(dsk)
REG WORD dsk;
{
	REG struct tbstr *tbp;

	tbp = firstbuf;
	while ( tbp )
	{
		if ( tbp->dsk == dsk ) tbp->valid = 0;
		tbp = tbp->nextbuf;
	}
}
#endif

/************************************************************************/
/*	BIOS Select Disk Function					*/
/************************************************************************/

struct dph *slctdsk(dsk, logged)
REG BYTE dsk;
BYTE logged;
{
	REG struct dph	*dphp;
	REG LONG	 psn;

	setdsk = dsk;	/* Record selected disk number */

#if ! LOADER
	if ( (dsk > MAXDSK)
#if ! DISKB
	     || (dsk == 1)
#endif
#if ! DISKD
	     || (dsk == 3)
#endif
	   )
	{
		printstr("\n\rBIOS ERROR -- DISK ");
		cons_out('A'+dsk);
		printstr(" NOT SUPPORTED\n\r");
		return(0L);
	}
#endif

	dphp = &dphtab[dsk];

#if	MEMDSK
	if (setdsk == MEMDSK)
		return(dphp);
#endif

	if ( ! (logged & 0x1) )
	{
		/* determine disk type and size */
		switch ( dsk )
		{
			case 0:
			case 1:
				/* floppy disk */
#if ! LOADER
				setinvld(dsk);
#endif
				/* assume 96 tpi */
				if ( tkflg[dsk] == TPI48 )
				{
					lstpsn[dsk] *= 2; /* correct to 96 */
					tkflg[dsk] = TPI96;
				}

				/* lstpsn assumes 16 sct/cyl */
				psn = lstpsn[dsk] / 16;
				if ( psn == 0 ) psn = 1; /* skip track 0 */
				psn = psn * 16;		/* sector to test */

				/* scan a sector at an odd cyl to check */
				/* track density */
				sndcmd(dsk, psn, 1, CTL512DD, DSKSCAN);
				gtsns();
				switch (sns.ercode)
				{
				case NOERR:
					dphp->dpbp = &dpb96;
					break;
				case IDNTFND:
					dphp->dpbp = &dpb48;
					tkflg[dsk] = TPI48;
					break;
				default:	/* other error */
					dphp = NULL;
					break;
				}
				break;
			case 2:
			case 3:
				/* hard disk */
				break;
			default:
#if ! LOADER
				printstr("\n\rBIOS ERROR -- DISK ");
				cons_out('A'+dsk);
				printstr(" NOT SUPORTED\n\r");
#endif
				return(NULL);
		}
	}
	return(dphp);
}

/************************************************************************/
/*	Home Disk							*/
/************************************************************************/

homedsk()
{
	settrk = 0;
	sndcmd(setdsk, (LONG)0, 0, CTL512DD, DSKRECAL);
	while ( DSKCNTL->intstt & BUSY ) /* wait while controller busy */
		;			/* assume no errors */
}

/************************************************************************/
/*	Disk Initialization						*/
/************************************************************************/

initvdsks()
{
	REG WORD i;

	if ( config ) return;		/* only init once */

	/* turn off controller interrupts */
	DSKCNTL->intstt = 0;

	/* set up initial disk assumptions */
	for ( i = 0; i < NUMDSKS; i++ )
	{
		tkflg[i] = TPI96;
		lstpsn[i] = 0;
	}

	/* configure controller for disks */
	sndcnf(0, 1, 79, 40);		/* a: fd, 96 tpi, ds */
	while ( DSKCNTL->intstt & BUSY ) /* wait while controller busy */
		;			/* assume no errors */
#if DISKB
	sndcnf(1, 1, 79, 40);		/* b: fd, 96 tpi, ds */
	while ( DSKCNTL->intstt & BUSY ) /* wait while controller busy */
		;			/* assume no errors */
#endif
	sndcnf(2, CMHD, CMCYL, 255);	/* c: wd */
	while ( DSKCNTL->intstt & BUSY ) /* wait while controller busy */
		;			/* assume no errors */
#if DISKD
	sndcnf(3, DMHD, DMCYL, 255);	/* d: wd */
	while ( DSKCNTL->intstt & BUSY ) /* wait while controller busy */
		;			/* assume no errors */
#endif
	config = 1;			/* set configuration flag */
}


#if ! LOADER

/************************************************************************/
/*	Write one disk buffer						*/
/************************************************************************/

flush1(tbp)
struct tbstr *tbp;
{
	REG WORD ok;

	if ( tbp->valid && tbp->dirty )
		ok = dskxfer(tbp->dsk, tbp->trk, tbp->buf, DSKWRITE);
	else ok = 1;

	tbp->dirty = 0;		/* even if error, mark not dirty */
	tbp->valid &= ok;	/* otherwise system has trouble  */
				/* continuing.			 */
	return(ok);
}

/************************************************************************/
/*	Write all disk buffers						*/
/************************************************************************/

flush()
{
	REG struct tbstr *tbp;
	REG WORD ok;

	ok = 1;
	tbp = firstbuf;
	while (tbp)
	{
		if ( ! flush1(tbp) ) ok = 0;
		tbp = tbp->nextbuf;
	}
	return(ok);
}



/*************************************************************************/
/*	Fill the indicated disk buffer with the current track and sector */
/*************************************************************************/

fill(tbp)
REG struct tbstr *tbp;
{
	REG WORD ok;

	if ( tbp->valid && tbp->dirty ) ok = flush1(tbp);
	else ok = 1;

	if (ok) ok = dskxfer(setdsk, settrk, tbp->buf, DSKREAD);

	tbp->valid = ok;
	tbp->dirty = 0;
	tbp->trk = settrk;
	tbp->dsk = setdsk;

	return(ok);
}


/************************************************************************/
/*	Return the address of a track buffer structure containing the	*/
/*	currently set track of the currently set disk.			*/
/************************************************************************/

struct tbstr *gettrk()
{
	REG struct tbstr *tbp;
	REG struct tbstr *ltbp;
	REG struct tbstr *mtbp;

	/* Does not check for disk on-line.  Doing so causes floppy */
	/* disk I/O to be extremely slow.  We will catch the disk */
	/* problem the next time we try to read or write the disk. */

	/* Search through buffers to see if the required stuff	*/
	/* is already in a buffer				*/

	tbp = firstbuf;
	ltbp = 0;
	mtbp = 0;

	while (tbp)
	{
		if ( (tbp->valid) && (tbp->dsk == setdsk) 
		     && (tbp->trk == settrk) )
		{
			if (ltbp)	/* found it -- rearrange LRU links */
			{
				ltbp->nextbuf = tbp->nextbuf;
				tbp->nextbuf  = firstbuf;
				firstbuf      = tbp;
			}
			return ( tbp );
		}
		else
		{
			mtbp = ltbp;	/* move along to next buffer */
			ltbp = tbp;
			tbp  = tbp->nextbuf;
		}
	}

	/* The stuff we need is not in a buffer, we must make a buffer	*/
	/* available, and fill it with the desired track		*/

	if (mtbp) mtbp->nextbuf = 0;	/* detach lru buffer */
	ltbp->nextbuf = firstbuf;
	firstbuf = ltbp;
	if (flush1(ltbp) && fill(ltbp)) mtbp = ltbp;	/* success */
	else				mtbp = 0L ;	/* failure */
	return (mtbp);
}



/************************************************************************/
/*	Bios READ Function -- read one sector				*/
/************************************************************************/

read()
{
	REG BYTE	*p;
	REG BYTE	*q;
	REG WORD	 i;
	REG struct tbstr *tbp;

#if	MEMDSK
    if(setdsk != MEMDSK)
    {
#endif
	tbp = gettrk();		/* locate track buffer with sector */

	if ( ! tbp ) return(1); /* failure */

	/* locate sector in buffer and copy contents to user area */

	p = (tbp->buf) + (setsec << 7);	/* multiply by shifting */
#if	MEMDSK
    }
    else
	p = memdsk + (((LONG)(settrk) << 12L) + ((LONG)setsec << 7L));
#endif
	q = setdma;
	i = 128;
	do {*q++ = *p++; i -= 1;} while (i); /* this generates good code */
	return(0);
}


/************************************************************************/
/*	BIOS WRITE Function -- write one sector 			*/
/************************************************************************/

write(mode)
BYTE mode;
{
	REG BYTE	*p;
	REG BYTE	*q;
	REG WORD	 i;
	REG struct tbstr *tbp;

	/* locate track buffer containing sector to be written */
#if	MEMDSK
    if(setdsk != MEMDSK)
    {
#endif
	tbp = gettrk();
	if ( ! tbp ) return (1); /* failure */

	/* locate desired sector and do copy the data from the user area */

	p = (tbp->buf) + (setsec << 7);	/* multiply by shifting */
#if	MEMDSK
     } else
     {
	p = memdsk + (((LONG)(settrk) << 12L) + ((LONG)setsec << 7L));
	q = setdma;
	i = 128;
	do {*p++ = *q++; i -= 1;} while (i); /* this generates good code */
	return(0);
      }
#endif
	q = setdma;
	i = 128;
	do {*p++ = *q++; i -= 1;} while (i); /* this generates good code */

	tbp->dirty = 1;	/* the buffer is now "dirty" */

	/* The track must be written if this is a directory write */

	if ( mode == 1 ){if ( flush1(tbp) ) return(0); else return(1);}
	else return(0);
}

#else

/************************************************************************/
/*	Read and Write functions for the Loader BIOS			*/
/************************************************************************/

read()
{
	REG BYTE *p;
	REG BYTE *q;
	REG WORD  i;

	if ( ( (! bufvalid) || (buftrk != settrk) ) &&
	     ( ! dskxfer(setdsk, settrk, buf1trk, DSKREAD) ) ) {return(1);}
	bufvalid = 1;
	buftrk = settrk;
	p = buf1trk + (setsec << 7);
	q = setdma;
	i = 128;
	do { *q++ = *p++; i-=1; } while(i);
	return(0);
}

#endif


/************************************************************************/
/*	BIOS Sector Translate Function					*/
/************************************************************************/

WORD sectran(s, xp)
REG WORD  s;
REG BYTE *xp;
{
	if (xp) return (WORD)xp[s];
	else	return (s+1);
}


/************************************************************************/
/*	BIOS Set Exception Vector Function				*/
/************************************************************************/

				/* exception vector base address	*/
LONG		*vbase = ((LONG *)0);

LONG setxvect(vnum, vval)
WORD vnum;
LONG vval;
{
	REG LONG  oldval;
	REG LONG *vloc;

	vloc = &vbase[vnum]; 
	oldval = *vloc;

/* TENBUG used the illegal instruction, trace, TRAP #15 and user
   vector 78 (Abort button on console) so don't allow these to be
   clobbered while debugging.  Also we use TRAP #15 to do screen 
   output.								*/

	if (
#ifdef	DEBUG
	   (vnum != 4) &&		/* illegal instruction		*/
	   (vnum != 9) &&		/* trace vector       		*/
#endif
	   (vnum != 47) &&		/* TRAP #15 vector		*/
	   (vnum != 78)) 		/* user trap (trap # 78)	*/

		*vloc = vval;

	return(oldval);	

}


#if ! LOADER
/****************************************************************/
/*								*/
/*	This function is included as an undocumented, 		*/
/*	unsupported method for VME/10 users to format		*/
/*	disks.  It is not a part of CP/M-68K proper, and	*/
/*	is only included here for convenience, since the	*/
/*	Motorola disk controller is somewhat complex to		*/
/*	program, and the BIOS contains supporting routines.	*/
/*								*/
/****************************************************************/

format(dsk)
REG WORD dsk;
{
	if ( ! slctdsk( (BYTE)dsk, (BYTE) 1 ) ) return(0);

#if	MEMDSK
	if (setdsk == MEMDSK) return(1);
#endif

	tkflg[dsk] = TPI96;
	sndcmd(dsk, (LONG)0, 0, CTL512DD, DSKDFRMT);
	gtsns();
	if ( sns.ercode ) return(0);
	sndcmd(dsk, (LONG)0, 0, CTL128SD, DSKTFRMT);
	gtsns();
	if ( sns.ercode ) return(0);
	return(1);
}

#endif 

/************************************************************************/
/*									*/
/*	Bios initialization.  Must be done before any regular BIOS	*/
/*	calls are performed.						*/
/*									*/
/************************************************************************/

biosinit()
{
#if ! LOADER
	c_init();
	m400init();

#if	MVME410
	m410_init();
#endif

#endif
	initdsks();
}

initdsks()
{
	REG WORD i;

#if ! LOADER
	for ( i = 0; i < NUMTB; ++i )
	{
		tbuf[i].valid = 0;
		tbuf[i].dirty = 0;
		if ( (i+1) < NUMTB ) tbuf[i].nextbuf = &tbuf[i+1];
		else		     tbuf[i].nextbuf = 0;
	}
	firstbuf = &tbuf[0];
	lastbuf  = &tbuf[NUMTB-1];
#else
	bufvalid = 0;
#endif

	initvdsks();

}
 

#if	! LOADER
 /**********************************************************************
 *	Driver for MVME400 Dual RS-232C Serial Port Module
 ************************************************************************

 *	WARNING:  DO NOT OPTIMIZE THIS DRIVER !!!!!!!
 *	It contains redundant stores to the serial controller
 *	that are necessary for proper operation.
 */


/* 7201 control register 0 operations */

#define SELREG1		1
#define SELREG2		2
#define SELREG3		3
#define SELREG4		4
#define SELREG5		5
#define SELREG6		6
#define SELREG7		7
#define ABRTSDLC	8
#define REXSTINT	0x10
#define CHANRST		0x18
#define INTNXTRC	0x20
#define RSTTXINT	0x28
#define ERRRST		0x30
#define EOINT		0x38
#define RSTRXCRC	0x40
#define RSTTXCRC	0x80
#define RSTTXUR		0xC0

/* 7201 control register 1 operations */

#define EXINTEN		1
#define TXINTEN		2
#define STATAFV		4
#define RXINTDS		0
#define RXINT1		8
#define RXINTALP	0x10
#define RXINTANP	0x18
#define WAITRXTX	0x20
#define WAITEN		0x80
#define INTDSMSK	0xE4

/* 7201 control register 2A operations (2B is int vector) */

#define BOTHINT		0
#define ADMABINT	1
#define BOTHDMA		2
#define PRIAGB		0
#define PRIRGT		4
#define M8085M		0
#define M8085S		8
#define M8086		0x10
#define NONVEC		0
#define INTVEC		0x20
#define RTSBP10		0
#define SYNCBP10	0x80

/* 7201 control register 3 operations */

#define RXENABLE	1
#define SYNLDIN		2
#define ADRSRCH		4
#define RXCRCEN		8
#define ENTHUNT		0x10
#define AUTOENA		0x20
#define RX5BITS		0
#define RX7BITS		0x40
#define RX6BITS		0x80
#define RX8BITS		0xC0
#define RXSZMSK		0x3F

/* 7201 control register 4 operations */

#define PARENAB		1
#define EVENPAR		2
#define ODDPAR		0
#define SYNCMODE	0
#define SBIT1		4
#define SBIT1P5		8
#define SBIT2		0xC
#define SBITMSK		0xF3
#define SYN8BIT		0
#define	SYN16BIT	0x10
#define SDLCMODE	0x20
#define EXTSYNC		0x30
#define CLKX1		0
#define CLKX16		0x40
#define CLKX32		0x80
#define CLKX64		0xC0

/* 7201 control register 5 operations */

#define TXCRCEN		1
#define RTS		2
#define CRC16		4
#define CRCCCITT	0
#define TXENABLE	8
#define SENDBRK		0x10
#define TX5BITS		0
#define TX7BITS		0x20
#define TX6BITS		0x40
#define TX8BITS		0x60
#define TXSZMSK		0x9F
#define DTR		0x80

/* 7201 control register 6 = sync bits 0-7 */
/* 7201 control register 7 = sync bits 8-15 */

/* 7201 status register 0 */

#define RXCHAR		1		/*Recieve character available */
#define INTPNDNG	2
#define TXBUFEMP	4		/*Transmit register is empty  */
#define DCD		8
#define SYNCHUNT	0x10
#define CTS		0x20
#define TXUNDER		0x40
#define BRKABRT		0x80

/* 7201 status register 1 */

#define PARERR		0x10
#define RXOVRUN		0x20
#define CRCFRMER	0x40
#define EOFRAME		0x80

/* 7201 status register 2 = int vector */

#define FALSE		0
#define TRUE		1

/* Macro to WRITE information to the 7201's control registers		*/

#define WRITE(y,x,z,w)	*y = x;\
			*y = aux_state[z].w

#define M400_1		0	/* table indices for the 2 auxillary ports */
#define M400_2		1
#define AUX 		M400_1	/* Auxllary Serial Device		*/
#define LST 		M400_2	/* List Device (line printer)		*/


                               		/* baud rate control values
	 0 for   0 ,	 0 for  50 ,	 1 for  75 ,	 2 for 110 ,
	 3 for 134 ,	 4 for 150 ,	 4 for 200 ,	 5 for 300 ,
	 6 for 600 ,	 7 for1200 ,	 8 for1800 ,	10 for2400 ,
	12 for4800 ,	14 for9600 ,	15 forEXTA ,	15 forEXTB 
					      EXTA & EXTB = 19.2K  */
typedef struct
   {
   BYTE		cr1;
   BYTE		cr2;
   BYTE		cr3;
   BYTE		cr4;
   BYTE		cr5;
   BYTE		baud;			/*baud rate for the port */
   BYTE		char_size;		/*size of character: 0x20 = 7
							     0x40 = 6
							     0x60 = 8 */
   } mstate;

		/*following is the actual variable which holds the state
		  of the MVME400 board. It is referenced in the code below
		  using the pointer variable "aux_state" defined above.
		  The array dimesion expression forces even byte alignment
		  at the end of each element of mstate(of which there are
		  2).  All of this foolishness is necessary because the
		  C compiler will not initialize char variables.	*/

BYTE		init_state[] = {
		(0),      	  		/* A cr1 */
		(BOTHINT|PRIRGT|M8086|RTSBP10),	/* A cr2 */
		(AUTOENA|RX8BITS|RXENABLE),    	/* A cr3 */
		(SBIT1|CLKX16), 		/* A cr4 */
		(TXENABLE|TX8BITS|RTS|DTR),    	/* A cr5 */
		(14), 				/* A baud rate = 9600*/
		(TX8BITS),     			/* A character size */
		(0), 				/* Dummy fill char  */
		(STATAFV),       		/* B cr1 */
		(0), 				/* B cr2 */
		(AUTOENA|RX8BITS|RXENABLE),    	/* B cr3 */
		(SBIT1|CLKX16), 		/* B cr4 */
		(TXENABLE|TX8BITS|RTS|DTR),    	/* B cr5 */
		(7), 				/* A baud rate = 1200*/
		(TX8BITS), 			/* A character size */
		0				/* Dummy fill char  */
};

		/* State of the MVME400 board; one set of information
		   for each of the ports on the board		     	*/

mstate		*aux_state = (mstate *)init_state;

/*
 *	Structure of MVME400 hardware registers.
 *	Assumes an odd starting address.
 */
typedef struct
   {
	BYTE		m4_piaad;	/* pia a data */
	BYTE		m4_fill0;	/* fill */
	BYTE		m4_piaac;	/* pia a control */
	BYTE		m4_fill1;	/* fill */
	BYTE		m4_piabd;	/* pia b data */
	BYTE		m4_fill2;	/* fill */
	BYTE		m4_piabc;	/* pia b control */
	BYTE		m4_fill3;	/* fill */
	BYTE		m4_7201d[3];	/* 7201 a data */
/*	BYTE		m4_fill4;	   fill */
/*	BYTE		m4_72bd;	   7201 b data */
	BYTE		m4_fill5;	/* fill */
	BYTE		m4_7201c[3];	/* 7201 a control */
/*	BYTE		m4_fill6;	   fill */
/*	BYTE		m4_72bc;	   7201 b control */
   } m4_map;

/* MVME400 BASE ADDRESS							*/

#define	M400_ADDR	((m4_map *)0xf1c1c1)	

/* Macro to dereference VME/10 control register #6 */

#define IOCHANRG	(*(BYTE *)0xF19F11)
#define CHN3EN		0x20

/*********************************************************************
** Initialize both ports on the mvme400 card 
**********************************************************************/

m400init()
   {
   REG BYTE		*caddra, *caddrb;
   REG m4_map 		*addr;

   IOCHANRG &= ~CHN3EN;		/* disable I/O channel 3 interrupts */

   aux_state = (mstate *)init_state;/*aux_state points at initialized array*/

   if ( no_device((LONG)M400_ADDR) ) return;

   addr = M400_ADDR;
   caddra = &addr->m4_7201c[0];	/* address of A side control register*/
   caddrb = &addr->m4_7201c[2];	/* address of B side control register*/
   addr->m4_piaac = 0;		/* set up pia data direction regs */
   addr->m4_piaad = 0x18;
   addr->m4_piaac = 4;
   addr->m4_piabc = 0;
   addr->m4_piabd = 0xff;
   addr->m4_piabc = 4;
   addr->m4_piaad = 0;		/* fail led off */

				/* set the baud rate for both ports	*/
				
   addr->m4_piabd = (aux_state[M400_1].baud << 4) 	/* A port */
			| aux_state[M400_2].baud;	/* B port */

   *caddra = CHANRST;		/* reset channels */
linit1:				/* label to force generation of next line */
   *caddra = CHANRST;		/* write twice so */
   *caddrb = CHANRST;		/* it is sure to be */
linit2:			
   *caddrb = CHANRST;		/* written to cr0 */
				/* Initialize the control registers NEC 7201
				   Communiciations controller chip	*/

   WRITE(caddra,SELREG2,M400_1,cr2);
   WRITE(caddrb,SELREG2,M400_2,cr2);
   WRITE(caddra,SELREG4,M400_1,cr4);
   WRITE(caddra,SELREG3,M400_1,cr3);
   WRITE(caddra,SELREG5,M400_1,cr5);
   WRITE(caddra,SELREG1|RSTTXINT,M400_1,cr1);
   WRITE(caddrb,SELREG4,M400_2,cr4);
   WRITE(caddrb,SELREG3,M400_2,cr3);
   WRITE(caddrb,SELREG5,M400_2,cr5);
   WRITE(caddrb,SELREG1|RSTTXINT,M400_2,cr1);
}
/*********************************************************************
** Read a character from one of the asynchronous ports on the mvme400
**********************************************************************/

BYTE m400_in(port)

REG WORD	port;
   {
   m4_map	*addr;

   while (!(((M400_ADDR)->m4_7201c[port*2]) & RXCHAR));/*wait for char. ready*/

   return((M400_ADDR)->m4_7201d[port*2]);		/* get the char */
   }

/*********************************************************************
** Write a character to one of the asynchronous ports on the mvme400
**********************************************************************/

VOID m400_out(port, ch)

REG WORD	port;
REG BYTE	ch;
   {
   					/*wait till ready to send 	*/
   while (!(((M400_ADDR)->m4_7201c[port*2]) & TXBUFEMP));

   (M400_ADDR)->m4_7201d[port*2] = ch;	/* output the character		*/

   return;
   }
#endif

#if ! LOADER

#if MVME410
/***********************************************************************
 *	m410 driver for the VME/10.
 *	
 *	ROUTINES:
 *
 *	m410_init()	- initialize mvme410 card.
 *	m410_stat()	- check the status of the mvme410 card.
 *	m410_out()	- put a character out on the mvme410 card.
 *
 */

/* 
 *	base address of the mvme410
 *	control block.
 */

#define M410BASE	((struct m410_ctl_blk *) 0xF1C1E0)

struct m410_ctl_blk
{
	char	pad0;
	char	data_a;
	char	pad1;
	char	ctl_a;
	char	pad2;
	char	data_b;
	char	pad3;
	char	ctl_b;
};

/*
 *	define some simple aliases for structure members 
 *	above.
 */

#define stat_a		ctl_a
#define stat_b		ctl_b
#define ddr_a		data_a		/* ddr - data direction register */
#define ddr_b		data_b
#define prdy		data_b
#define strobe		ctl_a
#define acknowledge	ctl_a
#define ready		data_b

/*
 *	some control values - bit positions.
 */

#define PAPEROUT	0x2
#define SELECT		0x1

/*
 *	data strobe low and high following write.
 */

#define STROBELOW	0x34
#define STROBEHIGH	0x3C

/*
 *	data acknowledge is set after printer accepts
 *	character.
 */

#define DATA_ACK	0x80

/*
 *	m410_stat return values.
 */

#define NOTREADY	0x00
#define READY		0xFF


/*
 *	Initialization values.
 */

#define INITDDR		0x38
#define INITCTL		0x3C
#define OUTPUT		0xFF
#define INPUT		0x00

/*
 *	m410_init()
 *
 *	initialize the mvme 410 board for use as parallel
 *	printer interface.
 */

m410_init()
{
	register struct m410_ctl_blk	*m410_base;

	m410_base = M410BASE;

	/*
	 *	test if a 410 card is available before performing
	 *	initialization.
	 */

	if ( no_device((LONG)&(M410BASE->data_a)) ) return;

	/*
	 *	initialize a side of controller to output.
	 */

	m410_base->ctl_a = INITDDR;
	m410_base->ddr_a = OUTPUT;
	m410_base->ctl_a = INITCTL;

	/*
	 *	initialize b side of controller to input.
	 */

	m410_base->ctl_b = INITDDR;
	m410_base->ddr_b = INPUT;
	m410_base->ctl_b = INITCTL;
}


/*
 *	m410_stat()
 *
 *	determine status of mvme 410 board.  Is the device ready to write to.
 *
 *	returns:
 *
 *		$FF - if ready
 *		$00 - if not ready
 */


m410_stat()
{
	register struct m410_ctl_blk	*m410_base;
	register short	status;

	m410_base = M410BASE;

	status = m410_base->prdy & (PAPEROUT|SELECT);
	if( status != SELECT )
		return( NOTREADY );
	
	return( READY );
}

/*
 *	m410_out()
 *
 *	wait until device is ready,
 *	write a single character 'c' to the 410 card,
 *	wait for acknowledgement.
 */

m410_out(c)
register char	c;
{
	register struct m410_ctl_blk	*m410_base;

	while( m410_stat() == NOTREADY )
		;

	m410_base = M410BASE;

	m410_base->data_a = c;		/* write character out */

	c = m410_base->data_a;		/* dummy read to clear acknowledge */

	m410_base->strobe = STROBELOW;
	m410_base->strobe = STROBEHIGH;

	/*
	 *	wait for data acknowledge
	 */

	while( (m410_base->acknowledge & DATA_ACK) == 0 )
		;
	return;
}

/**************************************************************************/

#endif  /* MVME410 */
#endif	/* ! LOADER */
	


/************************************************************************/
/*									*/
/*      BIOS MAIN ENTRY -- Branch out to the various functions.		*/
/*									*/
/************************************************************************/
 
LONG cbios(d0, d1, d2)
REG WORD	d0;
REG LONG	d1, d2;
{

	switch(d0)
	{
		case 0:	biosinit();			/* INIT		*/
			break;

#if ! LOADER
		case 1:	flush();			/* WBOOT	*/
			initdsks();
			wboot();
		     /* break; */

		case 2:	return(cons_stat());		/* CONST	*/
		     /* break; */

		case 3: return(cons_in());		/* CONIN	*/
		     /* break; */
#endif
		case 4: cons_out((char)d1);		/* CONOUT	*/
			break;

#if ! LOADER

#if MVME410
		case 5: m410_out((char)d1);		/* LIST		*/
			break;
#else
		case 5:	m400_out(M400_2, (char)d1); 	/* LIST		*/
			break;
#endif

		case 6: m400_out(M400_1, (char)d1);	/* PUNCH	*/
			break;

		case 7:	return(m400_in(M400_1));	/* READER	*/
		     /* break; */
#endif

		case 8:	homedsk();			/* HOME		*/
			break;

		case 9:	
#if	LOADER
			d1 = rcnvdsk[bootdsk]; /* disk booter was loaded from */
#endif
		return((LONG)slctdsk((char)d1, (char)d2)); /* SELDSK	*/
		     /* break; */

		case 10: settrk = (int)d1;		/* SETTRK	*/
			 break;

		case 11: setsec = ((int)d1-1);		/* SETSEC	*/
			 break;

		case 12: setdma = (BYTE *)d1;		/* SETDMA	*/
			 break;

		case 13: return(read());		/* READ		*/
		      /* break; */
#if ! LOADER
		case 14: return(write((char)d1));	/* WRITE	*/
		      /* break; */

		case 15:
#if MVME410
			return(m410_stat());
#else
		      /* auxiliary input status */
		      break;
#endif /* MVME410 */
#endif /* ! LOADER */

		case 16: return(sectran((int)d1, d2));	/* SECTRAN	*/
		      /* break; */
#if ! LOADER
		case 18: return((LONG)&memtab);		/* GMRTA	*/
		      /* break; */

		case 19: return(iobyte);		/* GETIOB	*/
		      /* break; */

		case 20: iobyte = (int)d1;		/* SETIOB	*/
			 break;

		case 21: if (flush()) return(0L);	/* FLUSH	*/
			 else	      return(0xffffL);
		      /* break; */
#endif
		case 22: return(setxvect((int)d1,d2));	/* SETXVECT	*/
		      /* break; */
#if ! LOADER
		/**********************************************************/
		/*       This function is not part of a standard BIOS.	  */
		/*	 It is included only for convenience, and will	  */
		/*	 not be supported in any way, nor will it	  */
		/* 	 necessarily be included in future versions of	  */
		/* 	 CP/M-68K					  */
		/**********************************************************/
		case 63: return( ! format((int)d1) );	/* Disk Formatter */
		      /* break; */
#endif
	
	 	default: return(0L);
			 break;

	} /* end switch */


} /* END OF BIOS */
 
/* End of C Bios */

 */
#endif
	
	 	default: return(0L);
			 break;

	} /* end switch */