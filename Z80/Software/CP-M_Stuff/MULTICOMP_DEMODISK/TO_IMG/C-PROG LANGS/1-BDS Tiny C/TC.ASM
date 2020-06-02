;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; COPYRIGHT 1977, TINY-C ASSOCIATES ;;;;;;;;;;;;;;;;;;
;;;;;;    ALL RIGHTS RESERVED            ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG	($+100H)/100H*100H	;go to round address
LCFIX	EQU	20H	;maps literals to lower case
;error codes
STATERR	EQU	1
CURSERR	EQU	2
SYMERR	EQU	3
RPARERR EQU	5
RANGERR	EQU	6
CLASERR	EQU	7
SYNXERR	EQU	9
LVALERR	EQU	14
PUSHERR	EQU	16
TMFUERR	EQU	17
TMVRERR	EQU	18
TMVLERR	EQU	19
LINKERR	EQU	20
ARGSERR	EQU	21
LBRCERR	EQU	22
MCERR	EQU	24
SYMERRA	EQU	26
KILL	EQU	99
;recognition length of symbols
VLEN	EQU	8
;where tc exits to.
TCEXIT	EQU	0000H
;end-of-line character
ASCRET	EQU	0DH
;
;entry points
	JMP	COLD
	JMP	WARM
	JMP	HOT
;tailoring vector
ECHO	DB	0	;zero suppresses char echo
INCH	JMP	0103h
OUTCH	JMP	0106h
CHRDY	JMP	0109h
FOPEN	JMP	010Ch
FREAD	JMP	010Fh
FWRITE	JMP	0112h
FCLOSE	JMP	0115h
USERMC	JMP	0118h
PRBEGIN	NOP
	NOP
	RET
STBEGIN	NOP
	NOP
	RET
PRDONE	NOP
	NOP
	RET
;MC tools
XMCESET	JMP	MCESET
XTOPTOI	JMP	TOPTOI
XPUSHK	JMP	PUSHK
MCARGS	DB	0
;escape character
ESCAPE	DB	1BH
;space allocation
BSTACK	DW	1A00H
ESTACK	DW	-1A80H
BFUN	DW	1A80H
EFUN	DW	-1B00H
BVAR	DW	1B00H
EVAR	DW	-2200H
BPR	DW	2200H
EPR	DW	-4CF0H
MSTACK	DW	1A00H
;standard cells
ERR	DW	0
ERRAT	DW	0
LEAVE	DB	0
BRAKE	DB	0
TOP	DW	0
NXTVAR	DW	0
CURFUN	DW	0
CURGLBL	DW	0
FNAME	DW	0
LNAME	DW	0
STCURS	DW	0
CURSOR	DW	0
PRUSED	DW	0
PROGEND	DW	0	;stored negative
APPLVL	DB	0
;
;literals
BALPHS	EQU	$	;beginning of alphabetics
XIF	DB	LCFIX + 'i'
	DB	LCFIX + 'f'
	DB	0
XELS	DB	LCFIX + 'e'
	DB	LCFIX + 'l'
	DB	LCFIX + 's'
	DB	LCFIX + 'e'
	DB	0
XINT	DB	LCFIX + 'i'
	DB	LCFIX + 'n'
	DB	LCFIX + 't'
	DB	0
XCHAR	DB	LCFIX + 'c'
	DB	LCFIX + 'h'
	DB	LCFIX + 'a'
	DB	LCFIX + 'r'
	DB	0
XWHI	DB	LCFIX + 'w'
	DB	LCFIX + 'h'
	DB	LCFIX + 'i'
	DB	LCFIX + 'l'
	DB	LCFIX + 'e'
	DB	0
XRET	DB	LCFIX + 'r'
	DB	LCFIX + 'e'
	DB	LCFIX + 't'
	DB	LCFIX + 'u'
	DB	LCFIX + 'r'
	DB	LCFIX + 'n'
	DB	0
XBRK	DB	LCFIX + 'b'
	DB	LCFIX + 'r'
	DB	LCFIX + 'e'
	DB	LCFIX + 'a'
	DB	LCFIX + 'k'
	DB	0
XENDL	DB	LCFIX + 'e'
	DB	LCFIX + 'n'
	DB	LCFIX + 'd'
	DB	LCFIX + 'l'
	DB	LCFIX + 'i'
	DB	LCFIX + 'b'
	DB	LCFIX + 'r'
	DB	LCFIX + 'a'
	DB	LCFIX + 'r'
	DB	LCFIX + 'y'
	DB	0
XR	DB	LCFIX + 'r'	;loader 'read' command
XG	DB	LCFIX + 'g'	;'go' command
	DB	0FFH	;end of alphabetics
LB	DB	'['
	DB	0
RB	DB	']'
	DB	0
LPAR	DB	'('
	DB	0
RPAR	DB	')'
	DB	0
COMMA	DB	','
	DB	0
NEWLINE	DB	ASCRET
	DB	0
CMNT	DB	'/'
XSTAR	DB	'*'
	DB	0
SEMI	DB	';'
	DB	0
XPCNT	DB	'%'
	DB	0
XSLASH	DB	'/'
	DB	0
XPLUS	DB	'+'
	DB	0
XMINUS	DB	'-'
	DB	0
LT	DB	'<'
	DB	0
GT	DB	'>'
	DB	0
NOTEQ	DB	'!'
	DB	'='
	DB	0
EQEQ	DB	'='
XEQ	DB	'='
	DB	0
GE	DB	'>'
	DB	'='
	DB	0
LE	DB	'<'
	DB	'='
	DB	0
XNL	DB	ASCRET
	DB	0
;EQ performs an assignment of top into top-1. Top-1
;  must be an lvalue.
EQ	CALL	TOPTOI	;value into DE
	PUSH	D	;stuff to be assigned
	CALL	POPST	;where to assign
	ORA	A
	JZ	EQ2	;if class>0 set size=2
	MVI	C,2
EQ2	MOV	A,B	;must be lvalue
	CPI	'L'
	JNZ	EQERR
	XCHG		;where -> HL
	POP	D	;stuff -> DE
	MOV	M,E	;assign lo byte
	DCR	C	;size--
	JZ	PUSHK	;call/ret, put result on stack
	INX	H
	MOV	M,D	;hi byte
	JMP	PUSHK	;call/ret, put result on stack
EQERR	CALL	ESET
	DB	LVALERR
	POP	D
	JMP	PUSHK	;skip the assign part
;
;-(BC) -> BC
DNEG	MOV	A,C
	CMA
	MOV	C,A
	MOV	A,B
	CMA
	MOV	B,A
	INX	B
	RET
;
;difference between two top values -> DE, setting Z, CY
TOPDIF	CALL	POPTWO	;hence fall into DSUB.
;
; (DE) - (BC) -> DE
DSUB	MOV	A,E
	SUB	C
	MOV	E,A
	MOV	A,D
	SBB	B
	MOV	D,A
	ORA	E	;Z now set, CY clear
	MOV	A,D
	RLC		;sign is now in CY
	RET
;
; (BC) + (DE) -> DE
DADD	MOV	A,C
	ADD	E
	MOV	E,A
	MOV	A,B
	ADC	D
	MOV	D,A
	ORA	E	;Z now set. CY cleared.
	MOV	A,D
	RLC		;Sign is now in CY, Z not hurt.
	RET
;
; (BC) * (DE) -> DE
DMPY	LXI	H,0
DM2	MOV	A,C	;test lo bit of BC
	RRC
	JNC	DM3
	DAD	D	;add multiplier
DM3	CALL	BCRS	;shift BC right
	JNZ	DM4	;return if BC is 0
	XCHG		;answer -> DE
	RET
DM4	CALL	DELS	;shift multiplier left, return
	JNZ	DM2	;  if zero.
	XCHG
	RET
;
; shift BC right, setting Z if 0.
BCRS	XRA	A	;zero CY flag
	MOV	A,B
	RAR
	MOV	B,A
	MOV	A,C
	RAR		;picks up carry left by hi byte
	MOV	C,A
	ORA	B
	RET
; shift DE left. Sets z iff (DE)==0.
DELS	XRA	A	;zero CY flag
; rotate DE left, CY -> lo bit
RDEL	MOV	A,E	;lo byte first
	RAL
	MOV	E,A
	MOV	A,D
	RAL		;picks up carry left by lo byte
	MOV	D,A
	ORA	E
	RET
;
; (DE) % (BC) -> DE, quotient in HL.
DREM	MOV	A,D	;sign of result -> stack
	XRA	B
	PUSH	PSW
	MOV	A,D	;make factors positive
	ORA	A
	CM	DENEG
	MOV	A,B
	ORA	A
	CM	DNEG
	MVI	A,16	;shift count -> stack
	PUSH	PSW
	XCHG		;numerator -> HL
	LXI	D,0	;partial remainder -> DE
DR2	CALL	HLLS	;divide loop.  Long left shift
	CALL	RDEL	;  DEHL.
	JZ	DR3
	CALL	DCMP	;test BC <= DE
	JM	DR3
	MOV	A,L	;set lo bit of L, and subtract
	ORI	1	;  divisor from partial
	MOV	L,A	;  remainder
	CALL	DSUB
DR3	POP	PSW	;decrement shift count
	DCR	A
	JZ	DR4
	PUSH	PSW
	JMP	DR2
DR4	POP	PSW	;put sign on quotient and rem
	RP
	CALL	DENEG
	XCHG
	CALL	DENEG
	XCHG
	RET
;
; (DE) / (BC) -> DE
DDIV	CALL	DREM
	XCHG
	RET
;
; -(DE) -> DE
DENEG	MOV	A,D
	CMA
	MOV	D,A
	MOV	A,E
	CMA
	MOV	E,A
	INX	D
	RET
;
;double compare (DE) - (BC) changing neither, but
;  setting s, cy
;  Note that z is not set reliably.
DCMP	MOV	A,E
	SUB	C
	MOV	A,D
	SBB	B
	RET
;
;HL left shift
HLLS	DAD	H
	RET
;
;@@@@@@@@  stack tools  @@@@@@@@@@
;
;TOPTOI pops top of stack into DE, converting lvalue
;  to actual if necessary.
TOPTOI	CALL	POPST	;class in A, lvalue in B,
	STA	TPCLASS	;  size in C, stuff in DE
	MOV	A,B
	CPI	'A'
	JZ	TT2
	XCHG		;fetch data
	MOV	E,M
	INX	H
	MOV	D,M
TT2	DCR	C	;if size 1 and class 0 return
	RNZ		;  lo byte, with sign propgated
	LDA	TPCLASS	;  thru hi byte.
	ORA	A
	RNZ
	MOV	A,E
	RLC		;propogate sign into D.
	SBB	A
	MOV	D,A
	RET
TPCLASS	DB	0
;
;pops two from stack, top -> bc, next -> de.
POPTWO	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	POP	B
	RET
;
;pops the stack into A, B, C, DE. New top in HL.
POPST	LHLD	TOP
	MOV	A,M	;class
	INX	H
	MOV	B,M	;lvalue
	INX	H
	MOV	C,M	;size
	INX	H
	MOV	E,M	;stuff, lo-byte
	INX	H
	MOV	D,M	;stuff, hi-byte
	PUSH	B
	LXI	B,-9
	DAD	B	;decrement top by 5.
	POP	B
	SHLD	TOP
	RET
;
;pushes constant 1.
PONE	LXI	D,1
	JMP	PUSHK
;pushes constant 0.
PZERO	LXI	D,0
;pushes constant in DE
PUSHK	XRA	A	;class 0
	MVI	B,'A'	;actual
	MVI	C,2	;2 byte size
;pushes class (A), lvalue (B), size (C), stuff (DE)
;  onto stack.
PUSHST	LHLD	TOP	;add 5 to top.
	PUSH	D
	LXI	D,5
	DAD	D
	SHLD	TOP
	XCHG
	LHLD	ESTACK
	DAD	D
	XCHG		;top -> HL
	POP	D	;restore stuff
	JC	PERR
	MOV	M,A
	INX	H
	MOV	M,B
	INX	H
	MOV	M,C
	INX	H
	MOV	M,E
	INX	H
	MOV	M,D
	RET
PERR	CALL	ESET
	DB	PUSHERR
	RET
;
; @@@@@@@@ ESET sets ERR unless one is already set @@@@
ESET	LDA	ERR
	XTHL
	ORA	A
	JZ	ES2
	INX	H
	XTHL
	RET
ES2	MOV	A,M
	INX	H
	XTHL
	STA	ERR
	LHLD	CURSOR
	SHLD	ERRAT
	RET
;
;store 0's from (DE) thru (HL) inclusive
ZERO	MVI	B,0
;store (B) from (DE) thru (HL) inclusive
BZAP	MOV	A,L
	SUB	E
	MOV	A,H
	SBB	D
	RC
	MOV	M,B
	DCX	H
	JMP	BZAP
;
;print string starting at (HL), terminated by null byte
PS	MOV	A,M
	ORA	A
	RZ
	CALL	OUTCH
	INX	H
	JMP	PS
;
;@@@@@@@@@  SCAN TOOLS  @@@@@@@@@@@@
;
;LIT is used to match literals. It advances the cursor
;  over blanks, then attempts a match with the literal.
;  DE points to the literal, which is terminated by a
;  null byte. On match, the cursor is advanced
;  beyond the matched text, and NZ is set. On no match
;  the cursor is not advanced (except over the initial
;  blanks), and Z is set. LIT is called often, so some
;  attention to speed is given, mainly by using inline
;  code for blanks and string matching.
LIT	LHLD	CURSOR
	MVI	A,' '	;trim blanks
LIT2	CMP	M
	JNZ	LIT3
	INX	H
	JMP	LIT2
LIT3	SHLD	CURSOR	;capture cursor, in case no mch
LIT4	LDAX	D	;char from literal
	ORA	A
	JZ	MATCH	;null signals end of literal
	CMP	M	;char from program
	INX	D
	INX	H
	JZ	LIT4
	XRA	A	;no match, return Zero
	ORA	A
	RET
MATCH	SHLD	CURSOR	;capture new cursor
	CMA		;return Not Zero
	ORA	A
	RET
;
;advances cursor over blanks. Puts cursor in HL.
BLANKS	LHLD	CURSOR
	MVI	A,' '
LOOP	CMP	M
	JNZ	BLOUT
	INX	H
	JMP	LOOP
BLOUT	SHLD	CURSOR
	RET
;
;skips over balanced l-r delimiters, (assuming the
;first l delimiter is already matched.) Tests that
;cursor stays within program limits, and sets ERR and
;doesn't advance cursor on violation.
SKIP	MVI	D,1	;counter
SK2	MOV	A,M
	CMP	B
	JZ	SKL	;match left delimiter
	CMP	C
	JNZ	SKNEXT
	DCR	D	;match right delimiter
	JNZ	SKNEXT
	INX	H	;all done, bump over last
	SHLD	CURSOR	;  matched.
	STC
	CMC		;CY off on success
	RET
SKL	INR	D
SKNEXT	INX	H	;bump HL, test for overflow
	XCHG		;cursor -> DE
	PUSH	H	;make H safe
	LHLD	PROGEND	;stored negative, so add
	DAD	D
	POP	H
	XCHG		;now all reg's restored
	JNC	SK2
	CALL	ESET
	DB	CURSERR
	STC		;CY set on error
	RET
;
;tests if (A) is alphanumeric. Plus on yes.
ALNUM	CPI	'0'
	RM
	CPI	'9'+1
	JM	YESA
;tests if (A) is alpha. Plus on yes.
ALPHA	CPI	'A'
	RM		;not alpha
	CPI	'Z'+1
	JM	YESA
	CPI	LCFIX + 'a'
	RM
	CPI	LCFIX + 'z'+1
	JM	YESA
	CMA		;not alpha, this sets Minus.
	ORA	A
	RET
YESA	XRA	A	;set Plus.
	RET
;
;matches a variable or function name. Sets FNAME,
;  LNAME to first and last chars of the name. Returns
;  Not Zero on match, Zero on no match.
SYMNAME	CALL	BLANKS
	SHLD	FNAME
	MOV	A,M
	CALL	ALPHA
	JM	SY3
SY2	INX	H	;is a symbol, find its end.
	MOV	A,M
	CALL	ALNUM
	JP	SY2
	SHLD	CURSOR	;just beyond symbol
	DCX	H
	SHLD	LNAME	;symbol end
	RET
SY3	XRA	A	;no symbol, return Z
	RET
;
;matches 3 kinds of constants, setting FNAME, LNAME as
;  in SYMNAME. Sets A to 0 on no match, 1,2,or 3 on mch
CONST	CALL	BLANKS
	MOV	A,M	;first char
	CPI	'+'	;test for number
	JZ	CN2
	CPI	'-'
	JZ	CN2
	CPI	'0'
	JM	CN3
	CPI	'9'+1
	JP	CN3
CN2	SHLD	FNAME	;number, cursor to fname
CN4	INX	H	;find end
	MOV	A,M
	CPI	'0'
	JM	CN5
	CPI	'9'+1
	JM	CN4	;is a digit, keep going
CN5	SHLD	CURSOR	;not a digit
	DCX	H
	SHLD	LNAME
	MVI	A,1	;type 1 constant (integer)
	RET
CN3	CPI	'"'	;test for quoted string
	JNZ	CN6
	INX	H	;quote found
	SHLD	FNAME	;first char of string (quote
CN7	MOV	A,M	;  excluded
	ORA	A	;ended by either null or "
	JZ	CN8
	SBI	'"'
	JZ	CN8
	INX	H
	XCHG		;cursor check
	LHLD	PROGEND
	DAD	D
	XCHG
	JNC	CN7
	JMP	CNERR	;cursor overflow
CN8	MOV	M,A	;end quote found, replace with
	DCX	H	;  a null.
	SHLD	LNAME	;last char of string
	MVI	A,2	;constant of type 2 (char str)
	ORA	A
	INX	H
	INX	H
	SHLD	CURSOR
	RET
CN6	CPI	27H	;test for prime
	JNZ	CN9
	INX	H
	SHLD	FNAME
CN12	MOV	A,M	;scan for matching prime
	CPI	27H
	JZ	CN11
	INX	H
	XCHG		;cursor check
	LHLD	PROGEND
	DAD	D
	XCHG
	JNC	CN12
	JMP	CNERR
CN11	MVI	A,3	;found matching prime
	ORA	A
	INX	H
	SHLD	CURSOR
	RET
CN9	XRA	A	;no match
	RET
CNERR	CALL	ESET
	DB	CURSERR
	RET
;
;skips over remarks and/or end-of-lines in any order.
REM	LXI	D,NEWLINE
	CALL	LIT
	JZ	RE2
RE3	MOV	A,M	;skip linefeeds
	CPI	0AH
	JNZ	REM
	INX	H
	SHLD	CURSOR
	JMP	REM
RE2	LXI	D,CMNT
	CALL	LIT
	RZ
	MVI	B,1	;comment found, skip its text
	MVI	C,ASCRET
	CALL	SKIP
	RC		;error check
	JMP	RE3
;
;HL points to start of digit string. Converts to intger
;  leaving result in DE. Uses all digits, even if DE
;  overflows. First nondigit stops scan.
ATON	XCHG		;pointer into DE
	LXI	H,0	;answer developed here
AN2	LDAX	D	;next ascii
	SUI	48
	JC	AN3	;test for digit
	CPI	10
	JNC	AN3
	MOV	B,H	;digit, set HL=10*HL+A
	MOV	C,L
	DAD	H
	DAD	H
	DAD	B
	DAD	H
	MOV	C,A
	MVI	B,0
	DAD	B
	INX	D	;bump pointer
	JMP	AN2
AN3	XCHG		;answer -> DE
	RET
;
;HL points to beginning of ascii integer, possibly
;  signed. Converts to integer and leaves value in DE.
AISGN	DB	0	;nonzero for -
ATOI	XRA	A
	STA	AISGN
AI6	MOV	A,M	;skip blanks
	CPI	' '
	JNZ	AI2
	INX	H
	JMP	AI6
AI2	CPI	'-'	;test sign
	JNZ	AI3
	STA	AISGN	;is -
	INX	H
AI3	CPI	'+'
	JNZ	AI4
	INX	H
AI4	MOV	A,M	;skip more blanks
	CPI	' '
	JNZ	AI5
	INX	H
	JMP	AI4
AI5	CALL	ATON	;does the digits
	LDA	AISGN	;magnitude in DE
	ORA	A
	RZ
	JMP	DENEG	;computes negative and returns
;
;@@@@@@@@@  SYMBOL TOOLS  @@@@@@@@@@@
;
;allocate reference in FUNB for variables of a function
NEWFUN	LHLD	CURFUN
	LXI	D,6	;bump CURFUN by 6
	DAD	D
	SHLD	CURFUN
	XCHG		;test too many active functions
	LHLD	EFUN
	DAD	D
	XCHG
	JNC	NF2
	CALL	ESET
	DB	TMFUERR
	RET
NF2	LDA	NXTVAR	;init first and last var
	MOV	M,A	;fv lo byte
	SUI	6+VLEN
	MOV	C,A	;lv lo byte -> C for now
	LDA	NXTVAR+1
	INX	H
	MOV	M,A	;fv hi byte
	SBI	0	;picks up possible carry
	INX	H
	MOV	M,C	;lv lo byte
	INX	H
	MOV	M,A	;lv hi byte
	LDA	PRUSED	;now set up backup pointer
	INX	H
	MOV	M,A	;bu lo byte
	LDA	PRUSED+1
	INX	H
	MOV	M,A	;bu hi bytv
	RET		;all done
;
;deallocate variables of last function.
FUNDONE	LHLD	CURFUN
	MOV	A,M
	STA	NXTVAR	;lo byte
	INX	H
	MOV	A,M
	STA	NXTVAR+1
	INX	H
	INX	H
	INX	H
	MOV	A,M
	STA	PRUSED
	INX	H
	MOV	A,M
	STA	PRUSED+1
	LXI	D,-11
	DAD	D	;subtract 5 for above INX's,
	SHLD	CURFUN	;  plus 5 more to pop FUNB.
	RET
;
;allocate a variable. Class in A, size in B, len in DE,
;  passed value in HL.
CLASS	DB	0	;temps used by newvar
OBSIZE	DB	0
PASSED	DW	0
LEN	DW	0
FVAL	DW	0
KF	DW	0
;
NEWVAR	STA	CLASS
	MOV	A,B
	STA	OBSIZE
	SHLD	PASSED
	XCHG
	SHLD	LEN
	LHLD	NXTVAR
	CALL	CANON	;put canonical form of name
;			 into (NXTVAR). Leaves HL
;	pointing to last byte of NAME of VARB.
	INX	H	;-> CLASS in VARB.
	LDA	CLASS
	MOV	M,A
	INX	H	;-> OBJSIZE in VARB.
	LDA	OBSIZE
	MOV	M,A
	INX	H	;-> LEN in VARB (2 bytes).
	LDA	LEN
	MOV	M,A
	INX	H
	LDA	LEN+1
	MOV	M,A
	INX	H
	SHLD	FVAL	;address where fval will be put
	LDA	CLASS
	ORA	A	;if class is 0, or not a passed
	JZ	NR2	;  arg, then get value space.
	LHLD	PASSED
	MOV	A,L
	ORA	H
	JNZ	NR3
NR2	LHLD	PRUSED	;get value space
	INX	H	;  starting at PRUSED + 1
	SHLD	KF	;Put in KF for later use.
	XCHG
	LHLD	FVAL
	MOV	M,E
	INX	H
	MOV	M,D	;fval part of varb set to
	LHLD	LEN	;  prused+1. Now bump prused
	XCHG		;  by obsize*len.
	LHLD	PRUSED
	LDA	OBSIZE
	DAD	D
	DCR	A
	JZ	NR7
	DAD	D
NR7	SHLD	PRUSED
	XCHG		;test if allocation exceeds
	LHLD	EPR	;  limits of prog space.
	DAD	D
	XCHG
	JNC	NR4
	CALL	ESET	;RAM exceeded
	DB	TMVLERR
	RET
NR4	LHLD	KF	;zero the allocated space
	XCHG
	LHLD	PRUSED
	CALL	ZERO
	JMP	NR5	;end of space allocation
NR3	LHLD	FVAL	;Value is passed and is a
	LDA	PASSED	;  class > 0. Put value in fval
	MOV	M,A	;  part of VARB. Dont allocate
	INX	H	;  space.
	LDA	PASSED+1
	MOV	M,A
	JMP	NR6
NR5	LDA	CLASS	;if passed & class is 0 move
	ORA	A	;  the passed value into the
	JNZ	NR6	;  allocated space.
	LHLD	PASSED
	MOV	A,H
	ORA	L
	JZ	NR6
	XCHG		;passed -> DE
	LHLD	KF
	MOV	M,E	;lo byte of passed value
	INX	H
	MOV	M,D	;hi byte, or junk if only one
;			   byte passed. Who cares.
NR6	LHLD	CURFUN	;in FUNB set lvar part to this
	INX	H	;  variable.
	INX	H
	LDA	NXTVAR
	MOV	M,A
	INX	H
	LDA	NXTVAR+1
	MOV	M,A
	LHLD	NXTVAR	;increment NXTVAR
	LXI	D,6+VLEN	;  by 6 + vlen
	DAD	D
	SHLD	NXTVAR
	XCHG		;test if too many variables
	LHLD	EVAR
	DAD	D
	XCHG
	LHLD	FVAL
	RNC		;normal return, FVAL in HL.
	CALL	ESET	;VARB exceeded.
	DB	TMVRERR
	RET
;
;ADDRVAL looks up a symbol pointed to by FNAME,LNAME.
;  Returns address in HL, class in A, size in B, and
;  length in DE. Sets err if symbol cannot be found.
;  Searches 3 areas:
;	area	0	locals
;		1	globals
;		2	library symbols
NAME	DS	VLEN	;holds canonical form of name
PVAR	DW	0
AREA	DB	0
SFUN	DW	0
LAST	DW	0
;
ADDRVAL	LHLD	CURFUN
	SHLD	SFUN	;search locals first
	LXI	H,NAME
	CALL	CANON
	XRA	A
	STA	AREA	;area 0
AD8	LHLD	SFUN	;variable search area
	MOV	E,M
	INX	H
	MOV	D,M	;fvar of search area -> DE
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M	;lvar -> BC
	XCHG
	SHLD	PVAR	;currently searched variable
	MOV	H,B
	MOV	L,C
	SHLD	LAST	;last to search in this area
	LHLD	PVAR	;begin search loop
AD2	LDA	LAST	;test for end of loop
	SUB	L
	LDA	LAST+1
	SBB	H
	JC	AD3
	MVI	C,VLEN	;number of chars to match
	LXI	D,NAME	;match string address
AD4	LDAX	D	;(HL already as table entry)
	CMP	M
	JNZ	AD5	;no match
	DCR	C
	INX	D
	INX	H
	JNZ	AD4	;next char
	MOV	A,M	;MATCH. HL points to class.
	INX	H
	MOV	B,M	;obsize
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M	;length
	INX	H
	ORA	A	;if class > 0 & class < 'E'
	JZ	AD9	;  then return address of fval
	CPI	'E'	;  part of VARB, which is alrdy
	RNZ		;  in HL.
AD9	PUSH	D	;otherwise return contents of
	MOV	E,M	;  fval part of VARB.
	INX	H
	MOV	D,M
	XCHG
	POP	D
	RET
AD5	LHLD	PVAR	;go to next variable
	LXI	D,VLEN+6
	DAD	D
	SHLD	PVAR
	JMP	AD2
AD3	LDA	AREA	;go to next area
	ORA	A
	JNZ	AD6
	LHLD	CURGLBL	;second search area, globals
AD7	SHLD	SFUN
	INR	A
	STA	AREA
	JMP	AD8
AD6	CPI	2
	JP	ADERR
	LHLD	BFUN	;third area is library, which
	JMP	AD7	;  is at beginning of FUNB.
ADERR	CALL	ESET
	DB	SYMERRA
	RET
;
;canonicalizes symbol from FNAME to LNAME inclusive,
;  putting form with VLEN chars in (HL).
OUTNAME	DW	0
CANON	SHLD	OUTNAME
	MVI	A,VLEN	;zero output field
	MVI	B,0
	MOV	C,B	;zero C for later
CA2	MOV	M,B
	DCR	A
	JZ	CA3
	INX	H
	JMP	CA2
CA3	PUSH	H	;save pointer to last byte
	LHLD	FNAME	;compute symbols actual length
	LDA	LNAME
	SUB	L
	INR	A
	CPI	VLEN
	JM	CA6
	MVI	A,VLEN	;A now has number of chars to
	MOV	C,A	;  be moved, and C is nonzero
CA6	XCHG		;  iff act len > VLEN.
	MOV	B,A
	LHLD	OUTNAME	;FNAME -> DE, OUTNAME -> HL
CA4	LDAX	D	;copy loop
	MOV	M,A
	DCR	B
	JZ	CA5
	INX	D
	INX	H
	JMP	CA4
CA5	POP	H	;pointer to last byte
	XRA	A
	ORA	C	;test if short name
	RZ
	XCHG		;long name, put last char in
	LHLD	LNAME	;  the canon form.
	MOV	A,M	;last char of name
	XCHG
	MOV	M,A	;into last pos of outname
	RET
;ASGN is the expression evaluator,so called because
;  the highest form of an expression is an assignment.
;  An asgn is a reln or an lvalue = asgn. Note that
;  reln can match an lvalue.
;Returns non-zero if valid expression, 0 if invalid.
ASGN	CALL	RELN	;stacked as lvalue if that's
;			  what it is.
	LXI	D,XEQ	; test for =
	CALL	LIT
	JZ	A2
	CALL	ASGN
	LDA	ERR	;check for error
	ORA	A
	CZ	EQ	;perform assignment
A2	LDA	ERR	;return 0 (i.e. no match) if
	ORA	A	;  there was an error
	JZ	A3
	XRA	A
	RET
A3	DCR	A	;no error so return non-zero A
	RET
;
;a RELN is an expr or a comparison of exprs
RELN	CALL	EXPR
	LXI	D,LE	; <=
	CALL	LIT
	JZ	R2
	CALL	EXPR	;right side
	CALL	TOPDIF	;sets Z,C flags. C set as
	JZ	PONE	;  though it were S. Must be
	JC	PONE	;  zero or negative for true.
	JMP	PZERO	;These jumps all call/rets.
R2	LXI	D,GE	; >=
	CALL	LIT
	JZ	R3
	CALL	EXPR
	CALL	TOPDIF
	JZ	PONE
	JNC	PONE
	JMP	PZERO
R3	LXI	D,EQEQ	; ==
	CALL	LIT
	JZ	R4
	CALL	EXPR
	CALL	TOPDIF
	JZ	PONE
	JMP	PZERO
R4	LXI	D,NOTEQ
	CALL	LIT
	JZ	R5
	CALL	EXPR
	CALL	TOPDIF
	JNZ	PONE
	JMP	PZERO
R5	LXI	D,GT	; >
	CALL	LIT
	JZ	R6
	CALL	EXPR
	CALL	TOPDIF
	JZ	PZERO
	JC	PZERO
	JMP	PONE
R6	LXI	D,LT	; <
	CALL	LIT
	RZ		; no relational operator
	CALL	EXPR
	CALL	TOPDIF
	JC	PONE
	JMP	PZERO
;
;an EXPR is a term or sum (diff) of terms.
EXPR	LXI	D,XMINUS	; unary -
	CALL	LIT
	JZ	EX2
	CALL	TERM
	CALL	TOPTOI	;push negative of top back onto
	MOV	A,E
	CMA
	MOV	E,A
	MOV	A,D
	CMA
	MOV	D,A
	INX	D
	CALL	PUSHK
	JMP	EX3
EX2	LXI	D,XPLUS	;optional unary +
	CALL	LIT
	CALL	TERM
;first term is now stacked. Check for error so far.
EX3	LDA	ERR
	ORA	A
	RNZ
	LXI	D,XPLUS	; +
	CALL	LIT
	JZ	EX4
	CALL	TERM
	CALL	POPTWO	;top two values on stack are
;			  actualized and put into
;			  (BC) and (DE).
	CALL	DADD	; (BC)+(DE)->(DE)
	CALL	PUSHK	; sum onto stack.
	JMP	EX3	;back for more terms
EX4	LXI	D,XMINUS ; -
	CALL	LIT
	RZ		;no more terms
	CALL	TERM
	CALL	POPTWO
	CALL	DSUB
	CALL	PUSHK
	JMP	EX3	;back for more terms.
;
;a term is a factor or a product of factors.
TERM	CALL	FACTOR
TE2	LDA	ERR	;check for error so far
	ORA	A
	RNZ
	LXI	D,XSTAR	; *
	CALL	LIT
	JZ	TE3
	CALL	FACTOR
	CALL	POPTWO
	CALL	DMPY
	CALL	PUSHK
	JMP	TE2	;back for more factors.
TE3	CALL	REM	;make sure no /*
	LXI	D,XSLASH	; /
	CALL	LIT
	JZ	TE4
	CALL	FACTOR
	CALL	POPTWO
	CALL	DDIV
	CALL	PUSHK
	JMP	TE2
TE4	LXI	D,XPCNT	; %
	CALL	LIT
	RZ		;no more factors.
	CALL	FACTOR
	CALL	POPTWO
	CALL	DREM
	CALL	PUSHK
	JMP	TE2
;
;a FACTOR is a ( asgn ), or a constant, or a variable
;  reference, or a function reference.
FACTOR	LXI	D,LPAR	; (
	CALL	LIT
	JZ	FA2
	CALL	ASGN
	LXI	D,RPAR	; )
	CALL	LIT
	RNZ
	CALL	ESET	;right paren error
	DB	RPARERR
	RET
FA2	CALL	CONST	;recognizes 3 types of constant
	JZ	FA5	;  setting A accordingly.
	CPI	1
	JNZ	FA3
	LHLD	FNAME	;type 1: integer. FNAME points
	CALL	ATOI	;  to beginning. ATOI converts
	JMP	PUSHK	;  it, leaving value in (DE).
FA3	CPI	2
	JNZ	FA4
	MVI	A,1	;type 2: char string. Push
	MVI	B,'A'	;  class=1, lval='A', size=1,
	MVI	C,1	;  and stuff=address of
	LHLD	FNAME	;  beginning of string.
	XCHG
	JMP	PUSHST
FA4	XRA	A	;type 3: char constant. Push
	MVI	B,'A'	;  class=0, lval='A', size=1,
	MVI	C,1	; and stuff=actual character.
	LHLD	FNAME
	MOV	E,M
	JMP	PUSHST
FA5	CALL	SYMNAME	;not a constant, try symbol.
	JZ	FA6
	LHLD	FNAME	;symbol. Test for special
	INX	H	;  symbol MC. First is symbol
	LDA	LNAME	;  length exactly 2.
	CMP	L
	JNZ	FA7
	LDA	LNAME+1
	CMP	H
	JNZ	FA7
	MOV	A,M	;length is 2, and (HL)=FNAME.
	CPI	'C'
	JNZ	FA7
	DCX	H
	MOV	A,M
	CPI	'M'
	JNZ	FA7
	LXI	H,0
	JMP	ENTER	;causes machine call.
FA7	CALL	ADDRVAL	;not MC, look up symbol.
	SHLD	FWHERE
	STA	CLASS
	MOV	A,B	;save results of lookup.
	STA	OBSIZE
	XCHG
	SHLD	LEN
	MOV	A,D	;where is now in DE
	ORA	E
	JZ	FA8
	LDA	CLASS
	CPI	'E'	;class E => function entry
	JZ	FA9
	LXI	D,LPAR	;variable. Test for subscript.
	CALL	LIT
	JZ	FA10
	LDA	CLASS	;subscripted, class must be > 0
	DCR	A
	STA	CLASS	;class of element is one less
	JP	FA11	;  than class of array.
	CALL	ESET
	DB	CLASERR
	RET
FA11	LHLD	FWHERE	;replace where by two bytes
	MOV	E,M	;  referenced by where.
	INX	H
	MOV	D,M
	PUSH	D	;save where, len, class,
	LHLD	LEN	;  obsize.
	PUSH	H
	LHLD	CLASS	;(also gets obsize)
	PUSH	H
	CALL	ASGN	;evaluate subscript
	POP	H
	SHLD	CLASS	;restore everything
	POP	H
	SHLD	LEN
	POP	H
	SHLD	FWHERE
	RZ		;assign error
	LXI	D,RPAR	;skip )
	CALL	LIT
	CALL	TOPTOI	;subscript value -> DE
	XCHG
	SHLD	SUBSCR
	XCHG
	LHLD	LEN
	MOV	A,L
	DCR	A
	ORA	H	;for LEN = 1 skip subscript
	JZ	FA12	;  check.
	LDA	CLASS
	ORA	A
	JNZ	FA12	;skip for pointers, too.
	ORA	D
	JM	SUBERR	;cant be negative
	MOV	B,H	;len -> BC
	MOV	C,L
	CALL	DSUB
	JC	FA12	;subscr-len must be negative
SUBERR	CALL	ESET
	DB	RANGERR
FA12	LHLD	SUBSCR
	XCHG		;where =+ subscr * obsize
	LHLD	FWHERE
	LDA	OBSIZE
FA13	DCR	A
	JM	FA14
	DAD	D
	JMP	FA13
FA14	SHLD	FWHERE
FA10	LDA	OBSIZE	;push class, 'L', obsize,
	MOV	C,A	;  stuff=where.
	LDA	CLASS
	MVI	B,'L'
	LHLD	FWHERE
	XCHG
	JMP	PUSHST	;call/ret
FA9	LHLD	FWHERE
	JMP	ENTER	;call/ret
FA8	CALL	ESET	;symbol error
	DB	SYMERR
	RET
FA6	CALL	ESET	;cannot recognize factor
	DB	SYNXERR
	RET
;
;locals used by ASGN, etc.
FWHERE	DW	0
SUBSCR	DW	0
;SKIPST skips over a (possibly compound) statement,
;  including whole nested sets of if-then-elses.
;  Assumes balanced [], even within comments.
SKIPST	CALL	REM
	LXI	D,LB	;test for [
	CALL	LIT
	JZ	SS2
	MVI	B,'['
	MVI	C,']'
	CALL	SKIP
	JMP	REM	;and done
SS2	LXI	D,XIF	;test for if or while
	CALL	LIT
	JNZ	SS6
	LXI	D,XWHI
	CALL	LIT
	JZ	SS3
SS6	LXI	D,LPAR
	CALL	LIT
	MVI	B,'('
	MVI	C,')'
	CALL	SKIP	;skip over (condition) part
	CALL	SKIPST	;skip then part
	LXI	D,XELS	;test for ELSE
	CALL	LIT
	CNZ	SKIPST	;skip else part
	JMP	REM	;and done
SS3	LHLD	CURSOR	;simple statement, move cursor
SS4	MOV	A,M	;  past next ; or return.
	CPI	ASCRET
	JZ	SS8
	CPI	';'
	JZ	SS5
	INX	H
	XCHG		;test cursor overflow
	LHLD	PROGEND
	DAD	D
	XCHG
	JNC	SS4
	JMP	REM	;and done
SS5	INX	H
SS8	SHLD	CURSOR
	JMP	REM	;and done
;
;VALLOC parses one variable behind INT or CHAR and
;  makes allocation and symbol entry.
TYPE	DB	0	;'C' or 'I'
VPASSED	DW	0	;0 for global or local, two
;			 byte value if param to fnction
;	It turns out a 0 valued parameter gets the same
;	treatment as a local.
VCLASS	DB	0	;defined in globals section.
ALEN	DW	0	;elements in an array.
;
VALLOC	STA	TYPE
	SHLD	VPASSED
	CALL	SYMNAME	;sets FNAME, LNAME around symbl
	JZ	V2	;error if no symbol.
	XRA	A
	STA	VCLASS	;assume class 0 (not an array)
	LXI	D,LPAR
	CALL	LIT
	JZ	V3
	LHLD	FNAME	;array, evaluate subscript
	PUSH	H	;  expression. Must push FNAME,
	LHLD	LNAME	;  LNAME, and class, because
	PUSH	H	;  subscripts may invoke
	LDA	VCLASS	;  functions which themselves
	INR	A	;  allocate variables.
	PUSH	PSW
	CALL	ASGN
	POP	PSW	;restore pushed stuff.
	STA	VCLASS
	POP	H
	SHLD	LNAME
	POP	H
	SHLD	FNAME
	LDA	ERR	;test for error in ASGN
	ORA	A
	RNZ
	LXI	D,RPAR
	CALL	LIT	;skip )
	CALL	TOPTOI	;value of subscript + 1 into
	INX	D	;  LEN
	XCHG
	SHLD	ALEN
	JMP	V5
V3	LXI	H,1	;non-subscripted variable
	SHLD	ALEN	;  has ALEN 1.
V5	LDA	TYPE	;object size is 1 of 'C', 2 for
	MVI	B,1	;  'I'
	CPI	'C'
	JZ	V7
	INR	B	;obsize in B
V7	LDA	VCLASS	;class in A
	LHLD	ALEN	;len in DE.
	XCHG
	LHLD	VPASSED	;passed in HL
	JMP	NEWVAR	;call/ret, NEWVAR allocates the
;			   variable
V2	CALL	ESET
	DB	SYMERR
	RET
;
;@@@@@@@@@@ tiny - c interpreter @@@@@@@@@@@@
;
;ST interprets a possibly compound statement
;
ST	CALL	QUIT	;test if program should quit.
	LDA	ERR
	ORA	A
	RNZ
	CALL	REM	;pass over remarks and/or
;			end of line
	CALL	STBEGIN	;bugout for blips, statistics,
;			;  etc, user provided.
ST2	LHLD	CURSOR	;capture cursor
	SHLD	STCURS
	CALL	DECL	;test for declaration
	JNZ	REM
	LXI	D,LB	;test for left bracket
	CALL	LIT
	JZ	TIF
	CALL	REM
CMPND	LDA	ERR	;compound statement. Execute
	MOV	B,A	;  each of its inner stmnts.
	LDA	LEAVE	;  Exit on error, leave, break,
	ORA	B	;  or ] literal.
	MOV	B,A
	LDA	BRAKE
	ORA	B
	RNZ
	LXI	D,RB	; ]
	CALL	LIT
	JNZ	REM	;and done
	CALL	ST	;recursive call to ST
	JMP	CMPND	;then do next statement.
TIF	LXI	D,XIF	;test for IF
	CALL	LIT
	JZ	TWHI
	LXI	D,LPAR	;skip (
	CALL	LIT
	CALL	ASGN	;evaluate condition
	RZ		;return on error
	LXI	D,RPAR	;skip )
	CALL	LIT
	CALL	TOPTOI	;condition value
	MOV	A,D
	ORA	E
	JZ	IF2
	CALL	ST	;true, execute conditional
	LXI	D,XELS	;skip else clause if there
	CALL	LIT
	CNZ	SKIPST
	RET
IF2	CALL	SKIPST	;false, skip conditional
	LXI	D,XELS	;execute else clause if there
	CALL	LIT
	CNZ	ST
	RET
TWHI	LXI	D,XWHI	;test for WHILE
	CALL	LIT
	JZ	TSEM
	LXI	D,LPAR	;skip (
	CALL	LIT
	CALL	ASGN	;condition
	RZ		;return on error
	LXI	D,RPAR	;skip )
	CALL	LIT
	CALL	TOPTOI	;condition value
	MOV	A,D
	ORA	E
	JZ	WH2
	LHLD	STCURS	;true, save STCURS and CURSOR
	PUSH	H
	LHLD	CURSOR
	PUSH	H
	CALL	ST	;execute object of while
	POP	H	;saved cursor into OBJT
	SHLD	OBJT
	POP	H	;  and stcurs into AGIN
	SHLD	AGIN
	LDA	BRAKE	;if a BREAK statement caused
	ORA	A	;  this return, then set CURSOR
	JZ	WH3	;  to object of the while and
	LHLD	OBJT	;  skip over it, and restore
	SHLD	CURSOR	;  break. The WHILE is alllll
	CALL	SKIPST	;  done.
	XRA	A
	STA	BRAKE
	RET
WH3	LHLD	AGIN	;Otherwise, set cursor back to
	SHLD	CURSOR	;  beginning of while statement
	RET		;  and return, causing WHILE to
;			   to be done again.
WH2	CALL	SKIPST	;If condition is false, skip
	RET		;  the object, and done.
TSEM	LXI	D,SEMI	;test for null statement
	CALL	LIT
	JNZ	REM	;and done
TRET	LXI	D,XRET	;test for RETURN statement
	CALL	LIT
	JZ	TBRK
	LXI	D,SEMI	;if ; or remark push a 0.
	CALL	LIT
	JNZ	TR2
	LXI	D,XNL
	CALL	LIT
	JNZ	TR2
	CALL	ASGN	;otherwise push return value
	JMP	TR4
TR2	CALL	PZERO
TR4	MVI	A,1	;set leave flag
	STA	LEAVE
	RET
TBRK	LXI	D,XBRK	;test for BREAK
	CALL	LIT
	JZ	TASG
	MVI	A,1	;set break flag
	STA	BRAKE
	RET
TASG	CALL	ASGN	;if none of above, must be an
	JZ	STER	;  expression, or an error.
	CALL	TOPTOI	;if an expression, discard its
;			   value.
	LXI	D,SEMI	;skip optional ;
	CALL	LIT
	JMP	REM	;and done
STER	CALL	ESET
	DB	STATERR	;statement error
	RET
OBJT	DW	0	;points to object of while
AGIN	DW	0	;points to beginning of while
;
;DECL tests for and interprets declarations
DECL	LXI	D,XCHAR
	CALL	LIT	;test for CHAR
	JZ	TINT
CH2	MVI	A,'C'
	LXI	H,0
	CALL	VALLOC
	LXI	D,COMMA
	CALL	LIT
	JNZ	CH2	;get all vars
CH3	LXI	D,SEMI	;skip optional ;
	CALL	LIT
	MVI	A,07FH	;set flag to Not Zero
	ORA	A
	RET
TINT	LXI	D,XINT
	CALL	LIT
	RZ		;flag is zero
IN2	MVI	A,'I'
	LXI	H,0
	CALL	VALLOC
	LXI	D,COMMA
	CALL	LIT
	JNZ	IN2
	JMP	CH3
;
;catches interrupts (ESC key) at appl level.
QUIT	LDA	APPLVL
	ORA	A
	RZ
	CALL	CHRDY
	RZ
	MOV	B,A	;char keyed in -> B
	LDA	ESCAPE
	CMP	B
	RNZ
	CALL	INCH	;discard the ESC
	CALL	ESET	;signal the escape
	DB	KILL
	RET
;
;evaluates arguments of a function. Sets cursor to
;  beginning of function's text. Parses its argument
;  declarations, giving them values of the parameters.
;  executes the function. Determines cause of exit, and
;  pushes default 0 return value if needed. Restores
;  cursor.
NARGS	DB	0	;number of args
WHERE	DW	0	;0 for MC, otherwise address of
;			 function.
ARG	DW	0	;pointer into stack to first
;			 arg.
ENTER	SHLD	WHERE
	XRA	A
	STA	NARGS
	LHLD	TOP
	LXI	D,5
	DAD	D
	SHLD	ARG
	LXI	D,LPAR	;skip optional (
	CALL	LIT
	LXI	D,RPAR	;test for no args, several ways
	CALL	LIT
	JNZ	ARGSDNE
	LHLD	CURSOR
	MOV	A,M
	CPI	']'
	JZ	ARGSDNE
	CPI	';'
	JZ	ARGSDNE
	CPI	ASCRET
	JZ	ARGSDNE
	CPI	'/'
	JZ	ARGSDNE
EN2	LDA	ERR	;eval args, first test for err
	ORA	A
	RNZ
	LHLD	ARG	;save locals
	PUSH	H
	LHLD	WHERE
	PUSH	H
	LHLD	NARGS
	PUSH	H
	CALL	ASGN	;evaluate
	POP	H	;restore locals
	MOV	A,L
	POP	H
	SHLD	WHERE
	POP	H
	SHLD	ARG
	INR	A	;increment NARGS
	STA	NARGS
	LXI	D,COMMA
	CALL	LIT	;comma means more args
	JNZ	EN2
	LXI	D,RPAR	;optional )
	CALL	LIT
ARGSDNE	LDA	ERR
	ORA	A
	RNZ
	LHLD	WHERE	;test for MC
	MOV	A,H
	ORA	L
	JNZ	EN3
	LDA	NARGS
	CALL	MC
	RET
EN3	LHLD	CURSOR	;save current cursor
	PUSH	H
	LHLD	STCURS
	PUSH	H
	LHLD	WHERE	;set cursor to start of fctn
	SHLD	CURSOR
	CALL	NEWFUN	;new layer of value space
EN4	CALL	REM	;parse arg decls and pass value
	LXI	D,XINT	;works just like DECL, except
	CALL	LIT	;  uses SETARG instead of
	JZ	EN5	;  VALLOC.
EN6	LHLD	ARG
	MVI	B,'I'
	CALL	SETARG
	LHLD	ARG	;bump ARG pointer to next
	LXI	D,5	;  stack layer
	DAD	D
	SHLD	ARG
	LXI	D,COMMA
	CALL	LIT
	JNZ	EN6
	LXI	D,SEMI
	CALL	LIT
	JMP	EN4
EN5	LXI	D,XCHAR
	CALL	LIT
	JZ	EN7
EN8	LHLD	ARG
	MVI	B,'C'
	CALL	SETARG
	LHLD	ARG
	LXI	D,5
	DAD	D
	SHLD	ARG
	LXI	D,COMMA
	CALL	LIT
	JNZ	EN8
	LXI	D,SEMI
	CALL	LIT
	JMP	EN4
EN7	LHLD	TOP	;test correct number of args
	LXI	D,5
	DAD	D
	LDA	ARG	;should be TOP+5
	CMP	L
	JZ	EN9
	POP	D	;set up old cursor for
	POP	H	;  the error call
	SHLD	CURSOR
	PUSH	H
	PUSH	D
	CALL	ESET
	DB	ARGSERR
EN9	LXI	H,NARGS	;pop all args off stack
	DCR	M
	JM	EN11
	CALL	POPST
	JMP	EN9
EN11	LDA	ERR	;if no errors, execute function
	ORA	A
	CZ	ST
	LDA	LEAVE	;push 0 if default leave
	ORA	A
	CZ	PZERO
	XRA	A	;zero LEAVE
	STA	LEAVE
	POP	H	;restore cvrsor
	SHLD	STCURS
	POP	H
	SHLD	CURSOR
	CALL	FUNDONE	;pop layer of value space
	RET
;
;HL points into stack to an arg. B (used by VALLOC) is
;  type. SETARG gets actual value of arg, calls VALLOC
;  to allocate local space, which also puts arg value
;  into allocated space.
SETARG	PUSH	B
	MOV	B,M	;class
	INX	H
	MOV	A,M	;lvalue
	INX	H
	MOV	C,M	;size
	INX	H
	MOV	E,M	;stuff
	INX	H
	MOV	D,M
	CPI	'A'	;test for actual
	JZ	SE2
	XCHG		;address of datum -> HL
	MOV	E,M
	INX	H
	MOV	D,M
SE2	MOV	A,C	;if size==1 & class==0
	DCR	A
	ORA	B
	JNZ	SE3
	MOV	A,E	;  then propogate sign
	RLC
	SBB	A
	MOV	D,A
SE3	POP	B	;type -> A
	MOV	A,B
	XCHG		;passed value -> HL
	JMP	VALLOC	;call/ret, valloc does the rest
;
;scans program and allocates all externals in next fctn
;  layer. An "endlibrary" line causes a new fctn layer
;  to be opened.
LINK	CALL	NEWFUN
LI2	LDA	ERR	;check no error
	ORA	A
	RNZ
	LHLD	CURSOR
	INX	H
	INX	H
	XCHG
	LHLD	PROGEND
	DAD	D
	XCHG
	RC
	CALL	REM	;more text to process, skip
	LXI	D,LB	;  remarks.
	CALL	LIT	;test for compound statement.
	JZ	LIDCL
	MVI	B,'['	;skip compound st.
	MVI	C,']'
	CALL	SKIP
	JMP	LI2
LIDCL	CALL	DECL	;test for declaration, and
	JNZ	LI2	;  allocate it
	LXI	D,XENDL	;test for endlibrary statement.
	CALL	LIT
	JZ	LISYM
	CALL	NEWFUN
	JMP	LI2
LISYM	CALL	SYMNAME	;test for symbol
	JZ	LIERR
	MVI	A,'E'	;allocate a variable with
	MVI	B,2	;  class E, size 2, len 1,
	MVI	E,1	;  passed value = cursor. (This
	MVI	D,0	;  is a function entry.)
	LHLD	CURSOR
	CALL	NEWVAR
	LHLD	CURSOR	;advance cursor to beginning of
	MVI	A,'['	;  program body.
LI3	CMP	M
	JZ	LI4
	INX	H
	XCHG
	LHLD	PROGEND
	DAD	D
	XCHG
	JNC	LI3
	CALL	ESET
	DB	LBRCERR
	RET
LI4	SHLD	CURSOR	;skip body
	CALL	SKIPST
	JMP	LI2
LIERR	CALL	ESET
	DB	LINKERR
	RET
;
;move -(bc) bytes from (hl) to (de)
MOVE	MOV	A,M
	STAX	D
	INX	D
	INX	H
	INR	C
	JNZ	MOVE
	INR	B
	JNZ	MOVE
	RET
;it all starts here!!!!!
;cold start erases system level tc programs, and enters
;  the loader. Used to load a tailered or different
;  system program.
;warm start does not erase sys level progs, but enters
;  the loader so more can be loaded.
;hot start assumes all the loading is done, and immed
;  starts up the loaded sys level tc prog.
;Unfortunately, there is no hot start that preserves
;  application programs.
COLD	LHLD	MSTACK	;initialize 8080 stack, if need
	MOV	A,H
	ORA	L
	JZ	CL2
	SPHL
CL2	LXI	B,-10	;copy initial statement
	LHLD	BPR	;  PR
	XCHG
	LXI	H,INST	;  into PR
	CALL	MOVE
	LHLD	BPR
	LXI	D,9
	DAD	D
	CALL	HLNEG
	SHLD	PROGEND
	CALL	LOGO
WARM	CALL	LOADER
HOT	CALL	LOGO
	LHLD	PROGEND
	CALL	HLNEG
	SHLD	PRUSED
	LHLD	BPR
	SHLD	CURSOR
	LHLD	BFUN
	LXI	D,6
	DAD	D
	SHLD	CURGLBL
	LXI	D,-12
	DAD	D
	SHLD	CURFUN
	LHLD	BVAR
	SHLD	NXTVAR
	LHLD	BSTACK
	LXI	D,-5
	DAD	D
	SHLD	TOP
	XRA	A
	MOV	H,A
	MOV	L,A
	STA	ERR
	SHLD	ERRAT
	STA	LEAVE
	STA	BRAKE
	CALL	LINK
	CALL	NEWFUN
	LHLD	BPR
	SHLD	CURSOR
	CALL	PRBEGIN
	CALL	ST	;this executes the system progm
	CALL	PRDONE
	LXI	H,DONEMSG
	CALL	PS
	LDA	ERR
	ORA	A
	JZ	NOERR
	LHLD	ERR
	XCHG
	CALL	PN
	MVI	A,' '	;  and a space,
	CALL	OUTCH
	LHLD	ERRAT
	XCHG
	CALL	PN
NOERR	MVI	A,0DH
	CALL	OUTCH
	JMP	WARM
DONEMSG	DB	0DH
	DB	0DH
	DB	'D'
	DB	'O'
	DB	'N'
	DB	'E'
	DB	' '
	DB	0
INST	DB	'['
	DB	'm'
	DB	'a'
	DB	'i'
	DB	'n'
	DB	'('
	DB	')'
	DB	';'
	DB	']'
	DB	0
;
LOADER	LXI	H,BUFF
	MVI	A,'>'
	CALL	OUTCH
	CALL	OUTCH
	CALL	OUTCH
D2	CALL	INCH
	MOV	B,A
	LDA	ECHO
	ORA	A
	MOV	A,B
	CNZ	OUTCH
	MOV	M,A
	CPI	7FH	;delete char
	JZ	D3
	CPI	0DH	;return
	JZ	DOIT
	INX	H
	JMP	D2
D3	LXI	D,-BUFF-1
	PUSH	H
	DAD	D
	POP	H
	JNC	D2
	DCX	H
	JMP	D2
DOIT	MVI	M,0	;null at command's end
	LDA	BUFF+1	;ignore period in buff.
	MOV	B,A
	LDA	XR	;the letter r
	CMP	B
	JZ	LOAD
	MVI	A,LCFIX+'x'	; .x is the exit command
	CMP	B
	JZ	TCEXIT
	LDA	XG	;the letter g
	CMP	B
	RZ		;leaves editor
	MVI	A,'?'	;unrecognized command
	CALL	OUTCH
	CALL	OUTCH
	CALL	OUTCH
	MVI	A,0DH
	CALL	OUTCH
	JMP	LOADER
LOAD	LXI	H,BUFF+3	;file name
	LXI	D,1	;read option
	LXI	B,1	;unit
	MVI	A,1	;open to read
	CALL	FOPEN
	JNZ	LOADER
	LHLD	PROGEND	;where to load (stored neg)
L2	CALL	HLNEG
	LXI	B,1	;unit
	CALL	FREAD	;read one block
	JNZ	L5	;err or end of file
	DAD	D	;# bytes read in DE
	MVI	M,0	;just beyond last byte read
	CALL	HLNEG
	SHLD	PROGEND	;points to null byte at end
	JMP	L2
L5	LXI	B,1	;close unit 1
	CALL	FCLOSE
	JMP	LOADER
BUFF	DS	40
;
;Negate HL
HLNEG	MOV	A,H
	CMA
	MOV	H,A
	MOV	A,L
	CMA
	MOV	L,A
	INX	H
	RET
;
;print (DE) as signed integer
PN	LXI	H,BUFF
	CALL	ITOA
	MVI	M,0	;put null at end
	LXI	H,BUFF
	JMP	PS	;and done
;
;convert (DE) to ascii signed integer
ITOA	MOV	A,D	;test for minus
	ORA	A
	JP	NTOA
	CALL	DENEG	;make positive
	MVI	M,'-'	;output minus
	INX	H	;now fall into NTOA
;convert (DE) to ascii unsigned integer
NTOA	MOV	A,D
	ORA	E	;must be at least one digit, so
	JNZ	NT2	;  test for 0.
	MVI	M,'0'
	INX	H
	RET
NT2	XRA	A	;put mark on stack
	PUSH	PSW
NT3	LXI	B,10
	PUSH	H
	CALL	DDIV
	MOV	A,L	;remainder -> A
	POP	H
	ADI	'0'
	PUSH	PSW	;ascii digit -> stack
	MOV	A,D	;done if quotient is zero
	ORA	E
	JNZ	NT3
NT4	POP	PSW	;top of stack is digit or mark.
	RZ		;done if mark.
	MOV	M,A	;otherwise digit -> buffer.
	INX	H
	JMP	NT4
;
;prints the copyright message on the terminal.
LOGO	LXI	H,CPMSG
	JMP	PS
CPMSG	DB	0CH
	DB	'*'
	DB	'*'
	DB	'*'
	DB	' '
	DB	' '
	DB	'T'
	DB	'I'
	DB	'N'
	DB	'Y'
	DB	'-'
	DB	'C'
	DB	' '
	DB	' '
	DB	' '
	DB	'V'
	DB	'E'
	DB	'R'
	DB	'S'
	DB	'I'
	DB	'O'
	DB	'N'
	DB	' '
	DB	'1'
	DB	'.'
	DB	'0'
	DB	' '
	DB	' '
	DB	'*'
	DB	'*'
	DB	'*'
	DB	0DH
	DB	0AH
	DB	'C'
	DB	'O'
	DB	'P'
	DB	'Y'
	DB	'R'
	DB	'I'
	DB	'G'
	DB	'H'
	DB	'T'
	DB	' '
	DB	'1'
	DB	'9'
	DB	'7'
	DB	'7'
	DB	','
	DB	' '
	DB	'T'
	DB	' '
	DB	'A'
	DB	' '
	DB	'G'
	DB	'I'
	DB	'B'
	DB	'S'
	DB	'O'
	DB	'N'
	DB	0DH
	DB	0AH
	DB	0
;move the block (DE)...(HL) inclusive (BC) bytes. If
;  (BC) is positive, the block is moved up in RAM,
;  highest byte first, lowest byte last. If (BC) is
;  negative, the block is moved down in RAM, lowest
;  byte first. Thus large blocks can be safely moved
;  up or down short distances.
MOVEBL	MOV	A,B
	ORA	A
	JM	MOVEDN
	ORA	C
	RZ
MOVEUP	SHLD	FROMPTR	;hi end of block is fromptr
	DAD	B	;to pointer -> DE
	XCHG
	LDA	FROMPTR	; - length -> BC
	CMA
	ADD	L	; - length =
	MOV	C,A	;	current HL - fromptr +1
	LDA	FROMPTR+1
	CMA
	ADC	H
	MOV	B,A
	LHLD	FROMPTR
MU2	MOV	A,M
	STAX	D
	DCX	H
	DCX	D
	INR	C
	JNZ	MU2
	INR	B
	JNZ	MU2
	RET
MOVEDN	XCHG		;lo end of block is from ptr
	SHLD	FROMPTR
	DAD	B	;to pointer -> HL
	LDA	FROMPTR	; - length -> BC
	SUB	E
	MOV	C,A
	LDA	FROMPTR+1
	SBB	D
	MOV	B,A
	DCX	B
	XCHG		;to ptr -> DE
	LHLD	FROMPTR	;from ptr -> HL
	JMP	MOVE
FROMPTR	DW	0
;
;scan for the Nth occurance of a character in a block,
;  or the end of the block, whichever comes first. The
;  block is (DE)..(HL) inclusive. N is (BC) and can be
;  0 to 65k. (A) is the character. On completion, (DE)
;  points to the Nth occurance, or to the last byte of
;  the block. (BC) is N minus the number of (A) found,
;  e.g. 0 if N (A)'s were found. HL is undisturbed.
SCANN	PUSH	PSW	;ch -> stack
	XCHG		;reverse first and last
SC2	MOV	A,C
	ORA	B	;test if done
	JZ	SC9
	MOV	A,E
	SUB	L
	MOV	A,D
	SBB	H
	JC	SC9
	POP	PSW
	PUSH	PSW
	CMP	M
	JNZ	SC3
	DCX	B
SC3	INX	H
	JMP	SC2
SC9	DCX	H
	XCHG
	POP	PSW
	RET
;
;count the occurances of a character in a block. (A) is
;  the character. The block is (DE)..(HL) inclusive.
;  The count is returned in (BC). (A) and (DE) are
;  unchanged. (HL) is clobbered.
COUNTCH	LXI	B,0
	PUSH	PSW	;ch -> stack
CC2	MOV	A,L	;test for end
	SUB	E
	MOV	A,H
	SBB	D
	JC	CC9
	POP	PSW
	PUSH	PSW
	CMP	M
	DCX	H
	JNZ	CC2
	INX	B	;count this one
	JMP	CC2
CC9	POP	PSW
	RET
;Machine Call routine to interface to 8080 coded
;  routines.  Standard routines used by the system
;  are coded here, numbers 1 to 11. 12 to 999 are
;  reserved. 1000 and up are available to users.
MC	STA	MCARGS	;for checking,
	CALL	TOPTOI	;  for MC's that need it.
	LXI	H,-1000	;test for user MC
	DAD	D
	JC	USERMC
	MOV	A,E	;fctn num -> A
	CPI	1
	JZ	MC1
	CPI	2
	JZ	MC2
	CPI	3
	JZ	MC3
	CPI	4
	JZ	MC4
	CPI	5
	JZ	MC5
	CPI	6
	JZ	MC6
	CPI	7
	JZ	MC7
	CPI	8
	JZ	MC8
	CPI	9
	JZ	MC9
	CPI	10
	JZ	MC10
	CPI	11
	JZ	MC11
	CPI	12
	JZ	MC12
	CPI	13
	JZ	MC13
	CPI	14
	JZ	MC14
MCESET	CALL	ESET
	DB	MCERR
	RET
;
;put a character to screen
MC1	CALL	TOPTOI	;char -> A
	CALL	PUSHK	;push it back
	MOV	A,E
	JMP	OUTCH
;
;get a char from keyboard
MC2	CALL	INCH	;char -> DE
	MOV	B,A	;test for ESC in appl level
	LDA	APPLVL
	ORA	A
	JZ	USEIT
	LDA	ESCAPE
	CMP	B
	JNZ	USEIT
	CALL	ESET
	DB	KILL
USEIT	LDA	ECHO	;test if echo required
	ORA	A
	MOV	A,B
	CNZ	OUTCH
	MOV	E,A
	XRA	A
	MOV	D,A
	JMP	PUSHK	;put char onto stack
;
;file open (r/w, name, fsize, unit)
MC3	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI	;r/w -> A
	MOV	A,E
	ORA	D
	POP	H	;name pointer -> HL
	POP	D	;file size -> DE
	POP	B	;unit -> BC
	CALL	FOPEN
	LXI	D,0
	MOV	E,A	;push result code
	JMP	PUSHK
;
; read block( where, unit)
MC4	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	XCHG		;where -> HL
	POP	B	;unit -> BC
	CALL	FREAD
	JZ	MC4P	;if result code is 0 DE has
	LXI	D,-1	;  byte count to be pushed.
	MOV	E,A	;  Otherwise A is an err or eof
MC4P	JMP	PUSHK	;  code to be returned negative
;
;write block ( first byte, last byte, unit). Block may
;  be any size from 1 to 256.
MC5	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	XCHG		;first -> HL
	POP	D	;last -> DE
	POP	B	;unit -> BC
	CALL	FWRITE
	LXI	D,0	;push result code
	MOV	E,A
	JMP	PUSHK
;
;close file ( unit )
MC6	CALL	TOPTOI
	MOV	C,E	;unit -> BC
	MOV	B,D
	CALL	FCLOSE
	JMP	PZERO	;return a 0
;
;move a block up or down. Args are first,last,K. If K
;  negative, block is moved down |k| bytes, if positive
;  then up K bytes.
MC7	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI	;first -> DE
	POP	H	;last
	POP	B	;K
	CALL	MOVEBL
	JMP	PZERO	;return a 0
;
;count # instances of character CH in a block. Args are
; first,last,CH.
MC8	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI	;first -> DE
	POP	H	;last
	POP	B	;ch -> A
	MOV	A,C
	CALL	COUNTCH
	MOV	E,C	;count -> DE
	MOV	D,B
	JMP	PUSHK
;
;scan for nth occurance of CH in a block. Args are
;  first,last,CH,cnt address. Return pointer to nth
;  occurance,if it exists, otherwise to last. Also
;  cnt is reduced by one for every CH found.
MC9	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI	;first -> DE
	POP	H	;last
	POP	B	;ch -> A
	MOV	A,C
	XTHL
	MOV	C,M	;cnt -> BC
	INX	H
	MOV	B,M
	DCX	H
	XTHL		;addr of cnt still on stack
	PUSH	D	;first on stack, too
	CALL	SCANN
	POP	H	;make ptr (DE) relative to
	MOV	A,E	;  first
	SUB	L
	MOV	E,A
	MOV	A,D
	SBB	H
	MOV	D,A
	POP	H	;BC -> cnt
	MOV	M,C
	INX	H
	MOV	M,B
	JMP	PUSHK	;return pointer to last byte
;			;  examined.
;
;trap to moniter 4.0 for debugging.
MC10	DB	0FFH	;RST 7
	RET
;
;enters an application program, setting up a new
; globals variable level, redefining progend, links
; the program, executes if no error occured, upon
; completion captures a few facts (err, and either
; cursor or errat) and restores old globals level,
; progend, zeros err, pushes a zero as the value of
; this function, and resumes the calling program.
MC11	LHLD	CURSOR
	PUSH	H
	LHLD	PROGEND
	PUSH	H
	LHLD	PRUSED
	PUSH	H
	LHLD	CURGLBL
	PUSH	H
	CALL	TOPTOI	;appl pr address
	XCHG
	PUSH	H
	SHLD	CURSOR
	CALL	TOPTOI	;end of appl addr
	XCHG
	SHLD	PRUSED
	CALL	HLNEG
	SHLD	PROGEND
	CALL	LINK
	LHLD	CURFUN
	SHLD	CURGLBL
	CALL	TOPTOI	;start statement address
	XCHG
	SHLD	CURSOR
	CALL	NEWFUN
	CALL	TOPTOI	;facts address
	PUSH	D
	LXI	H,APPLVL	;increment appl level
	INR	M
	PUSH	H
	LDA	ERR	;if no err so far, do it!!
	ORA	A
	JNZ	DONE
	CALL	PRBEGIN
	CALL	ST
	CALL	PRDONE
DONE	POP	H	;its done, decrement appl level
	DCR	M
	CALL	FUNDONE	;discard appl locals
	CALL	FUNDONE	;  and globals
	LHLD	CURSOR	;set up facts
	LDA	ERR
	ORA	A
	JZ	MCEN2
	LHLD	ERRAT
MCEN2	XCHG		;returned currsor -> DE
	POP	H	;facts -> HL
	POP	B	;appl pr address -> BC
	MOV	A,E	;make returned cursor relative
	SUB	C	;  to appl address
	MOV	E,A
	MOV	A,D
	SBB	B
	MOV	D,A
	LDA	ERR
	MOV	M,A	;err -> facts
	XRA	A
	INX	H
	MOV	M,A	;err hi byte -> facts
	INX	H
	MOV	M,E	;cursor -> facts
	INX	H
	MOV	M,D
	POP	H	;curglobal
	SHLD	CURGLBL
	POP	H
	SHLD	PRUSED
	POP	H	;progend
	SHLD	PROGEND
	POP	H	;cursor
	SHLD	CURSOR
	XRA	A	;zero the error
	STA	ERR
	JMP	PZERO	;value of MC11
;
;test if keyboard char ready, return copy if so,else 0.
MC12	CALL	CHRDY
	MVI	D,0
	MOV	E,A
	JMP	PUSHK
;
;print RAM, from and to addresses are given
;  nulls are mapped to quotes
MC13	CALL	TOPTOI
	PUSH	D
	CALL	TOPTOI
	XCHG		;from -> HL
	POP	D	;to -> DE
LOOP13	MOV	A,E	;test if done
	SUB	L
	MOV	A,D
	SBB	H
	JC	PZERO	;done
	MOV	A,M
	ORA	A
	JNZ	EC13
	MVI	A,'"'
EC13	CALL	OUTCH
	INX	H
	JMP	LOOP13
;
;print a signed integer
MC14	CALL	TOPTOI
	PUSH	D
	CALL	PN
	POP	D
	JMP	PUSHK
