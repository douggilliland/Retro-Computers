 name sss.c
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -6 a
* Auto -8 b
* Auto -10 c
* Auto -12 d
* Begin expression - 4
 ldd -6,y
 cmpd #1
 blt 10f
 ldd -8,y
 cmpd #2
 bne 10f
 ldd -10,y
 cmpd #3
10
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1
* Begin expression - 5
 ldd -6,y
 cmpd #1
 blt 10f
 ldd -8,y
 cmpd #2
 beq 10f
 ldd -10,y
 cmpd #3
 bge 10f
 ldd -12,y
 cmpd #4
10
 beq 1f
 ldd #0
 bra 2f
1 ldd #1
2
 lbra L1
L2 equ 12
L1
 leas -4,y
 puls x,y,u,pc
 end
