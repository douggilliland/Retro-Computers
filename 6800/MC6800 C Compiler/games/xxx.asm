 name getchar.c
 text
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
 leas -L2,s
* Begin expression - 49
 jsr _flush
* Begin expression - 50
 ldx #__ibuf
 stx __ipos
* Begin expression - 51
 ldd #512
 std 0,s
 ldx #__ibuf
 pshs x
 ldd _fin
 pshs d
 jsr _read
 leas 4,s
 std __ibytes
 lbgt L3
* Begin expression - 52
 ldd #65535
 lbra L1
L3
* Begin expression - 53
 ldd __ibytes
 subd #1
 std __ibytes
* Begin expression - 54
 ldx __ipos
 ldb 0,x+
 stx __ipos
 sex
 clra
 lbra L1
L2 equ 4
L1
 leas -4,y
 puls x,y,u,pc
 global _getchar
_getchar pshs u,y,x
 leay 4,s
 leas -L5,s
* Begin expression - 59
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
 lbra L4
L5 equ 4
L4
 leas -4,y
 puls x,y,u,pc
 global _ungetcha
_ungetcha pshs u,y,x
 leay 4,s
* Auto 4 c
 leas -L7,s
* Begin expression - 64
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
 ldd #65535
11
 lbra L6
L7 equ 4
L6
 leas -4,y
 puls x,y,u,pc
 global _peekchar
_peekchar pshs u,y,x
 leay 4,s
 leas -L9,s
* Begin expression - 69
 ldd __ibytes
 ble 10f
 ldb [__ipos]
 sex
 clra
 bra 11f
10
 jsr __filbuf
 std __ipeek
 cmpd #65535
 bne 12f
 ldd #65535
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
 lbra L8
L9 equ 4
L8
 leas -4,y
 puls x,y,u,pc
 end
 name putchar.c
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
 ldd #65535
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
 cmpd #65535
 lbne L7
* Begin expression - 48
 ldd #65535
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
 end
 name printf.c
 text
 global _printf
_printf pshs u,y,x
 leay 4,s
* Auto 4 args
 leas -L2,s
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
 ldd #65535
 std -16,y
* Begin expression - 45
 ldd -14,y
 cmpd #20
 lbhs L3
* Begin expression - 46
 leau 2,u
* Begin expression - 47
 cmpd _fout
 lbeq L4
* Begin expression - 48
 jsr _flush
* Begin expression - 49
 ldd _fout
 std -16,y
* Begin expression - 50
 ldd -14,y
 std _fout
L4
L3
* Begin expression - 53
 leau 2,u
 ldx -2,u
 stx -10,y
L5
L8
* Begin expression - 55
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
 cmpd #37
 lbeq L9
* Begin expression - 56
 cmpd #0
 lbeq L9
L10
* Begin expression - 58
 ldd -6,y
 std 0,s
 jsr _putchar
 lbra L8
L9
* Begin expression - 60
 ldd -6,y
 lbeq L6
L11
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
 lbne L12
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
L12
* Begin expression - 69
 ldd -6,y
 cmpd #48
 lbne L13
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
L13
L14
* Begin expression - 73
 ldd -6,y
 cmpd #48
 lblt L15
 cmpd #57
10
 lbgt L15
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
 lbra L14
L15
* Begin expression - 77
 ldd -6,y
 cmpd #46
 lbne L16
* Begin expression - 78
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
L17
* Begin expression - 79
 ldd -6,y
 cmpd #48
 lblt L18
 cmpd #57
10
 lbgt L18
* Begin expression - 80
 ldx -10,y
 ldb 0,x+
 stx -10,y
 sex
 std -6,y
 lbra L17
L18
L16
* Begin expression - 82
 ldd -6,y
 lbeq L6
L19
* Begin expression - 84
 ldd -6,y
 lbra L21
L22
* Begin expression - 86
 ldd -14,y
 orb #$2
 std -14,y
L23
L24
* Begin expression - 89
 ldd #10
 std -6,y
 lbra L25
L26
* Begin expression - 92
 ldd #8
 std -6,y
 lbra L25
L27
* Begin expression - 95
 ldd #2
 std -6,y
 lbra L25
L28
L29
* Begin expression - 99
 ldd #16
 std -6,y
L25
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
 lbra L7
L30
* Begin expression - 103
 ldd 0,u++
 clra
 andb #$7F
 std -6,y
* Begin expression - 104
 ldd -14,y
 clra
 andb #$1
 lbeq L31
* Begin expression - 105
 ldd -6,y
 cmpd #32
 blt 11f
 cmpd #127
10
 lbne L32
11
* Begin expression - 106
 ldd -6,y
 lbra L34
L35
* Begin expression - 108
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 109
 ldd #110
 std -6,y
 lbra L33
L36
* Begin expression - 112
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 113
 ldd #114
 std -6,y
 lbra L33
L37
* Begin expression - 116
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 117
 ldd #98
 std -6,y
 lbra L33
L38
* Begin expression - 120
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 121
 ldd #102
 std -6,y
 lbra L33
L39
* Begin expression - 124
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 125
 ldd #116
 std -6,y
 lbra L33
L40
* Begin expression - 128
 ldb #92
 sex
 std 0,s
 jsr _putchar
* Begin expression - 129
 ldd #101
 std -6,y
 lbra L33
L41
* Begin expression - 132
 ldb #94
 sex
 std 0,s
 jsr _putchar
* Begin expression - 133
 ldd -6,y
 eorb #$40
 std -6,y
 lbra L33
L34
 ldx #L10003
 std L10002
L10001 cmpd 0,x++
 bne L10001
 jmp [L10002-L10003,x]
 data
L10003  fdb 13,13,8,12,9,27
L10002 fdb 0
 fdb L35,L36,L37,L38,L39,L40,L41
 text
L33
* Begin expression - 135
 ldd -12,y
 subd #1
 std -12,y
L32
L31
* Begin expression - 137
 ldd -6,y
 std 0,s
 jsr _putchar
* Begin expression - 138
 ldd -12,y
 subd #1
 std -12,y
L42
* Begin expression - 139
 ldd -12,y
 subd #1
 std -12,y
 lblt L43
* Begin expression - 140
 ldb #32
 sex
 std 0,s
 jsr _putchar
 lbra L42
L43
 lbra L7
L44
* Begin expression - 143
 leau 2,u
 ldx -2,u
 stx -8,y
L45
* Begin expression - 144
 ldb [-8,y]
 lbeq L46
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
 lbeq L47
* Begin expression - 147
 ldd -6,y
 cmpd #32
 blt 11f
 cmpd #127
10
 lbne L48
11
* Begin expression - 148
 ldb #94
 sex
 std 0,s
 jsr _putchar
* Begin expression - 149
 ldd -12,y
 lbeq L49
 subd #1
 std -12,y
10
 lble L46
L49
* Begin expression - 151
 ldd -6,y
 eorb #$40
 std -6,y
L48
L47
* Begin expression - 153
 ldd -6,y
 std 0,s
 jsr _putchar
* Begin expression - 154
 ldd -12,y
 lbeq L50
 subd #1
 std -12,y
10
 lble L46
L50
 lbra L45
L46
L51
* Begin expression - 157
 ldd -12,y
 subd #1
 std -12,y
 lblt L52
* Begin expression - 158
 ldb #32
 sex
 std 0,s
 jsr _putchar
 lbra L51
L52
 lbra L7
 lbra L20
L21
 ldx #L10007
 std L10006
L10005 cmpd 0,x++
 bne L10005
 jmp [L10006-L10007,x]
 data
L10007  fdb 100,108,117,111,98,104,120,99,115
L10006 fdb 0
 fdb L22,L23,L24,L26,L27,L28,L29,L30,L44,L10004
 text
L10004
 text
L20
* Begin expression - 161
 ldd -6,y
 std 0,s
 jsr _putchar
L7
 lbra L5
L6
* Begin expression - 163
 ldd -16,y
 lblt L53
* Begin expression - 164
 jsr _flush
* Begin expression - 165
 ldd -16,y
 std _fout
L53
L2 equ 16
L1
 leas -4,y
 puls x,y,u,pc
__num pshs u,y,x
 leay 4,s
* Auto 4 an
* Auto 6 ab
* Auto 8 ap
* Auto 10 af
 leas -L55,s
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
 lbeq L56
 ldd 4,y
10
 lbge L56
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
L56
* Begin expression - 184
 clr 0,-u
L57
* Begin expression - 186
 ldd -6,y
 std 0,s
 ldd -8,y
 jsr umod
 ldx #L60
 ldb d,x
 stb 0,-u
 data
L60 fcb 48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70
 fcb 0
 text
* Begin expression - 187
 ldd 8,y
 subd #1
 std 8,y
L58
* Begin expression - 188
 ldd -6,y
 std 0,s
 ldd -8,y
 jsr udiv
 std -6,y
 lbne L57
L59
* Begin expression - 189
 ldd #32
 std -6,y
* Begin expression - 190
 ldd 10,y
 clra
 andb #$5
 cmpd #1
 lbne L61
* Begin expression - 191
 ldd #48
 std -6,y
 lbra L62
L61
* Begin expression - 192
 ldd -10,y
 lbeq L63
* Begin expression - 193
 ldb #45
 stb 0,-u
* Begin expression - 194
 ldd #0
 std -10,y
L63
L62
* Begin expression - 196
 ldd 10,y
 clra
 andb #$4
 lbne L64
L65
* Begin expression - 197
 ldd 8,y
 subd #1
 std 8,y
 lblt L66
* Begin expression - 198
 ldd -6,y
 stb 0,-u
 lbra L65
L66
L64
* Begin expression - 199
 ldd -10,y
 lbeq L67
* Begin expression - 200
 ldb #45
 stb 0,-u
L67
L68
* Begin expression - 201
 ldb 0,u
 lbeq L69
* Begin expression - 202
 ldb 0,u+
 sex
 std 0,s
 jsr _putchar
 lbra L68
L69
L70
* Begin expression - 203
 ldd 8,y
 subd #1
 std 8,y
 lblt L71
* Begin expression - 204
 ldd -6,y
 std 0,s
 jsr _putchar
 lbra L70
L71
L55 equ 27
L54
 leas -4,y
 puls x,y,u,pc
 end
 name aliens.c
 text
 data
 global _vs_cols
_vs_cols fdb 80
 bss
 global _scores
_scores rmb 2
 global _bases
_bases rmb 2
 global _game
_game rmb 2
 global _danger
_danger rmb 2
 global _max_dang
_max_dang rmb 2
 global _flip
_flip rmb 2
 global _flop
_flop rmb 2
 global _left
_left rmb 2
 global _al_num
_al_num rmb 2
 global _b
_b rmb 2
 global _al_cnt
_al_cnt rmb 2
 global _bmb_cnt
_bmb_cnt rmb 2
 data
L1 fcb 32,32,32,32,32,32,32,32,32,35,35,35,35,35,35,35
 fcb 35,32,32,32,32,32,32,32,32,32,32,35,35,35,35,35
 fcb 35,35,35,32,32,32,32,32,32,32,32,32,32,35,35,35
 fcb 35,35,35,35,35,32,32,32,32,32,32,32,32,32,32,35
 fcb 35,35,35,35,35,35,35,0
 global _barrin1
_barrin1 fdb L1
L2 fcb 32,32,32,32,32,32,32,32,35,35,35,35,35,35,35,35
 fcb 35,35,32,32,32,32,32,32,32,32,35,35,35,35,35,35
 fcb 35,35,35,35,32,32,32,32,32,32,32,32,35,35,35,35
 fcb 35,35,35,35,35,35,32,32,32,32,32,32,32,32,35,35
 fcb 35,35,35,35,35,35,35,35,0
 global _barrin2
_barrin2 fdb L2
L3 fcb 32,32,32,32,32,32,32,32,35,35,35,32,32,32,32,35
 fcb 35,35,32,32,32,32,32,32,32,32,35,35,35,32,32,32
 fcb 32,35,35,35,32,32,32,32,32,32,32,32,35,35,35,32
 fcb 32,32,32,35,35,35,32,32,32,32,32,32,32,32,35,35
 fcb 35,32,32,32,32,35,35,35,0
 global _barrin3
_barrin3 fdb L3
L4 fcb 32,32,32,32,32,32,32,32,35,35,35,32,32,32,32,35
 fcb 35,35,32,32,32,32,32,32,32,32,35,35,35,32,32,32
 fcb 32,35,35,35,32,32,32,32,32,32,32,32,35,35,35,32
 fcb 32,32,32,35,35,35,32,32,32,32,32,32,32,32,35,35
 fcb 35,32,32,32,32,35,35,35,0
 global _barrin4
_barrin4 fdb L4
 bss
 global _barr1
_barr1 rmb 80
 global _barr2
_barr2 rmb 80
 global _barr3
_barr3 rmb 80
 global _barr4
_barr4 rmb 80
 global _al_row
_al_row rmb 110
 global _al_col
_al_col rmb 110
 global _bmb_row
_bmb_row rmb 40
 global _bmb_col
_bmb_col rmb 40
 global _shp_vel
_shp_vel rmb 2
 global _shp_val
_shp_val rmb 2
 global _shp_col
_shp_col rmb 2
 global _bas_row
_bas_row rmb 2
 global _bas_col
_bas_col rmb 2
 global _bas_vel
_bas_vel rmb 2
 global _bem_row
_bem_row rmb 2
 global _bem_col
_bem_col rmb 2
 text
 global _over
_over pshs u,y,x
 leay 4,s
 leas -L6,s
* Auto -6 i
* Begin expression - 74
 ldd _game
 cmpd #4
 lbne L7
* Begin expression - 75
 ldd #3
 std _game
* Begin expression - 76
 ldd #0
 std -6,y
L8
* Begin expression - 76
 ldd -6,y
 cmpd #55
 lbge L9
* Begin expression - 76
 lslb
 rola
 ldx #_al_row
 ldd d,x
 lbeq L11
* Begin expression - 77
 ldd -6,y
 lslb
 rola
 ldx #_al_col
 ldd d,x
 std 0,s
 ldd -6,y
 lslb
 rola
 ldx #_al_row
 ldd d,x
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 78
 ldd -6,y
 lslb
 rola
 ldx #_al_col
 leax d,x
 ldd -6,y
 lslb
 rola
 stx 0,s
 ldx #_al_row
 ldd d,x
 asra
 rorb
 addd [0,s]
 clra
 andb #$1
 std 0,s
 ldd -6,y
 pshs d
 ldd #22
 jsr idiv
 leas 2,s
 lslb
 rola
 addd 0,s
 std 0,s
 jsr _ds_obj
L11
L10
* Begin expression - 80
 inc -5,y
 lbne L8
 inc -6,y
 lbra L8
L9
* Begin expression - 80
 ldd #4
 std _game
L7
* Begin expression - 82
 ldd #20
 std 0,s
 ldd #9
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 83
 ldx #L12
 stx 0,s
 jsr _printf
 data
L12 fcb 32,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
 fcb 95,95,95,95,95,95,95,95,95,95,95,32,0
 text
* Begin expression - 84
 ldd #20
 std 0,s
 ldd #10
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 85
 ldx #L13
 stx 0,s
 jsr _printf
 data
L13 fcb 124,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 32,32,32,32,32,32,32,32,32,32,32,124,0
 text
* Begin expression - 86
 ldd #20
 std 0,s
 ldd #11
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 87
 ldx #L14
 stx 0,s
 jsr _printf
 data
L14 fcb 124,32,71,32,65,32,77,32,69,32,32,32,79,32,86,32
 fcb 69,32,82,32,32,32,32,32,32,32,32,124,0
 text
* Begin expression - 88
 ldd #20
 std 0,s
 ldd #12
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 89
 ldx #L15
 stx 0,s
 jsr _printf
 data
L15 fcb 124,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 32,32,32,32,32,32,32,32,32,32,32,124,0
 text
* Begin expression - 90
 ldd #20
 std 0,s
 ldd #13
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 91
 ldd _game
 std 0,s
 ldx #L16
 pshs x
 jsr _printf
 leas 2,s
 data
L16 fcb 124,32,71,97,109,101,32,116,121,112,101,32,58,32,37,100
 fcb 32,32,32,32,32,32,32,32,32,32,32,32,124,0
 text
* Begin expression - 92
 ldd #20
 std 0,s
 ldd #14
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 93
 ldd _scores
 std 0,s
 ldx #L17
 pshs x
 jsr _printf
 leas 2,s
 data
L17 fcb 124,32,32,70,73,78,65,76,32,83,67,79,82,69,32,32
 fcb 37,52,100,32,32,32,32,32,32,32,124,0
 text
* Begin expression - 94
 ldd #20
 std 0,s
 ldd #15
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 95
 ldx #L18
 stx 0,s
 jsr _printf
 data
L18 fcb 124,95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
 fcb 95,95,95,95,95,95,95,95,95,95,95,124,0
 text
* Begin expression - 96
 jsr _leave
L6 equ 6
L5
 leas -4,y
 puls x,y,u,pc
 global _init
_init pshs u,y,x
 leay 4,s
 leas -L20,s
* Begin expression - 108
 ldd #0
 std _game
* Begin expression - 109
 jsr _instruc
L21
* Begin expression - 110
 ldd _game
 lbne L22
* Begin expression - 110
 jsr _poll
 lbra L21
L22
* Begin expression - 111
 ldd #0
 std _scores
* Begin expression - 112
 ldd #3
 std _bases
* Begin expression - 113
 ldd #11
 std _danger
* Begin expression - 114
 ldd #22
 std _max_dan
L20 equ 4
L19
 leas -4,y
 puls x,y,u,pc
 global _tabl
_tabl pshs u,y,x
 leay 4,s
 leas -L24,s
* Auto -6 j
* Auto -8 i
* Begin expression - 123
 jsr _clr
* Begin expression - 124
 ldd #0
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 125
 ldx #L25
 stx 0,s
 jsr _printf
 data
L25 fcb 83,99,111,114,101,58,0
 text
* Begin expression - 126
 ldd #9
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 127
 ldd _scores
 std 0,s
 ldx #L26
 pshs x
 jsr _printf
 leas 2,s
 data
L26 fcb 37,45,100,0
 text
* Begin expression - 128
 ldd #18
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 129
 ldx #L27
 stx 0,s
 jsr _printf
 data
L27 fcb 73,32,78,32,86,32,65,32,83,32,73,32,79,32,78,32
 fcb 32,32,79,32,70,32,32,32,84,32,72,32,69,32,32,32
 fcb 65,32,76,32,73,32,69,32,78,32,83,32,33,0
 text
* Begin expression - 130
 ldd #70
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 131
 ldd _bases
 std 0,s
 ldx #L28
 pshs x
 jsr _printf
 leas 2,s
 data
L28 fcb 76,97,115,101,114,115,58,32,37,100,0
 text
* Begin expression - 134
 ldd #55
 std _al_cnt
* Begin expression - 135
 ldd #0
 std -6,y
L29
* Begin expression - 135
 ldd -6,y
 cmpd #4
 lbgt L30
* Begin expression - 137
 ldd #0
 std 0,s
 ldd -6,y
 lslb
 rola
 nega
 negb
 sbca #0
 addd _danger
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 138
 ldd #0
 std -8,y
L32
* Begin expression - 138
 ldd -8,y
 cmpd #10
 lbgt L33
* Begin expression - 140
 addd -6,y
 clra
 andb #$1
 std 0,s
 ldd -6,y
 asra
 rorb
 lslb
 rola
 addd 0,s
 std 0,s
 jsr _ds_obj
* Begin expression - 141
 ldb #32
 sex
 std 0,s
 jsr _putchar
* Begin expression - 142
 ldd -6,y
 std 0,s
 ldd #11
 jsr imul
 addd -8,y
 lslb
 rola
 ldx #_al_row
 leax d,x
 ldd -6,y
 lslb
 rola
 nega
 negb
 sbca #0
 addd _danger
 std 0,x
* Begin expression - 143
 ldd -6,y
 std 0,s
 ldd #11
 jsr imul
 addd -8,y
 lslb
 rola
 ldx #_al_col
 leax d,x
 ldd -8,y
 std 0,s
 ldd #6
 jsr imul
 std 0,x
L34
* Begin expression - 144
 inc -7,y
 lbne L32
 inc -8,y
 lbra L32
L33
L31
* Begin expression - 145
 inc -5,y
 lbne L29
 inc -6,y
 lbra L29
L30
* Begin expression - 146
 ldd _danger
 cmpd _max_dan
 lbge L35
* Begin expression - 146
 inc _danger+1
 bne 1f
 inc _danger
1
L35
* Begin expression - 147
 ldd #54
 std _al_num
* Begin expression - 148
 ldd #0
 std _flip
* Begin expression - 149
 ldd #0
 std _flop
* Begin expression - 150
 ldd #0
 std _left
* Begin expression - 154
 ldd #23
 std _bas_row
* Begin expression - 155
 ldd #72
 std _bas_col
* Begin expression - 156
 ldd #0
 std _bas_vel
* Begin expression - 157
 ldd #0
 std _bem_row
* Begin expression - 161
 ldd #0
 std -8,y
L36
* Begin expression - 161
 ldd -8,y
 cmpd #4
 lbge L37
* Begin expression - 161
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 ldd #0
 std 0,x
L38
* Begin expression - 161
 inc -7,y
 lbne L36
 inc -8,y
 lbra L36
L37
* Begin expression - 162
 ldd #0
 std _b
* Begin expression - 163
 ldd #0
 std _bmb_cnt
* Begin expression - 167
 ldd #0
 std -6,y
L39
* Begin expression - 167
 ldd -6,y
 cmpd #79
 lbge L40
* Begin expression - 168
 ldx #_barr1
 leax d,x
 ldb #32
 stb 0,x
* Begin expression - 169
 ldd -6,y
 ldx #_barr2
 leax d,x
 ldb #32
 stb 0,x
* Begin expression - 170
 ldd -6,y
 ldx #_barr3
 leax d,x
 ldb #32
 stb 0,x
* Begin expression - 171
 ldd -6,y
 ldx #_barr4
 leax d,x
 ldb #32
 stb 0,x
L41
* Begin expression - 172
 inc -5,y
 lbne L39
 inc -6,y
 lbra L39
L40
* Begin expression - 173
 ldb #0
 stb _barr4+79
 stb _barr3+79
 stb _barr2+79
 stb _barr1+79
* Begin expression - 176
 ldd #0
 std 0,s
 ldd #19
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 178
 ldd #0
 std -6,y
L42
* Begin expression - 178
 ldd -6,y
 ldx _barrin1
 ldb d,x
 lbeq L43
* Begin expression - 179
 ldd -6,y
 ldx #_barr1
 leax d,x
 stx 0,s
 ldx _barrin1
 ldb d,x
 stb [0,s]
L44
* Begin expression - 179
 inc -5,y
 lbne L42
 inc -6,y
 lbra L42
L43
* Begin expression - 180
 ldx #_barr1
 stx 0,s
 jsr _printf
* Begin expression - 182
 ldd #0
 std 0,s
 ldd #20
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 183
 ldd #0
 std -6,y
L45
* Begin expression - 183
 ldd -6,y
 ldx _barrin2
 ldb d,x
 lbeq L46
* Begin expression - 184
 ldd -6,y
 ldx #_barr2
 leax d,x
 stx 0,s
 ldx _barrin2
 ldb d,x
 stb [0,s]
L47
* Begin expression - 184
 inc -5,y
 lbne L45
 inc -6,y
 lbra L45
L46
* Begin expression - 185
 ldx #_barr2
 stx 0,s
 jsr _printf
* Begin expression - 187
 ldd #0
 std 0,s
 ldd #21
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 188
 ldd #0
 std -6,y
L48
* Begin expression - 188
 ldd -6,y
 ldx _barrin3
 ldb d,x
 lbeq L49
* Begin expression - 189
 ldd -6,y
 ldx #_barr3
 leax d,x
 stx 0,s
 ldx _barrin3
 ldb d,x
 stb [0,s]
L50
* Begin expression - 189
 inc -5,y
 lbne L48
 inc -6,y
 lbra L48
L49
* Begin expression - 190
 ldx #_barr3
 stx 0,s
 jsr _printf
* Begin expression - 192
 ldd #0
 std 0,s
 ldd #22
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 193
 ldd #0
 std -6,y
L51
* Begin expression - 193
 ldd -6,y
 ldx _barrin4
 ldb d,x
 lbeq L52
* Begin expression - 194
 ldd -6,y
 ldx #_barr4
 leax d,x
 stx 0,s
 ldx _barrin4
 ldb d,x
 stb [0,s]
L53
* Begin expression - 194
 inc -5,y
 lbne L51
 inc -6,y
 lbra L51
L52
* Begin expression - 195
 ldx #_barr4
 stx 0,s
 jsr _printf
* Begin expression - 201
 ldd #0
 std _shp_vel
 lbra L23
L24 equ 8
L23
 leas -4,y
 puls x,y,u,pc
 global _poll
_poll pshs u,y,x
 leay 4,s
 leas -L55,s
* Auto -6 cbuf
* Begin expression - 208
 ldd _game
 cmpd #1
 lbne L56
* Begin expression - 209
 ldd _bas_col
 cmpd #1
 lbgt L57
* Begin expression - 209
 ldd #1
 std _bas_vel
L57
* Begin expression - 210
 ldd _bas_col
 cmpd #72
 lblt L58
* Begin expression - 210
 ldd #65535
 std _bas_vel
L58
L56
* Begin expression - 213
 jsr _charead
 cmpd #0
 lbne L59
 lbra L54
L59
* Begin expression - 216
 jsr _getchar
 std -6,y
* Begin expression - 218
 clra
 andb #$7F
 lbra L61
L62
* Begin expression - 219
 ldd _bem_row
 lbne L63
* Begin expression - 219
 ldd #22
 std _bem_row
L63
 lbra L54
L64
L65
* Begin expression - 222
 ldd _game
 cmpd #1
 lbne L66
 lbra L54
L66
* Begin expression - 223
 ldd #65535
 std _bas_vel
 lbra L54
L67
L68
* Begin expression - 225
 ldd _game
 cmpd #1
 lbne L69
 lbra L54
L69
* Begin expression - 226
 ldd #1
 std _bas_vel
 lbra L54
L70
L71
* Begin expression - 228
 ldd _game
 cmpd #1
 lbne L72
 lbra L54
L72
* Begin expression - 229
 ldd #0
 std _bas_vel
 lbra L54
L73
L74
L75
* Begin expression - 232
 jsr _over
L76
* Begin expression - 233
 ldd _game
 lbeq L77
 lbra L54
L77
* Begin expression - 234
 ldd #1
 std _game
 lbra L54
L78
* Begin expression - 235
 ldd _game
 lbeq L79
 lbra L54
L79
* Begin expression - 236
 ldd #2
 std _game
 lbra L54
L80
* Begin expression - 237
 ldd _game
 lbeq L81
 lbra L54
L81
* Begin expression - 238
 ldd #3
 std _game
 lbra L54
L82
* Begin expression - 239
 ldd _game
 lbeq L83
 lbra L54
L83
* Begin expression - 240
 ldd #4
 std _game
 lbra L54
 lbra L60
L61
 ldx #L10011
 std L10010
L10009 cmpd 0,x++
 bne L10009
 jmp [L10010-L10011,x]
 data
L10011  fdb 32,122,44,99,47,120,46,127,28,113,49,50,51,52
L10010 fdb 0
 fdb L62,L64,L65,L67,L68,L70,L71,L73,L74,L75,L76,L78,L80,L82,L10008
 text
L10008
 text
L60
L55 equ 6
L54
 leas -4,y
 puls x,y,u,pc
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L85,s
* Begin expression - 249
 jsr _noecho
* Begin expression - 250
 jsr _init
* Begin expression - 251
 jsr _nonl
L86
* Begin expression - 252
 ldd #1
 lbeq L87
* Begin expression - 254
 jsr _tabl
L88
* Begin expression - 255
 ldd #1
 lbeq L89
* Begin expression - 257
 jsr _poll
* Begin expression - 258
 jsr _beam
* Begin expression - 259
 jsr _base
* Begin expression - 260
 jsr _bomb
* Begin expression - 261
 jsr _ship
* Begin expression - 262
 jsr _alien
* Begin expression - 263
 jsr _alien
* Begin expression - 264
 ldd _al_cnt
 lbeq L89
L90
 lbra L88
L89
 lbra L86
L87
L85 equ 4
L84
 leas -4,y
 puls x,y,u,pc
 global _barrx
_barrx pshs u,y,x
 leay 4,s
* Auto 4 row
* Auto 6 col
 leas -L92,s
* Begin expression - 271
 ldd 4,y
 lbra L94
L95
* Begin expression - 273
 ldd 6,y
 ldx #_barr1
 ldb d,x
 lbra L91
L96
* Begin expression - 274
 ldd 6,y
 ldx #_barr2
 ldb d,x
 lbra L91
L97
* Begin expression - 275
 ldd 6,y
 ldx #_barr3
 ldb d,x
 lbra L91
L98
* Begin expression - 276
 ldd 6,y
 ldx #_barr4
 ldb d,x
 lbra L91
 lbra L93
L94
 ldx #L10015
 std L10014
L10013 cmpd 0,x++
 bne L10013
 jmp [L10014-L10015,x]
 data
L10015  fdb 0,1,2,3
L10014 fdb 0
 fdb L95,L96,L97,L98,L10012
 text
L10012
 text
L93
L92 equ 4
L91
 leas -4,y
 puls x,y,u,pc
 global _barrxp
_barrxp pshs u,y,x
 leay 4,s
* Auto 4 row
* Auto 6 col
* Auto 8 val
 leas -L100,s
* Begin expression - 283
 ldd 4,y
 lbra L102
L103
* Begin expression - 285
 ldd 6,y
 ldx #_barr1
 leax d,x
 ldd 8,y
 stb 0,x
 lbra L99
L104
* Begin expression - 286
 ldd 6,y
 ldx #_barr2
 leax d,x
 ldd 8,y
 stb 0,x
 lbra L99
L105
* Begin expression - 287
 ldd 6,y
 ldx #_barr3
 leax d,x
 ldd 8,y
 stb 0,x
 lbra L99
L106
* Begin expression - 288
 ldd 6,y
 ldx #_barr4
 leax d,x
 ldd 8,y
 stb 0,x
 lbra L99
 lbra L101
L102
 ldx #L10019
 std L10018
L10017 cmpd 0,x++
 bne L10017
 jmp [L10018-L10019,x]
 data
L10019  fdb 0,1,2,3
L10018 fdb 0
 fdb L103,L104,L105,L106,L10016
 text
L10016
 text
L101
L100 equ 4
L99
 leas -4,y
 puls x,y,u,pc
 end
 name ajunk.c
 text
 global _chaready
_chaready pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -10 chrmds
* Begin expression - 6
 leax -10,y
 stx 0,s
 ldd #0
 pshs d
 jsr _gtty
 leas 2,s
* Begin expression - 7
 ldb -6,y
 sex
 clra
 andb #$80
 lbra L1
L2 equ 10
L1
 leas -4,y
 puls x,y,u,pc
 end
 name aobj.c
 text
 global _base
_base pshs u,y,x
 leay 4,s
 leas -L2,s
* Begin expression - 44
 ldd _bas_col
 addd _bas_vel
 std _bas_col
* Begin expression - 45
 cmpd #1
 lbge L3
* Begin expression - 45
 ldd #1
 std _bas_col
 lbra L4
L3
* Begin expression - 46
 ldd _bas_col
 cmpd #72
 lble L5
* Begin expression - 46
 ldd #72
 std _bas_col
L5
L4
* Begin expression - 47
 ldd _bas_col
 std 0,s
 ldd _bas_row
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 48
 ldd #7
 std 0,s
 jsr _ds_obj
L2 equ 4
L1
 leas -4,y
 puls x,y,u,pc
 global _beam
_beam pshs u,y,x
 leay 4,s
 leas -L7,s
* Auto -6 i
* Auto -8 j
* Begin expression - 60
 ldd _bem_row
 lbra L9
L10
 lbra L6
L11
* Begin expression - 62
 ldd _bem_col
 std 0,s
 ldd #21
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 63
 ldb #124
 sex
 std 0,s
 jsr _putchar
 lbra L8
L12
* Begin expression - 65
 ldd _bas_col
 addd #3
 std _bem_col
* Begin expression - 66
 std 0,s
 ldd #22
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 67
 ldb #124
 sex
 std 0,s
 jsr _putchar
 lbra L8
L13
* Begin expression - 69
 ldd _bem_col
 std 0,s
 ldd _bem_row
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 70
 ldx #L14
 stx 0,s
 jsr _printf
 data
L14 fcb 124,8,10,10,32,0
 text
 lbra L8
 lbra L8
L9
 ldx #L10022
 std L10021
L10020 cmpd 0,x++
 bne L10020
 jmp [L10021-L10022,x]
 data
L10022  fdb 0,21,22
L10021 fdb 0
 fdb L10,L11,L12,L13
 text
L8
* Begin expression - 76
 ldd #0
 std -6,y
L15
* Begin expression - 76
 ldd -6,y
 cmpd #55
 lbge L16
* Begin expression - 78
 lslb
 rola
 ldx #_al_row
 ldd d,x
 cmpd _bem_row
 lbne L18
 ldd -6,y
 lslb
 rola
 ldx #_al_col
 ldd d,x
 addd #1
 cmpd _bem_col
 lbgt L18
 ldd -6,y
 lslb
 rola
 ldx #_al_col
 ldd d,x
 addd #3
 cmpd _bem_col
10
 lblt L18
* Begin expression - 82
 ldd -6,y
 std 0,s
 ldd #22
 jsr idiv
 addd _scores
 addd #1
 std _scores
* Begin expression - 83
 ldd #9
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 84
 ldd _scores
 std 0,s
 ldx #L19
 pshs x
 jsr _printf
 leas 2,s
 data
L19 fcb 37,45,100,0
 text
* Begin expression - 85
 ldd _bem_col
 std 0,s
 ldd _bem_row
 addd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 86
 ldb #32
 sex
 std 0,s
 jsr _putchar
* Begin expression - 87
 ldd -6,y
 lslb
 rola
 ldx #_al_col
 ldd d,x
 std 0,s
 ldd -6,y
 lslb
 rola
 ldx #_al_row
 ldd d,x
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 88
 ldd #6
 std 0,s
 jsr _ds_obj
* Begin expression - 89
 ldd #0
 std _bem_row
* Begin expression - 90
 ldd -6,y
 lslb
 rola
 ldx #_al_row
 leax d,x
 ldd #0
 std 0,x
* Begin expression - 91
 tst _al_cnt+1
 bne 1f
 dec _al_cnt
1 dec _al_cnt+1
 lbra L6
L18
L17
* Begin expression - 94
 inc -5,y
 lbne L15
 inc -6,y
 lbra L15
L16
* Begin expression - 98
 ldd #0
 std -6,y
L20
* Begin expression - 98
 ldd -6,y
 cmpd #4
 lbge L21
* Begin expression - 99
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 cmpd _bem_row
 lbne L23
 ldd -6,y
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 cmpd _bem_col
10
 lbne L23
* Begin expression - 100
 ldd _bem_col
 std 0,s
 ldd _bem_row
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 101
 ldx #L24
 stx 0,s
 jsr _printf
 data
L24 fcb 32,8,10,32,0
 text
* Begin expression - 102
 ldd #0
 std _bem_row
* Begin expression - 103
 tst _bmb_cnt+1
 bne 1f
 dec _bmb_cnt
1 dec _bmb_cnt+1
* Begin expression - 104
 ldd -6,y
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 ldd #0
 std 0,x
 lbra L6
L23
L22
* Begin expression - 107
 inc -5,y
 lbne L20
 inc -6,y
 lbra L20
L21
* Begin expression - 112
 ldd _bem_row
 cmpd #19
 lblt L25
 cmpd #22
 lbgt L25
 ldd _bem_col
 std 0,s
 ldd _bem_row
 subd #19
 pshs d
 jsr _barrx
 leas 2,s
 cmpd #32
10
 lbeq L25
* Begin expression - 113
 ldd _bem_col
 std 0,s
 ldd _bem_row
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 114
 ldx #L26
 stx 0,s
 jsr _printf
 data
L26 fcb 32,8,10,32,0
 text
* Begin expression - 115
 ldb #32
 sex
 std 0,s
 ldd _bem_col
 pshs d
 ldd _bem_row
 subd #19
 pshs d
 jsr _barrxp
 leas 4,s
* Begin expression - 116
 ldd #0
 std _bem_row
 lbra L6
L25
* Begin expression - 123
 ldd _shp_vel
 lbeq L27
 ldd _bem_row
 cmpd #1
 lbne L27
 ldd _shp_col
 subd _shp_vel
 std -6,y
 cmpd _bem_col
 lbge L27
 addd #7
 cmpd _bem_col
10
 lble L27
* Begin expression - 127
 ldd -6,y
 std 0,s
 ldd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 128
 ldx #L28
 stx 0,s
 jsr _printf
 data
L28 fcb 32,32,32,32,32,32,32,32,0
 text
* Begin expression - 129
 ldd #0
 std _shp_vel
* Begin expression - 130
 ldd _shp_val
 std 0,s
 ldd #3
 jsr idiv
 addd _scores
 std _scores
* Begin expression - 131
 ldd #9
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 132
 ldd _scores
 std 0,s
 ldx #L29
 pshs x
 jsr _printf
 leas 2,s
 data
L29 fcb 37,45,100,0
 text
L27
* Begin expression - 137
 ldd _bem_row
 subd #1
 std _bem_row
 lbne L30
* Begin expression - 138
 ldd _bem_col
 std 0,s
 ldd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 139
 ldb #32
 sex
 std 0,s
 jsr _putchar
* Begin expression - 140
 ldd _bem_col
 std 0,s
 ldd #2
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 141
 ldb #32
 sex
 std 0,s
 jsr _putchar
L30
 lbra L6
L7 equ 8
L6
 leas -4,y
 puls x,y,u,pc
 global _bomb
_bomb pshs u,y,x
 leay 4,s
 leas -L32,s
* Auto -6 i
* Auto -8 j
* Begin expression - 151
 ldd _bmb_cnt
 lbne L34
 lbra L31
L33
L34
* Begin expression - 152
 ldd #1
 lbeq L35
* Begin expression - 153
 ldd _b
 addd #1
 std _b
 cmpd #4
 lblt L36
* Begin expression - 153
 ldd #0
 std _b
L36
* Begin expression - 154
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 lbne L35
L37
 lbra L34
L35
* Begin expression - 159
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
* Begin expression - 160
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 cmpd #23
 lbne L38
* Begin expression - 161
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 cmpd _bas_col
 lble L39
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 leax d,x
 ldd _bas_col
 addd #5
 cmpd 0,x
10
 lblt L39
* Begin expression - 165
 tst _bases+1
 bne 1f
 dec _bases
1 dec _bases+1
* Begin expression - 166
 ldd #70
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 167
 ldd _bases
 std 0,s
 ldx #L40
 pshs x
 jsr _printf
 leas 2,s
 data
L40 fcb 76,97,115,101,114,115,58,32,37,100,0
 text
* Begin expression - 171
 ldd #0
 std -6,y
L41
* Begin expression - 171
 ldd -6,y
 cmpd #10
 lbge L42
* Begin expression - 172
 ldx #L44
 stx 0,s
 jsr _printf
 data
L44 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 173
 ldx #L45
 stx 0,s
 jsr _printf
 data
L45 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 174
 ldx #L46
 stx 0,s
 jsr _printf
 data
L46 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 175
 ldx #L47
 stx 0,s
 jsr _printf
 data
L47 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 176
 ldx #L48
 stx 0,s
 jsr _printf
 data
L48 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 177
 ldx #L49
 stx 0,s
 jsr _printf
 data
L49 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 178
 ldx #L50
 stx 0,s
 jsr _printf
 data
L50 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 179
 ldx #L51
 stx 0,s
 jsr _printf
 data
L51 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 180
 ldx #L52
 stx 0,s
 jsr _printf
 data
L52 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 181
 ldx #L53
 stx 0,s
 jsr _printf
 data
L53 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
* Begin expression - 182
 ldx #L54
 stx 0,s
 jsr _printf
 data
L54 fcb 7,1,1,1,1,1,1,1,1,1,1,0
 text
L43
* Begin expression - 183
 inc -5,y
 lbne L41
 inc -6,y
 lbra L41
L42
* Begin expression - 184
 ldd _bases
 lbne L55
* Begin expression - 188
 jsr _over
L55
* Begin expression - 190
 ldd #2
 std 0,s
 jsr _sleep
* Begin expression - 191
 ldd _bas_col
 std 0,s
 ldd #23
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 192
 ldx #L56
 stx 0,s
 jsr _printf
 data
L56 fcb 32,32,32,32,32,32,32,0
 text
* Begin expression - 193
 ldd #72
 std _bas_col
L39
L38
* Begin expression - 197
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 cmpd #19
 lblt L57
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 cmpd #23
 lbge L57
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 subd #19
 pshs d
 jsr _barrx
 leas 2,s
 cmpd #32
10
 lbeq L57
* Begin expression - 201
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 subd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 202
 ldx #L58
 stx 0,s
 jsr _printf
 data
L58 fcb 32,8,10,42,8,32,0
 text
* Begin expression - 203
 ldb #32
 sex
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 pshs d
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 subd #19
 pshs d
 jsr _barrxp
 leas 4,s
* Begin expression - 204
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 ldd #0
 std 0,x
* Begin expression - 205
 tst _bmb_cnt+1
 bne 1f
 dec _bmb_cnt
1 dec _bmb_cnt+1
 lbra L31
L57
* Begin expression - 208
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 209
 ldb #42
 sex
 std 0,s
 jsr _putchar
* Begin expression - 210
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 subd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 211
 ldb #32
 sex
 std 0,s
 jsr _putchar
* Begin expression - 212
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 cmpd #23
 lbne L59
* Begin expression - 213
 tst _bmb_cnt+1
 bne 1f
 dec _bmb_cnt
1 dec _bmb_cnt+1
* Begin expression - 214
 ldd _b
 lslb
 rola
 ldx #_bmb_col
 ldd d,x
 std 0,s
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 215
 ldb #32
 sex
 std 0,s
 jsr _putchar
* Begin expression - 216
 ldd _b
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 ldd #0
 std 0,x
L59
 lbra L31
L32 equ 8
L31
 leas -4,y
 puls x,y,u,pc
 global _ship
_ship pshs u,y,x
 leay 4,s
 leas -L61,s
* Auto -6 i
* Begin expression - 225
 ldd _shp_vel
 lbne L62
* Begin expression - 226
 ldd -6,y
 lbeq L63
* Begin expression - 232
 cmpd #16
 lbge L64
* Begin expression - 233
 ldd #65535
 std _shp_vel
* Begin expression - 234
 ldd _vs_cols
 subd #8
 std _shp_col
 lbra L65
L64
* Begin expression - 237
 ldd #1
 std _shp_vel
* Begin expression - 238
 ldd #1
 std _shp_col
L65
* Begin expression - 240
 ldd #90
 std _shp_val
L63
 lbra L66
L62
* Begin expression - 247
 ldd _shp_col
 std 0,s
 ldd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 248
 ldd _game
 cmpd #4
 lbeq L67
* Begin expression - 249
 ldd _shp_val
 std 0,s
 ldx #L68
 pshs x
 jsr _printf
 leas 2,s
 data
L68 fcb 32,60,61,37,50,100,61,62,32,0
 text
L67
* Begin expression - 250
 tst _shp_val+1
 bne 1f
 dec _shp_val
1 dec _shp_val+1
* Begin expression - 251
 ldd _shp_col
 addd _shp_vel
 std _shp_col
* Begin expression - 252
 std -6,y
 std 0,s
 ldd _vs_cols
 subd #8
 cmpd 0,s
 blt 11f
 ldd -6,y
 cmpd #1
10
 lbge L69
11
* Begin expression - 256
 ldd _shp_col
 subd _shp_vel
 std 0,s
 ldd #1
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 257
 ldx #L70
 stx 0,s
 jsr _printf
 data
L70 fcb 32,32,32,32,32,32,32,32,0
 text
* Begin expression - 258
 ldd #0
 std _shp_vel
L69
L66
L61 equ 6
L60
 leas -4,y
 puls x,y,u,pc
 global _alien
_alien pshs u,y,x
 leay 4,s
 leas -L72,s
* Auto -6 i
* Auto -8 j
L73
* Begin expression - 269
 ldd #1
 lbeq L74
* Begin expression - 271
 ldd _al_num
 addd #1
 std _al_num
 cmpd #55
 lblt L75
* Begin expression - 273
 ldd _al_cnt
 lbne L76
 lbra L71
L76
* Begin expression - 274
 ldd #0
 std _flop
* Begin expression - 275
 ldd _flip
 lbeq L77
* Begin expression - 275
 ldd _left
 addd #1
 clra
 andb #$1
 std _left
* Begin expression - 276
 ldd #1
 std _flop
L77
* Begin expression - 278
 ldd #0
 std _flip
* Begin expression - 279
 ldd #0
 std _al_num
L75
* Begin expression - 281
 ldd _al_num
 lslb
 rola
 ldx #_al_row
 ldd d,x
 std -6,y
 lbgt L74
L78
 lbra L73
L74
* Begin expression - 283
 ldd -6,y
 cmpd #23
 lblt L79
* Begin expression - 287
 jsr _over
L79
* Begin expression - 290
 ldd _left
 lbeq L80
* Begin expression - 290
 ldd _al_num
 lslb
 rola
 ldx #_al_col
 leax d,x
 tst 1,x
 bne 1f
 dec 0,x
1 dec 1,x
 lbra L81
L80
* Begin expression - 291
 ldd _al_num
 lslb
 rola
 ldx #_al_col
 leax d,x
 inc 1,x
 bne 1f
 inc 0,x
1
L81
* Begin expression - 292
 ldd _al_num
 lslb
 rola
 ldx #_al_col
 ldd d,x
 std -8,y
 beq 11f
 cmpd #75
10
 lbne L82
11
* Begin expression - 292
 ldd #1
 std _flip
L82
* Begin expression - 293
 ldd -8,y
 std 0,s
 ldd -6,y
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 294
 ldd _flop
 lbeq L83
* Begin expression - 295
 ldd #6
 std 0,s
 jsr _ds_obj
* Begin expression - 296
 ldd _al_num
 lslb
 rola
 ldx #_al_row
 leax d,x
 ldd 0,x
 addd #1
 std 0,x
 std -6,y
* Begin expression - 297
 ldd -8,y
 std 0,s
 ldd -6,y
 pshs d
 jsr _pos
 leas 2,s
L83
* Begin expression - 299
 ldd -6,y
 asra
 rorb
 addd -8,y
 clra
 andb #$1
 std 0,s
 ldd _al_num
 pshs d
 ldd #22
 jsr idiv
 leas 2,s
 lslb
 rola
 addd 0,s
 std 0,s
 jsr _ds_obj
* Begin expression - 303
 ldd _game
 cmpd #1
 beq 11f
 ldd _game
 cmpd #2
10
 lbne L84
11
 lbra L71
L84
* Begin expression - 304
 ldd _al_num
 subd #11
 std -6,y
L85
* Begin expression - 304
 ldd -6,y
 lblt L86
* Begin expression - 305
 lslb
 rola
 ldx #_al_row
 ldd d,x
 lbeq L88
 lbra L71
L88
L87
* Begin expression - 306
 ldd -6,y
 subd #11
 std -6,y
 lbra L85
L86
* Begin expression - 309
 ldd _al_num
 lslb
 rola
 ldx #_al_col
 ldd d,x
 cmpd _bas_col
 lblt L89
 ldd _al_num
 lslb
 rola
 ldx #_al_col
 leax d,x
 ldd _bas_col
 addd #3
 cmpd 0,x
 lble L89
 ldd _al_num
 lslb
 rola
 ldx #_al_row
 ldd d,x
 cmpd #20
10
 lbgt L89
* Begin expression - 310
 ldd #0
 std -6,y
L90
* Begin expression - 310
 ldd -6,y
 cmpd #4
 lbge L91
* Begin expression - 311
 lslb
 rola
 ldx #_bmb_row
 ldd d,x
 lbne L93
* Begin expression - 312
 ldd -6,y
 lslb
 rola
 ldx #_bmb_row
 leax d,x
 ldd _al_num
 lslb
 rola
 stx 0,s
 ldx #_al_row
 ldd d,x
 std [0,s]
* Begin expression - 313
 ldd -6,y
 lslb
 rola
 ldx #_bmb_col
 leax d,x
 ldd _al_num
 lslb
 rola
 stx 0,s
 ldx #_al_col
 ldd d,x
 addd #2
 std [0,s]
* Begin expression - 314
 inc _bmb_cnt+1
 lbne L91
 inc _bmb_cnt
 lbra L91
L93
L92
* Begin expression - 317
 inc -5,y
 lbne L90
 inc -6,y
 lbra L90
L91
L89
 lbra L71
L72 equ 8
L71
 leas -4,y
 puls x,y,u,pc
 end
 name autil.c
 text
 bss
 global _mode
_mode rmb 6
 text
 global _pos
_pos pshs u,y,x
 leay 4,s
* Auto 4 row
* Auto 6 col
 leas -L2,s
* Begin expression - 17
 ldd #27
 std 0,s
 jsr _putchar
* Begin expression - 18
 ldb #91
 sex
 std 0,s
 jsr _putchar
* Begin expression - 19
 ldd 4,y
 std 0,s
 jsr _aschar
* Begin expression - 20
 ldb #59
 sex
 std 0,s
 jsr _putchar
* Begin expression - 21
 ldd 6,y
 std 0,s
 jsr _aschar
* Begin expression - 22
 ldb #72
 sex
 std 0,s
 jsr _putchar
L2 equ 4
L1
 leas -4,y
 puls x,y,u,pc
 global _aschar
_aschar pshs u,y,x
 leay 4,s
* Auto 4 x
 leas -L4,s
* Begin expression - 27
 inc 5,y
 bne 1f
 inc 4,y
1
* Begin expression - 28
 ldd 4,y
 cmpd #9
 lble L5
* Begin expression - 29
 std 0,s
 ldd #10
 jsr idiv
 ldx #L6
 ldb d,x
 sex
 std 0,s
 jsr _putchar
 data
L6 fcb 48,49,50,51,52,53,54,55,56,57,0
 text
* Begin expression - 30
 ldd 4,y
 std 0,s
 ldd #10
 jsr imod
 std 4,y
L5
* Begin expression - 32
 ldd 4,y
 ldx #L7
 ldb d,x
 sex
 std 0,s
 jsr _putchar
 data
L7 fcb 48,49,50,51,52,53,54,55,56,57,0
L4 equ 4
 text
L3
 leas -4,y
 puls x,y,u,pc
 global _clr
_clr pshs u,y,x
 leay 4,s
 leas -L9,s
* Begin expression - 40
 ldd #0
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 41
 ldx #L10
 stx 0,s
 jsr _printf
 data
L10 fcb 27,91,50,74,0
 text
* Begin expression - 42
 jsr _flush
* Begin expression - 43
 ldd #3
 std 0,s
 jsr _sleep
L9 equ 4
L8
 leas -4,y
 puls x,y,u,pc
 global _ds_obj
_ds_obj pshs u,y,x
 leay 4,s
* Auto 4 class
 leas -L12,s
* Begin expression - 52
 ldd _game
 cmpd #4
 lbne L13
 ldd 4,y
 lblt L13
 cmpd #5
10
 lbgt L13
* Begin expression - 52
 ldd #6
 std 4,y
L13
* Begin expression - 53
 ldd 4,y
 lbra L15
L16
* Begin expression - 55
 ldx #L17
 stx 0,s
 jsr _printf
 data
L17 fcb 32,79,88,79,32,0
 text
 lbra L14
L18
* Begin expression - 57
 ldx #L19
 stx 0,s
 jsr _printf
 data
L19 fcb 32,88,79,88,32,0
 text
 lbra L14
L20
* Begin expression - 59
 ldx #L21
 stx 0,s
 jsr _printf
 data
L21 fcb 32,92,111,47,32,0
 text
 lbra L14
L22
* Begin expression - 61
 ldx #L23
 stx 0,s
 jsr _printf
 data
L23 fcb 32,47,111,92,32,0
 text
 lbra L14
L24
* Begin expression - 63
 ldx #L25
 stx 0,s
 jsr _printf
 data
L25 fcb 32,34,77,34,32,0
 text
 lbra L14
L26
* Begin expression - 65
 ldx #L27
 stx 0,s
 jsr _printf
 data
L27 fcb 32,119,77,119,32,0
 text
 lbra L14
L28
* Begin expression - 67
 ldx #L29
 stx 0,s
 jsr _printf
 data
L29 fcb 32,32,32,32,32,0
 text
 lbra L14
L30
* Begin expression - 69
 ldx #L31
 stx 0,s
 jsr _printf
 data
L31 fcb 32,120,120,124,120,120,32,0
 text
 lbra L14
L15
 ldx #L10026
 std L10025
L10024 cmpd 0,x++
 bne L10024
 jmp [L10025-L10026,x]
 data
L10026  fdb 0,1,2,3,4,5,6,7
L10025 fdb 0
 fdb L16,L18,L20,L22,L24,L26,L28,L30,L10023
 text
L10023
 text
L14
L12 equ 4
L11
 leas -4,y
 puls x,y,u,pc
 global _instruct
_instruct pshs u,y,x
 leay 4,s
 leas -L33,s
* Begin expression - 76
 jsr _clr
* Begin expression - 77
 ldd #0
 std 0,s
 ldd #0
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 78
 ldx #L34
 stx 0,s
 jsr _printf
 data
L34 fcb 65,116,116,101,110,116,105,111,110,58,32,65,108,105,101,110
 fcb 32,105,110,118,97,115,105,111,110,32,105,110,32,112,114,111
 fcb 103,114,101,115,115,33,13,13,0
 text
* Begin expression - 79
 ldx #L35
 stx 0,s
 jsr _printf
 data
L35 fcb 32,32,32,32,32,32,32,32,84,121,112,101,58,32,32,32
 fcb 60,44,62,32,32,32,32,32,116,111,32,109,111,118,101,32
 fcb 116,104,101,32,108,97,115,101,114,32,98,97,115,101,32,108
 fcb 101,102,116,13,0
 text
* Begin expression - 80
 ldx #L36
 stx 0,s
 jsr _printf
 data
L36 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,122,62,32,32,32,32,32,97,115,32,97,98,111,118,101
 fcb 44,32,102,111,114,32,108,101,102,116,105,101,115,13,0
 text
* Begin expression - 81
 ldx #L37
 stx 0,s
 jsr _printf
 data
L37 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,46,62,32,32,32,32,32,116,111,32,104,97,108,116,32
 fcb 116,104,101,32,108,97,115,101,114,32,98,97,115,101,13,0
 text
* Begin expression - 82
 ldx #L38
 stx 0,s
 jsr _printf
 data
L38 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,120,62,32,32,32,32,32,102,111,114,32,108,101,102,116
 fcb 105,101,115,13,0
 text
* Begin expression - 83
 ldx #L39
 stx 0,s
 jsr _printf
 data
L39 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,47,62,32,32,32,32,32,116,111,32,109,111,118,101,32
 fcb 116,104,101,32,108,97,115,101,114,32,98,97,115,101,32,114
 fcb 105,103,104,116,13,0
 text
* Begin expression - 84
 ldx #L40
 stx 0,s
 jsr _printf
 data
L40 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,99,62,32,32,32,32,32,102,111,114,32,108,101,102,116
 fcb 105,101,115,13,0
 text
* Begin expression - 85
 ldx #L41
 stx 0,s
 jsr _printf
 data
L41 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,115,112,97,99,101,62,32,116,111,32,102,105,114,101,32
 fcb 97,32,108,97,115,101,114,32,98,101,97,109,13,13,0
 text
* Begin expression - 86
 ldx #L42
 stx 0,s
 jsr _printf
 data
L42 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,49,62,32,32,32,32,32,116,111,32,112,108,97,121,32
 fcb 66,108,111,111,100,98,97,116,104,13,0
 text
* Begin expression - 87
 ldx #L43
 stx 0,s
 jsr _printf
 data
L43 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,50,62,32,32,32,32,32,116,111,32,112,108,97,121,32
 fcb 87,101,32,99,111,109,101,32,105,110,32,112,101,97,99,101
 fcb 13,0
 text
* Begin expression - 88
 ldx #L44
 stx 0,s
 jsr _printf
 data
L44 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,51,62,32,32,32,32,32,116,111,32,112,108,97,121,32
 fcb 73,110,118,97,115,105,111,110,32,111,102,32,116,104,101,32
 fcb 65,108,105,101,110,115,13,0
 text
* Begin expression - 89
 ldx #L45
 stx 0,s
 jsr _printf
 data
L45 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,52,62,32,32,32,32,32,116,111,32,112,108,97,121,32
 fcb 73,110,118,105,115,105,98,108,101,32,65,108,105,101,110,32
 fcb 87,101,97,115,101,108,115,13,0
 text
* Begin expression - 90
 ldx #L46
 stx 0,s
 jsr _printf
 data
L46 fcb 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
 fcb 60,113,62,32,32,32,32,32,116,111,32,113,117,105,116,13
 fcb 13,0
 text
* Begin expression - 91
 jsr _flush
 lbra L32
L33 equ 4
L32
 leas -4,y
 puls x,y,u,pc
 global _leave
_leave pshs u,y,x
 leay 4,s
 leas -L48,s
* Begin expression - 98
 ldd #0
 std 0,s
 ldd #23
 pshs d
 jsr _pos
 leas 2,s
* Begin expression - 99
 jsr _nl
* Begin expression - 100
 jsr _echo
* Begin expression - 101
 jsr _flush
* Begin expression - 102
 jsr _exit
L48 equ 4
L47
 leas -4,y
 puls x,y,u,pc
 global _sleep
_sleep pshs u,y,x
 leay 4,s
* Auto 4 n
 leas -L50,s
* Auto -6 i
L51
* Begin expression - 106
 ldd 4,y
 tst 5,y
 bne 1f
 dec 4,y
1 dec 5,y
 cmpd #0
 lbeq L52
* Begin expression - 107
 ldd #0
 std -6,y
L53
* Begin expression - 107
 ldd -6,y
 cmpd #10000
 lbge L54
L55
* Begin expression - 107
 inc -5,y
 lbne L53
 inc -6,y
 lbra L53
L54
 lbra L51
L52
L50 equ 6
L49
 leas -4,y
 puls x,y,u,pc
 global _nonl
_nonl pshs u,y,x
 leay 4,s
 leas -L57,s
* Begin expression - 111
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _gtty
 leas 2,s
* Begin expression - 112
 ldd #65519
 andb _mode
 stb _mode
* Begin expression - 113
 ldd #64
 orb _mode
 stb _mode
* Begin expression - 114
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _stty
 leas 2,s
L57 equ 4
L56
 leas -4,y
 puls x,y,u,pc
 global _nl
_nl pshs u,y,x
 leay 4,s
 leas -L59,s
* Begin expression - 117
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _gtty
 leas 2,s
* Begin expression - 118
 ldd #80
 orb _mode
 stb _mode
* Begin expression - 119
 ldd #65471
 andb _mode
 stb _mode
* Begin expression - 120
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _stty
 leas 2,s
L59 equ 4
L58
 leas -4,y
 puls x,y,u,pc
 global _noecho
_noecho pshs u,y,x
 leay 4,s
 leas -L61,s
* Begin expression - 123
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _gtty
 leas 2,s
* Begin expression - 124
 ldd #65533
 andb _mode
 stb _mode
* Begin expression - 125
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _stty
 leas 2,s
L61 equ 4
L60
 leas -4,y
 puls x,y,u,pc
 global _echo
_echo pshs u,y,x
 leay 4,s
 leas -L63,s
* Begin expression - 128
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _gtty
 leas 2,s
* Begin expression - 129
 ldd #2
 orb _mode
 stb _mode
* Begin expression - 130
 ldx #_mode
 stx 0,s
 ldd #0
 pshs d
 jsr _stty
 leas 2,s
L63 equ 4
L62
 leas -4,y
 puls x,y,u,pc
 end
