/*--------------------------------- ctype.h ---------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 *
 *  The macros in ctypex.h perform the same functions as the macros with
 *  the same names in ctype.h.	The macros in ctypex.h compare character
 *  values against constants explicitly.  These macros have side effects and
 *  should not be used casually.  They are usually slower than the
 *  corresponding macros in the ctype.h file, but their use may save space if
 *  only several comparisons are being made because the _ctype_tab array is
 *  not pulled in.  The argument to isascii() may be any valid integer.
 *  Arguments to all other macros must be -1 or a valid ASCII character.
 *
 *  The function version of any of the macros defined below can be referenced
 *  by #undef'ing the macro name.
 */

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

#define isalnum(c)	(isalpha(c) || isdigit(c))
#define isalpha(c)	(isupper(c) || islower(c))
#define iscntrl(c)	((((c) >= 0x0) && ((c) <= 0x1f)) || \
			((c) == 0x7f))
#define isdigit(c)	(((c) >= '0') && ((c) <= '9'))
#define isgraph(c)	(((c) >= 0x21) && ((c) <= 0x7e))
#define islower(c)	(((c) >= 'a') && ((c) <= 'z'))
#define isprint(c)	(((c) >= 0x20) && ((c) <= 0x7e))
#define ispunct(c)	((((c) >= 0x21) && ((c) <= 0x2f)) || \
			(((c) >= 0x3a) && ((c) <= 0x40)) || \
			(((c) >= 0x5b) && ((c) <= 0x60)) || \
			(((c) >= 0x7b) && ((c) <= 0x7e)))
#define isspace(c)	((((c) >= 0x9) && ((c) <= 0xd)) || ((c) == 0x20))
#define isupper(c)	(((c) >= 'A') && ((c) <= 'Z'))
#define isxdigit(c)	((((c) >= '0') && ((c) <= '9')) || \
			(((c) >= 'a') && ((c) <= 'f')) || \
			(((c) >= 'A') && ((c) <= 'F')))

#define isodigit(c)	(((c) >= '0') && ((c) <= '7'))
#define tolower(c)	((isupper(c)) ? _tolower(c) : (c))
#define toupper(c)	((islower(c)) ? _toupper(c) : (c))
#define iscsymf(c)	(isalpha(c) || ((c) == '_'))
#define iscsym(c)	(isalnum(c) || ((c) == '_'))
#define _tolower(c)	((c)-'A'+'a')
#define _toupper(c)	((c)-'a'+'A')
#define isascii(c)	((unsigned)(c) < 0x80)
#define toascii(c)	((c) & 0x7f)

