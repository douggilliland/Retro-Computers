;
;	On entry X points to the object
;
	.code
	.export lsubeq
	.export lsubeqa
	.export lsubeqysp

; In this form X is the stack offset. Turn that into X is a pointer and
; fall into the static form
lsubeqysp:
	stx @tmp
	sts @tmp2
	ldaa @tmp2
	ldab @tmp2+1
	addb @tmp+1
	adca @tmp
	ldx @tmp
lsubeq:
	staa @tmp
	stab @tmp+1
	ldaa 5,x	; do the low 16bits
	ldab 6,x
	subb @tmp+1
	sbca @tmp
	staa 5,x
	stab 6,x
	ldaa 3,x
	ldab 4,x
	sbcb @sreg+1
	sbca @sreg
	staa 3,x
	stab 4,x
	ldaa 5,x
	ldab 6,x
	rts
lsubeqa:
	clr @tmp
	clr @tmp+1
	bra lsubeq
