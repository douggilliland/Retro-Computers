;
;	Multiply D by 12
;

	.export mulax12

	.setcpu 6803
	.code

mulax12:
	asld			; x 2
	asld			; x 4
	std @tmp		; save
	asld			; x 8
	addd @tmp		; x 12
	rts
