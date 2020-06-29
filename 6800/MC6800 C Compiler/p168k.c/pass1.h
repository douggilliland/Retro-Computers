/*
* This file contains the definitions for tokens.
*/

#include "machine.h"

#include "symbol.h"
#include "tbdef.h"

#define SMC 1   /* ; */
#define LCB 2   /* { */
#define RCB 3   /* } */
#define LSB 4   /* [ */
#define RSB 5   /* ] */
#define LPR 6   /* ( */
#define RPR 7   /* ) */
#define COL 8   /* : */
#define SQU 9   /* ' */
#define DQU 10  /* " */
#define BKS 11  /* \ */
#define QUM 12  /* ? */
#define ARO 13  /* -> */
#define KEY 14  /* keyword */
#define VAR 15  /* variable */
#define CON 16  /* constant */
#define CHC 17  /* character constant */
#define STC 18  /* string constant */
#define BAD 127 /* no token */

/* adjustable quantity definitions */

#define MAXSTRNG 512
#define NUMSTRNG  10
#ifdef ALIGN
#define DMLEN 256
#define SWLEN 512
#define FORNUM 100
#define FORCON 48
#define NUMCON 128
#else
#define DMLEN 128
#define SWLEN 256
#define FORNUM 32
#define FORCON 20
#define NUMCON 64
#endif
#define SSLEN 16
#define MATLEN 127
#define ASLEN 2*MATLEN

/* structure definitions */

/* token table structure */

struct toktab {
  char ch;
  char tok;
};

/* string stack structure definition */

struct sstack {
  short stlbl;
  char *stptr;
};

/* structure info stack structure */

struct infost {
  short header;
  char number;
};

/* expression matrix structure definition */

struct express {
  char moprtr;
  short mttype;
  struct symtab *mo1loc;
  struct symtab *mo2loc;
};

/* classified operand structure */

struct classo {
  short otype;
  union {
    struct express *exp;
    struct symtab *sym;
  } oloc;
  char onode;
  char ocflag;
};

#define STNEST 10

struct ilab {
  char ityp;
  int iofset;
  int ilabn;
};

/* misc defines */

#define EOF (-1)
#define NULL 0

/* macro definitions */

#define getnch() (curchar ? curchar : (curchar = nxtchr()))

/* miscellaneous definitions */

#define FALSE 0
#define TRUE 1

#define STEXT 0
#define SDATA 1
#define SBSS 2

