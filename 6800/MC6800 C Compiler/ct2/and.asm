 name and.c
 text
 bss
 global _extv
_extv rmb 2 
 text
 global _main
_main pshs u,y,x
 leay 4,s
 leas -L2,s
* Auto -6 a
* Auto -8 b
* Auto -10 c
* Auto -11 d
* Auto -12 e
* Auto -13 f
 bss
* Static statv
L3 rmb 2 
 text
* Begin expression - 8 
 ldd -8,y
 clra
 std -6,y
* Begin expression - 9 
 ldd -8,y
 clrb
 std -6,y
* Begin expression - 10 
 ldd -8,y
 anda -10,y
 andb -9,y
 std -6,y
* Begin expression - 11 
 ldd -6,y
 stb -13,y
* Begin expression - 12 
 ldb -13,y
 sex
 std -6,y
* Begin expression - 13 
 ldd -8,y
 clra
 andb #12
 std -6,y
* Begin expression - 14 
 ldd -8,y
 addd -10,y
 std 0,s
 ldd _extv
 subd L3
 anda 0,s
 andb 1,s
 std -6,y
* Begin expression - 15 
 ldd -8,y
 addd -10,y
 std 0,s
 ldd -8,y
 subd #100
 anda _extv
 andb _extv+1
 jsr imul
 std -6,y
* Begin expression - 16 
 ldd -8,y
 addd -10,y
 std 0,s
 ldb -13,y
 sex
 addd -8,y
 pshs d
 ldb -11,y
 sex
 jsr imul
 leas 2,s
 anda 0,s
 andb 1,s
 std -6,y
* Begin expression - 17 
 ldd -8,y
 anda _extv
 andb _extv+1
 std -6,y
* Begin expression - 18 
 ldd -8,y
 anda L3
 andb L3+1
 std -6,y
* Begin expression - 19 
 ldb -12,y
 sex
 clra
 andb #63
 stb -11,y
* Begin expression - 20 
 ldb -12,y
 andb -13,y
 stb -11,y
* Begin expression - 21 
 ldb -12,y
 sex
 clra
 stb -11,y
* Begin expression - 22 
 ldb -12,y
 sex
 stb -11,y
* Begin expression - 23 
 ldd -8,y
 std -6,y
L2 equ 11
L1 
 leas -4,y
 puls x,y,u,pc
 end
