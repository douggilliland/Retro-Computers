;  1010001B  1324O  200D 200 200. de3aH 
;  &O377 &He3ba

	i8080
	org	&H1000	
table	equ	&h2000
s	equ	6+6
f	equ	n
j	equ	r
r	equ	f
w	equ	12-2
xp5	equ	x+5
n	equ	w
x 	equ	34;undef
g 	equ	45;undef
k	equ	g

	db	100,200,50
text:	dt	"abcdefg"
var:	ds	500
length	equ	$-var

	org	&h5000
var1	ds 	50*2
iobuf	dw	&Ha3d5,&ha300+5
iocnt	db	f,g

        di		;comment 8:36 PM 2/3/04
	in	j
	aci	50+j
        lhld    table   ;comment
	lbcd	table
	lxi	d,iobuf	;comment 8:36 PM 2/3/04
	lxi	ix,loop
	lxi	iy,loop
	lxi	hl,test
	dad	ix
	dad	iy	
	dad	bc
	inx	hl
	inx	ix
	dcx	bc
	dcx	iy
	pop	hl
	pop	ix	
	pop	bc
	pop	iy
	mvi	b,36
	mvi	m,-10
	lda	iocnt	;comment
	mov	b,a
loop	ldax	d
	inx	d
	inx	hl
	mov	m,a
	inx	h
	ora	m
	ora	5(ix)
	ora	(iy)
	dcr	(hl)
	dcr	-25(ix)
	dcr	500(iy)
	jrnz	exit
xout	outp	c
	outp	m
	ora	c
	bit	5,m
	res	8,c
	jrc	loop
lop	sub	c
	jmpr	loop
	dcr	c
	jmpr	lop
	dcr	m
	jrz	loop
	jnz	&hc000
	shld	table
	nop
exit:	ei
	rst	2
	rst	5
	org	&ha300
last:
test	equ	0-5
test2	equ	&Hffff-1
test3	equ	-5
test4 	equ	&Hae00
test5	equ	&H100*&200
test6	equ	&ha00f+&hb00b
test7	equ	&h00f*&h00b
