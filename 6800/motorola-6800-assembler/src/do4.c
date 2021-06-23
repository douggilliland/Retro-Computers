/*
 *      MC6804 specific processing
 */

#include "do.h"
#include "globals.h"
#include "as.h"
#include "util.h"
#include "eval.h"
#include "symtab.h"

#define IMMED   0
#define IND     1
#define OTHER   2

/* special addresses */
#define XREG    0x80
#define YREG    0x81
#define SD1REG  0x82
#define SD2REG  0x83
#define ACCUM   0xFF

static void mvi(int op, int to, int from);

/*
 *      localinit --- machine specific initialization
 */
void localinit(void)
{
	install("x",XREG);
	install("X",XREG);
	install("y",YREG);
	install("Y",YREG);
	install("a",ACCUM);
	install("A",ACCUM);
}

/*
 *      do_op --- process mnemonic
 */
void do_op(int opcode /* base opcode */, int class /* mnemonic class */)
{
	int     dist;   /* relative branch distance */
	int     amode;  /* indicated addressing mode */
	int     r1;     /* first eval() for mvi */

	if (( *Operand == '[' ) || ( *Operand == ','))
		amode = IND;
	else if( *Operand == '#' )
		amode = IMMED;
	else
		amode = OTHER;

	switch(class){
		case INH:                       /* inherent addressing */
			emit(opcode);
			return;
		case APOST:             /* A address in mem follows opcode */
			emit(opcode);
			emit(ACCUM);
			return;
		case REL:                       /* short relative branches */
			eval();
			dist = Result - (Pc+1);
			if( (dist >15 || dist <-16) && Pass==2){
				error("Branch out of Range");
				dist = -1;
				}
			emit(opcode + (dist&0x1F));
			return;
		case BTB:
		case SETCLR:
			eval();
			if(Result <0 || Result >7){
				error("Bit Number must be 0-7");
				return;
				}
			emit( opcode + Result);
			if(*Optr++ != ',')error("SYNTAX");
			eval();
			emit(lobyte(Result));
			if( class == SETCLR )
				return;
			if(*Optr++ != ',')error("SYNTAX");
			eval();
			dist = Result - (Old_pc+3);
			if( (dist >127 || dist <-128) && Pass==2){
				error("Branch out of Range");
				dist = -3;
				return;
				}
			emit(lobyte(dist));
			return;
		case EXT:               /* jsr, jmp */
			eval();
			emit(opcode | (hibyte(Result) & 0x0F));
			emit(lobyte(Result));
			return;
		case BPM:       /* brset/clr 7,accum,target */
			emit(opcode);
			emit(ACCUM);
			eval();
			dist = Result - (Old_pc + 3);
			if ((dist > 127 || dist < -128) && Pass == 2) {
				error("Branch out of range");
				dist = -3;
				return;
				}
			emit(lobyte(dist));
			return;
		case MVI:
			eval();
			r1 = Result;    /* save result */
			if (*Optr++ != ',')
				warn("Missing ','");
			eval();
			mvi(opcode,r1,Result);
			return;
		case CLRX:      /* mvi xreg,0 */
			mvi(opcode,XREG,0);
			return;
		case CLRY:      /* mvi yreg,0 */
			mvi(opcode,YREG,0);
			return;
		case LDX:       /* mvi xreg data */
			if (amode == IMMED) Optr++;
			eval();
			mvi(opcode,XREG,Result);
			return;
		case LDY:       /* mvi yreg data */
			if (amode == IMMED) Optr++;
			eval();
			mvi(opcode,YREG,Result);
			return;
		case NOIMM:
			if( amode == IMMED ){
				error("Immediate Addressing Illegal");
				return;
				}
		case GEN:
			if ( amode == IMMED ) {
				Optr++;
				eval();
				emit(opcode | 0x08);
				emit(Result);
				return;
				}
			if( amode == IND ){
				Optr++;
				eval();
				if ((*Optr != ']') && (*Operand != ','))
					warn("Missing ']'");
				if (Result != XREG && Result != YREG) {
					error("Operand must be $80 or $81");
					emit(opcode);
					return;
				}
				emit(opcode | ((Result&0x01)<<4));
				return;
				}
			eval();
			if (XREG <= Result && Result <=SD2REG){
				/*check for short direct cases*/
				if ( opcode==0xE6 ) {   /* inc */
					emit(0xA8 + (Result-XREG));
					return;
					}
				if ( opcode==0xE7 ) { /* dec */
					emit(0xB8 + (Result-XREG));
					return;
					}
				if ( opcode==0xE0 ) { /* lda */
					emit(0xAC | (Result-XREG));
					return;
					}
				if ( opcode==0xE1 ) { /* sta */
					emit(0xBC | (Result-XREG));
					return;
					}
				}
			/* else direct addressing */
			emit( opcode | 0x18);
			emit(lobyte(Result));
			return;
		default:
			fatal("Error in Mnemonic table");
		}
}

static void mvi(int op, int to, int from)
{
	emit(op);
	emit(to);
	emit(from);
}
