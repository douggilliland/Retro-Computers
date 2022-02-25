
/***************************** 68000 SIMULATOR ****************************

File Name: CODE3.C
Version: 1.0

The instructions implemented in this file are the integer arithmetic
	operations:

		ADD, ADDA, ADDI, ADDQ, ADDX, SUB, SUBA, SUBI, SUBQ, SUBX

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */




int	ADD()
{
  int	addr_modes_mask; 	/* holds mask for use in 'eff_addr()' */
  int	reg;		 	/* holds data register number */
  long	size;		 	/* holds instruction size */
  int     error;

  /* compute addressing modes mask from appropriate bit in instruction WORD_MASK */
  addr_modes_mask = (inst & 0x0100) ? MEM_ALT_ADDR : ALL_ADDR;

  /* the following statement decodes the instruction size using */
  /* decode_size(), then decodes the effective address using eff_addr() */
  if (decode_size(&size)) 	// if size is bad then return 'bad instruction'
    return (BAD_INST);

  error = eff_addr(size, addr_modes_mask, true);
  if (error)              // if address error
    return error;         // return error code

  reg = (inst >> 9) & 0x0007;		/* get data register number */

  /* now perform the addition according to instruction format */
  /* instruction bit 8 'on' means data register to effective-address */
  /* instruction bit 8 'off' means effective-address to data register */
  if (inst & 0x0100) {
          source = D[reg];
          dest = EV1;
          put (EA1, source + dest, size);	/* use 'put' to deposit result */
          value_of (EA1, &result, size);	/* set 'result' for use in 'cc_update' */
          }
  else {
          source = EV1;		/* get source. 'EV1' was set in 'eff_addr()' */
          dest = D[reg];		/* get destination */
          put (&D[reg], source + dest, size);
          result = D[reg];	/* set 'result' for use in 'cc_update()' */
          }

  /* update the condition codes */
  cc_update (GEN, GEN, GEN, CASE_1, CASE_5, source, dest, result, size, 0);

  /* now update the cycle counter appropriately depending on the instruction */
  /* size and the instruction format */
  if (inst & 0x0100) {          // if (<ea>)+(<Dn>) --> <ea>
    inc_cyc ( (size == LONG_MASK) ? 12 : 8);
  } else {
    if (size == LONG_MASK) {
      if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
        inc_cyc (8);
      else
        inc_cyc (6);
    } else {
      inc_cyc (4);
    }
  }

  /* return 'success' */
  return SUCCESS;

}


int	ADDA()
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


  reg = (inst >> 9) & 0x0007;

  if (size == WORD_MASK)                          // ck 1/22/2003
          sign_extend ((int)EV1, WORD_MASK, &EV1);

  source = EV1;
  dest = A[a_reg(reg)];

  //put (&A[a_reg(reg)], source + dest, size);    CK 11/6/2002
  put (&A[a_reg(reg)], source + dest, LONG_MASK); // always uses 32bits of Areg


  if (size == LONG_MASK) {
          if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
                  inc_cyc (8);
          else
                  inc_cyc (6);
          }
  else
          inc_cyc (8);

  return SUCCESS;

}


//--------------------------------------------------------------------------
int	ADDI()
{
  long	size;

  if (decode_size(&size))
    return (BAD_INST);			// bad instruction format

  mem_request (&PC, size, &source);

  int error = eff_addr(size, DATA_ALT_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  dest = EV1;
  put (EA1, source + dest, size);
  value_of (EA1, &result, size);
  cc_update (GEN, GEN, GEN, CASE_1, CASE_5, source, dest, result, size, 0);

  if (inst & 0x0038) {
    inc_cyc ( (size == LONG_MASK) ? 20 : 12);
  } else {
    inc_cyc ( (size == LONG_MASK) ? 16 : 8);
  }
  return SUCCESS;
}



//----------------------------------------------------------------------------
int	ADDQ()
{
  long	size;

  if (decode_size(&size))
          return (BAD_INST);			/* bad size format */

  if ((inst & 0x38) == 0x8)		/* if address reg direct, operation is long */
          size = LONG_MASK;

  int error = eff_addr(size, ALTERABLE_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  source = ((inst >> 9) & 0x07);
  if (source == 0) 			/* if source is '0', that corresponds to '8' */
          source = 8;

  dest = EV1;

  put (EA1, source + dest, size);
  value_of (EA1, &result, size);

  if (!((inst & 0x38) == 0x8))   /* if address reg direct, cc's not affected */
  cc_update (GEN, GEN, GEN, CASE_1, CASE_5, source, dest, result, size, 0);

  switch (inst & 0x0038) {
          case 0x0  : inc_cyc ( (size == LONG_MASK) ? 8 : 4);
                      break;
          case 0x8  : inc_cyc (8);        // CK 12-17-2005
                      break;
          default   : inc_cyc ( (size == LONG_MASK) ? 12 : 8);
                      break;
          }

  return SUCCESS;

}



//----------------------------------------------------------------------------
int	ADDX()
{
    long size;
    int  Rx, Ry, decrement=1;

    if (decode_size(&size)) return (BAD_INST);

    Ry = inst & 0x0007;         // source
    Rx = (inst >> 9) & 0x0007;  // destination

    // perform the ADDX operation
    if (inst & 0x0008) {        // -(Ay), -(Ax) addressing mode
        Rx = a_reg(Rx);
        Ry = a_reg(Ry);
        if (size == WORD_MASK)
            decrement = 2;
        if (size == LONG_MASK)
            decrement = 4;
        A[Ry] -= decrement;
        mem_req ((int) A[Ry], size, &source);
        A[Rx] -= decrement;
        if(mem_req ((int) A[Rx], size, &dest) == BUS_ERROR)
          A[Rx] += decrement; // Bus Error on destination does not decrement An
        else {
          put ((long *)&memory[A[Rx]], source + dest + ((SR & xbit) >> 4), size);
          mem_req ((int) A[Rx], size, &result);
        }
    }
    else        // Dy,Dx addressing mode
    {
        source = D[Ry] & size;
        dest = D[Rx] & size;
        put (&D[Rx], source + dest + ((SR & xbit) >> 4), size);
        result = D[Rx] & size;
    }

    cc_update (GEN, GEN, CASE_1, CASE_1, CASE_5, source, dest, result, size, 0);

    if (size == LONG_MASK)
        inc_cyc ( (inst & 0x0008) ? 30 : 8);
    else
        inc_cyc ( (inst & 0x0008) ? 18 : 4);

  return SUCCESS;
}


//----------------------------------------------------------------------------
int	SUB()
{
  int	addr_modes_mask, reg;
  long	size;

  addr_modes_mask = (inst & 0x0100) ? MEM_ALT_ADDR : ALL_ADDR;

  if (decode_size(&size))
    return (BAD_INST);	// bad instruction format

  int error = eff_addr(size, addr_modes_mask, true);
  if (error)              // if address error
    return error;         // return error code

  reg = (inst >> 9) & 0x0007;

  if (inst & 0x0100)
          {
          source = D[reg] & size;
          dest = EV1 & size;
          put (EA1, dest - source, size);
          value_of (EA1, &result, size);
          }
  else
          {
          source = EV1 & size;
          dest = D[reg] & size;
          put (&D[reg], dest - source, size);
          result = D[reg] & size;
          }

  cc_update (GEN, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

  if (inst & 0x0100) {
          inc_cyc ( (size == LONG_MASK) ? 12 : 8);
          }
  else {
          if (size == LONG_MASK) {
                  if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
                          inc_cyc (8);
                  else
                          inc_cyc (6);
                  }
          else {
                  inc_cyc (4);
                  }
          }

  return SUCCESS;

}


//----------------------------------------------------------------------------
int	SUBA()
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

  reg = (inst >> 9) & 0x0007;

  if (size == WORD_MASK)                          // ck 1/22/2003
          sign_extend ((int)EV1, WORD_MASK, &EV1);

  source = EV1;
  dest = A[a_reg(reg)];

  //put (&A[a_reg(reg)], dest - source, size);    // CK 11/6/2002
  put (&A[a_reg(reg)], dest - source, LONG_MASK); // always uses 32bits of Areg

  if (size == LONG_MASK) {
          if ( (!(inst & 0x0030)) || ((inst & 0x003f) == 0x003c) )
                  inc_cyc (8);
          else
                  inc_cyc (6);
          }
  else
          inc_cyc (8);

  return SUCCESS;

}


//----------------------------------------------------------------------------
int	SUBI()
{
  long	size;

  if (decode_size(&size))
    return (BAD_INST);		     // bad instruction format

  mem_request (&PC, size, &source);

  int error = eff_addr(size, DATA_ALT_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  dest = EV1;

  put (EA1, dest - source, size);
  value_of (EA1, &result, size);

  cc_update (GEN, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

  if (inst & 0x0038) {
          inc_cyc ( (size == LONG_MASK) ? 20 : 12);
          }
  else {
          inc_cyc ( (size == LONG_MASK) ? 16 : 8);
          }

  return SUCCESS;

}



//----------------------------------------------------------------------------
int	SUBQ()
{
  long	size;

  if (decode_size(&size))
    return (BAD_INST);			/* bad size format */

  if ((inst & 0x38) == 0x8)		/* if address reg direct, operation is long */
          size = LONG_MASK;

  int error = eff_addr(size, ALTERABLE_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  source = ((inst >> 9) & 0x07);
  if (source == 0) 			/* if source is '0', that corresponds to '8' */
          source = 8;

  dest = EV1;

  put (EA1, dest - source, size);
  value_of (EA1, &result, size);

  if (!((inst & 0x38) == 0x8))   /* if address reg direct, cc's not affected */
  cc_update (GEN, GEN, GEN, CASE_2, CASE_6, source, dest, result, size, 0);

  switch (inst & 0x0038) {
          case 0x0  : inc_cyc ( (size == LONG_MASK) ? 8 : 4);
                      break;
          case 0x8  : inc_cyc (8);        // CK 12-17-2005
                      break;
          default   : inc_cyc ( (size == LONG_MASK) ? 12 : 8);
                      break;
          }

  return SUCCESS;

}




//----------------------------------------------------------------------------
int	SUBX()
{
    long size;
    int	Rx, Ry, decrement=1;

    if (decode_size(&size))
        return (BAD_INST);

    Ry = inst & 0x0007;           // source
    Rx = (inst >> 9) & 0x0007;    // destination

    // perform the SUBX operation
    if (inst & 0x0008) {        // -(Ay),-(Ax) addressing mode
        Rx = a_reg(Rx);
        Ry = a_reg(Ry);
        if (size == WORD_MASK)
            decrement = 2;
        if (size == LONG_MASK)
            decrement = 4;
        A[Ry] -= decrement;
        mem_req ((int) A[Ry], size, &source);
        A[Rx] -= decrement;
        if(mem_req ((int) A[Rx], size, &dest) == BUS_ERROR)
          A[Rx] += decrement;   // Bus Error on destination does not decrement An
        else {
          put ((long *)&memory[A[Rx]], dest - source - ((SR & xbit)>> 4), size);
          mem_req ((int) A[Rx], size, &result);
        }
    }
    else        // Dy,Dx addressing mode
    {
        source = D[Ry] & size;
        dest = D[Rx] & size;
        put (&D[Rx], dest - source - ((SR & xbit) >> 4), size);
        result = D[Rx] & size;
    }

  cc_update (GEN, GEN, CASE_1, CASE_2, CASE_6, source, dest, result, size, 0);

  if (size == LONG_MASK)
     inc_cyc ( (inst & 0x0008) ? 30 : 8);
  else
     inc_cyc ( (inst & 0x0008) ? 18 : 4);

  return SUCCESS;

}

