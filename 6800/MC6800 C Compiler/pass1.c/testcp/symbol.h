
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

#define CHR 1
#define INT 2
#define SHORT 3
#define UNSND 4
#define LONG 5
#define FLOAT 6
#define DUBLE 7
#define STRUCT 11
#define UNION 12
#define ENUM 13
#define CONST 14
#define VOID 15

/* class definitions */

#define AUTO 1
#define STAT 2
#define REG 3
#define EXTN 4
#define TYPDF 5
#define STRTAG 8
#define UNNTAG 9
#define ENMTAG 10
#define MOS 11
#define MOU 12
#define MOE 13

/* type specifiers */

#define PTR 1
#define FNCT 2
#define ARAY 3

/* flag definitions */

#define FLAB 1
#define FUNION 2
#define FUND 4
#define FINIT 8
#define FFIELD 16
#define FPRM 32
#define FPSHD 64
#define FEXT 128

/* itype definitions */

#define SIDENT 1
#define STAG 2
#define SMEMBER 3
#define SLABEL 4
