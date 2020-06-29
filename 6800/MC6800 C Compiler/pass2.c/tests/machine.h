/*
     machine.h - Machine specific definitions for the
                 Motorola MC68000 microprocessor

          This file defines machine-dependent constants
          useful to builtins and test programs
*/

/*
     MC68000 - This constant is defined so that applications
               wishing to have special code for this processor
               can do so by checking for this constant's
               definition
*/
/*
#define   MC68000        1
*/


/*
     Memory configuration definitions:
     
          _PAGESIZ       The number of bytes in a page of memory
          _PGOFSTM       Mask to extract offset into page from addr
          _PGNUMM        Mask to extract page number from addr
          _PGNUMS        Shift count for page number
*/

#define   _PAGESIZ       4096
#define   _PGOFSTM       (_PAGESIZ-1)
#define   _PGNUMM        (!(_PGOFSTM))
#define   _PGNUMS        11


/*
     Register configuration information

          When writing code, assume there are eight data registers
          and eight address registers, allocated 0-7.  Give the
          most frequently used data variable DATAREG0, and the most
          frequently used address variable ADDRREG0.

          REGISTER is an archaic form which is defined "register"
          on machines with more than one register, define ""
          otherwise.  This construct should be removed from
          code whenever convenient
*/

#define   DATAREG0
#define   DATAREG1
#define   DATAREG2
#define   DATAREG3
#define   DATAREG4
#define   DATAREG5
#define   DATAREG6
#define   DATAREG7

#define   ADDRREG0       register
#define   ADDRREG1
#define   ADDRREG2
#define   ADDRREG3
#define   ADDRREG4      
#define   ADDRREG5       
#define   ADDRREG6
#define   ADDRREG7

#define   REGISTER       register


/*
     Data representation information:

          MAXPINT        The maximum positive integer
          MAXNINT        The maximum negative integer

          MAXPLINT       The maximum positive long integer
          MAXNLINT       The maximum negative long integer

          MAXPSINT       The maximum positive short integer
          MAXNSINT       The maximum negative short integer

          MAXUINT        The maximum unsigned integer
          MAXULINT       The maximum unsigned long integer
          MAXUSINT       The maximum signed short integer
*/

#define   MAXPINT        0x7FFF
#define   MAXNINT        0x8000
#define   MAXPLINT       0x7FFFFFFFL
#define   MAXNLINT       0x80000000L
#define   MAXPSINT       0x7FFF
#define   MAXNSINT       0x8000
#define   MAXUINT        0xFFFF
#define   MAXULINT       0xFFFFFFFFL
#define   MAXUSINT       0xFFFF
