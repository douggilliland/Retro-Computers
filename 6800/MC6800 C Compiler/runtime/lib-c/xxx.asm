 name tostr.c
 text
 global __ltostr
__ltostr pshs u,y
 leay 2,s
 leas -L2,s
* Auto 4 val
* Auto 8 base
* Begin expression - 0
 ldu 10,y
* Register 128 digits
* Auto 12 sign
* Auto -4 p
* Auto -6 b
* Auto -10 i
* Auto -14 j
 bss
* Static staticb
L3L3
 rmb 33
 text
* Begin expression - 95
 ldd 8,y
 cmpd #2
 blt 11f
 stu 0,s
 jsr _strlen
 cmpd 8,y
10
 lbge L4
11
* Begin expression - 96
 ldx #0
 lbra L1
L4
* Begin expression - 98
 ldx 12,y
 lbeq L5
* Begin expression - 99
 ldd #0
 pshs d
 bmi 1f
 ldd #0
 bra 2f
1 ldd #$ffff
2 pshs d
 leax 4,y
 jsr pshlong
 jsr cmplong
 cmpx #0
 lbge L6
 leas 8,s
* Begin expression - 101
 leax 4,y
 jsr pshlong
 jsr neglong
 leax 4,y
 jsr asnlong
 leas 4,s
* Begin expression - 102
 ldd #-1
 std [12,y]
 lbra L7
L6
* Begin expression - 104
 ldd #0
 std [12,y]
L7
L5
* Begin expression - 106
 ldx #L3+32
 stx -4,y
 clr 0,x
* Begin expression - 107
 ldd 8,y
 std -6,y
* Begin expression - 108
 leax 4,y
 jsr pshlong
 ldd 2,s
 leas 4,s
 pshs d
 ldd #0
 pshs d
 leax -10,y
 jsr asnlong
 leas 4,s
* Begin expression - 109
 ldd #0
 pshs d
 bmi 1f
 ldd #0
 bra 2f
1 ldd #$ffff
2 pshs d
 leax -10,y
 jsr pshlong
 jsr cmplong
 cmpx #0
 lbne L8
 leas 8,s
* Begin expression - 109
 ldb 0,u
 ldx -4,y
 stb 0,-x
 stx -4,y
 lbra L9
L8
L10
* Begin expression - 110
 ldd #0
 pshs d
 bmi 1f
 ldd #0
 bra 2f
1 ldd #$ffff
2 pshs d
 leax -10,y
 jsr pshlong
 jsr cmplong
 cmpx #0
 lbeq L11
 leas 8,s
* Begin expression - 112
 leax -10,y
 jsr pshlong
 leax -14,y
 jsr asnlong
 leas 4,s
* Begin expression - 113
 ldd -6,y
 pshs d
 ldd #0
 pshs d
 leax -10,y
 jsr pshlong
 jsr rudivlong
 leax -10,y
 jsr asnlong
 ldd -6,y
 pshs d
 ldd #0
 pshs d
 jsr umullong
 pshs x
 leax -14,y
 jsr pshlong
 jsr rsublong
 ldd 