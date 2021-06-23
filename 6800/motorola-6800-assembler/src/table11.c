
#include "table.h"

struct oper table[] = {

"aba",  INH,    0x1B,   2,
"abx",  INH,    0x3A,   3, /* 6801 */
"aby",  P2INH,  0x3A,   4, /* 6811 */
"adca", GEN,    0x89,   2,
"adcb", GEN,    0xC9,   2,
"adda", GEN,    0x8B,   2,
"addb", GEN,    0xCB,   2,
"addd", LONGIMM,0xC3,   4, /* 6801 */
"anda", GEN,    0x84,   2,
"andb", GEN,    0xC4,   2,
"asl",  GRP2,   0x68,   6,
"asla", INH,    0x48,   2,
"aslb", INH,    0x58,   2,
"asld", INH,    0x05,   3, /* 6801 */
"asr",  GRP2,   0x67,   6,
"asra", INH,    0x47,   2,
"asrb", INH,    0x57,   2,
"bcc",  REL,    0x24,   3,
"bclr", SETCLR, 0x1D,   6, /* 6811 */
"bcs",  REL,    0x25,   3,
"beq",  REL,    0x27,   3,
"bge",  REL,    0x2C,   3,
"bgt",  REL,    0x2E,   3,
"bhi",  REL,    0x22,   3,
"bhs",  REL,    0x24,   3,
"bita", GEN,    0x85,   2,
"bitb", GEN,    0xC5,   2,
"ble",  REL,    0x2F,   3,
"blo",  REL,    0x25,   3,
"bls",  REL,    0x23,   3,
"blt",  REL,    0x2D,   3,
"bmi",  REL,    0x2B,   3,
"bne",  REL,    0x26,   3,
"bpl",  REL,    0x2A,   3,
"bra",  REL,    0x20,   3,
"brclr",BTB,    0x1F,   6,   /* 6811 */
"brn",  REL,    0x21,   3,   /* for sharon 9/30/81 */
"brset",BTB,    0x1E,   6,   /* 6811 */
"bset", SETCLR, 0x1C,   6,   /* 6811 */
"bsr",  REL,    0x8D,   6,
"bvc",  REL,    0x28,   3,
"bvs",  REL,    0x29,   3,
"cba",  INH,    0x11,   2,
"clc",  INH,    0x0C,   2,
"cli",  INH,    0x0E,   2,
"clr",  GRP2,   0x6F,   6,
"clra", INH,    0x4F,   2,
"clrb", INH,    0x5F,   2,
"clv",  INH,    0x0A,   2,
"cmpa", GEN,    0x81,   2,
"cmpb", GEN,    0xC1,   2,
"cmpd", CPD,    0x83,   5,   /* 6811 */
"cmpx", XLIMM,  0x8C,   4,   /* 6811, LONGIMM for 6801 */
"cmpy", YLIMM,  0x8C,   5,   /* 6811 */
"com",  GRP2,   0x63,   6,
"coma", INH,    0x43,   2,
"comb", INH,    0x53,   2,
"cpd",  CPD,    0x83,   5,   /* 6811 */
"cpx",  XLIMM,  0x8C,   4,   /* 6811, LONGIMM for 6801 */
"cpy",  YLIMM,  0x8C,   5,   /* 6811 */
"daa",  INH,    0x19,   2,
"dec",  GRP2,   0x6A,   6,
"deca", INH,    0x4A,   2,
"decb", INH,    0x5A,   2,
"des",  INH,    0x34,   3,
"dex",  INH,    0x09,   3,
"dey",  P2INH,  0x09,   4,   /* 6811 */
"eora", GEN,    0x88,   2,
"eorb", GEN,    0xC8,   2,
"fdiv", INH,    0x03,   41,  /* 6811 */
"idiv", INH,    0x02,   41,  /* 6811 */
"inc",  GRP2,   0x6C,   6,
"inca", INH,    0x4C,   2,
"incb", INH,    0x5C,   2,
"ins",  INH,    0x31,   3,
"inx",  INH,    0x08,   3,
"iny",  P2INH,  0x08,   4,   /* 6811 */
"jmp",  GRP2,   0x6E,   3,
"jsr",  NOIMM,  0x8D,   4,
"lda",  GEN,    0x86,   2,
"ldaa", GEN,    0x86,   2,
"ldab", GEN,    0xC6,   2,
"ldad", LONGIMM,0xCC,   3,   /* 6801 */
"ldb",  GEN,    0xC6,   2,
"ldd",  LONGIMM,0xCC,   3,   /* 6801 */
"lds",  LONGIMM,0x8E,   3,
"ldx",  XLIMM,  0xCE,   3,   /* 6811, LONGIMM for 6801 */
"ldy",  YLIMM,  0xCE,   4,   /* 6811 */
"lsl",  GRP2,   0x68,   6,
"lsla", INH,    0x48,   2,
"lslb", INH,    0x58,   2,
"lsld", INH,    0x05,   3,   /* 6801 */
"lsr",  GRP2,   0x64,   6,
"lsra", INH,    0x44,   2,
"lsrb", INH,    0x54,   2,
"lsrd", INH,    0x04,   3,   /* 6801 */
"mul",  INH,    0x3D,   10,  /* 6801 */
"neg",  GRP2,   0x60,   6,
"nega", INH,    0x40,   2,
"negb", INH,    0x50,   2,
"nop",  INH,    0x01,   2,
"ora",  GEN,    0x8A,   2,
"oraa", GEN,    0x8A,   2,
"orab", GEN,    0xCA,   2,
"orb",  GEN,    0xCA,   2,
"psha", INH,    0x36,   3,
"pshb", INH,    0x37,   3,
"pshx", INH,    0x3C,   4,   /* 6801 */
"pshy", P2INH,  0x3C,   5,   /* 6811 */
"pula", INH,    0x32,   4,
"pulb", INH,    0x33,   4,
"pulx", INH,    0x38,   5,   /* 6801 */
"puly", P2INH,  0x38,   6,   /* 6811 */
"rol",  GRP2,   0x69,   6,
"rola", INH,    0x49,   2,
"rolb", INH,    0x59,   2,
"ror",  GRP2,   0x66,   6,
"rora", INH,    0x46,   2,
"rorb", INH,    0x56,   2,
"rti",  INH,    0x3B,   12,
"rts",  INH,    0x39,   5,
"sba",  INH,    0x10,   2,
"sbca", GEN,    0x82,   2,
"sbcb", GEN,    0xC2,   2,
"sec",  INH,    0x0D,   2,
"sei",  INH,    0x0F,   2,
"sev",  INH,    0x0B,   2,
"sta",  NOIMM,  0x87,   2,
"staa", NOIMM,  0x87,   2,
"stab", NOIMM,  0xC7,   2,
"stad", NOIMM,  0xCD,   3,   /* 6801 */
"stb",  NOIMM,  0xC7,   2,
"std",  NOIMM,  0xCD,   3,   /* 6801 */
"stop", INH,    0xCF,   2,   /* 6811 */
"sts",  NOIMM,  0x8F,   3,
"stx",  XNOIMM, 0xCF,   3,   /* 6811, LONGIMM for 6801 */
"sty",  YNOIMM, 0xCF,   4,   /* 6811 */
"suba", GEN,    0x80,   2,
"subb", GEN,    0xC0,   2,
"subd", LONGIMM,0x83,   4,   /* 6801 */
"swi",  INH,    0x3F,   14,
"tab",  INH,    0x16,   2,
"tap",  INH,    0x06,   2,
"tba",  INH,    0x17,   2,
"tpa",  INH,    0x07,   2,
"tst",  GRP2,   0x6D,   6,
"tsta", INH,    0x4D,   2,
"tstb", INH,    0x5D,   2,
"tsx",  INH,    0x30,   3,
"tsy",  P2INH,  0x30,   4,   /* 6811 */
"txs",  INH,    0x35,   3,
"tys",  P2INH,  0x35,   4,   /* 6811 */
"wai",  INH,    0x3E,   14,
"xgdx", INH,    0x8F,   3,   /* 6811 */
"xgdy", P2INH,  0x8F,   4    /* 6811 */
};

int sizeof_table(void)
{
	return sizeof(table);
}

