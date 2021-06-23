;
;	Shift the 32bit working register right 8 bits (unsigned)
;

	.export shreax8

	.code

shreax8:
	tab
	ldaa @sreg+1
	psha
	ldaa @sreg
	staa @sreg+1
	clr sreg
	pula
	rts
