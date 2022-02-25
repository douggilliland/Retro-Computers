/***********************************************************************
 *
 *		BUILD.C
 *		Instruction Building Routines for 68000 Assembler
 *
 * Description: The functions in this file build instructions, that is,
 *		they assemble the instruction word and its extension
 *		words given the skeleton bit mask for the instruction
 *		and opDescriptors for its operand(s). The instructions
 *		that each routine builds are noted above it in a
 *		comment. All the functions share the same calling
 *		sequence (except zeroOp, which has no argument and
 *		hence omits the operand descriptors), which is as
 *		follows: 
 *
 *		    general_name(mask, size, source, dest, errorPtr);
 *		    int mask, size;
 *		    opDescriptor *source, *dest;
 *		    int *errorPtr;
 *
 *		except
 *
 *		    zeroOp(mask, size, errorPtr);
 *		    int mask, size, *errorPtr;
 *
 *		The mask argument is the skeleton mask for the 
 *		instruction, i.e., the instruction word before the 
 *		addressing information has been filled in. The size 
 *		argument contains the size code that was specified with 
 *		the instruction (using the definitions in ASM.H) or 0 
 *		if no size code was specified. Arguments source and 
 *		dest are pointers to opDescriptors for the two 
 *		operands (only source is valid in some cases). The last 
 *		argument is used to return a status via the standard
 *		mechanism.
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 *    Modified: Charles Kelly
 *              Monroe County Community College
 *              http://www.monroeccc.edu/ckelly
 *
 ************************************************************************/


#include <stdio.h>
#include "asm.h"

extern int	loc;
extern bool pass2;


/**********************************************************************
 *
 *	Function move builds the MOVE and MOVEA instructions
 *
 **********************************************************************/

int move(int mask, int size,
         opDescriptor *source, opDescriptor *dest, int *errorPtr)
{
  unsigned short moveMask;
  char destCode;

  // Check whether the instruction can be assembled as MOVEQ
  if (source->mode == IMMEDIATE && source->backRef && source->size == 0
       && size == LONG_SIZE && dest->mode == DnDirect
       && source->data >= -128 && source->data <= 127) {
    moveq(0x7000, size, source, dest, errorPtr);
    return NORMAL;
  }

  // Otherwise assemble it as plain MOVE
  moveMask = mask | effAddr(source);
  destCode = (char) (effAddr(dest) & 0xff);
  moveMask |= ((destCode & 0x38) << 3) | ((destCode & 7) << 9);
  if (pass2)
    output((int) (moveMask), WORD_SIZE);
  loc += 2;
  extWords(source, size, errorPtr);
  extWords(dest, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function zeroOp builds the following instructions:
 *	 ILLEGAL
 *	 NOP
 *	 RESET
 *	 RTE
 *	 RTR
 *	 RTS
 *	 TRAPV
 *
 ***********************************************************************/

int zeroOp(int mask, int size,
                opDescriptor *source, opDescriptor *dest, int *errorPtr)
{
  if (pass2)
    output((int) (mask), WORD_SIZE);
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function oneOp builds the following instructions:
 *	 ASd  <ea>
 *	 CLR
 *	 JMP
 *	 JSR
 *	 LSd  <ea>
 *	 MOVE <ea>,CCR
 *	 MOVE <ea>,SR
 *	 NBCD
 *	 NEG
 *	 NEGX
 *	 NOT
 *	 PEA
 *	 ROd  <ea>
 *	 ROXd <ea>
 *	 TAS
 *	 TST
 *
 ***********************************************************************/

int	oneOp(int mask, int size,
                opDescriptor *source, opDescriptor *dest,
                int *errorPtr)
{
  if (pass2)
    output((int) (mask | effAddr(source)), WORD_SIZE);
  loc += 2;
  extWords(source, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function arithReg builds the following instructions:
 *	 ADD <ea>,Dn
 *	 ADDA
 *	 AND <ea>,Dn
 *	 CHK
 *	 CMP
 *	 CMPA
 *	 DIVS
 *	 DIVU
 *	 LEA
 *	 MULS
 *	 MULU
 *	 OR <ea>,Dn
 *	 SUB <ea>,Dn
 *	 SUBA
 *
 ***********************************************************************/

int	arithReg(int mask, int size,
                 opDescriptor *source, opDescriptor *dest,
                 int *errorPtr)
{
  unsigned short type;

  // Check whether the instruction is an immediate ADDA or SUBA
  //   that can be assembled as ADDQ or SUBQ
  type = mask & 0xF000;
  if ((type == 0xD000 || type == 0x9000)        // if ADDA or SUBA
        && source->mode == IMMEDIATE
        && size != BYTE_SIZE
        && (source->backRef && source->data >= 1 && source->data <= 8)
        && source->size == 0)                   // not forced Long with #n.L
    if (type == 0xD000) {       // if ADDA
      // Assemble as ADDQ
      if (size == LONG_SIZE)
        quickMath(0x5080, size, source, dest, errorPtr);
      else
        quickMath(0x5040, size, source, dest, errorPtr);
      return NORMAL;
    } else {
      // Assemble as SUBQ
      if (size == LONG_SIZE)
        quickMath(0x5180, size, source, dest, errorPtr);
      else
        quickMath(0x5140, size, source, dest, errorPtr);
      return NORMAL;
    }
  // Otherwise assemble as an ordinary instruction
  if (pass2)
    output((int) (mask | effAddr(source) | (dest->reg << 9)), WORD_SIZE);
  loc += 2;
  extWords(source, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function arithAddr builds the following instructions:
 *	 ADD Dn,<ea>
 *	 AND Dn,<ea>
 *	 BCHG Dn,<ea>
 *	 BCLR Dn,<ea>
 *	 BSET Dn,<ea>
 *	 BTST Dn,<ea>
 *	 EOR
 *	 OR Dn,<ea>
 *	 SUB Dn,<ea>
 *
 ***********************************************************************/


int	arithAddr(int mask, int size,
                  opDescriptor *source, opDescriptor *dest,
                  int *errorPtr)
{
  if (pass2)
    output((int) (mask | effAddr(dest) | (source->reg << 9)), WORD_SIZE);
  loc += 2;
  extWords(dest, size, errorPtr);

  return NORMAL;
}

//---------------------------------------------------------------------
// Function bitField builds the following instructions:
//      BFCHG  <ea>{offset:width}
//      BFCLR  <ea>{offset:width}
//      BFEXTS <ea>{offset:width},Dn
//      BFEXTU <ea>{offset:width},Dn
//      BFFFO  <ea>{offset:width},Dn
//      BFINS  Dn,<ea>{offset:width}
//      BFSET  <ea>{offset:width}
//      BFTST  <ea>{offset:width}

// type fields that use Dn
const int BFEXTS = 0x0300;
const int BFEXTU = 0x0100;
const int BFFFO  = 0x0500;
const int BFINS  = 0x0700;

int	bitField(int mask, int size,
                  opDescriptor *source, opDescriptor *dest,
                  int *errorPtr)
{
  unsigned short type;

  if (pass2)
  {
    type = mask & 0x0700;
    if (type == BFINS)
      output((int) (mask | effAddr(dest)), WORD_SIZE);
    else
      output((int) (mask | effAddr(source)), WORD_SIZE);
    loc += 2;

    if (type == BFEXTS || type == BFEXTU || type == BFFFO)
      source->field |= dest->reg << 12; // put Dn reg number in field
    if (type == BFINS) {                // if bfins Dn,<ea>{offset:width}
      dest->field |= source->reg << 12; // put Dn reg number in field
      output(dest->field, WORD_SIZE);   // field is in destination
    } else
      output(source->field, WORD_SIZE); // field is in source
    loc += 2;
  } else
    loc += 4;
  if (type == BFINS)                    // if bfins Dn,<ea>{offset:width}
    extWords(dest, size, errorPtr);     // output extension word for dest
  else
    extWords(source, size, errorPtr);   // output extension word for source

  return NORMAL;
}

/**********************************************************************
 *
 *	Function immedInst builds the following instructions:
 *	 ADDI
 *	 ANDI
 *	 CMPI
 *	 EORI
 *	 ORI
 *	 SUBI
 *
 ***********************************************************************/


int	immedInst(int mask, int size,
                  opDescriptor *source, opDescriptor *dest,
                  int *errorPtr)
{
  unsigned short type;

  // Check whether the instruction is an immediate ADD or SUB
  //   that can be assembled as ADDQ or SUBQ
  // Check the mask to determine the operation
  type = mask & 0xFF00;
  if ((type == 0x0600 || type == 0x0400)
        && (source->backRef && source->data >= 1 && source->data <= 8)
        && source->size == 0)
    if (type == 0x0600) {
      // Assemble as ADDQ
      quickMath(0x5000 | (mask & 0x00C0), size, source, dest, errorPtr);
      return NORMAL;
    } else {
      // Assemble as SUBQ
      quickMath(0x5100 | (mask & 0x00C0), size, source, dest, errorPtr);
      return NORMAL;
    }
  // Otherwise assemble as an ordinary instruction
  if (pass2)
    output((int) (mask | effAddr(dest)), WORD_SIZE);
  loc += 2;
  extWords(source, size, errorPtr);
  extWords(dest, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function quickMath builds the following instructions:
 *	 ADDQ
 *	 SUBQ
 *
 ***********************************************************************/


int quickMath(int mask, int size,
                  opDescriptor *source, opDescriptor *dest,
                  int *errorPtr)
{
  if (pass2) {
    output((int) (mask | effAddr(dest) | ((source->data & 7) << 9)), WORD_SIZE);
    if (source->data < 1 || source->data > 8)
      NEWERROR(*errorPtr, INV_QUICK_CONST);
  }
  loc += 2;
  extWords(dest, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function movep builds the MOVEP instruction.
 *
 ***********************************************************************/


int movep(int mask, int size,
          opDescriptor *source, opDescriptor *dest,
          int *errorPtr)
{
  if (pass2)
    if (source->mode == DnDirect) {
      // Convert plain address register indirect to address
      //   register indirect with displacement of 0
      if (dest->mode == AnInd) {
	dest->mode = AnIndDisp;
	dest->data = 0;
      }
      output((int) (mask | (source->reg << 9) | (dest->reg)), WORD_SIZE);
      loc += 2;
      extWords(dest, size, errorPtr);
    } else {
      // Convert plain address register indirect to address
      //   register indirect with displacement of 0
      if (source->mode == AnInd) {
	source->mode = AnIndDisp;
	source->data = 0;
      }
      output((int) (mask | (dest->reg << 9) | (source->reg)), WORD_SIZE);
      loc += 2;
      extWords(source, size, errorPtr);
    }

  else
    loc += 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function moves builds the MOVES instruction.
 *
 ***********************************************************************/


int moves(int mask, int size,
              opDescriptor *source, opDescriptor *dest,
              int *errorPtr)
{
  if (pass2)
    if (source->mode & (DnDirect | AnDirect)) {
      output((int) (mask | effAddr(dest)), WORD_SIZE);
      loc += 2;
      if (source->mode == DnDirect)
	output((int) (0x0800 | (source->reg << 12)), WORD_SIZE);
      else
	output((int) (0x8800 | (source->reg << 12)), WORD_SIZE);
      loc += 2;
    } else {
      output((int) mask | effAddr(source), WORD_SIZE);
      loc += 2;
      if (dest->mode == DnDirect)
	output((int) (dest->reg << 12), WORD_SIZE);
      else
	output((int) (0x8000 | (dest->reg << 12)), WORD_SIZE);
      loc += 2;
    }

  else
    loc += 4;
  extWords((source->mode & (DnDirect | AnDirect)) ? dest : source,
	     size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function moveReg builds the following instructions:
 *	 MOVE from CCR
 *	 MOVE from SR
 *
 ***********************************************************************/


int moveReg(int mask, int size, opDescriptor *source, opDescriptor *dest,
            int *errorPtr)
{
  if (pass2)
    output((int) (mask | effAddr(dest)), WORD_SIZE);
  loc += 2;
  extWords(dest, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function staticBit builds the following instructions:
 *	 BCHG #n,<ea>
 *	 BCLR #n,<ea>
 *	 BSET #n,<ea>
 *	 BTST #n,<ea>
 *
 ***********************************************************************/


int staticBit(int mask, int size, opDescriptor *source, opDescriptor *dest,
              int *errorPtr)
{
  if (pass2) {
    output((int) (mask | effAddr(dest)), WORD_SIZE);
    loc += 2;
    output(source->data & 0xFF, WORD_SIZE);
    loc += 2;
  }
  else
    loc += 4;
  extWords(dest, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function movec builds the MOVEC instruction.
 *
 ***********************************************************************/

int movec(int mask, int size, opDescriptor *source, opDescriptor *dest,
          int *errorPtr)
{
  unsigned short mask2;
  opDescriptor *regOp;
  int	controlMode;

  if (pass2) {
    output((int) (mask), WORD_SIZE);
    loc += 2;
    if (mask & 1) {
      regOp = source;
      controlMode = dest->mode;
    } else {
      regOp = dest;
      controlMode = source->mode;
    }
    mask2 = regOp->reg << 12;
    if (regOp->mode == AnDirect)
      mask2 |= 0x8000;
    if (controlMode == SFCDirect)
      mask2 |= 0x000;
    else if (controlMode == DFCDirect)
      mask2 |= 0x001;
    else if (controlMode == USPDirect)
      mask2 |= 0x800;
    else if (controlMode == VBRDirect)
      mask2 |= 0x801;
    output((int) (mask2), WORD_SIZE);
    loc += 2;
  }
  else
    loc += 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function trap builds the TRAP instruction.
 *
 ***********************************************************************/


int trap(int mask, int size, opDescriptor *source, opDescriptor *dest,
         int *errorPtr)
{
  if (pass2) {
    output(mask | (source->data & 0xF), WORD_SIZE);
    if (source->data < 0 || source->data > 15)
      NEWERROR(*errorPtr, INV_VECTOR_NUM);
  }
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function branch builds the following instructions:
 *	 BCC (BHS)   BGT	 BLT	     BRA
 *	 BCS (BLO)   BHI	 BMI	     BSR
 *	 BEQ	     BLE	 BNE         BVC
 *	 BGE	     BLS	 BPL         BVS
 *
 ***********************************************************************/


int branch(int mask, int size, opDescriptor *source, opDescriptor *dest,
           int *errorPtr)
{
  bool	shortDisp;
  int	disp;

  disp = source->data - loc - 2;
  shortDisp = false;
  if ( ((size == SHORT_SIZE) || (size == BYTE_SIZE)) ||
        (size != LONG_SIZE && size != WORD_SIZE && source->backRef &&
         disp >= -128 && disp <= 127 && disp))
    shortDisp = true;
  if (pass2) {
    if (shortDisp) {
      output((int) (mask | (disp & 0xFF)), WORD_SIZE);
      loc += 2;
      if (disp < -128 || disp > 127 || !disp)
	NEWERROR(*errorPtr, INV_BRANCH_DISP);
    } else {
      output((int) (mask), WORD_SIZE);
      loc += 2;
      output((int) (disp), WORD_SIZE);
      loc += 2;
      if (disp < -32768 || disp > 32767)
	NEWERROR(*errorPtr, INV_BRANCH_DISP);
    }
  }
  else
    loc += (shortDisp) ? 2 : 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function moveq builds the MOVEQ instruction.
 *
 ***********************************************************************/


int moveq(int mask, int size, opDescriptor *source, opDescriptor *dest,
          int *errorPtr)
{
  if (pass2) {
    output(mask | (dest->reg << 9) | (source->data & 0xFF), WORD_SIZE);
    if (source->data < -128 || source->data > 255)
      NEWERROR(*errorPtr, INV_MOVE_QUICK_CONST);
  }
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function immedToCCR builds the following instructions:
 *	 ANDI to CCR
 *	 EORI to CCR
 *	 ORI to CCR
 *
 ***********************************************************************/


int immedToCCR(int mask, int size, opDescriptor *source, opDescriptor *dest,
               int *errorPtr)
{
  if (pass2) {
    output((int) (mask), WORD_SIZE);
    loc += 2;
    output(source->data & 0xFF, WORD_SIZE);
    loc += 2;
    if ((source->data & 0xFF) != source->data)
      NEWERROR(*errorPtr, INV_8_BIT_DATA);
  }
  else
    loc += 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function immedWord builds the following instructions:
 *	 ANDI to SR
 *	 EORI to SR
 *	 ORI to SR
 *	 RTD
 *	 STOP
 *
 ***********************************************************************/


int immedWord(int mask, int size, opDescriptor *source, opDescriptor *dest,
              int *errorPtr)
{
  if (pass2) {
    output((int) (mask), WORD_SIZE);
    loc += 2;
    output(source->data & 0xFFFF, WORD_SIZE);
    loc += 2;
    if (source->data < -32768 || source->data > 65535)
      NEWERROR(*errorPtr, INV_16_BIT_DATA);
  }
  else
    loc += 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function dbcc builds the following instructions:
 *	 DBCC (DBHS)  DBGE	 DBLS	     DBPL
 *	 DBCS (DBLO)  DBGT	 DBLT	     DBT
 *	 DBEQ	      DBHI	 DBMI        DBVC
 *	 DBF (DBRA)   DBLE	 DBNE	     DBVS
 *
 ***********************************************************************/

int dbcc(int mask, int size, opDescriptor *source, opDescriptor *dest,
         int *errorPtr)
{
  //ck short disp;
  int disp;

  //ck disp = (short int) (dest->data - loc - 2);
  disp = dest->data - loc - 2;
  if (pass2) {
    output((int) (mask | source->reg), WORD_SIZE);
    loc += 2;
    //ck output((int) (disp), WORD_SIZE);
    output(disp, WORD_SIZE);
    loc += 2;
    if (disp < -32768 || disp > 32767)
      NEWERROR(*errorPtr, INV_BRANCH_DISP);
  }
  else
    loc += 4;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function scc builds the following instructions:
 *	 SCC (SHS)   SGE 	 SLS	    SPL
 *	 SCS (SLO)   SGT 	 SLT	    ST
 *	 SEQ	     SHI 	 SMI        SVC
 *	 SF	     SLE 	 SNE	    SVS
 *
 ***********************************************************************/


int scc(int mask, int size, opDescriptor *source, opDescriptor *dest,
        int *errorPtr)
{
  if (pass2)
    output((int) (mask | effAddr(source)), WORD_SIZE);
  loc += 2;
  extWords(source, size, errorPtr);

  return NORMAL;
}


/**********************************************************************
 *
 *	Function shiftReg builds the following instructions:
 *	 ASd	Dx,Dy
 *	 LSd	Dx,Dy
 *	 ROd	Dx,Dy
 *	 ROXd	Dx,Dy
 *	 ASd	#<data>,Dy
 *	 LSd	#<data>,Dy
 *	 ROd	#<data>,Dy
 *	 ROXd	#<data>,Dy
 *
 ***********************************************************************/

int shiftReg(int mask, int size, opDescriptor *source, opDescriptor *dest,
             int *errorPtr)
{
  if (pass2) {
    mask |= dest->reg;
    if (source->mode == IMMEDIATE) {
      mask |= (source->data & 7) << 9;
      if (source->data < 1 || source->data > 8)
	NEWERROR(*errorPtr, INV_SHIFT_COUNT);
    }
    else
      mask |= source->reg << 9;
    output((int) (mask), WORD_SIZE);
  }
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function exg builds the EXG instruction.
 *
 ***********************************************************************/


int exg(int mask, int size, opDescriptor *source, opDescriptor *dest,
        int *errorPtr)
{
  if (pass2) {
    // Are a data register and an address register being exchanged?
    if (source->mode != dest->mode)
      // If so, the address register goes in bottom three bits
      if (source->mode == AnDirect)
	mask |= source->reg | (dest->reg << 9);
      else
	mask |= dest->reg | (source->reg << 9);
      else
	// Otherwise it doesn't matter which way they go
	mask |= dest->reg | (source->reg << 9);
      output((int) (mask), WORD_SIZE);
   }
   loc += 2;

   return NORMAL;
}


/**********************************************************************
 *
 *	Function twoReg builds the following instructions:
 *	 ABCD
 *	 ADDX
 *	 CMPM
 *	 SBCD
 *	 SUBX
 *
 ***********************************************************************/


int twoReg(int mask, int size, opDescriptor *source, opDescriptor *dest,
           int *errorPtr)
{
  if (pass2) {
    output((int) (mask | (dest->reg << 9) | source->reg), WORD_SIZE);
  }
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function oneReg builds the following instructions:
 *	 EXT
 *	 SWAP
 *	 UNLK
 *
 ***********************************************************************/


int oneReg(int mask, int size, opDescriptor *source, opDescriptor *dest,
           int *errorPtr)
{
  if (pass2) {
    output((int) (mask | source->reg), WORD_SIZE);
  }
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function moveUSP builds the following instructions:
 *	 MOVE	USP,An
 *	 MOVE	An,USP
 *
 ***********************************************************************/


int moveUSP(int mask, int size, opDescriptor *source, opDescriptor *dest,
            int *errorPtr)
{
  if (pass2) {
    if (source->mode == AnDirect)
      output((int) (mask | source->reg), WORD_SIZE);
    else
      output((int) (mask | dest->reg), WORD_SIZE);
		}
  loc += 2;

  return NORMAL;
}


/**********************************************************************
 *
 *	Function link builds the LINK instruction
 *
 ***********************************************************************/

int link(int mask, int size, opDescriptor *source, opDescriptor *dest,
         int *errorPtr)
{
  if (pass2) {
    output((int) (mask | source->reg), WORD_SIZE);
    loc += 2;
    output(dest->data, WORD_SIZE);
    loc += 2;
    if (dest->data < -32768 || dest->data > 32767)
      NEWERROR(*errorPtr, INV_16_BIT_DATA);
  }
  else
    loc += 4;

  return NORMAL;
}


