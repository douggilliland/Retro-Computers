 name p1-out.c
 text
 global _outextd
_outextd pshs u,y
 leay 2,s
 leas -L2,s
* Begin expression - 24
 jsr _outbss
* Begin expression - 25
 ldx _symloc
 ldx 4,x
 stx 0,s
 jsr _outglob
* Begin expression - 26
 ldx _symloc
 ldx 4,x
 stx 0,s
 jsr _outdnam
* Begin expression - 27
 ldx _symloc
 stx 0,s
 jsr _sizeit
 std 0,s
 jsr _outsspa
L1
L2 equ 2
 leas -2,y
 puls y,u,pc
 global _outiext
_outiext pshs u,y
 leay 2,s
 leas -L4,s
* Begin expression - 33
 jsr _outdata
* Begin expression - 34
 ldx _symloc
 ldx 4,x
 stx 0,s
 jsr _outglob
* Begin expression - 35
 ldx _symloc
 ldx 4,x
 stx 0,s
 jsr _outdnam
L3
L4 equ 2
 leas -2,y
 puls y,u,pc
 global _outdnam
_outdnam pshs u,y
 leay 2,s
 leas -L6,s
* Auto 4 name
* Begin expression - 43
 ldx 4,y
 stx 0,s
 ldd #150
 pshs d
 ldx #L7
 pshs x
 jsr _outil
 leas 4,s
L5
L6 equ 2
 leas -2,y
 puls y,u,pc
 global _outglob
_outglob pshs u,y
 leay 2,s
 leas -L9,s
* Auto 4 name
* Begin expression - 51
 ldx 4,y
 stx 0,s
 ldd #160
 pshs d
 ldx #L10
 pshs x
 jsr _outil
 leas 4,s
L8
L9 equ 2
 leas -2,y
 puls y,u,pc
 global _outsspa
_outsspa pshs u,y
 leay 2,s
 leas -L12,s
* Auto 4 size
* Begin expression - 62
 ldd 4,y
 std 0,s
 ldd #147
 pshs d
 ldx #L13
 pshs x
 jsr _outil
 leas 4,s
L11
L12 equ 2
 leas -2,y
 puls y,u,pc
 global _outtext
_outtext pshs u,y
 leay 2,s
 leas -L15,s
* Begin expression - 69
 ldb _cspace
 lbeq L16
* Begin expression - 70
 clr _cspace
* Begin expression - 71
 ldd #144
 std 0,s
 ldx #L17
 pshs x
 jsr _outil
 leas 2,s
L16
L14
L15 equ 2
 leas -2,y
 puls y,u,pc
 global _outdata
_outdata pshs u,y
 leay 2,s
 leas -L19,s
* Begin expression - 78
 ldb _cspace
 cmpb #1
 lbeq L20
* Begin expression - 79
 ldb #1
 stb _cspace
* Begin expression - 80
 ldd #145
 std 0,s
 ldx #L21
 pshs x
 jsr _outil
 leas 2,s
L20
L18
L19 equ 2
 leas -2,y
 puls y,u,pc
 global _outbss
_outbss pshs u,y
 leay 2,s
 leas -L23,s
* Begin expression - 87
 ldb _cspace
 cmpb #2
 lbeq L24
* Begin expression - 88
 ldb #2
 stb _cspace
* Begin expression - 89
 ldd #146
 std 0,s
 ldx #L25
 pshs x
 jsr _outil
 leas 2,s
L24
L22
L23 equ 2
 leas -2,y
 puls y,u,pc
 global _outautd
_outautd pshs u,y
 leay 2,s
 leas -L27,s
* Begin expression - 96
 ldx _symloc
 ldx 4,x
 stx 0,s
 ldx _symloc
 ldd 6,x
 pshs d
 ldd #141
 pshs d
 ldx #L28
 pshs x
 jsr _outil
 leas 6,s
L26
L27 equ 2
 leas -2,y
 puls y,u,pc
 global _outstdf
_outstdf pshs u,y
 leay 2,s
 leas -L30,s
* Begin expression - 102
 jsr _outbss
* Begin expression - 103
 ldx _symloc
 ldx 4,x
 stx 0,s
 ldx _symloc
 ldd 6,x
 pshs d
 ldd #140
 pshs d
 ldx #L31
 pshs x
 jsr _outil
 leas 6,s
* Begin expression - 104
 ldx _symloc
 ldd 6,x
 std 0,s
 ldd #134
 pshs d
 ldx #L32
 pshs x
 jsr _outil
 leas 4,s
* Begin expression - 105
 ldx _symloc
 stx 0,s
 jsr _sizeit
 std 0,s
 jsr _outsspa
L29
L30 equ 2
 leas -2,y
 puls y,u,pc
 global _outistd
_outistd pshs u,y
 leay 2,s
 leas -L34,s
* Begin expression - 111
 jsr _outdata
* Begin expression - 112
 ldx _symloc
 ldx 4,x
 stx 0,s
 ldx _symloc
 ldd 6,x
 pshs d
 ldd #140
 pshs d
 ldx #L35
 pshs x
 jsr _outil
 leas 6,s
* Begin expression - 113
 ldx _symloc
 ldd 6,x
 std 0,s
 ldd #134
 pshs d
 ldx #L36
 pshs x
 jsr _outil
 leas 4,s
L33
L34 equ 2
 leas -2,y
 puls y,u,pc
 global _outlabe
_outlabe pshs u,y
 leay 2,s
 leas -L38,s
* Auto 4 num
* Begin expression - 121
 jsr _outtext
* Begin expression - 122
 ldd 4,y
 std 0,s
 ldd #134
 pshs d
 ldx #L39
 pshs x
 jsr _outil
 leas 4,s
L37
L38 equ 2
 leas -2,y
 puls y,u,pc
 global _outcbra
_outcbra pshs u,y
 leay 2,s
 leas -L41,s
* Auto 4 con
* Auto 6 num
* Auto -4 typ
* Begin expression - 133
 ldx _nxtmat
 ldd -7,x
 std -4,y
* Begin expression - 134
 cmpd #12
 beq 11f
 cmpd #13
10
 lbne L42
11
* Begin expression - 135
 ldd #104
 std 0,s
 jsr _rptern
L42
* Begin expression - 136
 jsr _outtext
* Begin expression - 137
 ldd 6,y
 std 0,s
 ldd 4,y
 pshs d
 ldd #136
 pshs d
 ldx #L43
 pshs x
 jsr _outil
 leas 6,s
L40
L41 equ 4
 leas -2,y
 puls y,u,pc
 global _outbra
_outbra pshs u,y
 leay 2,s
 leas -L45,s
* Auto 4 num
* Begin expression - 145
 jsr _outtext
* Begin expression - 146
 ldd 4,y
 std 0,s
 ldd #135
 pshs d
 ldx #L46
 pshs x
 jsr _outil
 leas 4,s
L44
L45 equ 2
 leas -2,y
 puls y,u,pc
 global _outswit
_outswit pshs u,y
 leay 2,s
 leas -L48,s
* Auto 4 lineno
* Auto 6 marker
* Begin expression - 155
 ldd _deflab
 std 0,s
 ldd 4,y
 pshs d
 ldd #139
 pshs d
 ldx #L49
 pshs x
 jsr _outil
 leas 6,s
L50
* Begin expression - 156
 ldx 6,y
 cmpx _nxtsw
 lbeq L51
* Begin expression - 160
 ldd [6,y]
 std 0,s
 ldx 6,y
 ldd 2,x
 pshs d
 ldx #L52
 pshs x
 jsr _outil
 leas 4,s
* Begin expression - 162
 ldx 6,y
 leax 4,x
 stx 6,y
 lbra L50
L51
* Begin expression - 164
 ldb #1
 stb _cspace
* Begin expression - 168
 ldd #0
 std 0,s
 ldx #L53
 pshs x
 jsr _outil
 leas 2,s
L47
L48 equ 2
 leas -2,y
 puls y,u,pc
 global _outregd
_outregd pshs u,y
 leay 2,s
 leas -L55,s
* Begin expression - 0
 ldu 4,y
* Register 128 sym
* Begin expression - 177
 ldx 4,u
 stx 0,s
 ldd 6,u
 pshs d
 ldd #142
 pshs d
 ldx #L56
 pshs x
 jsr _outil
 leas 6,s
L54
L55 equ 2
 leas -2,y
 puls y,u,pc
 global _outstrg
_outstrg pshs u,y
 leay 2,s
 leas -L58,s
* Begin expression - 183
 ldx #_strngbf
 stx 0,s
 ldd _label
 pshs d
 ldd #154
 pshs d
 ldx #L59
 pshs x
 ldd _fstr
 pshs d
 jsr _outil
 leas 8,s
L57
L58 equ 2
 leas -2,y
 puls y,u,pc
 global _obytes
_obytes pshs u,y
 leay 2,s
 leas -L61,s
* Auto -4 i
* Begin expression - 191
 ldb _ibindx
 sex
 std 0,s
 ldd #148
 pshs d
 ldx #L62
 pshs x
 jsr _outil
 leas 4,s
* Begin expression - 192
 ldd #0
 std -4,y
L63
* Begin expression - 192
 ldb _ibindx
 sex
 std 0,s
 ldd -4,y
 cmpd 