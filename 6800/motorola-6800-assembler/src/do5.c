/*
 *      MC6805 specific processing
 */

/* addressing modes */
#define IMMED   0       /* immediate */
#define IND     1       /* indexed */
#define OTHER   2       /* NOTA */

static void do_indexed(int op);
static void do_gen(int op, int mode);

#include "do.h"
#include "globals.h"
#include "as.h"
#include "util.h"
#include "eval.h"

/*
 *      localinit --- machine specific initialization
 */
void localinit(void)
{
}

/*
 *      do_op --- process mnemonic
 *
 *	Called with the base opcode and it's class. Optr points to
 *	the beginning of the operand field.
 */
void do_op(int opcode /* base opcode */, int class /* mnemonic class */)
{
	int     dist;   /* relative branch distance */
	int     amode;  /* indicated addressing mode */
	char	*peek;

	/* guess at addressing mode */
	peek = Optr;
	amode = OTHER;
	while( !delim(*peek) && *peek != EOS)  /* check for comma in operand field */
		if( *peek++ == ',' ){
			amode = IND;
			break;
			}
	if( *Optr == '#' ) amode = IMMED;

	switch(class){
		case INH:                       /* inherent addressing */
			emit(opcode);
			return;
		case GEN:                       /* general addressing */
			do_gen(opcode,amode);
			return;
		case REL:                       /* short relative branches */
			eval();
			dist = Result - (Pc+2);
			emit(opcode);
			if( (dist >127 || dist <-128) && Pass==2){
				error("Branch out of Range");
				emit(lobyte(-2));
				return;
				}
			emit(lobyte(dist));
			return;
		case NOIMM:
			if( amode == IMMED ){
				error("Immediate Addressing Illegal");
				return;
				}
			do_gen(opcode,amode);
			return;
		case GRP2:
			if( amode == IND ){
				do_indexed(opcode+0x20);
				return;
				}
			eval();
			Cycles += 2;
			if(Force_byte){
				emit(opcode);
				emit(lobyte(Result));
				return;
				}
			if(Result>=0 && Result <=0xFF){
				emit(opcode);
				emit(lobyte(Result));
				return;
				}
			error("Extended Addressing not allowed");
			return;
		case SETCLR:
		case BTB:
			eval();
			if(Result <0 || Result >7){
				error("Bit Number must be 0-7");
				return;
				}
			emit( opcode | (Result << 1));
			if(*Optr++ != ',')error("SYNTAX");
			eval();
			emit(lobyte(Result));
			if(class==SETCLR)
				return;
			/* else it's bit test and branch */
			if(*Optr++ != ',')error("SYNTAX");
			eval();
			dist = Result - (Old_pc+3);
			if( (dist >127 || dist <-128) && Pass==2){
				error("Branch out of Range");
				emit(lobyte(-3));
				return;
				}
			emit(lobyte(dist));
			return;
		default:
			fatal("Error in Mnemonic table");
		}
}

/*
 *      do_gen --- process general addressing
 */
static void do_gen(int op, int mode)
{
	if( mode == IMMED){
		Optr++;
		emit(op);
		eval();
		emit(lobyte(Result));
		return;
		}
	else if( mode == IND ){
		do_indexed(op+0x30);
		return;
		}
	else if( mode == OTHER){        /* direct or extended addressing */
		eval();
		if(Force_word){
			emit(op+0x20);
			eword(Result);
			Cycles += 3;
			return;
			}
		if(Force_byte){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles += 2;
			return;
			}
		if(Result >= 0 && Result <= 0xFF){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles += 2;
			return;
			}
		else {
			emit(op+0x20);
			eword(Result);
			Cycles += 3;
			return;
			}
		}
	else {
		error("Unknown Addressing Mode");
		return;
		}
}

/*
 *      do_indexed --- handle all wierd stuff for indexed addressing
 */
static void do_indexed(int op)
{
	eval();
	if(!(*Optr++ == ',' && (*Optr == 'x' || *Optr == 'X')))
		warn("Indexed Addressing Assumed");
	if(Force_word){
		if(op < 0x80 ){ /* group 2, no extended addressing */
			emit(op+0x10); /* default to one byte indexed */
			emit(lobyte(Result));
			Cycles += 3;
			return;
			}
		emit(op);
		eword(Result);
		Cycles += 4;
		return;
		}
	Cycles += 3;    /* assume 1 byte indexing */
	if(Force_byte){
		emit(op+0x10);
		emit(lobyte(Result));
		return;
		}
	if(Result==0){
		emit(op+0x20);
		Cycles--;       /* ,x slightly faster */
		return;
		}
	if(Result>0 && Result <=0xFF){
		emit(op+0x10);
		emit(lobyte(Result));
		return;
		}
	if( op < 0x80 ){
		warn("Value Truncated");
		emit(op+0x10);
		emit(lobyte(Result));
		return;
		}
	emit(op);
	eword(Result);
	Cycles++;       /* 2 byte slightly slower */
	return;
}
