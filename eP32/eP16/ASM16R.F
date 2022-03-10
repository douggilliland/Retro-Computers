HEX

VARIABLE h
VARIABLE lasth 0 lasth !                  \ init linkfield address lfa

: namer! ( d -- )
   h @ ram!                             \ store double to code buffer
   1 h +!                             \ bump nameh
   ;

: COMPILE-ONLY 40 lasth @ ram@ XOR lasth @ ram! ;
: IMMEDIATE    80 lasth @ ram@ XOR lasth @ ram! ;

VARIABLE hi   VARIABLE hw VARIABLE bi ( for packing)
: align   0C hi ! ;
: org   DUP . CR h !  align ;
: allot ( n -- ) h +! ;

CREATE mask  7C00 ,  3E0 ,  1F ,
: #,   ( d ) h @ ram!  1 h +! ;
: ,w   ( d ) hw @ ram@  OR  hw @ ram! ;
: ,i   ( d ) hi @ 0C =  IF  0 hi !  h @ hw !  8000 #,  THEN
             hi @ mask + @ AND  ,w  4 hi +! ;
: spread ( n - d ) DUP 20 * DUP 20 * + + ;
: ,l   ( n ) spread ,i ;
: ,b   bi @ 0 = IF 1 bi ! h @ hw ! 0 #, ,w      
       ELSE 0 bi ! 100 * ,w THEN ;              

: inst CONSTANT DOES> R> @ ,i ;
1E spread inst nop

: anew BEGIN hi @ 0C < WHILE nop REPEAT 0 bi ! ;
: # ( d )  0A spread ,i  #, ;
: ldi # ;
: LIT ( d -- ) # ;
: call ( a ) anew #, ;

: (makehead)
   anew
   20 WORD                                \ get name of new definition
   lasth @ namer!                         \ fill link field of last word
   h @ lasth !                        \ save nfa in lasth
   COUNT DUP ,b                                \ store count
   1- FOR 
      COUNT ,b                              \ fill name field
   NEXT
   DROP anew
   ;

: makehead
   >IN @ >R                               \ save interpreter pointer
   (makehead)
   R> >IN !                               \ restore word pointer
   ;

: $LIT ( -- )
   anew
   22 WORD
   COUNT DUP ,b ( compile count )
   1- FOR 
      COUNT ,b ( compile characters )
   NEXT
   DROP anew ;


: jump CONSTANT DOES> anew 3FF AND R> @ OR #, ;
   8000 jump bra           
   8000 jump jmp
   8800 jump bz
   8C00 jump bc
   9400 jump next
   9400 jump NEXT
   9400 jump <NEXT>

: return CONSTANT DOES> R> @ ,i anew ;
 1 spread return ret
 6 spread return times

: begin anew h @ ;
: until bz ;
: untilnc bc ;

: if      h @ 0 bz ;  ( 8800 )
: ifnc    h @ 0 bc ;  ( 8C00 )
: skip    h @ 0 bra ; ( 8000 )
: then    begin 3FF AND OVER ram@ OR SWAP ram! ;
: else    skip  SWAP then ;
: while   if SWAP ;
: whilenc ifnc  SWAP ;
: repeat  bra then ;
: again   bra ;
: aft ( a -- a' a" )
   DROP skip begin SWAP ;

: BEGIN anew h @ ;
: UNTIL bz ;
: UNTILNC bc ;
: JMP  bra ;

: IF      if ;  
: IFNC    ifnc ;  
: SKIP    skip ; 
: THEN    then ;
: ELSE    else ;
: WHILE   while ;
: WHILENC whilenc ;
: REPEAT  repeat ;
: AGAIN   bra ;
: AFT 	  aft ;

: ':   begin  .head CONSTANT  DOES> R> @  call ;
: CODE  makehead ': ;            \ for eforth kernel words
: code  makehead ': ;            \ for eforth kernel words

  08 spread inst ldrp  09 spread inst ldp ( 0A spread inst ldi)  0B spread inst ld
  0C spread inst strp  0D spread inst stp   0E spread inst rr8   0F spread inst st
  10 spread inst com   11 spread inst shl   12 spread inst shr   13 spread inst mul
  14 spread inst xor   15 spread inst and   16 spread inst div   17 spread inst add
  18 spread inst popr  19 spread inst lda   1A spread inst pushs 1B spread inst over
  1C spread inst pushr 1D spread inst sta ( 1E spread inst nop ) 1F spread inst pops

: for ( -- a )
   pushr begin ;
: FOR ( -- a )
   pushr begin ;




















