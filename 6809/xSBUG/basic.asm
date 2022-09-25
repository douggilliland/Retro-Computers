;=====================================================
;*	WRITTEN 20-OCT-77 BY JOHN BYRNS
;*	REVISED 30-DEC-77
;*	REVISED 18-JAN-78
;*	REVISED 10-APR-78
;*	REVISED 08-MAY-79 TO ELIMINATE USE OF SP
;*	REVISED 24-JAN-80 TO USE 6801 ON CHIP RAM
;*	REVISED 26-JAN-80 FOR NEW 6801 INSTRUCTIONS
;*	REVISED 24-JUL-81 FOR WHISTON BOARD
;*	REVISED 24-SEP-81 INCLUDE USER FUNCTION
;*	REVISED 08-APR-82 MAKE STANDALONE INCLUDE HEX CONSTANTS AND MEM FUNCTION
;*	REVISED 21-NOV-84 FOR 6809
;*	REVISED FEB 94 ADAPTED TO SIMULATOR AND BUGFIXES BY L.C. BENSCHOP.
;*
; Bob Applegate (bob@corshamtech.com) pulled the
; source from GITHUB:
;
;    https://github.com/6809/sbc09/tree/master/basic
;
; I've made some changes to run on the Corsham Tech
; SS-50 6809 board, added some comments, and done
; minor clean-up.  I also added conditional assembly
; to allow this to be included in an EPROM along
; with SBUG.
;
	if	~IN_SBUG
false	equ	0
true	equ	~false
	endif
;
;=====================================================
;* EDIT THE FOLLOWING EQUATES TO REFLECT THE
;* DESIRED ROM AND RAM LAYOUT
;
	if	IN_SBUG
;
; For SBUG, put the user code high in memory so other
; things can go low.  This is TINY BASIC; they won't
; need much memory!
;
LORAM	equ	$0080	;ADDRESS OF DIRECT PAGE SCRATCH RAM
BUFFER	equ	$1000	;ADDRESS OF MAIN RAM
RAMSIZ	equ	$2000	;SIZE OF MAIN RAM
RAMBEG	equ	BUFFER+BSIZE
RAMEND	equ	BUFFER+RAMSIZ
	else
LORAM	equ	$0080	;ADDRESS OF DIRECT PAGE SCRATCH RAM
BUFFER	equ	$1000	;ADDRESS OF MAIN RAM
RAMSIZ	equ	$2000	;SIZE OF MAIN RAM
ROMADR	equ	$b000	;ADDRESS OF TINY BASIC
RAMBEG	equ	BUFFER+BSIZE
RAMEND	equ	BUFFER+RAMSIZ
	endif
;
;=====================================================
; More options you can set...
;
; Command prompt character.
;
CMD_PROMPT	equ	':'
;
; Add the STOP command...
;
CMD_STOP	equ	false
;
;=====================================================
; ASCII constants
;
	if	~IN_SBUG
EOT	equ	$04
LF	equ	$0A
CR	equ	$0D
DEL	equ	$7F
	endif
CTRL_C	equ	$03
ETX	equ	$03
BELL	equ	$07
BS	equ	$08
CAN	equ	$18
BSIZE	equ	73
STKCUS	equ	48

;=====================================================
;

;
; SBUG vectors
;
	bss
	if	~IN_SBUG
	org	$f800
MONITOR	ds	2
NEXTCMD	ds	2
INCH	ds	2
INCHE	ds	2
INCHEK	ds	2
OUTCH	ds	2
PDATA	ds	2
PCRLF	ds	2
PSTRNG	ds	2
LRA	ds	2
	endif
*
	org	LORAM
USRBAS	ds	2
USRTOP	ds	2
STKLIM	ds	2
STKTOP	ds	2
CURSOR	ds	2
SAVESP	ds	2
LINENB	ds	2
SCRTCH	ds	2
CHAR	ds	2
ZONE	ds	1
MODE	ds	1
RESRVD	ds	1
LOEND	equ	*
*

	code
	if	~IN_SBUG
	org     ROMADR
	endif
;
;=====================================================
; Cold start is at offset 0000, warm start at offset
; 0003...
;
BASIC	jmp	SETUP
WARMS	lds	STKTOP
	bra	WMS05
SETUP	lds	#RAMEND-52
SET03	sts	STKTOP
CLEAR	ldd	#RAMBEG
	std	USRBAS
	std	USRTOP
CLR02	std	STKLIM
WMS05	ldx	#VSTR
	jsr	PUTSTR
CMDB	lds	STKTOP
	clr	MODE
	jsr	CRLF
	ldx	USRBAS
	stx	CURSOR
CMDE	ldx	#0000
	stx	LINENB
	tst	MODE
	bne	CMD01
	lda	#CMD_PROMPT
	jsr	PUTCHR
CMD01	jsr	GETLIN
	jsr	TSTNBR
	bcc	CMD02
	bvs	CMD05
	jsr	SKIPSP
	cmpa	#EOT
	beq	CMDE
	jsr	MSLINE
	bra	CMDB
CMD02	pshs	x
	ldx	USRTOP
	cmpx	STKLIM
	puls	x
	beq	CMD03
	jmp	ERRORR
CMD03	addd	#0
	beq	CMD05
CMD04	pshs	d
	subd	#9999
	puls	d
	bhi	CMD05
	bsr	EDITOR
	bra	CMDE
CMD05	jmp	ERRORS
VSTR	db	CR,LF,LF
	db	"TINY V1.37"
	db	EOT
******************************
******************************
EDITOR	pshs	d
	jsr	SKIPSP
	stx	SCRTCH
	lda	0,s
	ldx	CURSOR
	cmpx	USRTOP
	beq	ED00
	cmpd	0,x
	bcc	ED01
ED00	ldx	USRBAS
ED01	jsr	FNDLIN
	stx	CURSOR
	bcs	ED04
	stx	SAVESP
	leax	2,x
ED02	lda	,x+
	cmpa	#EOT
	bne	ED02
ED03	cmpx	USRTOP
	beq	ED35
	lda	,x+
	stx	CHAR
	ldx	SAVESP
	sta	,x+
	stx	SAVESP
	ldx	CHAR
	bra	ED03
ED35	ldx	SAVESP
	stx	USRTOP
	stx	STKLIM
ED04	ldx	SCRTCH
	ldb	#-1
ED05	incb
	lda	,x+
	cmpa	#EOT
	bne	ED05
	tstb
	bne	ED55
	leas	2,s
	rts
ED55	leax	-1,x
	addb	#4
ED06	leax	-1,x
	decb
	lda	0,x
	cmpa	#' '
	beq	ED06
	lda	#EOT
	sta	1,x
	clra
	ldx	USRTOP
	stx	CHAR
	addd	USRTOP
	std	USRTOP
	std	STKLIM
	jsr	TSTSTK
	bcc	ED07
	stx	USRTOP
	stx	STKLIM
	jmp	ERRORF
ED07	ldx	USRTOP
ED08	stx	SAVESP
	ldx	CHAR
	cmpx	CURSOR
	beq	ED09
	lda	,-x
	stx	CHAR
	ldx	SAVESP
	sta	,-x
	bra	ED08
ED09	puls	d
	ldx	CURSOR
	std	,x++
	stx	CHAR
ED10	ldx	SCRTCH
	lda	,x+
	stx	SCRTCH
	ldx	CHAR
	sta	,x+
	stx	CHAR
	cmpa	#EOT
	bne	ED10
	rts
;
;=====================================================
; PUTS will print a string pointed to by X.  Stops
; when an EOT ($04) is found.
;
PUTS01	jsr	PUTCHR
	leax	1,x
PUTSTR	lda	0,x
	cmpa	#EOT
	bne	PUTS01
	rts
;
;=====================================================
; Print CR/LF and clear the ZONE variable.
; Fortunately SBUG has a function to do
; some of the work, so use it.
;
CRLF	clr	ZONE
	if	~IN_SBUG
	jmp	[PCRLF]
	else
	jmp	PCRLF
	endif
;
;=====================================================
; Error handlers.
;
ERRORF	bsr	ER01
	db	"SORRY"
	db	EOT
;
ERRORS	bsr	ER01
	db	"WHAT?"
	db	EOT
;
ERRORR	bsr	ER01
	db	"HOW?"
	db	EOT
;
BREAK	bsr	ER01
	db	"BREAK"
	db	EOT
;
END	bsr	ER01
	db	"STOP"
	db	EOT
;
;=====================================================
; Common error handler.  On entry, the string
; immediately following the bsr to this function will
; be displayed.  Then the EOT is found, control is
; passed to the command handler.

ER01	bsr	CRLF	;CR/LF
	lda	#BELL	;Bell to get their attention
	jsr	PUTCHR
	ldd	LINENB	;print the line number
	jsr	PRNT4
	lda	#' '
	jsr	PUTCHR
	puls	x	;and then the error string
	bsr	PUTSTR
	bsr	CRLF
	jmp	CMDB	;back to command handler

******************************
******************************
GL00	bsr	CRLF
GETLIN	ldx	#BUFFER
GL03	jsr	GETCHR
	cmpa	#' '
	bcs	GL05
	cmpa	#$7F
	beq	GL03
	cmpx	#BUFFER+BSIZE-1
	bne	GL04
	lda	#BELL
	bra	GL02
GL04	sta	,x+
GL02	jsr	PUTCHR
	bra	GL03
GL05	cmpa	#BS
	beq	GL07
	cmpa	#CAN	;cancel line?
	beq	GL00	;yes, start over
	cmpa	#LF
	beq	GL09
	cmpa	#CR
	bne	GL03
	tst	MODE
	beq	GL06
	jsr	PUTCHR
	bra	GL08
GL06	pshs	x
	jsr	CRLF
	puls	x
GL08	lda	#EOT
	sta	0,x
	ldx	#BUFFER
	rts
GL07	cmpx	#BUFFER
	beq	GL03
	leax	-1,x
	lda	#BS
	jsr	PUTCHR
	lda	#' '
	jsr	PUTCHR
	lda	#BS
	bra	GL02
GL09	orcc	#$01
	ror	MODE
	bra	GL02
******************************
******************************
REM00	leax	1,x
REM	bsr	SKIPSP
	cmpa	#EOT
	bne	REM00
ENDSMT	jsr	TSTEOT
ENDS02	lda	LINENB
	ora	LINENB+1
	beq	REM09
REM05	cmpx	USRTOP
	bne	BNXTLIN
	jmp	ERRORR
BNXTLIN	ldd	,x++
	std	LINENB
MSLINE	jsr	TSTBRK
	bsr	IFAN
	bcs	IMPLET
	pshs	d
REM09	rts
IMPLET	jmp	LET
******************************
******************************
IFAN	bsr	SKIPSP
	stx	CURSOR
	ldx	#VERBT
FAN00	lda	,x+
	cmpa	#EOT
	bne	FAN04
	ldx	CURSOR
	orcc	#$01
	rts
FAN04	stx	CHAR
	ldx	CURSOR
	stx	SCRTCH
FAN05	ldx	SCRTCH
	cmpa	0,x
	bne	FAN07
	leax	1,x
	stx	SCRTCH
	ldx	CHAR
	lda	,x+
	stx	CHAR
	cmpa	#EOT
	bne	FAN05
	ldd	0,x
	ldx	SCRTCH
	andcc	#$FE
	rts
FAN07	ldx	CHAR
FAN08	lda	,x+
	cmpa	#EOT
	bne	FAN08
	leax	2,x
	bra	FAN00
******************************
******************************
NXTNSP	leax	1,x
SKIPSP	lda	0,x
	cmpa	#' '
	beq	NXTNSP
	rts
******************************
******************************
TSTHEX	bsr	TSTDIG
	bcc	TST05
	cmpa	#'A'
	bcs	TST03
	cmpa	#'F'
	bhi	TST03
	suba	#'A'-10
	andcc	#$FE
	rts
******************************
******************************
TSTLTR	cmpa	#'A'
	bcs	TST03
	cmpa	#'Z'
	bls	TST05
TST03	orcc	#$01
	rts
******************************
******************************
TSTDIG	cmpa	#'0'
	bcs	TST03
	cmpa	#'9'
	bhi	TST03
	suba	#'0'
TST05	andcc	#$FE
	rts
******************************
******************************
TSTVAR	bsr	SKIPSP
	bsr	TSTLTR
	bcs	TSTV03
	tfr	a,b
	lda	1,x
	bsr	TSTLTR
	bcc	TST03
	leax	1,x
	subb	#'A'
	aslb
	clra
	addd	STKTOP
TSTV02	andcc	#$FE
TSTV03	rts
******************************
******************************
USER	jsr	ARGONE
	pshs	d
	jsr	SKIPSP
	cmpa	#','
	beq	USER03
	cmpa	#')'
	orcc	#$01
	beq	USER05
USER02	jmp	ERRORS
USER03	leax	1,x
	jsr	EXPR
	pshs	a
	jsr	SKIPSP
	cmpa	#')'
	puls	a
	bne	USER02
	andcc	#$FE
USER05	leax	1,x
	stx	CURSOR
	jsr	[,s++]
	ldx	CURSOR
	andcc	#$FE
	rts
******************************
******************************
TSTSNB	jsr	SKIPSP
	cmpa	#'-'
	bne	TSTNBR
	leax	1,x
	bsr	TSTNBR
	bcs	TSN02
	nega
	negb
	sbca	#0
	andcc	#$FC
TSN02	rts
******************************
******************************
TSTNBR	jsr	SKIPSP
	jsr	TSTDIG
	bcc	TSTN02
	cmpa	#'$'
	orcc	#$01
	bne	TSTN09
TSTN20	leax	1,x
	clr	,-s
	clr	,-s
TSTN23	lda	0,x
	jsr	TSTHEX
	bcs	TSTN07
	leax	1,x
	pshs	x
	pshs	a
	ldd	3,s
	bita	#$F0
	bne	TSTN11
	aslb
	rola
	aslb
	rola
	aslb
	rola
	aslb
	rola
	addb	,s+
	std	2,s
	puls	x
	bra	TSTN23
TSTN02	leax	1,x
	pshs	a
	clr	,-s
TSTN03	lda	0,x
	jsr	TSTDIG
	bcs	TSTN07
	leax	1,x
	pshs	x
	pshs	a
	ldd	3,s
	aslb
	rola
	bvs	TSTN11
	aslb
	rola
	bvs	TSTN11
	addd	3,s
	bvs	TSTN11
	aslb
	rola
	bvs	TSTN11
	addb	0,s
	adca	#0
	bvs	TSTN11
	std	3,s
	leas	1,s
	puls	x
	bra	TSTN03
TSTN07	puls	d
	andcc	#$FE
TSTN09	andcc	#$FD
	rts
TSTN11	ldx	1,s
	leas	5,s
	orcc	#$03
	rts
******************************
******************************
TSTSTK	sts	SAVESP
	ldd	SAVESP
	subd	#STKCUS
	subd	STKLIM
	rts
******************************
******************************
PEEK	jsr	PAREXP
	pshs	d
	pshs	x
	ldb	[2,s]
	puls	x
	leas	2,s
	clra
	rts
******************************
******************************
POKE	jsr	PAREXP
	pshs	d
	jsr	SKIPSP
	cmpa	#'='
	beq	POKE05
	jmp	ERRORS
POKE05	leax	1,x
	jsr	EXPR
	jsr	TSTEOT
	pshs	x
	stb	[2,s]
	puls	x
	leas	2,s
	jmp	ENDS02
******************************
******************************
TSTFUN	jsr	SKIPSP
	stx	CURSOR
	ldx	#FUNT
	jsr	FAN00
	bcs	TSTF05
	pshs	d
TSTF05	rts
******************************
******************************
FUNT	db	"USR"
	db	EOT
	dw	USER
	db	"PEEK"
	db	EOT
	dw	PEEK
	db	"MEM"
	db	EOT
	dw	TSTSTK
	db	EOT
******************************
******************************
FLINE	ldx	USRBAS
FNDLIN	cmpx	USRTOP
	bne	FND03
	orcc	#$03
	rts
FND03	cmpd	0,x
	bne	FND05
	andcc	#$FC
	rts
FND05	bcc	FND07
	orcc	#$01
	andcc	#$FD
	rts
FND07	pshs	a
	lda	#EOT
	leax	1,x
FND09	leax	1,x
	cmpa	0,x
	bne	FND09
	puls	a
	leax	1,x
	bra	FNDLIN
******************************
******************************
RELEXP	bsr	EXPR
	pshs	d
	clrb
	jsr	SKIPSP
	cmpa	#'='
	beq	REL06
	cmpa	#'<'
	bne	REL03
	leax	1,x
	incb
	jsr	SKIPSP
	cmpa	#'>'
	bne	REL05
	leax	1,x
	addb	#4
	bra	REL07
REL03	cmpa	#'>'
	bne	EXPR06
	leax	1,x
	addb	#4
	jsr	SKIPSP
REL05	cmpa	#'='
	bne	REL07
REL06	leax	1,x
	addb	#2
REL07	pshs	b
	bsr	EXPR
	pshs	x
	subd	3,s
	tfr	cc,a
	lsra
	tfr	a,b
	asla
	asla
	pshs	b
	adda	,s+
	anda	#$06
	bne	REL08
	inca
REL08	clrb
	anda	2,s
	beq	REL09
	comb
REL09	clra
	puls	x
	leas	3,s
	rts
******************************
******************************
EXPR	clr	,-s
	clr	,-s
	jsr	SKIPSP
	cmpa	#'-'
	beq	EXPR05
	cmpa	#'+'
	bne	EXPR03
EXPR02	leax	1,x
EXPR03	bsr	TERM
EXPR04	addd	0,s
	std	0,s
	jsr	SKIPSP
	cmpa	#'+'
	beq	EXPR02
	cmpa	#'-'
	bne	EXPR06
EXPR05	leax	1,x
	bsr	TERM
	nega
	negb
	sbca	#0
	bra	EXPR04
EXPR06	puls	d
	rts
******************************
******************************
TERM	jsr	FACT
	pshs	d
TERM03	jsr	SKIPSP
	cmpa	#'*'
	beq	TERM07
	cmpa	#'/'
	beq	TERM05
	puls	d
	rts
TERM05	leax	1,x
	bsr	FACT
	pshs	x
	leax	2,s
	pshs	d
	eora	0,x
	jsr	ABSX
	leax	0,s
	jsr	ABSX
	pshs	a
	lda	#17
	pshs	a
	clra
	clrb
DIV05	subd	2,s
	bcc	DIV07
	addd	2,s
	andcc	#$FE
	bra	DIV09
DIV07	orcc	#$01
DIV09	rol	7,s
	rol	6,s
	rolb
	rola
	dec	0,s
	bne	DIV05
	lda	1,s
	leas	4,s
	tsta
	bpl	TERM06
	leax	2,s
	bsr	NEGX
TERM06	puls	x
	bra	TERM03
TERM07	leax	1,x
	bsr	FACT
MULT	pshs	b
	ldb	2,s
	mul
	lda	1,s
	stb	1,s
	ldb	0,s
	mul
	lda	2,s
	stb	2,s
	puls	b
	mul
	adda	0,s
	adda	1,s
	std	0,s
	bra	TERM03
******************************
******************************
FACT	jsr	TSTVAR
	bcs	FACT03
	pshs	x
	tfr	d,x
	ldd	0,x
	puls	x
FACT02	rts
FACT03	jsr	TSTNBR
	bcc	FACT02
	jsr	TSTFUN
	bcc	FACT02
PAREXP	bsr	ARGONE
	pshs	a
	jsr	SKIPSP
	cmpa	#')'
	puls	a
	bne	FACT05
	leax	1,x
	rts
FACT05	jmp	ERRORS
******************************
******************************
ARGONE	jsr	TSTSTK
	bcc	FACT04
	jmp	ERRORF
FACT04	jsr	SKIPSP
	cmpa	#'('
	bne	FACT05
	leax	1,x
	jmp	EXPR
******************************
******************************
ABSX	tst	0,x
	bpl	NEG05
NEGX	neg	0,x
	neg	1,x
	bcc	NEG05
	dec	0,x
NEG05	rts
******************************
******************************
TSTEOT	pshs	a
	jsr	SKIPSP
	cmpa	#EOT
	beq	TEOT03
	jmp	ERRORS
TEOT03	leax	1,x
	puls	a
	rts
******************************
******************************
LET	jsr	TSTVAR
	bcc	LET03
	jmp	ERRORS
LET03	pshs	d
	jsr	SKIPSP
	cmpa	#'='
	beq	LET05
	jmp	ERRORS
LET05	leax	1,x
	jsr	EXPR
	bsr	TSTEOT
	stx	CURSOR
	puls	x
	std	0,x
	ldx	CURSOR
	jmp	ENDS02
******************************
******************************
IF	jsr	RELEXP
	tstb
	beq	IF03
	jmp	MSLINE
IF03	jmp	REM
******************************
******************************
GOTO	jsr	EXPR
	bsr	TSTEOT
	jsr	FLINE
	bcs	GOSB04
	jmp	BNXTLIN
******************************
******************************
GOSUB	jsr	EXPR
	bsr	TSTEOT
	stx	CURSOR
	jsr	FLINE
	bcc	GOSB03
GOSB04	jmp	ERRORR
GOSB03	jsr	TSTSTK
	bcc	GOSB05
	jmp	ERRORF
GOSB05	ldd	CURSOR
	pshs	d
	ldd	LINENB
	pshs	d
	jsr	BNXTLIN
	puls	d
	std	LINENB
	puls	x
	jmp	ENDS02
******************************
******************************
RETURN	equ	TSTEOT
******************************
******************************
BPRINT	jsr	SKIPSP
PR01	cmpa	#','
	beq	PR05
	cmpa	#';'
	beq	PR07
	cmpa	#EOT
	beq	PR04
	cmpa	#'"'
	bne	PR02
	leax	1,x
	bsr	PRNTQS
	bra	PR03
PR02	jsr	EXPR
	pshs	x
	bsr	PRNTN
	puls	x
PR03	jsr	SKIPSP
	cmpa	#','
	beq	PR05
	cmpa	#';'
	beq	PR07
	cmpa	#EOT
	beq	PR04
	jmp	ERRORS
PR04	pshs	x
	jsr	CRLF
	puls	x
	bra	PR08
PR05	ldb	#$7
PR06	lda	#' '
	jsr	PUTCHR
	bitb	ZONE
	bne	PR06
PR07	leax	1,x
	jsr	SKIPSP
	cmpa	#EOT
	bne	PR01
PR08	leax	1,x
	jmp	ENDS02
*
*
PRQ01	jsr	PUTCHR
PRNTQS	lda	,x+
	cmpa	#EOT
	bne	PRQ03
	jmp	ERRORS
PRQ03	cmpa	#'"'
	bne	PRQ01
	rts
*
PRNTN	tsta
	bpl	PRN03
	nega
	negb
	sbca	#0
	pshs	a
	lda	#'-'
	jsr	PUTCHR
	puls	a
PRN03	ldx	#PRNPT-2
PRN05	leax	2,x
	cmpd	0,x
	bcc	PRN07
	cmpx	#PRNPTO
	bne	PRN05
PRN07	clr	CHAR
PRN09	cmpd	0,x
	bcs	PRN11
	subd	0,x
	inc	CHAR
	bra	PRN09
PRN11	pshs	a
	lda	#'0'
	adda	CHAR
	jsr	PUTCHR
	puls	a
	cmpx	#PRNPTO
	beq	PRN13
	leax	2,x
	bra	PRN07
PRN13	rts
PRNPT	dw	10000
	dw	1000
	dw	100
	dw	10
PRNPTO	dw	1
*
PRNT4	ldx	#PRNPT+2
	bra	PRN07
******************************
******************************
INPUT	jsr	TSTVAR
	bcs	IN11
	pshs	d
	stx	CURSOR
IN03	lda	#'?'
	jsr	PUTCHR
	jsr	GETLIN
IN05	jsr	SKIPSP
	cmpa	#EOT
	beq	IN03
	jsr	TSTSNB
	bcc	IN07
	ldx	#RMESS
	jsr	PUTSTR
	jsr	CRLF
	bra	IN03
IN07	stx	SCRTCH
	puls	x
	std	0,x
	ldx	CURSOR
	jsr	SKIPSP
	cmpa	#','
	beq	IN09
	jmp	ENDSMT
IN09	leax	1,x
	jsr	TSTVAR
	bcc	IN13
IN11	jmp	ERRORS
IN13	pshs	d
	pshs	x
	ldx	SCRTCH
	jsr	SKIPSP
	cmpa	#','
	bne	IN05
	leax	1,x
	bra	IN05
RMESS	db	"RE-ENTER"
	db	EOT
******************************
******************************
RUN	ldx	STKTOP
	lda	#52
RUN01	clr	,x+
	deca
	bne	RUN01
	ldx	USRBAS
	jmp	REM05
******************************
******************************
LIST	jsr	TSTNBR
	bcc	LIST03
	clra
	clrb
	std	CURSOR
	lda	#$7F
	bra	LIST07
LIST03	std	CURSOR
	jsr	SKIPSP
	cmpa	#','
	beq	LIST05
	lda	CURSOR
	bra	LIST07
LIST05	leax	1,x
	jsr	TSTNBR
	bcc	LIST07
	jmp	ERRORS
LIST07	jsr	TSTEOT
	pshs	d
	ldd	CURSOR
	stx	CURSOR
	jsr	FLINE
LIST09	cmpx	USRTOP
	beq	LIST10
	puls	d
	cmpd	0,x
	bcs	LIST11
	pshs	d
	ldd	,x++
	pshs	x
	jsr	PRNT4
	puls	x
	lda	#' '
	jsr	PUTCHR
	jsr	PUTSTR
	leax	1,x
	pshs	x
	jsr	CRLF
	puls	x
	jsr	TSTBRK
	bra	LIST09
LIST10	leas	2,s
	lda	#ETX
	jsr	PUTCHR
LIST11	ldx	CURSOR
	jmp	ENDS02
******************************
******************************
;=====================================================
; Keyword lookup.  Each entry has the keyword
; terminated with an EOT, then a pointer to the code
; that handles the keyword.
;
VERBT	db	"LET"
	db	EOT
	dw	LET
;
	db	"IF"
	db	EOT
	dw	IF
;
	db	"GOTO"
	db	EOT
	dw	GOTO
;
	db	"GOSUB"
	db	EOT
	dw	GOSUB
;
	db	"RETURN"
	db	EOT
	dw	RETURN
;
	db	"POKE"
	db	EOT
	dw	POKE
;
	db	"PRINT"
	db	EOT
	dw	BPRINT
;
	db	"INPUT"
	db	EOT
	dw	INPUT
;
	db	"REM"
	db	EOT
	dw	REM
;
	if	CMD_STOP
	db	"STOP"
	db	EOT
	dw	END
	endif
;
	db	"END"
	db	EOT
	dw	END
;
	db	"RUN"
	db	EOT
	dw	RUN
;
	db	"LIST"
	db	EOT
	dw	LIST
;
	db	"NEW"
	db	EOT
	dw	CLEAR
;
	db	"?"
	db	EOT
	dw	BPRINT
;
	if	IN_SBUG
	db	'!',EOT		;return to SBUG
	dw	MONITOR
	endif
;
; End of table indicated by an empty string, ie,
; first character is EOT.
;
	db	EOT
	page
;=====================================================
; TSTBRK is used to check if CTRL-C has been pressed.
; If not, this quietly returns.  If CTRL_C was
; pressed then this jumps to BREAK.
;
TSTBRK	bsr	BRKEEE 	
	beq	GETC05
GETCHR	bsr 	INEEE
	cmpa	#CTRL_C
	bne	GETC05
	jmp	BREAK
GETC05	rts
;
;=====================================================
; I/O Section.  This needs to be adjusted for your
; environment.  This version is based on SBUG with
; vectors in EPROM.
;
;=====================================================
; INEEE waits for the next key, clears the MSB, and
; returns the char in A.
;
INEEE	
	if	IN_SBUG
	jsr	INCH
	else
	jsr	[INCH]
	endif
	anda	#$7F
	rts
;
;=====================================================
; PUTCHR increments the ZONE variable, then falls into
; OUTEEE which then prints the character in A.
;
PUTCHR	inc	ZONE
OUTEEE	
	if	IN_SBUG
	jmp	OUTCH
	else
	jmp	[OUTCH]
	endif
;
;=====================================================
; BRKEEE returns with Z set if there is no character
; waiting at the input, or Z clear if there is.
;
BRKEEE	
	if	IN_SBUG
	jmp	INCHEK
	else
	jmp	[INCHEK]
	endif
endbas	equ	*
;
	if	~IN_SBUG
	end
	endif
