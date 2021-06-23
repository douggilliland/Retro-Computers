
#include "table.h"

struct oper table[] = {

"add",  GEN,    0xE2,	0,
"adda", GEN,    0xE2,	0,
"and",  GEN,    0xE5,	0,
"anda", GEN,    0xE5,	0,
"asla", APOST,  0xFA,	0,
"bam",  BPM,    0xCF,	0,
"bap",  BPM,    0xC7,	0,
"bcc",  REL,    0x40,	0,
"bclr", SETCLR, 0xD0,	0,
"bcs",  REL,    0x60,	0,
"beq",  REL,    0x20,	0,
"bhs",  REL,    0x40,	0,
"blo",  REL,    0x60,	0,
"bne",  REL,    0x00,	0,
"brclr",BTB,    0xC0,	0,
"brset",BTB,    0xC8,	0,
"bset", SETCLR, 0xD8,	0,
"clra", APOST,  0xFB,	0,
"clrx", CLRX,   0xB0,	0,
"clry", CLRY,   0xB0,	0,
"cmp",  GEN,    0xE4,	0,
"cmpa", GEN,    0xE4,	0,
"coma", INH,    0xB4,	0,
"dec",  NOIMM,  0xE7,	0,
"deca", APOST,  0xFF,	0,
"decx", INH,    0xB8,	0,
"decy", INH,    0xB9,	0,
"dex",  INH,    0xB8,	0,
"dey",  INH,    0xB9,	0,
"inc",  NOIMM,  0xE6,	0,
"inca", APOST,  0xFE,	0,
"incx", INH,    0xA8,	0,
"incy", INH,    0xA9,	0,
"inx",  INH,    0xA8,	0,
"iny",  INH,    0xA9,	0,
"jmp",  EXT,    0x90,	0,
"jsr",  EXT,    0x80,	0,
"lda",  GEN,    0xE0,	0,
"ldxi", LDX,    0xB0,	0,
"ldyi", LDY,    0xB0,	0,
"mvi",  MVI,    0xB0,	0,
"nop",  INH,    0x20,	0,
"rola", INH,    0xB5,	0,
"rrb",  INH,    0xB1,	0,
"rti",  INH,    0xB2,	0,
"rts",  INH,    0xB3,	0,
"sta",  NOIMM , 0xE1,	0,
"stop", INH,    0xB6,   0,
"sub",  GEN,    0xE3,	0,
"suba", GEN,    0xE3,	0,
"tax",  INH,    0xBC,	0,
"tay",  INH,    0xBD,	0,
"txa",  INH,    0xAC,	0,
"tya",  INH,    0xAD,   0,
"wait", INH,    0xB7,   0 
};

int sizeof_table(void)
{
	return sizeof(table);
}

