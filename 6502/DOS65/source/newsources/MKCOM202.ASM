;MAKECOM
;convert .KIM files to .COM files for dos/65
;version 2.02-A
;released:	25 september 1982
;last revision:
;	27 march 2008
;		eliminated page zero 0 & 1
;		reformatted for TASM & ASM210
;	2 april 2008
;		corrected error in page zero addressing
;		put com buffer on page boundary
;		added missing '
;read kim format object code files and generate
;executable command (com) file beginning at tea.
;conversion is terminated by eof char, zero
;length record, $ char or physical eof.  records must be
;monotonically increasing but may have gaps.
;any gaps are filled with zeros. upon entry
;file type is or is assumed to be "kim".
;base addresses
boot	=	$100		;warm boot
pem	=	$103		;pem entry point
dflfcb	=	$107		;source fcb
dflbuf	=	$128		;source buffer
tea	=	$800		;tea start
;fixed parameters
null	=	0		;null
lf	=	10		;linefeed $a
cr	=	13		;return $d
eof	=	26		;end of file $1a
semico	=	59		;semicolon $3b
;zero page storage - start at 2 for C64 & 128 compatibility
	*=	2
kimpnt				;kim record index
	*=	*+1
compnt				;com record pointer
	*=	*+2
curent				;current com pc
	*=	*+2
start				;current kim start
	*=	*+2
count				;current record byte count
	*=	*+1
bytes				;number bytes read
	*=	*+2
record				;number records read
	*=	*+2
number				;byte assembly buffer
	*=	*+1
commax				;max com pointer
	*=	*+2
;put .COM fcb outside area subject to PEM saves
	*=	32
comfcb				;com fcb
	*=	*+33
lastzp
;main program
	*=	tea
	jmp	load		;go execute
	.byte	"COPYRIGHT (C) 2008 -"
	.byte	" RICHARD A. LEARY"
;first clear page zero including .COM fcb
load	ldx	#lastzp-1	;set index to max
	lda	#0		;clear accum
clrmre	sta	0,x		;clear
	dex			;drop index
	cpx	#1		;if more
	bne	clrmre		;loop
;start .COM file build at TEA
	lda	#<tea		;set current
	sta	curent		;to tea
	ldy	#>tea		;both low
	sty	curent+1	;and high
;calculate maximum .COM file buffer length 
	sec			;set carry
	lda	pem+1		;get pem
	ldy	pem+2		;destination
	sbc	#<combuf	;start
	and	#128		;make mod 128
	sta	commax		;and save
	tya			;get high
	sbc	#>combuf	;subtract again
	sta	commax+1	;and save it
;commax is maximum length - now drop by a page
	dec	commax+1
;now calculate end of buffer + 1 byte
	clc			;then
	lda	commax		;add
	adc	#<combuf	;start
	sta	commax		;back
	lda	commax+1	;in to
	adc	#>combuf	;get buffer
	sta	commax+1	;limit
;initialize pointers
	jsr	clrcom		;clear com pointer
	lda	#128		;set pointers
	sta	kimpnt		;to invalid
;check to make sure file name is ufn
	ldx	#11		;check all char
	lda	#'?'		;for ambiguous
tstamb	cmp	dflfcb,x	;if not try
	bne	tstnxt		;for next
	jmp	inperr		;else an error
tstnxt	dex			;count down
	bne	tstamb		;and loop
;now see if type either KIM or blank
	ldx	#2		;if type
chkmkm	lda	kimtyp,x	;is not
	cmp	dflfcb+9,x	;kim then
	bne	chkspc		;try for spaces
	dex			;else count down
	bpl	chkmkm		;and loop
	bmi	typeok		;ok if kim
chkspc	ldx	#2		;check for
	lda	#' '		;spaces
chkmsp	cmp	dflfcb+9,x	;if so
	beq	tnxspc		;test next
	jmp	inperr		;else error
tnxspc	dex			;count down
	bpl	chkmsp		;and loop
;input file name is OK so build .COM fcb from input
typeok	ldx	#8		;set up
movfcb	lda	dflfcb,x	;and move
	sta	comfcb,x	;name to
	dex			;com
	bpl	movfcb		;fcb
;set input extension to KIM and output to COM
	ldx	#2		;then make
settyp	lda	kimtyp,x	;sure kim
	sta	dflfcb+9,x	;type is
	lda	comtyp,x	;set and com
	sta	comfcb+9,x	;type is set
	dex			;in
	bpl	settyp		;fcbs
;file name are OK so see if .KIM exists
	jsr	srhkim		;search for kim
	bne	kimok		;if there ok
	jmp	inperr		;else error
;input exists so delete and then create .COM file
kimok	jsr	dltcom		;delete com file
	jsr	crtcom		;create new com
	bne	comok		;if ok continue
	jmp	outerr		;else error
;finally we open the .KIM and .COM files
comok	jsr	opnkim		;open source
	bne	kimopn		;continue if ok
	jmp	inperr		;else error
kimopn	jsr	opncom		;open com file
	bne	main		;continue if ok
	jmp	outerr		;else error
;read loop - get characters from .KIM file and process them
main	jsr	getchr		;get char
	cmp	#'$'		;if $
	beq	endit		;then done
	cmp	#eof		;if eof
	beq	endit		;then done
	cmp	#semico		;if not file
	bne	main		;mark try again
;first two characters after ; are number of bytes of data in record (count)
	jsr	gettwo		;get length
	beq	endit		;if zero done
	sta	count		;else set count
;update cumulative count
	clc			;add to 
	adc	bytes		;cumulative count
	sta	bytes		;and 
	bcc	nohiby		;save
	inc	bytes+1		;low and high
;next four characters are start address of record in HL order
nohiby	jsr	gettwo		;get high
	sta	start+1		;address
	jsr	gettwo		;and get
	sta	start		;low
;make sure start >= curent
	cmp	curent		;compare to
	lda	start+1		;start
	sbc	curent+1	;address saved
	bcs	tsteql		;if >= then ok
	jmp	seqerr		;else error
;see if start > current and fill buffer with 0 until curent = start
tsteql	lda	start		;see if
	cmp	curent		;same as currrent
	bne	fillmr		;if not fill more
	lda	start+1		;try high
	cmp	curent+1	;comparison
	beq	fillok		;if same begin read
fillmr	lda	#null		;else
	jsr	insert		;fill com
	inc	curent		;then 
	bne	tsteql		;bump
	inc	curent+1	;current and
	jmp	tsteql		;loop
;update curent <-- curent + count
fillok	lda	count		;first
	clc			;update
	adc	curent		;current
	sta	curent		;pointer
	bcc	dofill		;with
	inc	curent+1	;carry
;get count bytes from .KIM and convert to binary and put in .COM buffer
dofill	jsr	gettwo		;get byte
	jsr	insert		;put in com
	dec	count		;count down
	bne	dofill		;and loop
;ignore two checksum bytes
	jsr	gettwo		;ignore
	jsr	gettwo		;checksum
	jmp	main		;and get next
;exit sequence
endit	sec			;set carry
	lda	compnt		;if pointer
	sbc	#<combuf	;at even
	and	#127		;record
	beq	noexcy		;then ok
	lda	#eof		;else add
	jsr	insert		;eof and
	jmp	endit		;loop
noexcy	lda	compnt		;get
	ldy	compnt+1	;pointer
	sta	commax		;and set
	sty	commax+1	;limit
	jsr	wrtbuf		;do one more
	jsr	bufcom		;go back to front of buffer
wrtdne	jsr	clscom		;close com file
	bne	wrtcls		;if ok continue
	jmp	outerr		;else error
wrtcls	lda	#<nxtadr	;point to
	ldy	#>nxtadr	;next message
	jsr	outbuf		;and send
	lda	curent+1	;send high
	jsr	outbyt		;byte
	lda	curent		;and low
	jsr	outbyt		;byte
	lda	#<bytrde	;point to
	ldy	#>bytrde	;number read message
	jsr	outbuf		;and send
	lda	bytes+1		;send high
	jsr	outbyt		;byte
	lda	bytes		;and low
	jsr	outbyt		;byte
	lda	#<recwrt	;point to
	ldy	#>recwrt	;number written message
	jsr	outbuf		;send
	lda	record+1	;get high
	jsr	outbyt		;count
	lda	record		;and low
	jsr	outbyt		;then return
	jmp	boot		;with warm boot
;subroutines
;get character from kim file
getchr	ldx	kimpnt		;get pointer
	bpl	noread		;if ok use
	jsr	bufkim		;point to kim
	jsr	rdekim		;read record
	bne	*+5		;if no error check for eof
	jmp	inperr		;else input error
	cmp	#0		;if not eof
	beq	readok		;continue
	lda	#eof		;else an eof
	sta	dflbuf		;insert in buffer
	lda	#0		;clear for ok
readok	tax			;set pointer
	stx	kimpnt		;and save
noread	inc	kimpnt		;bump pointer
	lda	dflbuf,x	;get char
	and	#%01111111	;mask out msb
	rts			;return
;get byte
gettwo	jsr	getone		;get first and continue
;get nibble
getone	jsr	getchr		;get char
	cmp	#'0'		;if less than "0"
	bmi	packer		;is an error
	cmp	#'9'+1		;if 0 to 9 is
	bmi	decnum		;decimal
	cmp	#'A'		;if less than a
	bmi	packer		;is error
	cmp	#'F'+1		;if more than f
	bpl	packer		;is error
	clc			;add 9
	adc	#9		;for a to f
decnum	rol	a		;shift
	rol	a		;to 
	rol	a		;high
	rol	a		;nibble
	ldx	#4		;then
packlp	rol	a		;shift a
	rol	number		;to number
	dex			;four
	bne	packlp		;times
	lda	number		;return
	rts			;with number
packer	jmp	nthxer		;error handler
;nibble to ascii
hex	and	#$f		;look at low
	ora	#'0'		;add "0"
	cmp	#'9'+1		;if 0 to 9
	bmi	notalp		;ok
	clc			;else add
	adc	#7		;7 for a to f
notalp	jmp	chrout		;send
;byte to ascii
outbyt	pha			;save byte
	lsr	a		;move
	lsr	a		;high
	lsr	a		;to
	lsr	a		;low
	jsr	hex		;convert and print
	pla			;same
	jmp	hex		;for low
;kim file references
bufkim	lda	#<dflbuf 	;point to
	ldy	#>dflbuf	;buffer
	ldx	#26		;set buffer
	bne	pemgo
srhkim	ldx	#17		;search for first
	bne	setkim
opnkim	ldx	#15		;open
	bne	setkim
rdekim	ldx	#20		;read record
setkim	lda	#<dflfcb	;set fcb
	ldy	#>dflfcb	;to default
	jmp	pemgo
;com file references
bufcom	lda	#<combuf	;set buffer
	ldy	#>combuf	;to com
	ldx	#26		;set buffer
	bne	pemgo
dltcom	ldx	#19		;delete file
	bne	setcom
crtcom	ldx	#22		;create file
	bne	setcom
wrtcom	ldx	#21		;write record
	bne	setcom
clscom	ldx	#16		;close file
	bne	setcom
opncom	ldx	#15		;open file
setcom	lda	#<comfcb	;point to
	ldy	#>comfcb	;com fcb
	jmp	pemgo
;general pem references
wrmbte	ldx	#0		;warm boot
	beq	pemgo
chrout	ldx	#2		;character output
	bne	pemgo
outbuf	ldx	#9		;string output
pemgo	jsr	pem		;execute
	cmp	#255		;test for invalid
	rts
;error routines
inperr	lda	#<inerms	;input file error
	ldy	#>inerms
	jmp	errsnd
nthxer	lda	#<icerms	;invalid character
	ldy	#>icerms
	jmp	errsnd
outerr	lda	#<oterms	;output file error
	ldy	#>oterms
	jmp	errsnd
seqerr	lda	#<sqerms	;sequence error
	ldy	#>sqerms
errsnd	jsr	outbuf		;send
	jmp	wrmbte		;do warm boot
;error messages
inerms	.byte	"INPUT ERROR$"
oterms	.byte	"OUTPUT ERROR$"
sqerms	.byte	"BAD SEQUENCE ERROR$"
icerms	.byte	"INVALID CHARACTER$"
;clear com pointer
clrcom	lda	#<combuf	;get low
	ldy	#>combuf	;and high
	sta	compnt		;pointer
	sty	compnt+1	;and set
	rts
;insert byte into com file
insert	ldx	compnt		;compare low pointer
	cpx	commax		;to max
	bne	nocmwr		;branch if not there
	ldx	compnt+1	;do same
	cpx	commax+1	;for high
	bne	nocmwr		;bytes
	pha			;save byte
	jsr	wrtbuf		;write file
	pla			;get byte
nocmwr	ldy	#0		;clear index
	sta	(compnt),y	;save byte
	inc	compnt		;bump
	bne	*+4		;pointer
	inc	compnt+1	;for next
	rts
;write com buffer
wrtbuf	jsr	clrcom		;clear pointer
wrtclp	lda	compnt		;set
	ldy	compnt+1	;pointer
	ldx	#26		;and set
	jsr	pem		;buffer address
	lda	compnt		;get low pointer
	cmp	commax		;compare to max
	bne	docwrt		;write if not there
	lda	compnt+1	;also check
	cmp	commax+1	;high pointer
	bne	docwrt		;write if different
	jmp	clrcom		;else clear pointer and exit
docwrt	jsr	wrtcom		;write record
	cmp	#0		;test for ok
	beq	*+5		;continue if ok
	jmp	outerr		;else error
	clc			;bump
	lda	compnt		;pointer
	adc	#128		;by 128
	sta	compnt		;and
	bcc	*+4		;save for
	inc	compnt+1	;next
	inc	record		;also
	bne	*+4		;bump
	inc	record+1	;record count
	jmp	wrtclp		;and loop
;tables
kimtyp	.byte	"KIM"
comtyp	.byte	"COM"
;messages
nxtadr	.byte	cr,lf,"NEXT ADDRESS=$"
bytrde	.byte	cr,lf,"BYTES READ=$"
recwrt	.byte	cr,lf,"RECORDS WRITTEN=$"
;com file buffer
	*=	*/256*256+256
combuf
	.end
	