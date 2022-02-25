
/***************************** 68000 SIMULATOR ****************************

File Name: CODE4.C

The instructions implemented in this file are the integer arithmetic
	operations:

		DIVS, DIVU, MULS, MULU, NEG, NEGX, CMP, CMPA, CMPI, CMPM,
		TST, CLR, EXT

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include "extern.h"         // contains global "extern" declarations

/*
 * Compute exact number of CPU cycles taken
 * by DIVU and DIVS on a 68000 processor.
 *
 * Copyright (c) 2005 by Jorge Cwik, pasti@fxatari.com
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *

 The routines below take dividend and divisor as parameters.
 They return 0 if division by zero, or exact number of cycles otherwise.

 The number of cycles returned assumes a register operand.
 Effective address time must be added if memory operand.

 For 68000 only (not 68010, 68012, 68020, etc).
 Probably valid for 68008 after adding the extra prefetch cycle.

 Best and worst cases for register operand:
 (Note the difference with the documented range.)

 DIVU:
 Overflow (always): 10 cycles.
 Worst case: 136 cycles.
 Best case: 76 cycles.

 DIVS:
 Absolute overflow: 16-18 cycles.
 Signed overflow is not detected prematurely.

 Worst case: 156 cycles.
 Best case without signed overflow: 122 cycles.
 Best case with signed overflow: 120 cycles

*/

// Change this depending on architecture
// This code assumes long is 32 bits and short is 16 bits

typedef unsigned long DWORD;
typedef unsigned short WORD;
typedef signed long LONG;
typedef signed short SHORT;

//
// DIVU
// Unsigned division
//

unsigned getDivu68kCycles( DWORD dividend, WORD divisor)
{
	unsigned mcycles;
	DWORD hdivisor;
	int i;

	if( (WORD) divisor == 0)
		return 0;

	// Overflow
	if( (dividend >> 16) >= (DWORD)divisor)
		return (mcycles = 5) * 2;

	mcycles = 38;
	hdivisor = ((DWORD) divisor) << 16;

	for( i = 0; i < 15; i++)
	{
		DWORD temp;
		temp = dividend;

		dividend <<= 1;

		// If carry from shift
		if( (LONG) temp < 0)
		{
			dividend -= hdivisor;
		}

		else
		{
			mcycles += 2;
			if( dividend >= hdivisor)
			{
				dividend -= hdivisor;
				mcycles--;
			}
		}
	}

	return mcycles * 2;
}

//
// DIVS
// Signed division
//

unsigned getDivs68kCycles( LONG dividend, SHORT divisor)
{
	unsigned mcycles;
	unsigned aquot;
	int i;

	if( (SHORT) divisor == 0)
		return 0;

	mcycles = 6;

	if( dividend < 0)
		mcycles++;

	// Check for absolute overflow
	if( ((DWORD) abs( dividend) >> 16) >= (DWORD) abs( divisor))
	{
		return (mcycles + 2) * 2;
	}

	// Absolute quotient
	aquot = (DWORD) abs( dividend) / (WORD) abs( divisor);

	mcycles += 55;

	if( divisor >= 0)
	{
		if( dividend >= 0)
			mcycles--;
		else
			mcycles++;
	}

	// Count 15 msbits in absolute of quotient

	for( i = 0; i < 15; i++)
	{
		if( (SHORT) aquot >= 0)
			mcycles++;
		aquot <<= 1;
	}


	return mcycles * 2;
}


// -----------------------------------------------
int	DIVS()
{
  int	reg;            //, overflow;
  long	remainder;
  __int64 result64;

  int error = eff_addr((long)WORD_MASK, DATA_ADDR, true);
  if (error)            // if address error
    return error;       // return error code

  reg = (inst >> 9) & 0x0007;

  from_2s_comp (EV1 & WORD_MASK, (long) WORD_MASK, &source);
  from_2s_comp (D[reg], LONG_MASK, &dest);

  if (source == 0)
    return (DIV_BY_ZERO);		// initiate exception processing

  result64 = ((__int64)dest / source);
  if (result64 > 32767 || result64 < -32768)  // if overflow
    SR |= vbit;
  else {
    SR &= ~vbit;
    result = result64 & 0xffff;
    remainder = (dest % source) & 0xffff;
    D[reg] = result | (remainder * 0x10000);
    cc_update (N_A, GEN, GEN, N_A, ZER, source, dest, result, (long) WORD_MASK, 0);
  }
  inc_cyc (getDivs68kCycles( (LONG) dest, (SHORT) source));
  return SUCCESS;
}


//------------------------------------------------
// DIVU <ea>,Dn
// Destination / Source --> Destination
// Size = Word
// Divide the destination operand by the source operand and store the result
// in the destination. The destination operand is a long operand (32 bits) and
// the source operand is a word (16 bit) operand. The operation is performed
// using unsigned arithmetic. The result is a 32-bit result such that:
//   1. The quotient is in the lower word (least significant 16 bits)
//   2. The remainder is in the upper word (most significant 16 bits)
// Two special condition may arise:
//   1. Division by zero causes a trap
//   2. Overflow may be detected and set before completion of the instruction.
//      If overflow is detected, the condition is flagged but the operands
//      are unaffected.
int	DIVU()
{
  int reg;

  int error = eff_addr((long)WORD_MASK, DATA_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  reg = (inst >> 9) & 0x0007;

  source = EV1 & WORD_MASK;
  dest = D[reg];

  if (source == 0)
    return (DIV_BY_ZERO);		// initiate exception processing

  if ( ((unsigned)dest / source) > WORD_MASK)
    SR |= vbit; 		        // check for overflow
  else {
    SR &= ~vbit;
    D[reg] = result =(((unsigned)dest / source) & 0xffff) |
                      (((unsigned)dest % source) * 0x10000);
    cc_update (N_A, GEN, GEN, N_A, ZER, source, dest, result, (long) WORD_MASK, 0);
  }

  inc_cyc (getDivu68kCycles((DWORD)dest, (WORD)source));
  return SUCCESS;
}


//------------------------------------------------
int	MULS()
{
  int	reg;

  int error = eff_addr((long)WORD_MASK, DATA_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  reg = (inst >> 9) & 0x0007;

  from_2s_comp (EV1 & WORD_MASK, (long) WORD_MASK, &source);
  from_2s_comp (D[reg] & WORD_MASK, (long) WORD_MASK, &dest);

  D[reg] = result = source * dest;

  cc_update (N_A, GEN, GEN, CASE_9, ZER, source, dest, result, (long) LONG_MASK, 0);  // ck 8-10-2005

  // timing 38 + 2n clocks where n is
  // concatanate the <ea> with a zero as the LSB;
  // n is the number of transitions from 0 to 1 or 1 to 0 in the 17-bit source
  int s17 = source & 0x0FFFF;
  int n = 0, m = 0;
  for (int i=0; i<16; i++) {
    if ((s17 & 1) != m) {
      n++;
      m = s17 & 1;
    }
    s17 = s17 >> 1;
  }
  inc_cyc (38 + (2*n));

  return SUCCESS;

}


//------------------------------------------------
int	MULU()
{
  int	reg;

  int error = eff_addr((long)WORD_MASK, DATA_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  reg = (inst >> 9) & 0x0007;

  source = EV1 & WORD_MASK;
  dest = D[reg] & WORD_MASK;

  D[reg] = result = source * dest;

  cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, result, LONG_MASK, 0);

  // timing 38 + 2n clocks where n is
  // the number of ones in the source
  int s17 = source & 0x0FFFF;
  int n = 0;
  for (int i=0; i<16; i++) {
    if ((s17 & 1))
      n++;
    s17 = s17 >> 1;
  }
  inc_cyc (38 + (2*n));

  return SUCCESS;

}


//------------------------------------------------
int	NEG()
{
long	size;

if (decode_size(&size))
  return (BAD_INST);	 // bad instruction format

int error = eff_addr(size, DATA_ALT_ADDR, true);
if (error)              // if address error
  return error;         // return error code

source = dest = EV1 & size;

/* perform the NEG operation */
put (EA1, -dest, size);
value_of (EA1, &result, size);

cc_update (GEN, GEN, GEN, CASE_3, CASE_4, source, dest, result, size, 0);

if (inst & 0x0030)
	inc_cyc ( (size == LONG_MASK) ? 12 : 8);
else 
	inc_cyc ( (size == LONG_MASK) ? 6 : 4);

return SUCCESS;

}


//------------------------------------------------
int	NEGX()
{
long	size;

if (decode_size(&size))
  return (BAD_INST);  	// bad instruction format

int error = eff_addr(size, DATA_ALT_ADDR, true);
if (error)              // if address error
  return error;         // return error code

dest = dest = EV1 & size;

/* perform the NEGX operation */
put (EA1, -dest - ((SR & xbit) >> 4), size);
value_of (EA1, &result, size);

cc_update (GEN, GEN, CASE_1, CASE_3, CASE_4, source, dest, result, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG_MASK) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG_MASK) ? 6 : 4);
	}

return SUCCESS;

}


//------------------------------------------------
int	CMP()
{
long	size;
int	reg;

if (decode_size(&size))
  return (BAD_INST);	// bad instruction format

int error = eff_addr(size, ALL_ADDR, true);
if (error)              // if address error
  return error;         // return error code

reg = (inst >> 9) & 0x0007;

source = EV1 & size;
dest = D[reg] & size;

put (&result, dest - source, size);

/* now set the condition codes */
cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

inc_cyc ( (size == LONG_MASK) ? 6 : 4);

return SUCCESS;

}

//------------------------------------------------
int	CMPA()
{
long	size;
int	reg;

if (inst & 0x0100)
	size = LONG_MASK;
else
	size = WORD_MASK;

int error = eff_addr(size, ALL_ADDR, true);
if (error)              // if address error
  return error;         // return error code

reg = a_reg((inst >> 9) & 0x0007);

if (size == WORD_MASK)
	sign_extend ((int)EV1, WORD_MASK, &EV1);

//source = EV1 & size;                  // bug report by max Aug 22, 2005
//dest = A[reg] & size;
//put (&result, dest - source, size);
source = EV1;
dest = A[reg];
put (&result, dest - source, LONG_MASK);

/* now set the condition codes according to the result */
// cc_update (N_A, GEN, GEN, GEN, GEN, source, dest, result, size, 0);
//cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);  // bug report by max Aug 22, 2005
cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, LONG_MASK, 0);

inc_cyc (6);

return SUCCESS;

}

//------------------------------------------------
int	CMPI()
{
long	size;

if (decode_size(&size))
  return (BAD_INST);	   // bad instruction format

mem_request (&PC, size, &source);

int error = eff_addr(size, DATA_ALT_ADDR, true);
if (error)              // if address error
  return error;         // return error code

dest = EV1 & size;

put (&result, dest - source, size);

cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

if (inst & 0x0038) {
	inc_cyc ( (size == LONG_MASK) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG_MASK) ? 14 : 8);
	}

return SUCCESS;

}


//------------------------------------------------
int	CMPM()          // (Ay)+,(Ax)+
{
    long size;
    int	Rx, Ry, increment=1;    // default to 1 byte

    if (decode_size(&size))
        return (BAD_INST);

    Ry = a_reg(inst & 0x07);            // source
    Rx = a_reg((inst >> 9) & 0x07);     // destination
    if (size == WORD_MASK)
        increment = 2;          // 2 bytes
    if (size == LONG_MASK)
	increment = 4;          // 4 bytes

    mem_req ( (int) A[Ry], size, &source);      // get source
    A[Ry] += increment;
    if(mem_req ( (int) A[Rx], size, &dest) != BUS_ERROR)  // get destination
    {
      A[Rx] += increment;
      put (&result, dest - source, size);
    }

    // now set the condition codes according to the result
    cc_update (N_A, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);
    inc_cyc ( (size == LONG_MASK) ? 20 : 12);
    return SUCCESS;
}


//------------------------------------------------
int	TST()
{
long	size;

if (decode_size(&size))
  return (BAD_INST);    // bad instruction format

int error = eff_addr(size, DATA_ALT_ADDR, true);
if (error)              // if address error
  return error;         // return error code

value_of (EA1, &dest, size);

/* test the dest operand and set the condition codes accordingly */
cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, dest, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG_MASK) ? 4 : 4);
	}
else {
	inc_cyc ( (size == LONG_MASK) ? 4 : 4);
	}

return SUCCESS;

}


//------------------------------------------------
int	CLR()
{
long	size;

if (decode_size(&size))
  return (BAD_INST);	// bad instruction format

int error = eff_addr(size, DATA_ALT_ADDR, true);
if (error)              // if address error
  return error;         // return error code

source = dest = EV1 & size;

/* perform the CLR operation */
put (EA1, (long) 0, size);
value_of (EA1, &result, size);

cc_update (N_A, ZER, GEN, ZER, ZER, source, dest, result, size, 0);

if (inst & 0x0030) {
	inc_cyc ( (size == LONG_MASK) ? 12 : 8);
	}
else {
	inc_cyc ( (size == LONG_MASK) ? 6 : 4);
	}

return SUCCESS;

}



//------------------------------------------------
int	EXT()
{
long	size;
int	reg;

reg = inst & 0x07;

if (inst & 0x0040)
	size = LONG_MASK;
else
	size = WORD_MASK;

source = dest = D[reg] & size;

if (size == WORD_MASK)
 D[reg] = (D[reg]&~WORD_MASK) | (D[reg] & BYTE_MASK) | (0xff00 * ((D[reg]>>7) & 0x01));
else
 D[reg] = (D[reg] & WORD_MASK) | (0xffff0000 * ((D[reg] >> 15) & 0x01));

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, D[reg], size, 0);

inc_cyc (4);

return SUCCESS;

}

