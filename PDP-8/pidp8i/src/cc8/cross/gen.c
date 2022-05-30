/*      File gen.c: 2.1 (83/03/20,16:02:06) */
/*% cc -O -c %
 *
 */

#include <stdio.h>
#include "defs.h"
#include "data.h"
#include "extern.h"

/* ToUpper routine */

int ucase(int ch) {
  if ('a'>ch || ch>'z') return(ch);
  return(ch-32);
}

/**
 * return next available internal label number
 */
int getlabel() {
    return (nxtlab++);
}

/**
 * print specified number as label
 * @param label
 */
void print_label(int label) {
    output_label_prefix ();
    output_octal (label);
}

/**
 * glabel - generate label
 * not used ?
 * @param lab label number
 */
void glabel(char *lab) {
    output_string (lab);
    output_label_terminator ();
    newline ();
}

/**
 * generate_label - generate numeric label
 * @param nlab label number
 * @return 
 */
void generate_label(int nlab) {
    print_label (nlab);
    output_label_terminator ();
    newline ();
}

/**
 * outputs one byte
 * @param c
 * @return 
 */
char output_byte(char c) {
    if (c == 0)
        return (0);
    fputc (c, output);
    return (c);
}

/**
 * outputs a string
 * @param ptr the string
 * @return 
 */
void output_string(char ptr[]) {
    int k;
    k = 0;
    while (output_byte (ucase(ptr[k++])));
    if (0) printf ("DBG: %s\n", ptr);
}

/**
 * outputs a tab
 * @return 
 */
void print_tab() {
    output_byte ('\t');
}

/**
 * output line
 * @param ptr
 * @return 
 */
void output_line(char ptr[])
{
    output_with_tab (ptr);
    newline ();
}

/**
 * tabbed output
 * @param ptr
 * @return 
 */
void output_with_tab(char ptr[]) {
    // print_tab ();
    output_string (ptr);
}

/**
 * output octal number
 * @param number
 * @return 
 */
void output_octal(int number) {
	int	k, zs;
	char	c;

	zs = 0;
	k = 01000;
	if (number < 0) {
		number = (-number);
		output_byte ('-');
	}
	while (k >= 1) {
		c = number / k + '0';
		if ((c != '0' || (k == 1) || zs)) {
			zs = 1;
			output_byte (c);
		}
		number = number % k;
		k = k / 8;
	}
    return;
}

/**
 * stores values into memory
 * @param lval
 * @return 
 * Why does store use stack for indirect, and get use indirect?
 */
void store(LVALUE *lval) {
    if (lval->indirect == 0)
        gen_put_memory (lval->symbol);
    else
        gen_put_stack (lval->indirect);
}

int rvalue(LVALUE *lval, int reg) {
    if ((lval->symbol != 0) & (lval->indirect == 0))
        gen_get_memory (lval->symbol);
    else
        gen_get_indirect (lval->indirect, reg);
    return HL_REG;
}

int rivalue(LVALUE *lval, int reg) {
    if ((lval->symbol != 0) & (lval->indirect == 0))
        gen_get_inc_memory (lval->symbol);
    else
        gen_inc_direct (lval->indirect);
    return HL_REG;
}


/**
 * parses test part "(expression)" input and generates assembly for jump
 * @param label
 * @param ft : false - test jz, true test jnz
 * @return 
 */
void test(int label, int ft) {
    needbrack ("(");
    expression (YES);
    needbrack (")");
    gen_test_jump (label, ft);
}

/**
 * scale constant depending on type
 * @param type
 * @param otag
 * @param size
 * @return 
 */
void scale_const(int type, int otag, int *size) {
    switch (type) {
        case CINT:
        case UINT:
            *size *= *size;
            break;
        case STRUCT:
            *size *= tag_table[otag].size;
            break;
        default:
            break;
    }
}
