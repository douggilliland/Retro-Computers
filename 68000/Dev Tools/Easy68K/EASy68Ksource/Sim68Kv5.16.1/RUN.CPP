
/***************************** 68000 SIMULATOR ****************************

File Name: RUN.C

This file contains various routines to run a 68000 instruction.  These
routines are :

	decode_size(), eff_addr(), runprog(), exec_inst(), exception()

   Modified by: Charles Kelly
                www.easy68k.com

***************************************************************************/



#include <stdio.h>
#include <stdlib.h>
#include "extern.h"        		// global declarations
#include "opcodes.h"       		// opcode masks for decoding
#include "SIM68Ku.h"
#include "simIOu.h"
#include "hardwareu.h"
#include "logU.h"


extern char buffer[256];  //used to form messages for display in window
extern AnsiString str;
bool trace_bit = false;

/**************************** int decode_size() ****************************

   name       : int decode_size (result)
   parameters : long *result : the appropriate mask for the decoded size
   function   : decodes the size field in the instruction being processed
                  and returns a mask to be used in instruction execution.
                  For example, if the size field was "01" then the mask
                  returned is WORD_MASK.

****************************************************************************/


int decode_size (long *result)
{
	int	bits;

	/* the size field is always in bits 6 and 7 of the instruction word */
	bits = (inst >> 6) & 0x0003;

	switch (bits) {
		case 0 : *result = BYTE_MASK;
			 break;
		case 1 : *result = WORD_MASK;
			 break;
		case 2 : *result = LONG_MASK;
			 break;
		default : *result = 0;
		}

	if (*result != 0)       // ck 1-06-2006
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


int eff_addr (long size, int mask, int add_times)
{
  bool  legal = false;
  int	error = SUCCESS, mode, reg, addr, move_operation;
  int	bwinc, linc;
  long	ext, temp_ext, inc_size, ind_reg, *value, disp;

  if (( ((inst & 0xf000) == 0x1000) ||
        ((inst & 0xf000) == 0x2000) ||
        ((inst & 0xf000) == 0x3000)
      ) && (mask == DATA_ALT_ADDR) )
    move_operation = true;    // move destination address
  else
    move_operation = false;   // other effective address or move source address

  if (move_operation)
    addr = (inst >> 6) & 0x003f;
  else
    addr = inst & 0x003f;
  bwinc = linc = 0;
  if (move_operation) {		// reg and mode are reversed in MOVE dest EA
    reg = (addr & MODE_MASK) >> 3;
    mode = addr & REG_MASK;
  } else {
    mode = (addr & MODE_MASK) >> 3;
    reg = addr & REG_MASK;
  }

  switch (mode) {               // switch on effective address mode
    case 0 :                                    // Dn
      if (mask & bit_1) {
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = &D[reg];
          value_of (EA2, &EV2, size);
        } else {
          EA1 = &D[reg];
          value_of (EA1, &EV1, size);
        }
        bwinc = linc = 0;
	legal = true;
      }
      break;
    case 1 :                                    // An
      if (mask & bit_2 && size != BYTE_MASK) {
	reg = a_reg(reg);
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = &A[reg];
          value_of (EA2, &EV2, size);
        } else {
          EA1 = &A[reg];
          value_of (EA1, &EV1, size);
        }
	bwinc = linc = 0;
	legal = true;
      }
      break;
    case 2 :                                    // [An]
      if (mask & bit_3) {
	reg = a_reg(reg);
	//value = (long *) &memory[A[reg]];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV2);
        } else {
          EA1 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV1);
        }
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 3 :                                    // [An]+
      if (mask & bit_4) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = a_reg(reg);               // set reg to 8 if Supervisor Stack
	//value = (long *) &memory[A[reg]];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV2);
        } else {
          EA1 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV1);
        }
	A[reg] = A[reg] + inc_size;
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 4 :                                    // -[An]
      if (mask & bit_5) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = a_reg(reg);                  // set reg to 8 if Supervisor Stack
	A[reg] = A[reg] - inc_size;
	//value = (long *) &memory[A[reg]];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV2);
        } else {
          EA1 = (long *) &memory[A[reg] & ADDRMASK];
          error = mem_req(A[reg], size, &EV1);
        }
	bwinc = 6;
	linc = 10;
        legal = true;
      }
      break;
    case 5 :                                    // d[An]
      if (mask & bit_6)	{
	reg = a_reg(reg);
	mem_request (&PC, (long) WORD_MASK, &ext);
	from_2s_comp (ext, (long) WORD_MASK, &ext);
	//value = (long *) &memory[A[reg] + ext];
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = (long *) &memory[(A[reg] + ext) & ADDRMASK];
          error = mem_req(A[reg] + ext, size, &EV2);
        } else {
          EA1 = (long *) &memory[(A[reg] + ext) & ADDRMASK];
          error = mem_req(A[reg] + ext, size, &EV1);
        }
	bwinc = 8;
	linc = 12;
	legal = true;
      }
      break;
    case 6 :                                    // d[An, Xi]
      if (mask & bit_7) {
	reg = a_reg(reg);
	// fetch extension word
	mem_request (&PC, (long) WORD_MASK, &ext);
	disp = ext & 0xff;
	sign_extend (disp, BYTE_MASK, &disp);
	from_2s_comp (disp, (long) WORD_MASK, &disp);
	// get index register value
	if (ext & 0x8000)
	  ind_reg = A[a_reg((ext & 0x7000) >> 12)];
	else
	  ind_reg = D[(ext & 0x7000) >> 12];
	// get correct length for index register
	if (!(ext & 0x0800)) {
	  sign_extend (ind_reg, WORD_MASK, &ind_reg);
	  from_2s_comp (ind_reg, (long) LONG_MASK, &ind_reg);
	}
	//value = (long *) (&memory[A[reg] + disp + ind_reg]);
        if (move_operation) { // choose EA2 in case of MOVE dest effective address
          EA2 = (long *) &memory[(A[reg] + disp + ind_reg) & ADDRMASK];
          error = mem_req(A[reg] + disp + ind_reg, size, &EV2);
        } else {
          EA1 = (long *) &memory[(A[reg] + disp + ind_reg) & ADDRMASK];
          error = mem_req(A[reg] + disp + ind_reg, size, &EV1);
        }
	bwinc = 10;
	linc = 14;
	legal = true;
      }
      break;
    case 7 :                    // Abs.W  Abs.L  d[PC]  d[PC, Xi]
      switch (reg) {
	case 0 :                                // Abs.W
          if (mask & bit_8) {
	    mem_request (&PC, (long) WORD_MASK, &ext);  // get address from instruction
            if (ext >= 0x8000)          // if address is negative word  ck 1-11-2008
              ext = 0xFFFF0000 | ext;   // sign extend (corrected ck 6-23-2009)
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              EA2 = (long *) &memory[ext & ADDRMASK];              // get effective address
              error = mem_req(ext, size, &EV2);         // read data
            } else {
              EA1 = (long *) &memory[ext & ADDRMASK];
              error = mem_req(ext, size, &EV1);
            }
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 1 :                                // Abs.L
          if (mask & bit_9) {
	    mem_request (&PC, LONG_MASK, &ext);         //ck 8-23-02 WORD_MASK TO LONG
	    //mem_request (&PC, LONG_MASK, &temp_ext);  //ck
	    //ext = ext * 0xffff + temp_ext;            //ck
	    //value = (long *) &memory[ext & ADDRMASK];
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              EA2 = (long *) &memory[ext & ADDRMASK];
              error = mem_req(ext, size, &EV2);
            } else {
              EA1 = (long *) &memory[ext & ADDRMASK];
              error = mem_req(ext, size, &EV1);
            }
            bwinc = 12;
	    linc = 16;
	    legal = true;
	  }
	  break;
	case 2 :                                // d[PC]
          if (mask & bit_10) {
	    mem_request (&PC, (long) WORD_MASK, &ext);
	    from_2s_comp (ext, (long) WORD_MASK, &ext);
	    //value = (long *) &memory[PC + ext - 2];
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              EA2 = (long *) &memory[(PC + ext - 2) & ADDRMASK];
              error = mem_req(PC + ext - 2, size, &EV2);
            } else {
              EA1 = (long *) &memory[(PC + ext - 2) & ADDRMASK];
              error = mem_req(PC + ext - 2, size, &EV1);
            }
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 3 :                                // d[PC, Xi]
          if (mask & bit_11) {
	    // fetch extension word
	    mem_request (&PC, (long) WORD_MASK, &ext);
	    disp = ext & 0xff;
	    sign_extend (disp, BYTE_MASK, &disp);
	    from_2s_comp (disp, (long) WORD_MASK, &disp);
	    // get index register value
	    if (ext & 0x8000)
	      ind_reg = A[a_reg((ext & 0x7000) >> 12)];
	    else
	      ind_reg = D[(ext & 0x7000) >> 12];
	    // get correct length for index register
	    if (!(ext & 0x0800)) {
	      sign_extend (ind_reg, WORD_MASK, &ind_reg);
	      from_2s_comp (ind_reg, (long) LONG_MASK, &ind_reg);
	    }
	    ext = ext & 0x00ff;
	    //value = (long *) (&memory[PC - 2 + disp + ind_reg]);
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              EA2 = (long *) &memory[(PC - 2 + disp + ind_reg) & ADDRMASK];
              error = mem_req(PC - 2 + disp + ind_reg, size, &EV2);
            } else {
              EA1 = (long *) &memory[(PC - 2 + disp + ind_reg) & ADDRMASK];
              error = mem_req(PC - 2 + disp + ind_reg, size, &EV1);
            }
	    bwinc = 10;
	    linc = 14;
	    legal = true;
	  }
	  break;
	case 4 :                                // Imm
          if (mask & bit_12) {
	    if ((size == BYTE_MASK) || (size == WORD_MASK))
	      mem_request (&PC, (long) WORD_MASK, &ext);
	    else
	      mem_request (&PC, LONG_MASK, &ext);
	    global_temp = ext;
	    //value = &global_temp;
            if (move_operation) { // choose EA2 in case of MOVE dest effective address
              EA2 = (long *) &global_temp;
              value_of (EA2, &EV2, size);
            } else {
              EA1 = (long *) &global_temp;
              value_of (EA1, &EV1, size);
            }
	    bwinc = 4;
	    linc = 8;
	    legal = true;
	  }
	  break;
      }
      break;
  }   	  // switch

  if (legal) {          // if legal instruction
    if (add_times) {
      if (size != LONG_MASK)
	    inc_cyc (bwinc);
      else
	    inc_cyc (linc);
    }
    //if (error == SUCCESS) { // if NO error occurred executing a legal instruction
      //if (move_operation) { // choose EA2 in case of MOVE dest effective address
        //EA2 = value;
        //value_of (EA2, &EV2, size);
      //} else {
        //EA1 = value;
        //value_of (EA1, &EV1, size);
      //}
    //}
  } else
    return BAD_INST;    // ILLEGAL instruction
  return error;         // return error code

}

/**************************** int eff_addr_noread() ***************************
   Same as eff_addr above but does not read from address. Used by LEA & PEA

   name       : int eff_addr_noread (size, mask, add_times)
   parameters : long size : the appropriate size mask
                int mask : the effective address modes mask to be used
                int add_times : tells whether to increment the cycle counter
                      (there are times when we don't want to)
   description: decodes the effective address field in the current
                  instruction, returns a pointer to the effective address
                  either in EA1 or EA2.

****************************************************************************/


int eff_addr_noread (long size, int mask, int add_times)
{
  int	mode, reg, legal, addr, move_operation;
  int	bwinc, linc;
  long	ext, temp_ext, inc_size, ind_reg, *value, disp;

  if (( ((inst & 0xf000) == 0x1000) ||
        ((inst & 0xf000) == 0x2000) ||
        ((inst & 0xf000) == 0x3000)
      ) && (mask == DATA_ALT_ADDR) )
    move_operation = true;
  else
    move_operation = false;

  if (move_operation)
    addr = (inst >> 6) & 0x003f;
  else
    addr = inst & 0x003f;
  legal = false;
  bwinc = linc = 0;
  if (move_operation) {		/* reg and mode are reversed in MOVE dest EA */
    reg = (addr & MODE_MASK) >> 3;
    mode = addr & REG_MASK;
  } else {
    mode = (addr & MODE_MASK) >> 3;
    reg = addr & REG_MASK;
  }

  switch (mode) {               // switch on effective address mode
    case 0 :                                    // Dn
      if (mask & bit_1) {
        value = &D[reg];
        bwinc = linc = 0;
	legal = true;
      }
      break;
    case 1 :                                    // An
      if (mask & bit_2) {
	reg = a_reg(reg);
	value = &A[reg];
	bwinc = linc = 0;
	legal = true;
      }
      break;
    case 2 :                                    // [An]
      if (mask & bit_3) {
	reg = a_reg(reg);
	value = (long *) &memory[A[reg] & ADDRMASK];
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 3 :                                    // [An]+
      if (mask & bit_4) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = a_reg(reg);               // set reg to 8 if Supervisor Stack
	value = (long *) &memory[A[reg] & ADDRMASK];
	A[reg] = A[reg] + inc_size;
	bwinc = 4;
	linc = 8;
	legal = true;
      }
      break;
    case 4 :                                    // -[An]
      if (mask & bit_5) {
	if (size == BYTE_MASK)
          if (reg == 7)                    // if stack operation on byte
            inc_size = 2;                  // force even address  ck 4-19-2002
          else
	    inc_size = 1;
	else if (size == WORD_MASK)
	  inc_size = 2;
	else
          inc_size = 4;
	reg = a_reg(reg);                  // set reg to 8 if Supervisor Stack
	A[reg] = A[reg] - inc_size;
	value = (long *) &memory[A[reg] & ADDRMASK];
	bwinc = 6;
	linc = 10;
	legal = true;
      }
      break;
    case 5 :                                    // d[An]
      if (mask & bit_6)	{
	reg = a_reg(reg);
	mem_request (&PC, (long) WORD_MASK, &ext);
	from_2s_comp (ext, (long) WORD_MASK, &ext);
	value = (long *) &memory[(A[reg] + ext) & ADDRMASK];
	bwinc = 8;
	linc = 12;
	legal = true;
      }
      break;
    case 6 :                                    // d[An, Xi]
      if (mask & bit_7) {
	reg = a_reg(reg);
	// fetch extension word
	mem_request (&PC, (long) WORD_MASK, &ext);
	disp = ext & 0xff;
	sign_extend (disp, BYTE_MASK, &disp);
	from_2s_comp (disp, (long) WORD_MASK, &disp);
	// get index register value
	if (ext & 0x8000)
	  ind_reg = A[a_reg((ext & 0x7000) >> 12)];
	else
	  ind_reg = D[(ext & 0x7000) >> 12];
	// get correct length for index register
	if (!(ext & 0x0800)) {
	  sign_extend (ind_reg, WORD_MASK, &ind_reg);
	  from_2s_comp (ind_reg, (long) LONG_MASK, &ind_reg);
	}
	value = (long *) (&memory[(A[reg] + disp + ind_reg) & ADDRMASK]);
	bwinc = 10;
	linc = 14;
	legal = true;
      }
      break;
    case 7 :                    // Abs.W  Abs.L  d[PC]  d[PC, Xi]
      switch (reg) {
	case 0 :                                // Abs.W
          if (mask & bit_8) {
	    mem_request (&PC, (long) WORD_MASK, &ext);
	    value = (long *) &memory[ext & ADDRMASK];
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 1 :                                // Abs.L
          if (mask & bit_9) {
	    mem_request (&PC, LONG_MASK, &ext);         //ck 8-23-02 WORD_MASK TO LONG
	    //mem_request (&PC, LONG_MASK, &temp_ext);  //ck
	    //ext = ext * 0xffff + temp_ext;            //ck
	    //value = (long *) &memory[ext & ADDRMASK]; //ck 2-21-03
	    value = (long *) &memory[ext & ADDRMASK];
            bwinc = 12;
	    linc = 16;
	    legal = true;
	  }
	  break;
	case 2 :                                // d[PC]
          if (mask & bit_10) {
	    mem_request (&PC, (long) WORD_MASK, &ext);
	    from_2s_comp (ext, (long) WORD_MASK, &ext);
	    value = (long *) &memory[(PC + ext - 2) & ADDRMASK];
	    bwinc = 8;
	    linc = 12;
	    legal = true;
	  }
	  break;
	case 3 :                                // d[PC, Xi]
          if (mask & bit_11) {
	    // fetch extension word
	    mem_request (&PC, (long) WORD_MASK, &ext);
	    disp = ext & 0xff;
	    sign_extend (disp, BYTE_MASK, &disp);
	    from_2s_comp (disp, (long) WORD_MASK, &disp);
	    // get index register value
	    if (ext & 0x8000)
	      ind_reg = A[a_reg((ext & 0x7000) >> 12)];
	    else
	      ind_reg = D[(ext & 0x7000) >> 12];
	    // get correct length for index register
	    if (!(ext & 0x0800)) {
	      sign_extend (ind_reg, WORD_MASK, &ind_reg);
	      from_2s_comp (ind_reg, (long) LONG_MASK, &ind_reg);
	    }
	    ext = ext & 0x00ff;
	    value = (long *) (&memory[(PC - 2 + disp + ind_reg) & ADDRMASK]);
	    bwinc = 10;
	    linc = 14;
	    legal = true;
	  }
	  break;
	case 4 :                                // Imm
          if (mask & bit_12) {
	    if ((size == BYTE_MASK) || (size == WORD_MASK))
	      mem_request (&PC, (long) WORD_MASK, &ext);
	    else
	      mem_request (&PC, LONG_MASK, &ext);
	    global_temp = ext;
	    value = &global_temp;
	    bwinc = 4;
	    linc = 8;
	    legal = true;
	  }
	  break;
      }
      break;
  }   	  // switch

  if (legal) {
    if (add_times) {
      if (size != LONG_MASK)
	inc_cyc (bwinc);
      else
	inc_cyc (linc);
    }
    if (move_operation) { // choose EA2 in case of MOVE dest effective address
      EA2 = value;
    } else {
      EA1 = value;
    }
    return SUCCESS;
  }
  else
    return FAILURE;       // return FAILURE if illegal addressing mode

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
  int i;
  char ch, *pc_str;

  halt = false;
  exec_inst();          // execute an instruction

  do {
    Application->ProcessMessages();
    if(inputMode)
      Sleep(10);        // don't hog the CPU while waiting for input
  } while (inputMode && runMode);

  if (errflg) {        // if illegal opcode in program initiate an exception
    halt = true;               // force halt
    Form1->Message->Lines->Add("Address or Bus error during exception processing. Execution halted");
  }

  // simple breakpoints
  for (i = 0; i < bpoints; i++) {
    if (PC == brkpt[i])
    {
      Form1->Message->Lines->Add(str.sprintf("break point at %04x", PC));
      trace = true;             // force trace mode
      Form1->AutoTraceTimer->Enabled = false;
      //Form1->SetFocus();        // bring Form1 to top
    }
  }

  // if run to cursor address reached
  if (PC == runToAddr) {
    trace = true;             // force trace mode
    Form1->AutoTraceTimer->Enabled = false;
    runToAddr = 0;
  }

  // advanced breakpoints
  for(i = 0; i < exprCount; i++) {
    // Evaluate isBreak() for all expressions
    //if(true) {
    if(bpExpressions[i].isBreak()) {
      Form1->Message->Lines->Add(str.sprintf("break point at %04x", PC));
      trace = true;             // force trace mode
      Form1->AutoTraceTimer->Enabled = false;
      //Form1->SetFocus();        // bring Form1 to top
    }
  }

  if (sstep) {                  // if "Step Over" mode
    if (PC == stepToAddr) {     // if step address reached
      trace = true;             // force trace mode
      stepToAddr = 0;           // reset for next use
      //Form1->SetFocus();        // bring Form1 to top
    }
  }

  OLD_PC = PC;	// update the OLD_PC

  if (trace || halt) {
    runMode = false;            // stop running if enabled
    if (!stopInstruction)
      Hardware->autoIRQoff(); // turn off auto interrupt timers unless STOP instruction ck 1-11-2008
    if (simIO->fullScreen && Form1->Monitor->MonitorNum == FullScreenMonitor) {
      simIO->fullScreen = false;
      simIO->setupWindow();
    }
    scrshow();              // if trace is on then update the screen

    if (halt)
      Form1->setMenuTrace();    // set menu and toolbar to disable debug commands
    else {
      Form1->setMenuActive();   // enable debug commands
      //Hardware->enable();
    }

    if (trace) {
      if (!inputMode)           // if not doing user input
        Form1->SetFocus();      //   bring Form1 to top
    }
  }

  return 0;
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
  static int start, finish, exec_result, i, intMask;
  static long temp;

  // Reset read and write flags so when breakpoints are tested for read/write
  // access, we know if this instruction caused a respective read/write.
  bpRead = false;
  bpWrite = false;

  try {

    // if previous instruction caused bus or address error
    if (exec_result == ADDR_ERROR || exec_result == BUS_ERROR)
      errflg = true;            // default to halt simulator
    exec_result = mem_request (&PC, (long) WORD_MASK, (long *)&inst);
    if ( !(exec_result) )
    {
      start = offsets[(inst & FIRST_FOUR) >> 12];
      finish = offsets[((inst & FIRST_FOUR) >> 12) + 1] - 1;

      for (i = start; i <= finish || exec_result == BAD_INST; i++)  // for all offsets
      {
        if( (exec_result == BAD_INST) || ((inst & ~inst_arr[i].mask) == inst_arr[i].val) )
        {
          if (trace) {
            mem_req (PC, (long) WORD_MASK, &temp);
            if(inst == 0xFFFF && temp == 0xFFFF)  // if SIMHALT command
              sprintf(buffer,"PC=%08X  Code=%04X  SIMHALT", PC-2, inst);
            else
              sprintf(buffer,"PC=%08X  Code=%04X  %s", PC-2, inst, inst_arr[i].name);
            Form1->Message->Lines->Add(buffer);

            if (logging)
            {
              // ----- if logging memory -----
              if (ElogFlag == INST_REG_MEM) {     // if logging memory
                int addr = logMemAddr;            // address to log
                int nRows = logMemBytes/16;       // how many rows to log

                fprintf(ElogFile,"\n");           // blank line
                // display memory by rows of 16 bytes
                for (int r=0; r<nRows; r++) {
                  if (addr < 0 || addr >= MEMSIZE)    // if invalid address
                    fprintf(ElogFile,"%08X: Invalid Address",addr);
                  else                                // valid address
                    fprintf(ElogFile,"%08X: ",addr);
                  // display 16 hex bytes of memory
                  for (int i=0; i<16; i++) {
                    if (addr+i >= MEMSIZE)            // if invalid address
                      fprintf(ElogFile,"xx ");        // is this necessary?
                    else
                      fprintf(ElogFile,"%02hX ",(unsigned char)memory[(addr+i) & ADDRMASK]);
                  }
                  // display 16 bytes as ASCII
                  for (int i=0; i<16; i++) {
                    if (addr+i >= MEMSIZE)            // if invalid address
                      fprintf(ElogFile,"-");          // is this necessary?
                    else {
                      if (memory[(addr+i) & ADDRMASK] >= ' ')    // if displayable char
                        fprintf(ElogFile,"%hc",memory[(addr+i) & ADDRMASK]);
                      else
                        fprintf(ElogFile,"-");
                    }
                  }
                  addr += 16;
                  fprintf(ElogFile,"\n");         // new line
                }
              }

              // ----- if logging registers -----
              if (ElogFlag == REGISTERS || ElogFlag == INST_REG_MEM) {
                fprintf(ElogFile,"\n");
                // output registers to log file
                fprintf(ElogFile,"D0=%08lX D4=%08lX A0=%08lX A4=%08lX    T_S__INT___XNZVC\n",
                                  D[0],D[4],A[0],A[4]);
                fprintf(ElogFile,"D1=%08lX D5=%08lX A1=%08lX A5=%08lX SR=",
                                  D[1],D[5],A[1],A[5]);
                for (int j=0; j<16; j++) {        // display each bit of SR
                  if ((0x8000 >> j) & SR)
                    fprintf(ElogFile,"1");
                  else
                    fprintf(ElogFile,"0");
                }
                fprintf(ElogFile,"\nD2=%08lX D6=%08lX A2=%08lX A6=%08lX US=%08lX\n",
                                  D[2],D[6],A[2],A[6],A[7]);
                fprintf(ElogFile,"D3=%08lX D7=%08lX A3=%08lX A7=%08lX SS=%08lX\n",
                                  D[3],D[7],A[3],A[a_reg(7)],A[8]);
              }

              // ----- if logging instruction -----
              if (ElogFlag) {
                if(Form1->lineToLog() == false) {  // output instruction to log file
                  fprintf(ElogFile, buffer); // if source not present output limited info
                  fprintf(ElogFile, "\n");
                }
                fflush(ElogFile);                  // write all bufferred data to file
              }
            } // end if logging
          }

          if (SR & tbit)                        // if trace bit set
            trace_bit = true;
          else
            trace_bit = false;

          if(exec_result != BAD_INST)
            exec_result = (*(names[i]))();        // run the 68000 instruction

          // if previous instruction caused address or bus error but this one did not
          if (errflg && (exec_result != ADDR_ERROR && exec_result != BUS_ERROR))
            errflg = false;                     // don't halt the simulator

          //-------------------------------------------------------------------
          //------------------------ EXCEPTION PROCESSING ---------------------
          //-------------------------------------------------------------------
          if (exceptions)               // if exception processing enabled
          {
            OLD_PC = PC;                //ck 2.9.2

            switch (exec_result)        // these results prevent trace exception
            {
              case BAD_INST : inc_cyc (34);	// Illegal instruction
                OLD_PC -= 2;                    // ck 12-16-2005
                mem_req (0x10, LONG_MASK, &PC);
                exceptionHandler (1, 0, READ);
                break;
              case NO_PRIVILEGE : inc_cyc (34); // Privileged violation
                mem_req (0x20, LONG_MASK, &PC);
                exceptionHandler (1, 0, READ);
                break;
            }
            intMask = 0xFF80 >> (7 - ((SR & intmsk) >> 8)) | 0x40;
            if ( irq & intMask)         // if IRQ
              irqHandler();             // process IRQ

            if (trace_bit)      // if trace exception enabled
            {
              inc_cyc (34);
              mem_req (0x24, LONG_MASK, &PC);
              exceptionHandler (2, 0, READ);
              OLD_PC = PC;              //ck 2.9.2
            }
            switch (exec_result)        // these results do not prevent trace exception
            {
              case SUCCESS  : break;
              case STOP_TRAP : 	        // STOP instruction
                //trace = true;
                Form1->AutoTraceTimer->Enabled = false;
                halt = true;
                if (stopInstruction == false) {
                  stopInstruction = true;
                  Form1->Message->Lines->Add("STOP instruction. Execution halted");
                  Form1->SetFocus();    // bring Form1 to top
                  scrshow();            // update the screen
                }
                break;
              case TRAP_TRAP : inc_cyc (38);
                mem_req (128 + (inst & 0x0f) * 4, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case DIV_BY_ZERO : inc_cyc (42);
                mem_req (0x14, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case CHK_EXCEPTION : inc_cyc (44);
                mem_req (0x18, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case TRAPV_TRAP : inc_cyc (34);
                mem_req (0x1C, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case TRACE_EXCEPTION : inc_cyc(34);
                mem_req(0x24, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case LINE_1010 : inc_cyc(34);
                mem_req (0x28, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
              case LINE_1111 : inc_cyc(34);
                mem_req (0x2C, LONG_MASK, &PC);
                exceptionHandler (2, 0, READ);
                break;
            }
          }
          else        // exception processing not enabled
          {
            switch (exec_result)
            {
              case SUCCESS  : break;
              case BAD_INST : halt = true;	// halt the program
                Form1->Message->Lines->Add(str.sprintf
                    ("Illegal instruction found at location %4x. Execution halted", OLD_PC));
                break;
              case NO_PRIVILEGE : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("supervisor privilege violation at location %4x. Execution halted", OLD_PC));
                break;
              case CHK_EXCEPTION : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("CHK exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case STOP_TRAP : halt = true;
                Form1->AutoTraceTimer->Enabled = false;
                Form1->Message->Lines->Add(str.sprintf
                    ("STOP instruction executed at location %4x. Execution halted", OLD_PC));
                Log->stopLogWithAnnounce();
                Form1->SetFocus();    // bring Form1 to top
                scrshow();            // update the screen
                Hardware->disable();
                break;
              case TRAP_TRAP : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("TRAP exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case TRAPV_TRAP : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("TRAPV exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case DIV_BY_ZERO : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Divide by zero occurred at location %4x. Execution halted", OLD_PC));
                break;
              case ADDR_ERROR : halt = true;
                Form1->Message->Lines->Add("Execution halted");
                break;
              case BUS_ERROR : halt = true;
                Form1->Message->Lines->Add("Execution halted");
                break;
              case TRACE_EXCEPTION : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Trace exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case LINE_1010 : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Line 1010 Emulator exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              case LINE_1111 : halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Line 1111 Emulator exception occurred at location %4x. Execution halted", OLD_PC));
                break;
              default: halt = true;
                Form1->Message->Lines->Add(str.sprintf
                    ("Unknown execution error %4x occurred at location %4x. Execution halted", exec_result, OLD_PC));
            }

            if (SR & tbit)
            {
              halt = true;
              Form1->Message->Lines->Add(str.sprintf
                  ("TRACE exception occurred at location %4x. Execution halted", OLD_PC));
            }
          }
          break;        // break out of for loop
        }
        if(i == finish)
          exec_result = BAD_INST;
      } // end for

    } // end if
  } catch( ... ) {
    Form1->AutoTraceTimer->Enabled = false;
    sprintf(buffer, "ERROR: An exception occurred in routine 'exec_inst'.\nPC=%08X  Code=%04X", PC-2, inst);
    Application->MessageBox(buffer, "Error", MB_OK);
    trace = true;       // stop running programs
    sstep = false;
  }

  return 0;
}





/**************************** int exceptionHandler () *****************************

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

void exceptionHandler(int clas, long loc, int r_w)
{
  int	infoWord;
  AnsiString str;

  // if SSP on odd address OR outside memory range
  if ( (A[8] % 2) || (A[8] < 0) || ((unsigned int)A[8] > MEMSIZE) ){
    Form1->AutoTraceTimer->Enabled = false;
    Form1->Message->Lines->Add(str.sprintf
          ("Error during Exception Handler: SSP odd or outside memory space "));
    Form1->Message->Lines->Add(str.sprintf ("at location %4x", A[8]));
    trace = true;       // stop running programs
    sstep = false;
    return;
  }
  if ( (clas == 1) || (clas == 2)) {
    A[8] -= 4;		/* create the stack frame for class 1 and 2 exceptions */
    put ((long *)&memory[A[8] & ADDRMASK], OLD_PC, LONG_MASK);
    A[8] -= 2;
    put ((long *)&memory[A[8] & ADDRMASK], (long) SR, (long) WORD_MASK);
  } else {			/* class 0 exception (address or bus error) */
    inc_cyc (50);         /* fifty clock cycles for the address or bus exception */
    A[8] -= 4;		/* now create the exception stack frame */
    put ((long *)&memory[A[8] & ADDRMASK], OLD_PC+2, LONG_MASK);   // OLD_PC+2 to match MECB
    A[8] -= 2;
    put ((long *)&memory[A[8] & ADDRMASK], (long) SR, (long) WORD_MASK);
    A[8] -= 2;
    put ((long *)&memory[A[8] & ADDRMASK], (long) inst, (long) WORD_MASK);
    A[8] -= 4;
    put ((long *)&memory[A[8] & ADDRMASK], loc, LONG_MASK);
    A[8] -= 2;
    if (loc == OLD_PC+2)        // if address exception reading instruction
      infoWord = 0x6;           // function code 110 Supervisor Program
    else                        // else data access error
      infoWord = 0x5;           // function code 101 Supervisor Data
    if (r_w == READ)
      infoWord |= 0x10;
    put ((long *)&memory[A[8] & ADDRMASK], (long)infoWord, (long) WORD_MASK);/* push information word */
  }
  SR = SR | sbit;			/* force processor into supervisor state */
  SR = SR & ~tbit;			/* turn off trace mode */
  trace_bit = false;
}

//---------------------------------------------------------
void irqHandler()
{
  exceptionHandler(2,0,READ);
  SR &= 0xF8FF;                 // clear irq priority bits
  if (irq & 0x40) {             // if IRQ 7
    SR = SR | 0x700;	        // set priority level
    mem_req (0x7C, LONG_MASK, &PC);
    irq &= 0x3F;                // clear irq request
  } else if (irq & 0x20) {      // if IRQ 6
    SR = SR | 0x600;	        // set priority level
    mem_req (0x78, LONG_MASK, &PC);
    irq &= 0x1F;                // clear irq request
  } else if (irq & 0x10) {      // if IRQ 5
    SR = SR | 0x500;	        // set priority level
    mem_req (0x74, LONG_MASK, &PC);
    irq &= 0x0F;                // clear irq request
  } else if (irq & 0x08) {      // if IRQ 4
    SR = SR | 0x400;	        // set priority level
    mem_req (0x70, LONG_MASK, &PC);
    irq &= 0x07;                // clear irq request
  } else if (irq & 0x04) {      // if IRQ 3
    SR = SR | 0x300;	        // set priority level
    mem_req (0x6C, LONG_MASK, &PC);
    irq &= 0x03;                // clear irq request
  } else if (irq & 0x02) {      // if IRQ 2
    SR = SR | 0x200;	        // set priority level
    mem_req (0x68, LONG_MASK, &PC);
    irq &= 0x01;                // clear irq request
  } else if (irq & 0x01) {      // if IRQ 1
    SR = SR | 0x100;	        // set priority level
    mem_req (0x64, LONG_MASK, &PC);
    irq &= 0x00;                // clear irq request
  }
  inc_cyc (34);
}

//---------------------------------------------------------
// Halt Simulator
void haltSimulator()
{
  Form1->AutoTraceTimer->Enabled = false;
  trace = false;
  halt = true;
  Hardware->disable();
  Log->stopLogWithAnnounce();
}