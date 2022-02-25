
/***************************** 68000 SIMULATOR ****************************

File Name: CODE5.C
Version: 1.0

The instructions implemented in this file are the binary coded decimal
   operations:

		ABCD, SBCD, NBCD

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */



//-------------------------------------------------------
// perform the ABCD operation
int ABCD()
{
    int	Rx, Ry, carry, temp_result;

    Rx = (inst >> 9) & 0x0007;    // destination
    Ry = inst & 0x0007;           // source

    if (inst & 0x0008) // -(Ay),-(Ax) addressing mode
    {
        Rx = a_reg(Rx);
        Ry = a_reg(Ry);
        A[Ry]--;
        mem_req ((int)A[Ry], BYTE_MASK, &source);
        A[Rx]--;
        if(mem_req ((int)A[Rx], BYTE_MASK, &dest) == BUS_ERROR)
          A[Rx]++;      // Bus Error on destination does not decrement An
    }
    else	        // Dy,Dx addressing mode
    {
        source = D[Ry] & BYTE_MASK;
        dest = D[Rx] & BYTE_MASK;
    }

    // perform the ABCD operation
    result = ((SR & xbit) >> 4) + (source & 0xf) + (dest & 0xf);
    if (result > 9)
    {
        result = result - 10;
        carry = 1;
    }
    else
        carry = 0;
    temp_result = ((source >> 4) & 0xf) + ((dest >> 4) & 0xf) + carry;
    if (temp_result > 9)
    {
        temp_result = temp_result - 10;
        carry = 1;
    }
    else
        carry = 0;

    result = result + (temp_result << 4);

    if (inst & 0x0008)
        put ((long *)&memory[A[Rx]], result, (long) BYTE_MASK);
    else
        put (&D[Rx], result, (long) BYTE_MASK);
    if (carry)
        SR = SR | cbit;
    else
        SR = SR & ~cbit;

    cc_update (GEN, UND, CASE_1, UND, N_A, source, dest, result, (long) BYTE_MASK, 0);
    inc_cyc ( (inst & 0x0008) ? 18 : 6);
    return SUCCESS;
}



//-------------------------------------------------------
// perform the SUB operation
int SBCD()
{
    int Rx, Ry, borrow, temp_result;

    Rx = (inst >> 9) & 0x0007;    // destination
    Ry = inst & 0x0007;           // source

    if (inst & 0x0008)  // -(Ay),-(Ax) addressing mode
    {
        Rx = a_reg(Rx);
        Ry = a_reg(Ry);
        A[Ry]--;
        mem_req ((int)A[Ry], BYTE_MASK, &source);
        A[Rx]--;
        if(mem_req ((int)A[Rx], BYTE_MASK, &dest) == BUS_ERROR)
          A[Rx]++;      // Bus Error on destination does not decrement An
    }
    else
    {		        // Dy,Dx addressing mode
        source = D[Ry];
        dest = D[Rx];
    }

    // perform the SBCD operation
    result = (dest & 0xf) - (source & 0xf) - ((SR & xbit) >> 4);
    if (result < 0)
    {
        result = result + 10;
        borrow = 1;
    }
    else
        borrow = 0;
    temp_result = ((dest >> 4) & 0xf) - ((source >> 4) & 0xf) - borrow;
    if (temp_result < 0)
    {
        temp_result = temp_result + 10;
        borrow = 1;
    }
    else
        borrow = 0;
    result = result + (temp_result << 4);

    if (inst & 0x0008)
        put ((long *)&memory[A[Rx]], result, (long) BYTE_MASK);
    else
        put (&D[Rx], result, (long) BYTE_MASK);

    if (borrow)
        SR = SR | cbit;
    else
        SR = SR & ~cbit;

    cc_update (GEN, UND, CASE_1, UND, N_A, source, dest, result, (long) BYTE_MASK, 0);
    inc_cyc ( (inst & 0x0008) ? 18 : 6);
    return SUCCESS;
}


//-------------------------------------------------------
// perform the NBCD operation
int	NBCD()
{
  int	borrow, temp_result;

  int error = eff_addr((long)BYTE_MASK, DATA_ALT_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  dest = EV1 & BYTE_MASK;

  result = 10 - (dest & 0xf) - ((SR & xbit) >> 4);
  if (result < 10)
    borrow = 1;
  else {        // dest was 0 so 0-0 result should be 0 ck 8-10-2005
    borrow = 0;
    result = 0;
  }

  temp_result = 10 - ((dest >> 4) & 0xf) - borrow;
  if (temp_result < 10)
    borrow = 1;
  else {        // dest was 0 so 0-0 result should be 0 ck 8-10-2005
    borrow = 0;
    temp_result = 0;
  }

  result = result + (temp_result << 4);

  if (borrow)
    SR = SR | cbit;
  else
    SR = SR & ~cbit;

  put (EA1, result, (long) BYTE_MASK);
  cc_update (GEN, UND, CASE_1, UND, N_A, source, dest, result, (long) BYTE_MASK, 0);
  inc_cyc ( (inst & 0x0030) ? 8 : 6);
  return SUCCESS;
}

