* disassembly by dynamite+ of t7

* system name equates

term equ 5
stack equ 7
write equ 13

* external label equates

s0110 equ $0110
s0112 equ $0112
s0114 equ $0114
s0125 equ $0125
s0127 equ $0127
s013f equ $013f
s0141 equ $0141


 data $0000

s0000 bra s0004
 neg <s0016
s0004 jsr >s009f
 puls a,b
 leax ,s
 pshs x
 pshs a,b
 jsr >s001c
 ldd #$0000
 pshs a,b
s0016 equ *-1
 jsr >s00de
 neg <s0000
s001c pshs y,u
 leas -6,s
 ldd #$0003
 std 4,s
 clra
 clrb
 std 2,s
s0029 ldd 2,s
 cmpd #$4e20
 lbge s0048
 ldd 4,s
 pshs a,b
 ldd 4,s
 jsr >s004c
 std ,s
 ldd 2,s
 addd #$0001
 std 2,s
 jmp >s0029
s0048 leas 6,s
 puls y,u,pc
s004c tsta
 bne s0061
 tst 2,s
 bne s0061
 lda 3,s
 mul
 ldx ,s
 stx 2,s
 ldx #s0000
 std ,s
 puls a,b,pc
s0061 pshs a,b
 ldd #$0000
 pshs a,b
 pshs a,b
 lda 5,s
 ldb 9,s
 mul
 std 2,s
 lda 5,s
 ldb 8,s
 mul
 addd 1,s
 std 1,s
 bcc s007e
 inc ,s
s007e lda 4,s
 ldb 9,s
 mul
 addd 1,s
 std 1,s
 bcc s008b
 inc ,s
s008b lda 4,s
 ldb 8,s
 mul
 addd ,s
 std ,s
 ldx 6,s
 stx 8,s
 ldx ,s
 ldd 2,s
 leas