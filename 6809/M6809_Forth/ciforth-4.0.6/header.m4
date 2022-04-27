dnl  $Id: header.m4,v 4.1.2.8 2004/11/24 17:11:02 albert Exp $  M4 file to handle the develish FIG headers.
dnl Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
dnl
dnl _STRING : Lay down a string in memory.
define({_STRING},
{DC      len({$1})
        DSS      _quoted}({{$1}}))dnl
define({_sc},0)dnl
define({_STRINGINLINE},
{DC      SKIP
         DC      len({$1})
SB{}_sc: DSS      _quoted}({{$1}})
{       _ALIGNED_({_ALIGN(4)})
        DC      LIT, SB{}_sc
        DC      LIT, len({$1})
define({_sc},{incr}(_sc))dnl })dnl
dnl
dnl _VOCLINKOLD is a m4 variable that generates a chain of vocabularies.
define({_VOCLINKOLD},0)dnl
define(_VOCLINK,
        {DC      DOVOC
        DC      _VOCLINKOLD{}define({_VOCLINKOLD},_LINKOLD)dnl
})dnl
dnl We lay down a nice square around the definition as a tribute to Thomas Newman
dnl _star(x) generates x stars
define({_star},{ifelse}(0,$1,,{*{_star}({decr}($1))}))
dnl
dnl Lay down a header with forth name $1, assembler name $2 and code field $3
dnl and data field $4, flag field $5, link field $6.
dnl All except the assembler name are optional.
define(_HEADER, {dnl
define({_L},ifelse(0,len({$6}),dnl Only link in if there is no explicit link.
{_LINKOLD{}define({_LINKOLD},{$2})},dnl
$6))dnl
ifelse(0,len({$1}),,
_C  ********_star(len({$1}))
_C  *   {{$1}}   *
_C  ********_star(len({$1}))
_C
_ALIGNED_({        _ALIGN(4)},{dnl})
N_$2:
        {_STRING}({{$1}}))
_ALIGNED_({        _ALIGN(4)},{dnl})
ifelse(0,len($2),,$2:)
        DC    ifelse(0,len($3),0x0,$3)
        DC    ifelse(0,len($4),$2+HEADSIZE,$4)
        DC    ifelse(0,len($5),0x0,$5)
        DC    _L
        DC    ifelse(0,len({$1}),_DATA_FIELD(ZERO),N_$2)
_SOURCEFIELD_({        DC    0},{dnl})
_EXTRAFIELD_({        DC    0},{dnl})
})dnl
dnl
dnl
dnl ------------------ to get dictionaries better under control -------------------------------------
dnl Remember! The assembler names denote the code field.
dnl The link etc. field of the word with assembler name $1
define({_DEA},{$1})dnl
define({_CODE_FIELD},$1)dnl
define({_DATA_FIELD},{($1+_CELLS(D_HOFFSET))})dnl
define({_LINK_FIELD},{($1+_CELLS(L_HOFFSET))})dnl
define({_VAR_FIELD},{($1+HEADSIZE)})dnl
dnl     Handle Branching
define({_0BRANCH},dnl
{DC      ZBRAN
        DC      $1-_AP_-CW})dnl
define({_BRANCH},dnl
{DC      BRAN
        DC      $1-_AP_-CW})dnl
define({_DO},dnl
{DC     XDO
        DC      $1-_AP_-CW})dnl
define({_QDO},dnl
{DC     XQDO
        DC      $1-_AP_-CW})dnl
define({_LOOP},dnl
{DC     XLOOP
        DC      $1-_AP_-CW})dnl
dnl The field where a pointer to the latest entry of a vocabulary resides.
define({CODE_HEADER},
{_HEADER({$1},
{$2},
{$2+HEADSIZE},
{$2+HEADSIZE},
$5)})dnl
define({JMPHERE_FROM_PROT},{})dnl
define({JMPHERE_FROM_REAL},{})dnl
define({JMPFAR},{DB    0x0EA})dnl
define({_CELLS},(CW*($1)))dnl
#
# Start of Intel dependant code part
# The 32 bit version may be used in the postlude to redefine
# _NEXT etc. to generate faster code.
#
# See definition of NEXT in glossary.
define({_NEXT},{JMP     NEXT})
define({_NEXT32},
        {LODSW                 _C NEXT
        JMP     _CELL_PTR[WOR]  } )
# See definition of PUSH in glossary.
define({_PUSH},{JMP     APUSH})
define({_PUSH32},
        {PUSH    AX
        _NEXT32})
# Like PUSH but for two numbers.
define({_2PUSH},{JMP     DPUSH})
define({_2PUSH32},
        {PUSH    DX
        _PUSH32})
