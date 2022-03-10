: :: code ;
: ;; ret ;

CRR .( Chararter IO ) CRR
:: ?KEY  erxbfull @ ;;
:: KEY   begin erxbfull @ until erxbuf @ ;;      
:: EMIT  begin etxbempty  @ until etxbuf  ! ;;

CRR .( Common functions ) CRR
:: U< ( u u -- t ) 2DUP XOR 0< IF SWAP DROP 0< EXIT THEN - 0< ;;
::  < ( n n -- t ) 2DUP XOR 0< IF      DROP 0< EXIT THEN - 0< ;;
:: MAX ( n n -- n ) 2DUP      < IF SWAP THEN DROP ;;
:: MIN ( n n -- n ) 2DUP SWAP < IF SWAP THEN DROP ;;
:: WITHIN ( u ul uh -- t ) \ ul <= u < uh
   OVER - >R - R> U< ;;

CRR .( Divide ) CRR
CODE UM/MOD ( ud u -- ur uq )
   com 1 ldi add sta
   pushr lda pushr sta
   popr popr
   skip
CODE /MOD ( n n -- r q )
   com 1 ldi add pushr
   sta popr 0 ldi
   then
   div div div div
   div div div div
   div div div div
   div div div div
   div 1 ldi xor shr
   pushr pops popr lda
   ret
CODE MOD ( n n -- r )
   /MOD
   pops ret
CODE / ( n n -- q )
   /MOD
   pushr pops popr ret
:: M/MOD ( d n -- r q ) \ floored
  DUP 0<  DUP >R
  IF NEGATE >R DNEGATE R>
  THEN >R DUP 0< IF R@ + THEN R> UM/MOD R>
  IF SWAP NEGATE SWAP THEN ;;

CRR .( Multiply ) CRR
CODE UM* ( u u -- ud )
   sta 0 ldi
   mul mul mul mul
   mul mul mul mul
   mul mul mul mul
   mul mul mul mul
   pushr pops lda popr
   ret
:: * ( n n -- n ) UM* DROP ;;
:: M* ( n n -- d )
  2DUP XOR 0< >R  ABS SWAP ABS UM*  R> IF DNEGATE THEN ;;
:: */MOD ( n n n -- r q ) >R M* R> M/MOD ;;
:: */ ( n n n -- q ) */MOD SWAP DROP ;;

CRR .( Bits & Bytes ) CRR
:: >CHAR ( c -- c )
  $7F LIT AND DUP $7F LIT BL WITHIN
  IF DROP ( CHAR _ ) $5F LIT THEN ;;

CRR .( Memory access ) CRR
:: HERE ( -- a ) CP @ ;;
:: PAD ( -- a ) CP @ 50 LIT + ;;
:: TIB ( -- a ) 'TIB @ ;;

CRR
:: @EXECUTE ( a -- ) @ ?DUP IF EXECUTE THEN ;;
:: CMOVE ( b b u -- )
  FOR AFT >R DUP @ R@ ! 1+ R> 1+ THEN NEXT 2DROP ;;
:: FILL ( b u c -- )
  SWAP FOR SWAP AFT 2DUP ! 1+ THEN NEXT 2DROP ;;
:: PACK$ ( b u a -- a ) \ null fill
  pushs pushr
  1 ldi tmp sta st
  sta pushs pushr rr8 st
  lda popr
  FOR AFT ( b a )
    B>
    tmp sta ld
    IF   0 ldi st
         1 ldi add
         pushs sta 0 ldi st
    ELSE 1 ldi st
    THEN
  THEN NEXT
  tmp sta ld
  IF sta ld rr8 st
  ELSE pops
  THEN
  pops popr
  ;;
:: //
  $1E LIT and 1 LIT xor
  shr ret
:: UNPACK$ ( a b -- b )
  DUP >R ( save b )
  >B //
  FOR AFT
    >B DROP
  THEN NEXT
  2DROP R>
  ;;

CRR .( Numeric Output ) CRR \ single precision
:: DIGIT ( u -- c )
  9 LIT OVER < 7 LIT AND +
  ( CHAR 0 ) 30 LIT + ;;
:: EXTRACT ( n base -- n c )
  0 LIT SWAP UM/MOD SWAP DIGIT ;;
:: <# ( -- ) PAD HLD ! ;;
:: HOLD ( c -- ) HLD @ 1- DUP HLD ! ! ;;
:: # ( u -- u ) BASE @ EXTRACT HOLD ;;
:: #S ( u -- 0 ) BEGIN # DUP WHILE REPEAT ;;
CRR
:: SIGN ( n -- ) 0< IF ( CHAR - ) 2D LIT HOLD THEN ;;
:: #> ( w -- b u ) DROP HLD @ PAD OVER - ;;
:: str ( n -- b u ) DUP >R ABS <# #S R> SIGN #> ;;
:: HEX ( -- ) 10 LIT BASE ! ;;
:: DECIMAL ( -- ) 0A LIT BASE ! ;;

CRR .( Numeric Input ) CRR \ single precision
:: DIGIT? ( c base -- u t )
  >R ( CHAR 0 ) 30 LIT - 9 LIT OVER <
  IF 7 LIT - DUP 0A LIT  < OR THEN DUP R> U< ;;
:: NUMBER? ( a -- n T | a F )
  BASE @ >R  0 LIT OVER COUNT ( a 0 b n)
  OVER @ ( CHAR $ ) 24 LIT =
  IF HEX SWAP 1+ SWAP 1- THEN ( a 0 b' n')
  OVER @ ( CHAR - ) 2D LIT = >R ( a 0 b n)
  SWAP R@ - SWAP R@ + ( a 0 b" n") ?DUP
  IF 1- ( a 0 b n)
    FOR DUP >R @ BASE @ DIGIT?
      WHILE SWAP BASE @ * +  R> 1+
    NEXT DROP R@ ( b ?sign) IF NEGATE THEN SWAP
      ELSE R> R> ( b index) 2DROP ( digit number) 2DROP 0 LIT
      THEN DUP
  THEN R> ( n ?sign) 2DROP R> BASE ! ;;

CRR .( Basic I/O ) CRR
:: SPACE ( -- ) BL EMIT ;;
:: CHARS ( +n c -- )
  SWAP 0 LIT MAX
  FOR AFT DUP EMIT THEN NEXT DROP ;;
:: SPACES ( +n -- ) BL CHARS ;;
:: TYPE ( b u -- )
  FOR AFT DUP @ >CHAR EMIT 1+
  THEN NEXT DROP ;;
:: CR ( -- ) ( =Cr )
  0A LIT 0D LIT EMIT EMIT ;;
:: do$ ( -- a )
  R> R@ TEXT UNPACK$
  R@ R> @ $FE LIT AND
  1 LIT XOR shr 1+ +
  >R SWAP >R ;;

400 org

CRR
:: $"| ( -- a ) do$ ;; 
:: ."| ( -- ) do$ COUNT TYPE ;;
::  .R ( n +n -- )
  >R str      R> OVER - SPACES TYPE ;;
:: U.R ( u +n -- )
  >R <# #S #> R> OVER - SPACES TYPE ;;
:: U. ( u -- ) <# #S #> SPACE TYPE ;;
::  . ( n -- )
  BASE @ 0A LIT  XOR
  IF U. EXIT THEN str SPACE TYPE ;;
:: ? ( a -- ) @ . ;;

CRR .( Parsing ) CRR
:: (parse) ( b u c -- b u delta ; <string> )
  tmp ! OVER >R DUP \ b u u
  IF 1- tmp @ BL =
    IF              \ b u' \ 'skip'
      FOR BL OVER @ - 0< NOT
        WHILE 1+
      NEXT ( b) R> DROP 0 LIT DUP EXIT \ all delim
        THEN  R>
    THEN OVER SWAP  \ b' b' u' \ 'scan'
    FOR tmp @ OVER @ -  tmp @ BL =
      IF 0< THEN WHILE 1+
    NEXT DUP >R
      ELSE R> DROP DUP 1+ >R
      THEN OVER -  R>  R> - EXIT
  THEN ( b u) OVER R> - ;;
:: PARSE ( c -- b u ; <string> )
  >R  TIB >IN @ +
  #TIB @ >IN @ -
  R> (parse) >IN +! ;;
:: TOKEN ( -- a ;; <string> )
  BL PARSE 1F LIT MIN 2DUP
  DUP TEXT ! TEXT 1+ SWAP CMOVE
  HERE 1+ PACK$ ;;
:: WORD ( c -- a ; <string> )
  PARSE HERE 1+ PACK$ ;;

CRR .( Dictionary Search ) CRR
:: NAME> ( a -- xt )
  DUP @ // + 1+ ;;
:: SAME? ( a a u -- a a f \ -0+ )
  //
  FOR AFT OVER R@ + @
    OVER R@ + @ - ?DUP
    IF R> DROP EXIT THEN
  THEN NEXT
  0 LIT ;;
:: find ( a va -- xt na | a F )
  SWAP         \ va a
  DUP @ tmp !  \ va a  \ get cell count
  DUP @ >R     \ va a  \ count
  1+ SWAP      \ a' va
  BEGIN @ DUP  \ a' na na
    IF DUP @ $FF3F LIT AND
      R@ XOR \ ignore lexicon bits
      IF 1+ -1 LIT
      ELSE 1+ tmp @ SAME?
      THEN
    ELSE R> DROP SWAP 1- SWAP EXIT \ a F
    THEN
  WHILE 1- 1-  \ a' la
  REPEAT R> DROP SWAP DROP
  1- DUP NAME> SWAP ;;
:: NAME? ( a -- xt na | a F )
  CONTEXT find ;;

CRR .( Terminal ) CRR
:: ^H ( b b b -- b b b ) \ backspace
  >R OVER R> SWAP OVER XOR
  IF ( =BkSp ) 8 LIT EMIT
     1-         BL EMIT \ distructive
     ( =BkSp ) 8 LIT EMIT \ backspace
  THEN ;;
:: TAP ( bot eot cur c -- bot eot cur )
  DUP EMIT OVER ! 1+ ;;
:: kTAP ( bot eot cur c -- bot eot cur )
  DUP ( =Cr ) 0D LIT XOR
  IF ( =BkSp ) 8 LIT XOR
    IF BL TAP ELSE ^H THEN
    EXIT
  THEN DROP SWAP DROP DUP ;;

CRR
:: accept ( b u -- b u )
  OVER + OVER
  BEGIN 2DUP XOR
  WHILE  KEY  DUP BL -  5F LIT U<
    IF TAP ELSE kTAP THEN
  REPEAT DROP  OVER - ;;
:: EXPECT ( b u -- ) accept SPAN ! DROP ;;
:: QUERY ( -- )
  TIB 50 LIT accept #TIB !
  DROP 0 LIT >IN ! ;;

CRR .( Error handling ) CRR
:: ABORT ( -- ) 'ABORT @EXECUTE ;;
:: abort" ( f -- )
  IF do$ COUNT TYPE ABORT THEN do$ DROP ;;

CRR .( Interpret ) CRR
:: ERROR ( a -- )
  DROP SPACE TEXT COUNT TYPE
  $3F LIT EMIT CR ABORT
:: $INTERPRET ( a -- )
  NAME?  ?DUP
  IF @ $40 LIT AND
    abort" $LIT compile only" EXECUTE EXIT
  THEN DROP TEXT NUMBER?
  IF EXIT THEN ERROR
:: [ ( -- )
  forth_' $INTERPRET  >body forth_@ LIT 'EVAL !
  ;; IMMEDIATE
:: .OK ( -- )
  forth_' $INTERPRET >body forth_@ LIT 'EVAL @ =
  IF ."| $LIT OK" CR
  THEN ;;
:: EVAL ( -- )
  BEGIN TOKEN DUP @
  WHILE 'EVAL @EXECUTE \ ?STACK
  REPEAT DROP SPACE .OK ;;

CRR .( Shell ) CRR
:: QUIT ( -- )
  ( =TIB) $A0 LIT 'TIB !
   [ BEGIN QUERY EVAL AGAIN

CRR .( Compiler Primitives ) CRR
:: ' ( -- xt )
  TOKEN NAME? IF EXIT THEN
  ERROR
:: ALLOT ( n -- ) anew CP +! ;;
:: , ( w -- ) HERE DUP 1+ CP ! ! ;;
:: [COMPILE] ( -- ; <string> )
  ' , ;; IMMEDIATE

CRR
:: COMPILE ( -- ) R> DUP @ , 1+ >R ;;
:: LITERAL $ABDE LIT , ,
  ;; IMMEDIATE
:: $," ( -- ) ( CHAR " )
  22 LIT WORD NAME> CP ! ;;
:: (CALL) ( a -- call ) 7FFF LIT AND ;;

CRR .( Name Compiler ) CRR
:: ?UNIQUE ( a -- a )
  DUP NAME?
  IF TEXT COUNT TYPE ."| $LIT reDef "
  THEN DROP ;;
:: $,n ( a -- )
  DUP @
  IF ?UNIQUE
    ( na) DUP NAME> CP !
    ( na) DUP LAST ! \ for OVERT
    ( na) 1-
    ( la) CONTEXT @ SWAP ! EXIT
  THEN ERROR

CRR .( FORTH Compiler ) CRR

:: $COMPILE ( a -- )
  NAME? ?DUP
  IF @ $80 LIT AND
    IF EXECUTE
    ELSE (CALL) , anew
    THEN EXIT
  THEN DROP TEXT NUMBER?
  IF LITERAL anew EXIT
  THEN ERROR
:: OVERT ( -- ) LAST @ CONTEXT ! ;;
:: ; ( -- )
  $87DE LIT , [ OVERT ;; IMMEDIATE
:: ] ( -- )
  forth_' $COMPILE >body forth_@ LIT 'EVAL ! ;;
:: : ( -- ; <string> )
  TOKEN $,n ] ;;

CRR .( Tools ) CRR
:: dm+ ( b u -- b )
  OVER 6 LIT U.R SPACE
  FOR AFT DUP @ 9 LIT U.R 1+
  THEN NEXT ;;
:: DUMP ( b u -- )
  BASE @ >R HEX  8 LIT /
  FOR AFT CR 8 LIT dm+
  THEN NEXT DROP R> BASE ! ;;

CRR
:: >NAME ( xt -- na | F )
  CONTEXT
  BEGIN @ DUP
  WHILE 2DUP NAME> XOR
    IF 1-
    ELSE SWAP DROP EXIT
    THEN
  REPEAT SWAP DROP ;; 
:: .ID ( a -- )
  TEXT UNPACK$
  COUNT $01F LIT AND TYPE SPACE ;;

CRR
:: SEE ( -- ; <string> )
  ' CR
  BEGIN
    20 LIT FOR
      DUP @ DUP 8000 LIT AND
      IF U. SPACE
      ELSE >NAME
        ?DUP IF .ID THEN
      THEN 1+
    NEXT KEY 0D LIT =  \ can't use ESC on terminal
  UNTIL DROP ;;
:: WORDS ( -- )
  CR CONTEXT
  BEGIN @ ?DUP
  WHILE DUP SPACE .ID 1-
  REPEAT ;;
CODE .S ( dump all 33 stack items )
  PAD sta stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  stp stp stp stp
  PAD $21 LIT
  FOR DUP ? 1+ NEXT
  DROP PAD @ CR ;;

CRR .( file download and upload ) CRR
:: READ PAD
  BEGIN KEY DUP 1A LIT XOR
  WHILE OVER ! 1+
  REPEAT DROP
  PAD - SPAN ! ;;
:: OK 'TIB @ >R #TIB @ >R >IN @ >R
  PAD 'TIB ! SPAN @ #TIB ! 0 LIT >IN !
  EVAL R> >IN ! R> #TIB ! R> 'TIB ! ;;
:: SEND ( b u -- )
  CR
  FOR AFT DUP @ <# # # # # # # #> TYPE 1+
    DUP 7 LIT AND IF SPACE ELSE CR THEN
  THEN NEXT
  DROP ;;
:: FORGET ( -- )
  TOKEN NAME? ?DUP
  IF 1- DUP CP !
     @ DUP CONTEXT ! LAST !
     DROP EXIT
  THEN ERROR

CRR .( Hardware reset ) CRR
800 org

::   DIAGNOSE     ( - )
    $65 LIT
\    mask
\ 'F'  prove UM+ 0<         \ carry, TRUE, FALSE
    0 LIT 0< -2 LIT 0<     \ 0 FFFF
    UM+ DROP               \ FFFF ( -1)
    3 LIT UM+ UM+ DROP     \ 3
     $43 LIT UM+ DROP       \ 'F'
\ 'o' logic: XOR AND OR
     $4F LIT $6F LIT XOR    \ 20h
     $F0 LIT AND
     $4F LIT OR
\ 'r' stack: DUP OVER SWAP DROP
     8 LIT 6 LIT SWAP
     OVER XOR 3 LIT AND AND
     $70 LIT UM+ DROP       \ 'r'
\ 't'-- prove BRANCH ?BRANCH
     0 LIT IF $3F LIT THEN
     -1 LIT IF $74 LIT ELSE $21 LIT THEN
\ 'h' -- @ ! test memeory address
     $68 LIT $80 LIT !
     $80 LIT @
\ 'M' -- prove >R R> R@
     $4D LIT >R R@ R> AND
\ 'l'  -- prove 'next' can run
     61 LIT $A LIT FOR 1 LIT UM+ DROP NEXT
\ 'S' -- prove ldp, stp, ldrp, strp
     $50 LIT $3 LIT
     $30 LIT sta stp stp
     $30 LIT sta ldp ldp
     xor
\     EMIT
\ 'emi' -- prove mul, dupy, popy
     $656D LIT $100 LIT UM*
     SWAP $100 LIT UM*
     SWAP pops
\      EMIT EMIT
\ ' C' -- prove div
     $2043 LIT 0 LIT $100 LIT UM/MOD
\     EMIT EMIT
     ;;

CRR
:: COLD ( -- )
   DIAGNOSE
   CR ."| $LIT eP16 v"
   12D LIT <# # # ( CHAR . ) 2E LIT HOLD # #> TYPE
   CR QUIT

CRR .( Structures ) CRR
:: OFFSET ( A -- a ) 3FF LIT AND ;;
:: BEGIN ( -- a ) anew HERE ;; IMMEDIATE
:: THEN ( A -- ) BEGIN OFFSET SWAP +! ;; IMMEDIATE
:: FOR ( -- a ) F3DE LIT , BEGIN ;; IMMEDIATE
CRR
:: NEXT ( a -- )  OFFSET 9400 LIT XOR , anew ;; IMMEDIATE
:: UNTIL ( a -- ) OFFSET 8800 LIT XOR , anew ;; IMMEDIATE
:: AGAIN ( a -- ) OFFSET 8000 LIT XOR , anew ;; IMMEDIATE
:: IF ( -- A )   BEGIN 8800 LIT , ;; IMMEDIATE
CRR
:: AHEAD ( -- A ) BEGIN 8000 LIT , ;; IMMEDIATE
:: REPEAT ( A a -- ) AGAIN THEN ;; IMMEDIATE
:: AFT ( a -- a A ) DROP AHEAD BEGIN SWAP ;; IMMEDIATE
:: ELSE ( A -- A )  AHEAD SWAP THEN ;; IMMEDIATE
:: WHEN ( a A -- a A a ) IF OVER ;; IMMEDIATE
:: WHILE ( a -- A a )    IF SWAP ;; IMMEDIATE

CRR
:: ABORT" ( -- ; <string> )
   forth_' abort" >body forth_@ LIT (CALL) HERE !
   $," ;; IMMEDIATE
:: $" ( -- ; <string> )
   forth_' $"| >body forth_@ LIT (CALL) HERE !
   $," ;; IMMEDIATE
:: ." ( -- ; <string> ) 
   forth_' ."| >body forth_@ LIT (CALL) HERE !
   $," ;; IMMEDIATE

CRR
': doVAR popr ret
:: CODE ( -- ; <string> ) TOKEN $,n OVERT align ;;
:: CREATE ( -- ; <string> ) CODE 
    forth_' doVAR >body forth_@ LIT (CALL) , ;;
:: VARIABLE ( -- ; <string> ) CREATE 0 LIT , ;;
:: CONSTANT CODE $A89E  LIT , , ;;
:: DOES ( -- ) R> (CALL) LAST @ NAME> ! ;;

CRR
(makehead) .( ( -- ) 29 LIT PARSE TYPE ;; IMMEDIATE
(makehead) \ ( -- ) #TIB @ >IN ! ;; IMMEDIATE
(makehead) ( 29 LIT PARSE 2DROP ;; IMMEDIATE
(makehead) IMMEDIATE $80 LIT LAST +! ;;

CRR
(makehead) EXIT popr pops ret
(makehead) EXECUTE pushr ret
(makehead) ! sta st ret
(makehead) @ sta ld ret
(makehead) R> popr sta popr lda pushr ret
(makehead) R@ popr sta popr pushs pushr lda pushr ret
(makehead) >R popr sta pushr lda pushr ret

(makehead) SWAP
   pushr sta popr lda ret
(makehead) OVER
   pushr pushs sta popr
   lda ret
(makehead) 2DROP
   pops pops ret

(makehead) +  add ret
(makehead) NOT com ret
(makehead)  NEGATE
   com 1 ldi add ret
(makehead) 1-
   -1 ldi add ret
(makehead) 1+
   1 ldi add ret

(makehead) BL
   20 ldi ret
(makehead) +!
   sta ld add st
   ret
(makehead) -
   com add 1 ldi add
   ret
(makehead) OR
   com pushr com
   popr and com ret
(makehead) ROT
   pushr pushr sta popr
   popr lda ret
(makehead) 2DUP
   pushs pushr pushr
   pushs sta popr lda popr
   ret
(makehead) 2!
   sta pushr stp
   popr st ret
(makehead) 2@
   sta ldp ld ret
(makehead) COUNT 
   sta ldp pushr lda
   popr ret

(makehead) DUP pushs ret
(makehead) DROP pops ret
(makehead) AND and ret
(makehead) XOR xor ret
(makehead) INVERT com ret

CRR

h forth_@

0 org COLD
0 #, 0 #, 0 #,

$24 org
$A0 #,
0A #,
lasth forth_@ #,
             #,
lasth forth_@ #,
forth_' $INTERPRET >body forth_@ #,
forth_' QUIT >body forth_@ #,
0 #,
0 #,
lasth forth_@ #,



