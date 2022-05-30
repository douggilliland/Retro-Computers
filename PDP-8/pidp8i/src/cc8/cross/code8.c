/*	File code8080.c: 2.2 (84/08/31,10:05:09) */
/*% cc -O -c %
 *
 */
#ifndef unix
#define unix
#endif

#include <stdio.h>
#include <string.h>
#include "defs.h"
#include "data.h"
#include "extern.h"

/*	Define ASNM and LDNM to the names of the assembler and linker
	respectively */

/*
 *	Some predefinitions:
 *
 *	INTSIZE is the size of an integer in the target machine
 *	BYTEOFF is the offset of an byte within an integer on the
 *		target machine. (ie: 8080,pdp11 = 0, 6809 = 1,
 *		360 = 3)
 *	This compiler assumes that an integer is the SAME length as
 *	a pointer - in fact, the compiler uses INTSIZE for both.
 */

/* INTSIZE now defined in defs.h
#define	INTSIZE	1
*/
#define	BYTEOFF	0

/*
 *	print all assembler info before any code is generated
 *
 */
void header ()
{
	output_string ("/	Small C PDP8 Coder (1.0:27/1/99)");
	newline ();
	frontend_version();
	newline ();

    /* Define some useful op-codes SABR doesn't provide, some for use by
     * LIBC, some also useful to end user code.  We document these in
     * the CC8 user manual, here:
     * 
     * https://tangentsoft.com/pidp8i/doc/trunk/doc/cc8-manual.md#opdef
     *
     * BEWARE: Also change the copy in ../os8/header.sb !
     */
	output_line ("OPDEF ANDI 0400");
	output_line ("OPDEF TADI 1400");
	output_line ("OPDEF ISZI 2400");
	output_line ("OPDEF DCAI 3400");
	output_line ("OPDEF JMSI 4400");
	output_line ("OPDEF JMPI 5400");
	output_line ("OPDEF MQL 7421");
	output_line ("OPDEF ACL 7701");
	output_line ("OPDEF MQA 7501");
	output_line ("OPDEF SWP 7521");
	output_line ("OPDEF CDF1 6211");
	output_line ("OPDEF CDF0 6201");
	output_line ("OPDEF CDF4 6241");
	output_line ("OPDEF RIF 6224");
	output_line ("OPDEF CAF0 6203");
	output_line ("OPDEF BSW 7002");
	output_line ("OPDEF CAM 7621");
	output_line ("OPDEF DILX 6053");
	output_line ("OPDEF DILY 6054");
	output_line ("OPDEF DIXY 6055");

	output_line ("/");
}

void newline ()
{
	output_byte (10);
}

void initmac()
{
	defmac("cpm\t1");
	defmac("I8080\t1");
	defmac("RMAC\t1");
	defmac("smallc\t1");
}

int galign(t)
long	t;
{
	return(t);
}

/*
 *	return size of an integer
 */
int intsize() {
	return(INTSIZE);
}

/*
 *	return offset of ls byte within word
 *	(ie: 8080 & pdp11 is 0, 6809 is 1, 360 is 3)
 */
int byteoff() {
	return(BYTEOFF);
}

/*
 *	Output internal generated label prefix
 */
void output_label_prefix() {
	output_with_tab ("CC");
}


/*
 *	Output a label definition terminator
 */
void output_label_terminator ()
{
	output_byte (',');
}

/*
 *	begin a comment line for the assembler
 *
 */
void gen_comment ()
{
	output_byte ('/');
}

/*
 *	Emit user label prefix
 */
void prefix ()
{
    return;
}

/* Stkbase output stack base->literals =stkp+2 ... ie 202(8) =130(10) + sizeof(globals) */
void stkbase()
{
	output_with_tab ("GBL");
}

/*
 *	print any assembler stuff needed after all code
 *
 */
void trailer ()
{
//	output_with_tab ("\tENTRY ");
//	output_byte('M');
//	print_label (litlab);
//	newline ();
	output_byte('M');
	print_label (litlab);
	output_label_terminator ();
	output_with_tab ("\t0");
	newline ();
	output_line("\tCDF1");
	output_with_tab ("\tTAD L");
	print_label (litlab);
	newline ();
	output_line ("\tSNA CLA    / Any literals to push?");
	output_with_tab ("\tJMP I M");
	print_label (litlab);
	newline ();
	output_with_tab ("\tTAD X");
	print_label (litlab);
	newline ();
	output_line ("\tDCA JLC");
	output_byte('D');
	print_label (litlab);
	output_label_terminator ();
	output_line("CDF0");
	output_with_tab ("\tTADI JLC");
	newline ();
	output_line ("\tJMSI PSH");
	output_line ("\tCLA");
	output_line ("\tISZ JLC");
	output_with_tab ("\tISZ L");
	print_label (litlab);
	newline ();
	output_with_tab ("\tJMP D");
	print_label (litlab);
	newline ();
	output_with_tab ("\tJMP I M");
	print_label (litlab);
	newline ();
	output_line("CCEND,\t0");
	output_line ("\tEND");
}


/*
 *	function prologue
 */
void prologue (char *sym) {
    return;
}

/*
 *	text (code) segment
 */
void code_segment_gtext ()
{
/*	output_line ("cseg"); */
    return;
}

/*
 *	data segment
 */
void data_segment_gdata ()
{
/*	output_line ("dseg"); */
    return;
}

/*
 *  Output the variable symbol at scptr as an extrn or a public
 */
void ppubext(SYMBOL *scptr)  {
        if (symbol_table[current_symbol_table_idx].storage == STATIC) return;
//      output_with_tab (scptr->storage == EXTERN ? ";extrn\t" : ".globl\t");
//	output_string (scptr->name);
//	newline ();
}

/*
 * Output the function symbol at scptr as an extrn or a public
 */
void fpubext(SYMBOL *scptr) {
/*	if (scptr[STORAGE] == STATIC) return;
//	output_with_tab (scptr[OFFSET] == FUNCTION ? "public\t" : "extrn\t");
//	prefix ();
//	output_string (scptr);
//	newline (); */
}

/*
 *  Output an octal number to the assembler file
 */
void output_number (num) int num; {
	output_octal (num);
}


/*
 *	fetch a static memory cell into the primary register
getmem (sym)
char	*sym;
{
	int adr;
		output_line ("\tCLA");
		gen_immediate3 ();
		adr=glint(sym)+128;
		output_number (glint(sym)+128);
		newline ();
		output_line("\tDCA JLC");
		output_line("\tTADI JLC");
}*/

void gen_get_memory (SYMBOL *sym) {

	output_line ("\tCLA");
	gen_immediate4 ();
	output_number (glint(sym)+128);
    newline ();
}
/*
 * @param sym
 *	fetch a static memory cell into the primary register (pre-increment*/

void gen_get_inc_memory (SYMBOL *sym) {
	int adr;
	output_line ("\tCLA");
	adr=glint(sym)+128;
	output_with_tab ("\tISZI (");
	output_number (adr);
	newline ();
	gen_immediate4 ();
	output_number (adr);
	newline ();
}


/*
 *	fetch the address of the specified symbol into the primary register
 *
 */
int gen_get_locale (SYMBOL *sym)  {
	output_line("\tCLA");
	output_line("\tTAD STKP");
	if (sym->storage == LSTATIC) {
		gen_immediate3 ();
		print_label(-1-glint(sym));
		newline ();
	} else {
		if (stkp-glint(sym)==0) output_string ("/");
		gen_immediate3 ();
		output_octal (stkp-glint(sym));
		newline ();
	}
    return 0;
}

/*
 *	store the primary register into the specified static memory cell
 *

putmem (sym)
char	*sym;
{
		output_line("\tMQL");
		gen_immediate3 ();
		output_number (glint(sym)+128);
		newline ();
		output_line("\tDCA JLC");
		output_line("\tACL");
		output_line("\tDCAI JLC");
		output_line("\tTADI JLC");
}
*/

void gen_put_memory (SYMBOL *sym) {
	output_with_tab ("\tDCAI (");
	output_number (glint(sym)+128);
	newline ();
	gen_immediate4 ();
	output_number (glint(sym)+128);
	newline ();
}

/*
 *	store the specified object type in the primary register
 *	at the address on the top of the stack
 *
 */
void gen_put_stack (typeobj)
char	typeobj;
{
	output_line("\tJMSI PTSK");
	stkp = stkp + INTSIZE;
}

/*
 *	fetch the specified object type indirect through the primary
 *	register into the primary register
 *
 */
void gen_get_indirect (typeobj, reg)
char	typeobj;
int     reg;
{
	output_line("\tDCA JLC");
/*	output_line("\tCDF1"); */
	output_line("\tTADI JLC");
}

/*
 *	fetch the specified object type indirect through the primary
 *	register into the primary register (pre-increment)
 *
 */
void gen_inc_direct (typeobj)
char	typeobj;
{
	output_line("\tDCA JLC");
	output_line("\tISZI JLC");
	output_line("\tTADI JLC");
}


/*
 *	swap the primary and secondary registers
 *
 */
void gen_swap ()
{
	output_line ("\tSWP");
}

/*
*	Clear primary reg
*/
void cpri()
{
	output_line("\tCLA");
}
/*
 *	print partial instruction to get an immediate value into
 *	the primary register
 *
 */
void gen_immediate ()
{
	output_line ("\tCLA");
	output_with_tab ("\tTAD (");
}

void gen_immediate2 ()
{
	output_line ("\tCLA");
	output_with_tab ("\tTAD ");
}

void gen_immediate3 ()
{
	output_with_tab ("\tTAD (");
}

void gen_immediate4 ()
{
	output_with_tab ("\tTADI (");
}
/*
 *	push the primary register onto the stack
 * Ignores specfied register.
 *
 */
void gen_push (int reg)
{
	output_line ("\tJMSI PSH");
	stkp = stkp - INTSIZE;
}

/*
 *	pop the top of the stack into the secondary register
 *
 */
void gen_pop ()
{
	output_line ("\tJMSI POP");
	stkp = stkp + INTSIZE;
}

/*
 *	swap the primary register and the top of the stack
 *
 */
void gen_swap_stack ()
{
	output_line ("\tMQL");
	gen_pop();
	output_line ("\tSWP");
	gen_push(0);
	output_line ("\tSWP");
}

/*
 *	call the specified subroutine name
 *	varag is allowed for libc functions using a v prefix. In this case, the arg count+1 is pushed onto the stack as well.
 *  For the actual routine, the declaration should be a single arg eg printf(int args) in this case, the value of args is the count and &args-args point to the first arg in the caller's list.
 */
void gen_call (sname, nargs)
char	*sname;
int		*nargs;
{
	char tm[10];

	if (strstr(sname,"vlibc")) {
	gen_immediate();
	sname++;
	output_octal (*nargs);
	output_string ("\t/ PUSH ARG COUNT");
	newline ();
	output_line("\tJMSI PSH");
	stkp = stkp - INTSIZE;
	(*nargs)++;
	}
	if (strstr(sname,"libc"))
	{
		strcpy(tm,sname);
		gen_immediate();
		output_string (tm+4);
		newline ();
		output_line("\tMQL");
		output_line("\tCALL 1,LIBC");
		output_line("\tARG STKP");
		output_line("\tCDF1");		/* Make sure DF is correct */
		return;
	}
	output_line("\tCPAGE 2");
	output_line("\tJMSI PCAL");
	output_with_tab ("\t");
	output_string (sname);
	newline ();
}

/* Serial read/write routines for use of field 4 a a block of storage */

void stri()
{
	output_line("\tJMSI PSTRI");
}

void iinit()
{
	output_line("\tJMSI PINIT");
}

void strd()
{
	output_line("\tJMSI PSTRD");
}

void strl()
{
	output_line("\tJMSI PSTRL");
}


/*
 *	return from subroutine
 *
 */

void gen_ret (sym)
char *sym;
{
	output_line ("\tJMPI POPR");
}

/*
 *	perform subroutine call to value on top of stack
 *
 */
void callstk ()
{
	gen_immediate ();
	output_string ("$+5");
	newline ();
	gen_swap_stack ();
	output_line ("pchl");
	stkp = stkp + INTSIZE;
}

/*
 *	jump to specified internal label number
 *
 */
void gen_jump (label)
int	label;
{
	output_with_tab ("\tJMP\t");
	print_label (label);
	newline ();
}

/*
 *	test the primary register and jump if false to label
 *
 */
void gen_test_jump (label, ft)
int	label,
	ft;
{
	if (ft)
		output_line ("\tSZA");
	else
		output_line ("\tSNA");
	gen_jump (label);
}

void casejump()
{
	output_line("\tTAD TMP");
	output_line("\tSNA CLA");
}
/*
 *	print pseudo-op  to define a byte
 *
 */

void gen_def_byte ()
{
	output_with_tab ("\t");
}

/*
 *	print pseudo-op to define storage
 *
 */
void gen_def_storage ()
{
	output_with_tab ("COMMN\t");
}

/*
 *	print pseudo-op to define a word
 *
 */
void gen_def_word ()
{
	return;
}

/*
 *	modify the stack pointer to the new value indicated
 *
 */
int gen_modify_stack (newstkp)
int	newstkp;
{
	int	k;

	k = galign(stkp-newstkp);
	if (k == 0)
		return (newstkp);
	if (k>0 && k<5) {
		while (k--) output_line ("\tISZ STKP");
		return (newstkp);
	}
	output_line ("\tMQL");
	gen_immediate3 ();
	output_octal (k);
	newline ();
	output_line ("\tTAD STKP");
	output_line ("\tDCA STKP");
	gen_swap ();
	return (newstkp);
}

/*
 *	multiply the primary register by INTSIZE
 */

void gen_asl_int () {
  return;
}

/*
 * Multiply_by_two is target specific where INTSIZE=2

void gen_multiply_by_two ()
{
  output_line ("\tRAL");;
}
*/


/*
 *	divide the primary register by INTSIZE
 */
void gen_asr_int () {
  return;
}

/*
 * divide_by_two is target specific where INTSIZE=2
void gen_divide_by_two()
{
  output_line("\tCLL RAR");
}
*/

/*
 *	Case jump instruction
 */
void gen_jump_case() {
	output_line ("\tCIA");
	output_line ("\tDCA TMP");
}

/*
 *	add the primary and secondary registers
 *	if lval2 is int pointer and lval is not, scale lval
 */
void gen_add (lval,lval2) long *lval,*lval2;
{
/*	if (lval==0) output_line("\tCIA");*/
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tTAD JLC");
	stkp = stkp + INTSIZE;
}

/*
 *	subtract the primary register from the secondary
 *
 */
void gen_sub ()
{
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tTAD JLC");
	stkp = stkp + INTSIZE;
}

/*
 *	multiply the primary and secondary registers
 *	(result in primary)
 *
 */
void gen_mult ()
{
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tCALL 1,MPY");
	output_line("\tARG JLC");
	output_line("\tCDF1");
	stkp = stkp + INTSIZE;
}

/*
 *	divide the secondary register by the primary
 *	(quotient in primary, remainder in secondary)
 *
 */
void gen_div ()
{
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tCALL 1,DIV");
	output_line("\tARG JLC");
	output_line("\tCDF1");
	stkp = stkp + INTSIZE;
}

/*
 * PDP-8 has no unsigned divide so we just use the signed divide.
 */

void gen_udiv ()
{
  gen_div();
}

/*
 *	compute the remainder (mod) of the secondary register
 *	divided by the primary register
 *	(remainder in primary, quotient in secondary)
 *
 */
void gen_mod ()
{
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tCALL 1,DIV");
	output_line("\tARG JLC");
	output_line("\tCALL 1,IREM");
	output_line("\tARG 0");
	output_line("\tCDF1");
	stkp = stkp + INTSIZE;
}

/*
 * PDP-8 has no unsigned mod so we just use the signed mod.
 */

void gen_umod ()
{
  gen_mod();
}

/*
 *	inclusive 'or' the primary and secondary registers
 *
 */
void gen_or ()
{
	output_line("\tJMSI POP");
	output_line("\tMQA");
	stkp = stkp + INTSIZE;
}

/*
 *	exclusive 'or' the primary and secondary registers
 *
 */
void gen_xor ()
{
  int nargs;
  nargs = 1;
  
	gen_pop();
	gen_call ("?xor", &nargs);
}

/*
 *	'and' the primary and secondary registers
 *
 */
void gen_and ()
{
	output_line("\tDCA JLC");
	output_line("\tJMSI POP");
	output_line("\tACL");
	output_line("\tAND JLC");
	stkp = stkp + INTSIZE;
}

/*
 *	arithmetic shift right the secondary register the number of
 *	times in the primary register
 *	(results in primary register)
 *
 */
void gen_arithm_shift_right ()
{
	int lbl;

	lbl=getlabel();
	output_line("\tCIA");
	output_line("\tJMSI POP");
	generate_label(lbl);
	output_line("\tSWP");
	output_line("\tCLL RAR");
	output_line("\tSWP");
	output_line("\tIAC");
	output_line("\tSZA");
	gen_jump(lbl);
	output_line("\tSWP");
	stkp = stkp + INTSIZE;
}

/**
 * logically shift right the secondary register the number of
 * times in the primary register (results in primary register)
 * For now treat it like logical shift right.
 */
void gen_logical_shift_right() {
  gen_arithm_shift_right();
}


/*
 *	arithmetic shift left the secondary register the number of
 *	times in the primary register
 *	(results in primary register)
 *
 */
void gen_arithm_shift_left ()
{
	int lbl;

	lbl=getlabel();
	output_line("\tCIA");
	output_line("\tJMSI POP");
	generate_label(lbl);
	output_line("\tSWP");
	output_line("\tCLL RAL");
	output_line("\tSWP");
	output_line("\tIAC");
	output_line("\tSZA");
	gen_jump(lbl);
	output_line("\tSWP");
	stkp = stkp + INTSIZE;
}

/*
 *	two's complement of primary register
 *
 */
void gen_twos_complement ()
{
	output_line("\tCIA");
}

/*
 *	logical complement of primary register
 *
 */
void gen_logical_negation ()
{
	output_line("\tSNA CLA");
	output_line("\tCMA");
}

/*
 *	one's complement of primary register
 *
 */
void gen_complement ()
{
	output_line("\tCMA");
}

/*
 *	Convert primary value into logical value (0 if 0, 1 otherwise)
 *
 */
void gen_convert_primary_reg_value_to_bool ()
{
	output_line("\tSZA CLA");
	output_line("\tIAC");
}

/*
 *	increment the primary register by 1 if char, INTSIZE if
 *      int
 */
void gen_increment_primary_reg (LVALUE *lval) {
  if (lval->ptr_type == STRUCT) {
    gen_immediate3 ();
    output_number(lval->tagsym->size);
    newline();
  } else output_line ("\tIAC");
/*	if (lval[2] == CINT)
//		output_line ("inx\th"); */
}

/*
 * Shortened INC
*/

void gen_isz (LVALUE *lval) {
	int adr;
	struct symbol *sym=lval->symbol;

	if (lval->indirect) {
		output_line ("\tISZI JLC");
		return;
	}

	output_with_tab ("\tISZI (");
	adr=stkp-glint(sym);
//	if (lval[STORAGE] == PUBLIC)
		adr=glint(sym)+128;
	output_number (adr);
	newline ();
}

/*
 *	decrement the primary register by one if char, INTSIZE if
 *	int
 */
void gen_decrement_primary_reg (LVALUE *lval) {
    if (lval->ptr_type == STRUCT) {
      gen_immediate3 ();
      output_number(lval->tagsym->size);
      output_line ("\tCIA");
      newline();
  } else output_line ("\tTAD (-1");
/*	if (lval[2] == CINT)
//		output_line("dcx\th"); */
}

/*
 *	following are the conditional operators.
 *	they compare the secondary register against the primary register
 *	and put a literl 1 in the primary if the condition is true,
 *	otherwise they clear the primary register
 *
 */

/*
 *	equal
 *
 */
void gen_equal ()
{
	output_line("\tCIA");
	output_line("\tTADI STKP");
	gen_pop();
	output_line("\tSNA CLA");
	output_line("\tCMA");
}

/*
 *	not equal
 *
 */
void gen_not_equal ()
{
        gen_pop();
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
}

/*
 *	less than (signed)
 *
 */
void gen_less_than ()
{
        gen_pop();
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tAND (4000");
}

/*
 *	less than or equal (signed)
 *
 */
void gen_less_or_equal ()
{
        gen_pop();
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNA");
	output_line("\tCLA CMA");
	output_line("\tAND (4000");
}

/*
 *	greater than (signed)
 *
 */
void gen_greater_than ()
{
	gen_pop();
	output_line("\tSWP");
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tAND (4000");
}

/*
 *	greater than or equal (signed)
 *
 */
void gen_greater_or_equal ()
{
	gen_pop();
	output_line("\tSWP");
	output_line("\tCIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNA");
	output_line("\tCLA CMA");
	output_line("\tAND (4000");
}

/*
 *	less than (unsigned)
 *
 */
void gen_unsigned_less_than ()
{
	gen_pop();
	output_line("\tCLL CIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNL CLA");
	output_line("\tIAC");
}

/*
 *	less than or equal (unsigned)
 *
 */
void gen_unsigned_less_or_equal ()
{
	gen_pop();
	output_line("\tCLL CIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNL CLA");
	output_line("\tIAC");
}

/*
 *	greater than (unsigned)
 *
 */
void gen_usigned_greater_than ()
{
	gen_pop();
	output_line("\tCLL CIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNA SZL CLA");
	output_line("\tIAC");
}

/*
 *	greater than or equal (unsigned)
 *
 */
void gen_unsigned_greater_or_equal ()
{
	gen_pop();
	output_line("\tSWP");
	output_line("\tCLL CIA");
	output_line("\tDCA JLC");
	output_line("\tACL");
	output_line("\tTAD JLC");
	output_line("\tSNL CLA");
	output_line("\tIAC");
}

/*	Squirrel away argument count in a register that modstk
	doesn't touch.
*/

char *inclib() {
#ifdef  cpm
        return("B:");
#endif
#ifdef  unix
#ifdef  INCDIR
        return(INCDIR);
#else
        return "";
#endif
#endif
}

void gnargs(d)
long	d; {
/*	output_with_tab ("mvi\ta,");
//	output_number (d);
//	newline (); */
}

int assemble(s)
char	*s; {
#ifdef	ASNM
	char buf[100];
	strcpy(buf, ASNM);
	strcat(buf, " ");
	strcat(buf, s);
	buf[strlen(buf)-1] = 's';
	return(system(buf));
#else
	return(0);
#endif
}

/**
 * add offset to primary register
 * @param val the value
 */
void add_offset(int val) {
    gen_immediate3();
    output_number(val);
    newline();
}

/**
 * multiply the primary register by the length of some variable
 * @param type
 * @param size
 */
void gen_multiply(int type, int size) {
    switch (type) {
        case CINT:
        case UINT:
	    gen_asl_int();
            break;
        case STRUCT:
            gen_immediate2();
            output_number(size);
            newline();
            gen_call("ccmul");
            break ;
        default:
            break;
    }
}

