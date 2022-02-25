//---------------------------------------------------------------------------
//   Author: Charles Kelly
//           www.easy68k.com
//---------------------------------------------------------------------------
#ifndef defH
#define defH

#include <stdio.h>
#pragma hdrstop

/***************************** 68000 SIMULATOR ****************************
File Name: DEF.H
This file contains definitions used in the simulator source files.
***************************************************************************/
#define uint unsigned int
#define ushort unsigned short
#define uchar unsigned char
//typedef unsigned int uint;
//typedef unsigned short ushort;
//typedef unsigned char uchar;

// version info
const char TITLE[] = "EASy68K Simulator v5.16.1"; // ***** change both *****
const unsigned int VERSION =        0x00051001;    // ***** change both *****

// memory map types (bit flags which may be combined with OR logic)
enum maptype {Invalid=0x01, Protected=0x02, Read=0x04, Rom=0x10};

// status register bitmasks

const int bit_1	    = 0x0001;
const int bit_2		= 0x0002;
const int bit_3		= 0x0004;
const int bit_4		= 0x0008;
const int bit_5		= 0x0010;
const int bit_6		= 0x0020;
const int bit_7		= 0x0040;
const int bit_8		= 0x0080;
const int bit_9		= 0x0100;
const int bit_10	= 0x0200;
const int bit_11	= 0x0400;
const int bit_12	= 0x0800;


const int cbit		= 0x0001;
const int vbit		= 0x0002;
const int zbit		= 0x0004;
const int nbit		= 0x0008;
const int xbit		= 0x0010;
const int intmsk	= 0x0700;       // three bits
const int sbit		= 0x2000;
const int tbit		= 0x8000;


// misc
const uint MEMSIZE      = 0x01000000;   // 16 Meg address space
const int ADDRMASK      = 0x00ffffff;

const int  BYTE_MASK    = 0xff;         // byte mask
const int  WORD_MASK    = 0xffff;       // word mask
const long LONG_MASK    = 0xffffffff;   // long mask


const int D_REGS	= 8;            // number of D registers
const int A_REGS	= 9;            // number of A registers


// Possible addressing modes permitted by an instruction
// Each bit represents a different addressing mode.
// For example CONTROL_ADDR = 0x07e4 which means the following addressing
// modes are permitted.
// Imm d[PC,Xi] d[PC] Abs.L Abs.W d[An,Xi] d[An] -[An] [An]+ [An] An Dn
//  0      1      1     1     1      1       1     0     0     1   0  0
const int DATA_ADDR             = 0x0ffd;
const int MEMORY_ADDR		= 0x0ffc;
const int CONTROL_ADDR		= 0x07e4;
const int ALTERABLE_ADDR	= 0x01ff;
const int ALL_ADDR		= 0x0fff;
const int DATA_ALT_ADDR		= (DATA_ADDR & ALTERABLE_ADDR);
const int MEM_ALT_ADDR		= (MEMORY_ADDR & ALTERABLE_ADDR);
const int CONT_ALT_ADDR		= (CONTROL_ADDR & ALTERABLE_ADDR);


/* these are the instruction return codes */

const int SUCCESS		= 0x0000;
const int BAD_INST		= 0x0001;
const int NO_PRIVILEGE		= 0x0002;
const int CHK_EXCEPTION	        = 0x0003;
//const int ILLEGAL_TRAP		= 0x0004;
const int STOP_TRAP		= 0x0005;
const int TRAPV_TRAP		= 0x0006;
const int TRAP_TRAP		= 0x0007;
const int DIV_BY_ZERO		= 0x0008;
const int USER_BREAK		= 0x0009;
const int BUS_ERROR             = 0x000A;
const int ADDR_ERROR            = 0x000B;
const int LINE_1010             = 0x000C;
const int LINE_1111             = 0x000D;
const int TRACE_EXCEPTION       = 0x000E;
const int ROM_MAP               = 0x000F;
const int FAILURE		= 0x1111;	// general failure


// these are the cases for condition code setting

const int N_A		        = 0;
const int GEN		        = 1;
const int ZER		        = 2;
const int UND		        = 3;
const int CASE_1		= 4;
const int CASE_2		= 5;
const int CASE_3		= 6;
const int CASE_4		= 7;
const int CASE_5		= 8;
const int CASE_6		= 9;
const int CASE_7		= 10;
const int CASE_8		= 11;
const int CASE_9		= 12;


// these are used in run.c

const int MODE_MASK  		= 0x0038;
const int REG_MASK   		= 0x0007;
const int FIRST_FOUR 		= 0xf000;

const int READ		 	= 0xffff;
const int WRITE		 	= 0x0000;


// conditions for BCC, DBCC, and SCC

const int COND_T  = 0x00;
const int COND_F  = 0x01;
const int COND_HI = 0x02;
const int COND_LS = 0x03;
const int COND_CC = 0x04;
const int COND_CS = 0x05;
const int COND_NE = 0x06;
const int COND_EQ = 0x07;
const int COND_VC = 0x08;
const int COND_VS = 0x09;
const int COND_PL = 0x0a;
const int COND_MI = 0x0b;
const int COND_GE = 0x0c;
const int COND_LT = 0x0d;
const int COND_GT = 0x0e;
const int COND_LE = 0x0f;


// file handling error codes
const short F_SUCCESS = 0;
const short F_EOF = 1;
const short F_ERROR = 2;
const short F_READONLY = 3;

const int MAXFILES = 8;         // maximun files that may be open at one time

struct FileStruct {
  FILE *fp;                     // file pointer
  char name[256];               // file name
};

// simulator log types
const int DISABLED = 0;
const int INSTRUCTION = 1;
const int REGISTERS = 2;
const int INST_REG_MEM = 3;
const int TEXTONLY = 1;
// LogfileDialog returns
//const int CANCEL =  mrCancel;           // must be non-zero for modal form returns
//const int APPEND = mrAll;
//const int REPLACE = mrOk;

//////////////////////////////////
// DEBUG / Breakpoint definitions
//////////////////////////////////

const int MAX_BPOINTS = 100;
const int MAX_BP_EXPR = 50;
const int MAX_LB_NODES = 10;

// Define logical operator types
const int AND_OP = 0;
const int OR_OP = 1;

const int LPAREN = MAX_BPOINTS + OR_OP + 1;
const int RPAREN = LPAREN + 1;

// BPoint IDs are shared between PC/Reg and ADDR breakpoints.
// This constant is used to jump to the ADDR range.
// (It's ok to have unused breakPoints array elements .. see extern.h)
const int ADDR_ID_OFFSET = 50;

const int MAX_REG_ROWS = 50;
const int MAX_ADDR_ROWS = 50;
const int MAX_EXPR_ROWS = 50;

// Stored in fields of BPoint objects
const int PC_REG_TYPE = 0;
const int ADDR_TYPE = 1;

const int D0_TYPE_ID = 0;
const int D1_TYPE_ID = 1;
const int D2_TYPE_ID = 2;
const int D3_TYPE_ID = 3;
const int D4_TYPE_ID = 4;
const int D5_TYPE_ID = 5;
const int D6_TYPE_ID = 6;
const int D7_TYPE_ID = 7;
const int A0_TYPE_ID = 8;
const int A1_TYPE_ID = 9;
const int A2_TYPE_ID = 10;
const int A3_TYPE_ID = 11;
const int A4_TYPE_ID = 12;
const int A5_TYPE_ID = 13;
const int A6_TYPE_ID = 14;
const int A7_TYPE_ID = 15;
const int PC_TYPE_ID = 16;
const int DEFAULT_TYPE_ID = PC_TYPE_ID;

const int EQUAL_OP = 0;         // ==
const int NOT_EQUAL_OP = 1;     // !=
const int GT_OP = 2;            // >
const int GT_EQUAL_OP = 3;      // >=
const int LT_OP = 4;            // <
const int LT_EQUAL_OP = 5;      // <=
const int NA_OP = 6;            // NA
const int DEFAULT_OP = EQUAL_OP;

const int BYTE_SIZE = 0;
const int WORD_SIZE = 1;
const int LONG_SIZE = 2;
const int DEFAULT_SIZE = LONG_SIZE;

const int RW_TYPE = 0;
const int READ_TYPE = 1;
const int WRITE_TYPE = 2;
const int NA_TYPE = 3;
const int DEFAULT_TYPE = RW_TYPE;

const int EXPR_ON = 0;
const int EXPR_OFF = 1;

const int SREC_MAX = 515;       // maximum buffer size for S-Record

const int MAX_COMM = 16;        // maximum number of comm ports supported
const int MAX_SERIAL_IN = 256;  // maximum size of serial input buffer

//Default window locations and sizes.
const int FORM1_TOP = 100;          // Form1 Top
const int FORM1_LEFT = 100;         // Form1 Left
const int SIMIO_FORM_TOP = 300;     // SimIO Form Top
const int SIMIO_FORM_LEFT = 200;    // SimIO Form Left
const int MEMORY_FORM_TOP = 80;     // Memory Form Top
const int MEMORY_FORM_LEFT = 280;   // Memory Form Left
const int STACK_FORM_TOP = 200;     // Stack Form Top
const int STACK_FORM_LEFT = 40;     // Stack Form Left
const int STACK_FORM_HEIGHT = 538;  // Stack Form Height
const int HARDWARE_FORM_TOP = 100;  // Hardware Form Top
const int HARDWARE_FORM_LEFT = 240; // Hardware Form Left

#endif
