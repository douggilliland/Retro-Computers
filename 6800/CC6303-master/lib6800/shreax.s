;
;	Shift the 32bit primary right one bit
;

	.export shreax1
	.export shreax2
	.export shreax3
	.export shreax4

	.code

shreax4:
	lsr @sreg
	ror @sreg+1
	rora
	rorb
shreax3:
	lsr @sreg
	ror @sreg+1
	rora
	rorb
shreax2:
	lsr @sreg
	ror @sreg+1
	rora
	rorb
shreax1:
	lsr @sreg
	ror @sreg+1
	rora
	rorb
	rts
