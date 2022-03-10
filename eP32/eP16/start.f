VER VARIABLE FENCE
' FENCE >NAME FENCE !   \ protect system words

: CAPS -1 CAP ! ; CAPS  \ case insensitive mode

HEX
: DOES>                 \  change runtime behavior to following code, para on return stack
  R>                    \ next address of defining word
  LAST @ NAME>          \ cfa of original word
  1+ SWAP               \ skip call code , dovar-addr parent-body
  OVER CELL+ -          \ dovar-addr relative-offset
  SWAP !                \ overwrite doVar to adr
;

: CONSTANT CREATE , DOES> R> @ ;
: TO ' 1+ CELL+ ! ;
: RET, $C3 C, ;

: doFORGET         ( nfa -- )
  FENCE @ MAX DUP               \ check fence  ( nfa nfa -- )
  CELL- @ CURRENT @ !           \ set current
  CP !                          \ adjust cp
;
  
: FORGET ' >NAME ?DUP IF doFORGET THEN ;
: EMPTY FENCE @ doFORGET ;
   
: ANEW 
  BL WORD NAME?           \ cfa nfa 
  ?DUP IF 
    SWAP DROP DUP doFORGET
  THEN
  $,n OVERT RET,
;

FLOAD win32.f     \ win32 interface
FLOAD api.f       \ commonly used API
FLOAD ui.f        \ window stuff

0 CAP !
FLOAD meta16R.f
