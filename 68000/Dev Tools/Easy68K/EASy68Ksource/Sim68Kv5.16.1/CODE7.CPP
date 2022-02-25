
/***************************** 68000 SIMULATOR ****************************

File Name: CODE7.C
Version: 1.0

The instructions implemented in this file are shift and rotate operations:

		SHIFT_ROT (ASL, ASR, LSL, LSR, ROL, ROR, ROXL, ROXR), SWAP,
		BIT_OP (BCHG, BCLR, BSET, BTST), TAS
                BIT_FIELD (BFCHG, BFCLR, BFEXTS, BFEXTU, BFFFO, BFINS, BFSET, BFTST)

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include "extern.h"         // contains global "extern" declarations


int	SHIFT_ROT()
{
  long	size;
  int	reg, count_reg, shift_count, shift_size, shift_result, type, counter, msb;
  int	direction, temp_bit, temp_bit_2, carry, xflag;

  if ((inst & 0xc0) == 0xc0) {
    int error = eff_addr((long)WORD_MASK, MEM_ALT_ADDR, true);
    if (error)              // if address error
      return error;         // return error code

    size = WORD_MASK;
    shift_count = 1;
    source = dest = EV1 & size;
    type = (inst & 0x600) >> 9;
    inc_cyc (8);
  } else {
    if (decode_size(&size))
      return (BAD_INST);                // bad instruction format
    if (inst & 0x20)
       shift_count = (unsigned(D[(inst >> 9) & 0x7]) & size) % 64;
    else {                              // #immediate shift count
      shift_count = (inst >> 9) & 0x7;
      if (shift_count == 0)             // #immediate shift count of 0 is equal to 8
	    shift_count = 8;
    }
    reg = inst & 7;
    source = dest = D[reg] & size;
    type = (inst & 0x18) >> 3;
    EA1 = &D[reg];
    value_of (EA1, &EV1, size);
    if (size == LONG_MASK)
      inc_cyc (8 + 2 * shift_count);
    else
      inc_cyc (6 + 2 * shift_count);
  }
  direction = inst & 0x100;
  if (size == LONG_MASK)
    shift_size = 31;
  else if (size == WORD_MASK)
    shift_size = 15;
  else
    shift_size = 7;

  if (shift_count == 0)	{               // if shift count is 0
    if (type == 2)                      // if ROXL or ROXR
      cc_update (N_A, GEN, GEN, ZER, CASE_1,
                 source, dest, EV1, size, shift_count);
    else                                // all others
      cc_update (N_A, GEN, GEN, ZER, ZER,
		 source, dest, EV1, size, shift_count);
  }
  else {                                // else shift count NOT zero
    switch (type) {
      case 0 :                          // Arithmetic shift
       if (direction) {		        // if ASL
        if (shift_count >= 32) // 68000 does modulo 64 shift, c++ does modulo 32
          shift_result = 0;
        else
          shift_result = (EV1 & size) << shift_count;
          put (EA1, shift_result, size);
	  value_of (EA1, &EV1, size);
	  cc_update (GEN, GEN, GEN, CASE_4, CASE_9,     // CK 5-2012
		     source, dest, EV1, size, shift_count);
	} else {                        // else ASR
	  // do the shift replicating the most significant bit
	  if ((EV1 >> shift_size) & 1)
	    temp_bit = 1;
	  else
	    temp_bit = 0;
	  for (counter = 1; counter <= shift_count; counter++) {
	    put (EA1, (EV1 & size) >> 1, size);
	    value_of (EA1, &EV1, size);
	    if (temp_bit)
	      put (EA1, EV1 | (1 << shift_size), size);
	    else
	      put (EA1, EV1 & (~(1 << shift_size)), size);
	    value_of (EA1, &EV1, size);
	  }
	  cc_update (GEN, GEN, GEN, ZER, CASE_7,
	             source, dest, EV1, size, shift_count);
        }
        break;
      case 1 :                          // Logical shift
        if (direction) {		// if LSL
          if (shift_count >= 32)        // 68000 does modulo 64 shift, c++ does modulo 32
            shift_result = 0;
          else
            shift_result = EV1 << shift_count;
          put (EA1, shift_result, size);
          value_of (EA1, &EV1, size);
	  cc_update (GEN, GEN, GEN, ZER, CASE_9,        // CK 5-2012
	             source, dest, EV1, size, shift_count);
	} else {		        // else LSR
          if (shift_count >= 32)        // 68000 does modulo 64 shift, c++ does modulo 32
            shift_result = 0;
          else
            shift_result = (unsigned)(EV1 & size) >> shift_count;
	  put (EA1, shift_result, size);
	  value_of (EA1, &EV1, size);
	  cc_update (GEN, GEN, GEN, ZER, CASE_8,        // ck 5-2012
	             source, dest, EV1, size, shift_count);
	}
        break;
      case 2 :                          // Rotate with extend
        // Modified 12-2012 by CK. Incorporated code from the UAE emulator.
        if(shift_size == 7) {
          if(shift_count >= 36) shift_count -= 36;
          if(shift_count >= 18) shift_count -= 18;
          if(shift_count >= 9) shift_count -= 9;
        } else if(shift_size == 15) {
          if(shift_count >= 34) shift_count -= 34;
          if(shift_count >= 17) shift_count -= 17;
        } else
          if(shift_count >= 33) shift_count -= 33;
        if (direction) {		// if ROXL
          xflag = (SR & xbit) >> 4;
	  for (counter = 1; counter <= shift_count; counter++) {
	    carry = (EV1 >> shift_size) & 1;
            EV1 <<= 1;
            if(xflag) EV1 |= 1;
            xflag = carry;
          }
          put (EA1, (EV1 & size), size);
	  value_of (EA1, &EV1, size);
	  if (xflag)
            SR = SR | xbit;
	  else
	    SR = SR & ~xbit;
	  cc_update (N_A, GEN, GEN, ZER, CASE_1,
	             source, dest, EV1, size, shift_count);
	} else {                        // else ROXR
          uint cmask = 1 << shift_size;
          xflag = (SR & xbit) >> 4;
	  for (counter = 1; counter <= shift_count; counter++) {
	    carry = EV1 & 1;
            (uint)EV1 >>= 1;
	    if(xflag) EV1 |= cmask;
            xflag = carry;
	  }
          put (EA1, (EV1 & size), size);
	  value_of (EA1, &EV1, size);
	  if (xflag)
            SR = SR | xbit;
	  else
	    SR = SR & ~xbit;
	  cc_update (N_A, GEN, GEN, ZER, CASE_1,
	             source, dest, EV1, size, shift_count);
        }
        break;
      case 3 : 	                        // Rotate
	if (direction) {	        // if ROL
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = (EV1 >> shift_size) & 1;
	    put (EA1, (EV1 & size) << 1, size);
	    value_of (EA1, &EV1, size);
	    if (temp_bit)
	      put (EA1, EV1 | 1, size);
	    else
	      put (EA1, EV1 & ~1, size);
	    value_of (EA1, &EV1, size);
	  }
	  cc_update (N_A, GEN, GEN, ZER, CASE_3,
	             source, dest, EV1, size, shift_count);
        } else {		                // else ROR
	  for (counter = 1; counter <= shift_count; counter++) {
	    temp_bit = EV1 & 1;
	    put (EA1, (EV1 & size) >> 1, size);
	    value_of (EA1, &EV1, size);
	    if (temp_bit)
	      put (EA1, EV1 | (1 << shift_size), size);
	    else
	      put (EA1, EV1 & (~(1 << shift_size)), size);
	    value_of (EA1, &EV1, size);
	  }
	  cc_update (N_A, GEN, GEN, ZER, CASE_2,
	             source, dest, EV1, size, shift_count);
        }
        break;
    }
  }
  return SUCCESS;
}


//-------------------------------------------------------------------------
int	SWAP()
{
long	reg;

reg = inst & 0x07;

/* perform the SWAP operation */
D[reg] = ((D[reg] & WORD_MASK) * 0x10000) | ((D[reg] & 0xffff0000) / 0x10000);

cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, D[reg], LONG_MASK, 0);

inc_cyc (4);

return SUCCESS;

}

//----------------------------------------------------------------------------
// BIT_OP (BCHG, BCLR, BSET, BTST)

int	BIT_OP()
{
  int	reg, mem_reg;
  unsigned long	size, bit_no;

  if (inst & 0x100)
    bit_no = D[(inst >> 9) & 0x07];
  else	{
    mem_request (&PC, (long)WORD_MASK, &(static_cast<long>(bit_no))); // get bit_no from instruction
    bit_no = bit_no & 0xff;
  }
  mem_reg = (inst & 0x38);

  if (mem_reg) {
    bit_no = bit_no % 8;
    size = BYTE_MASK;
  } else {
    bit_no = bit_no % 32;
    size = LONG_MASK;
  }

  int error = eff_addr(size, DATA_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  if ((EV1 >> bit_no) & 1)
    SR = SR & (~zbit);
  else
    SR = SR | zbit;

  switch ((inst >> 6) & 0x3) {
    case 0 : 			/* perform a bit test operation */
      if (mem_reg)
	inc_cyc (4);
      else
	inc_cyc (6);
      break;
    case 1 : 			/* perform a bit change operation */
      if ((EV1 >> bit_no) & 1)
	put (EA1, *EA1 & (~(1 << bit_no)), size);
      else
	put (EA1, *EA1 | (1 << bit_no), size);
      inc_cyc (8);
      break;
    case 2 : /* perform a bit clear operation */
      put (EA1, *EA1 & (~(1 << bit_no)), size);
      if (mem_reg)
	inc_cyc (8);
      else
	inc_cyc (10);
      break;
    case 3 : /* perform a bit set operation */
      put (EA1, *EA1 | (1 << bit_no), size);
      inc_cyc (8);
      break;
  }

  if (mem_reg)
    inc_cyc (4);

  return SUCCESS;
}


//--------------------------------------------------------------------------

int	TAS()
{
  int error = eff_addr((long)BYTE_MASK, DATA_ALT_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  /* perform the TAS operation */
  /* first set the condition codes according to *EA1 */
  cc_update (N_A, GEN, GEN, ZER, ZER, source, dest, *EA1, (long) BYTE_MASK, 0);

  /* then set the high order bit of the *EA1 byte */
  put (EA1, EV1 | 0x80, (long) BYTE_MASK);

  inc_cyc ((inst & 0x30) ? 10 : 4);

  return SUCCESS;
}

//--------------------------------------------------------------------------
// Simulates the bit field instructions. This code is patterned after the
// 68020 simulator code used in the UAE (Unix Amiga Emulator)
int	BIT_FIELD()
{
  long	extra, bf0, bf1, bf2, bf3, bf4;
  int width, destAddr, error = SUCCESS;
  int x_bit, n_bit, z_bit, v_bit, c_bit;
  uint offset, tmp;
  const int BFTST = 0, BFEXTU = 1, BFCHG = 2, BFEXTS = 3, BFCLR = 4, BFFF0 = 5;
  const int BFSET = 6, BFINS = 7;
  int cycles;

  if (!bitfield)                        // if bit field instructions not enabled
    return (BAD_INST);                  // bad instruction format

  mem_request(&PC, (long) WORD_MASK, &extra);
  if (extra & 0x800)
    offset = D[(extra >> 6) & 0x07];
  else
    offset = (extra >> 6) & 0x1f;

  if (extra & 0x20)
    width = ((D[(extra & 7)] -1) & 0x1f) + 1;
  else
    width = ((extra - 1) & 0x1f) + 1;

  if ((inst & 0x0038) == 0) {    // if Mode 000
    tmp = D[inst & 7] << (offset & 0x1f);
    cycles = 7;
  } else {
    error = eff_addr((long)BYTE_MASK, CONTROL_ADDR, true);
    if (error)              // if address error
      return error;         // return error code
    destAddr = (long) ( (long)EA1 - (long)&memory[0]);  // destination address
    destAddr += (offset >> 3) | (offset & 0x80000000 ? ~0x1fffffff : 0);  // add offset
    error = mem_req (destAddr, (long) BYTE_MASK, &bf0);  // get 5 bytes from memory
    if (error)
      return error;
    error = mem_req (destAddr+1, (long) BYTE_MASK, &bf1);
    if (error)
      return error;
    error = mem_req (destAddr+2, (long) BYTE_MASK, &bf2);
    if (error)
      return error;
    error = mem_req (destAddr+3, (long) BYTE_MASK, &bf3);
    if (error)
      return error;
    error = mem_req (destAddr+4, (long) BYTE_MASK, &bf4);
    if (error)
      return error;
    bf0 = bf0 << 24 | bf1 << 16 | bf2 << 8 | bf3;
    tmp = (bf0 << (offset & 7)) | (bf4 >> (8 - (offset & 7))); // 32 bits of potential data
    if (((offset & 7) + width) > 32)
      cycles = 16;
    else
      cycles = 12;
  }
  tmp >>= (32 - width);                         // width determines how many bits to use
  x_bit = SR & xbit;                            // set condition codes
  n_bit = (tmp & (1 << (width-1)) ? 1 : 0);
  z_bit = (tmp == 0);
  v_bit = 0;
  c_bit = 0;

  switch ((inst >> 8) & 0x7) {
    case BFTST:
      break;
    case BFEXTU:
      D[(extra >> 12) & 7] = tmp;
      if (cycles == 7)
        cycles = 8;
      else if (cycles == 12)
        cycles = 13;
      else
        cycles = 18;
      break;
    case BFCHG:
      tmp = ~tmp;
      if (cycles == 7)
        cycles = 12;
      else if (cycles == 12)
        cycles = 16;
      else
        cycles = 24;
      break;
    case BFEXTS:
      if (n_bit)
        tmp |= width == 32 ? 0 : (-1 << width);
      D[(extra >> 12) & 7] = tmp;
      if (cycles == 7)
        cycles = 8;
      else if (cycles == 12)
        cycles = 13;
      else
        cycles = 18;
      break;
    case BFCLR:
      tmp = 0;
      if (cycles == 7)
        cycles = 12;
      else if (cycles == 12)
        cycles = 16;
      else
        cycles = 24;
      break;
    case BFFF0:
      { uint mask = 1 << (width-1);
        while (mask) {
          if (tmp & mask)
            break;
          mask >>= 1;
          offset++;
        }
      }
      D[(extra >> 12) & 7] = offset;
      if (cycles == 7)
        cycles = 18;
      else if (cycles == 12)
        cycles = 24;
      else
        cycles = 32;
      break;
    case BFSET:
      tmp = 0xffffffff;
      if (cycles == 7)
        cycles = 12;
      else if (cycles == 12)
        cycles = 16;
      else
        cycles = 24;
      break;
    case BFINS:
      tmp = D[(extra >> 12) & 7];
      n_bit = (tmp & (1 << (width - 1)) ? 1 : 0);
      z_bit = (tmp == 0) ? 1 : 0;
      if (cycles == 7)
        cycles = 10;
      else if (cycles == 12)
        cycles = 15;
      else
        cycles = 21;
      break;
  }
  inc_cyc(cycles);
  
  // set SR according to results
  SR = SR & 0xffe0;		 		// clear the condition codes
  if (x_bit) SR = SR | xbit;
  if (n_bit) SR = SR | nbit;
  if (z_bit) SR = SR | zbit;
  if (v_bit) SR = SR | vbit;
  if (c_bit) SR = SR | cbit;

  switch ((inst >> 8) & 0x7) {
    case BFCHG: case BFCLR: case BFSET: case BFINS:
      tmp <<= (32 - width);
      if ((inst & 0x0038) == 0) {               // if ea is data register
        D[inst & 7] = (D[inst & 7] & ((offset & 0x1f) == 0 ? 0 :
          (0xffffffff << (32 - (offset & 0x1f))))) |
          (tmp >> (offset & 0x1f)) |
          (((offset & 0x1f) + width) >= 32 ? 0 :
          (D[inst & 7] & ((uint)0xffffffff >> ((offset & 0x1f) + width))));
      } else {
        bf0 = (bf0 & (0xff000000 << (8 - (offset & 7)))) |
          (tmp >> (offset & 7)) |
          (((offset & 7) + width) >= 32 ? 0 :
           (bf0 & ((uint)0xffffffff >> ((offset & 7) + width))));
        mem_put(bf0 >> 24, destAddr,   (long)BYTE_MASK);
        mem_put(bf0 >> 16, destAddr+1, (long)BYTE_MASK);
        mem_put(bf0 >> 8,  destAddr+2, (long)BYTE_MASK);
        mem_put(bf0,       destAddr+3, (long)BYTE_MASK);
        if (((offset & 7) + width) > 32) {
          bf4 = (bf4 & (0xff >> (width - 32 + (offset & 7)))) |
                (tmp << (8 - (offset & 7)));
          mem_put(bf1, destAddr+4, (long)BYTE_MASK);
        }
      }
  }
  return error;
}


