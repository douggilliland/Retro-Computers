
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
#include "SIM68Ku.h"
#include "hardwareu.h"
#include "Memory1.h"
#include "PROTO.H"

extern int ROMStart, ROMEnd, ReadStart, ReadEnd;
extern int ProtectedStart, ProtectedEnd, InvalidStart, InvalidEnd;
extern bool ROMMap, ReadMap, ProtectedMap, InvalidMap;
extern int seg7loc, LEDloc, switchLoc, pbLoc;

/**************************** int to_2s_comp () ****************************

   name       : int to_2s_comp (number, size, result)
   parameters : long number : the number to be converted to 2's compliment
                long size : the size of the operation
                long *result : the result of the conversion
   function   : to_2s_comp() converts a number to 2's compliment notation.


****************************************************************************/

int	to_2s_comp (long number, long size, long *result)
{

if (size == LONG_MASK)
	{
	if (number < 0)
		*result = ~number - 1;
	else
		*result = number;
	}
if (size == WORD_MASK)
	{
	if (number < 0)
		*result = (~(number & WORD_MASK) & WORD_MASK) - 1;
	else
		*result = number;
	}
if (size == BYTE_MASK)
	{
	if (number < 0)
		*result = (~(number & BYTE_MASK) & BYTE_MASK) - 1;
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


int	from_2s_comp (long number, long size, long *result)
{

if (size == LONG_MASK)
	{
	if (number & 0x80000000)
		{
		*result = ~number + 1;
		*result = -*result;
		}
	else
		*result = number;
	}
if (size == WORD_MASK)
	{
	if (number & 0x8000)
		{
		*result = (~number + 1) & WORD_MASK;
		*result = -*result;
		}
	else
		*result = number;
	}
if (size == BYTE_MASK)
	{
	if (number & 0x80)
		{
		*result = (~number + 1) & BYTE_MASK;
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

int	sign_extend (int number, long size_from, long *result)
{

	*result = number & size_from;
	if ((size_from == WORD_MASK) && (number & 0x8000))
		*result |= 0xffff0000;
	if ((size_from == BYTE_MASK) && (number & 0x80))
		*result |= 0xff00;

	return SUCCESS;

}




/**************************** int inc_cyc () *******************************

   name       : int inc_cyc (num)
   parameters : int num : number of cycles to increment the cycle counter.
   function   : inc_cyc() increments the machine cycle counter by 'num'.


****************************************************************************/

void inc_cyc (int num)
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

int eff_addr_code (int inst, int start)
{
	int	mode, reg;

	inst = (inst >> start);
        if (start) {            // if checking destination address
          mode = inst & 0x07;
	  reg = (inst >> 3) & 0x07;
        } else {                // else, source address
          reg = inst & 0x07;
	  mode = (inst >> 3) & 0x07;
        }

	if (mode != 7) return (mode);

	switch (reg) {
		case 0x00 : return (7);
		case 0x01 : return (8);
		case 0x02 : return (9);
		case 0x03 : return (10);
		case 0x04 : return (11);
		}

	return 12;

}




/**************************** int a_reg () *********************************

   name       : int a_reg (reg_num)
   parameters : int reg_num : the address register number to be processed
   function   : a_reg() allows both the SSP and USP to act as A[7].  It
                  returns the value '8' if the supervisor bit is set and
                  the reg_num input was '7'.  Otherwise, it returns the
                  reg_num without change.


****************************************************************************/

int a_reg (int reg_num)
{

	if ((reg_num == 7) && (SR & sbit))
		return 8;
	else
		return reg_num;

}


//--------------------------------------------------------------------------
// Check for memory map violations
// Pre: mapt contains map type flags
//      INVALID | PROTECTED | READ | ROM
// Post: initiates bus error if necessary and returns error code

int memoryMapCheck(maptype mapt, int loc, int bytes)
{
  AnsiString str;

  // if hardware access (hardware access always permitted)
  if(( (loc >= seg7loc && loc <= seg7loc+15) ||
         loc == LEDloc || loc == switchLoc || loc == pbLoc) )
    return SUCCESS;

  // if access outside valid 68000 memory map
  if(loc < 0 || loc > MEMSIZE-1){               // if Invalid memory area
    if (exceptions) {
      mem_req (0x8, LONG_MASK, &PC);            // get bus error vector
      exceptionHandler (0, (long) loc, WRITE);
    }else{
      haltSimulator();
      Form1->Message->Lines->Add(str.sprintf
        ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
    }
    return BUS_ERROR;
  }

  // Check for access to areas of memory defined in the Memory Map of the
  // hardware window.

  if(InvalidMap && (mapt & Invalid)) {  // if Invalid map (bus error on access)
    if(loc+bytes-1 >= InvalidStart && loc <= InvalidEnd){ // if Invalid memory area
      if (exceptions) {
        mem_req (0x8, LONG_MASK, &PC);        // get bus error vector
        exceptionHandler (0, (long) loc, WRITE);
      }else{
        haltSimulator();
        Form1->Message->Lines->Add(str.sprintf
          ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
      }
      return BUS_ERROR;
    }
  }

  if(ProtectedMap && (mapt & Protected)) {    // if Protected map (bus error if not supervisor mode)
    if(loc+bytes-1 >= ProtectedStart && loc <= ProtectedEnd){ // if Protected memory area
      if (Form1->regSR->EditText[3] == '0'){    // if not Supervisor mode
        if (exceptions) {
          mem_req (0x8, LONG_MASK, &PC);        // get bus error vector
          exceptionHandler (0, (long) loc, WRITE);
        }else{
          haltSimulator();
          Form1->Message->Lines->Add(str.sprintf
            ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
        }
        return BUS_ERROR;
      }
    }
  }

  if(ReadMap && (mapt & Read)) {           // if Read map (bus error on write)
    if(loc+bytes-1 >= ReadStart && loc <= ReadEnd){ // if Read Only memory area
      if (exceptions) {
        mem_req (0x8, LONG_MASK, &PC);        // get bus error vector
        exceptionHandler (0, (long) loc, WRITE);
      }else{
        haltSimulator();
        Form1->Message->Lines->Add(str.sprintf
          ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
      }
      return BUS_ERROR;
    }
  }

  if(ROMMap && (mapt & Rom)) {    // if ROM map, must be checked last, (writes are ignored)
    if(loc+bytes-1 >= ROMStart && loc <= ROMEnd) // if ROM memory area
      return ROM_MAP;                      // writes are ignored
  }

  return SUCCESS;
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

int mem_put (long data, int loc, long size)
{
  AnsiString str;
  int bytes = 1;
  int code;

  if (size == WORD_MASK)
    bytes = 2;
  else if (size == LONG_MASK)
    bytes = 4;

  // check for odd location reference on word and longword writes
  // if there is a violation, initiate an address exception
  if ((loc % 2 != 0) && (size != BYTE_MASK))
  {
    // generate an address error
    if (exceptions) {
      mem_req (0xc, LONG_MASK, &PC);        // get address error vector
      exceptionHandler (0, (long) loc, WRITE);
    }else{
      haltSimulator();
      Form1->Message->Lines->Add(str.sprintf
        ("Address Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
    }
    return (ADDR_ERROR);
  }

  // CK 10/2009 The upper 8 bits of address are not external to the 68000 so
  // all memory I/O occurs in a 24 bit address map regardless of what the upper
  // 8 bits of the specified address contains.
  loc = loc & ADDRMASK;       // strip upper byte (24 bit address bus on 68000)

  // check memory map
  code = memoryMapCheck(Invalid | Protected | Read | Rom , loc, bytes);
  if (code == BUS_ERROR)        // if bus error caused by memory map
    return code;
  if (code == ROM_MAP)          // if ROM map, writes are ignored
    return SUCCESS;

  // if everything is okay then perform the write according to size
  if (size == BYTE_MASK)
    memory[loc] = data & BYTE_MASK;
  else if (size == WORD_MASK)
  {
    memory[loc] = (data >> 8) & BYTE_MASK;
    memory[loc+1] = data & BYTE_MASK;
  }
  else if (size == LONG_MASK)
  {
    memory[loc] = (data >> 24) & BYTE_MASK;
    memory[loc+1] = (data >> 16) & BYTE_MASK;
    memory[loc+2] = (data >> 8) & BYTE_MASK;
    memory[loc+3] = data & BYTE_MASK;
  }

  writeEA = (long *)&memory[loc];
  bpWrite = true;
  Hardware->updateIfNeeded(loc);        // update hardware display
  MemoryFrm->LivePaint(loc);            // update memory display
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

int mem_req (int loc, long size, long *result)
{
  long	temp;
  AnsiString str;

  /* check for odd location reference on word and longword reads. */
  /* If there is a violation, initiate an address exception */
  if ((loc % 2 != 0) && (size != BYTE_MASK))
  {
    // generate an address error
    if (exceptions) {
      OLD_PC = PC-2;                        //ck 12-16-2005
      mem_req (0xc, LONG_MASK, &PC);        // get address error vector
      exceptionHandler (0, (long) loc, READ);
    }else{
      haltSimulator();
      Form1->Message->Lines->Add(str.sprintf
        ("Address Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
    }
    return (ADDR_ERROR);
  }

  // CK 10/2009 The upper 8 bits of address are not external to the 68000 so
  // all memory I/O occurs in a 24 bit address map regardless of what the upper
  // 8 bits of the specified address contains.
  loc = loc & ADDRMASK;       // strip upper byte (24 bit address bus on 68000)

  // if not hardware access
  if(!( (loc >= seg7loc && loc <= seg7loc+15) ||
         loc == LEDloc || loc == switchLoc || loc == pbLoc) )
  {
    // Check for access to areas of memory defined in the Memory Map of the
    // hardware window.
    if(InvalidMap) {      // bus error on access
      if(loc >= InvalidStart && loc <= InvalidEnd){ // if Invalid memory area
        if (exceptions) {
          mem_req (0x8, LONG_MASK, &PC);        // get bus error vector
          exceptionHandler (0, (long) loc, WRITE);
        }else{
          haltSimulator();
          Form1->Message->Lines->Add(str.sprintf
            ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
        }
        return (BUS_ERROR);
      }
    }

    if(ProtectedMap) {    // bus error if not supervisor mode
      if(loc >= ProtectedStart && loc <= ProtectedEnd){ // if Protected memory area
        if (Form1->regSR->EditText[3] == '0'){    // if not Supervisor mode
          if (exceptions) {
            mem_req (0x8, LONG_MASK, &PC);        // get bus error vector
            exceptionHandler (0, (long) loc, WRITE);
          }else{
            haltSimulator();
            Form1->Message->Lines->Add(str.sprintf
              ("Bus Error: Instruction at %4x accessing address %4x", OLD_PC, loc));
          }
          return (BUS_ERROR);
        }
      }
    }
  }
  /* if everything is okay then perform the read according to size */
  temp = memory[loc] & BYTE_MASK;
  if (size != BYTE_MASK)
  {
    temp = (temp << 8) | (memory[loc + 1] & BYTE_MASK);
    if (size != WORD_MASK)
    {
      temp = (temp << 8) | (memory[loc + 2] & BYTE_MASK);
      temp = (temp << 8) | (memory[loc + 3] & BYTE_MASK);
    }
  }
  *result = temp;

  readEA = (long *)&memory[loc];
  bpRead = true;
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
                  (above) using "WORD_MASK" for the size mask if the simulator
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

int mem_request (long *loc, long size, long *result)
{
	int	req_result;

	if (size == LONG_MASK)
		req_result = mem_req (*loc, LONG_MASK, result);
	else
		req_result = mem_req (*loc, (long) WORD_MASK, result);

	if (size == BYTE_MASK)
		*result = *result & 0xff;

	if (!req_result)
		if (size == LONG_MASK)
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
   void        : Used only in exceptionHandler() in RUN.CPP. Return
                 values are ignored.

   Modified: Chuck Kelly
             Monroe County Community College
             http://www.monroeccc.edu/ckelly

****************************************************************************/

void put (long *dest, long source, long size)
{
//  // if dest is memory
//  if (( (int)dest >= (int)&memory[0]) && ((int)dest <= (int)&memory[MEMSIZE]))
//    mem_put (source, (int) ((int)dest - (int)&memory[0]), size);
//  else          // else dest is register
//    *dest = (source & size) | (*dest & ~size);

  // if dest is register
  if ( ( (int)dest >= (int)&D[0] ) && ( (int)dest < (int)&inst ) )
    *dest = (source & size) | (*dest & ~size);
  else          // else dest is memory
    mem_put (source, (int) ((int)dest - (int)&memory[0]), size);
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


void value_of (long *EA, long *EV, long size)
{
//  // if invalid 68000 address
//  if (((int)EA < (int)&memory[0]) || ((int)EA > (int)&memory[MEMSIZE]))
//    *EV = *EA & size;
//  else
//    mem_req ( (int) ((int)EA - (int)&memory[0]), size, EV);

  // if EA is register
  if ( ( (int)EA >= (int)&D[0] ) && ( (int)EA < (int)&inst ) )
    *EV = *EA & size;
  else          // else EA is memory
    mem_req ( (int) ((int)EA - (int)&memory[0]), size, EV);
}


/**************************** int cc_update() *****************************

   name       : int cc_update (x, n, z, v, c, source, dest, result, sizeMask, shiftCount)
   parameters : int x, n, z, v, c : the codes for actions that should be
                    taken to compute the different condition codes.
                long source : the source operand for the instruction
                long dest : the destination operand for the instruction
                long result : the result of the instruction
                long size : the size in bits of the instruction (8, 16, 32)
                int shiftCount : the shift count for shift and rotate instructions mod 64
                  A shiftCount of 0 is handled in CODE7.CPP
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


int cc_update (int x, int n, int z, int v, int c,
               long source, long dest, long result, long sizeMask, int shiftCount)
{
  int	x_bit, n_bit, z_bit, v_bit, c_bit, mask;
  long	Rm, Dm, Sm;
  long	count, temp1, temp2, size;

  // assign the bits to their variables here
  x_bit = SR & xbit;
  n_bit = SR & nbit;
  z_bit = SR & zbit;
  v_bit = SR & vbit;
  c_bit = SR & cbit;

  source &= sizeMask;
  dest &= sizeMask;
  result &= sizeMask;

  if (sizeMask == BYTE_MASK)
  {
    size = 8;
    Sm = source & 0x0080;
    Rm = result & 0x0080;
    Dm = dest & 0x0080;
  }
  if (sizeMask == WORD_MASK)
  {
    size = 16;
    Sm = source & 0x8000;
    Rm = result & 0x8000;
    Dm = dest & 0x8000;
  }
  if (sizeMask == LONG_MASK)
  {
    size = 32;
    Sm = source & 0x80000000;
    Rm = result & 0x80000000;
    Dm = dest & 0x80000000;
  }

  // calculate each of the five condition codes according to the requested
  // method of calculation
  switch (n) {
    case N_A : break; 		 // n_bit not affected
    case ZER : n_bit = 0;
      break;
    case GEN : n_bit = (Rm) ? true : false;
      break;
    case UND : n_bit = !n_bit;	 // undefined result
      break;
  }
  switch (z) {
    case N_A : break;		 // z_bit not affected
    case UND : z_bit = !z_bit;	 // z_bit undefined
      break;
    case GEN : z_bit = (result == 0) ? true : false;
      break;
    case CASE_1 : z_bit = (z_bit && (result == 0)) ? true : false;
      break;
  }
  switch (v) {
    case N_A :  break;		 // v_bit not affected
    case ZER :  v_bit = 0;
      break;
    case UND :  v_bit = !v_bit;	 // v_bit not defined
      break;
    case CASE_1 : v_bit = ((Sm && Dm && !Rm) || (!Sm && !Dm && Rm)) ? true : false;
      break;
    case CASE_2 : v_bit = ((!Sm && Dm && !Rm) || (Sm && !Dm && Rm)) ? true : false;
      break;
    case CASE_3 : v_bit = (Dm && Rm) ? true : false;
      break;
    case CASE_4 : mask = (~((unsigned)sizeMask >> shiftCount+1)) & sizeMask;  // ASL v bit  //CK 10-11-2007
      if (shiftCount > (size-1) & source)       // CK 1-25-2008
        v_bit = true;
      else
        v_bit = (((mask & source) == 0) || ((mask & ~source) == 0)) ? false : true;
      break;
    }
  switch (c) {
    case N_A :  break;          // c_bit not affected
    case UND :  c_bit = !c_bit; // c_bit undefined
      break;
    case ZER :  c_bit = 0;
      break;
    case CASE_1 : c_bit = x_bit; // shiftCount was 0 for ROXL or ROXR
      break;
    case CASE_2 :               // ROR, ROXR   CK 5-2015
      if(shiftCount > size)
        shiftCount %= size;
        if(shiftCount == 0)
          shiftCount = size;
      c_bit = ((dest >> (shiftCount-1)) & 1) ? true : false;
      break;
    case CASE_3 :               // ROL         CK 3-2013
      shiftCount %= size;       // shift count MOD size
      if(shiftCount == 0)
        c_bit = (dest & 1) ? true : false;
      else
        c_bit = ((dest >> (size-shiftCount)) & 1) ? true : false;
      break;
    case CASE_4 :
      c_bit = (Dm || Rm) ? true : false;
      break;
    case CASE_5 :
      c_bit = ((Sm && Dm) || (!Rm && Dm) || (Sm && !Rm)) ? true : false;
      break;
    case CASE_6 :
      c_bit = ((Sm && !Dm) || (Rm && !Dm) || (Sm && Rm)) ? true : false;
      break;
    case CASE_7 :                // ASR CK 5-2015
      if (shiftCount > size)
        shiftCount = size;
      c_bit = ((dest >> (shiftCount-1)) & 1) ? true : false;
      break;
    case CASE_8 :               // LSR CK 5-2015
      if (shiftCount > size)    // if shift count > size
        c_bit = false;
      else
        c_bit = ((dest >> (shiftCount-1)) & 1) ? true : false;
      break;
    case CASE_9 :               // ASL, LSL CK 5-2015
      if (shiftCount > size)    // if shift count > size
        c_bit = false;
      else
        c_bit = ((dest >> (size-shiftCount)) & 1) ? true : false;
      break;
  }
  switch (x) {
    case N_A : break;     	// X condition code not affected
    case GEN : x_bit = c_bit;	// general case
      break;
  }

  // set SR according to results
  SR = SR & 0xffe0;		 // clear the condition codes
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

                  ck 4-8-2002 fixed bug with COND_HI
                  ck 4-26-2002 fixed bug with COND_GT, COND_VS
****************************************************************************/


int check_condition (int condition)
{
int	result;

result = false;
switch (condition)
	{
	case COND_T : result = 1;				/* true */
		   break;
	case COND_F : result = 0;				/* false */
		   break;
	case COND_HI : result = !(SR & cbit) && !(SR & zbit);	/* high */
		   break;
	case COND_LS : result = (SR & cbit) || (SR & zbit);	/* low or same */
		   break;
	case COND_CC : result = !(SR & cbit);		/* carry clear */
		   break;
	case COND_CS : result = (SR & cbit);		/* carry set */
		   break;
	case COND_NE : result = !(SR & zbit);		/* not equal */
		   break;
	case COND_EQ : result = (SR & zbit);		/* equal */
		   break;
	case COND_VC : result = !(SR & vbit);		/* overflow clear */
		   break;
	case COND_VS : result = (SR & vbit);		/* overflow set */
		   break;
	case COND_PL : result = !(SR & nbit);		/* plus */
		   break;
	case COND_MI : result = (SR & nbit);                /* minus */
		   break;
	case COND_GE : result = ((SR & nbit) && (SR & vbit)) ||
          (!(SR & nbit) && !(SR & vbit));          /* greater or equal */
		   break;
	case COND_LT : result = ((SR & nbit) && !(SR & vbit))    /* less than */
          || (!(SR & nbit) && (SR & vbit));
		   break;
	case COND_GT : result = ((SR & nbit) && (SR & vbit) && !(SR & zbit))
          || (!(SR & nbit) && !(SR & vbit) && !(SR & zbit)); /* greater than */
		   break;
	case COND_LE : result = ((SR & nbit) && !(SR & vbit))    /* less or equal */
          || (!(SR & nbit) && (SR & vbit)) || (SR & zbit);
			break;
	}
return result;

}

// convert little endian to big endian and vice versa
/*
inline uint flip(uint *n)
{
  const byte *b = (byte *) n;
  return b[0]<<24 | b[1]<<16 | b[2]<<8 | b[3];
}

inline uint flip(uint &n)
{
  return flip(&n);
}
*/
ushort flip(ushort *n)
{
  const byte *b = (byte *) n;
  return b[0]<<8 | b[1];
}

ushort flip(ushort &n)
{
  return flip(&n);
}

