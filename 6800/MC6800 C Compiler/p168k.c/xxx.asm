 name pass1.c
 text
 data
 global _fout
_fout fdb 1
 bss
 global __obuf
__obuf rmb 512
 data
 global __opos
__opos fdb __obuf
 text
 global _flush
_flush pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -6 n
* Begin expression - 38
 ldd #__obuf
 std 0,s
 ldd __opos
 subd 0,s
 std -6,y
* Begin expression - 39
 ldx #__obuf
 stx __opos
* Begin expression - 40
 cmpd #0
 lble L3
* Begin expression - 41
 std 0,s
 ldx #__obuf
 pshs x
 ldd _fout
 pshs d
 jsr _write
 leas 4,s
 cmpd -6,y
 lbeq L4
* Begin expression - 42
 ldd #-1
 lbra L1
L4
L3
* Begin expression - 43
 ldd #0
L1
L2 equ 4
 leas -4,y
 puls x,y,u,pc
 global __flsbuf
__flsbuf pshs u,y,x
 leay 4,s
 leas -L6,s
* Auto 4 c
* Begin expression - 47
 jsr _flush
 cmpd #-1
 lbne L7
* Begin expression - 48
 ldd #-1
 lbra L5
L7
* Begin expression - 49
 ldd 4,y
 ldx __opos
 stb 0,x+
 stx __opos
* Begin expression - 50
 ldd 4,y
L5
L6 equ 2
 leas -4,y
 puls x,y,u,pc
 global __cleanu
__cleanu pshs u,y,x
 leay 4,s
 leas -L9,s
* Begin expression - 55
 jsr _flush
L8
L9 equ 2
 leas -4,y
 puls x,y,u,pc
 global _putchar
_putchar pshs u,y,x
 leay 4,s
 leas -L11,s
* Auto 4 c
* Begin expression - 61
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd 4,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd 4,y
 std 0,s
 jsr __flsbuf
11
L10
L11 equ 2
 leas -4,y
 puls x,y,u,pc
 bss
 global _pp_if_r
_pp_if_r rmb 2
 global _errcnt
_errcnt rmb 2
 global _curchar
_curchar rmb 2
 global _curtok
_curtok rmb 2
 global _dtype
_dtype rmb 2
 global _lstflg
_lstflg rmb 1
 global _dclass
_dclass rmb 1
 global _blklev
_blklev rmb 1
 global _pmlsf
_pmlsf rmb 1
 global _fndcf
_fndcf rmb 1
 global _deftyp
_deftyp rmb 1
 global _sukey
_sukey rmb 1
 global _ilopt
_ilopt rmb 1
 global _nobopt
_nobopt rmb 1
 global _absflag
_absflag rmb 1
 global _qopt
_qopt rmb 1
 global _optf
_optf rmb 1
 global _uopt
_uopt rmb 1
 global _tempch
_tempch rmb 2
 global _ptrcnt
_ptrcnt rmb 2
 global _opcount
_opcount rmb 2
 global _retlab
_retlab rmb 2
 global _argoff
_argoff rmb 2
 global _datareg
_datareg rmb 2
 global _addrreg
_addrreg rmb 2
 global _nxtarg
_nxtarg rmb 2
 global _nxtaut
_nxtaut rmb 2
 global _inztyp
_inztyp rmb 2
 global _nxtdim
_nxtdim rmb 2
 global _subsptr
_subsptr rmb 2
 global _label
_label rmb 2
 global _cspace
_cspace rmb 1
 global _nocomf
_nocomf rmb 1
 global _funnum
_funnum rmb 1
 global _dpflag
_dpflag rmb 1
 global _nokey
_nokey rmb 1
 global _funtype
_funtype rmb 2
 global _lastmem
_lastmem rmb 2
 global _strhdr
_strhdr rmb 2
 global _strtag
_strtag rmb 2
 global _strofs
_strofs rmb 2
 global _strptr
_strptr rmb 2
 global _brklab
_brklab rmb 2
 global _conlab
_conlab rmb 2
 global _deflab
_deflab rmb 2
 global _nxtsw
_nxtsw rmb 2
 global _cswmrk
_cswmrk rmb 2
 global _ferrs
_ferrs rmb 2
 global _erofset
_erofset rmb 2
 global _strsize
_strsize rmb 2
 global _fpvars
_fpvars rmb 2
 global _swflag
_swflag rmb 1
 global _matlev
_matlev rmb 1
 global _strnum
_strnum rmb 1
 global _strcoun
_strcoun rmb 1
 global _namsize
_namsize rmb 2
 global _strnum2
_strnum2 rmb 1
 global _strhdr2
_strhdr2 rmb 2
 global _enumval
_enumval rmb 2
 global _value
_value rmb 2
 global _hdrlab
_hdrlab rmb 2
 global _cursubs
_cursubs rmb 2
 global _nxtcon
_nxtcon rmb 2
 global _thisop
_thisop rmb 1
 global _strloc
_strloc rmb 2
 global _swexp
_swexp rmb 1
 global _rtexp
_rtexp rmb 1
 global _cmexfl
_cmexfl rmb 1
 global _doqmf
_doqmf rmb 1
 global _ioff
_ioff rmb 2
 global _fstr
_fstr rmb 2
 global _doingfl
_doingfl rmb 1
 global _fieldof
_fieldof rmb 1
 global _initfld
_initfld rmb 1
 global _crntfld
_crntfld rmb 2
 global _lwr
_lwr rmb 2
 global _upr
_upr rmb 2
 global _aft
_aft rmb 2
 global _fieldva
_fieldva rmb 2
 global _iname
_iname rmb 2
 global _ibindx
_ibindx rmb 1
 global _iwindx
_iwindx rmb 1
 global _ilindx
_ilindx rmb 1
 global _ilbindx
_ilbindx rmb 1
 global _ibstk
_ibstk rmb 16
 global _iwstk
_iwstk rmb 32
 global _ilstk
_ilstk rmb 64
 global _ilbstk
_ilbstk rmb 96
 global _pszsym
_pszsym rmb 24
 global _op1
_op1 rmb 2
 global _op2
_op2 rmb 2
 global _classes
_classes rmb 12
 global _nxtmat
_nxtmat rmb 2
 global _typdfsy
_typdfsy rmb 2
 global _inzsym
_inzsym rmb 2
 global _absdec
_absdec rmb 24
 global _tos
_tos rmb 2
 global _contab
_contab rmb 128
 global _strings
_strings rmb 384
 global _nxtsst
_nxtsst rmb 2
 global _astack
_astack rmb 508
 global _ptinfo
_ptinfo rmb 2
 global _stinfo
_stinfo rmb 40
 global _emat
_emat rmb 1016
 global _contyp
_contyp rmb 2
 global _convalu
_convalu rmb 4
 global _fconval
_fconval rmb 4
 global _nxtfrc
_nxtfrc rmb 2
 global _nxtfor
_nxtfor rmb 2
 global _frctab
_frctab rmb 40
 global _fortab
_fortab rmb 256
 global _symloc
_symloc rmb 2
 global _funnam
_funnam rmb 2
 global _argptr
_argptr rmb 2
 global _endprms
_endprms rmb 2
 global _dimstk
_dimstk rmb 256
 global _swttab
_swttab rmb 512
 global _strngbf
_strngbf rmb 512
 data
 global _esctab
_esctab fcb 110,13,116,9,98,8,114,13,102,12,118,11,0
 global _clstbl
_clstbl fcb 1,2,3,4,5
 global _typtab
_typtab fcb 6,2,8,4,1,10,11,12,13,14,0
 global _dchtab
_dchtab fcb 61,60
 fcb 43,30
 fcb 45,31
 fcb 38,53
 fcb 124,54
 fcb 60,46
 fcb 62,45
 fcb 0,0
 global _eqctab
_eqctab fcb 60,62
 fcb 62,64
 fcb 33,61
 fcb 0,0
 global _chrtab
_chrtab fcb 123,2
 fcb 125,3
 fcb 91,4
 fcb 93,5
 fcb 124,48
 fcb 94,49
 fcb 126,38
 fcb 92,11
 fcb 0,0
 global _fasttbl
_fasttbl fcb 34,10,127,127,44,47,9,6,7,42,40,105,41,99,43,127
 fcb 127,127,127,127,127,127,127,127,127,8,1,63,80,65,12
 global _onecon
_onecon fdb 1551,1
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L13,s
* Auto 4 argc
* Auto 6 argv
* Begin expression - 197
 ldx 6,y
 stx 0,s
 ldd 4,y
 pshs d
 jsr _prs
 leas 2,s
 cmpd #0
 lbeq L14
* Begin expression - 198
 ldx #L15
 stx 0,s
 jsr _perror
* Begin expression - 199
 ldd #255
 std 0,s
 jsr _exit
L14
* Begin expression - 201
 jsr _initial
* Begin expression - 202
 jsr _loop
* Begin expression - 203
 jsr _errrpt
L12
L13 equ 2
 leas -4,y
 puls x,y,u,pc
 global _initial
_initial pshs u,y,x
 leay 4,s
 leas -L17,s
* Begin expression - 237
 ldd #3
 std _fout
* Begin expression - 238
 ldd #0
 std _errcnt
* Begin expression - 239
 clr _doqmf
* Begin expression - 240
 ldd #0
 std 0,s
 ldx #L19
 pshs x
 jsr _open
 leas 2,s
 std _ferrs
 lbge L18
* Begin expression - 241
 ldx #L20
 stx 0,s
 jsr _perror
* Begin expression - 242
 ldd #255
 std 0,s
 jsr _exit
L18
L16
L17 equ 2
 leas -4,y
 puls x,y,u,pc
 global _loop
_loop pshs u,y,x
 leay 4,s
 leas -L22,s
* Auto -6 name
L23
* Begin expression - 254
 jsr _nxtfil
 tfr d,x
 stx -6,y
 lbeq L24
* Begin expression - 255
 jsr _finit
* Begin expression - 256
 ldx -6,y
 stx 0,s
 jsr _domodul
 lbra L23
L24
* Begin expression - 258
 jsr _flush
L21
L22 equ 4
 leas -4,y
 puls x,y,u,pc
 global _finit
_finit pshs u,y,x
 leay 4,s
 leas -L26,s
* Begin expression - 264
 ldd #0
 std _label
 std _curchar
 std _curtok
* Begin expression - 265
 ldd #0
 std _conlab
 std _brklab
 stb _matlev
 stb _swflag
 sex
 std _tempch
* Begin expression - 266
 ldd #0
 std _deflab
 std _retlab
 stb _absflag
* Begin expression - 267
 ldx #_swttab
 stx _nxtsw
* Begin expression - 268
 ldx #_strings
 stx _nxtsst
* Begin expression - 269
 ldx #_dimstk
 stx _nxtdim
* Begin expression - 270
 ldd #63
 std 0,s
 ldx #L28
 pshs x
 jsr _creat
 leas 2,s
 std _fstr
 lbge L27
* Begin expression - 271
 ldx #L29
 stx 0,s
 jsr _perror
* Begin expression - 272
 ldd #255
 std 0,s
 jsr _exit
L27
* Begin expression - 274
 ldd _fstr
 std 0,s
 jsr _close
* Begin expression - 275
 ldd #2
 std 0,s
 ldx #L30
 pshs x
 jsr _open
 leas 2,s
 std _fstr
* Begin expression - 276
 ldx #L31
 stx 0,s
 jsr _unlink
L25
L26 equ 2
 leas -4,y
 puls x,y,u,pc
 global _flstr
_flstr pshs u,y,x
 leay 4,s
 leas -L33,s
* Auto -6 i
* Begin expression - 284
 ldb _optf
 lbeq L34
* Begin expression - 285
 jsr _outtext
 lbra L35
L34
* Begin expression - 287
 jsr _outdata
L35
* Begin expression - 288
 jsr _flush
* Begin expression - 289
 ldd #0
 std 0,s
 ldx #0
 pshs x
 ldd _fstr
 pshs d
 jsr _lseek
 leas 4,s
L36
* Begin expression - 290
 ldd #512
 std 0,s
 ldx #__obuf
 pshs x
 ldd _fstr
 pshs d
 jsr _read
 leas 4,s
 std -6,y
 lbeq L37
* Begin expression - 291
 ldd -6,y
 std 0,s
 ldx #__obuf
 pshs x
 ldd _fout
 pshs d
 jsr _write
 leas 4,s
 lbra L36
L37
* Begin expression - 292
 ldd _fstr
 std 0,s
 jsr _close
* Begin expression - 293
 jsr _outtext
L32
L33 equ 4
 leas -4,y
 puls x,y,u,pc
 global _errrpt
_errrpt pshs u,y,x
 leay 4,s
 leas -L39,s
* Begin expression - 299
 ldd _errcnt
 lbeq L40
* Begin expression - 300
 ldd _errcnt
 std 0,s
 ldx #L41
 pshs x
 ldd #1
 pshs d
 jsr _outil
 leas 4,s
* Begin expression - 301
 jsr _flush
* Begin expression - 302
 ldd #255
 std 0,s
 jsr _exit
L40
L38
L39 equ 2
 leas -4,y
 puls x,y,u,pc
 global _perror
_perror pshs u,y,x
 leay 4,s
 leas -L43,s
* Auto 4 msg
* Begin expression - 311
 ldx 4,y
 stx 0,s
 ldd #2
 pshs d
 jsr _outil
 leas 2,s
L42
L43 equ 2
 leas -4,y
 puls x,y,u,pc
 global _error
_error pshs u,y,x
 leay 4,s
 leas -L45,s
* Auto 4 n
* Begin expression - 319
 ldd 4,y
 cmpd #100
 lbge L46
* Begin expression - 320
 addd #150
 std 4,y
L46
* Begin expression - 321
 ldd #0
 std 0,s
 ldd 4,y
 pshs d
 ldd #1
 pshs d
 jsr _pfilerr
 leas 4,s
* Begin expression - 322
 jsr _flush
* Begin expression - 323
 ldd #255
 std 0,s
 jsr _exit
L44
L45 equ 2
 leas -4,y
 puls x,y,u,pc
 global _rptern
_rptern pshs u,y,x
 leay 4,s
 leas -L48,s
* Auto 4 num
* Begin expression - 331
 ldd #0
 std 0,s
 ldd 4,y
 pshs d
 ldd #0
 pshs d
 jsr _pfilerr
 leas 4,s
* Begin expression - 332
 ldx #L49
 stx 0,s
 ldd #1
 pshs d
 jsr _outil
 leas 2,s
* Begin expression - 333
 ldd #0
L47
L48 equ 2
 leas -4,y
 puls x,y,u,pc
 global _rptwrn
_rptwrn pshs u,y,x
 leay 4,s
 leas -L51,s
* Auto 4 num
* Begin expression - 341
 ldd #1
 std 0,s
 ldd 4,y
 pshs d
 ldd #0
 pshs d
 jsr _pfilerr
 leas 4,s
* Begin expression - 342
 ldx #L52
 stx 0,s
 ldd #1
 pshs d
 jsr _outil
 leas 2,s
* Begin expression - 343
 ldd #0
L50
L51 equ 2
 leas -4,y
 puls x,y,u,pc
 global _pfilerr
_pfilerr pshs u,y,x
 leay 4,s
 leas -L54,s
* Auto 4 flag
* Auto 6 num
* Auto 8 warn
* Begin expression - 351
 ldd 8,y
 lbne L55
* Begin expression - 352
 inc _errcnt+1
 bne 1f
 inc _errcnt
1
L55
* Begin expression - 353
 ldb _lstflg
 lbne L56
* Begin expression - 354
 jsr _pfile
L56
* Begin expression - 355
 jsr _pline
* Begin expression - 356
 ldd #0
 std 0,s
 ldd 6,y
 addd #-1
 lslb
 rola
 tfr d,x
 ldx []
 pshs x
 ldd _ferrs
 pshs d
 jsr _lseek
 leas 4,s
* Begin expression - 357
 ldd #2
 std 0,s
 ldx 