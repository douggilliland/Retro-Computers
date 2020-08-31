;COMPILE
;BASIC-E/65 Compiler
;Version 2.03-A
;COPYRIGHT - RICHARD A. LEARY - 1982
;released:	18 october 1982
;last revision:
;	24 december 1983
;		added chkule for prod 5
;		modified error to print line
;		added code to set seprtr
;	12 january 1984
;		deleted error0 bit and branch
;		fixed first blank line list for $b option
;		fixed buffer overwrite on error
;	4 april 2008
;		reformatted for ASM211 & TASM
;		eliminated page zero 0 & 1
;		moved some variables from page zero
;A translation of Gordon Eubanks BASIC-E to operate under DOS/65.  This is a
;compile-interpret systems invoked against a source file of type .BAS.  The
;compiler produces an intermediate code file of type .INT which is executed
;by the program RUN.
;external references
BOOT	=	$100		;boot entry
PEM	=	$103		;pem entry
FCB	=	$107		;default fcb
TEA	=	$800		;load address
;fixed parameters and constants
;CAUTION: When a register is set to TRUE, Z is set to 0 (i.e. NE).  If a
;register is set to FALSE then Z is set to 1 (i.e. EQ).
TRUE	=	$FF
FALSE	=	0
;ascii characters
TAB	=	9		;tab
LF	=	10		;linefeed
CR	=	13		;return and eol
EOF	=	26		;eof char
SPACE	=	32		;ascii blank
semico	=	59		;semicolon
backsl	=	92		;backslash
;other
IDNTSZ	=	32		;max identifier size + 1
VARCSZ	=	100		;varc stack size
PSTKSZ	=	32		;parse stack size
SRCRSZ	=	128		;source file record size
INTRSZ	=	128		;int file record size
CBUFSZ	=	82		;console buffer size
HSHTSZ	=	64		;hash table size
HSHMSK	=	HSHTSZ-1	;hashing mask
MAXOCT	=	15		;max number on statements
MAXRWL	=	9		;max reserved word length
MAXRNO	=	120		;max read count
MAXLNO	=	175		;max look count
MAXPNO	=	189		;max push count
MAXSNO	=	341		;max state count
STARTS	=	121		;start state
PRODNO	=	152		;number productions
SIMVAR	=	0
SUBVAR	=	2
CONST	=	4
LABLE	=	8
UNFUNC	=	$A
;mnemonics for basic-e machine
FAD	=	0
FMI	=	1
FMU	=	2
FDI	=	3
EXP	=	4
LSS	=	5
GTR	=	6
EQU	=	7
NEQ	=	8
GEQ	=	9
LEQ	=	10
NOT	=	11
ANDO	=	12
BOR	=	13
LOD	=	14
STO	=	15
XIT	=	16
DEL	=	17
DUP	=	18
XCH	=	19
STD	=	20
SLT	=	21
SGT	=	22
SEQ	=	23
SNE	=	24
SGE	=	25
SLE	=	26
STS	=	27
ILS	=	28
CAT	=	29
PRO	=	30
RTN	=	31
ROW	=	32
SUB	=	33
RDV	=	34
WRV	=	35
WST	=	36
RDF	=	37
RDB	=	38
ECR	=	39
POT	=	40
WRB	=	40
RDN	=	41
RDS	=	42
WRN	=	43
WRS	=	44
OPN	=	45
CON	=	46
RST	=	47
NEG	=	48
RES	=	49
NOPO	=	50
DAT	=	51
DBF	=	52
NSP	=	53
BRS	=	54
BRC	=	55
BFC	=	56
BFN	=	57
CVB	=	58
RCN	=	59
DRS	=	60
DRF	=	61
EDR	=	62
EDW	=	63
CLS	=	64
IRN	=	77
RON	=	91
CKO	=	92
EXR	=	93
DEF	=	94
BOL	=	95
ADJ	=	96
;token definitions
POUND	=	12
ASTRK	=	4
LESST	=	1
EXPON	=	14
TDATA	=	99
TELSE	=	34
TFOR	=	28
TIF	=	17
TNEXT	=	37
SLASH	=	8
TOR	=	21
TREST	=	48
TSTOP	=	40
FUNCT	=	53
TLEQ	=	18
TNE	=	19
TOUT	=	31
IDENT	=	52
UDFUNC	=	54
LPARN	=	2
TPLUS	=	3
TCOLIN	=	11
EQUAL	=	13
TAND	=	24
TDEF	=	25
TEND	=	27
TGOSB	=	43
TINPT	=	44
TNOT	=	30
TPRNT	=	45
TRETN	=	46
TTHEN	=	41
TGEQ	=	15
COMMA	=	9
TCLOS	=	42
TIRN	=	51
RPARN	=	5
TMINUS	=	7
SCOLN	=	6
GTRT	=	10
TCR	=	23
TDIM	=	26
TFILE	=	35
TGOTO	=	36
TLET	=	29
TON	=	20
TREAD	=	38
TSTEP	=	39
TTO	=	22
TSUB	=	32
TGO	=	16
TXOR	=	33
STRING	=	50
FLOTPT	=	49
TREM	=	0
;page zero variables
;all non-zero initial values are shown as i=xxxx where xxxx is the initial
;value. PL/M name is shown if significantly different.
	*=	2
GPIND				;index in GETCHR
	*=	*+1
ERRCNT				;error count (errorcount)
	*=	*+2
DATACT				;count data area size
	*=	*+2
INPSTM				;(inputstmt)
	*=	*+1
GSBSTM				;(gosubstmt)
	*=	*+1
TOKEN				;type of token
	*=	*+1
SUBTYP				;subtype of token (subtype)
	*=	*+1
FUNCOP				;function number if function
	*=	*+1
HSHCDE				;hash of current token (hashcode)
	*=	*+1
NXTCHR				;current char from GETCHR (nextchar)
	*=	*+1
ACCUM				;current token
	*=	*+IDNTSZ
ACCLEN	=	ACCUM		;length is first byte
CONT				;accum full flag
	*=	*+1
COLUMN				;current column
	*=	*+1
LINENO				;current line number
	*=	*+2
OUTIND				;INT buffer index (buffptr)
	*=	*+1
LENGTH				;output line length
	*=	*+1
SEPRTR				;separator i=':'
	*=	*+1
SRCIND				;source index i=SRCRSZ (sourceptr)
	*=	*+1
LNEPTR				;line pointer
	*=	*+1
POINTR				;pointer in ERROR
	*=	*+1
ERRCDE				;compiler error code
	*=	*+1
STATE				;state
	*=	*+2
SP				;stack pointer
	*=	*+1
MP
	*=	*+1
MPP1				;MP + 1
	*=	*+1
NOLOOK
	*=	*+1
VARIND				;index into VAR
	*=	*+1
TYPESP				;group of
	*=	*+1
TYPEM1				;variables
	*=	*+1
TYPEMP				;to hold
	*=	*+1
STYPSP				;parser stack
	*=	*+1
STYPM1				;contents
	*=	*+1
STYPMP				;during
	*=	*+1
SYMLSP				;action
	*=	*+2
SYMLM1				;of synthesize
	*=	*+2
SYMLMP				;in
	*=	*+2
HASHSP				;order to
	*=	*+1
HASHM1				;reduce
	*=	*+1
HASHMP				;the amount
	*=	*+1
SRLOSP				;of indexing
	*=	*+2
SRLOMP				;in SYNTHE
	*=	*+2
DECOUT				;decimal word
	*=	*+2
LZFLAG				;leading zero flag in PRNDEC
	*=	*+1
FIELD				;pointer in compare
	*=	*+2
I				;parser var
	*=	*+2
J				;same
	*=	*+2
K				;even more
	*=	*+2
INDEX
	*=	*+1
I2				;I*2 and word pointer
	*=	*+2
IC				;index in COMPAR
	*=	*+1
PTR				;pointer in LOOKUP and COMPAR
	*=	*+2
IL				;index in LOOKUP
	*=	*+1
SBTTOP				;top of for/next stack
	*=	*+2
BASE				;base of current entry
	*=	*+2
FORCNT				;for count
	*=	*+1
SBTBL				;top of symbol table
	*=	*+2
APTADD				;utility var to access table
	*=	*+2
PRTCT				;count prt entries
	*=	*+2
FDACT				;count fda entries
	*=	*+2
CODESI				;count size of code area
	*=	*+2
ULERFL
	*=	*+1
PRNTNM				;pointer set before SLOOKU or ENTER
	*=	*+2
SYMHSH				;hash of token reference
	*=	*+1
PRODCT				;production number (0 to PRODNO)
	*=	*+1
NXSTPT				;next statement pointer
	*=	*+2
TMPHSH				;local hash in GETHSH
	*=	*+1
TMPPTR				;local ptr in GETHSH
	*=	*+1
LEN				;temp in SLOOKU
	*=	*+1
NUMPRM				;temp in UNLINK/RELINK
	*=	*+1
LINKI				;temp in UNLINK/RELINK
	*=	*+1
TMPADR				;temp in UNLINK/RELINK
	*=	*+2
WHERE				;temp in genils
	*=	*+2
STRPTR				;temp in ginils
	*=	*+1
IGEN				;temp in gencon
	*=	*+1
LZ
;entry point
	*=	TEA
	JMP	MAIN
;copyright notice
	.byte	"COPYRIGHT - RICHARD"
	.byte	" A. LEARY - 2008"
;SUBROUTINES
;subroutine to point to source fcb and go to pem
RFCBX	LDA	#<FCB		;point
	LDY	#>FCB		;to fcb
	JMP	PEM		;and go
;point to int fcb and go to pem
WFCBX	LDA	#<WFCB		;point
	LDY	#>WFCB		;to fcb
	JMP	PEM		;and go
;send cr and lf to console/list
CRLF	LDA	#CR		;get
	JSR	PRNCHR		;a cr
	LDA	#LF		;and
	JMP	PRNCHR		;then a lf
;output char in A to console or list device as a function of LSTFLG
SPCOUT	LDA	#SPACE		;get space
CHROUT	BIT	LSTFLG		;test flag
	BMI	*+7		;use list if set
	LDX	#2		;else set
	JMP	PEM		;and do console
	LDX	#5		;set list
	JMP	PEM		;and do
;print char in A and handle tabs and linefeeds
PRNCHR	CMP	#TAB		;see if tab
	BNE	NOTTAB		;branch if not
TABOVR	JSR	SPCOUT		;send a space
	INC	COLUMN		;bump column
	LDA	COLUMN		;get it
	AND	#7		;see if mod 8
	BNE	TABOVR		;loop if not
	RTS			;else done
NOTTAB	PHA			;save char
	JSR	CHROUT		;send it
	INC	COLUMN		;bump column
	PLA			;get char
	CMP	#LF		;if a lf
	BEQ	*+3		;then branch
	RTS			;else done
	LDA	#0		;clear column
	STA	COLUMN		;and then
	RTS			;done
;convert AY to decimal number and print on console
PRNDEC	STA	DECOUT		;save
	STY	DECOUT+1	;value
	LDA	#FALSE		;set flag
	STA	LZFLAG		;to false
	LDX	#'0'-1		;set digit to '0' - 1
	SEC			;now
P10000	LDA	DECOUT		;subtract
	SBC	#10000*256/256	;10000
	STA	DECOUT		;from
	LDA	DECOUT+1	;value
	SBC	#10000/256	;and
	STA	DECOUT+1	;save
	INX			;bump digit
	BCS	P10000		;loop if no borrow
	LDA	DECOUT		;else
	ADC	#10000*256/256	;add
	STA	DECOUT		;10000
	LDA	DECOUT+1	;back
	ADC	#10000/256	;in to
	STA	DECOUT+1	;correct
	JSR	DIGOUT		;send digit
P1000	LDA	DECOUT		;now
	SBC	#1000*256/256	;drop
	STA	DECOUT		;by
	LDA	DECOUT+1	;1000
	SBC	#1000/256	;until
	STA	DECOUT+1	;a borrow
	INX			;bump digit
	BCS	P1000		;loop if more
	LDA	DECOUT		;now
	ADC	#1000*256/256	;add
	STA	DECOUT		;1000
	LDA	DECOUT+1	;back
	ADC	#1000/256	;in to
	STA	DECOUT+1	;correct
	JSR	DIGOUT		;send 1000s
P100	LDA	DECOUT		;now
	SBC	#100		;do
	STA	DECOUT		;subtract
	LDA	DECOUT+1	;for
	SBC	#0		;100
	STA	DECOUT+1	;with
	INX			;digit bump
	BCS	P100		;loop if more
	LDA	DECOUT		;else
	ADC	#100		;add back
	STA	DECOUT		;to correct
	JSR	DIGOUT		;send 100s
P10	LDA	DECOUT		;now
	SBC	#10		;drop
	STA	DECOUT		;by 10
	INX			;bump digit
	BCS	P10		;loop if more
	ADC	#10		;correct
	STA	DECOUT		;save
	JSR	DIGOUT		;and send 10s
	LDA	#'0'		;get zero
	ORA	DECOUT		;add number
	JMP	PRNCHR		;and print always
;send a single digit in X and handle leading zeros
DIGOUT	LDA	#SPACE		;preset for blank
	BIT	LZFLAG		;test flag
	BMI	D2		;branch if set
	CPX	#'0'		;else test current
	BEQ	D3		;branch if '0'
	LDA	#TRUE		;else set
	STA	LZFLAG		;flag
D2	TXA			;get char
D3	JSR	PRNCHR		;print it
	LDX	#'0'-1		;now preset
	SEC			;for next
	RTS
;print message pointed to by AY until a $ is encountered
PRNMSG	STA	PRN0+1		;save message
	STY	PRN0+2		;address
PRN0	LDA	$FFFF		;get byte
	CMP	#'$'		;see if end
	BNE	*+3		;branch if not
	RTS			;else done
	JSR	PRNCHR		;print it
	INC	PRN0+1		;bump low
	BNE	PRN0		;loop if no carry
	INC	PRN0+2		;bump high
	JMP	PRN0		;and loop
;disk error exit
DSKERR	LDA	#<DEMSG		;point to
	LDY	#>DEMSG		;message
DSKER0	JSR	PRNMSG		;print it
	JMP	BOOT		;and boot
;open source file
OPNSRC	LDX	#3		;first
OPN1	LDA	BASSTR-1,X	;move
	STA	FCB+8,X		;BAS to
	DEX			;type part
	BNE	OPN1		;of fcb
	STX	FCB+12		;clear extent
	stx	fcb+13
	STX	FCB+32		;and record
	LDA	#<INPBUF	;point to
	LDY	#>INPBUF	;buffer
	LDX	#26		;and set
	JSR	PEM		;as buffer location
	LDX	#15		;open code
	JSR	RFCBX		;do it
	BMI	*+3		;branch if bad
	RTS			;else done
	LDA	#<NSMSG		;point to
	LDY	#>NSMSG		;no source message
	JMP	DSKER0		;send and quit
;close output (INT) file
CLSINT	LDX	#16		;close code
	JSR	WFCBX		;do it
	BMI	*+3		;branch if bad
	RTS			;else done
	JMP	DSKERR		;error exit
;set-up INT file
SUPINT	BIT	NINTFL		;test no-int flag
	BPL	*+3		;branch if false
	RTS			;else done
	LDX	#8		;move 9
SUP0	LDA	FCB,X		;char including drive
	STA	WFCB,X		;to write fcb
	DEX			;drop count
	BPL	SUP0		;loop if more
	INX
	STX	WFCB+12
	stx	wfcb+13
	STX	WFCB+32		;clear extent and record
	LDX	#19		;now delete
	JSR	WFCBX		;it if there
	LDX	#22		;now try
	JSR	WFCBX		;to create
	BPL	*+5		;branch if ok
	JMP	DSKERR		;else error
	RTS			;and quit
;reset compiler flags
SETFLG	LDA	#FALSE
	STA	RNDFLE		;random file
	STA	FILEIO		;file io
	STA	INPSTM		;input statement
	STA	FORSTM		;for statement
	STA	GSBSTM		;gosub statement
	RTS
;write INT record
WRTINT	BIT	NINTFL		;test flag
	BPL	*+3		;ok if false
	RTS			;else done
	LDA	#<OUTBUF	;point to
	LDY	#>OUTBUF	;buffer
	LDX	#26		;and set
	JSR	PEM		;as dma
	LDX	#21		;now do
	JSR	WFCBX		;write op
	BEQ	*+5		;ok if zero
	JMP	DSKERR		;else error
	LDA	#<INPBUF	;point back
	LDY	#>INPBUF	;to input
	LDX	#26		;and set
	JMP	PEM		;as default
;emit byte in A to INT file
EMIT	LDX	OUTIND		;get index
	BPL	EMIT0		;ok if < 128
	PHA			;else save
	JSR	WRTINT		;write buffer
	PLA			;get byte
	LDX	#0		;now clear
	STX	OUTIND		;index
EMIT0	INC	OUTIND		;bump for next
	STA	OUTBUF,X	;save byte
	RTS			;and done
;read source file record
RDESRC	LDX	#20		;get code
	JSR	RFCBX		;do it
	CMP	#2		;see if ok
	BCC	*+5		;branch if was
	JMP	DSKERR		;else error
	RTS
;clear output line buffer
CLLNBF	LDX	#CBUFSZ-1	;get length - 1
	LDA	#SPACE		;use space
CLLN0	STA	CONBUF,X	;store
	DEX			;drop index
	CPX	#255		;see if wrap
	BNE	CLLN0		;loop if not
	RTS
;list line of length LENGTH
;note that this routine also sets seprtr to : (just in case!!)
LSTLNE	LDA	LINENO		;get line
	LDY	LINENO+1	;number
	JSR	PRNDEC		;print it
	LDA	SEPRTR		;then print
	JSR	PRNCHR		;separator
	LDA	#SPACE		;and a
	JSR	PRNCHR		;space
	LDA	#0		;now clear
	STA	GPIND		;index
LSTL0	LDX	GPIND		;get index
	LDA	CONBUF,X	;get char
	JSR	PRNCHR		;print it
	INC	GPIND		;bump index
	LDA	GPIND		;get index
	CMP	LENGTH		;compare to length
	BCC	LSTL0		;loop if more
	BEQ	LSTL0		;or if same
	JSR	CRLF		;do cr and lf
	JSR	CLLNBF		;clear buffer
	LDA	#':'		;and set
	STA	SEPRTR		;separator
	RTS
;set global variable NXTCHR to next source file character and return with
;NXTCHR in A. Replace TAB with SPACE and if LSTSRC is TRUE or an error
;occurs send the line to the console.
GETCHR	JSR	CHKFLE		;go get char
	BNE	GETEOF		;branch if eof
	LDA	NXTCHR		;get nextchar
	CMP	#EOF		;see if eof char
	BNE	NTEOF		;branch if not
GETEOF	LDX	#4		;move 5
GETE0	LDA	ADDEND,X	;from ADDEND
	STA	INPBUF,X	;to input buffer
	DEX			;drop count
	BPL	GETE0		;loop if more
	INX			;clear X
	STX	SRCIND		;and then index
	JSR	NXTSRC		;get next
	STA	NXTCHR		;save it
NTEOF	LDX	LNEPTR		;get pointer
	CPX	#CBUFSZ		;compare to max
	BCS	LTOBIG		;branch if too big
	INX			;else bump
	STX	LNEPTR		;and save
	LDA	NXTCHR		;get char
	STA	CONBUF,X	;and save
LTOBIG	LDA	NXTCHR		;get char
	CMP	#CR		;see if a cr
	BNE	NTEOL		;branch if not
	INC	LINENO		;else bump
	BNE	*+4		;line
	INC	LINENO+1	;number
	LDX	LNEPTR		;get pointer
	DEX			;drop it
	STX	LENGTH		;put in length
	LDA	LSTSRC		;get flag
	BEQ	NOLSLN		;branch if not true
	JSR	LSTLNE		;list it
NOLSLN	LDA	#0		;then clear
	STA	LNEPTR		;pointer
	LDA	NXTCHR		;get char
NTEOL	CMP	#TAB		;see it tab
	BEQ	*+3		;branch if is
	RTS
	LDA	#SPACE		;else get space
	STA	NXTCHR		;set
	RTS			;and done
;get byte from source file
NXTSRC	LDX	SRCIND		;get index
	LDA	INPBUF,X	;then byte
	RTS
;maintain source buffer full and check for eof. if eof is detected then
;A:=TRUE else A:=FALSE
CHKFLE	INC	SRCIND		;bump index
	BPL	CHKFL0		;branch if ok
	LDA	#0		;else clear
	STA	SRCIND		;index
	JSR	RDESRC		;read record
	CMP	#1		;see if eof
	BNE	CHKFL0		;branch if not
	LDA	#TRUE		;else set
	RTS			;eof=true
CHKFL0	JSR	NXTSRC		;get next
	STA	NXTCHR		;save it
	CMP	#LF		;if a lf
	BEQ	CHKFLE		;loop for more
	LDA	#FALSE		;else say
	RTS			;wasn't eof
;get non-blank from source. will also skip past eof to reach physical eof.
GTNBLK	JSR	GETCHR		;get new char
	CMP	#SPACE		;if a space
	BEQ	GTNBLK		;try again
	CMP	#EOF		;if an eof
	BEQ	GTNBLK		;try again
	RTS
;check for continuation character. if it is will get first char from next line.
CHKCNT	LDA	NXTCHR		;get next
	CMP	#backsl		;see if continue
	BEQ	*+3		;branch if is
	RTS
CHKCN0	JSR	GETCHR		;get next
	CMP	#CR		;see if eol
	BNE	CHKCN0		;loop if isn't
	JMP	GTNBLK		;now get first non-blank
;compiler error handler
;at entry a contains error number
ERROR	STA	ERRCDE		;save
	LDA	LNEPTR		;get index
	STA	POINTR		;move to pointer
	INC	POINTR		;and bump
	INC	POINTR		;by two
	LDA	TOKEN		;get token
	CMP	#TCR		;see if for eol
	BEQ	ERROR3		;branch if is
	LDA	NXTCHR		;else get next
ERROR1	CMP	#CR		;if a cr
	BEQ	ERROR3		;then done
	JSR	CHKCNT		;else see if continue
	JSR	GETCHR		;get another char
	JMP	ERROR1		;and loop
ERROR3	BIT	PASS2		;test pass 2 flag
	BPL	ERROR6		;branch if clear
	BIT	LSTSRC		;see if source already listed
	BMI	*+5		;skip list if was
	JSR	LSTLNE		;else list
	INC	ERRCNT		;bump
	BNE	*+4		;error
	INC	ERRCNT+1	;count
	LDA	#'?'		;print a ?
	JSR	PRNCHR
	LDA	#'-'
	JSR	PRNCHR		;print two -
	LDA	#'-'
	JSR	PRNCHR
ERROR4	DEC	POINTR		;drop pointer
	BEQ	ERROR5		;done if zero
	BMI	ERROR5		;or <0
	LDA	#'-'		;else get -
	JSR	PRNCHR		;print it
	JMP	ERROR4		;and loop
ERROR5	LDA	#'^'		;get up arrow
	JSR	PRNCHR		;print it
	JSR	CRLF		;then a cr and lf
	LDA	ERRCDE		;get error code
	ASL	A		;mult by two
	TAX
	LDA	ERMTBL,X
	LDY	ERMTBL+1,X	;get message address
	JSR	PRNMSG		;print it
	JSR	CRLF
ERROR6	LDA	#FALSE		;now clear
	STA	CMPLNG		;compiling flag
	JMP	SETFLG		;and then other flags
;initialize scanner by setting NXTCHR to the first non-blank character from the
;input file and by setting the line number and pointer
INSCAN	BIT	PASS1		;test for pass 1
	BPL	NOGTPR		;branch if not
	LDX	#8		;move 8 parms
INSCA0	LDA	FCB+16,X	;from fcb
	STA	PRMLST-1,X	;to save area
	DEX			;drop count
	BNE	INSCA0		;loop if more
NOGTPR	JSR	OPNSRC		;open file
	LDA	#0		;now
	STA	CONT		;clear
	STA	COLUMN		;variables
	STA	LINENO		;for start
	STA	LINENO+1	;of a
	STA	LNEPTR		;pass
	JSR	CLLNBF		;clear output buffer
	LDA	#SRCRSZ		;now set source
	STA	SRCIND		;index to invalid
	LDA	#':'		;set separator
	STA	SEPRTR		;to a colon
	LDA	PRMLST		;get first parm
	CMP	#'$'		;see if start
	BNE	INSDNE		;not so exit
	LDX	#1		;set index to first
INSCAP	LDA	PRMLST,X	;get parm
	INX			;bump index
	CMP	#SPACE		;if not a space
	BEQ	INSDNE		;done if space
	LDY	#TRUE		;set true
	CMP	#'A'		;if not A
	BNE	PNOTA		;try next
	STY	LSTPRD		;else set
	BEQ	INSCAP		;and loop
PNOTA	CMP	#'C'		;if not C
	BNE	PNOTC		;try next
	STY	nintfl		;else set
	BEQ	INSCAP		;and loop
PNOTC	CMP	#'E'		;see if E
	BNE	PNOTE		;branch if not
	STY	DEBUGL		;else set
	BEQ	INSCAP		;and loop
PNOTE	CMP	#'F'		;see if F
	BNE	PNOTF		;branch if not
	STY	LSTFLG		;else set
	BEQ	INSCAP		;and loop
PNOTF	LDY	#FALSE		;now use false
	CMP	#'B'		;if not B
	BNE	PNOTB		;try next
	STY	lstsrc		;else set
	BEQ	INSCAP		;and loop
PNOTB	CMP	#'D'		;if not D
	BNE	INSCAP		;then not valid
	STY	LWRUPR		;else set
	BEQ	INSCAP		;and loop
;done with INSCAN so get first non-blank
INSDNE	LDA	#0		;clear eol flag
	STA	EOLSTS
	JMP	GTNBLK
;put NXTCHR in ACCUM
PUTACC	BIT	CONT		;test for continue
	BPL	*+3		;do if not
	RTS			;else done
	INC	ACCLEN		;bump length
	LDX	ACCLEN		;get it as index
	LDA	NXTCHR		;get next
	STA	ACCUM,X		;store it
	CLC			;clear carry
	ADC	HSHCDE		;add hashcde
	AND	#HSHMSK		;mask it
	STA	HSHCDE		;and save
	CPX	#IDNTSZ-1	;compare to max
	BCS	*+3		;branch if too big
	RTS			;else done
	LDA	#TRUE		;set CONT
	STA	CONT		;flag
	RTS
;put NXTCHR in ACCUM and get another non-blank
PUTGET	JSR	PUTACC		;put
	JMP	GTNBLK		;and get
;put NXTCHR in ACCUM and get another char
PUTCHR	JSR	PUTACC		;put
	JMP	GETCHR		;and get
;test for numeric NXTCHR. return with A:=TRUE iff NXTCHR in '0' to '9'
NUMRIC	LDA	NXTCHR		;get char
	CMP	#'0'		;see if less than 0
	BCC	NOTNUM		;branch if is
	CMP	#'9'+1		;see if over 9
	BCS	NOTNUM		;branch if is
	LDA	#TRUE		;else set
	RTS			;for numeric
NOTNUM	LDA	#FALSE		;set false
	RTS
;test for lower case NXTCHR. return with A:=TRUE iff NXTCHR in 'a' to 'z'
LWRCSE	LDA	NXTCHR		;get chat
	CMP	#'a'		;see if < a
	BCC	NOTLWR		;branch if is
	CMP	#'z'+1		;see if > z
	BCS	NOTLWR		;branch if is
	LDA	#TRUE		;else 
	RTS			;is lower
NOTLWR	LDA	#FALSE		;not lower
	RTS
;test for NXTCHR a decimal point
DCMLPT	LDA	NXTCHR		;get char
	CMP	#'.'		;test it
	BNE	NTDCML		;branch if not
	LDA	#TRUE		;set for true
	RTS
NTDCML	LDA	#FALSE		;false
	RTS
;convert lowercase to uppercase
CNVLWR	JSR	LWRCSE		;see if lower
	AND	LWRUPR		;and with flag
	BNE	*+3		;ok if both true
	RTS			;else done
	LDA	NXTCHR		;get char
	AND	#$5F		;convert
	STA	NXTCHR		;and save
	RTS
;test for letter. set A:=TRUE if lowercase or uppercase letter
LETTER	JSR	CNVLWR		;covert if all set
	JSR	LWRCSE		;see if still lowercase
	BEQ	*+3		;branch if not
	RTS			;else is TRUE
	LDA	NXTCHR		;get char
	CMP	#'A'		;if < A
	BCC	NOTLTR		;is not letter
	CMP	#'Z'+1		;if > Z
	BCS	NOTLTR		;is not letter
	LDA	#TRUE		;else is
	RTS
NOTLTR	LDA	#FALSE		;not letter
	RTS
;test for letter, number or decimal point. return A:=TRUE if either
ALPNUM	JSR	LETTER		;first try letter
	BEQ	*+3		;branch if not
	RTS
	JSR	NUMRIC		;now try number
	BEQ	*+3		;branch if not
	RTS
	JMP	DCMLPT		;finally try decimal point
;spool numeric data into ACCUM
SPLNUM	JSR	NUMRIC		;see if number
	BNE	*+3		;branch if is
	RTS			;else done
	JSR	PUTCHR		;stuff it
	JMP	SPLNUM		;and loop
;set up next call
SUPNCL	LDA	NXTCHR		;get next
	CMP	#SPACE		;see if blank
	BNE	*+5		;branch if not
	JSR	GTNBLK		;get non-blank
	LDA	#FALSE		;set continue
	STA	CONT		;to false
	RTS
;procedure called by SYNTHE to reduce the amount of indexing
SCOPY	LDX	SP		;get stack pointer
	LDA	TYPE,X		;do
	STA	TYPESP		;byte
	LDA	STYPE,X		;values
	STA	STYPSP		;first
	LDA	HASH,X
	STA	HASHSP
	TXA			;now
	ASL	A		;make a
	TAX			;word index
	LDA	SYMLOC,X
	LDY	SYMLOC+1,X
	STA	SYMLSP
	STY	SYMLSP+1
	LDA	SRLOC,X
	LDY	SRLOC+1,X
	STA	SRLOSP
	STY	SRLOSP+1
	LDX	MP		;now get MP
	LDA	TYPE,X
	STA	TYPEMP
	LDA	STYPE,X
	STA	STYPMP
	LDA	HASH,X
	STA	HASHMP
	TXA			;now
	ASL	A		;make a
	TAX			;word index
	LDA	SYMLOC,X
	LDY	SYMLOC+1,X
	STA	SYMLMP
	STY	SYMLMP+1
	LDA	SRLOC,X
	LDY	SRLOC+1,X
	STA	SRLOMP
	STY	SRLOMP+1
	LDX	MPP1		;now get MP+1
	LDA	TYPE,X
	STA	TYPEM1
	LDA	STYPE,X
	STA	STYPM1
	LDA	HASH,X
	STA	HASHM1
	TXA			;now
	ASL	A		;make a
	TAX			;word index
	LDA	SYMLOC,X
	LDY	SYMLOC+1,X
	STA	SYMLM1
	STY	SYMLM1+1
	RTS
;called by SYNTHE to set SYMLOC(SP) to AY
STSLSP	PHA			;save A part
	LDA	SP		;get SP
STSL	ASL	A		;mult by two
	TAX			;make index
	PLA			;get byte
	STA	SYMLOC,X	;save it
	TYA			;get high
	STA	SYMLOC+1,X	;save it
	RTS
;called by SYNTHE to set SYMLOC(MP) to AY
STSLMP	PHA			;save low
	LDA	MP		;get MP
	JMP	STSL		;go do
;called by SYNTHE to set TYPE(SP) to A
STTYSP	LDX	SP		;get SP
	STA	TYPE,X		;save
	RTS
;called by SYNTHE to set STYPE(SP) to A
STSTSP	LDX	SP		;get SP
	STA	STYPE,X		;save
	RTS
;set STYPE(MP) to A
STSTMP	LDX	MP		;get MP
	STA	STYPE,X		;save
	RTS
;set TYPE(MP) to A
STTYMP	LDX	MP		;get MP
	STA	TYPE,X		;save
	RTS
;set HASH(MP) to A
STHAMP	LDX	MP		;get MP
	STA	HASH,X		;insert
	RTS
;set HASH(SP) to A
STHASP	LDX	SP		;get SP
	STA	HASH,X		;insert
	RTS
;set SRLOC(SP) to AY
STSRSP	PHA			;save low
	LDA	SP		;get SP
	ASL	A		;mult by two
	TAX			;make index
	PLA			;get low
	STA	SRLOC,X		;save ir
	TYA			;get high
	STA	SRLOC+1,X	;save it
	RTS
;write generated code in A and count size of code area
GENERT	INC	CODESI		;bump
	BNE	*+4		;code
	INC	CODESI+1	;size
	BIT	PASS1		;test for pass 1
	BMI	*+5		;branch if
	JMP	EMIT		;else go emit
	RTS
;write data in A during pass 2 and count size of data area
EMITDT	INC	DATACT		;bump
	BNE	*+4		;data
	INC	DATACT+1	;size
	BIT	PASS2		;test for pass 2
	BPL	*+5		;branch if not
	JMP	EMIT		;else go emit
	RTS
;compare ACCUM to reserved word string
COMPAR	LDA	#0
	STA	IC
COMPA0	LDY	IC
	LDA	(PTR),Y		;a=field(i)
	INC	IC
	LDY	IC		;i=i+1
	CMP	ACCUM,Y		;compare field(i) to accum(i=i+1)
	BNE	COMPAX		;exit if different
	LDA	ACCLEN
	CMP	IC		;if i<=acclen
	BCS	COMPA0		;then loop
COMPAT	LDA	#TRUE		;was a match
	RTS
COMPAX	LDA	ACCLEN		;check termination condition
	CMP	IC
	BCC	COMPAT		;if i>acclen is true
	LDA	#FALSE
	RTS
;attempt to match reserved word
LOOKUP	LDA	#MAXRWL		;compare max word length
	CMP	ACCLEN		;to length
	BCC	LOOKFL		;exit as false if too big
	LDX	ACCLEN		;get length
	LDA	OFFSET,X	;and offset
	CLC			;in reserved word table
	ADC	#<LNG1		;now add to
	STA	PTR		;start to
	LDA	#0		;get
	ADC	#>LNG1		;indirect
	STA	PTR+1		;pointer
	LDA	#0		;set index
	STA	IL		;to zero
LOOKU0	INC	IL		;bump index
	LDX	ACCLEN		;see if count
	LDA	COUNT,X		;bigger than
	CMP	IL		;number words
	BCC	LOOKFL		;no match if is
	JSR	COMPAR		;try to match
	BNE	LOOKMT		;branch if did
	CLC			;else
	LDA	PTR		;bump
	ADC	ACCLEN		;pointer
	STA	PTR		;by length
	BCC	LOOKU0		;of word
	INC	PTR+1		;and try
	JMP	LOOKU0		;next
LOOKMT	LDX	ACCLEN		;get length
	LDA	TKOS,X		;and token offset
	CLC			;add to
	ADC	IL		;index
	TAX			;make an index
	LDA	TK,X		;get token
	STA	TOKEN		;and save
	CMP	#64+1		;see if over 64
	BCC	LOOKTR		;branch if not
	CMP	#TDATA		;see if TDATA
	BEQ	LOOKTR		;branch if is
	STA	FUNCOP		;else save as FUNCOP
	SEC			;now subtract
	SBC	#65		;65 to
	TAX			;make index
	LDA	ST,X		;get subtype
	STA	SUBTYP		;and save
	LDA	#FUNCT
	STA	TOKEN		;token=funct
LOOKTR	LDA	#TRUE		;match
	RTS
LOOKFL	LDA	#FALSE		;no match
	RTS
;scanner accepts input characters from the source file returning tokens to the
;parser.  conversion to uppercase is performed if LWRUPR is set.  each token is
;placed in ACCUM and ACCLEN is the length of the token.  the token is hashed by
;summing each ASCII character modulo HSHTSZ (hashtablesize) and is stored in
;HSHCDE (hashcode).  SUBTYP and FUNCOP are set if the token is a predefined
;function.  REM and DATA statements are handled completely by the scanner. REM
;and REMARK statements cause the input to be scanned until the end of the
;current input line is located.  the cr is then scanned and returned.  DATA
;statements are similar except data is output using EMITDT.
SCANNR	LDA	#0		;clear
	STA	ACCLEN		;these
	STA	HSHCDE		;variables
	STA	TOKEN		;at
	STA	SUBTYP		;start
	BIT	CONT		;test continue flag
	BMI	SCAN1		;branch if set
	BIT	EOLSTS		;test eol status
	BPL	SCAN28		;skip if char ready
	JSR	GTNBLK		;else go read
	LDA	#0		;then clear flag
	STA	EOLSTS
SCAN28	LDA	NXTCHR		;else get next
	CMP	#'"'		;see if "
	BNE	SCAN5		;branch if not
;first case is string or string continuation
SCAN1	LDA	#STRING		;get token
	STA	TOKEN		;and set
	LDA	#FALSE		;and set
	STA	CONT		;CONT as false
SCAN2	JSR	GETCHR		;get char
	CMP	#'"'		;see if delimiter
	BEQ	SCAN4		;branch if is
	CMP	#CR		;see if eol
	BNE	SCAN3		;branch if not
	LDA	#22		;else is unterminated string
	JMP	ERROR		;do error and quit
SCAN3	JSR	PUTACC		;put in ACCUM
	BIT	CONT		;test for continue
	BPL	SCAN2		;loop if not
	RTS			;else done
SCAN4	JSR	GTNBLK		;get non-blank
	CMP	#'"'		;see if another delimiter
	BEQ	*+3		;branch if is
	RTS			;else done
	JSR	PUTACC		;put in ACCUM
	JMP	SCAN2		;and loop
SCAN5	JSR	NUMRIC		;see if number
	BNE	SCAN6		;branch if is
	JSR	DCMLPT		;see if decimal point
	BEQ	SCAN15		;branch if not
;is a numeric of up to IDNTSZ-1 characters
SCAN6	LDA	#FLOTPT		;get token
	STA	TOKEN		;and set
	LDA	NXTCHR		;get next char
SCAN7	CMP	#'0'		;see if leading zero
	BNE	SCAN8		;branch if not
	JSR	GETCHR		;else get next
	JMP	SCAN7		;and loop to flush
SCAN8	JSR	SPLNUM		;spool numeric
	JSR	DCMLPT		;test for decimal point
	BEQ	SCAN9		;branch if not
	JSR	PUTCHR		;insert it
	JSR	SPLNUM		;spool rest
SCAN9	JSR	CNVLWR		;convert next to upper
	LDA	NXTCHR		;get it
	CMP	#'E'		;see if e for exponent
	BNE	SCAN13		;branch if not
	JSR	PUTGET		;else insert and get another
	CMP	#'+'		;if a +
	BEQ	SCAN10		;go insert and get another
	CMP	#'-'		;if not a -
	BNE	SCAN11		;skip ahead
SCAN10	JSR	PUTGET		;insert and get
SCAN11	JSR	NUMRIC		;test for number
	BNE	SCAN12		;branch if is
	LDA	#9		;else illegal floating point format
	JSR	ERROR		;error
SCAN12	JSR	SPLNUM		;spool numbers
SCAN13	LDA	ACCLEN		;get length
	BNE	SCAN14		;branch if not zero
	INC	ACCLEN		;else bump
	LDA	#'0'		;and insert a '0'
	STA	ACCUM+1		;in ACCUM
	STA	HSHCDE		;and hashcode
SCAN14	JMP	SUPNCL		;setupnextcall and return
SCAN15	JSR	LETTER		;see if letter
	BNE	*+5		;continue if is
	JMP	SCAN26		;else go to next section
;is an identifier or may be REM, REMARK, or DATA statements. these two are
;handled here
SCAN16	JSR	ALPNUM		;test for alphanumeric
	BEQ	SCAN17		;branch if not
	JSR	PUTCHR		;else insert and get
	JMP	SCAN16		;and loop
SCAN17	LDA	NXTCHR		;get next char
	CMP	#'$'		;if not a $
	BNE	SCAN18		;is floating
	LDA	#STRING		;else set string
	STA	SUBTYP		;as subtype
	JSR	PUTCHR		;put and get
	JMP	SCAN19		;and continue
SCAN18	LDA	#FLOTPT		;set floating
	STA	SUBTYP		;as subtype
SCAN19	JSR	LOOKUP		;try to match
	BNE	SCAN21		;branch if reserved
	LDA	ACCUM+1		;check for user
	CMP	#'F'		;defined function
	BNE	SCAN20		;branch if not
	LDA	ACCUM+2		;same for next
	CMP	#'N'		;char in ACCUM
	BNE	SCAN20
	LDA	ACCLEN		;get length
	CMP	#1		;must not be 1
	BEQ	SCAN20		;branch if is
	LDA	#UDFUNC		;ah!ah! is FN--
	STA	TOKEN		;set token
	JMP	SUPNCL		;exit with setupnextcall
SCAN20	LDA	#IDENT		;is identifier
	STA	TOKEN		;set token
	JMP	SUPNCL		;exit with setupnextcall
SCAN21	LDA	TOKEN		;is a reserved
	CMP	#TREM		;see if REM
	BNE	SCAN23		;branch if not
SCAN22	LDA	NXTCHR		;get next
	CMP	#CR		;see if eol
	BNE	*+5		;branch if not
	JMP	SCANNR		;else loop to start
	JSR	GETCHR		;get char
	JSR	CHKCNT		;check for continue
	JMP	SCAN22		;and loop
SCAN23	CMP	#TDATA		;see if DATA
	BEQ	*+5		;branch if is
	JMP	SUPNCL		;else setupnextcall and exit
	LDA	#DAT		;emit DAT opcode
	JSR	EMITDT		;to start
	LDA	NXTCHR		;get next
	JSR	EMITDT		;emit it
SCAN24	JSR	GETCHR		;get another
	CMP	#CR		;see if eol
	BEQ	SCAN25		;branch if is
	JSR	CHKCNT		;else check for continue
	LDA	NXTCHR		;get char
	JSR	EMITDT		;emit it
	JMP	SCAN24		;and loop
SCAN25	LDA	#','		;now emit
	JSR	EMITDT		;a comma
	LDA	#0		;and a
	JSR	EMITDT		;zero
	LDA	DATACT		;now
	BNE	*+4		;drop
	DEC	DATACT+1	;data count
	DEC	DATACT		;by one
	JMP	SCANNR		;and loop to start
;final case is a special character -- it may be continuation char in which case
;just go to next line and scan somemore
SCAN26	LDA	NXTCHR		;get char
	CMP	#backsl		;see if continue
	BNE	SCAN27		;branch if not
	JSR	CHKCNT		;check it
	JMP	SCANNR		;and loop
SCAN27	JSR	PUTACC		;put in accum
	LDA	NXTCHR		;get last char
	CMP	#CR		;see if eol
	BNE	SCAN29		;not so skip
	LDA	#$FF		;set flag to read
	STA	EOLSTS
	BMI	SCAN30		;then jump ahead
SCAN29	JSR	GTNBLK		;get non blank
SCAN30	JSR	LOOKUP		;see if match
	BEQ	*+3		;branch if not
	RTS			;else done
	LDA	#7		;illegal character error
	JMP	ERROR		;and quit
;adjust base for next entry
NXTENT	LDY	#0		;clear index
	LDA	(BASE),Y	;get name length
	CLC			;now
	ADC	BASE		;add to current
	STA	BASE		;and update
	BCC	*+4		;don't forget
	INC	BASE+1		;carry
	CLC			;now
	LDA	BASE		;add
	ADC	#7		;seven for
	STA	BASE		;overhead
	BCC	*+4		;to get
	INC	BASE+1		;new base
	RTS
;get length of printname
GETLEN	LDY	#0		;clear index
	LDA	(BASE),Y	;get length
	RTS
;write numeric constant during pass 1
EMITCN	BIT	PASS1		;test for pass 1
	BMI	*+3		;branch if is
	RTS			;else done
	JMP	EMIT		;write byte
;write two bytes of object code on disk for literals
GENTWO	PHA			;save low
	TYA			;get high
	JSR	GENERT		;write it
	PLA			;get low
	JMP	GENERT		;do it
;
LITERL	PHA			;save low
	TYA			;get high
	ORA	#$80		;set msb
	TAY			;back to Y
	PLA			;get low
	JMP	GENTWO		;send it
;
LITLOD	PHA			;save low
	TYA			;get high
	ORA	#$C0		;or with mask
	TAY			;back to Y
	PLA			;get low
	JMP	GENTWO		;write it
;
LINENU	BIT	DEBUGL		;test debug flag
	BMI	*+3		;branch if set
	RTS			;else do nothing
	LDA	LINENO		;get low
	LDY	LINENO+1	;and high number
	JSR	LITERL		;send as literal
	LDA	#BOL		;then send BOL
	JMP	GENERT		;opcode
;fill hashtable with 0's and initialize pointer to top of symbol table
INSYMT	BIT	PASS1		;see if pass 1
	BPL	INSYM1		;branch if not
	LDX	#HSHTSZ*2-1	;get number to clear
	LDA	#0		;then value
INSYM0	STA	HSHTBL,X	;store it
	DEX			;drop count
	CPX	#255		;see if wrap
	BNE	INSYM0		;loop if not
	LDA	#<MEMORY	;get memory
	LDY	#>MEMORY	;start
	STA	SBTBL		;and set
	STY	SBTBL+1		;table start
INSYM1	LDA	PEM+1		;get limit
	LDY	PEM+2		;of memory
	SEC			;drop
	SBC	#2		;two
	STA	SBTTOP		;to get
	STA	NXSTPT		;top starting
	BCS	*+3		;branch if no borrow
	DEY			;else drop Y
	STY	SBTTOP+1	;set high
	STY	NXSTPT+1	;and set
	LDA	#0		;clear A
	LDY	#1		;set index to 1
	STA	(NXSTPT),Y	;put in memory
	RTS
;
GETHSH	LDY	#0		;get
	LDA	(BASE),Y	;PTR
	STA	TMPPTR		;and save
	STY	TMPHSH		;clear internal hash
	LDA	BASE		;get
	LDY	BASE+1		;base
	CLC			;now
	ADC	#2		;add 2
	STA	APTADD		;and save
	BCC	*+3		;branch if
	INY			;no carry
	STY	APTADD+1	;save high
	LDY	#1		;set starting index
GETHS0	CPY	TMPPTR		;compare to limit
	BEQ	GETHS1		;continue if equal
	BCC	GETHS1		;branch if less
	LDA	TMPHSH		;else get HASH
	RTS			;and quit
GETHS1	LDA	(APTADD),Y	;get value
	CLC			;now add
	ADC	TMPHSH		;in old hash
	AND	#HSHMSK		;and mask
	STA	TMPHSH		;and save
	INY			;bump loop index
	JMP	GETHS0		;then loop
;
HSOSYM	LDA	SYMHSH		;get symhsh
	ASL	A		;mult by two
	TAX			;make index
	LDA	HSHTBL,X	;get value
	LDY	HSHTBL+1,X	;in table
	RTS
;
SETLNK	LDX	BASE		;get
	LDY	BASE+1		;base
	INX			;bump
	STX	APTADD		;by
	BNE	*+3		;one
	INY			;and
	STY	APTADD+1	;save
	RTS
;set pointer for addr reference with offset in A
SETADP	LDY	#0		;clear index
	CLC			;and carry
	ADC	(BASE),Y	;add PTR
	BCC	*+3		;branch if no carry
	INY			;else set Y to 1
	CLC			;clear carry
	ADC	BASE		;add base
	STA	APTADD		;to low
	TYA			;now add
	ADC	BASE+1		;with carry to high
	STA	APTADD+1	;and save
	RTS
;check to see if additional SBTBL entry will overflow limits of memory. if
;so then abort else return. at entry A contains amount to be added (COUNT)
LIMITS	CLC			;add count
	ADC	SBTBL		;to start
	LDY	SBTBL+1		;with
	BCC	*+3		;carry to
	INY			;high
	CMP	SBTTOP		;compare to limit
	TYA			;including
	SBC	SBTTOP+1	;high
	BCS	*+3		;whoops! no borrow
	RTS			;else ok
	LDA	#TRUE		;set to
	STA	PASS2		;pass 2
	LDA	#19		;symbol table error
	JSR	ERROR		;send it
	JMP	BOOT		;and abort
;set the address field at location LOC in AY and resolved bit
SETRSV	PHA			;save
	TYA			;A
	PHA			;and Y
	LDA	#4		;set offset
	JSR	SETADP		;of four
	LDY	#1		;set index to 1
	PLA			;get high
	STA	(APTADD),Y	;and save
	DEY			;drop Y to 0
	PLA			;get low
	STA	(APTADD),Y	;save it
	LDA	APTADD		;now
	BNE	*+4		;drop
	DEC	APTADD+1	;pointer
	DEC	APTADD		;by one
	LDA	(APTADD),Y	;now set
	ORA	#$80		;resolved
	STA	(APTADD),Y	;bit
	RTS
;return type of variable
GETTYP	LDA	#3		;build
	JSR	SETADP		;new indirect
	LDY	#0		;clear index
	LDA	(APTADD),Y	;get
	AND	#$7F		;mask out set bit
	RTS
;set type of variable to A and preserve resolved bit
SETTYP	PHA			;save type
	LDA	#3		;calculate
	JSR	SETADP		;new pointer
	LDY	#0		;clear index
	PLA			;get type
	ORA	(APTADD),Y	;or with contents
	STA	(APTADD),Y	;save it
	RTS
;get resolved bit A:=TRUE iff bit=1 else A:=FALSE
GETRES	LDA	#3		;build
	JSR	SETADP		;pointer
	LDY	#0		;clear index
	LDA	(APTADD),Y	;get byte
	BMI	*+5		;branch if set
	LDA	#FALSE		;else set
	RTS			;false
	LDA	#TRUE		;was set
	RTS
;get the address of the printname location in AY
GETADR	LDA	#4		;build
	JSR	SETADP		;pointer
	LDY	#0		;clear index
	LDA	(APTADD),Y	;now get low
	PHA			;save
	INY			;set Y to 1
	LDA	(APTADD),Y	;get high
	TAY			;move to Y
	PLA			;get low
	RTS
;check to see if printname located at address in PRNTNM is in SBTBL. if is
;then A:=TRUE and BASE:=address else A:=FALSE
SLOOKU	JSR	HSOSYM		;find base
SLOOKX	STA	BASE		;and
	STY	BASE+1		;save
SLOOK0	LDA	BASE		;see if
	ORA	BASE+1		;base = 0
	BEQ	SLOOFL		;false if is
	LDY	#0		;clear index
	LDA	(BASE),Y	;get PTR
	STA	LEN		;save as length
	CMP	(PRNTNM),Y	;compare
	BNE	SLOOK2		;branch if different
SLOOK1	LDY	LEN		;get length
	LDA	(PRNTNM),Y	;get name
	INY			;bump index
	INY			;by two
	CMP	(BASE),Y	;compare to entry
	BNE	SLOOK2		;branch if different
	DEC	LEN		;drop length
	BNE	SLOOK1		;loop for more
	LDA	#TRUE		;else say true
	RTS
SLOOK2	JSR	SETLNK		;set link
	LDY	#0		;clear index
	LDA	(APTADD),Y	;get low
	PHA			;save it
	INY			;set y to 1
	LDA	(APTADD),Y	;get high
	TAY			;move to Y
	PLA			;get low
	JMP	SLOOKX		;and loop
SLOOFL	LDA	#FALSE		;was not
	RTS			;found
;enter token reference by PRNTNM and SYMHSH into next available location in the
;symbol table.  set BASE to beginning of this entry and increment SBTBL. check
;for symbol table full
ENTER	LDY	#0		;clear index
	LDA	(PRNTNM),Y	;get length
	CLC			;now
	ADC	#7		;add seven
	PHA			;save on stack
	JSR	LIMITS		;test limits
	LDA	SBTBL		;update
	LDY	SBTBL+1		;base
	STA	BASE
	STY	BASE+1
	LDY	#0		;get
	LDA	(PRNTNM),Y	;length
	STA	(BASE),Y	;move to table
	TAX			;make a counter
	BEQ	ENTER1		;done if zero
	INY			;start with Y=1
ENTER0	LDA	(PRNTNM),Y	;get name
	INY			;bump index
	INY			;by two
	STA	(SBTBL),Y	;insert
	DEY			;drop y by one
	DEX			;drop count
	BNE	ENTER0		;loop if more
ENTER1	LDA	#3		;clear resolve bit
	JSR	SETADP		;by getting pointer
	LDY	#0		;clear index
	TYA			;and A
	STA	(APTADD),Y	;insert
	JSR	SETLNK		;set link
	JSR	HSOSYM		;find address
	PHA			;save low on stack
	TYA			;high to A
	LDY	#1		;do high
	STA	(APTADD),Y	;first
	DEY			;drop Y
	PLA			;get low
	STA	(APTADD),Y	;and set
	LDA	SYMHSH		;get hash
	ASL	A		;mult by two
	TAX			;make index
	LDA	BASE		;get
	STA	HSHTBL,X	;and move
	LDA	BASE+1		;to
	STA	HSHTBL+1,X	;table
	PLA			;get new length
	CLC			;now
	ADC	SBTBL		;to start
	STA	SBTBL		;to get
	BCC	*+4		;new
	INC	SBTBL+1		;table address
	RTS
;insert subtype in SBTBL
SETSUB	PHA			;save code
	LDA	#6		;offset pointer
	JSR	SETADP		;get pointer
	LDY	#0		;clear index
	PLA			;get code
	STA	(APTADD),Y	;save
	RTS
;return the subtype
GETSUB	LDA	#6		;build
	JSR	SETADP		;pointer
	LDY	#0		;clear pointer
	LDA	(APTADD),Y	;get subtype
	RTS
;
UNLINK	JSR	GETTYP		;get type
	STA	NUMPRM		;save it
	LDA	#1		;set index
	STA	LINKI		;to one
UNLNK0	LDA	NUMPRM		;compare limit
	CMP	LINKI		;to count
	BCS	*+3		;continue if ok
	RTS			;else done
	JSR	NXTENT		;get next
	JSR	GETHSH		;and hash
	ASL	A		;mult
	CLC			;by two
	ADC	#<HSHTBL	;and add
	STA	TMPADR		;hash table start
	LDY	#>HSHTBL	;get high
	BCC	*+3		;with carry
	INY			;bump
	STY	TMPADR+1	;and save
UNLNK1	LDY	#0		;clear index
	LDA	BASE		;compare base low
	CMP	(TMPADR),Y	;to byte
	BNE	UNLNK2		;branch if different
	INY			;set y to 1
	LDA	BASE+1		;do same
	CMP	(TMPADR),Y	;for high
	BEQ	UNLNK3		;branch if all same
UNLNK2	LDY	#0		;y back to zero
	LDA	(TMPADR),Y	;get low
	PHA			;save it
	INY			;bump index
	LDA	(TMPADR),Y	;get high
	STA	TMPADR+1	;change address
	PLA			;get low
	STA	TMPADR		;save it
	INC	TMPADR
	BNE	UNLNK1
	INC	TMPADR+1
	JMP	UNLNK1		;and loop
UNLNK3	JSR	SETLNK		;set link
	LDY	#0		;clear index
	LDA	(APTADD),Y	;get low
	STA	(TMPADR),Y	;and move
	INY			;now
	LDA	(APTADD),Y	;same
	STA	(TMPADR),Y	;for high
	INC	LINKI		;bump loop index
	JMP	UNLNK0		;and loop
;
RELINK	JSR	GETTYP		;get type
	STA	NUMPRM		;save it
	LDA	#1		;set count
	STA	LINKI		;to one
RELNK0	LDA	NUMPRM		;get limit and
	CMP	LINKI		;compare to count
	BCS	*+3		;branch if >=
	RTS			;else done
	JSR	NXTENT		;do next entry
	LDA	BASE		;now set
	LDY	BASE+1		;temp
	STA	TMPADR
	INC	TMPADR		;bump low
	BNE	*+3
	INY
	STY	TMPADR+1	;save high
	JSR	GETHSH		;get hash
	ASL	A		;mult by two
	TAX			;make index
	LDY	#0		;clear Y
	LDA	HSHTBL,X	;get low
	STA	(TMPADR),Y	;save it
	INY			;now high
	LDA	HSHTBL+1,X	;get it
	STA	(TMPADR),Y	;save it
	JSR	GETHSH		;gethash
	ASL	A
	TAX
	LDA	BASE		;now get
	STA	HSHTBL,X	;and put
	LDA	BASE+1		;new base
	STA	HSHTBL+1,X	;in table
	INC	LINKI		;bump loop index
	JMP	RELNK0		;and loop
;initialize SYNTHE
;data definitions for initialization
CONZER	.byte	1,"0"
CONONE	.byte	1,"1"
INSYN	LDA	#0		;first
	STA	CODESI		;clear
	STA	CODESI+1	;variables
	STA	DATACT
	STA	DATACT+1
	STA	ONSP
	STA	IFLABL
	STA	FDACT+1		;set fda
	LDA	#1		;count to
	STA	FDACT		;one
	LDA	#$FF		;set prt
	STA	PRTCT		;count
	STA	PRTCT+1		;to -1
	JSR	SETFLG		;set flags
	BIT	PASS1		;see if pass 1
	BMI	*+3		;branch if is
	RTS			;else done
	JSR	SUPINT		;setup int file
	LDA	#<CONONE	;initialize
	LDY	#>CONONE	;printname
	STA	PRNTNM		;pointer
	STY	PRNTNM+1
	LDA	#'1'		;then
	STA	SYMHSH		;symbol hash
	JSR	ENTER		;put in table
	LDA	#'1'		;emit
	JSR	EMITCN		;emit
	LDA	#'$'		;do a $
	JSR	EMITCN
	LDA	#0		;constant 1
	TAY			;is at fda position 0
	JSR	SETRSV		;set
	LDA	#CONST		;set type
	JSR	SETTYP		;as constant
	LDA	#<CONZER	;now
	LDY	#>CONZER	;point
	STA	PRNTNM		;to
	STY	PRNTNM+1	;zero
	LDA	#'0'		;set hash
	STA	SYMHSH		;to '0'
	JSR	ENTER		;enter it
	LDA	#'0'		;now
	JSR	EMITCN		;output it
	LDA	#'$'		;do $
	JSR	EMITCN
	LDA	#1		;set address
	LDY	#0
	JSR	SETRSV
	LDA	#CONST		;and type = const
	JMP	SETTYP		;then exit
;calculate var(a)+.varc
CALVRC	TAX			;make index
	LDA	VAR,X		;get var contents
	CLC			;now add
	ADC	#<VARC		;varc start
	LDY	#>VARC		;with carry
	BCC	*+3
	INY
	RTS
;setlookup
STLKUP	PHA			;save param
	JSR	CALVRC		;calculate varc
	STA	PRNTNM		;save as printname
	STY	PRNTNM+1	;position
	PLA			;get param
	TAX			;make index
	LDA	HASH,X		;get entry
	STA	SYMHSH		;and set symbols
	RTS
;lookup$only
LKONLY	JSR	STLKUP		;set up
	JMP	SLOOKU		;try to lookup
;normal$lookup
NRMLKU	JSR	LKONLY		;call lookup$only
	BEQ	*+3		;if false
	RTS			;else done
	JSR	ENTER		;enter in table
	LDA	#FALSE		;then done
	RTS
;count size of the prt and return with count in AY
CNTPRT	INC	PRTCT		;bump
	BNE	*+4
	INC	PRTCT+1
	LDA	PRTCT		;and get
	LDY	PRTCT+1
	RTS
;setifname
SETIFN	LDA	#<IFLBLN	;point to printname
	LDY	#>IFLBLN
	STA	PRNTNM
	STY	PRNTNM+1
	LDA	IFLABL		;set symhash
	AND	#HSHMSK
	STA	SYMHSH
	RTS
;enter$compiler$label(a)
ENCMLB	BIT	PASS1		;test for pass 1
	BMI	*+3		;branch if is
	RTS
	PHA			;save parameter
	JSR	SETIFN		;call setifname
	JSR	ENTER		;call enter
	PLA			;get param
	CLC			;add to codesize
	ADC	CODESI
	LDY	CODESI+1
	BCC	*+3
	INY			;with carry
	JMP	SETRSV		;call setaddr(codesize+a)
;set$compiler$label
STCMLB	INC	IFLABL		;bump iflable
	JSR	SETIFN		;call setifname
	JMP	SLOOKU		;call "s"lookup
;compiler$label
COMLBL	JSR	STCMLB		;call set$compiler$label
	JSR	GETADR		
	JMP	GENTWO		;call gen$two(getaddr)
;check for mp and sp both floating point
CHKTY1	LDA	STYPMP		;get stypemp
	CMP	#FLOTPT		;see if = floatpt
	BNE	DOC1MF		;error if not
	LDA	STYPSP		;get stypesp
	CMP	#FLOTPT		;see if = floatpt
	BNE	DOC1MF		;error if not
	LDA	#TRUE
	RTS
DOC1MF	JSR	MFERR		;error
	LDA	#FALSE
	RTS
;check mp and sp both same type
CHKTY2	LDA	STYPSP		;get stypesp
	CMP	STYPMP		;see if stypemp same
	BNE	*+5		;error if not
	LDA	#TRUE
	RTS
	LDA	#13		;mixed mode error
	JSR	ERROR
	LDA	#FALSE
	RTS
;chktyp3
CHKTY3	LDA	STYPSP		;get stypesp
	JSR	STSTMP		;call setstypemp(stypesp)
	LDA	STYPSP		;get stypesp
	CMP	#FLOTPT		;see if floating
	BNE	*+5		;error if not
	LDA	#TRUE
	RTS
	JSR	MFERR		;must be floating error
	LDA	#FALSE
	RTS
;must be floating point error
MFERR	LDA	#12
	JMP	ERROR
;chktyp4
CHKTY4	LDA	STYPM1		;get stypemp1
	CMP	#STRING		;see if string
	BNE	*+5		;ok if not
	JSR	MFERR		;else must be floating error
	LDA	#RON
	JMP	GENERT		;call generate(ron)
;chktyp5
CHKTY5	JSR	CHKTY4		;call chktyp4
	INC	TYPEMP		;bump typemp
	LDA	TYPEMP
	JMP	STTYMP		;call settypemp(typemp:=typemp+1)
;subcalc
SUBCAL	LDA	TYPESP		;get type
	JSR	SETSUB		;call setsubtype(typesp)
	LDA	#ROW
	JSR	GENERT		;call generate(row)
	LDA	TYPESP
	JSR	GENERT		;call generate(typesp)
	LDA	#STD
	JMP	GENERT		;call generate(std)
;gen$store
GENSTR	LDA	STYPM1		;get stypemp1
	CMP	#FLOTPT		;see if floating
	BNE	*+7		;branch if not
	LDA	#STD
	JMP	GENERT		;call generate(std)
	LDA	#STS
	JMP	GENERT		;call generate(sts)
;setup$input
SEINPU	LDA	#TRUE
	STA	INPSTM		;inputstmt=true
	LDA	#RCN
	JMP	GENERT		;call generate(rcn)
;gen$read(a,y)
GENRDE	LDX	STYPSP		;get stypesp
	CPX	#STRING		;see if string
	BNE	*+10		;branch if not
	JSR	GENERT		;call generate(i)
	LDA	#STS
	JMP	GENERT		;call generate(sts)
	TYA
	JSR	GENERT		;call generate(y)
	LDA	#STD
	JMP	GENERT		;call generate(std)
;get$field
GETFLD	LDA	TYPESP		;get typesp
	CMP	#SIMVAR		;see if simple variable
	BNE	*+9		;skip if not
	LDA	SYMLSP
	LDY	SYMLSP+1
	JSR	LITERL		;call literal(symlocsp)
	BIT	INPSTM		;test inputstmt
	BPL	*+9		;branch if not
	LDA	#RES
	LDY	#RDV
	JMP	GENRDE		;call gen$read(res,rdv)
	BIT	FILEIO		;see if file io
	BPL	*+9		;branch if not
	LDA	#RDS
	LDY	#RDN
	JMP	GENRDE		;call gen$read(rds,rdn)
	LDA	#DRS
	LDY	#DRF
	JMP	GENRDE		;call gen$read(drs,drf)
;gen$on
GENON	LDA	#RON
	JSR	GENERT		;call generate(ron)
	INC	ONSP
	LDX	ONSP		;get as index
	LDA	ONSTAK,X	;get entry
	LDY	#0		;high always clear
	JSR	LITERL		;call(onstack(onsp:=onsp+1))
	LDA	#CKO
	JSR	GENERT		;call generate(cko)
	LDA	#BFN
	JMP	GENERT		;call generate(bfn)
;gen$on$2
GENON2	LDA	TYPESP
	LDX	ONSP
	STA	ONSTAK,X
	RTS
;gennext
GENNXT	DEC	FORCNT		;drop forcount
	LDA	FORCNT		;get it
	CMP	#255		;see if wrap
	BNE	*+9		;branch if ok
	INC	FORCNT		;set to 0
	LDA	#16		;next w/o for error
	JMP	ERROR
	LDA	#BRS
	JSR	GENERT		;call generate(brs)
	LDY	#2*2		;word addressing
	LDA	(NXSTPT),Y	;get low
	PHA			;save
	INY
	LDA	(NXSTPT),Y	;get high
	TAY			;move to Y
	PLA			;get low
	JSR	GENTWO		;call gen$two(nextaddress(2))
	LDY	#0*2		;still word addressing
	LDA	CODESI
	STA	(NXSTPT),Y	;put
	INY
	LDA	CODESI+1	;do high
	ORA	#$80		;set msb
	STA	(NXSTPT),Y	;insert
GENNX0	LDY	#1		;set index to 1
	LDA	(NXSTPT),Y	;get nextbytev(1)
	BMI	*+3		;continue if > 127
	RTS
	CLC			;now add 8 to nextstmtptr
	LDA	NXSTPT
	ADC	#8
	STA	NXSTPT
	BCC	GENNX0
	INC	NXSTPT+1
	JMP	GENNX0
;gen$next$with$ident
GENWID	LDA	MPP1		;get mpp1
	JSR	LKONLY
	BEQ	GENWIE		;branch if false
	LDY	#3*2		;word addressing
	LDA	(NXSTPT),Y	;get low
	CMP	BASE		;compare to low base
	BNE	GENWIE		;error if different
	INY
	LDA	(NXSTPT),Y	;same for high
	CMP	BASE+1
	BNE	GENWIE
	JMP	GENNXT		;else ok
GENWIE	LDA	#14		;next does not match for
	JMP	ERROR
;check$ul$error
CHKULE	BIT	ULERFL		;test flag
	BPL	*+7		;branch if clear
	LDA	#20		;else undefined label
	JSR	ERROR
	LDA	#FALSE		;now clear flag
	STA	ULERFL
	RTS
;findlabel
FNDLBL	LDA	SP		;get sp
	JSR	NRMLKU		;normal$lookup(sp)
	BNE	*+3		;if true
	RTS
	BIT	PASS2		;if pass2
	BMI	*+3		;then
	RTS
	JSR	GETRES		;if not getres
	BEQ	*+3		;then
	RTS
	LDA	#TRUE
	STA	ULERFL		;ulerrorflag=true
	RTS
;resolve$label
RESLBL	JSR	FNDLBL		;findlabel
	LDA	#PRO		;preset for true
	BIT	GSBSTM		;test gosubstmt
	BMI	*+4		;if true
	LDA	#BRS		;else
	JSR	GENERT		;generate( )
	JSR	GETADR
	JMP	GENTWO		;gen$two(getaddr)
;process$simple$variable
PSIMPV	JSR	NRMLKU		;normal$lookup
	BEQ	PSIMP0		;if false then
	JSR	GETTYP		;if getype
	CMP	#SIMVAR		;= simvar
	BEQ	PSIMP1		;then
	LDA	#11		;array name used as simple variable
	JSR	ERROR
	JMP	PSIMP1		;continue
PSIMP0	JSR	CNTPRT
	JSR	SETRSV		;setaddr(countprt)
	LDA	#SIMVAR
	JSR	SETTYP		;setype(simvar)
PSIMP1	JSR	GETADR
	STA	SYMLSP
	STY	SYMLSP+1	;symlocsp=getaddr
	JSR	STSLSP		;setsymlocsp( )
	LDA	#SIMVAR
	JSR	STTYSP		;settypesp(simvar)
	BIT	FORSTM		;if forstmt
	BMI	*+3		;then
	RTS
	LDA	#FALSE
	STA	FORSTM		;forstmt=false
	LDY	#3*2		;word addressing
	LDA	BASE
	STA	(SBTTOP),Y
	INY
	LDA	BASE+1
	STA	(SBTTOP),Y	;foraddress(3)=base
	RTS
;gen$ils
GENILS	STA	WHERE
	STY	WHERE+1		;save parameter
	LDA	#STRING
	JSR	STSTSP		;setstypesp(string)
	LDA	#ILS
	JSR	GENERT		;generate(ils)
GENIL0	LDA	#1
	STA	STRPTR		;strptr=1
GENIL1	LDY	#0
	LDA	(WHERE),Y	;if stringtospool(0)
	CMP	STRPTR		;< strptr
	BCC	GENIL2		;then
	LDY	STRPTR
	LDA	(WHERE),Y	;stringtospool(strptr)
	JSR	GENERT		;generate
	INC	STRPTR		;strptr=strptr+1
	JMP	GENIL1
GENIL2	BIT	CONT		;if not cont
	BPL	*+8		;then
	JSR	SCANNR		;scanner
	JMP	GENIL0
	LDA	#0
	JMP	GENERT		;generate(0)
;gencon
GENCON	LDA	#CON
	JSR	GENERT		;generate(con)
	LDA	#CONST
	JSR	STTYSP		;settypesp(const)
	LDA	#FLOTPT
	JSR	STSTSP		;setstypesp(floatpt)
	LDA	SP
	JSR	LKONLY		;lookup$only(sp)
	BEQ	GENCO0		;if false then
	JSR	GETTYP		;if getype
	CMP	#CONST		;<> const
	BNE	GENCO0		;then
	JSR	GETADR
	JMP	GENTWO		;gen$two(getaddr)
GENCO0	LDA	#1
	STA	IGEN		;igen=1
GENCO1	LDA	ACCLEN
	CMP	IGEN		;if igen>acclen
	BCC	GENCO2		;then
	LDX	IGEN
	LDA	ACCUM,X
	JSR	EMITCN		;emitcon(accum(i))
	INC	IGEN		;i=i+1
	JMP	GENCO1
GENCO2	LDA	#'$'
	JSR	EMITCN		;emitcon('$')
	INC	FDACT
	BNE	*+4
	INC	FDACT+1		;fdact=fdact+1
	LDA	FDACT
	LDY	FDACT+1
	JMP	GENTWO		;gen$two(fdact)
;put$field
PUTFLD	BIT	FILEIO		;if not fileio
	BPL	NTFLIO		;then
	LDA	STYPSP		;if stypesp
	CMP	#FLOTPT		;<> floatpt
	BNE	*+7		;then
	LDA	#WRN
	JMP	GENERT		;generate(wrn)
	LDA	#WRS
	JMP	GENERT		;generate(wrs)
NTFLIO	LDA	STYPSP		;if stypesp
	CMP	#FLOTPT		;= floatpt
	BEQ	*+7		;then
	LDA	#WST
	JMP	GENERT		;generate(wst)
	LDA	TYPESP		;if typesp
	CMP	#74		;not a tab
	BNE	*+3		;then
	RTS
	LDA	#WRV
	JMP	GENERT		;generate(wrv)
;gen$parm
GENPRM	LDA	TYPEMP
	CMP	#UNFUNC		;if typemp = unfunc
	BEQ	*+3		;then
	RTS
	LDA	SYMLMP
	LDY	SYMLMP+1
	STA	BASE
	STY	BASE+1		;base=symlocmp
	JSR	NXTENT		;nextentry
	LDA	BASE
	LDY	BASE+1
	JSR	STSLMP		;setsymlocmp(base)
	DEC	HASHMP
	LDA	HASHMP
	JSR	STHAMP		;sethashmp(hashmp:=hashmp-1)
	JSR	GETADR
	JMP	LITERL		;literal(getaddr)
;checkparm
CHKPRM	LDA	TYPEMP
	CMP	#UNFUNC		;if typemp <> unfunc
	BNE	NTUNFN		;then
	LDA	SYMLMP
	LDY	SYMLMP+1
	STA	BASE
	STY	BASE+1		;base=symlocmp
	JSR	GETSUB		;getsubtype
	CMP	STYPM1		;if = stypemp1
	BEQ	*+7		;then
	LDA	#5		;else invalid parameter type in function ref
	JSR	ERROR
	JMP	GENSTR		;gen$store
NTUNFN	LDA	#1
	LDY	STYPM1		;if stypemp1
	CPY	#FLOTPT		;<> floatpt
	BNE	*+4		;then
	LDA	#FALSE
	EOR	HASHMP		;xor hashmp
	AND	#1		;test lsb only
	BEQ	*+7		;if true
	LDA	#5		;invalid type in function parameter list
	JSR	ERROR
	LDA	HASHMP
	LSR	A		;shr(hashmp,1)
	JSR	STHAMP		;sethashmp
	DEC	STYPMP
	LDA	STYPMP
	JMP	STSTMP		;setstypemp(stypemp=stypemp-1)
;funcgen
FNCGEN	LDA	TYPEMP
	CMP	#UNFUNC		;if typemp <> unfunc
	BNE	NOFNGN		;then
	LDA	HASHMP		;if hashmp=0
	BEQ	*+7		;then
	LDA	#4		;incorrect number parameters
	JSR	ERROR
	LDA	#PRO
	JSR	GENERT		;generate(pro)
	LDA	SRLOSP
	LDY	SRLOSP+1
	STA	BASE
	STY	BASE+1		;base=srlocsp
	JSR	GETADR
	JMP	GENTWO		;gen$two(getaddr)
NOFNGN	LDA	STYPMP
	AND	#3		;if stypemp and 3 = 0
	BEQ	*+7		;then
	LDA	#4		;incorrect number parameters
	JSR	ERROR
	LDA	TYPEMP
	JSR	GENERT		;generate(typemp)
	LDA	STYPMP
	AND	#%01000000	;if not rol(stypemp,2)
	BEQ	*+7		;then
	LDA	#STRING
	JMP	STSTMP		;setstypemp(string)
	LDA	#FLOTPT
	JMP	STSTMP		;setstypemp(floatpt)
;enter$parm
ENTRPR	BIT	PASS1		;if pass 1
	BMI	*+3		;then
	RTS
	LDA	MPP1
	JSR	STLKUP		;setlookup(mpp1)
	JSR	ENTER
	JSR	CNTPRT
	JSR	SETRSV		;setaddr(countprt)
	LDA	STYPM1
	JSR	SETSUB		;setsubtype(stypemp1)
	LDA	#SIMVAR
	JSR	SETTYP		;setype(simvar)
	LDX	TYPEMP
	INX
	TXA
	JMP	STTYMP		;settypemp(typemp+1)
;synthesis
;main code generation routine
SYNTHE	STA	PRODCT		;save production
	LDA	PASS2		;if not pass 2
	AND	LSTPRD		;and listprod
	BEQ	NPPROD		;then
	LDA	#<PRDMSG
	LDY	#>PRDMSG
	JSR	PRNMSG		;print message
	LDA	PRODCT
	LDY	#0
	JSR	PRNDEC		;print number
	JSR	CRLF
NPPROD	JSR	SCOPY		;set up simple variables
	LDA	PRODCT		;get number
	ASL	A		;make word index
	TAX			;make index
	BCS	GT127		;branch if > 127
	LDA	PRODL,X
	STA	JPROD+1
	LDA	PRODL+1,X
	STA	JPROD+2		;set address
JPROD	JMP	$FFFF		;do it
GT127	LDA	PRODH,X
	STA	JPROD+1
	LDA	PRODH+1,X
	STA	JPROD+2
	JMP	JPROD		;same for high
;production jump table for 0 - 127
PRODL	.word	PRN,PRN,PR2,PR3,CHKULE,CHKULE,PRN,PRN
	.word	PRN,PRN,PRN,PRN,PRN,PRN,PRN,PRN
	.word	PRN,PRN,PRN,PRN,PRN,PRN,PRN,PRN
	.word	PRN,PRN,PRN,PRN,PRN,PRN,PR30,PR31
	.word	PRN,PR33,PR34,PR35,PRN,PR37,PRN,PR39
	.word	PRN,PR41,PRN,PR43,PR44,CHKTY3,PR46,PRN
	.word	PR48,PR49,PRN,PR51,PR52,PRN,PRN,PR55
	.word	PR56,PR57,PR58,CHKTY5,PR60,FNCGEN,GENPRM,PR63
	.word	PR64,PR65,GENCON,PR67,PR68,PR69,PR69,PR71
	.word	PR71,PR73,PR74,PR75,PR75,PR77,PR78,PR79
	.word	PR80,PR81,PR82,PR82,PR84,PRN,RESLBL,PR87
	.word	PR88,PR89,PR90,ENTRPR,PR92,PR92,ENTRPR,PRN
	.word	PRN,PRN,PR98,CHKTY4,PR100,PRN,SUBCAL,SUBCAL
	.word	PR104,PR105,CHKTY5,PRN,PR108,PR108,PR110,PRN
	.word	PR112,PR113,SEINPU,GETFLD,GETFLD,PR117,PRN,PR119
	.word	PUTFLD,PUTFLD,PRN,PUTFLD,PUTFLD,PRN,PR126,PR127
;production jump table for 128 - 255
PRODH	.word	PR128,PRN,PR130,RESLBL,GENON2,PR133,GENON,PR135
	.word	PR136,PR137,PR138,PRN,PRN,PRN,PRN,GENWID
	.word	GENNXT,PRN,GENWID,PR147,PR148,PR149,PR150,PR151
	.word	PR152
;productions not already defined by single no-parameter subroutines
PRN	RTS			;do nothing - used a lot !!!!
;2	<line number>::=<number>
PR2	LDA	SP
	JSR	LKONLY		;lookup$only(sp)
	BEQ	PR2D		;if false
	JSR	GETRES		;see if resolved
	BEQ	PR2C		;if not
	JSR	GETADR		;getaddr
	CMP	CODESI		;try low
	BNE	PR2A		;error if <>
	CPY	CODESI+1
	BEQ	*+7		;ok if same
PR2A	LDA	#0		;duplicate labels
	JSR	ERROR
	JMP	LINENU
PR2C	LDA	CODESI
	LDY	CODESI+1
	JSR	SETRSV		;setaddr(codesize)
	LDA	#LABLE
	JSR	SETTYP		;setype(lable)
	JMP	LINENU
PR2D	LDA	#'*'
	STA	SEPRTR		;separator=astrik
	JMP	LINENU
;3	|
PR3	LDA	#':'		;set separator
	STA	SEPRTR
	JMP	LINENU		;then do line number
;30	<assignmemt>::=<assign head><expression>
PR30	JSR	CHKTY2		;if not chktyp2
	BEQ	*+5		;then
	JMP	GENSTR		;else gen$store
	RTS
;31	<assign head>::=<variable>=
PR31	LDA	TYPEMP
	CMP	#SIMVAR		;if typemp=simvar
	BEQ	*+3		;then
	RTS
	LDA	SYMLMP
	LDY	SYMLMP+1
	JMP	LITERL		;literal(symlocmp)
;33	|<expression><or><logical factor>
PR33	JSR	CHKTY1		;if chktyp1
	BNE	*+3		;then
	RTS
	LDA	TYPEM1
	JMP	GENERT		;generate(typemp1)
;34	<or>::=or
PR34	LDA	#BOR
	JMP	STTYSP		;settypesp(bor)
;35	|xor
PR35	LDA	#EXR
	JMP	STTYSP		;sttysp
;37	<logical secondary>
PR37	JSR	CHKTY1		;if chktyp1
	BNE	*+3		;then
	RTS
	LDA	#ANDO
	JMP	GENERT		;generate(ando)
;39	|not <logical primary>
PR39	JSR	CHKTY3		;if chktyp3
	BNE	*+3		;then
	RTS
	LDA	#NOT
	JMP	GENERT		;generate(not)
;41	<arithmetic expression>
PR41	JSR	CHKTY2		;if chktyp2
	BNE	*+3		;then
	RTS
	LDA	STYPSP
	CMP	#FLOTPT		;if stypesp<>floatpt
	BNE	PR41A		;then
	LDA	TYPEM1
	JMP	GENERT		;generate(typemp1)
PR41A	CLC
	LDA	TYPEM1
	ADC	#16
	JSR	GENERT		;generate(typemp1+16)
	LDA	#FLOTPT
	JMP	STSTMP		;setstypemp(floatpt)
;43	|<arithmetic expression>+<term>
PR43	JSR	CHKTY2		;if chktyp2
	BNE	*+3		;then
	RTS
	LDA	#FAD
	LDY	STYPSP
	CPY	#FLOTPT		;if stypesp=floatpt
	BEQ	*+4		;then generate(fad)
	LDA	#CAT
	JMP	GENERT		;else generate(cat)
;44	|<arithmetic expression>-<term>
PR44	JSR	CHKTY1		;if chktyp1
	BNE	*+3		;then
	RTS
	LDA	#FMI
	JMP	GENERT		;generate(fmi)
;46	|-<term>
PR46	JSR	CHKTY3		;if chktyp3
	BNE	*+3		;then
	RTS
	LDA	#NEG
	JMP	GENERT		;generate(neg)
;48	|<term>*<primary>
PR48	JSR	CHKTY1		;if chktyp1
	BNE	*+3		;then
	RTS
	LDA	#FMU
	JMP	GENERT		;generate(fmu)
;49	|<term>/<primary>
PR49	JSR	CHKTY1		;if chktyp1
	BNE	*+3		;then
	RTS
	LDA	#FDI
	JMP	GENERT		;generate(fdi)
;51	|<primary>**<element>
PR51	JSR	CHKTY1		;the chktyp1
	BNE	*+3		;then
	RTS
	LDA	#EXP
	JMP	GENERT		;generate(exp)
;52	<element>::=<variable>
PR52	LDA	TYPESP		;if typesp
	CMP	#SIMVAR		;= simvar
	BEQ	*+7		;then
	LDA	#LOD
	JMP	GENERT		;else generate(lod)
	LDA	SYMLSP
	LDY	SYMLSP+1
	JMP	LITLOD		;litload(symlocsp)
;55	|(<expression>)
PR55	LDA	STYPM1
	JMP	STSTMP		;setstypemp(stypemp1)
;56	<variable>::=<identifier>
PR56	LDA	SP
	JMP	PSIMPV		;process$simple$variable(sp)
;57	|<subscript head><expression>
PR57	BIT	FORSTM		;if not forstmt
	BPL	*+7		;then
	LDA	#3		;for index not simple variable
	JSR	ERROR
	JSR	CHKTY5		;chktyp5
	LDA	SYMLMP
	LDY	SYMLMP+1
	STA	BASE
	STY	BASE+1		;base=symlocsp
	JSR	GETSUB		;if getsubtype
	CMP	TYPEMP		;= typemp
	BEQ	*+7		;then
	LDA	#17		;incorrect number subscripts
	JSR	ERROR
	JSR	GETADR
	JSR	LITLOD		;litload(getaddr)
	LDA	#SUB
	JSR	GENERT		;generate(subo)
	LDA	#SUBVAR
	JMP	STTYMP		;settypemp(subvar)
;58	<subscript head>::=<identifier>(
PR58	LDA	MP
	JSR	LKONLY		;lookup$only(mp)
	BEQ	PR58A		;if not then error
	JSR	GETTYP		;if getype
	CMP	#SUBVAR		;= subvar
	BEQ	*+7		;then ok
PR58A	LDA	#10		;subscripted variable not dimensioned
	JSR	ERROR
	LDA	#0
	JSR	STTYMP		;settypemp(0)
	LDA	BASE
	LDY	BASE+1
	JMP	STSLMP		;setsymlocmp(base)
;60	<function call>::=<function heading><expression>
PR60	JSR	CHKPRM		;checkparm
	LDA	SRLOMP
	LDY	SRLOMP+1
	STA	SRLOSP
	STY	SRLOSP+1	;srlocsp=srlocmp
	JMP	FNCGEN		;funcgen
;63	|<function heading><expression>
PR63	JSR	CHKPRM		;check$parm
	JMP	GENPRM		;gen$parm
;64	<function name>::=<user defined name>
PR64	LDA	SP
	JSR	LKONLY		;if lookup$only(sp)
	BNE	*+7		;then
	LDA	#6		;function undefined
	JMP	ERROR
	LDA	BASE
	LDY	BASE+1
	JSR	STSRSP		;setsrlocsp(base)
	LDA	BASE
	LDY	BASE+1
	JSR	STSLSP		;setsymlocsp(base)
	LDA	#UNFUNC
	JSR	STTYSP		;settypesp(unfunc)
	JSR	GETTYP
	JMP	STHASP		;sethashsp(getype)
;65	|<predefined name>
PR65	LDA	FUNCOP
	JSR	STTYSP		;settypesp(funcop)
	LDA	STYPSP
	LSR	A
	LSR	A		;shr(stypesp,2)
	AND	#7
	JMP	STHASP		;sethashsp( )
;67	|<string>
PR67	LDA	#<ACCUM
	LDY	#>ACCUM
	JMP	GENILS		;gen$ils(.accum)
;68	<relation>::= =
PR68	LDA	#7
	JMP	STTYSP		;settypesp(7)
;69	| >= | GE
PR69	LDA	#9
	JMP	STTYMP		;settypemp(9)
;71	| <= | LE
PR71	LDA	#10
	JMP	STTYMP		;settypemp(10)
;73	| >
PR73	LDA	#6
	JMP	STTYSP		;settypesp(6)
;74	| <
PR74	LDA	#5
	JMP	STTYSP		;settypesp(5)
;75	| <> | NE
PR75	LDA	#8
	JMP	STTYMP		;settypemp(8)
;77	<for statement>::=<for head> to <expression> <step clause>
PR77	LDY	#3*2		;word addressing
	LDA	(SBTTOP),Y
	STA	BASE
	INY
	LDA	(SBTTOP),Y
	STA	BASE+1		;base=foraddress(3)
	LDA	TYPESP		;if not typesp
	LSR	A
	BCC	*+7		;then
	LDA	#DUP
	JSR	GENERT		;generate(dup)
	JSR	GETADR
	JSR	LITLOD		;litload(getaddr)
	LDA	#FAD
	JSR	GENERT		;generate(fad)
	LDA	TYPESP		;if not
	LSR	A		;typesp
	BCC	PR77A		;then
	JSR	GETADR
	JSR	LITERL		;literal(getaddr)
	LDA	#XCH
	JSR	GENERT		;generate(xch)
PR77A	LDA	#STO
	JSR	GENERT		;generate(sto)
	LDA	TYPESP		;if not
	LSR	A		;typesp
	BCC	PR77B		;then
	LDA	#XCH
	JSR	GENERT		;generate(xch)
	LDA	#0
	TAY
	JSR	LITERL		;literal(0)
	LDA	#LSS
	JSR	GENERT		;generate(lss)
	LDA	#5
	LDY	#0
	JSR	LITERL		;literal(5)
	LDA	#BFC
	JSR	GENERT		;generate(bfc)
	LDA	#LEQ
	JSR	GENERT		;generate(leq)
	LDA	#2
	LDY	#0
	JSR	LITERL		;literal(2)
	LDA	#BFN
	JSR	GENERT		;generate(bfn)
PR77B	LDA	#GEQ
	JSR	GENERT		;generate(beq)
	LDA	#BRC
	JSR	GENERT		;generate(brc)
	LDY	#0*2		;word address
	LDA	(SBTTOP),Y
	PHA
	INY
	LDA	(SBTTOP),Y
	TAY
	PLA
	JSR	GENTWO		;gen$two(foraddress(0))
	LDY	#1*2		;word addressing
	LDA	CODESI
	STA	(SBTTOP),Y
	INY
	LDA	CODESI+1
	STA	(SBTTOP),Y	;foraddress(1)=codesize
	RTS
;78	<for head>::=<for><assignment>
PR78	LDA	#BRS
	JSR	GENERT		;generate(brs)
	LDY	#1*2		;word addressing
	LDA	(SBTTOP),Y
	PHA
	INY
	LDA	(SBTTOP),Y
	TAY
	PLA
	JSR	GENTWO		;gen$two(foraddress(1))
	LDY	#2*2		;word addressing
	LDA	CODESI
	STA	(SBTTOP),Y
	INY
	LDA	CODESI+1
	STA	(SBTTOP),Y	;foraddress(2)=codesize
	RTS
;79	<for>::= for
PR79	LDA	#TRUE
	STA	FORSTM		;forstmt=true
	SEC
	LDA	SBTTOP
	SBC	#8
	STA	SBTTOP
	STA	NXSTPT
	LDY	SBTTOP+1
	BCS	*+3
	DEY
	STY	SBTTOP+1
	STY	NXSTPT+1	;sbtbltop,nextstmtptr=sbtbltop-8
	LDY	#1
	LDA	(NXSTPT),Y
	AND	#$7F
	STA	(NXSTPT),Y	;nextbytev(1)=nextbytev(1) and $7f
	LDA	#0
	JSR	LIMITS		;limits(0)
	INC	FORCNT		;forcount=forcount+1
	RTS
;80	<step clause>::= step <expression>
PR80	LDA	#1
	JMP	STTYMP		;settypemp(true)
;81	|
PR81	LDY	#3*2		;word addressing
	LDA	(SBTTOP),Y
	STA	BASE
	INY
	LDA	(SBTTOP),Y
	STA	BASE+1		;base=foraddress(3)
	JSR	GETADR
	JSR	LITERL		;literal(getaddr)
	LDA	#FALSE
	JSR	STTYSP		;settypesp(false)
	LDA	#CON
	JSR	GENERT		;generate(con)
	LDA	#0
	TAY
	JMP	GENTWO		;gen$two(0)
;82	<if statement>::=<if group>
PR82	LDA	#0
	JMP	ENCMLB		;enter$compiler$label(0)
;84	| if end # <expression> then <number>
PR84	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#DEF
	JSR	GENERT		;generate(def)
	JSR	FNDLBL		;findlabel
	JSR	GETADR
	JMP	GENTWO		;gen$two(getaddr)
;87	<if else group>::=<if head><statement list> else
PR87	LDA	#3
	JSR	ENCMLB		;emter$compiler$label(3)
	LDA	#BRS
	JSR	GENERT		;generate(brs)
	JMP	COMLBL		;compiler$label
;88	<if head>::=if <expression> then
PR88	LDA	STYPM1		;if stypemp1
	CMP	#STRING		;<> string
	BNE	*+7		;then
	LDA	#8		;else if expression is not floating point
	JSR	ERROR
	LDA	#BRC
	JSR	GENERT		;generate(brc)
	JMP	COMLBL		;compiler$label
;89	<dummy argument list>::=<expresssion>
PR89	JSR	CHKTY2		;if chkty2
	BNE	*+3		;the
	RTS
	LDA	SYMLMP
	LDY	SYMLMP+1
	STA	BASE
	STY	BASE+1
	LDA	TYPEM1
	JSR	SETTYP		;setype(typemp1)
	JSR	UNLINK
	LDA	#XCH
	JSR	GENERT		;generate(xch)
	LDA	#RTN
	JSR	GENERT		;generate(rtn)
	LDA	#0
	JMP	ENCMLB		;enter$compiler$label(0)
;90	(ud function name>::= def <user defined name>
PR90	LDA	#BRS
	JSR	GENERT		;generate(brs)
	JSR	COMLBL		;compiler$label
	LDA	SP
	JSR	NRMLKU		;normal$lookup(sp)
	PHA			;save result
	LDA	STYPSP
	JSR	STSTMP		;setstypemp(stypesp)
	LDA	BASE
	LDY	BASE+1
	JSR	STSLMP		;setsymlocmp(base)
	BIT	PASS1		;if pass 1
	BMI	*+6		;then
	PLA			;clear stack
	JMP	RELINK
	PLA			;if not flag
	BEQ	*+7		;then
	LDA	#2		;else function name previously defined
	JSR	ERROR
	LDA	CODESI
	LDY	CODESI+1
	JMP	SETRSV		;setaddr(codesize)
;92	|
PR92	LDA	#0
	JMP	STTYMP		;settypemp(0)
;98	<file decleration>::=<identifier><file rec size>
PR98	LDA	MP
	JSR	PSIMPV		;process$simple$variable(mp)
	LDA	STYPMP		;if stypemp
	CMP	#FLOTPT		;<> floatpt
	BNE	*+7		;then
	LDA	#23		;invalid type in file
	JSR	ERROR
	LDA	SYMLSP
	LDY	SYMLSP+1
	JSR	LITLOD		;litload(symlocsp)
	LDA	#OPN
	JMP	GENERT		;generate(opn)
;100	|
PR100	LDA	#0
	TAY
	JMP	LITERL		;literal(0)
;104	<dimension variable>::=<dim var head><expression>
PR104	JSR	CHKTY5		;chktyp5
	LDA	SYMLMP
	LDY	SYMLMP+1
	STA	BASE
	STY	BASE+1		;base=symlocsp
	RTS
;105	<dim var head>::=<identifier>(
PR105	LDA	MP
	JSR	NRMLKU		;if not normal$lookup(mp)
	BEQ	PR105A		;then
	BIT	PASS1		;if not pass 1
	BPL	PR105A		;then
	LDA	#1		;identifier in dim previously defined
	JSR	ERROR
PR105A	LDA	#SUBVAR
	JSR	SETTYP		;setype(subvar)
	BIT	PASS1		;if not pass 1
	BPL	*+8		;then
	JSR	CNTPRT
	JSR	SETRSV		;setaddr(countprt)
	JSR	GETADR
	JSR	LITERL		;literal(getaddr)
	LDA	#0
	JSR	STTYMP		;settypemp(0)
	LDA	BASE
	LDY	BASE+1
	JMP	STSLMP		;setsymlocmp(base)
;108	<close list>::=<expression>
PR108	LDA	STYPSP		;if stypesp
	CMP	#STRING		;<> string
	BNE	*+5		;then
	JSR	MFERR		;must be floating
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#CLS
	JMP	GENERT		;generate(cls)
;110	<read statement>::= read <file option><read list>
PR110	BIT	FILEIO		;if not fileio
	BPL	PR110A		;then
	LDA	#EDR
	JSR	GENERT		;generate(edr)
;117	|
PR117	LDA	#FALSE
	STA	FILEIO		;fileio=false
PR110A	RTS
;112	<input statement>::=input <prompt option><read list>
PR112	LDA	#ECR
	JSR	GENERT		;generate(ecr)
	LDA	#FALSE
	STA	INPSTM		;inputstmt=false
	RTS
;113	<prompt option>::=<constant>
PR113	JSR	PUTFLD		;put$field
	JMP	SEINPU		;setup$input
;119	|print <file option><file list>
PR119	LDA	#EDW
	JSR	GENERT		;generate(edw)
	LDA	#FALSE
	STA	FILEIO		;fileio=false
	RTS
;126	|
PR126	LDA	#DBF
	JMP	GENERT		;generate(dbf)
;127	<file option>::= # <expression>
PR127	LDA	#TRUE
	STA	FILEIO		;fileio=true
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#RDB
	JMP	GENERT		;generate(rdb)
;128	| # <expression>,<expression>;
PR128	LDA	#TRUE
	STA	FILEIO		;fileio=true
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#XCH
	JSR	GENERT		;generate(xch)
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#RDF
	JMP	GENERT		;generate(rdf)
;130	| ,
PR130	BIT	FILEIO		;if not fileio
	BPL	*+3		;then
	RTS
	LDA	#NSP
	JMP	GENERT		;generate(nsp)
;133	|<on gosub> <label list>
PR133	JSR	GENON2		;gen$on$2
	LDA	#0
	JMP	ENCMLB		;enter$compiler$label(0)
;135	<on gosub>::= on <expression> <gosub>
PR135	JSR	STCMLB		;set$compiler$label
	JSR	GETADR
	JSR	LITERL		;literal(getaddr)
	LDA	#ADJ
	JSR	GENERT		;generate(adj)
	LDA	#XCH
	JSR	GENERT		;generate(xch)
	JMP	GENON		;gen$on
;136	<label list>::=<number>
PR136	JSR	RESLBL		;resolve$label
	LDA	#1
	JMP	STTYSP		;settypesp(1)
;137	|<label list>,<number>
PR137	JSR	RESLBL		;resolve$label
	LDX	TYPEMP
	INX
	TXA
	JMP	STTYMP		;settypemp(typemp+1)
;138	<gosub statement>::=<gosub><number>
PR138	LDA	#TRUE
	STA	GSBSTM		;gosubstmt=true
	JSR	RESLBL		;resolve$label
	LDA	#FALSE
	STA	GSBSTM		;gosubstmt=false
	RTS
;147	<out statement>::= out <expression>,<expression>
PR147	LDA	#FLOTPT		;if stypemp1
	CMP	STYPM1		;<> floatpt
	BNE	*+6		;then
	CMP	STYPSP		;if stypesp = floatpt
	BEQ	*+5		;then ok
	JMP	MFERR		;must be floating error
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#XCH
	JSR	GENERT		;generate(xch)
	LDA	#RON
	JSR	GENERT		;generate(ron)
	LDA	#POT
	JMP	GENERT		;generate(pot)
;148	<return statement>::= return
PR148	LDA	#RTN
	JMP	GENERT		;generate(rtn)
;149	<stop statement>::= stop
PR149	LDA	#XIT
	JMP	GENERT		;generate(xit)
;150	<end statement>::= end
PR150	BIT	PASS1		;if not pass 1
	BPL	PR150B		;then
	LDA	#FALSE
	STA	PASS1		;pass1=false
	LDA	FORCNT		;if forcount
	BEQ	PR150A		;= zero then ok
	LDA	#24		;else for without next error
	JSR	ERROR
	LDA	#0
	STA	FORCNT		;forcount=0
PR150A	LDA	#'*'
	JSR	GENERT		;generate('*')
	CLC
	LDA	CODESI
	LDY	CODESI+1
	ADC	#3
	BCC	*+3
	INY
	AND	#$FC
	JSR	GENTWO		;gen$two((codesize+3) and $fffc)
	LDA	DATACT
	LDY	DATACT+1
	JSR	GENTWO		;gen$two(datact)
	JSR	CNTPRT
	JMP	GENTWO		;gen$two(countprt)
PR150B	LDA	NXTCHR
	CMP	#CR
	BEQ	*+8
	JSR	GETCHR
	JMP	PR150B		;while not eol
	LDA	#XIT
	JSR	GENERT		;generate(xit)
	LDA	#$7F
	JSR	GENERT		;generate($7f)
	JSR	WRTINT		;write$int$file
	JSR	CLSINT		;close$int$file
	LDA	ERRCNT
	LDY	ERRCNT+1
	JSR	PRNDEC		;printdec(errorcount)
	LDA	#<ERDMSG
	LDY	#>ERDMSG
	JSR	PRNMSG		;print('errors detected')
	JSR	CRLF
	JMP	BOOT
;151	<restore statement>::= restore
PR151	LDA	#RST
	JMP	GENERT		;generate(rst)
;152	<randomize statement>::= randomize
PR152	LDA	#IRN
	JMP	GENERT		;generate(irn)
;getin1  (does ay=index1(state))
GETIN1	LDA	STATE
	LDY	STATE+1		;get state
	ASL	A
	TAX
	TYA
	ROL	A
	TAY
	CLC
	TXA
	ADC	#<INDEX1	;add state*2 since is word addressing
	STA	GT+1
	TYA
	ADC	#>INDEX1
	STA	GT+2
	LDX	#0
	JSR	GT		;get low
	PHA
	INX
	JSR	GT		;get high
	TAY
	PLA
	RTS
;general purpose lda abs,x routine
GT	LDA	$FFFF,X
	RTS
;getin2 (does ay=index2(state))
GETIN2	LDA	STATE
	LDY	STATE+1
	CLC
	ADC	#<INDEX2
	STA	G2+1
	TYA
	ADC	#>INDEX2
	STA	G2+2
G2	LDA	$FFFF
	LDY	#0		;y always zero
	RTS
;incsp
INCSP	INC	SP
	LDA	SP		;bump and get
	CMP	#PSTKSZ		;compare to max
	BEQ	*+3		;if = then
	RTS			;else ok
	LDA	#18		;stack overflow error
	JMP	ERROR
;lookahead
LAHEAD	BIT	NOLOOK		;if not nolook
	BPL	LAHEAX		;then done
	JSR	SCANNR		;scanner
	LDA	#FALSE
	STA	NOLOOK		;nolook=false
LAHEAX	RTS
;set$varc$i ---- set varc and increment varindex
STVRCI	LDX	VARIND
	STA	VARC,X		;save
	INX
	STX	VARIND		;bump index
	CPX	#VARCSZ+1	;if too big
	BCS	*+3		;then error
	RTS
	LDA	#21		;varc overflow
	JMP	ERROR
;initialize all of system
INTLZ	JSR	INSYMT		;in$symtbl
	JSR	INSYN		;in$syn
	JMP	INSCAN
;MAIN PROGRAM
MAIN	LDX	#2		;clear page zero
	LDA	#0
PZC	STA	0,X
	INX
	CPX	#LZ
	BNE	PZC
	LDA	#TRUE		;initialize once
	STA	PASS1
	STA	LWRUPR
	LDA	#':'
	STA	SEPRTR
	LDA	#SRCRSZ
	STA	SRCIND
	LDA	#<OPNMSG
	LDY	#>OPNMSG
	JSR	PRNMSG		;print opening message
	JSR	CRLF
	JSR	INTLZ		;initialize all
;do forever
;do while (pass1 or pass2)
M10	BIT	PASS1		;if pass 1
	BMI	M12		;then go
	BIT	PASS2		;or if
	BMI	M12		;pass2 go
	JMP	EWP1P2		;else end of do while pass1 or pass2
M12	LDA	#TRUE
	STA	NOLOOK		;nolook=true
	STA	CMPLNG		;compiling=true
	LDA	#<STARTS
	LDY	#>STARTS
	STA	STATE
	STY	STATE+1		;state=startstate
	LDA	#255
	STA	SP		;sp=255
	LDA	#0
	STA	VARIND		;varind=0
	STA	VAR
;do while compiling
M14	BIT	CMPLNG		;test for compiling
	BPL	M10		;branch if not
	LDA	#<MAXRNO
	CMP	STATE
	LDA	#>MAXRNO
	SBC	STATE+1		;if state>maxrno
	BCS	*+5		;continue if ok
	JMP	M30		;else try next
	JSR	INCSP
	LDA	SP
	ASL	A		;word addressing
	TAX
	LDA	STATE
	STA	STSTAK,X
	LDA	STATE+1
	STA	STSTAK+1,X	;statestack(sp)=state
	JSR	GETIN1
	STA	I
	STY	I+1		;i=getin1
	JSR	LAHEAD		;lookahead
	JSR	GETIN2		;index2(state)
	CLC
	ADC	I
	STA	J
	TYA
	ADC	I+1
	STA	J+1
	LDA	J
	BNE	*+4
	DEC	J+1
	DEC	J		;j=i-1+getin2
M20	LDA	J
	CMP	I
	LDA	J+1
	SBC	I+1		;if i>j
	BCC	M14		;go to while compiling
	CLC
	LDA	I
	ADC	#<READ1
	STA	I2
	LDA	I+1
	ADC	#>READ1
	STA	I2+1
	LDY	#0
	LDA	(I2),Y		;a=read(i)
	CMP	TOKEN		;if not token
	BNE	M23		;then
	LDA	VARIND		;get varindex
	LDX	SP
	STA	VAR,X		;set var(sp)
	LDX	#0
	STX	INDEX		;index=0
M22	LDA	ACCUM,X		;accum(index)
	JSR	STVRCI
	INC	INDEX		;index=index+1
	LDX	INDEX
	CPX	ACCLEN		;if < length
	BCC	M22		;then loop
	BEQ	M22		;loop also if equal
	LDX	SP
	LDA	HSHCDE
	STA	HASH,X		;hash(sp)=hashcode
	LDA	SUBTYP
	STA	STYPE,X		;stype(sp)=subtype
	LDA	I
	ASL	A
	STA	I2
	LDA	I+1
	ROL	A
	STA	I2+1		;i2=i*2
	CLC
	LDA	I2
	ADC	#<READ2
	STA	I2
	LDA	I2+1
	ADC	#>READ2
	STA	I2+1		;read2(i)
	LDY	#0
	LDA	(I2),Y		;low
	STA	STATE
	INY
	LDA	(I2),Y
	STA	STATE+1		;state=read2(i)
	LDA	#TRUE
	STA	NOLOOK		;nolook=true
	LDA	J
	LDY	J+1
	STA	I
	STY	I+1
	JMP	M24
M23	LDA	I
	CMP	J		;ok if different
	BNE	M24
	LDA	I+1
	CMP	J+1
	BNE	M24		;ok if different
	LDA	#15		;no legal production
	JSR	ERROR
M24	INC	I		;bump i and loop
	BNE	*+4
	INC	I+1
	JMP	M20
M30	LDA	#<MAXPNO	;if state <= maxpno
	CMP	STATE
	LDA	#>MAXPNO
	SBC	STATE+1
	BCC	*+5
	JMP	M40
	JSR	GETIN2		;index2(state)
	STA	I		;ignore high
	SEC
	LDA	SP
	SBC	I
	STA	MP		;mp=sp-getin2
	TAY
	INY
	STY	MPP1		;mpp1=mp+1
	SEC
	LDA	STATE
	SBC	#<MAXPNO	;parameter=state-maxpno
	JSR	SYNTHE		;synthesize(state-maxpno)
	BIT	CMPLNG		;if compiling
	BMI	*+5		;then go
	JMP	M10		;else go to do while pass 1 or pass 2
	LDA	MP
	STA	SP		;sp=mp
	JSR	GETIN1
	STA	I
	STY	I+1		;i=getin1
	LDX	SP
	LDA	VAR,X
	STA	VARIND		;varindex=var(sp)
	TXA
	ASL	A
	TAX			;word addressing
	LDA	STSTAK,X
	STA	J
	LDA	STSTAK+1,X
	STA	J+1		;j=statestack(sp)
M31	LDX	#0
	STX	K+1		;high must be zero
	LDX	I
	LDA	APPLY1,X
	STA	K
	BEQ	M33		;exit if k=0
	CMP	J
	BNE	M32		;ok if low k <> low j
	LDA	J+1
	BEQ	M33		;if =0 then j=k
M32	INC	I
	BNE	M31		;loop
	INC	I+1
	JMP	M31
M33	LDA	I		;ignore high i
	ASL	A
	STA	I2
	LDA	I+1
	ROL	A
	STA	I2+1
	CLC
	LDA	I2
	ADC	#<APPLY2
	STA	I2
	LDA	I2+1
	ADC	#>APPLY2
	STA	I2+1
	LDY	#0
	LDA	(I2),Y
	STA	STATE
	INY
	LDA	(I2),Y
	STA	STATE+1		;state=apply2(i)
	ORA	STATE
	BNE	*+7		;if not zero then
	LDA	#FALSE
	STA	CMPLNG		;compiling=false
	JMP	M14
M40	LDA	#<MAXLNO	;if state
	CMP	STATE
	LDA	#>MAXLNO
	SBC	STATE+1		;> maxlno
	BCC	M50		;then go to next
	JSR	GETIN1
	STA	I
	STY	I+1		;i=getin1
	JSR	LAHEAD		;lookahead
M41	LDX	#0
	STX	K+1
	CLC
	LDA	I
	ADC	#<LOOK1
	STA	I2
	LDA	I+1
	ADC	#>LOOK1
	STA	I2+1
	LDY	#0
	LDA	(I2),Y		;a=look1(i)
	STA	K
	BEQ	M42		;exit if k=0
	CMP	TOKEN
	BEQ	M42		;or if =token
	INC	I		;bump and loop
	BNE	M41
	INC	I+1
	JMP	M41
M42	LDA	I		;word addressing
	ASL	A
	STA	I2
	LDA	I+1
	ROL	A
	STA	I2+1
	CLC
	LDA	I2		;add start
	ADC	#<LOOK2
	STA	I2
	LDA	I2+1
	ADC	#>LOOK2
	STA	I2+1
	LDY	#0
	LDA	(I2),Y		;low
	STA	STATE
	INY
	LDA	(I2),Y
	STA	STATE+1
	JMP	M14
M50	JSR	INCSP
	JSR	GETIN2
	PHA			;save low
	LDA	SP
	ASL	A		;word addressing
	TAX
	PLA
	STA	STSTAK,X	;statestack(sp)=getin2
	TYA
	STA	STSTAK+1,X
	JSR	GETIN1
	STA	STATE
	STY	STATE+1		;state=getin1
	JMP	M14
;end of do while pass 1 or pass 2
EWP1P2	LDA	#TRUE
	STA	LSTSRC		;listsource=true
	JSR	INTLZ		;initialize
	LDA	#TRUE
	STA	PASS2		;pass2=true
	JMP	M10		;do forever
;parser state tables
READ1	.byte	0,49,10,13,2,49,50,52,53,54,49,13,22,32,2,3,7,27,30,49,50,52,53
	.byte	54,2,3,7,30,49,50,52,53,54,54,52,12,52,2,3,7,49,50,52,53,54,12
	.byte	52,49,49,50,2,3,7,12,30,49,50,52,53,54,2,2,2,9,5,9,49,4,8,49,16
	.byte	20,28,29,31,35,36,37,38,40,42,43,44,45,46,48,49,51,52,49,14,6
	.byte	22,13,52,9,52,9,23,9,21,33,41,16,21,33,36,43,9,21,33,5,9,21,33
	.byte	5,21,33,5,9,21,33,5,9,21,33,6,9,21,33,21,33,39,21,33,41,5,21,33
	.byte	6,21,33,9,6,9,16,17,20,25,26,27,28,29,31,35,36,37,38,40,42,43
	.byte	44,45,46,48,51,52,2,16,20,28,29,31,35,36,37,38,40,42,43,44,45
	.byte	46,48,51,52,52,13,24,11,34,9,2,1,3,7,10,13,15,18,19,3,7,9,0
LOOK1	.byte	0,49,0,10,13,0,13,0,11,23,34,0,52,0,12,52,0,49,50,0,6,9,11,23
	.byte	34,0,2,0,2,0,9,0,4,8,0,4,8,0,4,8,0,4,8,0,4,8,0,11,23,34,0,14,0
	.byte	14,0,14,0,9,0,9,0,9,0,9,0,9,0,21,33,0,21,33,0,21,33,0,21,33,0
	.byte	21,33,39,0,21,33,0,21,33,0,21,33,0,23,0,21,33,0,21,33,0,9,0,9
	.byte	0,6,9,0,52,0,11,23,0,11,23,34,0,2,0,11,23,0,52,0,24,0,24,0,11
	.byte	0,23,0,11,0,9,0,2,0,1,3,7,10,13,15,18,19,0,3,7,0,9,0
APPLY1	.byte	0,0,0,0,55,105,0,19,0,0,32,47,0,0,3,4,12,14,16,17,20,21,22,26
	.byte	27,34,36,38,40,98,100,102,103,114,116,0,0,46,0,28,0,33,0,63,0,5
	.byte	6,8,9,0,7,10,0,23,0,13,19,32,35,47,55,99,101,105,106,0,0,0,0,0
	.byte	39,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,0,0,0,0,99
	.byte	106,0,0,0,0,0,40,0,0,0,0,0,0,62,0,0,74,0,74,0,0,0,0,0,0,0,0,0
READ2	.word	0,191,264,260,3,255,256,129,254,253,326,258,329,331,3,5,8,31
	.word	33,255,256,129,254,253,3,5,8,33,255,256,129,254,253,279,42,21
	.word	129,3,5,8,255,256,129,254,253,20,129,273,255,256,3,5,8,20,33
	.word	255,256,129,254,253,247,294,4,335,280,283,320,7,10,327,24,26
	.word	268,32,34,285,328,125,126,338,38,330,127,128,337,340,275,341
	.word	129,325,23,302,27,220,130,17,131,13,190,14,223,224,277,24,223
	.word	224,328,330,12,223,224,246,248,223,224,244,223,224,249,252,223
	.word	224,293,295,223,224,316,16,223,224,223,224,36,223,224,37,288
	.word	223,224,317,223,224,15,318,319,24,25,26,29,30,339,268,32,34,285
	.word	328,125,126,338,38,330,127,128,337,340,341,129,251,24,26,268,32
	.word	34,285,328,125,126,338,38,330,127,128,337,340,341,129,45,22,28
	.word	124,276,286,282,122,6,9,123,257,259,261,265,6,9,11,0
LOOK2	.word	0,1,176,2,2,263,18,262,177,177,177,19,334,333,35,35,178,39,39
	.word	179,180,180,180,180,180,40,41,245,43,181,44,332,49,49,231,50,50
	.word	234,51,51,235,52,52,232,53,53,233,182,182,182,55,57,236,58,237
	.word	59,238,66,308,68,300,69,299,70,301,72,296,76,76,297,77,77,309
	.word	78,78,219,84,84,312,85,85,85,183,87,87,336,88,88,298,89,89,310
	.word	278,91,93,93,313,94,94,269,95,321,96,322,97,97,184,99,185,186
	.word	186,101,314,314,314,102,104,250,187,187,105,106,188,109,221,110
	.word	222,111,193,274,112,113,272,115,284,117,189,118,118,118,118,118
	.word	118,118,118,229,119,119,230,120,290
APPLY2	.word	0,0,161,71,169,170,168,199,198,200,218,267,201,98,80,90,151,152
	.word	92,155,83,86,154,74,150,75,156,146,147,148,149,153,82,79,81,73
	.word	46,167,166,226,225,228,227,174,173,133,135,134,136,132,139,140
	.word	138,240,239,305,64,64,304,64,64,304,64,64,304,241,114,243,116
	.word	163,60,242,63,202,61,47,266,194,271,164,137,197,172,108,107,204
	.word	65,171,287,196,175,292,291,103,205,145,206,210,165,143,144,142
	.word	207,159,141,307,100,160,162,208,213,56,62,158,157,209,323,48
	.word	324,54,203,67,216,212,211,195,214,215
INDEX1	.word	0,1,2,24,24,4,4,4,4,4,4,34,24,36,24,10,24,24,11,168,24,24,24,4
	.word	12,14,24,24,24,33,34,35,36,37,24,45,24,47,24,48,50,60,61,62,63
	.word	64,24,36,66,67,67,67,67,67,69,70,89,90,90,90,91,92,89,37,93,94
	.word	95,96,97,97,97,98,99,100,103,108,100,100,100,111,115,118,122
	.word	126,100,130,133,100,100,100,136,100,139,100,100,142,142,143,24
	.word	36,24,145,24,24,167,168,36,186,187,188,188,189,189,189,24,191
	.word	24,192,193,201,203,1,3,6,8,12,14,17,20,26,28,30,32,35,38,41,44
	.word	47,51,53,55,57,59,61,63,65,67,70,73,76,79,83,86,89,92,94,97,100
	.word	102,104,107,109,112,116,118,121,123,125,127,129,131,133,135,137
	.word	146,149,192,217,306,303,311,289,217,270,315,306,217,217,306,281
	.word	1,2,2,3,3,3,3,3,4,4,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,9,10,13
	.word	14,14,36,36,37,37,39,39,41,41,43,43,43,43,43,45,45,45,50,50,53
	.word	53,53,53,55,55,66,66,67,67,68,68,69,69,70,70,72,72,72,72,72,72
	.word	72,72,72,73,74,75,76,76,77,77,77,78,78,79,80,81,82,83,83,84,84
	.word	85,86,86,87,88,88,89,90,90,91,93,93,94,95,95,96,96,97,98,98,99
	.word	99,99,102,102,103,103,103,104,104,105,105,106,106,108,108,109
	.word	110,110,111,112,113,113,115,116,116,118,118,120,120,121,121,122
	.word	123,124,125,126,127
INDEX2	.byte	0,1,2,9,9,6,6,6,6,6,6,1,9,1,9,1
	.byte	9,9,1,18,9,9,9,6,2,10,9,9,9,1,1
	.byte	1,1,8,9,2,9,1,9,2,10,1,1,1,1,2
	.byte	9,1,1,2,2,2,2,2,1,19,1,1,1,1,1,1
	.byte	1,8,1,1,1,1,1,1,1,1,1,3,5,3,2,2
	.byte	2,4,3,4,4,4,2,3,3,2,2,2,3,2,3,2
	.byte	2,1,1,2,9,1,9,22,9,9,1,18,1,1,1
	.byte	1,1,1,2,1,9,1,9,1,8,2,1,2,3,2,4
	.byte	2,3,3,6,2,2,2,3,3,3,3,3,4,2,2,2
	.byte	2,2,2,2,2,3,3,3,3,4,3,3,3,2,3,3
	.byte	2,2,3,2,3,4,2,3,2,2,2,2,2,2,2,2
	.byte	9,3,2,1,19,35,39,40,43,55,85,97
	.byte	99,101,105,106,117,2,0,0,0,0,0,0
	.byte	0,0,2,0,0,0,0,0,0,0,0,0,0,0,0
	.byte	0,0,0,0,0,0,1,1,1,0,2,0,0,0,2,0
	.byte	1,0,2,0,2,2,1,1,0,2,2,0,2,0,0,0
	.byte	2,0,2,1,2,2,0,1,2,0,0,0,0,0,1,0
	.byte	1,0,0,0,1,0,3,1,0,1,0,0,1,5,1,1
	.byte	2,2,3,1,2,0,0,2,1,0,2,1,2,0,1,0
	.byte	2,2,1,2,1,0,2,2,1,2,1,0,0,2,0,2
	.byte	2,0,2,0,0,2,0,0,2,4,0,0,1,1,1,2
	.byte	2,0,2,1,0,1,0,1,1,0,0,2,3,0,0,0
	.byte	0,0
;reserved word tables
;length=1
LNG1	.byte	CR,"<(+*)-,=/",semico,">:#^"
;length=2
LNG2	.byte	"IFTOGOONOREQLTGTLEGENE"
;length=3
LNG3	.byte	"FORLETREMDIMDEFNOTAND"
	.byte	"TANSINCOSSQRTABLOGLEN"
	.byte	"FREATNABSEXPINTEND"
	.byte	"POSRNDSGNASCVALXORSUB"
;length=4
LNG4	.byte	"PEEKPOKE"
	.byte	"THENREADGOTOELSENEXTSTOPDATA"
	.byte	"FILECHR$MID$STEPSTR$CALLSINH"
;length=5
LNG5	.byte	"PRINTINPUTGOSUBCLOSELEFT$"
;length=6
LNG6	.byte	"RETURNRIGHT$REMARK"
;length=7
LNG7	.byte	"RESTORE"
;length=9
LNG9	.byte	"RANDOMIZE"
;token table
;this table must be ordered in the same order as the reserved word table.  the
;first entry does not correspond to any valid token.
TK	.byte	0
;length=1
	.byte	TCR,LESST,LPARN,TPLUS,ASTRK,RPARN,TMINUS,COMMA,EQUAL,SLASH
	.byte	SCOLN,GTRT,TCOLIN,POUND,EXPON
;length=2
	.byte	TIF,TTO,TGO,TON,TOR,EQUAL,LESST,GTRT,TLEQ,TGEQ,TNE
;length=3
	.byte	TFOR,TLET,TREM,TDIM,TDEF,TNOT,TAND,72,69,70,73,74,78,84,76,71
	.byte	65,75,66,TEND,79,67,68,81,88,TXOR,TSUB
;length=4
	.byte	80,TOUT
	.byte	TTHEN,TREAD,TGOTO,TELSE,TNEXT,TSTOP,TDATA,TFILE,82,85,TSTEP
	.byte	87,89,90
;length=5
	.byte	TPRNT,TINPT,TGOSB,TCLOS,83
;length=6
	.byte	TRETN,86,TREM
;length=7
	.byte	TREST
;length=9
	.byte	TIRN
;token offset table
OFFSET	.byte	0,0,15,37,118,182,207,225,232,232
;reserved word count table
;each entry is the number of reserved words of the associated length (0 and up)
COUNT	.byte	0,15,11,27,16,5,3,1,0,1
;each entry is the index into the token table for the first token of the
;associated length (0 and up)
TKOS	.byte	0,0,15,26,53,69,74,77,78,78
;
ST	.byte	1,1,0,1,1,1,1,1,1,1,1,0,0,1,0,1,5,65,70,5,71,70,65,5,1,1
;error messages
ERM0	.byte	"DUPLICATE LABELS OR "
	.byte	"SYNCHRONIZATION ERROR$"
ERM1	.byte	"IDENTIFIER IN DIM "
	.byte	"PREVIOUSLY DEFINED$"
ERM2	.byte	"PREDEFINED FUNCTION "
	.byte	"NAME PREVIOUSLY DEFINED$"
ERM3	.byte	"FOR LOOP INDEX NOT SIMPLE"
	.byte	" FLOATING POINT VARIABLE$"
ERM4	.byte	"INCORRECT NUMBER OF PARAMETERS"
	.byte	" IN FUNCTION REFERENCE$"
ERM5	.byte	"INVALID PARAMETER TYPE IN "
	.byte	"FUNCTION REFERENCE$"
ERM6	.byte	"UNDEFINED FUNCTION$"
ERM7	.byte	"INVALID CHARACTER$"
ERM8	.byte	"EXPRESSION IN IF STATEMENT"
	.byte	" NOT FLOATING POINT$"
ERM9	.byte	"ILLEGAL FLOATING POINT FORMAT$"
ERM10	.byte	"SUBSCRIPTED VARIABLE NOT "
	.byte	"PREVIOUSLY DIMENSIONED$"
ERM11	.byte	"ARRAY NAME USED AS SIMPLE"
	.byte	" VARAIBLE$"
ERM12	.byte	"STRING EXPRESSION NOT ALLOWED$"
ERM13	.byte	"MIXED MODE (STRING - FLOATING)"
	.byte	" EXPRESSION$"
ERM14	.byte	"NEXT VARIABLE DOES NOT "
	.byte	"MATCH FOR$"
ERM15	.byte	"NO PRODUCTION EXISTS$"
ERM16	.byte	"NEXT STATEMENT WITHOUT "
	.byte	"MATCHING FOR$"
ERM17	.byte	"INCORRECT NUMBER OF "
	.byte	"SUBSCRIPTS$"
ERM18	.byte	"COMPILER STACK OVERFLOW$"
ERM19	.byte	"SYMBOL TABLE OVERFLOW$"
ERM20	.byte	"UNDEFINED LABEL$"
ERM21	.byte	"VARC TABLE OVERFLOW$"
ERM22	.byte	"UNTERMINATED STRING$"
ERM23	.byte	"INVALID TYPE IN FILE"
	.byte	" IDENTIFIER$"
ERM24	.byte	"FOR WITHOUT MATCHING NEXT$"
;error message table
ERMTBL	.word	ERM0,ERM1,ERM2,ERM3,ERM4,ERM5,ERM6,ERM7
	.word	ERM8,ERM9,ERM10,ERM11,ERM12,ERM13,ERM14,ERM15
	.word	ERM16,ERM17,ERM18,ERM19,ERM20,ERM21,ERM22,ERM23
	.word	ERM24
;messages and strings
PRDMSG	.byte	"PROD $"
ERDMSG	.byte	" ERRORS DETECTED$"
DEMSG	.byte	"DISK ERROR - ABORTING $"
BASSTR	.byte	"BAS"
NSMSG	.byte	"NO SOURCE - ABORTING $"
ADDEND	.byte	"END",CR,LF
OPNMSG	.byte	"BASIC-E/65 COMPILER - "
	.byte	"VERSION 2.03-A$"
;variables - this area holds data moved from page zero to save page zero space
pass1	.byte	0		;pass 1 if true i=TRUE
pass2	.byte	0		;pass 2 if true
LSTPRD	.byte	0		;list production if true (listprod)
LSTSRC	.byte	0		;list source if true (listsource)
DEBUGL	.byte	0		;debug line numbers if true (debugln)
LWRUPR	.byte	0		;convert if true i=TRUE (lowertoupper)
NINTFL	.byte	0		;no .INT file if true (nointfile)
LSTFLG	.byte	0		;list device if false (lstflag)
EOLSTS	.byte	0		;flag that eol (cr) read by scan
CMPLNG	.byte	0		;compiling if true (compiling)
FORSTM	.byte	0		;for statement flag (forstmt)
FILEIO	.byte	0		;file i/o flag
;next variable is never read or tested - need to check need
RNDFLE	.byte	0		;random file flag (randomfile)
;fcbs and similar
WFCB
	*=	*+9
	.byte	"INT"
	*=	*+21
PRMLST	.byte	"         "
;parser data tables
IFLBLN	.byte	2
IFLAB2	.byte	23
IFLABL	.byte	0
HSHTBL
	*=	HSHTSZ*2+*
HASH
	*=	*+PSTKSZ
VAR
	*=	*+PSTKSZ
TYPE
	*=	*+PSTKSZ
STYPE
	*=	*+PSTKSZ
SRLOC
	*=	PSTKSZ*2+*
SYMLOC
	*=	PSTKSZ*2+*
STSTAK				;(statestack)
	*=	PSTKSZ*2+*
VARC
	*=	*+VARCSZ
ONSTAK
	*=	*+MAXOCT
ONSP	=	ONSTAK
;buffers
INPBUF				;input
	*=	*+SRCRSZ
OUTBUF				;output
	*=	*+INTRSZ
CONBUF				;console
	*=	*+CBUFSZ+2
;start of free memory
MEMORY
	.END
