 name kntshrt.c
 text
 bss
 global _h
_h rmb 72
 data
 global _a
_a fdb 0,2,1,65535,65534,65534,65535,1,2
 global _b
_b fdb 0,1,2,2,1,65535,65534,65534,65535
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -6 i
* Auto -8 j
* Auto -10 q
* Begin expression - 13
 ldd #1
 std -6,y
L3
* Begin expression - 13
 ldd -6,y
 cmpd #6
 lbge L4
* Begin expression - 14
 ldd #1
 std -8,y
L6
* Begin expression - 14
 ldd -8,y
 cmpd #6
 lbge L7
* Begin expression - 15
 ldd -6,y
 std 0,s
 ldd #12
 jsr imul
 ldx #_h
 leax d,x
 ldd -8,y
 lslb
 rola
 leax d,x
 ldd #0
 std 0,x
L8
* Begin expression - 15
 inc -7,y
 lbne L6
 inc -8,y
 lbra L6
L7
L5
* Begin expression - 15
 inc -5,y
 lbne L3
 inc -6,y
 lbra L3
L4
* Begin expression - 16
 ldd #1
 std _h+14
* Begin expression - 17
 leax -10,y
 stx 0,s
 ldd #1
 pshs d
 ldd #1
 pshs d
 ldd #2
 pshs d
 jsr _try
 leas 6,s
L2 equ 10
L1
 leas -4,y
 puls x,y,u,pc
 global _try
_try pshs u,y,x
 leay 4,s
* Auto 4 i
* Auto 6 x
* Auto 8 y
* Auto 10 q
 leas -L10,s
* Auto -6 k
* Auto -8 u
* Auto -10 v
* Auto -12 q1
* Begin expression - 26
 ldd #0
 std -6,y
L11
* Begin expression - 28
 inc -5,y
 bne 1f
 inc -6,y
1
* Begin expression - 29
 ldd #0
 std -12,y
* Begin expression - 30
 ldd -6,y
 lslb
 rola
 ldx #_a
 ldd d,x
 addd 6,y
 std -8,y
* Begin expression - 31
 ldd -6,y
 lslb
 rola
 ldx #_b
 ldd d,x
 addd 8,y
 std -10,y
* Begin expression - 32
 ldd -8,y
 cmpd #1
 lblt L14
 cmpd #6
 lbge L14
 ldd -10,y
 cmpd #1
 lblt L14
 cmpd #6
10
 lbge L14
* Begin expression - 33
 ldd -8,y
 std 0,s
 ldd #12
 jsr imul
 ldx #_h
 leax d,x
 ldd -10,y
 lslb
 rola
 ldd d,x
 lbne L15
* Begin expression - 34
 ldd -8,y
 std 0,s
 ldd #12
 jsr imul
 ldx #_h
 leax d,x
 ldd -10,y
 lslb
 rola
 leax d,x
 ldd 4,y
 std 0,x
* Begin expression - 35
 ldd 4,y
 cmpd #25
 lbge L16
* Begin expression - 36
 leax -12,y
 stx 0,s
 ldd -10,y
 pshs d
 ldd -8,y
 pshs d
 ldd 4,y
 addd #1
 pshs d
 jsr _try
 leas 6,s
* Begin expression - 37
 ldd -12,y
 lbne L17
* Begin expression - 38
 ldd -8,y
 std 0,s
 ldd #12
 jsr imul
 ldx #_h
 leax d,x
 ldd -10,y
 lslb
 rola
 leax d,x
 ldd #0
 std 0,x
L17
 lbra L18
L16
* Begin expression - 41
 ldd #1
 std -12,y
L18
L15
L14
L12
* Begin expression - 43
 ldd -12,y
 lbne L13
 ldd -6,y
 cmpd #8
10
 lbne L11
L13
* Begin expression - 44
 ldd -12,y
 std [10,y]
L10 equ 12
L9
 leas -4,y
 puls x,y,u,pc
 end
