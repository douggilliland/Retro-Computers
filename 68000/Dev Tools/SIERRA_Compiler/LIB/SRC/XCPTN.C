/*
 *  xcptn.c (libc)
 *
 *  Copyright 1987 - 1992 by Sierra Systems.  All rights reserved.
 *
 *  Define one of:
 *
 *  M68000
 *  M68010
 *  M68020
 *  M68040
 *  M68332
 */

#include <stdio.h>
#include <signal.h>

#ifdef M68010
#undef M68000
#endif

#ifdef M68020
#define FP_XCPTN
#endif
#ifdef M68040
#define FP_XCPTN
#endif

static void dmp_regs(char *);
static void dump_fp_regs(char *);
static void flt2str(char *, char *);
static char *itoh(unsigned long, int, char *);
static char *get_exception_sp(void);

/*--------------------------- _xcptn_info_000() -----------------------------*/
/*--------------------------- _xcptn_info_010() -----------------------------*/
/*--------------------------- _xcptn_info_020() -----------------------------*/
/*--------------------------- _xcptn_info_040() -----------------------------*/
/*--------------------------- _xcptn_info_332() -----------------------------*/

/*
 * _xcptn_info_XXX gets a pointer to the portion of the stack containing
 * information about the exception, and prints the status information saved
 * by the processor.  The processor specific function for dumping information
 * stacked by the processor during the exception is ifdef'ed in this file.
 * The module names should correspond to the defined processor name.
 */

#ifdef M68000
void _xcptn_info_000(long sig)
#endif
#ifdef M68010
void _xcptn_info_010(long sig)
#endif
#ifdef M68020
void _xcptn_info_020(long sig)
#endif
#ifdef M68040
void _xcptn_info_040(long sig)
#endif
#ifdef M68332
void _xcptn_info_332(long sig)
#endif
{
    register char *oldstack;
    register long sig_nbr;
    char *err_msg;
    short status;
    char buf[12];
#ifdef FP_XCPTN
    short fsave_size;
    register char *fp_err_msg;
#endif

    sig_nbr = sig & 0xffff;
    switch( sig_nbr ) {
    case SIGBUS:    err_msg = "         BUS ERROR         ";	break;
    case SIGFPE:    err_msg = " FLOATING POINT EXCEPTION  ";

#ifdef FP_XCPTN
	switch( sig >> 24 ) {
	case 1:	fp_err_msg = "       Illegal Instruction";	    break;
#ifndef M68040
	case 2:	fp_err_msg = "        Protocol Violation";	    break;
#endif
	case 3:	fp_err_msg = "Branch Set on Unordered Condition";   break;
	case 4:	fp_err_msg = "          Inexact Result";	    break;
	case 5:	fp_err_msg = "          Divide by Zero";	    break;
	case 6:	fp_err_msg = "             Underflow";		    break;
	case 7:	fp_err_msg = "           Operand Error";	    break;
	case 8:	fp_err_msg = "             Overflow";		    break;
	case 9:	fp_err_msg = "          Signaling NaN";		    break;
#ifdef M68040
	case 10:fp_err_msg = "      Unimplemented Data Type";	    break;
#endif
	default:fp_err_msg = "      Integer Divide by Zero"; 
	}
#endif
	break;

    case SIGCHK:    err_msg = " CHK INSTRUCTION EXCEPTION ";	break;
    case SIGINT:    err_msg = "    KEYBOARD INTERRUPT     ";	break;
    case SIGILL:    err_msg = "    ILLEGAL INSTRUCTION    ";	break;
    case SIGTRAP:   err_msg = "       TRAPV - TRAPcc      ";	break;
    case SIGPRIV:   err_msg = "    PRIVILEGE VIOLATION    ";	break;
    case SIGADDR:   err_msg = "       ADDRESS ERROR       ";	break;
    case SIGSPUR:   err_msg = "    SPURIOUS INTERRUPT     ";	break;
    case SIGZDIV:   err_msg = "      DIVIDE BY ZERO       ";	break;
/*
    case SIGUSER:   err_msg = "    USER DEFINED SIGNAL    ";	break;
*/
    default:	    err_msg = "     UNDEFINED SIGNAL      ";
    }

    fputs("\n************ ", stderr);
    fputs(err_msg, stderr);
    fputs(" ***********\n", stderr);

    if( sig_nbr == SIGFPE ) {
#ifdef FP_XCPTN
	fputs("         ", stderr);
	fputs(fp_err_msg, stderr);
#else
	fputs("               Integer Divide by Zero", stderr);
#endif
    }

    oldstack = get_exception_sp();

    switch( sig_nbr ) {
    case SIGFPE:
#ifdef FP_XCPTN
	if( sig & 0xff0000 )	/* floating point information was stacked */
	    oldstack += 96 + (fsave_size = (sig >> 16) & 0xff);
#endif
    case SIGCHK:
    case SIGINT:
    case SIGILL:
    case SIGTRAP:
    case SIGPRIV:
    case SIGSPUR:
    case SIGZDIV:
/*
    case SIGUSER:
*/
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 6, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 64), 4, buf), stderr);
	fputs("\n", stderr);
#ifdef FP_XCPTN
	if( sig & 0xff0000 )
	    dump_fp_regs(oldstack - 96 - fsave_size);
#endif
	dmp_regs(oldstack);
	break;

#ifdef M68000
    case SIGBUS:
    case SIGADDR:
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 74), 6, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 72), 4, buf), stderr);
	fputs("\n First word of instruction being executed:     ",stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 70), 4, buf), stderr);
	fputs("\n Address being accessed:                   ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 8, buf), stderr);
	fputs("\n Access information:                          ", stderr);
	fputs((*(unsigned short *)(oldstack + 64) & 0x10) ?
	" read\n" : "write\n", stderr);
#endif

#ifdef	M68010
    case SIGBUS:
    case SIGADDR:
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 8, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 64), 4, buf), stderr);
	fputs("\n Special status word:                          ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 72), 4, buf), stderr);
	fputs("\n Fault address:                            ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 74), 8, buf), stderr);
	fputc('\n', stderr);
#endif

#ifdef	M68020
    case SIGBUS:
    case SIGADDR:
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 8, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 64), 4, buf), stderr);
	fputs("\n Special status word:                          ", stderr);
	fputs(itoh((status = *(unsigned short *)(oldstack + 74)), 4, buf),
	stderr);
	if( status & 0xc000 ) {
	    fputs("\n Instruction fault, stage ", stderr);
	    fputc((status & 0x4000) ? 'B':'C', stderr);
	}
	else if( status & 0x100 ) {
	    fputs("\n Data fault address:                       ", stderr);
	    fputs(itoh(*(unsigned long *)(oldstack + 80), 8, buf), stderr);
	    fputs("\n Access information:              ", stderr);
	    if( status & 0x80 )
		fputs("read/modify/write", stderr);
	    else
		fputs((status & 0x40) ? "             read" :
		"            write", stderr);
	}
	fputc('\n', stderr);
#endif

#ifdef M68332
    case SIGBUS:
    case SIGADDR:
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 8, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 64), 4, buf), stderr);
	fputs("\n Special status word:                          ", stderr);
	fputs(itoh((status = *(unsigned short *)(oldstack + 86)), 4, buf),
	stderr);
	if( status & 0x80 ) {
	    fputs("\n Instruction prefetch fault address:       ", stderr);
	    fputs(itoh(*(unsigned long *)(oldstack + 72), 8, buf), stderr);
	}
	else {
	    fputs("\n Operand fault address:                    ", stderr);
	    fputs(itoh(*(unsigned long *)(oldstack + 72), 8, buf), stderr);
	    fputs("\n Access information:              ", stderr);
	    if( status & 0x100 )
		fputs("read/modify/write", stderr);
	    else
		fputs((status & 0x40) ? "             read" :
		"            write", stderr);
	}
	fputc('\n', stderr);
#endif

#ifdef M68040
    case SIGBUS:
    case SIGADDR:
	fputs("\n PC = ", stderr);
	fputs(itoh(*(unsigned long *)(oldstack + 66), 8, buf), stderr);
	fputs("\n SR = ", stderr);
	fputs(itoh(*(unsigned short *)(oldstack + 64), 4, buf), stderr);
	if( sig_nbr == SIGBUS ) {
	    fputs("\n Special status word:                          ",
	    stderr);
	    fputs(itoh((status = *(unsigned short *)(oldstack + 76)), 4, buf),
	    stderr);
	    if( status & 0x0400 ) 
		fputs("\n ATC fault", stderr);
	    else {
		fputs("\n Access information:                          ",
		stderr);
		fputs((status & 0x100) ? "read" : "write", stderr);
	    }	    
	}
	else {
	    fputs("\n Reference address:                        ", stderr);
	    fputs(itoh(*(unsigned long *)(oldstack + 72), 8, buf), stderr);
	}
	fputc('\n', stderr);
#endif

	dmp_regs(oldstack);
	break;
    default:
	return;
    }
    fputs("----------------------------------------------------\n\n",stderr);
}

#ifdef FP_XCPTN
/*--------------------------- dump_fp_regs() --------------------------------*/

static void dump_fp_regs(char *oldstack)
{
    int i;
    char reg[4];
    char buf[32];

    reg[0] = ' ';
    reg[1] = 'F';
    reg[2] = 'P';
    reg[4] = '\0';

    for( i = 0; i < 8; i++ ) {
	flt2str(oldstack + (i * sizeof(long double)), buf);
	reg[3] = i + '0';
	fputs(reg, stderr);
	fputs("=", stderr);
	fputs(buf, stderr);
	putc('\n', stderr);
    }
}
#endif

/*----------------------------- dmp_regs() ----------------------------------*/

static void dmp_regs(char *oldstack)
{
    int i;
    int c;
    char reg[4];
    char buf[12];
    unsigned long *old_stack;

    old_stack = (unsigned long *)oldstack;

    reg[2] = '\0';

    for( c = 'D'; c >= 'A'; c -= 3, old_stack += 8 ) {
	reg[0] = c;
	for( i = 0; i < 8; i++ ) {
	    reg[1] = i + '0';
	    putc(' ', stderr);
	    fputs(reg, stderr);
	    putc('=', stderr);
	    fputs(itoh(*(old_stack + i), 8, buf), stderr);
	    putc(' ', stderr);
	    if( (i & 0x3) == 3 )
		putc('\n', stderr);
	}
    }
}

/*------------------------------- itoh() ------------------------------------*/

static char *itoh(unsigned long number, int length, char *buf)
{
    register char *ptr;

    ptr = buf + 9;
    *--ptr = '\0';

    while( length-- ) {
	*--ptr = "0123456789ABCDEF"[number & 0xf];
	number >>= 4;
    }
    return(ptr);
}

/*------------------------------ flt2str() ----------------------------------*/

/*
 * flt2str converts a long double value to an 'E' format fp string
 */

static void flt2str(char *value, char *buf)
{
    register int length;
    register char *ptr;

    length = _f_fltstr(2, value, buf, 'E', 18, 0);
    ptr = buf + length;
    while( length++ < 26 )
	*ptr++ = ' ';
    *ptr = '\0';
}

/*---------------------------- get_exception_sp() ---------------------------*/

/*
 * get_exception_sp traces back through 4 frames until the stack area
 * is reached that contains the information dumped in the exception.
 *
 * get_exception_sp is called only after the following calls are made:
 *
 *    <processor exception>
 *    <exception handler>
 *    __xraise()
 *    _dflt_sig()
 *    __disp_xcptn_info()   ...	  no frame used
 *    __xcptn_info_XXX()
 *
 * get_exception_sp is completely dependant on this, and will not work in
 * any other context.
 */

    asm("_get_exception_sp:");
    asm("	movea.l	(a6),a0");	/* a0 is now address of frame in dflt_sig()   */
    asm("	movea.l	(a0),a0");	/* a0 is now address of frame in _xraise()    */
    asm("	lea 	12(a0),a0");/* skip back past saved fp, pc and pushed arg */ 
    asm("	rts");

