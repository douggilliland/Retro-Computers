/*
*  Pass 2 structure definitions
*/

/* Entry for an operand in the expression matrix */

struct operand {
  char optype;
  union {
    struct {
      char nclass;
      int ntype;
      union {
        int nampos;
        char namext[8];
      } ndata;
    } name;
    struct {
      char ctype;
      union {
        int cint;
        long clong;
        int cfp[4];
      } cdata;
    } cons;
    struct {
      int nnum;
    } node;
    struct {
      char ltype;
      int lnum;
    } lbl;
    struct {
      char btype;
      char bltyp1;
      int blnum1;
      char bltyp2;
      int blnum2;
    } blx;
    struct {
      char bxcon;
      char bxtyp;
      int bxlnum;
    } brx;
  } opkind;
};

/* Entry of the expression matrix */

struct express {
  int rslt;
  char operator;
  int rtype;
  struct operand op1;
  struct operand op2;
};

#define MAXEXP 132


/* Result types */

#define NOREG 0
#define DATREG 0x10
#define ADRREG 0x20
#define LNGREG 0x30
#define FPPREG 0x40
#define ARREF 0x80
#define BREG 0
#define DREG 1
#define XREG 0
#define YREG 1
#define UREG 2
#define NREF 1
#define TREF 2
#define BREF 3
#define CREF 4
#define LREF 5

/* Type definitions */

#define VOID 0
#define UNS 1
#define CHR 2
#define SHORT 4
#define INT 6
#define UNSND (INT|UNS)
#define LONG 8
#define FLOAT 10
#define DUBLE 11
#define STRUCT 12
#define CONST 15

#define PTR 1
#define FNCT 2
#define ARAY 3

/* Class definitions */

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

/* Address register structure */

struct addreg {
  int ar_ref;                  /* reference type */
  int ar_off;                  /* offset */
  int ar_ofr;                  /* register offset */
  int ar_inc;                  /* increment */
  int ar_ind;                  /* indirection level */
  char ar_pre;                 /* pre or post increment */
  char ar_chg;                 /* changed flag */
  int *ar_con;                 /* pointer to constant value */
  union {
    int ad_val;
    char ad_nam[8];
    } ar_data;                 /* data */
};

#define NUMADR 48

#define OFFB 1
#define OFFD 2

/* d contents structure */

struct dstruct {
  int d_ref;
  union {
    int d_val;
    char d_name[8];
  } d_data;
};

/* additional il ops not in il.h */

#define BRX 128
#define BLX 129
#define LBL 130

#define EOF (-1)

#define MAXSWT 256
#define NUMLOG 32

#define BFALSE 0
#define BTRUE 1
#define BALWAYS 2
#define LOCLAB 0
#define REGLAB 1

#define EQ 0
#define NE 1
#define LT 2
#define GT 3
#define LE 4
#define GE 5

#define NULL 0

