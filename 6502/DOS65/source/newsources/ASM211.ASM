;ASM -- DOS/65 Assembler
;Version 2.11-A
;released:	7 march 2008
;this version incorporates the following changes from 2.04
;	format for *= changed for TASM compatibility
;		this means first * not in column 1
;		all such statements are on a separate line from lable
;	.byt & .wor changed to .byte & .word for TASM
;	all comments have ; for TASM
;	made ' & " interchangeable so strings can us
;		"" for TASM compatibility.
;		note that ASM210 uses ' only
;		and should be assembled either by
;		itself, ASM204, or if all strings
;		in .byte statement are changed to "
;		it can be assembled by TASM.
;	made all #' ' have closing ' (or ") for TASM
;	strings broken up to 31 max for TASM
;	many comments added or clarified
;	more ascii characters defined to simplify compatibility
;last revision:
;	31 march 2008
;		changed string delimiters to ""
;		added five missing semicolons
;ascii character definitions
TAB	=	$9		;tab char
LF	=	$A		;linefeed
CR	=	$D		;return
EOF	=	$1A		;end of file
BLANK	=	$20		;blank
quote	=	$22		;value of "
apost	=	$27		;value of '
semico	=	$3b		;value of semicolon ;
DELETE	=	$7F		;del char
;fixed parameters
NUMASM	=	15		;number directives or parameters
NUMSAV	=	10		;number OPT parameters
LINESZ	=	80		;characters per line (not incl cr/lf)
BYTSRC	=	24		;bytes per kim record
SRCLNG	=	1024		;source buffer length
KIMLNG	=	1024		;kim buffer length
LSTLNG	=	1024		;list buffer length
;external references
TEA	=	$800
PEM	=	$103
DFLFCB	=	$107
DFLBUF	=	$128
;page zero variables
	*=	2
n				;count in sort
	*=	*+2
PASNUM				;pass number
	*=	*+1
SRCIND				;source buffer index
	*=	*+2
KIMIND				;kim buffer index
	*=	*+2
LSTIND				;list buffer index
	*=	*+2
STSAVE				;symbol table start
	*=	*+2
TBLSZ				;symbol table end
	*=	*+2
SYMTBL				;address of symbol found
	*=	*+2
OPRTBL				;address of opcode in table
	*=	*+2
TBLPTR				;used in assembler directive searches
	*=	*+2
COLCNT				;column count
	*=	*+1
LINENO				;line number (hl)
	*=	*+2
NOSYM				;number symbols (hl)
	*=	*+2
ERCT				;total error count (hl)
	*=	*+2
PC				;program counter
	*=	*+2
FLAGS				;set of flags
;flag bit functions
; flag	(7)	if 1 then do not generate strings
;	(6)	if 1 then list symbol table
;	(5)	if 1 then generate kim file
;	(4)	if 1 and if flag(2)=0 then list errors
;	(3)
;	(2)	if 1 then produce listing
;	(1)
;	(0)
; flag+1(7)
;	(6)
;	(5)
;	(4)	EXPR return flag
;	(3)	EXPR overflow flag
;	(2)
;	(1)	sign bit
;	(0)	EXP sign bit
	*=	*+2
COLP				;current column
	*=	*+1
CSB				;current string beginning
	*=	*+1
CSE				;current string end
	*=	*+1
CSL				;current string length
	*=	*+1
LSST				;start of label
	*=	*+1
EXP				;value of expression (hl)
	*=	*+2
PARST				;parse starting column
	*=	*+1
MAXCL				;max column in line
	*=	*+1
LABL				;flag set if label in line
	*=	*+1
ORG				;flag set if org in line
	*=	*+1
BYWOR				;byte/word flag
	*=	*+1
LCDPT				;multiple lines flag
	*=	*+1
SYMPTR				;current # symbols searched in FIND
	*=	*+2
LEN				;length of string to be packed
	*=	*+1
BASE				;base of number
	*=	*+1
OP				;next operator in EVAL
	*=	*+1
LOW				;< flag
	*=	*+1
HIGH				;> flag
	*=	*+1
VAL				;intermediate value in EVAL (hl)
	*=	*+2
RETURN				;return code
	*=	*+1
OPBAS				;base opcode
	*=	*+1
OPTEM				;opcode template
	*=	*+1
OPLEN				;operand length
	*=	*+1
OPTYP				;operand type
	*=	*+1
NOPV				;flag for no operand value
	*=	*+1
J				;utility variable
	*=	*+1
ERCOL				;column with error
	*=	*+1
EROR				;error number
	*=	*+1
TEMP				;utility variable
	*=	*+2
TEMB				;utility variable
	*=	*+2
LTBL				;length table - info buffer
	*=	*+5
SRTFLG				;sort flag
	*=	*+1
CURADR				;current symbol for sort
	*=	*+2
NXTADR				;next symbol for sort
	*=	*+2
BYTCNT				;kim record byte count
	*=	*+1
FRSTPC				;first pc in kim record
	*=	*+2
KIMREC				;kim record buffer
	*=	*+BYTSRC
CHKSUM				;kim record checksum
	*=	*+2
CURNPC				;current kim pc
	*=	*+2
CDEPTR				;code pointer
	*=	*+2
SAVE				;save for x and y
	*=	*+2
ACC				;mul and div accum
	*=	*+2
KINDEX				;kim record index
	*=	*+1
KIMCNT				;kim code count
	*=	*+1
RDSCCN				;read source sector count
	*=	*+1
LNGKIM				;length of buffer at write
	*=	*+2
LNGLST				;length of list buffer
	*=	*+2
MPNT				;pointer for string write
	*=	*+2
MAXECH				;last echo position
	*=	*+1
STRING				;lowercase flag
	*=	*+1
lstflg				;list file to console if > 127
	*=	*+1
nlsflg				;no list file output if > 127
	*=	*+1
nkmflg				;no kim file output if > 127
	*=	*+1
strdel				;string delimiter in .byt
	*=	*+1
LASTZP
;entry point
	*=	TEA
	JMP	MAIN		;skip to main section
symlen	.byte	16		;max symbol length
	.byte	"COPYRIGHT (C) 2008 -"
	.byte	" RICHARD A. LEARY"
;subroutines
;check for correct drive range
chkdrv	cmp	#'A'		;if less than a
	bcc	badrv		;is bad
	cmp	#'H'+1		;if over h
	bcs	badrv		;is bad
	and	#15		;look at lsbs only
	rts
badrv	lda	#<ildmsg	;point to message
	ldy	#>ildmsg
	jsr	wrcnms		;write it
;warm boot
WRMBTE	LDX	#0
	BEQ	PEMENT
;console output
cnsout	cmp	#eof		;see if eof char
	bne	*+3		;continue if not
	rts			;else done
	LDX	#2
	BNE	PEMENT
;select drive
DRVSEL	LDX	#14
	BNE	PEMENT
;set buffer address
SETBUF	LDX	#26
	BNE	PEMENT
;write console message
WRCNMS	LDX	#9
	BNE	PEMENT
;open file
OPNFIL	LDX	#15
	BNE	PEM255
;close file
CLSFIL	LDX	#16
	BNE	PEM255
;delete file
DLTFIL	LDX	#19
	BNE	PEM255
;create file
CRTFIL	LDX	#22
	BNE	PEM255
;read record
RDERCR	LDX	#20
	BNE	PEMENT
;write record
WRTRCR	LDX	#21
;PEM entry
PEMENT	JMP	PEM		;execute
;PEM entry with test A=255
PEM255	JSR	PEM		;execute
	CMP	#255		;test for invalid
	RTS
;write message to list file
;input: A,Y point to message
;output: none
;alters: all
WRLSMS	STA	MPNT		;save
	STY	MPNT+1		;pointer
	LDY	#0		;clear index
WR	LDA	(MPNT),Y	;get char
	CMP	#'$'		;see if $
	BNE	*+3		;continue if not
	RTS			;else done
	JSR	OUTPUT		;send it
	INY			;bump index
	BNE	WR		;jump always
;dos error handler
DOSERR	LDA	#<PERMSG	;print error
	LDY	#>PERMSG	;message on
	JSR	WRCNMS		;console
	JMP	WRMBTE		;and do boot
;set source fcb
SSRFCB	LDA	#<SRCFCB
	LDY	#>SRCFCB
	RTS
;set kim fcb
SKMFCB	LDA	#<KIMFCB
	LDY	#>KIMFCB
	RTS
;set list fcb
SLSFCB	LDA	#<LSTFCB
	LDY	#>LSTFCB
	RTS
;delete kim file
DLTKIM	JSR	SKMFCB		;set fcb
	JMP	DLTFIL		;delete and return
;read source record
RDESRC	LDA	#<SRCBUF	;set
	LDY	#>SRCBUF	;buffer
	JSR	SETBUF		;address
	JSR	SSRFCB		;point to fcb
	JMP	RDERCR		;read
;write kim record
WRTKIM	SEC			;subtract
	LDA	KIMIND		;start
	SBC	#<KIMBUF	;from
	STA	LNGKIM		;index
	LDA	KIMIND+1	;to get
	SBC	#>KIMBUF	;length
	STA	LNGKIM+1	;of buffer
	LDX	#7		;divide
WRTDV	LSR	LNGKIM+1	;by 128
	ROR	LNGKIM		;to get
	DEX			;number
	BNE	WRTDV		;of records
	CPX	LNGKIM		;if not zero
	BNE	*+3		;go write
	RTS			;else done
	JSR	CLKIND		;clear index
WRTKLP	LDA	KIMIND		;get record
	LDY	KIMIND+1	;start
	JSR	SETBUF		;and set buffer
	JSR	SKMFCB		;point to fcb
	JSR	WRTRCR		;write sector
	BEQ	*+5		;continue if ok
	JMP	DOSERR		;else dos/65 error
	CLC			;add
	LDA	KIMIND		;128
	ADC	#128		;to
	STA	KIMIND		;kim
	BCC	*+4		;index
	INC	KIMIND+1	;for next
	DEC	LNGKIM		;drop count
	BNE	WRTKLP		;loop if more
;clear kim index
CLKIND	LDA	#<KIMBUF	;set
	LDY	#>KIMBUF	;index
	STA	KIMIND		;to buffer
	STY	KIMIND+1	;start
	RTS
;list file character output
;input: ascii char in A
;output: none
;alters: all
;write list buffer to disk if full and
;then insert char into buffer
lstout	bit	nlsflg		;test for no list output
	bmi	lstext		;done if set
	bit	lstflg		;test flag
	bpl	*+5		;if clear to disk
	jmp	cnsout		;else to console
	LDX	LSTIND		;get low index
	CPX	#LSTBUF+LSTLNG*256/256	;compare to limit
	BNE	NOLSWR		;jump if ok
	LDX	LSTIND+1	;else try
	CPX	#LSTBUF+LSTLNG/256	;same for high
	BNE	NOLSWR		;ok if different
	PHA			;save char
	JSR	WRTLST		;write buffer
	PLA			;get char
NOLSWR	LDY	#0		;clear index
	STA	(LSTIND),Y	;insert char
	INC	LSTIND		;bump
	BNE	*+4		;index
	INC	LSTIND+1	;by one
lstext	RTS
;write list buffer to disk
;input: none
;output: none
;alters: all
;also sets index to start
WRTLST	SEC			;subtract
	LDA	LSTIND		;buffer start
	SBC	#<LSTBUF	;from
	STA	LNGLST		;current
	LDA	LSTIND+1	;index to
	SBC	#>LSTBUF	;get
	STA	LNGLST+1	;length
	LDX	#7		;divide
WRLDV	LSR	LNGLST+1	;that
	ROR	LNGLST		;by 128
	DEX			;to calculate
	BNE	WRLDV		;number records
	CPX	LNGLST		;if not zero
	BNE	*+3		;then go write
	RTS			;else done
	JSR	CLLIND		;set index to start
WRTLLP	LDA	LSTIND		;get index
	LDY	LSTIND+1	;and set
	JSR	SETBUF		;as buffer start
	JSR	SLSFCB		;point to fcb
	JSR	WRTRCR		;write record
	BEQ	*+5		;continue if ok
	JMP	DOSERR		;else a fatal error
	CLC			;now
	LDA	LSTIND		;add
	ADC	#128		;128
	STA	LSTIND		;to
	BCC	*+4		;index
	INC	LSTIND+1	;for next
	DEC	LNGLST		;drop count
	BNE	WRTLLP		;loop if more
;clear list index
;input: none
;output: none
;alters: A,Y,P
CLLIND	LDA	#<LSTBUF	;set list
	LDY	#>LSTBUF	;index
	STA	LSTIND		;to
	STY	LSTIND+1	;buffer
	RTS			;start
;convert nibble to hex
NIBHEX	AND	#$F		;mask out msn
	ORA	#'0'		;convert to ascii
	CMP	#'9'+1		;if decimal
	BCC	*+4		;ok
	ADC	#6		;else make alpha
	RTS
;kim file byte output
KIMBYT	PHA			;save byte
	LSR	A		;move
	LSR	A		;msn
	LSR	A		;to
	LSR	A		;lsn
	JSR	KIMHEX		;convert and send
	PLA			;get byte
;kim file nibble output
KIMHEX	JSR	NIBHEX		;convert
;kim file char output
KIMOUT	LDX	KIMIND		;compare index
	CPX	#KIMBUF+KIMLNG*256/256	;to limit
	BNE	NOKMWR		;continue if less
	LDX	KIMIND+1	;do same
	CPX	#KIMBUF+KIMLNG/256	;for
	BNE	NOKMWR		;high bytes
	PHA			;save byte
	JSR	WRTKIM		;write buffer
	PLA			;restore char
NOKMWR	LDY	#0		;clear index
	STA	(KIMIND),Y	;save char
	INC	KIMIND		;bump
	BNE	*+4		;index
	INC	KIMIND+1	;by one
	RTS
;output single char to list file
OUTPUT	PHP			;save flags
	PHA			;save char
	STX	SAVE		;save X
	STY	SAVE+1		;and Y
	BIT	PASNUM
	BPL	*+5
	JSR	LSTOUT		;do output
	LDY	SAVE+1		;restore Y
	LDX	SAVE		;and X
	PLA			;restore char
	PLP			;restore flags
	RTS
;output byte as hex to list file
NUMA	PHA			;save byte
	LSR	A		;move
	LSR	A		;msn
	LSR	A		;to
	LSR	A		;lsn
	JSR	NIBHEX		;convert
	JSR	OUTPUT		;and send
	PLA			;get char
	JSR	NIBHEX		;convert lsn
	JMP	OUTPUT		;and send
;output byte as hex to console
;input: A
;output: none
;alters: A,P
CNUMA	PHA			;save byte
	LSR	A		;move
	LSR	A		;msn
	LSR	A		;to
	LSR	A		;lsn
	JSR	NIBHEX		;convert
	JSR	CNSOUT		;send to console
	PLA			;get byte
	JSR	NIBHEX		;convert low
	JMP	CNSOUT		;send it
;do a cr and lf to list file
CRLF	LDA	#CR		;get cr
	JSR	OUTPUT		;send
	LDA	#LF		;then get lf
	JMP	OUTPUT		;send it
;do a cr and lf to console
CCRLF	LDA	#CR		;get cr
	JSR	CNSOUT		;send
	LDA	#LF		;then get lf
	JMP	CNSOUT		;and send it
;set next sort address
ADRNS	CLC			;add
	LDA	CURADR		;length+2
	ADC	symlen		;to current
	STA	NXTADR		;to
	LDA	CURADR+1	;make
	ADC	#0		;pointer to
	STA	NXTADR+1	;next entry
	clc			;do +2 part now
	lda	nxtadr
	adc	#2
	sta	nxtadr
	bcc	adrnsx		;done if no carry
	inc	nxtadr+1	;else bump high
adrnsx	RTS
;sort symbol table
;uses bubble sort but keeps track
;of highest symbol to sort
;check for zero or one symbol
sort	ldy	nosym+1		;set low
	sty	n+1		;count
	LDA	NOSYM		;and high
	sta	n		;count
	BNE	SORT1		;if > 255 go do sort
	tya			;get low
	beq	sortx		;done if zero
	CMP	#1		;if more than
	BNE	SORT1		;one do sort
sortx	RTS			;else done
;drop and check count
sort0	lda	n+1		;check low
	bne	*+4		;skip if not zero
	dec	n		;else drop high
	dec	n+1		;then low
	lda	n		;get new high
	bne	sort1		;do it if <> 0
	lda	n+1		;now get low
	beq	sortx		;done if zero
	cmp	#1		;see if one
	beq	sortx		;done if is
;intialize for pass
SORT1	LDA	#$FF		;set
	STA	SRTFLG		;flag
	LDA	STSAVE		;set
	STA	CURADR		;pointer
	LDA	STSAVE+1	;to first
	STA	CURADR+1	;entry
	LDA	#1		;then
	STA	SYMPTR+1	;set
	LDA	#0		;counter
	STA	SYMPTR		;to one
	JSR	ADRNS		;set next address
;compare symbols
SORT11	LDY	#0		;clear index
SORT2	LDA	(CURADR),Y	;compare first
	CMP	(NXTADR),Y	;to next
	BNE	SORT21		;jump if not same
	INY			;else bump index
	CPY	symlen		;if still small
	BNE	SORT2		;for next
	BEQ	SORT3		;else do next pair
SORT21	BCC	SORT3		;if order ok do next
;switch symbols
	LDY	symlen		;do symbol and value
	iny
RX1	LDA	(CURADR),Y	;get low
	PHA			;save
	LDA	(NXTADR),Y	;then move high
	STA	(CURADR),Y	;to low
	PLA			;restore low
	STA	(NXTADR),Y	;move to high
	DEY			;count down
	BPL	RX1		;loop if more
	INY			;clear flag
	STY	SRTFLG		;to show switch
;next pair
SORT3	LDA	NXTADR		;change
	STA	CURADR		;pointer
	LDA	NXTADR+1	;to next
	STA	CURADR+1	;symbol
	JSR	ADRNS		;and set next
	INC	SYMPTR+1	;bump
	BNE	*+4		;counter
	INC	SYMPTR		;by 1
	LDA	SYMPTR		;if more
	CMP	n		;then go
	BCC	SORT11		;sort more
	LDA	SYMPTR+1	;do same
	CMP	n+1		;with low
	BCC	SORT11		;part of count
	BIT	SRTFLG		;test switch
	BPL	SORT0		;go if was a switch
	RTS			;else done
;increment line buffer pointer
; if x <= maxcl then c=0 else c=1
INCRP	INX
	CPX	MAXCL
	BNE	*+3
	CLC
	RTS
;check if EXP is a valid indirect address
; if exp < 255 then c=1 else c=0
INDADR	LDA	EXP		;if exp>255 is too big
	BEQ	*+4
	CLC
	RTS
	LDA	EXP+1		;if exp=255 is too big
	CMP	#255
	BEQ	*-6
	SEC
	RTS
;check if a relative branch is out of range
; temp must = pc and exp must =	dest addr
; if valid then c=1 else c=0
RELADR	CLC			;compute relative offset
	LDA	TEMP
	ADC	#2
	STA	TEMB+1
	LDA	TEMP+1
	ADC	#0
	STA	TEMB
	SEC
	LDA	EXP+1
	SBC	TEMB+1
	STA	EXP+1
	TAY
	LDA	EXP
	SBC	TEMB
	STA	EXP
	BNE	HRA20		;check for positive out of range
	TYA
	BMI	HRA30
HRA10	SEC
	RTS
HRA20	CMP	#255		;check for negative out of range
	BNE	HRA30
	TYA
	BMI	HRA10
HRA30	CLC
	RTS
;find next non-blank
; if found then c=1 else c=0
FNDNB	LDA	MAXCL		;if max >127
	BMI	J30		;is no good
	LDX	COLP		;get col pointer
J10	CPX	MAXCL		;if pointer <= maxcl
	BEQ	*+4		;branch if equal
	BCS	J30		;branch if >
	LDA	LINE,X		;get char
	CMP	#BLANK		;if a blank
	BEQ	*+6		;then branch
	STX	CSB		;else save pointer in csb
	SEC
	RTS
	INX			;bump pointer
	STX	COLP
	BNE	J10		;loop always
;did not find a non-blank
J30	CLC			;was all blanks
	RTS
;find end of current string
;  if found then c=1 else c=0
FNDEN	LDY	#0
	STY	CSL
	LDX	COLP		;get pointer
I10	CPX	MAXCL		;test against max
	BEQ	*+4		;branch if ok
	BCS	I30		;branch if too big
	LDA	LINE,X		;get char
	CMP	#BLANK		;if a blank
	BEQ	I20		;then branch
	CMP	#'='		;if an =
	BEQ	I20		;then branch
	CMP	#semico		;if not a semi
	BNE	I40		;then branch
I20	CPY	#0		;is y=0
	BNE	I60		;branch if not
I25	DEX
	STX	CSE		;update end of string
	SEC
	RTS
I30	CPY	#0
	BEQ	I25
	CLC
	RTS
I40	CMP	#apost		;is it an apostrophe
	BNE	I60		;branch if not
	INY			;else bump temp
	CPY	#2		;if 2
	BNE	I60		;continue else
	LDY	#0		;reset temp
I60	INX			;bump pointer
	INC	CSL
	BNE	I10		;loop always
;find non-embedded comma or right paren
; if found then c=1 else c=0
FNCMP	LDX	COLP		;get pointer
K40	CPX	MAXCL		;compare to max
	BEQ	*+4
	BCS	K10		;end of line
	LDA	LINE,X		;get char
	CMP	#apost		;if not string start
	BNE	K20		;branch
K30	JSR	INCRP		;skip over string
	STX	COLP
	BCS	K10
	LDA	LINE,X		;get new char
	CMP	#apost		;if not apostrophe
	BNE	K30		;then branch
	INX
	STX	COLP		;bump pointer
	BNE	K40
K20	LDA	LINE,X		;get char
	CMP	#BLANK		;if blank
	BEQ	K10		;done
	CMP	#')'
	BEQ	K15
	CMP	#','
	BEQ	K15
	INX
	STX	COLP		;bump pointer
	BNE	K40
K10	CLC			;error
K15	RTS
;test a char to see if alphanumeric
; if alphanumeric then c=1 else c=0
ALNUM	JSR	ALPH
	BCC	NUMRC
	RTS
;test a char to see if alpha
; if alpha then c=1 else c=0
ALPH	LDA	LINE,X		;get char
	CMP	#'A'		;if less than A
	BCC	*+7		;not alpha
	CMP	#'Z'+1		;if less than Z+1
	BCC	*+4		;is alpha
	CLC			;not alpha
	RTS
	SEC			;alpha
	RTS
;test a char to see if number
; if number then c=1 else c=0
NUMRC	LDA	LINE,X		;get char
	CMP	#'0'		;if less than 0
	BCC	*+7		;not number
	CMP	#'9'+1		;if less than 9+1
	BCC	*+4		;is a number
	CLC			;not number
	RTS
	SEC			;number
	RTS
;construct a symbol
; if non-alpha char then c=0 else c=1
CONSYM	LDY	#$FF		;use y as counter
C10	INY			;bump y
	CPY	symlen		;and test
	BEQ	C15
	CPY	LEN		;if all char in symbol
	BCS	C30		;go fill blanks
	JSR	ALNUM
	BCS	C20
	CLC			;non-alphanumeric
C15	RTS
C20	LDA	LINE,X		;get char
	STA	SYM,Y
	INX			;bump pointer
	BCS	C10
C30	LDA	#BLANK		;fill in blanks
	STA	SYM,Y
	BCS	C10
;evaluate expression
; on exit ercol points to bad char if any
;         x points to next char if good expr
;         return is set as follows
;          -1 if ok and exp is set to value
;           0 if undefined symbol
;           1 if uninterpretable
EVAL	LDA	#0		;initialize
	STA	EXP
	STA	EXP+1
	LDA	#1
	STA	RETURN
	LDA	#%11111110	;set sign to plus
	AND	FLAGS+1
	STA	FLAGS+1
	STX	ERCOL
	STX	J
	JSR	ENDTST		;if more
	BCC	*+3		;continue
	RTS
;get initial operation
	LDY	#'+'		;set to plus
	CMP	#'-'		;if not minus
	BNE	D15		;ok
	TAY			;set to minus
D11A	JSR	INCRP		;point to next char
	BCC	D15
	RTS
D15	STY	OP		;save oper
	STX	ERCOL
	LDA	#0		;initialize
	STA	LOW		;flags
	STA	HIGH
	JSR	ENDTST		;if more
	BCC	*+3		;continue
	RTS
	CMP	#'<'		;if not <
	BNE	D150
	INC	LOW		;else bump low
	BNE	D151
D150	CMP	#'>'		;if not >
	BNE	D158
	INC	HIGH
D151	JSR	INCRP
	BCC	D158
	RTS
D158	STX	ERCOL
	JSR	NUMRC		;is char a number
	BCC	*+7		;no - not base 10
	LDY	#10		;is base 10
	JMP	D55		;get char and eval
	CMP	#'$'		;is char a $
	BNE	*+7		;no - not hex
	LDY	#16		;else is hex
	JMP	D50		;go evaluate
	CMP	#'@'		;is char a @
	BNE	*+7		;no - not octal
	LDY	#8		;else is octal
	JMP	D50		;go evaluate
	CMP	#'%'		;is char a %
	BNE	*+7		;no - not base 2
	LDY	#2		;else is binary
	JMP	D50		;go evaluate
	JSR	ALPH		;is it alpha
	BCC	D46		;no check for pc
;process a symbol
	JSR	FNDLN		;find length
	sec			;drop by one
	sbc	#1
	CMP	symlen		;if not too big
	BCC	D43		;continue
	RTS
D43	JSR	CONSYM		;construct symbol
	JSR	FIND
	BCC	*+5
	JMP	D60
	BVS	*+5		;branch if not defined
	JSR	SETCHN		;create it
	LDA	BYWOR		;if .byt or .wor
	BNE	D44E		;branch
	LDA	ORG		;if equ or org
	BNE	D44E		;branch
	LDA	EXP+1		;error if expr
	BNE	D452
	LDA	EXP
	BNE	D452
	LDA	OP		;error if not +
	CMP	#'+'
	BNE	D44F
	STX	ERCOL
	DEX			;error if expr after symbol
	JSR	INCRP
	BCS	D44E
	JSR	ENDTST
	BCC	D452
D44E	JMP	D200
D44F	LDX	J
	STX	ERCOL
D452	RTS
;evaluate field with pc (*)
D46	CMP	#'*'		;if not asterix
	BNE	D47		;continue
	LDA	PC		;save pc
	STA	VAL+1		;in
	LDA	PC+1		;value
	STA	VAL
	INX			;next char
	BNE	D60		;do op
;get a single char
D47	CMP	#apost		;if '
	BEQ	*+3		;maybe ok
	RTS
	JSR	INCRP		;next pos
	BCC	*+3		;not end
	RTS
	LDA	LINE,X		;get char
	CMP	#apost		;see if another apost
	BNE	D47A		;branch if not
	JSR	INCRP		;bump x
	BCS	STROPR		;error if end
	LDA	LINE,X		;now get next
	CMP	#apost		;see if apost again
	BNE	STROPR		;branch if is
D47A	STA	VAL+1		;store
	LDA	#0		;clear
	STA	VAL		;high
	JSR	INCRP		;next
	BCS	D60
	LDA	LINE,X		;get char
	CMP	#apost		;if '
	BNE	STROPR
	JSR	INCRP
	BCS	D60
	LDA	LINE,X
	CMP	#apost
	BNE	D60
STROPR	LDX	ERCOL
	RTS
	INX			;next pos
	BNE	D60		;do oper
;evaluate numeric field
D50	JSR	INCRP		;next char
	BCC	*+3		;continue if ok
	RTS
	STX	ERCOL
	JSR	ALNUM
	BCS	D55		;if number continue
	RTS
D55	STY	BASE		;save base
;get length
	JSR	FNDLN		;point to next
;compute value
	JSR	NUMBER		;compute
	BCS	D60		;continue if ok
	RTS
;do oper
D60	LDA	LOW		;low only?
	BEQ	D68		;no so junp
	LDA	#0		;is ow only so clear high
	STA	VAL
	BEQ	D69
D68	LDA	HIGH		;high only?
	BEQ	D69		;no
	LDA	VAL		;is so put high
	STA	VAL+1		;in low
	LDA	#0		;clear high
	STA	VAL
D69	LDA	OP		;get oper
	CMP	#'+'		;if not add
	BNE	D65		;branch
;add operation
	LDA	EXP+1		;get low
	CLC			;add
	ADC	VAL+1		;low of number
	STA	EXP+1		;save
	LDA	EXP		;then do
	ADC	VAL		;same for
	STA	EXP		;high
	LDA	#0		;put carry
	ROL	A		;in A
	TAY			;then Y
	JSR	CMPSGN		;compare signs
	BNE	D62		;branch if different
	TYA			;if carry
	BNE	D61		;then overflow
	JMP	D70		;else continue
D61	LDA	#8		;get overflow mask
	ORA	FLAGS+1		;set flag
	STA	FLAGS+1		;save
	JMP	D70		;continue
D62	TYA			;check carry
	BEQ	D63		;if none is neg
	LDA	#254		;get pos mask
	AND	FLAGS+1		;set
	STA	FLAGS+1		;save
	JMP	D70
D63	LDA	#1		;negative mask
	ORA	FLAGS+1		;set sign
	STA	FLAGS+1		;save
	JMP	D70		;continue
D65	CMP	#'-'		;if not -
	BNE	TRYMUL		;try mult
;subtract operation section
	LDA	EXP+1		;get low
	SEC			;subtract
	SBC	VAL+1		;number
	STA	EXP+1		;save
	LDA	EXP		;do
	SBC	VAL		;same
	STA	EXP		;for high
	LDA	#0		;save
	ROL	A		;carry
	TAY
	JSR	CMPSGN		;compare signs
	BNE	D67		;branch if different
	TYA			;get carry
	BEQ	D66		;if none branch
	LDA	#254		;set pos
	AND	FLAGS+1		;mask
	STA	FLAGS+1		;for expr
	JMP	D70		;continue
D66	LDA	#1		;set neg
	ORA	FLAGS+1		;mask
	STA	FLAGS+1		;for expr
	JMP	D70		;continue
D67	STY	TEMP		;save carry
	LDA	#1		;get exp
	AND	FLAGS+1		;sign
	EOR	TEMP		;compare to carry
	BNE	*+5		;branch if not equal
	JMP	D70		;else continue
	LDA	#8		;load
	ORA	FLAGS+1		;overflow mask
	STA	FLAGS+1		;for exp
	JMP	D70
TRYMUL	CMP	#'*'		;if not mult
	BNE	TRYDIV		;try division
;multiplication operation
	LDA	#0		;clear
	STA	ACC+1		;accum
	STA	ACC
	JSR	SMEXP		;make exp sign/magn
	JSR	SMVAL		;same for val
	TXA			;save
	PHA			;current index
	LDX	#16		;do 16 bits
MULLPE	LSR	VAL		;shift mult
	ROR	VAL+1		;right
	BCC	NOADD		;if zero no add
	CLC			;else
	LDA	ACC+1		;get accum
	ADC	EXP+1		;add exp
	STA	ACC+1		;save
	LDA	ACC		;same
	ADC	EXP		;for
	STA	ACC		;high
NOADD	ASL	EXP+1		;mult exp
	ROL	EXP		;by two
	DEX			;count down
	BNE	MULLPE		;loop if more
	PLA			;restore
	TAX			;x
ENDMUL	LDA	ACC+1		;set
	STA	EXP+1		;exp
	LDA	ACC		;to accum
	STA	EXP		;value
	JSR	CMPSGN		;compare signs
	BNE	EXPNEG		;negative
	LDA	#254		;else
	AND	FLAGS+1		;positive
	STA	FLAGS+1		;result
	JMP	D70
EXPNEG	LDA	#1		;set sign
	ORA	FLAGS+1		;to neg
	STA	FLAGS+1		;in flags
	JSR	TCPEXP		;make twos compl
	JMP	D70		;continue
TRYDIV	CMP	#'/'		;if not div
	BEQ	DODIV		;error else ok
	LDX	J
	STX	ERCOL
	RTS
;division operation
DODIV	LDA	#0		;clear
	STA	ACC+1		;accum
	STA	ACC
	JSR	SMEXP		;convert
	JSR	SMVAL		;to sign/magn
	LDA	VAL+1		;if divisor
	ORA	VAL		;not zero
	BNE	DIVLPE		;then ok
	LDX	J
	STX	ERCOL
	RTS
DIVLPE	SEC			;subtract
	LDA	EXP+1		;val
	SBC	VAL+1		;from exp
	STA	EXP+1		;until
	LDA	EXP		;a
	SBC	VAL		;borrow
	STA	EXP
	BCC	ENDMUL		;then done
	INC	ACC+1		;bump low
	BNE	DIVLPE		;loop if no carry
	INC	ACC		;else bump high
	BNE	DIVLPE		;loop always
;end oper
D70	CPX	MAXCL		;see if end
	BEQ	D71		;no
	BPL	D100		;yes done
D71	JSR	ENDTST		;at end of expr
	BCS	D100		;yes but bad
	LDY	LINE,X		;get op
	STX	J
	JMP	D11A		;start over
;exits
D100	LDA	#255		;good
	STA	RETURN		;return
	RTS
D200	LDA	#0		;undefined
	STA	RETURN		;symbol
	RTS
;finds length of field
; loops until non-alphanumeric found
; ercol must = x
; result in len
FNDLN	JSR	INCRP		;bump pointer
	BCS	HLN220
	JSR	ALNUM
	BCS	FNDLN
HLN220	TXA			;get ending
	SEC			;subtract
	SBC	ERCOL		;start
	STA	LEN		;save answer
	LDX	ERCOL
	RTS
;compare signs of exp and val
CMPSGN	LDA	#1		;get sign
	AND	FLAGS+1		;of exp
	ASL	A		;move to val pos
	STA	TEMP		;save
	LDA	#2		;get sign
	AND	FLAGS+1		;of val
	EOR	TEMP		;see if different
	RTS
;convert exp to sign/magn
SMEXP	LDA	#1		;get
	AND	FLAGS+1		;sign
	BEQ	SM1		;done if
;convert expr
TCPEXP	CLC			;else do
	LDA	EXP+1		;a
	EOR	#$FF		;two's
	ADC	#1		;complement
	STA	EXP+1
	LDA	EXP
	EOR	#$FF
	ADC	#0
	STA	EXP
SM1	RTS
;convert val to sign/magn
SMVAL	LDA	#2		;get
	AND	FLAGS+1		;sign
	BEQ	SM1		;done if +
	CLC			;else do
	LDA	VAL+1		;a
	EOR	#$FF		;two's
	ADC	#1		;complement
	STA	VAL+1
	LDA	VAL
	EOR	#$FF
	ADC	#0
	STA	VAL
	RTS
;test for end of string
; if found then c=1 else c=0
ENDTST	LDA	LINE,X		;get char
	CMP	#blank		;if blank
	BEQ	DD10		;set carry
	CMP	#','		;if comma
	BEQ	DD10		;set carry
	CMP	#')'		;if right paren
	BEQ	DD10		;set carry
	CMP	#semico		;if semi
	BEQ	DD10		;set carry
	CLC			;else clear
DD10	RTS
;convert input string to number
; if ok then c=1 else c=0
NUMBER	LDA	#0		;clear
	STA	VAL		;value
	STA	VAL+1
E10	LDA	LINE,X		;get char
	JSR	NUMRC		;if not number
	BCC	E20		;then branch
	AND	#$F		;remove zone
	BPL	E30		;jump
E20	JSR	ALPH		;if not alpha
	BCC	E40		;is error
	SEC
	SBC	#$37		;remove zone
E30	CMP	BASE		;is base valid
	BCC	E50		;yes
E40	CLC			;else bad base
	RTS
E50	STA	COLCNT
	TXA
	PHA
	LDY	BASE		;get base
	CPY	#2		;is it 2
	BNE	E60		;no
	LDX	#1		;shift one
	BNE	E90
E60	CPY	#8		;is it 8
	BNE	E70		;no
	LDX	#3		;shift three
	BNE	E90
E70	CPY	#16		;is it 16
	BNE	E80		;no
	LDX	#4		;shift four
	BNE	E90
E80	CPY	#10		;if not 10
	BNE	E40		;is invalid
	LDA	VAL		;save
	STA	TEMP		;val
	LDA	VAL+1
	STA	TEMP+1
	LDX	#3		;10 means 3 shifts + 1 shift
E90	ASL	VAL+1		;shift
	ROL	VAL		;left
	BCC	E100		;branch if no carry
	LDA	FLAGS+1		;else overflow
	ORA	#8
	STA	FLAGS+1
E100	DEX			;count down
	BNE	E90		;loop if more
	CPY	#10		;if not base 10
	BNE	E120		;done
	ASL	TEMP+1		;must do another
	ROL	TEMP
	BCC	E115		;if clear ok
	LDA	FLAGS+1		;else set
	ORA	#8		;overflow
	STA	FLAGS+1
E115	LDA	VAL+1		;add parts
	CLC
	ADC	TEMP+1
	STA	VAL+1
	LDA	VAL
	ADC	TEMP
	STA	VAL
	BCC	E120		;no overflow
	LDA	FLAGS+1
	ORA	#8		;set overflow
	STA	FLAGS+1
E120	LDA	COLCNT		;get first
	CLC			;add
	ADC	VAL+1		;to val
	STA	VAL+1
	LDA	VAL
	ADC	#0
	STA	VAL
	BCC	E130
	LDA	FLAGS+1		;set
	ORA	#8		;overflow
	STA	FLAGS+1
E130	PLA
	TAX
	INX			;bump pointer
	DEC	LEN		;drop count
	BEQ	E140
	JMP	E10		;loop for more
E140	SEC
	RTS
;search symbol table
; if found and defined then c=1 and v=0
; if found and not defined then c=0 and v=1
; if not found then c=0 and v=0
; symtbl contains next available address
FIND	LDA	STSAVE		;get start
	STA	SYMTBL		;set pointer
	LDA	STSAVE+1
	STA	SYMTBL+1
	LDA	#1
	STA	SYMPTR+1
	LDA	#0
	STA	SYMPTR
G10	CLV
	LDA	SYMPTR
	CMP	NOSYM
	BCC	G20
	BNE	G50
	LDA	SYMPTR+1
	CMP	NOSYM+1
	BEQ	G20
	BCS	G50
G20	LDY	symlen		;get length
	dey			;drop by one
G30	LDA	(SYMTBL),Y
	BPL	G32
	AND	#$7F
	BIT	KLUDG		;set v
G32	CMP	SYM,Y
	BNE	G70
	DEY
	BPL	G30
	LDY	symlen
	LDA	(SYMTBL),Y
	STA	VAL
	INY
	LDA	(SYMTBL),Y
	STA	VAL+1
	BVS	G50
	RTS
G50	CLC			;no match
	RTS
;try next symbol
G70	LDA	SYMTBL		;get low addr
	CLC			;add length
	ADC	symlen
	STA	SYMTBL
	BCC	g751
	INC	SYMTBL+1
g751	clc			;add two
	lda	symtbl
	adc	#2
	sta	symtbl
	bcc	g75		;skip if no carry
	inc	symtbl+1
G75	INC	SYMPTR+1
	BNE	G10
	INC	SYMPTR
	JMP	G10
;create undefined symbol
SETCHN	LDA	#$FF		;set
	STA	VAL		;null
	STA	VAL+1		;value
	LDA	SYM		;set
	ORA	#$80		;undefined
	STA	SYM		;flag
;insert a new symbol into table
;if v=1 just update entry with new values
;if v=0 then create new entry by bumping nosym
INSERT	LDA	SYMTBL+1
	CMP	TBLSZ+1
	BCC	G105
	BNE	G110
	LDA	SYMTBL
	CMP	TBLSZ
	BCS	G110
G105	LDY	symlen		;put symbol and value in table
	dey			;drop by one
G100	LDA	SYM,Y		;get char
	STA	(SYMTBL),Y	;insert
	DEY			;next char
	BPL	G100		;loop if more
	LDY	symlen
	LDA	VAL
	STA	(SYMTBL),Y
	LDA	VAL+1
	INY
	STA	(SYMTBL),Y
	BVS	G104		;only defining undefined
	INC	NOSYM+1
	BNE	G104
	INC	NOSYM
G104	RTS
G110	SEC
	RTS
;fill LINE until LF or EOF
; expand tab (ctl-i) during fill
; convert all non-embedded alpha to uppercase
LINEIN	LDA	#0		;clear
	STA	MAXCL		;index
	STA	MAXECH		;and echo index
	STA	STRING		;and convert flag
GNC	JSR	GNX		;get next byte
	LDX	MAXECH		;get echo index
	STA	ECHBUF,X	;save in echo buffer
	CMP	#apost		;see if apost
	beq	instr		;is so start string
	cmp	#quote		;now check for double quote
	bne	nts		;isn't so not string start or end
instr	pha			;save char
	LDA	STRING		;else get flag
	EOR	#$FF		;complement
	STA	STRING		;and save
	pla			;get char back
NTS	BIT	STRING		;test flag
	BMI	NLCC		;branch if set
;not in string so covert lowercase to uppercase
	CMP	#'a'		;if < a
	BCC	NLCC		;do nothing
	CMP	#'z'+1		;if over z
	BCS	NLCC		;do nothing
	AND	#$5F		;else make upper
NLCC	LDX	MAXCL		;get index
	STA	LINE,X		;save char
	CMP	#TAB		;if not tab
	BNE	NTT		;branch
	INC	MAXECH		;bump echo pointer
;expand tab
CTB	LDA	#blank		;get blank
	STA	LINE,X		;store
	INC	MAXCL		;bump index
	LDX	MAXCL		;get index
	CPX	#LINESZ+1	;if too big
	BCS	ER23		;is error
	TXA			;if index
	AND	#7		;not mod 8
	BNE	CTB		;expand
	BEQ	GNC		;else next char
;not a tab
NTT	CMP	#EOF		;if an eof
	BEQ	EXT		;done
	CMP	#LF		;if lf
	BEQ	EXT		;done
	INC	MAXECH		;bump echo pointer
	INC	MAXCL		;next
	LDA	MAXCL		;get index
	CMP	#LINESZ+2	;if not too big
	BCC	GNC		;get next
;line too long
ER23	LDA	#CR		;set
	STA	LINE+LINESZ
	STA	ECHBUF+LINESZ	;buffer end
	LDA	#LF		;end
	STA	LINE+LINESZ+1
	STA	ECHBUF+LINESZ+1	;for both
	SEC			;error
RDE	RTS
;normal
EXT	CLC
	RTS
;get next source char
GNX	LDA	SRCIND		;if index
	CMP	#SRCBUF+SRCLNG*256/256	;is less
	LDA	SRCIND+1	;than
	SBC	#SRCBUF+SRCLNG/256	;maximum
	BCC	BUFULL		;use it
	JSR	CLSIND		;else set to start
	LDA	#SRCLNG/128	;set number
	STA	RDSCCN		;records
RDESLP	LDA	SRCIND		;get buffer
	LDY	SRCIND+1	;start
	JSR	SETBUF		;set it
	JSR	SSRFCB		;point to fcb
	JSR	RDERCR		;read record
	BEQ	RDESOK		;branch if ok
	CMP	#1		;if a one
	BEQ	*+5		;is just eof
	JMP	DOSERR		;else is error
	LDY	#0		;clear index
	LDA	#EOF		;get an eof
	STA	(SRCIND),Y	;insert it
	BNE	ENDRDE		;and exit
RDESOK	CLC			;add
	LDA	SRCIND		;128
	ADC	#128		;to
	STA	SRCIND		;source
	BCC	*+4		;index
	INC	SRCIND+1	;then
	DEC	RDSCCN		;drop count
	BNE	RDESLP		;loop if more
ENDRDE	JSR	CLSIND		;set index to start
BUFULL	LDY	#0		;clear index
	LDA	(SRCIND),Y	;get char
	AND	#$7F		;mask parity
	CMP	#EOF		;if not eof
	BNE	*+3		;go bump index
	RTS			;else done
	INC	SRCIND		;bump low
	BNE	*+4		;then as needed
	INC	SRCIND+1	;bump high
	RTS
;set source index to start
CLSIND	LDA	#<SRCBUF	;get
	LDY	#>SRCBUF	;address
	STA	SRCIND		;and
	STY	SRCIND+1	;set
	RTS
;search opcode table for valid code
; if found then c=1 else c=0
OPFND	LDA	#<OPRNDS	;get low
	STA	OPRTBL		;save
	LDA	#>OPRNDS	;then
	STA	OPRTBL+1	;high
	LDX	#0		;clear opcode number
G200	LDY	#2		;offset for compare
G210	LDA	SYM,Y		;get char
	CMP	(OPRTBL),Y	;compare
	BNE	G220		;no match
	DEY			;next char
	BPL	G210		;try next
;found valid
	LDA	KTMPL,X		;get template
	STA	OPTEM		;save
	LDA	KCODE,X
	STA	OPBAS		;save
	RTS
;no match
G220	LDA	OPRTBL		;get low addr
	CLC			;point
	ADC	#3		;to
	STA	OPRTBL		;next
	BCC	*+4		;opcode
	INC	OPRTBL+1	;in
	INX			;bump number
	CPX	#57		;looked at all?
	BMI	G200		;no
	CLC			;not found
	RTS
;make an entry in length table
; x=col with error
; y=length
; a=error code
LTINS	STA	LTBL+4		;save error
	STY	LTBL		;save length
	STX	LTBL+1		;and col
	LDA	PC
	STA	LTBL+2		;save pc
	LDA	PC+1
	STA	LTBL+3
	TYA			;add
	CLC			;length
	ADC	PC		;to pc
	STA	PC
	BCC	*+4
	INC	PC+1
	LDA	LTBL+4		;get error flag
	BNE	LTI		;branch if error
	LDA	#%00000100	;test print flag
	AND	FLAGS
	BEQ	*+5		;no print
	JMP	PRTLN
	JMP	PRT170		;go do kim output
LTI	STA	EROR
	SED
	CLC
	LDA	ERCT+1
	ADC	#1
	STA	ERCT+1
	LDA	ERCT
	ADC	#0
	STA	ERCT
	CLD
	LDA	BYWOR		;get byte/word flag
	BNE	*+7		;branch if set
	LDA	#0		;else clear
	STA	CODE		;opcode
	LDA	#%00010100	;check for
	AND	FLAGS		;error print
	BEQ	*+8		;no
	JSR	PRTLN
	JMP	ERRHND
	JMP	PRT170		;go do kim file
;print the symbol table
;prints one symbol per line
NSTAT	LDA	STSAVE		;point to start
	STA	SYMTBL
	LDA	STSAVE+1
	STA	SYMTBL+1
	LDA	#1		;start at beginning
	STA	SYMPTR+1
	LDA	#0
	STA	SYMPTR
R20	CLV
	LDA	SYMPTR
	CMP	NOSYM
	BEQ	R30
	BCC	R42
R25	RTS
R30	LDA	SYMPTR+1
	CMP	NOSYM+1
	BEQ	R42
	BCS	R25
R42	JSR	OUTCL1
	LDY	#0		;symbol and value (* if undef)
R43A	LDA	(SYMTBL),Y
	BPL	R43B
	AND	#$7F
	BIT	KLUDG		;set v
R43B	JSR	OUTPUT
	INY
	CPY	symlen		;compare to length
	BNE	R43A
	JSR	OUTCL2
	BVC	R43C
	LDY	#4
	JSR	PRAST
	BEQ	R43D
R43C	LDA	(SYMTBL),Y
	JSR	NUMA
	INY
	LDA	(SYMTBL),Y
	JSR	NUMA
R43D	JSR	CRLF
	CLC
	lda	symtbl		;add length
	ADC	symlen		;to table pointer
	STA	SYMTBL
	BCC	r431
	INC	SYMTBL+1
r431	clc			;add two
	lda	symtbl
	adc	#2
	sta	symtbl
	bcc	r432		;skip if no carry
	inc	symtbl+1
r432	INC	SYMPTR+1
	BNE	R20
	INC	SYMPTR
	JMP	R20
;print number * in y
PRAST	LDA	#'*'		;get *
	JSR	OUTCNT
	DEY
	BNE	PRAST
	RTS
;end of assembly code (.END)
H10	LDX	#0
	TXA
	TAY
	JSR	LTINS
	BIT	PASNUM		;test pass number
	BPL	H10X		;skip if first
	JSR	CR2
	LDA	#$40
	AND	FLAGS
	BEQ	MNOS
	JSR	CR2
	JSR	SORT		;do final sort
	JSR	NSTAT
	JSR	CRLF		;and a last cr and lf
MNOS	LDA	#<ENDMSG	;point to
	LDY	#>ENDMSG	;end message
	JSR	WRCNMS		;print it
	JSR	CCRLF
H10X	LDX	#$FB
	TXS
	SEC
	RTS
;print output line
PRTLN	LDA	#<CODE
	STA	CDEPTR
	LDA	#>CODE
	STA	CDEPTR+1
	LDA	LTBL+2
	STA	PC
	LDA	LTBL+3
	STA	PC+1
	LDA	LTBL
PRT10	PHA
	LDA	#0
	STA	COLCNT
	JSR	OUTCL1
	LDA	PC+1
	JSR	NUMC2
	LDA	PC
	JSR	NUMC2
	JSR	OUTCL1		;send a blank
	PLA
	BNE	PRT20		;ok if not zero
	PHA			;save zero again
	LDA	LCDPT		;get mult lines flag
	BNE	PRT140		;branch if set
	JSR	OUTTB		;send tab
	JSR	OUTTB		;and another
	JMP	PRT130		;go echo line
;was something to print
PRT20	TAX
	CMP	#4
	BCC	PRT40
	LDX	#3
	SEC
	SBC	#3
	JMP	PRT50
PRT40	LDA	#0
PRT50	PHA
PRT60	DEX
	BMI	PRT100
	LDY	#0
	LDA	(CDEPTR),Y
PRT70	JSR	NUMC2
PRT80	JSR	OUTCL1
	INC	PC
	BNE	*+4
	INC	PC+1
	INC	CDEPTR
	BNE	PRT60
	INC	CDEPTR+1
	BNE	PRT60
PRT100	LDA	LCDPT
	BNE	PRT140
	LDX	MAXCL
	BMI	PRT140
	JSR	OUTTB		;send a tab
PRT130	JSR	ECHOPR		;now do line
PRT140	JSR	CRLF
	INC	LCDPT
	PLA
	BEQ	PRT170
	TAX
	LDA	#128
	AND	FLAGS
	BNE	PRT160
	TXA
	JMP	PRT10
PRT160	CLC
	TXA
	ADC	PC
	STA	PC
	BCC	PRT170
	INC	PC+1
PRT170	BIT	PASNUM
	bpl	extkim		;exit if first pass
	LDA	LTBL
	beq	extkim		;or if no output
	STA	KIMCNT
	LDA	FLAGS		;get flag
	AND	#%00100000	;isolate kim bit
	beq	extkim		;exit if kim disabled
	bit	nkmflg		;see if command line Z
	bpl	*+3		;it wasn't so continue
extkim	RTS			;else done
;following code actually does kim output
	LDA	BYTCNT
	BNE	NONEW
NWKIM	LDA	LTBL+2		;initialize program counter
	STA	FRSTPC+1
	STA	CURNPC+1
	LDA	LTBL+3
	STA	FRSTPC
	STA	CURNPC
NONEW	LDA	LTBL+2
	CMP	CURNPC+1
	BEQ	*+8
W0	JSR	WRKMRC
	JMP	NWKIM
	LDA	LTBL+3
	CMP	CURNPC
	BNE	W0
	LDY	#0
W1	LDX	BYTCNT
KFL	LDA	CODE,Y
	STA	KIMREC,X
	INC	CURNPC+1
	BNE	*+4
	INC	CURNPC
	INY
	INX
	STX	BYTCNT
	DEC	KIMCNT
	BNE	*+7
	CPX	#BYTSRC
	BEQ	WRKMRC
	RTS
	CPX	#BYTSRC
	BNE	KFL
	TYA
	PHA
	JSR	WRKMRC
	PLA
	TAY
	LDA	CURNPC+1
	STA	FRSTPC+1
	LDA	CURNPC
	STA	FRSTPC
	JMP	W1
;write kim record
wrkmrc	lda	#0		;clear checksum
	sta	chksum+1
	sta	chksum
	LDA	BYTCNT		;get byte count
	BNE	*+3
	RTS			;done if zero
;start output with semicolon
	LDA	#semico
	JSR	KIMOUT
	LDA	BYTCNT
	jsr	addck		;add count to checksum
	JSR	KIMBYT
	LDA	BYTCNT		;adjust to get address
	CLC
	ADC	#2
	STA	BYTCNT
	LDA	#1
	STA	KINDEX
WRK1	LDX	KINDEX
	LDA	BYTCNT,X
	jsr	addck		;add to checksum
	JSR	KIMBYT
	INC	KINDEX
	DEC	BYTCNT
	BNE	WRK1
	LDA	CHKSUM		;send high
	JSR	KIMBYT		;checksum
	LDA	CHKSUM+1	;then
	JSR	KIMBYT		;low part
	LDA	#CR
	JSR	KIMOUT
	LDA	#LF
	JMP	KIMOUT
;add byte in a to checksum and save a
addck	pha			;save byte
	clc			;now do add
	adc	chksum+1
	sta	chksum+1
	bcc	addckx		;done if no carry
	inc	chksum		;else bump high
addckx	pla			;get input byte
	rts
;print line as in buffer
ECHOPR	LDX	#$FF
	DEC	MAXECH		;drop limit
ECH10	INX			;bump index
	CPX	MAXECH		;compare to max
	BCS	ECH20
	LDA	ECHBUF,X	;get char
	JSR	OUTPUT		;send
	JMP	ECH10		;and loop
ECH20	RTS
;print error message and pointer
ERRHND	BIT	PASNUM		;test pass number
	BMI	erh01		;continue if second
	RTS			;else done
erh01	LDA	#<ERRMSG	;point to
	LDY	#>ERRMSG	;error message
	JSR	WRLSMS		;write it
	JSR	OUTTB		;send a tab
	LDX	LTBL+1		;get error column
ERH10	DEX
	BMI	ERH20
	JSR	OUTCL1
	JMP	ERH10
ERH20	LDA	#'^'
	JSR	OUTPUT
	JSR	CRLF
	LDA	EROR		;get error number
	ASL	A		;mult by two
	TAX			;make into index
	LDA	ERRVEC,X	;get low
	LDY	ERRVEC+1,X	;and high address
	JSR	WRLSMS		;write message
	JMP	CRLF		;and cr lf
;print byte and adjust column count
NUMC2	INC	COLCNT
	INC	COLCNT
	JMP	NUMA
;output blanks and adjust count
OUTCL4	JSR	OUTCL1
	JSR	OUTCL1
OUTCL2	JSR	OUTCL1
OUTCL1	LDA	#blank
OUTCNT	INC	COLCNT
	JMP	OUTPUT
;send a tab
OUTTB	LDA	#TAB		;get it
	JMP	OUTPUT		;and send
;cr lf routines
CR4	JSR	CRLF
	JSR	CRLF
CR2	JSR	CRLF
	JMP	CRLF
;-------------------------------
;process a single line
;-------------------------------
PROCES	LDA	#0
	LDX	#13
	STA	FLAGS+1,X
	DEX
	BPL	*-3
	LDX	#LINESZ-5	;clear
	STA	CODE,X		;all of
	DEX			;code
	BPL	*-4		;buffer
	JSR	LINEIN		;get the input line
	DEX
	DEX
	STX	MAXCL
	CMP	#EOF
	BNE	NTEOF		;continue if not eof
	LDA	#CR		;stuff cr and lf
	STA	ECHBUF
	LDA	#LF
	STA	ECHBUF+1
	LDX	#255		;set column to -1
	STA	MAXCL
	LDX	#1
	STX	MAXECH		;set max echo col to 1
	JMP	H10
;not eof so process line
NTEOF	SED			;set decimal mode
	LDA	LINENO+1	;bump line number by 1
	ADC	#1
	STA	LINENO+1
	LDA	LINENO
	ADC	#0
	STA	LINENO
	CLD			;back to binary mode
	JSR	FNDNB		;get first non-blank
	BCS	H88
;blank line so ignore
HL0000	LDY	#0
HLY000	LDX	#0
	TXA
	JMP	LTS1
;there is something in the line other than blanks
H88	JSR	NUMRC		;see if first char a number
	BCC	H88B		;jump if not
	JSR	INCRP		;number so go to next char
	STX	PARST		;prepare to use
	STX	COLP
	BCS	HL0000		;hit eol so ignore line
	BCC	H88		;not eol so loop until past number
;at this point line number has been ignored & we are ready to continue parsing
;this is also main loop entry after successive fields are evaluated
H88B	JSR	FNDNB		;find non-blank
	BCC	HL0000		;none so ignore blank line
H88A	LDA	LINE,X		;get the character
	CMP	#semico		;if start of comment then also ignore
	BEQ	HL0000
	JSR	FNDEN		;find end of character sequence
	BCS	H1		;jump if found
HL303B	LDA	#3		;else ERR03 - illegal or missing opcode
HL3AAB	LDY	#3
HLYAAB	LDX	CSB
	JMP	LTS1
;have found a character string - start testing it
H1	LDX	CSB		;go back to string start
	LDA	LINE,X		;get char
	CMP	#'.'		;see if start of directive
	BNE	*+5		;if not then jump
	JMP	H5		;if is go to directive processing section
	CMP	#'*'		;see if PC processing
	BNE	*+5		;if not then jump
	JMP	H102		;if is process PC change
;at this point we either have a label or an opcode but need to check length
	LDY	CSL		;get char string length
	CPY	symlen		;compare to max
	BCC	H76		;ok is less
	beq	h76		;ok if same
;ERR09 - label too long
	LDA	#9
HL3AAX	LDY	#3
	JMP	LTS1
;there is a string that may be label or opcode
H76	STY	LEN		;set length
	JSR	CONSYM		;try to construct symbol
	BCS	h76ok		;jump if all alpha-numeric
	LDA	#10		;else ERR10 - non-alphanumeric
	BNE	HL3AAX
h76ok	LDA	CSL		;see if symbol is right length
	CMP	#3		;for opcode
	BNE	cslnt3		;jump if not
	JSR	OPFND		;see if opcode
	BCC	cslnt3		;not so process as label
	JMP	H201		;is so process opcode
;at this point we have a string that looks like a label
cslnt3	LDA	LABL		;first see if already a label
	BNE	HL303B		;ERR03 if is - illegal opcode
	INC	LABL		;but now say there is a label
	LDX	COLP		;point to start
	JSR	ALPH		;see if alpha
	BCS	H94		;ok if is
	LDA	#8		;else ERR08 - label does not start with alpha
	BNE	HL3AAX
;label starts with alpha
H94	LDA	SYM+1		;see if single character long
	CMP	#blank		;jump more than one char
	BNE	H93
	LDA	SYM
	CMP	#'A'		;test for illegal label
	BEQ	H97		;A is illegal
	CMP	#'X'
	BEQ	H97		;X is illegal
	CMP	#'Y'
	BEQ	H97		;Y is illegal
	CMP	#'S'
	BEQ	H97		;S is illegal
	CMP	#'P'
	BNE	H93		;not P so legal
;ERR20 - label is a reserved single character
H97	LDA	#20
	JMP	HL3AAX
;label is not reserved and is not opcode
H93	STX	LSST
	LDX	#0
;push symbol and then symbol length onto stack
H8845	LDA	SYM,X		;get char
	PHA			;push onto stack
	INX			;bump pointer
	CPX	symlen		;compare to max
	BNE	H8845		;loop if more
	LDA	CSL		;now get length
	PHA			;and push it
	LDX	CSE		;point to end of string
	INX			;and go one past
	STX	COLP		;save as pointer
	JSR	FNDNB		;look for non blank
	BCC	H120		;none found
	LDA	LINE,X
	CMP	#'='
	BEQ	H121
H120	JSR	FIND		;see if exiting label
	BCC	H95		;either not found or not not defined
;label is existing label and is defined so make sure it is not being changed
	LDA	VAL		;first test high
	CMP	PC+1
	BNE	MRO2		;error if different
	LDA	VAL+1		;now test low
	CMP	PC
	BEQ	H95A		;ok if same
;ERR02 - label previously defined
MRO2	LDY	#3
	JMP	HLY02L
;at this point we have a valid label so create or update entry
;v flag must not have been altered since jsr find was executed at h120
;as that flag determines if insert creates new entry or just updates
;value of existing entry
H95	LDA	PC+1		;set val to current pc
	STA	VAL
	LDA	PC
	STA	VAL+1
	JSR	INSERT		;do insert or update
H95A	LDX	CSB		;test start of string
	CPX	LSST		;against label start
	BEQ	*+5		;if same then done with line
	JMP	H88A		;else loop to find next field
	JMP	HL0000
;process PC reference statement
H102	INC	ORG		;set flag to say an org is in line
	INC	COLP
	STX	LSST
	JSR	FNDNB		;find next non blank
	BCS	H103		;got one so continue
	JMP	HL307B		;else ERR07 - ran off line
H103	LDA	LINE,X		;get that next char
	CMP	#'='		;see if =
	BEQ	H121		;is so ok
	LDA	#22		;if not is ERR22 - expecting = for org
	JMP	HL3AAX
;entry point for normal * = processing as well as <label> = processing
H121	INC	ORG		;make sure flag set
	JSR	INCRP		;bump pointer
	STX	COLP		;and save
	BCC	*+5		;ok if not eol
	JMP	HL307B		;else ERR07 - ran off line
	JSR	FNDNB		;find a non-blank
	BCS	H104		;got one
	LDY	#0		;else ERR
	JMP	HLY07E
H104	JSR	EVAL
	LDA	RETURN
	BMI	H105
	BNE	H8806
	LDA	#11		;else ERR11 - forward reference in equate or org
	JMP	HL3AAJ
H8806	LDA	#13		;ERR13 - invalid expression
	JMP	HL3AAJ
H105	LDA	ORG
	CMP	#1
	BEQ	H9
	LDA	#1
	AND	FLAGS+1
	BEQ	H150
	LDX	CSB
	LDA	#21
	LDY	#0
	JSR	LTINS
	LDX	#0
	STX	PC
	STX	PC+1
	JMP	NXT
H150	LDX	#0
	TXA
	TAY
	JSR	LTINS
	LDA	EXP
	STA	PC+1
	LDA	EXP+1
	STA	PC
	JMP	NXT
H9	PLA
	STA	CSL
	LDX	symlen		;get length
	dex			;and drop
H8846	PLA
	STA	SYM,X
	DEX
	BPL	H8846
	JSR	FIND
	BCC	H106
	LDA	VAL
	CMP	EXP
	BNE	MR01
	LDA	VAL+1
	CMP	EXP+1
	BEQ	H106A
MR01	LDY	#0
HLY02L	LDA	#2
	LDX	LSST
	JMP	LTS1
H106	LDA	EXP
	STA	VAL
	LDA	EXP+1
	STA	VAL+1
	JSR	INSERT
H106A	JMP	HL0000
;assembler directive processing
;search directive table and process if found
H5	LDX	CSB		;get string start
	INX			;go past "."
	LDA	#<ASMDIR	;initialize pointer to table start
	STA	TBLPTR
	LDA	#>ASMDIR
	STA	TBLPTR+1
	LDA	#3		;set length to 3
	STA	LEN
	JSR	CONSYM		;build a symbol
	DEX			;drop index so pointing to third char
;loop entry for search
H8847	JSR	INCRP		;go to next char
	BCS	H8849		;jump if eol
	LDA	LINE,X		;else get char
	CMP	#blank		;test against blank
	BNE	H8847		;loop if not to handle full length directives
H8849	STX	COLP		;save pointer
	BCS	H8835		;jump if valid directive
HL014B	LDY	#0		;else say ERR14 - invalid directive
	LDA	#14
	JMP	HLYAAB
;start testing symbol against valid directive table entries
H8835	LDX	#NUMASM-1	;set x to last entry
H9938	LDY	#2		;y is char index starting at end
H9939	LDA	SYM,Y		;get symbol char
	CMP	(TBLPTR),Y	;compare to table entry char
	BNE	H9940		;jump if no match
	DEY			;match so far so drop index
	BPL	H9939		;loop if more to test
	TXA			;full match so set x to 2x
	ASL	A
	TAX
	LDA	ASMJMP,X	;get entry address and
	STA	TBLPTR		;set pointer
	LDA	ASMJMP+1,X
	STA	TBLPTR+1
;following line may be redundant - need to double check
	LDA	FLAGS		;get flags for directive use
	JMP	(TBLPTR)	;go to entry point
;there was not a match so try next table entry
H9940	LDA	TBLPTR
	CLC
	ADC	#3
	STA	TBLPTR
	BCC	*+4
	INC	TBLPTR+1
	DEX			;drop counter
	BPL	H9938		;loop if more
	BMI	HL014B		;else error
;execute .PAG directive
PAGE	LDA	FLAGS		;get flags
	AND	#%00000100	;test list
	BEQ	NOPAGE		;branch if no list
	lda	$100+2		;get sim page
	sta	getff+2
getff	lda	$FF00+62	;get formfeed code
	JSR	OUTPUT		;send it
NOPAGE	JMP	HL0000		;and continue
;process .byt directive
H111	LDY	#1		;value for .byt for flag
	BNE	H13A		;jump always
;process .wor directive
H113	LDY	#2		;value for .wor for flag
H13A	STY	BYWOR		;save .byt or .wor flag
	JSR	FNDNB		;find next non-blank
	BCS	HBW10
	JMP	HLY07E
HBW10	JSR	EVAL		;evaluate expression
	LDA	RETURN		;get return code
	BEQ	HBW40		;undefined symbol
	BPL	HBW60		;uninterpretable
	STX	COLP		;else set pointer to next
	LDX	BYWOR		;get flag
	LDY	#0		;point to low part of code
	LDA	EXP+1		;get low part of result
	STA	CODE,Y		;save in code buffer
	CPX	#2		;see if .wor
	BNE	HBW20A		;jump if not
	LDA	EXP		;if .wor get high part
	INY			;bump code index
	STA	CODE,Y		;and save high part
HBW20A	LDA	FLAGS+1
	AND	#9
	BNE	HBW20B
	CPX	#1
	BNE	HBW20C
	LDA	EXP
	BEQ	HBW20C
HBW20B	LDY	BYWOR
	LDA	#4
	LDX	CSB
	JMP	HIYAAX
HBW20C	LDY	BYWOR
HIY00X	LDA	#0
HIYAAX	JSR	LTINS
HBW30	LDX	COLP		;get pointer
	CPX	MAXCL		;see if at max
	BEQ	*+4		;ok if is
	BCS	EXTBYT		;done if past last
	LDA	LINE,X		;and char
	CMP	#','		;see if comma
	BEQ	GOTCMA		;ok if is
	CMP	#blank		;see if space
	BEQ	EXTBYT		;exit if is
BADOPR	JMP	HL318B		;bad operand format
EXTBYT	JMP	NXT		;else end of line
GOTCMA	JSR	INCRP
	STX	COLP
	JSR	FNDNB
	BCS	HBW10
	JMP	HL307B
HBW40	LDA	#6
	BNE	HIJAAJ
;expression evaluation said expression uninterpretable
;so test for string
HBW60	LDA	LINE,X		;get first char
	sta	strdel		;save for later use
	CMP	#apost		;see if '
	beq	hbw60v		;is so may be string
	cmp	#quote		;also check "
	BNE	HBW60A		;not so is ERR13 - invalid exp
hbw60v	CPX	CSB		;may be start of string so check
	BNE	HBW60A		;jump to ERR13 if index and string start not =
	LDY	BYWOR		;get mode flag
	CPY	#1		;see if .byt
	BEQ	HBW60B		;is so get string
HBW60A	LDA	#13
HIJAAJ	PHA			;save error code
	JSR	FNCMP		;skip to next field
	PLA			;get error code back
	LDY	BYWOR
	LDX	ERCOL
	JMP	HIYAAX
;start processing .byt '....'
HBW60B	STX	COLP		;save pointer
	LDY	#0		;set index to start
;loop entry for .byt '....' processing
HBW70	LDX	COLP		;get pointer
	JSR	INCRP		;go to next char
	STX	COLP		;save pointer
	BCC	*+5		;jump is not eol
	JMP	HLY07B		;else ran off eol error
	LDA	LINE,X		;get char
	cmp	strdel		;see if same as start delimiter
	BNE	HBW80		;if not go test for valid
;have a valid string delimiter
	LDX	COLP		;get pointer
	JSR	INCRP		;go to next char
	STX	COLP		;save pointer
	BCS	HIY00X		;if eol go to eol processing
	LDA	LINE,X		;get char
	CMP	strdel		;see if same as first delimiter
	BNE	HIY00X		;not so not double
;have a character - see if valid
HBW80	CMP	#blank		;see if less than space
	BCC	HBW80A		;is so enter 0
	CMP	#DELETE		;see if < delete
	BCC	HBW80B		;is so valid char
HBW80A	LDA	#0
HBW80B	STA	CODE,Y		;save char in code buffer
	INY			;point to next buffer position
	JMP	HBW70		;and loop for more
;process .opt directive
H301	JSR	FNDNB
	BCS	*+5
	JMP	HL0000
	LDX	CSB
	LDA	#3
	STA	LEN
	JSR	CONSYM
	BCS	*+5
	JMP	HL014B
	LDA	#<OPTDIR
	STA	TBLPTR
	LDA	#>OPTDIR
	STA	TBLPTR+1
	LDX	#NUMSAV-1
	JMP	H9938
;generate kim file
KIM	ORA	#%00100000	;set bit
	BNE	H390
;do not generate kim file
NOKIM	AND	#%11011111	;clear bit
	JMP	H390
H323	AND	#127
	JMP	H390
H302	ORA	#128
	BNE	H390
H303	ORA	#64
	BNE	H390
H304	AND	#191
	JMP	H390
H307	ORA	#16
	BNE	H390
H308	AND	#239
	JMP	H390
H311	ORA	#4
	BNE	H390
H312	AND	#251
H390	STA	FLAGS
H390A	JSR	FNCMP
	BCS	H8840
H8839	JMP	HL0000
H8840	LDA	LINE,X
	CMP	#','
	BNE	H8839
	INX
	STX	COLP
	JMP	H301
;opcode & operand psocessing section
;first clear flags and values
H201	LDA	#0
	STA	OPTYP
	STA	OPLEN
	STA	NOPV
	TAY
	LDA	OPBAS		;this was set by OPFND
	STA	CODE
	LDA	OPTEM
	CMP	#20
	BNE	H17
HL1000	LDY	#1
	JMP	HLY000
H17	LDA	CSE
	STA	COLP
	INC	COLP
	JSR	FNDNB
	BCS	H9917
	LDY	#3
;ERR07 - ran off line at CSE
HLY07E	LDA	#7
	LDX	CSE
	JMP	LTS1
H9917	LDA	LINE,X
	CMP	#semico
	BNE	H9934
HL307B	LDY	#3
HLY07B	LDA	#7
	JMP	HLYAAB
H9934	CMP	#'A'
	BNE	H39
	CPX	MAXCL
	BEQ	H9965
	LDY	LINE+1,X
	CPY	#blank
	BNE	H39
H9965	LDY	OPTEM
	LDA	KLTBL-1,Y
	BMI	HL305B
	CLC
	ADC	OPBAS
	STA	CODE
	JMP	HL1000
HL305B	LDA	#5
	JMP	HL3AAB
H39	CMP	#'#'
	BNE	H24
	LDA	#10
	JMP	H831
H24	CMP	#'('
	BNE	H23
	LDA	#5
H831	STA	OPTYP
	INC	CSB
	JSR	INCRP
	BCC	H23
	JMP	HL307B
;evaluate the operand
H23	JSR	EVAL
	LDA	RETURN		;test result code
	BMI	H20		;jump if it was good!
	LDA	OPTYP		;if bad see if was immediate mode
	CMP	#10
	BEQ	H9935		;if so may be single ascii char
	LDA	RETURN
	BEQ	H202
;at this point we have a goofy expression
;make a check for relative addressing so only two bytes
;get allocated during first pass
	lda	optem		;get template
	cmp	#14		;see if relative
	beq	bad2by		;if so allocate only two bytes
;goofy expression and 3 byte instruction
HL313J	LDA	#13
HL3AAJ	LDX	ERCOL
	JMP	HL3AAX
;bad expression and immediate mode
H9935	LDA	LINE,X		;get character
;first see if a single character
	CMP	#apost		;look for starting '
	BNE	BAD2BY		;no so say is bad
	JSR	INCRP		;bump pointer
	BCC	*+7		;jump if not at end
	LDY	#2		;else flag as error
	JMP	HLY07B
	LDA	LINE,X		;get char after '
	CMP	#blank		;see if smaller than space
	BCC	H9921		;is so value 0
	CMP	#DELETE		;see if smaller than DELETE
	BCC	H9922		;is so store as result
H9921	LDA	#0		;clear low byte (hl order)
H9922	STA	EXP+1		;store low (0 or char)
	LDA	#0		;high part always 0
	STA	EXP
	LDA	#%11110110	;set flag asno overflow & pos
	AND	FLAGS+1
	STA	FLAGS+1
	JSR	INCRP		;look for next char
;code at this point allows single character to be terminated by
;end of line or a blank - this is candidate for change to restrict
;syntax.
	BCS	H20		;reached EOL
	LDA	LINE,X		;get char
	CMP	#blank		;see if space
	BEQ	H20		;if so OK
;we have a bad 2-byte instruction so ERR 13
BAD2BY	LDA	#13
hl2aaj	LDX	ERCOL
	LDY	#2
	JMP	LTS1
H202	INC	NOPV
	LDA	#2
	STA	OPLEN
H20	JSR	FNCMP		;find non-embedded , or )
	BCC	H500		;jump if none found
	LDA	LINE,X		;get the char
	CMP	#')'
	BNE	H51
	INC	OPTYP
	INC	OPTYP
	LDA	OPBAS
	CMP	#$4C
	BEQ	H140
	JSR	INCRP
	BCC	*+5		;ok if a char
	JMP	HL307B
	LDA	LINE,X		;get char
	CMP	#','		;see if comma
	BEQ	H51A		;branch if n),
	BNE	HL318B		;else n) is illegal
H51	LDA	LINE,X
	CMP	#','
	BNE	H203
	LDA	OPBAS		;get base opcode
	CMP	#$4C		;see if JMP
	BNE	H51A		;jump if not
;if is then is illegal operand for JMP
HL318B	LDA	#18		;error 18
	JMP	HL3AAB
H51A	JSR	INCRP		;look for next char
	BCC	H203		;jump if OK
	JMP	HL307B
H203	LDA	LINE,X		;get char
	CMP	#'X'
	BNE	H25
	INC	OPTYP
	JMP	H40
H25	CMP	#'Y'
	BEQ	H27
	LDA	#12
	JMP	HL3AAX
H27	INC	OPTYP
	INC	OPTYP
	BNE	H40
H500	LDA	OPBAS		;get base opcode
	CMP	#$4C		;see if JMP
	BNE	H40		;jump if not
H140	LDA	OPTYP
	BNE	H145
H140A	LDY	#2
	STY	OPLEN
	JMP	H46
H145	CMP	#7
	BNE	HL318B
	LDA	#32
	JSR	INCRP
	BCS	H140A
	LDY	LINE,X
	CPY	#blank
	BEQ	H140A
	BNE	HL318B
H40	LDA	NOPV
	BNE	H41
	LDA	#2
	STA	OPLEN
	LDA	OPTEM
	CMP	#14
	BNE	H22
	LDA	PC
	STA	TEMP
	LDA	PC+1
	STA	TEMP+1
	JSR	RELADR
	BCS	HOP70
	lda	#17		;relative branch out of range error
hl2aab	ldy	#2		;do a two byte error for code in a
	jmp	hlyaab		;do it
HOP70	LDA	#0
	STA	EXP
H22	LDA	OPTYP
	CMP	#6
	BCC	H400
	CMP	#10
	BCS	H400
	JSR	INDADR
	BCS	H400
	lda	#19		;indirect operand out-of-range
	jmp	hl2aaj		;do two byte error
H400	LDA	EXP
	BNE	H41
	LDA	#1
	STA	OPLEN
	LDA	OPTYP
	CLC
	ADC	#2
	STA	OPTYP
H50	CMP	#13
	BCC	H45
	LDA	#15
	JMP	HL3AAB
H41	LDA	OPTYP
	CLC
	ADC	#13
	STA	OPTYP
H47	CMP	#16
	BCS	H49
H45	TAY
	DEY
	LDA	KLUDG,Y
	CLC
	ADC	OPTEM
	TAY
	LDA	KLTBL,Y
	BPL	H46
H49	LDA	NOPV
	BEQ	H48
	LDA	OPLEN
	CMP	#2
	BEQ	*+5
	JMP	HL318B
	DEC	OPLEN
	LDA	OPTYP
	SEC
	SBC #11
	STA	OPTYP
	JMP	H50
H48	LDA	OPLEN
	CMP	#1
	BEQ	*+5
	JMP	HL318B
	INC	OPLEN
	LDA	OPTYP
	CLC
	ADC	#11
	STA	OPTYP
	JMP	H47
H46	CLC
	ADC	OPBAS
	LDY	#0
	STA	CODE,Y
	LDA	NOPV
	BNE	HL301X
	INY
	LDA	EXP+1
	STA	CODE,Y
	INY
	LDA	OPLEN
	CMP	#1
	BEQ	H9931A
	LDA	EXP
	STA	CODE,Y
H9931A	LDA	#9
	AND	FLAGS+1
	BEQ	H9931B
HLJ04B	LDY	OPLEN
	INY
	LDA	#4
	JMP	HLYAAB
H9931B	LDA	OPLEN
	CMP	#1
	BNE	HLJ000
	LDA	EXP
	BNE	HLJ04B
HLJ000	LDY	OPLEN
	INY
	JMP	HLY000
HL301X	LDA	CODE
	LDY	#3
	AND	#$1F
	CMP	#$10
	BNE	*+3
	DEY
	LDA	#1
;general error handler
;first inserts an error code into table
;then resets stack so that system returns to recovery point
;regardless of how far down the parser has gone.
;ASM resets stack to $FF so this is what defines recovery point
;	STACK = $FD --> after JSR DOPASS (either 1st or 2nd)
;	STACK = $FB --> after JSR PROCES
;c=0 so DOPASS will try next line
LTS1	JSR	LTINS		;save code
NXT	LDX	#$FB		;recover to JSR PROCES
	TXS
	CLC			;not EOF
	RTS
;do one pass through the source file
DOPASS	LDA	#SRCBUF+SRCLNG*256/256	;set index
	LDY	#SRCBUF+SRCLNG/256	;to
	STA	SRCIND		;illegal
	STY	SRCIND+1	;value
	JSR	PROCES
	BCC	*-3
	RTS
;-------------------------------
;MAIN PROCESSING ROUTINE
;-------------------------------
MAIN	LDA	#<STRMSG	;point to
	LDY	#>STRMSG	;start message
	JSR	WRCNMS		;write it
;clear page zero
	LDX	#2		;set index
	LDA	#0		;clear a
CLRZP	STA	$00,X		;clear mem
	inx			;bump count
	CPX	#lastzp		;compare to end
	BNE	CLRZP		;loop if more
;make sure SYMLEN at least 6
	lda	symlen		;get symbol length
	cmp	#6		;and test
	bcs	symlok		;ok if >= 6
	lda	#6		;else force to 6
	sta	symlen
;check default FCB for valid UFN for source
symlok	LDX	#8
SFB	LDA	DFLFCB,X
	CMP	#'?'
	BEQ	BDF		;is an AFN so not valid
	STA	SRCFCB,X
	STA	KIMFCB,X
	STA	LSTFCB,X	;insert in list fcb
	DEX
	BPL	SFB
	BMI	*+5
BDF	JMP	DOSERR		;abort for disk error
	lda	dflfcb+9	;get source loc if any
	cmp	#blank		;see if blank
	beq	usedfl		;use default if is
	jsr	chkdrv		;check for legal
	sta	srcfcb		;and set
	lda	dflfcb+10	;try for kim
	cmp	#blank		;see if none
	beq	usedfl		;use default if so
	cmp	#'Z'		;see if Z
	bne	trykah		;if not try for a-h
	sec			;else set no kim flag
	ror	nkmflg
	bmi	tstprn		;then go try prn
trykah	jsr	chkdrv		;else go check
	sta	kimfcb		;and set
tstprn	lda	dflfcb+11	;try list
	cmp	#blank		;do same for it
	beq	usedfl		;if blank
	cmp	#'X'		;see if X
	bne	trylst		;if not try Z
	sec			;set console output
	ror	lstflg
	bmi	usedfl		;and press on
trylst	cmp	#'Z'		;see if Z
	bne	tryah		;if not try a to h
	sec			;set no list flag
	ror	nlsflg
	bmi	usedfl		;and press
tryah	jsr	chkdrv		;then check
	sta	lstfcb		;and set
usedfl	JSR	SSRFCB
	JSR	OPNFIL
	BEQ	BDF
	JSR	DLTKIM
	bit	nkmflg		;test no kim flag
	bmi	skpkim		;skip if set
	JSR	SKMFCB
	JSR	CRTFIL
	BEQ	BDF
	JSR	SKMFCB
	JSR	OPNFIL
	BEQ	BDF
skpkim	JSR	SLSFCB		;point to list fcb
	JSR	DLTFIL		;delete it
	lda	lstflg		;see if no .prn file
	ora	nlsflg
	bmi	skplst		;if so skip ahead
	JSR	SLSFCB		;point again
	JSR	CRTFIL		;now make it
	BEQ	BDF		;exit if bad
	JSR	SLSFCB		;point once more
	JSR	OPNFIL		;open it
	BEQ	BDF		;exit if bad
skplst	LDA	#%11110100	;set default
	STA	FLAGS		;flags
;calculate symbol table start address
	lda	#<sym		;get buffer start
	ldy	#>sym
	clc			;no add symbol length
	adc	symlen
	sta	stsave		;set low
	bcc	sthiok		;high ok if no carry
	iny			;else bump high
sthiok	sty	stsave+1	;save high
;now calculate upper limit
	LDA	PEM+1		;get pem address
	LDY	PEM+2
	SEC			;drop by symbol length
	SBC	symlen
	STA	TBLSZ
	BCS	*+3
	DEY
	STY	TBLSZ+1
	sec			;drop by two more
	lda	tblsz
	sbc	#2
	sta	tblsz
	bcs	ntborw		;done if no borrow
	dec	tblsz+1
ntborw	LDX	#$FF
	TXS
	lda	#<ps1msg	;send start of pass 1 msg
	ldy	#>ps1msg
	jsr	wrcnms
	JSR	DOPASS
	LDA	#<SRTMSG	;point to
	LDY	#>SRTMSG	;end of pass one message
	JSR	WRCNMS		;print it
	LDA	#0
	STA	LINENO
	STA	LINENO+1
	STA	PC
	STA	PC+1
	STA	ERCT
	STA	ERCT+1
	STA	BYTCNT
	STA	SRCFCB+12
	sta	srcfcb+13	;clear both extent bytes
	STA	SRCFCB+32
	LDA	#%11110100	;set default
	STA	FLAGS		;flags
	LDA	#$FF		;change
	STA	PASNUM		;pass number
	JSR	SSRFCB
	JSR	OPNFIL
	JSR	SORT		;sort symbol table
	JSR	CCRLF		;send cr and lf to console
	lda	#<ps2msg	;send start of pass 2 msg
	ldy	#>ps2msg
	jsr	wrcnms
	JSR	CLKIND		;clear kim index
	JSR	CLLIND		;clear list index
	JSR	DOPASS
	LDA	#<ERNMSG	;point to
	LDY	#>ERNMSG	;error count message
	JSR	WRCNMS		;write it
	LDA	ERCT		;then high
	JSR	CNUMA		;byte of count
	LDA	ERCT+1		;then low
	JSR	CNUMA		;byte of count
	JSR	CCRLF		;send a last cr and lf
	bit	nkmflg		;test for no kim
	bmi	skkmfo		;done if set
	JSR	WRKMRC
FLSHKM	SEC			;see if
	LDA	KIMIND		;whole
	SBC	#<KIMBUF	;number
	AND	#127		;sectors
	BEQ	WHLREC		;branch if it is
	LDA	#EOF		;else insert
	JSR	KIMOUT		;an eof
	JMP	FLSHKM		;and loop
WHLREC	JSR	WRTKIM		;write last sector
	JSR	SKMFCB
	JSR	CLSFIL
skkmfo	lda	lstflg		;see if no list
	ora	nlsflg
	bmi	extsys		;exit if none
FLSHLS	SEC			;see if list
	LDA	LSTIND		;index a whole
	SBC	#<LSTBUF	;number sectors
	AND	#127		;of 128
	BEQ	WHLLST		;jump if it is
	LDA	#EOF		;else get an eof
	JSR	OUTPUT		;send to buffer
	JMP	FLSHLS		;and loop
WHLLST	JSR	WRTLST		;now write file
	JSR	SLSFCB		;point to it
	JSR	CLSFIL		;close it
extsys	JMP	WRMBTE
;messages
ps1msg	.byte	"START OF PASS 1",cr,lf,"$"
ps2msg	.byte	"START OF PASS 2",cr,lf,"$"
ENDMSG	.byte	"END OF PASS 2$"
STRMSG	.byte	"DOS/65 ASSEMBLER",CR,LF
	.byte	"VERSION 2.11-A",CR,LF,"$"
ildmsg	.byte	"ILLEGAL DRIVE DESIGNATOR$"
SRTMSG	.byte	"END OF PASS 1",CR,LF
	.byte	"SORTING SYMBOL TABLE"
	.byte	" - PLEASE WAIT$"
ERNMSG	.byte	"NUMBER OF ERRORS = $"
ERRMSG	.byte	"**ERROR**$"
PERMSG	.byte	CR,LF,"DOS/65 FILE ERROR - ASSEMBLY "
	.byte	"ABORTED$"
;error message vector table
ERRVEC	.word	0,ERR01,ERR02,ERR03,ERR04
	.word	ERR05,ERR06,ERR07,ERR08,ERR09
	.word	ERR10,ERR11,ERR12,ERR13,ERR14
	.word	ERR15,ERR16,ERR17,ERR18,ERR19
	.word	ERR20,ERR21,ERR22,ERR23,ERR24
	.word	ERR25
;assembler error messages
ERR01	.byte	"UNDEFINED SYMBOL$"
ERR02	.byte	"LABEL PREVIOUSLY DEFINED$"
ERR03	.byte	"ILLEGAL OR MISSING OPCODE$"
ERR04	.byte	"ADDRESS NOT VALID$"
ERR05	.byte	"ACCUMULATOR MODE NOT ALLOWED$"
ERR06	.byte	"FORWARD REFERENCE IN .BYT OR "
	.byte	".WOR$"
ERR07	.byte	"RAN OFF END OF LINE$"
ERR08	.byte	"LABEL DOES NOT BEGIN WITH "
	.byte	"ALPHABETIC CHARACTER$"
ERR09	.byte	"LABEL TOO LONG$"
ERR10	.byte	"LABEL OR OPCODE CONTAINS "
	.byte	"NON-ALPHANUMERIC$"
ERR11	.byte	"FORWARD REFERENCE IN EQUATE "
	.byte	"OR ORG$"
ERR12	.byte	"INVALID INDEX - MUST BE X OR"
	.byte	" Y$"
ERR13	.byte	"INVALID EXPRESSION$"
ERR14	.byte	"UNDEFINED ASSEMBLER DIRECTIVE$"
ERR15	.byte	"INVALID OPERAND FOR PAGE ZERO "
	.byte	"MODE$"
ERR16	.byte	"INVALID OPERAND FOR ABSOLUTE "
	.byte	"MODE$"
ERR17	.byte	"RELATIVE BRANCH OUT OF RANGE$"
ERR18	.byte	"ILLEGAL OPERAND TYPE FOR THIS "
	.byte	"INSTRUCTION$"
ERR19	.byte	"OUT OF BOUNDS ON INDIRECT "
	.byte	"ADDRESSING$"
ERR20	.byte	"A,X,Y,S, AND P ARE RESERVED "
	.byte	"LABELS$"
ERR21	.byte	"PROGRAM COUNTER NEGATIVE - "
	.byte	"RESET TO 0$"
ERR22	.byte	"INVALID CHARACTER - EXPECTING"
	.byte	" = FOR ORG$"
ERR23	.byte	"SOURCE LINE TOO LONG$"
ERR24	.byte	"DIVIDE BY ZERO IN EXPRESSION$"
ERR25	.byte	"SYMBOL TABLE OVERFLOW$"
;directive and option jump table
ASMJMP	.word	H312,H311,H308,H307
	.word	NOKIM,KIM,H304,H303,H302
	.word	H323,H301,H10,PAGE
	.word	H113,H111
;assembler directives
ASMDIR	.byte	"BYTWORPAGENDOPT"
;option parameters
OPTDIR	.byte	"GENNOGSYMNOSKIMNOK"
	.byte	"ERRNOELISNOL"
;op-codes
OPRNDS	.byte	"ADCANDASLBCCBCSBEQBITBMI"
	.byte	"BNEBPLBRKBVCBVSCLCCLDCLI"
	.byte	"CLVCMPCPXCPYDECDEXDEYEOR"
	.byte	"INCINXINYJMPJSRLDALDXLDY"
	.byte	"LSRNOPORAPHAPHPPLAPLPROL"
	.byte	"RORRTIRTSSBCSECSEDSEISTA"
	.byte	"STXSTYTAXTAYTSXTXATXSTYA"
KLUDG	.byte	255,13,27,41,55,69,83,97
	.byte	111,125,139,153,167,181,195
KLTBL	.byte	255,255,255,255,4,255,255,255
	.byte	255,255,255,255,255,255,4,4
	.byte	255,255,0,4,0,4,0,0
	.byte	4,0,255,0,20,20,255,255
	.byte	16,255,255,20,255,16,255,16
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,16,255,20,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,0,0,32,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,255,255,16,16,255,255
	.byte	255,255,255,255,255,255,255,255
	.byte	255,255,8,255,255,255,255,0
	.byte	255,0,255,255,0,255,255,255
	.byte	12,12,0,0,8,12,8,12
	.byte	8,8,12,8,255,255,28,28
	.byte	255,255,24,255,255,28,255,255
	.byte	255,24,255,255,24,24,255,255
	.byte	255,255,255,255,255,255,$1C,255
	.byte	255,255
;template table that defines groups of opcodes
;that have the same addressing modes
;this comment includes 65c02 opcodes not yet in ASM
; 1=adc,and,cmp,eor,lda,ora,sbc
; 2=sta
; 3=jmp
; 4=jsr
; 5=asl,lsr,rol,ror
; 6=cpx,cpy
; 7=bit
; 8=ldy
; 9=stx
; 10=sty
; 11=ldx
; 12=dec,inc
; 13 not used
; 14=bcc,bcs,beq,bmi,bne,bpl,bra,bvc,bvs
; 15-19 not used
; 20=all implied (e.g., tay and brk)
KTMPL	.byte	1,1,5,14,14,14,7,14
	.byte	14,14,20,14,14,20,20,20
	.byte	20,1,6,6,12,20,20,1
	.byte	12,20,20,3,4,1,11,8
	.byte	5,20,1,20,20,20,20,5
	.byte	5,20,20,1,20,20,20,2
	.byte	9,10,20,20,20,20,20,20
;table of base opcodes arranged in same
;order as OPRNDS table
;the entry in this table is the actual opcode
;for template groups 4, 14, and 20.  For all
;others, the entry is the smallest numerical
;opcode for that mnemonic.
KCODE	.byte	97,33,6,144,176,240,36,48
	.byte	208,16,0,80,112,24,216,88
	.byte	184,193,224,192,198,202,136,65
	.byte	230,232,200,76,32,161,162,160
	.byte	70,234,1,72,8,104,40,38
	.byte	$66,64,96,225,56,248,120,129
	.byte	134,132,170,168,186,138,154,152
;source fcb
SRCFCB	.byte	0
	*=	*+8
	.byte	"ASM",0,0,0
	*=	*+17
	.byte	0
;kim fcb
KIMFCB	.byte	0
	*=	*+8
	.byte	"KIM",0,0,0
	*=	*+17
	.byte	0
;list fcb
LSTFCB	.byte	0
	*=	*+8
	.byte	"PRN",0,0,0
	*=	*+17
	.byte	0
;source disk buffer
SRCBUF
	*=	*+SRCLNG
;kim disk buffer
KIMBUF
	*=	*+KIMLNG
;list disk buffer
LSTBUF
	*=	*+LSTLNG
;code buffer
CODE
	*=	*+LINESZ-4
;line buffer
LINE
	*=	*+LINESZ+2
;input echo buffer
ECHBUF				;echo buffer
	*=	*+LINESZ+2
;symbol buffer
;length is determined by symlen
sym
	.END
