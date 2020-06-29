* disassembly by dynamite+ of div2

* system name equates

term equ 5
stack equ 7
write equ 13

* external label equates

s01c2 equ $01c2
s01c3 equ $01c3
s01c6 equ $01c6
s01c8 equ $01c8
s01d4 equ $01d4
s01d6 equ $01d6
s01df equ $01df
s01e4 equ $01e4
s01ff equ $01ff


 data $0000

s0000 bra s0004
 neg <s0016
s0004 jsr s0126
 puls a,b
 leax ,s
 pshs x
 pshs a,b
 jsr >s001c
 ldd #$0000
 pshs a,b
s0016 equ *-1
 jsr s0165
 neg <s0000
s001c pshs y,u
 jmp >s005f
s0021 leas -10,s
 ldd #$2710
 std 6,s
 ldd #$00d4
 std 4,s
 clra
 clrb
 std ,s
s0031 ldd ,s
 cmpd #$ea60
 lbcc s0050
 ldd 6,s
 pshs a,b
 ldd 6,s
 jsr >s00b9
 std 8,s
 ldd ,s
 addd #$0001
 std ,s
 jmp >s0031
s0050 ldd 6,s
 pshs a,b
 ldd 6,s
 jsr >s0073
 std 8,s
 leas 10,s
 puls y,u,pc
s005f ldd #$ff74
 jsr s013f
 jmp >s0021
 clr s01af
 ldx #s00a8
 stx s01b0
 bra s0083
s0073 ldx #s00b9
 stx s01b0
 clr s01af
 tst 2,s
 bpl s0083
 inc s01af
s0083 subd #$0000
 bne s008e
 puls x
 ldd ,s++
 jmp ,x
s008e ldx 2,s
 pshs x
 jsr [s01b0]
 ldd ,s
 std 2,s
 tfr x,d
 tst s01af
 beq s00a5
 nega
 negb
 sbca #0
s00a5 std ,s++
 rts
s00a8 subd #$0000
 lbeq s0186
 pshs a,b
 leas -2,s
 clr ,s
 clr 1,s
 bra s00e0
s00b9 cmpd #$0000
 lbeq s0186
 pshs a,b
 leas -2,s
 clr ,s
 clr 1,s
 tsta
 bpl s00d4
 nega
 negb
 sbca #0
 inc 1,s
 std 2,s
s00d4 ldd 6,s
 bpl s00e0
 nega
 negb
 sbca #0
 com 1,s
 std 6,s
s00e0 lda #1
s00e2 inca
 asl 3,s
 rol 2,s
 bpl s00e2
 sta ,s
 ldd 6,s
 clr 6,s
 clr 7,s
s00f1 subd 2,s
 bcc s00fb
 addd 2,s
 andcc #$fe
 bra s00fd
s00fb orcc #1
s00fd rol 7,s
 rol 6,s
 lsr 2,s
 ror 3,s
 dec ,s
 bne s00f1
 std 2,s
 tst 1,s
 beq s0117
 ldd 6,s
 nega
 negb
 sbca #0
 std 6,s
s0117 ldx 4,s
 ldd 6,s
 std 4,s
 stx 6,s
 ldx 2,s
 ldd 4,s
 leas 6,s
 rts
s0126 ldx #s01c2
 stx s01ba
 sts s01bc
 sts s01be
 ldd #$ff80
 bra s013f
 ldd 2,s
 nega
 negb
 sbca #0
s013f leax d,s
 cmpx s01be
 bcs s0147
 rts
s0147 leax -128,x
 sys stack
 bcs s0153
 stx s01be
 rts
s0153 ldd #$0002
 sys write,s016d,$0019
 swi
 ldd s01bc
 subd s01be
 rts
s0165 jsr s01ae
 ldd 2,s
 sys term
s016d bpl s0199
 bpl s019b
 bra s01c6
 lsrb
 fcb $41
 coma
 fcb $4b
 bra s01c8
 rorb
 fcb $45
 fcb $52
 rora
 inca
 clra
 asrb
 bra s01ac
 bpl s01ae
 bpl s0193
s0186 clra
 clrb
 sys write,s0195,$0019
 ldd #$0001
 sys term
s0193 equ *-2
s0195 bpl s01c1
 bpl s01c3
s0199 bra s01df
s019b rola
 rorb
 rola
 lsra
 fcb $45
 bra s01e4
 rolb
 bra s01ff
 fcb $45
 fcb $52
 clra
 bra s01d4
 bpl s01d6
s01ac bpl s01bb
s01ae rts

 bss

s01af rmb 1
s01b0 rmb 10
s01ba rmb 1
s01bb rmb 1
s01bc rmb 2
s01be rmb 3
s01c1 rmb 1

 end s0000
