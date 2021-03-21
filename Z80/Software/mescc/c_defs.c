/*	c_defs.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M

	Definitions.

	Copyright (c) 1999-2021 Miguel I. Garcia Lopez, FloppySoftware.

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	Revisions:

	17 Jan 2001 : Last revision.
	16 Apr 2007 : GPL'd.
	31 Jul 2014 : String pool resized to 9K (was 6000 bytes before).
	31 Jul 2014 : v1.02
	17 Feb 2015 : v1.03
	10 Apr 2015 : v1.04
	11 May 2015 : v1.05
	14 Aug 2015 : v1.06
	16 Aug 2015 : Removed TURBO C and PCC support.
	16 Aug 2015 : v1.07
	04 Sep 2015 : v1.08
	28 Oct 2015 : v1.09
	20 Nov 2015 : Added SY_FLAGS. Decreased local symbol table.
	22 Nov 2015 : Added ERCNTAS error message.
	27 Nov 2015 : Removed some text defs.
	02 Dec 2015 : v1.10
	08 Jan 2016 : Supported #ifs from 5 to 8.
	04 Apr 2016 : v1.11
	19 Jul 2016 : Removed def. ERMACUD (Macro not exist).
	20 Jul 2016 : v1.12
	12 Aug 2016 : v1.13
	03 Oct 2016 : v1.14
	11 Oct 2016 : Errors by id, instead by string. Removed #defines for help text. Documented.
	13 Oct 2016 : v1.15
	17 Oct 2016 : v1.16
	21 Oct 2016 : v1.17
	24 Oct 2016 : v1.18
	13 Dec 2017 : v1.19
	14 Feb 2018 : Added ERESCSQ and ERNOMEM error codes. Added C_USEMALLOC macro.
	              v1.20
	03 May 2018 : v1.21
	04 Jan 2021 : v1.22
	13 Jan 2021 : v1.23
*/

// Optional #defines
// -----------------

//#define C_USEPRINTF  // To use printf, fprintf and sprintf
#define C_USEMALLOC  // To use malloc for buffers

// Version
// -------

#define VERSION	"Mike's Enhanced Small C Compiler v1.23 - 13 Jan 2021"
#define COPYRGT "(c) 1999-2021 FloppySoftware"

// Output types
// ------------

#define OUT_PRG 0
#define OUT_LIB 1
#define OUT_ASM 2

// String (and array) buffer
// -------------------------

#define STRBUF_SIZ 9216

// Input line buffer
// -----------------

#define LN_MAX	255  // Max. # of characters
#define LN_SIZ	256  // Size: LN_MAX + ZERO

// Symbol table format
// -------------------

#define SY_NAME	    0   // 12 bytes
#define SY_IDENT    12  //  1 byte
#define SY_TYPE	    13  //  1 byte
#define SY_STORAGE  14  //  1 byte
#define SY_FLAGS    15  //  1 byte
#define SY_OFFSET   16  //  2 bytes (1 word)

#define SYMSIZE	    18  // Size of a symbol table record

// Symbol name
#define NAME_MAX    11  // Max. # of characters
#define NAME_SIZ    12  // Size: NAME_MAX + ZERO


// Identity
#define ID_VAR      1  // Variable
#define ID_ARR      2  // Array
#define ID_PTR      3  // Pointer
#define ID_FUN      4  // Function

// Type
#define TY_CHAR     1  // 00000001b char
#define TY_INT      2  // 00000010b int
#define TY_UCHAR    5  // 00000101b unsigned char
#define TY_UINT     6  // 00000110b unsigned int

// Storage
#define ST_EXTERN   1  // Extern
#define ST_STATIK   2  // Global
#define ST_STKLOC   3  // Local

// Flags
#define FL_VALUE    1  // 00000001b It has been initializated with a value
#define FL_STRBF    2  // 00000010b Value is an offset to the string buffer

// Symbol table storage
// --------------------

// Globals
#define GLB_NUM     450                    // Max. # of globals
#define GLB_TABSIZ  8100                   // Size: GLB_NUM * SYMSIZE
#define GLB_START   glbsymtab

#ifdef C_USEMALLOC
#define GLB_END     glbend
#else
#define GLB_END     (GLB_START+GLB_TABSIZ)
#endif

// Locals
#define LOC_NUM     32                     // Max. # of locals in a function
#define LOC_TABSIZ  576                    // Size: LOC_NUM * SYMSIZE
#define LOC_START   locsymtab

#ifdef C_USEMALLOC
#define LOC_END     locend
#else
#define LOC_END     (LOC_START+LOC_TABSIZ)
#endif

// Statement types
// ---------------

#define S_IF        1  // if
#define S_WHILE     2  // while
#define S_FOR       3  // for
#define S_SWITCH    4  // switch
#define S_RETURN    5  // return
#define S_BREAK     6  // break
#define S_CONT      7  // continue
#define S_EXP       8  // expression

// Switch statement
// ----------------

#define SWITCH_MAX 254 // Max. # of cases in a switch

// While queue table format
// ------------------------

#define WQ_SYM      0  // 1 word
#define WQ_SP       1  // 1 word
#define WQ_LOOP     2  // 1 word
#define WQ_LAB      3  // 1 word
#define WQ_LAB2     4  // 1 word
#define WQ_END      5  // 1 word
#define WQ_BODY     6  // 1 word

#define WQ_TABSIZ   120
#define WQ_SIZ      7
#define WQ_MAX      (wq+WQ_TABSIZ-WQ_SIZ)

// Preprocessor
// ------------

#define CPPMACSIZ   4000 // Macro table size
#define CPPMAXINC   3    // Max. # of included files
#define CPPMAXIFS   8    // Max. # of active #ifs
#define CPPHASHSIZ  53   // Hash table size: A..Z a..z _

// Error codes
// -----------

// Compiler
#define ERCONST  1 // Must be constant
#define ERARRSZ  2 // Illegal array size
#define ERARRPT  3 // Illegal *[]
#define ERCNTAS  4 // Can't assign
#define ERARGNB  5 // Illegal number of arguments
#define ERARGNM  6 // Need name of argument
#define ERFUNDE  7 // Illegal function declaration
#define ERSYMNM  8 // Illegal symbol name
#define ERALDEF  9 // Already defined
#define EROFGLB 10 // Global symbol table is full
#define EROFLOC 11 // Local symbol table is full
#define ERTMWHI 12 // Too many whiles
#define ERNOWHI 13 // No active whiles
#define EREXWHI 14 // Need a while
#define ERLTLNG 15 // Line too long
#define ERTMCAS 16 // Too many cases

// Expression parser
#define ERSIZOF 30 // Illegal use of sizeof
#define EROFSTR 31 // String table is full
#define ERILADR 32 // Illegal address
#define ERCTSUB 33 // Can't index
#define ERINVEX 34 // Illegal expression
#define ERMBLVL 35 // Must be lvalue
#define ERESCSQ 36 // Bad escape sequence

// Preprocessor
#define ERASMWE 50 // #asm without #endasm
#define EREASWA 51 // #endasm without #asm
#define ERMACAD 52 // Macro already defined
#define ERTMIFS 53 // Too many active #ifs
#define ERELSEW 54 // #else without #if
#define ERENDIF 55 // #endif without #if
#define ERBADCM 56 // Illegal # command
#define EROFMAC 57 // Macro table if full
#define ERTMINC 58 // Too many active includes

// File I/O
#define EROPEN  70 // Can't open
#define ERWRITE 71 // Can't write
#define ERCLOSE 72 // Can't close

// Command line
#define ERCMDLN 80 // Illegal option
#define ERCMDER 81 // Illegal max. number of errors
#define ERCMDLB 82 // Illegal label
#define ERCMDST 83 // Illegal size of stack

// Initialization
#define ERNOMEM 90 // Not enough memory for buffers

