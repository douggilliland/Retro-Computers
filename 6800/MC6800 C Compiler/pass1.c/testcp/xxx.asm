 name subs.c
 text
 data
 global _d_error
_d_error fdb 0
 global _comtab
_comtab fdb L1,_define
 fdb L2,_include
 fdb L3,_info
 fdb L4,_info
 fdb L5,_line_co
 fdb L6,_undef
 fdb 0,0,0,0
 global _iftab
_iftab fdb L7,_ifexpr
 fdb L8,_ifdef
 fdb L9,_ifndef
 fdb L10,_else_co
 fdb L11,_endif
 fdb 0,0,0,0
 text
 global _aname
_aname pshs u,y
 leay 2,s
 leas -L13,s
* Begin expression - 0
 ldu 4,y
* Register 128 tp
* Auto 6 p
* Auto -4 chrcnt
* Auto -5 chr
* Auto -7 cp
* Begin expression - 72
 ldx 6,u
 stx 4,u
 stx -7,y
* Begin expression - 73
 ldd #0
 std -4,y
L14
* Begin expression - 75
 ldx -7,y
 ldb 0,x+
 stx -7,y
 stb -5,y
* Begin expression - 76
 inc -3,y
 bne 1f
 inc -4,y
1
* Begin expression - 77
 ldb -5,y
 cmpb #95
 beq 10f
 ldx #__chcode
 ldb b,x
 sex
 clra
 andb #$6
 beq 11f
10
 ldd #1
 bra 13f
11
 ldb -5,y
 ldx #__chcode
 ldb b,x
 sex
 clra
 andb #$8
 beq 13f
 ldd #2
 bra 14f
13
 ldd #0
14
0
 std _class
 lbeq L17
* Begin expression - 78
 ldd -4,y
 cmpd #9
 lbge L18
* Begin expression - 78
 ldb -5,y
 ldx 6,y
 stb 0,x+
 stx 6,y
L18
L17
L15
* Begin expression - 79
 ldd _class
 lbeq L16
 ldx 2,u
 cmpx -7,y
10
 lbgt L14
L16
* Begin expression - 80
 clr [6,y]
* Begin expression - 81
 ldd _class
 bne 10f
 ldx -7,y
 leax -1,x
 bra 11f
10
 ldx -7,y
11
 stx 4,u
L12
L13 equ 7
 leas -2,y
 puls y,u,pc
 global _command
_command pshs u,y
 leay 2,s
 leas -L20,s
* Auto -11 cname
* Auto -13 fp
* Begin expression - 96
 ldx _rline
 leax 6,x
 stx 0,s
 ldx _rline
 ldx 1,x
 stx [0,s]
L21
* Begin expression - 97
 ldx _rline
 ldb [6,x]
 cmpb #32
 beq 11f
 ldx _rline
 ldb [6,x]
 cmpb #9
10
 lbne L22
11
* Begin expression - 97
 ldx _rline
 leax 6,x
 stx 0,s
 ldx [0,s]
 leax 1,x
 stx [0,s]
 lbra L21
L22
* Begin expression - 98
 ldx _rline
 ldb [6,x]
 cmpb #13
 lbeq L23
* Begin expression - 99
 leax -11,y
 stx 0,s
 ldx _rline
 pshs x
 jsr _aname
 leas 2,s
* Begin expression - 100
 leax -11,y
 stx 0,s
 ldx #_comtab
 pshs x
 jsr _find_co
 tfr d,x
 leas 2,s
 stx -13,y
 lbeq L24
* Begin expression - 101
 ldd _skip
 lbne L25
* Begin expressio