;
;	6803 lacks xgdx...
;
	.setcpu 6803
	.code
	.export swapstk

swapstk:
	pulx
	stx @tmp
	psha
	pshb
	ldd @tmp
	rts
