//---------------------------------------------------------------------------
//   Author: Chuck Kelly,
//           http://www.easy68k.com
//---------------------------------------------------------------------------
// File Name: def.h
// This file contains definitions.
// EASyBIN binary file creation and editing utility for EASy68K
//---------------------------------------------------------------------------

#ifndef defH
#define defH
#include <stdio.h>
#pragma hdrstop

#define uint unsigned int
#define ushort unsigned short
#define uchar unsigned char

// version info
const char TITLE[] = "EASyBIN v2.4.0";

// misc
const uint MEMSIZE      = 0x01000000;   // 16 Meg address space
//const int ADDRMASK      = 0x00ffffff;

//const int  BYTE_MASK    = 0xff;         // byte mask
//const int  WORD_MASK    = 0xffff;       // word mask
//const long LONG_MASK    = 0xffffffff;   // long mask

#endif

