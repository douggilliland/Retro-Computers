;
;	Right shift the 32bit working register by 8
;
	.export asreax8

	.setcpu 6803

	.code

asreax8:
	psha		; Save low 8bits we need
	ldd @sreg	; Grab top 16
	staa @sreg+1	; Save the top 8 in the low 8 of sreg
	cmpa #$80	; Negative ?
	ldaa #0		; Clear top byte
	bcc positive
	coma		; Negative so set top byte for arithmetic shift
positive:
	staa @sreg	; Save sign bits
	tba		; Move low bits of original sreg to high of D
	pulb		; Recover old high of D in B
	rts

