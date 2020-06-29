* disassembly by dynamite+ of t

* system name equates

term equ 5

s0000 leax 2,s
 ldd ,s
 pshs a,b,x
 jsr >s0010
 ldd #$0000
 clra
 sys term
s0010 pshs y,u
 leay 2,s
 leas >-4,s
 ldd -6,y
 addd #$0001
 std -6,y
 leas -2,y
 puls y,u,pc

 end s0000
