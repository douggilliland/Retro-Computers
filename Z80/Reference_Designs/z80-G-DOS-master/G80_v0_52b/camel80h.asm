; LISTING 2.
;
; ===============================================
; CamelForth for the Zilog Z80
; Copyright (c) 1994,1995 Bradford J. Rodriguez
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Commercial inquiries should be directed to the author at 
; 115 First St., #105, Collingwood, Ontario L9Y 4W3 Canada
; or via email to bj@camelforth.com
;
; ===============================================
; CAMEL80H.AZM: High Level Words
;   Source code is for the Z80MR macro assembler.
;   Forth words are documented as follows:
;*   NAME     stack -- stack    description
;   Word names in upper case are from the ANS
;   Forth Core word set.  Names in lower case are
;   "internal" implementation words & extensions.
; ===============================================

; SYSTEM VARIABLES & CONSTANTS ==================

;C BL      -- char            an ASCII space
    head BL,2,'bl',docon
        dw 20h

;Z tibsize  -- n         size of TIB
    head TIBSIZE,7,'tibsize',docon
        dw 124          ; 2 chars safety zone

;X tib     -- a-addr     Terminal Input Buffer
;  HEX 82 CONSTANT TIB   CP/M systems: 126 bytes
;  HEX -80 USER TIB      others: below user area

;   head TIB,3,'tib',docon
;       dw 82h

    head TIB,3,'tib',douser
        dw -82h

;Z u0      -- a-addr       current user area adrs
;  0 USER U0
    head U0,2,'u0',douser
        dw 0

;C >IN     -- a-addr        holds offset into TIB
;  2 USER >IN
    head TOIN,3,'>in',douser
        dw 2

;C BASE    -- a-addr       holds conversion radix
;  4 USER BASE
    head BASE,4,'base',douser
        dw 4

;C STATE   -- a-addr       holds compiler state
;  6 USER STATE
    head STATE,5,'state',douser
        dw 6

;Z dp      -- a-addr       holds dictionary ptr
;  8 USER DP
    head DP,2,'dp',douser
        dw 8

;Z 'source  -- a-addr      two cells: len, adrs
; 10 USER 'SOURCE
;    head TICKSOURCE,7,"'source",douser
        DW link                 ; must expand
        DB 0                    ; manually
link    DEFL $                  ; because of
        DB 7,27h,'SOURCE'       ; tick character
TICKSOURCE: call douser         ; in name!
        dw 10

;Z latest    -- a-addr     last word in dict.
;   14 USER LATEST
    head LATEST,6,'latest',douser
        dw 14

;Z hp       -- a-addr     HOLD pointer
;   16 USER HP
    head HP,2,'hp',douser
        dw 16

;Z LP       -- a-addr     Leave-stack pointer
;   18 USER LP
    head LP,2,'lp',douser
        dw 18

;Z s0       -- a-addr     end of parameter stack
    head S0,2,'s0',douser
        dw 100h

;X PAD       -- a-addr    user PAD buffer
;                         = end of hold area!
    head PAD,3,'pad',douser
        dw 128h

;Z l0       -- a-addr     bottom of Leave stack
    head L0,2,'l0',douser
        dw 180h

;Z r0       -- a-addr     end of return stack
    head R0,2,'r0',douser
        dw 200h

;Z uinit    -- addr  initial values for user area
    head UINIT,5,'uinit',docreate
        DW 0,0,10,0     ; reserved,>IN,BASE,STATE
        DW enddict      ; DP
        DW 0,0          ; SOURCE init'd elsewhere
        DW lastword     ; LATEST
        DW 0            ; HP init'd elsewhere

;Z #init    -- n    #bytes of user area init data
    head NINIT,5,'#init',docon
        DW 18

; ARITHMETIC OPERATORS ==========================

;C S>D    n -- d          single -> double prec.
;   DUP 0< ;
    head STOD,3,'s>d',docolon
        dw DUP,ZEROLESS,EXIT

;Z ?NEGATE  n1 n2 -- n3  negate n1 if n2 negative
;   0< IF NEGATE THEN ;        ...a common factor
    head QNEGATE,7,'?negate',docolon
        DW ZEROLESS,QBRANCH,QNEG1,NEGATE
QNEG1:  DW EXIT

;C ABS     n1 -- +n2     absolute value
;   DUP ?NEGATE ;
    head fABS,3,'abs',docolon
        DW DUP,QNEGATE,EXIT

;X DNEGATE   d1 -- d2     negate double precision
;   SWAP INVERT SWAP INVERT 1 M+ ;
    head DNEGATE,7,'dnegate',docolon
        DW SWOP,INVERT,SWOP,INVERT,LIT,1,MPLUS
        DW EXIT

;Z ?DNEGATE  d1 n -- d2   negate d1 if n negative
;   0< IF DNEGATE THEN ;       ...a common factor
    head QDNEGATE,8,'?dnegate',docolon
        DW ZEROLESS,QBRANCH,DNEG1,DNEGATE
DNEG1:  DW EXIT

;X DABS     d1 -- +d2    absolute value dbl.prec.
;   DUP ?DNEGATE ;
    head DABS,4,'dabs',docolon
        DW DUP,QDNEGATE,EXIT

;C M*     n1 n2 -- d    signed 16*16->32 multiply
;   2DUP XOR >R        carries sign of the result
;   SWAP ABS SWAP ABS UM*
;   R> ?DNEGATE ;
    head MSTAR,2,'m*',docolon
        DW TWODUP,fXOR,TOR
        DW SWOP,fABS,SWOP,fABS,UMSTAR
        DW RFROM,QDNEGATE,EXIT

;C SM/REM   d1 n1 -- n2 n3   symmetric signed div
;   2DUP XOR >R              sign of quotient
;   OVER >R                  sign of remainder
;   ABS >R DABS R> UM/MOD
;   SWAP R> ?NEGATE
;   SWAP R> ?NEGATE ;
; Ref. dpANS-6 section 3.2.2.1.
    head SMSLASHREM,6,'sm/rem',docolon
        DW TWODUP,fXOR,TOR,OVER,TOR
        DW fABS,TOR,DABS,RFROM,UMSLASHMOD
        DW SWOP,RFROM,QNEGATE,SWOP,RFROM,QNEGATE
        DW EXIT

;C FM/MOD   d1 n1 -- n2 n3   floored signed div'n
;   DUP >R              save divisor
;   SM/REM
;   DUP 0< IF           if quotient negative,
;       SWAP R> +         add divisor to rem'dr
;       SWAP 1-           decrement quotient
;   ELSE R> DROP THEN ;
; Ref. dpANS-6 section 3.2.2.1.
    head FMSLASHMOD,6,'fm/mod',docolon
        DW DUP,TOR,SMSLASHREM
        DW DUP,ZEROLESS,QBRANCH,FMMOD1
        DW SWOP,RFROM,PLUS,SWOP,ONEMINUS
        DW BRANCH,FMMOD2
FMMOD1: DW RFROM,DROP
FMMOD2: DW EXIT

;C *      n1 n2 -- n3       signed multiply
;   M* DROP ;
    head STAR,1,'*',docolon
        dw MSTAR,DROP,EXIT

;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
;   >R S>D R> FM/MOD ;
    head SLASHMOD,4,'/mod',docolon
        dw TOR,STOD,RFROM,FMSLASHMOD,EXIT

;C /      n1 n2 -- n3       signed divide
;   /MOD nip ;
    head SLASH,1,'/',docolon
        dw SLASHMOD,NIP,EXIT

;C MOD    n1 n2 -- n3       signed remainder
;   /MOD DROP ;
    head _MOD,3,'_mod',docolon
        dw SLASHMOD,DROP,EXIT

;C */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
;   >R M* R> FM/MOD ;
    head SSMOD,5,'*/mod',docolon
        dw TOR,MSTAR,RFROM,FMSLASHMOD,EXIT

;C */     n1 n2 n3 -- n4        n1*n2/n3
;   */MOD nip ;
    head STARSLASH,2,'*/',docolon
        dw SSMOD,NIP,EXIT

;C MAX    n1 n2 -- n3       signed maximum
;   2DUP < IF SWAP THEN DROP ;
    head MAX,3,'max',docolon
        dw TWODUP,LESS,QBRANCH,MAX1,SWOP
MAX1:   dw DROP,EXIT

;C MIN    n1 n2 -- n3       signed minimum
;   2DUP > IF SWAP THEN DROP ;
    head MIN,3,'min',docolon
        dw TWODUP,GREATER,QBRANCH,MIN1,SWOP
MIN1:   dw DROP,EXIT

; DOUBLE OPERATORS ==============================

;C 2@    a-addr -- x1 x2    fetch 2 cells
;   DUP CELL+ @ SWAP @ ;
;   the lower address will appear on top of stack
    head TWOFETCH,2,'2@',docolon
        dw DUP,CELLPLUS,FETCH,SWOP,FETCH,EXIT

;C 2!    x1 x2 a-addr --    store 2 cells
;   SWAP OVER ! CELL+ ! ;
;   the top of stack is stored at the lower adrs
    head TWOSTORE,2,'2!',docolon
        dw SWOP,OVER,STORE,CELLPLUS,STORE,EXIT

;C 2DROP  x1 x2 --          drop 2 cells
;   DROP DROP ;
    head TWODROP,5,'2drop',docolon
        dw DROP,DROP,EXIT

;C 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
;   OVER OVER ;
    head TWODUP,4,'2dup',docolon
        dw OVER,OVER,EXIT

;C 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2  per diagram
;   ROT >R ROT R> ;
    head TWOSWAP,5,'2swap',docolon
        dw ROT,TOR,ROT,RFROM,EXIT

;C 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
;   >R >R 2DUP R> R> 2SWAP ;
    head TWOOVER,5,'2over',docolon
        dw TOR,TOR,TWODUP,RFROM,RFROM
        dw TWOSWAP,EXIT

; INPUT/OUTPUT ==================================

;C COUNT   c-addr1 -- c-addr2 u  counted->adr/len
;   DUP CHAR+ SWAP C@ ;
    head COUNT,5,'count',docolon
        dw DUP,CHARPLUS,SWOP,CFETCH,EXIT

;C CR      --               output newline
;   0D EMIT 0A EMIT ;
    head fCR,2,'cr',docolon
        dw LIT,0dh,EMIT,LIT,0ah,EMIT,EXIT

;C SPACE   --               output a space
;   BL EMIT ;
    head fSPACE,5,'space',docolon
        dw BL,EMIT,EXIT

;C SPACES   n --            output n spaces
;   BEGIN DUP WHILE SPACE 1- REPEAT DROP ;
    head SPACES,6,'spaces',docolon
SPCS1:  DW DUP,QBRANCH,SPCS2
        DW fSPACE,ONEMINUS,BRANCH,SPCS1
SPCS2:  DW DROP,EXIT

;Z umin     u1 u2 -- u      unsigned minimum
;   2DUP U> IF SWAP THEN DROP ;
    head UMIN,4,'umin',docolon
        DW TWODUP,UGREATER,QBRANCH,UMIN1,SWOP
UMIN1:  DW DROP,EXIT

;Z umax    u1 u2 -- u       unsigned maximum
;   2DUP U< IF SWAP THEN DROP ;
    head UMAX,4,'umax',docolon
        DW TWODUP,ULESS,QBRANCH,UMAX1,SWOP
UMAX1:  DW DROP,EXIT

;C ACCEPT  c-addr +n -- +n'  get line from term'l
;   OVER + 1- OVER      -- sa ea a
;   BEGIN KEY           -- sa ea a c
;   DUP 0D <> WHILE
;       DUP EMIT        -- sa ea a c
;       DUP 8 = IF  DROP 1-    >R OVER R> UMAX
;             ELSE  OVER C! 1+ OVER UMIN
;       THEN            -- sa ea a
;   REPEAT              -- sa ea a c
;   DROP NIP SWAP - ;
    head ACCEPT,6,'accept',docolon
        DW OVER,PLUS,ONEMINUS,OVER
ACC1:   
	DW KEY
	DW DUP,LIT,0DH,NOTEQUAL,QBRANCH,ACC5
        DW DUP,EMIT,DUP,LIT,8,EQUAL,QBRANCH,ACC3
        DW DROP,ONEMINUS,TOR,OVER,RFROM,UMAX
        DW BRANCH,ACC4
ACC3:   
	DW OVER,CSTORE,ONEPLUS,OVER,UMIN
ACC4:   
	DW BRANCH,ACC1
ACC5:   
	DW DROP,NIP,SWOP,MINUS
	DW EXIT

;C TYPE    c-addr +n --     type line to term'l
;   ?DUP IF
;     OVER + SWAP DO I C@ EMIT LOOP
;   ELSE DROP THEN ;
    head TYPE,4,'type',docolon
        DW QDUP,QBRANCH,TYP4
        DW OVER,PLUS,SWOP,XDO
TYP3:   DW II,CFETCH,EMIT,XLOOP,TYP3
        DW BRANCH,TYP5
TYP4:   DW DROP
TYP5:   DW EXIT

;Z (S")     -- c-addr u   run-time code for S"
;   R> COUNT 2DUP + ALIGNED >R  ;
    head XSQUOTE,4,'(s")',docolon
        DW RFROM,COUNT,TWODUP,PLUS,ALIGNED,TOR
        DW EXIT

;C S"       --         compile in-line string
;   COMPILE (S")  [ HEX ]
;   22 WORD C@ 1+ ALIGNED ALLOT ; IMMEDIATE
    immed SQUOTE,2,'s"',docolon
        DW LIT,XSQUOTE,COMMAXT
        DW LIT,22H,WORD,CFETCH,ONEPLUS
        DW ALIGNED,ALLOT,EXIT

;C ."       --         compile string to print
;   POSTPONE S"  POSTPONE TYPE ; IMMEDIATE
    immed DOTQUOTE,2,'."',docolon
        DW SQUOTE
        DW LIT,TYPE,COMMAXT
        DW EXIT
                        
; NUMERIC OUTPUT ================================
; Numeric conversion is done l.s.digit first, so
; the output buffer is built backwards in memory.

; Some double-precision arithmetic operators are
; needed to implement ANSI numeric conversion.

;Z UD/MOD   ud1 u2 -- u3 ud4   32/16->32 divide
;   >R 0 R@ UM/MOD  ROT ROT R> UM/MOD ROT ;
    head UDSLASHMOD,6,'ud/mod',docolon
        DW TOR,LIT,0,RFETCH,UMSLASHMOD,ROT,ROT
        DW RFROM,UMSLASHMOD,ROT,EXIT

;Z UD*      ud1 d2 -- ud3      32*16->32 multiply
;   DUP >R UM* DROP  SWAP R> UM* ROT + ;
    head UDSTAR,3,'ud*',docolon
        DW DUP,TOR,UMSTAR,DROP
        DW SWOP,RFROM,UMSTAR,ROT,PLUS,EXIT

;C HOLD  char --        add char to output string
;   -1 HP +!  HP @ C! ;
    head HOLD,4,'hold',docolon
        DW LIT,-1,HP,PLUSSTORE
        DW HP,FETCH,CSTORE,EXIT

;C <#    --             begin numeric conversion
;   PAD HP ! ;          (initialize Hold Pointer)
    head LESSNUM,2,'<#',docolon
        DW PAD,HP,STORE,EXIT

;Z >digit   n -- c      convert to 0..9A..Z
;   [ HEX ] DUP 9 > 7 AND + 30 + ;
    head TODIGIT,6,'>digit',docolon
        DW DUP,LIT,9,GREATER,LIT,7,fAND,PLUS
        DW LIT,30H,PLUS,EXIT

;C #     ud1 -- ud2     convert 1 digit of output
;   BASE @ UD/MOD ROT >digit HOLD ;
    head NUM,1,'#',docolon
        DW BASE,FETCH,UDSLASHMOD,ROT,TODIGIT
        DW HOLD,EXIT

;C #S    ud1 -- ud2     convert remaining digits
;   BEGIN # 2DUP OR 0= UNTIL ;
    head NUMS,2,'#s',docolon
NUMS1:  DW NUM,TWODUP,fOR,ZEROEQUAL,QBRANCH,NUMS1
        DW EXIT

;C #>    ud1 -- c-addr u    end conv., get string
;   2DROP HP @ PAD OVER - ;
    head NUMGREATER,2,'#>',docolon
        DW TWODROP,HP,FETCH,PAD,OVER,MINUS,EXIT

;C SIGN  n --           add minus sign if n<0
;   0< IF 2D HOLD THEN ;
    head SIGN,4,'sign',docolon
        DW ZEROLESS,QBRANCH,SIGN1,LIT,2DH,HOLD
SIGN1:  DW EXIT

;C U.    u --           display u unsigned
;   <# 0 #S #> TYPE SPACE ;
    head UDOT,2,'u.',docolon
        DW LESSNUM,LIT,0,NUMS,NUMGREATER,TYPE
        DW fSPACE,EXIT

;C .     n --           display n signed
;   <# DUP ABS 0 #S ROT SIGN #> TYPE SPACE ;
    head DOT,1,'.',docolon
        DW LESSNUM,DUP,fABS,LIT,0,NUMS
        DW ROT,SIGN,NUMGREATER,TYPE,fSPACE,EXIT

;C DECIMAL  --      set number base to decimal
;   10 BASE ! ;
    head DECIMAL,7,'decimal',docolon
        DW LIT,10,BASE,STORE,EXIT

;X HEX     --       set number base to hex
;   16 BASE ! ;
    head fHEX,3,'hex',docolon
        DW LIT,16,BASE,STORE,EXIT

; DICTIONARY MANAGEMENT =========================

;C HERE    -- addr      returns dictionary ptr
;   DP @ ;
    head HERE,4,'here',docolon
        dw DP,FETCH,EXIT

;C ALLOT   n --         allocate n bytes in dict
;   DP +! ;
    head ALLOT,5,'allot',docolon
        dw DP,PLUSSTORE,EXIT

; Note: , and C, are only valid for combined
; Code and Data spaces.

;C ,    x --           append cell to dict
;   HERE ! 1 CELLS ALLOT ;
    head COMMA,1,''',',docolon
        dw HERE,STORE,LIT,1,CELLS,ALLOT,EXIT

;C C,   char --        append char to dict
;   HERE C! 1 CHARS ALLOT ;
    head CCOMMA,2,'c,',docolon
        dw HERE,CSTORE,LIT,1,CHARS,ALLOT,EXIT

; INTERPRETER ===================================
; Note that NFA>LFA, NFA>CFA, IMMED?, and FIND
; are dependent on the structure of the Forth
; header.  This may be common across many CPUs,
; or it may be different.

;C SOURCE   -- adr n    current input buffer
;   'SOURCE 2@ ;        length is at lower adrs
    head SOURCE,6,'source',docolon
        DW TICKSOURCE,TWOFETCH,EXIT

;X /STRING  a u n -- a+n u-n   trim string
;   ROT OVER + ROT ROT - ;
    head SLASHSTRING,7,'/string',docolon
        DW ROT,OVER,PLUS,ROT,ROT,MINUS,EXIT

;Z >counted  src n dst --     copy to counted str
;   2DUP C! CHAR+ SWAP CMOVE ;
    head TOCOUNTED,8,'>counted',docolon
        DW TWODUP,CSTORE,CHARPLUS,SWOP,CMOVE,EXIT

;C WORD   char -- c-addr n   word delim'd by char
;   DUP  SOURCE >IN @ /STRING   -- c c adr n
;   DUP >R   ROT SKIP           -- c adr' n'
;   OVER >R  ROT SCAN           -- adr" n"
;   DUP IF CHAR- THEN        skip trailing delim.
;   R> R> ROT -   >IN +!        update >IN offset
;   TUCK -                      -- adr' N
;   HERE >counted               --
;   HERE                        -- a
;   BL OVER COUNT + C! ;    append trailing blank
    head WORD,4,'word',docolon
        DW DUP,SOURCE,TOIN,FETCH,SLASHSTRING
        DW DUP,TOR,ROT,SKIP
        DW OVER,TOR,ROT,SCAN
        DW DUP,QBRANCH,WORD1,ONEMINUS  ; char-
WORD1:  DW RFROM,RFROM,ROT,MINUS,TOIN,PLUSSTORE
        DW TUCK,MINUS
        DW HERE,TOCOUNTED,HERE
        DW BL,OVER,COUNT,PLUS,CSTORE,EXIT

;Z NFA>LFA   nfa -- lfa    name adr -> link field
;   3 - ;
    head NFATOLFA,7,'nfa>lfa',docolon
        DW LIT,3,MINUS,EXIT

;Z NFA>CFA   nfa -- cfa    name adr -> code field
;   COUNT 7F AND + ;       mask off 'smudge' bit
    head NFATOCFA,7,'nfa>cfa',docolon
        DW COUNT,LIT,07FH,fAND,PLUS,EXIT

;Z IMMED?    nfa -- f      fetch immediate flag
;   1- C@ ;                     nonzero if immed
    head IMMEDQ,6,'immed?',docolon
        DW ONEMINUS,CFETCH,EXIT

;C FIND   c-addr -- c-addr 0   if not found
;C                  xt  1      if immediate
;C                  xt -1      if "normal"
;   LATEST @ BEGIN             -- a nfa
;       2DUP OVER C@ CHAR+     -- a nfa a nfa n+1
;       S=                     -- a nfa f
;       DUP IF
;           DROP
;           NFA>LFA @ DUP      -- a link link
;       THEN
;   0= UNTIL                   -- a nfa  OR  a 0
;   DUP IF
;       NIP DUP NFA>CFA        -- nfa xt
;       SWAP IMMED?            -- xt iflag
;       0= 1 OR                -- xt 1/-1
;   THEN ;
    head FIND,4,'find',docolon
        DW LATEST,FETCH
FIND1:  DW TWODUP,OVER,CFETCH,CHARPLUS
        DW SEQUAL,DUP,QBRANCH,FIND2
        DW DROP,NFATOLFA,FETCH,DUP
FIND2:  DW ZEROEQUAL,QBRANCH,FIND1
        DW DUP,QBRANCH,FIND3
        DW NIP,DUP,NFATOCFA
        DW SWOP,IMMEDQ,ZEROEQUAL,LIT,1,fOR
FIND3:  DW EXIT

;C LITERAL  x --        append numeric literal
;   STATE @ IF ['] LIT ,XT , THEN ; IMMEDIATE
; This tests STATE so that it can also be used
; interpretively.  (ANSI doesn't require this.)
    immed LITERAL,7,'literal',docolon
        DW STATE,FETCH,QBRANCH,LITER1
        DW LIT,LIT,COMMAXT,COMMA
LITER1: DW EXIT

;Z DIGIT?   c -- n -1   if c is a valid digit
;Z            -- x  0   otherwise
;   [ HEX ] DUP 39 > 100 AND +     silly looking
;   DUP 140 > 107 AND -   30 -     but it works!
;   DUP BASE @ U< ;
    head DIGITQ,6,'digit?',docolon
        DW DUP,LIT,39H,GREATER,LIT,100H,fAND,PLUS
        DW DUP,LIT,140H,GREATER,LIT,107H,fAND
        DW MINUS,LIT,30H,MINUS
        DW DUP,BASE,FETCH,ULESS,EXIT

;Z ?SIGN   adr n -- adr' n' f  get optional sign
;Z  advance adr/n if sign; return NZ if negative
;   OVER C@                 -- adr n c
;   2C - DUP ABS 1 = AND    -- +=-1, -=+1, else 0
;   DUP IF 1+               -- +=0, -=+2
;       >R 1 /STRING R>     -- adr' n' f
;   THEN ;
    head QSIGN,5,'?sign',docolon
        DW OVER,CFETCH,LIT,2CH,MINUS,DUP,fABS
        DW LIT,1,EQUAL,fAND,DUP,QBRANCH,QSIGN1
        DW ONEPLUS,TOR,LIT,1,SLASHSTRING,RFROM
QSIGN1: DW EXIT

;C >NUMBER  ud adr u -- ud' adr' u'
;C                      convert string to number
;   BEGIN
;   DUP WHILE
;       OVER C@ DIGIT?
;       0= IF DROP EXIT THEN
;       >R 2SWAP BASE @ UD*
;       R> M+ 2SWAP
;       1 /STRING
;   REPEAT ;
    head TONUMBER,7,'>number',docolon
TONUM1: DW DUP,QBRANCH,TONUM3
        DW OVER,CFETCH,DIGITQ
        DW ZEROEQUAL,QBRANCH,TONUM2,DROP,EXIT
TONUM2: DW TOR,TWOSWAP,BASE,FETCH,UDSTAR
        DW RFROM,MPLUS,TWOSWAP
        DW LIT,1,SLASHSTRING,BRANCH,TONUM1
TONUM3: DW EXIT

;Z ?NUMBER  c-addr -- n -1      string->number
;Z                 -- c-addr 0  if convert error
;   DUP  0 0 ROT COUNT      -- ca ud adr n
;   ?SIGN >R  >NUMBER       -- ca ud adr' n'
;   IF   R> 2DROP 2DROP 0   -- ca 0   (error)
;   ELSE 2DROP NIP R>
;       IF NEGATE THEN  -1  -- n -1   (ok)
;   THEN ;
    head QNUMBER,7,'?number',docolon
        DW DUP,LIT,0,DUP,ROT,COUNT
        DW QSIGN,TOR,TONUMBER,QBRANCH,QNUM1
        DW RFROM,TWODROP,TWODROP,LIT,0
        DW BRANCH,QNUM3
QNUM1:  DW TWODROP,NIP,RFROM,QBRANCH,QNUM2,NEGATE
QNUM2:  DW LIT,-1
QNUM3:  DW EXIT

;Z INTERPRET    i*x c-addr u -- j*x
;Z                      interpret given buffer
; This is a common factor of EVALUATE and QUIT.
; ref. dpANS-6, 3.4 The Forth Text Interpreter
;   'SOURCE 2!  0 >IN !
;   BEGIN
;   BL WORD DUP C@ WHILE        -- textadr
;       FIND                    -- a 0/1/-1
;       ?DUP IF                 -- xt 1/-1
;           1+ STATE @ 0= OR    immed or interp?
;           IF EXECUTE ELSE ,XT THEN
;       ELSE                    -- textadr
;           ?NUMBER
;           IF POSTPONE LITERAL     converted ok
;           ELSE COUNT TYPE 3F EMIT CR ABORT  err
;           THEN
;       THEN
;   REPEAT DROP ;
    head INTERPRET,9,'interpret',docolon
        DW TICKSOURCE,TWOSTORE,LIT,0,TOIN,STORE
INTER1: DW BL,WORD,DUP,CFETCH,QBRANCH,INTER9
        DW FIND,QDUP,QBRANCH,INTER4
        DW ONEPLUS,STATE,FETCH,ZEROEQUAL,fOR
        DW QBRANCH,INTER2
        DW EXECUTE,BRANCH,INTER3
INTER2: DW COMMAXT
INTER3: DW BRANCH,INTER8
INTER4: DW QNUMBER,QBRANCH,INTER5
        DW LITERAL,BRANCH,INTER6
INTER5: DW COUNT,TYPE,LIT,3FH,EMIT,fCR,ABORT
INTER6:
INTER8: DW BRANCH,INTER1
INTER9: DW DROP,EXIT

;C EVALUATE  i*x c-addr u -- j*x  interprt string
;   'SOURCE 2@ >R >R  >IN @ >R
;   INTERPRET
;   R> >IN !  R> R> 'SOURCE 2! ;
    head EVALUATE,8,'evaluate',docolon
        DW TICKSOURCE,TWOFETCH,TOR,TOR
        DW TOIN,FETCH,TOR,INTERPRET
        DW RFROM,TOIN,STORE,RFROM,RFROM
        DW TICKSOURCE,TWOSTORE,EXIT

;C QUIT     --    R: i*x --    interpret from kbd
;   L0 LP !  R0 RP!   0 STATE !
;   BEGIN
;       TIB DUP TIBSIZE ACCEPT  SPACE
;       INTERPRET
;       STATE @ 0= IF CR ." OK" THEN
;   AGAIN ;
    head fQUIT,4,'quit',docolon
        DW L0,LP,STORE
        DW R0,RPSTORE,LIT,0,STATE,STORE
QUIT1:  DW TIB,DUP,TIBSIZE,ACCEPT,fSPACE ;was CPMACCEPT
        DW INTERPRET
        DW STATE,FETCH,ZEROEQUAL,QBRANCH,QUIT2
        DW fCR,XSQUOTE
        DB 3,'ok '
        DW TYPE
QUIT2:  DW BRANCH,QUIT1

;C ABORT    i*x --   R: j*x --   clear stk & QUIT
;   S0 SP!  QUIT ;
    head ABORT,5,'abort',docolon
        DW S0,SPSTORE,fQUIT   ; QUIT never returns

;Z ?ABORT   f c-addr u --      abort & print msg
;   ROT IF TYPE ABORT THEN 2DROP ;
    head QABORT,6,'?abort',docolon
        DW ROT,QBRANCH,QABO1,TYPE,ABORT
QABO1:  DW TWODROP,EXIT

;C ABORT"  i*x 0  -- i*x   R: j*x -- j*x  x1=0
;C         i*x x1 --       R: j*x --      x1<>0
;   POSTPONE S" POSTPONE ?ABORT ; IMMEDIATE
    immed ABORTQUOTE,6,'abort"',docolon
        DW SQUOTE
        DW LIT,QABORT,COMMAXT
        DW EXIT

;C '    -- xt           find word in dictionary
;   BL WORD FIND
;   0= ABORT" ?" ;
;    head TICK,1,"'",docolon
        DW link                 ; must expand
        DB 0                    ; manually
link    DEFL $                  ; because of
        DB 1,27h                ; tick character
TICK:   call docolon
        DW BL,WORD,FIND,ZEROEQUAL,XSQUOTE
        DB 1,'?'
        DW QABORT,EXIT

;C CHAR   -- char           parse ASCII character
;   BL WORD 1+ C@ ;
    head CHAR,4,'char',docolon
        DW BL,WORD,ONEPLUS,CFETCH,EXIT

;C [CHAR]   --          compile character literal
;   CHAR  ['] LIT ,XT  , ; IMMEDIATE
    immed BRACCHAR,6,'[char]',docolon
        DW CHAR
        DW LIT,LIT,COMMAXT
        DW COMMA,EXIT

;C (    --                     skip input until )
;   [ HEX ] 29 WORD DROP ; IMMEDIATE
    immed PAREN,1,'(',docolon
        DW LIT,29H,WORD,DROP,EXIT

; COMPILER ======================================

;C CREATE   --      create an empty definition
;   LATEST @ , 0 C,         link & immed field
;   HERE LATEST !           new "latest" link
;   BL WORD C@ 1+ ALLOT         name field
;   docreate ,CF                code field
    head CREATE,6,'create',docolon
        DW LATEST,FETCH,COMMA,LIT,0,CCOMMA
        DW HERE,LATEST,STORE
        DW BL,WORD,CFETCH,ONEPLUS,ALLOT
        DW LIT,docreate,COMMACF,EXIT
        
;Z (DOES>)  --      run-time action of DOES>
;   R>              adrs of headless DOES> def'n
;   LATEST @ NFA>CFA    code field to fix up
;   !CF ;
    head XDOES,7,'(does>)',docolon
        DW RFROM,LATEST,FETCH,NFATOCFA,STORECF
        DW EXIT

;C DOES>    --      change action of latest def'n
;   COMPILE (DOES>)
;   dodoes ,CF ; IMMEDIATE
    immed DOES,5,'does>',docolon
        DW LIT,XDOES,COMMAXT
        DW LIT,dodoes,COMMACF,EXIT

;C RECURSE  --      recurse current definition
;   LATEST @ NFA>CFA ,XT ; IMMEDIATE
    immed RECURSE,7,'recurse',docolon
        DW LATEST,FETCH,NFATOCFA,COMMAXT,EXIT

;C [        --      enter interpretive state
;   0 STATE ! ; IMMEDIATE
    immed LEFTBRACKET,1,'[',docolon
        DW LIT,0,STATE,STORE,EXIT

;C ]        --      enter compiling state
;   -1 STATE ! ;
    head RIGHTBRACKET,1,']',docolon
        DW LIT,-1,STATE,STORE,EXIT

;Z HIDE     --      "hide" latest definition
;   LATEST @ DUP C@ 80 OR SWAP C! ;
    head HIDE,4,'hide',docolon
        DW LATEST,FETCH,DUP,CFETCH,LIT,80H,fOR
        DW SWOP,CSTORE,EXIT

;Z REVEAL   --      "reveal" latest definition
;   LATEST @ DUP C@ 7F AND SWAP C! ;
    head REVEAL,6,'reveal',docolon
        DW LATEST,FETCH,DUP,CFETCH,LIT,7FH,fAND
        DW SWOP,CSTORE,EXIT

;C IMMEDIATE   --   make last def'n immediate
;   1 LATEST @ 1- C! ;   set immediate flag
    head IMMEDIATE,9,'immediate',docolon
        DW LIT,1,LATEST,FETCH,ONEMINUS,CSTORE
        DW EXIT

;C :        --      begin a colon definition
;   CREATE HIDE ] !COLON ;
    head COLON,1,':',docode
        CALL docolon    ; code fwd ref explicitly
        DW CREATE,HIDE,RIGHTBRACKET,STORCOLON
        DW EXIT

;C ;
;   REVEAL  ,EXIT
;   POSTPONE [  ; IMMEDIATE
    immed SEMICOLON,1,';',docolon
        DW REVEAL,CEXIT
        DW LEFTBRACKET,EXIT

;C [']  --         find word & compile as literal
;   '  ['] LIT ,XT  , ; IMMEDIATE
; When encountered in a colon definition, the
; phrase  ['] xxx  will cause   LIT,xxt  to be
; compiled into the colon definition (where
; (where xxt is the execution token of word xxx).
; When the colon definition executes, xxt will
; be put on the stack.  (All xt's are one cell.)
;    immed BRACTICK,3,['],docolon
        DW link                 ; must expand
        DB 1                    ; manually
link    DEFL $                  ; because of
        DB 3,5Bh,27h,5Dh        ; tick character
BRACTICK: call docolon
        DW TICK               ; get xt of 'xxx'
        DW LIT,LIT,COMMAXT    ; append LIT action
        DW COMMA,EXIT         ; append xt literal

;C POSTPONE  --   postpone compile action of word
;   BL WORD FIND
;   DUP 0= ABORT" ?"
;   0< IF   -- xt  non immed: add code to current
;                  def'n to compile xt later.
;       ['] LIT ,XT  ,      add "LIT,xt,COMMAXT"
;       ['] ,XT ,XT         to current definition
;   ELSE  ,XT      immed: compile into cur. def'n
;   THEN ; IMMEDIATE
    immed POSTPONE,8,'postpone',docolon
        DW BL,WORD,FIND,DUP,ZEROEQUAL,XSQUOTE
        DB 1,'?'
        DW QABORT,ZEROLESS,QBRANCH,POST1
        DW LIT,LIT,COMMAXT,COMMA
        DW LIT,COMMAXT,COMMAXT,BRANCH,POST2
POST1:  DW COMMAXT
POST2:  DW EXIT
               
;Z COMPILE   --   append inline execution token
;   R> DUP CELL+ >R @ ,XT ;
; The phrase ['] xxx ,XT appears so often that
; this word was created to combine the actions
; of LIT and ,XT.  It takes an inline literal
; execution token and appends it to the dict.
;    head COMPILE,7,'COMPILE',docolon
;        DW RFROM,DUP,CELLPLUS,TOR
;        DW FETCH,COMMAXT,EXIT
; N.B.: not used in the current implementation

; CONTROL STRUCTURES ============================

;C IF       -- adrs    conditional forward branch
;   ['] QBRANCH ,BRANCH  HERE DUP ,DEST ;
;   IMMEDIATE
    immed fIF,2,'if',docolon
        DW LIT,QBRANCH,COMMABRANCH
        DW HERE,DUP,COMMADEST,EXIT

;C THEN     adrs --        resolve forward branch
;   HERE SWAP !DEST ; IMMEDIATE
    immed THEN,4,'then',docolon
        DW HERE,SWOP,STOREDEST,EXIT

;C ELSE     adrs1 -- adrs2    branch for IF..ELSE
;   ['] branch ,BRANCH  HERE DUP ,DEST
;   SWAP  POSTPONE THEN ; IMMEDIATE
    immed fELSE,4,'else',docolon
        DW LIT,BRANCH,COMMABRANCH
        DW HERE,DUP,COMMADEST
        DW SWOP,THEN,EXIT

;C BEGIN    -- adrs        target for bwd. branch
;   HERE ; IMMEDIATE
    immed BEGIN,5,'begin',docode
        jp HERE

;C UNTIL    adrs --   conditional backward branch
;   ['] QBRANCH ,BRANCH  ,DEST ; IMMEDIATE
;   conditional backward branch
    immed UNTIL,5,'until',docolon
        DW LIT,QBRANCH,COMMABRANCH
        DW COMMADEST,EXIT

;X AGAIN    adrs --      uncond'l backward branch
;   ['] branch ,BRANCH  ,DEST ; IMMEDIATE
;   unconditional backward branch
    immed AGAIN,5,'again',docolon
        DW LIT,BRANCH,COMMABRANCH
        DW COMMADEST,EXIT

;C WHILE    -- adrs         branch for WHILE loop
;   POSTPONE IF ; IMMEDIATE
    immed WHILE,5,'while',docode
        jp fIF

;C REPEAT   adrs1 adrs2 --     resolve WHILE loop
;   SWAP POSTPONE AGAIN POSTPONE THEN ; IMMEDIATE
    immed REPEAT,6,'repeat',docolon
        DW SWOP,AGAIN,THEN,EXIT

;Z >L   x --   L: -- x        move to leave stack
;   CELL LP +!  LP @ ! ;      (L stack grows up)
    head TOL,2,'>l',docolon
        DW CELL,LP,PLUSSTORE,LP,FETCH,STORE,EXIT

;Z L>   -- x   L: x --      move from leave stack
;   LP @ @  CELL NEGATE LP +! ;
    head LFROM,2,'l>',docolon
        DW LP,FETCH,FETCH
        DW CELL,NEGATE,LP,PLUSSTORE,EXIT

;C DO       -- adrs   L: -- 0
;   ['] xdo ,XT   HERE     target for bwd branch
;   0 >L ; IMMEDIATE           marker for LEAVEs
    immed DO,2,'do',docolon
        DW LIT,XDO,COMMAXT,HERE
        DW LIT,0,TOL,EXIT

;Z ENDLOOP   adrs xt --   L: 0 a1 a2 .. aN --
;   ,BRANCH  ,DEST                backward loop
;   BEGIN L> ?DUP WHILE POSTPONE THEN REPEAT ;
;                                 resolve LEAVEs
; This is a common factor of LOOP and +LOOP.
    head ENDLOOP,7,'endloop',docolon
        DW COMMABRANCH,COMMADEST
LOOP1:  DW LFROM,QDUP,QBRANCH,LOOP2
        DW THEN,BRANCH,LOOP1
LOOP2:  DW EXIT

;C LOOP    adrs --   L: 0 a1 a2 .. aN --
;   ['] xloop ENDLOOP ;  IMMEDIATE
    immed LOOP,4,'loop',docolon
        DW LIT,XLOOP,ENDLOOP,EXIT

;C +LOOP   adrs --   L: 0 a1 a2 .. aN --
;   ['] xplusloop ENDLOOP ;  IMMEDIATE
    immed PLUSLOOP,5,'+loop',docolon
        DW LIT,XPLUSLOOP,ENDLOOP,EXIT

;C LEAVE    --    L: -- adrs
;   ['] UNLOOP ,XT
;   ['] branch ,BRANCH   HERE DUP ,DEST  >L
;   ; IMMEDIATE      unconditional forward branch
    immed LEAVE,5,'leave',docolon
        DW LIT,UNLOOP,COMMAXT
        DW LIT,BRANCH,COMMABRANCH
        DW HERE,DUP,COMMADEST,TOL,EXIT

; OTHER OPERATIONS ==============================

;X WITHIN   n1|u1 n2|u2 n3|u3 -- f   n2<=n1<n3?
;  OVER - >R - R> U< ;          per ANS document
    head WITHIN,6,'within',docolon
        DW OVER,MINUS,TOR,MINUS,RFROM,ULESS,EXIT

;C MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
;  >R 2DUP SWAP DUP R@ +     -- ... dst src src+n
;  WITHIN IF  R> CMOVE>        src <= dst < src+n
;       ELSE  R> CMOVE  THEN ;          otherwise
    head MOVE,4,'move',docolon
        DW TOR,TWODUP,SWOP,DUP,RFETCH,PLUS
        DW WITHIN,QBRANCH,MOVE1
        DW RFROM,CMOVEUP,BRANCH,MOVE2
MOVE1:  DW RFROM,CMOVE
MOVE2:  DW EXIT

;C DEPTH    -- +n        number of items on stack
;   SP@ S0 SWAP - 2/ ;   16-BIT VERSION!
    head DEPTH,5,'depth',docolon
        DW SPFETCH,S0,SWOP,MINUS,TWOSLASH,EXIT

;C ENVIRONMENT?  c-addr u -- false   system query
;                         -- i*x true
;   2DROP 0 ;       the minimal definition!
    head ENVIRONMENTQ,12,'environment?',docolon
        DW TWODROP,LIT,0,EXIT

; UTILITY WORDS AND STARTUP =====================

;X WORDS    --          list all words in dict.
;   LATEST @ BEGIN
;       DUP COUNT TYPE SPACE
;       NFA>LFA @
;   DUP 0= UNTIL
;   DROP ;
    head WORDS,5,'words',docolon
        DW LATEST,FETCH
WDS1:   DW DUP,COUNT,TYPE,fSPACE,NFATOLFA,FETCH
        DW DUP,ZEROEQUAL,QBRANCH,WDS1
        DW DROP,EXIT

;X .S      --           print stack contents
;   SP@ S0 - IF
;       SP@ S0 2 - DO I @ U. -2 +LOOP
;   THEN ;
    head DOTS,2,'.s',docolon
        DW SPFETCH,S0,MINUS,QBRANCH,DOTS2
        DW SPFETCH,S0,LIT,2,MINUS,XDO
DOTS1:  DW II,FETCH,UDOT,LIT,-2,XPLUSLOOP,DOTS1
DOTS2:  DW EXIT

;Z COLD     --      cold start Forth system
;   UINIT U0 #INIT CMOVE      init user area
;   80 COUNT INTERPRET       interpret CP/M cmd
;   ." Z80 CamelForth etc."
;   ABORT ;
    head COLD,4,'cold',docolon
        DW UINIT,U0,NINIT,CMOVE
      ; DW LIT,80h,COUNT,INTERPRET
        DW XSQUOTE
        DB 35,'Z80 CamelForth v1.01  25 Jan 1995',0Dh,0Ah
        DW TYPE
	DW ABORT       ; ABORT never returns

