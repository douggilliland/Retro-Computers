
/***************************** 68000 SIMULATOR ****************************

File Name: RUN.C
Version: 1.0

This file contains various routines to run a 68000 instruction.  These
routines are :

	decode_size(), eff_addr(), runprog(), exec_inst(), exception()

***************************************************************************/



#include <stdio.h>
#include "extern.h"         					/* global declarations */
#include "opcodes.h"        					/* opcode masks for decoding */
														/* the 68000 instructions */



/**************************** int decode_size() ****************************

   name       : int decode_size (result)
   parameters : long *result : the appropriate mask for the decoded size
   function   : decodes the size field in the instruction being processed
                  and returns a mask to be used in instruction execution.
                  For example, if the size field was "01" then the mask 
                  returned is WORD.

****************************************************************************/


int	decode_size (result)
long	*result;
{
	int	bits;

	/* the size field is always in bits 6 and 7 of the instruction word */
	bits = (inst >> 6) & 0x0003;

	switch (bits) {
		case 0 : *result = BYTE;
			 break;
		case 1 : *result = WORD;
			 break;
		case 2 : *result = LONG;
			 break;
		default : *result = 0;
		}

	if (result != 0) 
	   return SUCCESS;
	else	
	   return FAILURE;

}



/**************************** int eff_addr() *******************************

   name       : int eff_addr (size, mask, add_times)
   parameters : long size : the appropriate size mask
                int mask : the effective address modes mask to be used
                int add_times : tells whether to increment the cycle counter
                      (there are times when we don't want to)
   function   : eff_addr() decodes the effective address field in the current
                  instruction, returns a pointer to the effective address 
                  either in EA1 or EA2, and returns the value at that 
                  location in EV1 or EV2.

****************************************************************************/


int eff_addr (size, mask, add_times)
long	size;
int	mask;
int	add_times;
{
	int	mode, reg, legal, addr, move_operation;
	int	bwinc, linc;
	long	ext, temp_ext, inc_size, ind_reg, *value, disp;

	if (
			( 
				((inst & 0xf000) == 0x1000)
				|| ((inst & 0xf000) == 0x2000)
				||	((inst & 0xf000) == 0x3000)
			) 
			&& (mask == DATA_ALT_ADDR)
		)
		move_operation = TRUE;
	else
		move_operation = FALSE;

	if (move_operation)
		addr = (inst >> 6) & 0x003f;
	else
		addr = inst & 0x003f;
	legal = FALSE;
	bwinc = linc = 0;
   if (move_operation)		/* reg and mode are reversed in MOVE dest EA */
		{
		reg = (addr & MODE_MASK) >> 3;
		mode = addr & REG_MASK;
		}
	else
		{
		mode = (addr & MODE_MASK) >> 3;
		reg = addr & REG_MASK;
		}
	switch (mode) {
	   case	0 : if (mask & bit_1)
			{
			value = &D[reg];
			bwinc = linc = 0;
			legal = TRUE;
			}
		    break;
	   case	1 : if (mask & bit_2)
			{
			reg = a_reg(reg);
			value = &A[reg];
			bwinc = linc = 0;
			legal = TRUE;
			}
		    break;
	   case	2 : if (mask & bit_3)
			{
			reg = a_reg(reg);
			value = (long) &memory[A[reg]];
			bwinc = 4;
			linc = 8;
			legal = TRUE;
			}
		    break;
	   case	3 : if (mask & bit_4)
			{
			reg = a_reg(reg);
			if (size == BYTE) 
				inc_size = 1;
			else if (size == WORD)
				inc_size = 2;
			else inc_size = 4;
			value = (long) &memory[A[reg]];
			A[reg] = A[reg] + inc_size;
			bwinc = 4;
			linc = 8;
			legal = TRUE;
			}
		    break;
	   case	4 : if (mask & bit_5)
			{
			reg = a_reg(reg);
			if (size == BYTE) 
				inc_size = 1;
			else if (size == WORD)
				inc_size = 2;
			else inc_size = 4;
			A[reg] = A[reg] - inc_size;
			value = (long) &memory[A[reg]];
			bwinc = 6;
			linc = 10;
			legal = TRUE;
			}
		    break;
	   case	5 : if (mask & bit_6)
			{
			reg = a_reg(reg);
			mem_request (&PC, (long) WORD, &ext);
			from_2s_comp (ext, (long) WORD, &ext);
			value = (long) &memory[A[reg] + (ext & WORD)];
			bwinc = 8;
			linc = 12;
			legal = TRUE;
			}
		    break;
	   case	6 : if (mask & bit_7)
			{
			reg = a_reg(reg);
			/* fetch extension word */
			mem_request (&PC, (long) WORD, &ext);
			disp = ext & 0xff;
			sign_extend (disp, BYTE, &disp);
			from_2s_comp (disp, (long) WORD, &disp);
			/* get index register value */
			if (ext & 0x8000)
				ind_reg = A[a_reg((ext & 0x7000) >> 12)];
			else
				ind_reg = D[(ext & 0x7000) >> 12];
			/* get correct length for index register */
			if (!(ext & 0x0800))
				{
				sign_extend (ind_reg, WORD, &ind_reg);
				from_2s_comp (ind_reg, (long) LONG, &ind_reg);
				}
			value = (long) (&memory[A[reg] + (disp & WORD) + ind_reg]);
			bwinc = 10;
			linc = 14;
			legal = TRUE;
			}
		    break;
	   case	7 : switch (reg) {
			   case	0 : if (mask & bit_8)
	    			{
					mem_request (&PC, (long) WORD, &ext);
					value = (long) &memory[ext];
					bwinc = 8;
					linc = 12;
					legal = TRUE;
					}
				    break;
			   case	1 : if (mask & bit_9)
					{
					mem_request (&PC, (long) WORD, &ext);
					mem_request (&PC, (long) WORD, &temp_ext);
					ext = ext * 0xffff + temp_ext;
					value = (long) &memory[ext & ADDRMASK];
					bwinc = 12;
					linc = 16;
					legal = TRUE;
					}
					 break;
			   case	2 : if (mask & bit_10)
					{
					mem_request (&PC, (long) WORD, &ext);
					from_2s_comp (ext, (long) WORD, &ext);
					value = (long) &memory[PC + (ext & WORD) - 1];
					bwinc = 8;
					linc = 12;
					legal = TRUE;
					}
					 break;
			   case	3 : if (mask & bit_11)
					{
					/* fetch extension word */
					mem_request (&PC, (long) WORD, &ext);
					disp = ext & 0xff;
					sign_extend (disp, BYTE, &disp);
					from_2s_comp (disp, (long) WORD, &disp);
					/* get index register value */
					if (ext & 0x8000)
					   ind_reg = A[a_reg((ext & 0x7000) >> 12)];
					else
					   ind_reg = D[(ext & 0x7000) >> 12];
					/* get correct length for index register */
					if (!(ext & 0x0800))
						{
						sign_extend (ind_reg, WORD, &ind_reg);
						from_2s_comp (ind_reg, (long) LONG, &ind_reg);
						}
					ext = ext & 0x00ff;
					value = (long) (&memory[PC - 1 + (disp & WORD) + ind_reg]);
					bwinc = 10;
					linc = 14;
					legal = TRUE;
					}
				    break;
			   case	4 : if (mask & bit_12)
					{
					if ((size == BYTE) || (size == WORD))
						mem_request (&PC, (long) WORD, &ext);
					else
						mem_request (&PC, LONG, &ext);
					global_temp = ext;
					value = &global_temp;
					bwinc = 4;
					linc = 8;
					legal = TRUE;
					}
				    break;
				}
			break;
	}   	  /* switch */

	if (legal) 
		{
		if (add_times) {
			if (size != LONG) 
				inc_cyc (bwinc);
			else 	
				inc_cyc (linc);
		}
		if (move_operation)/* choose EA2 in case of MOVE dest effective address */
			{
	 		EA2 = value;
			value_of (EA2, &EV2, size);
			}
		else
			{
			EA1 = value;
			value_of (EA1, &EV1, size);
			}
		return SUCCESS;
		}
	else
		return FAILURE;       /* return FAILURE if illegal addressing mode */

}




/**************************** int runprog() *******************************

   name       : int runprog ()
   parameters : NONE
   function   : executes a program at PC specified or current PC if not
                  specified.  this function is the outer loop of the 
                  running program.  it handles i/o interrupts, user
                  (keyboard) interrupts, and calls the error routine if an
                  illegal opcode is found.


****************************************************************************/

int runprog()
{
	int new_pc;
	int i;
	char ch, *pc_str;

	printf ("Running the program ...");
	windowLine();

	if (wcount > 1)
		{
		pc_str = wordptr[1];
		eval2 (pc_str, &new_pc);
		OLD_PC = PC = new_pc;
		}

	errflg = 0;

	for (;;)		/* execute instructions until error or break */
		{

		exec_inst();		/* execute an instruction */

		ch = chk_buf();   /* has a character been hit ? */
		if (ch != '\0')
			switch ((int) ch)
				{
				case 3: exit (0);     /* exit simulator if control-c */
				case 2: save_cursor();
							scrshow();    /* terminate the 68000 program if control-b */
							restore_cursor();
	                 return (USER_BREAK);
				}

		if (errflg)   /* if illegal opcode in program initiate an exception */
			{
			printf("illegal opcode at loc %04x", WORD & (PC - 1));
			windowLine();
			inc_cyc (34);
			exception (1, 0, READ);
			mem_req (0x10, LONG, &PC);
			save_cursor();
			scrshow();
			restore_cursor();
			return (0);
			}

		if (trace) {
			save_cursor();
			scrshow();   /* if trace is on then update the screen */
			restore_cursor();
			}

		for (i = 0; i < bpoints; i++)	  /* if PC equals a breakpoint, break */
			if (PC == brkpt[i])
				{
				printf("break point at %04x", PC);
				windowLine();
				save_cursor();
				scrshow();
				restore_cursor();
				return (0);
				}
		if (sstep) return (0);  /* if single stepping is on then stop running */

		OLD_PC = PC;	/* update the OLD_PC */
		}

}




/**************************** int exec_inst() *****************************

   name       : int exec_inst ()
   parameters : NONE
   function   : executes a single instruction at the location pointed 
                  to by PC.  it is called from runprog() and sets the 
                  flag "errflg" if an illegal opcode is detected so 
                  that runprog() terminates.  exec_inst() also takes
                  care of handling the different kinds of exceptions 
                  that may occur.  If an instruction returns a different
                  return code than "SUCCESS" then the appropriate
                  exception is initiated, unless the "exceptions" flag
                  is turned off by the user in which case the exception
                  is not initiated and the program simply terminates and
                  informs the user that an exception condition has occurred.


****************************************************************************/


int exec_inst()
{
int	start, finish, exec_result, i;

if ( !(mem_request (&PC, (long) WORD, &inst)) )
   {
	start = offsets[(inst & FIRST_FOUR) >> 12];
	finish = offsets[((inst & FIRST_FOUR) >> 12) + 1] - 1;
	errflg = TRUE;

	if ((inst & 0xF000) == 0xA000)	/* unimplemented instruction */
		{
		errflg = FALSE;
		mem_req (0x28, LONG, &PC);
		printf ("'Line A' unimplemented instruction found at location %4x",
			OLD_PC);
		windowLine();
		}
	else
	if ((inst & 0xF000) == 0xF000)	/* unimplemented instruction */
		{
		errflg = FALSE;
		mem_req (0x2C, LONG, &PC);
		printf ("'Line F' unimplemented instruction found at location %4x",
			OLD_PC);
		windowLine();
		}
	else
	for (i = start; i <= finish; i++)
		{
		if ((inst & ~inst_arr[i].mask) == inst_arr[i].val)
			{
			if (trace) {
				printf ("executing a %s instruction at location %4x",
					inst_arr[i].name, PC-2);
				windowLine();
				}

			exec_result = (*(names[i]))();

	if (exceptions)
	{
			switch (exec_result)
				{
				case SUCCESS  : break;
				case BAD_INST : inc_cyc (34);	/* load the PC from the illegal */
									 exception (1, 0, READ);
									 mem_req (0x10, LONG, &PC);	    /* vector */
	printf ("Illegal instruction found at location %4x", OLD_PC);
									windowLine();
						          break;
				case NO_PRIVILEGE : inc_cyc (34);
									 exception (1, 0, READ);
									 mem_req (0x20, LONG, &PC);
	printf ("supervisor privilege violation at location %4x", OLD_PC);
									windowLine();
						          break;
				case CHK_EXCEPTION : inc_cyc (40);
									 exception (2, 0, READ);
									 mem_req (0x18, LONG, &PC);
						          break;
				case ILLEGAL_TRAP : inc_cyc (34);
									 exception (1, 0, READ);
									 mem_req (0x10, LONG, &PC);
						          break;
				case STOP_TRAP : sstep = TRUE;	/* break out of the program */
									 break;
				case TRAP_TRAP : inc_cyc (34);
									 exception (2, 0, READ);
									 mem_req (128 + (inst & 0x0f) * 4, LONG, &PC);
						          break;
				case TRAPV_TRAP : inc_cyc (34);
									 exception (2, 0, READ);
									 mem_req (0x1c, LONG, &PC);
						          break;
				case DIV_BY_ZERO : inc_cyc (38);
									 exception (2, 0, READ);
									 mem_req (0x14, LONG, &PC);
						          break;
				}

			if (SR & tbit)   /* initiate a trace exception */
				{
				inc_cyc (34);
				exception (1, 0, READ);
				mem_req (0x24, LONG, &PC);
				}
	}
	else
	{
			switch (exec_result)
				{
				case SUCCESS  : break;
				case BAD_INST : sstep = TRUE;	/* break out of the program */
	printf ("Illegal instruction found at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case NO_PRIVILEGE : sstep = TRUE;	/* break out of the program */
	printf ("supervisor privilege violation at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case CHK_EXCEPTION : sstep = TRUE;	/* break out of the program */
	printf ("CHK exception occurred at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case ILLEGAL_TRAP : sstep = TRUE;	/* break out of the program */
	printf ("Illegal instruction found at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case STOP_TRAP : sstep = TRUE;	/* break out of the program */
	printf ("STOP instruction executed at location %4x. Execution halted", OLD_PC);
									windowLine();
									 break;
				case TRAP_TRAP : sstep = TRUE;	/* break out of the program */
	printf ("TRAP exception occurred at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case TRAPV_TRAP : sstep = TRUE;	/* break out of the program */
	printf ("TRAPV exception occurred at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				case DIV_BY_ZERO : sstep = TRUE;	/* break out of the program */
	printf ("Divide by zero occurred at location %4x. Execution halted", OLD_PC);
									windowLine();
						          break;
				}

	if (SR & tbit)
		{
		sstep = TRUE;	/* break out of the program */
		printf ("TRACE exception occurred at location %4x. Execution halted", OLD_PC);
		windowLine();
		}
	}
			errflg = FALSE;
			break;
			}
		}

}

}





/**************************** int exception () *****************************

   name       : int exception (class, loc, r_w)
   parameters : int class : class of exception to be taken
                long loc : the address referenced in the case of an
                  address or bus error
                int r_w : in the case of an address or bus error, this
                  tells whether the reference was a read or write 
   function   : initiates exception processing by pushing the appropriate
                  exception stack frame on the system stack and turning 
                  supervisor mode on and trace mode off.


****************************************************************************/

int	exception(class, loc, r_w)
int	class;
long	loc;
int	r_w;
{
	int	info_word;

	if ( (class == 1) || (class == 2))
		{
		A[8] -= 4;		/* create the stack frame for class 1 and 2 exceptions */
		put (&memory[A[8]], OLD_PC, LONG);
		A[8] -= 2;
		put (&memory[A[8]], (long) SR, (long) WORD);
		}
	else
		{						/* class 0 exception (address or bus error) */
		inc_cyc (50);    /* fifty clock cycles for the address or bus exception */
		A[8] -= 4;						/* now create the exception stack frame */
		put (&memory[A[8]], OLD_PC, LONG);
		A[8] -= 2;
		put (&memory[A[8]], (long) SR, (long) WORD);
		A[8] -= 2;
		put (&memory[A[8]], (long) inst, (long) WORD);
		A[8] -= 4;
		put (&memory[A[8]], loc, LONG);
		A[8] -= 2;
		info_word = 0x6;
		if (r_w == READ)
			info_word |= 0x10;
		put (&memory[A[8]], (long)0x0016, (long) WORD);/* push information word */
		}
	SR = SR | sbit;			/* force processor into supervisor state */
	SR = SR & ~tbit;			/* turn off trace mode */

}


