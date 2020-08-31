;debug - dos/65 debugger
;version 2.02-A
;released:	30 september 1982
;last revision:
;	29 march 2008
;		reformatted for ASM210 & TASM
;		deleted redundant copyright notice
;		eliminated page zero 0 & 1
;	30 march 2008
;		set minimum load address to tea
;		aligned start of run time on page boundary
;		corrected error near JMP (EXECUT)
;base addresses
btejmp	=	$100		;sim+3 entry
pemjmp	=	$103		;pem entry
dflfcb	=	$107		;default fcb
dflbuf	=	$128		;default buffer
minmem	=	$800		;minimum load address
tea	=	$800		;tea start
;zero page for setup
	*=	2
point				;relocate pointer
	*=	*+2
adjust				;relocate distance
	*=	*+2
lower				;lower limit
	*=	*+2
paglim				;upper page limit
	*=	*+1
length				;program length
	*=	*+2
newstr				;start after move
	*=	*+2
execut				;execute vector
	*=	*+2
from				;start for move
	*=	*+2
movcnt				;counter for move
	*=	*+2
;fixed parameters
lf	=	$a		;linefeeed
cr	=	$d		;return
eof	=	$1a		;end of file
semico	=	59		;semicolon
;set-up pointers
	*=	tea
	jmp	start		;go start
	.byte	"COPYRIGHT (C) 2008 -"
	.byte	" RICHARD A. LEARY"
;first use PEM JMP in page 1 to get vector to PEM so PEM
;link can be maintained.
start	lda	pemjmp+1	;set vector
	ldy	pemjmp+2	;to pem
	sta	vector		;from page
	sty	vector+1	;one jump
	sta	gotopm+1	;set message pem call address
	sty	gotopm+2
	ldx	#17-1		;initialize 17 bytes
setzpg	lda	inittb,X	;page
	sta	2,X		;zero
	dex			;variables
	bpl	setzpg		;and pointers
;zero page has been initialized
;now calculate destination start address for relocation and move
	sec			;subtract low of length
	lda	vector		;from low
	sbc	length		;pem location
	sta	newstr		;and save
	sta	pemjmp+1	;also in vector around debug
	sta	execut		;also in final link
	lda	vector+1	;get high
	sbc	length+1	;and subtract high
	sta	newstr+1	;and save
	sta	pemjmp+2
	sta	execut+1
;now calculate distance to move since point starts out set to
;pemvec location
	sec			;calculate
	lda	newstr		;distance
	sbc	point		;to
	sta	adjust		;relocate
	lda	newstr+1	;from new
	sbc	point+1		;and old
	sta	adjust+1	;start
;begin relocation
strtrl	ldy	#0		;get opcode
	lda	(point),Y	;from memory
	tay			;save in Y
	ldx	#7		;search seven
rlloop	tya			;get opcode
	and	table1-1,X	;remove bits
	eor	table2-1,X	;test rest
	beq	gotopc		;if zero a match
	dex			;else try
	bne	rlloop		;next
gotopc	ldy	table3,X	;get length/flag
	bpl	skipby		;no change if positive
	iny			;add one
	bmi	stsmpg		;exit if terminator
	iny			;else add one more
	lda	(point),Y	;get low
	tax			;save in X
	iny			;then get
	lda	(point),Y	;high
	cmp	paglim		;if at high limit
	bcs	norelc		;do nothing
	cmp	lower+1		;if above
	bne	trylow		;lower limit
	cpx	lower		;then
trylow	bcc	norelc		;do nothing
	pha			;else save high
	TXA			;add offset
	CLC			;to low
	ADC	adjust		;and then
	tax			;save
	PLA			;get high
	ADC	adjust+1	;add again
norelc	sta	(point),Y	;put back
	dey			;backup
	TXA			;get low
	sta	(point),Y	;save
	ldy	#3		;go up three
skipby	inc	point		;add one
	bne	noincy		;with
	inc	point+1		;carry
noincy	dey			;loop if
	bne	skipby		;more
	beq	strtrl		;then start over
;set sim page address
stsmpg	lda	btejmp+2	;get sim page
	sta	gtchln+2	;set size param addresses
	sta	gtlnsc+2
;disable interrupts before testing
	php			;save current status
	sei			;then disable
;see if interrupts allowed and set pointers
	lda	#$fe		;set pointer to vector
	ldy	#$ff
	sta	point
	sty	point+1
;loop back point for rom test
tsptrm	jsr	tstrom		;see if rom
	beq	wasrom		;jump if was
gotram	lda	(point),y	;else get low
	sta	irqvec		;and save
	iny			;now go for high
	lda	(point),y
	sta	irqvec+1	;and save
	lda	ibkvec+1	;get high of vector
	sta	(point),y	;and put at point
	dey			;do low
	lda	ibkvec
	sta	(point),y	;in same way
;send message saying IRQ/BRK vector has been set
	lda	#<setmsg	;point to message
	ldy	#>setmsg
setext	ldx	#9		;send message
gotopm	jsr	$ffff		;to console
	jmp	exrelc		;and continue
;at this point it has been determined that IRQ/BRK vector is in ROM
;but now test to see if it points to a JMP, either absolute or indirect.
;If that is the case see if the JMP operand can be modified.
wasrom	jsr	ldepnt		;do point load
	lda	(point),y	;get byte
	cmp	#$4c		;see if jmp opcode
	beq	isjmab		;jump if is
	cmp	#$6c		;see if jmp indirect
	bne	cnntst		;if not can not set
	jsr	bmppnt		;bump pointer
	jsr	ldepnt		;then (point) --> point
	jmp	tsptrm		;and loop back to start
;this is target when it has been determined that IRQ/BRK ca not be set
cnntst	ldy	#255		;set y to $ff
	sty	brkok		;to disable brk
;send message saying IRQ/BRK can not be set
	lda	#<ntsmsg	;point to message
	ldy	#>ntsmsg
	jmp	setext		;then continue
;it has been determined that IRQ/BRK points to a JMP - see if it
;can be changed
isjmab	jsr	bmppnt		;bump pointer past JMP
	jsr	tstrom		;see if rom
	beq	wasrom		;jump if was
	bne	gotram		;else go ram
;do actual move of debug execute module to correct location
EXRELC	ldy	#0		;clear index
	lda	(from),Y	;get byte
	sta	(newstr),Y	;move
	inc	from		;then
	bne	fromok		;bump
	inc	from+1		;pointers
fromok	inc	newstr		;both
	bne	NEWOK		;from and 
	inc	newstr+1	;to
NEWOK	sec			;now
	lda	movcnt		;decrement
	sbc	#1		;count
	sta	movcnt		;by one
	bcs	skpdec		;jump if no borrow
	DEC	movcnt+1	;decrement high
skpdec	ora	movcnt+1	;if not zero
	bne	EXRELC		;move more
;prepare to jump to new start + 3 to bypass jmp to true PEM
	CLC			;else
	lda	execut		;get start
	ADC	#3		;add three
	sta	execut		;save
	bcc	NOXQCY		;jump if no carry
	inc	execut+1	;else bump high
NOXQCY	jmp	(execut)	;then execute
;Relocation Tables
table1	.byte	$C,$1F,$D,$87,$1F,$FF,$3
table2	.byte	$C,$19,$8,$0,$10,$20,$3
table3	.byte	2,$FF,$FF,1,1,2,$FF,$FE
;Initialization Tables
inittb	.word	pemvec		;point
	.word	0		;adjust
	.word	tea-1		;lower
	.byte	$FF		;paglim
	.word	LAST-pemvec+1	;length
	.word	0		;newstr
	.word	0		;execut
	.word	pemvec		;from
	.word	LAST-pemvec+1	;movcnt
;messages
setmsg	.byte	"IRQ/BRK VECTOR SET$"
ntsmsg	.byte	"CAN NOT SET IRQ/BRK VECTOR$"
;load point from (point)
;exits with y=0
ldepnt	ldy	#0		;clear index
	lda	(point),y	;get low
	tax			;save in x
	iny			;y to one
	lda	(point),y	;get high
	sta	point+1
	stx	point
	dey			;set y to zero
	rts
;subroutine to check (point) for rom
;returns z=1 if rom or z=0 if ram
;returns with y=0
tstrom	ldy	#0		;clear index
	lda	(point),y	;get value
	pha			;save on stack
	tya			;clear a
	sta	(point),y	;store a zero
	lda	(point),y	;get it back
	bne	ptisrm		;is rom if not zero
	lda	#$ff		;set a to ff
	sta	(point),y	;and set
	cmp	(point),y	;then compare
	bne	ptisrm		;rom if different
	pla			;is ram so restore
	sta	(point),y
	lda	#$ff		;set z=0 for ram
	rts
ptisrm	pla			;clear stack
	sta	(point),y	;do a restore to be safe
	lda	#0		;set z=1 for rom
	rts
;bump page zero point
bmppnt	inc	point		;do low
	bne	*+4
	inc	point+1
	rts
;----------------------------------------
;debug
;From here on is the code and data that gets moved below PEM and acts
;as the command shell to load files, manipulate memory, etc
;----------------------------------------
;first align start on a page boundary
	*=	*/256*256+256
;Vector to pem
pemvec	jmp	(vector)	;vector from page one
;Main Program
debug	plp			;restore interrupt status
	jsr	SETBUF		;point to default buffer
	lda	#' '		;if name
	cmp	dflfcb+1	;not blank
	bne	TRYAFN		;check for afn
	cmp	dflfcb+9	;if type blank
	beq	GETCOM		;do nothing
TRYAFN	ldx	#11		;check
	lda	#'?'		;all of name
TstaFN	cmp	dflfcb,X	;for ambiguous
	beq	BDFILE		;file name
	dex			;count down
	bne	TstaFN		;and loop until done
	beq	RDEINP		;then execute
BDFILE	jmp	error		;error in file
RDEINP	jsr	XQREAD		;read file
GETCOM	ldx	USRS		;reset
	TXS			;stack
	jsr	crlf		;do a cr and lf
	lda	#'-'		;prompt with
	jsr	chrout		;a dash
	jsr	RDEBUF		;get command line
	ldy	#0		;set index to zero
	ldx	CNSLNG		;get length
	beq	GETCOM		;if zero try again
LWRUPR	lda	cnstxt,Y	;get character
	cmp	#'a'		;if less than
	bcc	NXTCHG		;a ok
	cmp	#'{'		;or if over
	bcs	NXTCHG		;a { ok
	and	#%01011111	;else convert
	sta	cnstxt,Y	;and put back
NXTCHG	iny			;bump index
	dex			;decrement count
	bne	LWRUPR		;loop if more
	TXA			;set a to zero
	sta	cnstxt,Y	;insert stopper
	tay			;set index to zero
	jsr	SKPSPC		;get first non-blank
	sta	COMMND		;save command
	beq	GETCOM		;try again if none
	cmp	#'I'		;if not I
	bne	NOTINP		;then continue
	jsr	XQINPT		;else input file name
	jmp	GETCOM		;and loop
NOTINP	cmp	#'X'
	beq	*+5		;continue if X
	jmp	NOTSTE
;X=machine state
	iny			;get command
	jsr	SKPSPC		;object register
	beq	NOSTCH		;ok if none
	sta	XRGCMD		;else save
	iny			;then get
	jsr	SKPSPC		;equals sign
	bne	*+5		;ok if not null
	jmp	error		;else error
	cmp	#'='		;if equals
	beq	*+5		;then ok
	jmp	error		;else error
	jsr	GETPRM		;get parameter
	lda	NUMPRM		;get number parms
	cmp	#1		;if one
	beq	*+5		;is ok
	jmp	error		;else error
	lda	XRGCMD		;get command
	cmp	#'*'		;if not pc
	bne	*+8		;try byte/bit
	jsr	PRMUPC		;else set pc
	jmp	NOSTCH		;and display
;byte changes
	lda	parm3+1		;if high zero
	beq	*+5		;is ok
	jmp	error		;else error
	ldx	#0		;clear index
	ldy	#0		;for search
	lda	XRGCMD		;get command
TSTREG	cmp	REGTBL,Y	;if same as table
	beq	GOTREG		;is ok
	cpy	#8		;if past s
	bcs	*+3		;do not bump
	INX			;byte index
	iny			;else bump
	iny			;index by two
	cpy	#22		;if not too big
	bne	TSTREG		;try again
	jmp	error		;else error
;found register or bit
GOTREG	cpx	#4		;if a bit change
	beq	ISABIT		;go do it
	lda	parm3		;else get byte
	sta	USRA,X		;set register
	jmp	NOSTCH		;and display
;is a flag bit
ISABIT	iny			;point to mask
	lda	parm3		;if parm zero
	beq	ZROBIT		;then clear
	cmp	#1		;if one ok
	beq	*+5		;to use
	jmp	error		;else error
	lda	REGTBL,Y	;get mask
	sta	parm3		;set
ZROBIT	lda	REGTBL,Y	;get mask
	eor	#$ff		;complement
	and	USRP		;get flags
	ora	parm3		;or with new
	sta	USRP		;and save
NOSTCH	ldx	#0		;clear index
STMSLP	lda	STEMSG,X	;get message
	beq	EXTSMS		;done if null
	jsr	chrout		;else send
	INX			;next char
	bne	STMSLP		;loop
EXTSMS	lda	usrpc+1		;get high PC
	jsr	outbyt		;send byte
	lda	usrpc		;get low PC
	jsr	BYTSPC		;send byte and space
	lda	USRA		;get A
	jsr	BYTSPC		;send it
	lda	USRX		;get X
	jsr	BYTSPC		;send it
	lda	USRY		;get Y
	jsr	BYTSPC		;send it
	lda	USRS		;get S
	jsr	BYTSPC		;send it
	ldx	#8		;eight bits
	lda	USRP		;get flags
STSLPE	ASL	A		;shift left
	pha			;save what is left
	lda	#0		;get a zero
	bcc	*+4		;skip if msb is zero
	lda	#1		;get a one
	jsr	outnib		;to console
	PLA			;get flags back
	dex			;count down
	bne	STSLPE		;loop if more
	jmp	GETCOM		;get new command
;Dispatch Command
NOTSTE	jsr	GETPRM		;get parms
	ldx	NUMPRM		;get number parms
	lda	COMMND		;and command
	cmp	#'R'		;if not READ
	bne	NTREAD		;try next
;R=READ File
	cpx	#2		;if zero or one
	bcc	DOREAD		;do read
	jmp	error		;else error
DOREAD	jsr	XQREAD		;read file
	jmp	GETCOM		;and loop
NTREAD	cmp	#'D'		;if not DISPLAY
	bne	NTDISP		;try next
;D=DISPLAY Memory
	TXA			;get number parms
	bne	TDOPRM		;if not zero try one
cldend	jsr	cltlby		;add number bytes minus one
	clc
	ADC	pointr		;to pointer
	sta	parm2		;and save
	lda	pointr+1	;in parm
	ADC	#0		;number
	sta	parm2+1		;two as end
	jmp	DODISP		;then execute
TDOPRM	cmp	#1		;if not one
	bne	TDTPRM		;try two
	jsr	PR3PTR		;else move parm3 to pointer
	jmp	CLDEND		;and set end
TDTPRM	cmp	#2		;if not two parms
	bne	suberr		;then error
	jsr	clbyln		;else find bytes per line
	jsr	PR2PTR		;move parm2 to pointer
	jsr	PR3PR2		;move parm3 to parm2
DODISP	jsr	XQDISP		;do display
	jmp	GETCOM		;then loop
NTDISP	cmp	#'S'		;if not SUBSTITUTE
	bne	NTSUBS		;try next
;S=SUBSTITUTE Memory
	TXA			;get number parms
	beq	dosubs		;if zero do it
	cmp	#1		;if not one
	bne	TRTWSU		;try two
	jsr	PR3PTR		;else set pointer
dosubs	jsr	xqsubs		;execute
	jmp	GETCOM		;and loop
TRTWSU	cmp	#2		;if two parms
	beq	DOUBLE		;do double store
suberr	jmp	error		;else is error
DOUBLE	jsr	PR2PTR		;set pointer
	jsr	STRABS		;store absolute
	lda	parm3		;get low
	jsr	MOVPNT		;set
	jsr	incPNT		;go to next
	lda	parm3+1		;get high
	jsr	MOVPNT		;set
	jmp	GETCOM		;then loop
NTSUBS	cmp	#'F'		;if not FILL
	bne	NTFILL		;try next
;F=FILL Memory
	cpx	#3		;if three parms
	beq	DOFILL		;do it
FILLER	jmp	error		;else is error
DOFILL	lda	parm3+1		;if high not
	bne	FILLER		;zero then error
	jsr	pr1ptr		;set pointer
	jsr	STRABS		;store absolute
FILMRE	lda	parm3		;get byte
	jsr	MOVPNT		;store
	jsr	incPNT		;point to next
	jsr	TSTPR0		;test for zero pointer
	beq	EXFILL		;done if it is
	jsr	LSTCHK		;if not last
	bcs	FILMRE		;do more
EXFILL	jmp	GETCOM		;else loop
NTFILL	cmp	#'L'		;if not LIST
	bne	NTLIST		;try next
;L=LIST (Disassemble)
	TXA			;get number parms
	beq	DOONLS		;do one if zero
	cmp	#1		;if not one
	bne	TRTWLS		;try two
	jsr	PR3PTR		;set pointer
doonls	jsr	gtlnsc		;do num lines minus one
	sta	COUNT		;instructions
DSONMR	jsr	DSMBL		;do disassembly
	DEC	COUNT		;count down
	bne	DSONMR		;loop if more
	jmp	GETCOM		;else get next
TRTWLS	cmp	#2		;if two then
	beq	DOTWDS		;do it
	jmp	error		;else error
DOTWDS	jsr	PR2PTR		;set pointer
	jsr	PR3PR2		;move parm3 to parm2
DSMORE	jsr	DSMBL		;do one intruction
	jsr	LSTCHK		;test for end
	bcs	DSMORE		;loop if more
	jmp	GETCOM		;else get next com
NTLIST	cmp	#'G'		;if G
	beq	*+5		;do
	jmp	NTGO		;else try next
;G=GO (execute)
	TXA			;get number parms
	bne	*+5		;if not zero try more
	jmp	dogo		;else go
	cmp	#1		;if not one
	bne	TGTPRM		;see if two
	jsr	PRMUPC		;set user pc
	jmp	dogo		;and go
TGTPRM	cmp	#2		;if not two
	bne	TG3PRM		;see if three
	lda	parm2		;if pc
	ora	parm2+1		;is zero
	beq	NOPC2		;use old
	lda	parm2		;else get
	ldy	parm2+1		;new
	sta	usrpc		;and
	sty	usrpc+1		;set
NOPC2	BIT	BRKOK		;if brk not
	bmi	dogo2		;allowed go do
	jsr	PR3PTR		;else move
	jsr	LDEABS		;set load mode
	jsr	MOVPNT		;get opcode
	beq	dogo2		;if brk execute
	sta	OPCDE1		;else save
	jsr	SETBPT		;get break
	ldx	#0		;set
	jsr	PNTBPT		;pointer
dogo2	jmp	dogo		;and go
TG3PRM	cmp	#3		;if three
	beq	*+5		;the ok
	jmp	error		;else error
	lda	parm1		;if pc 0
	ora	parm1+1		;then use
	beq	NOPC3		;old
	lda	parm1		;else get
	ldy	parm1+1		;new
	sta	usrpc		;and
	sty	usrpc+1		;set
NOPC3	BIT	BRKOK		;if brk not ok
	bmi	dogo		;just execute
	jsr	PR2PTR		;else set pointer
	jsr	LDEABS		;load mode
	jsr	MOVPNT		;get opcode
	beq	TRYBK2		;if zero see if second
	sta	OPCDE1		;else save
	jsr	SETBPT		;get break
	ldx	#0		;set
	jsr	PNTBPT		;pointer
TRYBK2	jsr	LDEABS		;load mode
	jsr	PR3PTR		;set pointer
	jsr	MOVPNT		;get opcode
	beq	dogo		;if break go
	sta	OPCDE2		;else save
	jsr	SETBPT		;set break
	ldx	#2		;then set
	jsr	PNTBPT		;location
dogo	ldy	USRY		;set Y
	ldx	USRS		;get stack
	TXS			;and set
	lda	usrpc+1		;get high PC
	pha			;push
	lda	usrpc		;then get low
	pha			;push
	lda	USRP		;get flags
	pha			;push
	ldx	USRX		;get X
	lda	USRA		;and A
	RTI			;and go
NTGO	jmp	GETCOM		;loop
;----------------------------------------
;Input File Designator
;----------------------------------------
XQINPT	ldx	#11		;fill
	lda	#' '		;name
MRESPC	sta	dflfcb,X	;and
	dex			;type
	bne	MRESPC		;with spaces
	INX			;set index to one
	ldy	#0		;skip I
	jsr	SKPSPC		;in command
	iny			;get next
	jsr	SKPSPC		;non blank char
	beq	INPERR		;error if none
	and	#%00000111	;convert to number
	sta	dflfcb		;set automatic
	iny			;point to next
	lda	cnstxt,Y	;get char
	cmp	#':'		;if : then
	beq	getnme		;then continue
	dey			;else backup
	dey			;two places
	lda	#0		;then clear
	sta	dflfcb		;automatic
getnme	iny			;go to next
GTMRNM	lda	cnstxt,Y	;get char
	beq	ENDALL		;over if none
	cmp	#'.'		;if separator
	beq	ENDNME		;then have name
	jsr	TSTLGL		;make sure its legal
	beq	INPERR		;if not error
	sta	dflfcb,X	;else put in fcb
	iny			;point to
	INX			;next positions
	cpx	#9		;if not to big
	bne	GTMRNM		;get more
ENDNME	ldx	#9		;start of type
	lda	cnstxt,Y	;get input
	beq	ENDALL		;if zero done
	cmp	#'.'		;if not delimiter
	bne	INPERR		;then error
	iny			;point to next
NXTTYP	lda	cnstxt,Y	;get char
	beq	ENDALL		;done if none
	jsr	TSTLGL		;but if illegal
	beq	INPERR		;is an error
	sta	dflfcb,X	;save char
	iny			;point to
	INX			;next positions
	cpx	#12		;if not at end
	bne	NXTTYP		;try another
	jsr	SKPSPC		;if more char
	bne	INPERR		;is wrong
ENDALL	dex			;and if no
	beq	INPERR		;input is error
	rts			;else return
INPERR	jmp	error		;error exit
;----------------------------------------
;Read File -- COM or KIM
;----------------------------------------
XQREAD	lda	#0		;clear
	ldx	#32		;fcb
ZERFCB	sta	dflfcb,X	;except
	dex			;for name
	cpx	#11		;and type
	bne	ZERFCB		;and drive
	jsr	OPNDFL		;try to open
	cmp	#255		;if ok continue
	bne	*+5		;since got it
	jmp	error		;else error
	ldx	#2		;if type
TSTTYP	lda	COMTYP,X	;is not com
	cmp	dflfcb+9,X	;then
	bne	KIMTYP		;do KIM read
	dex			;else count down
	bpl	TSTTYP		;and loop until done
;COM Read
	lda	#<tea		;get tea
	ldy	#>tea		;start
	CLC			;add offset
	ADC	parm3		;low
	sta	pointr		;and set
	tya			;pointer
	ADC	parm3+1		;to new
	sta	pointr+1	;value
	tay			;get high back
	lda	pointr		;and low
	pha			;save low
	cmp	#<minmem	;test against low
	tya			;get high
	sbc	#>minmem	;subtract low limit
	PLA			;get low back
	bcs	CMRDLP		;if ok continue
	jmp	error		;else error
CMRDLP	jsr	SETDMA		;set buffer address
	lda	pointr		;get low
	ldy	pointr+1	;and high pointer
	CLC			;add
	ADC	#128		;128
	sta	pointr		;and save
	bcc	noadcy		;skip inc w/o carry
	iny			;else bump high
	sty	pointr+1	;and save
noadcy	cmp	strvec		;test against debug
	tya			;lower
	sbc	strvec+1	;limit
	bcc	LASTOK		;continue if ok
	jmp	error		;else error
LASTOK	jsr	RDEDFL		;read sector
	cmp	#0		;if not ok
	bne	ENDCOM		;then done
	lda	pointr		;else get pointer
	ldy	pointr+1	;low and high
	jmp	CMRDLP		;and loop
ENDCOM	cmp	#1		;if one
	beq	comeof		;then eof
	jmp	error		;else error
comeof	jsr	nxtpcm		;send message
	lda	pointr		;get
	ldy	pointr+1	;pointer
	sec			;subtract
	sbc	#128		;128 from
	sta	pointr		;pointer
	bcs	NOADBR		;and save
	dey			;high
	sty	pointr+1	;and low
NOADBR	pha			;save low
	tya			;get high
	jsr	outbyt		;send it
	PLA			;get low
	jsr	outbyt		;send it
	jsr	SETBUF		;set default
	rts
;KIM Read
KIMTYP	lda	#128		;set pointer
	sta	KIMPNT		;to illegal
	ASL	A		;clear A
	sta	SAVPNT		;and save pointer
	jsr	STRABS		;store absolute
KIMLOP	jsr	GETCHR		;get char
	cmp	#'$'		;if $
	beq	endkim		;then done
	cmp	#eof		;if eof
	beq	endkim		;then done
	cmp	#semico		;if not file mark
	bne	KIMLOP		;try again
	jsr	GETTWO		;get count
	beq	endkim		;done if zero
	sta	COUNT		;set count
	jsr	GETTWO		;get high addr
	sta	pointr+1	;and save
	jsr	GETTWO		;get low addr
	CLC			;add
	ADC	parm3		;offset
	sta	pointr		;and save
	pha			;locally
	lda	pointr+1	;get high
	ADC	parm3+1		;add offset
	sta	pointr+1	;and save
	tay			;set high
	PLA			;and low
	pha			;save low again
	cmp	#<minmem	;see if
	tya			;too small
	sbc	#>minmem	;less than tea
	PLA			;get low back
	bcs	CHKHIG		;if ok continue
	jmp	error		;else error
CHKHIG	CLC			;add
	ADC	COUNT		;count
	bcc	noyinc		;to start
	iny			;and save
noyinc	cmp	strvec		;see if
	tya			;too
	sbc	strvec+1	;big
	bcc	KMHIOK		;if ok continue
	jmp	error		;else error
KMHIOK	jsr	GETTWO		;get byte
	jsr	MOVPNT		;store
	jsr	incPNT		;bump pointer
	DEC	COUNT		;count down
	bne	KMHIOK		;loop if more
	jsr	GETTWO		;ignore
	jsr	GETTWO		;checksum
	jmp	KIMLOP		;and loop
endkim	jsr	nxtpcm		;send message
	lda	pointr+1	;send high
	jsr	outbyt		;pointer
	lda	pointr		;then low
	jmp	outbyt		;pointer
;----------------------------------------
;Display Memory
;----------------------------------------
XQDISP	jsr	LSTCHK		;check start>=end
	bcc	ENDDSP		;exit if not
	jsr	LDEABS      	;load absolute
LNLOOP	lda	pointr      	;get
	ldy	pointr+1    	;pointer
	sta	parm3       	;save in 
	sty	parm3+1     	;parm3
	jsr	crlf        	;send a cr and lf
	jsr	OUTPNT      	;send pointer
	jsr	OUTSPC      	;than a space
HXLOOP	jsr	MOVPNT      	;get byte
	jsr	BYTSPC      	;send it and space
	jsr	incPNT      	;bump pointer
	jsr	TSTPR0		;test for zero pointer
	beq	HEXEND		;exit if it is
	jsr	LSTCHK      	;test for end
	bcc	HEXEND      	;done if is
	lda	pointr      	;else get pointer
	and	linmsk		;if not start
	bne	HXLOOP      	;then loop
HEXEND	jsr	PR3PTR		;reset pointer
ASLOOP	jsr	MOVPNT		;get char
	and	#%01111111	;mask parity
	cmp	#' '+1		;if over space
	bcs	*+4		;use
	lda	#'.'		;else use period
	jsr	chrout		;send as ascii
	jsr	incPNT		;bump pointer
	jsr	TSTPR0		;test for zero pointer
	beq	ENDDSP		;exit if it is
	jsr	LSTCHK		;if more
	bcc	ENDDSP		;then last then done
	lda	pointr		;get pointer
	and	linmsk		;if more in line
	bne	ASLOOP		;do it
	beq	LNLOOP		;else new line
ENDDSP	rts			;done
;----------------------------------------
;Substitute
;----------------------------------------
xqsubs	jsr	crlf		;send a cr and lf
	jsr	OUTPNT		;send pointer
	jsr	OUTSPC		;then a space
	lda	#0		;clear
	sta	NUMBER		;convert
	sta	NUMBER+1	;buffer
	lda	#2		;set for
	sta	COUNT		;two characters
	jsr	LDEABS		;load absolute
	jsr	MOVPNT		;get byte
	jsr	BYTSPC		;send it and space
NXSBIN	jsr	CHRINP		;get char
	cmp	#cr		;if a cr
	beq	EXTSUB		;then done
	cmp	#'.'		;if a period
	beq	NXTSUB		;go to next
	cmp	#'a'		;if less than "a"
	bcc	NTLWCS		;skip conversion
	cmp	#'z'+1		;if over "z"
	bcs	NTLWCS		;skip conversion
	and	#%01011111	;else convert
NTLWCS	jsr	PACK		;pack
	bcc	*+5		;if ok continue
	jmp	error		;else error
	DEC	COUNT		;count down
	bne	NXSBIN		;if more loop
	jsr	STRABS		;store absolute
	lda	NUMBER		;get byte
	jsr	MOVPNT		;and set
NXTSUB	jsr	incPNT		;go to next
	jmp	xqsubs		;loop
EXTSUB	jmp	incPNT		;end with bump
;Next Address Message
nxtpcm	ldx	#0		;clear index
PCMLPE	lda	nxtmsg,X	;get char
	beq	EXTPMS		;if null done
	jsr	chrout		;else send
	INX			;bump index
	bne	PCMLPE		;and loop
EXTPMS	rts
;disassemble an instruction
DSMBL	jsr	INSDSP
	jsr	PNTAJ
	sta	pointr
	sty	pointr+1
	rts
INSDSP	jsr	PRPC
	jsr	LDEABS		;load absolute
	jsr	MOVPNT		;get byte
	tay
	lsr	A
	bcc	IEVEN
	lsr	A
	bcs	ERR
	cmp	#$22
	beq	ERR
	and	#7
	ora	#$80
IEVEN 	lsr	A
	tax
	lda	MODE,X
	bcs	RTMODE
	lsr	A
	lsr	A
	lsr	A
	lsr	A
RTMODE	and	#$F
	bne	GETFMT
ERR	ldy	#$80
	lda	#0
GETFMT	tax
	lda	MODE2,X
	sta	FORMAT
	and	#3
	sta	LENGT
	tya
	and	#$8F
	tax
	tya
	ldy	#3
	cpx	#$8A
	beq	MNNDX3
MNNDX1	lsr	A
	bcc	MNNDX3
	lsr	A
MNNDX2	lsr	A
	ora	#$20
	dey
	bne	MNNDX2
	iny
MNNDX3	dey
	bne	MNNDX1
	pha
PROP	lda	#$B9		;load abs,y
	sta	MOVPNT		;mode
	jsr	MOVPNT		;get byte
	jsr	outbyt
	ldx	#1
PROPBL	jsr	PRBL2
	cpy	LENGT
	iny
	bcc	PROP
	ldx	#3
	cpy	#4
	bcc	PROPBL
	PLA
	tay
	lda	MNEML,Y
	sta	LMNEM
	lda	MNEMR,Y
	sta	RMNEM
PRMN1	lda	#0
	ldy	#5
PRMN2	ASL	RMNEM
	ROL	LMNEM
	ROL	A
	dey
	bne	PRMN2
	ADC	#$BF
	jsr	chrout		;send to console
	dex
	bne	PRMN1
	jsr	PRBL
	ldx	#6
PRADR1	cpx	#3
	bne	PRADR3
	ldy	LENGT
	beq	PRADR3
PRADR2	lda	FORMAT
	cmp	#$E8
	lda	#$B9		;load abs,y
	sta	MOVPNT		;mode
	jsr	MOVPNT		;get byte
	bcs	RELADR
	jsr	outbyt
	dey
	bne	PRADR2
PRADR3	ASL	FORMAT
	bcc	PRADR4
	lda	CHAR1-1,X
	jsr	chrout
	lda	CHAR2-1,X
	beq	PRADR4
	jsr	chrout
PRADR4	dex
	bne	PRADR1
	rts
RELADR	jsr	PNTAJ3
	tax
	INX
	bne	outyx
	iny
outyx	tya
outax	jsr	outbyt
OUTX	TXA
	jmp	outbyt
PRPC	jsr	crlf
	jsr	OUTPNT
	lda	#'-'
	jsr	chrout
PRBL	ldx	#3
PRBL2	jsr	OUTSPC
	dex
	bne	PRBL2
	rts
PNTAJ	lda	LENGT
PNTAJ2	sec
PNTAJ3	ldy	pointr+1
	tax
	bpl	PNTAJ4
	dey
PNTAJ4	ADC	pointr
	bcc	rts1
	iny
rts1	rts
;gather parameters
GETPRM	lda	#0		;CLEAR
	sta	NUMPRM		;COUNT
PRMLPE	jsr	PSHOVE		;PUSH PARMS
	iny			;FIND next
	jsr	SKPSPC		;NON-BLANK
	beq	ENDPRM		;DONE IF NONE
	sta	LSTCHR		;SAVE LAST CHAR
	inc	NUMPRM		;ELSE BUMP COUNT
	cmp	#','		;IF SEPARATOR
	beq	PRMLPE		;TRY FOR ANOTHER
PACKIT	jsr	PACK		;CONVERT and	PACK
	bcs	PRMERR		;IF error EXIT
	iny			;point TO next
	lda	cnstxt,Y	;GET CHAR
	beq	ENDPRM		;EXIT IF NONE
	sta	LSTCHR		;SAVE LAST CHAR
	cmp	#','		;IF SEPARATOR
	beq	PRMLPE		;LOOP FOR MORE
	cmp	#' '		;IF NOT space
	bne	PACKIT		;TRY TO CONVERT
	jsr	SKPSPC		;ELSE GET next
	beq	ENDPRM		;DONE IF NONE
	sta	LSTCHR		;SAVE LAST CHAR
	cmp	#','		;IF SEPSRATOR
	beq	PRMLPE		;LOOP FOR MORE
PRMERR	jmp	error		;ELSE error
ENDPRM	lda	LSTCHR		;GET LAST
	cmp	#','		;IF NOT COMMA
	bne	NOMRPR		;then done
	inc	NUMPRM		;else bump count
NOMRPR	jmp	PSHOVE		;push last
;Skip Blanks
SKPSPC	lda	cnstxt,Y	;get char
	beq	EXTSKP		;done if none
	cmp	#' '		;if not space
	bne	EXTSKP		;then done
	iny			;else loop
	bne	SKPSPC		;and try again
EXTSKP	rts
;Test For Illegal
TSTLGL	lda	cnstxt,Y	;get char
	beq	extlgl		;done if null
	cmp	#' '		;if less than space
	bcc	BADINP		;is an error
	beq	extlgl
	cmp	#'?'
	beq	extlgl
	cmp	#'*'
	beq	extlgl
	cmp	#'='
	beq	extlgl
	cmp	#'_'
	beq	extlgl
	cmp	#'.'
	beq	extlgl
	cmp	#':'
	beq	extlgl
	cmp	#semico
	beq	extlgl
	cmp	#'<'
	beq	extlgl
	cmp	#'>'
extlgl	rts
BADINP	jmp	error
;Push Parms Down
PSHOVE	ldx	#16		;shift 16 bits
SHVLPE	ASL	parm3		;from
	ROL	parm3+1		;parm3
	ROL	parm2		;to parm2
	ROL	parm2+1		;and from
	ROL	parm1		;parm2 to
	ROL	parm1+1		;parm1
	dex			;loop until
	bne	SHVLPE		;all done
	lda	NUMBER		;get number
	sta	parm3		;and set parm3
	lda	NUMBER+1	;low and
	sta	parm3+1		;high
	stx	NUMBER		;clear
	stx	NUMBER+1	;number
	rts
;Get Character
GETCHR	ldx	KIMPNT		;get pointer
	bpl	NOREAD		;if ok use
	jsr	RDEDFL		;else read
	beq	GETOK		;if ok continue
	cmp	#1		;if eof
	beq	*+5		;is ok
	jmp	error		;else error
	lda	#eof		;get an eof
	sta	dflbuf		;put in buffer
	lda	#0		;clear a to
GETOK	tax			;clear index
	stx	KIMPNT		;and pointer
NOREAD	inc	KIMPNT		;bump pointer
	lda	dflbuf,X	;get char
	and	#%01111111  	;mask out parity
	rts
;Get Byte
GETTWO	lda	#0		;clear
	sta	NUMBER		;buffer
	sta	NUMBER+1	;so no error
	jsr	GETONE		;get nibble
GETONE	jsr	GETCHR		;get char
	jsr	PACK		;pack and convert
	bcs	geterr		;error if carry
	lda	NUMBER		;else get result
	rts
geterr	jmp	error		;error exit
;Pack Ascii
PACK	cmp	#'0'		;if too small
	bmi	packer		;then error
	cmp	#'9'+1		;if "0" to "9"
	bmi	DECNUM		;is decimal
	cmp	#'A'		;if less than "A"
	bmi	packer		;then error
	cmp	#'F'+1		;if more than "F"
	bpl	packer		;then error
	CLC			;else add
	ADC	#9		;nine
DECNUM	ROL	A		;move
	ROL	A		;to
	ROL	A		;high
	ROL	A		;nibble
	ldx	#4		;shift
PACKLP	ROL	A		;input
	ROL	NUMBER		;and
	ROL	NUMBER+1	;buffer
	bcs	packer		;error if carry
	dex			;count down
	bne	PACKLP		;and loop
	rts
packer	sec			;error
	rts			;return
;Output Nibble
outnib	and	#%00001111  	;low nibble
	ora	#'0'		;make ascii
	cmp	#'9'+1		;if "0" to "9"
	bmi	NOTALP		;send it
	CLC			;else
	ADC	#7		;add seven
NOTALP	jmp	chrout		;write it
;Output Byte
outbyt	pha			;save
	lsr	A		;move
	lsr	A		;high
	lsr	A		;to
	lsr	A		;low
	jsr	outnib		;send
	PLA			;then send
	jmp	outnib		;high
;Output Pointer
OUTPNT	lda	pointr+1	;get high
	jsr	outbyt		;send
	lda	pointr		;then low
	jmp	outbyt		;send it
;Parameter 1 to Pointer
pr1ptr	lda	parm1		;get low
	ldy	parm1+1		;and high
	sta	pointr		;set
	sty	pointr+1	;pointer
	rts
;Parameter 2 to Pointer
PR2PTR	lda	parm2		;get low
	ldy	parm2+1		;and high
	sta	pointr		;set
	sty	pointr+1	;pointer
	rts
;Parameter 3 to Pointer
PR3PTR	lda	parm3		;get low
	ldy	parm3+1		;and high
	sta	pointr		;set
	sty	pointr+1	;pointer
	rts
;Parameter 3 to Parameter 2
PR3PR2	lda	parm3		;get low
	ldy	parm3+1		;and high
	sta	parm2		;set
	sty	parm2+1		;parm 2
	rts
;Last Address Check
LSTCHK	lda	parm2		;subtract
	cmp	pointr		;pointer
	lda	parm2+1		;from
	sbc	pointr+1	;parm2
	rts
;Increment Pointer
incPNT	inc	pointr		;bump low
	bne	*+5		;done if not zero
	inc	pointr+1	;else bump high
	rts
;decrement pointer
DECPNT	lda	pointr		;get low
	bne	*+5		;jump if not zero
	DEC	pointr+1	;else drop high
	DEC	pointr		;always drop low
	rts
;Increment Parameter 2
incPR2	inc	parm2		;bump low
	bne	*+5		;done if not zero
	inc	parm2+1		;else bump high
	rts
;Error Handler
error	jsr	crlf		;send cr lf
	lda	#'?'		;then a
	jsr	chrout		;question
	jmp	GETCOM		;restart
;parm3 to user pc
PRMUPC	lda	parm3		;get low
	ldy	parm3+1		;and high
	sta	usrpc		;set pc
	sty	usrpc+1		;in ram
	rts
;test for pointer=0
TSTPR0	lda	pointr		;get low
	ora	pointr+1	;or with high
	rts
;cr and lf
crlf	lda	#cr		;do
	jsr	chrout		;a cr
	lda	#lf		;and
	bne	chrout		;a lf
;Output Space
OUTSPC	lda	#' '		;get space
;Output With Save
chrout	pha			;save char
	stx	savex		;save X
	sty	savey		;and Y
	jsr	OUTCHR		;send
	ldy	savey		;restore
	ldx	savex		;X and Y
	PLA			;then char
	rts
;Default File References
SETBUF	lda	#<dflbuf	;point to
	ldy	#>dflbuf	;default buffer
SETDMA	ldx	#26		;set dma
	bne	pemgo
OPNDFL	ldx	#15		;open file
	bne	SETDFL
RDEDFL	ldx	#20		;read record
SETDFL	lda	#<dflfcb	;point to
	ldy	#>dflfcb	;default fcb
	jmp	pemgo		;go
;General pem References
CHRINP	ldx	#1		;character input
	bne	pemgo
outchr	and	#$7f		;clear msb
	ldx	#2		;do char output
	bne	pemgo
RDEBUF	lda	BUFVEC		;read buffer
	ldy	BUFVEC+1
	ldx	#10
pemgo 	jmp	(vector)
;set BRK opcode
SETBPT	jsr	STRABS		;store absolute
	lda	#0		;BRK code
	jmp	MOVPNT		;set
;move pointer to breakpoint pointer (x=0 or 2)
PNTBPT	lda	pointr		;get low
	sta	brkpt1,X	;set low
	lda	pointr+1	;get high
	sta	brkpt1+1,X  	;then set
	dex			;drop x
	bpl	*+3		;if 1 ok
	INX			;else make 0
	lda	#$FF		;get flag
	sta	BRFLG1,X	;and set
	rts
;send byte then ascii space
BYTSPC	jsr	outbyt		;send byte
	jmp	OUTSPC		;then space
;load absolute mode
LDEABS	lda	#$AD		;load absolute code
	sta	MOVPNT		;set
	rts
;store absolute mode
STRABS	lda	#$8D		;store absolute code
	sta	MOVPNT		;set
	rts
;clear breakpoints
CLRBPS	jsr	STRABS		;set store absolute
	ldx	#0		;first pointer
	ldy	#0		;first flag and opcode
	jsr	CLR1		;clear first
	iny			;second flag and opcode
	ldx	#2		;second pointer
;clear one breakpoint
CLR1	lda	BRFLG1,Y	;get flag
	beq	CLR1EX		;do nothing in clear
	lda	brkpt1,X	;else get
	sta	pointr		;address
	lda	brkpt1+1,X	;and set
	sta	pointr+1	;pointer
	lda	OPCDE1,Y	;then get opcode
	jsr	MOVPNT		;and restore
	lda	#0		;clear
	sta	BRFLG1,Y	;flag
CLR1EX	rts
;IRQ and BRK handler
IRQBRK PHP			;save P
	pha			;A
	TXA			;and
	pha			;X
	TSX			;get status
	lda	$104,X		;from stack
	and	#%00010000  	;look at brk bit
	bne	ISABRK		;brk if not zero
	PLA			;else restore 
	tax			;X
	PLA			;A
USRBRK	PLP			;and P
	jmp	(IRQVEC)	;and do IRQ
ISABRK	PLA			;restore
	tax			;X
	PLA			;A
	PLP			;and P
	sta	USRA		;now save
	stx	USRX		;everything
	sty	USRY		;in
	PLA			;user
	sta	USRP		;save
	PLA			;locations
	sta	usrpc		;including
	PLA			;PC
	sta	usrpc+1		;and
	TSX			;stack
	stx	USRS		;before BRK
	CLD			;binary mode
	sec			;adjust
	lda	usrpc		;PC
	sbc	#2		;to
	sta	usrpc		;correctly
	bcs	*+5		;point to
	DEC	usrpc+1		;BRK
	lda	BRFLG1		;if flag zero
	beq	TRYBP2		;is not set
	lda	usrpc		;else get low
	ldy	usrpc+1		;and high PC
	cmp	brkpt1		;if low not
	bne	TRYBP2		;equal try 2
	cpy	brkpt1+1	;if high
	beq	RSTOPC		;equal is ok
TRYBP2	lda	BRFLG2		;if not set
	beq	NOTSET		;must be user
	lda	usrpc		;else get
	ldy	usrpc+1		;user Pc
	cmp	brkpt2		;if low not same
	bne	NOTSET		;is user
	cpy	brkpt2+1	;if high not same
	bne	NOTSET		;is user
RSTOPC	jsr	CLRBPS		;clear breakpoints
	lda	usrpc		;set
	ldy	usrpc+1		;pointer
	sta	pointr		;to PC
	sty	pointr+1	;for opcode restore
	jsr	INSDSP		;show instruction
	jmp	NOSTCH		;show status
;user BRK
NOTSET	CLC			;adjust
	lda	usrpc		;user
	ADC	#2		;PC
	sta	usrpc		;to original
	bcc	*+5		;for
	inc	usrpc+1		;BRK
	lda	usrpc+1		;get high
	pha			;push
	lda	usrpc		;get low
	pha			;push
	lda	USRP		;get flags
	pha			;push
	ldx	USRX		;get X
	ldy	USRY		;and Y
	lda	USRA		;and A
	jmp	USRBRK
;get char per line
gtchln	lda	$ff00+61	;dummy with offset
	rts
;get lines per screen - 1
gtlnsc	lda	$ff00+60	;dummy with offset
	sec
	sbc	#1
	rts
;calculate bytes per line
clbyln	jsr	gtchln		;get char per line
	cmp	#33
	bcs	gt32		;if >32 then
	lda	#2
	ldx	#%11
	bne	gotmod
gt32	cmp	#65
	bcs	gt64		;if >64 then
	lda	#3
	ldx	#%111
	bne	gotmod
gt64	lda	#4
	ldx	#%1111
gotmod	sta	bytpln		;save both params
	stx	linmsk
	rts
;calculate total bytes-1
cltlby	jsr	clbyln		;bytes per line
	tax			;save log of bytes per line
	jsr	gtlnsc
	sec
	sbc	#1		;drop another for security
cltllp	asl	a
	bcc	*+4		;ok if no carry
	lda	#0		;else is "256"
	dex
	bne	cltllp		;loop if more
	sec
	sbc	#1		;drop by one
	rts
;Relocatable Vectors
	.byte	$20
strvec	.word	pemvec		;start of debug
	.byte	$20
BUFVEC	.word	CNSBUF		;console buffer
	.byte	$20
IBKVEC	.word	IRQBRK		;IRQ/BRK vector
	.byte	$FF		;stopper for relocate
;register table
REGTBL	.byte	"A",0
	.byte	"X",0
	.byte	"Y",0
	.byte	"S",0
	.byte	"N",128
	.byte	"V",64
	.byte	"B",16
	.byte	"D",8
	.byte	"I",4
	.byte	"Z",2
	.byte	"C",1
;disassembler tables
MODE	.byte	$40,$2,$45,$3,$D0,$8,$40,$9
	.byte	$30,$22,$45,$33,$D0,$8,$40,$9
	.byte	$40,$2,$45,$33,$D0,$8,$40,$9
	.byte	$40,$2,$45,$B3,$D0,$8,$40,$9
	.byte	$0,$22,$44,$33,$D0,$8C,$44,$0
	.byte	$11,$22,$44,$33,$D0,$8C,$44,$9A
	.byte	$10,$22,$44,$33,$D0,$8,$40,$9
	.byte	$10,$22,$44,$33,$D0,$8,$40,$9
	.byte	$62,$13,$78,$A9
MODE2	.byte	$0,$21,$81,$82,$0,$0,$59,$4D
	.byte	$91,$92,$86,$4A,$85,$9D
CHAR1	.byte	$AC,$A9,$AC,$A3,$A8,$A4
CHAR2	.byte	$D9,$0,$D8,$A4,$A4,$0
MNEML	.byte	$1C,$8A,$1C,$23,$5D,$8B,$1B,$A1
	.byte	$9D,$8A,$1D,$23,$9D,$8B,$1D,$A1
	.byte	$0,$29,$19,$AE,$69,$A8,$19,$23
	.byte	$24,$53,$1B,$23,$24,$53,$19,$A1
	.byte	$0,$1A,$5B,$5B,$A5,$69,$24,$24
	.byte	$AE,$AE,$A8,$AD,$29,$0,$7C,$0
	.byte	$15,$9C,$6D,$9C,$A5,$69,$29,$53
	.byte	$84,$13,$34,$11,$A5,$69,$23,$A0
MNEMR	.byte	$D8,$62,$5A,$48,$26,$62,$94,$88
	.byte	$54,$44,$C8,$54,$68,$44,$E8,$94
	.byte	$0,$B4,$8,$84,$74,$B4,$28,$6E
	.byte	$74,$F4,$CC,$4A,$72,$F2,$A4,$8A
	.byte	$0,$AA,$A2,$A2,$74,$74,$74,$72
	.byte	$44,$68,$B2,$32,$B2,$0,$22,$0
	.byte	$1A,$1A,$26,$26,$72,$72,$88,$C8
	.byte	$C4,$CA,$26,$48,$44,$44,$A2,$C8
;messages
COMTYP	.byte	"COM"
nxtmsg	.byte	cr,lf,"NEXT ADDRESS=",0
STEMSG	.byte	cr,lf,"*    A  X  Y  S  NV?BDIZC",cr,lf,0
;Variable Storage
	*=	*/2*2+2		;align on word boundary
IRQVEC	.word	0		;IRQ vector
vector	.word	0		;pem vector
CNSBUF
CNSMAX	.byte	32		;input
CNSLNG	.byte	0		;buffer
cnstxt
	*=	*+32
parm1	.word	0		;parameters
parm2	.word	0		;for
parm3	.word	0		;commands
COMMND	.byte	0		;command letter
MOVPNT	.byte	$8D		;opcode
pointr	.word	tea		;pointer
	.byte	$60		;return
BUFADD	.word	tea		;com read address
KIMPNT	.byte	0		;KIM char pointer
SAVPNT	.byte	0		;save pointer
COUNT	.byte	0		;counter
NUMBER	.word	0		;pack buffer
usrpc	.word	tea		;user registers
USRA	.byte	0
USRX	.byte	0
USRY	.byte	0
USRS	.byte	$FF
USRP	.byte	%00000100
brkpt1	.word	0		;breakpoint 1
brkpt2	.word	0		;breakpoint 2
OPCDE1	.byte	0		;opcode 1
OPCDE2	.byte	0		;opcode 2
BRFLG1	.byte	0		;break set
BRFLG2	.byte	0		;flags
NUMPRM	.byte	0		;number parms
savex	.byte	0		;save
savey	.byte	0		;registers
LSTCHR	.byte	0		;last parm char
BRKOK	.byte	0		;0 if BRK allowed
XRGCMD	.byte	0		;state command
LENGT	.byte	0		;instruction length
FORMAT	.byte	0		;format code
LMNEM	.byte	0		;left name
RMNEM	.byte	0		;right name
linmsk	.byte	0		;line end mask for display
bytpln	.byte	0		;bytes per line for display
;align end on page boundary-1
LAST	=	*/256*256+256-1
	.END
	