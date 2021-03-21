/*	ccopt.c

	Mike's Enhanced Small C Compiler for Z80 & CP/M.

	New peephole optimizer with customizable rules, for MESCC v1.10 or higher.

	Copyright (c) 2015 Miguel I. Garcia Lopez, FloppySoftware.

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation; either version 2, or (at your option) any
	later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

	Revisions:

	29 Oct 2015 : Work started from scratch (not based at all on previous ccopt).
	02 Nov 2015 : Work on defining rules.
	04 Nov 2015 : Work on binary expressions.
	05 Nov 2015 : Work on unary expressions.
	09 Nov 2015 : Added verbose flag.
	01 Dec 2015 : More space for buffers. Cleaned. Removed verbose flag.
	02 Dec 2015 : Cleaned.

	v2.00

	10 Jan 2016 : v2.01 : Cleaned a bit.
	28 Jan 2016 : v2.02 : Added 'line too long' error. Solved bug in get_sym().
	                      Improved test_rule() and test_line().
	                      Modified get_num().

	Rules:

	Symbol fields are specified as @a to @e.
	Decimal constant fields are specified as @0 to @4.

	The first time a field specificacion is found in the rule, the scanner tries to read
	its value from the source - ie:

	@b -- symbol name expected
	@3 -- decimal constant expected

	The following time(s) a field specification is found in the rule, the scanner tries to
	match the field value with the next characters in the source.

	Output:

	Constant operations can be specified as:

	@=1+2	To perform a signed add with @1 and @2.

	Or, for unary expressions:

	@=!1    To perform a logical not of @1

	Valir operators are:

	+ Add
	???????????????


	Usage:

	ccopt file [-r]
*/

/* MESCC standard libraries
*/
#include <mescc.h>
#include <ctype.h>
#include <string.h>
#include <mem.h>
#include <alloc.h>
#include <fileio.h>
#include <printf.h>
#include <fprintf.h>
#include <sprintf.h>

/* Rules
*/
#include "ccopt.h"

/* Defs.
*/
#define APP_NAME    "ccopt"
#define APP_VERSION "v2.02 / 28 Jan 2016"
#define APP_COPYRGT "(c) 2015-2016 FloppySoftware"
#define APP_USAGE   "ccopt file [-r]"

#define DEBUG 0         /* != 0 to DEBUG */

#define SPECIAL   '@'   /* Special character for fields, etc. */
#define SPC_NUMOP '='   /* Subspecial char. for numeric operations */

#define GEN_COMMENT '#' /* Comment in rules */

#define SKIP_ON  ";["   /* Skip this line and following */
#define SKIP_OFF ";]"   /* Stop skipping lines */

#define LIN_TOT 24     /* Max. # of lines in buffer */
#define LIN_MAX 16     /* Max. # of lines to fill */
#define LIN_LEN 127    /* Max. length of each line */
#define LIN_SIZ 128    /* Max. length of each line + ZERO */

WORD lin[LIN_TOT];     /* char *lin[LIN_TOT] */
int lin_skip[LIN_TOT]; /* True if this line has to be skipped in the rule test */
int lines;             /* Lines in array */

int skip;              /* NZ if we are in skip mode */

#define SYM_MAX 5      /* Max. # of symbol variables: @a to @e */
#define SYM_LEN 11     /* Variable length in characters */
#define SYM_SIZ 12     /* Variable length in characters + ZERO */

WORD sym[SYM_MAX];     /* char *sym[SYM_MAX] */

#define NUM_MAX 5      /* Max. # of number variables: @0 to @4 */
#define NUM_LEN 6      /* Variable length in characters */
#define NUM_SIZ 7      /* Variable length in characters + ZERO */

WORD num[NUM_MAX];     /* char *num[NUM_MAX] */

FILE *fp_in;               /* Input file */
FILE *fp_out;              /* Output file */

char fn_in[FILENAME_MAX];  /* Input file */
char fn_out[FILENAME_MAX]; /* Output file */

#define FTYPE_ASM ".ZSM"  /* Filetype for ZSM files */
#define FTYPE_TMP ".$$$"  /* Filetype for temporary files */

#define FTYPE_RUL ".RUL"  /* Filetype for rule files */
#define FTYPE_OUT ".H"    /* Filetype for H files */

extern int rules_max;     /* # of rules */
extern WORD rules[];      /* char *rules[] */
extern int rules_saved[]; /* # of saved bytes for each rule */

int saved;                /* Total # of saved bytes */

int out_lines;            /* # of lines written */

#define LAB_MAX 2048      /* Max. # of labels */
#define LAB_LEN 11        /* Label length */
#define LAB_SIZ 12        /* Label length + ZERO */

char *lab_names;          /* Label names */
int *lab_lines;           /* Line # for each label */
int labels;               /* # of stored labels */

#define JP_REL 48         /* Change from JP to JR: -48 / + 48 */

int jumps_saved;          /* # of bytes saved in jumps */

/* Error codes
*/
#define ERR_BAD_OPT   10 /* Bad option */
#define ERR_BAD_CMD   11 /* Bad command line */

#define ERR_OPEN      20 /* Can't open */
#define ERR_CLOSE     21 /* Can't close */
#define ERR_READ      22 /* Can't read */
#define ERR_WRITE     23 /* Can't write */
#define ERR_FNAME     24 /* Bad filename */

#define ERR_LN_LONG   25 /* Line too long */

#define ERR_NO_MEM    28 /* Not enough memory */

#define ERR_NO_ROOM   31 /* No room for more lines in buffer */
#define ERR_NO_VAR    32 /* Undefined variable */
#define ERR_NO_SPC    33 /* Bad special format */
#define ERR_NO_FIELD  34 /* Bad field */
#define ERR_TM_LABELS 35 /* Too many labels */
#define ERR_TM_LINES  36 /* Too many lines in rule */
#define ERR_NO_RULE   37 /* Bad rule specification */

/* Entry point
*/
main(argc, argv)
int argc, argv[]; /* char *argv[] */
{
	/* Copyright etc. */

	printf("%s %s\n\n", APP_NAME, APP_VERSION);
	printf("%s\n\n", APP_COPYRGT);

	/* Usage */

	if(argc == 1) {
		printf("Usage: %s\n", APP_USAGE);
		exit(0);
	}

	/* Check options */

	if(argc > 2) {
		if(argc > 3)
			error(ERR_BAD_CMD);

		/* Option -R : Generate rules */

		if(!strcmp(strupr(argv[2]), "-R")) {

			/* Option: Generate rules */

			set_fnames(argv[1], FTYPE_RUL, FTYPE_OUT);

			gen_rules();

		}
		else
			error(ERR_BAD_OPT);
	}
	else {

		/* Optimize */

		set_fnames(argv[1], FTYPE_ASM, FTYPE_TMP);

		optimize();
	}

	/* Success */

	return 0;
}

/* Set input and output filenames
*/
set_fnames(fn, tpin, tpout)
char *fn, *tpin, *tpout;
{
	if(strchr(fn, '.') != NULL
		|| strlen(fn) + strlen(tpin) >= FILENAME_MAX
		|| strlen(fn) + strlen(tpout) >= FILENAME_MAX)
			error_ext(ERR_FNAME, fn);

	strcpy(fn_in, fn); strcat(fn_in, tpin);
	strcpy(fn_out, fn); strcat(fn_out, tpout);
}

/* Open input file
*/
open_in()
{
	if((fp_in = fopen(fn_in, "r")) == NULL)
		error_ext(ERR_OPEN, fn_in);
}

/* Close input file
*/
close_in()
{
	fclose(fp_in);
}

/* Open input and output files
*/
open_all()
{
	/* Open input file */

	open_in();

	/* Open output file */

	if((fp_out = fopen(fn_out, "w")) == NULL)
		error_ext(ERR_OPEN, fn_out);
}

/* Close input and output files
*/
close_all()
{
	close_in();

	if(fclose(fp_out))
		error_ext(ERR_CLOSE, fn_out);
}

/* Generate rules
*/
gen_rules()
{
	int i, no;
	char *pch;

	printf("Generating rules:\n\n");

	/* Alloc memory for buffer lines */

	lin_alloc();

	/* Reset lines */

	lin_reset();

	/* Setup */

	no = 0;

	/* Open input and output files */

	open_all();

	/* Write header */

	if(fprintf(fp_out, "/* Include file for CCOPT, the MESCC optimizer */\n\n#asm\n") < 0)
		error_ext(ERR_WRITE, fn_out);

	/* Write rules */

	while(1) {

		/* Read rule lines */

		if(!gen_fill())
			break;

		if(lines > LIN_MAX)
			error(ERR_TM_LINES);

		printf("Rule #%d.\n", no);

		/* Write # of lines in rule */

		if(fprintf(fp_out, "rule%d\n DEFB %d\n", no++, lines) < 0)
			error_ext(ERR_WRITE, fn_out);

		/* Write rule lines */

		for(i = 0; i < lines; ++i) {
			if(fprintf(fp_out, " DEFB '%s', 0\n", lin[i]) < 0)
				error_ext(ERR_WRITE, fn_out);
		}

		/* Read output lines */

		gen_fill();

		if(lines > LIN_MAX)
			error(ERR_TM_LINES);

		/* Write # of output lines */

		if(fprintf(fp_out, " DEFB %d\n", lines) < 0)
			error_ext(ERR_WRITE, fn_out);

		/* Write output lines */

		for(i = 0; i < lines; ++i) {
			if(fprintf(fp_out, " DEFB '%s', 0\n", lin[i]) < 0)
				error_ext(ERR_WRITE, fn_out);
		}

		/* Go to # of bytes saved, skip comments */

		while((pch = read_line(fp_in, lin[0])) != NULL) {
			if(*pch != GEN_COMMENT)
				break;
		}

		if(pch == NULL)
			error(ERR_NO_RULE);

		/* Write # of bytes saved */

		if(fprintf(fp_out, " DEFB %s\n\n", lin[0]) < 0)
			error_ext(ERR_WRITE, fn_out);
	}

	/* Write array of rule pointers */

	if(!no)
		error(ERR_NO_RULE);

	if(fprintf(fp_out, "rules\n") < 0)
		error_ext(ERR_WRITE, fn_out);

	for(i = 0; i < no; ++i) {
		if(fprintf(fp_out, " DEFW rule%d\n", i) < 0)
			error_ext(ERR_WRITE, fn_out);
	}

	/* Write # of rules */

	if(fprintf(fp_out, "\nrules_max\n DEFW %d\n", no) < 0)
		error_ext(ERR_WRITE, fn_out);

	/* Write array of # of bytes saved in each rule */

	if(fprintf(fp_out, "\nrules_saved\n DEFS %d\n", no + no) < 0)
		error_ext(ERR_WRITE, fn_out);

	/* Write footer */

	if(fprintf(fp_out, "#endasm\n") < 0)
		error_ext(ERR_WRITE, fn_out);

	/* Close input and output files */

	close_all();

	printf("\nDone.\n");
}

/* Optimize (test rules and jumps)
*/
optimize()
{
	int i, t_saved, pass;

	printf("Optimizing (%d rules):\n\n", rules_max);

	/* Alloc memory for buffer lines and variables */

	lin_alloc();
	var_alloc();

	/* Setup */

	// jumps_saved = saved = 0;

	pass = 1;

	/* Do a pass */

	do {
		printf("Rules - pass #%d: ", pass++);

		t_saved = saved;

		/* Reset lines */

		lin_reset();

		/* Reset values */

		out_lines = skip = 0;

		/* Test all rules */

		test_rules();

		/* Swap filenames */

		swap_fnames();

		printf("%4d bytes saved.\n", saved - t_saved);

	} while(t_saved != saved);

	/* Test jumps */

	printf("\nJumps: ");

	/* Alloc memory for labels */

	lab_alloc();

	/* Setup */

	//labels = 0;

	/* Read all labels */

	read_labels();

	/* Test jumps */

	test_jumps();

	printf("%4d bytes saved (%d labels found).\n", jumps_saved, labels);

	/* Remove input file */

	remove(fn_in);

	/* Rename output file? */

	if(pass % 2)
		rename(fn_out, fn_in); // TMP to ZSM

	/* Final report */

	printf("\nTotal saved: %4d bytes (Rules: %4d, Jumps: %4d)\n\nDone.\n",
		t_saved + jumps_saved, t_saved, jumps_saved);

	//printf("%d lines in file\n", out_lines);

/*****************
	for(i = 0; i < rules_max; ++i) {
		if(!rules_saved[i])
			printf("Rule #%d not used?\n", i);
	}
********************/


/****************
	if(labels) {
		printf("%d labels:\n", labels);

		for(i = 0; i < labels; ++i)
			printf("%5d = %5d : %s\n", i, lab_lines[i], lab_names + i * LAB_SIZ);
	}
***************/
}

/* Read all labels in input file
*/
read_labels()
{
	int line, skip;
	char *buf;

	/* Open input file */

	open_in();

	/* Setup */

	buf = lin[0];

	line = skip = 0;

	/* Read all input lines */

	while(read_line(fp_in, buf) != NULL) {

		/* Skip lines between #asm and #endasm */

		if(skip) {
			if(!strcmp(buf, SKIP_OFF))
				skip = 0;
		}
		else if(!strcmp(buf, SKIP_ON)) {
			skip = 1;
		}
		else if(isalpha(*buf)) {

			/* Get label */

			if(labels >= LAB_MAX)
				error(ERR_TM_LABELS);

			if(get_field(lab_names + labels * LAB_SIZ, buf, LAB_LEN, 0) != NULL)
				lab_lines[labels++] = line;
		}

		++line;
	}

	/* Close input file */

	close_in();
}

/* Test all jumps, changing from JP to JR if possible
*/
test_jumps()
{
	int i, line, skip, rel;
	char *buf, *pch, *plb;

	// FIXME: Do a sort and find labels by binary search?

	/* Open input and output files */

	open_all();

	/* Setup */

	buf = lin[0];

	line = skip = 0;

	/* Read all input lines */

	while(read_line(fp_in, buf) != NULL) {

		/* Skip lines between #asm and #endasm */

		if(skip) {
			if(!strcmp(buf, SKIP_OFF))
				skip = 0;
		}
		else if(!strcmp(buf, SKIP_ON)) {
			skip = 1;
		}
		else if(!memcmp(buf, " JP ", 4)) {

			pch = buf + 4;

			if(!memcmp(pch, "Z,", 2))
				pch += 2;
			else if(!memcmp(pch, "NZ,", 3))
				pch += 3;
			else if(!memcmp(pch, "C,", 2))
				pch += 2;
			else if(!memcmp(pch, "NC,", 3))
				pch += 3;
			else if(!memcmp(pch, "M,", 2))
				pch = NULL;
			else if(!memcmp(pch, "P,", 2))
				pch = NULL;
			else if(!memcmp(pch, "PE,", 3))
				pch = NULL;
			else if(!memcmp(pch, "PO,", 3))
				pch = NULL;

			/* Search this label */

			if(pch != NULL) {

				plb = lab_names;

				for(i = 0; i < labels; ++i) {

					/* Match? */

					if(!strcmp(pch, plb)) {

						/* Match */

						rel = line - lab_lines[i];

						if(rel < 0)
							rel = -rel;

						/* Change from JP to JR */

						if(rel <= JP_REL) {
							buf[2] = 'R';
							++jumps_saved;
							break;
						}
					}

					/* Next label */

					plb += LAB_SIZ;
				}
			}
		}

		/* Write the line */

		if(fprintf(fp_out, "%s\n", buf) < 0)
			error_ext(ERR_WRITE, fn_out);

		++line;
	}

	/* Close input and output files */

	close_all();
}

/* Test all rules
*/
test_rules()
{
	int i;
	char *pch;

	/* Open input and output files */

	open_all();

	/* Test all input lines */

	while(fill_lines()) {

		/* Skip this line? */

		if(!lin_skip[0]) {

			/* Test all rules against lines in buffer */

			for(i = 0; i < rules_max; ++i) {

#if DEBUG
	printf("DEBUG: Testing rule %3d, line %4d", i, out_lines);
#endif

				/* Match? */

				if((pch = test_rule(rules[i])) != NULL) {

#if DEBUG
	printf(" : MATCH");
#endif

					/* Match */

					rules_saved[i] += *pch;
					saved += *pch;

					/* Exit on EOF */

					if(!fill_lines())
						break;

					/* Skip this line? */

					if(lin_skip[0])
						break;

					/* Loop again from the beginning */

					i = -1;
				}
#if DEBUG
	printf("\n");
#endif
			}

			/* Exit on EOF */

			if(!lines)
				break;
		}

		/* Out 1st line in buffer */

		if(fprintf(fp_out, "%s\n", lin[0]) < 0)
			error_ext(ERR_WRITE, fn_out);

		++out_lines;

		make_room(-1);
	}

	/* Close input and output files */

	close_all();
}

/* Test and output a rule
   ----------------------
   Returns pointer to bytes saved field on success,
   or NULL on failure.
*/
test_rule(rul_ptr)
char *rul_ptr;
{
	int i, rul_lines;
	char *pch;

	/* Number of lines in the rule */

	rul_lines = *rul_ptr++;

	/* Abort if there are not enough lines in buffer */

	if(lines < rul_lines)
		return NULL;

	/* Reset variables */

	//var_reset();

	for(i = 0; i < SYM_MAX; ++i) {
		*(pch = sym[i]) = '\0';
	}

	for(i = 0; i < NUM_MAX; ++i) {
		*(pch = num[i]) = '\0';
	}

	/* Test all lines in rule */

	for(i = 0; i < rul_lines; ++i) {

		if(lin_skip[i])
			return NULL;

		if((rul_ptr = test_line(rul_ptr, lin[i])) == NULL)
			return NULL;
	}

	/* Success */

	return out_rule(rul_ptr, rul_lines);
}

/* Test a rule line
   ----------------
   Returns pointer to following char. after the line + ZERO (next rule line or ZERO) on success,
   or NULL on failure.
*/
test_line(rul_line, src_line)
char *rul_line, *src_line;
{
	char *pch;
	int len;

	/* Process the whole rule line */

	while(*rul_line) {

		/* Check EOL in source line */

		//if(!(*src_line))
		//	return NULL;

		/* Check normal character in rule line */

		if(*rul_line != SPECIAL) {

			//if(*rul_line != *src_line)
			//	return NULL;

			//++rul_line;
			//++src_line;
			//continue;

			if(*rul_line++ == *src_line++)
				continue;

			return NULL;
		}

		/* It's special */

		++rul_line;

		if((pch = get_sym(rul_line)) != NULL) {
			if(*pch) {
				if(memcmp(src_line, pch, (len = strlen(pch))))
					return NULL;

				src_line += len;
			}
			else if((src_line = get_field(pch, src_line, SYM_LEN, 0)) == NULL)
				return NULL;
		}
		else if((pch = get_num(rul_line)) != NULL) {
			if(*pch) {
				if(memcmp(src_line, pch, (len = strlen(pch))))
					return NULL;

				src_line += len;
			}
			else if((src_line = get_field(pch, src_line, NUM_LEN, 1)) == NULL)
				return NULL;
		}
		else if(*rul_line == SPECIAL) {
			if(*src_line++ != SPECIAL)
				return NULL;
		}
		else
			error(ERR_NO_SPC);

		++rul_line;
	}

	/* rul_line is exhausted */

	return *src_line ? NULL : ++rul_line;
}

/* Get field value
   ---------------
   Fills dst with value + ZERO from src, and returns updated src pointer,
   or NULL on failure.
*/
get_field(dst, src, max, dec)
char *dst, *src; int max, dec;
{
	int ch, len;

	/* Setup counter */

	len = max;

	/* Numeric or alphanumeric? */

	if(dec) {
		if(*src == '-') {
			*dst++ = *src++; --len;
		}
	}
	else if(!isalpha(*src))
		return NULL;

	/* Read value */

	while((ch = *src)) {

		/* Read char. */

		if(dec ? isdigit(ch) : isalpha(ch) || isdigit(ch) || ch == '_') {

			if(len--)
				*dst++ = *src++;
			else
				return NULL;
		}
		else
			break;
	}

	/* Set ZERO */

	*dst = '\0';

	/* Return success or failure */

	return len < max ? src : NULL;
}

/* Transform and output a rule
   ---------------------------
   Return pointer to the bytes saved.
*/
out_rule(out_ptr, rul_lines)
char *out_ptr; int rul_lines;
{
	int i, prt_lines;

	prt_lines = *out_ptr++;

	make_room(prt_lines - rul_lines);

	for(i = 0; i < prt_lines; ++i)
		out_ptr = out_line(out_ptr, lin[i]);

	return out_ptr;
}

/* Transform and output a rule line
   --------------------------------
   Returns pointer to following char. after the ZERO.
*/
out_line(out_ptr, dst_ptr)
char *out_ptr, *dst_ptr;
{
	int s1, s2, r;
	char *pch;
	int ch1, ch2;

	while(*out_ptr) {

		if(*out_ptr != SPECIAL) {
			*dst_ptr++ = *out_ptr++;
			continue;
		}

		/* It's special */

		++out_ptr;

		if(*out_ptr == SPC_NUMOP) {

			if(!isdigit(*(++out_ptr))) {

				/* Unary expression? */

				ch1 = *out_ptr++;

				if((pch = get_num(out_ptr++)) == NULL)
					error(ERR_NO_SPC);

				s1 = atoi(pch);

				switch(ch1) {
					case '!' : r = !s1; break;
					case '-' : r = -s1; break;
					case '~' : r = ~s1; break;
					default  : error(ERR_NO_SPC); break;
				}

				sprintf(dst_ptr, "%d", r);
				dst_ptr += strlen(dst_ptr);

				continue;
			}

			/* Binary expression? */

			if((pch = get_num(out_ptr++)) == NULL)
				error(ERR_NO_SPC);

			s1 = atoi(pch);

			ch1 = *out_ptr++;
			ch2 = isdigit(*out_ptr) ? 0 : *out_ptr++;

			if((pch = get_num(out_ptr)) == NULL)
				error(ERR_NO_SPC);

			s2 = atoi(pch);

			switch(ch1) {
				case '+' : r = s1 + s2; break;
				case '-' : r = s1 - s2; break;
				case '*' : r = s1 * s2; break;
				case '/' : r = s1 / s2; break;
				case '%' : r = s1 % s2; break;
				case '|' :
					if(!ch2) {
						r = s1 | s2;
					}
					else if(ch2 == '|') {
						r = s1 || s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				case '&' :
					if(!ch2) {
						r = s1 & s2;
					}
					else if(ch2 == '&') {
						r = s1 && s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				case '^' : r = s1 ^ s2; break;
				case '=' :
					if(ch2 == '=') {
						r = s1 == s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				case '!' :
					if(ch2 == '=') {
						r = s1 != s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				case '>' :
					if(!ch2) {
						r = s1 > s2;
					}
					else if(ch2 == '=') {
						r = s1 >= s2;
					}
					else if(ch2 == '>') {
						r = s1 >> s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				case '<' :
					if(!ch2) {
						r = s1 < s2;
					}
					else if(ch2 == '=') {
						r = s1 <= s2;
					}
					else if(ch2 == '<') {
						r = s1 << s2;
					}
					else
						error(ERR_NO_SPC);
					break;
				default  : error(ERR_NO_SPC);
			}

			sprintf(dst_ptr, "%d", r);
			dst_ptr += strlen(dst_ptr);
		}
		else if((pch = get_sym(out_ptr)) != NULL) {
			if(*pch) {
				strcpy(dst_ptr, pch); dst_ptr += strlen(pch);
			}
			else
				error(ERR_NO_VAR);
		}
		else if((pch = get_num(out_ptr)) != NULL) {
			if(*pch) {
				strcpy(dst_ptr, pch); dst_ptr += strlen(pch);
			}
			else
				error(ERR_NO_VAR);
		}
		else if(*out_ptr == SPECIAL)
			*dst_ptr++ = SPECIAL;
		else
			error(ERR_NO_SPC);

		++out_ptr;
	}

	*dst_ptr = '\0';

	return ++out_ptr;
}

/* Make room in buffer
   -------------------
   Positive values, adds lines on top. Negative values, delete lines on top.
*/
make_room(howmany)
int howmany;
{
	int i;
	char *tmp_adr;

	if(howmany > 0) {
		if(lines + howmany > LIN_TOT)
			error(ERR_NO_ROOM);

		lines += howmany;

		for(i = lines - 1; i >= howmany; --i) {
			tmp_adr = lin[i];
			lin[i] = lin[i - howmany];
			lin[i - howmany] = tmp_adr;

			lin_skip[i] = lin_skip[i - howmany];
			lin_skip[i - howmany] = 0;
		}
	}
	else if(howmany < 0) {

		howmany = -howmany;
		lines -= howmany;

		for(i = 0; i < lines; ++i) {
			tmp_adr = lin[i];
			lin[i] = lin[i + howmany];
			lin[i + howmany] = tmp_adr;

			lin_skip[i] = lin_skip[i + howmany];
			//lin_skip[i + howmany] = 0;
		}
	}
}

/* Get memory for buffer lines
*/
lin_alloc()
{
	int i;
	char *pch;

	if((pch = malloc(LIN_TOT * LIN_SIZ)) == NULL)
		error(ERR_NO_MEM);

	for(i = 0; i < LIN_TOT; ++i) {
		lin[i] = pch;
		pch += LIN_SIZ;
	}
}

/* Reset lines in buffer
*/
lin_reset()
{
	int i;
	char *pch;

	for(i = 0; i < LIN_TOT; ++i) {
		*(pch = lin[i]) = lin_skip[i] = 0;
	}
}

/* Get memory for variables
*/
var_alloc()
{
	int i;
	char *pch;

	/* Symbol variables */

	if((pch = malloc(SYM_MAX * SYM_SIZ)) == NULL)
		error(ERR_NO_MEM);

	for(i = 0; i < SYM_MAX; ++i) {
		sym[i] = pch;
		pch += SYM_SIZ;
	}

	/* Number variables */

	if((pch = malloc(NUM_MAX * NUM_SIZ)) == NULL)
		error(ERR_NO_MEM);

	for(i = 0; i < NUM_MAX; ++i) {
		num[i] = pch;
		pch += NUM_SIZ;
	}
}

/* Reset variables
*/
/********************************
var_reset()
{
	int i;
	char *pch;

	for(i = 0; i < SYM_MAX; ++i) {
		*(pch = sym[i]) = '\0';
	}

	for(i = 0; i < NUM_MAX; ++i) {
		*(pch = num[i]) = '\0';
	}
}
******************************/

/* Search number variable
   ----------------------
   Returns address, or NULL.
*/
get_num(pch)
char *pch;
{
	//if(isdigit(*pch))
	if(*pch >= '0' && *pch < '0' + NUM_MAX)
		return num[*pch - '0'];

	return NULL;
}

/* Search symbol variable
   ----------------------
   Returns address, or NULL.
*/
get_sym(pch)
char *pch;
{
	if(*pch >= 'a' && *pch < 'a' + SYM_MAX)
		return sym[*pch - 'a'];

	return NULL;
}

/* Get memory for labels
*/
lab_alloc()
{
	lab_names = malloc(LAB_MAX * LAB_SIZ);
	lab_lines = malloc(LAB_MAX * sizeof(int));

	if(lab_names == NULL || lab_lines == NULL)
		error(ERR_NO_MEM);
}

/* Fill the buffer on optimization
   -------------------------------
   Returns # of lines in buffer (0 means EOF).
*/
fill_lines()
{
	int i;
	char *pch;

	for(i = lines; i < LIN_MAX; ++i) {

		/* Read a line */

		if((pch = read_line(fp_in, lin[i])) == NULL) {
			break;
		}

		++lines;

		/* Skip lines between #asm and #endasm */

		if(skip) {
			lin_skip[i] = 1; // Skip this line

			if(!strcmp(pch, SKIP_OFF))
				skip = 0; // Don't skip next lines
		}
		else if(!strcmp(pch, SKIP_ON))
			lin_skip[i] = skip = 1;
		else if(!(*pch) || *pch == ';')
			lin_skip[i] = 1;
		else
			lin_skip[i] = 0;
	}

	/* Return # of lines in buffer */

	return lines;
}

/* Fill the buffer on rules generation
   -----------------------------------
   Returns # of lines in buffer (0 means EOF).
*/
gen_fill()
{
	int i;
	char *pch;

	for(i = lines = 0; i < LIN_TOT; ++i) {
		if((pch = read_line(fp_in, lin[i])) == NULL) {
			break;
		}

		/* Skip comments */

		if(*pch == GEN_COMMENT) {
			--i;
			continue;
		}

		/* End of block? */

		if(!(*pch))
			break;

		/* One line more */	

		++lines;

		/* Abort on overflow */

		if(lines > LIN_MAX)
			break;
	}

	/* Return # of lines in buffer */

	return lines;
}

/* Read a line from a file
   -----------------------
   Returns pointer to buffer, or NULL on EOF.
*/
read_line(fp, buf)
FILE *fp; char *buf;
{
	int i, ch;
	char *pch;

	pch = buf;

	for(i = 0; (ch = fgetc(fp)) != EOF; ++i) {

		if(ch == '\n')
			break;

		if(i == LIN_LEN)
			error(ERR_LN_LONG); /* Line too long */

		*pch++ = ch;
	}

	if(ch == EOF && !i)
		return NULL;

	*pch = '\0';

	return buf;
}

/* Swap two filenames
*/
swap_fnames()
{
	int ch, i;

	for(i = 0; i < FILENAME_MAX; ++i) {
		ch = fn_in[i]; fn_in[i] = fn_out[i]; fn_out[i] = ch;
	}
}

/* Print extended error message and exit
*/
error_ext(err, ext)
int err; char *ext;
{
	char *s;

	switch(err) {
		case ERR_BAD_OPT:   s = "Bad option"; break;
		case ERR_BAD_CMD:   s = "Bad command line"; break;

		case ERR_OPEN:      s = "Can't open"; break;
		case ERR_CLOSE:     s = "Can't close"; break;
		case ERR_READ:      s = "Can't read"; break;
		case ERR_WRITE:     s = "Can't write"; break;
		case ERR_FNAME:     s = "Bad filename"; break;

		case ERR_LN_LONG:   s = "Line too long"; break;

		case ERR_NO_MEM:    s = "Not enough memory"; break;

		case ERR_NO_ROOM:   s = "No room for more lines in buffer"; break;
		case ERR_NO_VAR:    s = "Undefined variable"; break;
		case ERR_NO_SPC:    s = "Bad special format"; break;
		case ERR_NO_FIELD:  s = "Bad field"; break;
		case ERR_TM_LABELS: s = "Too many labels"; break;
		case ERR_TM_LINES:  s = "Too many lines"; break;
		case ERR_NO_RULE:   s = "Bad rule format"; break;

		default :           s = "Unknown error"; break;
	}

	if(ext == NULL)
		printf("\n\n%s.", s);
	else
		printf("\n\n%s: %s.", s, ext);

	exit(-1);
}

/* Print simple error message and exit
*/
error(err)
int err;
{
	error_ext(err, NULL);
}
