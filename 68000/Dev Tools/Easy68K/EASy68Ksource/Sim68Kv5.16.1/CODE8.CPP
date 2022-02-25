
/***************************** 68000 SIMULATOR ****************************

File Name: CODE8.C
Version: 1.0

The instructions implemented in this file are the program control operations:

		Bcc, DBcc, Scc, BRA, BSR, JMP, JSR, RTE, RTR, RTS, NOP

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/


#include <stdio.h>
#include "extern.h"         /* contains global "extern" declarations */


//-------------------------------------------------------------------------
// Branch on Condition Code (not just Carry Clear)
int BCC()
{
  long	displacement;
  int	condition;

  displacement = inst & 0xff;
  if (displacement == 0) {
    mem_request (&PC, (long) WORD_MASK, &displacement);
    from_2s_comp (displacement, (long) WORD_MASK, &displacement);
  } else
    from_2s_comp (displacement, (long) BYTE_MASK, &displacement);

  condition = (inst >> 8) & 0x0f;

  // perform the BCC operation
  if (check_condition (condition))      // If branch taken
  {
    PC = OLD_PC + displacement + 2;
    // displacement is relative to the end of the instruction word
    inc_cyc (10);
  }
  else                                  // Else, branch not taken
    inc_cyc ((inst & 0xff) ? 8 : 12);   // if short branch inc_cyc(8)

  return SUCCESS;
}

//-------------------------------------------------------------------------
// DBcc
// ck. Fixed bug, DBcc did not exit loop and was modifying the upper word
//     of the data register.
int DBCC()
{
  long	displacement;
  int	reg;

  mem_request(&PC, (long) WORD_MASK, &displacement);
  from_2s_comp (displacement, (long) WORD_MASK, &displacement);
  reg = inst & 0x07;

  // perform the DBCC operation
  if (check_condition ((inst >> 8) & 0x0f))
    inc_cyc (12);
  else {
    D[reg] = (D[reg] & ~WORD_MASK) | ((D[reg] - 1) & 0xFFFF);
    if ((D[reg] & 0xffff) == 0xFFFF)
      inc_cyc (14);
    else {
      inc_cyc (10);
      // displacement is relative to the end of the instruction word
      PC = OLD_PC + displacement + 2;
    }
  }

  return SUCCESS;
}


int	SCC()
{
  int	condition;

  int error = eff_addr((long)BYTE_MASK, DATA_ALT_ADDR, true);
  if (error)              // if address error
    return error;         // return error code

  /* perform the SCC operation */
  condition = (inst >> 8) & 0x0f;
  if (check_condition (condition))
    put (EA1, (long) BYTE_MASK, (long) BYTE_MASK);
  else
    put (EA1, (long) 0, (long) BYTE_MASK);

  if ((inst & 0x0030) == 0)
    inc_cyc (check_condition (condition) ? 6 : 4);
  else
    inc_cyc (8);

  return SUCCESS;
}


//-------------------------------------------------------------------------
// BRA
int BRA()
{
  long	displacement;

  displacement = inst & 0xff;
  if (displacement == 0) {
    mem_request (&PC, (long) WORD_MASK, &displacement);
    from_2s_comp (displacement, (long) WORD_MASK, &displacement);
  } else
    from_2s_comp (displacement, (long) BYTE_MASK, &displacement);

  // perform the BRA operation
  PC = OLD_PC + displacement + 2;
  // displacement is relative to the end of the instructin word

  inc_cyc (10);
  return SUCCESS;
}



int	BSR()
{
  long	displacement;

  displacement = inst & 0xff;
  if (displacement == 0) {
    mem_request (&PC, (long) WORD_MASK, &displacement);
    from_2s_comp (displacement, (long) WORD_MASK, &displacement);
  } else
    from_2s_comp (displacement, (long) BYTE_MASK, &displacement);

  // perform the BSR operation
  A[a_reg(7)] -= 4;
  put ((long *) &memory[A[a_reg(7)]], PC, LONG_MASK);

  // set address to stop program execution if user selects "Step Over"
  if (sstep && stepToAddr == 0) {  // if "Step Over" mode
    trace = false;              // do not trace through subroutine
    stepToAddr = PC;
  }

  PC = OLD_PC + displacement + 2;
  // displacement is relative to the end of the instruction word

  inc_cyc (18);
  return SUCCESS;
}



int	JMP()
{
  int error = eff_addr((long)WORD_MASK, CONTROL_ADDR, false);
  if (error)              // if address error
    return error;         // return error code

  /* perform the JMP operation */
  PC = (int) ((int)EA1 - (int)&memory[0]);

  switch (eff_addr_code (inst, 0)) {
	case 0x02 : inc_cyc (8);
	            break;
	case 0x05 : inc_cyc (10);
	            break;
	case 0x06 : inc_cyc (14);
	            break;
	case 0x07 : inc_cyc (10);
	            break;
	case 0x08 : inc_cyc (12);
	            break;
	case 0x09 : inc_cyc (10);
	            break;
	case 0x0a : inc_cyc (14);
	            break;
	default   : break;
	}

  return SUCCESS;
}




int	JSR()
{
  int error = eff_addr((long)WORD_MASK, CONTROL_ADDR, false);
  if (error)              // if address error
    return error;         // return error code

  // push the longword address immediately following PC on the system stack
  // then change the PC
  A[a_reg(7)] -= 4;
  put ((long *)&memory[A[a_reg(7)]], PC, LONG_MASK);

  // set address to stop program execution if user selects "Step Over"
  if (sstep && stepToAddr == 0) {  // if "Step Over" mode
    trace = false;              // do not trace through subroutine
    stepToAddr = PC;
  }

  PC = (int) ((int)EA1 - (int)&memory[0]);

  switch (eff_addr_code (inst, 0)) {
	case 0x02 : inc_cyc (16);
	            break;
	case 0x05 : inc_cyc (18);
	            break;
	case 0x06 : inc_cyc (22);
	            break;
	case 0x07 : inc_cyc (18);
	            break;
	case 0x08 : inc_cyc (20);
	            break;
	case 0x09 : inc_cyc (18);
	            break;
	case 0x0a : inc_cyc (22);
	            break;
	default   : break;
	}

  return SUCCESS;

}


int	RTE()
{
long	temp;

if (!(SR & sbit))
	return (NO_PRIVILEGE);

mem_request (&A[8], (long) WORD_MASK, &temp);
SR = temp & WORD_MASK;
mem_request (&A[8], LONG_MASK, &PC);

inc_cyc (20);

return SUCCESS;

}



int	RTR()
{
long	temp;

mem_request (&A[a_reg(7)], (long) BYTE_MASK, &temp);
SR = (SR & 0xff00) | (temp & 0xff);

mem_request (&A[a_reg(7)], LONG_MASK, &PC);

inc_cyc (20);

return SUCCESS;

}



int	RTS()
{

mem_request (&A[a_reg(7)], LONG_MASK, &PC);

inc_cyc (16);

return SUCCESS;

}



int	NOP()
{

inc_cyc (4);

return SUCCESS;

}

