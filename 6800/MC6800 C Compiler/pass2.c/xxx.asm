 name t1.c
 text
 bss
 global _p
_p rmb 2
 global _l
_l rmb 4
 text
 global _main
_main pshs u,y
 leay 2,s
 leas -L2,s
* Begin expression - 4
 ldd _l
 ldx _p
 ldb d,x
 sex
 pshs d
 bmi 1f
 ldd #0
 bra 2f
1 ldd #$ffff
2 pshs d
 ldx #_l
 jsr asnlong
 leas 4,s
* Begin expression - 5
 ldx _l
 stx _p
* Begin expression - 6
 ldx #_p
 jsr pshlong
 ldx #_l
 jsr asnlong
 leas 4,s
L1
L2 equ 2
 leas -2,y
 puls y,u,pc
 data
 text
 end
