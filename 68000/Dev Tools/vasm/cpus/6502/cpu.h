/*
** cpu.h 650x/65C02/6510/6280 cpu-description header-file
** (c) in 2002,2008,2009,2014,2018,2020 by Frank Wille
*/

#define BIGENDIAN 0
#define LITTLEENDIAN 1
#define VASM_CPU_650X 1

/* maximum number of operands for one mnemonic */
#define MAX_OPERANDS 3

/* maximum number of mnemonic-qualifiers per mnemonic */
#define MAX_QUALIFIERS 0

/* data type to represent a target-address */
typedef int32_t taddr;
typedef uint32_t utaddr;

/* minimum instruction alignment */
#define INST_ALIGN 1

/* default alignment for n-bit data */
#define DATA_ALIGN(n) 1

/* operand class for n-bit data definitions */
#define DATA_OPERAND(n) DATAOP

/* returns true when instruction is valid for selected cpu */
#define MNEMONIC_VALID(i) cpu_available(i)

/* parse cpu-specific directives with label */
#define PARSE_CPU_LABEL(l,s) parse_cpu_label(l,s)

/* we define two additional unary operations, '<' and '>' */
int ext_unary_type(char *);
int ext_unary_eval(int,taddr,taddr *,int);
int ext_find_base(symbol **,expr *,section *,taddr);
#define LOBYTE (LAST_EXP_TYPE+1)
#define HIBYTE (LAST_EXP_TYPE+2)
#define EXT_UNARY_NAME(s) (*s=='<'||*s=='>')
#define EXT_UNARY_TYPE(s) ext_unary_type(s)
#define EXT_UNARY_EVAL(t,v,r,c) ext_unary_eval(t,v,r,c)
#define EXT_FIND_BASE(b,e,s,p) ext_find_base(b,e,s,p)

/* type to store each operand */
typedef struct {
  int type;
  expr *value;
  utaddr dp;
} operand;


/* additional mnemonic data */
typedef struct {
  unsigned char opcode;
  unsigned char zp_opcode;  /* !=0 means optimization to zero page allowed */
  uint16_t available;
} mnemonic_extension;

/* available */
#define M6502    1       /* standard 6502 instruction set */
#define ILL      2       /* illegal 6502 instructions */
#define DTV      4       /* C64 DTV instruction set extension */
#define M65C02   8       /* basic 65C02 extensions on 6502 instruction set */
#define WDC02    16      /* WDC65C02 extensions on 65C02 instruction set */
#define CSGCE02  32      /* CSG65CE02 extensions on WDC65C02 instruction set */
#define HU6280   64      /* HuC6280 extensions on WDC65C02 instruction set */


/* adressing modes */
#define IMPLIED  0
#define ABS      1       /* $1234 */
#define ABSX     2       /* $1234,X */
#define ABSY     3       /* $1234,Y */
#define INDIR    4       /* ($1234) - JMP only */
#define INDX     5       /* ($12,X) */
#define INDY     6       /* ($12),Y */
#define DPINDIR  7       /* ($12) */
#define INDIRX   8       /* ($1234,X) - JMP only */
#define ZPAGE    9       /* add ZPAGE-ABS to optimize ABS/ABSX/ABSY */
#define ZPAGEX   10
#define ZPAGEY   11
#define RELJMP   12      /* B!cc/JMP construction */
#define REL      13      /* $1234 - 8-bit signed relative branch */
#define IMMED    14      /* #$12 */
#define WBIT     15      /* bit-number (WDC65C02) */
#define DATAOP   16      /* data operand */
#define ACCU     17      /* A */
#define DUMX     18      /* dummy X as 'second' operand */
#define DUMY     19      /* dummy Y as 'second' operand */


/* cpu-specific symbol-flags */
#define ZPAGESYM (RSRVD_C<<0)   /* symbol will reside in the zero/direct-page */


/* exported by cpu.c */
int cpu_available(int);
int parse_cpu_label(char *,char **);
