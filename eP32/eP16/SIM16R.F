HEX
903E forth_' KEY  >body forth_@ ram!
9C3E forth_' EMIT >body forth_@ ram!

forth_forget h

DECIMAL

$1F CONSTANT LIMIT ( stack depth )
$1FFF CONSTANT RANGE ( program memory size in words )
VARIABLE CLOCK ( slot is in the last 3 bits )
VARIABLE (REGISTER) ( where registers and stacks are )
VARIABLE BREAK

: REGISTER  (REGISTER) @ ;
: FROM  PAD (REGISTER) ! ;
: TO    PAD $600 + (REGISTER) ! ;

: P     REGISTER ;
: I     REGISTER 4 + ;
: I1    REGISTER 8 + ;
: I2    REGISTER 9 + ;
: I3    REGISTER 10 + ;
: I4    REGISTER 11 + ;
: I5    REGISTER 12 + ;
: RP    REGISTER 13 + ;
: SP    REGISTER 14 + ;
: T     REGISTER 16 + ;
: R     REGISTER 24 + ;
: A     REGISTER 32 + ;
: S     REGISTER 56 + ;
: RSTACK  RP C@ LIMIT AND 4 * REGISTER + $100 + ;
: SSTACK  SP C@ LIMIT AND 4 * REGISTER + $200 + ;

: CYCLE TO P FROM P $600 CMOVE 1 CLOCK +! ;

: JUMP  CLOCK @ 3 OR CLOCK ! ;

: RPUSH ( d -- , push d on return stack )
        FROM R @ RP C@ 1 + LIMIT AND TO RP C! RSTACK ! R ! ;

: RPOPP ( -- d , pop d from return stack )
        FROM R @ RSTACK @ RP C@ 1 - LIMIT AND TO RP C! R ! ;

: SPUSH ( d -- , push d on data stack )
        FROM S @ SP C@ 1 + LIMIT AND TO SP C! SSTACK !
        FROM T @ TO S !
        TO T ! ;

: SPOPP ( -- d , pop d from data stack )
        FROM T @
        FROM S @ TO T !
        FROM SSTACK @ SP C@ 1 - LIMIT AND TO SP C! S ! ;

: call  FROM P @ RPUSH I @ TO RANGE AND P !
        JUMP ;
: continue
        FROM P @ DUP 1+ TO RANGE AND P !
        ram@ DUP $FFFF AND I !
        $20 /MOD SWAP I3 C!
        $20 /MOD SWAP I2 C!
        $1F AND I1 C!
        ;

: nop   JUMP ;
: ei    ;
: di    ;
: bra   FROM I @ $3FF AND
        P @ $FC00 AND + TO RANGE AND P ! JUMP ;
: ret   RPOPP TO RANGE AND P !
        JUMP ;
: bc    SPOPP $10000 AND ( branch on carry )
        IF bra ELSE JUMP THEN ;
: bz    SPOPP $FFFF AND ( branch on zero )
        IF JUMP ELSE bra THEN ;
: next  FROM R @ $FFFF AND
        IF ELSE RPOPP DROP JUMP EXIT THEN ( exit loop )
        FROM R @ 1- TO R ! ( decrement R )
        bra ;
: times FROM R @ $FFFF AND
        IF ELSE RPOPP DROP JUMP EXIT THEN ( exit loop )
        FROM R @ 1- TO R ! ( decrement R )
        FROM -1 P +! TO -1 P +! ;
: pushr SPOPP RPUSH ;
: dupr  FROM R @ SPUSH ;
: popr  RPOPP SPUSH ;
: andd  SPOPP TO T @ AND T ! ;
: xorr  SPOPP TO T @ XOR T ! ;
: com   FROM T @ -1 XOR TO T ! ;
: add   SPOPP $FFFF AND TO T @ $FFFF AND + TO T ! ;
: mul   FROM A @ 1 AND
        IF S @ $FFFF AND T @ $FFFF AND +
        ELSE T @ $FFFF AND THEN
        DUP 2/ TO T !
        1 AND >R
        FROM A @ 2/ $7FFF AND R> IF $8000 OR THEN TO A ! ;
: div   FROM S @ $FFFF AND T @ $FFFF AND +
        DUP >R DUP $10000 AND
        IF ELSE DROP T @ THEN $7FFF AND
        2* ( diff) A @ $8000 AND IF 1+ THEN TO T !
        FROM A @ $7FFFF AND 2* R> $10000 AND IF 1+ THEN TO A ! ;
: shr   FROM T @ $8000 AND T @ $FFFF AND 2/ + TO T ! ;
: shl   FROM T @ 2* $1FFFF AND TO T ! ;
: rr8   FROM T @ $100 * $FF00 AND T @ $100 / $FF AND + TO T ! ;
: ldi   FROM P @ 1+ TO RANGE AND P !
        FROM P @ RANGE AND ram@ SPUSH ;
: pushs FROM T @ SPUSH ;
: lda   FROM A @ SPUSH ;
: pops  SPOPP DROP ;
: overr FROM S @ SPUSH ;
: sta   SPOPP TO A ! ;
: ld    FROM A @ RANGE AND ram@ SPUSH ;
: ldp   ld
        FROM A @ 1+ $1FFFF AND TO A ! ;
: ldrp  FROM R @ RANGE AND ram@ SPUSH
        FROM R @ 1+ $1FFFF AND TO R ! ;
: st    SPOPP FROM A @ RANGE AND ram! ;
: stp   st
        FROM A @ 1+ $1FFFF AND TO A ! ;
: strp  SPOPP FROM R @ RANGE AND ram!
        FROM R @ 1+ $1FFFF AND TO R ! ;
: get   KEY DUP $1B = ABORT" done"
        SPUSH ret ;
: put   SPOPP $7F AND EMIT ret ;

HEX

: execute ( code -- )
        DUP 00 = IF DROP bra   EXIT THEN
        DUP 01 = IF DROP ret   EXIT THEN
        DUP 02 = IF DROP bz    EXIT THEN
        DUP 03 = IF DROP bc    EXIT THEN
\        DUP 04 = IF DROP call  EXIT THEN
        DUP 05 = IF DROP next  EXIT THEN
        DUP 06 = IF DROP times EXIT THEN
\        DUP 07 = IF DROP di    EXIT THEN
\        DUP 08 = IF DROP ldrp  EXIT THEN
        DUP 09 = IF DROP ldp   EXIT THEN
        DUP 0A = IF DROP ldi   EXIT THEN
        DUP 0B = IF DROP ld    EXIT THEN
\        DUP 0C = IF DROP strp  EXIT THEN
        DUP 0D = IF DROP stp   EXIT THEN
        DUP 0E = IF DROP rr8   EXIT THEN
        DUP 0F = IF DROP st    EXIT THEN
        DUP 10 = IF DROP com   EXIT THEN
        DUP 11 = IF DROP shl   EXIT THEN
        DUP 12 = IF DROP shr   EXIT THEN
        DUP 13 = IF DROP mul   EXIT THEN
        DUP 14 = IF DROP xorr  EXIT THEN
        DUP 15 = IF DROP andd  EXIT THEN
        DUP 16 = IF DROP div   EXIT THEN
        DUP 17 = IF DROP add   EXIT THEN
        DUP 18 = IF DROP popr  EXIT THEN
        DUP 19 = IF DROP lda   EXIT THEN
        DUP 1A = IF DROP pushs EXIT THEN
        DUP 1B = IF DROP overr EXIT THEN
        DUP 1C = IF DROP pushr EXIT THEN
        DUP 1D = IF DROP sta   EXIT THEN
        DUP 1E = IF DROP nop   EXIT THEN
        DUP 1F = IF DROP pops  EXIT THEN
        DUP 04 = IF DROP get   EXIT THEN
        DUP 07 = IF DROP put   EXIT THEN
        . ABORT" :Illegel instruction" ;

: .stack ( add # ) FOR AFT DUP @ $1FFFF AND . 4 - THEN NEXT DROP CR ;
: .sstack ." S:" T @ $1FFFF AND U.
        S @ $1FFFF AND U. SSTACK SP C@ .stack ;
: .rstack ." R:" R @ $1FFFF AND U. RSTACK RP C@ .stack ;
: .a ."  A:" A @ $1FFFF AND U. ;
: .registers ."  P=" P @ . ."  I=" I @ U.
        ."  I1=" I1 C@ . ."  I2=" I2 C@ .
        ."  I3=" I3 C@ . .a CR ;
: S     ." CLOCK=" CLOCK @ . .registers
        .sstack .rstack ;

: sync  CLOCK @ 3 AND
        DUP 0 = IF      continue
                        DROP EXIT
                THEN
        DUP 1 = IF      I @ $8000 AND
                        IF   I1 C@ execute DROP EXIT
                        ELSE call DROP EXIT THEN
                THEN
        DUP 2 = IF   I2 C@ execute DROP EXIT
                THEN
        DUP 3 = IF   I3 C@ execute DROP EXIT
                THEN
        DROP JUMP ;
: C     sync CYCLE S ;
: reset FROM P $C00 0 FILL 0 CLOCK ! ;
reset

: G     ( addr -- )
        CR ." Press any key to stop." CR
        BREAK !
        BEGIN sync P @ BREAK @ =
              IF CYCLE C EXIT
              ELSE CYCLE
              THEN
              ?KEY
        UNTIL ;
: PUSH  ( n ) pushs TO T ! ;
: POP   pops ;

: D     P @ 1- four four ;
: M     show ;
: RUN   CR ." Press ESC to stop." CR
        BEGIN C KEY 1B = UNTIL ;
: P     DUP FROM RANGE AND P ! TO RANGE AND P ! ;

: HELP  CR ." eP16 Simulator, copyright eForth Group, 2002"
        CR ." C: execute next cycle"
        CR ." S: show all registers"
        CR ." D: display next 8 words"
        CR ." addr M: display 128 words from addr"
        CR ." addr P: start execution at addr"
        CR ." addr G: run and stop at addr"
        CR ." RUN: execute, one key per cycle"
        CR ;


