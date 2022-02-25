
/***************************** 68000 SIMULATOR ****************************

File Name: OPCODES.H
Version: 1.0

This file contains opcode values to decode 68000 instructions.  It is
	included in the file "run.c"

***************************************************************************/



extern int	ORI(), ORI_TO_CCR(), ORI_TO_SR(), BIT_OP(), MOVEP(), 
		ANDI(), ANDI_TO_CCR(), ANDI_TO_SR(), SUBI(), ADDI(),
		EORI(), EORI_TO_CCR(), EORI_TO_SR(), CMPI(), MOVEA(),
		MOVE(), NEGX(), MOVE_FR_SR(), CHK(), LEA(), CLR(),
		NEG(), MOVE_TO_CCR(), NOT(), MOVE_TO_SR(), NBCD(),
		SWAP(), PEA(), EXT(), MOVEM(), TST(), TAS(),
		ILLEGAL(), TRAP(), LINK(), UNLK(), MOVE_USP(),
		RESET(), NOP(), STOP(), RTE(), RTS(), TRAPV(), RTR(),
		JSR(), JMP(), ADDQ(), SCC(), DBCC(), SUBQ(), BCC(),
		BRA(), BSR(), MOVEQ(), OR(), DIVU(), SBCD(), DIVS(),
		SUB(), SUBA(), SUBX(), CMP(), CMPA(), EOR(), CMPM(),
		AND(), MULU(), ABCD(), EXG(), MULS(), ADD(), ADDA(),
		ADDX(), BIT_FIELD(), SHIFT_ROT(), LINE1010(), LINE1111();

// The offsets array contains the index in inst_arr[] where the most significant
// digit of the instruction word changes. This is used in exec_inst() to
// speed up the search.
int		offsets[] =
	{ 0, 15, 16, 18, 20, 53, 57, 60, 61, 65, 68, 69, 73, 80, 83, 86, 87 };


/***************************  W  A  R  N  I  N  G  *************************/
/*                                                                         */
/*  IF YOU CHANGE THE BELOW STRUCTURE, BE SURE TO MAKE THE CORRESPNDING	   */
/*  CHANGES IN THE "NAMES" ARRAY AT THE END OF THIS FILE		   				*/
/*                                                                         */
/*                                                                         */
/***************************  W  A  R  N  I  N  G  *************************/

struct inst_rec {
		int	mask;
		int	val;
		char	name[13];
		}
		inst_arr[] =
		{
			{	0x0000, 0x0a3c, "EORI_TO_CCR " },       //[0]
			{	0x0000, 0x0a7c, "EORI_TO_SR  " },
			{	0x0000, 0x003c, "ORI_TO_CCR  " },
			{	0x0000, 0x007c, "ORI_TO_SR   " },
			{	0x0000, 0x023c, "ANDI_TO_CCR " },
			{	0x0000, 0x027c, "ANDI_TO_SR  " },
			{	0x0ec7, 0x0108, "MOVEP       " },
			{	0x00ff, 0x0200, "ANDI        " },
			{	0x00ff, 0x0000, "ORI         " },
			{	0x00ff, 0x0400, "SUBI        " },       //10
			{	0x00ff, 0x0600, "ADDI        " },
			{	0x00ff, 0x0800, "BIT_OP      " },
			{	0x00ff, 0x0a00, "EORI        " },
			{	0x00ff, 0x0c00, "CMPI        " },
			{	0x0eff, 0x0100, "BIT_OP      " },
			{	0x0fff, 0x1000, "MOVEB       " },       //[15]
			{	0x0e3f, 0x2040, "MOVEAL      " },       //[16]
			{	0x0fff, 0x2000, "MOVEL       " },
			{	0x0e3f, 0x3040, "MOVEAW      " },       //[18]
			{	0x0fff, 0x3000, "MOVEW       " },
			{	0x0000, 0x4afc, "ILLEGAL     " },       //[20]
			{	0x0000, 0x4e70, "RESET       " },
			{	0x0000, 0x4e71, "NOP         " },
			{	0x0000, 0x4e72, "STOP        " },
			{	0x0000, 0x4e73, "RTE         " },
			{	0x0000, 0x4e75, "RTS         " },
			{	0x0000, 0x4e76, "TRAPV       " },
			{	0x0000, 0x4e77, "RTR         " },
			{	0x0007, 0x4e50, "LINK        " },
			{	0x0007, 0x4e58, "UNLK        " },
			{	0x0007, 0x4e60, "MOVE_TO_USP " },       //30
			{	0x0007, 0x4e68, "MOVE_FR_USP " },
			{	0x0007, 0x4840, "SWAP        " },
			{	0x0007, 0x4880, "EXT         " },
			{	0x0007, 0x48c0, "EXT         " },
			{	0x000f, 0x4e40, "TRAP        " },
			{	0x003f, 0x40c0, "MOVE_FR_SR  " },
			{	0x003f, 0x44c0, "MOVE_TO_CCR " },
			{	0x003f, 0x46c0, "MOVE_TO_SR  " },
			{	0x003f, 0x4800, "NBCD        " },
			{	0x003f, 0x4840, "PEA         " },       //40
			{	0x003f, 0x4ac0, "TAS         " },
			{	0x003f, 0x4e80, "JSR         " },
			{	0x003f, 0x4ec0, "JMP         " },
			{	0x007f, 0x4c80, "MOVEM_TO_REG" },
			{	0x007f, 0x4880, "MOVEM_TO_EA " },
			{	0x00ff, 0x4200, "CLR         " },
			{	0x00ff, 0x4000, "NEGX        " },
			{	0x00ff, 0x4400, "NEG         " },
			{	0x00ff, 0x4600, "NOT         " },
			{	0x00ff, 0x4a00, "TST         " },       //50
			{	0x0e3f, 0x4180, "CHK         " },
			{	0x0e3f, 0x41c0, "LEA         " },
			{	0x0f07, 0x50c8, "DBCC        " },       //[53]
			{	0x0f3f, 0x50c0, "SCC         " },
			{	0x0eff, 0x5100, "SUBQ        " },
			{	0x0eff, 0x5000, "ADDQ        " },
			{	0x00ff, 0x6000, "BRA         " },       //[57]
			{	0x00ff, 0x6100, "BSR         " },
			{	0x0fff, 0x6000, "BCC         " },
			{	0x0eff, 0x7000, "MOVEQ       " },       //[60]
			{	0x0e0f, 0x8100, "SBCD        " },       //[61]
			{	0x0e3f, 0x80c0, "DIVU        " },
			{	0x0e3f, 0x81c0, "DIVS        " },
			{	0x0fff, 0x8000, "OR          " },
			{	0x0f3f, 0x90c0, "SUBA        " },       //[65]
			{	0x0ecf, 0x9100, "SUBX        " },
			{	0x0fff, 0x9000, "SUB         " },
            {   0x0fff, 0xa000, "LINE_1010   " },       //[68]  CK v2.3
			{	0x0f3f, 0xb0c0, "CMPA        " },       //[69]
			{	0x0ec7, 0xb108, "CMPM        " },       //70
			{	0x0eff, 0xb000, "CMP         " },
			{	0x0eff, 0xb100, "EOR         " },
			{	0x0e07, 0xc140, "EXG_D       " },       //[73]
			{	0x0e07, 0xc148, "EXG_A       " },
			{	0x0e07, 0xc188, "EXG_D_AND_A " },
			{	0x0e0f, 0xc100, "ABCD        " },
			{	0x0e3f, 0xc1c0, "MULS        " },
			{	0x0e3f, 0xc0c0, "MULU        " },
			{	0x0fff, 0xc000, "AND         " },
			{	0x0f3f, 0xd0c0, "ADDA        " },       //[80]
			{	0x0ecf, 0xd100, "ADDX        " },
			{	0x0fff, 0xd000, "ADD         " },
            {   0x073f, 0xe8c0, "BIT_FIELD   " },       //[83]  CK v3.8
			{	0x073f, 0xe0c0, "SHIFT_ROT   " },
			{	0x0fff, 0xe000, "SHIFT_ROT   " },
            {   0x0fff, 0xf000, "LINE_1111   " },       //[86]  CK v2.3
		};


/***************************  W  A  R  N  I  N  G  *************************/
/*                                                                         */
/*  IF YOU CHANGE THE BELOW ARRAY, BE SURE TO MAKE THE CORRESPNDING	   	*/
/*  CHANGES IN THE "INST_REC" STRUCTURE ABOVE 				   					*/
/*                                                                         */
/*                                                                         */
/***************************  W  A  R  N  I  N  G  *************************/

int	(*(names[]))() =
		{
		EORI_TO_CCR, EORI_TO_SR, ORI_TO_CCR, ORI_TO_SR,	ANDI_TO_CCR,
		ANDI_TO_SR, MOVEP, ANDI, ORI, SUBI, ADDI, BIT_OP, EORI, CMPI,
		BIT_OP, MOVE, MOVEA, MOVE, MOVEA, MOVE,	ILLEGAL, RESET, NOP,
		STOP, RTE, RTS, TRAPV, RTR, LINK, UNLK, MOVE_USP, MOVE_USP,
		SWAP, EXT, EXT, TRAP, MOVE_FR_SR, MOVE_TO_CCR, MOVE_TO_SR,
		NBCD, PEA, TAS, JSR, JMP, MOVEM, MOVEM, CLR, NEGX, NEG, NOT,
		TST, CHK, LEA, DBCC, SCC, SUBQ, ADDQ, BRA, BSR, BCC, MOVEQ,
		SBCD,	DIVU, DIVS, OR, SUBA, SUBX, SUB, LINE1010, CMPA, CMPM,
                CMP, EOR, EXG, EXG, EXG, ABCD, MULS, MULU, AND, ADDA, ADDX,
                ADD, BIT_FIELD, SHIFT_ROT, SHIFT_ROT, LINE1111
		};

