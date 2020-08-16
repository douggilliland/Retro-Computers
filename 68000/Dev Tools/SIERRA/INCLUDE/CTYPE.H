/*--------------------------------- ctype.h ---------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  The macros in ctype.h determine character types by table lookup.  The
 *  argument to isascii() may be any valid integer.  Arguments to all other
 *  macros must be -1 or a valid ASCII character.  Most of the macros defined
 *  below cause the table _ctype_tab (128 bytes) to be pulled in.  Use the
 *  header ctypex.h is you do not want the table to be pulled in.  Note, the
 *  macros defined in ctypex.h may evaluate the argument more than once and
 *  are generally slower.
 *
 *  The function version of any of the macros defined below can be referenced
 *  by #undef'ing the macro name.
 */

extern const unsigned char _ctype_tab[];

int isalnum(int c);
int isalpha(int c);
int iscntrl(int c);
int isdigit(int c);
int isgraph(int c);
int islower(int c);
int isprint(int c);
int ispunct(int c);
int isspace(int c);
int isupper(int c);
int isxdigit(int c);
int tolower(int c);
int toupper(int c);
int isodigit(int c);
int iscsymf(int c);
int iscsym(int c);
int _tolower(int c);
int _toupper(int c);
int isascii(int c);
int toascii(int c);

#define _L  0x1		/* lower case letter */
#define _U  0x2		/* upper case letter */
#define _D  0x4		/* decimal digit     */
#define _P  0x8		/* puctuation	     */
#define _X  0x10	/* hexadecimal digit */
#define _O  0x20	/* octal digit	     */
#define _S  0x40	/* space character   */
#define _C  0x80	/* control character */

#define isalnum(c)	((_ctype_tab+1)[c] & (_L|_U|_D))
#define isalpha(c)	((_ctype_tab+1)[c] & (_L|_U))
#define iscntrl(c)	((_ctype_tab+1)[c] & _C)
#define isdigit(c)	((_ctype_tab+1)[c] & _D)
#define isgraph(c)	((_ctype_tab+1)[c] & (_U|_L|_P|_D))
#define islower(c)	((_ctype_tab+1)[c] & _L)
#define isprint(c)	(isgraph(c) || ((c) == ' '))
#define ispunct(c)	((_ctype_tab+1)[c] & _P)
#define isspace(c)	((_ctype_tab+1)[c] & _S)
#define isupper(c)	((_ctype_tab+1)[c] & _U)
#define isxdigit(c)	((_ctype_tab+1)[c] & _X)
#define tolower(c)	((isupper(c)) ? _tolower(c) : (c))
#define toupper(c)	((islower(c)) ? _toupper(c) : (c))
#define isodigit(c)	((_ctype_tab+1)[c] & _O)
#define iscsymf(c)	(isalpha(c) || ((c) == '_'))
#define iscsym(c)	(isalnum(c) || ((c) == '_'))
#define _tolower(c)	((c)-'A'+'a')
#define _toupper(c)	((c)-'a'+'A')
#define isascii(c)	((unsigned)(c) < 0x80)
#define toascii(c)	((c) & 0x7f)

/* the following macros are #undef'd because   */
/* they evaluate their argument more than once */

#undef isprint
#undef iscsymf
#undef iscsym
#undef tolower
#undef toupper

