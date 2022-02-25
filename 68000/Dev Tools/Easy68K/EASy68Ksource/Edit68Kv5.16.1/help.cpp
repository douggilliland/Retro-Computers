//---------------------------------------------------------------------------
//   Author: Charles Kelly,
//           Monroe County Community College
//           http://www.monroeccc.edu/ckelly
//---------------------------------------------------------------------------

#pragma hdrstop
#include <string.h>
#include "help.h"
#include "ez68k.h"

//---------------------------------------------------------------------------

#pragma package(smart_init)



//------------------------------------------------------------------------

typedef struct {
  char   *name;
  int    id;
} idh_cont;

// Context words should contain alpha num characters only
idh_cont context[] = {
        {"EASY68K",	        IDH_INTRO},
        {"68000",               IDH_QUICKREF},
        {"ABCD",                IDH_ABCD},
        {"ADD",                 IDH_ADD},
        {"ADDA",                IDH_ADDA},
        {"ADDI",                IDH_ADDI},
        {"ADDQ",                IDH_ADDQ},
        {"ADDX",                IDH_ADDX},
        {"AND",                 IDH_AND},
        {"ANDI",                IDH_ANDI},
        {"ASCII",               IDH_ASCII},
        {"ASL",                 IDH_ASL},
        {"ASR",                 IDH_ASR},
        {"ASSEMBLER",           IDH_ASSEMBLER_BASIC_OPERATION},
        {"OPTIONS",	        IDH_EDIT_OPTIONS},
        {"BCC",                 IDH_BCC},
        {"BCS",                 IDH_BCC},
        {"BEQ",                 IDH_BCC},
        {"BNE",                 IDH_BCC},
        {"BGE",                 IDH_BCC},
        {"BGT",                 IDH_BCC},
        {"BHI",                 IDH_BCC},
        {"BLE",                 IDH_BCC},
        {"BLS",                 IDH_BCC},
        {"BLT",                 IDH_BCC},
        {"BMI",                 IDH_BCC},
        {"BPL",                 IDH_BCC},
        {"BVC",                 IDH_BCC},
        {"BVS",                 IDH_BCC},
        {"BRA",                 IDH_BCC},
        {"BCHG",                IDH_BCHG},
        {"BCLR",                IDH_BCLR},
        {"BFCHG",               IDH_BFCHG},
        {"BFCLR",               IDH_BFCLR},
        {"BFEXTS",              IDH_BFEXTS},
        {"BFEXTU",              IDH_BFEXTU},
        {"BFFFO",               IDH_BFFFO},
        {"BFINS",               IDH_BFINS},
        {"BFSET",               IDH_BFSET},
        {"BFTST",               IDH_BFTST},
        {"BREAKPOINT",	        IDH_SIM_ADVBREAK},
        {"BSET",                IDH_BSET},
        {"BSR",                 IDH_BSR},
        {"BTST",                IDH_BTST},
        {"CHK",                 IDH_CHK},
        {"CLR",                 IDH_CLR},
        {"CMP",                 IDH_CMP},
        {"CMPA",                IDH_CMPA},
        {"CMPI",                IDH_CMPI},
        {"CMPM",                IDH_CMPM},
        {"CONDITIONAL",         IDH_CONDITIONAL},
        {"CREDITS",		IDH_CREDITS},
        {"DBCC",                IDH_DBCC},
        {"DBCS",                IDH_DBCC},
        {"DBEQ",                IDH_DBCC},
        {"DBNE",                IDH_DBCC},
        {"DBGE",                IDH_DBCC},
        {"DBGT",                IDH_DBCC},
        {"DBHI",                IDH_DBCC},
        {"DBLE",                IDH_DBCC},
        {"DBLS",                IDH_DBCC},
        {"DBLT",                IDH_DBCC},
        {"DBMI",                IDH_DBCC},
        {"DBPL",                IDH_DBCC},
        {"DBVC",                IDH_DBCC},
        {"DBVS",                IDH_DBCC},
        {"DBRA",                IDH_DBCC},
        {"DBLOOP",              IDH_STRUCCONTROL_DBLOOP},
        {"DC",			IDH_DIRECT_DC},
        {"DCB",			IDH_DIRECT_DCB},
        {"DIVS",                IDH_DIVS},
        {"DIVU",                IDH_DIVU},
        {"DS",			IDH_DIRECT_DS},
        {"END",			IDH_DIRECT_END},
        {"ENDC",	   	IDH_CONDITIONAL},
        {"ENDF",  	        IDH_STRUCCONTROL_FOR},
        {"ENDI",	        IDH_STRUCCONTROL_IF},
        {"ENDM",	   	IDH_MACRO},
        {"ENDW",		IDH_STRUCCONTROL_WHILE},
        {"EOR",                 IDH_EOR},
        {"EORI",                IDH_EORI},
        {"EQU",			IDH_DIRECT_EQU},
        {"ERROR",               IDH_ASSEMBLER_ERROR},
        {"EXCEPTIONS",          IDH_SIM_EXCEPTIONS},
        {"EXG",                 IDH_EXG},
        {"EXPRESSION",	        IDH_STRUCCONTROL_EXSYNTAX},
        {"EXT",                 IDH_EXT},
        {"FAIL",                IDH_DIRECT_FAIL},
        {"FILE",		IDH_IO_FILE},
        {"FOR",		        IDH_STRUCCONTROL_FOR},
        {"GOD",                 IDH_PSALMS},
        {"GRAPHICS",		IDH_IO_GRAPHICS},
        {"HARDWARE",            IDH_SIM_HARDWARE},
        {"IF",		        IDH_STRUCCONTROL_IF},
        {"IFC",		        IDH_CONDITIONAL},
        {"IFEQ",	        IDH_CONDITIONAL},
        {"IFGE",   	        IDH_CONDITIONAL},
        {"IFGT",   	        IDH_CONDITIONAL},
        {"IFLE",   	        IDH_CONDITIONAL},
        {"IFLT",   	        IDH_CONDITIONAL},
        {"IFNC",   	        IDH_CONDITIONAL},
        {"IFNE",   	        IDH_CONDITIONAL},
        {"ILLEGAL",             IDH_ILLEGAL},
        {"INCBIN",              IDH_DIRECT_INCBIN},
        {"INCLUDE",		IDH_DIRECT_INCLUDE},
        {"JMP",                 IDH_JMP},
        {"JSR",                 IDH_JSR},
        {"LEA",                 IDH_LEA},
        {"LINK",                IDH_LINK},
        {"LIST",                IDH_LIST},
        {"LSL",                 IDH_LSL},
        {"LSR",                 IDH_LSR},
        {"MACRO",		IDH_MACRO},
        {"MOUSE",               IDH_IO_PERIPHERAL},
        {"MOVE",                IDH_MOVE},
        {"MOVEA",               IDH_MOVEA},
        {"MOVEM",               IDH_MOVEM},
        {"MOVEP",               IDH_MOVEP},
        {"MOVEQ",               IDH_MOVEQ},
        {"MOVE USP",            IDH_MOVE_USP},
        {"MULS",                IDH_MULS},
        {"MULU",                IDH_MULU},
        {"NBCD",                IDH_NBCD},
        {"NEG",                 IDH_NEG},
        {"NEGX",                IDH_NEGX},
        {"NOLIST",              IDH_NOLIST},
        {"NOT",                 IDH_NOT},
        {"NOP",                 IDH_NOP},
        {"OFFSET",		IDH_DIRECT_OFFSET},
        {"OPT",			IDH_DIRECT_OPT},
        {"MEX",			IDH_DIRECT_OPT},
        {"NOMEX",		IDH_DIRECT_OPT},
        {"NOSEX",		IDH_DIRECT_OPT},
        {"NOWAR",		IDH_DIRECT_OPT},
        {"SEX",			IDH_DIRECT_OPT},
        {"WAR",			IDH_DIRECT_OPT},
        {"OR",                  IDH_OR},
        {"ORG",			IDH_DIRECT_ORG},
        {"ORI",                 IDH_ORI},
        {"PAGE",                IDH_DIRECT_PAGE},
        {"PEA",                 IDH_PEA},
        {"REG",			IDH_DIRECT_REG},
        {"REPEAT",		IDH_STRUCCONTROL_REPEAT},
        {"RESET",               IDH_RESET},
        {"ROL",                 IDH_ROL},
        {"ROR",                 IDH_ROR},
        {"ROXL",                IDH_ROXL},
        {"ROXR",                IDH_ROXR},
        {"RTE",                 IDH_RTE},
        {"RTR",                 IDH_RTR},
        {"RTS",                 IDH_RTS},
        {"SBCD",                IDH_SBCD},
        {"SCC",                 IDH_SCC},
        {"SCS",                 IDH_SCC},
        {"SEQ",                 IDH_SCC},
        {"SGE",                 IDH_SCC},
        {"SGT",                 IDH_SCC},
        {"SHI",                 IDH_SCC},
        {"SLE",                 IDH_SCC},
        {"SLS",                 IDH_SCC},
        {"SLT",                 IDH_SCC},
        {"SME",                 IDH_SCC},
        {"SNE",                 IDH_SCC},
        {"SPL",                 IDH_SCC},
        {"SVC",                 IDH_SCC},
        {"SVS",                 IDH_SCC},
        {"SSF",                 IDH_SCC},
        {"SST",                 IDH_SCC},
        {"SECTION",             IDH_DIRECT_SECTION},
        {"SET",			IDH_DIRECT_SET},
        {"SIMHALT",             IDH_DIRECT_SIMHALT},
        {"MEMORY",		IDH_DIRECT_MEMORY},
        {"SERIAL",		IDH_IO_SERIAL},
        {"SIMULATOR",		IDH_SIM_BASIC},
        {"SOUND",		IDH_IO_SOUND},
        {"STACK",		IDH_SIM_STACK},
        {"STOP",                IDH_STOP},
        {"STRUCTURED",		IDH_STRUCCONTROL_INTRO},
        {"SUB",                 IDH_SUB},
        {"SUBA",                IDH_SUBA},
        {"SUBI",                IDH_SUBI},
        {"SUBQ",                IDH_SUBQ},
        {"SUBX",                IDH_SUBX},
        {"SWAP",                IDH_SWAP},
        {"TAS",                 IDH_TAS},
        {"TEXT",		IDH_IO_TEXT},
        {"TRAP",                IDH_TRAP},
        {"TRAPV",               IDH_TRAPV},
        {"TST",                 IDH_TST},
        {"UNLK",                IDH_UNLK},
        {"UNLESS",              IDH_STRUCCONTROL_DBLOOP},
        {"UNTIL",		IDH_STRUCCONTROL_REPEAT},
        {"WARNING",             IDH_ASSEMBLER_ERROR},
        {"WHILE",		IDH_STRUCCONTROL_WHILE},
        {"CHARLES",		IDH_CREDITS},
        {"CURT",		IDH_CREDITS},
        {"AARON",		IDH_CREDITS},
        };

// Declare a global variable containing the size of the context table

int contextSize = sizeof(context)/sizeof(idh_cont);

//---------------------------------------------------------------------------
// returns context ID for HTML help
int __fastcall getHelpContext(char* str)
{
  int i, cmp;
  int contextID;

  // search for help context in context table
  i = 0;
  do {
    cmp = strcmpi(str, context[i].name);
    i++;
  } while (cmp && (i < contextSize));

  // if context found
  if (!cmp)
    contextID = context[i-1].id;
  else                  // else, context not found
    contextID = IDH_INTRO;   // use INTRO contextID

  return contextID;
}
