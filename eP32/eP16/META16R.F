( meta16o.f for weforth, 06sep02cht )
( eP16 v3.01 )
( meta16R.f for Brevia2, 29feb12cht )

HEX
VARIABLE debugging?

: .head ( addr -- addr )
   >IN @ 20 WORD COUNT TYPE SPACE >IN !
   DUP . SPACE
   ;

: cr CR
   debugging? @
   IF .S KEY 0D = ABORT" DONE"
   THEN
   ;

: forth_' ' ;
: forth_dup DUP ;
: forth_drop DROP ;
: forth_over OVER ;
: forth_swap SWAP ;
: forth_@ @ ;
: forth_! ! ;
: forth_and AND ;
: forth_+ + ;
: forth_- - ;
: forth_word WORD ;
: forth_words WORDS ;
: forth_.s .S ;
: CRR cr ;
: forth_.( [COMPILE] .( ;
: forth_count COUNT ;
: forth_r> R> ;
: -or   XOR ;
: >body 5 + ;
: forth_forget FORGET ;

CREATE ram  8000 ALLOT
: reset   ram 8000 0 FILL ; 
: ram@   2 * ram + @ FFFF AND ;
: ram!   2 * ram + 2DUP C!  1+ SWAP FFFF AND 100 / SWAP C! ;
: binary 2 BASE ! ;
: four   3 FOR DUP ram@ 5 U.R  1+ NEXT ;
: show ( a)   0F FOR CR  DUP 6 .R SPACE
      four 2 SPACES four NEXT ;
: showram 0 0B FOR show NEXT DROP ;

VARIABLE hFile
CREATE CRLF-ARRAY 0D C, 0A C,
: CRLF   
      hFile @ 
      CRLF-ARRAY 2
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   ;

: open-mif-file
   Z" mem.mif" 
   $40000000 ( GENERIC_WRITE )
   0 ( share mode )
   0 ( security attribute )
   2 ( CREATE_ALWAYS )
   $80 ( FILE_ATTRIBUTE_NORMAL )
   0 ( hTemplateFile )
   CreateFileA hFile !
   ;
: write-mif-line
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
   ;
: write-mif-header
      hFile @ 
      $" #Format=AddrHex " 
      write-mif-line
      hFile @ 
      $" #Depth=4096 " 
      write-mif-line
      hFile @ 
      $" #Width=32 " 
      write-mif-line
      hFile @ 
      $" #AddrRadix=3 " 
      write-mif-line
      hFile @ 
      $" #DataRadix=3 " 
      write-mif-line
   ;

: write-mif-data
   0 ( initial ram location )
   $1000 FOR AFT
    DUP ram@ IF
      hFile @ 
      OVER
      <# 3A HOLD #S #>
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
      hFile @ 
      OVER ram@ 
      <# #S #>
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
      CRLF
    THEN
      1+
   THEN NEXT
   DROP ( discard ram location )
   ;

: close-mif-file
   hFile @ CloseHandle DROP
   ;

: write-mif-file
   open-mif-file
   write-mif-header
   write-mif-data
   close-mif-file
   ;
   

FLOAD asm16R.f
FLOAD kern16R.f
FLOAD ef16R.f
write-mif-file
FLOAD sim16R.f

