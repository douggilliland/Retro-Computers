
/***************************** 68000 SIMULATOR ****************************

File Name: DEF.H
Version: 1.0

This file contains definitions used in the simulator source files.

***************************************************************************/


/* version numbers */

#define	MAJOR_VERSION	1
#define	MINOR_VERSION	0


/* status register bitmasks */

#define bit_1		0x0001
#define bit_2		0x0002
#define bit_3		0x0004
#define bit_4		0x0008
#define bit_5		0x0010
#define bit_6		0x0020
#define bit_7		0x0040
#define bit_8		0x0080
#define bit_9		0x0100
#define bit_10		0x0200
#define bit_11		0x0400
#define bit_12		0x0800


#define	cbit		0x0001
#define	vbit		0x0002
#define	zbit		0x0004
#define	nbit		0x0008
#define	xbit		0x0010
#define	intmsk	0x0700         /* three bits */
#define	sbit		0x2000
#define	tbit		0x8000


/* miscallaneous */

#define MEMSIZE 0x10000
#define ADDRMASK 0xffff

#define	TRUE		-1
#define	FALSE		0
#define	BYTE		0xff              /* byte mask */
#define	WORD		0xffff        		/* word mask */
#define	LONG		0xffffffff			/* long mask */

#define	D_REGS	8              	/* number of D registers */
#define	A_REGS	9              	/* number of A registers */

#define DATA_ADDR 			0x0ffd
#define MEMORY_ADDR			0x0ffc
#define CONTROL_ADDR			0x07e4
#define ALTERABLE_ADDR		0x01ff
#define ALL_ADDR				0x0fff
#define DATA_ALT_ADDR		(DATA_ADDR & ALTERABLE_ADDR)
#define MEM_ALT_ADDR			(MEMORY_ADDR & ALTERABLE_ADDR)
#define CONT_ALT_ADDR		(CONTROL_ADDR & ALTERABLE_ADDR)


/* these are the instruction return codes */

#define SUCCESS			0x0000
#define BAD_INST			0x0001
#define NO_PRIVILEGE		0x0002
#define CHK_EXCEPTION	0x0003
#define ILLEGAL_TRAP		0x0004
#define STOP_TRAP			0x0005
#define TRAPV_TRAP		0x0006
#define TRAP_TRAP			0x0007
#define DIV_BY_ZERO		0x0008

#define USER_BREAK		0x0009
#define FAILURE			0x1111	/* general failure */


/* these are the cases for condition code setting */

#define	N_A			0
#define	GEN			1
#define	ZER			2
#define	UND			3
#define	CASE_1		4
#define	CASE_2		5
#define	CASE_3		6
#define	CASE_4		7
#define	CASE_5		8
#define	CASE_6		9
#define	CASE_7		10
#define	CASE_8		11
#define	CASE_9		12


/* these are used in run.c */

#define		MODE_MASK  		0x0038
#define		REG_MASK   		0x0007
#define		FIRST_FOUR 		0xf000

#define		READ				0xffff
#define		WRITE				0x0000


/* conditions for BCC, DBCC, and SCC */

#define		T				0x00
#define		F				0x01
#define		HI				0x02
#define		LS				0x03
#define		CC				0x04
#define		CS				0x05
#define		NE				0x06
#define		EQ				0x07
#define		VC				0x08
#define		VS				0x09
#define		PL				0x0a
#define		MI				0x0b
#define		GE				0x0c
#define		LT				0x0d
#define		GT				0x0e
#define		LE				0x0f


