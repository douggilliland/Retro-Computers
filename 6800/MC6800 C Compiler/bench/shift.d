* disassembly by dynamite+ of shift

* system name equates

term equ 5
stack equ 7
write equ 13

* external label equates

s0148 equ $0148
s014a equ $014a
s014c equ $014c
s015d equ $015d
s015f equ $015f
s0177 equ $0177
s0179 equ $0179


 data $0000

s0000 bra s0004
 neg <s0016
s0004 jsr >s00d7
 puls a,b
 leax ,s
 pshs x
 pshs a,b
 jsr >s001c
 ldd #$0000
 pshs a,b
s0016 equ *-1
 jsr s0116
 neg <s0000
s001c pshs y,u
 jmp >s009f
s0021 leas -8,s
 ldd #$0008
 std 2,s
 clra
 clrb
 std ,s
s002c ldd ,s
 cmpd #$2710
 lbge s009b
 ldd 4,s
 aslb
 rola
 aslb
 rola
 std 6,s
 ldd 4,s
 aslb
 rola
 aslb
 rola
 aslb
 rola
 aslb
 rola
 std 6,s
 ldd 4,s
 pshs a,b
 ldd #$0006
 jsr >s00cb
 std 6,s
 ldd 4,s
 pshs a,b
 ldd #$0008
 jsr >s00cb
 std 6,s
 ldd 4,s
 pshs a,b
 ldd #$000a
 jsr >s00cb
 std 6,s
 ldd 4,s
 pshs a,b
 ldd #$000c
 jsr >s00cb
 std 6,s
 ldd 4,s
 pshs a,b
 ldd #$000e
 jsr >s00cb
 std 6,s
 ldd 4,s
 pshs a,b
 ldd 4,s
 jsr >s00cb
 std 6,s
 ldd ,s
 addd #$0001
 std ,s
 jmp >s002c
s009b leas 8,s
 puls y,u,pc
s009f ldd #$ff76
 jsr >s00f0
 jmp >s0021
 tstb
 beq s00be
s00ab asr 2,s
 ror 3,s
 decb
 bne s00ab
 bra s00be
 tstb
 beq s00be
s00b7 lsr 2,s
 ror 3,s
 decb
 bne s00b7
s00be ldd 2,s
 pshs a,b
 ldd 2,s
 std 4,s
 ldd ,s
 leas 4,s
 rts
s00cb tstb
 beq s00be
s00ce asl 3,s
 rol 2,s
 decb
 bne s00ce
 bra s00be
s00d7 ldx #s0148
 stx s0140
 sts s0142
 sts s0144
 ldd #$ff80
 bra s00f0
 ldd 2,s
 nega
 negb
 sbca #0
s00f0 leax d,s
 cmpx s0144
 bcs s00f8
 rts
s00f8 leax -128,x
 sys stack
 bcs s0104
 stx s0144
 rts
s0104 ldd #$0002
 sys write,s011e,$0019
 swi
 ldd s0142
 subd s0144
 rts
s0116 jsr s0137
 ldd 2,s
 sys term
s011e bpl s014a
 bpl s014c
 bra s0177
 lsrb
 fcb $41
 coma
 fcb $4b
 bra s0179
 rorb
 fcb $45
 fcb $52
 rora
 inca
 clra
 asrb
 bra s015d
 bpl s015f
 bpl s0144
s0137 rts

 bss

 rmb 8
s0140 rmb 2
s0142 rmb 2
s0144 rmb 4

 end s0000
