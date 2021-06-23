;
;	Boolean negation for a long
;
	.export bnegeax

	.code

bnegeax:
	tsta
	bne nonz	; non zero
	tstb
	bne nonz	; non zero
	; A and B are thus both zero from here on
	cmpa @sreg
	bne nonz2
	cmpa @sreg+1
	bne nonz2
	incb		; to 1
	rts
nonz:	clra
	clrb
nonz2:
	rts
