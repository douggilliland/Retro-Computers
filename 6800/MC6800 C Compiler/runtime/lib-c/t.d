* disassembly by dynamite+ of t

* system name equates

term equ 5
stack equ 7
write equ 13

* external label equates

s00e8 equ $00e8
s00ef equ $00ef
s00f1 equ $00f1
s0109 equ $0109
s010b equ $010b


 data $0000

s0000 bra s0004
 neg <s0016
s0004 jsr >s0069
 puls a,b
 leax ,s
 pshs x
 pshs a,b
 jsr >s001c
 ldd #$0000
 pshs a,b
s0016 equ *-1
 jsr >s00a8
 neg <s0000
s001c pshs y,u
 jmp >s0038
s0021 ldx #s00d4
 ldd 2,x
 pshs a,b
 ldd ,x
 pshs a,b
 ldx #s0041
 jsr >s0045
 lblt s0036
s0036 puls y,u,pc
s0038 ldd