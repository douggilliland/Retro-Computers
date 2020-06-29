 name ind.c
 text
 bss
 global _a1
_a1 rmb 2
 global _a2
_a2 rmb 2
 global _a3
_a3 rmb 2
 global _a4
_a4 rmb 2
 global _a5
_a5 rmb 2
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -6 i
* Auto -8 p
* Begin expression - 7
 ldd [_a1]
 std -6,y
* Begin expression - 8
 ldx [_a2]
 ldd 0,x
 std -6,y
* Begin expression - 9
 ldx [_a3]
 ldd [0,x]
 std -6,y
* Begin expression - 10
 ldx [_a4]
 ldx [0,x]
 ldd 0,x
 std -6,y
* Begin expression - 11
 ldx [_a5]
 ldx [0,x]
 ldd [0,x]
 std -6,y
* Begin expression - 12
 ldx _a1
 stx -8,y
* Begin expression - 13
 ldx [_a2]
 stx -8,y
* Begin expression - 14
 ldx [_a3]
 ldx 0,x
 stx -8,y
* Begin expression - 15
 ldx [_a4]
 ldx [0,x]
 stx -8,y
* Begin expression - 16
 ldx [_a5]
 ldx [0,x]
 ldx 0,x
 stx -8,y
L2 equ 8
L1
 leas -4,y
 puls x,y,u,pc
 end
