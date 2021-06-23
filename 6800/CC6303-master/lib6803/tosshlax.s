;
;	Shift TOS left by D
;
	.export tosshlax		; unsigned
	.export tosaslax		; signed
	.export pop2get

	.setcpu 6803
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
	ldd @zero
	std 2,x
shiftdone:
;
;	Like pop2 but used when the result ends up in situ
;
pop2get:
	pulx
	pula
	pulb
	jmp ,x
