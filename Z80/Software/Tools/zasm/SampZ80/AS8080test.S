	z80
	predef logic
testPB1	equ	((true)and(true))and(true) and (true)
testPB2	equ	((true) and(true))and (true) and true
testPB3	equ	((true)or(true))shl(true) shr (true)
testPB4	equ	((true) xor(true))imp (true) eqv true
testPB5	equ	((true)idiv(true))and(true) idiv (true)
testPB6	equ	((true) mod(true))and (true) mod true

	ifs_cs	xyz, eq, XYZ
	endif
	ifs_ncs	xyz, eq, XYZ
	endif
	ifs_cs	xyz, ne, XYZ
	endif
	ifs_ncs	xyz, ne, XYZ
	endif
	ifs_cs	xyz, neq, XYZ
	endif
	
	maclib	UnDocZ80
	lxi	ix,400h
	ixmov	h,l
	ixmov	b,h
	iysub	h
	ixmov	b,c
	iysub	c
	ixadd	l
	iysbb	h
WarnUDZ80	set -1
	ixadc	l
	ixmvi	h,50
	ixcmp	l
	iyxra	h
WarnUDZ80	set 0
	ixora	l
	ixinr	h
	iydcr	l
	lxi	iy,1000h
	;end
	predef 	all
	org	100h
testPi	i3ed	PI
testS	i3es	10.5,1,-5.5,-8
testD	i3ed	10.5,1,-5.5,-8
testSbe	i3es_be	10.5,1,-5.5,-8
testDbe	i3ed_be	10.5,1,-5.5,-8
	db	1 * 2^2 + 1 * 2^1 + 0* 2^0
	;end
test2	org	$
	.deg
	i3ed_be	sin(90)
	.rad
	i3ed_be	sin(deg2rad(90))
	db	0xdd
	mov	h,l
	db	0xdd
	mov	b,h
@sym	equ	4
* even though errors are generated, it produced what we wanted
	db	6 shl 2,6 shr 2, -6 shl 2, -6 shr 2
;try to get rid of errors
	db	6 shl 2,6 shr 2, s8(-6 shl 2), s8(-6 shr 2)
	dz	5,'test',5,"null"
	dc	8,"testz"
	dc	"testz",8
	db	'a'-'9','a''-''9','\a\'this\'is "string" data'
;	end
	mov	5 and @sym(x),a
	mov	(hl),a
	mov	m,a
	nolist
	mov	-5(ix),a
	mov	-5(x),a
	mov	-5(y),a
	list
	pop 	ix
	popiy
	push	x
	pop	a
	push	psw
	cpi	' '
	cpi	'+'
	cpi	'-'
	cpi	'*'
	cpi	'/'
	cpi	'|'
	cpi	'%'
	cpi	'<'
	cpi	'>'
	cpi	','
	mvi	a,','
	cpi	';'
;why no error ?
	cpi	'''
	cpi	''''
	cpi	'"'
	cpi	'_'
	cpi	'.'
	cpi	'$'
	cpi	'!'
	cpi	'&'
	cpi	'#'
	cpi	'='

;	end

value	equ 	8
true	equ	-1
sValue	set	4*dvalue
svalue1	set	value
dValue	equ	7.7	;equate to double precision float
aValue	equ	u8(7.7)	;convert to unsigned integer first
bValue	equ	s8(-7.7)
cValue	equ	u8(-7.7)

	dw	2
	dw	888^888 * 999 ^ 999
	dw	5 plus 4
	dw	( sin( x + y \ (dvalue mod 4) - 2 )   +   'g'  ) * ( '\r' or 0x80 )

DataA	org	2000h

	db	't'-'s','this ''is\' a test',"xxz",'\377','\377\377','ab'
	db	'\r\n','\aThis is "string" data','\r','\n','a'-'9','''','\'','a'
	db	9+4-6,0xff,'a',PI
Sixteen	dw	0aa55h,2000,01010101010101b,'g\n'	;Define Words
	dw	900+800-333,0xffff,9999999999999
	dw	PI,e,HalfPi,377Q,value,dValue

	if 	sValue
xxx1	db	aValue
	else
xxx1	db	(dValue*3)\2
	endif

	dw	(0xffff\16)*(4+3+9)
	dw 	(0xffff/16)*(4+3+9)
	dw	0ffffh\16
	dw	0xffff/16

test1	org	1800h
	mvi	b,not 6
	mvi	b,high 0xf1f2
	mov	b,4 + not 7(ix)
	mov	c,( 9 * 8 ) - 50 (iy)	;(ix) and (iy) cannot contain spaces
	mov	d,(0xff and not 5)(ix)
	mov	e,(0xff and not -5)(ix)
	mov	h,s8(0xffff xor 5)(ix)
	mov	cValue-4(ix),a
	ret

;Internally, all numbers are all handled as double precision 
;floating point. Symbols are stored as double precision values.
;Internally, logical operations and integer conversion functions 
;are converted by the implemetation to 32 bit signed 
;integers. All values returned to the assembler are truncated by
;the assembler to either 8 or 16 bit signed or unsigned
;numbers as needed, except for the EQU directive, which maintains 
;double precision and stores that in the symbol table.

data2	org	1400h

	db	355, 3.3, 355 and 0xff, 3.3 @ 0xff, 9999^9999
	db	hHigh(0xabcdef01),hLow(0xabcdef01),High(0xabcdef01),Low(0xabcdef01)
data	db	5, 0ah ,0xd3 ,'g',0101b,0377o,s8(17+sin(90)),-1	;Define bytes
data1	db	5 or 7,16+ not 5 and 0xff
OKnow	db	0x0d,0x0a,"\aThis \"is"" supported now!",0x0d,0x0a

place	ds	20	;reserves 20 byte of unintialized storage
Place	ds	30	;Place is different label than place

;these text directives should be replaced with the DB directive

RIGHT	text	"\aQuotes ("") can be used as \"quotes\"\r\n\0"
label26	textz	"This is ""terminated"" with a \"null\""
Label23	texts	"Last \"byte\" has sign bit set\r\n"
label24	text	"~!@#$%^&*()_+<>?{}|:>`/.,';\\" ;it works now
;can not replace this one
label25	text	kLetter \k is the quote chark

	db	"\aQuotes ("") can be used as \"quotes\"\r\n\0"
	dz	"This is ""terminated"" with a \"null\""
	dc	"Last \"byte\" has sign bit set\r\n"
	db	"~!@#$%^&*()_+<>?{}|:>`/.,';\\" ;it works now

start	org	0100h	;set origin(must NOT be forword ref)
	lxi	h,Sixteen and 0q17777 	;back ref OK
	mvi	a,value and 377o
	mvi	a,value + 2 AND 0xff	;
	lxi	hl,Ok1			;forward ref ok
; 
Ok1	ani	5 + value xor 0f0h and 0x0ff	; 
;
	rst	7
	rst	-2
	rst	9
forward equ	f1+f2+f3	;multiple forward refs ok
f3	equ	1+f2		; but adds a pass for each
f2	equ	1+f1
f1	equ	1

;conditional assembly is supported

true	equ	-1		;non zero is TRUE
false	equ	0		;zero is FALSE

test	equ	true

	iff	test	;if false
tttv	 equ	1234	
t111v	 equ	456
	else
tttv	 equ	4321	
t111v	 equ	654
	endif

testval	equ	0
	ifz	testval	;if zero
xyz	equ	4
	endif

	ifnz	testval	;not zero
xyz	equ	999
	endif

	if	(5+6)=(6\6+5*2) ;equal to not 0 or TRUE
	mov	01010101b(ix),d
	endif

	ifgt	5	;greater than 0
	mov	01010101b(ix),a
	endif

	iflt	5	;less than zero
	mov	6(ix),a
	endif

	ifle	4-5	;less than or equal zero
	mov	value+5(ix),b
	endif

	ifge	4-5	;greater than or equal zero
	mov	30h(ix),c
	endif

some	org	0x1000

..redef	equ	5
..redef	equ	6	;can re define symbol starting with ..

..loop	jmp	..loop
..loop 	jmp	..loop	; references last defined ..loop
	jmp	..whoa	; forward ref NOT of .. allowed
..whoa 	mvi	a,-10+40h-2+7	;unary - allowed

	Output: mvi c,2 ! call 5 ! rz	;muti-line
; label: can be indented if : present
;multiple instructions per line are allowed
lastLoc	equ 	$
	end	start