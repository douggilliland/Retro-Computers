/*
 *      MC6801 specific processing
 */

#include "do.h"
#include "globals.h"
#include "as.h"
#include "util.h"
#include "eval.h"

/* addressing modes */
#define IMMED   0       /* immediate */
#define IND     1       /* indexed */
#define OTHER   2       /* NOTA */

static void do_indexed(int op);
static void do_gen(int op, int mode);

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
		case REL:                       /* relative branches */
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
			if( amode == IMMED){
				error("Immediate Addressing Illegal");
				return;
				}
			do_gen(opcode,amode);
			return;
		case LONGIMM:
			if( amode == IMMED ){
				emit(opcode);
				Optr++;
				eval();
				eword(Result);
				return;
				}
			do_gen(opcode,amode);
			return;
		case GRP2:
			if( amode == IND ){
				do_indexed(opcode);
				return;
				}
			/* extended addressing */
			eval();
			emit(opcode+0x10);
			eword(Result);
			return;
		default:
			fatal("Error in Mnemonic table");
		}
}

/*
 *      do_gen --- process general addressing modes
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
		Cycles+=2;
		do_indexed(op+0x20);
		return;
		}
	else if( mode == OTHER){
		eval();
		if(Force_word){
			emit(op+0x30);
			eword(Result);
			Cycles+=2;
			return;
			}
		if(Force_byte){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles++;
			return;
			}
		if(Result>=0 && Result <=0xFF){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles++;
			return;
			}
		else {
			emit(op+0x30);
			eword(Result);
			Cycles+=2;
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
	emit(op);
	eval();
	if( mapdn(*++Optr) != 'x' )
		warn("Indexed Addressing Assumed");
	if( Result < 0 || Result > 255)
		warn("Value Truncated");
	emit(lobyte(Result));
}
