;
;	Shift TOS left by D
;
	.export tosshlax		; unsigned
	.export tosaslax		; signed
	.export pop2get

	.code

; For 6303 it might be faster to load into D, shift in D using X as the
; count (as we can xgdx it in)
tosaslax:				; negative shift is not defined
					; anyway
tosshlax:
	clra				; shift of > 15 is meaningless
	cmpb #15
	bgt shiftout
	tsx
shloop:
	tstb
	beq shiftdone
	lsr 2,x
	ror 3,x
	decb
	bra shloop
shiftout:
	clra
	clrb
	staa 2,x
	stab 3,x
shiftdone:
pop2get:
	tsx				; no pulx on original 6800
	ldx ,x				; so do it by hand
	ins
	ins
	pula
	pulb
	jmp ,x
