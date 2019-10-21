;  1010001B  1324O  200D 200 200. de3aH 
;  &O377 &He3ba

	z80
	org	&H1000	
table	equ	&h2000
symbol1	equ	&H11
symbol2	equ	&H22
symbol3	equ	&H33
symbol4	equ	&H44
symbol5	equ	&H55
symbol6	equ	&H6666
symbol7	equ	&H7777
symbol8	equ	&H8888
symbol9	equ	&H9999

bin1	equ	11101110b
bin2	equ	0b
bin3	equ	123b
bin4	equ	0101010101010101010b

;symbols are case sensitive these are different

Symbol1	equ	22h
Symbol2	equ	380o
Symbol3	equ	45h
Symbol4	equ	0a0h
Symbol5	equ	9bh
Symbol6	equ	6666o
Symbol7	equ	7777o
Symbol8	equ	8888h
Symbol9	equ	9999h

	page	66
	page
	title	"xyz"

table2	db	100,200,50
	db	0,0,0,'4',0,0,0,0,'p',0,0,0,0,'a',0,0,0,0,0,0
	dw	5,5,5,5,5,'3',5,5,5,5,5
text:	text	'This "is" text';comment
	text	"More ; 'text' and '"	;comment
	text	"Text	with	Tabs"
	text	'More text ;comment
	textz	"Text terminated with" a NULL
	texts	"Text with sign bit set"
var:	ds	500
length	equ	$-var

	org	&h5000
var1	ds 	50*2
iobuf	dw	&Ha3d5,&ha300+5
iocnt	db	symbol5-74o,symbol7
	org	&H6000
var2	db	&h10+14o
var3	ds	&h100
var4	db	&h20+6
var5	ds	&h200	
var6	db 	&h30-&o17
var7	ds 	&h500
	org	&H7000
var8	ds 	&H500
var9	ds	&h100
var0	ds	&h200
	org	&H8000

	cma		;comment 
	neg		;comment 
	daa		;comment 
	stc		;comment 
	cmc		;comment 
	nop		;comment 
	hlt		;comment 
	exaf		;comment 
	exx		;comment 
	xthl		;comment 
	xtix		;comment 
	xtiy		;comment 
	xchg		;comment 
	pchl		;comment 
	pcix		;comment 
	pciy		;comment 
	sphl		;comment 
	spix		;comment 
	spiy		;comment 
	di		;comment 
	ei		;comment 
	ldai		;comment 
	stai		;comment 
	ldar		;comment 
	star		;comment 
	im0		;comment 
	im1		;comment 
	im2		;comment 

	rst	0
	rst	7

	adi	10
	aci	10
	sui	10
	sbi	20
	ani	20
	xri	55
	ori	66
; should be cpi but might conflict with z80 cpi if not cci
	cmpi	30	
	cpi	'Y'
	add	b
	add	c
	add	d
	add	e
	add	h
	add	l
	add	m
	add	a
	add	(hl)
	add	4(ix)
	add	4(iy)
	add	b

	ora	c
	ora	d
	ora	e
	ora	h
	ora	l
	ora	m
	ora	a
	ora	5(ix)
	ora	6(iy)

	lda	iobuf
	sta	iobuf

	ldax	bc
	ldax	de
; these not allowed
	ldax	hl
	ldax	sp
	ldax	ix
	ldax	iy

	stax	bc
	stax	de
; these not allowed
	stax	hl
	stax	sp
	stax	ix
	stax	iy


        lbcd    table   ;comment
	lded	table
	lhld	table
	lspd	table
	lixd	table
	liyd	table

        sbcd    table   ;comment
	sded	table
	shld	table
	sspd	table
	sixd	table
	siyd	table

	lxi	bc,symbol1
	lxi	de,symbol2
	lxi	hl,symbol3
	lxi	sp,iobuf	;comment 8:36 PM 2/3/04
	lxi	ix,loop
	lxi	iy,loop

	dadc	bc
	dadc	de
	dadc	hl
	dadc	sp
; ix iy not allowed
	dadc	ix
	dadc	iy

	dad	bc
	dad	de
	dad	hl
	dad	sp
; ix iy not allowed
	dad	ix
	dad	iy

	dadx	bc
	dadx	de
; hl not allowed
	dadx	hl
	dadx	sp
	dadx	ix
	dadx	iy

	dady	bc
	dady	de
; hl not allowed
	dady	hl
	dady	sp
	dady	ix
	dady	iy

	inx	bc
	inx	de
	inx	hl
	inx	sp
	inx	ix
	inx	iy
	inxix
	inxiy		;maclib z80
	dcx	bc
	dcx	de
	dcx	hl
	dcx	sp
	dcx	ix
	dcx	iy	
	dcxix
	dcxiy		;maclib z80
	pop	bc
	pop	de	
	pop	hl
; sp not allowed
	pop	sp
	pop	a
	pop	psw
	pop	ix
	pop	iy
	popix		;maclib z80
	popiy

	push	bc
	push	de	
	push	hl
; sp not allowed
	push	sp
	push	a
	push	psw
	push	ix
	push	iy
	pushix		;maclib z80
	pushiy

	in	83
	out	83

	inp	b
	inp	c
	inp	d
	inp	e
	inp	h
	inp	l
	inp	m
	inp	5(ix)
	inp	67(iy)

	ini	
	inir
	ind
	indr

	outi	
	outir
	outd
	outdr

	ldi	
	ldir
	ldd
	lddr

	cpi	
	cpir
	cpd
	cpdr

	cci	
	ccir
	ccd
	ccdr

	bit	0,b
	bit	1,c
	bit	2,d
	bit	3,e
	bit	4,h
	bit	5,l
	bit	6,m
	bit	7,8(ix)
	bit	6,9(iy)

	bset	0,b
	set	1,c
	setb	2,d
	bset	3,e
	setb	4,h
	set	5,l
	set	6,m
	set	7,8(ix)
	set	6,9(iy)


	res	0,b
	res	1,c
	res	2,d
	res	3,e
	res	4,h
	res	5,l
	res	6,m
	res	7,8(ix)
	res	6,9(iy)

	rld
	rrd

	rlc
	rlca
	rrc
	rrca
	ral
	rla
	rar
	rra

	rlcr	b
	rlar	c
	rrcr	d
	rrar	e
	slar	h
	srar	l
	srlr	m
	srlr	&H34(ix)
	srlr	&H55(iy)

	mvi	b,36
	mvi	c,-10
	mvi	d,36
	mvi	e,-10
	mvi	h,36
	mvi	l,-10
	mvi	m,36
; need to check order of disp and data
	mvi	&H88(ix),-10
	mvi	&H99(iy),36
	
loop	mov	l,b
	mov	h,c
	mov	e,d
	mov	d,e
	mov	c,h
	mov	b,l
	mov	a,m
	mov	m,a
	mov	a,&H99(ix)
	mov	a,&H99(iy)
	mov	&H99(ix),a
	mov	&H99(iy),a
;generates HALT
	mov	m,m
; not allowed
	mov	&H99(ix),&H88(ix)
	mov	&H99(ix),&H88(iy)
	mov	m,&H99(iy)
	mov	&H99(ix),m

	jmp	loop
	jnz	loop
	jz	loop
	jnc	loop
	jc	loop
	jpo	loop
	jpe	loop
	jp	loop
	jm	loop

	jr	loop
	jmpr	loop
	jrnz	loop
	jrz	loop
	jrnc	loop
	jrc	loop

	call	loop
	cnz	loop
	cz	loop
	cnc	loop
	cc	loop
	cpo	loop
	cpe	loop
	cp	loop
	cm	loop

	ret
	rnz
	rz
	rnc
	rc
	rpo
	rpe
	rp
	rm

	reti
	retn
	
	jr	$-131
	jr	$+131
	jr	$-130
	jr	$+130
	jr	$-129
	jr	$+129
	jr	$-128
	jr	$+128
	jr	$-127
	jr	$+127
	jr	$-126
	jr	$+126
	jr	$-125
	jr	$+125
	jr	$-124
	jr	$+124