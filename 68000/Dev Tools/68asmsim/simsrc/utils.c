
/***************************** 68000 SIMULATOR ****************************

File Name: UTILS.C
Version: 1.0

This file contains various routines to aid in executing a 68000 instruction

The routines are :  

   to_2s_comp, from_2s_comp, sign_extend, inc_cyc, eff_addr_code, 
   a_reg, mem_put, mem_req, mem_request, put, value_of, cc_update, 
   and check_condition.

***************************************************************************/



#include <stdio.h>
#include "extern.h"         /* contains global declarations */



/**************************** int to_2s_comp () ****************************

   name       : int to_2s_comp (number, size, result)
   parameters : long number : the number to be converted to 2's compliment
                long size : the size of the operation
                long *result : the result of the conversion
   function   : to_2s_comp() converts a number to 2's compliment notation.


****************************************************************************/

int	to_2s_comp (number, size, result)
long	number, size, *result;
{

if (size == LONG)
	{
	if (number < 0)
		*result = ~number - 1;
	else
		*result = number;
	}
if (size == WORD)
	{
	if (number < 0)
		*result = (~(number & WORD) & WORD) - 1;
	else
		*result = number;
	}
if (size == BYTE)
	{
	if (number < 0)
		*result = (~(number & BYTE) & BYTE) - 1;
	else
		*result = number;
	}

return SUCCESS;

}




/**************************** int from_2s_comp () **************************

   name       : int from_2s_comp (number, size, result)
   parameters : long number : the number to be converted to 2's compliment
                long size : the size of the operation
                long *result : the result of the conversion
   function   : from_2s_comp() converts a number from 2's compliment 
                  notation to the "C" language format so that operations
                  may be performed on it.


****************************************************************************/


int	from_2s_comp (number, size, result)
long	number, size, *result;
{

if (size == LONG)
	{
	if (number & 0x80000000)
		{
		*result = ~number + 1;
		*result = -*result;
		}
	else
		*result = number;
	}
if (size == WORD)
	{
	if (number & 0x8000)
		{
		*result = (~number + 1) & WORD;
		*result = -*result;
		}
	else
		*result = number;
	}
if (size == BYTE)
	{
	if (number & 0x80)
		{
		*result = (~number + 1) & BYTE;
		*result = -*result;
		}
	else
		*result = number;
	}

return SUCCESS;

}



/**************************** int sign_extend () ***************************

   name       : int sign_extend (number, size_from, result)
   parameters : int number : the number to sign extended
                long size_from : the size of the source
                long *result : the result of the sign extension
   function   : sign_extend() sign-extends a number from byte to word or
                  from word to long.


****************************************************************************/

int	sign_extend (number, size_from, result)
int	number;
long	size_from;
long	*result;
{

	*result = number & size_from;
	if ((size_from == WORD) && (number & 0x8000))
		*result |= 0xffff0000;
	if ((size_from == BYTE) && (number & 0x80))
		*result |= 0xff00;

	return SUCCESS;

}




/**************************** int inc_cyc () *******************************

   name       : int inc_cyc (num)
   parameters : int num : number of cycles to increment the cycle counter.
   function   : inc_cyc() increments the machine cycle counter by 'num'.


****************************************************************************/

int inc_cyc (num)
int	num;
{

   cycles = cycles + num;

}



/**************************** int eff_addr_code () *************************

   name       : int eff_addr_code (inst, start)
   parameters : int inst : the instruction word
                int start : the start bit of the effective address field
   function   : returns the number of the addressing mode contained in 
                  the effective address field of the instruction.  This
                  number is used in calculating the execution time for 
                  many functions.


****************************************************************************/

int	eff_addr_code (inst, start)
int	inst;
int	start;
{
	int	mode, reg;

	inst = (inst >> start);
	reg = inst & 0x07;
	mode = (inst >> 3) & 0x07;

	if (mode != 7) return (mode);

	switch (reg) {
		case 0x00 : return (7);
	               break;
		case 0x01 : return (8);
	               break;
		case 0x02 : return (9);
	               break;
		case 0x03 : return (10);
	               break;
		case 0x04 : return (11);
	               break;
		default   : return (12);
   	            break;
		}

	return -1;

}




/**************************** int a_reg () *********************************

   name       : int a_reg (reg_num)
   parameters : int reg_num : the address register number to be processed
   function   : a_reg() allows both the SSP and USP to act as A[7].  It
                  returns the value '8' if the supervisor bit is set and
                  the reg_num input was '7'.  Otherwise, it returns the
                  reg_num without change.


****************************************************************************/

int	a_reg (reg_num)
int	reg_num;
{

	if ((reg_num == 7) && (SR & sbit))
		return 8;
	else
		return reg_num;

}



/**************************** int mem_put() ********************************

   name       : int mem_put(data, loc, size)
   parameters : long data : the data to be placed in memory
                int loc   : the location to place the data
                long size : the appropriate size mask for the operation
   function   : mem_put() puts data in main memory.  It acts as the "memory
                  management unit" in that it checks for out-of-bound
                  virtual addresses and odd memory accesses on long and
                  word operations and performs the appropriate traps in
                  the cases where there is a violation.  Theoretically,
                  this is the only place in the simulator where the main
                  memory should be written to.

****************************************************************************/

int	mem_put (data, loc, size)
long	data;
int	loc;
long	size;
{

/* check for odd location reference on word and longword writes */
/* if there is a violation, initiate an address exception */
if ((loc % 2 != 0) && (size != BYTE))       
	{
	/* generate an address error */
	printf ("Address exception at location %4x", OLD_PC);
	windowLine();
	printf ("  was writing to location %4x", loc);
	windowLine();
	mem_req (0xc, LONG, &PC);
	exception (0, (long) loc, WRITE);
	return (FAILURE);
	}

/* check for virtual-address out-of-bounds condition.  If there is a */
/* violation, initiate a bus error */
if ((loc < 0) || (loc > MEMSIZE))
	{			/* generate a bus error */
	printf ("Bus Error: Address out of virtual memory space ");
	printf ("at location %4x", OLD_PC);
	windowLine();
	printf ("  was writing to location %4x", loc);
	windowLine();
	mem_req (0x8, LONG, &PC);
	exception (0, (long) loc, WRITE);
	return (FAILURE);
	}

/* if everything is okay then perform the write according to size */
if (size == BYTE)
	memory[loc] = data & BYTE;
else if (size == WORD)
	{
	memory[loc] = (data >> 8) & BYTE;
	memory[loc+1] = data & BYTE;
	}
else if (size == LONG)
	{
	memory[loc] = (data >> 24) & BYTE;
	memory[loc+1] = (data >> 16) & BYTE;
	memory[loc+2] = (data >> 8) & BYTE;
	memory[loc+3] = data & BYTE;
	}

return SUCCESS;

}




/**************************** int mem_req() ********************************

   name       : int mem_req(loc, size, result)
   parameters : int loc : the memory location to read data from
                long size : the appropriate size mask for the operation
                long *result : a pointer to the longword location  
                      to store the result in
   function   : mem_req() returns the contents of a location in main 
                  memory.  It acts as the "memory management unit" in 
                  that it checks for out-of-bound virtual addresses and 
                  odd memory accesses on long and word operations and 
                  performs the appropriate traps in the cases where there 
                  is a violation.  Theoretically, this is the only function
                  in the simulator where the main memory should be read
                  from.

****************************************************************************/

int	mem_req (loc, size, result)
int	loc;
long	size;
long	*result;
{
long	temp;

/* check for odd location reference on word and longword reads. */
/* If there is a violation, initiate an address exception */
if ((loc % 2 != 0) && (size != BYTE))
	{
	/* generate an address error */
	errflg = FALSE;
	printf ("Address exception at location %4x", OLD_PC);
	windowLine();
	printf ("  was reading from location %4x", loc);
	windowLine();
	mem_req (0xc, LONG, &PC);
	exception (0, (long) loc, READ);
	return (FAILURE);
	}

/* check for virtual-address out-of-bounds condition.  If there is a */
/* violation, initiate a bus error */
if ((loc < 0) || (loc > MEMSIZE))
	{
	/* generate a bus error */
	errflg = FALSE;
	printf ("Bus Error: Address out of virtual memory space ");
	printf ("at location %4x", OLD_PC);
	windowLine();
	printf ("  was reading from location %4x", loc);
	windowLine();
	mem_req (0x8, LONG, &PC);
	exception (0, (long) loc, READ);
	return (FAILURE);
	}

/* if everything is okay then perform the read according to size */
temp = memory[loc] & BYTE;
if (size != BYTE)
	{
	temp = (temp << 8) | (memory[loc + 1] & BYTE);
	if (size != WORD)
		{
		temp = (temp << 8) | (memory[loc + 2] & BYTE);
		temp = (temp << 8) | (memory[loc + 3] & BYTE);
		}
	}
*result = temp;

return SUCCESS;

}




/**************************** int mem_request() ****************************

   name       : int mem_request (loc, size, result)
   parameters : int *loc : the memory location to read data from
                long size : the appropriate size mask for the operation
                long *result : a pointer to the longword location  
                      to store the result in
   function   : mem_request() is another "level" of main-memory access.
                  It performs the task of calling the functin mem_req()
                  (above) using "WORD" for the size mask if the simulator
                  wants a byte from main memory.  Also, it increments
                  the location pointer passed to it.  This is to 
                  facilitate easy opcode and operand fetch operations
                  where the program counter needs to be incremented.

                  Therefore, in the simulator, "mem_req()" requests data
                  from main memory, and "mem_request()" does the same but
                  also increments the location pointer.  Note that 
                  mem_request() requires a pointer to an int as the first
                  parameter.

****************************************************************************/

int	mem_request (loc, size, result)
int	*loc;
long	size;
long	*result;
{
	int	req_result;

	if (size == LONG)
		req_result = mem_req (*loc, LONG, result);
	else
		req_result = mem_req (*loc, (long) WORD, result);

	if (size == BYTE)
		*result = *result & 0xff;

	if (!req_result)
		if (size == LONG)
			*loc += 4;
		else
			*loc += 2;

	return req_result;

}




/**************************** int put() ************************************

   name       : int put (dest, source, size)
   parameters : long *dest : the destination to move data to
                long source : the data to move
                long size : the appropriate size mask for the operation
   function   : put() performs the task of putting the result of some
                  operation into a destination location "according to 
                  size".  This means that the bits of the destination
                  that are in excess to the size of the operation are not
                  affected.  This function provides a general-purpose
                  mechanism for putting the result of an operation in 
                  the destination, no matter whether the destination is
                  a memory location or a 68000 register.  The data is
                  placed in the destination correctly and the rest of
                  the bits in a register are left alone.

****************************************************************************/

int	put (dest, source, size)
long	*dest, source, size;

{

	if (( (int)dest >= (int)&memory[0]) &&
			((int)dest <= (int)&memory[MEMSIZE]))
		mem_put (source, (int) ((int)dest - (int)&memory[0]), size);
	else
		*dest = (source & size) | (*dest & ~size);

}




/**************************** int value_of() *******************************

   name       : int value_of (EA, EV, size)
   parameters : long *EA : the location of the data to be evaluated
                long *EV : the location of the result
                long size : the appropriate size mask
   function   : value_of() returns the value of the location referenced
                  regardless of whether it is a virtual memory location
                  or a 68000 register location.  The "C" language stores
                  the bytes in an integer in the reverse-order that we 
                  store the bytes in virtual memory, so this function
                  provides a general way of finding the value at a 
                  location.

****************************************************************************/


int	value_of (EA, EV, size)
long	*EA, *EV, size;
{

	if (((int)EA < (int)&memory[0]) || ((int)EA > (int)&memory[MEMSIZE]))
		*EV = *EA & size;
	else
		mem_req ( (int) ((int)EA - (int)&memory[0]), size, EV);

}




/**************************** int cc_update() *****************************

   name       : int cc_update (x, n, z, v, c, source, dest, result, size, r)
   parameters : int x, n, z, v, c : the codes for actions that should be
                    taken to compute the different condition codes.
                long source : the source operand for the instruction
                long dest : the destination operand for the instruction
                long result : the result of the instruction
                long size : the size of the instruction
                int r : the shift count for shift and rotate instructions
   function   : updates the five condition codes according to the codes
                  passed as parameters.  each of the condition codes
                  has a number of ways it can be calculated, and the 
                  appropriate method of computation is passed as the 
                  parameter for that condition code.  The source, dest, and
                  result operands contain the source, destination, and
                  result of the instruction requesting updating the 
                  condition codes.  Also, for shift and rotate instructions
                  the shift count needs to be passed.

                  The details of the different ways to calculate condition
                  codes are contained in Appendix A of the 68000 
                  Programmer's Reference Manual.

****************************************************************************/


int	cc_update (x, n, z, v, c, source, dest, result, size, r)
int	x, n, z, v, c;
long	source, dest, result;
long	size;
int	r;
{
int	x_bit, n_bit, z_bit, v_bit, c_bit;
long	Rm, Dm, Sm;
long	count, temp1, temp2, m;

/* assign the bits to their variables here */
x_bit = SR & xbit;
n_bit = SR & nbit;
z_bit = SR & zbit;
v_bit = SR & vbit;
c_bit = SR & cbit;

source &= size;
dest &= size;
result &= size;

if (size == BYTE)
			{
			m = 7;
		   Sm = source & 0x0080;
		   Rm = result & 0x0080;
		   Dm = dest & 0x0080;
			};
if (size == WORD)
			{
			m = 15;
		   Sm = source & 0x8000;
		   Rm = result & 0x8000;
		   Dm = dest & 0x8000;
			};
if (size == LONG)
			{
			m = 31;
		   Sm = source & 0x80000000;
		   Rm = result & 0x80000000;
		   Dm = dest & 0x80000000;
			};

/* calculate each of the five condition codes according to the requested */
/* method of calculation */
switch (n) {
	case N_A : break; 			/* n_bit not affected */
	case GEN : n_bit = (Rm) ? TRUE : FALSE;
		   break;
	case UND : n_bit = !n_bit;		/* undefined result */
		   break;
	}
switch (z) {
	case N_A : break;			/* z_bit not affected */
	case UND : z_bit = !z_bit;		/* z_bit undefined */
		   break;
	case GEN : z_bit = (result == 0) ? TRUE : FALSE;
		   break;
	case CASE_1 : z_bit = (z_bit && (result == 0)) ? TRUE : FALSE;
	      break;
	};
switch (v) {
	case N_A : break;			/* v_bit not affected */
	case ZER : v_bit = 0;
		   break;
	case UND : v_bit = !v_bit;		/* v_bit not defined */
		   break;
	case CASE_1 : v_bit = ((Sm && Dm && !Rm) || (!Sm && !Dm && Rm)) ? 
			TRUE : FALSE;
		      break;
	case CASE_2 : v_bit = ((!Sm && Dm && !Rm) || (Sm && !Dm && Rm)) ? 
			TRUE : FALSE;
		      break;
	case CASE_3 : v_bit = (Dm && Rm) ? TRUE : FALSE;
		      break;
	};
switch (c) {
	case N_A : break;			/* c_bit not affected */
	case UND : c_bit = !c_bit;    		/* c_bit undefined  */
		   break;
	case ZER : c_bit = 0;
		   break;
	case CASE_1 : c_bit = x_bit;
		      break;
	case CASE_2 : c_bit = ((dest >> (r-1)) & 1) ? TRUE : FALSE;
		      break;
	case CASE_3 : c_bit = ((dest >> (m-r+1)) & 1) ? TRUE : FALSE;
		      break;
	case CASE_4 : c_bit = (Dm || Rm) ? TRUE : FALSE;
		      break;
	case CASE_5 : c_bit = ((Sm && Dm) || (!Rm && Dm) || (Sm && !Rm)) ? 
			TRUE : FALSE;
		      break;
	case CASE_6 : c_bit = ((Sm && !Dm) || (Rm && !Dm) || (Sm && Rm)) ? 
			TRUE : FALSE;
		      break;
	};
switch (x) {
	case N_A : break;     		/* X condition code not affected */
	case GEN : x_bit = c_bit;		/* general case */
		   break;
	};

/* set SR according to results */
SR = SR & 0xffe0;							/* clear the condition codes */
if (x_bit) SR = SR | xbit;
if (n_bit) SR = SR | nbit;
if (z_bit) SR = SR | zbit;
if (v_bit) SR = SR | vbit;
if (c_bit) SR = SR | cbit;

return SUCCESS;

}




/**************************** int check_condition() ************************

   name       : int check_condition (condition)
   parameters : int condition : the condition to be checked
   function   : check_condition() checks for the truth of a certain 
                  condition and returns the result.  The possible conditions
                  are encoded in DEF.H and can be seen in the switch()
                  statement below.

****************************************************************************/


int	check_condition (condition)
int	condition;
{
int	result;

result = FALSE;
switch (condition)
	{
	case T : result = 1;				/* true */
		   break;
	case F : result = 0;				/* false */
		   break;
	case HI : result = !(SR & cbit) && !(SR && zbit);	/* high */
		   break;
	case LS : result = (SR & cbit) || (SR & zbit);	/* low or same */
		   break;
	case CC : result = !(SR & cbit);		/* carry clear */
		   break;
	case CS : result = (SR & cbit);		/* carry set */
		   break;
	case NE : result = !(SR & zbit);		/* not equal */
		   break;
	case EQ : result = (SR & zbit);		/* equal */
		   break;
	case VC : result = !(SR & vbit);		/* overflow clear */
		   break;
	case VS : result = (SR & cbit);		/* overflow set */
		   break;
	case PL : result = !(SR & nbit);		/* plus */
		   break;
	case MI : result = (SR & nbit);                /* minus */
		   break;
	case GE : result = ((SR & nbit) && (SR & vbit)) ||
          (!(SR & nbit) && !(SR & vbit));          /* greater or equal */  
		   break;
	case LT : result = ((SR & nbit) && !(SR & vbit))    /* less than */
          || (!(SR & nbit) && (SR & vbit));
		   break;
	case GT : result = ((SR & nbit) && (SR & vbit) && !(SR & zbit)) 
          || (!(SR & nbit) && !(SR & vbit) && (SR & zbit)); /* greater than */
		   break;
	case LE : result = ((SR & nbit) && !(SR & vbit))    /* less or equal */
          || (!(SR & nbit) && (SR & vbit)) || (SR & zbit);
			break;
	}
return result;

}


