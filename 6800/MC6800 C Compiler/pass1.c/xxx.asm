 name xx.c
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -4 a
* Auto -8 b
* Auto -12 c
* Auto -16 d
* Auto -20 e
* Auto -24 p
* Auto -28 p2
* Begin expression - 5
 ldd -4,y
 addd -8,y
 ldx [-28,y]
 ldx 0,x
 stx 0,s
 pshs d
 jsr _fun
 addd [0,s]
 addd 0,s++
 tfr d,x
 stx -24,y
L1
L2 equ 30
 leas -4,y
 puls x,y,u,pc
 data
 text
 end
