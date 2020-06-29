#include "machine.h"

/* symbol table structure */

struct symtab {
  short stype;
  char sclass;
  char sflags;
  char *sname;
  short sstore;
  char sblklv;
  char sitype;
  int *ssubs;
  short sstrct;
  short spoint;
  char sstrnum;
  char smemnum;
};

/* type defines */

#define VOID 0
#define UNS 1
#define CHR 2
#define SHORT 4
#define INT 6
#define LONG 8
#define UNSND (INT|UNS)
#define FLOAT 10
#define DUBLE 11
#define STRUCT 12
#define UNION 13
#define ENUM 14
#define CONST 15

/* class definitions */

#define AUTO 1
#define STAT 2
#define REG 3
#define EXTN 4
#define TYPDF 5
#define STRTAG 8
#define UNNTAG 9
#define ENMTAG 10
#define MOS 12
#define MOU 13
#define MOE 14

/* type specifiers */

#define PTR 1
#define FNCT 2
#define ARAY 3

/* flag definitions */

#define FLAB 1
#define FSTATIC 2
#define FUND 4
#define FINIT 8
#define FFIELD 16
#define FPRM 32
#define FALND 64
#define FEXT 128

/* itype definitions */

#define SIDENT 1
#define STAG 2
#define SMEMBER 3
#define SLABEL 4

