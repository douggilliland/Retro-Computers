	opt	l
	opt	s
	opt	s19

pia	equ	$c000
piaa	equ	pia+0
cra	equ	pia+1
piab	equ	pia+2
crb	equ	pia+3
uart	equ	$c400
rbr	equ	uart+0
thr	equ	uart+0
ier	equ	uart+1
iir	equ	uart+2
fcr	equ	uart+2
lcr	equ	uart+3
mcr	equ	uart+4
lsr	equ	uart+5
msr	equ	uart+6
scr	equ	uart+7
dll	equ	uart+0
dlm	equ	uart+1
eeprom	equ	$e000
initstack	equ	$c000
inbuf	equ	$be00
sdws	equ	$bd00
hcflag	equ	$bdff
blkbuf	equ	$bb00
ptype	equ	$baff
pstart	equ	$bafb
fatsec	equ	$baf7
rdirsec	equ	$baf3
sec0	equ	$baef
sperc	equ	$baee
rseed	equ	$baec
seeded	equ	$baeb


	org	$fff2

	fdb	nilint	; swi3
	fdb	nilint	; swi2
	fdb	nilint	; fiq
	fdb	nilint	; irq
	fdb	nilint	; swi
	fdb	nilint	; nmi
	fdb	reset

	org	$fe00

nilint
	rti

reset
	; Set up UART
	lda	#$83
	sta	lcr
	lda	#12
	sta	dll
	clr	dlm
	lda	#3
	sta	lcr
	; 0 says we got at least far enough to talk
	; to the UART
	lda	#'0
reslp0
	ldb	lsr
	andb	#$20
	beq	reslp0
	sta	thr
	; 1 says we seem to be able to talk to the PIA
	; Set up PIA
	lda	piaa
	lbne	rstfail
	lda	#$ff
	sta	piaa
	cmpa	piaa
	lbne	rstfail
	lda	piab
	lbne	rstfail
	lda	#$71
	sta	piab
	cmpa	piab
	lbne	rstfail
	lda	#4
	sta	cra
	sta	crb
	lda	cra
	anda	#$3f
	cmpa	#$04
	lbne	rstfail
	lda	crb
	anda	#$3f
	cmpa	#$04
	lbne	rstfail
	lda	#$26
	sta	piaa
	cmpa	piaa
	bne	rstfail
	lda	#$11
	sta	piab
	lda	piab
	anda	#$71
	cmpa	#$11
	bne	rstfail
	lda	#'1
reslp1
	ldb	lsr
	andb	#$20
	beq	reslp1
	sta	thr
	; Do a simple memory test and print 2 if successful
	ldx	#0
memlp1
	stx	,x++
	cmpx	#$c000
	bne	memlp1
	ldx	#0
memlp2
	cmpx	,x++
	bne	rstfail
	cmpx	#$c000
	bne	memlp2
	lda	#'2
reslp2
	ldb	lsr
	andb	#$20
	beq	reslp2
	sta	thr

	lds	#initstack
	clr	seeded

	; Set up PIA
	lda	#$ff
	sta	piaa
	lda	#$71
	sta	piab
	lda	#4
	sta	cra
	sta	crb
	lda	#$26
	sta	piaa
	lda	#$11
	sta	piab

	; Set up UART
	lda	#$83
	sta	lcr
	lda	#12
	sta	dll
	clr	dlm
	lda	#3
	sta	lcr
	jsr	autobt

	jmp	extjmp

rstfail
*	bra	rstfail

	org	eeprom

extjmp
	jmp	warmstart
	jmp	getc
	jmp	hexdig
	jmp	getline
	jmp	gethex1
	jmp	gethex2
	jmp	putc
	jmp	outhl
	jmp	outhr
	jmp	outs
	jmp	print
	jmp	prthex
	jmp	map
	jmp	sdinit
	jmp	sdcmd
	jmp	rdblk
	jmp	wrblk
	jmp	fatinit
	jmp	fatwalk
	jmp	fatls
	jmp	fatcreate

warmstart
	lds	#initstack
	clr	seeded

	; Set up PIA
	lda	#$ff
	sta	piaa
	lda	#$71
	sta	piab
	lda	#4
	sta	cra
	sta	crb
	lda	#$26
	sta	piaa
	lda	#$11
	sta	piab

	; Set up UART
	lda	#$83
	sta	lcr
	lda	#12
	sta	dll
	clr	dlm
	lda	#3
	sta	lcr

	lbra	mon

putc
	stb	,-s
pclp
	ldb	lsr
	andb	#$20
	beq	pclp
	sta	thr
	ldb	,s+
	rts

outs
	lda	#$20
	bra	putc

print
	sta	,-s
prlp
	lda	,x+
	beq	pout
	bsr	putc
	bra	prlp
pout
	lda	,s+
	rts

phexdig
	cmpa	#9
	bgt	pbighex
	adda	#'0
	bsr	putc
	rts
pbighex
	adda	#'a-10
	bsr	putc
	rts

outhr
	anda	#$f
	bra	phexdig

outhl
	lsra
	lsra
	lsra
	lsra
	bra	phexdig

prthex
	sta	,-s
	lsra
	lsra
	lsra
	lsra
	bsr	phexdig
	lda	,s+
	anda	#$f
	bsr	phexdig
	rts

entgetc
	pshs	b	;
eglp
	ldd	rseed
	addd	#1
	std	rseed
	lda	lsr
	anda	#1
	beq	eglp
	lda	rbr
	ldb	#1
	stb	seeded
	puls	b	;
	rts

getc
	tst	seeded
	beq	entgetc
gclp
	lda	lsr
	anda	#1
	beq	gclp
	lda	rbr
	rts

getline
	pshs	a,x	;
gllp
	bsr	getc
	bsr	putc
	cmpa	#$a
	bne	g1
	lda	#$d
	jsr	putc
	bra	glout
g1
	cmpa	#$d
	bne	g2
	lda	#$a
	jsr	putc
	bra	glout
g2
	cmpa	#$8
	beq	backspace
	cmpa	#$7f
	beq	backspace
	sta	,x+
	bra	gllp
backspace
	leax	-1,x
	lda	#$20
	jsr	putc
	lda	#$8
	lbsr	putc
	bra	gllp
glout
	clra
	sta	,x+
	puls	a,x	;
	rts

skpspc
	lda	,x+
	beq	skpout
	cmpa	#$20
	beq	skpspc
	cmpa	#$09
	beq	skpspc
	lda	,-x
skpout
	rts

hexdig
	lda	,x+
	cmpa	#'0
	blt	badhex
	cmpa	#'9
	bgt	bighex
	anda	#$f
	rts
bighex
	ora	#'a-'A
	cmpa	#'a
	blt	badhex
	cmpa	#'f
	bgt	badhex
	suba	#'a-10
	rts
badhex
	lda	,-x
	lda	#$ff
	rts

gethex1
	bsr	hexdig
	tfr	a,b
	bsr	hexdig
	cmpa	#$ff
	beq	gh1done
	lslb
	lslb
	lslb
	lslb
	sta	,-s
	addb	,s+
gh1done
	tfr	b,a
	rts

dshiftadd
	sta	,-s
	lda	3,s
	ldb	4,s
	lslb
	rola
	lslb
	rola
	lslb
	rola
	lslb
	rola
	orb	,s+
	sta	2,s
	stb	3,s
	rts

gethex2
	sta	,-s
	clra
	sta	,-s
	sta	,-s
	bsr	hexdig
	cmpa	#$ff
	beq	gh2done
	bsr	dshiftadd
	bsr	hexdig
	cmpa	#$ff
	beq	gh2done
	bsr	dshiftadd
	bsr	hexdig
	cmpa	#$ff
	beq	gh2done
	bsr	dshiftadd
	bsr	hexdig
	cmpa	#$ff
	beq	gh2done
	bsr	dshiftadd
gh2done
	ldy	,s++
	lda	,s+
	rts

*spixfr
*	stb	,-s
*	ldb	#8
*sxloop
*	stb	,-s
*	ldb	piab
*	andb	#$9f
*	rola
*	bcc	sx1
*	orb	#$20
*sx1
*	stb	piab
*	orb	#$40
*	stb	piab
*	andcc	#$fe
*	tst	piab
*	bpl	sx2
*	orcc	#1
*sx2
*	ldb	,s+
*	decb
*	bne	sxloop
*	rola
*	ldb	,s+
*	rts

*spixfr
*	pshs	b,x	; 8	46+8*38=350 = 175uS
*	ldb	#8	; 2
*	stb	,-s	; 6
*	ldx	#piab	; 3
*	ldb	,x	; 4
*sxloop
*	andb	#$9f	; 2
*	rola		; 2
*	bcc	sx1	; 3
*	orb	#$20	; 2
*sx1
*	stb	,x	; 4
*	orb	#$40	; 2
*	stb	,x	; 4
*	ldb	,x	; 4
*	bpl	sx2	; 3
*	orcc	#1	; 3
*	dec	,s	; 6
*	bne	sxloop	; 3
*	bra	sx3	; 3
*sx2
*	andcc	#$fe	; 3
*	dec	,s	; 6
*	bne	sxloop	; 3
*sx3
*	rola		; 2
*	leas	1,s	; 5
*	puls	b,x	; 8
*	rts		; 5

spixfr
	pshs	b,x	; 8	15: total 15+25+6*27+44=246 = 123uS
	ldx	#piab	; 3
	ldb	,x	; 4
sxloop
	andb	#$1f	; 2	25
	rola		; 2
	bcc	sx1	; 3
	orb	#$20	; 2
sx1
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx2	; 3
	orb	#$40	; 2
sx2
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx3	; 3
	orb	#$40	; 2
sx3
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx4	; 3
	orb	#$40	; 2
sx4
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx5	; 3
	orb	#$40	; 2
sx5
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx6	; 3
	orb	#$40	; 2
sx6
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	27
	rola		; 2
	bcc	sx7	; 3
	orb	#$40	; 2
sx7
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2

	andb	#$3f	; 2	44
	rola		; 2
	bcc	sx8	; 3
	orb	#$40	; 2
sx8
	lsrb		; 2
	stb	,x	; 4
	orb	#$40	; 2
	stb	,x	; 4
	ldb	,x	; 4
	lslb		; 2
	rola		; 2
	puls	b,x	; 8
	rts		; 5

sdcmd
	sta	,-s
	lda	piab
	anda	#$ef
	sta	piab
sc2
	tstb
	bne	sc1
	lda	,s+
	rts
sc1
	lda	,x+
	lbsr	spixfr
	decb
	bra	sc2

sdfini
	pshs	a	;
	lda	piab
	ora	#$10
	sta	piab
	lda	#$ff
	jsr	spixfr
	puls	a	;
	rts

sdresp
	pshs	b	;
	ldb	#$ff
sr1
	lda	#$ff
	lbsr	spixfr
	tsta
	bpl	sr2
	decb
	bne	sr1
	lda	#$ff
sr2
	puls	b	;
	rts

sdinit
	pshs	b,x
	clra
	sta	hcflag
	lda	piab
	anda	#$ef
	sta	piab
	ldb	#10
siloop
	lda	#$ff
	jsr	spixfr
	decb
	bne	siloop
	lda	piab
	ora	#$10
	sta	piab
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	ldb	#6
	ldx	#sdcmd0
	jsr	sdcmd
	jsr	sdresp
	cmpa	#$ff
	bne	do8
	jsr	sdfini
	ldx	#nosd
	jsr	print
	puls	b,x	;
	lda	#$ff
	rts
do8
	ldb	#6
	ldx	#sdcmd8
	jsr	sdcmd
	jsr	sdresp
	cmpa	#1
	bne	do8

	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	jsr	sdfini
siloop2
	ldb	#6
	ldx	#sdcmd55
	jsr	sdcmd
	jsr	sdresp
	jsr	sdfini
	cmpa	#1
	bne	siloop2
	ldb	#6
	ldx	#sdacmd41
	jsr	sdcmd
	jsr	sdresp
	jsr	sdfini
	anda	#1
	bne	siloop2
siloop3
	ldb	#6
	ldx	#sdcmd58
	jsr	sdcmd
	jsr	sdresp
	anda	#1
	bne	siloop3
	lda	#$ff
	jsr	spixfr
	anda	#$40
	sta	hcflag
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	jsr	sdfini

	ldb	#6
	ldx	#sdcmd16
	jsr	sdcmd
	jsr	sdresp
	jsr	sdfini
	puls	b,x	;
	clra
	rts

sdcmd0
	fcb	$40,$00,$00,$00,$00,$95
sdcmd8
	fcb	$48,$00,$00,$01,$aa,$87
sdcmd13
	fcb	$4d,$00,$00,$00,$00,$ff
sdcmd16
	fcb	$50,$00,$02,$00,$00,$ff
sdacmd41
	fcb	$69,$40,$ff,$80,$00,$ff
sdcmd55
	fcb	$77,$00,$00,$00,$00,$ff
sdcmd58
	fcb	$7a,$00,$00,$00,$00,$ff

rdblk
	pshs	a,b,x	;
	ldx	#sdws
	lda	#$51
	sta	,x
	tst	hcflag
	bne	rdhc
	clr	4,x
	lda	11,s
	lsla
	sta	3,x
	lda	10,s
	rola
	sta	2,x
	lda	9,s
	rola
	sta	1,x
	bra	rdx
rdhc
	lda	8,s
	sta	1,x
	lda	9,s
	sta	2,x
	lda	10,s
	sta	3,x
	lda	11,s
	sta	4,x
rdx
	lda	#$1
	sta	5,x
	ldb	#6
	jsr	sdcmd
	jsr	sdresp
	beq	sdrdwait
	jsr	prthex
	lda	#$ff
	jsr	spixfr
	jsr	sdfini
	puls	a,b,x
	rts
sdrdwait
	lda	#$ff
	jsr	spixfr
	cmpa	#$ff
	beq	sdrdwait
	ldx	6,s
	tfr	x,d
	addd	#512
	std	,--s
sdrdloop
	lda	#$ff
	jsr	spixfr
	sta	,x+
	cmpx	,s
	bne	sdrdloop
	ldd	,s++
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	jsr	sdfini
	puls	a,b,x
	rts

wrblk
	pshs	a,b,x
	ldx	#sdws
	lda	#$58
	sta	,x
	tst	hcflag
	bne	wrhc
	clr	4,x
	lda	11,s
	lsla
	sta	3,x
	lda	10,s
	rola
	sta	2,x
	lda	9,s
	rola
	sta	1,x
	bra	wrx
wrhc
	lda	8,s
	sta	1,x
	lda	9,s
	sta	2,x
	lda	10,s
	sta	3,x
	lda	11,s
	sta	4,x
wrx
	lda	#$1
	sta	5,x
	ldb	#6
	jsr	sdcmd
	jsr	sdresp
	bne	sdwrdone
;	beq	sdwrstart
;	jsr	prthex
;	bra	sdwrdone
sdwrstart
	lda	#$ff
	jsr	spixfr
	ldx	6,s
	tfr	x,d
	addd	#512
	std	,--s
	lda	#$fe
	jsr	spixfr
sdwrloop
	lda	,x+
	jsr	spixfr
	cmpx	,s
	bne	sdwrloop
	leas	2,s
	lda	#$ff		; fake CRC
	jsr	spixfr
	lda	#$ff
	jsr	spixfr
	lda	#$ff		; get data response
	jsr	spixfr
	anda	#$1f
	cmpa	#$5
	bne	sdwrdone
;	beq	sdwrwait
;	jsr	prthex
;	bra	sdwrdone
sdwrwait
	lda	#$ff
	jsr	spixfr
	tsta
	beq	sdwrwait
	ldx	#sdcmd13	; get status
	ldb	#$6
	jsr	sdcmd
	jsr	sdresp
	sta	,-s
	lda	#$ff
	jsr	spixfr
	tfr	a,b
	lda	,s+
	anda	#$fe
	cmpd	#0
	beq	sdwrdone
	bra	sdwrwait
;	jsr	prthex
;	tfr	b,a
;	jsr	prthex
sdwrdone
	lda	#$ff
	jsr	spixfr
	jsr	sdfini
	puls	a,b,x
	rts

nosd
	fcc	"No SD card"
	fcb	$d,$a,0

	org	eeprom+$500
	
mon
	; Write the greeting message
	ldx	#greet
	lbsr	print

com_loop
	ldx	#prompt
	lbsr	print
	ldx	#inbuf
	lbsr	getline
	ldx	#inbuf
	ldb	,x+
	beq	com_loop
	orb	#'a-'A
	cmpb	#'a
	bge	t1
	lbsr	nocmd
	bra	com_loop
t1
	cmpb	#'z
	blt	t2
	lbsr	nocmd
	bra	com_loop
t2
	subb	#'a
	lslb
	ldy	#comtab
	jsr	[b,y]
	lda	#$d
	jsr	putc
	lda	#$a
	jsr	putc
	bra	com_loop

wait
	sync
	bra	wait

greet
	fcb	$d,$a
	fcc	"AHCS 6809 SBC"
crlf
	fcb	$d,$a,0
prompt
	fcc	"; "
	fcb	0

badcmd
	fcc	"Unimplemented command"
	fcb	$d,$a,0

	org	eeprom+$580

comtab
	fdb	autobt	;a
	fdb	boot	;b
	fdb	nocmd	;c
	fdb	deposit	;d
	fdb	examine	;e
	fdb	memfill	;f
	fdb	go	;g
	fdb	help	;h
	fdb	sdinit	;i
	fdb	nocmd	;j
	fdb	nocmd	;k
	fdb	load	;l
	fdb	mappage	;m
	fdb	nocmd	;n
	fdb	oldboot	;o
	fdb	nocmd	;p
	fdb	nocmd	;q
	fdb	sdread	;r
	fdb	nocmd	;s
	fdb	nocmd	;t
	fdb	nocmd	;u
	fdb	nocmd	;v
	fdb	sdwrite	;w
	fdb	nocmd	;x
	fdb	nocmd	;y
	fdb	nocmd	;z

helpmsg
	fcc	"a - autoboot"
	fcb	$d,$a
	fcc	"b - boot"
	fcb	$d,$a
	fcc	"d val addr - deposit"
	fcb	$d,$a
	fcc	"e addr [-addr] - examine"
	fcb	$d,$a
	fcc	"f addr count val - fill area of memory"
	fcb	$d,$a
	fcc	"g addr - go"
	fcb	$d,$a
	fcc	"h - help"
	fcb	$d,$a
	fcc	"i - initialize SD card"
	fcb	$d,$a
	fcc	"l addr - load"
	fcb	$d,$a
	fcc	"m page frame - set memory map"
	fcb	$d,$a
	fcc	"p addr - program eeprom"
	fcb	$d,$a
	fcc	"r block addr - read microSD block"
	fcb	$d,$a
	fcc	"w block addr - write microSD block"
	fcb	0

syntax	fcc	"syntax error"
	fcb	$d,$a,0

	org	eeprom+$780

nocmd
	ldx	#badcmd
	lbsr	print
	rts

setupsd
	jsr	skpspc
	jsr	gethex2
	sty	6,s
	lda	#0
	sta	5,s
	sta	4,s
	jsr	skpspc
	jsr	gethex2
	sty	2,s
	rts

sdread
	leas	-6,s
	jsr	setupsd
	jsr	rdblk
	leas	6,s
	rts

sdwrite
	leas	-6,s
	jsr	setupsd
	jsr	wrblk
	leas	6,s
	rts

deposit
	jsr	skpspc
	jsr	gethex1
	pshs	a	;
	jsr	skpspc
	jsr	gethex2
	puls	a	;
	sta	,y
	rts

examine
	jsr	skpspc
	jsr	gethex2
	jsr	skpspc
	tsta
	bne	ex1
	lda	,y
	jsr	prthex
	rts
ex1
	lda	,x+
	cmpa	#'-
	bne	exerr
	sty	,--s
	jsr	skpspc
	jsr	gethex2
	ldx	,s++
	sty	,--s
	clrb
	stb	,-s
exloop
	cmpx	1,s
	bgt	exdone
	lda	,x+
	jsr	prthex
	ldb	,s+
	incb
	cmpb	#$10
	bge	exline
	stb	,-s
	lda	#$20
	jsr	putc
	bra	exloop
exline
	clrb
	stb	,-s
	lda	#$0d
	jsr	putc
	lda	#$0a
	jsr	putc
	bra	exloop
exdone
	ldb	,s+
	ldy	,s++
	rts
exerr
	ldx	#syntax
	jsr	print
	rts

go
	jsr	skpspc
	jsr	gethex2
	jsr	,y
	rts

memfill
	jsr	skpspc
	jsr	gethex2
	pshs	y	;
	jsr	skpspc
	jsr	gethex2
	pshs	y	;
	ldd	2,s
	addd	,s
	std	,s
	jsr	skpspc
	jsr	gethex1
	ldx	2,s
mflp
	sta	,x+
	cmpx	,s
	bne	mflp
	leas	4,s
	rts

load
	jsr	skpspc
	jsr	gethex2
ldloop
	sty	,--s
	lda	,s+
	jsr	prthex
	lda	,s+
	jsr	prthex
	lda	#':
	jsr	putc
	lda	#$20
	jsr	putc
	lda	,y
	jsr	prthex
	lda	#$20
	jsr	putc
	lda	#'>
	jsr	putc
	lda	#$20
	jsr	putc
	ldx	#inbuf
	jsr	getline
	ldx	#inbuf
	jsr	skpspc
	tsta
	beq	ldout
	jsr	gethex1
	sta	,y+
	bra	ldloop
ldout
	rts

mappage
	jsr	skpspc
	jsr	gethex1
	pshs	a	;
	jsr	skpspc
	jsr	gethex1
	puls	b		; a  has frame, b has page
map
	pshs	a	;
	cmpa	#3
	bne	not3
	lda	piab
	cmpb	4
	blt	lopage
	ora	#1
	bra	hidone
lopage
	anda	#$fe
hidone
	sta	piab
	lda	,s
not3
	mul
	puls	a	;
	ldx	#framemask
	lda	a,x
	coma
	anda	piaa
	ldx	#pagetran
	ora	b,x
	sta	piaa
	rts

pagetran
	fcb	$00,$01,$08,$09,$40,$41,$48,$49
	fcb	$00,$02,$10,$12,$80,$82,$90,$92
	fcb	$00,$04,$20,$24,$00,$04,$20,$24
framemask
	fcb	$49, $92, $24

help
	ldx	#helpmsg
	lbsr	print
	rts

oldboot
	jsr	sdinit
	tsta
	beq	ob1
	rts
ob1
	leas	-6,s
	clra
	sta	4,s
	sta	3,s
	sta	2,s
	sta	1,s
	lda	#1
	sta	5,s
	sta	,s
	jsr	rdblk
	leas	6,s
getname
	ldx	#bprompt
	jsr	print
	ldx	#inbuf
	jsr	getline
	lda	,x
	cmpa	#'?
	bne	notq
	bsr	menu
	bra	getname
notq
	ldy	#$102
search
	ldx	#inbuf
	bsr	strcmp
	beq	found
	leay	32,y
	bra	search
found
	leas	-6,s
	clra
	sta	4,s
	sta	3,s
	sta	2,s
	sta	1,s
	lda	#1
	sta	,s
	lda	-2,y
	ldb	-1,y
blloop
	sta	5,s
	jsr	rdblk
	decb
	beq	lddone
	stb	,-s
	ldb	1,s
	addb	#2
	stb	1,s
	ldb	,s+
	inca
	bra	blloop
lddone
	leas	6,s
	jsr	$100
	rts

menu
	ldy	#$102
mloop
	lda	,y
	beq	skipit
	tfr	y,x
	jsr	print
	lda	#$20
	jsr	putc
skipit
	leay	32,y
	cmpy	#$300
	blt	mloop
	ldx	#crlf
	jsr	print
	rts

strcmp
	clrb
cmploop
	lda	,x+
	cmpa	b,y
	bne	done
	tsta
	beq	done
	incb
	bra	cmploop
done
	rts

abname	fcc	"AUTOBOOT"
	fcb	0

autobt
	jsr	fatinit
	tsta
	beq	doab
	rts
doab
	ldx	#inbuf
	ldy	#abname
ablp
	lda	,y+
	sta	,x+
	bne	ablp
	bra	ucdone

bprompt	fcc	"@ "
	fcb	0

boot
	jsr	fatinit
	tsta
	beq	bploop
	rts
bploop
	; load a file and run
	ldx	#bprompt
	jsr	print
	ldx	#inbuf
	jsr	getline
	lda	inbuf
	cmpa	#'?
	bne	dontls
	jsr	fatls
	bra	bploop
dontls
	ldx	#inbuf
uclp
	lda	,x
	beq	ucdone
	cmpa	#'a
	blt	dontuc
	anda	#$df
dontuc
	sta	,x+
	bra	uclp
ucdone
	ldx	#inbuf
	jsr	fatwalk
	tsta
	beq	ucd1
	rts
ucd1
	lda	sec0+3
	pshs	a	;
	lda	sec0+2
	pshs	a	;
	lda	sec0+1
	pshs	a	;
	lda	sec0
	pshs	a	;
	lda	$1a,y
	ldb	sperc
	mul
	addb	3,s
	stb	3,s
	adca	2,s
	sta	2,s
	lda	$1b,y
	ldb	sperc
	mul
	addb	2,s
	stb	2,s
	adca	1,s
	sta	1,s
	lda	ptype
	cmpa	#$0b
	bne	pushadr
	lda	$14,y
	ldb	sperc
	mul
	addb	1,s
	stb	1,s
	adca	,s
	sta	,s
	lda	$15,y
	ldb	sperc
	mul
	addb	,s
	stb	,s
pushadr
	ldd	#$100
	pshs	d	;
	ldb	$1d,y
	lsrb
	incb
blklp
	jsr	rdblk
	decb
	beq	runit
	lda	5,s
	inca
	sta	5,s
	clra
	adca	4,s
	sta	4,s
	clra
	adca	3,s
	sta	3,s
	clra
	adca	2,s
	sta	2,s
	lda	,s
	adda	#2
	sta	,s
	bra	blklp

runit
	leas	6,s
	jsr	$100
	rts

fatinit
	jsr	sdinit
	tsta
	beq	fi1
	rts
fi1
	ldx	#0
	pshs	x	;
	pshs	x	;
	ldx	#blkbuf
	pshs	x	;
	jsr	rdblk
	leas	6,s
	ldy	#blkbuf+$1be
	lda	4,y
	sta	ptype
	lda	8,y
	sta	pstart+3
	pshs	a	;
	lda	9,y
	sta	pstart+2
	pshs	a	;
	lda	10,y
	sta	pstart+1
	pshs	a	;
	lda	11,y
	sta	pstart
	pshs	a	;
	ldx	#blkbuf
	pshs	x	;
	jsr	rdblk
	leas	6,s
	ldy	#blkbuf+$b
	lda	2,y
	sta	sperc
	lda	4,y
	ldb	3,y
	addd	pstart+2
	std	fatsec+2
	ldd	pstart
	adcb	#0
	adca	#0
	std	fatsec
	lda	ptype
	cmpa	#$0b
	lbne	not32
	;
	; compute the starting point of the root dir
	;
	clr	rdirsec
	clr	rdirsec+1
	ldb	5,y
	lda	$19,y
	mul
	std	rdirsec+2
	ldb	5,y
	lda	$1a,y
	mul
	addd	rdirsec+1
	std	rdirsec+1
	ldb	5,y
	lda	$1b,y
	mul
	addd	rdirsec
	std	rdirsec
	ldb	5,y
	lda	$1c,y
	mul
	addb	rdirsec
	stb	rdirsec
	lda	rdirsec+3
	adda	fatsec+3
	sta	rdirsec+3
	lda	rdirsec+2
	adca	fatsec+2
	sta	rdirsec+2
	lda	rdirsec+1
	adca	fatsec+1
	sta	rdirsec+1
	lda	rdirsec
	adca	fatsec
	sta	rdirsec
	;
	; for FAT32, the pseudo-sector 0 is two clusters
	; before the root directory
	;
	lda	sperc
	lsla
	pshs	a	;
	lda	rdirsec+3
	suba	,s+
	sta	sec0+3
	lda	rdirsec+2
	sbca	#0
	sta	sec0+2
	lda	rdirsec+1
	sbca	#0
	sta	sec0+1
	lda	rdirsec
	sbca	#0
	sta	sec0
	clra
	rts

not32
	;
	; compute the starting point of the root dir
	;
	clr	rdirsec
	clr	rdirsec+1
	ldb	5,y
	lda	11,y
	mul
	std	rdirsec+2
	ldb	5,y
	lda	12,y
	mul
	addd	rdirsec+1
	std	rdirsec+1
	lda	rdirsec+3
	adda	fatsec+3
	sta	rdirsec+3
	lda	rdirsec+2
	adca	fatsec+2
	sta	rdirsec+2
	lda	rdirsec+1
	adca	fatsec+1
	sta	rdirsec+1
	lda	rdirsec
	adca	fatsec
	sta	rdirsec
	;
	; for FAT16, the pseudo sector 0 is 2 clusters
	; before the end of the root directory
	;
	lda	sperc
	lsla
	pshs	a	;
	lda	rdirsec+3
	suba	,s+
	sta	sec0+3
	lda	rdirsec+2
	sbca	#0
	sta	sec0+2
	lda	rdirsec+1
	sbca	#0
	sta	sec0+1
	lda	rdirsec
	sbca	#0
	sta	sec0
	lda	blkbuf+$12
	ldb	blkbuf+$11
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	addb	sec0+3
	stb	sec0+3
	adca	sec0+2
	sta	sec0+2
	lda	sec0+1
	adca	#0
	sta	sec0+1
	lda	sec0
	adca	#0
	sta	sec0
	clra
	rts

fatwalk
	pshs	x	;
	ldd	rdirsec+2
	pshs	d	;
	ldd	rdirsec
	pshs	d	;
	ldx	#blkbuf
	pshs	x	;
fwblk
	jsr	rdblk
	ldy	#blkbuf
fsearch
	tst	,y
	beq	fnotfound
	lda	$b,y
	anda	#$8
	bne	nmskip
	ldx	6,s
	lbsr	strcmp
	tsta
	beq	ffound
nmskip
	leay	$20,y
	cmpy	#blkbuf+$200
	blt	fsearch
	ldd	4,s
	addd	#1
	std	4,s
	bra	fwblk
ffound
	leas	8,s
	clra
	rts
fnotfound
	leas	8,s
	ldx	#nfmsg
	jsr	print
	lda	#$ff
	rts

nfmsg	fcc	"not found"
	fcb	$d,$a,0

fatls
	ldd	rdirsec+2
	pshs	d	;
	ldd	rdirsec
	pshs	d	;
	ldx	#blkbuf
	pshs	x	;
lsblk
	jsr	rdblk
	ldx	#blkbuf
lsloop
	tst	,x
	lbeq	lsdone
	lda	$b,x
	anda	#$8
	bne	lsskip
	clrb
namlp
	lda	b,x
	cmpa	#$20
	beq	skplet
	jsr	putc
skplet
	incb
	cmpb	#$8
	bne	namlp
	lda	#$2e
	jsr	putc
extlp
	lda	b,x
	cmpa	#$20
	beq	skplet2
	jsr	putc
skplet2
	incb
	cmpb	#$b
	bne	extlp
	lda	#$20
	jsr	putc
	lda	ptype
	cmpa	#$0b
	bne	smallsec
	lda	$15,x
	jsr	prthex
	lda	$14,x
	jsr	prthex
smallsec
	lda	$1b,x
	jsr	prthex
	lda	$1a,x
	jsr	prthex
	lda	#$20
	jsr	putc
	lda	$1f,x
	jsr	prthex
	lda	$1e,x
	jsr	prthex
	lda	$1d,x
	jsr	prthex
	lda	$1c,x
	jsr	prthex
	pshs	x	;
	ldx	#crlf
	jsr	print
	puls	x	;
lsskip
	leax	$20,x
	cmpx	#blkbuf+$200
	lblt	lsloop
	ldd	4,s
	addd	#1
	std	4,s
	lbra	lsblk
lsdone
	leas	6,s
	rts

fatcreate
	pshs	x	;
	ldd	rdirsec+2
	pshs	d	;
	ldd	rdirsec
	pshs	d	;
	ldx	#blkbuf
	pshs	x	;
fcblk
	jsr	rdblk
	ldy	#blkbuf

	rts
