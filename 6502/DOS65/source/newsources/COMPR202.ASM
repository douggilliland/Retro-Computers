;file comparison routine
;the command syntax for this routine is
;	compare file1 file2
;where file1 and file2 are both ufns.
;version 2.02-A
;released:	18 july 1983
;last revision:	
;	28 december 1985
;		increased byte count to 3
;	31 march 2008
;		converted to TASM ASM21x format
;		eliminated page zero 0 & 1
;definitions
cr	=	$d		;carriage return
lf	=	$a		;linefeed
eof	=	$1a		;eof character
boot	=	$100		;warm boot entry
pem	=	$103		;pem entry
dflfcb	=	$107		;default fcb
dflbuf	=	$128		;default buffer
tea	=	$800		;tea start
buflng	=	1024		;file buffer length
;page zero data definitions
	*=	2
f1pnt				;pointer into file 1
	*=	*+2
f1eof				;one past last valid byte
	*=	*+2
f2pnt				;pointer into file 2
	*=	*+2
f2eof				;one past last valid byte
	*=	*+2
eofflg				;eof flag
	*=	*+1
bytcnt				;byte counter
	*=	*+3
leadzf				;leading zero flag
	*=	*+1
moduls				;digit modulus
	*=	*+3
byte1				;byte from file one
	*=	*+1
byte2				;byte from file two
	*=	*+1
;start of main program
	*=	tea
	lda	#0		;clear eof flag
	sta	eofflg
	sta	bytcnt		;and byte count
	sta	bytcnt+1
	sta	bytcnt+2
	lda	#<f1max		;set pointers to illegal
	ldy	#>f1max
	sta	f1pnt
	sty	f1pnt+1
	sta	f1eof		;also preset eof pointer
	sty	f1eof+1
	lda	#<f2max
	ldy	#>f2max
	sta	f2pnt
	sty	f2pnt+1
	sta	f2eof
	sty	f2eof+1
	lda	#<opnmsg	;point to opening message
	ldy	#>opnmsg
	jsr	msgout		;send it
	ldx	#0		;move default fcb data
mvfcbs	lda	dflfcb,x	;get file 1
	sta	f1fcb,x
	lda	dflfcb+16,x	;then get file 2
	sta	f2fcb,x
	inx			;bump indx
	cpx	#12		;see if at limit
	bne	mvfcbs		;loop if not
	lda	#0		;clear rest of fcb
clfcbs	sta	f1fcb,x		;both 1
	sta	f2fcb,x		;and 2
	inx
	cpx	#16		;until end
	bne	clfcbs
	lda	f2fcb+1		;now see if fcb2 is blank
	cmp	#' '
	bne	ntblnk		;branch if not
	lda	f2fcb+9		;check type also
	cmp	#' '		;branch if not blank
	bne	ntblnk
	ldx	#1		;now move fcb one to two
cpfcb	lda	f1fcb,x		;get from one
	sta	f2fcb,x		;put in x
	inx			;bump index
	cpx	#12		;see if at limit
	bne	cpfcb		;loop if not
ntblnk	jsr	open1		;open first
	jsr	open2		;then second
compar	jsr	read1		;get byte from one
	jsr	read2		;get byte from two
	cmp	byte1		;compare the bytes
	beq	compar		;if same keep looping
unequl	lda	#<unemsg	;send unequal message
	ldy	#>unemsg
	jsr	msgout
	jsr	outdec		;send count
	lda	#<decmsg	;then send decimal message
	ldy	#>decmsg
	jsr	msgout
	jmp	boot		;exit with boot
;subroutines
;byte read routines
read1	jsr	f1get		;get byte
	bcs	eof1		;branch if eof
	inc	bytcnt		;else bump count
	bne	read1x		;exit if not zero
	inc	bytcnt+1
	bne	read1x		;exit if not zero
	inc	bytcnt+2
read1x	rts
;eof of file 1
eof1	lda	#128		;set flag
	sta	eofflg
	jsr	read2		;now read from two
	lda	#<ef1msg	;send eof 1 not eof 2
	ldy	#>ef1msg
	jsr	msgout
	jmp	unequl		;then say unequal
;file two
read2	jsr	f2get		;get byte
	bcc	r2ok		;exit if ok
;got eof on file 2 - did we get it on file one
	bit	eofflg		;test flag
	bmi	aok		;if set is ok
	lda	#<ef2msg	;else send eof 2 not 1
	ldy	#>ef2msg
	jsr	msgout
	jmp	unequl		;then say unequal
;files match
aok	lda	#<mchmsg	;so send message
	ldy	#>mchmsg
	jsr	msgout
	jsr	outdec		;print length
	jmp	boot
r2ok	rts
;convert three binary bytes to decimal
outdec	lda	#0		;clear leading zero flag
	sta	leadzf
;since assembler can only do 16 bit arithmetic, the
;following numbers are for 100000.
	lda	#$a0		;100000 and ff
	ldy	#$86		;(100000/256) and ff
	ldx	#$01		;100000/65536
	jsr	dodigt
	lda	#<10000		;do 10000s
	ldy	#>10000
	ldx	#0
	jsr	dodigt
	lda	#<1000		;then 1000s
	ldy	#>1000
	ldx	#0
	jsr	dodigt
	lda	#100		;then 100s
	ldy	#0
	ldx	#0
	jsr	dodigt
	lda	#10		;then 10s
	ldy	#0
	ldx	#0
	jsr	dodigt
	lda	bytcnt		;then always do 1s
	ora	#'0'
	jmp	conout
;do a single digit
dodigt	sta	moduls		;save modulus
	sty	moduls+1
	stx	moduls+2
	ldx	#$ff		;clear digit
	sec
diglpe	lda	bytcnt		;subtract until borrow
	sbc	moduls
	sta	bytcnt
	lda	bytcnt+1
	sbc	moduls+1
	sta	bytcnt+1
	lda	bytcnt+2
	sbc	moduls+2
	sta	bytcnt+2
	inx			;bump digit
	bcs	diglpe		;loop if no borrow
	lda	bytcnt		;now add modulus back
	adc	moduls
	sta	bytcnt
	lda	bytcnt+1
	adc	moduls+1
	sta	bytcnt+1
	lda	bytcnt+2
	adc	moduls+2
	sta	bytcnt+2
	txa			;test digit
	beq	digzro		;skip if zero
	sec			;else set flag
	ror	leadzf
digzro	bit	leadzf		;test flag
	bpl	dontpr		;skip if clear
	ora	#'0'		;else make ascii
	jsr	conout		;and send
dontpr	rts
;pem entries
;read file one
f1rde	lda	#<f1fcb		;point to fcb
	ldy	#>f1fcb
	jmp	rdefle
;read file two
f2rde	lda	#<f2fcb		;point to fcb
	ldy	#>f2fcb
rdefle	ldx	#20
	jmp	pem
;output char to console
conout	ldx	#2
	jmp	pem
;send message to console
msgout	ldx	#9		;get operation number
	jmp	pem		;go do it
;set dma address to value in ay
setdma	ldx	#26
	jmp	pem
;open file 1
open1	lda	#<f1fcb		;point to fcb
	ldy	#>f1fcb
	jmp	opnfle		;then go open
;open file 2
open2	lda	#<f2fcb		;point to fcb
	ldy	#>f2fcb
;open file
opnfle	ldx	#15		;open code
	jsr	pem
	bpl	opniok		;ok if positive
	lda	#<nflmsg	;say no file
	ldy	#>nflmsg
	jsr	msgout
	jmp	boot		;and exit
opniok	rts
;get byte from file one and set carry if eof
f1get	jsr	tf1pnt		;test pointer
	bcc	f1gnow		;if so go get byte
	jsr	cf1pnt		;else set pointer to start
f1lpe	lda	f1pnt		;set address
	ldy	f1pnt+1
	jsr	setdma
	jsr	f1rde		;then read record
	bne	f1end		;if not zero is eof
	jsr	bf1pnt		;bump pointer
	jsr	tf1pnt		;and test pointer
	bcc	f1lpe		;loop if more to read
f1cont	jsr	cf1pnt		;else clear pointer
f1gnow	ldy	#0		;get byte
	lda	(f1pnt),y
	sta	byte1		;save in register
	lda	f1pnt		;now see if at eof
	cmp	f1eof
	lda	f1pnt+1
	sbc	f1eof+1
	inc	f1pnt		;now bump pointer
	bne	*+4
	inc	f1pnt+1
	lda	byte1		;get byte back
	rts
;end of file for file one
f1end	lda	f1pnt		;set eof pointer
	ldy	f1pnt+1
	sta	f1eof
	sty	f1eof+1
	jmp	f1cont
;get byte from file two and set carry if eof
f2get	jsr	tf2pnt		;test pointer
	bcc	f2gnow		;if so go get byte
	jsr	cf2pnt		;else set pointer to start
f2lpe	lda	f2pnt		;set address
	ldy	f2pnt+1
	jsr	setdma
	jsr	f2rde		;then read record
	bne	f2end		;if not zero is eof
	jsr	bf2pnt		;bump pointer
	jsr	tf2pnt		;and test pointer
	bcc	f2lpe		;loop if more to read
f2cont	jsr	cf2pnt		;else clear pointer
f2gnow	ldy	#0		;get byte
	lda	(f2pnt),y
	sta	byte2		;save in register
	lda	f2pnt		;now see if eof
	cmp	f2eof
	lda	f2pnt+1
	sbc	f2eof+1
	inc	f2pnt		;now bump pointer
	bne	*+4
	inc	f2pnt+1
	lda	byte2		;get byte back
	rts
;end of file for file two
f2end	lda	f2pnt		;set eof pointer
	ldy	f2pnt+1
	sta	f2eof
	sty	f2eof+1
	jmp	f2cont
;test file one pointer and set carry if too big
tf1pnt	lda	f1pnt		;do by subtracting
	cmp	#<f1max
	lda	f1pnt+1
	sbc	#>f1max
	rts
;test file two pointer and set carry if too big
tf2pnt	lda	f2pnt		;do by subtracting
	cmp	#<f2max
	lda	f2pnt+1
	sbc	#>f2max
	rts
;set file one pointer to start
cf1pnt	lda	#<f1buf		;get start
	ldy	#>f1buf
	sta	f1pnt		;then set
	sty	f1pnt+1
	rts
;set file two pointer to start
cf2pnt	lda	#<f2buf		;get start
	ldy	#>f2buf
	sta	f2pnt		;and set
	sty	f2pnt+1
	rts
;bump file one pointer by 128
bf1pnt	clc			;clear carry
	lda	f1pnt
	adc	#128
	sta	f1pnt		;save low
	bcc	*+4
	inc	f1pnt+1		;do high if needed
	rts
;bump file two pointer by 128
bf2pnt	clc			;clear carry
	lda	f2pnt
	adc	#128
	sta	f2pnt		;save low
	bcc	*+4
	inc	f2pnt+1		;do high if needed
	rts
;messages
opnmsg	.byte	"File Comparison Routine"
	.byte	cr,lf,"Version 2.02-A$"
nflmsg	.byte	cr,lf,"One of the files "
	.byte	"does not exist!$"
crlmsg	.byte	cr,lf,"$"
mchmsg	.byte	cr,lf,"Files match - length is $"
decmsg	.byte	" (decimal)$"
unemsg	.byte	cr,lf,"Files are unequal at byte $"
ef1msg	.byte	cr,lf,"EOF on file 1 but"
	.byte	" not file 2$"
ef2msg	.byte	cr,lf,"EOF on file 2 but"
	.byte	" not file 1$"
;fcbs
f1fcb				;file 1
	*=	*+32
	.byte	0		;record
f2fcb				;file 2
	*=	*+32
	.byte	0
;buffers
f1buf				;file 1
	*=	*+buflng
f1max
f2buf				;file 2
	*=	*+buflng
f2max
	.end
