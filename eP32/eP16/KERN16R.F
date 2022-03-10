
HEX
cr .( system variables ) 
: HLD 20 ldi ;         \ scratch
: SPAN 21 ldi ;        \ #chars input by expect
: >IN  22 ldi ;        \ input buffer offset
: #TIB 23 ldi ;        \ #chars in the input buffer
: 'TIB 24 ldi ;        \ tib
: BASE 25 ldi ;       \ number base

cr
: CONTEXT 26 ldi ;    \ first search vocabulary
: CP 27 ldi ;         \ dictionary code pointer
: LAST 28 ldi ;       \ ptr to last name compiled
: 'EVAL 29 ldi ;       \ interpret/compile vector
: 'ABORT 2A ldi ;
: TEXT 30 ldi ;         \ unpack buffer
: tmp 2B ldi ;        \ ptr to converted # string
: cpi 2C ldi ;          \ assembler slot poiner
: cpw 2D ldi ;         \ pointer to word under construction

: etxbuf    FF00 ldi ; 
: etxbempty FF01 ldi ;
: erxbfull  FF02 ldi ;
: erxbuf    FF03 ldi ;

cr .( macro words ) cr
: DOLIT # ;
: EXIT ret ;
: EXECUTE ( a ) pushr ret anew ;
: ! ( n a -- ) sta st ;
: @ ( a - n ) sta ld ;
: R> ( - n ) popr ;
: R@ ( - n ) popr pushs pushr ;
: >R ( n ) pushr ;
: DUP ( n - n n ) pushs ;
: SWAP ( n1 n2 - n2 n1 )
   pushr sta popr lda ;
: DROP ( w w  -- )
   pops ;
: 2DROP ( w w  -- )
   pops pops ;
: + ( w w -- w ) add ;
: NOT ( w -- w ) com ;
: AND and ;
: XOR xor ;
: OVER over ;
: NEGATE ( n -- -n )
   com 1 ldi add ;
: 1- ( a -- a )
   -1 ldi add ;
: 1+ ( a -- a )
   1 ldi add ;
: BL ( -- 32 )
   20 ldi ;
: +! ( n a -- )
   sta ld add st
   ;
: - ( w w -- w )
   com add 1 ldi add
   ;
: OR ( n n - n )
   com pushr com
   popr and com ;
: ROT ( w1 w2 w3 -- w2 w3 w1 )
   pushr pushr sta popr
   popr lda ;
: 2DUP ( w1 w2 -- w1 w2 w1 w2 )
   pushs pushr pushr
   pushs sta popr lda popr
   ;
: 2! ( d a -- )
   sta pushr stp
   popr st ;
: 2@ ( a -- d )
   sta ldp ld ;
: COUNT ( b -- b +n )
   sta ldp pushr lda
   popr ;

cr .( kernel words ) cr
$100 org

code DOVAR popr ret 
code 0< ( n - f )
   shl ifnc pushs pushs xor ret
   then
   -1 ldi ret
code UM+  ( n n - n carry )
   add pushs
   ifnc pushs pushs xor ret
   then
   1 ldi ret
code ?DUP ( w -- w w | 0 )
   pushs
   if pushs ret then
   ret

cr
code DNEGATE ( d -- -d )
   com pushr com 1 ldi
   add pushs
   ifnc popr ret
   then
   popr 1 ldi add ret
code ABS ( n -- +n )
   pushs shl
   ifnc ret then
   NEGATE ret
code = ( w w -- t )
   xor
   if pushs pushs xor ret then
   -1 ldi ret

cr ( pack b> and unpack >b strings )
code B> ( b a -- b+1 a )
   pushr sta ldp pushr
   lda popr popr sta
   $FF ldi and
   ld $FF00 ldi and xor
   rr8 st lda ret
code >B ( a b -- a+1 b+2 count )
   pushr sta ldp pushr
   lda popr popr ( a+1 n b ) sta 
   pushs $FF ldi and stp rr8
   pushs $FF ldi and stp rr8
   pushr lda popr $FF ldi and
   ret


