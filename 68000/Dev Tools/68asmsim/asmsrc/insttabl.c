/***********************************************************************
 *
 *		INSTTABLE.C
 *		Instruction Table for 68000 Assembler
 *
 * Description: This file contains two kinds of data structure declara-
 *		tions: "flavor lists" and the instruction table. First
 *		in the file are "flavor lists," one for each different
 *		instruction. Then comes the instruction table, which
 *		contains the mnemonics of the various instructions, a
 *		pointer to the flavor list for each instruction, and
 *		other data. Finally, the variable tableSize is
 *		initialized to contain the number of instructions in
 *		the table. 
 *
 *      Author: Paul McKee
 *		ECE492    North Carolina State University
 *
 *        Date:	12/13/86
 *
 ************************************************************************/

/*********************************************************************

          HOW THE INSTRUCTION TABLE AND FLAVOR LISTS ARE USED

     The procedure which instLookup() and assemble() use to look up
and verify an instruction (or directive) is as follows. Once the
mnemonic of the instruction has been parsed and stripped of its size
code and trailing spaces, the instLookup() does a binary search on the
instruction table to determine if the mnemonic is present. If it is
not found, then the INV_OPCODE error results. If the mnemonic is
found, then assemble() examines the field parseFlag for that entry.
This flag is TRUE if the mnemonic represents a normal instruction that
can be parsed by assemble(); it is FALSE if the instruction's operands
have an unusual format (as is the case for MOVEM and DC). 

      If the parseFlag is TRUE, then assemble will parse the
instruction's operands, check them for validity, and then pass the
data to the proper routine which will build the instruction. To do
this it uses the pointer in the instruction table to the instruction's
"flavor list" and scans through the list until it finds an particular
"flavor" of the instruction which matches the addressing mode(s)
specified.  If it finds such a flavor, it checks the instruction's
size code and passes the instruction mask for the appropriate size 
(there are three masks for each flavor) to the building routine
through a pointer in the flavor list for that flavor. 

*********************************************************************/


#include <stdio.h>
#include "asm.h"

/* Definitions of addressing mode masks for various classes of references */

#define Data	(DnDirect | AnInd | AnIndPost | AnIndPre | AnIndDisp \
		 | AnIndIndex | AbsShort | AbsLong | PCDisp | PCIndex \
		 | Immediate)

#define Memory	(AnInd | AnIndPost | AnIndPre | AnIndDisp | AnIndIndex \
		 | AbsShort | AbsLong | PCDisp | PCIndex | Immediate)

#define Control	(AnInd | AnIndDisp | AnIndIndex | AbsShort | AbsLong | PCDisp \
		 | PCIndex)

#define Alter	(DnDirect | AnDirect | AnInd | AnIndPost | AnIndPre \
		 | AnIndDisp | AnIndIndex | AbsShort | AbsLong)

#define All	(Data | Memory | Control | Alter)
#define DataAlt	(Data & Alter)
#define MemAlt	(Memory & Alter)
#define Absolute (AbsLong | AbsShort)
#define GenReg	(DnDirect | AnDirect)


/* Define size code masks for instructions that allow more than one size */

#define BW	(BYTE | WORD)
#define WL	(WORD | LONG)
#define BWL	(BYTE | WORD | LONG)
#define BL	(BYTE | LONG)


/* Define the "flavor lists" for each different instruction */

flavor abcdfl[] = {
	{ DnDirect, DnDirect, BYTE, twoReg, 0xC100, 0xC100, 0 },
	{ AnIndPre, AnIndPre, BYTE, twoReg, 0xC108, 0xC108, 0 }
       };

flavor addfl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0600, 0x0640, 0x0680 },
	{ Immediate, AnDirect, WL, quickMath, 0, 0x5040, 0x5080 },
	{ All, DnDirect, BWL, arithReg, 0xD000, 0xD040, 0xD080 },
	{ DnDirect, MemAlt, BWL, arithAddr, 0xD100, 0xD140, 0xD180 },
	{ All, AnDirect, WL, arithReg, 0, 0xD0C0, 0xD1C0 },
       };

flavor addafl[] = {
	{ All, AnDirect, WL, arithReg, 0, 0xD0C0, 0xD1C0 },
       };

flavor addifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0600, 0x0640, 0x0680 }
       };

flavor addqfl[] = {
	{ Immediate, DataAlt, BWL, quickMath, 0x5000, 0x5040, 0x5080 },
	{ Immediate, AnDirect, WL, quickMath, 0, 0x5040, 0x5080 }
       };

flavor addxfl[] = {
	{ DnDirect, DnDirect, BWL, twoReg, 0xD100, 0xD140, 0xD180 },
	{ AnIndPre, AnIndPre, BWL, twoReg, 0xD108, 0xD148, 0xD188 }
       };

flavor andfl[] = {
	{ Data, DnDirect, BWL, arithReg, 0xC000, 0xC040, 0xC080 },
	{ DnDirect, MemAlt, BWL, arithAddr, 0xC100, 0xC140, 0xC180 },
	{ Immediate, DataAlt, BWL, immedInst, 0x0200, 0x0240, 0x0280 }
       };

flavor andifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0200, 0x0240, 0x0280 },
	{ Immediate, CCRDirect, BYTE, immedToCCR, 0x023C, 0x023C, 0 },
	{ Immediate, SRDirect, WORD, immedWord, 0, 0x027C, 0 }
       };

flavor aslfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE1C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE120, 0xE160, 0xE1A0 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE100, 0xE140, 0xE180 }
       };

flavor asrfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE0C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE020, 0xE060, 0xE0A0 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE000, 0xE040, 0xE080 }
       };

flavor bccfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6400, 0x6400, 0x6400 }
       };

flavor bchgfl[] = {
	{ DnDirect, MemAlt, BYTE, arithAddr, 0x0140, 0x0140, 0 },
	{ DnDirect, DnDirect, LONG, arithAddr, 0, 0x0140, 0x0140 },
	{ Immediate, MemAlt, BYTE, staticBit, 0x0840, 0x0840, 0 },
	{ Immediate, DnDirect, LONG, staticBit, 0, 0x0840, 0x0840 }
       };

flavor bclrfl[] = {
	{ DnDirect, MemAlt, BYTE, arithAddr, 0x0180, 0x0180, 0 },
	{ DnDirect, DnDirect, LONG, arithAddr, 0, 0x0180, 0x0180 },
	{ Immediate, MemAlt, BYTE, staticBit, 0x0880, 0x0880, 0 },
	{ Immediate, DnDirect, LONG, staticBit, 0, 0x0880, 0x0880 }
       };

flavor bcsfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6500, 0x6500, 0x6500 }
       };

flavor beqfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6700, 0x6700, 0x6700 }
       };

flavor bgefl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6C00, 0x6C00, 0x6C00 }
       };

flavor bgtfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6E00, 0x6E00, 0x6E00 }
       };

flavor bhifl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6200, 0x6200, 0x6200 }
       };

flavor bhsfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6400, 0x6400, 0x6400 }
       };

flavor blefl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6f00, 0x6F00, 0x6F00 }
       };

flavor blofl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6500, 0x6500, 0x6500 }
       };

flavor blsfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6300, 0x6300, 0x6300 }
       };

flavor bltfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6d00, 0x6D00, 0x6D00 }
       };

flavor bmifl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6b00, 0x6B00, 0x6B00 }
       };

flavor bnefl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6600, 0x6600, 0x6600 }
       };

flavor bplfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6a00, 0x6A00, 0x6A00 }
       };

flavor brafl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6000, 0x6000, 0x6000 }
       };

flavor bsetfl[] = {
	{ DnDirect, MemAlt, BYTE, arithAddr, 0x01C0, 0x01C0, 0 },
	{ DnDirect, DnDirect, LONG, arithAddr, 0, 0x01C0, 0x01C0 },
	{ Immediate, MemAlt, BYTE, staticBit, 0x08C0, 0x08C0, 0 },
	{ Immediate, DnDirect, LONG, staticBit, 0, 0x08C0, 0x08C0 }
       };

flavor bsrfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6100, 0x6100, 0x6100 }
       };

flavor btstfl[] = {
	{ DnDirect, Memory, BYTE, arithAddr, 0x0100, 0x0100, 0 },
	{ DnDirect, DnDirect, LONG, arithAddr, 0, 0x0100, 0x0100 },
	{ Immediate, Memory, BYTE, staticBit, 0x0800, 0x0800, 0 },
	{ Immediate, DnDirect, LONG, staticBit, 0, 0x0800, 0x0800 }
       };

flavor bvcfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6800, 0x6800, 0x6800 }
       };

flavor bvsfl[] = {
	{ Absolute, 0, SHORT | LONG, branch, 0x6900, 0x6900, 0x6900 }
       };

flavor chkfl[] = {
	{ Data, DnDirect, WORD, arithReg, 0, 0x4180, 0 }
       };

flavor clrfl[] = {
	{ DataAlt, 0, BWL, oneOp, 0x4200, 0x4240, 0x4280 }
       };

flavor cmpfl[] = {
	{ All, DnDirect, BWL, arithReg, 0xB000, 0xB040, 0xB080 },
	{ All, AnDirect, WL, arithReg, 0, 0xB0C0, 0xB1C0 },
	{ Immediate, DataAlt, BWL, immedInst, 0x0C00, 0x0C40, 0x0C80 }
       };

flavor cmpafl[] = {
	{ All, AnDirect, WL, arithReg, 0, 0xB0C0, 0xB1C0 }
       };

flavor cmpifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0C00, 0x0C40, 0x0C80 }
       };

flavor cmpmfl[] = {
	{ AnIndPost, AnIndPost, BWL, twoReg, 0xB108, 0xB148, 0xB188 }
       };

flavor dbccfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x54C8, 0 }
       };

flavor dbcsfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x55C8, 0 }
       };

flavor dbeqfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x57C8, 0 }
       };

flavor dbffl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x51C8, 0 }
       };

flavor dbgefl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5CC8, 0 }
       };

flavor dbgtfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5EC8, 0 }
       };

flavor dbhifl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x52C8, 0 }
       };

flavor dbhsfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x54C8, 0 }
       };

flavor dblefl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5FC8, 0 }
       };

flavor dblofl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x55C8, 0 }
       };

flavor dblsfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x53C8, 0 }
       };

flavor dbltfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5DC8, 0 }
       };

flavor dbmifl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5BC8, 0 }
       };

flavor dbnefl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x56C8, 0 }
       };

flavor dbplfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x5AC8, 0 }
       };

flavor dbrafl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x51C8, 0 }
       };

flavor dbtfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x50C8, 0 }
       };

flavor dbvcfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x58C8, 0 }
       };

flavor dbvsfl[] = {
	{ DnDirect, Absolute, WORD, dbcc, 0, 0x59C8, 0 }
       };

flavor divsfl[] = {
	{ Data, DnDirect, WORD, arithReg, 0, 0x81C0, 0 }
       };

flavor divufl[] = {
	{ Data, DnDirect, WORD, arithReg, 0, 0x80C0, 0 }
       };

flavor eorfl[] = {
	{ DnDirect, DataAlt, BWL, arithAddr, 0xB100, 0xB140, 0xB180 },
	{ Immediate, DataAlt, BWL, immedInst, 0x0A00, 0x0A40, 0x0A80 }
       };

flavor eorifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0A00, 0x0A40, 0x0A80 },
	{ Immediate, CCRDirect, BYTE, immedToCCR, 0x0A3C, 0x0A3C, 0 },
	{ Immediate, SRDirect, WORD, immedWord, 0, 0x0A7C, 0 }
       };

flavor exgfl[] = {
	{ DnDirect, DnDirect, LONG, exg, 0, 0xC140, 0xC140 },
	{ AnDirect, AnDirect, LONG, exg, 0, 0xC148, 0xC148 },
	{ GenReg, GenReg, LONG, exg, 0, 0xC188, 0xC188 }
       };

flavor extfl[] = {
	{ DnDirect, 0, WL, oneReg, 0, 0x4880, 0x48C0 }
       };

flavor illegalfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4AFC, 0 }
       };

flavor jmpfl[] = {
	{ Control, 0, 0, oneOp, 0, 0x4EC0, 0 }
       };

flavor jsrfl[] = {
	{ Control, 0, 0, oneOp, 0, 0x4E80, 0 }
       };

flavor leafl[] = {
	{ Control, AnDirect, LONG, arithReg, 0, 0x41C0, 0x41C0 }
       };

flavor linkfl[] = {
	{ AnDirect, Immediate, 0, link, 0, 0x4E50, 0 }
       };

flavor lslfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE3C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE128, 0xE168, 0xE1A8 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE108, 0xE148, 0xE188 }
       };

flavor lsrfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE2C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE028, 0xE068, 0xE0A8 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE008, 0xE048, 0xE088 }
       };

flavor movefl[] = {
	{ All, DataAlt, BWL, move, 0x1000, 0x3000, 0x2000 },
	{ All, AnDirect, WL, move, 0, 0x3000, 0x2000 },
	{ Data, CCRDirect, WORD, oneOp, 0, 0x44C0, 0 },
	{ Data, SRDirect, WORD, oneOp, 0, 0x46C0, 0 },
	{ CCRDirect, DataAlt, WORD, moveReg, 0, 0x42C0, 0 },
	{ SRDirect, DataAlt, WORD, moveReg, 0, 0x40C0, 0 },
	{ AnDirect, USPDirect, LONG, moveUSP, 0, 0x4E60, 0x4E60 },
	{ USPDirect, AnDirect, LONG, moveUSP, 0, 0x4E68, 0x4E68 }
       };

flavor moveafl[] = {
	{ All, AnDirect, WL, move, 0, 0x3000, 0x2000 }
       };

flavor movecfl[] = {
	{ SFCDirect | DFCDirect | USPDirect | VBRDirect,
           GenReg, LONG, movec, 0, 0x4E7A, 0x4E7A },
	{ GenReg, SFCDirect | DFCDirect | USPDirect | VBRDirect,
           LONG, movec, 0, 0x4E7B, 0x4E7B }
       };

flavor movepfl[] = {
	{ DnDirect, AnIndDisp, WL, movep, 0, 0x0188, 0x01C8 },
	{ AnIndDisp, DnDirect, WL, movep, 0, 0x0108, 0x0148 },
	{ DnDirect, AnInd, WL, movep, 0, 0x0188, 0x01C8 },
	{ AnInd, DnDirect, WL, movep, 0, 0x0108, 0x0148 }
       };

flavor moveqfl[] = {
	{ Immediate, DnDirect, LONG, moveq, 0, 0x7000, 0x7000 }
       };

flavor movesfl[] = {
	{ GenReg, MemAlt, BWL, moves, 0x0E00, 0x0E40, 0x0E80 },
	{ MemAlt, GenReg, BWL, moves, 0x0E00, 0x0E40, 0x0E80 }
       };

flavor mulsfl[] = {
	{ Data, DnDirect, WORD, arithReg, 0, 0xC1C0, 0 }
       };

flavor mulufl[] = {
	{ Data, DnDirect, WORD, arithReg, 0, 0xC0C0, 0 }
       };

flavor nbcdfl[] = {
	{ DataAlt, 0, BYTE, oneOp, 0x4800, 0x4800, 0 }
       };

flavor negfl[] = {
	{ DataAlt, 0, BWL, oneOp, 0x4400, 0x4440, 0x4480 }
       };

flavor negxfl[] = {
	{ DataAlt, 0, BWL, oneOp, 0x4000, 0x4040, 0x4080 }
       };

flavor nopfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E71, 0 }
       };

flavor notfl[] = {
	{ DataAlt, 0, BWL, oneOp, 0x4600, 0x4640, 0x4680 }
       };

flavor orfl[] = {
	{ Data, DnDirect, BWL, arithReg, 0x8000, 0x8040, 0x8080 },
	{ DnDirect, MemAlt, BWL, arithAddr, 0x8100, 0x8140, 0x8180 },
	{ Immediate, DataAlt, BWL, immedInst, 0x0000, 0x0040, 0x0080 }
       };

flavor orifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0000, 0x0040, 0x0080 },
	{ Immediate, CCRDirect, BYTE, immedToCCR, 0x003C, 0x003C, 0 },
	{ Immediate, SRDirect, WORD, immedWord, 0, 0x007C, 0 }
       };

flavor peafl[] = {
	{ Control, 0, LONG, oneOp, 0, 0x4840, 0x4840 }
       };

flavor resetfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E70, 0 }
       };

flavor rolfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE7C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE138, 0xE178, 0xE1B8 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE118, 0xE158, 0xE198 }
       };

flavor rorfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE6C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE038, 0xE078, 0xE0B8 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE018, 0xE058, 0xE098 }
       };

flavor roxlfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE5C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE130, 0xE170, 0xE1B0 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE110, 0xE150, 0xE190 }
       };

flavor roxrfl[] = {
	{ MemAlt, 0, WORD, oneOp, 0, 0xE4C0, 0 },
	{ DnDirect, DnDirect, BWL, shiftReg, 0xE030, 0xE070, 0xE0B0 },
	{ Immediate, DnDirect, BWL, shiftReg, 0xE010, 0xE050, 0xE090 }
       };

flavor rtdfl[] = {
	{ Immediate, 0, 0, immedWord, 0, 0x4E74, 0 }
       };

flavor rtefl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E73, 0 }
       };

flavor rtrfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E77, 0 }
       };

flavor rtsfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E75, 0 }
       };

flavor sbcdfl[] = {
	{ DnDirect, DnDirect, BYTE, twoReg, 0x8100, 0x8100, 0 },
	{ AnIndPre, AnIndPre, BYTE, twoReg, 0x8108, 0x8108, 0 }
       };

flavor sccfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x54C0, 0x54C0, 0 }
       };

flavor scsfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x55C0, 0x55C0, 0 }
       };

flavor seqfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x57C0, 0x57C0, 0 }
       };

flavor sffl[] = {
	{ DataAlt, 0, BYTE, scc, 0x51C0, 0x51C0, 0 }
       };

flavor sgefl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5CC0, 0x5CC0, 0 }
       };

flavor sgtfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5EC0, 0x5EC0, 0 }
       };

flavor shifl[] = {
	{ DataAlt, 0, BYTE, scc, 0x52C0, 0x52C0, 0 }
       };

flavor shsfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x54C0, 0x54C0, 0 }
       };

flavor slefl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5FC0, 0x5FC0, 0 }
       };

flavor slofl[] = {
	{ DataAlt, 0, BYTE, scc, 0x55C0, 0x55C0, 0 }
       };

flavor slsfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x53C0, 0x53C0, 0 }
       };

flavor sltfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5DC0, 0x5DC0, 0 }
       };

flavor smifl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5BC0, 0x5BC0, 0 }
       };

flavor snefl[] = {
	{ DataAlt, 0, BYTE, scc, 0x56C0, 0x56C0, 0 }
       };

flavor splfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x5AC0, 0x5AC0, 0 }
       };

flavor stfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x50C0, 0x50C0, 0 }
       };

flavor stopfl[] = {
	{ Immediate, 0, 0, immedWord, 0, 0x4E72, 0 }
       };

flavor subfl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0400, 0x0440, 0x0480 },
	{ Immediate, AnDirect, WL, quickMath, 0, 0x5140, 0x5180 },
	{ All, DnDirect, BWL, arithReg, 0x9000, 0x9040, 0x9080 },
	{ DnDirect, MemAlt, BWL, arithAddr, 0x9100, 0x9140, 0x9180 },
	{ All, AnDirect, WL, arithReg, 0, 0x90C0, 0x91C0 },
       };

flavor subafl[] = {
	{ All, AnDirect, WL, arithReg, 0, 0x90C0, 0x91C0 }
       };

flavor subifl[] = {
	{ Immediate, DataAlt, BWL, immedInst, 0x0400, 0x0440, 0x0480 }
       };

flavor subqfl[] = {
	{ Immediate, DataAlt, BWL, quickMath, 0x5100, 0x5140, 0x5180 },
	{ Immediate, AnDirect, WL, quickMath, 0, 0x5140, 0x5180 }
       };

flavor subxfl[] = {
	{ DnDirect, DnDirect, BWL, twoReg, 0x9100, 0x9140, 0x9180 },
	{ AnIndPre, AnIndPre, BWL, twoReg, 0x9108, 0x9148, 0x9188 }
       };

flavor svcfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x58C0, 0x58C0, 0 }
       };

flavor svsfl[] = {
	{ DataAlt, 0, BYTE, scc, 0x59C0, 0x59C0, 0 }
       };

flavor swapfl[] = {
	{ DnDirect, 0, WORD, oneReg, 0, 0x4840, 0 }
       };

flavor tasfl[] = {
	{ DataAlt, 0, BYTE, oneOp, 0x4AC0, 0x4AC0, 0 }
       };

flavor trapfl[] = {
	{ Immediate, 0, 0, trap, 0, 0x4E40, 0 }
       };

flavor trapvfl[] = {
	{ 0, 0, 0, zeroOp, 0, 0x4E76, 0 }
       };

flavor tstfl[] = {
	{ DataAlt, 0, BWL, oneOp, 0x4A00, 0x4A40, 0x4A80 }
       };

flavor unlkfl[] = {
	{ AnDirect, 0, 0, oneReg, 0, 0x4E58, 0 }
       };


/* Define a macro to compute the length of a flavor list */

#define flavorCount(flavorArray) (sizeof(flavorArray)/sizeof(flavor))


/* The instruction table itself... */

instruction instTable[] = {
	{ "ABCD", abcdfl, flavorCount(abcdfl), TRUE, NULL },
	{ "ADD", addfl, flavorCount(addfl), TRUE, NULL },
	{ "ADDA", addafl, flavorCount(addafl), TRUE, NULL },
	{ "ADDI", addifl, flavorCount(addifl), TRUE, NULL },
	{ "ADDQ", addqfl, flavorCount(addqfl), TRUE, NULL },
	{ "ADDX", addxfl, flavorCount(addxfl), TRUE, NULL },
	{ "AND", andfl, flavorCount(andfl), TRUE, NULL },
	{ "ANDI", andifl, flavorCount(andifl), TRUE, NULL },
	{ "ASL", aslfl, flavorCount(aslfl), TRUE, NULL },
	{ "ASR", asrfl, flavorCount(asrfl), TRUE, NULL },
	{ "BCC", bccfl, flavorCount(bccfl), TRUE, NULL },
	{ "BCHG", bchgfl, flavorCount(bchgfl), TRUE, NULL },
	{ "BCLR", bclrfl, flavorCount(bclrfl), TRUE, NULL },
	{ "BCS", bcsfl, flavorCount(bcsfl), TRUE, NULL },
	{ "BEQ", beqfl, flavorCount(beqfl), TRUE, NULL },
	{ "BGE", bgefl, flavorCount(bgefl), TRUE, NULL },
	{ "BGT", bgtfl, flavorCount(bgtfl), TRUE, NULL },
	{ "BHI", bhifl, flavorCount(bhifl), TRUE, NULL },
	{ "BHS", bccfl, flavorCount(bccfl), TRUE, NULL },
	{ "BLE", blefl, flavorCount(blefl), TRUE, NULL },
	{ "BLO", bcsfl, flavorCount(bcsfl), TRUE, NULL },
	{ "BLS", blsfl, flavorCount(blsfl), TRUE, NULL },
	{ "BLT", bltfl, flavorCount(bltfl), TRUE, NULL },
	{ "BMI", bmifl, flavorCount(bmifl), TRUE, NULL },
	{ "BNE", bnefl, flavorCount(bnefl), TRUE, NULL },
	{ "BPL", bplfl, flavorCount(bplfl), TRUE, NULL },
	{ "BRA", brafl, flavorCount(brafl), TRUE, NULL },
	{ "BSET", bsetfl, flavorCount(bsetfl), TRUE, NULL },
	{ "BSR", bsrfl, flavorCount(bsrfl), TRUE, NULL },
	{ "BTST", btstfl, flavorCount(btstfl), TRUE, NULL },
	{ "BVC", bvcfl, flavorCount(bvcfl), TRUE, NULL },
	{ "BVS", bvsfl, flavorCount(bvsfl), TRUE, NULL },
	{ "CHK", chkfl, flavorCount(chkfl), TRUE, NULL },
	{ "CLR", clrfl, flavorCount(clrfl), TRUE, NULL },
	{ "CMP", cmpfl, flavorCount(cmpfl), TRUE, NULL },
	{ "CMPA", cmpafl, flavorCount(cmpafl), TRUE, NULL },
	{ "CMPI", cmpifl, flavorCount(cmpifl), TRUE, NULL },
	{ "CMPM", cmpmfl, flavorCount(cmpmfl), TRUE, NULL },
	{ "DBCC", dbccfl, flavorCount(dbccfl), TRUE, NULL },
	{ "DBCS", dbcsfl, flavorCount(dbcsfl), TRUE, NULL },
	{ "DBEQ", dbeqfl, flavorCount(dbeqfl), TRUE, NULL },
	{ "DBF", dbffl, flavorCount(dbffl), TRUE, NULL },
	{ "DBGE", dbgefl, flavorCount(dbgefl), TRUE, NULL },
	{ "DBGT", dbgtfl, flavorCount(dbgtfl), TRUE, NULL },
	{ "DBHI", dbhifl, flavorCount(dbhifl), TRUE, NULL },
	{ "DBHS", dbccfl, flavorCount(dbccfl), TRUE, NULL },
	{ "DBLE", dblefl, flavorCount(dblefl), TRUE, NULL },
	{ "DBLO", dbcsfl, flavorCount(dbcsfl), TRUE, NULL },
	{ "DBLS", dblsfl, flavorCount(dblsfl), TRUE, NULL },
	{ "DBLT", dbltfl, flavorCount(dbltfl), TRUE, NULL },
	{ "DBMI", dbmifl, flavorCount(dbmifl), TRUE, NULL },
	{ "DBNE", dbnefl, flavorCount(dbnefl), TRUE, NULL },
	{ "DBPL", dbplfl, flavorCount(dbplfl), TRUE, NULL },
	{ "DBRA", dbrafl, flavorCount(dbrafl), TRUE, NULL },
	{ "DBT", dbtfl, flavorCount(dbtfl), TRUE, NULL },
	{ "DBVC", dbvcfl, flavorCount(dbvcfl), TRUE, NULL },
	{ "DBVS", dbvsfl, flavorCount(dbvsfl), TRUE, NULL },
	{ "DC", NULL, 0, FALSE, dc },
	{ "DCB", NULL, 0, FALSE, dcb },
	{ "DIVS", divsfl, flavorCount(divsfl), TRUE, NULL },
	{ "DIVU", divufl, flavorCount(divufl), TRUE, NULL },
	{ "DS", NULL, 0, FALSE, ds },
	{ "END", NULL, 0, FALSE, funct_end },
	{ "EOR", eorfl, flavorCount(eorfl), TRUE, NULL },
	{ "EORI", eorifl, flavorCount(eorifl), TRUE, NULL },
	{ "EQU", NULL, 0, FALSE, equ },
	{ "EXG", exgfl, flavorCount(exgfl), TRUE, NULL },
	{ "EXT", extfl, flavorCount(extfl), TRUE, NULL },
	{ "ILLEGAL", illegalfl, flavorCount(illegalfl), TRUE, NULL },
	{ "JMP", jmpfl, flavorCount(jmpfl), TRUE, NULL },
	{ "JSR", jsrfl, flavorCount(jsrfl), TRUE, NULL },
	{ "LEA", leafl, flavorCount(leafl), TRUE, NULL },
	{ "LINK", linkfl, flavorCount(linkfl), TRUE, NULL },
	{ "LSL", lslfl, flavorCount(lslfl), TRUE, NULL },
	{ "LSR", lsrfl, flavorCount(lsrfl), TRUE, NULL },
	{ "MOVE", movefl, flavorCount(movefl), TRUE, NULL },
	{ "MOVEA", moveafl, flavorCount(moveafl), TRUE, NULL },
	{ "MOVEC", movecfl, flavorCount(movecfl), TRUE, NULL },
	{ "MOVEM", NULL, 0, FALSE, movem },
	{ "MOVEP", movepfl, flavorCount(movepfl), TRUE, NULL },
	{ "MOVEQ", moveqfl, flavorCount(moveqfl), TRUE, NULL },
	{ "MOVES", movesfl, flavorCount(movesfl), TRUE, NULL },
	{ "MULS", mulsfl, flavorCount(mulsfl), TRUE, NULL },
	{ "MULU", mulufl, flavorCount(mulufl), TRUE, NULL },
	{ "NBCD", nbcdfl, flavorCount(nbcdfl), TRUE, NULL },
	{ "NEG", negfl, flavorCount(negfl), TRUE, NULL },
	{ "NEGX", negxfl, flavorCount(negxfl), TRUE, NULL },
	{ "NOP", nopfl, flavorCount(nopfl), TRUE, NULL },
	{ "NOT", notfl, flavorCount(notfl), TRUE, NULL },
	{ "OR", orfl, flavorCount(orfl), TRUE, NULL },
	{ "ORG", NULL, 0, FALSE, org },
	{ "ORI", orifl, flavorCount(orifl), TRUE, NULL },
	{ "PEA", peafl, flavorCount(peafl), TRUE, NULL },
	{ "REG", NULL, 0, FALSE, reg },
	{ "RESET", resetfl, flavorCount(resetfl), TRUE, NULL },
	{ "ROL", rolfl, flavorCount(rolfl), TRUE, NULL },
	{ "ROR", rorfl, flavorCount(rorfl), TRUE, NULL },
	{ "ROXL", roxlfl, flavorCount(roxlfl), TRUE, NULL },
	{ "ROXR", roxrfl, flavorCount(roxrfl), TRUE, NULL },
	{ "RTD", rtdfl, flavorCount(rtdfl), TRUE, NULL },
	{ "RTE", rtefl, flavorCount(rtefl), TRUE, NULL },
	{ "RTR", rtrfl, flavorCount(rtrfl), TRUE, NULL },
	{ "RTS", rtsfl, flavorCount(rtsfl), TRUE, NULL },
	{ "SBCD", sbcdfl, flavorCount(sbcdfl), TRUE, NULL },
	{ "SCC", sccfl, flavorCount(sccfl), TRUE, NULL },
	{ "SCS", scsfl, flavorCount(scsfl), TRUE, NULL },
	{ "SEQ", seqfl, flavorCount(seqfl), TRUE, NULL },
	{ "SET", NULL, 0, FALSE, set },
	{ "SF", sffl, flavorCount(sffl), TRUE, NULL },
	{ "SGE", sgefl, flavorCount(sgefl), TRUE, NULL },
	{ "SGT", sgtfl, flavorCount(sgtfl), TRUE, NULL },
	{ "SHI", shifl, flavorCount(shifl), TRUE, NULL },
	{ "SHS", sccfl, flavorCount(sccfl), TRUE, NULL },
	{ "SLE", slefl, flavorCount(slefl), TRUE, NULL },
	{ "SLO", scsfl, flavorCount(scsfl), TRUE, NULL },
	{ "SLS", slsfl, flavorCount(slsfl), TRUE, NULL },
	{ "SLT", sltfl, flavorCount(sltfl), TRUE, NULL },
	{ "SMI", smifl, flavorCount(smifl), TRUE, NULL },
	{ "SNE", snefl, flavorCount(snefl), TRUE, NULL },
	{ "SPL", splfl, flavorCount(splfl), TRUE, NULL },
	{ "ST", stfl, flavorCount(stfl), TRUE, NULL },
	{ "STOP", stopfl, flavorCount(stopfl), TRUE, NULL },
	{ "SUB", subfl, flavorCount(subfl), TRUE, NULL },
	{ "SUBA", subafl, flavorCount(subafl), TRUE, NULL },
	{ "SUBI", subifl, flavorCount(subifl), TRUE, NULL },
	{ "SUBQ", subqfl, flavorCount(subqfl), TRUE, NULL },
	{ "SUBX", subxfl, flavorCount(subxfl), TRUE, NULL },
	{ "SVC", svcfl, flavorCount(svcfl), TRUE, NULL },
	{ "SVS", svsfl, flavorCount(svsfl), TRUE, NULL },
	{ "SWAP", swapfl, flavorCount(swapfl), TRUE, NULL },
	{ "TAS", tasfl, flavorCount(tasfl), TRUE, NULL },
	{ "TRAP", trapfl, flavorCount(trapfl), TRUE, NULL },
	{ "TRAPV", trapvfl, flavorCount(trapvfl), TRUE, NULL },
	{ "TST", tstfl, flavorCount(tstfl), TRUE, NULL },
	{ "UNLK", unlkfl, flavorCount(unlkfl), TRUE, NULL }
       };


/* Declare a global variable containing the size of the instruction table */

short int tableSize = sizeof(instTable)/sizeof(instruction);

