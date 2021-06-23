/*
 *      MC68HC11 specific processing
 */

#include "do.h"
#include "globals.h"
#include "as.h"
#include "util.h"
#include "eval.h"

#define PAGE1   0x00
#define PAGE2   0x18
#define PAGE3   0x1A
#define PAGE4   0xCD

/* addressing modes */
#define IMMED   0
#define INDX    1
#define INDY    2
#define LIMMED  3       /* long immediate */
#define OTHER   4

static int bitop(int op, int mode, int class);
static void do_gen(int op, int mode, int pnorm,int px,int py);
static void do_indexed(int op);
static void epage(int p);

int     yflag = 0;      /* YNOIMM, YLIMM, and CPD flag */

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
			if( mapdn(*peek) == 'y' )
				amode = INDY;
			else
				amode = INDX;
			break;
			}
	if( *Optr == '#' ) amode = IMMED;

	yflag = 0;
	switch(class){
		case P2INH:
			emit(PAGE2);
		case INH:                       /* inherent addressing */
			emit(opcode);
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
		case LONGIMM:
			if( amode == IMMED )
				amode = LIMMED;
		case NOIMM:
			if( amode == IMMED ){
				error("Immediate Addressing Illegal");
				return;
				}
		case GEN:                       /* general addressing */
			do_gen(opcode,amode,PAGE1,PAGE1,PAGE2);
			return;
		case GRP2:
			if( amode == INDY ){
				Cycles++;
				emit(PAGE2);
				amode = INDX;
				}
			if( amode == INDX )
				do_indexed(opcode);
			else{   /* extended addressing */
				eval();
				emit(opcode+0x10);
				eword(Result);
				}
			return;
		case CPD:               /* cmpd */
			if( amode == IMMED )
				amode = LIMMED;
			if( amode == INDY )
				yflag=1;
			do_gen(opcode,amode,PAGE3,PAGE3,PAGE4);
			return;
		case XNOIMM:            /* stx */
			if( amode == IMMED ){
				error("Immediate Addressing Illegal");
				return;
				}
		case XLIMM:             /* cpx, ldx */
			if( amode == IMMED )
				amode = LIMMED;
			do_gen(opcode,amode,PAGE1,PAGE1,PAGE4);
			return;
		case YNOIMM:            /* sty */
			if( amode == IMMED ){
				error("Immediate Addressing Illegal");
				return;
				}
		case YLIMM:             /* cpy, ldy */
			if(amode == INDY)
				yflag=1;
			if( amode == IMMED )
				amode = LIMMED;
			do_gen(opcode,amode,PAGE2,PAGE3,PAGE2);
			return;
		case BTB:               /* bset, bclr */
		case SETCLR:            /* brset, brclr */
			opcode = bitop(opcode,amode,class);

			if (amode == INDX)
				Cycles++;
			if( amode == INDY ){
				Cycles+=2;
				emit(PAGE2);
				amode = INDX;
				}
			emit(opcode);
			eval();
			emit(lobyte(Result));   /* address */
			if( amode == INDX )
				Optr += 2;      /* skip ,x or ,y */
			Optr = skip_white(Optr);
			eval();
			emit(lobyte(Result));   /* mask */
			if( class == SETCLR )
				return;
			Optr = skip_white(Optr);
			eval();
			dist = Result - (Pc+1);
			if( (dist >127 || dist <-128) && Pass==2){
				error("Branch out of Range");
				dist = Old_pc - (Pc+1);
				}
			emit(lobyte(dist));
			return;
		default:
			fatal("Error in Mnemonic table");
		}
}

/*
 *      bitop --- adjust opcode on bit manipulation instructions
 */
static int bitop(int op, int mode, int class)
{
	if( mode == INDX || mode == INDY )
		return(op);
	if( class == SETCLR )
		return(op-8);
	else if(class==BTB)
		return(op-12);
	else
		fatal("bitop");
}

/*
 *      do_gen --- process general addressing modes
 */
static void do_gen(int op    /* base opcode */,
                   int mode  /* addressing mode */,
                   int pnorm /* page for normal addressing modes: IMM,DIR,EXT */,
                   int px    /* page for INDX addressing */,
                   int py    /* page for INDY addressing */)
{
	switch(mode)
    {
	case LIMMED:
		Optr++;
		epage(pnorm);
		emit(op);
		eval();
		eword(Result);
		break;
	case IMMED:
		Optr++;
		epage(pnorm);
		emit(op);
		eval();
		emit(lobyte(Result));
		break;
	case INDY:
		if(yflag)
			Cycles += 2;
		else
			Cycles += 3;
		epage(py);
		do_indexed(op+0x20);
		break;
	case INDX:
		Cycles+=2;
		epage(px);
		do_indexed(op+0x20);
		break;
	case OTHER:
		eval();
		epage(pnorm);
		if(Force_word){
			emit(op+0x30);
			eword(Result);
			Cycles+=2;
			break;
			}
		if(Force_byte){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles++;
			break;
			}
		if(Result>=0 && Result <=0xFF){
			emit(op+0x10);
			emit(lobyte(Result));
			Cycles++;
			break;
			}
		else {
			emit(op+0x30);
			eword(Result);
			Cycles+=2;
			break;
			}
		break;
	default:
		error("Unknown Addressing Mode");
	}
}

/*
 *      do_indexed --- handle all wierd stuff for indexed addressing
 */
static void do_indexed(int op)
{
	char c;

	emit(op);
	eval();
	if( *Optr++ != ',' )
		error("Syntax");
	c = mapdn(*Optr++);
	if( c != 'x' && c != 'y')
		warn("Indexed Addressing Assumed");
	if( Result < 0 || Result > 255)
		warn("Value Truncated");
	emit(lobyte(Result));
}

/*
 *      epage --- emit page prebyte
 */
static void epage(int p)
{
	if( p != PAGE1 )        /* PAGE1 means no prebyte */
		emit(p);
}

