;
;	Right shift the 32bit working register
;
	.export asreax1
	.export asreax2
	.export asreax3
	.export asreax4
	.export asreax8

	.code

asreax8:
	tab
	ldaa @sreg+1
	psha
	ldaa @sreg
	staa @sreg+1
	; Now the sign 
	bpl signok
	ldaa #$FF
	staa @sreg
	pula
	rts
signok:
	clr @sreg
	pula
	rts
	
asreax4:
	asr @sreg
	ror @sreg+1
	rora
	rorb
asreax3:
	asr @sreg
	ror @sreg+1
	rora
	rorb
asreax2:
	asr @sreg
	ror @sreg+1
	rora
	rorb
asreax1:
	asr @sreg
	ror @sreg+1
	rora
	rorb
	rts
