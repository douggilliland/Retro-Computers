 name as09.c
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
 ldd __opos
 std 0,s
 ldd #__obuf
 nega
 negb
 sbca #0
 addd 0,s
 std -6,y
* Begin expression - 39
 ldx #__obuf
 stx __opos
* Begin expression - 40
 ldd -6,y
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
 lbra L1
L2 equ 6
L1
 leas -4,y
 puls x,y,u,pc
 global __flsbuf
__flsbuf pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L6,s
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
 lbra L5
L6 equ 4
L5
 leas -4,y
 puls x,y,u,pc
 global __cleanup
__cleanup pshs u,y,x
 leay 4,s
 leas -L9,s
* Begin expression - 55
 jsr _flush
L9 equ 4
L8
 leas -4,y
 puls x,y,u,pc
 global _putchar
_putchar pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L11,s
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
 lbra L10
L11 equ 4
L10
 leas -4,y
 puls x,y,u,pc
 data
 global _fin
_fin fdb 0
 global __ibytes
__ibytes fdb 0
 bss
 global __ibuf
__ibuf rmb 512
 data
 global __ipos
__ipos fdb __ibuf
 bss
 global __ipeek
__ipeek rmb 2
 text
 global __filbuf
__filbuf pshs u,y,x
 leay 4,s
 leas -L13,s
* Begin expression - 49
 ldx #__ibuf
 stx __ipos
* Begin expression - 50
 ldd #512
 std 0,s
 ldx #__ibuf
 pshs x
 ldd _fin
 pshs d
 jsr _read
 leas 4,s
 std __ibytes
 lbgt L14
* Begin expression - 51
 ldd #-1
 lbra L12
L14
* Begin expression - 52
 ldd __ibytes
 subd #1
 std __ibytes
* Begin expression - 53
 ldx __ipos
 ldb 0,x+
 stx __ipos
 sex
 clra
 lbra L12
L13 equ 4
L12
 leas -4,y
 puls x,y,u,pc
 global _getchar
_getchar pshs u,y,x
 leay 4,s
 leas -L16,s
* Begin expression - 58
 ldd __ibytes
 subd #1
 std __ibytes
 blt 10f
 ldx __ipos
 ldb 0,x+
 stx __ipos
 sex
 clra
 bra 11f
10
 jsr __filbuf
11
 lbra L15
L16 equ 4
L15
 leas -4,y
 puls x,y,u,pc
 global _ungetcha
_ungetcha pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L18,s
* Begin expression - 63
 ldx __ipos
 cmpx #__ibuf
 ble 10f
 inc __ibytes+1
 bne 1f
 inc __ibytes
1
 ldd 4,y
 ldx __ipos
 stb 0,-x
 stx __ipos
 sex
 clra
 bra 11f
10
 ldd #-1
11
 lbra L17
L18 equ 4
L17
 leas -4,y
 puls x,y,u,pc
 global _peekchar
_peekchar pshs u,y,x
 leay 4,s
 leas -L20,s
* Begin expression - 68
 ldd __ibytes
 ble 10f
 ldb [__ipos]
 sex
 clra
 bra 11f
10
 jsr __filbuf
 std __ipeek
 cmpd #-1
 bne 12f
 ldd #-1
 bra 11f
12
 inc __ibytes+1
 bne 1f
 inc __ibytes
1
 ldd __ipeek
 ldx __ipos
 stb 0,-x
 stx __ipos
 sex
 clra
11
 lbra L19
L20 equ 4
L19
 leas -4,y
 puls x,y,u,pc
 global _printf
_printf pshs u,y,x
 leay 4,s
* Auto 4 args
 leas -L22,s
* Register 1 ap
* Auto -6 c
* Auto -8 s
* Auto -10 af
* Auto -12 p
* Auto -14 f
* Auto -16 sfout
* Begin expression - 42
 leau 4,y
* Begin expression - 43
 ldd 0,u
 std -14,y
* Begin expression - 44
 ldd #-1
 std -16,y
* Begin expression - 45
 ldd -14,y
 cmpd #20
 lbhs L23
* Begin expression - 46
 leau 2,u
* Begin expression - 47
 cmpd _fout
 lbeq L24
* Begin expression - 48
 jsr _flush
* Begin expression - 49
 ldd _fout
 std -16,y
* Begin expression - 50
 ldd -14,y
 std _fout
L24
L23
* Begin expression - 53
 leau 2,u
 ldx -2,u
 stx -10,y
L25
L28
* Begin expression - 55
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
 cmpd #37
 lbeq L29
* Begin expression - 56
 cmpd #0
 lbeq L29
L30
* Begin expression - 58
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd -6,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr __flsbuf
11
 lbra L28
L29
* Begin expression - 60
 ldd -6,y
 lbeq L26
L31
* Begin expression - 62
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
* Begin expression - 63
 ldd #0
 std -12,y
* Begin expression - 64
 ldd #0
 std -14,y
* Begin expression - 65
 ldd -6,y
 cmpd #45
 lbne L32
* Begin expression - 66
 ldd -14,y
 orb #$4
 std -14,y
* Begin expression - 67
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
L32
* Begin expression - 69
 ldd -6,y
 cmpd #48
 lbne L33
* Begin expression - 70
 ldd -14,y
 orb #$1
 std -14,y
* Begin expression - 71
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
L33
L34
* Begin expression - 73
 ldd -6,y
 cmpd #48
 lblt L35
 cmpd #57
10
 lbgt L35
* Begin expression - 74
 ldd -12,y
 std 0,s
 ldd #10
 jsr imul
 addd -6,y
 subd #48
 std -12,y
* Begin expression - 75
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
 lbra L34
L35
* Begin expression - 77
 ldd -6,y
 cmpd #46
 lbne L36
* Begin expression - 78
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
L37
* Begin expression - 79
 ldd -6,y
 cmpd #48
 lblt L38
 cmpd #57
10
 lbgt L38
* Begin expression - 80
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
 lbra L37
L38
L36
* Begin expression - 82
 ldd -6,y
 lbeq L26
L39
* Begin expression - 84
 ldd -6,y
 lbra L41
L42
* Begin expression - 86
 ldd -14,y
 orb #$2
 std -14,y
L43
L44
* Begin expression - 89
 ldd #10
 std -6,y
 lbra L45
L46
* Begin expression - 92
 ldd #8
 std -6,y
 lbra L45
L47
* Begin expression - 95
 ldd #2
 std -6,y
 lbra L45
L48
L49
* Begin expression - 99
 ldd #16
 std -6,y
L45
* Begin expression - 100
 ldd -14,y
 std 0,s
 ldd -12,y
 pshs d
 ldd -6,y
 pshs d
 ldd 0,u++
 pshs d
 jsr __num
 leas 6,s
 lbra L27
L50
* Begin expression - 103
 ldd 0,u++
 clra
 andb #$7F
 std -6,y
* Begin expression - 104
 ldd -14,y
 clra
 andb #$1
 lbeq L51
* Begin expression - 105
 ldd -6,y
 cmpd #32
 blt 11f
 cmpd #127
10
 lbne L52
11
* Begin expression - 106
 ldd -6,y
 lbra L54
L55
* Begin expression - 108
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 109
 ldd #110
 std -6,y
 lbra L53
L56
* Begin expression - 112
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 113
 ldd #114
 std -6,y
 lbra L53
L57
* Begin expression - 116
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 117
 ldd #98
 std -6,y
 lbra L53
L58
* Begin expression - 120
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 121
 ldd #102
 std -6,y
 lbra L53
L59
* Begin expression - 124
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 125
 ldd #116
 std -6,y
 lbra L53
L60
* Begin expression - 128
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #92
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #92
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 129
 ldd #101
 std -6,y
 lbra L53
L61
* Begin expression - 132
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #94
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #94
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 133
 ldd -6,y
 eorb #$40
 std -6,y
 lbra L53
L54
 ldx #L10003
 std L10002
L10001 cmpd 0,x++
 bne L10001
 jmp [L10002-L10003,x]
 data
L10003  fdb 13,13,8,12,9,27
L10002 fdb 0
 fdb L55,L56,L57,L58,L59,L60,L61
 text
L53
* Begin expression - 135
 ldd -12,y
 subd #1
 std -12,y
L52
L51
* Begin expression - 137
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd -6,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr __flsbuf
11
* Begin expression - 138
 ldd -12,y
 subd #1
 std -12,y
L62
* Begin expression - 139
 ldd -12,y
 subd #1
 std -12,y
 lblt L63
* Begin expression - 140
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L62
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L62
L63
 lbra L27
L64
* Begin expression - 143
 leau 2,u
 ldx -2,u
 stx -8,y
L65
* Begin expression - 144
 ldb [-8,y]
 lbeq L66
* Begin expression - 145
 ldx -8,y
 ldb 0,x+
 stx -8,y
 sex
 clra
 andb #$7F
 std -6,y
* Begin expression - 146
 ldd -14,y
 clra
 andb #$1
 lbeq L67
* Begin expression - 147
 ldd -6,y
 cmpd #32
 blt 11f
 cmpd #127
10
 lbne L68
11
* Begin expression - 148
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #94
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #94
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 149
 ldd -12,y
 lbeq L69
 subd #1
 std -12,y
10
 lble L66
L69
* Begin expression - 151
 ldd -6,y
 eorb #$40
 std -6,y
L68
L67
* Begin expression - 153
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd -6,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr __flsbuf
11
* Begin expression - 154
 ldd -12,y
 lbeq L70
 subd #1
 std -12,y
10
 lble L66
L70
 lbra L65
L66
L71
* Begin expression - 157
 ldd -12,y
 subd #1
 std -12,y
 lblt L72
* Begin expression - 158
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L71
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L71
L72
 lbra L27
 lbra L40
L41
 ldx #L10007
 std L10006
L10005 cmpd 0,x++
 bne L10005
 jmp [L10006-L10007,x]
 data
L10007  fdb 100,108,117,111,98,104,120,99,115
L10006 fdb 0
 fdb L42,L43,L44,L46,L47,L48,L49,L50,L64,L10004
 text
L10004
 text
L40
* Begin expression - 161
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd -6,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr __flsbuf
11
L27
 lbra L25
L26
* Begin expression - 163
 ldd -16,y
 lblt L73
* Begin expression - 164
 jsr _flush
* Begin expression - 165
 ldd -16,y
 std _fout
L73
L22 equ 16
L21
 leas -4,y
 puls x,y,u,pc
__num pshs u,y,x
 leay 4,s
* Auto 4 an
* Auto 6 ab
* Auto 8 ap
* Auto 10 af
 leas -L75,s
* Auto -6 n
* Auto -8 b
* Register 1 p
* Auto -10 neg
* Auto -27 buf
* Begin expression - 175
 leau -10,y
* Begin expression - 176
 ldd 4,y
 std -6,y
* Begin expression - 177
 ldd 6,y
 std -8,y
* Begin expression - 178
 ldd #0
 std -10,y
* Begin expression - 179
 ldd 10,y
 clra
 andb #$2
 lbeq L76
 ldd 4,y
10
 lbge L76
* Begin expression - 180
 inc -9,y
 bne 1f
 inc -10,y
1
* Begin expression - 181
 ldd -6,y
 nega
 negb
 sbca #0
 std -6,y
* Begin expression - 182
 ldd 8,y
 subd #1
 std 8,y
L76
* Begin expression - 184
 clr 0,-u
L77
* Begin expression - 186
 ldd -6,y
 std 0,s
 ldd -8,y
 jsr umod
 ldx #L80
 ldb d,x
 stb 0,-u
 data
L80 fcb 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70
 fcb 0
 text
* Begin expression - 187
 ldd 8,y
 subd #1
 std 8,y
L78
* Begin expression - 188
 ldd -6,y
 std 0,s
 ldd -8,y
 jsr udiv
 std -6,y
 lbne L77
L79
* Begin expression - 189
 ldd #32
 std -6,y
* Begin expression - 190
 ldd 10,y
 clra
 andb #$5
 cmpd #1
 lbne L81
* Begin expression - 191
 ldd #48
 std -6,y
 lbra L82
L81
* Begin expression - 192
 ldd -10,y
 lbeq L83
* Begin expression - 193
 ldb #45
 stb 0,-u
* Begin expression - 194
 ldd #0
 std -10,y
L83
L82
* Begin expression - 196
 ldd 10,y
 clra
 andb #$4
 lbne L84
L85
* Begin expression - 197
 ldd 8,y
 subd #1
 std 8,y
 lblt L86
* Begin expression - 198
 ldd -6,y
 stb 0,-u
 lbra L85
L86
L84
* Begin expression - 199
 ldd -10,y
 lbeq L87
* Begin expression - 200
 ldb #45
 stb 0,-u
L87
L88
* Begin expression - 201
 ldb 0,u
 lbeq L89
* Begin expression - 202
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb 0,u+
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L88
10
 ldb 0,u+
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L88
L89
L90
* Begin expression - 203
 ldd 8,y
 subd #1
 std 8,y
 lblt L91
* Begin expression - 204
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd -6,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L90
10
 ldd -6,y
 std 0,s
 jsr __flsbuf
11
 lbra L90
L91
L75 equ 27
L74
 leas -4,y
 puls x,y,u,pc
 bss
 global _clobber
_clobber rmb 2
 global _symll
_symll rmb 2
 global _symn
_symn rmb 6400
 global _symv
_symv rmb 1600
 global _symp
_symp rmb 800
 global _mbody
_mbody rmb 70
 global _mmbody
_mmbody rmb 2450
 global _mdef
_mdef rmb 70
 global _mmdef
_mmdef rmb 350
 global _edtab
_edtab rmb 120
 global _eedtab
_eedtab rmb 540
 global _exrtab
_exrtab rmb 1000
 global _exatab
_exatab rmb 1000
 global _exptab
_exptab rmb 500
 global _rrtab
_rrtab rmb 1000
 global _ratab
_ratab rmb 1000
 global _rptab
_rptab rmb 500
 global _globs
_globs rmb 140
 global _gglobs
_gglobs rmb 560
 global _loadtab
_loadtab rmb 30
 global _lloadtb
_lloadtb rmb 105
 data
L92 fcb 77,105,115,115,105,110,103,32,111,112,101,114,104,97,110,100
 fcb 0
 global _MI
_MI fdb L92
L93 fcb 76,97,98,108,101,115,32,99,97,110,39,116,32,115,116,97
 fcb 114,116,32,119,105,116,104,32,39,36,39,32,111,114,32,39
 fcb 37,39,46,0
 global _BL
_BL fdb L93
L94 fcb 73,110,118,97,108,105,100,32,100,105,103,105,116,115,32,105
 fcb 110,32,110,117,109,98,101,114,0
 global _IDIN
_IDIN fdb L94
L95 fcb 66,97,100,32,83,121,110,116,97,120,0
 global _SYN
_SYN fdb L95
L96 fcb 85,110,100,101,102,105,110,100,101,100,32,115,121,109,98,111
 fcb 108,0
 global _UND
_UND fdb L96
L97 fcb 37,37,37,37,9,37,115,13,0
 global _UCS
_UCS fdb L97
L98 fcb 79,110,108,121,32,111,110,32,111,112,101,114,104,97,110,100
 fcb 32,97,108,108,111,119,101,100,46,0
 global _SOI
_SOI fdb L98
 bss
 global _pc
_pc rmb 32
 global _psect
_psect rmb 2
 global _spsect
_spsect rmb 2
 global _pass
_pass rmb 2
 global _rlpass
_rlpass rmb 24
 global _lineno
_lineno rmb 2
 global _passend
_passend rmb 2
 global _poe
_poe rmb 2
 global _stlen
_stlen rmb 2
 global _mtlen
_mtlen rmb 2
 global _filler
_filler rmb 4
 global _prebyte
_prebyte rmb 2
 global _b1
_b1 rmb 2
 global _b2
_b2 rmb 2
 global _b3
_b3 rmb 2
 global _b4
_b4 rmb 2
 global _b5
_b5 rmb 2
 global _b6
_b6 rmb 2
 global _fb2
_fb2 rmb 2
 global _fb3
_fb3 rmb 2
 global _fb4
_fb4 rmb 2
 global _fb5
_fb5 rmb 2
 global _fb6
_fb6 rmb 2
 global _fd
_fd rmb 2
 global _pcolpc
_pcolpc rmb 2
 global _pcoch
_pcoch rmb 2
 global _pcocnt
_pcocnt rmb 2
 global _pcob
_pcob rmb 68
 global _pcobs
_pcobs rmb 2
 global _pcobsp
_pcobsp rmb 2
 global _pcost
_pcost rmb 2
 global _ppsect
_ppsect rmb 34
 global _numerrs
_numerrs rmb 2
 global _nestc
_nestc rmb 2
 global _nest
_nest rmb 50
 global _ifcount
_ifcount rmb 2
 global _relob
_relob rmb 2
 global _symtabr
_symtabr rmb 2
 global _relocate
_relocate rmb 2
 global _exttabr
_exttabr rmb 2
 global _extrtp
_extrtp rmb 2
 global _rtrtp
_rtrtp rmb 2
 global _curbase
_curbase rmb 2
 global _macnest
_macnest rmb 2
 global _macstack
_macstack rmb 100
 global _listflag
_listflag rmb 1
 global _macflag
_macflag rmb 1
 global _binflag
_binflag rmb 1
 global _sorflag
_sorflag rmb 1
 global _malflag
_malflag rmb 1
 global _mabflag
_mabflag rmb 1
 global _mamflag
_mamflag rmb 1
 global _exflag
_exflag rmb 1
 global _dbuff
_dbuff rmb 513
 global _dbuffc
_dbuffc rmb 2
 global _ifd
_ifd rmb 20
 global _ifdc
_ifdc rmb 2
 global _ibuff
_ibuff rmb 513
 global _ibuffp
_ibuffp rmb 2
 global _ibuffc
_ibuffc rmb 2
 global _indir
_indir rmb 1
 global _p2evnf
_p2evnf rmb 1
 global _p2evnn
_p2evnn rmb 2
 global _bytef
_bytef rmb 1
 global _bytep
_bytep rmb 1
 text
 global _main
_main pshs u,y,x
 leay 4,s
* Auto 4 argc
* Auto 6 argv
 leas -L100,s
* Auto -125 line
* Register 1 k
* Auto -126 c
* Auto -128 i
* Auto -150 arg
* Auto -152 j
* Auto -154 bc
* Auto -156 s
* Auto -158 ii
* Auto -160 jj
* Auto -162 ss
* Auto -163 b
* Auto -165 kaboom
* Auto -171 tvec
* Begin expression - 140
 ldd 4,y
 cmpd #1
 lbne L101
* Begin expression - 141
 ldx #L102
 stx 0,s
 jsr _printf
 data
L102 fcb 85,115,97,103,101,58,32,97,115,48,57,32,102,105,108,101
 fcb 110,97,109,101,13,0
 text
* Begin expression - 142
 jsr _flush
 lbra L99
L101
* Begin expression - 146
 ldd #1
 std _pass
* Begin expression - 147
 ldd #0
 std _lineno
* Begin expression - 148
 ldd #1
 std _passend
* Begin expression - 149
 ldd #0
 std _poe
* Begin expression - 150
 ldd #0
 std _extrtp
* Begin expression - 151
 ldd #0
 std _rtrtp
* Begin expression - 152
 ldd #0
 std _symv
* Begin expression - 153
 clr _symp
* Begin expression - 154
 ldd #1
 std _stlen
* Begin expression - 155
 ldd #1
 std _mtlen
* Begin expression - 156
 ldd #0
 std _macnest
* Begin expression - 157
 ldd #10
 std _curbase
* Begin expression - 158
 ldb #1
 stb _listfla
* Begin expression - 159
 clr _macflag
* Begin expression - 160
 clr _binflag
* Begin expression - 161
 ldb #1
 stb _malflag
* Begin expression - 162
 clr _mamflag
* Begin expression - 163
 clr _mabflag
* Begin expression - 164
 clr _exflag
* Begin expression - 165
 ldb #1
 stb _sorflag
* Begin expression - 166
 ldb #1
 stb _bytef
* Begin expression - 167
 ldd #0
 std _dbuffc
* Begin expression - 168
 ldd #0
 std _ifdc
* Begin expression - 169
 ldd #0
 std _ibuffc
* Begin expression - 170
 ldd #0
 std _symll
* Begin expression - 172
 ldx #_mmbody
 stx 0,s
 ldx #_mbody
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 173
 ldx #_mmdef
 stx 0,s
 ldx #_mdef
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 174
 ldx #_eedtab
 stx 0,s
 ldx #_edtab
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 175
 ldx #_gglobs
 stx 0,s
 ldx #_globs
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 176
 ldx #_lloadtb
 stx 0,s
 ldx #_loadtab
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 177
 ldd #0
 std _pcocnt
* Begin expression - 178
 ldd #0
 std _pcolpc
* Begin expression - 179
 ldu #_symn
* Begin expression - 180
 ldd #0
 std -128,y
L103
* Begin expression - 180
 ldd -128,y
 cmpd #6400
 lbeq L104
* Begin expression - 180
 clr 0,u+
L105
* Begin expression - 180
 inc -127,y
 lbne L103
 inc -128,y
 lbra L103
L104
* Begin expression - 182
 ldd #0
 std _psect
* Begin expression - 183
 ldd #0
 std _spsect
* Begin expression - 184
 ldd #0
 std -128,y
L106
* Begin expression - 184
 ldd -128,y
 cmpd #16
 lbeq L107
* Begin expression - 184
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd #0
 std 0,x
L108
* Begin expression - 184
 inc -127,y
 lbne L106
 inc -128,y
 lbra L106
L107
* Begin expression - 185
 ldd #0
 std _symv
* Begin expression - 186
 ldd #0
 std _numerrs
* Begin expression - 187
 ldd #0
 std _nestc
* Begin expression - 188
 ldd #0
 std 0,s
 ldx 6,y
 ldx 2,x
 pshs x
 jsr _open
 leas 2,s
 std _fin
* Begin expression - 189
 ldd _fin
 cmpd #-1
 lbne L109
* Begin expression - 190
 ldx 6,y
 ldx 2,x
 stx 0,s
 ldx #L110
 pshs x
 jsr _printf
 leas 2,s
 data
L110 fcb 67,97,110,39,116,32,102,105,110,100,32,39,37,115,39,46
 fcb 13,0
 text
 lbra L99
L109
* Begin expression - 195
 ldd 4,y
 cmpd #2
 lble L111
* Begin expression - 196
 subd #1
 std -128,y
L112
* Begin expression - 196
 ldd -128,y
 cmpd #1
 lble L113
* Begin expression - 197
 lslb
 rola
 ldx 6,y
 ldb [d,x]
 cmpb #45
 lbne L115
* Begin expression - 198
 ldd #1
 std -152,y
L116
* Begin expression - 199
 ldd -128,y
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -152,y
 ldx 0,x
 ldb d,x
 lbeq L117
* Begin expression - 200
 ldd -128,y
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -152,y
 ldx 0,x
 ldb d,x
 sex
 lbra L119
L120
* Begin expression - 202
 clr _malflag
 lbra L118
L121
* Begin expression - 205
 clr _sorflag
 lbra L118
L122
* Begin expression - 208
 ldb #1
 stb _mabflag
 lbra L118
L123
* Begin expression - 211
 ldb #1
 stb _mamflag
 lbra L118
L124
* Begin expression - 214
 ldb #1
 stb _exflag
 lbra L118
L125
* Begin expression - 217
 ldd -128,y
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -152,y
 ldx 0,x
 ldb d,x
 sex
 std 0,s
 ldx #L126
 pshs x
 jsr _printf
 leas 2,s
 data
L126 fcb 66,97,100,32,111,112,116,105,111,110,45,32,39,37,99,39
 fcb 46,13,0
 text
 lbra L118
L119
 ldx #L10010
 std L10009
L10008 cmpd 0,x++
 bne L10008
 jmp [L10009-L10010,x]
 data
L10010  fdb 108,115,98,109,117
L10009 fdb 0
 fdb L120,L121,L122,L123,L124,L125
 text
L118
* Begin expression - 219
 inc -151,y
 bne 1f
 inc -152,y
1
 lbra L116
L117
L115
L114
* Begin expression - 222
 tst -127,y
 bne 1f
 dec -128,y
1 dec -127,y
 lbra L112
L113
L111
* Begin expression - 226
 ldx #L127
 stx 0,s
 jsr _fsyms
 data
L127 fcb 46,0
 text
L128
L129
* Begin expression - 228
 ldd _passend
 lbeq L130
* Begin expression - 229
 leax -125,y
 stx 0,s
 jsr _getline
* Begin expression - 230
 leax -125,y
 stx 0,s
 jsr _cline
 lbra L129
L130
* Begin expression - 232
 ldd _pass
 cmpd #2
 lbne L131
 ldb _mabflag
10
 lbne L131
* Begin expression - 233
 ldd _pcocnt
 lbeq L132
* Begin expression - 233
 jsr _pdump
L132
L133
* Begin expression - 234
 ldd _loadtab+2
 cmpd #-1
 lbeq L134
* Begin expression - 235
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 235
 ldb #51
 sex
 std 0,s
 jsr _dput
* Begin expression - 236
 ldx _loadtab+2
 leau 0,x
L135
* Begin expression - 237
 ldb 0,u
 lbeq L136
* Begin expression - 237
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
 lbra L135
L136
* Begin expression - 238
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 239
 ldx #_loadtab
 stx 0,s
 ldd #1
 pshs d
 jsr _chisel
 leas 2,s
 lbra L133
L134
* Begin expression - 241
 ldd #1
 std -152,y
L137
* Begin expression - 242
 ldd -152,y
 lslb
 rola
 ldx #_globs
 ldd d,x
 cmpd #-1
 lbeq L138
* Begin expression - 243
 ldd -152,y
 lslb
 rola
 ldx #_globs
 ldd d,x
 std 0,s
 jsr _fsyml1
 std -128,y
 cmpd #-1
 lbne L139
* Begin expression - 244
 ldx #L140
 stx 0,s
 jsr _panic
 data
L140 fcb 85,110,100,101,102,105,110,101,100,32,103,108,111,98,97,108
 fcb 58,0
 text
* Begin expression - 245
 ldd -152,y
 lslb
 rola
 ldx #_globs
 ldd d,x
 std 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
 lbra L141
L139
* Begin expression - 248
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 248
 ldb #52
 sex
 std 0,s
 jsr _dput
* Begin expression - 249
 ldd -128,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 tfr a,b
 sex
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 250
 ldd -128,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 251
 ldd -128,y
 ldx #_symp
 ldb d,x
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 252
 ldd -152,y
 lslb
 rola
 ldx #_globs
 ldx d,x
 leau 0,x
L142
* Begin expression - 253
 ldb 0,u
 lbeq L143
* Begin expression - 253
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
 lbra L142
L143
* Begin expression - 254
 ldb #13
 sex
 std 0,s
 jsr _dput
L141
* Begin expression - 256
 inc -151,y
 bne 1f
 inc -152,y
1
 lbra L137
L138
* Begin expression - 258
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 259
 ldb #54
 sex
 std 0,s
 jsr _dput
* Begin expression - 260
 ldd _poe
 tfr a,b
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 260
 ldd _poe
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 261
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 262
 ldd #0
 std -128,y
L144
* Begin expression - 263
 ldd -128,y
 cmpd _extrtp
 lbge L145
* Begin expression - 264
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 265
 ldb #55
 sex
 std 0,s
 jsr _dput
* Begin expression - 266
 ldd -128,y
 lslb
 rola
 ldx #_exatab
 ldd d,x
 tfr a,b
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 267
 ldd -128,y
 lslb
 rola
 ldx #_exatab
 ldd d,x
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 268
 ldd -128,y
 ldx #_exptab
 ldb d,x
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 269
 ldd -128,y
 lslb
 rola
 ldx #_exrtab
 ldd d,x
 lslb
 rola
 ldx #_edtab
 ldx d,x
 leau 0,x
L146
* Begin expression - 270
 ldb 0,u
 lbeq L147
* Begin expression - 271
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
 lbra L146
L147
* Begin expression - 273
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 274
 inc -127,y
 bne 1f
 inc -128,y
1
 lbra L144
L145
* Begin expression - 276
 ldd #0
 std -128,y
L148
* Begin expression - 276
 ldd -128,y
 cmpd #16
 lbeq L149
* Begin expression - 277
 lslb
 rola
 ldx #_pc
 ldd d,x
 lbeq L151
* Begin expression - 278
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 278
 ldb #56
 sex
 std 0,s
 jsr _dput
* Begin expression - 279
 ldd -128,y
 lslb
 rola
 ldx #_pc
 ldd d,x
 tfr a,b
 sex
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 279
 ldd -128,y
 lslb
 rola
 ldx #_pc
 ldd d,x
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 280
 ldb #48
 sex
 std 0,s
 jsr _dput
* Begin expression - 280
 ldd -128,y
 addd #48
 std 0,s
 jsr _dput
* Begin expression - 280
 ldb #13
 sex
 std 0,s
 jsr _dput
L151
L150
* Begin expression - 282
 inc -127,y
 lbne L148
 inc -128,y
 lbra L148
L149
* Begin expression - 283
 ldd #1
 std -128,y
L152
* Begin expression - 284
 ldd -128,y
 cmpd _symll
 lbge L153
* Begin expression - 285
 ldx #_globs
 stx 0,s
 lslb
 rola
 lslb
 rola
 lslb
 rola
 ldx #_symn
 leau d,x
 pshs u
 jsr _llu
 leas 2,s
 cmpd #-1
 lbne L154
* Begin expression - 286
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 286
 ldb #65
 sex
 std 0,s
 jsr _dput
* Begin expression - 287
 ldd -128,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 tfr a,b
 sex
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 288
 ldd -128,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 289
 ldd -128,y
 ldx #_symp
 ldb d,x
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 290
 ldd #0
 std -158,y
L155
* Begin expression - 291
 ldb 0,u
 lbeq L156
 ldd -158,y
 cmpd #8
10
 lbge L156
* Begin expression - 291
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
* Begin expression - 291
 inc -157,y
 bne 1f
 inc -158,y
1
 lbra L155
L156
* Begin expression - 292
 ldb #13
 sex
 std 0,s
 jsr _dput
L154
* Begin expression - 294
 inc -127,y
 bne 1f
 inc -128,y
1
 lbra L152
L153
* Begin expression - 296
 ldd #0
 std -128,y
L157
* Begin expression - 297
 ldd -128,y
 cmpd _rtrtp
 lbge L158
* Begin expression - 298
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 299
 ldb #66
 sex
 std 0,s
 jsr _dput
* Begin expression - 300
 ldd -128,y
 lslb
 rola
 ldx #_ratab
 ldd d,x
 tfr a,b
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 301
 ldd -128,y
 lslb
 rola
 ldx #_ratab
 ldd d,x
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 302
 ldd -128,y
 ldx #_rptab
 ldb d,x
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 303
 ldd -128,y
 lslb
 rola
 ldx #_rrtab
 ldd d,x
 lslb
 rola
 ldx #_edtab
 ldx d,x
 leau 0,x
L159
* Begin expression - 304
 ldb 0,u
 lbeq L160
* Begin expression - 305
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
 lbra L159
L160
* Begin expression - 307
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 308
 inc -127,y
 bne 1f
 inc -128,y
1
 lbra L157
L158
* Begin expression - 310
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 311
 ldb #57
 sex
 std 0,s
 jsr _dput
* Begin expression - 312
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 313
 jsr _fdput
* Begin expression - 314
 jsr _flush
* Begin expression - 315
 ldd _fd
 std 0,s
 jsr _close
* Begin expression - 316
 jsr _flush
L131
* Begin expression - 318
 ldd _pass
 cmpd #2
 lbne L161
* Begin expression - 319
 ldd #1
 std _fout
* Begin expression - 320
 ldd _numerrs
 lbeq L162
* Begin expression - 321
 cmpd #1
 bne 10f
 ldx #L164
 bra 11f
10
 ldx #L165
11
 stx 0,s
 ldd _numerrs
 pshs d
 ldx #L163
 pshs x
 jsr _printf
 leas 4,s
 data
L163 fcb 37,100,32,101,114,114,111,114,37,115,13,0
L164 fcb 0
L165 fcb 115,0
 text
L162
* Begin expression - 323
 jsr _flush
* Begin expression - 324
 ldd _numerrs
 lbeq L166
* Begin expression - 324
 ldd #-1
 std 0,s
 jsr _exit
L166
* Begin expression - 325
 ldd #0
 std 0,s
 jsr _exit
L161
L167
* Begin expression - 327
 ldd __ibytes
 subd #1
 std __ibytes
 blt 10f
 ldx __ipos
 ldb 0,x+
 stx __ipos
 sex
 clra
 bra 11f
10
 jsr __filbuf
11
 cmpd #-1
 lbne L167
L168
* Begin expression - 328
 ldd #0
 std 0,s
 ldd #0
 pshs d
 ldd _fin
 pshs d
 jsr _seek
 leas 4,s
* Begin expression - 329
 jsr _flush
* Begin expression - 330
 ldb _malflag
 lbeq L169
* Begin expression - 331
 ldx 6,y
 ldu 2,x
* Begin expression - 331
 ldd #0
 std -128,y
L170
* Begin expression - 332
 ldd -128,y
 inc -127,y
 bne 1f
 inc -128,y
1
 leax -125,y
 leax d,x
 ldb 0,u+
 stb 0,x
 lbne L170
L171
* Begin expression - 333
 ldx #L172
 stx 0,s
 leax -125,y
 pshs x
 jsr _cats
 leas 2,s
 data
L172 fcb 46,108,115,116,0
 text
* Begin expression - 334
 ldd #420
 std 0,s
 leax -125,y
 pshs x
 jsr _creat
 leas 2,s
 std _fout
L169
* Begin expression - 337
 ldb _mabflag
 lbne L173
* Begin expression - 338
 ldx 6,y
 ldu 2,x
* Begin expression - 338
 ldd #0
 std -128,y
L174
* Begin expression - 339
 ldd -128,y
 inc -127,y
 bne 1f
 inc -128,y
1
 leax -125,y
 leax d,x
 ldb 0,u+
 stb 0,x
 lbne L174
L175
* Begin expression - 340
 ldx #L176
 stx 0,s
 leax -125,y
 pshs x
 jsr _cats
 leas 2,s
 data
L176 fcb 46,114,101,108,0
 text
* Begin expression - 341
 ldd #420
 std 0,s
 leax -125,y
 pshs x
 jsr _creat
 leas 2,s
 std _fd
* Begin expression - 342
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 342
 ldb #48
 sex
 std 0,s
 jsr _dput
* Begin expression - 343
 ldx 6,y
 ldu 2,x
L177
* Begin expression - 344
 ldb 0,u
 lbeq L178
* Begin expression - 344
 ldb 0,u+
 sex
 std 0,s
 jsr _dput
 lbra L177
L178
* Begin expression - 345
 ldb #13
 sex
 std 0,s
 jsr _dput
L173
* Begin expression - 348
 ldd #2
 std _pass
* Begin expression - 349
 ldd #0
 std _lineno
* Begin expression - 350
 ldd #1
 std _passend
* Begin expression - 351
 ldd #0
 std _psect
* Begin expression - 352
 ldd #0
 std -128,y
L179
* Begin expression - 352
 ldd -128,y
 cmpd #16
 lbeq L180
* Begin expression - 352
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd #0
 std 0,x
L181
* Begin expression - 352
 inc -127,y
 lbne L179
 inc -128,y
 lbra L179
L180
* Begin expression - 353
 ldd #0
 std _pcocnt
* Begin expression - 354
 ldd #0
 std _relob
* Begin expression - 355
 ldd #0
 std _relocat
* Begin expression - 356
 ldd #0
 std _exttabr
* Begin expression - 357
 ldd #1
 std _pcost
* Begin expression - 358
 ldd #0
 std _numerrs
* Begin expression - 359
 ldd #0
 std _nestc
* Begin expression - 360
 ldb #1
 stb _listfla
* Begin expression - 361
 clr _macflag
* Begin expression - 362
 ldb #1
 stb _bytef
 lbra L128
L100 equ 171
L99
 leas -4,y
 puls x,y,u,pc
 global _getline
_getline pshs u,y,x
 leay 4,s
* Auto 4 line
 leas -L183,s
* Register 1 k
* Auto -5 c
* Auto -7 i
* Auto -9 p
* Auto -11 j
L184
* Begin expression - 375
 ldd _nestc
 lbeq L185
* Begin expression - 376
 lslb
 rola
 ldx #_nest
 leax d,x
 stx 0,s
 ldx [0,s]
 leax 1,x
 stx [0,s]
 ldb -1,x
 stb -5,y
 lbra L186
L185
* Begin expression - 379
 jsr _gchar
 stb -5,y
* Begin expression - 380
 ldd _ifdc
 lbne L187
* Begin expression - 380
 ldd _lineno
 addd #1
 std _lineno
L187
L186
* Begin expression - 382
 ldu 4,y
* Begin expression - 383
 ldd #0
 std -7,y
L188
* Begin expression - 384
 ldb -5,y
 cmpb #13
 lbeq L189
 cmpb #255
 lbeq L189
 lbeq L189
 ldd -7,y
 cmpd #119
10
 lbge L189
* Begin expression - 385
 ldb -5,y
 stb 0,u+
* Begin expression - 386
 inc -6,y
 bne 1f
 inc -7,y
1
* Begin expression - 387
 ldd _nestc
 lbeq L190
* Begin expression - 387
 lslb
 rola
 ldx #_nest
 leax d,x
 stx 0,s
 ldx [0,s]
 leax 1,x
 stx [0,s]
 ldb -1,x
 stb -5,y
 lbra L191
L190
* Begin expression - 388
 jsr _gchar
 stb -5,y
L191
 lbra L188
L189
* Begin expression - 391
 ldd -7,y
 cmpd #119
 lblt L192
* Begin expression - 392
 ldx #L193
 stx 0,s
 jsr _panic
 data
L193 fcb 87,97,114,110,105,110,103,45,32,105,110,112,117,116,32,108
 fcb 105,110,101,32,116,111,111,32,108,111,110,103,46,32,32,76
 fcb 105,110,101,32,116,114,117,110,99,97,116,101,100,0
 text
* Begin expression - 393
 leau -1,u
* Begin expression - 393
 clr 0,u
L194
* Begin expression - 394
 ldb -5,y
 cmpb #13
 lbeq L195
 lbeq L195
 cmpb #255
10
 lbeq L195
* Begin expression - 395
 ldd _nestc
 lbeq L196
* Begin expression - 395
 lslb
 rola
 ldx #_nest
 leax d,x
 stx 0,s
 ldx [0,s]
 leax 1,x
 stx [0,s]
 ldb -1,x
 stb -5,y
 lbra L197
L196
* Begin expression - 396
 jsr _gchar
 stb -5,y
L197
 lbra L194
L195
L192
* Begin expression - 399
 ldb -5,y
 cmpb #255
 beq 11f
10
 lbne L198
11
* Begin expression - 400
 ldd _ifdc
 lbne L199
* Begin expression - 401
 ldx #L200
 stx 0,s
 jsr _panic
 data
L200 fcb 78,111,32,101,110,100,32,115,116,97,116,101,109,101,110,116
 fcb 0
 text
* Begin expression - 402
 ldd #0
 std _passend
* Begin expression - 403
 clr [4,y]
 lbra L201
L199
* Begin expression - 406
 ldd _ifdc
 cmpd #1
 lbne L202
* Begin expression - 406
 ldd #0
 std _ibuffc
L202
* Begin expression - 407
 ldd _ifdc
 tst _ifdc+1
 bne 1f
 dec _ifdc
1 dec _ifdc+1
 lslb
 rola
 ldx #_ifd
 ldd d,x
 std 0,s
 jsr _close
 lbra L184
L201
L198
* Begin expression - 411
 ldb -5,y
 cmpb #13
 lbne L203
* Begin expression - 412
 ldb #59
 stb 0,u+
* Begin expression - 413
 clr 0,u
L203
L183 equ 11
L182
 leas -4,y
 puls x,y,u,pc
 global _gchar
_gchar pshs u,y,x
 leay 4,s
 leas -L205,s
* Auto -5 data
* Auto -7 count
* Begin expression - 422
 ldd _ifdc
 lbeq L206
* Begin expression - 423
 cmpd #1
 lbne L207
* Begin expression - 424
 ldd _ibuffc
 lbne L208
* Begin expression - 425
 ldd #512
 std 0,s
 ldx #_ibuff
 pshs x
 ldd _ifdc
 lslb
 rola
 ldx #_ifd
 ldd d,x
 pshs d
 jsr _read
 leas 4,s
 std _ibuffc
* Begin expression - 426
 ldx #_ibuff
 stx _ibuffp
* Begin expression - 427
 ldd _ibuffc
 lbne L209
* Begin expression - 427
 ldd #-1
 lbra L204
L209
L208
* Begin expression - 429
 tst _ibuffc+1
 bne 1f
 dec _ibuffc
1 dec _ibuffc+1
* Begin expression - 430
 ldx _ibuffp
 ldb 0,x+
 stx _ibuffp
 lbra L204
 lbra L210
L207
* Begin expression - 433
 ldd #1
 std 0,s
 leax -5,y
 pshs x
 ldd _ifdc
 lslb
 rola
 ldx #_ifd
 ldd d,x
 pshs d
 jsr _read
 leas 4,s
 std -7,y
* Begin expression - 434
 cmpd #0
 lbne L211
* Begin expression - 434
 ldb #255
 stb -5,y
L211
L210
 lbra L212
L206
* Begin expression - 437
 ldd __ibytes
 subd #1
 std __ibytes
 blt 10f
 ldx __ipos
 ldb 0,x+
 stx __ipos
 sex
 clra
 bra 11f
10
 jsr __filbuf
11
 stb -5,y
L212
* Begin expression - 438
 ldb -5,y
 lbra L204
L205 equ 7
L204
 leas -4,y
 puls x,y,u,pc
 global _mexp
_mexp pshs u,y,x
 leay 4,s
* Auto 4 body
* Auto 6 arglist
* Auto 8 flag
 leas -L214,s
* Auto -124 line
* Auto -524 bline
* Register 1 p
* Auto -526 k
* Auto -527 c
* Auto -529 i
* Auto -531 j
* Begin expression - 449
 ldd 8,y
 lbeq L215
* Begin expression - 450
 leax -524,y
 stx -526,y
L216
* Begin expression - 451
 ldb [4,y]
 lbeq L217
* Begin expression - 452
 ldx 4,y
 ldb 0,x+
 stx 4,y
 stb -527,y
 sex
 lbra L219
L220
* Begin expression - 454
 ldd 8,y
 lbeq L221
* Begin expression - 455
 ldx 4,y
 ldb 0,x+
 stx 4,y
 stb -527,y
* Begin expression - 456
 cmpb #65
 lblt L222
* Begin expression - 457
 stb -124,y
* Begin expression - 458
 clr -123,y
* Begin expression - 459
 leax -124,y
 stx 0,s
 jsr _fsyml1
 std -531,y
* Begin expression - 460
 cmpd #-1
 lbne L223
* Begin expression - 461
 ldx #L224
 stx 0,s
 jsr _panic
 data
L224 fcb 85,110,100,101,102,63,0
 text
* Begin expression - 462
 ldd #1
 std -531,y
L223
* Begin expression - 464
 ldd -531,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 std -531,y
* Begin expression - 465
 ldx 4,y
 ldb 0,x+
 stx 4,y
 subb #48
 sex
 std -529,y
* Begin expression - 466
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -531,y
 ldx 0,x
 ldb d,x
 ldx -526,y
 stb 0,x+
 stx -526,y
 lbra L225
L222
* Begin expression - 469
 ldb -527,y
 subb #48
 sex
 std -529,y
* Begin expression - 470
 lslb
 rola
 ldx 6,y
 ldu d,x
L226
* Begin expression - 471
 ldb 0,u+
 ldx -526,y
 stb 0,x+
 stx -526,y
 tstb
 lbne L226
L227
* Begin expression - 472
 ldx -526,y
 leax -1,x
 stx -526,y
L225
 lbra L228
L221
* Begin expression - 476
 ldb -527,y
 ldx -526,y
 stb 0,x+
 stx -526,y
L228
 lbra L218
L229
* Begin expression - 480
 ldb [4,y]
 cmpb #38
 lbne L230
 ldd 8,y
10
 lbeq L230
* Begin expression - 481
 ldb #38
 ldx -526,y
 stb 0,x+
 stx -526,y
* Begin expression - 482
 ldx 4,y
 leax 1,x
 stx 4,y
 lbra L231
L230
* Begin expression - 484
 ldb -527,y
 ldx -526,y
 stb 0,x+
 stx -526,y
L231
 lbra L218
L232
* Begin expression - 487
 ldb -527,y
 ldx -526,y
 stb 0,x+
 stx -526,y
 lbra L218
L219
 ldx #L10013
 std L10012
L10011 cmpd 0,x++
 bne L10011
 jmp [L10012-L10013,x]
 data
L10013  fdb 38,92
L10012 fdb 0
 fdb L220,L229,L232
 text
L218
 lbra L216
L217
* Begin expression - 490
 clr [-526,y]
* Begin expression - 491
 leax -524,y
 stx -526,y
 lbra L233
L215
* Begin expression - 493
 ldx 4,y
 stx -526,y
L233
* Begin expression - 494
 inc _nestc+1
 bne 1f
 inc _nestc
1
L234
* Begin expression - 495
 ldb [-526,y]
 lbeq L235
* Begin expression - 496
 leau -124,y
L236
* Begin expression - 497
 ldx -526,y
 ldb 0,x+
 stx -526,y
 stb 0,u+
 cmpb #13
 lbne L236
L237
* Begin expression - 498
 clr 0,u
* Begin expression - 499
 ldd _nestc
 lslb
 rola
 ldx #_nest
 leax d,x
 stx 0,s
 ldx -526,y
 stx [0,s]
* Begin expression - 500
 leax -124,y
 stx 0,s
 jsr _cline
* Begin expression - 501
 ldd _nestc
 lslb
 rola
 ldx #_nest
 ldx d,x
 stx -526,y
 lbra L234
L235
* Begin expression - 503
 tst _nestc+1
 bne 1f
 dec _nestc
1 dec _nestc+1
L214 equ 531
L213
 leas -4,y
 puls x,y,u,pc
 global _dumpst
_dumpst pshs u,y,x
 leay 4,s
 leas -L239,s
* Register 1 p
* Auto -6 i
* Auto -8 k
* Auto -10 j
* Auto -12 jj
* Auto -14 w
* Begin expression - 514
 ldb _malflag
 lbne L240
 lbra L238
L240
* Begin expression - 515
 ldb _sorflag
 lbeq L241
L241
* Begin expression - 520
 ldd #1
 std -6,y
* Begin expression - 521
 ldd #1
 std -10,y
L242
* Begin expression - 522
 ldd -6,y
 cmpd _symll
 lbge L243
* Begin expression - 523
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #16
 pshs d
 ldd -6,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 524
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 525
 ldd -6,y
 lslb
 rola
 lslb
 rola
 lslb
 rola
 ldx #_symn
 leax d,x
 stx -8,y
* Begin expression - 526
 inc -5,y
 bne 1f
 inc -6,y
1
* Begin expression - 527
 ldd #0
 std -14,y
L244
* Begin expression - 528
 ldd -14,y
 cmpd #8
 lbge L245
 ldb [-8,y]
10
 lbeq L245
* Begin expression - 529
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldx -8,y
 ldb 0,x+
 stx -8,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldx -8,y
 ldb 0,x+
 stx -8,y
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 530
 inc -13,y
 bne 1f
 inc -14,y
1
 lbra L244
L245
L246
* Begin expression - 532
 ldd -14,y
 cmpd #14
 lbge L247
* Begin expression - 532
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 532
 inc -13,y
 bne 1f
 inc -14,y
1
 lbra L246
L247
* Begin expression - 533
 ldd -10,y
 inc -9,y
 bne 1f
 inc -10,y
1
 std 0,s
 ldd #3
 jsr imod
 lbne L248
* Begin expression - 533
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L249
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L249
L248
* Begin expression - 534
 ldx #L250
 stx 0,s
 jsr _printf
 data
L250 fcb 32,32,32,32,32,0
 text
L249
 lbra L242
L243
* Begin expression - 536
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
L239 equ 14
L238
 leas -4,y
 puls x,y,u,pc
 global _commaerr
_commaerr pshs u,y,x
 leay 4,s
* Auto 4 ss
 leas -L252,s
* Begin expression - 542
 ldx 4,y
 stx 0,s
 jsr _eatspac
* Begin expression - 543
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L253
* Begin expression - 544
 ldx [4,y]
 leax 1,x
 stx [4,y]
* Begin expression - 545
 ldx _MI
 stx 0,s
 jsr _panic
L253
* Begin expression - 547
 ldx 4,y
 stx 0,s
 jsr _eatspac
L254
* Begin expression - 548
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L255
* Begin expression - 549
 ldx [4,y]
 leax 1,x
 stx [4,y]
* Begin expression - 550
 ldx 4,y
 stx 0,s
 jsr _eatspac
 lbra L254
L255
L252 equ 4
L251
 leas -4,y
 puls x,y,u,pc
 global _panic
_panic pshs u,y,x
 leay 4,s
* Auto 4 s
 leas -L257,s
* Begin expression - 557
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #37
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #37
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 557
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #37
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #37
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 558
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #10
 pshs d
 ldd _lineno
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 559
 ldx 4,y
 stx 0,s
 ldx #L258
 pshs x
 jsr _printf
 leas 2,s
 data
L258 fcb 58,32,37,115,13,0
 text
* Begin expression - 560
 ldd _numerrs
 addd #1
 std _numerrs
L257 equ 4
L256
 leas -4,y
 puls x,y,u,pc
 global _eqs
_eqs pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L260,s
* Begin expression - 566
 ldd 4,y
 cmpd #13
 beq 10f
 cmpd #59
10
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L259
L260 equ 4
L259
 leas -4,y
 puls x,y,u,pc
 global _neqs
_neqs pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L262,s
* Begin expression - 572
 ldd 4,y
 cmpd #13
 beq 10f
 cmpd #59
10
 bne 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L261
L262 equ 4
L261
 leas -4,y
 puls x,y,u,pc
 global _p1cnc
_p1cnc pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L264,s
* Auto -6 i
* Begin expression - 579
 ldd #1
 std -6,y
* Begin expression - 580
 ldx 4,y
 stx 0,s
 jsr _eatspac
* Begin expression - 581
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L265
* Begin expression - 582
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 583
 ldd #1
 lbra L263
L265
L266
* Begin expression - 585
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L267
* Begin expression - 586
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L268
* Begin expression - 587
 inc -5,y
 bne 1f
 inc -6,y
1
* Begin expression - 588
 ldx [4,y]
 leax 1,x
 stx [4,y]
* Begin expression - 589
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L269
L270
* Begin expression - 590
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 cmpb #44
 lbne L271
* Begin expression - 590
 inc -5,y
 lbne L270
 inc -6,y
 lbra L270
L271
* Begin expression - 591
 ldx _SYN
 stx 0,s
 jsr _panic
L269
L268
* Begin expression - 594
 ldx [4,y]
 leax 1,x
 stx [4,y]
 lbra L266
L267
* Begin expression - 596
 ldd -6,y
 lbra L263
L264 equ 6
L263
 leas -4,y
 puls x,y,u,pc
 global _p2evn
_p2evn pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L273,s
* Begin expression - 602
 ldd #0
 std _p2evnn
* Begin expression - 603
 ldx 4,y
 stx 0,s
 jsr _eatspac
* Begin expression - 604
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L274
* Begin expression - 605
 ldb #0
 stb _p2evnf
 lbra L272
L274
* Begin expression - 608
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L275
* Begin expression - 608
 ldx [4,y]
 leax 1,x
 stx [4,y]
L275
* Begin expression - 609
 ldx 4,y
 stx 0,s
 jsr _evolexp
 std _p2evnn
* Begin expression - 610
 ldb #1
 stb _p2evnf
 lbra L272
L273 equ 4
L272
 leas -4,y
 puls x,y,u,pc
 global _prn
_prn pshs u,y,x
 leay 4,s
 leas -L277,s
* Auto -6 i
* Begin expression - 617
 ldd _ifdc
 lbne L278
 ldb _listfla
 lbeq L278
 ldb _malflag
 lbeq L278
 ldd _nestc
 beq 11f
 ldb _macflag
 beq 11f
 ldb _mamflag
11
10
 lbne L278
* Begin expression - 618
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #10
 pshs d
 ldd _lineno
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 619
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 620
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #16
 pshs d
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 621
 ldx #L279
 stx 0,s
 jsr _printf
 data
L279 fcb 32,32,0
 text
* Begin expression - 622
 ldd _prebyte
 lbeq L280
* Begin expression - 622
 std 0,s
 jsr _phexd
 lbra L281
L280
* Begin expression - 623
 ldx #L282
 stx 0,s
 jsr _printf
 data
L282 fcb 32,32,0
 text
L281
* Begin expression - 624
 ldd _b1
 clra
 std _b1
* Begin expression - 625
 std 0,s
 jsr _phexd
* Begin expression - 626
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 627
 ldd _fb2
 lbeq L283
* Begin expression - 627
 ldd _b2
 std 0,s
 jsr _phexd
 lbra L284
L283
* Begin expression - 628
 ldx #L285
 stx 0,s
 jsr _printf
 data
L285 fcb 32,32,0
 text
L284
* Begin expression - 629
 ldd _fb3
 lbeq L286
* Begin expression - 629
 ldd _b3
 std 0,s
 jsr _phexd
 lbra L287
L286
* Begin expression - 630
 ldx #L288
 stx 0,s
 jsr _printf
 data
L288 fcb 32,32,0
 text
L287
* Begin expression - 631
 ldd _fb4
 lbeq L289
* Begin expression - 631
 ldd _b4
 std 0,s
 jsr _phexd
 lbra L290
L289
* Begin expression - 632
 ldx #L291
 stx 0,s
 jsr _printf
 data
L291 fcb 32,32,0
 text
L290
* Begin expression - 633
 ldx #L292
 stx 0,s
 jsr _printf
 data
L292 fcb 32,0
 text
L278
* Begin expression - 635
 jsr _pbytes
L277 equ 6
L276
 leas -4,y
 puls x,y,u,pc
 global _prsn
_prsn pshs u,y,x
 leay 4,s
* Auto 4 n
 leas -L294,s
* Begin expression - 641
 jsr _canlist
 cmpd #0
 lbne L295
 lbra L293
L295
* Begin expression - 642
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #10
 pshs d
 ldd _lineno
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 643
 ldx #L296
 stx 0,s
 jsr _printf
 data
L296 fcb 32,32,32,32,32,32,32,32,32,32,32,32,0
 text
* Begin expression - 644
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #16
 pshs d
 ldd 4,y
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 645
 ldx #L297
 stx 0,s
 jsr _printf
 data
L297 fcb 32,32,32,0
L294 equ 4
 text
L293
 leas -4,y
 puls x,y,u,pc
 global _prsnb
_prsnb pshs u,y,x
 leay 4,s
 leas -L299,s
* Begin expression - 650
 ldb _bytef
 lbeq L300
 jsr _canlist
10
 cmpd #0
 lbeq L300
* Begin expression - 651
 ldb _bytep
 lbne L301
* Begin expression - 652
 jsr _prspc
* Begin expression - 653
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
L301
* Begin expression - 655
 ldd _b1
 std 0,s
 jsr _phexd
* Begin expression - 656
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 657
 ldb _bytep
 inc _bytep
 cmpb #15
 lblt L302
* Begin expression - 658
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 659
 clr _bytep
L302
L300
L299 equ 4
L298
 leas -4,y
 puls x,y,u,pc
 global _prs
_prs pshs u,y,x
 leay 4,s
 leas -L304,s
* Begin expression - 668
 jsr _canlist
 cmpd #0
 lbeq L305
* Begin expression - 669
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #10
 pshs d
 ldd _lineno
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 670
 ldx #L306
 stx 0,s
 jsr _printf
 data
L306 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 32,32,32,0
 text
L305
L304 equ 4
L303
 leas -4,y
 puls x,y,u,pc
 global _prspc
_prspc pshs u,y,x
 leay 4,s
 leas -L308,s
* Begin expression - 676
 jsr _canlist
 cmpd #0
 lbeq L309
* Begin expression - 677
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #10
 pshs d
 ldd _lineno
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 678
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 679
 ldd #0
 std 0,s
 ldd #4
 pshs d
 ldd #16
 pshs d
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 pshs d
 jsr _jnum
 leas 6,s
* Begin expression - 680
 ldx #L310
 stx 0,s
 jsr _printf
 data
L310 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,0
 text
L309
L308 equ 4
L307
 leas -4,y
 puls x,y,u,pc
 global _prl
_prl pshs u,y,x
 leay 4,s
* Auto 4 line
 leas -L312,s
* Register 1 k
* Auto -5 delay
* Begin expression - 688
 jsr _canlist
 cmpd #0
 lbne L313
 lbra L311
L313
* Begin expression - 689
 ldu 4,y
* Begin expression - 690
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #32
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #32
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 691
 ldb 0,u
 lbne L314
 lbra L311
L314
* Begin expression - 692
 ldx 4,y
 ldb 1,x
 lbne L315
 lbra L311
L315
* Begin expression - 693
 ldb 0,u+
 stb -5,y
L316
* Begin expression - 694
 ldb 0,u
 lbeq L317
* Begin expression - 695
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb -5,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb -5,y
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 696
 ldb 0,u+
 stb -5,y
 lbra L316
L317
* Begin expression - 698
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
L312 equ 5
L311
 leas -4,y
 puls x,y,u,pc
 global _prsl
_prsl pshs u,y,x
 leay 4,s
* Auto 4 line
 leas -L319,s
* Begin expression - 704
 jsr _canlist
 cmpd #0
 lbne L320
 lbra L318
L320
* Begin expression - 705
 jsr _prs
* Begin expression - 706
 ldx 4,y
 stx 0,s
 jsr _prl
L319 equ 4
L318
 leas -4,y
 puls x,y,u,pc
 global _canlist
_canlist pshs u,y,x
 leay 4,s
 leas -L322,s
* Begin expression - 710
 ldb _listfla
 beq 10f
 ldb _malflag
 beq 10f
 ldd _ifdc
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 std 0,s
 ldd _nestc
 beq 11f
 ldb _macflag
 beq 11f
 ldb _mamflag
11
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 sex
 anda 0,s
 andb 1,s
10
 cmpd #0
 bne 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L321
L322 equ 4
L321
 leas -4,y
 puls x,y,u,pc
 global _pbytes
_pbytes pshs u,y,x
 leay 4,s
 leas -L324,s
* Begin expression - 714
 ldb _binflag
 lbeq L325
 lbra L323
L325
* Begin expression - 715
 ldb _mabflag
 lbeq L326
 lbra L323
L326
* Begin expression - 716
 ldd _pcost
 lbeq L327
* Begin expression - 717
 ldd #0
 std _pcost
* Begin expression - 718
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std _pcolpc
L327
L328
* Begin expression - 720
 ldd _pcocnt
 lbne L329
* Begin expression - 721
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std _pcolpc
* Begin expression - 722
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std _pcobs
* Begin expression - 723
 ldd _psect
 std _pcobsp
L329
* Begin expression - 725
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 cmpd _pcolpc
 lbeq L330
* Begin expression - 726
 jsr _pdump
 lbra L328
L330
* Begin expression - 729
 ldd _prebyte
 lbeq L331
* Begin expression - 730
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _prebyte
 std 0,x
* Begin expression - 731
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
* Begin expression - 732
 inc _pcolpc+1
 bne 1f
 inc _pcolpc
1
* Begin expression - 733
 ldd _relob
 lslb
 rola
 std _relob
L331
* Begin expression - 735
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _b1
 std 0,x
* Begin expression - 736
 ldd _relob
 lslb
 rola
 std _relob
* Begin expression - 737
 ldd _relocat
 cmpd #1
 lbne L332
* Begin expression - 738
 ldd _relob
 orb #$1
 std _relob
* Begin expression - 738
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L333
L332
* Begin expression - 740
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
L333
* Begin expression - 741
 ldd _pcolpc
 addd #1
 std _pcolpc
* Begin expression - 742
 ldd _fb2
 lbeq L334
* Begin expression - 743
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _b2
 std 0,x
* Begin expression - 744
 ldd _pcolpc
 addd #1
 std _pcolpc
* Begin expression - 745
 ldd _relob
 lslb
 rola
 std _relob
* Begin expression - 746
 ldd _relocat
 cmpd #2
 lbne L335
* Begin expression - 747
 ldd _relob
 orb #$1
 std _relob
* Begin expression - 747
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L336
L335
* Begin expression - 749
 ldd _relocat
 cmpd #1
 lbne L337
* Begin expression - 749
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L338
L337
* Begin expression - 750
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
L338
L336
L334
* Begin expression - 752
 ldd _fb3
 lbeq L339
* Begin expression - 753
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _b3
 std 0,x
* Begin expression - 754
 ldd _pcolpc
 addd #1
 std _pcolpc
* Begin expression - 755
 ldd _relob
 lslb
 rola
 std _relob
* Begin expression - 756
 ldd _relocat
 cmpd #3
 lbne L340
* Begin expression - 757
 ldd _relob
 orb #$1
 std _relob
* Begin expression - 757
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L341
L340
* Begin expression - 759
 ldd _relocat
 cmpd #2
 lbne L342
* Begin expression - 759
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L343
L342
* Begin expression - 760
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
L343
L341
L339
* Begin expression - 762
 ldd _fb4
 lbeq L344
* Begin expression - 763
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _b4
 std 0,x
* Begin expression - 764
 ldd _pcolpc
 addd #1
 std _pcolpc
* Begin expression - 765
 ldd _relob
 lslb
 rola
 std _relob
* Begin expression - 766
 ldd _relocat
 cmpd #3
 lbne L345
* Begin expression - 766
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _spsect
 stb 0,x
 lbra L346
L345
* Begin expression - 767
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
L346
L344
* Begin expression - 769
 ldd _fb5
 lbeq L347
* Begin expression - 770
 ldd _pcocnt
 lslb
 rola
 ldx #_pcob
 leax d,x
 ldd _b5
 std 0,x
* Begin expression - 771
 ldd _pcolpc
 addd #1
 std _pcolpc
* Begin expression - 772
 ldd _relob
 lslb
 rola
 std _relob
* Begin expression - 773
 ldd _pcocnt
 inc _pcocnt+1
 bne 1f
 inc _pcocnt
1
 ldx #_ppsect
 leax d,x
 ldd _psect
 stb 0,x
L347
* Begin expression - 775
 ldd _pcocnt
 cmpd #10
 lble L348
* Begin expression - 776
 jsr _pdump
 lbra L323
L348
L324 equ 4
L323
 leas -4,y
 puls x,y,u,pc
 global _pdump
_pdump pshs u,y,x
 leay 4,s
 leas -L350,s
* Auto -6 i
* Auto -8 j
* Begin expression - 787
 ldb #83
 sex
 std 0,s
 jsr _dput
* Begin expression - 787
 ldb #50
 sex
 std 0,s
 jsr _dput
* Begin expression - 788
 ldd #0
 std -6,y
* Begin expression - 789
 ldd #0
 std _pcoch
* Begin expression - 790
 ldd _pcocnt
 addd #5
 std 0,s
 jsr _pdumb
* Begin expression - 791
 ldd _relob
 tfr a,b
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 792
 ldd _relob
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 793
 ldd _pcobs
 tfr a,b
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 794
 ldd _pcobs
 clra
 std 0,s
 jsr _pdumb
* Begin expression - 795
 ldd _pcobsp
 std 0,s
 jsr _pdumb
L351
* Begin expression - 796
 ldd _pcocnt
 lbeq L352
* Begin expression - 797
 ldd -6,y
 ldx #_ppsect
 ldb d,x
 sex
 std 0,s
 jsr _pdumb
* Begin expression - 798
 ldd -6,y
 inc -5,y
 bne 1f
 inc -6,y
1
 lslb
 rola
 ldx #_pcob
 ldd d,x
 std 0,s
 jsr _pdumb
* Begin expression - 799
 tst _pcocnt+1
 bne 1f
 dec _pcocnt
1 dec _pcocnt+1
 lbra L351
L352
* Begin expression - 801
 ldd _pcoch
 comb
 coma
 std 0,s
 jsr _pdumb
* Begin expression - 802
 ldb #13
 sex
 std 0,s
 jsr _dput
* Begin expression - 803
 ldd #0
 std _relob
L350 equ 8
L349
 leas -4,y
 puls x,y,u,pc
 global _pdumb
_pdumb pshs u,y,x
 leay 4,s
* Auto 4 n
 leas -L354,s
* Auto -6 i
* Auto -8 j
* Begin expression - 811
 ldd 4,y
 std -6,y
* Begin expression - 812
 clra
 andb #$F0
 asra
 rorb
 asra
 rorb
 asra
 rorb
 asra
 rorb
 std -6,y
* Begin expression - 813
 std 0,s
 jsr _phexdm
 std 0,s
 jsr _dput
* Begin expression - 814
 ldd 4,y
 clra
 andb #$F
 std -6,y
* Begin expression - 815
 std 0,s
 jsr _phexdm
 std 0,s
 jsr _dput
* Begin expression - 816
 ldd _pcoch
 addd 4,y
 std _pcoch
L354 equ 8
L353
 leas -4,y
 puls x,y,u,pc
 global _dput
_dput pshs u,y,x
 leay 4,s
* Auto 4 data
 leas -L356,s
* Begin expression - 822
 ldd _dbuffc
 inc _dbuffc+1
 bne 1f
 inc _dbuffc
1
 ldx #_dbuff
 leax d,x
 ldd 4,y
 stb 0,x
* Begin expression - 823
 ldd _dbuffc
 cmpd #512
 lbne L357
* Begin expression - 824
 ldd #512
 std 0,s
 ldx #_dbuff
 pshs x
 ldd _fd
 pshs d
 jsr _write
 leas 4,s
* Begin expression - 825
 ldd #0
 std _dbuffc
L357
L356 equ 4
L355
 leas -4,y
 puls x,y,u,pc
 global _fdput
_fdput pshs u,y,x
 leay 4,s
 leas -L359,s
* Begin expression - 830
 ldd _dbuffc
 lbeq L360
* Begin expression - 830
 std 0,s
 ldx #_dbuff
 pshs x
 ldd _fd
 pshs d
 jsr _write
 leas 4,s
L360
L359 equ 4
L358
 leas -4,y
 puls x,y,u,pc
 global _phexd
_phexd pshs u,y,x
 leay 4,s
* Auto 4 n
 leas -L362,s
* Auto -6 i
* Auto -8 j
* Begin expression - 838
 ldd 4,y
 std -6,y
* Begin expression - 839
 clra
 andb #$F0
 asra
 rorb
 asra
 rorb
 asra
 rorb
 asra
 rorb
 std -6,y
* Begin expression - 840
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 std 0,s
 jsr _phexdm
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr _phexdm
 std 0,s
 jsr __flsbuf
11
* Begin expression - 841
 ldd 4,y
 clra
 andb #$F
 std -6,y
* Begin expression - 842
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 std 0,s
 jsr _phexdm
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd -6,y
 std 0,s
 jsr _phexdm
 std 0,s
 jsr __flsbuf
11
L362 equ 8
L361
 leas -4,y
 puls x,y,u,pc
 global _phexdm
_phexdm pshs u,y,x
 leay 4,s
* Auto 4 i
 leas -L364,s
* Begin expression - 848
 ldd 4,y
 addd #48
 std 4,y
* Begin expression - 849
 cmpd #57
 lble L365
* Begin expression - 849
 ldb #57
 sex
 addd #1
 negb
 addb #65
 sex
 addd 4,y
 std 4,y
L365
* Begin expression - 850
 ldd 4,y
 lbra L363
L364 equ 4
L363
 leas -4,y
 puls x,y,u,pc
 global _ppb
_ppb pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L367,s
* Begin expression - 856
 ldd 4,y
 lbra L369
L370
* Begin expression - 858
 ldd #2
 lbra L366
L371
* Begin expression - 860
 ldd #4
 lbra L366
L372
* Begin expression - 862
 ldd #16
 lbra L366
L373
* Begin expression - 864
 ldd #128
 lbra L366
L374
* Begin expression - 866
 ldd #64
 lbra L366
L375
* Begin expression - 868
 ldd #32
 lbra L366
L376
* Begin expression - 870
 ldd #1
 lbra L366
L377
* Begin expression - 872
 ldd #6
 lbra L366
L378
* Begin expression - 874
 ldd #8
 lbra L366
 lbra L368
L369
 ldx #L10017
 std L10016
L10015 cmpd 0,x++
 bne L10015
 jmp [L10016-L10017,x]
 data
L10017  fdb 97,98,120,112,117,121,99,100,122
L10016 fdb 0
 fdb L370,L371,L372,L373,L374,L375,L376,L377,L378,L10014
 text
L10014
 text
L368
* Begin expression - 876
 ldx #L379
 stx 0,s
 jsr _panic
 data
L379 fcb 66,97,100,32,112,115,104,47,112,117,108,32,114,101,103,105
 fcb 115,116,101,114,32,111,112,101,114,104,97,110,100,0
L367 equ 4
 text
L366
 leas -4,y
 puls x,y,u,pc
 global _ibr
_ibr pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L381,s
* Begin expression - 883
 ldd 4,y
 lbra L383
L384
* Begin expression - 885
 ldd #0
 lbra L380
L385
* Begin expression - 887
 ldd #1
 lbra L380
L386
* Begin expression - 889
 ldd #2
 lbra L380
L387
* Begin expression - 891
 ldd #3
 lbra L380
 lbra L382
L383
 ldx #L10021
 std L10020
L10019 cmpd 0,x++
 bne L10019
 jmp [L10020-L10021,x]
 data
L10021  fdb 120,121,117,115
L10020 fdb 0
 fdb L384,L385,L386,L387,L10018
 text
L10018
 text
L382
* Begin expression - 893
 ldx #L388
 stx 0,s
 jsr _panic
 data
L388 fcb 66,97,100,32,105,110,100,101,120,32,114,101,103,105,115,116
 fcb 101,114,0
L381 equ 4
 text
L380
 leas -4,y
 puls x,y,u,pc
 global _setpre
_setpre pshs u,y,x
 leay 4,s
* Auto 4 s
 leas -L390,s
* Begin expression - 899
 ldx #_mot10
 stx 0,s
 ldx 4,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L391
* Begin expression - 899
 ldd #16
 std _prebyte
L391
* Begin expression - 900
 ldx #_mot11
 stx 0,s
 ldx 4,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L392
* Begin expression - 900
 ldd #17
 std _prebyte
L392
L390 equ 4
L389
 leas -4,y
 puls x,y,u,pc
 global _tfrb
_tfrb pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L394,s
* Begin expression - 906
 ldd 4,y
 lbra L396
L397
* Begin expression - 908
 ldd #0
 lbra L393
L398
* Begin expression - 910
 ldd #1
 lbra L393
L399
* Begin expression - 912
 ldd #2
 lbra L393
L400
* Begin expression - 914
 ldd #3
 lbra L393
L401
* Begin expression - 916
 ldd #4
 lbra L393
L402
* Begin expression - 918
 ldd #5
 lbra L393
L403
* Begin expression - 920
 ldd #8
 lbra L393
L404
* Begin expression - 922
 ldd #9
 lbra L393
L405
* Begin expression - 924
 ldd #10
 lbra L393
 lbra L395
L396
 ldx #L10025
 std L10024
L10023 cmpd 0,x++
 bne L10023
 jmp [L10024-L10025,x]
 data
L10025  fdb 100,120,121,117,115,112,97,98,99
L10024 fdb 0
 fdb L397,L398,L399,L400,L401,L402,L403,L404,L405,L10022
 text
L10022
 text
L395
* Begin expression - 926
 ldx #L406
 stx 0,s
 jsr _panic
 data
L406 fcb 66,97,100,32,116,102,114,47,101,120,103,32,114,101,103,105
 fcb 115,116,101,114,32,111,112,101,114,104,97,110,100,0
 text
* Begin expression - 927
 ldd #0
 lbra L393
L394 equ 4
L393
 leas -4,y
 puls x,y,u,pc
 global _opsize
_opsize pshs u,y,x
 leay 4,s
* Auto 4 k
 leas -L408,s
* Auto -6 i
* Register 1 p
* Auto -8 sp
* Auto -9 iflag
* Begin expression - 937
 ldu [4,y]
* Begin expression - 938
 stu -8,y
* Begin expression - 939
 clr -9,y
* Begin expression - 940
 ldb 0,u
 cmpb #91
 lbne L409
* Begin expression - 941
 ldb #1
 stb -9,y
* Begin expression - 942
 leau 1,u
L409
* Begin expression - 944
 ldb 0,u
 cmpb #44
 lbne L410
* Begin expression - 944
 ldd #0
 lbra L407
L410
* Begin expression - 945
 ldb 1,u
 cmpb #44
 lbne L411
* Begin expression - 946
 ldb 0,u
 cmpb #97
 beq 11f
 ldb 0,u
 cmpb #98
 beq 11f
 ldb 0,u
 cmpb #100
10
 lbne L412
11
* Begin expression - 947
 ldd #0
 lbra L407
L412
L411
* Begin expression - 949
 ldb 0,u
 cmpb #45
 lbne L413
* Begin expression - 949
 leau 1,u
L413
* Begin expression - 950
 ldb 0,u
 sex
 std 0,s
 jsr _islet
 cmpd #0
 lbne L414
* Begin expression - 951
 leau 1,u
L415
* Begin expression - 952
 ldb 0,u
 cmpb #44
 lbeq L416
 ldb 0,u
 cmpb #59
 lbeq L416
 ldb 0,u
 cmpb #13
10
 lbeq L416
* Begin expression - 953
 ldb 0,u+
 sex
 std 0,s
 jsr _island
 cmpd #1
 lbeq L417
* Begin expression - 953
 ldd #2
 lbra L407
L417
 lbra L415
L416
* Begin expression - 955
 ldx 4,y
 stx 0,s
 jsr _evolexp
 std -6,y
* Begin expression - 956
 ldx -8,y
 stx [4,y]
* Begin expression - 957
 cmpd #0
 lbge L418
* Begin expression - 957
 ldd -6,y
 nega
 negb
 sbca #0
 std -6,y
L418
* Begin expression - 958
 ldd -6,y
 cmpd #16
 lbge L419
* Begin expression - 959
 ldb -9,y
 lbeq L420
* Begin expression - 959
 ldd #1
 lbra L407
L420
* Begin expression - 960
 ldd #0
 lbra L407
L419
* Begin expression - 962
 ldd -6,y
 cmpd #128
 lbge L421
* Begin expression - 963
 ldd #1
 lbra L407
L421
* Begin expression - 964
 ldd #2
 lbra L407
L414
* Begin expression - 966
 ldd #2
 lbra L407
L408 equ 9
L407
 leas -4,y
 puls x,y,u,pc
 global _swapit
_swapit pshs u,y,x
 leay 4,s
* Auto 4 ss
 leas -L423,s
* Register 1 s
* Begin expression - 973
 ldu 4,y
* Begin expression - 974
 ldb 0,u
 cmpb #45
 lbeq L424
 lbra L422
L424
* Begin expression - 975
 ldb 1,u
 cmpb #45
 lbne L425
* Begin expression - 976
 ldb 2,u
 stb 0,u
* Begin expression - 977
 ldb #45
 stb 2,u
 stb 1,u
 lbra L422
L425
* Begin expression - 980
 ldb 1,u
 stb 0,u
* Begin expression - 981
 ldb #45
 stb 1,u
L423 equ 4
L422
 leas -4,y
 puls x,y,u,pc
 global _getarg
_getarg pshs u,y,x
 leay 4,s
* Auto 4 ss
* Auto 6 arg
 leas -L427,s
* Register 1 p
* Begin expression - 993
 ldx 4,y
 stx 0,s
 jsr _eatspac
* Begin expression - 994
 ldu 6,y
* Begin expression - 994
 clr 0,u
* Begin expression - 995
 ldx [4,y]
 ldb 0,x
 cmpb #44
 lbne L428
* Begin expression - 996
 ldx [4,y]
 leax 1,x
 stx [4,y]
* Begin expression - 997
 ldx 4,y
 stx 0,s
 jsr _eatspac
* Begin expression - 998
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L429
* Begin expression - 999
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 1000
 ldd #0
 lbra L426
L429
L428
* Begin expression - 1003
 ldx 4,y
 stx 0,s
 jsr _commaer
* Begin expression - 1004
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L430
* Begin expression - 1004
 ldd #0
 lbra L426
L430
L431
* Begin expression - 1005
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _island
 cmpd #0
 lbeq L432
* Begin expression - 1006
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb 0,u+
 lbra L431
L432
* Begin expression - 1008
 clr 0,u
* Begin expression - 1009
 ldd #1
 lbra L426
L427 equ 4
L426
 leas -4,y
 puls x,y,u,pc
 global _cline
_cline pshs u,y,x
 leay 4,s
* Auto 4 line
 leas -L434,s
* Auto -25 arg
* Auto -46 sarg
* Auto -446 lline
* Auto -546 llline
* Auto -548 s
* Auto -550 ss
* Auto -552 savess
* Auto -553 ncount
* Auto -554 fasciz
* Auto -556 hlable
* Auto -558 hclable
* Auto -560 hdclable
* Auto -562 ii
* Auto -564 jj
* Auto -584 marg
* Auto -684 mmarg
* Auto -714 maclab
* Auto -946 mmaclab
* Auto -947 c
* Auto -949 i
* Auto -951 j
* Begin expression - 1035
 ldd #0
 std -556,y
* Begin expression - 1036
 ldd #0
 std -558,y
* Begin expression - 1037
 ldd #1
 std -560,y
* Begin expression - 1038
 leax -684,y
 stx 0,s
 leax -584,y
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 1039
 leax -946,y
 stx 0,s
 leax -714,y
 pshs x
 jsr _mixerup
 leas 2,s
* Begin expression - 1040
 ldd 4,y
 std -548,y
* Begin expression - 1041
 leax -548,y
 stx -550,y
* Begin expression - 1042
 clr -25,y
* Begin expression - 1043
 inc _symv+1
 bne 1f
 inc _symv
1
* Begin expression - 1044
 clr -554,y
* Begin expression - 1045
 clr _bytep
* Begin expression - 1046
 ldb #1
 stb _p2evnf
* Begin expression - 1047
 ldd #_pc
 std _symv
* Begin expression - 1048
 ldd #0
 std _spsect
* Begin expression - 1050
 ldd _pass
 cmpd #1
 lbne L435
* Begin expression - 1053
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #1
 lbne L436
* Begin expression - 1054
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
 std -949,y
 cmpd #58
 lbne L437
L438
* Begin expression - 1055
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1056
 ldd #1
 std -558,y
* Begin expression - 1057
 ldx [-550,y]
 ldb 0,x
 cmpb #58
 lbne L439
* Begin expression - 1058
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1059
 ldd #0
 std -560,y
L439
L437
* Begin expression - 1062
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1063
 ldd -949,y
 cmpd #-1
 lbne L440
* Begin expression - 1064
 ldx #L441
 stx 0,s
 jsr _panic
 data
L441 fcb 77,105,115,115,105,110,103,32,79,112,99,111,100,101,0
 text
 lbra L442
L440
* Begin expression - 1067
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -949,y
 cmpd #-1
 lbeq L443
* Begin expression - 1068
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L444
* Begin expression - 1069
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1070
 ldd -949,y
 std -951,y
* Begin expression - 1071
 ldb -25,y
 stb -46,y
* Begin expression - 1071
 ldb -24,y
 stb -45,y
 lbra L445
 lbra L446
L444
* Begin expression - 1075
 ldd -949,y
 cmpd #1
 lble L447
* Begin expression - 1076
 ldx #L448
 stx 0,s
 jsr _panic
 data
L448 fcb 68,111,117,98,108,101,32,100,101,102,105,110,101,100,32,115
 fcb 121,109,98,111,108,58,0
 text
* Begin expression - 1077
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
L447
L446
L443
* Begin expression - 1080
 ldd -949,y
 cmpd #-1
 lbne L449
* Begin expression - 1081
 ldb -25,y
 cmpb #36
 beq 11f
 cmpb #37
10
 lbne L450
11
* Begin expression - 1082
 ldx _BL
 stx 0,s
 jsr _panic
 lbra L451
L450
* Begin expression - 1085
 leax -25,y
 stx 0,s
 jsr _fsyms
 std -949,y
* Begin expression - 1086
 ldx #_symp
 leax d,x
 ldd _psect
 stb 0,x
* Begin expression - 1087
 ldd -949,y
 lslb
 rola
 ldx #_symv
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 std [0,s]
* Begin expression - 1088
 inc -555,y
 bne 1f
 inc -556,y
1
* Begin expression - 1089
 ldd _macnest
 lbeq L452
 ldd -560,y
 bne 12f
 ldd _macnest
 ldx #_rlpass
 ldb d,x
 cmpb #1
10
 lbne L452
12
* Begin expression - 1090
 ldd _macnest
 lslb
 rola
 ldx #_macstac
 ldd d,x
 std 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L452
* Begin expression - 1091
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L453
* Begin expression - 1092
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1093
 ldd -949,y
 std -951,y
* Begin expression - 1094
 ldb -25,y
 stb -46,y
* Begin expression - 1094
 ldb -24,y
 stb -45,y
 lbra L445
L453
L451
L449
 lbra L454
L436
* Begin expression - 1101
 ldx [-550,y]
 ldb 0,x
 cmpb #59
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #42
10
 lbne L455
11
 lbra L442
L455
* Begin expression - 1102
 ldx [-550,y]
 ldb 0,x
 cmpb #32
 lbeq L456
 ldx [-550,y]
 ldb 0,x
 cmpb #9
10
 lbeq L456
* Begin expression - 1103
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbeq L442
L457
* Begin expression - 1104
 ldx #L458
 stx 0,s
 jsr _panic
 data
L458 fcb 73,110,118,97,108,105,100,32,108,97,98,108,101,0
 text
* Begin expression - 1105
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1106
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbeq L442
L459
L456
L454
* Begin expression - 1109
 ldx -550,y
 stx 0,s
 leax -46,y
 pshs x
 jsr _sscan
 leas 2,s
 std -949,y
* Begin expression - 1110
 cmpd #58
 lbne L460
* Begin expression - 1111
 leax -46,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _copystr
 leas 2,s
 lbra L438
L460
* Begin expression - 1114
 ldb -46,y
 lbne L461
 lbra L442
L461
* Begin expression - 1117
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1118
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L462
* Begin expression - 1119
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1120
 leax -46,y
 stx 0,s
 jsr _fsyml1
 std -951,y
 cmpd #-1
 lbne L463
* Begin expression - 1121
 ldx _UND
 stx 0,s
 jsr _panic
 lbra L442
L463
L445
* Begin expression - 1125
 ldd -951,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
* Begin expression - 1126
 ldd -951,y
 ldx #_symp
 leax d,x
 ldd _spsect
 stb 0,x
* Begin expression - 1127
 ldb -46,y
 cmpb #46
 lbne L464
 ldb -45,y
10
 lbne L464
* Begin expression - 1128
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 lslb
 rola
 stx 0,s
 ldx #_symv
 ldd d,x
 std [0,s]
L464
 lbra L442
L462
* Begin expression - 1133
 ldx #_mdef
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L465
L466
* Begin expression - 1134
 ldd #0
 std -562,y
* Begin expression - 1135
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1136
 ldd #0
 std -556,y
L467
* Begin expression - 1137
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L468
* Begin expression - 1138
 ldd #0
 std -564,y
* Begin expression - 1139
 clr -546,y
L469
* Begin expression - 1140
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbeq L470
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
10
 cmpd #0
 lbeq L470
* Begin expression - 1141
 ldd -564,y
 inc -563,y
 bne 1f
 inc -564,y
1
 leax -546,y
 leax d,x
 stx 0,s
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 stb [0,s]
 lbra L469
L470
* Begin expression - 1143
 ldd -564,y
 leax -546,y
 clr d,x
* Begin expression - 1144
 ldd -564,y
 cmpd #80
 lble L471
* Begin expression - 1144
 ldx #L472
 stx 0,s
 jsr _panic
 data
L472 fcb 84,111,111,32,109,97,110,121,32,99,104,97,114,97,99,116
 fcb 111,114,115,32,105,110,32,109,97,99,114,111,32,97,114,103
 fcb 46,0
 text
 lbra L473
L471
* Begin expression - 1145
 leax -584,y
 stx 0,s
 leax -546,y
 pshs x
 jsr _cement
 leas 2,s
L473
* Begin expression - 1146
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L474
* Begin expression - 1146
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L474
* Begin expression - 1147
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1148
 ldd -556,y
 inc -555,y
 bne 1f
 inc -556,y
1
 cmpd #9
 lble L475
* Begin expression - 1148
 ldx #L476
 stx 0,s
 jsr _panic
 data
L476 fcb 84,111,111,32,109,97,110,121,32,109,97,99,114,111,32,97
 fcb 114,103,117,109,101,110,116,115,0
 text
L475
* Begin expression - 1149
 ldx -550,y
 stx 0,s
 jsr _eatspac
 lbra L467
L468
L477
* Begin expression - 1151
 ldd -556,y
 inc -555,y
 bne 1f
 inc -556,y
1
 cmpd #10
 lbge L478
* Begin expression - 1151
 leax -584,y
 stx 0,s
 ldx #L479
 pshs x
 jsr _cement
 leas 2,s
 data
L479 fcb 0
 text
 lbra L477
L478
* Begin expression - 1152
 ldd _macnest
 addd #1
 std _macnest
 lslb
 rola
 ldx #_macstac
 leax d,x
 ldd -714,y
 std 0,x
* Begin expression - 1153
 ldd _macnest
 ldx #_rlpass
 leax d,x
 ldd _pass
 stb 0,x
* Begin expression - 1154
 ldd _pass
 cmpd #2
 lbne L480
* Begin expression - 1155
 ldd #1
 std _pass
* Begin expression - 1156
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std -949,y
* Begin expression - 1157
 ldd #1
 std 0,s
 leax -584,y
 pshs x
 ldd -951,y
 lslb
 rola
 ldx #_mbody
 ldd d,x
 pshs d
 jsr _mexp
 leas 4,s
* Begin expression - 1158
 ldd #2
 std _pass
* Begin expression - 1159
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -949,y
 std 0,x
* Begin expression - 1160
 ldd #1
 std 0,s
 leax -584,y
 pshs x
 ldd -951,y
 lslb
 rola
 ldx #_mbody
 ldd d,x
 pshs d
 jsr _mexp
 leas 4,s
 lbra L481
L480
* Begin expression - 1162
 ldd #1
 std 0,s
 leax -584,y
 pshs x
 ldd -951,y
 lslb
 rola
 ldx #_mbody
 ldd d,x
 pshs d
 jsr _mexp
 leas 4,s
L481
* Begin expression - 1163
 ldd _macnest
 subd #1
 std _macnest
L482
* Begin expression - 1164
 ldd -712,y
 cmpd #-1
 lbeq L483
* Begin expression - 1165
 ldd -712,y
 std 0,s
 jsr _fsyml1
 std -949,y
 cmpd #-1
 lbeq L484
* Begin expression - 1166
 ldx #_symn
 clr d,x
L484
* Begin expression - 1168
 leax -714,y
 stx 0,s
 ldd #1
 pshs d
 jsr _chisel
 leas 2,s
 lbra L482
L483
 lbra L442
 lbra L485
L465
* Begin expression - 1173
 ldx #_soptab
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L486
* Begin expression - 1175
 lbra L488
L489
L490
* Begin expression - 1178
 ldb -25,y
 lbne L491
* Begin expression - 1178
 ldx #L492
 stx 0,s
 jsr _panic
 data
L492 fcb 69,81,85,32,119,105,116,104,32,110,111,32,115,121,109,98
 fcb 111,108,0
 text
 lbra L493
L491
* Begin expression - 1179
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1180
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L494
11
* Begin expression - 1181
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 1182
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -949,y
* Begin expression - 1183
 ldx #_symn
 clr d,x
 lbra L493
L494
* Begin expression - 1186
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -949,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
* Begin expression - 1187
 ldd -556,y
 cmpd #1
 lble L495
* Begin expression - 1187
 ldx #L496
 stx 0,s
 jsr _panic
 data
L496 fcb 79,110,108,121,32,49,32,108,97,98,108,101,32,112,101,114
 fcb 32,101,113,117,0
 text
L495
L493
* Begin expression - 1188
 ldd _pass
 cmpd #2
 lbne L497
* Begin expression - 1189
 ldd -949,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 std 0,s
 jsr _prsn
* Begin expression - 1189
 ldx 4,y
 stx 0,s
 jsr _prl
L497
 lbra L442
L498
L499
* Begin expression - 1196
 ldd #0
 std _passend
 lbra L442
L500
L501
L502
L503
* Begin expression - 1203
 ldd -949,y
 cmpd #-1
 lbne L504
* Begin expression - 1204
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 1205
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
 lbra L442
L504
* Begin expression - 1208
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _p1cnc
 leas 2,s
 addd [0,s]
 std [0,s]
 lbra L442
L505
L506
* Begin expression - 1214
 ldb #1
 stb -554,y
L507
L508
L509
* Begin expression - 1219
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1220
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L510
11
* Begin expression - 1221
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L510
L511
* Begin expression - 1224
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L512
* Begin expression - 1225
 ldx [-550,y]
 ldb 0,x
 cmpb #34
 lbeq L513
* Begin expression - 1226
 ldx _SYN
 stx 0,s
 jsr _panic
 lbra L442
L513
* Begin expression - 1229
 ldd #0
 std -949,y
* Begin expression - 1230
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L514
* Begin expression - 1231
 ldx [-550,y]
 ldb 0,x
 cmpb #34
 lbeq L515
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbeq L515
 ldx [-550,y]
 ldb 0,x
10
 lbeq L515
* Begin expression - 1232
 ldx [-550,y]
 ldb 0,x
 cmpb #92
 lbne L516
* Begin expression - 1233
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1234
 ldx [-550,y]
 ldb 0,x
 cmpb #94
 lbne L517
* Begin expression - 1235
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L517
L516
* Begin expression - 1237
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1238
 inc -948,y
 bne 1f
 inc -949,y
1
 lbra L514
L515
* Begin expression - 1240
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 beq 11f
 ldx [-550,y]
 ldb 0,x
10
 lbne L518
11
* Begin expression - 1241
 ldx #L519
 stx 0,s
 jsr _panic
 data
L519 fcb 77,105,115,115,105,110,103,32,34,46,0
 text
L518
* Begin expression - 1242
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1243
 ldb -554,y
 lbeq L520
* Begin expression - 1243
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L520
* Begin expression - 1244
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd -949,y
 std 0,x
* Begin expression - 1245
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1246
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L521
* Begin expression - 1246
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L521
* Begin expression - 1247
 ldx -550,y
 stx 0,s
 jsr _eatspac
 lbra L511
L512
 lbra L442
L522
L523
L524
L525
* Begin expression - 1255
 ldd -949,y
 cmpd #-1
 lbne L526
* Begin expression - 1255
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 1256
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #2
 std 0,x
 lbra L442
L526
* Begin expression - 1259
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _p1cnc
 leas 2,s
 lslb
 rola
 addd [0,s]
 std [0,s]
 lbra L442
L527
L528
* Begin expression - 1264
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1265
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L529
11
* Begin expression - 1266
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L530
L529
* Begin expression - 1269
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
* Begin expression - 1270
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1271
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L531
* Begin expression - 1272
 ldx _SOI
 stx 0,s
 jsr _panic
L531
L532
* Begin expression - 1273
 ldb -25,y
 lbeq L533
* Begin expression - 1274
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -951,y
 cmpd #-1
 lbeq L534
* Begin expression - 1275
 lslb
 rola
 ldx #_symv
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 std [0,s]
* Begin expression - 1276
 ldd -951,y
 ldx #_symp
 leax d,x
 ldd _psect
 stb 0,x
L534
L533
L530
* Begin expression - 1279
 ldd _pass
 cmpd #2
 lbne L535
* Begin expression - 1280
 jsr _prspc
* Begin expression - 1280
 ldx 4,y
 stx 0,s
 jsr _prl
L535
 lbra L442
L536
* Begin expression - 1286
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1287
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L537
11
* Begin expression - 1288
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L537
* Begin expression - 1291
 ldx -550,y
 stx 0,s
 jsr _evolexp
 lbra L442
L538
* Begin expression - 1296
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1297
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L539
11
* Begin expression - 1298
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L539
 lbra L442
L540
L541
* Begin expression - 1305
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1306
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L542
11
* Begin expression - 1307
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L543
L542
* Begin expression - 1310
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -949,y
* Begin expression - 1311
 cmpd #0
 lbge L544
* Begin expression - 1312
 ldx #L545
 stx 0,s
 jsr _panic
 data
L545 fcb 67,97,110,39,116,32,114,101,112,101,97,116,32,97,32,110
 fcb 101,103,97,116,105,118,101,32,110,117,109,98,101,114,32,111
 fcb 102,32,116,105,109,101,115,0
 text
* Begin expression - 1313
 ldd #1
 std -949,y
L544
* Begin expression - 1315
 ldd _pass
 cmpd #2
 lbne L546
 jsr _canlist
10
 cmpd #0
 lbeq L546
* Begin expression - 1315
 ldx 4,y
 stx 0,s
 jsr _prsl
L546
* Begin expression - 1316
 leax -446,y
 stx 0,s
 jsr _getline
* Begin expression - 1317
 ldd -949,y
 lbeq L547
* Begin expression - 1318
 leax -446,y
 stx 0,s
 jsr _cline
* Begin expression - 1319
 ldd -949,y
 subd #1
 std -949,y
L547
* Begin expression - 1321
 ldd #0
 std -951,y
L548
* Begin expression - 1322
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #32
 lbeq L549
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #9
 lbeq L549
 ldd -951,y
 leax -446,y
 ldb d,x
10
 lbeq L549
* Begin expression - 1323
 ldd -951,y
 inc -950,y
 bne 1f
 inc -951,y
1
 leax -446,y
 leax d,x
 ldb #32
 stb 0,x
 lbra L548
L549
L550
* Begin expression - 1324
 ldd -949,y
 tst -948,y
 bne 1f
 dec -949,y
1 dec -948,y
 cmpd #0
 lbeq L551
* Begin expression - 1324
 leax -446,y
 stx 0,s
 jsr _cline
 lbra L550
L551
 lbra L442
L543
* Begin expression - 1326
 ldd _pass
 cmpd #2
 lbne L552
 jsr _canlist
10
 cmpd #0
 lbeq L552
* Begin expression - 1326
 ldx 4,y
 stx 0,s
 jsr _prsl
L552
 lbra L442
L553
L554
* Begin expression - 1333
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1334
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L555
11
* Begin expression - 1335
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L555
* Begin expression - 1338
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -949,y
* Begin expression - 1339
 ldd _pass
 cmpd #1
 lbne L556
 ldd -949,y
10
 lbge L556
* Begin expression - 1340
 ldx #L557
 stx 0,s
 jsr _panic
 data
L557 fcb 67,97,110,39,116,32,100,117,112,108,105,99,97,116,101,32
 fcb 98,121,32,110,101,103,97,116,105,118,101,32,110,117,109,98
 fcb 101,114,32,111,102,32,116,105,109,101,115,0
 text
* Begin expression - 1341
 ldd #1
 std -949,y
L556
* Begin expression - 1343
 ldd -949,y
 lbge L558
* Begin expression - 1343
 ldd #1
 std -949,y
L558
* Begin expression - 1344
 ldd -949,y
 std -564,y
* Begin expression - 1345
 ldd #0
 std -951,y
* Begin expression - 1346
 ldd #0
 std -562,y
* Begin expression - 1347
 ldd #0
 std -949,y
L559
* Begin expression - 1348
 ldd #1
 lbeq L560
* Begin expression - 1349
 leax -546,y
 stx 0,s
 jsr _getline
* Begin expression - 1350
 leax -546,y
 stx 0,s
 ldx #L562
 pshs x
 jsr _lfs
 leas 2,s
 data
L562 fcb 101,110,100,100,117,112,0
 text
 lbeq L561
* Begin expression - 1351
 ldd -562,y
 lble L564
L563
* Begin expression - 1352
 ldd -562,y
 subd #2
 std -562,y
L561
* Begin expression - 1354
 leax -546,y
 stx 0,s
 ldx #L566
 pshs x
 jsr _lfs
 leas 2,s
 data
L566 fcb 101,110,100,97,108,108,100,117,112,0
 text
 lbeq L565
 lbra L564
L565
* Begin expression - 1355
 leax -546,y
 stx 0,s
 ldx #L568
 pshs x
 jsr _lfs
 leas 2,s
 data
L568 fcb 100,117,112,0
 text
 lbeq L567
* Begin expression - 1356
 ldd -562,y
 addd #1
 std -562,y
L567
* Begin expression - 1358
 ldd #0
 std -949,y
L569
* Begin expression - 1359
 ldd -951,y
 leax -446,y
 leax d,x
 ldd -949,y
 inc -948,y
 bne 1f
 inc -949,y
1
 stx 0,s
 leax -546,y
 ldb d,x
 stb [0,s]
 lbeq L570
 ldd -951,y
 cmpd #400
10
 lbge L570
* Begin expression - 1360
 inc -950,y
 bne 1f
 inc -951,y
1
 lbra L569
L570
* Begin expression - 1362
 ldd -951,y
 inc -950,y
 bne 1f
 inc -951,y
1
 leax -446,y
 leax d,x
 ldb #13
 stb 0,x
* Begin expression - 1363
 ldd -951,y
 cmpd #400
 lblt L571
* Begin expression - 1364
 ldx #L572
 stx 0,s
 jsr _panic
 data
L572 fcb 84,111,111,32,109,97,110,121,32,99,104,97,114,97,99,116
 fcb 111,114,115,32,105,110,32,39,100,117,112,39,32,97,114,103
 fcb 117,109,101,110,116,0
 text
* Begin expression - 1365
 ldb #13
 stb -47,y
* Begin expression - 1366
 clr -46,y
* Begin expression - 1367
 tst -950,y
 bne 1f
 dec -951,y
1 dec -950,y
L571
 lbra L559
L560
L564
* Begin expression - 1371
 ldd -951,y
 leax -446,y
 clr d,x
* Begin expression - 1372
 ldd -564,y
 lbeq L573
* Begin expression - 1372
 ldd #0
 std 0,s
 leax -584,y
 pshs x
 leax -446,y
 pshs x
 jsr _mexp
 leas 4,s
L573
* Begin expression - 1373
 ldd #0
 std -951,y
* Begin expression - 1374
 ldd -564,y
 subd #1
 std -564,y
L574
* Begin expression - 1375
 ldd -951,y
 leax -446,y
 ldb d,x
 lbeq L575
* Begin expression - 1376
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #32
 lbeq L576
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #9
10
 lbeq L576
L577
* Begin expression - 1377
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #32
 lbeq L578
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #9
10
 lbeq L578
* Begin expression - 1378
 ldd -951,y
 inc -950,y
 bne 1f
 inc -951,y
1
 leax -446,y
 leax d,x
 ldb #32
 stb 0,x
 lbra L577
L578
L576
L579
* Begin expression - 1380
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #13
 lbeq L580
 ldd -951,y
 leax -446,y
 ldb d,x
10
 lbeq L580
* Begin expression - 1380
 inc -950,y
 lbne L579
 inc -951,y
 lbra L579
L580
* Begin expression - 1381
 ldd -951,y
 leax -446,y
 ldb d,x
 cmpb #13
 lbne L581
* Begin expression - 1381
 inc -950,y
 bne 1f
 inc -951,y
1
L581
 lbra L574
L575
L582
* Begin expression - 1383
 ldd -564,y
 tst -563,y
 bne 1f
 dec -564,y
1 dec -563,y
 cmpd #0
 lbeq L583
* Begin expression - 1383
 ldd #0
 std 0,s
 leax -584,y
 pshs x
 leax -446,y
 pshs x
 jsr _mexp
 leas 4,s
 lbra L582
L583
 lbra L442
L584
* Begin expression - 1388
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1389
 ldx -550,y
 stx 0,s
 jsr _commaer
* Begin expression - 1390
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L585
* Begin expression - 1391
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L585
L586
* Begin expression - 1394
 leax -25,y
 stx 0,s
 ldx -550,y
 pshs x
 jsr _getarg
 leas 2,s
 cmpd #0
 lbeq L587
* Begin expression - 1395
 ldx #_edtab
 stx 0,s
 leax -25,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L588
* Begin expression - 1396
 ldx #L589
 stx 0,s
 jsr _panic
 data
L589 fcb 87,97,114,110,105,110,103,32,45,100,111,117,98,108,101,32
 fcb 100,101,102,105,110,101,100,32,101,120,116,101,114,110,97,108
 fcb 0
 text
* Begin expression - 1397
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
 lbra L590
L588
* Begin expression - 1399
 ldx #_edtab
 stx 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L590
 lbra L586
L587
 lbra L442
L591
L592
* Begin expression - 1406
 ldd #0
 std -556,y
* Begin expression - 1407
 ldd #1
 std _b1
* Begin expression - 1408
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1409
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L593
11
* Begin expression - 1409
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L593
* Begin expression - 1410
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
* Begin expression - 1411
 ldx #_mdef
 stx 0,s
 leax -25,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L594
* Begin expression - 1412
 ldd _pass
 cmpd #1
 lbne L595
* Begin expression - 1413
 ldx #L596
 stx 0,s
 jsr _panic
 data
L596 fcb 68,111,117,98,108,101,32,100,101,102,105,110,101,100,32,109
 fcb 97,99,114,111,0
 text
* Begin expression - 1414
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
* Begin expression - 1415
 ldd #0
 std _b1
L595
 lbra L597
L594
* Begin expression - 1418
 ldd #1
 std -556,y
L597
* Begin expression - 1419
 ldd _pass
 cmpd #1
 beq 10f
 ldd -556,y
 lbeq L598
10
 ldd _b1
11
 lbeq L598
* Begin expression - 1419
 ldx #_mdef
 stx 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L598
* Begin expression - 1420
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1421
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L599
* Begin expression - 1422
 ldx #L600
 stx 0,s
 jsr _panic
 data
L600 fcb 79,110,108,121,32,111,110,101,32,111,112,101,114,104,97,110
 fcb 100,32,105,110,32,97,32,100,101,102,109,97,99,114,111,32
 fcb 115,116,97,116,101,109,110,116,32,45,102,105,114,115,116,32
 fcb 111,110,101,32,117,115,101,100,0
 text
L599
* Begin expression - 1423
 ldd #0
 std -951,y
* Begin expression - 1424
 ldb #13
 stb -446,y
* Begin expression - 1425
 ldd #0
 std -562,y
* Begin expression - 1426
 ldd #0
 std -949,y
L601
* Begin expression - 1427
 ldd #1
 lbeq L602
* Begin expression - 1428
 leax -546,y
 stx 0,s
 jsr _getline
* Begin expression - 1429
 leax -546,y
 stx 0,s
 ldx #L604
 pshs x
 jsr _lfs
 leas 2,s
 data
L604 fcb 101,110,100,109,97,99,114,111,0
 text
 lbeq L603
* Begin expression - 1430
 ldd -562,y
 lble L606
L605
* Begin expression - 1431
 ldd -562,y
 subd #1
 std -562,y
L603
* Begin expression - 1433
 leax -546,y
 stx 0,s
 ldx #L608
 pshs x
 jsr _lfs
 leas 2,s
 data
L608 fcb 101,110,100,97,108,108,109,97,99,114,111,0
 text
 lbeq L607
 lbra L606
L607
* Begin expression - 1434
 leax -546,y
 stx 0,s
 ldx #L610
 pshs x
 jsr _lfs
 leas 2,s
 data
L610 fcb 100,101,102,109,97,99,114,111,0
 text
 lbeq L609
* Begin expression - 1435
 ldd 4,y
 std -548,y
* Begin expression - 1436
 leax -548,y
 stx -550,y
* Begin expression - 1437
 ldb -546,y
 cmpb #32
 lbeq L611
 cmpb #9
10
 lbne L602
L611
* Begin expression - 1438
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
* Begin expression - 1439
 ldx #L613
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L613 fcb 100,101,102,109,97,99,114,111,0
 text
 lbeq L612
* Begin expression - 1439
 ldd -562,y
 addd #1
 std -562,y
L612
L609
* Begin expression - 1441
 ldd #0
 std -949,y
L614
* Begin expression - 1442
 ldd -951,y
 leax -446,y
 leax d,x
 ldd -949,y
 inc -948,y
 bne 1f
 inc -949,y
1
 stx 0,s
 leax -546,y
 ldb d,x
 stb [0,s]
 lbeq L615
 ldd -951,y
 cmpd #400
10
 lbge L615
* Begin expression - 1443
 inc -950,y
 bne 1f
 inc -951,y
1
 lbra L614
L615
* Begin expression - 1445
 ldd -951,y
 inc -950,y
 bne 1f
 inc -951,y
1
 leax -446,y
 leax d,x
 ldb #13
 stb 0,x
* Begin expression - 1446
 ldd -951,y
 cmpd #400
 lblt L616
* Begin expression - 1447
 ldx #L617
 stx 0,s
 jsr _panic
 data
L617 fcb 84,111,111,32,109,97,110,121,32,99,104,97,114,97,99,116
 fcb 111,114,115,32,105,110,32,39,100,101,102,109,97,99,114,111
 fcb 39,32,97,114,103,117,109,101,110,116,0
 text
* Begin expression - 1448
 ldb #13
 stb -47,y
* Begin expression - 1449
 clr -46,y
* Begin expression - 1450
 tst -950,y
 bne 1f
 dec -951,y
1 dec -950,y
 lbra L606
L616
 lbra L601
L602
L606
* Begin expression - 1454
 ldd -951,y
 leax -446,y
 clr d,x
* Begin expression - 1455
 ldd _pass
 cmpd #1
 beq 10f
 ldd -556,y
 lbeq L618
10
 ldd _b1
11
 lbeq L618
* Begin expression - 1455
 ldx #_mbody
 stx 0,s
 leax -446,y
 pshs x
 jsr _cement
 leas 2,s
L618
 lbra L442
L619
L620
* Begin expression - 1460
 ldx #L621
 stx 0,s
 jsr _panic
 data
L621 fcb 69,120,116,114,97,32,39,101,110,100,109,97,99,114,111,39
 fcb 0
 text
 lbra L442
L622
L623
* Begin expression - 1465
 ldx #L624
 stx 0,s
 jsr _panic
 data
L624 fcb 69,120,116,114,97,32,39,101,110,100,100,117,112,39,0
 text
 lbra L442
L625
L626
L627
* Begin expression - 1471
 ldd -949,y
 cmpd #-1
 lbne L628
* Begin expression - 1472
 ldx _MI
 stx 0,s
 jsr _panic
* Begin expression - 1473
 ldd _pass
 cmpd #2
 lbne L629
 jsr _canlist
10
 cmpd #0
 lbeq L629
* Begin expression - 1473
 ldx 4,y
 stx 0,s
 jsr _prsl
L629
 lbra L442
L628
L630
* Begin expression - 1476
 ldb _p2evnf
 lbeq L631
* Begin expression - 1477
 ldx -550,y
 stx 0,s
 jsr _p2evn
* Begin expression - 1478
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd _p2evnn
 std 0,x
 lbra L630
L631
* Begin expression - 1480
 ldd _pass
 cmpd #2
 lbne L632
 jsr _canlist
10
 cmpd #0
 lbeq L632
* Begin expression - 1481
 jsr _prspc
* Begin expression - 1482
 ldx 4,y
 stx 0,s
 jsr _prl
L632
 lbra L442
L633
L634
* Begin expression - 1488
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -951,y
* Begin expression - 1489
 inc _ifcount+1
 bne 1f
 inc _ifcount
1
* Begin expression - 1490
 ldd -951,y
 lbne L442
L635
* Begin expression - 1491
 ldd #1
 std -951,y
* Begin expression - 1492
 ldd #0
 std -562,y
L636
* Begin expression - 1493
 ldd -951,y
 lbeq L637
* Begin expression - 1494
 leax -546,y
 stx 0,s
 jsr _getline
* Begin expression - 1495
 ldd -546,y
 std -548,y
* Begin expression - 1496
 leax -548,y
 stx -550,y
* Begin expression - 1497
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #1
 lbne L638
* Begin expression - 1497
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
L638
* Begin expression - 1498
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L639
* Begin expression - 1499
 ldd _passend
 lbne L640
* Begin expression - 1500
 ldx #L641
 stx 0,s
 jsr _panic
 data
L641 fcb 66,114,111,107,101,110,32,39,105,102,39,32,115,116,97,116
 fcb 109,101,110,116,0
 text
 lbra L442
L640
 lbra L642
L639
* Begin expression - 1505
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
* Begin expression - 1506
 ldx #L644
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L644 fcb 101,110,100,105,102,0
 text
 lbeq L643
* Begin expression - 1507
 ldd -562,y
 lbne L645
* Begin expression - 1507
 ldd #0
 std -951,y
* Begin expression - 1508
 tst _ifcount+1
 bne 1f
 dec _ifcount
1 dec _ifcount+1
 lbra L646
L645
* Begin expression - 1510
 tst -561,y
 bne 1f
 dec -562,y
1 dec -561,y
L646
 lbra L647
L643
* Begin expression - 1512
 ldx #L649
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L649 fcb 101,108,115,101,0
 text
 lbeq L648
* Begin expression - 1513
 ldd -562,y
 lbne L650
* Begin expression - 1513
 ldd #0
 std -951,y
L650
 lbra L651
L648
* Begin expression - 1515
 ldx #L653
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L653 fcb 105,102,0
 text
 lbeq L652
* Begin expression - 1515
 inc -561,y
 bne 1f
 inc -562,y
1
L652
L651
L647
L642
 lbra L636
L637
 lbra L442
L654
L655
* Begin expression - 1522
 ldd _ifcount
 lbne L656
* Begin expression - 1523
 ldx #L657
 stx 0,s
 jsr _panic
 data
L657 fcb 69,120,116,114,97,32,39,101,108,115,101,39,32,115,116,97
 fcb 116,109,101,110,116,0
 text
 lbra L442
L656
* Begin expression - 1526
 ldd #1
 std -951,y
* Begin expression - 1527
 ldd #0
 std -562,y
L658
* Begin expression - 1528
 ldd -951,y
 lbeq L659
* Begin expression - 1529
 leax -546,y
 stx 0,s
 jsr _getline
* Begin expression - 1530
 ldd -546,y
 std -548,y
* Begin expression - 1531
 leax -548,y
 stx -550,y
* Begin expression - 1532
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #1
 lbne L660
* Begin expression - 1532
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
L660
* Begin expression - 1533
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L661
* Begin expression - 1534
 ldd _passend
 lbne L662
* Begin expression - 1535
 ldx #L663
 stx 0,s
 jsr _panic
 data
L663 fcb 66,114,111,107,101,110,32,105,102,32,115,116,97,116,109,101
 fcb 110,116,0
 text
 lbra L442
L662
 lbra L664
L661
* Begin expression - 1540
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
* Begin expression - 1541
 ldx #L666
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L666 fcb 101,110,100,105,102,0
 text
 lbeq L665
* Begin expression - 1542
 ldd -562,y
 lbne L667
* Begin expression - 1542
 ldd #0
 std -951,y
* Begin expression - 1543
 tst _ifcount+1
 bne 1f
 dec _ifcount
1 dec _ifcount+1
 lbra L668
L667
* Begin expression - 1545
 tst -561,y
 bne 1f
 dec -562,y
1 dec -561,y
L668
 lbra L669
L665
* Begin expression - 1547
 ldx #L671
 stx 0,s
 leax -25,y
 pshs x
 jsr _comstr
 leas 2,s
 data
L671 fcb 105,102,0
 text
 lbeq L670
* Begin expression - 1547
 inc -561,y
 bne 1f
 inc -562,y
1
L670
L669
L664
 lbra L658
L659
 lbra L442
L672
L673
* Begin expression - 1554
 ldd _ifcount
 lbne L674
* Begin expression - 1555
 ldx #L675
 stx 0,s
 jsr _panic
 data
L675 fcb 101,120,116,114,97,32,39,101,110,100,105,102,39,0
 text
 lbra L442
L674
* Begin expression - 1558
 tst _ifcount+1
 bne 1f
 dec _ifcount
1 dec _ifcount+1
 lbra L442
L676
L677
* Begin expression - 1562
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1563
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L678
* Begin expression - 1564
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L678
* Begin expression - 1567
 ldd #10
 std _curbase
* Begin expression - 1568
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _curbase
 lbra L442
L679
* Begin expression - 1572
 clr _listfla
 lbra L442
L680
* Begin expression - 1576
 ldb #1
 stb _listfla
 lbra L442
L681
L682
* Begin expression - 1581
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1582
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L683
* Begin expression - 1582
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L683
* Begin expression - 1583
 ldd _ifdc
 cmpd #10
 lbne L684
* Begin expression - 1583
 ldx #L685
 stx 0,s
 jsr _panic
 data
L685 fcb 84,111,111,32,109,97,110,121,32,110,101,115,116,101,100,32
 fcb 105,110,99,108,117,100,101,115,0
 text
 lbra L442
L684
* Begin expression - 1584
 ldd #0
 std -949,y
L686
* Begin expression - 1585
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L687
* Begin expression - 1585
 ldd -949,y
 inc -948,y
 bne 1f
 inc -949,y
1
 leax -546,y
 leax d,x
 stx 0,s
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 stb [0,s]
 lbra L686
L687
* Begin expression - 1586
 ldd -949,y
 leax -546,y
 clr d,x
* Begin expression - 1587
 ldd _ifdc
 addd #1
 std _ifdc
 lslb
 rola
 ldx #_ifd
 leax d,x
 stx 0,s
 ldd #0
 pshs d
 leax -546,y
 pshs x
 jsr _open
 leas 4,s
 std [0,s]
* Begin expression - 1588
 ldd _ifdc
 lslb
 rola
 ldx #_ifd
 ldd d,x
 cmpd #-1
 lbne L688
* Begin expression - 1589
 ldx #L689
 stx 0,s
 jsr _panic
 data
L689 fcb 67,97,110,39,116,32,114,101,97,100,32,105,110,99,108,117
 fcb 100,101,32,102,105,108,101,0
 text
* Begin expression - 1590
 ldd _ifdc
 subd #1
 std _ifdc
L688
 lbra L442
L690
 lbra L442
L691
 lbra L442
L692
L693
L694
* Begin expression - 1603
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1604
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L695
* Begin expression - 1604
 ldx _MI
 stx 0,s
 jsr _panic
L695
 lbra L442
L696
* Begin expression - 1608
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1609
 ldx -550,y
 stx 0,s
 jsr _commaer
* Begin expression - 1610
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L697
* Begin expression - 1611
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L697
L698
* Begin expression - 1614
 leax -25,y
 stx 0,s
 ldx -550,y
 pshs x
 jsr _getarg
 leas 2,s
 cmpd #0
 lbeq L699
* Begin expression - 1615
 ldx #_loadtab
 stx 0,s
 leax -25,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L700
* Begin expression - 1616
 ldx #L701
 stx 0,s
 jsr _panic
 data
L701 fcb 87,97,114,110,105,110,103,45,32,100,111,117,98,108,101,32
 fcb 100,101,102,105,110,101,100,32,108,111,97,100,109,111,100,0
 text
* Begin expression - 1617
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
 lbra L702
L700
* Begin expression - 1619
 ldx #_loadtab
 stx 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L702
 lbra L698
L699
 lbra L442
L703
L704
* Begin expression - 1624
 ldx #L705
 stx 0,s
 jsr _printf
 data
L705 fcb 37,37,37,37,32,85,115,101,114,32,109,101,115,115,97,103
 fcb 101,58,9,0
 text
L706
L707
* Begin expression - 1625
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L708
 ldx [-550,y]
 ldb 0,x
 cmpb #37
10
 lbeq L708
* Begin expression - 1625
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L707
10
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L707
L708
* Begin expression - 1626
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L709
* Begin expression - 1627
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
* Begin expression - 1628
 inc _numerrs+1
 lbne L442
 inc _numerrs
 lbra L442
L709
* Begin expression - 1631
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
* Begin expression - 1632
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -949,y
 cmpd #-1
 lbeq L710
* Begin expression - 1633
 ldd #16
 std 0,s
 ldd -949,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 pshs d
 jsr _basout
 leas 2,s
 lbra L711
L710
* Begin expression - 1635
 ldx _UND
 stx 0,s
 jsr _printf
L711
 lbra L706
L712
* Begin expression - 1639
 ldb #1
 stb _bytef
 lbra L442
L713
* Begin expression - 1643
 clr _bytef
 lbra L442
L714
L715
* Begin expression - 1648
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
* Begin expression - 1648
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 andb #$FE
 std 0,x
 lbra L532
L716
L717
* Begin expression - 1653
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 andb #$FE
 std 0,x
* Begin expression - 1653
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 lbne L532
 inc 0,x
 lbra L532
L718
L719
* Begin expression - 1658
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #4095
 std 0,x
* Begin expression - 1658
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 clrb
 anda #$F0
 std 0,x
 lbra L532
L720
L721
L722
* Begin expression - 1664
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1665
 ldd -949,y
 cmpd #-1
 beq 11f
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
10
 cmpd #0
 lbeq L723
11
* Begin expression - 1666
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L532
L723
* Begin expression - 1669
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _psect
* Begin expression - 1670
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1671
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L724
* Begin expression - 1671
 ldx _SOI
 stx 0,s
 jsr _panic
L724
 lbra L532
L725
* Begin expression - 1675
 ldd #0
 std _psect
 lbra L532
L726
* Begin expression - 1679
 ldd #1
 std _psect
 lbra L532
L727
* Begin expression - 1683
 ldd #2
 std _psect
 lbra L532
L728
* Begin expression - 1687
 ldd #3
 std _psect
 lbra L532
L729
* Begin expression - 1691
 ldd #4
 std _psect
 lbra L532
 lbra L487
L488
 ldx #L10029
 std L10028
L10027 cmpd 0,x++
 bne L10027
 jmp [L10028-L10029,x]
 data
L10029  fdb 1,41,2,15,31,3,34,35,17,33,4,16,32,5,6,7
 fdb 8,9,10,11,12,13,14,36,18,19,20,21,22,23,24,25
 fdb 26,27,39,40,28,29,30,37,38,42,43,44,45,46,47,48
 fdb 49,50,51
L10028 fdb 0
 fdb L489,L498,L499,L500,L501,L502,L505,L506,L507,L508,L509,L522,L523,L524,L527,L536
 fdb L538,L540,L553,L584,L591,L619,L622,L625,L626,L633,L654,L672,L676,L679,L680,L681
 fdb L690,L691,L692,L693,L694,L696,L703,L712,L713,L714,L716,L718,L720,L721,L725,L726
 fdb L727,L728,L729,L10026
 text
L10026
 text
L487
 lbra L730
L486
* Begin expression - 1698
 ldx #_spmot
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L731
* Begin expression - 1699
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 stx 0,s
 ldx #_spmots
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
 lbra L442
 lbra L732
L731
* Begin expression - 1703
 ldx #_mot
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L733
* Begin expression - 1704
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1705
 ldx [-550,y]
 stx -552,y
* Begin expression - 1706
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 4,x
 cmpb #1
 lbeq L734
* Begin expression - 1707
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
* Begin expression - 1708
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 4,x
 sex
 std -951,y
* Begin expression - 1709
 cmpd #52
 lblt L735
 cmpd #55
10
 lbgt L735
* Begin expression - 1709
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L735
* Begin expression - 1710
 ldd -951,y
 cmpd #30
 beq 11f
 cmpd #31
10
 lbne L736
11
* Begin expression - 1710
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L736
* Begin expression - 1711
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L737
* Begin expression - 1711
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
L737
* Begin expression - 1712
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L738
* Begin expression - 1712
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
L738
 lbra L442
L734
* Begin expression - 1715
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L739
* Begin expression - 1715
 ldx _MI
 stx 0,s
 jsr _panic
L739
* Begin expression - 1716
 ldx [-550,y]
 ldb 0,x
 cmpb #35
 lbne L740
* Begin expression - 1717
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L741
11
* Begin expression - 1718
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #4
 std 0,x
 lbra L742
L741
* Begin expression - 1720
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 stx 0,s
 ldx #_mvt
 ldb d,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
L742
* Begin expression - 1721
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 ldb d,x
 cmpb #1
 lbne L743
* Begin expression - 1721
 ldx #L744
 stx 0,s
 jsr _panic
 data
L744 fcb 73,110,118,97,108,105,100,32,109,111,100,101,0
 text
L743
 lbra L442
L740
* Begin expression - 1724
 ldx -550,y
 stx 0,s
 jsr _opsize
 stb -553,y
L745
* Begin expression - 1725
 ldx [-550,y]
 ldb 0,x
 cmpb #59
 lbeq L746
 ldx [-550,y]
 ldb 0,x
 cmpb #44
10
 lbeq L746
* Begin expression - 1725
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L745
L746
* Begin expression - 1726
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L747
* Begin expression - 1727
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1728
 ldx [-550,y]
 stx 0,s
 jsr _swapit
* Begin expression - 1729
 ldx [-550,y]
 ldb 0,x
 cmpb #120
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #121
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #115
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #117
10
 lbne L748
11
* Begin expression - 1730
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L749
11
* Begin expression - 1731
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #3
 std 0,x
 lbra L750
L749
* Begin expression - 1733
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 stx 0,s
 ldx #_mvt
 leax d,x
 ldb 2,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
L750
* Begin expression - 1734
 ldb [-552,y]
 cmpb #44
 lbeq L751
* Begin expression - 1735
 ldx -552,y
 leax 1,x
 stx -552,y
* Begin expression - 1736
 ldb [-552,y]
 cmpb #97
 lbeq L752
 ldb [-552,y]
 cmpb #98
 lbeq L752
 ldb [-552,y]
 cmpb #100
10
 lbeq L752
* Begin expression - 1736
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldb -553,y
 sex
 addd 0,x
 std 0,x
 lbra L753
L752
* Begin expression - 1738
 ldx -552,y
 leax 1,x
 stx -552,y
* Begin expression - 1739
 ldb [-552,y]
 cmpb #44
 lbeq L754
* Begin expression - 1739
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldb -553,y
 sex
 addd 0,x
 std 0,x
L754
L753
L751
* Begin expression - 1742
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 cmpb #1
 lbne L755
* Begin expression - 1742
 ldx #L756
 stx 0,s
 jsr _panic
 data
L756 fcb 73,110,118,97,108,105,100,32,109,111,100,101,0
 text
L755
 lbra L442
L748
* Begin expression - 1745
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L757
* Begin expression - 1747
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L758
11
* Begin expression - 1748
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #3
 std 0,x
 lbra L759
L758
* Begin expression - 1750
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 stx 0,s
 ldx #_mvt
 leax d,x
 ldb 1,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
L759
* Begin expression - 1751
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 1,x
 cmpb #1
 lbne L760
* Begin expression - 1751
 ldx #L761
 stx 0,s
 jsr _panic
 data
L761 fcb 73,110,118,97,108,105,100,32,109,111,100,101,0
 text
L760
 lbra L442
L757
* Begin expression - 1754
 ldx [-550,y]
 ldb 0,x
 cmpb #112
 lbne L762
* Begin expression - 1755
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L763
11
* Begin expression - 1756
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #5
 std 0,x
 lbra L764
L763
* Begin expression - 1758
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #4
 std 0,x
L764
* Begin expression - 1759
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 cmpb #1
 lbne L765
* Begin expression - 1759
 ldx #L766
 stx 0,s
 jsr _panic
 data
L766 fcb 73,110,118,97,108,105,100,32,109,111,100,101,0
 text
L765
 lbra L442
L762
* Begin expression - 1762
 ldx #L767
 stx 0,s
 jsr _panic
 data
L767 fcb 79,100,100,32,97,100,100,114,101,115,115,105,110,103,32,109
 fcb 111,100,101,0
 text
L747
* Begin expression - 1764
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 3,x
 cmpb #1
 lbeq L768
* Begin expression - 1765
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L769
11
* Begin expression - 1766
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #4
 std 0,x
 lbra L770
L769
* Begin expression - 1768
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 stx 0,s
 ldx #_mvt
 leax d,x
 ldb 3,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
L770
* Begin expression - 1769
 ldb [-552,y]
 cmpb #91
 lbne L771
* Begin expression - 1769
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
L771
 lbra L442
L768
* Begin expression - 1772
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 5,x
 cmpb #1
 lbeq L772
* Begin expression - 1773
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldx #_mot11
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
10
 lbeq L773
11
* Begin expression - 1774
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #4
 std 0,x
 lbra L774
L773
* Begin expression - 1776
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 stx 0,s
 ldx #_mvt
 leax d,x
 ldb 5,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 sex
 addd [0,s]
 std [0,s]
L774
 lbra L442
L772
* Begin expression - 1779
 ldx #L775
 stx 0,s
 jsr _panic
 data
L775 fcb 86,97,108,105,100,32,105,110,115,116,114,117,99,116,105,111
 fcb 110,32,119,105,116,104,32,105,110,118,97,108,105,100,32,109
 fcb 111,100,101,0
 text
L733
L732
L730
L485
* Begin expression - 1781
 ldx #L776
 stx 0,s
 jsr _panic
 data
L776 fcb 85,110,100,101,102,105,110,101,100,32,105,110,115,116,114,117
 fcb 99,116,105,111,110,58,0
 text
* Begin expression - 1782
 leax -46,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
 lbra L442
L435
* Begin expression - 1792
 ldd #0
 std _symtabr
* Begin expression - 1792
 ldd #0
 std _exttabr
* Begin expression - 1792
 ldd #0
 std _relocat
* Begin expression - 1793
 ldb #0
 stb _indir
 sex
 std _prebyte
 std _fb5
 std _fb4
 std _fb3
 std _fb2
* Begin expression - 1794
 ldd #18
 std _b1
* Begin expression - 1795
 ldd _symll
 cmpd #800
 lble L777
* Begin expression - 1796
 ldx #L778
 stx 0,s
 jsr _panic
 data
L778 fcb 79,117,116,32,111,102,32,101,120,116,101,114,110,97,108,32
 fcb 115,121,109,98,111,108,32,114,101,102,101,114,97,110,99,101
 fcb 32,116,97,98,108,101,32,115,112,97,99,101,0
 text
* Begin expression - 1797
 ldx #L779
 stx 0,s
 jsr _panic
 data
L779 fcb 73,110,116,101,114,110,97,108,108,121,44,32,99,104,97,110
 fcb 103,101,32,39,78,85,77,83,89,77,39,32,116,111,32,105
 fcb 110,99,114,101,97,115,101,32,116,97,98,108,101,0
 text
* Begin expression - 1798
 ldd _extrtp
 subd #1
 std _extrtp
L777
* Begin expression - 1801
 ldx [-550,y]
 ldb 0,x
 cmpb #59
 lbne L780
 ldx [-550,y]
 ldb 1,x
10
 lbne L780
* Begin expression - 1801
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L442
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L442
L780
* Begin expression - 1802
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #1
 lbne L781
* Begin expression - 1803
 ldx -550,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _sscan
 leas 2,s
 std -949,y
 cmpd #58
 lbne L782
L783
* Begin expression - 1804
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1805
 ldd #1
 std -558,y
* Begin expression - 1806
 ldx [-550,y]
 ldb 0,x
 cmpb #58
 lbne L784
* Begin expression - 1807
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1808
 ldd #0
 std -560,y
L784
L782
* Begin expression - 1811
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1812
 ldd -949,y
 cmpd #-1
 lbne L785
* Begin expression - 1813
 ldx #L786
 stx 0,s
 jsr _panic
 data
L786 fcb 77,105,115,115,105,110,103,32,111,112,99,111,100,101,0
 text
* Begin expression - 1814
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L785
* Begin expression - 1817
 leax -25,y
 stx 0,s
 jsr _fsyml1
 std -949,y
 cmpd #-1
 lbeq L787
* Begin expression - 1818
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L788
* Begin expression - 1819
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1820
 ldd -949,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
* Begin expression - 1821
 ldd -949,y
 ldx #_symp
 leax d,x
 ldd _spsect
 stb 0,x
* Begin expression - 1822
 ldb -25,y
 stb -46,y
* Begin expression - 1823
 ldb -24,y
 stb -45,y
* Begin expression - 1824
 ldd -949,y
 std -951,y
 lbra L789
L788
L787
* Begin expression - 1828
 ldd -949,y
 cmpd #-1
 lbne L790
* Begin expression - 1829
 ldb -25,y
 cmpb #36
 beq 11f
 cmpb #37
10
 lbne L791
11
* Begin expression - 1830
 ldx _BL
 stx 0,s
 jsr _panic
 lbra L792
L791
* Begin expression - 1833
 leax -25,y
 stx 0,s
 jsr _fsyms
 std -949,y
* Begin expression - 1834
 lslb
 rola
 ldx #_symv
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 std [0,s]
* Begin expression - 1835
 ldd #1
 std -556,y
* Begin expression - 1836
 ldd _macnest
 lbeq L793
 ldd -560,y
 bne 12f
 ldd _macnest
 ldx #_rlpass
 ldb d,x
 cmpb #1
10
 lbne L793
12
* Begin expression - 1837
 ldd _macnest
 lslb
 rola
 ldx #_macstac
 ldd d,x
 std 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L793
* Begin expression - 1838
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L794
* Begin expression - 1839
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1840
 ldd -949,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
* Begin expression - 1841
 ldb -25,y
 stb -46,y
* Begin expression - 1842
 ldb -24,y
 stb -45,y
* Begin expression - 1843
 ldd -949,y
 std -951,y
 lbra L789
L794
L792
L790
 lbra L795
L781
* Begin expression - 1850
 ldx [-550,y]
 ldb 0,x
 cmpb #59
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #42
10
 lbne L796
11
* Begin expression - 1850
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L796
* Begin expression - 1851
 ldx [-550,y]
 ldb 0,x
 cmpb #32
 lbeq L797
 ldx [-550,y]
 ldb 0,x
 cmpb #9
10
 lbeq L797
* Begin expression - 1852
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbne L798
* Begin expression - 1852
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L442
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L442
L798
* Begin expression - 1853
 ldx #L799
 stx 0,s
 jsr _panic
 data
L799 fcb 73,110,118,97,108,105,100,32,108,97,98,108,101,0
 text
L800
* Begin expression - 1854
 ldx [-550,y]
 ldb 0,x
 cmpb #32
 lbeq L801
 ldx [-550,y]
 ldb 0,x
 cmpb #9
 lbeq L801
 ldx [-550,y]
 ldb 0,x
 cmpb #13
10
 lbeq L801
* Begin expression - 1855
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L800
L801
* Begin expression - 1856
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbne L802
* Begin expression - 1856
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L802
L797
L795
* Begin expression - 1859
 ldx -550,y
 stx 0,s
 leax -46,y
 pshs x
 jsr _sscan
 leas 2,s
 std -949,y
* Begin expression - 1860
 cmpd #58
 lbne L803
* Begin expression - 1861
 leax -46,y
 stx 0,s
 leax -25,y
 pshs x
 jsr _copystr
 leas 2,s
 lbra L783
L803
* Begin expression - 1864
 ldb -46,y
 lbne L804
* Begin expression - 1865
 ldd -556,y
 lbeq L805
 ldd -558,y
10
 lbne L805
* Begin expression - 1866
 ldx #L806
 stx 0,s
 jsr _panic
 data
L806 fcb 87,97,114,110,105,110,103,32,45,108,97,98,108,101,32,119
 fcb 105,116,104,32,110,111,32,111,112,99,111,100,101,0
 text
* Begin expression - 1867
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
L805
* Begin expression - 1869
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L804
* Begin expression - 1873
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1874
 ldx [-550,y]
 ldb 0,x
 cmpb #61
 lbne L807
* Begin expression - 1875
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1876
 leax -46,y
 stx 0,s
 jsr _fsyml1
 std -951,y
 cmpd #-1
 lbne L808
* Begin expression - 1877
 ldx _UND
 stx 0,s
 jsr _panic
* Begin expression - 1878
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L808
* Begin expression - 1881
 ldd -951,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldx -550,y
 pshs x
 jsr _evolexp
 leas 2,s
 std [0,s]
L789
* Begin expression - 1883
 ldb -46,y
 cmpb #46
 lbne L809
 ldb -45,y
10
 lbne L809
* Begin expression - 1884
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 lslb
 rola
 stx 0,s
 ldx #_symv
 ldd d,x
 std [0,s]
* Begin expression - 1885
 jsr _prspc
 lbra L810
L809
* Begin expression - 1887
 ldd -951,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 std 0,s
 jsr _prsn
L810
* Begin expression - 1888
 ldx 4,y
 stx 0,s
 jsr _prl
 lbra L442
L807
* Begin expression - 1892
 ldx #_mdef
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L811
* Begin expression - 1893
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L466
L811
* Begin expression - 1897
 ldx #_soptab
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L812
* Begin expression - 1899
 lbra L814
L815
 lbra L490
L816
L817
* Begin expression - 1906
 ldd #0
 std _passend
* Begin expression - 1907
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 1908
 jsr _dumpst
 lbra L433
L818
L819
L820
* Begin expression - 1914
 ldx 4,y
 stx 0,s
 jsr _prsl
L821
* Begin expression - 1915
 ldb _p2evnf
 lbeq L822
* Begin expression - 1916
 ldx -550,y
 stx 0,s
 jsr _p2evn
* Begin expression - 1917
 ldb _p2evnf
 lbeq L822
L823
* Begin expression - 1918
 ldd _p2evnn
 std _b1
* Begin expression - 1919
 jsr _prsnb
* Begin expression - 1920
 jsr _pbytes
* Begin expression - 1921
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
 lbra L821
L822
* Begin expression - 1923
 ldb _bytep
 lbeq L824
 jsr _canlist
 cmpd #0
 lbeq L824
 ldb _bytef
10
 lbeq L824
* Begin expression - 1923
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L442
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
L824
 lbra L442
L825
L826
* Begin expression - 1928
 ldb #1
 stb -554,y
L827
L828
L829
* Begin expression - 1934
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 1935
 ldx -550,y
 stx 0,s
 jsr _eatspac
L830
* Begin expression - 1936
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L831
* Begin expression - 1937
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L832
* Begin expression - 1938
 ldx [-550,y]
 ldb 0,x
 cmpb #34
 lbeq L833
 ldx [-550,y]
 ldb 0,x
 cmpb #13
 lbeq L833
 ldx [-550,y]
 ldb 0,x
10
 lbeq L833
* Begin expression - 1939
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 sex
 std _b1
* Begin expression - 1940
 ldd _b1
 cmpd #92
 lbne L834
* Begin expression - 1941
 ldx [-550,y]
 ldb 0,x
 sex
 lbra L836
L837
* Begin expression - 1942
 ldd #7
 std _b1
 lbra L835
L838
L839
* Begin expression - 1945
 ldd #13
 std _b1
 lbra L835
L840
L841
* Begin expression - 1948
 ldd #9
 std _b1
 lbra L835
L842
L843
* Begin expression - 1951
 ldd #13
 std _b1
 lbra L835
L844
L845
* Begin expression - 1954
 ldd #8
 std _b1
 lbra L835
L846
L847
* Begin expression - 1957
 ldd #27
 std _b1
 lbra L835
L848
L849
* Begin expression - 1960
 ldd #12
 std _b1
 lbra L835
L850
* Begin expression - 1962
 ldd #0
 std _b1
 lbra L835
L851
* Begin expression - 1965
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 1966
 ldx [-550,y]
 ldb 0,x
 cmpb #63
 lbne L852
* Begin expression - 1966
 ldd #127
 std _b1
 lbra L853
L852
* Begin expression - 1967
 ldx [-550,y]
 ldb 0,x
 sex
 clra
 andb #$1F
 std _b1
L853
 lbra L835
L854
* Begin expression - 1969
 ldx [-550,y]
 ldb 0,x
 sex
 std _b1
 lbra L835
L836
 ldx #L10032
 std L10031
L10030 cmpd 0,x++
 bne L10030
 jmp [L10031-L10032,x]
 data
L10032  fdb 33,78,110,84,116,82,114,66,98,69,101,70,102,48,94
L10031 fdb 0
 fdb L837,L838,L839,L840,L841,L842,L843,L844,L845,L846,L847,L848,L849,L850,L851,L854
 text
L835
* Begin expression - 1971
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L834
* Begin expression - 1973
 jsr _prsnb
* Begin expression - 1973
 jsr _pbytes
* Begin expression - 1973
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
 lbra L832
L833
* Begin expression - 1975
 ldb -554,y
 lbeq L855
* Begin expression - 1976
 ldd #0
 std _b1
* Begin expression - 1977
 jsr _prsnb
* Begin expression - 1977
 jsr _pbytes
* Begin expression - 1977
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L855
* Begin expression - 1979
 ldx [-550,y]
 ldb 0,x
 cmpb #34
 lbne L856
* Begin expression - 1979
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L856
* Begin expression - 1980
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 1981
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L857
* Begin expression - 1981
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L857
* Begin expression - 1982
 ldx -550,y
 stx 0,s
 jsr _eatspac
 lbra L830
L831
* Begin expression - 1984
 jsr _canlist
 cmpd #0
 lbeq L858
 ldb _bytef
 lbeq L858
 ldb _bytep
10
 lbeq L858
* Begin expression - 1984
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L442
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
L858
 lbra L442
L859
L860
L861
* Begin expression - 1990
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 1991
 ldd #1
 std _fb2
L862
* Begin expression - 1992
 ldb _p2evnf
 lbeq L863
* Begin expression - 1993
 ldd #0
 std _symtabr
* Begin expression - 1993
 ldd #0
 std _exttabr
* Begin expression - 1994
 ldx -550,y
 stx 0,s
 jsr _p2evn
* Begin expression - 1995
 ldb _p2evnf
 lbeq L863
L864
* Begin expression - 1996
 ldd _p2evnn
 tfr a,b
 sex
 clra
 std _b1
* Begin expression - 1997
 ldd _p2evnn
 clra
 std _b2
* Begin expression - 1998
 ldd _symtabr
 lbeq L865
* Begin expression - 1998
 ldd #1
 std _relocat
L865
* Begin expression - 1999
 ldd _exttabr
 lbeq L866
* Begin expression - 2000
 ldd _extrtp
 lslb
 rola
 ldx #_exrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2001
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 std [0,s]
* Begin expression - 2002
 ldd _extrtp
 inc _extrtp+1
 bne 1f
 inc _extrtp
1
 ldx #_exptab
 leax d,x
 ldd _psect
 stb 0,x
L866
* Begin expression - 2004
 jsr _pbytes
* Begin expression - 2005
 jsr _prsnb
* Begin expression - 2006
 ldd _b2
 std _b1
* Begin expression - 2007
 jsr _prsnb
* Begin expression - 2008
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd #2
 std 0,x
 lbra L862
L863
* Begin expression - 2010
 ldb _bytep
 lbeq L867
 jsr _canlist
 cmpd #0
 lbeq L867
 ldb _bytef
10
 lbeq L867
* Begin expression - 2010
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L442
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
L867
 lbra L442
L868
 lbra L528
L869
* Begin expression - 2018
 ldx -550,y
 stx 0,s
 jsr _evolexp
* Begin expression - 2019
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L870
* Begin expression - 2023
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 2024
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 2025
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L871
* Begin expression - 2026
 ldx _MI
 stx 0,s
 jsr _panic
 lbra L442
L871
* Begin expression - 2029
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _poe
 lbra L442
L872
 lbra L541
L873
* Begin expression - 2036
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L554
L874
* Begin expression - 2040
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L875
 lbra L592
L876
* Begin expression - 2047
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L620
L877
* Begin expression - 2051
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L623
L878
L879
 lbra L627
L880
* Begin expression - 2059
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L634
L881
* Begin expression - 2063
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L655
L882
* Begin expression - 2067
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L673
L883
* Begin expression - 2071
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L677
L884
* Begin expression - 2075
 clr _listfla
 lbra L442
L885
* Begin expression - 2079
 ldb #1
 stb _listfla
 lbra L442
L886
* Begin expression - 2083
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L682
L887
* Begin expression - 2087
 ldb #1
 stb _macflag
 lbra L442
L888
* Begin expression - 2091
 clr _macflag
 lbra L442
L889
L890
L891
* Begin expression - 2097
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 2098
 ldx -550,y
 stx 0,s
 jsr _commaer
L892
* Begin expression - 2099
 leax -25,y
 stx 0,s
 ldx -550,y
 pshs x
 jsr _getarg
 leas 2,s
 cmpd #0
 lbeq L893
* Begin expression - 2100
 ldx #_globs
 stx 0,s
 leax -25,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbeq L894
* Begin expression - 2101
 ldx #L895
 stx 0,s
 jsr _panic
 data
L895 fcb 68,111,117,98,108,101,32,100,101,102,105,110,101,100,32,103
 fcb 108,111,98,97,108,58,0
 text
* Begin expression - 2102
 leax -25,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
 lbra L896
L894
* Begin expression - 2104
 ldx #_globs
 stx 0,s
 leax -25,y
 pshs x
 jsr _cement
 leas 2,s
L896
 lbra L892
L893
 lbra L442
L897
* Begin expression - 2109
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L898
 lbra L704
L899
* Begin expression - 2116
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 2117
 ldb #1
 stb _bytef
 lbra L442
L900
* Begin expression - 2121
 ldx 4,y
 stx 0,s
 jsr _prsl
* Begin expression - 2122
 clr _bytef
 lbra L442
L901
 lbra L715
L902
 lbra L717
L903
 lbra L719
L904
L905
 lbra L722
L906
* Begin expression - 2139
 ldd #0
 std _psect
 lbra L532
L907
* Begin expression - 2143
 ldd #1
 std _psect
 lbra L532
L908
* Begin expression - 2147
 ldd #2
 std _psect
 lbra L532
L909
* Begin expression - 2151
 ldd #3
 std _psect
 lbra L532
L910
* Begin expression - 2155
 ldd #4
 std _psect
 lbra L532
 lbra L813
L814
 ldx #L10036
 std L10035
L10034 cmpd 0,x++
 bne L10034
 jmp [L10035-L10036,x]
 data
L10036  fdb 1,41,2,15,31,3,34,35,17,33,4,16,32,5,6,7
 fdb 8,9,10,11,12,13,14,36,18,19,20,21,22,23,24,25
 fdb 26,27,39,40,28,29,30,37,38,42,43,44,45,46,47,48
 fdb 49,50,51
L10035 fdb 0
 fdb L815,L816,L817,L818,L819,L820,L825,L826,L827,L828,L829,L859,L860,L861,L868,L869
 fdb L870,L872,L873,L874,L875,L876,L877,L878,L879,L880,L881,L882,L883,L884,L885,L886
 fdb L887,L888,L889,L890,L891,L897,L898,L899,L900,L901,L902,L903,L904,L905,L906,L907
 fdb L908,L909,L910,L10033
 text
L10033
 text
L813
L812
* Begin expression - 2162
 ldx #_spmot
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
 cmpd #-1
 lbeq L911
* Begin expression - 2163
 std 0,s
 ldd #6
 jsr imul
 ldx #_spmotd
 ldb d,x
 sex
 clra
 std _b1
* Begin expression - 2164
 ldd -951,y
 ldx #_spmots
 ldb d,x
 cmpb #2
 lblt L912
* Begin expression - 2165
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_spmotd
 leax d,x
 ldb 1,x
 sex
 clra
 std _b2
* Begin expression - 2166
 ldd #1
 std _fb2
L912
* Begin expression - 2168
 ldd -951,y
 ldx #_spmots
 ldb d,x
 cmpb #3
 lblt L913
* Begin expression - 2169
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_spmotd
 leax d,x
 ldb 2,x
 sex
 clra
 std _b3
* Begin expression - 2170
 ldd #1
 std _fb3
L913
* Begin expression - 2172
 ldd -951,y
 ldx #_spmots
 ldb d,x
 cmpb #4
 lblt L914
* Begin expression - 2173
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_spmotd
 leax d,x
 ldb 3,x
 sex
 clra
 std _b4
* Begin expression - 2174
 ldd #1
 std _fb4
L914
* Begin expression - 2176
 ldd -951,y
 ldx #_spmots
 ldb d,x
 cmpb #5
 lblt L915
* Begin expression - 2177
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_spmotd
 leax d,x
 ldb 4,x
 sex
 clra
 std _b5
* Begin expression - 2178
 ldd #1
 std _fb5
L915
* Begin expression - 2180
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 2181
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L916
* Begin expression - 2181
 ldx _SYN
 stx 0,s
 jsr _panic
L916
 lbra L917
L911
* Begin expression - 2185
 ldx #_mot
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 std -951,y
* Begin expression - 2186
 cmpd #-1
 lbne L918
* Begin expression - 2187
 ldx #L919
 stx 0,s
 jsr _panic
 data
L919 fcb 85,110,100,101,102,105,110,101,100,32,32,73,110,115,116,114
 fcb 117,99,116,105,111,110,58,0
 text
* Begin expression - 2188
 leax -46,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
* Begin expression - 2189
 ldx 4,y
 stx 0,s
 jsr _prsl
 lbra L442
L918
* Begin expression - 2193
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 2194
 ldd #0
 std _prebyte
 stb _indir
 sex
 std _fb5
 std _fb4
 std _fb3
 std _fb2
* Begin expression - 2195
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 4,x
 cmpb #1
 lbeq L920
* Begin expression - 2196
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 4,x
 sex
 std _b1
* Begin expression - 2197
 ldd #0
 std _b2
* Begin expression - 2198
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2199
 ldd _b1
 cmpd #52
 lblt L921
 ldd _b1
 cmpd #55
10
 lbgt L921
* Begin expression - 2200
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L922
* Begin expression - 2200
 ldx _MI
 stx 0,s
 jsr _panic
L922
L923
* Begin expression - 2201
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L924
* Begin expression - 2202
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L925
 ldx [-550,y]
 ldb 1,x
 cmpb #112
10
 lbne L925
* Begin expression - 2203
 ldd _b2
 orb #$8
 std _b2
 lbra L926
L925
* Begin expression - 2204
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 sex
 std 0,s
 jsr _ppb
 ora _b2
 orb _b2+1
 std _b2
L926
L927
* Begin expression - 2205
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbeq L928
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
10
 cmpd #0
 lbeq L928
* Begin expression - 2205
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L927
L928
* Begin expression - 2206
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L929
* Begin expression - 2206
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L929
 lbra L923
L924
* Begin expression - 2208
 ldd #1
 std _fb2
L921
* Begin expression - 2210
 ldd _b1
 cmpd #30
 beq 11f
 ldd _b1
 cmpd #31
10
 lbne L930
11
* Begin expression - 2211
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L931
* Begin expression - 2211
 ldx _MI
 stx 0,s
 jsr _panic
L931
* Begin expression - 2212
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L932
 ldx [-550,y]
 ldb 1,x
 cmpb #112
10
 lbne L932
* Begin expression - 2213
 ldd #176
 std _b2
 lbra L933
L932
* Begin expression - 2214
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _tfrb
 lslb
 rola
 lslb
 rola
 lslb
 rola
 lslb
 rola
 std _b2
L933
L934
* Begin expression - 2215
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbeq L935
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
10
 cmpd #0
 lbeq L935
* Begin expression - 2215
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L934
L935
* Begin expression - 2216
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L936
* Begin expression - 2216
 ldx _MI
 stx 0,s
 jsr _panic
L936
* Begin expression - 2217
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2218
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L937
 ldx [-550,y]
 ldb 1,x
 cmpb #112
10
 lbne L937
* Begin expression - 2219
 ldd _b2
 addd #11
 std _b2
* Begin expression - 2220
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L938
L937
* Begin expression - 2222
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _tfrb
 addd _b2
 std _b2
L938
* Begin expression - 2223
 ldd #1
 std _fb2
* Begin expression - 2224
 ldd _b2
 clra
 andb #$80
 asra
 rorb
 asra
 rorb
 asra
 rorb
 asra
 rorb
 std 0,s
 ldd _b2
 clra
 andb #$8
 eora 0,s
 eorb 1,s
 cmpd #0
 lbeq L939
* Begin expression - 2225
 ldx #L940
 stx 0,s
 jsr _panic
 data
L940 fcb 116,102,114,47,101,120,103,32,98,101,116,119,101,101,110,32
 fcb 100,105,102,102,101,114,101,110,116,32,115,105,122,101,100,32
 fcb 114,101,103,105,115,116,101,114,115,46,0
 text
L939
* Begin expression - 2226
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2227
 ldx [-550,y]
 ldb 0,x
 cmpb #99
 lbne L941
* Begin expression - 2227
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
L941
L930
* Begin expression - 2229
 ldx -550,y
 stx 0,s
 jsr _eatspac
* Begin expression - 2230
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L942
* Begin expression - 2230
 ldx _SYN
 stx 0,s
 jsr _panic
L942
 lbra L917
L920
* Begin expression - 2233
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _eqs
 cmpd #0
 lbeq L943
* Begin expression - 2233
 ldx _MI
 stx 0,s
 jsr _panic
L943
* Begin expression - 2234
 ldx [-550,y]
 ldb 0,x
 cmpb #35
 lbne L944
* Begin expression - 2235
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 ldb d,x
 sex
 std _b1
* Begin expression - 2236
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2237
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2238
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _b2
* Begin expression - 2239
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 ldb d,x
 sex
 clra
 ldx #_mlt
 ldb d,x
 cmpb #3
 lbne L945
* Begin expression - 2240
 ldd _b2
 clra
 std _b3
* Begin expression - 2241
 ldd _b2
 tfr a,b
 sex
 clra
 std _b2
* Begin expression - 2242
 ldd #1
 std _fb2
* Begin expression - 2243
 ldd #1
 std _fb3
* Begin expression - 2244
 ldd _symtabr
 lbeq L946
* Begin expression - 2245
 ldd #2
 std _relocat
L946
* Begin expression - 2247
 ldd _exttabr
 lbeq L947
* Begin expression - 2248
 ldd _extrtp
 lslb
 rola
 ldx #_exrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2249
 ldd _prebyte
 lbeq L948
* Begin expression - 2249
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #2
 std [0,s]
 lbra L949
L948
* Begin expression - 2250
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #1
 std [0,s]
L949
* Begin expression - 2251
 ldd _extrtp
 inc _extrtp+1
 bne 1f
 inc _extrtp
1
 ldx #_exptab
 leax d,x
 ldd _psect
 stb 0,x
L947
 lbra L950
L945
* Begin expression - 2255
 ldd #1
 std _fb2
* Begin expression - 2256
 ldd _b2
 clra
 std _b2
L950
* Begin expression - 2258
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 ldb d,x
 cmpb #1
 lbne L951
* Begin expression - 2259
 ldx #L952
 stx 0,s
 jsr _panic
 data
L952 fcb 73,109,101,100,46,32,109,111,100,101,32,111,110,32,110,111
 fcb 110,45,105,109,101,100,46,32,105,110,115,116,114,117,99,116
 fcb 105,111,110,0
 text
L951
* Begin expression - 2261
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _neqs
 cmpd #0
 lbeq L953
* Begin expression - 2261
 ldx _SYN
 stx 0,s
 jsr _panic
L953
* Begin expression - 2262
 ldb _indir
 lbeq L954
* Begin expression - 2262
 ldx _SYN
 stx 0,s
 jsr _panic
L954
 lbra L917
L944
* Begin expression - 2265
 ldd -550,y
 std -562,y
* Begin expression - 2266
 ldd [-550,y]
 std -949,y
* Begin expression - 2267
 ldx -550,y
 stx 0,s
 jsr _opsize
 stb -553,y
L955
* Begin expression - 2268
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbeq L956
 ldx [-550,y]
 ldb 0,x
 cmpb #59
10
 lbeq L956
* Begin expression - 2268
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 lbra L955
L956
* Begin expression - 2269
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L957
* Begin expression - 2270
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2271
 ldx [-550,y]
 stx 0,s
 jsr _swapit
* Begin expression - 2272
 ldx [-550,y]
 ldb 0,x
 cmpb #120
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #121
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #117
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #115
10
 lbne L958
11
* Begin expression - 2273
 ldx [-550,y]
 ldb 0,x
 sex
 std 0,s
 jsr _ibr
 std 0,s
 ldd #5
 jsr ishl
 std _b2
* Begin expression - 2273
 ldd #1
 std _fb2
* Begin expression - 2274
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 sex
 std _b1
* Begin expression - 2275
 ldx -562,y
 stx -550,y
* Begin expression - 2275
 ldx -949,y
 stx [-550,y]
* Begin expression - 2276
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 cmpb #1
 lbne L959
* Begin expression - 2277
 ldx #L960
 stx 0,s
 jsr _panic
 data
L960 fcb 73,110,100,105,114,101,99,116,32,109,111,100,101,32,111,110
 fcb 32,110,111,110,45,105,110,100,105,114,101,99,116,32,105,110
 fcb 115,116,114,117,99,116,105,111,110,46,13,0
 text
L959
* Begin expression - 2278
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2279
 ldx [-550,y]
 ldb 0,x
 cmpb #91
 lbne L961
* Begin expression - 2280
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2280
 ldd _b2
 addd #16
 std _b2
* Begin expression - 2281
 inc _indir
L961
* Begin expression - 2283
 ldx [-550,y]
 ldb 0,x
 cmpb #44
 lbne L962
* Begin expression - 2284
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2285
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2286
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
 ldb -1,x
 sex
 lbra L964
L965
* Begin expression - 2288
 ldx [-550,y]
 ldb 0,x
 cmpb #43
 lbne L966
* Begin expression - 2289
 ldd _b2
 addd #129
 std _b2
 lbra L967
L966
* Begin expression - 2290
 ldd _b2
 addd #128
 std _b2
L967
 lbra L963
L968
* Begin expression - 2293
 ldx [-550,y]
 ldb 0,x
 cmpb #45
 lbne L969
* Begin expression - 2294
 ldd _b2
 addd #131
 std _b2
 lbra L970
L969
* Begin expression - 2295
 ldd _b2
 addd #130
 std _b2
L970
 lbra L963
L971
* Begin expression - 2298
 ldd _b2
 addd #132
 std _b2
 lbra L963
L964
 ldx #L10039
 std L10038
L10037 cmpd 0,x++
 bne L10037
 jmp [L10038-L10039,x]
 data
L10039  fdb 43,45
L10038 fdb 0
 fdb L965,L968,L971
 text
L963
 lbra L917
L962
* Begin expression - 2303
 ldx [-550,y]
 ldb 0,x
 cmpb #97
 beq 10f
 ldx [-550,y]
 ldb 0,x
 cmpb #98
 beq 10f
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L972
10
 ldx [-550,y]
 ldb 1,x
 cmpb #44
11
 lbne L972
* Begin expression - 2304
 ldx [-550,y]
 ldb 0,x
 sex
 lbra L974
L975
* Begin expression - 2306
 ldd _b2
 addd #134
 std _b2
 lbra L973
L976
* Begin expression - 2309
 ldd _b2
 addd #133
 std _b2
 lbra L973
L977
* Begin expression - 2312
 ldd _b2
 addd #139
 std _b2
 lbra L973
 lbra L973
L974
 ldx #L10043
 std L10042
L10041 cmpd 0,x++
 bne L10041
 jmp [L10042-L10043,x]
 data
L10043  fdb 97,98,100
L10042 fdb 0
 fdb L975,L976,L977,L10040
 text
L10040
 text
L973
* Begin expression - 2315
 ldx [-550,y]
 leax 3,x
 stx [-550,y]
* Begin expression - 2316
 ldx [-550,y]
 ldb 0,x
 cmpb #43
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #45
10
 lbne L978
11
* Begin expression - 2317
 ldx #L979
 stx 0,s
 jsr _panic
 data
L979 fcb 67,97,110,39,116,32,109,105,120,32,105,110,99,114,101,109
 fcb 101,110,116,115,32,119,105,116,104,32,111,102,102,115,101,116
 fcb 115,0
 text
L978
 lbra L917
L972
* Begin expression - 2321
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _b4
* Begin expression - 2322
 ldx [-550,y]
 leax 2,x
 stx [-550,y]
* Begin expression - 2323
 ldx [-550,y]
 ldb 0,x
 cmpb #45
 beq 11f
 ldx [-550,y]
 ldb 0,x
 cmpb #43
10
 lbne L980
11
* Begin expression - 2324
 ldx #L981
 stx 0,s
 jsr _panic
 data
L981 fcb 67,97,110,39,116,32,109,105,120,32,105,110,99,114,101,109
 fcb 101,110,116,115,32,119,105,116,104,32,111,102,102,115,101,116
 fcb 115,0
 text
L980
* Begin expression - 2325
 ldb -553,y
 lbne L982
* Begin expression - 2326
 ldb _indir
 lbne L984
L983
* Begin expression - 2327
 ldd _b4
 clra
 andb #$1F
 addd _b2
 std _b2
* Begin expression - 2328
 ldd #1
 std _fb2
 lbra L917
L982
* Begin expression - 2331
 ldb -553,y
 cmpb #1
 lbne L985
L984
* Begin expression - 2332
 ldd _b2
 addd #136
 std _b2
* Begin expression - 2332
 ldd #1
 std _fb3
 std _fb2
* Begin expression - 2333
 ldd _b4
 clra
 std _b3
 lbra L917
L985
* Begin expression - 2336
 ldd _b4
 tfr a,b
 sex
 clra
 std _b3
* Begin expression - 2337
 ldd _b4
 clra
 std _b4
* Begin expression - 2338
 ldd _b2
 addd #137
 std _b2
* Begin expression - 2338
 ldd #1
 std _fb4
 std _fb3
 std _fb2
 lbra L917
L958
* Begin expression - 2341
 ldx [-550,y]
 ldb 0,x
 cmpb #112
 lbne L986
* Begin expression - 2342
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 sex
 std _b1
* Begin expression - 2343
 ldd _b1
 cmpd #1
 lbne L987
* Begin expression - 2344
 ldx #L988
 stx 0,s
 jsr _panic
 data
L988 fcb 73,110,100,101,120,101,100,32,97,100,100,114,101,115,115,105
 fcb 110,103,32,111,110,32,110,111,110,45,105,110,100,101,120,101
 fcb 100,32,105,110,115,116,114,117,99,116,105,111,110,0
 text
L987
* Begin expression - 2345
 ldx -562,y
 stx -550,y
* Begin expression - 2345
 ldx -949,y
 stx [-550,y]
* Begin expression - 2346
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2347
 ldd #141
 std _b2
* Begin expression - 2348
 ldd #1
 std _fb4
 std _fb3
 std _fb2
* Begin expression - 2349
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std 0,s
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 nega
 negb
 sbca #0
 addd 0,s
 subd #4
 std _b4
* Begin expression - 2350
 ldd _prebyte
 lbeq L989
* Begin expression - 2350
 tst _b4+1
 bne 1f
 dec _b4
1 dec _b4+1
L989
* Begin expression - 2351
 ldd _exttabr
 lbeq L990
* Begin expression - 2352
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd _b4
 std _b4
* Begin expression - 2353
 ldd _prebyte
 lbeq L991
* Begin expression - 2354
 ldd _b4
 addd #5
 std _b4
 lbra L992
L991
* Begin expression - 2356
 ldd _b4
 addd #4
 std _b4
L992
L990
* Begin expression - 2358
 ldd _b4
 tfr a,b
 sex
 clra
 std _b3
* Begin expression - 2359
 ldd _b4
 clra
 std _b4
* Begin expression - 2360
 ldd _exttabr
 lbeq L993
* Begin expression - 2361
 ldd _rtrtp
 lslb
 rola
 ldx #_rrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2362
 ldd _prebyte
 lbeq L994
* Begin expression - 2362
 ldd _rtrtp
 lslb
 rola
 ldx #_ratab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #3
 std [0,s]
 lbra L995
L994
* Begin expression - 2363
 ldd _rtrtp
 lslb
 rola
 ldx #_ratab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #2
 std [0,s]
L995
* Begin expression - 2364
 ldd _rtrtp
 inc _rtrtp+1
 bne 1f
 inc _rtrtp
1
 ldx #_rptab
 leax d,x
 ldd _psect
 stb 0,x
L993
* Begin expression - 2366
 ldb _indir
 lbeq L996
* Begin expression - 2366
 ldd _b2
 addd #16
 std _b2
L996
 lbra L917
L986
* Begin expression - 2369
 ldx [-550,y]
 ldb 0,x
 cmpb #100
 lbne L997
* Begin expression - 2370
 ldx -562,y
 stx -550,y
* Begin expression - 2371
 ldx -949,y
 stx [-550,y]
* Begin expression - 2372
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std _b2
* Begin expression - 2373
 ldd #1
 std _fb2
* Begin expression - 2374
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 1,x
 sex
 std _b1
* Begin expression - 2375
 ldd _b1
 cmpd #1
 lbne L998
* Begin expression - 2376
 ldx #L999
 stx 0,s
 jsr _panic
 data
L999 fcb 68,105,114,101,99,116,32,109,111,100,101,32,111,110,32,110
 fcb 111,110,45,100,105,114,101,99,116,32,105,110,115,116,114,117
 fcb 99,116,105,111,110,0
 text
L998
* Begin expression - 2378
 ldb _indir
 lbeq L1000
* Begin expression - 2378
 ldx _SYN
 stx 0,s
 jsr _panic
L1000
 lbra L917
L997
* Begin expression - 2381
 ldx _SYN
 stx 0,s
 jsr _panic
L957
* Begin expression - 2383
 ldx -562,y
 stx -550,y
* Begin expression - 2384
 ldx -949,y
 stx [-550,y]
* Begin expression - 2385
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 3,x
 cmpb #1
 lbeq L1001
* Begin expression - 2386
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2387
 ldx [-550,y]
 ldb 0,x
 cmpb #91
 lbeq L1002
* Begin expression - 2388
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 3,x
 sex
 std _b1
* Begin expression - 2389
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -951,y
* Begin expression - 2390
 tfr a,b
 sex
 clra
 std _b2
* Begin expression - 2391
 ldd -951,y
 clra
 std _b3
* Begin expression - 2392
 ldd #1
 std _fb2
* Begin expression - 2393
 ldd #1
 std _fb3
* Begin expression - 2394
 ldd _symtabr
 lbeq L1003
* Begin expression - 2395
 ldd #2
 std _relocat
L1003
* Begin expression - 2397
 ldd _exttabr
 lbeq L1004
* Begin expression - 2398
 ldd _extrtp
 lslb
 rola
 ldx #_exrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2399
 ldd _prebyte
 lbeq L1005
* Begin expression - 2399
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #2
 std [0,s]
 lbra L1006
L1005
* Begin expression - 2400
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #1
 std [0,s]
L1006
* Begin expression - 2401
 ldd _extrtp
 inc _extrtp+1
 bne 1f
 inc _extrtp
1
 ldx #_exptab
 leax d,x
 ldd _psect
 stb 0,x
L1004
 lbra L917
L1002
* Begin expression - 2405
 ldx [-550,y]
 leax 1,x
 stx [-550,y]
* Begin expression - 2406
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 2,x
 sex
 std _b1
* Begin expression - 2407
 ldd #159
 std _b2
* Begin expression - 2407
 ldd #1
 std _fb4
 std _fb3
 std _fb2
* Begin expression - 2408
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -951,y
* Begin expression - 2409
 tfr a,b
 sex
 clra
 std _b3
* Begin expression - 2410
 ldd -951,y
 clra
 std _b4
* Begin expression - 2411
 ldd _symtabr
 lbeq L1007
* Begin expression - 2411
 ldd #3
 std _relocat
L1007
* Begin expression - 2412
 ldd _exttabr
 lbeq L1008
* Begin expression - 2413
 ldd _extrtp
 lslb
 rola
 ldx #_exrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2414
 ldd _extrtp
 lslb
 rola
 ldx #_exatab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #2
 std [0,s]
* Begin expression - 2415
 ldd _extrtp
 inc _extrtp+1
 bne 1f
 inc _extrtp
1
 ldx #_exptab
 leax d,x
 ldd _psect
 stb 0,x
L1008
 lbra L917
L1001
* Begin expression - 2419
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 5,x
 cmpb #1
 lbeq L1009
* Begin expression - 2420
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldb 5,x
 sex
 std _b1
* Begin expression - 2421
 leax -46,y
 stx 0,s
 jsr _setpre
* Begin expression - 2422
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 lbne L1010
 ldd _b1
 cmpd #22
 lbeq L1010
 cmpd #23
10
 lbeq L1010
* Begin expression - 2423
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -951,y
* Begin expression - 2424
 ldb _indir
 lbeq L1011
* Begin expression - 2424
 ldx _SYN
 stx 0,s
 jsr _panic
L1011
* Begin expression - 2425
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 subd 0,x
 cmpd #129
 bgt 11f
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 subd -951,y
 cmpd #125
10
 lble L1012
11
* Begin expression - 2426
 ldx #L1013
 stx 0,s
 jsr _panic
 data
L1013 fcb 82,101,108,97,116,105,118,101,32,97,100,100,114,101,115,115
 fcb 32,111,117,116,32,111,102,32,114,97,110,103,101,0
 text
* Begin expression - 2427
 ldd #0
 std -951,y
L1012
* Begin expression - 2429
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 cmpd -951,y
 lbgt L1014
* Begin expression - 2430
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd -951,y
 subd 0,x
 subd #2
 std _b2
L1014
* Begin expression - 2432
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 cmpd -951,y
 lble L1015
* Begin expression - 2433
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 subd -951,y
 addd #1
 comb
 coma
 std _b2
L1015
* Begin expression - 2435
 ldd #1
 std _fb2
 lbra L917
L1010
* Begin expression - 2438
 ldx #_mot10
 stx 0,s
 leax -46,y
 pshs x
 jsr _llu
 leas 2,s
 cmpd #-1
 bne 11f
 ldd _b1
 cmpd #22
 beq 11f
 cmpd #23
10
 lbne L1016
11
* Begin expression - 2440
 ldx -550,y
 stx 0,s
 jsr _evolexp
 std -951,y
* Begin expression - 2441
 ldb _indir
 lbeq L1017
* Begin expression - 2441
 ldx _SYN
 stx 0,s
 jsr _panic
L1017
* Begin expression - 2442
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 addd #4
 nega
 negb
 sbca #0
 addd -951,y
 std -951,y
* Begin expression - 2443
 ldd _b1
 cmpd #22
 beq 11f
 ldd _b1
 cmpd #23
10
 lbne L1018
11
* Begin expression - 2443
 inc -950,y
 bne 1f
 inc -951,y
1
L1018
* Begin expression - 2444
 ldd _exttabr
 lbeq L1019
* Begin expression - 2445
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 ldd 0,x
 addd -951,y
 std -951,y
* Begin expression - 2446
 ldd _b1
 cmpd #22
 beq 11f
 ldd _b1
 cmpd #23
10
 lbne L1020
11
* Begin expression - 2447
 ldd -951,y
 addd #3
 std -951,y
 lbra L1021
L1020
* Begin expression - 2449
 ldd -951,y
 addd #4
 std -951,y
L1021
L1019
* Begin expression - 2451
 ldd -951,y
 tfr a,b
 sex
 clra
 std _b2
* Begin expression - 2452
 ldd -951,y
 clra
 std _b3
* Begin expression - 2453
 ldd #1
 std _fb3
 std _fb2
* Begin expression - 2454
 ldd _exttabr
 lbeq L1022
* Begin expression - 2455
 ldd _rtrtp
 lslb
 rola
 ldx #_rrtab
 leax d,x
 ldd _exttabr
 std 0,x
* Begin expression - 2456
 ldd _prebyte
 lbeq L1023
* Begin expression - 2456
 ldd _rtrtp
 lslb
 rola
 ldx #_ratab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #2
 std [0,s]
 lbra L1024
L1023
* Begin expression - 2457
 ldd _rtrtp
 lslb
 rola
 ldx #_ratab
 leax d,x
 ldd _psect
 lslb
 rola
 stx 0,s
 ldx #_pc
 ldd d,x
 addd #1
 std [0,s]
L1024
* Begin expression - 2458
 ldd _rtrtp
 inc _rtrtp+1
 bne 1f
 inc _rtrtp
1
 ldx #_rptab
 leax d,x
 ldd _psect
 stb 0,x
L1022
 lbra L917
L1016
L1009
* Begin expression - 2463
 ldx #L1025
 stx 0,s
 jsr _panic
 data
L1025 fcb 73,110,116,101,114,110,97,108,32,101,114,114,111,114,45,32
 fcb 116,121,112,101,32,111,102,32,105,110,115,116,114,117,99,116
 fcb 105,111,110,32,117,110,107,110,111,119,110,0
 text
* Begin expression - 2464
 leax -46,y
 stx 0,s
 ldd -951,y
 pshs d
 ldx #L1026
 pshs x
 jsr _printf
 leas 4,s
 data
L1026 fcb 74,32,105,115,32,37,100,44,32,105,110,115,116,114,117,99
 fcb 116,105,111,110,32,105,115,32,37,115,46,13,0
 text
* Begin expression - 2465
 ldd #0
 std -949,y
L1027
* Begin expression - 2465
 ldd -949,y
 cmpd #5
 lbeq L1028
* Begin expression - 2465
 ldd -951,y
 std 0,s
 ldd #6
 jsr imul
 ldx #_mvt
 leax d,x
 ldd -949,y
 ldb d,x
 sex
 std 0,s
 ldx #L1030
 pshs x
 jsr _printf
 leas 2,s
 data
L1030 fcb 37,100,32,32,0
 text
L1029
* Begin expression - 2465
 inc -948,y
 lbne L1027
 inc -949,y
 lbra L1027
L1028
* Begin expression - 2466
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb #13
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 lbra L917
10
 ldb #13
 sex
 std 0,s
 jsr __flsbuf
11
 lbra L917
L1031
* Begin expression - 2468
 ldx _MI
 stx 0,s
 jsr _panic
L917
* Begin expression - 2470
 jsr _prn
* Begin expression - 2471
 ldx 4,y
 stx 0,s
 jsr _prl
* Begin expression - 2472
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
* Begin expression - 2472
 ldd _prebyte
 lbeq L1032
* Begin expression - 2472
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L1032
* Begin expression - 2473
 ldd _fb2
 lbeq L1033
* Begin expression - 2473
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L1033
* Begin expression - 2473
 ldd _fb3
 lbeq L1034
* Begin expression - 2473
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L1034
* Begin expression - 2473
 ldd _fb4
 lbeq L1035
* Begin expression - 2473
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L1035
* Begin expression - 2473
 ldd _fb5
 lbeq L1036
* Begin expression - 2473
 ldd _psect
 lslb
 rola
 ldx #_pc
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L1036
L442
* Begin expression - 2474
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std _symv
* Begin expression - 2475
 ldd _psect
 stb _symp
 lbra L433
L434 equ 951
L433
 leas -4,y
 puls x,y,u,pc
 global _evolexp
_evolexp pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L1038,s
* Auto -26 s
* Auto -28 q
* Auto -30 d
* Register 1 k
* Auto -32 nf
* Auto -34 o
* Auto -36 of
* Auto -38 j_type
* Auto -40 i_type
* Auto -42 i
* Auto -44 j
* Auto -45 c
* Begin expression - 2493
 ldd #0
 std -36,y
 std -32,y
 std -42,y
* Begin expression - 2494
 ldd #0
 std -40,y
 std -38,y
* Begin expression - 2495
 ldd #32
 std -34,y
L1039
* Begin expression - 2498
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb -45,y
* Begin expression - 2499
 cmpb #41
 lbne L1040
* Begin expression - 2500
 ldd -36,y
 lbne L1041
* Begin expression - 2501
 ldd -40,y
 std _spsect
* Begin expression - 2502
 ldd -42,y
 lbra L1037
L1041
L1042
* Begin expression - 2504
 ldd -36,y
 lbeq L1043
* Begin expression - 2504
 ldx #L1044
 stx 0,s
 jsr _panic
 data
L1044 fcb 80,97,114,101,110,32,103,97,114,98,101,103,101,0
 text
* Begin expression - 2504
 ldd -42,y
 lbra L1037
L1043
* Begin expression - 2505
 ldd -36,y
 lbne L1045
* Begin expression - 2505
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2505
 ldd -40,y
 std _spsect
* Begin expression - 2505
 ldd -42,y
 lbra L1037
L1045
L1040
* Begin expression - 2507
 ldb -45,y
 lbne L1046
* Begin expression - 2507
 ldx #L1047
 stx 0,s
 jsr _panic
 data
L1047 fcb 85,110,69,120,69,79,70,63,63,0
 text
* Begin expression - 2507
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2507
 ldd -42,y
 lbra L1037
L1046
* Begin expression - 2508
 ldb -45,y
 cmpb #91
 beq 11f
 cmpb #93
10
 lbne L1048
11
* Begin expression - 2509
 inc _indir
 lbra L1039
L1048
* Begin expression - 2512
 ldb -45,y
 cmpb #40
 lbne L1049
* Begin expression - 2513
 ldx 4,y
 stx 0,s
 jsr _evolexp
 std -44,y
* Begin expression - 2514
 ldd _spsect
 std -38,y
 lbra L1050
L1049
* Begin expression - 2518
 ldb -45,y
 cmpb #96
 lbne L1051
* Begin expression - 2519
 ldx [4,y]
 ldb 0,x
 cmpb #59
 lbeq L1052
* Begin expression - 2519
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1052
 lbra L1039
L1051
* Begin expression - 2523
 ldb -45,y
 cmpb #39
 lbne L1053
* Begin expression - 2524
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb -45,y
* Begin expression - 2525
 cmpb #92
 lbne L1054
* Begin expression - 2526
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb -45,y
* Begin expression - 2527
 sex
 lbra L1056
L1057
* Begin expression - 2528
 ldb #7
 stb -45,y
 lbra L1055
L1058
* Begin expression - 2530
 ldb #13
 stb -45,y
 lbra L1055
L1059
* Begin expression - 2532
 ldb #9
 stb -45,y
 lbra L1055
L1060
* Begin expression - 2534
 ldb #13
 stb -45,y
 lbra L1055
L1061
* Begin expression - 2536
 ldb #8
 stb -45,y
 lbra L1055
L1062
* Begin expression - 2538
 ldb #27
 stb -45,y
 lbra L1055
L1063
* Begin expression - 2540
 ldb #12
 stb -45,y
 lbra L1055
L1064
* Begin expression - 2543
 ldx [4,y]
 ldb 0,x
 cmpb #63
 lbne L1065
* Begin expression - 2543
 ldb #127
 stb -45,y
 lbra L1066
L1065
* Begin expression - 2544
 ldx [4,y]
 ldb 0,x
 sex
 clra
 andb #$1F
 stb -45,y
L1066
* Begin expression - 2545
 ldx [4,y]
 leax 1,x
 stx [4,y]
 lbra L1055
L1067
* Begin expression - 2548
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #0
 lbne L1068
* Begin expression - 2549
 ldx 4,y
 stx 0,s
 jsr _penum
 stb -45,y
 lbra L1069
L1068
* Begin expression - 2551
 clr -45,y
L1069
 lbra L1055
 lbra L1055
L1056
 ldx #L10047
 std L10046
L10045 cmpd 0,x++
 bne L10045
 jmp [L10046-L10047,x]
 data
L10047  fdb 33,110,116,114,98,101,102,94,48
L10046 fdb 0
 fdb L1057,L1058,L1059,L1060,L1061,L1062,L1063,L1064,L1067,L10044
 text
L10044
 text
L1055
L1054
* Begin expression - 2555
 ldb -45,y
 sex
 std -44,y
* Begin expression - 2556
 ldd #0
 std -38,y
* Begin expression - 2557
 ldx [4,y]
 ldb 0,x
 cmpb #39
 lbne L1070
* Begin expression - 2557
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1070
 lbra L1050
L1053
* Begin expression - 2560
 ldb -45,y
 cmpb #46
 lbne L1071
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _island
 cmpd #0
10
 lbne L1071
* Begin expression - 2561
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std -44,y
* Begin expression - 2562
 ldd _psect
 std -38,y
* Begin expression - 2563
 inc _symtabr+1
 lbne L1050
 inc _symtabr
 lbra L1050
L1071
* Begin expression - 2566
 ldb -45,y
 cmpb #36
 lbne L1072
* Begin expression - 2567
 ldx 4,y
 stx 0,s
 jsr _penum
 std -44,y
* Begin expression - 2568
 ldd #0
 std -38,y
 lbra L1050
L1072
* Begin expression - 2571
 ldb -45,y
 sex
 std 0,s
 jsr _islet
 cmpd #0
 lbne L1073
* Begin expression - 2572
 ldx 4,y
 stx 0,s
 jsr _penum
 std -44,y
* Begin expression - 2573
 ldd #0
 std -38,y
L1050
* Begin expression - 2575
 ldd -32,y
 lbne L1074
* Begin expression - 2576
 ldd -44,y
 std -42,y
* Begin expression - 2576
 ldd -38,y
 std -40,y
* Begin expression - 2577
 ldd #1
 std -32,y
 lbra L1039
L1074
* Begin expression - 2580
 ldd -36,y
 lbne L1075
* Begin expression - 2580
 ldx #L1076
 stx 0,s
 jsr _panic
 data
L1076 fcb 50,32,35,44,32,110,111,32,111,112,115,46,32,63,63,0
 text
 lbra L1039
L1075
* Begin expression - 2581
 ldd -34,y
 std 0,s
 ldd -44,y
 pshs d
 ldd -42,y
 pshs d
 jsr _eval
 leas 4,s
 std -42,y
* Begin expression - 2582
 ldd -40,y
 cmpd -38,y
 lbeq L1077
* Begin expression - 2583
 cmpd #0
 lbeq L1078
 ldd -38,y
10
 lbeq L1078
* Begin expression - 2584
 ldx #L1079
 stx 0,s
 jsr _panic
 data
L1079 fcb 77,105,120,101,100,32,112,115,101,99,116,115,32,105,110,32
 fcb 97,110,32,101,120,112,114,101,115,105,111,110,46,0
 text
L1078
L1077
* Begin expression - 2586
 ldd -38,y
 lbeq L1080
* Begin expression - 2586
 std -40,y
L1080
* Begin expression - 2587
 ldd #0
 std -36,y
* Begin expression - 2588
 ldd #32
 std -34,y
 lbra L1039
L1073
* Begin expression - 2592
 ldb -45,y
 cmpb #61
 lbne L1081
* Begin expression - 2593
 ldx [4,y]
 ldb 0,x
 cmpb #61
 lbne L1082
* Begin expression - 2594
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
* Begin expression - 2595
 ldd #15677
 std -34,y
* Begin expression - 2596
 ldd #1
 std -36,y
 lbra L1039
L1082
* Begin expression - 2602
 ldx [4,y]
 ldb 0,x
 sex
 std -30,y
 cmpd #43
 beq 11f
 cmpd #45
 beq 11f
 cmpd #42
 beq 11f
 cmpd #47
 beq 11f
 cmpd #37
 beq 11f
 cmpd #62
 beq 11f
 cmpd #60
 beq 11f
 cmpd #38
 beq 11f
 cmpd #94
 beq 11f
 cmpd #124
10
 lbne L1083
11
* Begin expression - 2603
 ldd -30,y
 cmpd #62
 lbne L1084
* Begin expression - 2603
 ldd #15934
 std -30,y
* Begin expression - 2603
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
L1084
* Begin expression - 2604
 ldd -30,y
 cmpd #60
 lbne L1085
* Begin expression - 2604
 ldd #15420
 std -30,y
* Begin expression - 2604
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
L1085
* Begin expression - 2605
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
* Begin expression - 2606
 ldx 4,y
 stx 0,s
 jsr _evolexp
 std -44,y
* Begin expression - 2607
 ldd _spsect
 std -38,y
* Begin expression - 2608
 leax -26,y
 stx 0,s
 jsr _fsyml1
 std -28,y
 cmpd #-1
 lbne L1086
* Begin expression - 2609
 ldx _UND
 stx 0,s
 jsr _panic
 lbra L1087
L1086
* Begin expression - 2611
 inc _symtabr+1
 bne 1f
 inc _symtabr
1
* Begin expression - 2612
 ldd -28,y
 lslb
 rola
 ldx #_symv
 leax d,x
 stx 0,s
 ldd -30,y
 pshs d
 ldd -44,y
 pshs d
 ldd -28,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 pshs d
 jsr _eval
 leas 6,s
 std [0,s]
* Begin expression - 2613
 ldd -28,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 std -44,y
L1087
 lbra L1088
L1083
* Begin expression - 2616
 ldx 4,y
 stx 0,s
 jsr _evolexp
 std -44,y
* Begin expression - 2617
 ldd _spsect
 std -38,y
* Begin expression - 2618
 leax -26,y
 stx 0,s
 jsr _fsyml1
 std -28,y
 cmpd #-1
 lbne L1089
* Begin expression - 2619
 ldx _UND
 stx 0,s
 jsr _panic
 lbra L1090
L1089
* Begin expression - 2621
 inc _symtabr+1
 bne 1f
 inc _symtabr
1
* Begin expression - 2622
 ldd -28,y
 lslb
 rola
 ldx #_symv
 leax d,x
 ldd -44,y
 std 0,x
L1090
L1088
* Begin expression - 2625
 ldx [4,y]
 ldb -1,x
 cmpb #41
 beq 11f
 ldx [4,y]
 ldb -1,x
 cmpb #59
 beq 11f
 ldx [4,y]
 ldb -1,x
 cmpb #44
 beq 11f
 ldx [4,y]
 ldb -1,x
 cmpb #13
10
 lbne L1091
11
* Begin expression - 2625
 ldx [4,y]
 leax -1,x
 stx [4,y]
L1091
* Begin expression - 2626
 ldd #0
 std -32,y
 lbra L1050
L1081
L1092
* Begin expression - 2631
 ldb -45,y
 sex
 std 0,s
 jsr _islet
 cmpd #2
 beq 11f
 ldb -45,y
 cmpb #37
10
 lbne L1093
11
* Begin expression - 2632
 ldd -36,y
 bne 11f
 ldd -32,y
10
 lbne L1094
11
* Begin expression - 2633
 ldb -45,y
 sex
 lbra L1096
L1097
* Begin expression - 2635
 ldx 4,y
 stx 0,s
 jsr _uneval
 nega
 negb
 sbca #0
 std -44,y
* Begin expression - 2636
 ldd _spsect
 std -38,y
 lbra L1050
L1098
* Begin expression - 2639
 ldx 4,y
 stx 0,s
 jsr _uneval
 comb
 coma
 std -44,y
* Begin expression - 2640
 ldd _spsect
 std -38,y
 lbra L1050
L1099
* Begin expression - 2643
 ldx 4,y
 stx 0,s
 jsr _uneval
 cmpd #0
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 std -44,y
* Begin expression - 2644
 ldd _spsect
 std -38,y
 lbra L1050
L1100
* Begin expression - 2647
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std -44,y
* Begin expression - 2648
 ldd _psect
 std -38,y
 lbra L1050
L1101
 lbra L1042
L1102
 lbra L1039
L1103
 lbra L1042
L1104
 lbra L1042
L1105
* Begin expression - 2659
 ldx #L1106
 stx 0,s
 jsr _panic
 data
L1106 fcb 73,110,118,97,108,105,100,32,85,110,97,114,121,32,45,0
 text
* Begin expression - 2660
 ldx #L1107
 stx 0,s
 jsr _printf
 data
L1107 fcb 37,37,37,37,9,39,0
 text
* Begin expression - 2661
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldb -45,y
 sex
 clra
 andb #$7F
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldb -45,y
 sex
 clra
 andb #$7F
 std 0,s
 jsr __flsbuf
11
* Begin expression - 2662
 ldx #L1108
 stx 0,s
 jsr _printf
 data
L1108 fcb 39,13,0
 text
 lbra L1039
 lbra L1095
L1096
 ldx #L10050
 std L10049
L10048 cmpd 0,x++
 bne L10048
 jmp [L10049-L10050,x]
 data
L10050  fdb 45,126,33,42,59,43,44,13
L10049 fdb 0
 fdb L1097,L1098,L1099,L1100,L1101,L1102,L1103,L1104,L1105
 text
L1095
L1094
* Begin expression - 2666
 ldb -45,y
 cmpb #59
 lbeq L1042
L1109
* Begin expression - 2667
 ldb -45,y
 cmpb #44
 lbeq L1042
L1110
* Begin expression - 2668
 ldb -45,y
 cmpb #13
 lbeq L1042
L1111
* Begin expression - 2669
 ldd -32,y
 lbeq L1112
 ldd -36,y
10
 lbeq L1112
* Begin expression - 2670
 ldb -45,y
 cmpb #42
 lbne L1113
* Begin expression - 2671
 ldd _psect
 lslb
 rola
 ldx #_pc
 ldd d,x
 std -44,y
* Begin expression - 2672
 ldd _psect
 std -38,y
 lbra L1050
L1113
* Begin expression - 2675
 ldx #L1114
 stx 0,s
 jsr _panic
 data
L1114 fcb 49,32,35,44,32,50,32,111,112,115,32,63,63,0
 text
L1112
* Begin expression - 2678
 ldx [4,y]
 ldb 0,x
 sex
 std 0,s
 jsr _islet
 cmpd #2
 lbne L1115
 ldx [4,y]
 ldb 0,x
 cmpb #40
 lbeq L1115
 ldx [4,y]
 ldb 0,x
 cmpb #39
 lbeq L1115
 ldx [4,y]
 ldb 0,x
 cmpb #42
 lbeq L1115
 ldx [4,y]
 ldb 0,x
 cmpb #45
 lbeq L1115
 ldx [4,y]
 ldb 0,x
 cmpb #126
 lbeq L1115
 ldx [4,y]
 ldb 0,x
 cmpb #33
10
 lbeq L1115
* Begin expression - 2679
 ldb -45,y
 sex
 tfr b,a
 clrb
 sex
 std -34,y
* Begin expression - 2680
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 sex
 addd -34,y
 std -34,y
 lbra L1116
L1115
* Begin expression - 2682
 ldb -45,y
 sex
 std -34,y
L1116
* Begin expression - 2683
 ldd #1
 std -36,y
L1093
* Begin expression - 2686
 ldb -45,y
 sex
 std 0,s
 jsr _island
 cmpd #0
 lbeq L1117
 ldb -45,y
 cmpb #37
10
 lbeq L1117
* Begin expression - 2687
 leau -26,y
* Begin expression - 2688
 ldx [4,y]
 leax -1,x
 stx [4,y]
L1118
* Begin expression - 2689
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb 0,u+
 sex
 std 0,s
 jsr _island
 cmpd #0
 lbne L1118
L1119
* Begin expression - 2690
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2691
 clr 0,-u
* Begin expression - 2692
 leax -26,y
 stx 0,s
 jsr _fsyml1
 std -28,y
 cmpd #-1
 lbne L1120
* Begin expression - 2693
 ldx #_edtab
 stx 0,s
 leax -26,y
 pshs x
 jsr _llu
 leas 2,s
 std -28,y
 cmpd #-1
 lbeq L1121
* Begin expression - 2694
 ldb _binflag
 lbne L1122
* Begin expression - 2694
 ldd -28,y
 std _exttabr
L1122
* Begin expression - 2695
 ldd #0
 std -44,y
* Begin expression - 2696
 ldd #0
 std -38,y
 lbra L1050
L1121
* Begin expression - 2699
 ldb _exflag
 lbeq L1123
* Begin expression - 2700
 ldx #_edtab
 stx 0,s
 leax -26,y
 pshs x
 jsr _cement
 leas 2,s
* Begin expression - 2701
 ldx #_edtab
 stx 0,s
 leax -26,y
 pshs x
 jsr _llu
 leas 2,s
 std -28,y
* Begin expression - 2702
 ldb _binflag
 lbne L1124
* Begin expression - 2702
 ldd -28,y
 std _exttabr
L1124
* Begin expression - 2703
 ldd #0
 std -44,y
* Begin expression - 2704
 ldd #0
 std -38,y
 lbra L1050
 lbra L1125
L1123
* Begin expression - 2708
 ldx _UND
 stx 0,s
 jsr _panic
* Begin expression - 2709
 leax -26,y
 stx 0,s
 ldx _UCS
 pshs x
 jsr _printf
 leas 2,s
L1125
 lbra L1039
L1120
* Begin expression - 2713
 inc _symtabr+1
 bne 1f
 inc _symtabr
1
* Begin expression - 2714
 ldd -28,y
 lslb
 rola
 ldx #_symv
 ldd d,x
 std -44,y
* Begin expression - 2715
 ldd -28,y
 ldx #_symp
 ldb d,x
 sex
 std -38,y
 lbra L1050
L1117
 lbra L1039
L1038 equ 45
L1037
 leas -4,y
 puls x,y,u,pc
 global _ishex
_ishex pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L1127,s
* Begin expression - 2724
 ldd 4,y
 cmpd #48
 lblt L1128
 cmpd #57
10
 lbgt L1128
* Begin expression - 2724
 ldd #1
 lbra L1126
L1128
* Begin expression - 2725
 ldd 4,y
 cmpd #97
 lblt L1129
 cmpd #102
10
 lbgt L1129
* Begin expression - 2725
 ldd #1
 lbra L1126
L1129
* Begin expression - 2726
 ldd #0
 lbra L1126
L1127 equ 4
L1126
 leas -4,y
 puls x,y,u,pc
 global _penum
_penum pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L1131,s
* Auto -26 s
* Register 1 pp
* Auto -28 ll
* Auto -30 base
* Auto -31 flag
* Begin expression - 2738
 ldb #1
 stb -31,y
* Begin expression - 2739
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2740
 leau -26,y
* Begin expression - 2741
 ldd _curbase
 std -30,y
* Begin expression - 2742
 ldx [4,y]
 ldb 0,x
 cmpb #36
 lbne L1132
* Begin expression - 2743
 ldd #16
 std -30,y
* Begin expression - 2744
 clr -31,y
* Begin expression - 2745
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1132
* Begin expression - 2747
 ldx [4,y]
 ldb 0,x
 cmpb #48
 lbne L1133
 ldx [4,y]
 ldb 1,x
 cmpb #120
 beq 12f
 ldx [4,y]
 ldb 1,x
 cmpb #88
10
 lbne L1133
12
* Begin expression - 2748
 ldd #16
 std -30,y
* Begin expression - 2749
 clr -31,y
* Begin expression - 2750
 ldx [4,y]
 leax 1,x
 stx [4,y]
* Begin expression - 2750
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1133
L1134
* Begin expression - 2752
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb 0,u+
 sex
 std 0,s
 jsr _ishex
 cmpd #0
 lbne L1134
L1135
* Begin expression - 2753
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2754
 clr 0,-u
* Begin expression - 2755
 stu -28,y
* Begin expression - 2756
 leau -26,y
* Begin expression - 2757
 ldb -31,y
 lbeq L1136
* Begin expression - 2758
 ldb 0,u
 cmpb #48
 lbne L1137
* Begin expression - 2758
 ldd #8
 std -30,y
L1137
* Begin expression - 2759
 ldx [4,y]
 ldb 0,x
 cmpb #104
 lbne L1138
* Begin expression - 2759
 ldd #16
 std -30,y
* Begin expression - 2759
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1138
* Begin expression - 2760
 ldx [4,y]
 ldb 0,x
 cmpb #113
 lbne L1139
* Begin expression - 2760
 ldd #16
 std -30,y
* Begin expression - 2760
 ldx [4,y]
 leax 1,x
 stx [4,y]
L1139
L1136
* Begin expression - 2762
 leau -26,y
L1140
* Begin expression - 2763
 ldb 0,u
 lbeq L1141
* Begin expression - 2764
 ldb 0,u
 sex
 std 0,s
 jsr _islet
 cmpd #0
 lbeq L1142
* Begin expression - 2765
 ldd #16
 std -30,y
 lbra L1143
L1142
* Begin expression - 2768
 ldb 0,u
 subb #48
 sex
 cmpd -30,y
 lblt L1144
* Begin expression - 2769
 ldx _IDIN
 stx 0,s
 jsr _panic
L1144
L1143
* Begin expression - 2771
 leau 1,u
 lbra L1140
L1141
* Begin expression - 2773
 ldd -30,y
 std 0,s
 leax -26,y
 pshs x
 jsr _basin
 leas 2,s
 lbra L1130
L1131 equ 31
L1130
 leas -4,y
 puls x,y,u,pc
 global _eval
_eval pshs u,y,x
 leay 4,s
* Auto 4 a1
* Auto 6 a2
* Auto 8 o
 leas -L1146,s
* Begin expression - 2779
 ldd 8,y
 lbra L1148
L1149
* Begin expression - 2782
 ldd 4,y
 addd 6,y
 lbra L1145
L1150
* Begin expression - 2784
 ldd 4,y
 subd 6,y
 lbra L1145
L1151
* Begin expression - 2786
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr imul
 lbra L1145
L1152
* Begin expression - 2788
 ldd 4,y
 beq 10f
 ldd 6,y
10
 bne 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1153
* Begin expression - 2790
 ldd 4,y
 bne 10f
 ldd 6,y
10
 bne 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1154
* Begin expression - 2792
 ldd 4,y
 cmpd 6,y
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1155
* Begin expression - 2794
 ldd 4,y
 cmpd 6,y
 bne 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1156
* Begin expression - 2796
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr ishr
 lbra L1145
L1157
* Begin expression - 2798
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr ishl
 lbra L1145
L1158
* Begin expression - 2800
 ldd 4,y
 eora 6,y
 eorb 7,y
 lbra L1145
L1159
* Begin expression - 2802
 ldd 4,y
 cmpd 6,y
 bgt 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1160
* Begin expression - 2804
 ldd 4,y
 cmpd 6,y
 blt 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1161
* Begin expression - 2806
 ldd 4,y
 cmpd 6,y
 ble 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1162
* Begin expression - 2808
 ldd 4,y
 cmpd 6,y
 bge 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1145
L1163
* Begin expression - 2810
 ldd 4,y
 anda 6,y
 andb 7,y
 lbra L1145
L1164
* Begin expression - 2812
 ldd 4,y
 ora 6,y
 orb 7,y
 lbra L1145
L1165
* Begin expression - 2814
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr idiv
 lbra L1145
L1166
* Begin expression - 2816
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr imod
 lbra L1145
L1167
* Begin expression - 2818
 ldx #L1168
 stx 0,s
 jsr _panic
 data
L1168 fcb 105,110,118,97,108,105,100,32,111,112,101,114,97,116,111,114
 fcb 32,45,8,0
 text
* Begin expression - 2819
 ldd 8,y
 clra
 andb #$7F
 std 8,y
* Begin expression - 2820
 ldx #L1169
 stx 0,s
 jsr _printf
 data
L1169 fcb 37,37,37,37,9,39,0
 text
* Begin expression - 2821
 ldx #__obuf+512
 cmpx __opos
 ble 10f
 ldd 8,y
 ldx __opos
 stb 0,x+
 stx __opos
 sex
 clra
 bra 11f
10
 ldd 8,y
 std 0,s
 jsr __flsbuf
11
* Begin expression - 2822
 ldx #L1170
 stx 0,s
 jsr _printf
 data
L1170 fcb 39,13,0
 text
* Begin expression - 2823
 ldd #0
 lbra L1145
 lbra L1147
L1148
 ldx #L10053
 std L10052
L10051 cmpd 0,x++
 bne L10051
 jmp [L10052-L10053,x]
 data
L10053  fdb 43,45,42,9766,31868,15677,15649,15934,15420,94,62,60,15676,15678,38,124
 fdb 47,37
L10052 fdb 0
 fdb L1149,L1150,L1151,L1152,L1153,L1154,L1155,L1156,L1157,L1158,L1159,L1160,L1161,L1162,L1163,L1164
 fdb L1165,L1166,L1167
 text
L1147
L1146 equ 4
L1145
 leas -4,y
 puls x,y,u,pc
 global _uneval
_uneval pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L1172,s
* Auto -6 ss
* Auto -8 sss
* Auto -108 s
* Auto -109 c
* Register 1 k
* Auto -111 i
* Begin expression - 2836
 leax -108,y
 stx -6,y
* Begin expression - 2837
 leax -6,y
 stx -8,y
* Begin expression - 2838
 leau -108,y
* Begin expression - 2839
 ldd #0
 std -111,y
L1173
L1174
* Begin expression - 2840
 ldx [4,y]
 leax 1,x
 stx [4,y]
 ldb -1,x
 stb 0,u+
 stb -109,y
 sex
 std 0,s
 jsr _island
 cmpd #0
 lbne L1174
L1175
* Begin expression - 2841
 ldb -109,y
 cmpb #32
 beq 11f
 cmpb #9
10
 lbne L1176
11
 lbra L1173
L1176
* Begin expression - 2842
 ldb -109,y
 cmpb #40
 lbne L1177
* Begin expression - 2842
 inc -110,y
 bne 1f
 inc -111,y
1
L1177
* Begin expression - 2843
 ldb -109,y
 cmpb #41
 lbne L1178
 ldd -111,y
10
 lbeq L1178
* Begin expression - 2843
 tst -110,y
 bne 1f
 dec -111,y
1 dec -110,y
L1178
* Begin expression - 2844
 ldd -111,y
 lbne L1173
L1179
* Begin expression - 2845
 ldb -109,y
 cmpb #41
 lbeq L1180
* Begin expression - 2845
 leau -1,u
L1180
* Begin expression - 2846
 ldb #59
 stb 0,u+
* Begin expression - 2847
 clr 0,u
* Begin expression - 2848
 ldx [4,y]
 leax -1,x
 stx [4,y]
* Begin expression - 2849
 ldx -8,y
 stx 0,s
 jsr _evolexp
 lbra L1171
L1172 equ 111
L1171
 leas -4,y
 puls x,y,u,pc
 end
 name supas09.c
 text
 global _fsyml1
_fsyml1 pshs u,y,x
 leay 4,s
* Auto 4 s
 leas -L2,s
* Register 1 p
* Auto -6 ps
* Auto -8 i
* Auto -10 pp
* Auto -12 j
* Begin expression - 11
 ldu #_symn
* Begin expression - 12
 ldd #0
 std -8,y
L3
* Begin expression - 13
 ldd -8,y
 inc -7,y
 bne 1f
 inc -8,y
1
 cmpd _symll
 lbge L4
* Begin expression - 14
 ldd #0
 std -12,y
* Begin expression - 14
 stu -10,y
* Begin expression - 14
 ldx 4,y
 stx -6,y
* Begin expression - 15
 ldb [-6,y]
 cmpb 0,u
 lbne L5
L6
* Begin expression - 16
 ldx -6,y
 ldb 0,x+
 stx -6,y
 cmpb 0,u
 lbne L7
* Begin expression - 17
 ldb 0,u+
 cmpb #0
 lbne L8
* Begin expression - 17
 ldd -8,y
 subd #1
 std -8,y
 lbra L1
L8
* Begin expression - 18
 ldd -12,y
 addd #1
 std -12,y
 cmpd #8
 lblt L9
* Begin expression - 18
 ldd -8,y
 subd #1
 std -8,y
 lbra L1
L9
 lbra L6
L7
L5
* Begin expression - 21
 ldx -10,y
 leau 8,x
 lbra L3
L4
* Begin expression - 23
 ldd #-1
 lbra L1
L2 equ 12
L1
 leas -4,y
 puls x,y,u,pc
 global _fsyml2
_fsyml2 pshs u,y,x
 leay 4,s
* Auto 4 s
 leas -L11,s
* Begin expression - 28
 ldx 4,y
 stx 0,s
 jsr _fsyml1
 lbra L10
L11 equ 4
L10
 leas -4,y
 puls x,y,u,pc
 global _fsyms
_fsyms pshs u,y,x
 leay 4,s
* Auto 4 s
 leas -L13,s
* Register 1 p
* Auto -6 pp
* Auto -8 i
* Auto -10 j
* Begin expression - 36
 ldu #_symn
* Begin expression - 36
 ldx 4,y
 stx -6,y
* Begin expression - 36
 ldd #0
 std -8,y
* Begin expression - 36
 ldd #0
 std -10,y
L14
* Begin expression - 37
 ldd -8,y
 inc -7,y
 bne 1f
 inc -8,y
1
 cmpd _symll
 lbge L15
* Begin expression - 38
 ldb 0,u
 lbne L16
L17
L18
* Begin expression - 39
 ldb [-6,y]
 lbeq L19
 ldd -10,y
 cmpd #8
10
 lbge L19
* Begin expression - 40
 ldx -6,y
 ldb 0,x+
 stx -6,y
 stb 0,u+
* Begin expression - 40
 inc -9,y
 bne 1f
 inc -10,y
1
 lbra L18
L19
* Begin expression - 42
 ldd -10,y
 cmpd #7
 lbge L20
* Begin expression - 42
 clr 0,u
L20
* Begin expression - 43
 ldd -8,y
 subd #1
 std -8,y
 lbra L12
L16
* Begin expression - 45
 leau 8,u
 lbra L14
L15
* Begin expression - 47
 ldd -8,y
 cmpd #700
 lble L21
* Begin expression - 48
 ldd #-1
 lbra L12
L21
* Begin expression - 50
 inc _symll+1
 lbne L17
 inc _symll
 lbra L17
L13 equ 10
L12
 leas -4,y
 puls x,y,u,pc
 global _llu
_llu pshs u,y,x
 leay 4,s
* Auto 4 world
* Auto 6 keylist
 leas -L23,s
* Register 1 p
* Auto -6 m
* Auto -8 i
* Begin expression - 59
 ldd #0
 std -8,y
L24
* Begin expression - 60
 ldd -8,y
 lslb
 rola
 ldx 6,y
 ldx d,x
 cmpx #-1
 lbeq L25
* Begin expression - 61
 ldu 4,y
* Begin expression - 62
 ldd -8,y
 inc -7,y
 bne 1f
 inc -8,y
1
 lslb
 rola
 ldx 6,y
 ldx d,x
 stx -6,y
L26
* Begin expression - 64
 ldx -6,y
 ldb 0,x+
 stx -6,y
 leau 1,u
 cmpb -1,u
 lbne L27
 ldb -1,u
10
 lbne L26
L27
* Begin expression - 66
 ldb 0,-u
 cmpb #0
 lbne L28
 ldx -6,y
 ldb 0,-x
 stx -6,y
 cmpb #0
10
 lbne L28
* Begin expression - 66
 ldd -8,y
 subd #1
 std -8,y
 lbra L22
L28
 lbra L24
L25
* Begin expression - 68
 ldd #-1
 lbra L22
L23 equ 8
L22
 leas -4,y
 puls x,y,u,pc
 global _cement
_cement pshs u,y,x
 leay 4,s
* Auto 4 item
* Auto 6 table
 leas -L30,s
* Register 1 p
* Auto -6 j
* Auto -8 i
* Begin expression - 76
 ldx 4,y
 stx -6,y
* Begin expression - 77
 ldx 6,y
 stx -8,y
L31
* Begin expression - 78
 ldx -8,y
 ldd 0,x++
 stx -8,y
 cmpd #-1
 lbne L31
L32
* Begin expression - 79
 ldd #-1
 std [-8,y]
* Begin expression - 80
 ldx -8,y
 leax -4,x
 stx -8,y
* Begin expression - 81
 ldx [-8,y]
 leau 0,x
L33
* Begin expression - 82
 ldb 0,u+
 tstb
 lbne L33
L34
* Begin expression - 83
 tfr u,d
 ldx -8,y
 leax 2,x
 stx -8,y
 std 0,x
L35
* Begin expression - 84
 ldx -6,y
 ldb 0,x+
 stx -6,y
 stb 0,u+
 tstb
 lbne L35
L36
L30 equ 8
L29
 leas -4,y
 puls x,y,u,pc
 global _chisel
_chisel pshs u,y,x
 leay 4,s
* Auto 4 index
* Auto 6 table
 leas -L38,s
* Auto -6 t
* Auto -8 f
* Register 1 i
* Begin expression - 91
 ldd 4,y
 lslb
 rola
 ldx 6,y
 ldd d,x
 subd [6,y]
 std -6,y
* Begin expression - 92
 ldd 4,y
 addd #1
 lslb
 rola
 ldx 6,y
 ldd d,x
 subd [6,y]
 std -8,y
* Begin expression - 93
 ldx 6,y
 stx 0,s
 jsr _lost
 std 0,s
 ldd -8,y
 pshs d
 ldd -6,y
 pshs d
 ldd [6,y]
 pshs d
 jsr _bumpd
 leas 6,s
* Begin expression - 94
 ldu 6,y
L39
* Begin expression - 95
 leau 2,u
 ldd 0,u
 cmpd #-1
 lbeq L40
* Begin expression - 95
 ldd 4,y
 lslb
 rola
 ldx 6,y
 leax d,x
 leax 2,x
 stu 0,s
 cmpx 0,s
 lbgt L41
* Begin expression - 96
 ldd -8,y
 subd -6,y
 nega
 negb
 sbca #0
 addd 0,u
 std 0,u
L41
 lbra L39
L40
* Begin expression - 98
 tfr u,d
 subd 6,y
 asra
 rorb
 std 0,s
 ldd 4,y
 addd #1
 pshs d
 ldd 4,y
 pshs d
 ldx 6,y
 pshs x
 jsr _slide
 leas 6,s
L38 equ 8
L37
 leas -4,y
 puls x,y,u,pc
 global _lost
_lost pshs u,y,x
 leay 4,s
* Auto 4 a
 leas -L43,s
* Register 1 i
* Auto -6 p
* Begin expression - 106
 ldu 4,y
L44
* Begin expression - 107
 ldd 0,u++
 cmpd #-1
 lbne L44
L45
* Begin expression - 108
 leau -4,u
* Begin expression - 109
 ldx 0,u
 stx -6,y
L46
* Begin expression - 110
 ldx -6,y
 ldb 0,x+
 stx -6,y
 tstb
 lbne L46
L47
* Begin expression - 111
 ldx -6,y
 leax -1,x
 stx -6,y
 tfr x,d
 subd [4,y]
 lbra L42
L43 equ 6
L42
 leas -4,y
 puls x,y,u,pc
 global _island
_island pshs u,y,x
 leay 4,s
* Auto 4 ch
 leas -L49,s
* Begin expression - 116
 ldd 4,y
 cmpd #65
 blt 10f
 cmpd #90
 ble 13f
10
 ldd 4,y
 cmpd #97
 lblt L50
 cmpd #122
11
 lbgt L50
13
* Begin expression - 116
 ldd #1
 lbra L48
L50
* Begin expression - 117
 ldd 4,y
 cmpd #48
 lblt L51
 cmpd #57
10
 lbgt L51
* Begin expression - 117
 ldd #1
 lbra L48
L51
* Begin expression - 118
 ldd 4,y
 cmpd #95
 lbne L52
* Begin expression - 118
 ldd #1
 lbra L48
L52
* Begin expression - 119
 ldd 4,y
 cmpd #46
 lbne L53
* Begin expression - 119
 ldd #1
 lbra L48
L53
* Begin expression - 120
 ldd 4,y
 cmpd #36
 lbne L54
* Begin expression - 120
 ldd #1
 lbra L48
L54
* Begin expression - 121
 ldd 4,y
 cmpd #37
 lbne L55
* Begin expression - 121
 ldd #1
 lbra L48
L55
* Begin expression - 122
 ldd #0
 lbra L48
L49 equ 4
L48
 leas -4,y
 puls x,y,u,pc
 global _islet
_islet pshs u,y,x
 leay 4,s
* Auto 4 ch
 leas -L57,s
* Begin expression - 127
 ldd 4,y
 cmpd #65
 blt 10f
 cmpd #90
 ble 13f
10
 ldd 4,y
 cmpd #97
 lblt L58
 cmpd #122
11
 lbgt L58
13
* Begin expression - 127
 ldd #1
 lbra L56
L58
* Begin expression - 128
 ldd 4,y
 cmpd #95
 lbne L59
* Begin expression - 128
 ldd #1
 lbra L56
L59
* Begin expression - 129
 ldd 4,y
 cmpd #46
 lbne L60
* Begin expression - 129
 ldd #1
 lbra L56
L60
* Begin expression - 130
 ldd 4,y
 cmpd #36
 lbne L61
* Begin expression - 130
 ldd #1
 lbra L56
L61
* Begin expression - 131
 ldd 4,y
 cmpd #37
 lbne L62
* Begin expression - 131
 ldd #1
 lbra L56
L62
* Begin expression - 132
 ldd 4,y
 cmpd #48
 lblt L63
 cmpd #57
10
 lbgt L63
* Begin expression - 132
 ldd #0
 lbra L56
L63
* Begin expression - 133
 ldd 4,y
 cmpd #33
 lblt L64
 cmpd #47
10
 lbgt L64
* Begin expression - 133
 ldd #2
 lbra L56
L64
* Begin expression - 134
 ldd 4,y
 cmpd #58
 lblt L65
 cmpd #63
10
 lbgt L65
* Begin expression - 134
 ldd #2
 lbra L56
L65
* Begin expression - 135
 ldd 4,y
 cmpd #96
 beq 11f
 cmpd #64
10
 lbne L66
11
* Begin expression - 135
 ldd #2
 lbra L56
L66
* Begin expression - 136
 ldd 4,y
 cmpd #91
 lblt L67
 cmpd #95
10
 lbgt L67
* Begin expression - 136
 ldd #2
 lbra L56
L67
* Begin expression - 137
 ldd 4,y
 cmpd #123
 lblt L68
 cmpd #126
10
 lbgt L68
* Begin expression - 137
 ldd #2
 lbra L56
L68
* Begin expression - 138
 ldd #3
 lbra L56
L57 equ 4
L56
 leas -4,y
 puls x,y,u,pc
 global _slide
_slide pshs u,y,x
 leay 4,s
* Auto 4 table
* Auto 6 fmto
* Auto 8 tmfrom
* Auto 10 ltable
 leas -L70,s
* Register 1 f
* Auto -6 t
* Auto -8 c
* Begin expression - 146
 ldd 6,y
 cmpd 8,y
 bge 11f
 ldd 8,y
 cmpd 10,y
10
 lble L71
11
* Begin expression - 146
 ldd #-1
 lbra L69
L71
* Begin expression - 147
 ldd 6,y
 lslb
 rola
 ldx 4,y
 leax d,x
 stx -6,y
* Begin expression - 148
 ldd 8,y
 lslb
 rola
 ldx 4,y
 leau d,x
* Begin expression - 149
 ldd 8,y
 std -8,y
* Begin expression - 150
 ldd 10,y
 subd -8,y
 addd #1
 std -8,y
L72
* Begin expression - 151
 ldd -8,y
 lbeq L73
* Begin expression - 151
 ldd 0,u++
 ldx -6,y
 std 0,x++
 stx -6,y
L74
* Begin expression - 151
 tst -7,y
 bne 1f
 dec -8,y
1 dec -7,y
 lbra L72
L73
* Begin expression - 152
 ldd #0
 lbra L69
L70 equ 8
L69
 leas -4,y
 puls x,y,u,pc
 global _mixerup
_mixerup pshs u,y,x
 leay 4,s
* Auto 4 table
* Auto 6 texts
 leas -L76,s
* Register 1 p
* Begin expression - 158
 ldu 4,y
* Begin expression - 159
 ldd 6,y
 std 0,u++
* Begin expression - 160
 ldd #-1
 std 0,u
* Begin expression - 161
 ldu 6,y
* Begin expression - 162
 ldd #0
 std 0,u
L76 equ 4
L75
 leas -4,y
 puls x,y,u,pc
 global _bumpd
_bumpd pshs u,y,x
 leay 4,s
* Auto 4 table
* Auto 6 fmto
* Auto 8 tmfrom
* Auto 10 ltable
 leas -L78,s
* Register 1 f
* Auto -6 t
* Auto -8 c
* Begin expression - 170
 ldd 6,y
 cmpd 8,y
 bge 11f
 ldd 8,y
 cmpd 10,y
10
 lble L79
11
* Begin expression - 170
 ldd #-1
 lbra L77
L79
* Begin expression - 171
 ldd 6,y
 ldx 4,y
 leax d,x
 stx -6,y
* Begin expression - 172
 ldd 8,y
 ldx 4,y
 leau d,x
* Begin expression - 173
 ldd 10,y
 subd 8,y
 addd #1
 std -8,y
L80
* Begin expression - 174
 ldd -8,y
 lbeq L81
* Begin expression - 174
 ldb 0,u+
 ldx -6,y
 stb 0,x+
 stx -6,y
L82
* Begin expression - 174
 tst -7,y
 bne 1f
 dec -8,y
1 dec -7,y
 lbra L80
L81
* Begin expression - 175
 ldd #0
 lbra L77
L78 equ 8
L77
 leas -4,y
 puls x,y,u,pc
 global _alsort2
_alsort2 pshs u,y,x
 leay 4,s
* Auto 4 list
* Auto 6 vtable
 leas -L84,s
* Auto -5 change
* Register 1 next
* Auto -7 end
* Auto -9 i
* Auto -11 temp
* Auto -13 temp2
* Begin expression - 187
 ldu 4,y
L85
* Begin expression - 188
 ldd 0,u
 cmpd #-1
 lbeq L86
* Begin expression - 188
 leau 2,u
 lbra L85
L86
* Begin expression - 189
 ldx 4,y
 stu 0,s
 cmpx 0,s
 lbne L87
 lbra L83
L87
* Begin expression - 190
 leau -2,u
* Begin expression - 191
 ldx 4,y
 stu 0,s
 cmpx 0,s
 lbne L88
 lbra L83
L88
* Begin expression - 192
 ldb #1
 stb -5,y
* Begin expression - 193
 stu -7,y
L89
* Begin expression - 194
 ldb -5,y
 lbeq L90
* Begin expression - 195
 clr -5,y
* Begin expression - 196
 ldd #0
 std -9,y
* Begin expression - 197
 ldu 4,y
L91
* Begin expression - 197
 cmpu -7,y
 lbeq L92
* Begin expression - 198
 ldd 2,u
 std 0,s
 ldd 0,u
 pshs d
 jsr _alsrtx
 leas 2,s
 cmpd #0
 lbeq L94
* Begin expression - 199
 ldx 2,u
 stx -11,y
* Begin expression - 200
 ldd 0,u
 std 2,u
* Begin expression - 201
 ldd -11,y
 std 0,u
* Begin expression - 202
 ldb #1
 stb -5,y
* Begin expression - 203
 ldd -9,y
 lslb
 rola
 ldx 6,y
 ldd d,x
 std -13,y
* Begin expression - 204
 ldd -9,y
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -9,y
 addd #1
 lslb
 rola
 stx 0,s
 ldx 6,y
 ldd d,x
 std [0,s]
* Begin expression - 205
 ldd -9,y
 addd #1
 lslb
 rola
 ldx 6,y
 leax d,x
 ldd -13,y
 std 0,x
L94
* Begin expression - 207
 inc -8,y
 bne 1f
 inc -9,y
1
L93
* Begin expression - 208
 leau 2,u
 lbra L91
L92
 lbra L89
L90
L84 equ 13
L83
 leas -4,y
 puls x,y,u,pc
 global _alsrtx
_alsrtx pshs u,y,x
 leay 4,s
* Auto 4 next
* Auto 6 one
 leas -L96,s
* Register 1 next2
* Auto -6 up
* Begin expression - 216
 ldu 4,y
* Begin expression - 217
 ldx 6,y
 stx -6,y
L97
* Begin expression - 218
 ldb 0,u
 lbeq L98
 ldb [-6,y]
10
 lbeq L98
* Begin expression - 219
 ldb [-6,y]
 cmpb 0,u
 lble L99
* Begin expression - 219
 ldd #0
 lbra L95
L99
* Begin expression - 220
 ldb [-6,y]
 cmpb 0,u
 lbge L100
* Begin expression - 220
 ldd #1
 lbra L95
L100
* Begin expression - 221
 leau 1,u
* Begin expression - 221
 ldx -6,y
 leax 1,x
 stx -6,y
 lbra L97
L98
* Begin expression - 223
 ldb [-6,y]
 cmpb 0,u
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbne L101
* Begin expression - 223
 ldd #0
 lbra L95
L101
* Begin expression - 224
 ldb 0,u
 lbeq L102
* Begin expression - 224
 ldd #1
 lbra L95
L102
* Begin expression - 225
 ldd #0
 lbra L95
L96 equ 6
L95
 leas -4,y
 puls x,y,u,pc
 global _basout
_basout pshs u,y,x
 leay 4,s
* Auto 4 n
* Auto 6 base
 leas -L104,s
* Auto -6 i
* Auto -8 k
* Begin expression - 233
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr umod
 std -6,y
* Begin expression - 234
 ldd 4,y
 std 0,s
 ldd 6,y
 jsr udiv
 std -8,y
 lbeq L105
* Begin expression - 235
 ldd 6,y
 std 0,s
 ldd -8,y
 pshs d
 jsr _basout
 leas 2,s
L105
* Begin expression - 236
 ldd -6,y
 addd #48
 std -6,y
* Begin expression - 237
 cmpd #58
 bge 10f
 bra 11f
10
 ldd -6,y
 addd #97
 subd #58
11
 std 0,s
 jsr _putchar
L104 equ 8
L103
 leas -4,y
 puls x,y,u,pc
 global _cats
_cats pshs u,y,x
 leay 4,s
* Auto 4 st1
* Auto 6 st2
 leas -L107,s
* Register 1 p
* Auto -6 k
* Begin expression - 244
 ldu 4,y
L108
* Begin expression - 245
 ldb 0,u
 lbeq L109
* Begin expression - 245
 leau 1,u
 lbra L108
L109
* Begin expression - 246
 ldx 6,y
 stx -6,y
L110
* Begin expression - 247
 ldx -6,y
 ldb 0,x+
 stx -6,y
 stb 0,u+
 tstb
 lbne L110
L111
L107 equ 6
L106
 leas -4,y
 puls x,y,u,pc
 global _comstr
_comstr pshs u,y,x
 leay 4,s
* Auto 4 s1
* Auto 6 s2
 leas -L113,s
* Register 1 p
* Auto -6 m
* Begin expression - 254
 ldu 4,y
* Begin expression - 255
 ldx 6,y
 stx -6,y
L114
* Begin expression - 257
 ldx -6,y
 ldb 0,x+
 stx -6,y
 leau 1,u
 cmpb -1,u
 lbne L115
 ldb -1,u
10
 lbne L114
L115
* Begin expression - 258
 ldb 0,-u
 cmpb #0
 lbne L116
 ldx -6,y
 ldb 0,-x
 stx -6,y
 cmpb #0
10
 lbne L116
* Begin expression - 258
 ldd #1
 lbra L112
L116
* Begin expression - 259
 ldd #0
 lbra L112
L113 equ 6
L112
 leas -4,y
 puls x,y,u,pc
 global _copystr
_copystr pshs u,y,x
 leay 4,s
* Auto 4 st1
* Auto 6 st2
 leas -L118,s
* Register 1 p
* Auto -6 k
* Begin expression - 266
 ldu 4,y
* Begin expression - 266
 ldx 6,y
 stx -6,y
L119
* Begin expression - 267
 ldx -6,y
 ldb 0,x+
 stx -6,y
 stb 0,u+
 tstb
 lbne L119
L120
L118 equ 6
L117
 leas -4,y
 puls x,y,u,pc
 global _eatspace
_eatspace pshs u,y,x
 leay 4,s
* Auto 4 p
 leas -L122,s
L123
* Begin expression - 272
 ldx [4,y]
 ldb 0,x
 cmpb #32
 beq 11f
 ldx [4,y]
 ldb 0,x
 cmpb #9
10
 lbne L124
11
* Begin expression - 272
 ldx [4,y]
 leax 1,x
 stx [4,y]
 lbra L123
L124
L122 equ 4
L121
 leas -4,y
 puls x,y,u,pc
 global _jnum
_jnum pshs u,y,x
 leay 4,s
* Auto 4 n
* Auto 6 base
* Auto 8 nchar
* Auto 10 jus
 leas -L126,s
* Auto -6 i
* Begin expression - 278
 ldd 6,y
 std 0,s
 ldd 4,y
 pshs d
 jsr _digcnt
 leas 2,s
 nega
 negb
 sbca #0
 addd 8,y
 std -6,y
* Begin expression - 279
 ldd 10,y
 cmpd #1
 lbne L127
* Begin expression - 280
 ldd 6,y
 std 0,s
 ldd 4,y
 pshs d
 jsr _basout
 leas 2,s
L128
* Begin expression - 281
 ldd -6,y
 lble L129
* Begin expression - 281
 ldb #32
 sex
 std 0,s
 jsr _putchar
L130
* Begin expression - 281
 tst -5,y
 bne 1f
 dec -6,y
1 dec -5,y
 lbra L128
L129
 lbra L131
L127
L132
* Begin expression - 284
 ldd -6,y
 lble L133
* Begin expression - 284
 ldb #32
 sex
 std 0,s
 jsr _putchar
L134
* Begin expression - 284
 tst -5,y
 bne 1f
 dec -6,y
1 dec -5,y
 lbra L132
L133
* Begin expression - 285
 ldd 6,y
 std 0,s
 ldd 4,y
 pshs d
 jsr _basout
 leas 2,s
L131
L126 equ 6
L125
 leas -4,y
 puls x,y,u,pc
 global _lfs
_lfs pshs u,y,x
 leay 4,s
* Auto 4 target
* Auto 6 string
 leas -L136,s
* Register 1 t
* Auto -6 p
* Auto -8 s
* Begin expression - 293
 ldu 6,y
L137
* Begin expression - 294
 ldd #1
 lbeq L138
* Begin expression - 295
 stu -8,y
* Begin expression - 296
 ldx 4,y
 stx -6,y
L139
* Begin expression - 297
 ldb [-6,y]
 cmpb [-8,y]
 beq 10f
 ldb [-8,y]
 cmpb #13
 lbeq L140
 ldb [-8,y]
11
 lbeq L140
L141
* Begin expression - 297
 ldx -8,y
 ldb 0,x+
 stx -8,y
 lbra L139
L140
* Begin expression - 298
 ldb [-8,y]
 beq 11f
 ldb [-8,y]
 cmpb #13
10
 lbne L142
11
* Begin expression - 298
 ldd #0
 lbra L135
L142
* Begin expression - 299
 ldx -8,y
 leau 1,x
L143
* Begin expression - 300
 ldx -6,y
 ldb 0,x+
 stx -6,y
 ldx -8,y
 leax 1,x
 stx -8,y
 cmpb -1,x
 lbeq L143
L144
* Begin expression - 301
 ldx -6,y
 ldb 0,-x
 stx -6,y
 cmpb #0
 lbne L145
* Begin expression - 301
 ldd #1
 lbra L135
L145
 lbra L137
L138
L136 equ 8
L135
 leas -4,y
 puls x,y,u,pc
 global _sscan
_sscan pshs u,y,x
 leay 4,s
* Auto 4 world
* Auto 6 string
 leas -L147,s
* Register 1 p
* Auto -6 c
* Auto -8 i
* Begin expression - 309
 ldu 4,y
* Begin expression - 310
 clr 0,u
* Begin expression - 311
 ldx 6,y
 stx -6,y
L148
* Begin expression - 313
 ldx [-6,y]
 ldb 0,x
 sex
 std 0,s
 jsr _island
 cmpd #1
 lbeq L149
 ldx [-6,y]
 ldb 0,x
 cmpb #13
 lbeq L149
 ldx [-6,y]
 ldb 0,x
 lbeq L149
 ldx [-6,y]
 ldb 0,x
 cmpb #59
10
 lbeq L149
* Begin expression - 313
 ldx [-6,y]
 leax 1,x
 stx [-6,y]
 lbra L148
L149
* Begin expression - 315
 ldx [-6,y]
 ldb 0,x
 cmpb #13
 lbne L150
* Begin expression - 315
 ldd #-1
 lbra L146
L150
* Begin expression - 316
 ldx [-6,y]
 ldb 0,x
 lbne L151
* Begin expression - 316
 ldd #-2
 lbra L146
L151
* Begin expression - 317
 ldx [-6,y]
 ldb 0,x
 cmpb #59
 lbne L152
* Begin expression - 317
 ldx [-6,y]
 ldb 0,x
 lbra L146
L152
* Begin expression - 318
 ldx [-6,y]
 leax 1,x
 stx [-6,y]
 ldb -1,x
 stb 0,u+
* Begin expression - 319
 ldd #1
 std -8,y
L153
* Begin expression - 320
 ldx [-6,y]
 leax 1,x
 stx [-6,y]
 ldb -1,x
 stb 0,u+
 sex
 std 0,s
 jsr _island
 cmpd #0
 lbeq L154
* Begin expression - 321
 ldd -8,y
 addd #1
 std -8,y
 cmpd #20
 lble L155
* Begin expression - 321
 leau -1,u
L155
 lbra L153
L154
* Begin expression - 322
 ldx [-6,y]
 leax -1,x
 stx [-6,y]
* Begin expression - 323
 ldb 0,-u
 cmpb #0
 lbne L156
* Begin expression - 323
 ldd #-2
 lbra L146
L156
* Begin expression - 324
 ldb 0,u
 cmpb #13
 lbne L157
* Begin expression - 325
 clr 0,u
* Begin expression - 326
 ldd #-1
 lbra L146
 lbra L158
L157
* Begin expression - 328
 ldb 0,u
 sex
 std -8,y
* Begin expression - 328
 clr 0,u
L158
* Begin expression - 329
 ldd -8,y
 lbra L146
L147 equ 8
L146
 leas -4,y
 puls x,y,u,pc
 global _basin
_basin pshs u,y,x
 leay 4,s
* Auto 4 string
* Auto 6 base
 leas -L160,s
* Auto -25 s
* Auto -27 number
* Auto -29 p
* Auto -31 i
* Auto -33 exponent
* Begin expression - 340
 ldd #0
 std -31,y
L161
* Begin expression - 340
 ldd -31,y
 leax -25,y
 leax d,x
 stx 0,s
 ldx 4,y
 ldb d,x
 stb [0,s]
 lbeq L162
L163
* Begin expression - 340
 inc -30,y
 lbne L161
 inc -31,y
 lbra L161
L162
* Begin expression - 341
 ldd #0
 std -29,y
L164
* Begin expression - 341
 ldd -29,y
 leax -25,y
 ldb d,x
 lbeq L165
L166
* Begin expression - 341
 inc -28,y
 lbne L164
 inc -29,y
 lbra L164
L165
* Begin expression - 342
 ldd #0
 std -31,y
L167
* Begin expression - 342
 ldd -31,y
 leax -25,y
 ldb d,x
 lbeq L168
* Begin expression - 343
 ldd -31,y
 leax -25,y
 ldb d,x
 cmpb #111
 beq 11f
 ldd -31,y
 leax -25,y
 ldb d,x
 cmpb #79
10
 lbne L170
11
* Begin expression - 343
 ldd -31,y
 leax -25,y
 leax d,x
 ldb #48
 stb 0,x
L170
* Begin expression - 344
 ldd -31,y
 leax -25,y
 ldb d,x
 cmpb #65
 lblt L171
 ldd -31,y
 leax -25,y
 ldb d,x
 cmpb #90
10
 lbgt L171
* Begin expression - 344
 ldd -31,y
 leax -25,y
 leax d,x
 ldd #32
 addb 0,x
 stb 0,x
L171
* Begin expression - 345
 ldd -31,y
 leax -25,y
 ldb d,x
 cmpb #57
 lble L172
* Begin expression - 346
 ldd -31,y
 leax -25,y
 leax d,x
 stx 0,s
 leax -25,y
 leax d,x
 ldb #97
 subb #58
 negb
 addb 0,x
 stb [0,s]
L172
L169
* Begin expression - 347
 inc -30,y
 lbne L167
 inc -31,y
 lbra L167
L168
* Begin expression - 348
 ldd #0
 std -27,y
* Begin expression - 348
 ldd #1
 std -33,y
* Begin expression - 348
 ldd -29,y
 subd #1
 std -29,y
L173
* Begin expression - 349
 ldd -29,y
 cmpd #-1
 lbeq L174
* Begin expression - 350
 tst -28,y
 bne 1f
 dec -29,y
1 dec -28,y
 leax -25,y
 ldb d,x
 sex
 subd #48
 std 0,s
 ldd -33,y
 jsr imul
 addd -27,y
 std -27,y
* Begin expression - 351
 ldd -33,y
 std 0,s
 ldd 6,y
 jsr imul
 std -33,y
 lbra L173
L174
* Begin expression - 352
 ldd -27,y
 lbra L159
L160 equ 33
L159
 leas -4,y
 puls x,y,u,pc
 global _digcnt
_digcnt pshs u,y,x
 leay 4,s
* Auto 4 n
* Auto 6 p
 leas -L176,s
* Auto -6 i
* Begin expression - 358
 ldd #0
 std -6,y
L177
* Begin expression - 358
 ldd 4,y
 lbeq L178
* Begin expression - 358
 std 0,s
 ldd 6,y
 jsr udiv
 std 4,y
L179
* Begin expression - 358
 inc -5,y
 lbne L177
 inc -6,y
 lbra L177
L178
* Begin expression - 359
 ldd -6,y
 lbne L180
* Begin expression - 359
 inc -5,y
 bne 1f
 inc -6,y
1
L180
* Begin expression - 360
 ldd -6,y
 lbra L175
L176 equ 6
L175
 leas -4,y
 puls x,y,u,pc
 end
 name data09.c
 text
 data
L1 fcb 49,35,52,98,37,54,0
L2 fcb 101,113,117,0
L3 fcb 101,110,100,0
L4 fcb 100,98,0
L5 fcb 100,115,0
L6 fcb 100,119,0
L7 fcb 111,114,103,0
L8 fcb 101,118,97,108,0
L9 fcb 101,110,116,114,121,0
L10 fcb 114,101,112,101,97,116,0
L11 fcb 100,117,112,0
L12 fcb 101,120,116,101,114,110,97,108,0
L13 fcb 100,101,102,109,97,99,114,111,0
L14 fcb 101,110,100,109,97,99,114,111,0
L15 fcb 101,110,100,100,117,112,0
L16 fcb 102,99,98,0
L17 fcb 102,100,98,0
L18 fcb 102,99,99,0
L19 fcb 114,109,98,0
L20 fcb 105,102,0
L21 fcb 101,108,115,101,0
L22 fcb 101,110,100,105,102,0
L23 fcb 98,97,115,101,0
L24 fcb 108,105,115,116,111,102,102,0
L25 fcb 108,105,115,116,111,110,0
L26 fcb 105,110,99,108,117,100,101,0
L27 fcb 109,97,99,111,102,102,0
L28 fcb 109,97,99,111,110,0
L29 fcb 103,108,111,98,97,108,0
L30 fcb 108,111,97,100,109,111,100,0
L31 fcb 109,101,115,115,97,103,101,0
L32 fcb 46,98,121,116,101,0
L33 fcb 46,119,111,114,100,0
L34 fcb 46,97,115,99,105,105,0
L35 fcb 46,97,115,99,105,105,122,0
L36 fcb 46,97,115,99,105,122,0
L37 fcb 114,115,0
L38 fcb 98,121,116,101,115,111,110,0
L39 fcb 98,121,116,101,115,111,102,102,0
L40 fcb 46,103,108,111,98,97,108,0
L41 fcb 46,103,108,111,98,108,0
L42 fcb 46,101,110,100,0
L43 fcb 46,101,118,101,110,0
L44 fcb 46,111,100,100,0
L45 fcb 46,112,97,103,101,0
L46 fcb 112,115,101,99,116,0
L47 fcb 46,112,115,101,99,116,0
L48 fcb 46,97,98,115,0
L49 fcb 46,116,101,120,116,0
L50 fcb 46,100,97,116,97,0
L51 fcb 46,98,115,115,0
L52 fcb 46,115,116,97,99,107,0
 global _soptab
_soptab fdb L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15,L16
 fdb L17,L18,L19,L20,L21,L22,L23,L24,L25,L26,L27,L28,L29,L30,L31,L32
 fdb L33,L34,L35,L36,L37,L38,L39,L40,L41,L42,L43,L44,L45,L46,L47,L48
 fdb L49,L50,L51,L52,65535
L53 fcb 50,51,53,56,100,50,0
L54 fcb 97,98,120,0
L55 fcb 97,100,99,97,0
L56 fcb 97,100,99,98,0
L57 fcb 97,100,100,97,0
L58 fcb 97,100,100,98,0
L59 fcb 97,100,100,100,0
L60 fcb 97,110,100,97,0
L61 fcb 97,110,100,98,0
L62 fcb 97,110,100,99,99,0
L63 fcb 97,115,108,0
L64 fcb 97,115,108,97,0
L65 fcb 97,115,108,98,0
L66 fcb 97,115,114,0
L67 fcb 97,115,114,97,0
L68 fcb 97,115,114,98,0
L69 fcb 98,99,99,0
L70 fcb 98,99,115,0
L71 fcb 98,101,113,0
L72 fcb 98,103,101,0
L73 fcb 98,103,116,0
L74 fcb 98,104,105,0
L75 fcb 98,104,115,0
L76 fcb 98,105,116,97,0
L77 fcb 98,105,116,98,0
L78 fcb 98,108,101,0
L79 fcb 98,108,111,0
L80 fcb 98,108,115,0
L81 fcb 98,108,116,0
L82 fcb 98,109,105,0
L83 fcb 98,110,101,0
L84 fcb 98,112,108,0
L85 fcb 98,114,97,0
L86 fcb 98,114,110,0
L87 fcb 98,115,114,0
L88 fcb 98,118,99,0
L89 fcb 98,118,115,0
L90 fcb 99,108,114,0
L91 fcb 99,108,114,97,0
L92 fcb 99,108,114,98,0
L93 fcb 99,109,112,97,0
L94 fcb 99,109,112,98,0
L95 fcb 99,109,112,100,0
L96 fcb 99,109,112,115,0
L97 fcb 99,109,112,117,0
L98 fcb 99,109,112,120,0
L99 fcb 99,109,112,121,0
L100 fcb 99,111,109,0
L101 fcb 99,111,109,97,0
L102 fcb 99,111,109,98,0
L103 fcb 99,119,97,105,0
L104 fcb 100,97,97,0
L105 fcb 100,101,99,0
L106 fcb 100,101,99,97,0
L107 fcb 100,101,99,98,0
L108 fcb 101,111,114,97,0
L109 fcb 101,111,114,98,0
L110 fcb 101,120,103,0
L111 fcb 105,110,99,0
L112 fcb 105,110,99,97,0
L113 fcb 105,110,99,98,0
L114 fcb 106,109,112,0
L115 fcb 106,115,114,0
L116 fcb 108,98,99,99,0
L117 fcb 108,98,99,115,0
L118 fcb 108,98,101,113,0
L119 fcb 108,98,103,101,0
L120 fcb 108,98,103,116,0
L121 fcb 108,98,104,105,0
L122 fcb 108,98,104,115,0
L123 fcb 108,98,108,101,0
L124 fcb 108,98,108,111,0
L125 fcb 108,98,108,115,0
L126 fcb 108,98,108,116,0
L127 fcb 108,98,109,105,0
L128 fcb 108,98,110,101,0
L129 fcb 108,98,112,108,0
L130 fcb 108,98,114,97,0
L131 fcb 108,98,114,110,0
L132 fcb 108,98,115,114,0
L133 fcb 108,98,118,99,0
L134 fcb 108,98,118,115,0
L135 fcb 108,100,97,0
L136 fcb 108,100,97,97,0
L137 fcb 108,100,98,0
L138 fcb 108,100,97,98,0
L139 fcb 108,100,100,0
L140 fcb 108,100,115,0
L141 fcb 108,100,117,0
L142 fcb 108,100,120,0
L143 fcb 108,100,121,0
L144 fcb 108,101,97,115,0
L145 fcb 108,101,97,117,0
L146 fcb 108,101,97,120,0
L147 fcb 108,101,97,121,0
L148 fcb 108,115,108,0
L149 fcb 108,115,108,97,0
L150 fcb 108,115,108,98,0
L151 fcb 108,115,114,0
L152 fcb 108,115,114,97,0
L153 fcb 108,115,114,98,0
L154 fcb 109,117,108,0
L155 fcb 110,101,103,0
L156 fcb 110,101,103,97,0
L157 fcb 110,101,103,98,0
L158 fcb 110,111,112,0
L159 fcb 111,114,97,0
L160 fcb 111,114,98,0
L161 fcb 111,114,99,99,0
L162 fcb 112,115,104,115,0
L163 fcb 112,115,104,117,0
L164 fcb 112,117,108,115,0
L165 fcb 112,117,108,117,0
L166 fcb 114,111,108,0
L167 fcb 114,111,108,97,0
L168 fcb 114,111,108,98,0
L169 fcb 114,111,114,0
L170 fcb 114,111,114,97,0
L171 fcb 114,111,114,98,0
L172 fcb 114,116,105,0
L173 fcb 114,116,115,0
L174 fcb 115,98,99,97,0
L175 fcb 115,98,99,98,0
L176 fcb 115,101,120,0
L177 fcb 115,116,97,0
L178 fcb 115,116,97,97,0
L179 fcb 115,116,98,0
L180 fcb 115,116,97,98,0
L181 fcb 115,116,100,0
L182 fcb 115,116,115,0
L183 fcb 115,116,117,0
L184 fcb 115,116,120,0
L185 fcb 115,116,121,0
L186 fcb 115,117,98,97,0
L187 fcb 115,117,98,98,0
L188 fcb 115,117,98,100,0
L189 fcb 115,119,105,0
L190 fcb 115,119,105,50,0
L191 fcb 115,119,105,51,0
L192 fcb 115,121,110,99,0
L193 fcb 116,102,114,0
L194 fcb 116,115,116,0
L195 fcb 116,115,116,97,0
L196 fcb 116,115,116,98,0
 global _mot
_mot fdb L53,L54,L55,L56,L57,L58,L59,L60,L61,L62,L63,L64,L65,L66,L67,L68
 fdb L69,L70,L71,L72,L73,L74,L75,L76,L77,L78,L79,L80,L81,L82,L83,L84
 fdb L85,L86,L87,L88,L89,L90,L91,L92,L93,L94,L95,L96,L97,L98,L99,L100
 fdb L101,L102,L103,L104,L105,L106,L107,L108,L109,L110,L111,L112,L113,L114,L115,L116
 fdb L117,L118,L119,L120,L121,L122,L123,L124,L125,L126,L127,L128,L129,L130,L131,L132
 fdb L133,L134,L135,L136,L137,L138,L139,L140,L141,L142,L143,L144,L145,L146,L147,L148
 fdb L149,L150,L151,L152,L153,L154,L155,L156,L157,L158,L159,L160,L161,L162,L163,L164
 fdb L165,L166,L167,L168,L169,L170,L171,L172,L173,L174,L175,L176,L177,L178,L179,L180
 fdb L181,L182,L183,L184,L185,L186,L187,L188,L189,L190,L191,L192,L193,L194,L195,L196
 fdb 65535
L197 fcb 49,100,51,0
L198 fcb 99,109,112,100,0
L199 fcb 99,109,112,121,0
L200 fcb 108,98,99,99,0
L201 fcb 108,98,99,115,0
L202 fcb 108,98,101,113,0
L203 fcb 108,98,103,101,0
L204 fcb 108,98,103,116,0
L205 fcb 108,98,104,105,0
L206 fcb 108,98,104,115,0
L207 fcb 108,98,108,101,0
L208 fcb 108,98,108,111,0
L209 fcb 108,98,108,115,0
L210 fcb 108,98,108,116,0
L211 fcb 108,98,109,105,0
L212 fcb 108,98,110,101,0
L213 fcb 108,98,112,108,0
L214 fcb 108,98,114,110,0
L215 fcb 108,98,118,99,0
L216 fcb 108,98,118,115,0
L217 fcb 108,100,115,0
L218 fcb 108,100,121,0
L219 fcb 115,116,115,0
L220 fcb 115,116,121,0
L221 fcb 115,119,105,50,0
 global _mot10
_mot10 fdb L197,L198,L199,L200,L201,L202,L203,L204,L205,L206,L207,L208,L209,L210,L211,L212
 fdb L213,L214,L215,L216,L217,L218,L219,L220,L221,65535
L222 fcb 39,50,99,50,107,0
L223 fcb 99,109,112,115,0
L224 fcb 99,109,112,117,0
L225 fcb 115,119,105,51,0
 global _mot11
_mot11 fdb L222,L223,L224,L225,65535
L226 fcb 35,50,51,102,57,0
L227 fcb 112,115,104,97,0
L228 fcb 112,115,104,98,0
L229 fcb 112,117,108,97,0
L230 fcb 112,117,108,98,0
L231 fcb 112,115,104,120,0
L232 fcb 112,117,108,120,0
L233 fcb 105,110,120,0
L234 fcb 100,101,120,0
L235 fcb 105,110,115,0
L236 fcb 100,101,115,0
L237 fcb 97,115,108,100,0
L238 fcb 97,115,114,100,0
L239 fcb 99,108,114,100,0
L240 fcb 99,111,109,100,0
L241 fcb 100,101,99,100,0
L242 fcb 108,115,108,100,0
L243 fcb 108,115,114,100,0
L244 fcb 112,115,104,100,0
L245 fcb 112,117,108,100,0
L246 fcb 114,111,114,100,0
L247 fcb 114,111,108,100,0
L248 fcb 116,115,116,100,0
L249 fcb 107,101,114,110,101,108,0
L250 fcb 117,115,101,114,0
L251 fcb 112,115,104,109,0
L252 fcb 112,117,108,109,0
L253 fcb 105,110,99,100,0
L254 fcb 110,101,103,100,0
L255 fcb 98,122,99,0
L256 fcb 98,122,115,0
L257 fcb 98,110,99,0
L258 fcb 98,110,115,0
 global _spmot
_spmot fdb L226,L227,L228,L229,L230,L231,L232,L233,L234,L235,L236,L237,L238,L239,L240,L241
 fdb L242,L243,L244,L245,L246,L247,L248,L249,L250,L251,L252,L253,L254,L255,L256,L257
 fdb L258,65535
 global _spmots
_spmots fcb 0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3
 fcb 2,2,2,2,2,2,4,3,5,5,5,3,5,1,1,1
 fcb 1,0
 global _spmotd
_spmotd fcb 0,0,0,0,0,0,52,2,0,0,0,0,52,4,0,0
 fcb 0,0,53,2,0,0,0,0,53,4,0,0,0,0,52,16
 fcb 0,0,0,0,53,16,0,0,0,0,48,1,0,0,0,0
 fcb 48,31,0,0,0,0,50,97,0,0,0,0,50,127,0,0
 fcb 0,0,88,73,0,0,0,0,71,86,0,0,0,0,79,95
 fcb 0,0,0,0,83,67,0,0,0,0,131,0,1,0,0,0
 fcb 88,73,0,0,0,0,68,86,0,0,0,0,52,6,0,0
 fcb 0,0,53,6,0,0,0,0,86,70,0,0,0,0,73,89
 fcb 0,0,0,0,16,131,0,0,0,0,127,228,188,0,0,0
 fcb 26,1,121,228,188,0,121,228,188,52,1,0,53,1,121,228
 fcb 118,0,195,0,1,0,0,0,83,67,195,0,1,0,38,0
 fcb 0,0,0,0,39,0,0,0,0,0,42,0,0,0,0,0
 fcb 43,0,0,0,0,0,0
 global _mvt
_mvt fcb 1,1,1,1,1,1,1,1,1,1,58,1,137,153,169,185
 fcb 1,1,201,217,233,249,1,1,139,155,171,187,1,1,203,219
 fcb 235,251,1,1,195,211,227,243,1,1,132,148,164,180,1,1
 fcb 196,212,228,244,1,1,28,1,1,1,1,1,1,8,104,120
 fcb 1,1,1,1,1,1,72,1,1,1,1,1,88,1,1,7
 fcb 103,119,1,1,1,1,1,1,71,1,1,1,1,1,87,1
 fcb 1,1,1,1,1,36,1,1,1,1,1,37,1,1,1,1
 fcb 1,39,1,1,1,1,1,44,1,1,1,1,1,46,1,1
 fcb 1,1,1,34,1,1,1,1,1,36,133,149,165,181,1,1
 fcb 197,213,229,245,1,1,1,1,1,1,1,47,1,1,1,1
 fcb 1,37,1,1,1,1,1,35,1,1,1,1,1,45,1,1
 fcb 1,1,1,43,1,1,1,1,1,38,1,1,1,1,1,42
 fcb 1,1,1,1,1,32,1,1,1,1,1,33,1,1,1,1
 fcb 1,141,1,1,1,1,1,40,1,1,1,1,1,41,1,15
 fcb 111,127,1,1,1,1,1,1,79,1,1,1,1,1,95,1
 fcb 129,145,161,177,1,1,193,209,225,241,1,1,131,147,163,179
 fcb 1,1,140,156,172,188,1,1,131,147,163,179,1,1,140,156
 fcb 172,188,1,1,140,156,172,188,1,1,1,3,99,115,1,1
 fcb 1,1,1,1,67,1,1,1,1,1,83,1,1,1,1,1
 fcb 60,1,1,1,1,1,25,1,1,10,106,122,1,1,1,1
 fcb 1,1,74,1,1,1,1,1,90,1,136,152,168,184,1,1
 fcb 200,216,232,248,1,1,1,1,1,1,30,1,1,12,108,124
 fcb 1,1,1,1,1,1,76,1,1,1,1,1,92,1,1,14
 fcb 110,126,1,1,1,157,173,189,1,1,1,1,1,1,1,36
 fcb 1,1,1,1,1,37,1,1,1,1,1,39,1,1,1,1
 fcb 1,44,1,1,1,1,1,46,1,1,1,1,1,34,1,1
 fcb 1,1,1,36,1,1,1,1,1,47,1,1,1,1,1,37
 fcb 1,1,1,1,1,35,1,1,1,1,1,45,1,1,1,1
 fcb 1,43,1,1,1,1,1,38,1,1,1,1,1,42,1,1
 fcb 1,1,1,22,1,1,1,1,1,33,1,1,1,1,1,23
 fcb 1,1,1,1,1,40,1,1,1,1,1,41,134,150,166,182
 fcb 1,1,134,150,166,182,1,1,198,214,230,246,1,1,198,214
 fcb 230,246,1,1,204,220,236,252,1,1,206,222,238,254,1,1
 fcb 206,222,238,254,1,1,142,158,174,190,1,1,142,158,174,190
 fcb 1,1,1,1,50,1,1,1,1,1,51,1,1,1,1,1
 fcb 48,1,1,1,1,1,49,1,1,1,1,8,104,120,1,1
 fcb 1,1,1,1,72,1,1,1,1,1,88,1,1,4,100,116
 fcb 1,1,1,1,1,1,68,1,1,1,1,1,84,1,1,1
 fcb 1,1,61,1,1,0,96,112,1,1,1,1,1,1,64,1
 fcb 1,1,1,1,80,1,1,1,1,1,18,1,138,154,170,186
 fcb 1,1,202,218,234,250,1,1,26,1,1,1,1,1,1,1
 fcb 1,1,52,1,1,1,1,1,54,1,1,1,1,1,53,1
 fcb 1,1,1,1,55,1,1,9,105,121,1,1,1,1,1,1
 fcb 73,1,1,1,1,1,89,1,1,6,102,118,1,1,1,1
 fcb 1,1,70,1,1,1,1,1,86,1,1,1,1,1,59,1
 fcb 1,1,1,1,57,1,130,146,162,178,1,1,194,210,226,242
 fcb 1,1,1,1,1,1,29,1,135,151,167,183,1,1,135,151
 fcb 167,183,1,1,199,215,231,247,1,1,199,215,231,247,1,1
 fcb 205,221,237,253,1,1,207,223,239,255,1,1,207,223,239,255
 fcb 1,1,143,159,175,191,1,1,143,159,175,191,1,1,128,144
 fcb 160,176,1,1,192,208,224,240,1,1,131,147,163,179,1,1
 fcb 1,1,1,1,63,1,1,1,1,1,63,1,1,1,1,1
 fcb 63,1,1,1,1,1,19,1,1,1,1,1,31,1,1,13
 fcb 109,125,1,1,1,1,1,1,77,1,1,1,1,1,93,1
 global _mlt
_mlt fcb 2,3,3,2,2,3,2,2,2,2,2,3,2,2,2,2
 fcb 0,0,1,1,3,3,3,3,3,1,2,3,2,1,2,2
 fcb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 fcb 2,2,2,2,2,2,2,2,3,1,1,1,2,1,3,1
 fcb 1,3,3,1,1,3,1,1,1,1,1,3,1,1,3,1
 fcb 1,3,3,1,1,3,1,1,1,1,1,3,1,1,3,1
 fcb 2,3,3,2,2,3,2,2,2,2,2,3,2,2,2,2
 fcb 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 fcb 2,2,2,3,2,2,2,3,2,2,2,2,3,2,3,3
 fcb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 fcb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 fcb 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 fcb 2,2,2,3,2,2,2,3,2,2,2,2,3,3,3,3
 fcb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 fcb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
 fcb 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
 global _lmlt10
_lmlt10 fcb 0,0,4,2,0,0,0,0,4,3,3,4,4,3,3,4
 global _lmlt11
_lmlt11 fcb 0,0,0,2,0,0,0,0,4,3,3,4,0,0,0,0
 end
