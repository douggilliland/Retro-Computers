;
;	Shift the 32bit primary left 8bits
;

	.export asleax8
	.export shleax8

	.code

asleax8:
shleax8:
	psha
	ldaa @sreg+1
	staa @sreg
	pula
	staa @sreg+1
	tba
	clrb
	rts

	
